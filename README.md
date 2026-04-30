# videoConverter

This is a simple **video helper** for your PC: resize many videos at once, glue clips together, cut out a section, or make a short **GIF**. Everything runs from one Windows file: **`FOR FFMPEG.bat`**.

You do **not** need to memorize FFmpeg commands—the black window walks you through choices and shows short tips. For full **step-by-step** instructions and install help, open **[INSTRUCTIONS.md](INSTRUCTIONS.md)**.

---

## Before you start (two things)

1. **Windows** — This project is built for normal Windows (the kind that opens a black “Command Prompt” style window).

2. **FFmpeg** — This is **free software** that does the actual video work. You must **install it yourself** and put it on your computer’s **PATH** (so Windows can find `ffmpeg` when you run the menu).  
   - The menu **does not** install FFmpeg for you.  
   - If FFmpeg is missing, you will see a **red** message; fix PATH, then open a **new** window and try again.  
   - Help: [FFmpeg download](https://ffmpeg.org/download.html).

---

## Getting started (easy path)

1. **Install FFmpeg** and confirm it works (open Command Prompt, type `ffmpeg -version` and press Enter—you should see version text, not “not recognized”).

2. Put **`FOR FFMPEG.bat`** in the **same folder** as your videos (for example your `Downloads` or a folder named `Videos`).  
   *That is the simplest way: double-click the `.bat` there and it looks for files in that folder.*

3. **Double-click** `FOR FFMPEG.bat`. A menu appears.

4. Press a number on your keyboard (**1**–**5**) when the menu asks you to. Read the lines on the screen—each tool explains what to type next.

To leave the menu, choose **5** (Exit). Inside a tool, **B** usually means **Back** to the home menu without running a job.

---

## Where your new files go (names)

| What you did | What the new file is usually called |
|--------------|-------------------------------------|
| Resize or trim | Same name as before, plus **`_converted`**, and the **same type** (e.g. `trip.mp4` → `trip_converted.mp4`) |
| GIF | Same name plus **`_converted.gif`** (e.g. `trip_converted.gif`) |
| Join several clips | **You type** the final name (suggested default: `vc_joined.mkv`). |

**Your original files stay.** If you run the same tool again on the same file, it may **replace** the old `*_converted*` output—only that new file is overwritten, not your original.

---

## What each menu number does

Think of **1–4** as four tools; **5** is quit.

| Key | Plain-English summary |
|-----|---------------------|
| **1** — Resize | Makes **new** copies of every **`.mkv`** and **`.mp4`** in **this folder only** (not inside subfolders). You pick a size **preset** with letter keys (**U** very large, **H** 1080p, **M** 720p, **L** smaller, **B** back). Picture shape is **not** stretched. |
| **2** — Join | Puts clips **one after another** into one file. Works best when all clips “match” (same kind of video settings). You can use **numbered** files (`1.mkv`, `2.mkv`, …) or **all `.mkv` files** here in A–Z name order. You type the **output** filename. |
| **3** — Trim | Keeps only the part from a **start time** to an **end time** (like 0:01:00 to 0:02:30). You can type the file name or paste the **full path** to the video. |
| **4** — GIF | Turns part of a video into an animated GIF. You pick **S / M / L** for smaller-or-larger GIF, then enter how many **seconds** long the GIF should be (not the end time). |
| **5** — Exit | Close the program. |

For letter shortcuts (**U/H/M/L**, **N/A**, **S/M/L**, **B**), follow the text at the bottom of each screen.

---

## Other files in this project

| File | For beginners… |
|------|------------------|
| **INSTRUCTIONS.md** | Read this for **step-by-step** help, including FFmpeg on Windows. |
| **FUTURE_IMPROVEMENTS.md** | Ideas for later—**not** something you must install. |
| **README.md** | You are here—big-picture overview. |

---

## Small files the menu may create

- **`progress.txt`** — Used while a job runs; the menu removes it when that step is done.  
- **`joinlist.txt`** — Used when joining videos; removed after the join step.

You can ignore them unless something went wrong and you are troubleshooting.

---

## Good to know

- **Join** is picky: if clips were recorded differently, joining might fail until they are converted to match (the full guide explains more).
- **Resize** and **GIF** take time because the video is processed again; **trim** and **join** try to be fast by copying data when possible.
- If an error message is short, open **[INSTRUCTIONS.md](INSTRUCTIONS.md)** or run FFmpeg from a terminal yourself for more detail.

## License

No license is specified in this repository; treat as personal / use at your own risk unless you add one.
