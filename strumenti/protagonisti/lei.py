# LEI, chibi, dal foglio «tactical RPG sprite sheet» di Bru: 32x48, i piedi a
# (16, 45). Ogni pezzo dice dove va (x, y); i colori sono in tavolozze.py.
from pezzi import r, coppia

# ---------------------------------------------------------------- di fronte
# la fascia larga prugna con le stelle e gli occhialoni d'ottone; sopra, i
# capelli raccolti a punte; la frangia, le ciocche lunghe ai lati; niente bocca
TESTA_GIU = r([  # x=4, y=1
    "........o.o..o.o........",  # 0
    ".......oHoHooHohoo......",  # 1
    "......oHHhHhoHhhhvo.....",  # 2
    ".....ohHHhhhhhhhvvVo....",  # 3
    "....ohHhhhhhhhhvvvVVo...",  # 4
    "...oauuuuammmmmuuuuMo...",  # 5
    "...ouyfffUmmmmuyfffUo...",  # 6
    "...oufffFUUUUUufffFUo...",  # 7
    "...oufFFFUMMMMufFFFUo...",  # 8
    "...oaUUUUammmmMUUUUMo...",  # 9
    "..omAmmAmmAmmAmmAmmAMo..",  # 10
    ".ohMMMMMMMMMMMMMMMMMMvo.",  # 11
    ".ohvhvVhvVhhvVhvVhvhvVo.",  # 12
    ".oXvhvShvShvSShvShvhVXo.",  # 13
    ".oXvSoeeesVSsSseeeoSvXo.",  # 14
    ".oXvseeiElssssseiEeSvXo.",  # 15
    ".oVvsseEEsssssseEESSVo..",  # 16
    ".oVvllssssssssssSSSVo...",  # 17
    "..oVolssssssssssSSSoVo..",  # 18
    "...oXosssssssssSSSoXo...",  # 19
    "....o..oSSSSSSSSo..o....",  # 20
    "........oooooooo........",  # 21
], 24)

BUSTO_GIU = r([  # x=0, y=21: il collo, le spalle, il top, la pancia, la cintura, gli shorts
    "............osss|sSSo............",  # 21
    "............osss|sSSo............",  # 22
    "........ollsstss|sSTSSSSo........",  # 23
    ".......olsttttTt|tTTTxSSo........",  # 24
    ".......osttttttT|TtTTxxSo........",  # 25
    ".........otttttT|TtTTxxo.........",  # 26
    ".........otttttT|TtTTTxo.........",  # 27
    ".........oxTTTTx|xTTTxxo.........",  # 28
    ".........osllsss|ssssSSo.........",  # 29
    ".........oslssss|SsssSSo.........",  # 30
    ".........ossssss|sssSSSo.........",  # 31
    ".........owcwwcw|wcwwcWo.........",  # 32
    ".........oDddddd|ddddddo.........",  # 33
    ".........oDdddDd|dDddddo.........",  # 34
    ".........oDddddo|odddddo.........",  # 35
], 32)

def _braccio(guanto_righe):
    return ["olsS", "olsS", "oKjn"] + guanto_righe + ["oKjn", "oJjn", "oJjj", ".ooo"]

BRACCIO_GIU_S = {  # x=5, y=24: la spalla nuda, poi il guanto lungo
    "neutro":   _braccio(["oJjn"] * 4),
    "avanti":   _braccio(["oJjn"] * 5),
    "indietro": _braccio(["oJjn"] * 3),
}
def _braccio_d(guanto_righe):
    return ["sSSo", "sSSo", "Kjno"] + guanto_righe + ["Kjno", "jnno", "jjno", "ooo."]
BRACCIO_GIU_D = {  # x=23, y=24
    "neutro":   _braccio_d(["jnno"] * 4),
    "avanti":   _braccio_d(["jnno"] * 5),
    "indietro": _braccio_d(["jnno"] * 3),
}

# le gambe: la coscia nuda, lo stivale alto fino a sopra il ginocchio; x=8, y=36
_DRITTA_S = [".olsssSo", ".olsssSo", ".oKKJjno", ".oJjjjno", ".oJKjjno", ".oJjjjno", ".oJjjjno", "ojJjjjno", "oooooooo"]
_DRITTA_D = ["osssSSo.", "osssSSo.", "oKJjnno.", "ojjjnno.", "ojKjnno.", "ojjjnno.", "ojjjnno.", "ojjjjnno", "oooooooo"]
_ALZATA_S = [".olsssSo", ".olsssSo", ".oKKJjno", ".oJjjjno", ".oJKjjno", ".oJjjjno", ".ooooooo"]
_ALZATA_D = ["osssSSo.", "osssSSo.", "oKJjnno.", "ojjjnno.", "ojKjnno.", "ojjjnno.", "ooooooo."]
_PIEGATA_S = [".olsssSo", ".oKKJjno", ".oJKjjno", ".oJjjjno", ".oJjjjno", "ojJjjjno", "oooooooo"]
_PIEGATA_D = ["osssSSo.", "oKJjnno.", "ojKjnno.", "ojjjnno.", "ojjjnno.", "ojjjjnno", "oooooooo"]

GAMBE_GIU = {
    "dritte": coppia(_DRITTA_S, _DRITTA_D),
    "s_avanti": coppia(_DRITTA_S, _ALZATA_D),
    "d_avanti": coppia(_ALZATA_S, _DRITTA_D),
    "d_passa": coppia(_DRITTA_S, _PIEGATA_D),
    "s_passa": coppia(_PIEGATA_S, _DRITTA_D),
}

# ---------------------------------------------------------------- di spalle
TESTA_SU = r([  # x=4, y=1: la coda a punte, la fascia da dietro, i capelli sotto
    "........o.o..o.o........",  # 0
    ".......oHoHooHohoo......",  # 1
    "......oHHhHhoHhhhvo.....",  # 2
    ".....ohHHhhhhhhhvvVo....",  # 3
    "....ohHhhhhhhhhvvvVVo...",  # 4
    "...oaammmmmmmmmmmmMMo...",  # 5
    "...oaammmmmmmmmmmmMMo...",  # 6
    "...oammmmmmmmmmmmmMMo...",  # 7
    "...oammmmmmmmmmmmmMMo...",  # 8
    "...oaMMMMMMMMMMMMMMMo...",  # 9
    "..omAmmAmmAmmAmmAmmAMo..",  # 10
    ".ohMMMMMMMMMMMMMMMMMMvo.",  # 11
    ".ohhhvhhhvhhhvhhhvhhvVo.",  # 12
    ".ohhvhhvhhvhhvhhvhhvVVo.",  # 13
    ".oVhvhVhvhVhvhVhvhVvVXo.",  # 14
    ".oVvhvVvhvVvhvVvhvVvVXo.",  # 15
    ".oXVvVvVvVvVvVvVvVvVXo..",  # 16
    "..oXVVvVVvVVvVVvVVVXo...",  # 17
    "...oXVVoVVVoVVVoVVXo....",  # 18
    "....oXo.oVVo.oVVo.oo....",  # 19
    ".........oo...oo........",  # 20
], 24)

BUSTO_SU = r([  # x=0, y=21: la schiena nuda, i lacci del top, la cintura, gli shorts
    "............osss|sSSo............",  # 21
    "............osss|sSSo............",  # 22
    "........ollssssT|TsSSSSSo........",  # 23
    ".......olsssssTs|sTSSSSSo........",  # 24
    ".......olssssTss|ssTSSSSo........",  # 25
    ".........otttttt|ttTTxxo.........",  # 26
    ".........otttttt|tTTTxxo.........",  # 27
    ".........oxTTTTT|TTTTxxo.........",  # 28
    ".........olsssss|ssssSSo.........",  # 29
    ".........olsssss|sssSSSo.........",  # 30
    ".........ossssss|sssSSSo.........",  # 31
    ".........owcwwcw|wcwwcWo.........",  # 32
    ".........oDddddd|ddddddo.........",  # 33
    ".........oDdddDd|dDddddo.........",  # 34
    ".........oDddddo|odddddo.........",  # 35
], 32)
BRACCIO_SU_S = BRACCIO_GIU_S
BRACCIO_SU_D = BRACCIO_GIU_D
GAMBE_SU = GAMBE_GIU

# ---------------------------------------------------------------- di lato
TESTA_DESTRA = r([  # x=5, y=1: guarda a destra; un occhialone di lato sul davanti
    "..o..o.o..............",  # 0
    "..oHooHoHo...o........",  # 1
    "...oHHhHhhHoohoo......",  # 2
    "...ohHhhhhhhhhhvoo....",  # 3
    "..ohHhhhhhhhhhhvvVVo..",  # 4
    "..oaaammmmmmmmuuuMo...",  # 5
    ".oaammmmmmmmmmuyffUo..",  # 6
    ".oammmmmmmmmmmufffUo..",  # 7
    ".oammmmmmmmmmmuFFFUo..",  # 8
    ".oammmmmmmmmmmMUUUMo..",  # 9
    ".omAmmAmmAmmAmmAmmMo..",  # 10
    ".ohMMMMMMMMMMMMMMMMvo.",  # 11
    ".ohvhvhhvhhvVhSvShvVo.",  # 12
    ".oXVhvhvVhVXSlssssSVo.",  # 13
    "..oXVhvVvXsSlssoeeesSo",  # 14
    "..oXVvVvXsSllsseeiEsSo",  # 15
    "...oXVvXosSlssseeEEsso",  # 16
    "...oXVXoosSssssssssSo.",  # 17
    "....oXo..oSssssssssSo.",  # 18
    ".....o....oSsssssSSo..",  # 19
    "...........oSSSSSSo...",  # 20
    "............oooooo....",  # 21
], 22)

BUSTO_DESTRA = r([  # x=10, y=21
    "....osSSo...",  # 21
    "....osSSo...",  # 22
    "..ollssSSo..",  # 23
    "..olsttttTo.",  # 24
    "..ostttttTTo",  # 25
    "..otttttttTo",  # 26
    "..otttttTTxo",  # 27
    "..oxTTTTTxo.",  # 28
    "..olsssssSo.",  # 29
    "..olsssssSo.",  # 30
    "..ossssssSo.",  # 31
    "..owcwwcwWo.",  # 32
    "..oDddddddo.",  # 33
    "..oDddddddo.",  # 34
    "..oDdddddDo.",  # 35
], 12)

STIVALE_DESTRA = [
    "oKJjo...",
    "oJjjo...",
    "ojJjjo..",
    "ojjjjjjo",
    "oooooooo",
]
STIVALE_DESTRA_LONTANO = [x.replace('K', 'j').replace('J', 'n') for x in STIVALE_DESTRA]
GUANTO_DESTRA = [".oo.", "oJjo", "ojno", ".oo."]
