# videoConverter

**One Windows batch menu** plus Markdown docs. It drives **FFmpeg** so you can resize a whole folder of videos, join clips, trim by time, or export a short GIF — without typing long commands yourself.

| If you are… | Start here |
|-------------|------------|
| **New to the tool** | Read this page through **“Good to know”**, then open **[INSTRUCTIONS.md](INSTRUCTIONS.md)** for detailed install and usage steps. |
| **Maintaining or changing the script** | Skim **For developers** below, then read **`FOR FFMPEG.bat`** (section comments mark each tool). Ideas backlog: **[FUTURE_IMPROVEMENTS.md](FUTURE_IMPROVEMENTS.md)**. |

---

## What you run

- **`FOR FFMPEG.bat`** — The only executable “app”. Double-click it or run it from a folder that contains your media (it `pushd`s to the script folder when launched from Explorer).

Everything else is documentation.

---

## Before you start

1. **Windows** — Uses `cmd` features such as `choice` and `call :label`. Not intended for macOS/Linux as-is.

2. **FFmpeg on `PATH`** — The script runs `where ffmpeg` at startup. It **does not** ship or install FFmpeg. If FFmpeg is missing you get a **red** screen; fix **PATH**, then open a **new** terminal session. [FFmpeg download](https://ffmpeg.org/download.html).

---

## Getting started (beginners)

1. Install FFmpeg and check **`ffmpeg -version`** in Command Prompt.
2. Put **`FOR FFMPEG.bat`** in the **same folder** as your videos (simplest workflow).
3. **Double-click** the `.bat` and use number keys **1**–**5** when prompted.
4. Use **5** to exit. Inside a sub-tool, **B** usually means **Back** without running a job.

Full walkthrough and troubleshooting: **[INSTRUCTIONS.md](INSTRUCTIONS.md)**.

---

## Output file names

| Action | Output |
|--------|--------|
| Resize or trim | `basename_converted` + same extension as the source |
| GIF | `basename_converted.gif` |
| Join | **You choose** the name (default suggestion in script: `vc_joined.mkv`) |

Originals are **never** deleted. If `basename_converted.ext` already exists, running the same job again **overwrites** that converted file. **Resize** also **skips** any **source** whose base name already ends in `_converted`, so a batch pass won’t re-encode its own outputs.

---

## Menu at a glance

| Key | Role |
|-----|------|
| **1** | Resize all **`.mkv` / `.mp4`** in the **current folder only** (skips `*_converted` sources) — **U** 4K, **H** 1080p, **M** 720p, **L** 360p, **B** back. |
| **2** | Join — **N** numbered files, **A** all `.mkv` A–Z, **B** back; you set the output filename. |
| **3** | Trim — start/end `HH:MM:SS`; source name or full path. |
| **4** | GIF — **S** 240px / **M** 320px / **L** 480px, **B** back; duration in **seconds** (not end time). |
| **5** | Exit |

Letter keys are shown on each screen; behavior matches **`FOR FFMPEG.bat`** (source of truth if docs drift).

---

## Repository layout

| Path | Audience |
|------|----------|
| `FOR FFMPEG.bat` | Everyone — the tool. |
| [INSTRUCTIONS.md](INSTRUCTIONS.md) | Beginners — step-by-step usage and FFmpeg on Windows. |
| [FUTURE_IMPROVEMENTS.md](FUTURE_IMPROVEMENTS.md) | Developers — non-binding ideas and possible enhancements. |
| `README.md` | Everyone — orientation and technical overview. |

---

## Helper files the script writes

Names are defined at the top of **`FOR FFMPEG.bat`** as **`VC_PROGRESS`** and **`VC_JOINLIST`** (default: `progress.txt`, `joinlist.txt`). They are deleted when each step finishes (or after a join attempt). Safe to ignore unless debugging.

---

## For developers

**Stack:** Windows **batch** + **FFmpeg CLI**. No package manager, no build step, no runtime beyond `ffmpeg` on `PATH`.

**Flow:** `setlocal EnableDelayedExpansion` → `mode con: cols=90 lines=42` (forces a fixed window) → `pushd "%~dp0"` → FFmpeg gate (`where ffmpeg`) → main loop (`:menu`) → tool labels (`:tool_resize`, …) → shared UI helpers.

**Worth knowing when editing:**

- **`choice` / `errorlevel`:** `if errorlevel N` is true for **N and any higher** code, so branches are ordered **high → low** (e.g. 5 before 4) to make the right option win.
- **Colors:** `:color_main`, `:color_title`, `:color_info`, `:color_prompt`, `:color_run`, `:color_success`, `:color_error`, `:color_neutral` — whole-screen `color` attributes (not per-line ANSI).
- **Errors:** Short user cancels and validation failures call `:show_err_short`; FFmpeg failures capture `%errorlevel%` **before** `:clean_progress` runs, since helper calls reset it.
- **Quoting:** Timecodes and paths passed to FFmpeg are **quoted** wherever user input could break parsing.
- **Compatibility:** Resize result messaging uses **nested** `if` / `else` (avoid `else if` for older `cmd` builds).
- **Validation (current behavior):** Join **N** must be a positive integer; trim requires both start and end times; GIF duration must be a whole number **≥ 1**; an empty GIF start defaults to **`0:00:00`**; resize **skips** sources ending in `_converted`, ignores missing `*.mkv` / `*.mp4` wildcard slots (`if exist "%%~fA"`), and reports when nothing remains to process.

**Places to tune behavior:** Scale presets and `force_original_aspect_ratio=decrease` in `:tool_resize`; the `findstr /i /r "_converted$"` skip filter and per-file `if exist` guard in the resize loop; concat / `-c copy` flags in join; GIF `-vf` chains (fps + scale) in `:tool_gif`.

**Testing:** No automated tests — use a scratch folder, small sample clips, and compare FFmpeg exit codes / output files.

---

## Good to know (everyone)

- **Join** needs all clips to share resolution, frame rate, and codec settings for **stream copy** (`-c copy`) to succeed; otherwise FFmpeg errors out and nothing is saved.
- **Resize** and **GIF** re-encode; **trim** and **join** use stream copy, so trim cuts snap to the nearest keyframe in the source.
- **Resize** only looks in the script folder (not subfolders). A folder with only `.mp4` or only `.mkv` files is fine.
- Logs use **`-loglevel error`**, so the screen stays quiet on success. For deep debugging, rerun the same FFmpeg line in a terminal with higher verbosity (e.g. `-loglevel info`).

**Troubleshooting:** see **[INSTRUCTIONS.md §10](INSTRUCTIONS.md#10-if-something-goes-wrong)** (PATH, join compatibility, trim times, sparse FFmpeg output).

---

## License

No license is specified in this repository; treat as personal / use at your own risk unless you add one.
