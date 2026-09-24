#!/bin/bash
# Record one app window on macOS. Captures that window's own pixels, so other windows,
# notifications, and the rest of the screen never reach disk, even when they overlap it.
#
#   mac-record.sh start "<App name>" ["<title substring>"]   # start recording the app's front window
#   mac-record.sh stop <name>                               # stop, encode $REC/<name>.mp4, extract $REC/check.png
#
# Needs ffmpeg and Screen Recording permission for the app running this script.
# The window must stay open and unminimized; covering it is fine.

set -euo pipefail

REC="${REC:-/tmp/record-screen}"
FRAMES="$REC/frames"

window_id() {
  osascript -l JavaScript - "$1" "${2:-}" <<'JXA'
ObjC.import('CoreGraphics');
function run(argv) {
  const [owner, title] = argv;
  const windows = ObjC.deepUnwrap(ObjC.castRefToObject(
    $.CGWindowListCopyWindowInfo($.kCGWindowListOptionOnScreenOnly | $.kCGWindowListExcludeDesktopElements, $.kCGNullWindowID)));
  const match = windows.find(w => w.kCGWindowOwnerName === owner && w.kCGWindowLayer === 0 &&
    w.kCGWindowBounds.Width > 50 && (!title || (w.kCGWindowName || '').includes(title)));
  if (!match) throw new Error(`no on-screen window for ${owner}${title ? ` titled *${title}*` : ''}`);
  return match.kCGWindowNumber;
}
JXA
}

start() {
  local id
  id=$(window_id "$1" "${2:-}")
  rm -rf "$FRAMES" "$REC/check.png"
  mkdir -p "$FRAMES"
  rm -f "$REC/stop"
  date +%s >"$REC/started"
  nohup bash -c '
    i=0
    while [ ! -f "$0/../stop" ]; do
      i=$((i + 1))
      screencapture -x -o -l "$1" "$(printf "%s/f%06d.png" "$0" "$i")" || exit 1
      sleep 0.05
    done' "$FRAMES" "$id" >"$REC/capture.log" 2>&1 &
  echo $! >"$REC/capture.pid"
  echo "recording window $id of '$1' (pid $(cat "$REC/capture.pid"))"
}

stop() {
  local name="$1" out="$REC/$1.mp4" pid count elapsed fps
  pid=$(cat "$REC/capture.pid")
  touch "$REC/stop"
  while kill -0 "$pid" 2>/dev/null; do sleep 0.1; done
  rm -f "$REC/stop"
  count=$(find "$FRAMES" -name 'f*.png' | wc -l | tr -d ' ')
  if [ "$count" -eq 0 ]; then
    echo "no frames captured; see $REC/capture.log" >&2
    exit 1
  fi
  elapsed=$(( $(date +%s) - $(cat "$REC/started") ))
  fps=$(awk "BEGIN{f=$count/($elapsed>0?$elapsed:1); printf \"%.2f\", (f<1?1:f)}")
  # Scale every frame to the first frame's even-sized dimensions in case the window was resized.
  ffmpeg -v error -y -framerate "$fps" -i "$FRAMES/f%06d.png" \
    -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2,fps=10" -c:v libx264 -preset slow -crf 28 \
    -pix_fmt yuv420p -movflags +faststart "$out"
  rm -rf "$FRAMES" "$REC/started" "$REC/capture.pid"
  ffmpeg -v error -y -sseof -1 -i "$out" -frames:v 1 "$REC/check.png"
  ffprobe -v error -show_entries format=duration,size -of default=nw=1 "$out"
  echo "video: $out ($count frames)"
  echo "check frame: $REC/check.png"
}

case "${1:-}" in
  start) start "${2:?app name required}" "${3:-}" ;;
  stop) stop "${2:?output name required}" ;;
  *) echo "usage: mac-record.sh start <App name> [title substring] | stop <name>" >&2; exit 2 ;;
esac
