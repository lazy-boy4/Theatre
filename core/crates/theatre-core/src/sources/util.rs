//! Shared scraper helpers — one copy of the parsing primitives every
//! source needs (year/quality/filename normalization).

/// First 4-digit year in `1900..=2100` (handles "2010-07-16", "2010").
pub(crate) fn extract_year(s: &str) -> Option<u16> {
    let b = s.as_bytes();
    for i in 0..b.len().saturating_sub(3) {
        if b[i].is_ascii_digit()
            && b[i + 1].is_ascii_digit()
            && b[i + 2].is_ascii_digit()
            && b[i + 3].is_ascii_digit()
        {
            if let Ok(y) = s[i..i + 4].parse::<u16>() {
                if (1900..=2100).contains(&y) {
                    return Some(y);
                }
            }
        }
    }
    None
}

/// Canonical quality label found in a release name, if any.
pub(crate) fn detect_quality(name: &str) -> Option<String> {
    let l = name.to_ascii_lowercase();
    if l.contains("2160p") || l.contains(" 4k") || l.contains("[4k") || l.contains("(4k") {
        Some("2160p".into())
    } else if l.contains("1080p") {
        Some("1080p".into())
    } else if l.contains("720p") {
        Some("720p".into())
    } else if l.contains("480p") {
        Some("480p".into())
    } else {
        None
    }
}

/// Sort key for release names (higher = better).
pub(crate) fn quality_rank(name: &str) -> u32 {
    match detect_quality(name).as_deref() {
        Some("2160p") => 4,
        Some("1080p") => 3,
        Some("720p") => 2,
        Some("480p") => 1,
        _ => 0,
    }
}

/// Filename-safe title (`".mp4"` suffixed, never a path).
pub(crate) fn sanitize_filename(name: &str) -> String {
    let s: String = name
        .chars()
        .map(|c| {
            if c.is_alphanumeric() || c == '.' || c == '-' || c == '_' || c == ' ' {
                c
            } else {
                '_'
            }
        })
        .collect();
    format!("{}.mp4", s.trim())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn year_shapes() {
        assert_eq!(extract_year("2010-07-16"), Some(2010));
        assert_eq!(extract_year("Released 1999"), Some(1999));
        assert_eq!(extract_year("nope"), None);
        assert_eq!(extract_year("12345"), None);
    }

    #[test]
    fn quality_ladder() {
        assert_eq!(detect_quality("X.2160p.WEB"), Some("2160p".into()));
        assert_eq!(detect_quality("X 4K HDR"), Some("2160p".into()));
        assert_eq!(detect_quality("X.1080p"), Some("1080p".into()));
        assert!(quality_rank("A.2160p") > quality_rank("B.1080p"));
        assert_eq!(quality_rank("cam"), 0);
    }

    #[test]
    fn traversal_stripped() {
        let evil = "../../../etc/passwd";
        let clean = sanitize_filename(evil);
        assert!(!clean.contains('/'));
        assert!(clean.ends_with(".mp4"));
    }
}
