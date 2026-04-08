#!/usr/bin/env python3
from PIL import Image, ImageDraw, ImageFont
import os

# iPhone 16 Pro Max landscape: 2868x1320
W, H = 2868, 1320
out_dir = "/Users/user/Soroban/screenshots"
os.makedirs(out_dir, exist_ok=True)

DARK_BG = (30, 25, 20)
WOOD_DARK = (89, 51, 26)
WOOD_MED = (102, 61, 31)
WOOD_LIGHT = (115, 71, 36)
BEAM_COLOR = (102, 61, 31)
BEAD_HEAVEN = (51, 31, 15)
BEAD_EARTH = (115, 71, 36)
BEAD_ACTIVE = (140, 90, 45)
ROD_COLOR = (140, 128, 115)
CREAM = (230, 217, 179)
DISPLAY_BG = (20, 15, 10)

def get_font(size):
    paths = [
        "/System/Library/Fonts/Helvetica.ttc",
        "/System/Library/Fonts/SFNSMono.ttf",
        "/Library/Fonts/Arial Unicode.ttf",
    ]
    for p in paths:
        if os.path.exists(p):
            try:
                return ImageFont.truetype(p, size)
            except:
                pass
    return ImageFont.load_default()

def draw_soroban(draw, offset_x=0, heaven_active=None, earth_active=None):
    margin = 80 + offset_x
    sW = W - margin * 2 + offset_x
    sH = H * 0.75
    sY = (H - sH) / 2 + 30

    # Frame
    draw.rounded_rectangle([margin, sY, margin + sW, sY + sH], radius=12, outline=WOOD_DARK, width=16, fill=(64, 38, 20))

    # Beam at 30% from top
    beamY = sY + sH * 0.30
    draw.rectangle([margin, beamY - 8, margin + sW, beamY + 8], fill=BEAM_COLOR)

    rods = 13
    spacing = sW / (rods + 1)

    for i in range(rods):
        x = margin + spacing * (i + 1)
        # Rod
        draw.line([(x, sY + 16), (x, sY + sH - 16)], fill=ROD_COLOR, width=3)

        # Heaven bead
        bw, bh = spacing * 0.38, sH * 0.055
        h_active = heaven_active[i] if heaven_active else False
        if h_active:
            by = beamY - 8 - bh
        else:
            by = sY + 20
        color = BEAD_ACTIVE if h_active else BEAD_HEAVEN
        draw_bead(draw, x, by + bh/2, bw, bh, color)

        # Earth beads
        for j in range(4):
            e_active = earth_active[i][j] if earth_active else False
            if e_active:
                by = beamY + 12 + j * (bh + 4)
            else:
                by = sY + sH - 20 - (3-j) * (bh + 4) - bh
            color = BEAD_ACTIVE if e_active else BEAD_EARTH
            draw_bead(draw, x, by + bh/2, bw, bh, color)

    # Dot markers
    for pos in [3, 6, 9]:
        dx = margin + spacing * (pos + 1)
        draw.ellipse([dx-5, beamY-5, dx+5, beamY+5], fill=CREAM)

def draw_bead(draw, cx, cy, hw, hh, color):
    # Diamond/bicone shape
    points = [
        (cx - hw, cy),
        (cx, cy - hh),
        (cx + hw, cy),
        (cx, cy + hh),
    ]
    draw.polygon(points, fill=color, outline=(color[0]+20, color[1]+15, color[2]+10))
    # Gloss
    gloss_points = [
        (cx - hw*0.4, cy - hh*0.1),
        (cx, cy - hh*0.7),
        (cx + hw*0.4, cy - hh*0.1),
    ]
    draw.polygon(gloss_points, fill=(color[0]+30, color[1]+25, color[2]+20))

# Screenshot 1: Default state with some values
img1 = Image.new("RGB", (W, H), DARK_BG)
d1 = ImageDraw.Draw(img1)
# Display bar
d1.rectangle([0, 0, W, 60], fill=DISPLAY_BG)
font = get_font(36)
d1.text((W - 200, 12), "7,832", fill=CREAM, font=font)
# Soroban with varied positions
h_active = [False, False, True, False, False, False, True, True, False, False, True, False, False]
e_active = [[j<3 for j in range(4)] if i==2 else [j<2 for j in range(4)] if i==6 else [j<1 for j in range(4)] if i==10 else [False]*4 for i in range(13)]
draw_soroban(d1, heaven_active=h_active, earth_active=e_active)
img1.save(os.path.join(out_dir, "01_main.png"))
print("Screenshot 1 created")

# Screenshot 2: All cleared
img2 = Image.new("RGB", (W, H), DARK_BG)
d2 = ImageDraw.Draw(img2)
d2.rectangle([0, 0, W, 60], fill=DISPLAY_BG)
d2.text((W - 100, 12), "0", fill=CREAM, font=font)
draw_soroban(d2)
img2.save(os.path.join(out_dir, "02_clear.png"))
print("Screenshot 2 created")

# Screenshot 3: Many values set
img3 = Image.new("RGB", (W, H), DARK_BG)
d3 = ImageDraw.Draw(img3)
d3.rectangle([0, 0, W, 60], fill=DISPLAY_BG)
d3.text((W - 350, 12), "9,876,543,210", fill=CREAM, font=font)
h3 = [True, True, False, True, True, False, True, False, False, True, True, False, True]
e3 = [[j<4 for j in range(4)], [j<3 for j in range(4)], [j<1 for j in range(4)],
      [j<2 for j in range(4)], [j<0 for j in range(4)], [j<4 for j in range(4)],
      [j<3 for j in range(4)], [j<2 for j in range(4)], [j<1 for j in range(4)],
      [j<0 for j in range(4)], [j<3 for j in range(4)], [j<1 for j in range(4)],
      [j<0 for j in range(4)]]
draw_soroban(d3, heaven_active=h3, earth_active=e3)
img3.save(os.path.join(out_dir, "03_values.png"))
print("Screenshot 3 created")

# Create 6.5 inch versions (2778x1284)
for fname in ["01_main.png", "02_clear.png", "03_values.png"]:
    img = Image.open(os.path.join(out_dir, fname))
    img65 = img.resize((2778, 1284), Image.LANCZOS)
    img65.save(os.path.join(out_dir, "65_" + fname))

print("All screenshots created!")
