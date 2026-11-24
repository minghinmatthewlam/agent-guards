---
name: "record-screen"
description: "Record a small MP4 while demonstrating or verifying a UI change, then attach the video as proof. Linux cloud sessions record the private virtual display; macOS records only the app window under test. Use for any repo whenever a UI change is verified or demoed."
---

# Record screen

Record the UI change and attach the MP4 as proof. Never record screens showing credentials or tokens.

- **Linux cloud:** record the private virtual X display (sections 1–2).
- **macOS:** never record the full desktop—capture only the app window (macOS section).

## Linux: 1. Start (before app launch)

Reuses a running display or starts Xvfb on `:99`, installs `ffmpeg` if missing, and records at 15 fps. Prefix later app commands with `DISPLAY=:99` if Xvfb was started here.

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

Demonstrate the change, pausing ~2s on each state.

## Linux: 2. Stop and encode (always, even on failure)

Replace `NAME` with a short slug. Trims black lead-in and encodes 10 fps H.264 faststart.

```sh
REC=/tmp/record-screen; OUT="$REC/NAME.mp4"; pid=$(cat "$REC/ffmpeg.pid")
kill -INT "$pid"; timeout 30 tail --pid="$pid" -f /dev/null
lead=$(ffmpeg -i "$REC/raw.mkv" -vf blackdetect=d=0.3:pix_th=0.05 -an -f null - 2>&1 \
  | awk -F'black_end:' '/black_start:0 /{split($2,a," "); print a[1]; exit}')
ffmpeg -v error -y -ss "${lead:-0}" -i "$REC/raw.mkv" -vf fps=10 -c:v libx264 -preset slow -crf 28 \
  -pix_fmt yuv420p -movflags +faststart "$OUT"
ffprobe -v error -show_entries format=duration,size -of default=nw=1 "$OUT"
```

## macOS: capture only the app window

[`scripts/mac-record.sh`](scripts/mac-record.sh) uses `screencapture -l` + `ffmpeg` (requires Screen Recording permission in System Settings → Privacy & Security). Open the window on-screen first (not minimized / other Space) with only test data; pass a title substring if the app has multiple windows.

```sh
S=<this skill>/scripts/mac-record.sh
$S start "<App name>" "<optional window title substring>"
# demonstrate the change, pausing ~2s on each state
$S stop NAME   # always, even on failure; writes /tmp/record-screen/NAME.mp4 and check.png
```

## 3. Check and attach

- Inspect a frame (`ffmpeg -ss 5 -i "$OUT" -frames:v 1 /tmp/record-screen/check.png`, or macOS's `check.png`). Verify it shows only the app under test; delete if anything else appears.
- In a project thread, copy to `/mnt/project-files/screen-recordings/NAME.mp4` and attach via `attached_outputs: [{"kind": "file", "ref": "<path>"}]`; otherwise give the path.
- Note what the video shows and its duration in one line.
