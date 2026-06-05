#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"
OUT_DIR="${SCRIPT_DIR}/out"

mkdir -p "${OUT_DIR}/assets/icon-crops"

magick -size 800x450 xc:"#f7fbfd" \
  -fill white -stroke "#146f9f" -strokewidth 4 -draw "roundrectangle 36,48 376,348 18,18" \
  -fill "#d6eef8" -stroke "#245e7b" -strokewidth 2 -draw "roundrectangle 60,80 340,250 10,10" \
  -fill "#89c7dd" -draw "circle 128,148 128,108" \
  -fill "#f3b25f" -draw "rectangle 175,125 322,230" \
  -fill "#4a94c4" -draw "polygon 72,235 142,165 216,235" \
  -fill white -stroke "#146f9f" -strokewidth 4 -draw "roundrectangle 530,48 764,348 18,18" \
  -fill "#eaf4fb" -stroke "#224f6c" -strokewidth 3 -draw "circle 485,165 545,165" \
  -fill none -stroke "#1386ce" -strokewidth 8 -draw "line 485,165 542,165 line 522,132 522,220" \
  -fill "#1386ce" -stroke none -draw "circle 522,165 537,165" \
  "${OUT_DIR}/source.png"

python "${REPO_DIR}/scripts/embed_crops.py" \
  --source "${OUT_DIR}/source.png" \
  --spec "${SCRIPT_DIR}/crops.json" \
  --template "${SCRIPT_DIR}/template.svg" \
  --output "${OUT_DIR}/smoke.svg" \
  --crop-dir "${OUT_DIR}/assets/icon-crops"

xmllint --noout "${OUT_DIR}/smoke.svg"
rsvg-convert -w 800 -h 450 "${OUT_DIR}/smoke.svg" -o "${OUT_DIR}/smoke_preview.png"

echo "Smoke test passed:"
echo "  ${OUT_DIR}/smoke.svg"
echo "  ${OUT_DIR}/smoke_preview.png"
