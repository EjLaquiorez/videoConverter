# Instructions — FFmpeg Video Tools (`FOR FFMPEG.bat`)

This guide is for **first-time users** of the Windows batch menu. The script itself also shows short hints on each screen.

---

## 1. What you need

| Requirement | Details |
|-------------|---------|
| **Windows** | The menu uses Command Prompt features (`choice`, batch syntax). |
| **FFmpeg** | Must be installed separately. The script **does not** download or install FFmpeg. |
| **PATH** | The folder that contains `ffmpeg.exe` must be on your **system PATH**. After changing PATH, **open a new** Command Prompt or double-click the `.bat` again. |

**Install FFmpeg (typical Windows flow):**

1. Download a Windows build from [ffmpeg.org/download](https://ffmpeg.org/download.html) (or another trusted source you prefer).
2. Unzip it somewhere permanent (for example `C:\Tools\ffmpeg`).
3. Add the **folder that directly contains** `ffmpeg.exe` to your user or system PATH (Windows: *Settings → System → About → Advanced system settings → Environment Variables → Path → Edit*).
4. Confirm in a **new** terminal: run `ffmpeg -version`. If that works, the menu will start normally.

If FFmpeg is missing, the script stops with a red message and a pause so you can read it.

---

## 2. Where to put files

**Easiest setup:** put `FOR FFMPEG.bat` in the **same folder** as your videos, then double-click the `.bat`.

- When you double-click, the script switches to **the folder where the `.bat` lives**. All “every file in this folder” options use that folder (not subfolders).
- For **Trim** and **GIF**, you can type a **full path** to a video elsewhere; otherwise use the file name as it appears in the current folder.

---

## 3. Starting the menu

1. Double-click `FOR FFMPEG.bat`, or open Command Prompt, `cd` to the folder, and run:
   ```text
   "FOR FFMPEG.bat"
   ```
2. At the main menu, press **1**, **2**, **3**, **4**, or **5** when prompted (single key).
3. **5** exits. **B** (where offered) goes **back** to the main menu without running FFmpeg.

The window is sized for the built-in help text (about 90×42 characters).

---

## 4. How output files are named

| Action | Output name |
|--------|-------------|
| Resize, Trim | `originalname_converted` + same extension as the source (example: `clip.mp4` → `clip_converted.mp4`) |
| GIF | `originalname_converted.gif` |
| Join | **You choose** the output file name (default suggestion: `vc_joined.mkv`). Include an extension such as `.mkv` or `.mp4`. |

**Important:** originals are **not** deleted. If `something_converted.ext` already exists, running the tool again **overwrites** that converted file only.

---

## 5. Option 1 — Batch resize

**What it does:** re-encodes every **`.mkv`** and **`.mp4`** in the current folder to fit inside a chosen maximum size. **Aspect ratio is preserved** (no stretching; video fits inside the box).

**Steps:**

1. Press **1** on the main menu.
2. Choose a preset:
   - **U** — up to 3840×2160 (4K box)
   - **H** — up to 1920×1080
   - **M** — up to 1280×720
   - **L** — up to 640×360
   - **B** — back to main menu
3. Wait until processing finishes. If any file fails, you will see a warning after the loop.

---

## 6. Option 2 — Join videos

**What it does:** concatenates multiple videos into **one** file using **stream copy** (`-c copy`). That is fast and avoids re-encoding, but **all segments should match** (same resolution, frame rate, and codec settings). If they do not, FFmpeg may error.

**Mode N — Numbered files**

1. Name your clips `1.mkv`, `2.mkv`, … `N.mkv` (or another extension you will specify).
2. Put them in the **same folder** as the script.
3. Press **N**, then enter **N** (the highest number) and the extension without a dot (default `mkv`).

**Mode A — All `.mkv` in folder**

1. Press **A**. Every `.mkv` in the folder is joined in **alphabetical** order by file name. Rename files beforehand if the order matters.

**After choosing N or A**

1. Type the **output** file name (e.g. `my_movie.mkv`). Press Enter alone to accept `vc_joined.mkv`.
2. On success, the script reports the saved path. On failure, note the exit code and check that segments are compatible.

---

## 7. Option 3 — Trim / cut

**What it does:** copies only the segment from **start** to **end** time (stream copy — fast, but cuts must align with how the file is encoded).

**Steps:**

1. Press **3**.
2. **Source video:** file name with extension (e.g. `video.mp4`) or a full path.
3. **Start time** and **end time** in `HH:MM:SS` (examples: `0:00:05`, `00:01:30`). Start must be **before** end.
4. Output: `sourcename_converted` + original extension, in the same directory as the resolved source path.

---

## 8. Option 4 — Clip to GIF

**What it does:** re-encodes a **short** part of the video into an animated GIF.

**Steps:**

1. Press **4**.
2. Choose size/quality: **S** (smaller file), **M**, or **L** (larger/clearer). **B** goes back.
3. Enter **source** file name (or path), **start** time (`HH:MM:SS`), and **duration in seconds** (how long the GIF runs — **not** the end time).
4. Output: `sourcename_converted.gif`.

Keep duration small; long or high-resolution GIFs grow very large.

---

## 9. Temporary files

| File | Purpose |
|------|---------|
| `progress.txt` | Used during FFmpeg runs; removed when each step finishes. |
| `joinlist.txt` | Built for join; deleted after the join step (success or failure). |

You can ignore them unless you are debugging. Do not delete them **while** FFmpeg is running.

---

## 10. If something goes wrong

| Problem | What to try |
|---------|-------------|
| “FFmpeg was not found” | Install FFmpeg and fix PATH; open a **new** console. |
| Join fails | Use clips with the same codec, resolution, and frame rate; or re-encode them to match first. |
| Trim fails or looks wrong | Check start/end times; stream copy needs valid keyframes — times must be inside the file length. |
| Resize / GIF errors | Confirm the path and file name; check that the disk has space; run `ffmpeg -version` manually. |
| Little error text on screen | The script uses `-loglevel error`; run the same FFmpeg command manually in a terminal for full logs if needed. |

---

## 11. Related files

- **README.md** — short project overview and requirements.
- **FOR FFMPEG.bat** — the actual menu (authoritative for keys and behavior if this doc ever drifts).
