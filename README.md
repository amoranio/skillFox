# Skillfox

Skillfox is a native macOS menu bar app for viewing AI Agent skills by provider.

## What it does

- Shows skills for enabled providers in a compact menu window.
- Supports provider modules for:
  - Claude
  - Copilot
  - Codex
  - Gemini
  - Antigravity
  - OpenCode
- Reads skills from provider skill directories (for example `~/.claude/skills`).
- Includes workspace + user/global directory patterns for Gemini, Antigravity, and OpenCode.
- Extracts per-skill description snippets from `SKILL.md`:
  - prefers YAML frontmatter `description:`
  - falls back to first body paragraph
- Lets users open a skill source file (`SKILL.md`) via an inline **Open** link.
- Settings allow enabling/disabling providers and hiding empty providers.
- Right-clicking the menu bar icon shows:
  - Open Skillfox
  - Quit Skillfox

## Requirements

- macOS 14+
- Swift 6.2 toolchain (Xcode with SwiftPM support)

## Install (end users)

1. Download the latest release artifact (`.dmg` or `.zip`).
2. If using DMG, open it and drag `Skillfox.app` to `Applications`.
3. Launch `Skillfox.app`.

## Build and run (development)

```bash
swift build
./Scripts/package_app.sh release
open Skillfox.app
```

## Release packaging (v1 distribution)

Create distributable artifacts:

```bash
./Scripts/package_release.sh 1.0.0
```

This produces:

- `dist/Skillfox-v1.0.0-macos-<arch>.zip`
- `dist/Skillfox-v1.0.0-macos-<arch>.dmg`
- SHA256 files for both artifacts

## Icons

### Menu bar icon

- Source resource: `Sources/Skillfox/Resources/skillfox.png`
- Current workflow uses `Icons/3.png` copied into that path.

### App icon (Finder / app bundle)

- Generated during packaging by `Scripts/package_app.sh` into `Icon.icns`
- Embedded in `Skillfox.app/Contents/Resources/Icon.icns`
- Default source: `Icons/3.png`
- Override source for packaging:

```bash
SKILLFOX_APP_ICON=/absolute/path/to/icon.png ./Scripts/package_app.sh release
```

## Project structure

- `Sources/Skillfox/Providers/` – provider definitions and catalog
- `Sources/Skillfox/Support/SkillDirectoryScanner.swift` – skill discovery + snippet extraction
- `Sources/Skillfox/Views/` – menu and settings UI
- `Scripts/package_app.sh` – builds `Skillfox.app`
- `Scripts/package_release.sh` – builds release artifacts in `dist/`
