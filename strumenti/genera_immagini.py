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
