#!/usr/bin/env python3
import argparse
import base64
import json
import os
import subprocess
from pathlib import Path


def run(args):
    subprocess.run(args, check=True)


def encode_data_uri(path):
    data = Path(path).read_bytes()
    return "data:image/png;base64," + base64.b64encode(data).decode("ascii")


def crop_source(source, crop_dir, item):
    name = item["name"]
    x = int(item["x"])
    y = int(item["y"])
    width = int(item["width"])
    height = int(item["height"])
    output = Path(crop_dir) / f"{name}.png"
    output.parent.mkdir(parents=True, exist_ok=True)
    run([
        "magick",
        str(source),
        "-crop",
        f"{width}x{height}+{x}+{y}",
        "+repage",
        "-strip",
        str(output),
    ])
    return output


def main():
    parser = argparse.ArgumentParser(
        description="Crop image regions and embed them into an SVG template as base64 data URIs."
    )
    parser.add_argument("--source", required=True, help="Source raster image, usually PNG.")
    parser.add_argument("--spec", required=True, help="JSON array of crop objects.")
    parser.add_argument("--template", required=True, help="SVG template with {{name}} placeholders.")
    parser.add_argument("--output", required=True, help="Final self-contained SVG path.")
    parser.add_argument("--crop-dir", default="assets/icon-crops", help="Directory for generated crop PNGs.")
    args = parser.parse_args()

    source = Path(args.source)
    crop_dir = Path(args.crop_dir)
    spec = json.loads(Path(args.spec).read_text())
    svg = Path(args.template).read_text()

    for item in spec:
        crop = crop_source(source, crop_dir, item)
        svg = svg.replace("{{" + item["name"] + "}}", encode_data_uri(crop))

    Path(args.output).write_text(svg)


if __name__ == "__main__":
    main()
