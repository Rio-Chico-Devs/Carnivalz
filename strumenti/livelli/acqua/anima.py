"""L'acqua animata, in Python (la stessa logica che va poi nella pagina): per provarla e guardarla.
uso come modulo: Acqua(npz, tessera) -> .fotogramma(t)"""
import numpy as np
from PIL import Image

BAYER = np.array([[0, 8, 2, 10], [12, 4, 14, 6], [3, 11, 1, 9], [15, 7, 13, 5]]) / 16.0 + 1 / 32
M32 = 0xFFFFFFFF
FONDO = -10


def h32(a):
    a &= M32
    a = (a ^ 61) ^ (a >> 16)
    a = (a + (a << 3)) & M32
    a ^= a >> 4
    a = (a * 0x27d4eb2d) & M32
    a ^= a >> 15
    return a


def rnd(k, m, j):
    return h32((k * 73856093) ^ (m * 19349663) ^ (j * 83492791)) / 4294967296.0


class Acqua:
    def __init__(self, npz, tessera, ox=0, oy=96, b0=-4.0, b1=12.0, vel=20.0):
        d = np.load(npz)
        self.d = d
        self.vel = vel
        self.AQ = d['AQ']
        self.mappa = d['mappa']
        cl, acq = d['classe'], d['acq']
        self.anim = acq & (cl >= 0) & (cl < 10) & ~d['ninfee'] & ~d['sassi']
        ys, xs = np.nonzero(self.anim)
        self.ys, self.xs = ys, xs
        U, V, Wd = d['U'][ys, xs], d['V'][ys, xs], d['Wd'][ys, xs]
        # il punto esatto della tessera: lungo il filo la proiezione sul punto piu' vicino, di traverso la distanza
        lin0 = np.asarray(d['lin'], float)
        tg0 = np.gradient(lin0, axis=0); tg0 /= np.linalg.norm(tg0, axis=1)[:, None] + 1e-9
        kk = np.clip(U.astype(int), 0, len(lin0) - 1)
        uf = kk + tg0[kk, 0] * (xs - lin0[kk, 0]) + tg0[kk, 1] * ((ys + FONDO) - lin0[kk, 1])
        txf, tyf = -uf + ox, -V + oy
        fx = np.floor((txf - np.floor(txf)) * 256 + 0.5).astype(int); ix = np.floor(txf).astype(int) + (fx >> 8)
        fy = np.floor((tyf - np.floor(tyf)) * 256 + 0.5).astype(int); iy = np.floor(tyf).astype(int) + (fy >> 8)
        self.tx0, self.fx = ix % 192, fx & 255
        self.ty, self.fy = iy % 192, fy & 255
        self.n = cl[ys, xs].astype(int)
        e = np.abs(V) - Wd
        self.scorre = np.ones(len(xs), bool)          # tutta l'acqua scorre (le ninfee restano ferme, radicate)
        self.baia = e > 0                             # lo stagno delle ninfee: qui cadono le gocce
        H, W = acq.shape
        self.H, self.W = H, W
        self.scorre_img = np.zeros((H, W), bool); self.scorre_img[ys, xs] = self.scorre
        self.fermo_img = np.zeros((H, W), bool); self.fermo_img[ys, xs] = self.baia
        self.e_img = np.full((H, W), -99.0); self.e_img[ys, xs] = e
        du, dd, dl, dr = d['du'], d['dd'], d['dl'], d['dr']
        self.ok_corrente = self.scorre_img & (du >= 6) & (dd >= 5) & (np.minimum(dl, dr) >= 5)
        cand = self.anim & (du > 6) & (dd > 3)
        self.scint = np.stack(np.nonzero(cand), 1)               # (y, x) dove puo' brillare
        self.anelli = np.stack(np.nonzero(self.fermo_img & (self.e_img > 12) & (du > 8) & (dd > 6) &
                                          (np.minimum(dl, dr) > 8)), 1)
        self.tile = np.asarray(Image.open(tessera).convert('RGB')).astype(np.int64)
        # il filo come lo riceve la pagina (due decimali), cosi' le anteprime sono uguali alla demo
        self.lin = np.array([[round(float(v), 2) for v in r] for r in d['lin']])
        self.wl = np.array([round(float(v), 2) for v in d['wl']])
        tg = np.gradient(self.lin, axis=0); self.tg = tg / (np.linalg.norm(tg, axis=1)[:, None] + 1e-9)
        self.schiuma = d['schiuma']
        self.sassi = d['sassi_info']
        self.Uimg = d['U']

    # ------------------------------------------------------------------ il fondo che scorre
    def colore(self, shift):
        # la tessera nel punto esatto: i quattro pixel vicini pesati (pesi interi, somma 65536)
        x0 = (self.tx0 + np.where(self.scorre, shift, 0)) % 192; x1 = (x0 + 1) % 192
        y0 = self.ty; y1 = (y0 + 1) % 192
        fx, fy = self.fx[:, None], self.fy[:, None]
        t = self.tile
        c = (t[y0, x0] * ((256 - fx) * (256 - fy)) + t[y0, x1] * (fx * (256 - fy)) +
             t[y1, x0] * ((256 - fx) * fy) + t[y1, x1] * (fx * fy) + 32768) >> 16
        return c

    def vicino(self, c):
        # il colore piu' vicino della scala dell'acqua (il primo, a parita')
        return ((self.AQ.astype(int)[None] - c[:, None]) ** 2).sum(-1).argmin(-1)

    def base(self, shift):
        c = self.colore(shift)
        idx_all = self.vicino(c)
        scuri = self.n > 0
        c = c.copy()
        c[scuri] = self.AQ[np.maximum(0, idx_all[scuri] - self.n[scuri])]
        out = self.mappa.copy()
        out[self.ys, self.xs] = np.clip(c, 0, 255).astype(np.uint8)
        idx = np.full((self.H, self.W), -1, int)
        idx[self.ys, self.xs] = idx_all
        return out, idx

    def metti(self, out, y, x, c, dove):
        if 0 <= y < self.H and 0 <= x < self.W and dove[y, x]:
            out[y, x] = self.AQ[c]

    # ------------------------------------------------------------------ un fotogramma
    def fotogramma(self, t, quanti=130, scintille=55):
        tq = np.floor(t * 20) / 20.0
        out, idx = self.base(int(np.floor(self.vel * tq)))
        N = len(self.lin)
        # le increspature della corrente: nascono, si allungano, vanno a valle con l'acqua, si accorciano, spariscono
        for k in range(quanti):
            T = 2.6 + 2.4 * rnd(k, 0, 1)
            ph = rnd(k, 0, 2) * T
            m = int(np.floor((tq + ph) / T)); tau = ((tq + ph) % T) / T
            i0 = 20 + int(rnd(k, m, 3) * (N - 60))
            off = -0.7 + 1.4 * rnd(k, m, 4)
            L = 5 + int(rnd(k, m, 5) * 8)
            sp = self.vel * (0.9 + 0.2 * rnd(k, 0, 6))
            i = i0 + int(np.floor(sp * tau * T))
            if i >= N - 13:
                continue
            Lv = max(1, int(np.floor(L * min(1.0, tau / 0.2, (1 - tau) / 0.2) + 0.5)))
            j0 = (L - Lv) // 2
            nx, ny = -self.tg[i, 1], self.tg[i, 0]; wid = self.wl[i]
            for j in range(j0, j0 + Lv):
                q = min(N - 1, i + j)
                x = int(np.floor(self.lin[q, 0] + nx * off * wid + 0.5)); y = int(np.floor(self.lin[q, 1] + ny * off * wid + 0.5)) - FONDO
                inner = j0 < j < j0 + Lv - 1
                self.metti(out, y, x, 7 if inner else 6, self.ok_corrente)
        # le scintille: un lampo breve, solo dove l'acqua che passa e' chiara
        for k in range(scintille):
            T = 1.4 + 1.8 * rnd(k, 0, 11)
            ph = rnd(k, 0, 12) * T
            m = int(np.floor((tq + ph) / T)); s = (tq + ph) % T
            if s >= 0.35:
                continue
            y, x = self.scint[int(rnd(k, m, 13) * len(self.scint))]
            if idx[y, x] < 5:
                continue
            c = 9 if 0.1 <= s < 0.25 else 8
            out[y, x] = self.AQ[c]
        # la schiuma attorno ai sassi nella corrente: l'anello a puntini che gira
        fase = int(np.floor(tq / 0.15)) % 3
        ys, xs = np.nonzero(self.schiuma > 0)
        for y, x in zip(ys, xs):
            if (x + 2 * y + fase) % 3 and self.anim[y, x]:
                out[y, x] = self.AQ[9] if self.schiuma[y, x] == 1 else self.AQ[8]
        # e la scia: puntini di schiuma che si staccano a valle del sasso
        for si, (fx, fy, rx, ry) in enumerate(self.sassi):
            u0 = self.Uimg[int(fy), int(fx)]
            i = int(np.clip(u0, 0, N - 1))
            dx, dy = self.tg[i]
            for k in range(7):
                T = 1.1 + 0.5 * rnd(si, k, 21)
                ph = rnd(si, k, 22) * T
                m = int(np.floor((tq + ph) / T)); s = ((tq + ph) % T)
                lat = (-0.8 + 1.6 * rnd(si * 7 + k, m, 23)) * rx
                dist = rx * 0.8 + self.vel * 1.1 * s
                px = fx + dx * dist - dy * lat * (1 + s * 0.6)
                py = fy + dy * dist + dx * lat * (1 + s * 0.6)
                c = 9 if s < T * 0.35 else (8 if s < T * 0.7 else 7)
                self.metti(out, int(np.floor(py + 0.5)), int(np.floor(px + 0.5)), c, self.anim)
        # i cerchi nello stagno fermo: una goccia, un pesce; l'anello si allarga e si sfa
        for k in range(3):
            T = 2.4 + 1.6 * rnd(k, 0, 31)
            ph = rnd(k, 0, 32) * T
            m = int(np.floor((tq + ph) / T)); s = (tq + ph) % T
            if s >= 1.5 or len(self.anelli) == 0:
                continue
            cy, cx = self.anelli[int(rnd(k, m, 33) * len(self.anelli))]
            ii = int(np.clip(self.Uimg[cy, cx], 0, N - 1))
            cx = cx + self.tg[ii, 0] * self.vel * s; cy = cy + self.tg[ii, 1] * self.vel * s
            tau = s / 1.5
            r = 1.5 + 7.0 * tau
            ry = r * 0.55
            for y in range(int(cy - ry - 2), int(cy + ry + 3)):
                for x in range(int(cx - r - 2), int(cx + r + 3)):
                    e = np.sqrt(((x - cx) / r) ** 2 + ((y - cy) / ry) ** 2)
                    if abs(e - 1) * r < 0.55:
                        if rnd(x, y, m) < tau * 0.8:
                            continue
                        self.metti(out, y, x, 7 if tau < 0.45 else 6, self.fermo_img)
        return out
