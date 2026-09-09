# Security Policy

## Supported Versions

| Version | Supported |
|---------|----------|
| 0.1.x   | Yes       |

## Threat Model

Theatre runs on user-controlled devices. The primary threats are:

1. **Malicious HLS playlists** — segments must only be fetched over `http(s)://`.
   The HLS parser rejects `file://`, `data:`, and other non-HTTP schemes.

2. **Proxy token interception** — the loopback proxy is bound to `127.0.0.1` only,
   uses a 128-bit random per-launch token, and rejects all requests with
   wrong/missing tokens with `403 Forbidden`.

3. **SQL injection** — all queries use `rusqlite` prepared statements with
   parameterized bindings. No string-interpolated SQL is used.

4. **Path traversal** — download paths are confined to the configured
   `download_root`. `Content-Disposition` filenames are sanitised.
   Subtitle sibling detection stays within the video file’s directory.

5. **Header injection** — `reqwest` validates `HeaderValue` and rejects
   values containing CRLF, preventing HTTP response splitting.

6. **Dependency security** — `cargo audit` runs on every CI push.
   Dependabot is enabled for Cargo and pub dependencies.

## Reporting a Vulnerability

Do **not** open a public issue. Email: `security@theatre.example.com`
(replace with your actual address). You will receive a response within 48h.

We follow [Responsible Disclosure](https://cheatsheetseries.owasp.org/cheatsheets/Vulnerability_Disclosure_Cheat_Sheet.html).
