"""Il fogliame a masse (l'albero 121 di Bru: "pochi pixel separati, sono piu' che altro masse, non si punta al reale ma
al toon"). Al posto dei ciuffetti piccoli ripetuti fitti (_fogliame di piante.py): pochi grumi grandi, tondi, messi su
file sfalsate; quelli in alto stanno davanti e coprono quelli sotto col loro bordo di sotto frastagliato a foglie (le
punte); ogni grumo ha la sua luce (chiaro in alto a sinistra) sopra la luce generale della chioma, e i toni sono pochi
e netti. Dentro un tono niente puntini: i pixel soli prendono il tono che hanno attorno.
Stessa firma di piante._fogliame, cosi' si puo' mettere al suo posto."""
import numpy as np


def _punte(ang, r, ogni=4.0):
    """un'onda a denti di sega lungo il giro del grumo: una punta ogni 'ogni' pixel"""
    foglie = max(5, int(round(2 * np.pi * r / ogni)))
    u = (ang / (2 * np.pi) * foglie) % 1.0
    return 1 - 4 * np.abs(u - 0.5)


def pulisci_toni(liv, m, volte=3):
    """un pixel che non ha nessuno dei quattro vicini col suo tono prende il tono piu' comune fra i vicini"""
    h, w = liv.shape
    for _ in range(volte):
        p = np.pad(liv, 1, constant_values=-9)
        vic = np.stack([p[:-2, 1:-1], p[2:, 1:-1], p[1:-1, :-2], p[1:-1, 2:]])
        solo = m & ~np.any(vic == liv[None], axis=0)
        if not solo.any():
            break
        for y, x in zip(*np.nonzero(solo)):
            v = [int(t) for t in vic[:, y, x] if t >= 0]
            if v:
                liv[y, x] = max(set(v), key=v.count)
    return liv


def masse(img, m, tono, rng, rampa=None, minimo=1, passo=(8, 6), lobi=None, raggio=7.5, grumi=(12, 9),
          forza=0.85):
    import piante as pt
    rampa = pt.CHIOMA if rampa is None else rampa
    h, w = m.shape
    n = len(rampa)
    out = np.full((h, w), -1)
    if not m.any():
        return out
    ys, xs = np.nonzero(m)
    sx, sy = grumi
    centri = []
    for j, y in enumerate(range(int(ys.min()) - 2, int(ys.max()) + 3, sy)):
        spost = (sx // 2) * (j % 2)
        for x in range(int(xs.min()) - 2 + spost, int(xs.max()) + 3, sx):
            cy, cx = y + int(rng.integers(-2, 3)), x + int(rng.integers(-2, 3))
            if 0 <= cy < h and 0 <= cx < w and m[cy, cx]:
                centri.append((cy, cx, raggio * rng.uniform(0.85, 1.25)))
    chi = np.full((h, w), -1)
    lx = np.zeros((h, w))
    ly = np.zeros((h, w))
    # dal basso in alto: quelli in alto vengono dopo, stanno davanti
    for k, (cy, cx, r) in sorted(enumerate(centri), key=lambda t: -t[1][0]):
        y0, y1 = max(0, int(cy - r * 1.3) - 2), min(h, int(cy + r * 1.3) + 3)
        x0, x1 = max(0, int(cx - r * 1.3) - 2), min(w, int(cx + r * 1.3) + 3)
        Y, X = np.mgrid[y0:y1, x0:x1]
        dx, dy = X - cx, (Y - cy) * 1.1
        d = np.hypot(dx, dy)
        ang = np.arctan2(dy, dx)
        rr = r * (1 + np.where(dy > 0, 0.22, 0.06) * _punte(ang, r, 4.5))
        dentro = (d <= rr) & m[y0:y1, x0:x1]
        if lobi is not None:
            dentro &= lobi[y0:y1, x0:x1] == lobi[cy, cx]
        chi[y0:y1, x0:x1][dentro] = k
        lx[y0:y1, x0:x1][dentro] = (dx / r)[dentro]
        ly[y0:y1, x0:x1][dentro] = (dy / r)[dentro]
    # ogni grumo ha un tono solo, piatto: quello della luce generale dove sta il suo centro (con un poco di caso);
    # dove il grumo guarda la luce (in alto a sinistra) una falce un tono piu' chiara, se non e' gia' in ombra
    toni = np.array([np.floor(tono[cy, cx] + rng.uniform(-0.3, 0.3) + 0.5) for cy, cx, _ in centri] or [0])
    liv = np.where(chi >= 0, toni[np.maximum(chi, 0)], np.floor(tono - 0.5 + 0.5)).astype(int)
    falce = (chi >= 0) & (0.6 * lx + 0.8 * ly < -0.62) & (liv >= minimo + 2)
    liv[falce] += 1
    liv = np.clip(liv, minimo, n - 1)
    liv[~m] = -1
    pulisci_toni(liv, m)
    out[m] = liv[m]
    for k in range(minimo, n):
        img[out == k] = rampa[k]
    return out
