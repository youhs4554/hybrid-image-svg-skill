---
name: hybrid-image-svg
description: Use when converting a raster infographic, slide image, screenshot, poster, or photo-containing layout into SVG for PPT/PPTX where text, lines, boxes, and layout should remain editable but icons, photos, or complex illustrations can be embedded as cropped images.
---

# Hybrid Image SVG

Create a PPT-friendly SVG by rebuilding structural elements as SVG shapes/text and embedding complex visual elements, including real photos, as cropped images from the source raster.

## Stable Approach

This skill's stable conversion mode is text-first hybrid SVG:

- Rebuild all readable text as SVG `<text>`/`<tspan>` wherever practical, including titles, labels, bullets, table/card text, captions, company names, and footer callouts.
- Rebuild layout structure as editable SVG shapes: outer panels, cards, separators, pills, banners, arrows, simple connector lines, dots, and basic geometric marks.
- Embed only complex visual assets as cropped images: photos, screenshots, maps, charts, product shots, logos, pictograms, detailed icons, shadows, gradients, and texture-heavy regions.
- Avoid cropping a whole text-containing panel or banner just because it is visually exact. If a crop contains text, that text will not become an editable PPT text box.
- Use larger bitmap-in-SVG regions only for an explicit exact-preview variant, not for the main PPT-editable output.

## Use This For

- Infographics or slide screenshots that must be imported into PowerPoint.
- Cases where full bitmap-in-SVG is visually exact but not editable enough.
- Cases where full vector tracing creates too many paths, blurry text, or slow PPT editing.
- Layouts containing photographs, product shots, people, screenshots, maps, charts, or visual textures that should not be over-vectorized.

Do not use this when the user needs every icon to be independently editable vector geometry.

## Workflow

1. Preserve the source raster and note its dimensions:

   ```bash
   sips -g pixelWidth -g pixelHeight input.png
   ```

2. Identify regions to keep as images: photos, product shots, screenshots, maps, complex illustrations, charts, icons, small pictograms, logos, shadows, gradients, and texture-heavy backgrounds. Do not include surrounding text in these crops unless that text is part of a logo or screenshot that should remain a single image.

3. Crop those regions into `assets/icon-crops/`:

   ```bash
   mkdir -p assets/icon-crops
   magick input.png -crop WIDTHxHEIGHT+X+Y assets/icon-crops/name.png
   ```

4. Rebuild the SVG with:

   - outer panels, cards, separators, pills, and banners as `<rect>`, `<path>`, `<line>`, `<circle>`.
   - all editable text as `<text>`/`<tspan>`, using likely local Korean fonts such as `"Malgun Gothic"` and `"Apple SD Gothic Neo"` when relevant.
   - cropped assets and all photographic regions as embedded base64 `<image>` elements.
   - original `viewBox` dimensions matching the source raster.

5. Keep the final SVG self-contained unless the user explicitly wants linked image files.

6. Verify:

   ```bash
   xmllint --noout output.svg
   rsvg-convert -w WIDTH -h HEIGHT output.svg -o output_preview.png
   ```

   Inspect the preview. Fix obvious overlaps, crop seams, text overflow, and mismatched background rectangles.

## Helper Script

Use `scripts/embed_crops.py` when a generated SVG template already contains placeholders and a JSON crop spec.

The script crops from the source raster and replaces placeholders like `{{asset_name}}` with `data:image/png;base64,...`.

Example crop spec:

```json
[
  {"name": "hospital", "x": 28, "y": 239, "width": 175, "height": 91},
  {"name": "map_pin", "x": 1118, "y": 238, "width": 190, "height": 112}
]
```

Example use:

```bash
python /Users/hossay/.agents/skills/hybrid-image-svg/scripts/embed_crops.py \
  --source input.png \
  --spec crops.json \
  --template template.svg \
  --output output.svg \
  --crop-dir assets/icon-crops
```

In `template.svg`:

```xml
<image href="{{hospital}}" x="28" y="239" width="175" height="91"/>
```

## Practical Rules

- Avoid full-image tracing as the default for PPT. It often creates tens or hundreds of thousands of paths.
- Avoid full-panel crops as the default for PPT-editable SVG. They hide text inside images and prevent PPT text-box extraction.
- If visual exactness matters more than editability, also provide an exact bitmap-in-SVG variant.
- If PPT editability matters, keep text and layout as SVG elements and embed the hard-to-draw or photo-real pieces.
- Never trace photographs or photo-real regions into SVG paths by default. Crop and embed them as images unless the user explicitly asks for a stylized vector/posterized result.
- Prefer many small, tight image crops over a few large text-containing crops when building the main editable output.
- Crop slightly tight around icons when the crop sits on a colored banner; background color mismatches make visible rectangles.
- For icons on solid colored backgrounds, consider transparent background conversion with ImageMagick `-fuzz` and `-transparent`.
- Always tell the user which parts will remain editable and which parts are embedded images.
