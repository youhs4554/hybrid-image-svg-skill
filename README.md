# Hybrid Image SVG Skill

Codex skill for converting raster infographics, slide screenshots, posters, or photo-containing layouts into PPT-friendly SVG files.

The skill rebuilds editable layout elements as SVG shapes and text, while embedding complex visual regions such as photos, maps, logos, icons, shadows, and texture-heavy graphics as cropped PNG images.

## Stable Conversion Mode

The stable mode is text-first hybrid SVG:

- Keep readable text editable with SVG `<text>` and `<tspan>` whenever practical.
- Keep layout editable with SVG shapes for panels, cards, separators, banners, arrows, dots, and connector lines.
- Embed only complex visual assets as cropped PNG data: photos, screenshots, maps, charts, product shots, logos, pictograms, detailed icons, shadows, gradients, and texture-heavy regions.
- Avoid full-panel or full-banner crops in the main PPT-editable output because they hide text inside images and prevent PPT text-box extraction.
- Use large bitmap regions only when producing a separate exact-preview variant.

## What Stays Editable

- Text rebuilt with SVG `<text>` and `<tspan>`
- Panels, cards, separators, pills, and banners rebuilt as SVG shapes
- Lines, circles, rectangles, and simple layout structure
- Bullets, labels, captions, company names, footer callouts, and other readable text whenever practical

## What Becomes Embedded Image Data

- Photos and photo-real regions
- Screenshots, maps, logos, icons, pictograms, shadows, gradients, and texture-heavy areas
- Any region where vector tracing would make the PPT file slow or visually noisy
- Text-containing screenshots or logos that must remain a single image

## Install

Run this on the machine where Codex or another compatible AI coding agent is installed:

```bash
mkdir -p ~/.agents/skills
git clone https://github.com/youhs4554/hybrid-image-svg-skill.git ~/.agents/skills/hybrid-image-svg
```

If the folder already exists:

```bash
cd ~/.agents/skills/hybrid-image-svg
git pull
```

Restart the agent session after installation so the skill list reloads.

## One-Command Install

```bash
curl -fsSL https://raw.githubusercontent.com/youhs4554/hybrid-image-svg-skill/main/install.sh | bash
```

## Smoke Test

After cloning or installing the skill, run the bundled smoke test:

```bash
cd ~/.agents/skills/hybrid-image-svg
examples/smoke-test/run.sh
```

The test generates a small raster source image, crops two complex regions, embeds them into an SVG template, validates the SVG with `xmllint`, and renders a PNG preview with `rsvg-convert`.

## AI Agent Setup Prompt

Give this prompt to an AI coding agent that has shell access:

```text
Install the Codex skill from https://github.com/youhs4554/hybrid-image-svg-skill.

Steps:
1. Create ~/.agents/skills if it does not exist.
2. Clone the repository into ~/.agents/skills/hybrid-image-svg.
3. If that folder already exists and is a git repository, run git pull in it instead.
4. Verify that ~/.agents/skills/hybrid-image-svg/SKILL.md exists.
5. Verify that ~/.agents/skills/hybrid-image-svg/scripts/embed_crops.py exists.
6. Run ~/.agents/skills/hybrid-image-svg/examples/smoke-test/run.sh.
7. Tell me to restart the agent session so the skill list reloads.
```

After setup, use the skill like this:

```text
$hybrid-image-svg Convert this slide screenshot into a PPT-friendly SVG. Keep text and layout editable, and embed photos/icons as cropped images.
```

## Requirements

The skill itself is an instruction file. The helper script uses local command-line tools when cropping and verifying SVG output:

- Python 3
- ImageMagick, available as `magick`
- `xmllint`
- `rsvg-convert`

On macOS, the common install path is:

```bash
brew install imagemagick libxml2 librsvg
```

## Helper Script

Use `scripts/embed_crops.py` when an SVG template contains placeholders and a crop spec JSON file.

```bash
python scripts/embed_crops.py \
  --source input.png \
  --spec crops.json \
  --template template.svg \
  --output output.svg \
  --crop-dir assets/icon-crops
```

Example crop spec:

```json
[
  { "name": "hospital", "x": 28, "y": 239, "width": 175, "height": 91 },
  { "name": "map_pin", "x": 1118, "y": 238, "width": 190, "height": 112 }
]
```

In the SVG template:

```xml
<image href="{{hospital}}" x="28" y="239" width="175" height="91"/>
```

The script crops each region and replaces placeholders with base64 PNG data URIs.

## Repository Layout

```text
.
├── SKILL.md
├── agents/
│   └── openai.yaml
├── examples/
│   └── smoke-test/
├── scripts/
│   └── embed_crops.py
├── install.sh
└── README.md
```

## Notes For Team Use

- Keep `SKILL.md` and the `scripts/` directory together.
- Do not install only `SKILL.md`; the helper script is part of the workflow.
- The final SVG should be self-contained unless the user explicitly asks for linked image files.
- Always tell the user which parts of the result remain editable and which parts are embedded images.
