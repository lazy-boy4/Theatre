# Contributing to Theatre

**Before contributing, read [AGENTS.md](AGENTS.md) in full.**
It governs how all work — human and AI — is performed in this repository.

## Quick Rules
1. No new dependency without a `tech-stack.md` entry in the same PR.
2. Never import `material_3_expressive` or `material` directly in `lib/features/`.
3. Scraper tests must never hit the live network — fixtures only.
4. Gates (`Gate-Mx` in `roadmap.md`) are passed by the maintainer only.
5. Conventional commits: `feat(core): …`, `fix(ui): …`, `chore: …`

## Getting Started
See [AGENTS.md §3](AGENTS.md) for the session lifecycle.
