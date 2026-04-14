# videoConverter

Windows batch menu for common **FFmpeg** tasks: batch resize, join clips, trim with stream copy, and export short GIFs. Put your videos in the same folder as the script (or run the script from that folder) and pick an option from the console menu.

## Requirements

- **Windows** (batch file uses `choice`, `cmd` features)
- **[FFmpeg](https://ffmpeg.org/)** installed and available on your `PATH` (so `ffmpeg` runs from any command prompt)

## How to run

1. Copy `FOR FFMPEG.bat` next to your video files, **or** open a command prompt, `cd` to your media folder, and run the batch file with its full path.
2. Double-click `FOR FFMPEG.bat`, or run it from the folder that contains your inputs.

The script uses `pushd` to the script directory when you double-click it, so relative paths are based on where the `.bat` file lives.

## Menu options

| Key | Tool | What it does |
|-----|------|----------------|
| **1** | Batch resize | Converts every `.mkv` and `.mp4` in the folder to a chosen resolution. Output: `basename_PRESET.ext` (e.g. `vacation_1080p.mkv`). Presets: 4K (3840×2160), 1080p, 720p, 360p. |
| **2** | Join videos | Concatenates clips with **stream copy** (`-c copy`). Modes: numbered files `1.ext` … `N.ext`, or all `.mkv` files in A–Z order. Builds `joinlist.txt`, then outputs a name you choose (default `vc_joined.mkv`). **Clips should use the same codec/settings** for reliable joins. |
| **3** | Trim / cut | Fast cut with stream copy. You enter source file, start and end as `HH:MM:SS`. Output: `basename_clip_START_to_END.ext` (colons in times become hyphens in the filename). |
| **4** | Clip to GIF | Exports a segment to GIF: small (240px, 8 fps), medium (320px, 10 fps), or large (480px, 12 fps). Output: `basename_gif_PRESET_Xs.gif`. |
| **5** | Exit | Closes the menu. |

## Temporary files

- **`progress.txt`** — written during FFmpeg runs and removed when each step finishes.
- **`joinlist.txt`** — created for join, then deleted after a successful join.

## Tips

- For **join**, prefer identical resolution, frame rate, and codecs across segments.
- **Resize** and **GIF** re-encode video; **join** and **trim** use copy when possible for speed and no generational loss.

## License

No license is specified in this repository; treat as personal/use-at-your-own-risk unless you add one.
