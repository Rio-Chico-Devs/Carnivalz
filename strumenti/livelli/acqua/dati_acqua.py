"""Rifa' con lo script del ruscello l'acqua della mappa (deve venire uguale a ruscello.png) e ne ricava i dati per
animarla: dove e' l'acqua, quanto e' scura, le coordinate lungo il filo del ruscello, ninfee, sassi, schiuma.
uso: dati_acqua.py uscita.npz
"""
import sys, os, time
import numpy as np
from PIL import Image
REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', '..'))
OUT = sys.argv[1]
sys.path.insert(0, os.path.join(REPO, 'strumenti', 'livelli'))
import ruscello_radenna as R

t0 = time.time()
t, F = R.pianta()
img, G = R.disegna(t, F)
fin = R.ombre(R.luce_turchese(R.decora(img.copy(), G), G), G)
fin8 = np.clip(fin, 0, 255).astype(np.uint8)
mappa = np.asarray(Image.open(os.path.join(REPO, 'art/livelli/ruscello.png')).convert('RGB'))
print('rifatta in %.0f s; pixel diversi dalla mappa: %d' % (time.time() - t0, int((fin8 != mappa).any(2).sum())))

tipo, Mb, GY = G['tipo'], G['m'], G['gy']
acq = (tipo == 1) & (Mb == R.ACQUA)
du = R._corsa(acq); dd = R._corsa(acq[::-1])[::-1]
dl = R._corsa(acq.T).T; dr = R._corsa(acq.T[::-1])[::-1].T
H, W = acq.shape
classe = np.full((H, W), -1, np.int8)     # -1 non acqua; 0..4 interno (gradi di scuro); 10.. bordi fissi
ys, xs = np.nonzero(acq)
for y, x in zip(ys, xs):
    a, bb, s = du[y, x], dd[y, x], min(dl[y, x], dr[y, x])
    if a <= 5 or s <= 3 or bb == 1:
        classe[y, x] = 10
    else:
        n = max(3 if a <= 8 else (2 if a <= 12 else (1 if a <= 15 else 0)),
                3 if s <= 5 else (2 if s <= 7 else (1 if s <= 9 else 0)),
                4 if bb <= 3 else (3 if bb <= 5 else (2 if bb <= 8 else (1 if bb <= 11 else 0))))
        if dl[y, x] <= 7 and Mb[y, x - dl[y, x]] in (R.SPALLA, R.PALO, R.PONTE):
            n = max(n, 3 if dl[y, x] <= 5 else 2)
        classe[y, x] = n
# l'acqua liscia (senza increspature e scintille) per sapere che cosa ci hanno posato sopra
pura = img.copy()
# coordinate lungo il filo: campo con raggio grande (copre lo stagno)
lin, u = F['lin'], F['u']
D2, S2, V2 = R.campo(lin, u, 140, t.HG, t.B)
gyc = np.clip(GY, 0, t.HG - 1)
X = np.repeat(np.arange(W)[None, :], H, 0)
Us = S2[gyc, X]; Vs = V2[gyc, X]; Ds = D2[gyc, X]
Ws = F['w'][gyc, X]
# le cose posate sull'acqua: ninfee e sassi (fissi), la schiuma attorno ai sassi
ninfee = np.zeros((H, W), bool); sassi = np.zeros((H, W), bool); schiuma = np.zeros((H, W), np.int8)
LIV = os.path.join(REPO, 'art/livelli')
for (n, fx, fy) in R.NINFEE:
    f, (px, py), _ = R.pezzo(n)
    a = np.asarray(Image.open(os.path.join(LIV, f)).convert('RGBA')).astype(float)
    a[R._e_acqua_del_pezzo_v(a), 3] = 0
    for j in range(a.shape[0]):
        for i in range(a.shape[1]):
            yy, xx = fy - py + j, fx - px + i
            if 0 <= yy < H and 0 <= xx < W and a[j, i, 3] > 0 and acq[yy, xx]:
                ninfee[yy, xx] = True
sassi_info = []
for (n, fx, fy) in R.SASSI_ACQUA:
    f, (px, py), (w, h) = R.pezzo(n)
    rx, ry = w * 0.62, max(2.5, h * 0.3)
    sassi_info.append((fx, fy, rx, ry))
    for yy in range(int(fy - ry - 3), int(fy + ry + 4)):
        for xx in range(int(fx - rx - 3), int(fx + rx + 4)):
            if 0 <= yy < H and 0 <= xx < W and acq[yy, xx]:
                e = ((xx - fx) / rx) ** 2 + ((yy - fy) / ry) ** 2
                if 0.7 <= e <= 1.25:
                    schiuma[yy, xx] = 1 if e < 1 else 2
    a = np.asarray(Image.open(os.path.join(LIV, f)).convert('RGBA')).astype(float)
    for j in range(a.shape[0]):
        for i in range(a.shape[1]):
            yy, xx = fy - py + j, fx - px + i
            if 0 <= yy < H and 0 <= xx < W and a[j, i, 3] > 0 and acq[yy, xx]:
                sassi[yy, xx] = True
np.savez_compressed(OUT, mappa=mappa, fin=fin8, acq=acq, classe=classe, du=du, dd=dd, dl=dl, dr=dr,
                    U=Us, V=Vs, D=Ds, Wd=Ws, ninfee=ninfee, sassi=sassi, schiuma=schiuma,
                    sassi_info=np.array(sassi_info), lin=lin, u=u, wl=F['wl'], AQ=R.AQ)
print('acqua', int(acq.sum()), 'interno', int((classe >= 0).sum() - (classe >= 10).sum()), 'bordi', int((classe >= 10).sum()),
      'ninfee', int(ninfee.sum()), 'sassi', int(sassi.sum()), 'schiuma', int((schiuma > 0).sum()),
      'D max sull acqua', float(np.nanmax(np.where(acq, Ds, 0))), 'senza D', int((acq & ~np.isfinite(Ds)).sum()))
