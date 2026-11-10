# LEI a 32x48, come lui: centro fra 15 e 16, piedi a terra alla riga 45.
def metta(meta):
    return [r + r[::-1] for r in meta]

TESTA_GIU = [  # x=6, y=0: la coda sopra, la fascia con le stelle e l'anello d'oro, le trecce
    ".......o..o.o.......",
    "......ohoohohoo.....",
    ".......ohHhhhvo.....",
    "......ohHhhhvvo.....",
    "....oooooooooooo....",
    "...oUuoawaawaawao...",
    "...ouUuaAaaAaaAao...",
    "...oUuoooooooooo....",
    "..ohhHhhhhhhhhhvo...",
    "..ohHhhvhhhvhhhvvo..",
    "..oVhvhsvhhsvhsvVo..",
    ".ohVsvsssssssssvVho.",
    ".ohVsvooossoooSVho..",
    ".ohVsEiwssssEiwSVho.",
    ".ohoSsEissssEiSSoho.",
    ".oho.oSssssssssSo.oho",
    ".ovo..ooSSsSSoo...ovo",
]
_BUSTO_META = [  # x=8, y=17
    "......oS",  # 17 collo
    "...ooosl",  # 18
    "..osllss",  # 19 spalle nude
    ".ossotTt",  # 20 il top
    ".osotTtt",  # 21
    ".osotttT",  # 22
    "..ootTtT",  # 23
    "...osllS",  # 24 la pancia
    "...osssl",  # 25
    "...owwWW",  # 26 la cintura bianca
    "...onnnn",  # 27 gli shorts
    "...onjnn",  # 28
]
BUSTO_GIU = metta(_BUSTO_META)
TRECCE_GIU = [  # x=7, y=15 e lo specchio a x=22: le trecce sul davanti delle spalle
    "oho",
    "ovo",
    "oho",
    "ovo",
    "oao",
    ".o.",
]

def braccio(posa):
    # il braccio sinistro (di chi guarda): spalla nuda, la fascia grigia, il guanto lungo
    spalla = [".o.", "oso", "oso", "oSo", "oco"]
    guanto = ["ojo", "oJo", "ojo"]
    mano = ["ojo", "oJo", ".o."]
    if posa == "neutro":
        return spalla + guanto + ["ojo"] + mano
    if posa == "avanti":
        return spalla + guanto + ["ojo", "ojo"] + mano
    return spalla + ["ojo", "oJo"] + mano

def gamba(stinco):
    # la gamba sinistra: la coscia scoperta, il bordo dello stivale, il
    # ginocchio, e la gamba che si stringe verso la caviglia. Righe larghe 6,
    # cosi' lo specchio resta allineato
    coscia = ["osssl.", "oSssS.", "oJjjno", "oJjnno"]
    sotto = [".oJjno", ".oJjno", ".oJnno", "..oJno", "..oJjo", "..oJno", "..oJjo"][:stinco]
    piede = ["..oJjo", ".oJjno", ".onnno", "..ooo."]
    return coscia + sotto + piede

GAMBA = {
    "dritta": gamba(7),     # 15 righe: dall'orlo degli shorts a terra
    "avanti": gamba(7),
    "dietro": gamba(5),
    "piegata": gamba(6),
}

# ---------------------------------------------------------------- di spalle
TESTA_SU = [  # x=6, y=0
    ".......o..o.o.......",
    "......ohoohohoo.....",
    ".......ohHhhhvo.....",
    ".......ovAaaAvo.....",
    "....oooaaaaaoooo....",
    "...oaawaawaawaaUo...",
    "...oAaaaaaaaaaAUo...",
    "...ooooooooooooo....",
    "..ohhHhhhhhhhhhvo...",
    "..ohHhhhhhhhhhhvvo..",
    "..ohhvhhhvhhhvhvvo..",
    ".ohVvhvvhvvhvvhvVho.",
    ".ohVvvhvvvvvhvvVVho.",
    ".oHVVvvVvvVvVvVVVHo.",
    ".ohooVVoVVoVVoVooho.",
    ".oHo..oSSssSSo...oHo",
    ".oho..oooooooo...oho",
]
_BUSTO_SU_META = [
    "......oS",  # 17
    "...ooosl",  # 18
    "..osllss",  # 19
    ".ossotTt",  # 20
    ".osotTtT",  # 21 la cerniera in mezzo (col 15-16)
    ".osotttq",  # 22
    "..ootTtq",  # 23
    "...osllS",  # 24
    "...osssl",  # 25
    "...owwWW",  # 26
    "...onnnn",  # 27
    "...onjnJ",  # 28
]
BUSTO_SU = metta(_BUSTO_SU_META)

# ---------------------------------------------------------------- di lato
TESTA_DESTRA = [  # x=5, y=0: la coda va indietro, l'anello d'oro sul lato
    "o..o..............",
    "ovoho.............",
    "ohvhvoo...........",
    ".ohhhvvoo.........",
    "..ohHhhvvoooooooo.",
    "...oaawaawaaUuUo..",
    "...oAaaaaaaauUuo..",
    "...oooooooooUuoo..",
    "..ohhHhhhhhhhhvo..",
    "..ohHhhhhhhvhsvo..",
    "..oVhvhhhhvsssso..",
    "...oVvhhhvssooso..",
    "...oVvhhhvssEiwso.",
    "...oHoVvvSssEiisS.",
    "...ohooVSssssssSo.",
    "...oHo.oSSssssSo..",
    "...oho..ooSssoo...",
]
BUSTO_DESTRA = [  # x=10, y=17: il petto avanti, i fianchi e il sedere dietro
    "....oSso...",
    "...osslo...",
    "..ossllso..",
    "..otTttTto.",
    ".otTtttttTo",
    ".otttttttTo",
    "..otTtttTo.",
    "..osllllSo.",
    "..osssslo..",
    "..owwwWWo..",
    ".onnnnjno..",
    ".onjnnnno..",
]
