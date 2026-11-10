# LUI, chibi, dal foglio «tactical RPG sprite sheet» di Bru: 32x48, i piedi a
# (16, 45). Ogni pezzo dice dove va (x, y); i colori sono in tavolozze.py.
from pezzi import r, coppia

# ---------------------------------------------------------------- di fronte
TESTA_GIU = r([  # x=4, y=1
    "..........o....o........",  # 0
    ".........oHo..oho..o....",  # 1
    "......o.oHHhoohhhooho...",  # 2
    ".....oHoHHHhhVhhhhhhvo..",  # 3
    "....oHHhHHhhhvHhhhvhvvo.",  # 4
    "...ohHHhHhhhhhvhhhhvvVvo",  # 5
    ".ohHHhhHhhhhhhhvhhvvvVvo",  # 6
    "..ohHhhhhhhhhhhhhvvvvVVo",  # 7
    "...ohhhhvhhhhhvhhhvvVVo.",  # 8
    "..ohhhvhhhhvhhhhvhhvVVvo",  # 9
    "oVhvhhvVhvVhhvVhvVvVVVo.",  # 10
    ".oVhhvVShvShvVShvSvVVXoo",  # 11
    ".oXvhhvShvShvSShvSvVXo..",  # 12
    ".oXhvvSsVSshVssVSsSvXo..",  # 13
    ".oXvVsoeeesVSseeeoSVXo..",  # 14
    ".oXVssseiElssseiESSVXo..",  # 15
    "..oVlsseEEsssseEESSVo...",  # 16
    "...ollssssssSssssSSSo...",  # 17
    "....olssssssssssSSSo....",  # 18
    ".....osssssssssSSSo.....",  # 19
    ".......oSSSSSSSSo.......",  # 20
    "........oooooooo........",  # 21
], 24)

# il busto senza braccia: sciarpa, giacca aperta, petto, cintura; x=0, y=20
BUSTO_GIU = r([
    "........oooooooo|oooooooo........",  # 20
    "........owwwwwww|wwwwwWYo........",  # 21
    "........owwwWwww|wwwwWwYo........",  # 22
    "........oWwwYWww|YWwwYWYo........",  # 23
    "......oooWWWWWWW|WWWWWWYooo......",  # 24
    "......oJJjjjKSss|ssSKjjnnno......",  # 25
    ".....oJJjjjjoSls|ssSojnnnnno.....",  # 26
    ".........oJjKSll|ssSKjno.........",  # 27
    ".........oJjoSSS|SSSojno.........",  # 28
    ".........oJjKSls|sSSKjno.........",  # 29
    ".........oJjoSSS|SSSojno.........",  # 30
    ".........oJjKSls|sSSKjno.........",  # 31
    ".........ojnoSss|sSSonno.........",  # 32
    ".........oncnnnw|Wnnncno.........",  # 33
    ".........obBpBBb|bBBpBbo.........",  # 34
    ".........obBpqBb|bBqpBbo.........",  # 35
], 32)

# le braccia: la manica, l'avambraccio della manica arrotolata, il guanto.
# 'avanti' e' piu' lungo di un pixel (viene verso di noi), 'indietro' piu' corto
def _braccio(maniche, pelle, guanto):
    return maniche + pelle + guanto

BRACCIO_GIU_S = {  # x=5, y=27 (di chi guarda: a sinistra, nella luce)
    "neutro":   _braccio(["oJjn"] * 4, ["ollS"], ["oGgg", "oGcg", "oggj", ".ooo"]),
    "avanti":   _braccio(["oJjn"] * 5, ["ollS"], ["oGgg", "oGcg", "oggj", ".ooo"]),
    "indietro": _braccio(["oJjn"] * 3, ["ollS"], ["oGgg", "oGcg", "oggj", ".ooo"]),
}
BRACCIO_GIU_D = {  # x=23, y=27 (a destra, nell'ombra)
    "neutro":   _braccio(["jnno"] * 4, ["sSSo"], ["ggjo", "gcjo", "gjjo", "ooo."]),
    "avanti":   _braccio(["jnno"] * 5, ["sSSo"], ["ggjo", "gcjo", "gjjo", "ooo."]),
    "indietro": _braccio(["jnno"] * 3, ["sSSo"], ["ggjo", "gcjo", "gjjo", "ooo."]),
}

# le gambe, x=8; la riga 0 e' l'anca (y=36, o 37 quando il corpo scende)
_DRITTA_S = [".obBpqBo", ".obBBpbo", ".obqqBbo", ".obBpBbo", ".ojJJjno", ".ojwJwno", "ojjwwjno", "oJjjjjno", "oooooooo"]
_DRITTA_D = ["oBqpBbo.", "obpBBbo.", "obBqqbo.", "obBpBbo.", "ojJjnno.", "ojwjwno.", "ojjwwjno", "ojjjjnno", "oooooooo"]
# il piede dietro, col tallone alzato: due righe piu' corto
_ALZATA_S = [".obBpqBo", ".obBBpbo", ".obqqBbo", ".ojJJjno", ".ojwJwno", ".ojjjjno", ".ooooooo"]
_ALZATA_D = ["oBqpBbo.", "obpBBbo.", "obBqqbo.", "ojJjnno.", "ojwjwno.", "ojjjjno.", "ooooooo."]
# la gamba che passa, piegata: il ginocchio sale e il piede viene avanti
_PIEGATA_S = [".obBpqBo", ".obqqBbo", ".obBpBbo", ".ojJJjno", ".ojwJwno", "ojjwwjno", "oooooooo"]
_PIEGATA_D = ["oBqpBbo.", "obBqqbo.", "obBpBbo.", "ojJjnno.", "ojwjwno.", "ojjwwjno", "oooooooo"]

GAMBE_GIU = {
    "dritte": coppia(_DRITTA_S, _DRITTA_D),
    "s_avanti": coppia(_DRITTA_S, _ALZATA_D),
    "d_avanti": coppia(_ALZATA_S, _DRITTA_D),
    "d_passa": coppia(_DRITTA_S, _PIEGATA_D),
    "s_passa": coppia(_PIEGATA_S, _DRITTA_D),
}

# ---------------------------------------------------------------- di spalle
TESTA_SU = r([  # x=4, y=1
    "..........o....o........",  # 0
    ".........oHo..oho..o....",  # 1
    "......o.oHHhoohhhooho...",  # 2
    ".....oHoHHHhhVhhhhhhvo..",  # 3
    "....oHHhHHhhhvHhhhvhvvo.",  # 4
    "...ohHHhHhhhhhvhhhhvvVvo",  # 5
    ".ohHHhhHhhhhhhhvhhvvvVvo",  # 6
    "..ohHhhhhhhhhhhhhvvvvVVo",  # 7
    "...ohhhhvhhhhhvhhhvvVVo.",  # 8
    "..ohhhvhhhhvhhhhvhhvVVvo",  # 9
    "oVhvhhvhhhvhhhhvhhvvVVo.",  # 10
    ".oVhhvhhvhhhvhhvhhvvVVoo",  # 11
    ".oVvhhvhvVhhvVhhvhvVVo..",  # 12
    ".oXvhvVhvVhvVhvVhvVVXo..",  # 13
    ".oXVvVvVhVvVhVvVhVvVXo..",  # 14
    "..oXVvVvVVvVVvVVvVVXo...",  # 15
    "...oXVVoVVVoVVVoVVXo....",  # 16
    "....oXo.oVVo.oVVo.oXo...",  # 17
    ".........oo...oo........",  # 18
], 24)

BUSTO_SU = r([  # x=0, y=19: il collo, la sciarpa intorno, la schiena della giacca
    "..............oS|So..............",  # 19
    "........oooooooo|oooooooo........",  # 20
    "........owwwwwww|wwwwwWYo........",  # 21
    "........owWwwwww|wwwwWWYo........",  # 22
    "........oWWwYWWw|YWWwYWYo........",  # 23
    "......oooWWWWWWW|WWWWWWYooo......",  # 24
    "......oJJjjjjjjj|jjjjjnnnno......",  # 25
    ".....oJJjjjjjjjj|jjjjjjnnnno.....",  # 26
    ".........oJjjjjj|jjjjjno.........",  # 27
    ".........oJjjjjj|jjjjjno.........",  # 28
    ".........ojjjjjj|jjjjjno.........",  # 29
    ".........ojjjjjj|jjjjnno.........",  # 30
    ".........ojjjjjj|jjjjnno.........",  # 31
    ".........onnnnnn|nnnnnno.........",  # 32
    ".........oncnnnn|nnnncno.........",  # 33
    ".........obBBBBb|bBBBBbo.........",  # 34
    ".........obBpBBb|bBBpBbo.........",  # 35
], 32)
# di spalle le braccia sono le stesse, scambiate: la luce resta a sinistra
BRACCIO_SU_S = BRACCIO_GIU_S
BRACCIO_SU_D = BRACCIO_GIU_D

def _da_dietro(g):
    # di spalle non si vedono i lacci degli stivali
    return [x.replace('w', 'j') for x in g]

GAMBE_SU = {k: _da_dietro(v) for k, v in GAMBE_GIU.items()}

# ---------------------------------------------------------------- di lato
TESTA_DESTRA = r([  # x=5, y=1: guarda a destra
    ".......o...o..........",  # 0
    "......oHo.oho...o.....",  # 1
    "..o..oHHhohhho.oho....",  # 2
    "..oo.oHHhhhhhhohhvo...",  # 3
    "...ooHHhHHhhhhhhhhvvo.",  # 4
    "oooHHhhHhhhhhhhhhhvvo.",  # 5
    ".ohHhhhhhhhhhhhhhhhvvo",  # 6
    "..ohhhhhhhhhhhhhhvhhvo",  # 7
    "ooHhhhvhhhhhhhhhvhhvVo",  # 8
    ".oVhhhhhhvhhhhvhhvVhVo",  # 9
    "..ohhvhhhhhvhhVhvSVhVo",  # 10
    ".ooVhhhvhhhVhSsSvSsVo.",  # 11
    ".oXVhvhhvhVXSsssSssVo.",  # 12
    "..oXVhvhvVXSlssssssSo.",  # 13
    "..oXVvhvVXsSlsssoeeso.",  # 14
    "...oXVvVXsSllssseiEso.",  # 15
    "....oXVXosSlsssseEEsso",  # 16
    ".....oXoosSssssssssSo.",  # 17
    "......o..oSssssssssSo.",  # 18
    "..........oSssssssSo..",  # 19
    "...........oSSSSSSo...",  # 20
    "............oooooo....",  # 21
], 22)

BUSTO_DESTRA = r([  # x=10, y=20
    "....oooooo..",  # 20
    "...owwwwwWo.",  # 21
    "..oWwwwwwWYo",  # 22
    "..oWYwwYwWYo",  # 23
    "..oooWWWWYoo",  # 24
    "..oJJjjjjjso",  # 25
    ".oJJjjjjjjlo",  # 26
    ".oJjjjjjjjso",  # 27
    ".oJjjjjjjjSo",  # 28
    ".oJjjjjjjKso",  # 29
    ".oJjjjjjjKSo",  # 30
    ".ojjjjjjjKso",  # 31
    ".ojjjjjjjnSo",  # 32
    ".oncnnnnnnno",  # 33
    ".obBBBBBBbo.",  # 34
    ".obBpBBBBbo.",  # 35
], 12)

# lo stivale di lato, la caviglia e' la colonna 2 della prima riga
STIVALE_DESTRA = [
    "ojJjo...",
    "ojwJjo..",
    "ojjwjjo.",
    "ojjjjjjo",
    "oooooooo",
]
STIVALE_DESTRA_LONTANO = [x.replace('J', 'j').replace('w', 'n') for x in STIVALE_DESTRA]
GUANTO_DESTRA = [".oo.", "oGgo", "ogjo", ".oo."]
