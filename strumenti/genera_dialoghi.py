#!/usr/bin/env python3
# Genera docs/dialoghi_demo.md: tutto il testo che il giocatore puo' leggere
# nella demo, nell'ordine in cui sta nei file, piu' la mappa dei punti dove i
# compagni non hanno ancora niente da dire.
import json, os

# la radice del progetto: questo script sta in strumenti/, il repo e' la
# cartella sopra. Si lancia da dove si vuole: python3 strumenti/genera_dialoghi.py
RADICE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

def carica(percorso):
    with open(os.path.join(RADICE, percorso), encoding="utf-8") as f:
        return json.load(f)

personaggi = {p["id"]: p for p in carica("data/personaggi.json")["personaggi"]}
classi = {c["id"]: c for c in carica("data/classes.json")["classi"]}

def nome_di(id_chi):
    if id_chi in personaggi:
        return personaggi[id_chi].get("nome", id_chi)
    if id_chi in classi:
        return classi[id_chi].get("nome", id_chi)
    return id_chi

def sequenza_di(nodo):
    if "sequenza" in nodo:
        return nodo["sequenza"]
    if "testo" in nodo:
        return [{"tipo": "narrazione", "testo": nodo["testo"]}]
    return []

def pulisci(testo):
    # il markdown spezza il corsivo su un a capo vero: le righe multiple di una
    # stessa narrazione restano una riga sola, separate da <br>
    return "<br>".join(r.strip() for r in str(testo).split("\n") if r.strip() != "") or str(testo)

def riga_messaggio(msg, protagonista="anonimo"):
    tipo = msg.get("tipo", "narrazione")
    testo = pulisci(msg.get("testo", ""))
    extra = ""
    if msg.get("attesa"):
        extra = f"  *(avanza da sola dopo {msg['attesa']}s)*"
    if tipo == "dialogo":
        chi = msg.get("chi", protagonista)
        return f"- **{nome_di(chi)}:** «{testo}»{extra}"
    if tipo == "notifica":
        return f"- `notifica` — {testo}{extra}"
    if tipo == "titolo":
        return f"- `CARTA DEL TITOLO` — **{testo}**{extra}"
    return f"- *{testo}*{extra}"

def blocco_scelte(nodo):
    righe = []
    for s in nodo.get("scelte", []):
        cond = []
        for chiave, etichetta in [
            ("richiede_flag", "se"), ("richiede_non_flag", "se NON"),
            ("richiede", "serve abilità"), ("richiede_oggetto", "serve oggetto"),
            ("richiede_compagno", "serve compagno"), ("richiede_ospite", "serve ospite"),
            ("richiede_legame", "serve legame ≥"),
        ]:
            if chiave in s:
                cond.append(f"{etichetta} `{s[chiave]}`")
        effetti = []
        if "combatti" in s:
            effetti.append("COMBATTIMENTO: " + ", ".join(nome_di(n) for n in s["combatti"]))
        if "vai" in s:
            effetti.append(f"→ `{s['vai']}`")
        if "oggetto" in s:
            effetti.append(f"ottieni `{s['oggetto']}`")
        if "recluta_temporaneo" in s:
            effetti.append(f"recluta `{s['recluta_temporaneo']}`")
        if s.get("torna_vuoto"):
            effetti.append("→ esci dallo squarcio")
        if s.get("torna_a_mappa"):
            effetti.append("→ mappa della zona")
        if s.get("reset"):
            effetti.append("→ fine campagna")
        coda = []
        if cond:
            coda.append("; ".join(cond))
        if effetti:
            coda.append(" · ".join(effetti))
        suffisso = f"  <sub>{' — '.join(coda)}</sub>" if coda else ""
        righe.append(f"  - ▸ «{pulisci(s.get('testo', '…'))}»{suffisso}")
    return righe

def sezione_file(titolo, percorso, note=""):
    dati = carica(percorso)
    fuori = [f"## {titolo}", "", f"`{percorso}`  ·  nodo iniziale: `{dati.get('nodo_iniziale', '?')}`", ""]
    if note:
        fuori += [note, ""]
    for id_nodo, nodo in dati.get("nodi", {}).items():
        fuori.append(f"### `{id_nodo}`")
        etichette = []
        if nodo.get("centro"):
            etichette.append(f"in scena: **{nome_di(nodo['centro'])}** (al centro)")
        else:
            lati = []
            if nodo.get("sinistra"):
                lati.append(nome_di(nodo["sinistra"]))
            if nodo.get("destra"):
                lati.append(nome_di(nodo["destra"]))
            if lati:
                etichette.append("in scena: **" + "**, **".join(lati) + "**")
        if nodo.get("flag"):
            etichette.append(f"alza `{nodo['flag']}`")
        if nodo.get("una_tantum"):
            etichette.append(f"alza `{nodo['una_tantum']}` (una volta)")
        if nodo.get("combattimento_automatico"):
            etichette.append("il combattimento parte da solo")
        if nodo.get("espulsione_automatica"):
            etichette.append("ti sbatte fuori da solo")
        if etichette:
            fuori.append("<sub>" + "  ·  ".join(etichette) + "</sub>")
        fuori.append("")
        for msg in sequenza_di(nodo):
            fuori.append(riga_messaggio(msg))
        if "scena" in nodo:
            scena = nodo["scena"]
            fuori.append("")
            fuori.append("**Tornandoci** (\"Osserva la scena\"):")
            if isinstance(scena, str):
                fuori.append(f"- *{pulisci(scena)}*")
            else:
                for msg in scena:
                    fuori.append(riga_messaggio(msg))
        scelte = blocco_scelte(nodo)
        if scelte:
            fuori.append("")
            fuori.append("**Scelte:**")
            fuori += scelte
        fuori.append("")
    return fuori

righe = []
righe += [
    "# Tutti i dialoghi della demo",
    "",
    "Istantanea generata dai file in `data/`. Ogni voce è nell'ordine in cui il giocatore la",
    "incontra dentro il suo nodo. Legenda:",
    "",
    "- **Nome:** «battuta» — un dialogo, con chi lo dice",
    "- *corsivo* — narrazione (la voce che racconta da fuori, senza targhetta)",
    "- `notifica` — il gioco che ti informa (hai raccolto, hai imparato)",
    "- ▸ «testo» — l'etichetta di una scelta, cioè quello che il giocatore preme",
    "- «Anonimo» è il protagonista: il nome vero lo sceglie il giocatore e viene sostituito a schermo",
    "",
    "I titoletti `come_questo` sono gli id dei nodi: per cambiare un testo si cerca quell'id nel",
    "file indicato e si modifica il campo `testo`.",
    "",
    "---",
    "",
]

righe += sezione_file("Introduzione", "data/events_intro.json",
    "Il monologo che apre una partita nuova. Finita la sequenza il tutorial parte da solo.")
righe += ["---", ""]
righe += sezione_file("Tutorial — il pianeta dei goblin e il quartier generale", "data/events_tutorial.json")
righe += ["---", ""]

vuoti = [
    ("Lo Squarcio Industriale", "data/vuoti/squarcio_industriale.json"),
    ("Meridia", "data/vuoti/meridia.json"),
    ("Cunicoli sotterranei di Jondoh", "data/vuoti/rocca_ossidiana.json"),
    ("Il Teatro del Passato", "data/vuoti/teatro_del_passato.json"),
    ("La Casa Gigante", "data/vuoti/casa_gigante.json"),
    ("Kizako Industries — Ala Dimenticata", "data/vuoti/kizako_ala.json"),
    ("La Fontana", "data/vuoti/fontana.json"),
    ("Qualcosa preme", "data/vuoti/qualcosa_preme.json"),
]
righe += ["# Il Vuoto Ardente — gli squarci", ""]
for titolo, percorso in vuoti:
    righe += sezione_file(titolo, percorso)
    righe += ["---", ""]

righe += sezione_file("La campagna di Jerah (il pianeta al centro)", "data/events.json")
righe += ["---", ""]

# --- chiacchiere coi compagni ---
dial = carica("data/dialoghi.json")
righe += [
    "# Chiacchiere coi compagni (bottone «Dialoga»)",
    "",
    "`data/dialoghi.json`. Funziona così: il bottone **Dialoga** compare in ogni nodo in cui hai",
    "almeno un compagno. Cliccandolo si apre la lista dei presenti; scegliendone uno, il gioco",
    "cerca in `luoghi` una voce **con lo stesso id del nodo in cui ti trovi**. Se non la trova —",
    "o se l'hai già esaurita — il compagno dice «*non ha altro da dirti, qui*».",
    "",
    "Quindi: una battuta esiste solo dove qualcuno l'ha scritta, stanza per stanza.",
    "",
    "## `luoghi` — battute legate a una stanza precisa",
    "",
]
for id_nodo, voce in dial.get("luoghi", {}).items():
    righe.append(f"### `{id_nodo}`")
    marche = []
    if voce.get("una_tantum"):
        marche.append(f"si può sentire una volta sola (`{voce['una_tantum']}`)")
    if voce.get("flag"):
        marche.append(f"alza `{voce['flag']}`")
    if marche:
        righe.append("<sub>" + "  ·  ".join(marche) + "</sub>")
    righe.append("")
    for msg in sequenza_di(voce):
        if msg.get("tipo") == "dialogo" and "chi" not in msg:
            righe.append(f"- **[il compagno con cui stai parlando]:** «{msg.get('testo','')}»")
        elif msg.get("tipo") != "dialogo" and "%s" in msg.get("testo", ""):
            righe.append(f"- *{msg['testo'].replace('%s', '[nome del compagno]')}*")
        else:
            righe.append(riga_messaggio(msg))
    righe.append("")

righe += ["## `conversazioni` — due compagni che parlano tra loro", ""]
for id_nodo, voce in dial.get("conversazioni", {}).items():
    tra = voce.get("tra", [])
    righe.append(f"### `{id_nodo}` — tra {' e '.join(nome_di(x) for x in tra)}")
    righe.append("<sub>compare solo se sono entrambi in squadra; una volta sola</sub>")
    righe.append("")
    for msg in sequenza_di(voce):
        righe.append(riga_messaggio(msg))
    med = voce.get("mediazione", {})
    if med:
        righe.append("")
        righe.append(f"**Puoi intervenire:** *{med.get('testo','')}*")
        for op in med.get("opzioni", []):
            cond = f"  <sub>serve `{op['richiede_oggetto']}`</sub>" if "richiede_oggetto" in op else ""
            righe.append(f"- ▸ «{op.get('testo','')}»{cond}")
            if "battuta" in op:
                righe.append(f"  - **Anonimo:** «{op['battuta']}»")
            if "risposta" in op:
                r = op["risposta"]
                righe.append(f"  - **{nome_di(r.get('chi',''))}:** «{r.get('testo','')}»")
            if op.get("legame"):
                righe.append(f"  - <sub>legame {op['legame']:+d}</sub>")
    righe.append("")

# --- Yhvina, stanza per stanza ---
casa = carica("data/vuoti/casa_gigante.json")
righe += [
    "---",
    "",
    "# Yhvina nella Casa Gigante, stanza per stanza",
    "",
    "Yhvina (id `insonne`) si unisce a te in `camera_da_letto` e resta fino alla fine dello",
    "squarcio: da quel momento il bottone **Dialoga** c'è in ogni stanza, e dentro c'è solo lei.",
    "Sotto, tutte le stanze della Casa Gigante nell'ordine in cui stanno nel file.",
    "",
    "- **battute scritte** = Yhvina parla dentro la scena, da sola, senza che tu prema niente",
    "- **Dialoga** = c'è una voce in `dialoghi.json` con l'id di quella stanza, quindi premendo",
    "  «Dialoga → Yhvina» dice qualcosa",
    "- **muta** = premendo «Dialoga → Yhvina» risponde solo *«Yhvina non ha altro da dirti, qui»*",
    "",
    "| Stanza | In scena | Dialoga | Cosa manca |",
    "|---|---|---|---|",
]
for id_nodo, nodo in casa.get("nodi", {}).items():
    battute = sum(1 for m in sequenza_di(nodo)
                  if m.get("tipo") == "dialogo" and m.get("chi") == "insonne")
    if battute == 0:
        in_scena = "—"
    elif battute == 1:
        in_scena = "1 battuta scritta"
    else:
        in_scena = f"{battute} battute scritte"
    ha_dialoga = id_nodo in dial.get("luoghi", {})
    colonna_dialoga = "sì" if ha_dialoga else "**muta**"
    manca = "" if ha_dialoga else "una voce `\"" + id_nodo + "\"` in `dialoghi.json → luoghi`"
    righe.append(f"| `{id_nodo}` | {in_scena} | {colonna_dialoga} | {manca} |")
righe.append("")
righe += [
    "Per riempirne una, in `data/dialoghi.json` dentro `luoghi`:",
    "",
    "```json",
    '"nome_della_stanza": {',
    '  "una_tantum": "dialogo_yhvina_nome_della_stanza",',
    '  "sequenza": [',
    '    { "tipo": "narrazione", "testo": "%s si ferma un attimo a guardare il soffitto." },',
    '    { "tipo": "dialogo", "chi": "insonne", "testo": "..." }',
    '  ]',
    "}",
    "```",
    "",
    "`%s` viene sostituito col nome del compagno. Un `dialogo` **senza** `chi` è la battuta di chi",
    "hai davanti in quel momento (utile se la stessa scena deve valere per più compagni); con",
    '`"chi": "insonne"` è per forza Yhvina. `una_tantum` la fa sentire una volta sola: senza,',
    "si può risentire ogni volta che si torna nella stanza.",
    "",
]

# --- dove i compagni non hanno niente da dire ---
righe += [
    "---",
    "",
    "# Dove i compagni NON hanno niente da dire",
    "",
    "Ogni riga è una stanza in cui il bottone «Dialoga» c'è ma la risposta è",
    "«*non ha altro da dirti, qui*». Per riempirne una basta aggiungere a `luoghi` in",
    "`data/dialoghi.json` una voce con **quell'id esatto**.",
    "",
    "L'introduzione e il tutorial non compaiono qui: là il protagonista è da solo, quindi il",
    "bottone «Dialoga» non esiste proprio.",
    "",
]
scritte = set(dial.get("luoghi", {}).keys())
for titolo, percorso in vuoti + [("La campagna di Jerah", "data/events.json")]:
    dati = carica(percorso)
    vuote = [n for n in dati.get("nodi", {}) if n not in scritte]
    if not vuote:
        continue
    righe.append(f"## {titolo}")
    righe.append(f"<sub>`{percorso}` — {len(vuote)} stanze/nodi senza battute dei compagni</sub>")
    righe.append("")
    for id_nodo in vuote:
        nodo = dati["nodi"][id_nodo]
        etichetta = ""
        scena = nodo.get("scena", "")
        if isinstance(scena, str) and scena:
            etichetta = scena
        else:
            for msg in sequenza_di(nodo):
                if msg.get("tipo", "narrazione") == "narrazione":
                    etichetta = msg.get("testo", "")
                    break
        if len(etichetta) > 110:
            etichetta = etichetta[:110].rsplit(" ", 1)[0] + "…"
        righe.append(f"- `{id_nodo}` — {etichetta}" if etichetta else f"- `{id_nodo}`")
    righe.append("")

# --- battute in combattimento e studio ---
righe += [
    "---",
    "",
    "# Battute in combattimento e testi di studio",
    "",
    "`data/personaggi.json`. Qui stanno le voci dei nemici: quello che si scopre studiandoli, le",
    "battute delle fasi dei boss e il retro delle carte collezionabili.",
    "",
    "Quando una voce di `studio` non ha una `domanda` scritta, il gioco ne pesca una a caso da",
    "`data/studio.json`: " + ", ".join("«%s»" % d for d in carica("data/studio.json")["domande_generiche"]) + ".",
    "",
]
for id_p, p in personaggi.items():
    blocco = []
    if p.get("descrizione"):
        blocco.append(f"- *Voce del bestiario:* {pulisci(p['descrizione'])}")
    if p.get("descrizione_extra"):
        blocco.append(f"- *Voce del bestiario (dopo averlo studiato):* {pulisci(p['descrizione_extra'])}")
    for domanda in p.get("studio", []):
        testo_domanda = pulisci(domanda.get("domanda", "")) if domanda.get("domanda") else \
                "[una domanda a caso da studio.json]"
        blocco.append(f"- **Studia** ▸ «{testo_domanda}»")
        blocco.append(f"  - **{p.get('nome', id_p)}:** «{pulisci(domanda.get('risposta',''))}»")
    if p.get("testo_studio_esaurito"):
        blocco.append(f"- *Se lo studi ancora:* {pulisci(p['testo_studio_esaurito'])}")
    for chiave, etichetta in [
        ("studio_cedimento", "Studio che lo fa cedere"),
        ("testo_cedimento", "Quando cede"),
        ("avviso_fuga", "Se provi a scappare"),
    ]:
        if p.get(chiave):
            v = p[chiave]
            if isinstance(v, dict):
                if v.get("domanda"):
                    blocco.append(f"- **{etichetta}** ▸ «{pulisci(v['domanda'])}»")
                if v.get("risposta"):
                    blocco.append(f"  - **{p.get('nome', id_p)}:** «{pulisci(v['risposta'])}»")
            else:
                blocco.append(f"- *{etichetta}:* {pulisci(v)}")
    if isinstance(p.get("combustione"), dict) and p["combustione"].get("testo_turno"):
        blocco.append(f"- *Ogni turno che brucia:* {pulisci(p['combustione']['testo_turno'])}")
    if isinstance(p.get("rigenerazione"), dict) and p["rigenerazione"].get("testo"):
        blocco.append(f"- *Quando si rigenera:* {pulisci(p['rigenerazione']['testo'])}")
    for chiave in ("dialogo_soglia_hp", "mossa_soglia_hp", "mossa_disperazione", "frenesia",
                   "crisi_gelosia", "risparmio", "cura_su_morte_alleato", "rabbia_su_morte_alleato",
                   "incontro_scriptato"):
        v = p.get(chiave)
        if isinstance(v, dict):
            for sotto in ("testo", "testo_turno", "annuncio", "frase"):
                if v.get(sotto):
                    blocco.append(f"- *{chiave}:* {pulisci(v[sotto])}")
    for mossa in p.get("mosse", []):
        if isinstance(mossa, dict) and mossa.get("testo"):
            blocco.append(f"- *Mossa «{mossa.get('nome', '?')}»:* {pulisci(mossa['testo'])}")
    for leva in p.get("leve", []):
        if isinstance(leva, dict):
            blocco.append(f"- **Leva** «{pulisci(leva.get('testo', leva.get('nome', '?')))}»")
            if leva.get("risposta"):
                blocco.append(f"  - **{p.get('nome', id_p)}:** «{pulisci(leva['risposta'])}»")
    if isinstance(p.get("carta"), dict) and p["carta"].get("testo"):
        blocco.append(f"- *Retro della carta collezionabile:* {pulisci(p['carta']['testo'])}")
    if not blocco:
        continue
    righe.append(f"### {p.get('nome', id_p)}  <sub>`{id_p}`</sub>")
    righe += blocco
    righe.append("")

with open(os.path.join(RADICE, "docs/dialoghi_demo.md"), "w", encoding="utf-8") as f:
    f.write("\n".join(righe) + "\n")
print("scritto docs/dialoghi_demo.md —", len(righe), "righe")
