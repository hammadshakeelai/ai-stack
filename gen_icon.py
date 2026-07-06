"""Generate odysseus.ico — a dark tile with a red mountain (matches the app)."""
import os
from PIL import Image, ImageDraw

S = 256
img = Image.new("RGBA", (S, S), (0, 0, 0, 0))
d = ImageDraw.Draw(img)

# Rounded dark tile background
bg = (30, 37, 48, 255)      # #1e2530
d.rounded_rectangle([6, 6, S - 6, S - 6], radius=46, fill=bg)

# Mountain (accent red/pink, like the Odysseus wordmark)
accent = (224, 108, 117, 255)   # #e06c75
d.polygon([(40, 196), (112, 78), (150, 140), (176, 104), (220, 196)], fill=accent)

# Snow cap on the main peak
d.polygon([(112, 78), (96, 104), (130, 104)], fill=(245, 245, 245, 255))

out = os.path.join(os.path.dirname(os.path.abspath(__file__)), "odysseus.ico")
img.save(out, sizes=[(16, 16), (32, 32), (48, 48), (64, 64), (128, 128), (256, 256)])
print("ICON_SAVED", out)
