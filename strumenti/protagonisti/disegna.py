#!/usr/bin/env python3
# I DUE PROTAGONISTI SUL PIANETA (prove/MondoProva.gd), dai disegni di Bru:
# scrive art/pianeti/protagonista/lui.png e lei.png.
#
#   python3 strumenti/protagonisti/disegna.py
#
# Bru, sul primo giro (24x32): «bisogna lavorarci meglio»; e poi: «non
# disegnare la bocca, fai meglio gli occhi, anche l'anatomia e i frame di
# animazione devono essere meglio». Quindi:
#   - 32x48 a fotogramma, il personaggio alto tre caselle: le proporzioni
#     sono quelle del foglio di Bru, la testa appena piu' grande perche' il
#     viso si legga. Niente bocca; gli occhi con ciglia, iride e luce;
#   - ogni figura e' fatta di pezzi (testa, busto, braccia, gambe) disegnati
#     a mano lettera per lettera (lui.py, lei.py); di lato braccia e gambe
#     sono arti articolati, anca-ginocchio-caviglia (arti.py, lato.py);
#   - il passo ha quattro tempi: il piede avanti, l'altro che passa piegato,
#     l'altro piede avanti, di nuovo il passaggio. Le braccia vanno al
#     contrario delle gambe e il corpo scende di un pixel quando i piedi sono
#     tutti e due a terra.
#
# Il foglio: righe giu', su, destra (la sinistra e' la destra allo
# specchio); colonne fermo, passo, passaggio, altro passo, passaggio. I piedi
# stanno a (16, 45) di ogni fotogramma. I colori sono in tavolozze.py, presi
# dal foglio in pixel art di Bru.
import os
import sys
QUI = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, QUI)
from pezzi import tela, incolla, specchia, righe, W, H
import lui, lei, lato, png
from tavolozze import LUI, LEI

# i tempi di fronte e di spalle: gamba sinistra, gamba destra, braccio
# sinistro, braccio destro, quanto scende il corpo
TEMPI = {
    "fermo":  ("dritta", "dritta", "neutro", "neutro", 0),
    "passo1": ("avanti", "dietro", "indietro", "avanti", 1),
    "medio1": ("dritta", "piegata", "neutro", "neutro", 0),
    "passo2": ("dietro", "avanti", "avanti", "indietro", 1),
    "medio2": ("piegata", "dritta", "neutro", "neutro", 0),
}
ORDINE = ("fermo", "passo1", "medio1", "passo2", "medio2")
# di spalle la gamba che va avanti si allontana: il piede sale invece di scendere
INVERTI = {"avanti": "dietro", "dietro": "avanti", "dritta": "dritta", "piegata": "piegata"}


def lui_giu(tempo):
    gs, gd, bs, bd, giu = TEMPI[tempo]
    t = tela()
    incolla(t, lui.ELSA_GIU, 3, 10 + giu)
    incolla(t, lui.GAMBA[gs], 10, 29 + giu)
    incolla(t, specchia(lui.GAMBA[gd]), 16, 29 + giu)
    incolla(t, lui.BUSTO_GIU, 8, 16 + giu)
    incolla(t, lui.SCIARPA_GIU, 11, 18 + giu)
    incolla(t, lui.braccio(bs), 7, 18 + giu)
    incolla(t, specchia(lui.braccio(bd)), 21, 18 + giu)
    incolla(t, lui.TESTA_GIU, 6, 1 + giu)
    return righe(t)


def lui_su(tempo):
    gs, gd, bs, bd, giu = TEMPI[tempo]
    t = tela()
    incolla(t, lui.GAMBA[INVERTI[gd]], 10, 29 + giu)
    incolla(t, specchia(lui.GAMBA[INVERTI[gs]]), 16, 29 + giu)
    incolla(t, lui.BUSTO_SU, 8, 16 + giu)
    incolla(t, lui.braccio(bd), 7, 18 + giu)
    incolla(t, specchia(lui.braccio(bs)), 21, 18 + giu)
    lato.spada_su(t, giu)
    incolla(t, lui.TESTA_SU, 6, 1 + giu)
    return righe(t)


def lui_destra(tempo):
    p = lato.TEMPI_LATO[tempo]
    giu = p["su"]
    t = tela()
    incolla(t, lui.ELSA_DESTRA, 4, 7 + giu)
    lato.braccio_lui(t, p["b_lon"], False)
    lato.gamba_lui(t, p["g_lon"], False)
    lato.gamba_lui(t, p["g_vic"], True)
    incolla(t, lui.BUSTO_DESTRA, 9, 16 + giu)
    incolla(t, lui.SCIARPA_DESTRA, 3, 17 + giu)
    lato.braccio_lui(t, p["b_vic"], True)
    incolla(t, lui.TESTA_DESTRA, 7, 1 + giu)
    return righe(t)


def lei_giu(tempo):
    gs, gd, bs, bd, giu = TEMPI[tempo]
    t = tela()
    incolla(t, lei.GAMBA[gs], 10, 29 + giu)
    incolla(t, specchia(lei.GAMBA[gd]), 16, 29 + giu)
    incolla(t, lei.BUSTO_GIU, 8, 17 + giu)
    incolla(t, lei.braccio(bs), 8, 19 + giu)
    incolla(t, specchia(lei.braccio(bd)), 21, 19 + giu)
    incolla(t, lei.TESTA_GIU, 6, 0 + giu)
    incolla(t, lei.TRECCE_GIU, 7, 15 + giu)
    incolla(t, lei.TRECCE_GIU, 22, 15 + giu)
    return righe(t)


def lei_su(tempo):
    gs, gd, bs, bd, giu = TEMPI[tempo]
    t = tela()
    incolla(t, lei.GAMBA[INVERTI[gd]], 10, 29 + giu)
    incolla(t, specchia(lei.GAMBA[INVERTI[gs]]), 16, 29 + giu)
    incolla(t, lei.BUSTO_SU, 8, 17 + giu)
    incolla(t, lei.braccio(bd), 8, 19 + giu)
    incolla(t, specchia(lei.braccio(bs)), 21, 19 + giu)
    incolla(t, lei.TESTA_SU, 6, 0 + giu)
    return righe(t)


def lei_destra(tempo):
    p = lato.TEMPI_LATO_LEI[tempo]
    giu = p["su"]
    t = tela()
    lato.braccio_lei(t, p["b_lon"], False)
    lato.gamba_lei(t, p["g_lon"], False)
    lato.gamba_lei(t, p["g_vic"], True)
    incolla(t, lei.BUSTO_DESTRA, 10, 17 + giu)
    lato.braccio_lei(t, p["b_vic"], True)
    incolla(t, lei.TESTA_DESTRA, 5, 0 + giu)
    return righe(t)


def colore(esadecimale):
    h = esadecimale.lstrip('#')
    return (int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16), 255)


def foglio(viste, tavolozza):
    # 5 colonne x 3 righe di 32x48, con l'ombra ovale per terra sotto i piedi
    fw, fh = W * 5, H * 3
    pix = [(0, 0, 0, 0)] * (fw * fh)
    for riga, vista in enumerate(viste):
        for colonna, tempo in enumerate(ORDINE):
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
    for nome, viste, tav in (('lui', (lui_giu, lui_su, lui_destra), LUI), ('lei', (lei_giu, lei_su, lei_destra), LEI)):
        w, h, pix = foglio(viste, tav)
        png.scrivi(os.path.join(cartella, nome + '.png'), w, h, pix)
        print('scritto', nome, w, h)
