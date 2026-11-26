"""I dati dell'acqua per la pagina: una PNG grande come la mappa (R,G = punto della tessera; B = bit) e un JSON.
B: bit 0-2 grado di scuro (0..4); bit 3 scorre; bit 4 increspature (se scorre) o cerchi (se ferma);
   bit 5 scintille; bit 6-7 schiuma (1 dentro, 2 fuori).
uso: dati_png.py acqua.npz uscita.png uscita.json"""
import sys, os, json
QUI = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, QUI)
import numpy as np
from PIL import Image
from anima import Acqua
TESSERA = os.path.join(QUI, '..', '..', '..', 'art', 'livelli', 'terreni', 'acqua_liscia.png')   # l'acqua liscia
NPZ, USCITA, INFO = sys.argv[1:4]
A = Acqua(NPZ, TESSERA)
d = A.d
H, W = A.H, A.W
du, dd = d['du'], d['dd']
img = np.zeros((H, W, 4), np.uint8)
ys, xs = A.ys, A.xs
img[ys, xs, 0] = A.tx0
img[ys, xs, 1] = A.ty
B = A.n.astype(int) & 7
B |= A.baia.astype(int) << 3                     # bit 3: lo stagno (i cerchi delle gocce restano qui dentro)
cor = A.ok_corrente[ys, xs]
B |= cor.astype(int) << 4                        # bit 4: ci passano le increspature
scint = (du[ys, xs] > 6) & (dd[ys, xs] > 3)
B |= scint.astype(int) << 5
B |= (A.schiuma[ys, xs].astype(int) & 3) << 6
img[ys, xs, 2] = B
img[ys, xs, 3] = 255
Image.fromarray(img, 'RGBA').save(USCITA, optimize=True)
# la fase del punto della tessera (quarti di pixel in x e in y: 4 * qx + qy), per prenderla nel punto esatto
fr = np.zeros((H, W, 4), np.uint8)
fr[ys, xs, 0] = A.fase
fr[ys, xs, 3] = 255
Image.fromarray(fr, 'RGBA').save(USCITA.replace('.png', '_frazioni.png'), optimize=True)
N = len(A.lin)
sassi = []
for (fx, fy, rx, ry) in A.sassi:
    i = int(np.clip(A.Uimg[int(fy), int(fx)], 0, N - 1))
    sassi.append([float(fx), float(fy), round(float(rx), 3), round(float(ry), 3), i])
info = {
    # i colori dell'acqua per la pagina: le tavolozze nuove (la tessera della pagina e' gia' ricolorata con questi)
    'AQ': (d['AQ_NUOVA'] if 'AQ_NUOVA' in d else A.AQ).astype(int).tolist(),
    'lin': [round(float(v), 2) for v in A.lin.reshape(-1)],
    'wl': [round(float(v), 2) for v in A.wl],
    'sassi': sassi,
    # dove nascono le gocce nello stagno: [indice del pixel, punto del filo] (in fila come nella prova)
    'gocce': [[int(y) * W + int(x), int(np.clip(A.Uimg[y, x], 0, N - 1))] for y, x in A.anelli],
    'fondo': -10,
    'vel': A.vel,
    'conti': {'animati': int(len(xs)), 'scorrono': int(A.scorre.sum()), 'increspature': int(cor.sum()),
              'gocce': int(len(A.anelli)), 'scintille': int(scint.sum())},
}
with open(INFO, 'w') as f:
    json.dump(info, f, separators=(',', ':'))
print(info['conti'], 'punti del filo', N)
