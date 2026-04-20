# videoConverter

Windows batch menu for common **FFmpeg** tasks: batch resize, join clips, trim with stream copy, and export short GIFs. Put your videos in the same folder as the script (or run the script from that folder) and pick an option from the console menu.

## Requirements

- **Windows** (batch file uses `choice`, `cmd` features)
- **[FFmpeg](https://ffmpeg.org/)** installed and on your **system `PATH`** (the script runs `where ffmpeg` at startup and exits with a short message if it is missing)

## How to run

1. Copy `FOR FFMPEG.bat` next to your video files, **or** open a command prompt, `cd` to your media folder, and run the batch file with its full path.
2. Double-click `FOR FFMPEG.bat`, or run it from the folder that contains your inputs.

The script uses `pushd` to the script directory when you double-click it, so relative paths are based on where the `.bat` file lives.

**Step-by-step guide for new users:** see [INSTRUCTIONS.md](INSTRUCTIONS.md).

## Menu options

| Key | Tool | What it does |
|-----|------|----------------|
| **1** | Batch resize | Re-encodes every `.mkv` and `.mp4` in the folder. Each preset is a **maximum** size (4K 3840×2160, 1080p, 720p, 360p); **aspect ratio is kept** (fits inside the box; no stretching). Output: `basename_converted.ext` (e.g. `vacation_converted.mkv`). If any file fails, you get a warning after the batch. |
| **2** | Join videos | Concatenates clips with **stream copy** (`-c copy`). Modes: numbered files `1.ext` … `N.ext`, or all `.mkv` files in A–Z order. Builds `joinlist.txt`, then outputs a name you choose (default `vc_joined.mkv`). **Clips should use the same codec/settings** for reliable joins. On failure, the script shows the FFmpeg exit code and a hint. |
| **3** | Trim / cut | Fast cut with stream copy. You enter source file, start and end as `HH:MM:SS`. Output: `basename_converted.ext`. Failures are reported with an exit code. |
| **4** | Clip to GIF | Exports a segment to GIF: small (240px, 8 fps), medium (320px, 10 fps), or large (480px, 12 fps). Output: `basename_converted.gif`. Failures are reported with an exit code. |
| **5** | Exit | Closes the menu. |

## Temporary files

- **`progress.txt`** — written during FFmpeg runs and removed when each step finishes.
- **`joinlist.txt`** — built for **Join**, then removed after the join step runs (success or failure).

## Tips

- For **join**, prefer identical resolution, frame rate, and codecs across segments.
- **Resize** and **GIF** re-encode video; **join** and **trim** use copy when possible for speed and no generational loss.
- With `-loglevel error`, FFmpeg may print little detail; if something fails, recheck file names, timecodes, and that inputs are valid for **stream copy** where used.

## License

No license is specified in this repository; treat as personal/use-at-your-own-risk unless you add one.
