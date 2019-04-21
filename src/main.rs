extern crate flate2;
extern crate tar;

use flate2::write::GzEncoder;
use flate2::Compression;
use std::fs::File;

fn main() -> Result<(), std::io::Error> {
    let tar_gz = File::create("archive.tar.gz")?;
    let enc = GzEncoder::new(tar_gz, Compression::default());
    let mut tar = tar::Builder::new(enc);
    tar.append_dir_all("./cache", "./cache")?;
    Ok(())
}
