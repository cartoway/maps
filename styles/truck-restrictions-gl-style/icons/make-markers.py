#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import glob
import io
import json
import os
import re

import resvg_py
from PIL import Image
from rectpack import newPacker

ASSETS_FOLDER = "."
TARGET_BASE = 40


def get_svg_size(svg_text):
    m = re.search(
        r'viewBox\s*=\s*["\']\s*([-\d.]+)[\s,]+([-\d.]+)[\s,]+([-\d.]+)[\s,]+([-\d.]+)\s*["\']',
        svg_text,
    )
    if m:
        w = float(m.group(3))
        h = float(m.group(4))
        if w > 0 and h > 0:
            return w, h

    svg_tag = re.search(r"<svg\b[^>]*>", svg_text, re.DOTALL)
    if svg_tag:
        width_match = re.search(
            r'\bwidth\s*=\s*["\']\s*([-\d.]+)(?:px)?\s*["\']', svg_tag.group(0)
        )
        height_match = re.search(
            r'\bheight\s*=\s*["\']\s*([-\d.]+)(?:px)?\s*["\']', svg_tag.group(0)
        )
        if width_match and height_match:
            w = float(width_match.group(1))
            h = float(height_match.group(1))
            if w > 0 and h > 0:
                return w, h

    return None


def svg_to_png_scaled(svg, pixel_ratio=1):
    target = TARGET_BASE * pixel_ratio
    size = get_svg_size(svg)
    if size:
        width, height = size
        scale = target / max(width, height)
        target_width = max(1, round(width * scale))
        target_height = max(1, round(height * scale))
    else:
        target_width = target
        target_height = target

    png_bytes = resvg_py.svg_to_bytes(
        svg_string=svg,
        width=target_width,
        height=target_height,
    )
    return Image.open(io.BytesIO(png_bytes)).convert("RGBA")


def make_gl_sprites(items, assets_folder):
    items = sorted(items, key=lambda item: item["name"])

    for pixel_ratio in [1, 2]:
        print(f"generate {pixel_ratio}x")
        icons_data = []
        failed = []
        for item in items:
            try:
                img = svg_to_png_scaled(item["svg"], pixel_ratio)
            except Exception as exc:
                failed.append(f"{item['name']}: {exc}")
                continue
            icons_data.append({"name": item["name"], "img": img})
        if failed:
            raise RuntimeError("failed to render icons:\n" + "\n".join(failed))

        w = 64
        h = 64
        rectangles = []
        while True:
            print(f"trying {w}x{h}")
            packer = newPacker(rotation=False)
            for index, item in enumerate(icons_data):
                packer.add_rect(item["img"].width, item["img"].height, index)
            packer.add_bin(w, h)
            packer.pack()
            rectangles = packer.rect_list()
            if len(rectangles) == len(icons_data):
                print("packed all")
                break
            if w >= 4096 and h >= 4096:
                raise RuntimeError(
                    f"could not pack {len(icons_data)} icons within 4096x4096"
                )
            if w < h:
                w *= 2
            else:
                h *= 2

        max_x = max(rect[1] + rect[3] for rect in rectangles)
        max_y = max(rect[2] + rect[4] for rect in rectangles)
        sprite_canvas = Image.new("RGBA", (max_x, max_y), (0, 0, 0, 0))
        sprite_json = {}
        for rect in rectangles:
            _, x, y, width, height, icon_idx = rect
            icon = icons_data[icon_idx]
            sprite_canvas.paste(icon["img"], (x, y))
            sprite_json[icon["name"]] = {
                "width": width,
                "height": height,
                "x": x,
                "y": y,
                "pixelRatio": pixel_ratio,
            }

        suffix = f"@{pixel_ratio}x" if pixel_ratio > 1 else ""
        png_path = os.path.join(assets_folder, f"../sprite{suffix}.png")
        json_path = os.path.join(assets_folder, f"../sprite{suffix}.json")
        with open(png_path, "wb") as f:
            sprite_canvas.save(f, "PNG")
        with open(json_path, "w", encoding="utf-8") as f:
            json.dump(sprite_json, f)
        print(f"done {suffix}")


def main():
    svg_files = sorted(glob.glob("*.svg"))
    if not svg_files:
        raise RuntimeError("no SVG files found")

    items = []
    for svg_path in svg_files:
        name = os.path.splitext(os.path.basename(svg_path))[0]
        with open(svg_path, encoding="utf-8") as f:
            items.append({"name": name, "svg": f.read()})

    make_gl_sprites(items, ASSETS_FOLDER)


if __name__ == "__main__":
    main()
