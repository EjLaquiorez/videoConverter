# Future development and improvements

Ideas for evolving **videoConverter** (`FOR FFMPEG.bat` and docs). Nothing here is committed work—use it as a backlog or design scratchpad.

**Source of truth for behavior:** `FOR FFMPEG.bat`. **README.md** = overview; **INSTRUCTIONS.md** = step-by-step; this file = backlog only.

---

## Recently shipped

- **Batch resize wildcard safety (May 14, 2026)** — Resize skips non-existent `*.mkv` / `*.mp4` wildcard slots (`if exist "%%~fA"`) and sources whose base name already ends in `_converted`, so a folder with only one extension type no longer false-fails and batch runs do not re-encode prior outputs.
- **Script hardening (May 14, 2026)** — `VC_PROGRESS` / `VC_JOINLIST` temp names, `:show_err_short` for validation, FFmpeg `%errorlevel%` captured before `:clean_progress`, quoted paths/timecodes, nested `if`/`else` for resize results (older `cmd` friendly).
- **Docs sync (May 14, 2026)** — README and INSTRUCTIONS aligned on overwrite vs skip, resize presets (U/H/M/L, S/M/L widths), wildcard note, join/trim/GIF caveats, and README → INSTRUCTIONS §10 troubleshooting link.

---

## User experience

- **Drag-and-drop** — Accept a video path as `%1` when the user drops a file onto the `.bat`, then jump to trim or GIF with that path pre-filled.
- **Output folder** — Optional subfolder (e.g. `converted\`) so outputs never sit mixed with sources unless the user wants that.
- **Overwrite guard** — Prompt or skip when `basename_converted.ext` already exists (resize / trim / GIF). Today the converted file is silently overwritten; docs describe this, the script does not ask.
- **Progress display** — The script already writes `progress.txt` via `-progress` but nothing reads it. Parse `out_time_ms` / `total_size` and print a single-line `[xx%] elapsed=… size=…` so batch runs feel less silent without enabling FFmpeg’s default chatter.
- **Help on demand** — A `?` key at any prompt that prints a longer help paragraph (durations, paths, examples) without leaving the tool. Keeps the on-screen text short by default.
- **Sticky last choice** — Remember the last preset (`U/H/M/L`, `S/M/L`) in a tiny `vc_settings.ini` next to the script and pre-select it on the next run.
- **Window size** — `mode con: cols=90 lines=42` is forced on every launch even when started from an already-sized console. Skip the resize when `%CMDCMDLINE%` indicates the script was invoked from an existing shell.
- **Locale** — If the audience grows, short translated hint blocks or an external `strings` file (harder in pure `.cmd`).

## Join (concat)

- **All `.mp4`** mode alongside “all `.mkv`” and numbered sequences.
- **Validate numbered mode** — Check that `1.ext` … `N.ext` exist before calling FFmpeg; print which ones are missing.
- **Re-encode join** — Optional path when `-c copy` fails (same resolution, one encoder) so mismatched clips can still be merged — slower but more forgiving.
- **Preview the list** — Show the generated `joinlist.txt` (or first/last few lines) before invoking FFmpeg so the user can spot a wrong file before a long run.

## Resize

- **Custom size** — Prompt for width×height or “max long edge” once instead of fixed presets only.
- **Audio / subtitles** — Explicit `-map` or copy behavior documented in-tool; optional “video only” or “copy all streams” choice.
- **Recurse opt-in** — Today only the script’s folder is scanned. An optional `[R]ecurse` flag could descend subfolders, with output mirrored next to each source.
- **Skip-if-smaller** — When a source is already inside the chosen box, copy streams (or skip) instead of re-encoding.

## Trim / cut

- **Re-encode trim fallback** — README/INSTRUCTIONS already note stream-copy keyframe limits; optional re-encode path when cuts look wrong or times do not land cleanly.
- **Milliseconds** — Accept `HH:MM:SS.mmm` if users paste from tools that emit fractions.
- **Duration as alternative to end** — Mirror the GIF tool: allow “start + length in seconds” in addition to start/end pairs.

## GIF

- **Palette pipeline** — `palettegen` + `paletteuse` for better colors and often smaller files than single-pass `gif`.
- **FPS / scale override** — Advanced prompt after presets for power users (today: S 240px 8fps, M 320px 10fps, L 480px 12fps in `:tool_gif`).
- **End time too** — Optional `HH:MM:SS` end input alongside the current “duration in seconds”.

## Robustness and packaging

- **FFmpeg path** — Allow `FFMPEG_EXE` env var or an `ffmpeg.exe` next to the `.bat` before falling back to `PATH`.
- **Logging** — Append FFmpeg stderr to `ffmpeg_last_run.log` on failure (and offer to open it) for support.
- **Temp file location** — `progress.txt` and `joinlist.txt` are written into the current folder, which can collide with user content or survive crashes. Move them under `%TEMP%\videoConverter\` or use a unique-per-run suffix.
- **Atomic-ish output** — Write to a temp name then `move` to final name to avoid half-written files on crash (optional).
- **Clean cancel** — Ctrl+C currently kills the whole `.bat`. Trap it (or use a sentinel key) so a batch run stops between files and prints a summary of what completed.

## Codebase / tooling

- **PowerShell or Python port** — Easier argument parsing, structured errors, and tests; batch remains the zero-dependency option.
- **Self-test** — A hidden `[T] Self test` entry that runs `where ffmpeg`, prints `ffmpeg -version` first line, and confirms write permissions in the current folder.
- **Samples** — Tiny sample clips (or documented fake names only) in the repo for manual regression checks — mind licensing if using real media.
- **CI** — If the script is ported or wrapped, add a minimal “ffmpeg present, dry run” check.

## Documentation

- **GIF preset table in INSTRUCTIONS** — Match README / on-screen labels (S 240px 8fps, M 320px 10fps, L 480px 12fps) so all three stay in sync.
- **Changelog habit** — When code or behavior changes, update **Recently shipped** here and the relevant section of README or INSTRUCTIONS in the same pass.

---

When you implement something from this list, move it to **Recently shipped** (with a short note) or delete it so the doc stays honest.
