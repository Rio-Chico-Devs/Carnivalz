# LUI a 32x48. Il centro della tela e' fra le colonne 15 e 16; i piedi
# toccano terra alla riga 46 (47 col passo avanti).
from pezzi import specchia

def metta(meta):
    # mezza figura (sinistra) -> intera
    return [r + r[::-1] for r in meta]

TESTA_GIU = [  # x=6, y=1: niente bocca; occhi: ciglia, iride, luce
    ".........oo.........",
    ".....o..oHHo..o.....",
    "....oHooHHhhooho....",
    "...ohHHhHhhhhhhvo...",
    "..ohHHhhhhhhhhhhvo..",
    ".ohHHhhhhhhhhhhhhvo.",
    "ohHhhhhhhhhhhhhhhvvo",
    ".ohhhvhhhhhhvhhhvvo.",
    ".ovhvhhvhhhvhhvhvVo.",
    "..oVvhvsvhhvsvhvVo..",
    "..oVsvsssvsssvssVo..",
    "..oVsooosssssoooVo..",
    "..oSsEiwssssEiwSSo..",
    "...oSEiisssEiiSSo...",
    "....oSssssssssSo....",
    ".....ooSSssSSoo.....",
]

# il busto: meta' sinistra (8 colonne), poi lo specchio; x=8, y=16
_BUSTO_META = [
    "......ow",  # 16 sciarpa
    "....oowW",  # 17
    "..ooojwW",  # 18 spalle
    ".ojJjowW",  # 19
    ".oJjjoWo",  # 20 bavero
    ".oJjjosl",  # 21 petto
    ".ojJjoSS",  # 22
    "..ojjosl",  # 23 addome
    "..ojjoSS",  # 24
    "..ojjosl",  # 25
    "..oojoss",  # 26
    "...ogggq",  # 27 cintura e fibbia
    "...oPPPp",  # 28 fianchi
]
BUSTO_GIU = metta(_BUSTO_META)
# la sciarpa che pende sul petto a sinistra di chi guarda, con la freccia nera
SCIARPA_GIU = [  # x=11, y=18
    "oWwo",
    "owwo",
    "oowo",
    "owoo",
    "owwo",
    "oWWo",
    ".oo.",
]

def braccio(posa):
    # il braccio sinistro (di chi guarda), 4x13; il destro e' lo specchio
    spalla = [".oo.", "oJjo", "oJjo", "oJjo", "ojjo"]
    gomito = ["ojjo", "oJjo"]
    avambraccio = ["osSo", "oqqo"]
    mano = ["oggo", "oGgo", ".oo."]
    if posa == "neutro":
        return spalla + gomito + avambraccio + mano
    if posa == "avanti":
        # la mano viene avanti: scende di un pixel e si vede di piu'
        return spalla + gomito + ["ojjo"] + avambraccio + ["oggo", "oGgo", "oggo", ".oo."]
    # indietro: la mano va dietro il fianco, il braccio si accorcia
    return spalla + ["ojjo"] + ["oSSo", "oqqo", "oggo", ".oo."]

def gamba(stinco, fondo_chiaro=True):
    # la gamba sinistra, 6 di largo: coscia a righe, ginocchiera, stivale
    coscia = ["oPPPPo", "oppppo", "oPPPPo", "oppppo", "oPPPPo", "oppppo"]
    # la ginocchiera grande col bordo chiaro, lo stivale nero col pannello bianco sullo stinco
    ginocchio = ["occcco", "oKcKKo"]
    stivale = ["onnnno", "onqqno", "onqqno", "onnnno", "onnnno", "onnnno"][:stinco]
    piede = ["onnnnno", "oqqqqqo" if fondo_chiaro else "onnnnno", ".ooooo."]
    return coscia + ginocchio + stivale + piede

GAMBA = {
    "dritta": gamba(6),            # 17 righe: dall'anca a terra
    "avanti": gamba(6),            # col corpo giu' di uno, il piede scende sotto la linea: viene verso di noi
    "dietro": gamba(4, False),     # il piede va indietro: si alza, la suola non si vede
    "piegata": gamba(5),           # il ginocchio sale
}

# la spada dietro le spalle, di fronte: spunta solo l'elsa sopra la spalla
ELSA_GIU = [  # x=3, y=10
    "oo....",
    "oqo...",
    ".ory..",
    "..oRo.",
    "...oro",
    "....oY",
]

# ---------------------------------------------------------------- di spalle
TESTA_SU = [  # x=6, y=1
    ".........oo.........",
    ".....o..oHHo..o.....",
    "....oHooHHhhooho....",
    "...ohHHhHhhhhhhvo...",
    "..ohHHhhhhhhhhhhvo..",
    ".ohHHhhhhhhhhhhhhvo.",
    "ohHhhhhhhhhhhhhhhvvo",
    ".ohhhvhhhhhhvhhhvvo.",
    ".ohvhhvhhhhvhhvhvvo.",
    "..ohvhhvhhvhhvhvvo..",
    "..oVvhvvhvvhvvhvVo..",
    "..oVvvhvvvvvhvvVVo..",
    "...oVVvvVvvVvVVVo...",
    "....oVVoVVoVVoVo....",
    ".....ooSSssSSoo.....",
]
_BUSTO_SU_META = [
    "......ow",  # 16 la sciarpa da dietro, a righe
    "....oowo",  # 17
    "..ooowow",  # 18
    ".ojJjjjj",  # 19
    ".oJjjjjj",  # 20
    ".oJjjjjj",  # 21
    ".ojJjjjj",  # 22
    "..ojjjjj",  # 23
    "..ojjjjj",  # 24
    "..onnnnn",  # 25 l'orlo della giacca corta
    "..oslsss",  # 26 la schiena nuda
    "...ogggg",  # 27 cintura
    "...oPPPp",  # 28
]
BUSTO_SU = metta(_BUSTO_SU_META)

# ---------------------------------------------------------------- di lato (verso destra)
TESTA_DESTRA = [  # x=7, y=1
    ".......oo.........",
    "...o..oHHo..o.....",
    "..oHooHHhhoohoo...",
    ".ohHHhHhhhhhhhho..",
    "ohHHhhhhhhhhhhhvo.",
    ".ooHhhhhhhhhhhhhvo",
    "..ohhhhhhhhhhvhvvo",
    ".ohvhhhhhhhvhsvhso",
    "..oVvhhhhhvsssslso",
    "...oVvhhhvssooosso",
    "...oVvvhvsssEiwsso",
    "....oVvvSssssEissS",
    ".....oVVSssssssSo.",
    "......oSSsssssSo..",
    ".......ooSsssoo...",
]
BUSTO_DESTRA = [  # x=9, y=16: la schiena curva dietro, il petto aperto davanti
    "......owwwo..",
    "...oowwwWWo..",
    "..ojowWWWWo..",
    ".ojJjjojjsso.",
    ".oJjjjojjslo.",
    ".oJjjjojjsSo.",
    ".ojJjjojjslo.",
    ".ojjjjojjsSo.",
    "..ojjjjojslo.",
    "..ojjjjojsso.",
    "..oojjjoosso.",
    "...ogggggqo..",
    "...oPPPPPPo..",
]
SCIARPA_DESTRA = [  # x=3, y=17: la coda vola dietro
    "...ooowww",
    "..owwwWWo",
    ".owoowwo.",
    "owo.oo...",
    ".o.......",
]
ELSA_DESTRA = [  # x=4, y=7: dietro la testa
    "oo...",
    "oqo..",
    ".oro.",
    "..oRo",
    "...oo",
]
