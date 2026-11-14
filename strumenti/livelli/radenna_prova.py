# Il prato di prova di Radenna: un pezzo di livello fatto col kit delle strade
# e coi terreni (art/livelli/terreni/), per provarci a camminare sopra (anche
# l'erba ai piedi, scripts/ErbaAiPiedi.gd).
#
#   python3 strumenti/livelli/radenna_prova.py        (serve numpy e Pillow)
#   poi: godot prove/LivelloProva.tscn -- livello radenna
#
# Scrive art/livelli/radenna.png (la mappa, 640x480, alla misura del mondo),
# radenna_passi.png (dove si cammina: dappertutto, tranne un bordo) e
# radenna.json (la pianta, col giro del pilota: dall'erba alla strada, lungo la
# strada, giu' verso l'anello e di nuovo sull'erba).
import json
import os

import numpy as np
from PIL import Image

QUI = os.path.dirname(os.path.abspath(__file__))
LIVELLI = os.path.join(QUI, '..', '..', 'art', 'livelli')
TERRENI = os.path.join(LIVELLI, 'terreni')
KIT = os.path.join(TERRENI, 'strade_radenna')
W, H = 640, 480


def pezzo(nome):
    return Image.open(os.path.join(KIT, nome + '.png')).convert('RGBA')


mappa = Image.new('RGBA', (W, H))
erbe = [Image.open(os.path.join(TERRENI, 'erba_radenna%s.png' % s)).convert('RGBA') for s in ('', '_2', '_3', '_4')]
caso = np.random.default_rng(7)
for y in range(0, H, 64):
    for x in range(0, W, 64):
        mappa.alpha_composite(erbe[caso.integers(4)], (x, y))


def metti(p, x, y, ritaglio=None):
    if isinstance(p, str):
        p = pezzo(p)
    if ritaglio:
        p = p.crop(ritaglio)
    x0, y0 = max(0, -x), max(0, -y)
    x1, y1 = min(p.width, W - x), min(p.height, H - y)
    if x1 > x0 and y1 > y0:
        mappa.alpha_composite(p.crop((x0, y0, x1, y1)), (x + x0, y + y0))


def orizzontale(x0, x1, y, fine_dx=False):
    t = pezzo('strada_orizzontale'); x = x0; fine = x1 - (14 if fine_dx else 0)
    while x < fine:
        metti(t, x, y, (0, 0, min(55, fine - x), 29)); x += 55
    if fine_dx:
        metti('fine_strada_dx', fine, y)


def verticale(y0, y1, x):
    t = pezzo('strada_verticale'); y = y0
    while y < y1:
        metti(t, x, y, (0, 0, 29, min(55, y1 - y))); y += 55


# il nodo in alto, con la strada che attraversa la mappa e scende all'anello
NX, NY = 300, 90
orizzontale(0, NX, NY + 6)
orizzontale(NX + 41, W, NY + 6)
metti('nodo', NX, NY)
metti('foglia_3', NX - 38, NY + 40)
metti('foglia_4', NX + 45, NY + 40)
CX, CY = 320, 300                      # l'anello: le strade ci entrano fino a 31 pixel dal centro
verticale(NY + 41, CY - 31, NX + 6)
orizzontale(CX + 31, 560, CY - 14, fine_dx=True)
verticale(CY + 31, H, CX - 14)
metti('anello', CX - 38, CY - 38)
metti('rovina_2', 566, CY - 14)
metti('rovina_3', 585, CY + 16)
metti('muretto_angolo', 40, 380)
metti('tratto_corto', 70, 200)
mappa.save(os.path.join(LIVELLI, 'radenna.png'))

passi = np.zeros((H, W), bool)
passi[6:H - 6, 6:W - 6] = True
Image.fromarray((passi * 255).astype(np.uint8)).convert('L').convert('RGBA').save(os.path.join(LIVELLI, 'radenna_passi.png'))
# la maschera e' bianca (opaca) dove si cammina, trasparente fuori
m = np.zeros((H, W, 4), np.uint8); m[passi] = (255, 255, 255, 255)
Image.fromarray(m).save(os.path.join(LIVELLI, 'radenna_passi.png'))

pianta = {
    "_nota": "Il prato di prova di Radenna, fatto col kit delle strade da strumenti/livelli/radenna_prova.py: "
             "per camminare sull'erba e sulle strade di Radenna. Non e' ancora un livello del gioco.",
    "nome": "Prato di Radenna",
    "mappa": "radenna.png",
    "scala": 1, "pixel": 1, "ingrandimento": 2,
    "_scala": "La mappa e' alla misura del mondo (un pixel, un pixel del mondo, come lei); la telecamera "
              "ingrandisce due volte.",
    "passi": "radenna_passi.png",
    "erba": {"tinta": [0.2, 0.47], "saturazione": 0.42, "luce": [0.1, 0.85]},
    "_erba": "Cos'e' erba sotto i piedi (scripts/ErbaAiPiedi.gd): i verdi del prato di Radenna sono saturi "
             "(da 0,46 in su), il bordo scuro delle strade no (0,38).",
    "limiti": [0, 0, W, H],
    "partenza": [150, 250], "verso": [1, 0],
    "stanze": [{"nome": "Prato di Radenna", "rett": [0, 0, W, H]}],
    "giro": [[150, 250], [240, 250], [240, 110], [320, 110], [320, 228], [420, 228], [420, 400],
             [200, 400], [200, 300]],
    "_giro": "Dall'erba alla strada, lungo la strada fino al nodo, giu' verso l'anello, di nuovo sull'erba.",
}
with open(os.path.join(LIVELLI, 'radenna.json'), 'w') as f:
    json.dump(pianta, f, indent=1, ensure_ascii=False)
    f.write('\n')
print('radenna: mappa %dx%d, giro di %d tappe' % (W, H, len(pianta["giro"])))
