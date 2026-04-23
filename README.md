# videoConverter

Small **Windows** helper: a console menu around **FFmpeg** for batch resize, joining clips, stream-copy trims, and short **GIF** exports. Main script: **`FOR FFMPEG.bat`**.

The menu shows **on-screen tips** on the home screen and inside each tool. For a full step-by-step guide, see **[INSTRUCTIONS.md](INSTRUCTIONS.md)**.

## Repository layout

| Item | Purpose |
|------|---------|
| `FOR FFMPEG.bat` | Run this. Switches to its own folder when double-clicked. |
| [INSTRUCTIONS.md](INSTRUCTIONS.md) | Detailed usage, FFmpeg install, troubleshooting. |
| [FUTURE_IMPROVEMENTS.md](FUTURE_IMPROVEMENTS.md) | Ideas and possible enhancements (backlog, not a promise). |
| `README.md` | This overview. |

## Requirements

- **Windows** — uses `choice` and classic batch features.
- **[FFmpeg](https://ffmpeg.org/)** on your **`PATH`**. Startup runs `where ffmpeg`; if that fails, you get a red screen explaining FFmpeg is **not** bundled, to fix `PATH`, and to open a **new** terminal ([download](https://ffmpeg.org/download.html)).
- **Console** — resized to about **90×42** so in-app help fits.

## How to run

1. Put **`FOR FFMPEG.bat`** in the same folder as your videos (simplest), **or** `cd` to your media folder and run the `.bat` by full path.
2. Double-click **`FOR FFMPEG.bat`**, then press **1**–**5** at the main prompt.

When you double-click, `pushd` uses the script’s directory, so relative names are resolved from the folder that contains the `.bat`.

## Output naming

| Tool | Output |
|------|--------|
| Resize, Trim | `originalname_converted` + same extension as the source |
| GIF | `originalname_converted.gif` |
| Join | **You choose** the filename (default suggestion `vc_joined.mkv`; include `.mkv` / `.mp4` / etc.). |

Original files are **not** deleted. An existing `*_converted*` file with the same base name is **overwritten** if you run the tool again.

## Menu (main keys **1**–**5**)

Inside submenus, **B** usually returns to the main menu without running FFmpeg.

| Key | Tool | Summary |
|-----|------|---------|
| **1** | Batch resize | All **`.mkv`** / **`.mp4`** in the **current folder only** (no subfolders). Presets: **U** 4K, **H** 1080p, **M** 720p, **L** 360p (**B** back). Fits inside max size; **aspect ratio kept**. → `name_converted.ext`. Warns if any file fails. |
| **2** | Join | **`-c copy`**. **N** = `1.ext`…`N.ext`; **A** = all `.mkv` A–Z; **B** back. You type output name. Clips should **match** (codec, resolution, fps). Shows FFmpeg exit code on failure. |
| **3** | Trim / cut | Stream copy from **start** to **end** (`HH:MM:SS`). Local name or **full path** to source. → `name_converted.ext`. |
| **4** | Clip to GIF | **S** 240px @ 8 fps · **M** 320 @ 10 · **L** 480 @ 12 (**B** back). Then **duration in seconds** (not end time). → `name_converted.gif`. |
| **5** | Exit | Quit. |

## Temporary files

- **`progress.txt`** — during FFmpeg; removed after each step.
- **`joinlist.txt`** — built for join; removed after the join attempt (success or failure).

## Tips

- **Join:** identical resolution, frame rate, and codecs across parts works best with stream copy.
- **Resize** and **GIF** re-encode; **join** and **trim** use copy where possible (fast, no extra quality loss).
- Logs use **`-loglevel error`** — if something fails, double-check paths, timecodes, and stream-copy compatibility; run FFmpeg manually for verbose output if needed.

## License

No license is specified in this repository; treat as personal / use at your own risk unless you add one.
