---
name: "record-screen"
description: "Record a small MP4 while demonstrating or verifying a UI change, then attach the video as proof. Linux cloud sessions record the private virtual display; macOS records only the app window under test. Use for any repo whenever a UI change is verified or demoed."
---

# Record screen

Video is the reviewer's main evidence for UI work. Record around the part of the run that shows the change, then attach the MP4.

- **Linux cloud session:** record the whole virtual X display with sections 1–3. Nothing else runs on it, so the whole display is safe to capture.
- **macOS:** the screen is the user's real desktop, with personal windows and notifications. Never record the full display. Use [the macOS section](#macos-record-only-the-app-window), then continue at section 4.

## Linux: 1. Start (just before the app launches)

Run as one command. It reuses a running display, else starts Xvfb on :99; installs ffmpeg if missing (about 30s with apt); records at 15 fps in the background.

```sh
REC=/tmp/record-screen; mkdir -p "$REC"; SUDO=$([ "$(id -u)" = 0 ] || echo sudo)
export DISPLAY=${DISPLAY:-:99}; d=${DISPLAY#*:}; d=${d%%.*}
if [ ! -S "/tmp/.X11-unix/X$d" ]; then
  command -v Xvfb >/dev/null || { $SUDO apt-get update -q || true; $SUDO apt-get install -y -q --no-install-recommends xvfb; }
  setsid nohup Xvfb "$DISPLAY" -screen 0 1920x1080x24 -nolisten tcp >"$REC/xvfb.log" 2>&1 &
  timeout 10 sh -c "until [ -S /tmp/.X11-unix/X$d ]; do sleep 0.2; done"
fi
command -v ffmpeg >/dev/null || { $SUDO apt-get update -q || true; $SUDO apt-get install -y -q --no-install-recommends ffmpeg; }
rm -f "$REC/raw.mkv"
setsid nohup ffmpeg -loglevel error -f x11grab -framerate 15 -draw_mouse 0 -i "$DISPLAY" \
  -c:v libx264 -preset ultrafast -crf 18 "$REC/raw.mkv" >"$REC/ffmpeg.log" 2>&1 &
echo $! >"$REC/ffmpeg.pid"; echo "recording $DISPLAY (pid $(cat "$REC/ffmpeg.pid"))"
```

The app under test must use the same `DISPLAY`. If you started Xvfb here, prefix later commands with `DISPLAY=:99`, since shell exports do not carry across tool calls.

## Linux: 2. Demonstrate

Drive the app so the change is visible: open the affected screens, pause about 2 seconds on each (`waitForTimeout` in Playwright is fine for pacing), and show the before and after state where it applies. Nothing but the app appears on a virtual display, and Playwright clicks do not move a pointer, so screens change without a visible cursor.

## Linux: 3. Stop and encode (always, even if the run failed)

Replace `NAME` with a short slug for the change. The stop is clean (`SIGINT`); the black lead-in before the first app frame is trimmed; the output is 10 fps H.264 with faststart, typically 0.2 MB for 20s and 4 MB for 90s at 1080p.

```sh
REC=/tmp/record-screen; OUT="$REC/NAME.mp4"; pid=$(cat "$REC/ffmpeg.pid")
kill -INT "$pid"; timeout 30 tail --pid="$pid" -f /dev/null
lead=$(ffmpeg -i "$REC/raw.mkv" -vf blackdetect=d=0.3:pix_th=0.05 -an -f null - 2>&1 \
  | awk -F'black_end:' '/black_start:0 /{split($2,a," "); print a[1]; exit}')
ffmpeg -v error -y -ss "${lead:-0}" -i "$REC/raw.mkv" -vf fps=10 -c:v libx264 -preset slow -crf 28 \
  -pix_fmt yuv420p -movflags +faststart "$OUT"
ffprobe -v error -show_entries format=duration,size -of default=nw=1 "$OUT"
```

## macOS: record only the app window

[`scripts/mac-record.sh`](scripts/mac-record.sh) captures one window's own pixels with `screencapture -l`, at about 5–10 fps, and encodes them with `ffmpeg`. Other windows, notifications and the rest of the screen never reach disk, even when they cover the window. Requires `ffmpeg` and Screen Recording permission for the app running the agent; if capture fails or macOS prompts, ask the user to allow it in System Settings → Privacy & Security → Screen Recording.

```sh
S=<this skill>/scripts/mac-record.sh
$S start "<App name as shown in the menu bar>" "<optional window title substring>"
# demonstrate the change, pausing about 2 seconds on each state
$S stop NAME   # always, even if the run failed; writes /tmp/record-screen/NAME.mp4 and check.png
```

- Open the app window before `start`. A minimized window or one on another Space is not on screen; `start` refuses rather than guessing.
- Pass a title substring when the app has several windows (for example a browser with personal tabs), so the recording picks the window under test.
- Launch the app under test in its own window with only test data in it. The window's contents are recorded as they are.

## 4. Check and attach

- Pull one frame (`ffmpeg -ss 5 -i "$OUT" -frames:v 1 /tmp/record-screen/check.png`) and look at it. A black or empty frame means the app ran on another display. On macOS, `stop` already wrote `check.png`; confirm it shows only the app under test, and delete the video if it shows anything else.
- In a project thread, copy the MP4 under `/mnt/project-files/` (for example `/mnt/project-files/screen-recordings/NAME.mp4`) and attach it to the reply that reports the result with `attached_outputs: [{"kind": "file", "ref": "<that path>"}]`. Elsewhere, give the path.
- Say in one line what the video shows and its duration. The video supports assertions and screenshots; it does not replace them.
- Never record screens that show credentials or tokens.