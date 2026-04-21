# videoConverter

Windows batch menu for common **FFmpeg** tasks: batch resize, join clips, trim with stream copy, and export short GIFs. Put your videos in the same folder as the script (or run the script from that folder) and pick an option from the console menu.

The menu includes **on-screen tips** for new users (main screen + each tool). For a full walkthrough, open [INSTRUCTIONS.md](INSTRUCTIONS.md).

## Requirements

- **Windows** (batch file uses `choice`, `cmd` features)
- **[FFmpeg](https://ffmpeg.org/)** on your **system `PATH`**. On startup the script runs `where ffmpeg`; if it fails, you get a red message explaining that FFmpeg is not bundled and to fix PATH, then open a **new** console.
- **Console window** — the script sets the window to about **90×42** characters so the built-in help fits.

## How to run

1. Copy `FOR FFMPEG.bat` next to your video files, **or** open a command prompt, `cd` to your media folder, and run the batch file with its full path.
2. Double-click `FOR FFMPEG.bat`, or run it from the folder that contains your inputs.

The script uses `pushd` to the script directory when you double-click it, so relative paths are based on where the `.bat` file lives.

**Step-by-step guide for new users:** see [INSTRUCTIONS.md](INSTRUCTIONS.md).

## Menu options

Main menu: press **1**–**5**. Inside tools, **B** usually means **back** to the main menu without running FFmpeg.

| Key | Tool | What it does |
|-----|------|----------------|
| **1** | Batch resize | Re-encodes every `.mkv` and `.mp4` in the **current folder only** (not subfolders). Presets (**U** 4K, **H** 1080p, **M** 720p, **L** 360p, **B** back): each is a **maximum** box; **aspect ratio is kept**. Output: `basename_converted.ext`. Warnings if any file in the batch fails. |
| **2** | Join videos | **Stream copy** (`-c copy`). **N** = numbered `1.ext`…`N.ext`; **A** = all `.mkv` in A–Z order; **B** back. You type the output name (default `vc_joined.mkv`). **Same codec/settings** across clips is usually required. FFmpeg exit code shown on failure. |
| **3** | Trim / cut | Stream copy from start to end `HH:MM:SS`. Output: `basename_converted.ext`. Full path to the source is allowed. Exit code on failure. |
| **4** | Clip to GIF | **S** / **M** / **L** = small/medium/large preset (**B** back); then duration in **seconds** (not end time). Output: `basename_converted.gif`. Exit code on failure. |
| **5** | Exit | Closes the menu. |

## Temporary files

- **`progress.txt`** — written during FFmpeg runs and removed when each step finishes.
- **`joinlist.txt`** — built for **Join**, then removed after the join step runs (success or failure).

## Tips

- For **join**, prefer identical resolution, frame rate, and codecs across segments.
- **Resize** and **GIF** re-encode video; **join** and **trim** use copy when possible for speed and no generational loss.
- Re-running resize/trim/GIF overwrites an existing `*_converted*` file with the same base name; originals are never deleted by this script.
- With `-loglevel error`, FFmpeg may print little detail; if something fails, recheck file names, timecodes, and that inputs are valid for **stream copy** where used.

## License

No license is specified in this repository; treat as personal/use-at-your-own-risk unless you add one.
