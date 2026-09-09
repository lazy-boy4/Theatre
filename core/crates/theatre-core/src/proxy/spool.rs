//! Spool file streaming with backpressure for HLS proxy serving.

use futures::stream::{self, Stream};
use std::path::Path;
use std::pin::Pin;
use tokio::fs::File;
use tokio::io::AsyncReadExt;

pub type ByteStream = Pin<Box<dyn Stream<Item = Result<bytes::Bytes, std::io::Error>> + Send>>;

/// Stream a spool file from `offset`, reading available bytes.
/// If the file doesn't exist yet, returns an empty stream.
pub async fn serve_spool_range(path: &str, offset: u64) -> Result<ByteStream, std::io::Error> {
    if !Path::new(path).exists() {
        return Ok(Box::pin(stream::empty()));
    }
    let mut file = File::open(path).await?;
    if offset > 0 {
        use tokio::io::AsyncSeekExt;
        file.seek(std::io::SeekFrom::Start(offset)).await?;
    }
    let s = async_stream::stream! {
        let mut buf = vec![0u8; 65536];
        loop {
            match file.read(&mut buf).await {
                Ok(0) => break,
                Ok(n) => yield Ok(bytes::Bytes::copy_from_slice(&buf[..n])),
                Err(e) => { yield Err(e); break; }
            }
        }
    };
    Ok(Box::pin(s))
}
