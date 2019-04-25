extern crate flate2;
extern crate futures;
extern crate rusoto_core;
extern crate rusoto_s3;
extern crate tar;

use flate2::write::GzEncoder;
use flate2::Compression;
use rusoto_core::Region;
use rusoto_s3::{PutObjectRequest, S3Client, S3};
use std::env;
use std::fs::File;
use std::io::prelude::*;

fn create_tar(dir: &str, mut vec: &mut Vec<u8>) -> Result<(), std::io::Error> {
    let enc = GzEncoder::new(&mut vec, Compression::default());
    let mut tar = tar::Builder::new(enc);
    tar.append_dir_all(&dir, &dir)?;

    Ok(())
}

fn upload_dir(
    bucket_name: &str,
    cache_key_file: &str,
    cache_s3_path: &str,
) -> Result<(), std::io::Error> {
    let mut contents: Vec<u8> = Vec::new();

    {
        let cache_local_path = env::var("CACHE_LOCAL_DIR").expect("No local cache dir specified");
        create_tar(&cache_local_path, &mut contents)?;
    }

    {
        // let bucket_name = env::var("CACHE_BUCKET").expect("No bucket name provided");
        // let cache_key_file = env::var("CACHE_KEY_FILE").unwrap_or(".cache_key".to_string());
        // let cache_s3_path = env::var("CACHE_S3_PATH").unwrap_or("./".to_string());

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
        let client = S3Client::new(Region::UsEast1);
        let req = PutObjectRequest {
            bucket: bucket_name.to_string(),
            key: path,
            body: Some(contents.into()),
            ..Default::default()
        };
        let result = client.put_object(req).sync().expect("Couldn't PUT object");
        println!("{:#?}", result);
    }

    Ok(())
}

fn main() -> Result<(), std::io::Error> {
    let bucket_name = env::var("CACHE_BUCKET").expect("No bucket name provided");
    let cache_key_file = env::var("CACHE_KEY_FILE").unwrap_or(".cache_key".to_string());
    let cache_s3_path = env::var("CACHE_S3_PATH").unwrap_or("".to_string());

    upload_dir(&bucket_name, &cache_key_file, &cache_s3_path)
}
