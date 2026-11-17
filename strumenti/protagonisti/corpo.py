# IL DISEGNO DI LEI, grande come i disegni di Bru (100 pixel): le tre viste da
# ferma in lei/*.txt, una lettera per pixel. passo.py ne fa il passo, lei.py
# scrive il foglio del gioco (art/pianeti/protagonista/lei.png).
#
# Bru ha mandato tre disegni in pixel (il giro davanti, dietro e di lato, lei
# grande di tre quarti, lei in posa) e ha scelto la misura dei disegni. Le
# viste sono ricostruite pixel per pixel dai disegni (ricostruisci.py: i JPG
# sono ingranditi, ogni pixel del disegno e' un quadretto) e poi ripulite a
# mano:
#   - davanti: dal disegno grande (22.jpg), il piu' nitido, com'e';
#   - dietro e di lato: dal giro (21.jpg), piu' piccolo e sporco dal JPG: la
#     fascia ridisegnata (curva dietro, con quattro stelle; di lato col cerchio
#     d'oro sul davanti), il viso di profilo, la spallina, la cintura a catena;
#     dietro gli stivali allungati di 7 righe (nel giro erano piu' corti che
#     davanti e di lato: girandosi lei cambiava altezza);
#   - di lato le gambe non ci sono: le disegna gambe.py, articolate.
# Le stesse misure in tutte e tre: la cintura a 41 pixel da terra, le spalle a 62.
#
# Le lettere (i colori sono quelli del disegno grande):
#   o contorno; A B C D E F lavanda (capelli, top) dalla luce all'ombra;
#   P Q R S T pelle; a b c d e la fascia cremisi; x il bianco degli occhi,
#   z le stelle, y il bianco in ombra, v la stella in ombra; g h j l'oro;
#   r s q gli occhi rossi; w k m n il nero lucido (riflesso, luce, base, scuro);
#   G H I l'argento (cintura, bracciali, ciondolo).
import os

QUI = os.path.dirname(os.path.abspath(__file__))


def esa(x):
    x = x.lstrip('#')
    return tuple(int(x[i:i + 2], 16) for i in (0, 2, 4))


COLORI = {k: esa(v) for k, v in {
    'o': '#0c0a14',
    'A': '#ecd4ee', 'B': '#c0afe2', 'C': '#9f8ec8', 'D': '#7e6ca3', 'E': '#614f86', 'F': '#423258',
    'P': '#c48a64', 'Q': '#ab7152', 'R': '#915a48', 'S': '#78453e', 'T': '#542f2f',
    'a': '#b52f5a', 'b': '#991d43', 'c': '#631735', 'd': '#3a1418', 'e': '#1f040b',
    'x': '#fbf6f3', 'z': '#f0cee6', 'y': '#c4b2b4', 'v': '#9a7890',
    'g': '#e9c375', 'h': '#a8703c', 'j': '#6c3a1c',
    'r': '#d02a40', 's': '#ab1d37', 'q': '#690f1a',
    'w': '#84878c', 'k': '#4a505e', 'm': '#252d36', 'n': '#1a1924',
    'G': '#e0e2e4', 'H': '#a8acb2', 'I': '#5c606c',
}.items()}


def leggi(nome):
    """lei/<nome>.txt -> righe di lettere, tutte larghe uguali ('.' e' vuoto)"""
    with open(os.path.join(QUI, 'lei', nome + '.txt')) as f:
        righe = [r.rstrip('\n') for r in f if r.strip('\n')]
    larga = len(righe[0])
    for j, r in enumerate(righe):
        assert len(r) == larga, (nome, j, len(r))
        for ch in r:
            assert ch == '.' or ch in COLORI, (nome, j, ch)
    return righe
