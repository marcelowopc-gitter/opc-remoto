"""Gera os assets de marca 'Suporte OPC' para o build personalizado do RustDesk."""
import sys
from pathlib import Path
from PIL import Image, ImageDraw

MARCA = Path(sys.argv[1])          # pasta com logo-opcao-telecom.png
OUT = Path(sys.argv[2])            # pasta de saida
OUT.mkdir(parents=True, exist_ok=True)

NAVY = (0, 19, 75)       # #00134B (site)
BLUE = (0, 52, 130)      # #003482 (logo)
RED = (230, 30, 35)      # vermelho do logo, levemente suavizado
WHITE = (255, 255, 255)


def icon(size: int) -> Image.Image:
    """Quadrado arredondado em degrade marinho->azul, anel 'O' branco e traco vermelho."""
    s = 1024
    img = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    # degrade diagonal
    grad = Image.new("RGBA", (s, s))
    gp = grad.load()
    for y in range(s):
        for x in range(s):
            t = (x + (s - y)) / (2 * s)
            gp[x, y] = tuple(int(NAVY[i] + (BLUE[i] - NAVY[i]) * t) for i in range(3)) + (255,)
    mask = Image.new("L", (s, s), 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, s - 1, s - 1), radius=int(s * 0.22), fill=255)
    img.paste(grad, (0, 0), mask)
    d = ImageDraw.Draw(img)
    # anel "O"
    cx, cy, r, w = s / 2, s * 0.47, s * 0.27, s * 0.105
    d.ellipse((cx - r, cy - r, cx + r, cy + r), outline=WHITE, width=int(w))
    # traco vermelho (referencia ao acento do logo OPCAO)
    bw, bh = s * 0.30, s * 0.075
    by = cy + r + s * 0.075
    d.rounded_rectangle((cx - bw / 2, by, cx + bw / 2, by + bh), radius=int(bh / 2), fill=RED)
    return img.resize((size, size), Image.LANCZOS)


big = icon(1024)
big.save(OUT / "icon-1024.png")
for n in (32, 64, 128, 256):
    icon(n).save(OUT / f"{n}x{n}.png")
icon(256).save(OUT / "icon.png")  # flutter/assets/icon.png e res/icon.png

ico_sizes = [(16, 16), (24, 24), (32, 32), (48, 48), (64, 64), (128, 128), (256, 256)]
big.save(OUT / "icon.ico", sizes=ico_sizes)
big.save(OUT / "app_icon.ico", sizes=ico_sizes)
big.save(OUT / "tray-icon.ico", sizes=[(16, 16), (24, 24), (32, 32), (48, 48)])

# logos 300x60 max (tela inicial do app)
logo = Image.open(MARCA / "logo-opcao-telecom.png").convert("RGBA")
logo.save(OUT / "logo_dark.png")  # branco + vermelho, para tema escuro
light = logo.copy()
px = light.load()
for y in range(light.height):
    for x in range(light.width):
        r, g, b, a = px[x, y]
        if a and not (r > 180 and g < 120 and b < 120):
            px[x, y] = BLUE + (a,)
light.save(OUT / "logo_light.png")  # azul + vermelho, para tema claro
light.save(OUT / "logo.png")

# label 96x32 da tela de extracao (fundo marinho)
lab = Image.new("RGB", (96, 32), NAVY)
lw = 88
lg = logo.resize((lw, round(logo.height * lw / logo.width)), Image.LANCZOS)
lab.paste(lg, ((96 - lg.width) // 2, (32 - lg.height) // 2), lg)
lab.save(OUT / "label.png")

for f in sorted(OUT.iterdir()):
    print(f.name, f.stat().st_size)
