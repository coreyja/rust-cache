extern crate flate2;
extern crate futures;
extern crate rusoto_core;
extern crate rusoto_s3;
extern crate tar;

use flate2::read::GzDecoder;
use flate2::write::GzEncoder;
use flate2::Compression;
use rusoto_core::Region;
use rusoto_s3::{GetObjectRequest, HeadObjectRequest, PutObjectRequest, S3Client, S3};
use std::env;
use std::fs::File;
use std::io::prelude::*;
use tar::Archive;

fn create_tar(dirs: &Vec<&str>, mut vec: &mut Vec<u8>) -> Result<(), std::io::Error> {
    let enc = GzEncoder::new(&mut vec, Compression::default());
    let mut tar = tar::Builder::new(enc);
    for dir in dirs {
        println!("Taring dir... {}", dir);
        tar.append_dir_all(&dir, &dir)?;
    }

    Ok(())
}

fn get_cache_filename(cache_s3_path: &str, cache_key_file: &str) -> Result<String, std::io::Error> {
    let mut file = File::open(cache_key_file)?;
    let mut cache_key = String::new();
    {
        file.read_to_string(&mut cache_key)?;
    }

    let path = format!(
        "{path}{filename}.tar.gz",
        path = cache_s3_path,
        filename = cache_key.trim(),
    );

    Ok(path)
}

fn upload_dir(bucket_name: &str, cache_path: &str) -> Result<(), std::io::Error> {
    let mut contents: Vec<u8> = Vec::new();

    {
        let cache_local_paths_string =
            env::var("CACHE_LOCAL_DIR").expect("No local cache dir specified");
        let cache_local_paths: Vec<&str> = cache_local_paths_string.split(",").collect();
        create_tar(&cache_local_paths, &mut contents)?;
        println!("Tar created. Uploading...");
    }

    {
        let client = S3Client::new(Region::UsEast1);
        let req = PutObjectRequest {
            bucket: bucket_name.to_string(),
            key: cache_path.to_string(),
            body: Some(contents.into()),
            ..Default::default()
        };
        let result = client.put_object(req).sync().expect("Couldn't PUT object");
        println!("{:#?}", result);
    }

    Ok(())
}

fn does_cache_file_exist(path: String, bucket: String) -> bool {
    let client = S3Client::new(Region::UsEast1);
    let req = HeadObjectRequest {
        bucket: bucket,
        key: path,
        ..Default::default()
    };

    match client.head_object(req).sync() {
        Ok(_) => true,
        _ => false,
    }
}

fn download_and_restore_cache(bucket: String, path: String) -> Result<(), std::io::Error> {
    let client = S3Client::new(Region::UsEast1);
    let req = GetObjectRequest {
        bucket: bucket,
        key: path,
        ..Default::default()
    };

    match client.get_object(req).sync() {
        Ok(object_output) => {
            let tar = GzDecoder::new(
                object_output
                    .body
                    .expect("Error opening body of cache file")
                    .into_blocking_read(),
            );
            let mut archive = Archive::new(tar);
            archive.unpack(".")?;
        }
        _ => panic!("Error downloading cache file"), // FixMe: This should return an error
    };

    Ok(())
}

fn download(bucket: String, path: String) -> Result<(), std::io::Error> {
    if does_cache_file_exist(path.clone(), bucket.clone()) {
        println!("Cache file found, downloading and restoring: {}", path);
        download_and_restore_cache(bucket.clone(), path.clone())
    } else {
        println!("No Cache File Found");
        Ok(())
    }
}

fn upload(bucket: String, path: String) -> Result<(), std::io::Error> {
    if does_cache_file_exist(path.clone(), bucket.clone()) {
        println!("Cache file already exists, not uploading");
        Ok(())
    } else {
        println!("Uploading new Cache");
        upload_dir(&bucket, &path)
    }
}

fn main() -> Result<(), std::io::Error> {
    let bucket_name = env::var("CACHE_BUCKET").expect("No bucket name provided");
    let cache_key_file = env::var("CACHE_KEY_FILE").unwrap_or(".cache_key".to_string());
    let cache_s3_path = env::var("CACHE_S3_PATH").unwrap_or("".to_string());
    let should_download = env::var("CACHE_DOWNLOAD").is_ok();

    let path = match get_cache_filename(&cache_s3_path, &cache_key_file) {
        Ok(p) => p,
        Err(e) => panic!("Unable to read cache key {}", e),
    };

    if should_download {
        download(bucket_name.clone(), path.clone())
    } else {
        upload(bucket_name.clone(), path.clone())
    }
}
