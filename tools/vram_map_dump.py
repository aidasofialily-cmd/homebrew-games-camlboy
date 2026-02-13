import sys
from PIL import Image

def decode_tile(tile_bytes):
    pixels = []
    for i in range(0, 16, 2):
        b1, b2 = tile_bytes[i], tile_bytes[i+1]
        for bit in range(7, -1, -1):
            color = ((b2 >> bit) & 1) << 1 | ((b1 >> bit) & 1)
            pixels.append(255 - (color * 85))
    return pixels

def render_full_map(vram_bin, output_png):
    with open(vram_bin, "rb") as f:
        data = f.read()

    # VRAM structure:
    # 0x0000 - 0x17FF: Tile Data (384 tiles)
    # 0x1800 - 0x1BFF: BG Map 1 ($9800-$9BFF)
    
    # 1. Decode all tiles into a dictionary
    tiles = {}
    for i in range(384):
        start = i * 16
        tiles[i] = decode_tile(data[start:start+16])

    # 2. Build the 256x256 map (32x32 tiles)
    full_map = Image.new('L', (256, 256))
    bg_map_start = 0x1800 

    for row in range(32):
        for col in range(32):
            # Get tile index from the background map
            tile_idx = data[bg_map_start + (row * 32) + col]
            
            # Note: Handle Signed vs Unsigned addressing if using 0x8800 method
            # For simplicity, we assume 0x8000 addressing here
            tile_pixels = tiles.get(tile_idx, [0]*64)
            
            tile_img = Image.frombytes('L', (8, 8), bytes(tile_pixels))
            full_map.paste(tile_img, (col * 8, row * 8))

    full_map.save(output_png)
    print(f"🖼️  Full Background Map saved to {output_png}")

if __name__ == "__main__":
    render_full_map(sys.argv[1], sys.argv[2])
