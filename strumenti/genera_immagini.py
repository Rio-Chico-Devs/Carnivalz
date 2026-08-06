#!/usr/bin/env python3
"""Genera docs/immagini.md: dove va ogni disegno, con il nome esatto del file.

Serve perche' il nome del file NON e' sempre l'id del personaggio. Yhvina ha
id "insonne" ma il suo ritratto si chiama yhvina.png, perche' il percorso lo
decide il campo "ritratto" nei dati e non l'id. Un file col nome sbagliato non
da' nessun errore: il gioco mostra il segnaposto con l'iniziale, e uno se ne
accorge giocando, magari fra un mese.

Questo documento si rigenera, non si scrive a mano:

    python3 strumenti/genera_immagini.py
"""
import json
import os

RADICE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# Le 16 espressioni dei dialoghi. "neutra" e' quella di ripiego: se un dialogo
# ne chiede una che non c'e', si usa quella.
ESPRESSIONI = [
    "neutra", "arrabbiata", "felice", "carina", "infastidita", "disgusto",
    "speciale", "dialogo", "delusa", "petrificata", "annoiata", "pensiero",
    "sorpresa", "sforzo", "cool", "decisa",
]

ALTRI = [
    ("art/mappa.png", "Sfondo della mappa stellare (la proiezione del settore)"),
    ("art/sede.png", "Sfondo della Sede"),
    ("art/branding/logo_studio.png", "Logo Rio Chico Devs, primo dei loghi d'apertura"),
    ("art/branding/logo_personale.png", "Logo personale, secondo logo d'apertura"),
    ("art/fx/slaughter.png", "Illustrazione a schermo intero dello Slaughter"),
]


def carica(percorso):
    with open(os.path.join(RADICE, percorso), encoding="utf-8") as f:
        return json.load(f)


def file_eventi():
    import glob
    fuori = sorted(glob.glob(os.path.join(RADICE, "data", "events*.json")))
    fuori += sorted(glob.glob(os.path.join(RADICE, "data", "vuoti", "*.json")))
    return fuori


def espressioni_richieste():
    """Quali facce i dialoghi chiedono DAVVERO, personaggio per personaggio.

    E' la differenza fra "servono 16 espressioni per 48 personaggi" (768 disegni,
    che nessuno fa) e "servono queste, adesso". Chi compare in scena ha bisogno
    almeno della neutra; le altre solo se una battuta le nomina.
    """
    usi = {}
    def segna(chi, espressione):
        if not chi or not espressione:
            return
        usi.setdefault(chi, set()).add(espressione)
    for percorso in file_eventi():
        with open(percorso, encoding="utf-8") as f:
            nodi = json.load(f).get("nodi", {})
        for nodo in nodi.values():
            in_scena = {}
            for lato in ["sinistra", "destra", "centro"]:
                valore = nodo.get(lato)
                if isinstance(valore, dict):
                    in_scena[lato] = valore.get("id", "")
                    segna(valore.get("id", ""), valore.get("espr", ""))
                elif isinstance(valore, str) and valore:
                    in_scena[lato] = valore
                segna(in_scena.get(lato, ""), nodo.get("espr_" + lato, ""))
            for chi in in_scena.values():
                segna(chi, "neutra")   # in scena senza indicazioni: la neutra serve
            for msg in nodo.get("sequenza", []):
                if not isinstance(msg, dict):
                    continue
                segna(msg.get("chi", ""), msg.get("espr", ""))
                if msg.get("tipo") == "dialogo":
                    segna(msg.get("chi", ""), "neutra")
    return usi


def illustrazioni():
    """Le illustrazioni a schermo intero che una scena si ferma a mostrare.

    Non sono ritratti: sono disegni singoli, chiamati da un messaggio
    `"tipo": "immagine"` col percorso scritto dentro il file di eventi. La
    didascalia serve a capire cosa ci deve stare dentro.
    """
    fuori = []
    visti = set()
    for percorso in file_eventi():
        with open(percorso, encoding="utf-8") as f:
            nodi = json.load(f).get("nodi", {})
        for id_nodo, nodo in nodi.items():
            for msg in nodo.get("sequenza", []):
                if not isinstance(msg, dict) or msg.get("tipo") != "immagine":
                    continue
                file_chiesto = msg.get("file", "")
                if not file_chiesto or file_chiesto in visti:
                    continue
                visti.add(file_chiesto)
                fuori.append({
                    "file": file_chiesto,
                    "dove": "%s › %s" % (os.path.basename(percorso), id_nodo),
                    "didascalia": msg.get("testo", ""),
                })
    return fuori


def esiste(percorso_res):
    return os.path.exists(os.path.join(RADICE, percorso_res.replace("res://", "")))


def voci():
    """Chi ha bisogno di un'immagine, e quale file esattamente."""
    fuori = []
    for classe in carica("data/classes.json")["classi"]:
        fuori.append({
            "gruppo": "Squadra",
            "id": classe["id"],
            "nome": classe.get("nome", classe["id"]),
            "file": classe.get("ritratto", ""),
            "dialoghi": True,
        })
    for p in carica("data/personaggi.json")["personaggi"]:
        combatte = "hp" in p
        fuori.append({
            "gruppo": "Creature" if combatte else "Personaggi",
            "id": p["id"],
            "nome": p.get("nome", p["id"]),
            "file": p.get("ritratto", ""),
            # chi non combatte compare solo nei dialoghi, quindi le espressioni
            # gli servono davvero; una creatura da combattimento se la cava con
            # il ritratto singolo
            "dialoghi": not combatte,
            "livello": p.get("livello"),
        })
    return [v for v in fuori if v["file"]]


def genera():
    elenco = voci()
    righe = ["# Dove vanno i disegni (generato, non scrivere qui a mano)", ""]
    righe.append("Rigenera con `python3 strumenti/genera_immagini.py`.")
    righe.append("")
    righe.append("**Il nome del file non e' sempre l'id.** Lo decide il campo `ritratto` nei dati:")
    righe.append("Yhvina ha id `insonne` ma il suo file si chiama `yhvina.png`. Usa la colonna")
    righe.append("*file* e non pensarci piu'.")
    righe.append("")
    righe.append("Formati: PNG con trasparenza. Non serve una misura precisa — il gioco scala")
    righe.append("mantenendo le proporzioni. Un file che manca non rompe niente: si vede un")
    righe.append("segnaposto con l'iniziale del nome, quindi si puo' disegnare a poco a poco.")
    righe.append("")
    righe.append("## Le espressioni, per chi parla nei dialoghi")
    righe.append("")
    righe.append("Chi ha delle battute puo' avere una cartella sua con le espressioni:")
    righe.append("")
    righe.append("```")
    righe.append("art/personaggi/<id>/<espressione>.png")
    righe.append("```")
    righe.append("")
    righe.append("Le 16: " + " · ".join("`%s`" % e for e in ESPRESSIONI))
    righe.append("")
    righe.append("`neutra` e' quella di ripiego, conviene farla per prima. Se manca anche quella")
    righe.append("si usa il file singolo `art/personaggi/<id>.png`, che va benissimo da solo.")
    righe.append("")
    righe.append("Le 16 non sono una gabbia: `espr` e' il nome del file, quindi una scena puo'")
    righe.append("chiedere `\"espr\": \"sotto_la_pioggia\"` e basta disegnare quel file.")
    righe.append("")

    # --- la lista che serve DAVVERO, in cima ---
    usi = espressioni_richieste()
    nomi = {v["id"]: v["nome"] for v in elenco}
    mancanti_ritratto = [v for v in elenco if not esiste(v["file"])]
    righe.append("## Cosa serve, adesso")
    righe.append("")
    righe.append("Non 16 espressioni per 48 personaggi (768 disegni, che non li fa nessuno).")
    righe.append("Questo e' quello che i dialoghi scritti finora chiedono davvero.")
    righe.append("")
    righe.append("### 1. Il ritratto singolo — %d da fare"
            % len({v["file"] for v in mancanti_ritratto}))
    righe.append("")
    righe.append("Basta questo perche' nessuno sia piu' un segnaposto. Le creature da")
    righe.append("combattimento si fermano qui: non parlano, non gli serve altro.")
    righe.append("")
    righe.append("```")
    # due creature possono condividere lo stesso ritratto (Jongo Dongo e il suo
    # risorto): il disegno e' uno, e nella lista deve comparire una volta sola
    visti = set()
    for v in sorted(mancanti_ritratto, key=lambda x: x["file"]):
        percorso = v["file"].replace("res://", "")
        if percorso in visti:
            continue
        visti.add(percorso)
        righe.append(percorso)
    righe.append("```")
    righe.append("")
    conteggio = sum(len(e) for e in usi.values())
    righe.append("### 2. Le espressioni dei dialoghi — %d da fare" % conteggio)
    righe.append("")
    righe.append("Solo per chi ha delle battute, e solo le facce che le battute nominano.")
    righe.append("Se una manca si ripiega sulla neutra, e se manca anche quella sul ritratto")
    righe.append("singolo: si puo' fare in qualunque ordine.")
    righe.append("")
    righe.append("```")
    for cid in sorted(usi):
        for espressione in sorted(usi[cid]):
            righe.append("art/personaggi/%s/%s.png" % (cid, espressione))
    righe.append("```")
    righe.append("")
    righe.append("| chi | quante | quali |")
    righe.append("|---|--:|---|")
    for cid in sorted(usi, key=lambda c: (-len(usi[c]), c)):
        righe.append("| %s (`%s`) | %d | %s |" % (
            nomi.get(cid, cid), cid, len(usi[cid]),
            " · ".join("`%s`" % e for e in sorted(usi[cid]))))
    righe.append("")

    for gruppo in ["Squadra", "Creature", "Personaggi"]:
        del_gruppo = [v for v in elenco if v["gruppo"] == gruppo]
        if not del_gruppo:
            continue
        righe.append("## %s" % gruppo)
        righe.append("")
        if gruppo == "Creature":
            righe.append("| creatura | lv | file | espressioni | c'è |")
            righe.append("|---|--:|---|---|:-:|")
        else:
            righe.append("| chi | file | espressioni | c'è |")
            righe.append("|---|---|---|:-:|")
        for v in sorted(del_gruppo, key=lambda x: (x.get("livello") or 0, x["nome"])):
            percorso = v["file"].replace("res://", "")
            cartella = "art/personaggi/%s/" % v["id"] if v["dialoghi"] else "—"
            segno = "✓" if esiste(v["file"]) else ""
            if gruppo == "Creature":
                righe.append("| %s | %s | `%s` | %s | %s |" % (
                    v["nome"], v.get("livello") or "—", percorso,
                    "`%s`" % cartella if cartella != "—" else "—", segno))
            else:
                righe.append("| %s | `%s` | %s | %s |" % (
                    v["nome"], percorso,
                    "`%s`" % cartella if cartella != "—" else "—", segno))
        righe.append("")

    quadri = illustrazioni()
    if quadri:
        righe.append("## Le illustrazioni delle scene")
        righe.append("")
        righe.append("Disegni singoli a schermo intero: la scena si ferma, li mostra con la")
        righe.append("didascalia sotto, e poi riprende. Se il file non c'e' resta la didascalia,")
        righe.append("quindi si possono fare con calma. Vanno in `art/illustrazioni/`.")
        righe.append("")
        righe.append("| file | dove | cosa si vede | c'è |")
        righe.append("|---|---|---|:-:|")
        for q in quadri:
            righe.append("| `%s` | %s | %s | %s |" % (
                q["file"].replace("res://", ""), q["dove"], q["didascalia"],
                "✓" if esiste(q["file"]) else ""))
        righe.append("")

    righe.append("## Il resto")
    righe.append("")
    righe.append("| file | cos'è | c'è |")
    righe.append("|---|---|:-:|")
    for percorso, cosa in ALTRI:
        righe.append("| `%s` | %s | %s |" % (percorso, cosa, "✓" if esiste(percorso) else ""))
    righe.append("")

    fatti = sum(1 for v in elenco if esiste(v["file"]))
    righe.append("---")
    righe.append("")
    righe.append("Ritratti presenti: **%d su %d**." % (fatti, len(elenco)))
    righe.append("")
    return "\n".join(righe)


if __name__ == "__main__":
    destinazione = os.path.join(RADICE, "docs", "immagini.md")
    with open(destinazione, "w", encoding="utf-8") as f:
        f.write(genera())
    print("scritto docs/immagini.md")
