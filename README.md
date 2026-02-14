# Skillfox

Skillfox is a native macOS menu bar app for viewing AI Agent skills by provider.
![skillFox](https://raw.githubusercontent.com/amoranio/skillFox/refs/heads/main/Icons/skillfox.jpg)

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

