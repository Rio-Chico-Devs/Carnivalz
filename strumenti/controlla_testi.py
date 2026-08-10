#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Cerca errori di ortografia e di battitura nei testi che il giocatore legge.

PERCHE' ESISTE. I testi sono decine di migliaia di parole scritte a quattro
mani e corrette a mano su un documento generato: un accento sbagliato o un
apostrofo mancante non fa fallire niente, non lo vede nessuna prova, e resta
li' finche' qualcuno non lo legge per caso a schermo. Rileggere tutto ogni
volta non e' un piano.

Qui non c'e' un correttore: c'e' un elenco di errori che in italiano si fanno
sempre, e che si riconoscono con certezza. Meglio poche regole che non sbagliano
mai di tante che gridano al lupo - un controllo che da' falsi allarmi smette di
essere letto dopo due giri.

    python3 strumenti/controlla_testi.py          # elenca
    python3 strumenti/controlla_testi.py --correggi   # corregge quelli sicuri
"""
import glob
import json
import os
import re
import sys

RADICE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# (cosa cercare, con cosa sostituire, perche')
# Il primo gruppo e' quello che viene sostituito; il resto del pattern serve
# solo a essere sicuri di aver capito bene.
REGOLE = [
    (r"\bperchè\b", "perché", "perché vuole l'accento acuto"),
    (r"\bpoichè\b", "poiché", "poiché vuole l'accento acuto"),
    (r"\bbenchè\b", "benché", "benché vuole l'accento acuto"),
    (r"\bfinchè\b", "finché", "finché vuole l'accento acuto"),
    (r"\banzichè\b", "anziché", "anziché vuole l'accento acuto"),
    (r"\bnonchè\b", "nonché", "nonché vuole l'accento acuto"),
    (r"\baffinchè\b", "affinché", "affinché vuole l'accento acuto"),
    (r"\bsicchè\b", "sicché", "sicché vuole l'accento acuto"),
    (r"\bcosicchè\b", "cosicché", "cosicché vuole l'accento acuto"),
    (r"\bun pò\b", "un po'", "«po'» è un troncamento: vuole l'apostrofo"),
    (r"\bLyloh\b", "Lylloh", "il nome della bambina si scrive Lylloh"),
    (r"\bLilloh\b", "Lylloh", "il nome della bambina si scrive Lylloh"),
    (r"\bHmph\b", "Hmpf", "il verso di Yhvina si scrive Hmpf"),
    (r"\bqual'è\b", "qual è", "«qual» non si apostrofa mai"),
    (r"\bsè stess", "sé stess", "«sé» pronome vuole l'accento acuto"),
    (r"\btra sè\b", "tra sé", "«sé» pronome vuole l'accento acuto"),
    (r"\bda sè\b", "da sé", "«sé» pronome vuole l'accento acuto"),
    (r"\bun'altro\b", "un altro", "«altro» è maschile: niente apostrofo"),
    (r"\bun'altra volta\b", "un'altra volta", None),   # corretto: serve a non toccarlo
    (r"\bnessun'altro\b", "nessun altro", "«altro» è maschile: niente apostrofo"),
    (r"\bqualcun'altro\b", "qualcun altro", "«altro» è maschile: niente apostrofo"),
    (r"\bce ne è\b", "ce n'è", "«ce n'è» si elide"),
    (r"\bdà retta\b", "da' retta", "imperativo di dare: «da'»"),
    (r"\baqua\b", "acqua", "battitura"),
    (r"\bpropio\b", "proprio", "battitura"),
    (r"\bfamilgia\b", "famiglia", "battitura"),
    (r"\bcosciente\b", "cosciente", None),
    (r"\bsopratutto\b", "soprattutto", "soprattutto vuole due t"),
    (r"\bpurtoppo\b", "purtroppo", "battitura"),
    (r"\bcomunuqe\b", "comunque", "battitura"),
    (r"\bquindin\b", "quindi", "battitura"),
    (r"\bassolutamnete\b", "assolutamente", "battitura"),
    (r"\bprovvenire\b", "provenire", "provenire ha una v sola"),
    (r"\braggionar", "ragionar", "ragionare ha una g sola"),
    (r"\braggione\b", "ragione", "ragione ha una g sola"),
    (r"\billegibil", "illeggibil", "illeggibile ha due g"),
    (r"\bartiginal", "artigianal", "artigianale"),
    (r"\baddorn", "adorn", "adornare ha una d sola"),
    (r"\bfermmo\b", "fermo", "battitura"),
    (r"\bcontradistigue\b", "contraddistingue", "contraddistingue"),
    (r"\bpiù\s+più\b", "più", "parola ripetuta"),
    (r"\bnon ostante\b", "nonostante", "nonostante è una parola sola"),
    (r"\bprorogativa\b", "prerogativa", "prerogativa"),
    (r"\bsvilluppa", "sviluppa", "sviluppare ha una l sola"),
    (r"\bricevuro\b", "ricevuto", "battitura"),
    (r"\brimasco\b", "rimasto", "battitura"),
    (r"\bsingorina\b", "signorina", "battitura"),
    (r"\bfraintendiamoci\b", "fraintendiamoci", None),
    (r"\bcreate questo\b", "creare questo", "battitura"),
    (r"\binaffi", "innaffi", "innaffiare ha due n"),
    (r"\bun entrata\b", "un'entrata", "«entrata» è femminile: vuole l'apostrofo"),
    (r"\bun anima\b", "un'anima", "«anima» è femminile: vuole l'apostrofo"),
    (r"\bun altra\b", "un'altra", "«altra» è femminile: vuole l'apostrofo"),
    (r"\bun ora\b", "un'ora", "«ora» è femminile: vuole l'apostrofo"),
    (r"\bun'\s+", "un'", "apostrofo staccato dalla parola"),
    (r"\bqualsiasi cosa sia\b", "qualsiasi cosa sia", None),
    (r"\bdisserbante\b", "diserbante", "diserbante ha una s sola"),
    (r"\bvelonos", "velenos", "velenoso"),
    (r"\bd'altronde\b", "d'altronde", None),
    (r"  +", " ", "spazi doppi"),
    (r" ,", ",", "spazio prima della virgola"),
    (r"\ba volta scatta\b", "a volte scatta", "battitura"),
]

# L'ACCENTO SCRITTO CON L'APOSTROFO. Nei commenti del codice si scrive "perche'"
# perche' li' l'accento da' fastidio; nei dati no, perche' quella roba finisce
# a schermo tale e quale. Sono due mondi vicini e si sbaglia di continuo.
# Il maiuscolo e' escluso: il Robo Pattuglia parla in stampatello, e li' e' voluto.
ACCENTO_CON_APOSTROFO = re.compile(
    r"\b(e|puo|piu|gia|sara|saro|finche|perche|poiche|cosi|liberta|citta|verita|realta|"
    r"meta|qualita|dovro|potro|andro|faro|dara|fara|verra)'(?![a-zA-ZÀ-ÿ])")
GIUSTO = {"e": "è", "puo": "può", "piu": "più", "gia": "già", "sara": "sarà", "saro": "sarò",
          "finche": "finché", "perche": "perché", "poiche": "poiché", "cosi": "così",
          "liberta": "libertà", "citta": "città", "verita": "verità", "realta": "realtà",
          "meta": "metà", "qualita": "qualità", "dovro": "dovrò", "potro": "potrò",
          "andro": "andrò", "faro": "farò", "dara": "darà", "fara": "farà", "verra": "verrà"}

# I campi che il giocatore legge davvero. Fuori da questi non si tocca niente:
# gli id, i percorsi e gli appunti di sviluppo non sono prosa.
CAMPI = {"testo", "nome", "nome_breve", "descrizione", "titolo", "domanda", "risposta",
         "osservazione", "testo_turno", "apertura", "scena", "testo_annuncio",
         "testo_studio_esaurito", "testo_applicazione"}


def file_dati():
    return sorted(glob.glob(os.path.join(RADICE, "data", "**", "*.json"), recursive=True))


def cammina(nodo, camino, trovato):
    """Scende nei dati e chiama trovato(camino, testo) su ogni stringa da leggere."""
    if isinstance(nodo, dict):
        for chiave, valore in nodo.items():
            if chiave.startswith("_"):
                continue          # _nota: appunti di sviluppo, non prosa
            passo = f"{camino}.{chiave}"
            if isinstance(valore, str):
                if chiave in CAMPI or chiave.startswith("testo"):
                    trovato(passo, valore, nodo, chiave)
            else:
                cammina(valore, passo, trovato)
    elif isinstance(nodo, list):
        for i, valore in enumerate(nodo):
            if not isinstance(valore, str):
                cammina(valore, f"{camino}[{i}]", trovato)


def controlla(correggi=False):
    segnalazioni = []
    for percorso in file_dati():
        with open(percorso, encoding="utf-8") as f:
            dati = json.load(f)
        cambiato = [False]

        def trovato(camino, testo, contenitore, chiave):
            nuovo = testo
            if not testo.isupper():
                for m in ACCENTO_CON_APOSTROFO.finditer(nuovo):
                    contorno = nuovo[max(0, m.start() - 34):m.end() + 34].replace("\n", " ")
                    segnalazioni.append((os.path.relpath(percorso, RADICE), camino, m.group(0),
                                         "accento scritto con l'apostrofo: qui si legge a schermo",
                                         contorno))
                nuovo = ACCENTO_CON_APOSTROFO.sub(
                    lambda m: GIUSTO[m.group(1)], nuovo)
            for cerca, sostituisci, perche in REGOLE:
                if perche is None:
                    continue      # regola presente solo per documentare che va bene cosi'
                for m in re.finditer(cerca, nuovo):
                    contorno = nuovo[max(0, m.start() - 34):m.end() + 34].replace("\n", " ")
                    segnalazioni.append((os.path.relpath(percorso, RADICE), camino,
                                         m.group(0), perche, contorno))
                nuovo = re.sub(cerca, sostituisci, nuovo)
            if correggi and nuovo != testo:
                contenitore[chiave] = nuovo
                cambiato[0] = True

        cammina(dati, os.path.basename(percorso)[:-5], trovato)
        if correggi and cambiato[0]:
            with open(percorso, "w", encoding="utf-8") as f:
                json.dump(dati, f, ensure_ascii=False, indent="\t")
                f.write("\n")
    return segnalazioni


if __name__ == "__main__":
    correggi = "--correggi" in sys.argv
    trovate = controlla(correggi)
    if not trovate:
        print("nessun errore fra quelli che questo controllo sa riconoscere")
        sys.exit(0)
    per_file = {}
    for percorso, camino, pezzo, perche, contorno in trovate:
        per_file.setdefault(percorso, []).append((camino, pezzo, perche, contorno))
    for percorso in sorted(per_file):
        print(f"\n{percorso}")
        for camino, pezzo, perche, contorno in per_file[percorso]:
            print(f"  «{pezzo}» → {perche}")
            print(f"      {camino}")
            print(f"      ...{contorno}...")
    print(f"\n{len(trovate)} segnalazioni"
          + (" — corrette" if correggi else " (rilancia con --correggi per sistemarle)"))
