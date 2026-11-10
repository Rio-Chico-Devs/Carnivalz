#!/usr/bin/env python3
# LUI SUL PIANETA (prove/MondoProva.gd), dai disegni di Bru: scrive
# art/pianeti/protagonista/lui.png. Lei non si disegna piu' qui: e' presa
# uguale dal foglio di Bru (ricalca.py).
#
#   python3 strumenti/protagonisti/disegna.py
#
# Il modello e' il «tactical RPG sprite sheet» che ha mandato Bru: figure
# chibi, la testa quasi meta' dell'altezza, i capelli lavanda a ciocche con
# l'ombra blu-viola, gli occhi grandi e scuri sotto la frangia. Bru: «ecco
# degli esempi, riesci a farli uguali o meglio?». Il foglio e' stato ricalcato
# alla misura del gioco solo per prendere proporzioni e colori; poi ogni pezzo
# e' ridisegnato a mano lettera per lettera (lui.py), pulito:
#   - niente bocca (Bru, sul giro prima); gli occhi con ciglia, iride e luce;
#   - la luce sempre dall'alto a sinistra, il contorno scuro ma non nero;
#   - fronte e spalle sono pezzi incollati (gambe, busto, braccia, testa); di
#     lato braccia e gambe sono arti articolati (arti.py, lato.py), con lo
#     stivale e il guanto in fondo;
#   - il passo ha quattro tempi (il piede avanti, l'altro che passa piegato,
#     l'altro piede avanti, di nuovo il passaggio); le braccia vanno al
#     contrario delle gambe e il corpo scende di un pixel quando i piedi sono
#     tutti e due a terra. Di lato le code della sciarpa di lui ondeggiano.
#
# Il foglio: righe giu', su, destra (la sinistra e' la destra allo
# specchio); dieci colonne come lei (fermo, il respiro, otto tempi del passo):
# i quattro tempi di lui, ognuno per due colonne. I piedi stanno a (16, 45)
# di ogni fotogramma.
import os
import sys
QUI = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, QUI)
from pezzi import tela, incolla, righe, W, H
import lui, lato, png
from tavolozze import LUI

# di fronte e di spalle: le gambe, il braccio a sinistra e quello a destra
# di chi guarda, quanto scende il corpo
TEMPI = {
    "fermo":  ("dritte", "neutro", "neutro", 0),
    "passo1": ("s_avanti", "indietro", "avanti", 1),
    "medio1": ("d_passa", "neutro", "neutro", 0),
    "passo2": ("d_avanti", "avanti", "indietro", 1),
    "medio2": ("s_passa", "neutro", "neutro", 0),
}
ORDINE = ("fermo", "passo1", "medio1", "passo2", "medio2")
# le dieci colonne del foglio del gioco (fermo, il respiro, otto tempi): lui ha
# quattro tempi, ognuno tenuto per due colonne, e da fermo non respira
COLONNE = ("fermo", "fermo") + tuple(t for t in ORDINE[1:] for _ in range(2))


def lui_giu(tempo):
    g, bs, bd, giu = TEMPI[tempo]
    t = tela()
    lato.spada(t, 7, 15, -1, giu)  # dietro: se ne vede l'elsa sopra la spalla
    incolla(t, lui.GAMBE_GIU[g], 8, 36 + giu)
    incolla(t, lui.BUSTO_GIU, 0, 20 + giu)
    incolla(t, lui.BRACCIO_GIU_S[bs], 5, 27 + giu)
    incolla(t, lui.BRACCIO_GIU_D[bd], 23, 27 + giu)
    incolla(t, lui.TESTA_GIU, 4, 1 + giu)
    return righe(t)


def lui_su(tempo):
    g, bs, bd, giu = TEMPI[tempo]
    t = tela()
    incolla(t, lui.GAMBE_SU[g], 8, 36 + giu)
    incolla(t, lui.BUSTO_SU, 0, 19 + giu)
    incolla(t, lui.BRACCIO_SU_S[bd], 5, 27 + giu)
    incolla(t, lui.BRACCIO_SU_D[bs], 23, 27 + giu)
    incolla(t, lui.TESTA_SU, 4, 1 + giu)
    lato.spada(t, 24, 15, 1, giu)  # sulla schiena, sopra a tutto
    return righe(t)


def lui_destra(tempo):
    p = lato.TEMPI_LATO[tempo]
    giu = p["su"]
    t = tela()
    lato.braccio(t, p["b_lon"], False, lui.GUANTO_DESTRA)
    lato.gamba(t, p["g_lon"], False, lui.STIVALE_DESTRA, lui.STIVALE_DESTRA_LONTANO)
    incolla(t, lui.BUSTO_DESTRA, 10, 20 + giu)
    lato.gamba(t, p["g_vic"], True, lui.STIVALE_DESTRA, lui.STIVALE_DESTRA_LONTANO)
    lato.code_sciarpa(t, ORDINE.index(tempo) % 2, giu)
    lato.braccio(t, p["b_vic"], True, lui.GUANTO_DESTRA)
    incolla(t, lui.TESTA_DESTRA, 5, 1 + giu)
    lato.elsa_lato(t, giu)
    return righe(t)


def colore(esadecimale):
    h = esadecimale.lstrip('#')
    return (int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16), 255)


def foglio(viste, tavolozza):
    # 10 colonne x 3 righe di 32x48, con l'ombra ovale per terra sotto i piedi
    fw, fh = W * len(COLONNE), H * 3
    pix = [(0, 0, 0, 0)] * (fw * fh)
    for riga, vista in enumerate(viste):
        for colonna, tempo in enumerate(COLONNE):
            griglia = vista(tempo)
            for y in range(H):
                for x in range(W):
                    ch = griglia[y][x]
                    p = (0, 0, 0, 0)
                    if ch in tavolozza:
                        p = colore(tavolozza[ch])
                    elif ch != '.':
                        raise ValueError("lettera senza colore: %r" % ch)
                    else:
                        dx, dy = (x + 0.5 - 16) / 9.0, (y + 0.5 - 45.5) / 2.0
                        if dx * dx + dy * dy < 1:
                            p = (18, 12, 24, 80)
                    pix[(riga * H + y) * fw + colonna * W + x] = p
    return fw, fh, pix


if __name__ == '__main__':
    cartella = os.path.join(QUI, '..', '..', 'art', 'pianeti', 'protagonista')
    os.makedirs(cartella, exist_ok=True)
    w, h, pix = foglio((lui_giu, lui_su, lui_destra), LUI)
    png.scrivi(os.path.join(cartella, 'lui.png'), w, h, pix)
    print('scritto lui', w, h)
