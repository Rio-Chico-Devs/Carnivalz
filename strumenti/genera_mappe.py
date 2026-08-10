#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Genera docs/mappe.md: come sono fatte le mappe, e la mappa di ogni zona.

Serve a vedere i PERCORSI. Un file di eventi e' un elenco di stanze in ordine
alfabetico: da li' non si capisce ne' dove si comincia, ne' cosa si apre dopo
cosa, ne' quali strade tornano indietro. Qui invece ogni zona viene disegnata
sulla griglia e poi ripercorsa dal suo nodo iniziale, segnando cosa si trova e
cosa sblocca.

Non si scrive a mano, si rigenera:

    python3 strumenti/genera_mappe.py
"""
import glob
import json
import os

RADICE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# I file di eventi, col nome con cui chiamarli nel documento
ZONE = [
    ("data/events_intro.json", "Introduzione"),
    ("data/events_tutorial.json", "Pianure di Redenna (tutorial)"),
    ("data/events.json", "Il Vuoto Ardente — campagna di Jerah"),
]

PREMESSA = """# Le mappe (generato, non scrivere qui a mano)

Rigenera con `python3 strumenti/genera_mappe.py`.

## Come e' fatta una mappa

Ogni **quadratino e' una scena**: un nodo del file di eventi, cioe' una
schermata con la sua descrizione, le sue scelte e i suoi agguati. Una zona e'
una figura composta da tanti quadratini, e la figura e' la mappa.

I quadratini si **illuminano man mano che esplori**: finche' non ci sei mai
arrivato, un quadratino non c'e'. Se e' il vicino ancora ignoto di un posto in
cui sei stato, si vede che c'e' qualcosa ma non cosa: e' il quadratino spento
al bordo della luce.

**Dalla mappa non ci si teletrasporta.** Vedere un posto e poterci arrivare
sono due cose diverse: da qui si va solo dove si andrebbe a piedi, cioe' in una
stanza che confina con quella in cui sei. Una mappa che porta ovunque cancella
l'esplorazione senza che nessuno se ne accorga - si continua a giocare,
semplicemente il mondo non ha piu' distanze.

### Il proiettore

L'unica eccezione. E' in dotazione al dominatore: in alcune stanze compare la
scelta di **piantarlo li'**, e da quel momento la mappa ci riporta da qualunque
punto della zona. Ne esiste **uno solo**, e piantarlo altrove lo sposta: e'
quello che rende «dove lo ancoro» una decisione invece di una comodita' che si
accumula. Vive per zona - un'ancora piantata a Meridia non ha senso dentro la
Casa Gigante.

Nei dati e' una scelta con `"piazza_proiettore": true`, e sparisce da sola nella
stanza dove il proiettore sta gia'.

### La legenda

| segno | cosa vuol dire |
|---|---|
| quadrato **rosso pieno** | ci sei stato: percorso normale |
| quadrato **verde pieno** | ci sei stato: zona segreta (`tipo: "segreta"`) |
| quadrato con **`?`** acceso | lo sai raggiungibile e non ci sei mai andato. Cliccandolo ci vai |
| quadrato con **`?`** spento | sai solo che li' c'e' qualcosa, perche' confina con un posto in cui sei stato. Cliccandolo il gioco dice perche' non si passa ancora |
| **niente** | non ne sai nemmeno l'esistenza: la mappa si costruisce camminando |
| **freccia** | dove sei adesso |
| **cerchio** | il boss della zona |
| **punto pieno** | uno scontro duro: li' negli agguati puo' capitare qualcosa di molto piu' grosso |
| **✕** | il punto da cui si esce dalla zona |
| **cornice** | la porzione di mappa che stai guardando |

Le icone sono disegnate a mano dal codice finche' non arrivano i disegni veri.
Aggiungerne una vuol dire **aggiungere un file**, non toccare il codice: se
esiste `art/icone_mappa/<icona>.png` quello vince sul disegno provvisorio.

### Le stanze grandi

Una stanza grande **occupa piu' di un quadratino**: nei dati e' il campo
`dimensione` (larghezza x altezza in quadratini). Serve a far vedere che la
piazza sotterranea non e' larga come un ripostiglio: la mappa deve mentire il
meno possibile.

Due stanze non possono finire sullo stesso quadratino. Non e' una convenzione:
`prova_mappe` tiene il conto di ogni casella occupata, e allargare una stanza
sopra la vicina fa fallire le prove invece di produrre un quadrato che ne copre
un altro (con quello sotto diventato incliccabile, e nessun errore da nessuna
parte).

### I piani

Se una frattura (o un Carnivalz) ha piu' piani, **ogni piano ha la sua mappa**,
col suo titolo — «1° piano», «-2», «sotterranei». Si passa da una all'altra
dove il percorso sale o scende. Il primo caso vero e' il garage di Meridia:
quattro piani sotto la citta', ognuno una discesa in linea retta.

### La mappa totale

Piu' avanti uno dei personaggi sapra' **disegnare la mappa intera** di una
zona. Non la riempie: ne mostra i *contorni*. Vedi la forma completa della
figura e capisci che li', in un punto che non hai ancora battuto, c'e'
qualcosa — un'area segreta, una stanza che non hai aperto — senza sapere cosa
sia. E' il contrario dell'esplorazione automatica: ti dice **dove guardare**,
non cosa troverai.

## Cosa c'e' gia' e cosa manca

| pezzo | stato |
|---|---|
| una mappa per zona, coi collegamenti | ✅ `mappa_dungeon` nel file di eventi |
| i posti si illuminano esplorando | ✅ `nodi_visitati` / `stanza_sbloccata()` |
| **quadrati su griglia** invece di pallini e linee | ✅ campo `cella` |
| **stanze grandi** su piu' quadratini | ✅ campo `dimensione` |
| il **«?»** su quello che si intravede | ✅ e cliccandolo ci si va, se la storia l'ha aperto |
| zone segrete in verde | ✅ campo `tipo: "segreta"` — nessuna ancora marcata nei dati |
| icone (boss, scontro duro, uscita...) | ✅ campo `icona`, disegnate a mano finche' non arrivano i disegni: basta mettere `art/icone_mappa/<icona>.png` |
| cornice della vista | ✅ |
| **niente teletrasporto**: si va solo nelle stanze confinanti | ✅ |
| il **proiettore** come unica eccezione | ✅ `piazza_proiettore` sulla scelta |
| zoom e trascinamento | ⬜ oggi la griglia si adatta da sola al riquadro |
| piu' piani per zona | ⬜ oggi la mappa e' una sola per file di eventi |
| eventi che compaiono sulla mappa dopo uno scontro, e **scadono** se il giocatore perde troppo tempo | ⬜ |
| mappa totale a contorni | ⬜ (abilita' di un personaggio, piu' avanti) |

## Come si legge quello che segue

Per ogni zona ci sono due disegni della stessa cosa.

**La griglia** e' la mappa come la vede il giocatore: dove stanno le stanze una
rispetto all'altra. `▶` e' il punto di ingresso, `✕` l'uscita dalla zona, `◇` una
zona segreta. Una stanza grande occupa piu' caselle: le caselle in piu' portano
una freccia (`↑`, `←`) verso quella che ha il nome.

**Il percorso** e' la stessa zona ripercorsa dall'ingresso, per far vedere in
che ordine si apre. Ogni riga e' una scelta; l'indentazione e' la profondita'.
A destra, fra parentesi, cosa comporta:

- `oggetto` — quella scelta fa raccogliere qualcosa (una volta sola)
- `agguato NN%` — entrando li' si rischia uno scontro casuale
- `scontro!` — uno scontro scritto, che parte da solo
- `flag` — quella stanza alza un flag (di solito e' cosi' che si apre altro)
- `serve ...` — la scelta non compare finche' non hai quello che chiede
- `→ gia' visto` — porta a una stanza gia' incontrata piu' in alto (non si
  ripete il ramo)
"""


def carica(percorso):
    with open(os.path.join(RADICE, percorso), encoding="utf-8") as f:
        return json.load(f)


def file_zone():
    fuori = list(ZONE)
    for percorso in sorted(glob.glob(os.path.join(RADICE, "data", "vuoti", "*.json"))):
        rel = os.path.relpath(percorso, RADICE)
        dati = carica(rel)
        titolo = dati.get("nome", os.path.basename(percorso)[:-5].replace("_", " ").title())
        fuori.append((rel, titolo))
    return fuori


def griglia(mappa):
    """Le stanze sulla griglia, una casella per quadratino occupato.

    Una stanza grande occupa piu' caselle (campo "dimensione"): qui compare in
    tutte quelle che occupa, cosi' nel disegno si vede larga davvero. La prima
    casella e' quella che porta il nome, le altre la continuano.
    """
    stanze = mappa.get("stanze", [])
    if not stanze:
        return None
    colonne = righe = 0
    celle = {}
    for s in stanze:
        c, r = s["cella"]
        larghezza, altezza = s.get("dimensione", [1, 1])
        colonne = max(colonne, c + larghezza)
        righe = max(righe, r + altezza)
        for dx in range(larghezza):
            for dy in range(altezza):
                celle[(c + dx, r + dy)] = (s, dx == 0 and dy == 0)
    return celle, colonne, righe


def disegna_griglia(mappa, id_iniziale, nodi):
    esito = griglia(mappa)
    if esito is None:
        return []
    celle, colonne, righe = esito
    # chi porta fuori dalla zona: e' l'uscita
    uscite = set()
    for id_nodo, nodo in nodi.items():
        for scelta in nodo.get("scelte", []):
            if scelta.get("torna_vuoto") or scelta.get("torna_a_mappa"):
                uscite.add(id_nodo)
    # una tabella markdown vuole comunque un'intestazione: qui e' vuota, perche'
    # le colonne della griglia non hanno un nome - sono posizioni
    fuori = ["|" + " |" * colonne, "|" + ":--:|" * colonne]
    for r in range(righe):
        cella_riga = []
        for c in range(colonne):
            voce = celle.get((c, r))
            if voce is None:
                cella_riga.append(" ")
                continue
            s, prima = voce
            if not prima:
                cella_riga.append("↑" if celle.get((c, r - 1), (None,))[0] is s else "←")
                continue
            segno = ""
            if s["id"] == id_iniziale:
                segno = "▶ "
            if s["id"] in uscite:
                segno += "✕ "
            if s.get("tipo") == "segreta":
                segno += "◇ "
            cella_riga.append("%s**%s**" % (segno, s.get("nome", s["id"])))
        fuori.append("| " + " | ".join(cella_riga) + " |")
    return fuori


def note_di(id_nodo, nodo, scelta):
    note = []
    for chiave in ["oggetto", "oggetti"]:
        valore = scelta.get(chiave)
        if valore:
            elenco = valore if isinstance(valore, list) else [valore]
            note.append("+" + ", ".join(elenco))
    if scelta.get("tazo"):
        note.append("+%d Tazo" % scelta["tazo"])
    for chiave, come in [("richiede", "serve l'abilita' %s"), ("richiede_flag", "serve %s"),
                         ("richiede_oggetto", "serve %s"), ("richiede_compagno", "serve %s"),
                         ("richiede_non_flag", "solo se non %s")]:
        if chiave in scelta:
            note.append(come % scelta[chiave])
    if "richiede_oggetti" in scelta:
        note.append("serve " + ", ".join(scelta["richiede_oggetti"]))
    if scelta.get("torna_vuoto"):
        note.append("esce dalla zona")
    return note


def note_stanza(nodo):
    note = []
    if "flag" in nodo:
        note.append("flag %s" % nodo["flag"])
    agguato = nodo.get("agguato")
    if agguato:
        note.append("agguato %d%%%s" % (round(agguato.get("probabilita", 0.3) * 100),
                                        ", ripetibile" if agguato.get("ripetibile") else ""))
    automatico = nodo.get("combattimento_automatico")
    if automatico:
        note.append("scontro! " + ", ".join(automatico.get("nemici", [])))
    if "salva_checkpoint" in nodo:
        note.append("checkpoint")
    return note


def percorso(nodi, id_iniziale):
    """Ripercorre la zona dall'ingresso, in ampiezza limitata: ogni stanza una volta."""
    righe = []
    visti = set()

    def scendi(id_nodo, profondita, etichetta, note_scelta):
        indenti = "  " * profondita
        nodo = nodi.get(id_nodo)
        if nodo is None:
            righe.append("%s%s → %s (NODO MANCANTE)" % (indenti, etichetta, id_nodo))
            return
        coda = note_scelta + note_stanza(nodo)
        if id_nodo in visti:
            righe.append("%s%s → %s [gia' visto]" % (indenti, etichetta, id_nodo))
            return
        visti.add(id_nodo)
        testa = "%s%s%s" % (indenti, etichetta, "" if etichetta == "" else " → ")
        righe.append("%s%s%s" % (testa, id_nodo, ("   (%s)" % "; ".join(coda)) if coda else ""))
        salto = nodo.get("vai_se_flag")
        if salto:
            righe.append("%s  ⟳ con %s diventa %s" % (indenti, salto.get("flag"), salto.get("vai")))
            scendi(str(salto.get("vai")), profondita + 1, "", [])
        if nodo.get("combattimento_automatico"):
            esito = nodo["combattimento_automatico"]
            for chiave, come in [("se_vinci", "vinci"), ("se_perdi", "perdi"), ("se_fuggi", "fuggi")]:
                if esito.get(chiave):
                    scendi(str(esito[chiave]), profondita + 1, come, [])
        for scelta in nodo.get("scelte", []):
            destinazione = scelta.get("vai")
            note = note_di(id_nodo, nodo, scelta)
            if not destinazione:
                righe.append("%s  · %s%s" % (indenti, scelta.get("testo", "…"),
                                             ("   (%s)" % "; ".join(note)) if note else ""))
                continue
            if destinazione == id_nodo:
                righe.append("%s  · %s%s" % (indenti, scelta.get("testo", "…"),
                                             ("   (%s)" % "; ".join(note)) if note else ""))
                continue
            scendi(str(destinazione), profondita + 1, "· " + scelta.get("testo", "…"), note)

    scendi(id_iniziale, 0, "", [])
    return righe


def genera():
    righe = [PREMESSA, ""]
    for percorso_file, titolo in file_zone():
        dati = carica(percorso_file)
        nodi = dati.get("nodi", {})
        if not nodi:
            continue
        id_iniziale = str(dati.get("nodo_iniziale", ""))
        righe.append("---")
        righe.append("")
        righe.append("# %s" % titolo)
        righe.append("")
        righe.append("<sub>`%s` — %d scene</sub>" % (percorso_file, len(nodi)))
        righe.append("")
        mappa = dati.get("mappa_dungeon", {})
        if mappa:
            righe.append("## La griglia")
            righe.append("")
            righe.extend(disegna_griglia(mappa, id_iniziale, nodi))
            righe.append("")
            collegamenti = mappa.get("connessioni", [])
            righe.append("%d stanze sulla mappa, %d collegamenti."
                         % (len(mappa.get("stanze", [])), len(collegamenti)))
            fuori_mappa = [k for k in nodi if k not in {s["id"] for s in mappa.get("stanze", [])}]
            if fuori_mappa:
                righe.append("")
                righe.append("Non sulla mappa (scene di passaggio, scontri scritti, varianti «dopo»): "
                             + ", ".join("`%s`" % k for k in sorted(fuori_mappa)) + ".")
        else:
            righe.append("*Questa zona non ha ancora una `mappa_dungeon`: si gioca solo a scelte.*")
        righe.append("")
        righe.append("## Il percorso")
        righe.append("")
        righe.append("```")
        righe.extend(percorso(nodi, id_iniziale))
        righe.append("```")
        righe.append("")
    return "\n".join(righe)


if __name__ == "__main__":
    destinazione = os.path.join(RADICE, "docs", "mappe.md")
    with open(destinazione, "w", encoding="utf-8") as f:
        f.write(genera())
    print("scritto docs/mappe.md")
