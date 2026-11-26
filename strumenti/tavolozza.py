"""Le tavolozze col segreto degli esempi di Bru (108, 109, 110). Misurati in OKLCH (luce L, intensita' C, tinta h,
come li vede l'occhio), i colori degli esempi seguono queste regole:
1. le ombre girano verso il blu-viola: scendendo di luce la tinta ruota piano, poi sempre piu' in fretta, fino al
   viola dell'ombra (h ~285); l'erba va giallo-verde -> verde -> verde acqua -> blu-viola, il tronco arancio ->
   rosso -> magenta -> viola;
2. le luci girano verso il giallo: la luce dell'erba tira al giallo, il bianco dei fiori e' crema, mai bianco puro;
3. gli scuri sono spenti: l'intensita' sta nei toni medi e chiari e crolla nelle ombre, verso quella dell'ombra;
4. tutte le rampe finiscono nella stessa famiglia di viola scuro (l'OMBRA): e' quello che tiene insieme materiali
   diversi;
5. pochi colori per materiale (4-7), salti di luce regolari, piu' larghi nelle ombre.
rampa() fa una rampa nuova con queste regole partendo da un colore solo (il tono medio del materiale); con il verde
medio degli esempi rifa' la rampa dell'erba di Bru. ricolora() porta un disegno sulle rampe dei suoi materiali
(riconosciuti dalla tinta), tenendo le sue luci e le sue ombre.

modulo; uso: tavolozza.py foglio.png   (gli esempi, la prova sull'erba e le rampe dei materiali di Radenna)"""
import numpy as np

# ---------------------------------------------------------------- OKLab / OKLCH
_M1 = np.array([[0.4122214708, 0.5363325363, 0.0514459929], [0.2119034982, 0.6806995451, 0.1073969566],
                [0.0883024619, 0.2817188376, 0.6299787005]])
_M2 = np.array([[0.2104542553, 0.7936177850, -0.0040720468], [1.9779984951, -2.4285922050, 0.4505937099],
                [0.0259040371, 0.7827717662, -0.8086757660]])
_M2I = np.linalg.inv(_M2)
_M1I = np.linalg.inv(_M1)


def oklch(rgb):
    c = np.asarray(rgb, float) / 255.0
    lin = np.where(c <= 0.04045, c / 12.92, ((c + 0.055) / 1.055) ** 2.4)
    L, a, b = np.moveaxis(np.cbrt(lin @ _M1.T) @ _M2.T, -1, 0)
    return np.stack([L, np.hypot(a, b), np.degrees(np.arctan2(b, a)) % 360], -1)


def _rgb_lin(L, C, h):
    a, b = C * np.cos(np.radians(h)), C * np.sin(np.radians(h))
    return (np.stack([L, a, b], -1) @ _M2I.T) ** 3 @ _M1I.T


def rgb(L, C, h):
    # da OKLCH a sRGB; se il colore non c'e' sullo schermo, si toglie intensita' finche' c'e'
    lo, hi = 0.0, C
    lin = _rgb_lin(L, C, h)
    if lin.min() < -1e-4 or lin.max() > 1 + 1e-4:
        for _ in range(30):
            m = (lo + hi) / 2
            t = _rgb_lin(L, m, h)
            if t.min() < -1e-4 or t.max() > 1 + 1e-4:
                hi = m
            else:
                lo = m
        lin = _rgb_lin(L, lo, h)
    lin = np.clip(lin, 0, 1)
    s = np.where(lin <= 0.0031308, lin * 12.92, 1.055 * lin ** (1 / 2.4) - 0.055)
    return tuple(int(round(v)) for v in np.clip(s * 255, 0, 255))


# ---------------------------------------------------------------- gli esempi di Bru
ESEMPI = {
    'erba (108)': [(53, 62, 78), (74, 109, 111), (89, 160, 116), (101, 189, 105), (151, 208, 95), (161, 220, 110),
                   (213, 252, 135)],
    'tronco (110)': [(69, 62, 116), (110, 64, 100), (130, 66, 93), (172, 105, 88)],
    'fiore (108)': [(246, 228, 146), (252, 255, 232)],
    'sfondo': [(47, 41, 67)],
}
OMBRA_H, OMBRA_C, OMBRA_L = 275.0, 0.04, 0.36       # il viola scuro dove finiscono tutte le rampe
LUCE_H = 100.0                                      # il giallo verso cui girano le luci


def _verso(h0, h1):
    # di quanti gradi girare da h0 a h1 per la strada piu' corta
    return ((h1 - h0 + 180) % 360) - 180


def rampa(chiave, n=5, basso=None, alto=None, scuri=1.6, luci=0.5, ombra_c=OMBRA_C):
    """n colori dallo scuro al chiaro, col tono medio 'chiave'. basso/alto: la luce del piu' scuro e del piu' chiaro
    (di solito l'ombra comune e poco sopra la chiave); scuri: quanto in fretta gira verso l'ombra; luci: quanta
    strada fa verso il giallo nelle luci (0-1); ombra_c: l'intensita' del piu' scuro (i caldi, come il tronco, hanno
    l'ombra viola piu' viva)"""
    Lk, Ck, hk = oklch(chiave)
    basso = OMBRA_L if basso is None else basso
    alto = min(0.95, Lk + 0.2) if alto is None else alto
    t = np.linspace(0, 1, n) ** 0.85                                # salti piu' larghi nelle ombre
    out = []
    for L in basso + (alto - basso) * t:
        if L <= Lk:
            w = ((Lk - L) / max(Lk - basso, 1e-6)) ** scuri
            h = hk + _verso(hk, OMBRA_H) * w
            # l'intensita' crolla gia' a meta' discesa (negli esempi a L 0.51 e' gia' quella dell'ombra)
            C = Ck + (ombra_c - Ck) * min(1.0, (Lk - L) / max(Lk - basso, 1e-6) / 0.6) ** 0.9
        else:
            w = ((L - Lk) / max(alto - Lk, 1e-6)) ** 0.6
            h = hk + _verso(hk, LUCE_H) * luci * w
            C = Ck * (1 - 0.05 * w)
        out.append(rgb(L, max(C, 0.0), h % 360))
    return out


# ---------------------------------------------------------------- i materiali di Radenna
MATERIALI = {
    # rampe dallo scuro al chiaro: il tono medio (chiave), quanti colori, la luce del piu' scuro e del piu' chiaro,
    # quanto gira verso l'ombra, quanto verso il giallo
    'erba': dict(chiave=(101, 189, 105), n=7, basso=0.36, alto=0.94, scuri=1.6, luci=0.55),
    'chioma': dict(chiave=(84, 160, 104), n=6, basso=0.36, alto=0.86, scuri=1.5, luci=0.6),   # alberi, cespugli
    'pino': dict(chiave=(62, 132, 112), n=5, basso=0.34, alto=0.74, scuri=1.4, luci=0.5),     # aghi, piu' freddi
    'muschio': dict(chiave=(128, 176, 92), n=5, basso=0.40, alto=0.86, scuri=1.5, luci=0.6),
    'pietra': dict(chiave=(150, 152, 146), n=6, basso=0.36, alto=0.90, scuri=1.4, luci=0.45),  # mai grigio puro
    'tronco': dict(chiave=(172, 105, 88), n=5, basso=0.36, alto=0.72, scuri=1.4, luci=0.4, ombra_c=0.085),
    'acqua': dict(chiave=(86, 176, 196), n=6, basso=0.38, alto=0.93, scuri=1.4, luci=0.35),
    'viola': dict(chiave=(150, 118, 200), n=5, basso=0.36, alto=0.86, scuri=1.4, luci=0.35),  # fiori viola
    'rosso': dict(chiave=(214, 104, 112), n=5, basso=0.36, alto=0.86, scuri=1.4, luci=0.4, ombra_c=0.08),
    'oro': dict(chiave=(232, 190, 92), n=5, basso=0.40, alto=0.95, scuri=1.4, luci=0.5, ombra_c=0.07),
}
# i fiori come negli esempi: il petalo crema (mai bianco puro) e il cuore giallo
FIORE = {'petalo': (252, 255, 232), 'cuore': (246, 228, 146)}


def tavolozze():
    r = {k: rampa(**v) for k, v in MATERIALI.items()}
    # i contorni e i neri dei disegni: l'ombra comune, e un gradino sotto (mai nero puro)
    r['ombra'] = [(47, 41, 67), (53, 62, 78)]          # i due scuri degli esempi di Bru
    return r


# ---------------------------------------------------------------- ricolorare un disegno
def materiale(L, C, h, pini=False):
    # di che materiale e' un colore, dalla tinta e dall'intensita'
    if L < 0.2:
        return 'ombra'
    if C < 0.035:
        return 'pietra'
    if 175 <= h < 250:
        return 'acqua' if C > 0.06 else 'pietra'
    if 125 <= h < 175:
        return 'pino' if pini else 'chioma'
    if 100 <= h < 125:
        return 'pino' if pini else 'muschio'
    if 70 <= h < 100:
        return 'oro' if C >= 0.09 else 'muschio'
    if 250 <= h < 330:
        return 'viola'
    if h >= 330 or h < 20:
        return 'rosso' if C >= 0.08 else 'tronco'
    return 'tronco'


def ricolora_colori(colori, rampe=None, pini=False, forza=None, curva=None, sostituisci=None):
    """dove va ogni colore: al suo materiale (forza: un materiale per tutti), e dentro il materiale al colore della
    rampa con la luce giusta. Con 'curva' [(luce vecchia, luce nuova), ...] la luce nuova e' la stessa per tutta la
    scena (un oggetto scuro resta piu' scuro di uno chiaro); senza, le luci di ogni materiale si stendono su tutta la
    sua rampa. 'sostituisci' {materiale: altro}: di che cosa e' fatto il disegno (in un cespuglio i verdi spenti sono
    foglie, non pietra)"""
    rampe = rampe or tavolozze()
    cols = np.array(colori, float).reshape(-1, 3)
    lch = oklch(cols)
    gruppi = {}
    for c, (L, C, h) in zip(cols, lch):
        m = forza or materiale(L, C, h, pini)
        m = (sostituisci or {}).get(m, m)
        gruppi.setdefault(m, []).append((L, tuple(int(v) for v in c)))
    mappa = {}
    for m, lista in gruppi.items():
        r = rampe[m]
        Ls = np.array([L for L, _ in lista])
        lo, hi = Ls.min(), Ls.max()
        rl = oklch(r)[:, 0]
        for L, c in lista:
            if curva is not None:
                Lr = np.interp(L, [a for a, _ in curva], [b for _, b in curva])
            else:
                t = 0.5 if hi - lo < 1e-6 else (L - lo) / (hi - lo)
                Lr = rl[0] + t * (rl[-1] - rl[0])
            mappa[c] = r[int(np.abs(rl - Lr).argmin())]
    return mappa


def ricolora(img, rampe=None, pini=False, forza=None, curva=None, sostituisci=None):
    """porta i colori di un disegno RGBA sulle rampe dei materiali (vedi ricolora_colori); i trasparenti restano"""
    a = np.asarray(img).copy()
    op = a[..., 3] > 0
    if not op.any():
        return a
    mappa = ricolora_colori(np.unique(a[op][:, :3], axis=0), rampe, pini, forza, curva, sostituisci)
    fl = a[..., :3].reshape(-1, 3)
    chiavi = fl[:, 0].astype(int) * 65536 + fl[:, 1].astype(int) * 256 + fl[:, 2].astype(int)
    opf = op.reshape(-1)
    for c, n in mappa.items():
        sel = opf & (chiavi == c[0] * 65536 + c[1] * 256 + c[2])
        fl[sel] = n
    a[..., :3] = fl.reshape(a.shape[:2] + (3,))
    return a


if __name__ == '__main__':
    import sys

    from PIL import Image, ImageDraw
    righe = []
    for nome, r in ESEMPI.items():
        righe.append(('Bru: ' + nome, r))
    righe.append(('rifatta dal solo verde medio', rampa((101, 189, 105), 7, 0.36, 0.94, 1.6, 0.55)))
    for nome, r in tavolozze().items():
        righe.append((nome, r))
    q, gx = 34, 220
    tela = Image.new('RGB', (gx + 7 * (q + 4) + 10, len(righe) * (q + 8) + 10), (47, 41, 67))
    d = ImageDraw.Draw(tela)
    for j, (nome, r) in enumerate(righe):
        y = 8 + j * (q + 8)
        d.text((8, y + q // 2 - 6), nome, fill=(232, 226, 240))
        for i, c in enumerate(r):
            d.rectangle([gx + i * (q + 4), y, gx + i * (q + 4) + q - 1, y + q - 1], fill=tuple(c))
    tela.save(sys.argv[1])
    print('rifatta:', rampa((101, 189, 105), 7, 0.36, 0.94, 1.6, 0.55))
    print('Bru:    ', ESEMPI['erba (108)'])
