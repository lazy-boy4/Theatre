//! FFmpeg sidecar — tech-stack §5, architecture §9.3.
//! Located relative to the core library at runtime — never from PATH.
//! Remux only: -c copy, no transcoding.

use std::path::PathBuf;
use tokio::io::{AsyncBufReadExt, BufReader};
use tokio::process::Command;

pub struct FfmpegSidecar {
    binary: PathBuf,
}

impl FfmpegSidecar {
    /// Locate the ffmpeg binary relative to the current executable/library.
    pub fn locate() -> Option<Self> {
        // Strategy: check common relative locations
        let exe = std::env::current_exe().ok()?;
        let dir = exe.parent()?;

        #[cfg(target_os = "windows")]
        let candidates = ["ffmpeg.exe", "vendor/ffmpeg/ffmpeg.exe"];
        #[cfg(not(target_os = "windows"))]
        let candidates = ["ffmpeg", "vendor/ffmpeg/ffmpeg", "../vendor/ffmpeg/ffmpeg"];

        for candidate in &candidates {
            let path = dir.join(candidate);
            if path.exists() {
                return Some(Self { binary: path });
            }
        }
        None
    }

    pub fn from_path(path: PathBuf) -> Self {
        Self { binary: path }
    }

    /// Remux `input` into `output` using -c copy.
    /// Tries MP4 first; falls back to MKV if codecs require it.
    pub async fn remux(&self, input: &str, output: &str) -> std::result::Result<(), String> {
        // Determine format from output extension
        let ext = std::path::Path::new(output)
            .extension()
            .and_then(|e| e.to_str())
            .unwrap_or("mp4");

        let result = self.run_ffmpeg(input, output, ext).await;
        if result.is_err() && ext == "mp4" {
            // MKV fallback
            let mkv_output = output.replace(".mp4", ".mkv");
            return self.run_ffmpeg(input, &mkv_output, "matroska").await;
        }
        result
    }

    async fn run_ffmpeg(
        &self,
        input: &str,
        output: &str,
        format: &str,
    ) -> std::result::Result<(), String> {
        let mut child = Command::new(&self.binary)
            .args([
                "-y",
                "-i",
                input,
                "-c",
                "copy",
                "-movflags",
                "+faststart",
                "-progress",
                "pipe:1",
                "-f",
                format,
                output,
            ])
            .stdout(std::process::Stdio::piped())
            .stderr(std::process::Stdio::piped())
            .spawn()
            .map_err(|e| format!("spawn ffmpeg: {}", e))?;

        // Drain stdout (progress) in background
        if let Some(stdout) = child.stdout.take() {
            tokio::spawn(async move {
                let mut lines = BufReader::new(stdout).lines();
                while let Ok(Some(_)) = lines.next_line().await {}
            });
        }

        let status = child
            .wait()
            .await
            .map_err(|e| format!("wait ffmpeg: {}", e))?;

        if status.success() {
            Ok(())
        } else {
            Err(format!("ffmpeg exited with {}", status))
        }
    }
}
