"""
This module contains tools to decode and dump Game Boy VRAM binary dumps into PNG images.
"""
import sys
from PIL import Image

def decode_tile(tile_bytes):
    """Decodes 16 bytes of 2BPP data into an 8x8 pixel array."""
    pixels = []
    for i in range(0, 16, 2):
        byte1 = tile_bytes[i]
        byte2 = tile_bytes[i+1]
        for bit in range(7, -1, -1):
            # Interleave bits to get color index (0-3)
            color = ((byte2 >> bit) & 1) << 1 | ((byte1 >> bit) & 1)
            # Map to grayscale: 0=White, 3=Black
            pixels.append(255 - (color * 85))
    return pixels

def dump_to_png(input_bin, output_png):
    """Reads VRAM binary dump and dumps the decoded tiles to a PNG image file."""
    with open(input_bin, "rb") as f:
        vram = f.read()

    # A full tile set is 256 tiles, arranged in a 16x16 grid
    canvas = Image.new('L', (128, 128))

    for tile_idx in range(256):
        start = tile_idx * 16
        tile_data = vram[start : start + 16]
        if len(tile_data) < 16:
            break

        pixels = decode_tile(tile_data)

        # Calculate position in 128x128 grid
        x_off = (tile_idx % 16) * 8
        y_off = (tile_idx // 16) * 8

        tile_img = Image.frombytes('L', (8, 8), bytes(pixels))
        canvas.paste(tile_img, (x_off, y_off))

    canvas.save(output_png)
    print(f"✅ VRAM snapshot saved to {output_png}")

if __name__ == "__main__":
    dump_to_png(sys.argv[1], sys.argv[2])
