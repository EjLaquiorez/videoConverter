# videoConverter

**One Windows batch menu** plus Markdown docs. It drives **FFmpeg** so you can resize batches of videos, join clips, trim by time, or export a short GIF—without typing long commands yourself.

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

Originals are **never** deleted. An existing `*_converted*` file with the same base name can be **overwritten** if you run the same operation again.

---

## Menu at a glance

| Key | Role |
|-----|------|
| **1** | Resize all **`.mkv` / `.mp4`** in the **current folder only** — presets **U / H / M / L**, **B** back. |
| **2** | Join — **N** numbered files, **A** all `.mkv` A–Z, **B** back; you set the output filename. |
| **3** | Trim — start/end `HH:MM:SS`; optional full path to source. |
| **4** | GIF — **S / M / L**, **B** back; duration is **seconds** (not end time). |
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

**Flow:** `setlocal EnableDelayedExpansion` → `pushd "%~dp0"` → FFmpeg gate → main loop (`:menu`) → tool labels (`:tool_resize`, …) → shared UI helpers.

**Worth knowing when editing:**

- **`choice` / `errorlevel`:** `if errorlevel N` is true for **N and any higher** code; branches are ordered **high → low** (e.g. 5 before 4) so the right option wins.
- **Colors:** `:color_main`, `:color_title`, `:color_info`, `:color_prompt`, `:color_run`, `:color_success`, `:color_error`, `:color_neutral` — whole-screen `color` attributes (not per-line ANSI).
- **Errors:** Short user cancels / validation failures use `:show_err_short` when appropriate; FFmpeg failures capture `%errorlevel%` **before** `:clean_progress` corrupts it.
- **Quoting:** Timecodes and paths passed to FFmpeg are **quoted** where user input can break parsing.
- **Compatibility:** Resize result messaging uses **nested** `if` / `else` (avoid `else if` for older `cmd` builds).
- **Validation (current behavior):** Join **N** must be a positive integer; trim requires start/end times; GIF duration must be a whole number **≥ 1**; empty GIF start defaults to **`0:00:00`**; resize reports when no `.mkv`/`.mp4` are present.

**Places to tune behavior:** Scale presets and `force_original_aspect_ratio=decrease` in `:tool_resize`; concat / copy flags in join; GIF `-vf` chains in `:tool_gif`.

**Testing:** No automated tests — use a scratch folder, small sample clips, and compare FFmpeg exit codes / output files.

---

## Good to know (everyone)

- **Join** usually needs matching resolution, frame rate, and codec settings for **stream copy** to succeed.
- **Resize** and **GIF** re-encode; **trim** and **join** prefer fast stream copy when possible.
- Logs use **`-loglevel error`**; for deep debugging, rerun the same FFmpeg line in a terminal with higher verbosity.

---

## License

No license is specified in this repository; treat as personal / use at your own risk unless you add one.
