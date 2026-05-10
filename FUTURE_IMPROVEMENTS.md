# Future development and improvements

Ideas for evolving **videoConverter** (`FOR FFMPEG.bat` and docs). Nothing here is committed work—use it as a backlog or design scratchpad.

---

## Recently shipped

- **Batch resize wildcard safety (May 2026)** — Resize now skips non-existent wildcard matches and ignores files already ending in `_converted`, preventing false failures when only one extension type is present.

---

## User experience

- **Drag-and-drop** — Accept a video path as `%1` when the user drops a file onto the `.bat`, then jump to trim or GIF with that path pre-filled.
- **Output folder** — Optional subfolder (e.g. `converted\`) so outputs never sit mixed with sources unless the user wants that.
- **Overwrite guard** — Prompt or skip when `*_converted*` already exists (resize / trim / GIF).
- **Progress** — Keep `-nostats` for quiet runs, or offer a “verbose” mode that shows FFmpeg’s default progress line.
- **Locale** — If the audience grows, short translated hint blocks or an external `strings` file (harder in pure `.cmd`).

## Join (concat)

- **All `.mp4`** mode alongside “all `.mkv`” and numbered sequences.
- **Validate numbered mode** — Check that `1.ext` … `N.ext` exist before calling FFmpeg; print what is missing.
- **Re-encode join** — Optional path when `-c copy` fails (same resolution, one encoder) so mismatched clips can still be merged—slower but more forgiving.

## Resize

- **Custom size** — Prompt for width×height or “max long edge” once instead of fixed presets only.
- **Audio / subtitles** — Explicit `-map` or copy behavior documented; optional “video only” or “copy all streams” choice.

## Trim / cut

- **Keyframe-safe copy** — Short note or optional shift to re-encode a few frames when stream copy cuts look wrong.
- **Milliseconds** — Accept `HH:MM:SS.mmm` if users paste from tools that emit fractions.

## GIF

- **Palette pipeline** — `palettegen` + `paletteuse` for better colors and often smaller files than single-pass `gif`.
- **FPS / scale override** — Advanced prompt after presets for power users.

## Robustness and packaging

- **FFmpeg path** — Allow `FFMPEG_EXE` env var or a `ffmpeg.exe` next to the `.bat` before falling back to `PATH`.
- **Logging** — Append FFmpeg stderr to `ffmpeg_last_run.log` on failure for support.
- **Atomic-ish output** — Write to a temp name then `move` to final name to avoid half-written files on crash (optional).

## Codebase / tooling

- **PowerShell or Python port** — Easier argument parsing, structured errors, and tests; batch remains the zero-dependency option.
- **Samples** — Tiny sample clips (or documented fake names only) in the repo for manual regression checks—mind licensing if using real media.
- **CI** — If the script is ported or wrapped, add a minimal “ffmpeg present, dry run” check.

## Documentation

- Keep **README.md** high-level; **INSTRUCTIONS.md** procedural; this file for **ideas only**—update or prune as items ship or are rejected.

---

When you implement something from this list, consider removing or checking it off here so the doc stays honest.
