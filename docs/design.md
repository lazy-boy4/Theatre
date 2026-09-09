---
name: Theatre
description: "MovieBox-TUI's engine, with a face — finds it, plays it, downloads it, and plays what you already have."
colors:
  primary: "#E8B44A"
  error: "#BA1A1A"
  surface: "#131313"
typography:
  display:
    fontFamily: "System sans (Roboto / system default)"
    fontWeight: 700
  body:
    fontFamily: "System sans (Roboto / system default)"
    fontWeight: 400
    lineHeight: 1.4
  label:
    fontWeight: 600
    letterSpacing: 1
rounded:
  sm: "4px"
  md: "8px"
  lg: "10px"
  xl: "12px"
  sheet: "16px top"
spacing:
  xs: "4px"
  sm: "8px"
  md: "12px"
  lg: "16px"
  xl: "20px"
  xxl: "24px"
  xxxl: "32px"
components:
  button-primary:
    backgroundColor: "{colors.primary}"
    rounded: "{rounded.lg}"
    padding: "14px vertical"
  chip-info:
    backgroundColor: "surface-container-highest"
    rounded: "{rounded.sm}"
---

# Design System: Theatre

**Status:** Living spec. Created from the M3E reworld pass (critique → harden/layout/adapt/document/polish).
**Related:** `prd.md` (F4 adaptive M3E UI) · `architecture.md` §14 · `../app/lib/design/` (token layer — normative for values)

## Overview

**Creative North Star: "The Honest Projector"**

Theatre is an Operate surface: the visitor completes a task (search → play → download → resume), and the tool disappears into it. The visual world is a dark cinema with one warm light — projector amber — spent only on action, progress, and selection. Everything else is tonal dark neutrals and M3 type. The brand's honesty is structural: expiring links, degraded sources, and partial results are designed states with recovery, not failures with apologies. If Netflix sells certainty, Theatre designs for the 403.

**Key Characteristics:**
- Dark-first, single-accent, tonal (not shadowed) depth.
- One family, tight M3 type scale; hierarchy from weight/size, never color alone.
- States before decoration: every async surface ships loading, error+retry, and empty-with-next-action.
- Copy names the problem and the recovery in plain language; no ticket numbers, no `toString()` dumps.

## Colors

Projector amber on near-black; red is reserved for failure and destruction.

### Primary
- **Projector Amber** (#E8B44A, seed in `theatreTheme()`): Play buttons, progress bars, selection indicators, active nav indicator (`primaryContainer`). The only saturated voice on any screen.

### Secondary (omitted)
Single-accent system by decision; status uses the semantic set below, not a second brand hue.

### Neutral
- **House Black** (#131313 family, M3 `surface`/`surfaceContainer*` from seed): app background, cards (`surfaceContainerHighest`), sheets/dialogs (`surfaceContainerHigh`), nav surfaces (`surfaceContainer`).
- **On-surface text**: full `onSurface` for titles/body; `onSurfaceVariant` for secondary text (dates, sizes, hints) — dim-white literals (`white38/white24`) are banned: they fail contrast at small sizes.

### Status vocabulary (Operate semantic set)
- Working (downloading, resolving): primary.
- Waiting (queued, paused): amber.
- Failed: `error` / `errorContainer`. Quality badges, progress, and spinners are never red.
- Done: green. Cancelled/inert: `onSurfaceVariant`.

### Named Rules
**The One Voice Rule.** The most saturated color on any screen carries exactly one meaning. Amber = do/going. Red = broken/destructive. If red means everything, it signals nothing.
**The Scrim Rule.** Text over artwork sits on a black scrim or a tinted container — never bare on a busy frame.

## Typography

**Display/Body/Label Font:** system sans (Roboto / platform default) with platform fallback. One family is right for product UI (operate depth).

**Character:** quiet and utilitarian; weight steps do the talking.

### Hierarchy
- **Display** (700, 24, 1.2): app titles (`Theatre`).
- **Headline/Title** (600, M3 `titleLarge`/`titleMedium`): section headers (`Browse`, `Continue Watching`, `About`, `Episodes`).
- **Body** (400, M3 `bodyMedium`, 1.4): descriptions, empty-state coaching, error explanations.
- **Label** (600, 11, uppercase, +1 tracking, primary-colored): settings section headers only. No eyebrow kickers anywhere else.

### Named Rules
**The No-Dump Rule.** Error and empty copy is written for the persona (Couch Streamer first), never forwarded from an exception. Every error names the problem, the next step, and preserves the user's place.
**The Named-Language Rule.** Language codes never ship bare: `subtitleLabel()` maps codes to display names (`Bengali (বাংলা)`).

## Layout

Spatial thesis: one primary path per screen, decided above the fold; disclosure before commitment (source × quality × subtitle above Play); pipeline transparency where work happens (Downloads tile: object → state → evidence → action).

- 4-unit spacing scale `TSpace` (4/8/12/16/20/24/32); tight groups (`sm/md`), generous separation (`lg/xxl`); more space above a heading than below it.
- Detail: source/quality/subtitle chips → Play/Download → meta → about → episodes.
- Player: top bar (back + title + quality + speed) → center play/pause → seek + asymmetric skips (−10s/+30s).
- Responsive is structural per `AdaptiveShell` (Bar <600dp → Rail <1200dp → Drawer): same five destinations everywhere (Home, Search, Downloads, Library, History); Settings lives in the drawer as app-level chrome. Never hide a core destination on a smaller class.
- Touch: 48dp targets (IconButton defaults; no `size: 20` overrides); thumb-zone placement for primary actions on phone.

## Elevation & Depth

Flat-by-default with tonal layering; no drop shadows in the system. Depth = surface-container steps + scrims over artwork. Sheets use the M3 top radius (16px), not shadows, to separate.

**The Flat-By-Default Rule.** Surfaces are flat at rest. Blur/scrim appears only over video/artwork for legibility.

## Shapes

- Cards/tiles: 8–12px radius (posters 8, tiles 10, banner 12).
- Chips: 4–8px. Pills are for small controls only (status chips).
- Bottom sheets: 16px top radius. Dialogs: M3 default.

## Components

### Buttons
- **Primary** (`FilledButton`, radius lg, 14px vertical padding): the one primary action per view (Play, Retry, Get a fresh link).
- **Secondary** (`OutlinedButton`): Download beside Play, dialog/sheet alternatives.
- Character: tactile and confident; full-width in error panels.

### Chips
- **Info** (`Chip`, surfaceContainerHighest, 4px): metadata (year, rating, duration, genre), subtitle state.
- **Action** (`ActionChip`, with icon + tooltip): source (health-dot avatar), quality. Tapping opens a bottom-sheet picker — choice happens before the costly resolve.

### Sheets & Dialogs
- Single-select options (quality, source, speed, settings lists) use `_OptionSheet`-style bottom sheets: title + checkmarked rows + full height safety (`Flexible` + shrink-wrap). `showMenu` with magic rects is banned (breaks RTL/foldables/desktop).
- Destructive choices (clear history, detach folder) use confirm dialogs with counts and consequences named (`Clear 214 items?`, `Files on disk stay untouched`).

### Player
- States: loading shimmer/spinner → ready controls → error panel (`_ErrorPanel`): cause-specific copy + [Get a fresh link] (force re-resolve) + [Retry] + [Details]. Auto-hide (4s) fires only in ready state.
- Skips −10s/+30s at 32px; timestamps 13px full-white; buffering spinner inline by the duration; slider in primary with announced values.

### Navigation
- Five first-class destinations; History is a tab, not a drawer exile. Back buttons appear only on pushed routes (`SearchScreen.isTab` suppresses back + autofocus in tab context). Loading dialogs are non-dismissible and always popped on every exit path.

### History & Resume
- Tap-to-resume everywhere (continue cards show `Xm left` + progress; history tiles resolve-and-play via shared `playContent()`). Local (`local` source) entries bypass resolving and play `file://` directly.
- Swipe-delete offers Undo (re-record); Clear-all confirms with count. Deletion never strands: snackbar names what was removed.

## Do's and Don'ts

### Do:
- **Do** spend amber only on action/progress/selection; spend red only on failure/destruction.
- **Do** resolve on intent (tap), never on view (PRD §8: resolve-on-play/download, never on search).
- **Do** route every new screen through `theatreTheme()` + `TSpace`; add the token if the system needs a reusable value.
- **Do** give every icon-only control a tooltip and every tappable card a semantic label.
- **Do** keep the partial-results banner pattern for degraded states: name what's wrong, keep working.

### Don't:
- **Don't** hardcode `Colors.*` for chrome or text in screens — read the theme.
- **Don't** ship a control that discards its result (variant pickers that don't re-resolve, banners that don't navigate, buttons with `TODO` bodies). Disabled-with-reason beats fake affordance.
- **Don't** expose engine vocabulary (`segs`, `auth headers`, ticket IDs, raw exceptions) or fake success (snackbars for work that never started).
- **Don't** lock orientation to dodge a layout bug; handheld users rotate, desktop windows stay put.
- **Don't** split basenames by `/` only — match `[/\\]` (Windows paths exist).
