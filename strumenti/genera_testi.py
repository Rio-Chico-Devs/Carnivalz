#!/usr/bin/env python3
"""Genera docs/testi_da_correggere.md.

Non e' un documento da leggere: e' un documento da correggere. Ogni singola
cosa che il giocatore puo' leggere - battute, narrazioni, nomi, descrizioni,
scritte dei bottoni, righe del diario di combattimento - compare una volta
sola, con un identificatore stabile e una riga vuota sotto dove scrivere la
versione giusta. Riconsegnato, le correzioni si applicano cercando l'ID.

Si lancia da dove si vuole:  python3 strumenti/genera_testi.py
"""
import json, os, re

RADICE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

def carica(percorso):
    with open(os.path.join(RADICE, percorso), encoding="utf-8") as f:
        return json.load(f)

def leggi(percorso):
    with open(os.path.join(RADICE, percorso), encoding="utf-8") as f:
        return f.read()

personaggi = {p["id"]: p for p in carica("data/personaggi.json")["personaggi"]}
classi = {c["id"]: c for c in carica("data/classes.json")["classi"]}
oggetti = {o["id"]: o for o in carica("data/oggetti.json")["oggetti"]}

def nome_di(id_chi):
    if id_chi in personaggi:
        return personaggi[id_chi].get("nome", id_chi)
    if id_chi in classi:
        return classi[id_chi].get("nome", id_chi)
    return id_chi

righe = []

def titolo(livello, testo):
    righe.append("")
    righe.append("#" * livello + " " + testo)
    righe.append("")

def nota(testo):
    righe.append(testo)
    righe.append("")

def voce(identificatore, contesto, testo):
    """Una cosa che il giocatore legge, con lo spazio per correggerla."""
    if testo is None:
        return
    testo = str(testo)
    if testo.strip() == "":
        return
    corpo = "<br>".join(r.strip() for r in testo.split("\n") if r.strip() != "") or testo
    intestazione = f"**`{identificatore}`**"
    if contesto:
        intestazione += " · " + contesto
    righe.append(intestazione)
    righe.append("> " + corpo)
    righe.append(">")
    righe.append("> →")
    righe.append("")

# ---------------------------------------------------------------- intestazione

righe += [
    "# Carnivalz — tutti i testi del gioco",
    "",
    "Ogni cosa che il giocatore può leggere, una volta sola, con un posto dove scrivere la",
    "versione giusta. **Non è un documento da leggere**: è un documento da riempire e ridarmi",
    "indietro. Ogni frase compare una volta sola, nell'ordine in cui sta nei file del gioco.",
    "",
    "## Come si usa",
    "",
    "Ogni voce è fatta così:",
    "",
    "```",
    "**`ESEMPIO.1`** · Tutorial › inizio › battuta di Anonimo",
    "> Dunque sarebbe questa la mia prima missione autonoma?",
    ">",
    "> →",
    "```",
    "",
    "1. La riga con **`ID`** dice dove sta la frase. **Non toccarla**: è quella che uso per",
    "   ritrovare il testo esatto da cambiare.",
    "2. La riga `>` è il testo com'è adesso. Lascialo com'è.",
    "3. Dopo la freccia `→` scrivi la versione corretta. Se una frase va bene, lascia la",
    "   freccia vuota e passa oltre — riscrivere solo quello che cambia rende il lavoro più",
    "   veloce per tutti e due.",
    "",
    "Cose utili da sapere mentre correggi:",
    "",
    "- `%s` e `%d` sono buchi che il gioco riempie da solo (`%s` un nome o una parola, `%d` un",
    "  numero). Se li sposti va bene, ma devono restare **tutti**, nello stesso ordine.",
    "- `<br>` segna un a capo dentro la stessa frase.",
    "- `[b]grassetto[/b]`, `[i]corsivo[/i]`, `[center]centrato[/center]` sono formattazione:",
    "  puoi tenerla, toglierla o metterla dove serve.",
    "- Per cancellare una frase, scrivi `ELIMINARE` dopo la freccia. Per spezzarla in due",
    "  pagine, scrivi le due parti separate da una riga con `---`.",
    "- Se una frase non ti convince ma non sai come riscriverla, scrivi `?` e una nota: la",
    "  riguardiamo insieme.",
    "",
    "Legenda dei prefissi degli ID:",
    "",
    "| Prefisso | Cosa |",
    "|---|---|",
    "| `UI.` | scritte dell'interfaccia (bottoni, menu, diario di combattimento) |",
    "| `INT.` | l'introduzione |",
    "| `TUT.` | il tutorial |",
    "| `IND.` `MER.` `OSS.` `TEA.` `CASA.` `KIZ.` `FON.` `PRE.` | gli squarci del Vuoto Ardente |",
    "| `JER.` | la campagna di Jerah |",
    "| `COMP.` | chiacchiere coi compagni |",
    "| `CRE.` | creature: descrizioni, studio, carte |",
    "| `CLA.` | personaggi giocabili |",
    "| `OGG.` | oggetti |",
    "| `STA.` | stati (avvelenato, terrore...) |",
    "| `CRES.` | crescita: nomi delle statistiche e abilità passive |",
    "| `APP.` | appunti del Diario |",
    "| `LUO.` | nomi dei luoghi sulle mappe |",
    "| `NEG.` | negozi |",
    "| `PSI.` | psichi |",
    "",
]

# ------------------------------------------------------- 1. scritte a schermo

CLASSI_GODOT = {
    "Label", "Button", "RichTextLabel", "CheckBox", "LineEdit", "PanelContainer",
    "HSlider", "ColorRect", "VBoxContainer", "HBoxContainer", "font", "panel",
    "normal", "hover", "pressed", "disabled", "focus",
}

SCHERMATE = [
    ("Splash.gd", "Loghi d'apertura"),
    ("Menu.gd", "Menu principale"),
    ("Opzioni.gd", "Opzioni"),
    ("Extra.gd", "Extra"),
    ("Collezione.gd", "Collezioni (album, bestiario, compendio)"),
    ("Album.gd", "Album delle carte"),
    ("Bestiario.gd", "Bestiario"),
    ("Compendio.gd", "Compendio degli oggetti"),
    ("Intro.gd", "Introduzione"),
    ("Selezione.gd", "Scelta della squadra"),
    ("Mappa.gd", "Mappa stellare"),
    ("Vuoto.gd", "Il Vuoto (mappa di una regione)"),
    ("MappaZona.gd", "Mappa di una zona"),
    ("Main.gd", "Schermata degli eventi"),
    ("Combattimento.gd", "Combattimento"),
    ("Negozio.gd", "Negozio"),
    ("Pausa.gd", "Pausa, storico e Diario"),
    ("Ritratto.gd", "Ritratti"),
    ("GameState.gd", "Varie"),
]

ETICHETTE_FUNZIONI = {
    "mostra_azioni": "menu delle azioni",
    "_menu_bersagli": "scelta del bersaglio",
    "_menu_studia": "scelta di chi studiare",
    "_menu_abilita": "menu abilità",
    "_menu_oggetti": "menu oggetti",
    "_menu_alleati": "menu alleati",
    "attacca": "quando si attacca",
    "difendi": "quando ci si difende",
    "studia": "quando si studia",
    "usa_oggetto": "quando si usa un oggetto",
    "usa_leva": "quando si mostra un oggetto al nemico",
    "fuggi": "quando si prova a fuggire",
    "provoca": "provocazione",
    "attacco_area": "colpo d'area",
    "risolvi": "fine dello scontro",
    "aggiorna_scheda": "schede dei combattenti",
    "aggiorna_speranza": "barra della speranza",
    "conclusione": "fine di un messaggio",
    "mostra_menu": "menu di pausa",
    "conferma_uscita": "conferma di uscita",
    "mostra_storico": "storico dei dialoghi",
    "mostra_diario": "Diario",
    "sezione_stato": "Diario › Stato",
    "sezione_crescita": "Diario › Cosa ti sta cambiando",
    "etichetta_azione": "Diario › nomi delle azioni tracciate",
    "sezione_passive": "Diario › Abilità passive",
    "sezione_squadra": "Diario › Squadra",
    "sezione_osservazioni": "Diario › Osservazioni",
    "sezione_organizzazione": "Diario › Organizzazione",
    "valutazione_organizzazione": "Diario › giudizio dell'Organizzazione",
    "sezione_appunti": "Diario › Appunti",
    "riga_appunto": "Diario › riga di un appunto",
    "aggiorna_stato": "barra di stato in alto",
    "pickup": "quando raccogli un oggetto",
    "notifiche_passive": "quando sblocchi una passiva",
    "notifiche_task": "quando il Diario si aggiorna",
    "ricostruisci_scelte": "scelte a schermo",
    "_su_compagno": "quando parli con un compagno",
    "_su_dialoga": "menu «Parla con la squadra»",
    "_mostra_mediazione": "quando intervieni in una discussione",
    "_su_start": "menu › Start",
    "_chiedi_nome": "quando scegli il nome",
    "_mostra_slot": "scelta dello slot di salvataggio",
    "_su_salva": "salvataggio",
}

def funzione_a(righe_file, indice):
    for k in range(indice, -1, -1):
        m = re.match(r"func\s+(\w+)", righe_file[k])
        if m:
            return m.group(1)
    return ""

def stringhe_visibili(percorso):
    contenuto = leggi(percorso).split("\n")
    trovate = []
    for n, l in enumerate(contenuto):
        spoglia = l.strip()
        if spoglia.startswith("#"):
            continue
        if "push_error" in l or "push_warning" in l or "print(" in l:
            continue
        contesto_ok = any(k in l for k in (
            ".text", "scrivi(", "bottone", "Bottone", '"testo"', "voce_diario",
            "intestazione(", "titolo_sezione(", "cursore(", "costruisci_prompt",
            "notifica", "return \"",
        ))
        if not contesto_ok:
            continue
        for m in re.finditer(r'"((?:[^"\\]|\\.)*)"', l):
            t = m.group(1)
            if t in CLASSI_GODOT:
                continue
            if t.startswith("res://") or t.startswith("user://"):
                continue
            if re.fullmatch(r"[a-z_0-9]*", t) or re.fullmatch(r"[a-z_]+/[a-z_]+", t):
                continue
            if not re.search(r"[ àèéìòùA-Z]", t):
                continue
            if not re.search(r"[A-Za-zÀ-ÿ]", t):
                continue  # solo simboli (frecce, triangolini): non e' testo da correggere
            trovate.append((funzione_a(contenuto, n), t.replace('\\"', '"').replace("\\n", "\n")))
    return trovate

titolo(1, "1. Scritte dell'interfaccia")
nota("Tutto quello che il gioco scrive di suo: bottoni, menu, notifiche, righe del diario di\n"
     "combattimento. Non è mai passato sotto i tuoi occhi finora.")

numero_schermata = 0
for file_script, nome_schermata in SCHERMATE:
    percorso = "scripts/" + file_script
    if not os.path.exists(os.path.join(RADICE, percorso)):
        continue
    trovate = stringhe_visibili(percorso)
    if not trovate:
        continue
    numero_schermata += 1
    titolo(2, f"1.{numero_schermata} {nome_schermata}")
    nota(f"<sub>`{percorso}`</sub>")
    sigla = file_script.replace(".gd", "")
    visti = set()
    contatore = 0
    for funzione, testo in trovate:
        if testo in visti:
            continue
        visti.add(testo)
        contatore += 1
        etichetta = ETICHETTE_FUNZIONI.get(funzione, "")
        if not etichetta and funzione not in ("_ready", ""):
            etichetta = funzione
        voce(f"UI.{sigla}.{contatore:03d}", etichetta, testo)

# ------------------------------------------------------------- 2. la storia

def sigla_messaggio(msg, protagonista="anonimo"):
    tipo = msg.get("tipo", "narrazione")
    if tipo == "dialogo":
        return "battuta di " + nome_di(msg.get("chi", protagonista))
    if tipo == "notifica":
        return "notifica"
    if tipo == "titolo":
        return "carta del titolo"
    return "narrazione"

def sequenza_di(nodo):
    if "sequenza" in nodo:
        return nodo["sequenza"]
    if "testo" in nodo:
        return [{"tipo": "narrazione", "testo": nodo["testo"]}]
    return []

def sezione_eventi(sigla, nome_umano, percorso):
    dati = carica(percorso)
    titolo(2, nome_umano)
    nota(f"<sub>`{percorso}`</sub>")
    for id_nodo, nodo in dati.get("nodi", {}).items():
        titolo(3, f"{nome_umano} › `{id_nodo}`")
        for i, msg in enumerate(sequenza_di(nodo), 1):
            voce(f"{sigla}.{id_nodo}.{i}", sigla_messaggio(msg), msg.get("testo", ""))
        scena = nodo.get("scena")
        if isinstance(scena, str):
            voce(f"{sigla}.{id_nodo}.scena", "quando ci torni («Osserva la scena»)", scena)
        elif isinstance(scena, list):
            for i, msg in enumerate(scena, 1):
                voce(f"{sigla}.{id_nodo}.scena{i}",
                     "quando ci torni — " + sigla_messaggio(msg), msg.get("testo", ""))
        for i, s in enumerate(nodo.get("scelte", []), 1):
            dettagli = []
            if "combatti" in s:
                dettagli.append("porta a un combattimento")
            if "oggetto" in s:
                dettagli.append("fa raccogliere " + str(oggetti.get(s["oggetto"], {}).get("nome", s["oggetto"])))
            if s.get("torna_vuoto"):
                dettagli.append("esce dallo squarcio")
            coda = " (" + ", ".join(dettagli) + ")" if dettagli else ""
            voce(f"{sigla}.{id_nodo}.scelta{i}", "bottone di scelta" + coda, s.get("testo", ""))

titolo(1, "2. La storia")

sezione_eventi("INT", "Introduzione", "data/events_intro.json")
sezione_eventi("TUT", "Tutorial", "data/events_tutorial.json")
for sigla, nome_umano, percorso in [
    ("IND", "Lo Squarcio Industriale", "data/vuoti/squarcio_industriale.json"),
    ("MER", "Meridia", "data/vuoti/meridia.json"),
    ("OSS", "Cunicoli sotterranei di Jondoh", "data/vuoti/rocca_ossidiana.json"),
    ("TEA", "Il Teatro del Passato", "data/vuoti/teatro_del_passato.json"),
    ("CASA", "La Casa Gigante", "data/vuoti/casa_gigante.json"),
    ("KIZ", "Kizako Industries — Ala Dimenticata", "data/vuoti/kizako_ala.json"),
    ("FON", "La Fontana", "data/vuoti/fontana.json"),
    ("PRE", "Qualcosa preme", "data/vuoti/qualcosa_preme.json"),
    ("JER", "La campagna di Jerah", "data/events.json"),
]:
    sezione_eventi(sigla, nome_umano, percorso)

# ------------------------------------------------- 3. chiacchiere coi compagni

dial = carica("data/dialoghi.json")
titolo(1, "3. Chiacchiere coi compagni")
nota("<sub>`data/dialoghi.json`</sub>\n\n"
     "Quello che i compagni dicono premendo «Parla con la squadra». Esiste solo dove qualcuno\n"
     "l'ha scritto, stanza per stanza: l'elenco delle stanze ancora mute è in appendice, in\n"
     "fondo a questo documento.")
for id_nodo, v in dial.get("luoghi", {}).items():
    titolo(3, f"Nella stanza `{id_nodo}`")
    for i, msg in enumerate(sequenza_di(v), 1):
        etichetta = sigla_messaggio(msg)
        if msg.get("tipo") == "dialogo" and "chi" not in msg:
            etichetta = "battuta del compagno con cui stai parlando"
        voce(f"COMP.{id_nodo}.{i}", etichetta, msg.get("testo", ""))
for id_nodo, v in dial.get("conversazioni", {}).items():
    tra = " e ".join(nome_di(x) for x in v.get("tra", []))
    titolo(3, f"Discussione in `{id_nodo}` — tra {tra}")
    for i, msg in enumerate(sequenza_di(v), 1):
        voce(f"COMP.conv.{id_nodo}.{i}", sigla_messaggio(msg), msg.get("testo", ""))
    med = v.get("mediazione", {})
    if med:
        voce(f"COMP.conv.{id_nodo}.med", "invito a intervenire", med.get("testo", ""))
        for i, op in enumerate(med.get("opzioni", []), 1):
            voce(f"COMP.conv.{id_nodo}.med{i}.scelta", "bottone di scelta", op.get("testo", ""))
            voce(f"COMP.conv.{id_nodo}.med{i}.battuta", "cosa dice Anonimo", op.get("battuta"))
            r = op.get("risposta", {})
            if r:
                voce(f"COMP.conv.{id_nodo}.med{i}.risposta",
                     "risposta di " + nome_di(r.get("chi", "")), r.get("testo", ""))

# ------------------------------------------------------------- 4. le creature

titolo(1, "4. Le creature")
nota("<sub>`data/personaggi.json`</sub>\n\n"
     "Voci del bestiario, risposte quando le studi, battute delle fasi dei boss, retro delle\n"
     "carte collezionabili.")
for id_p, p in personaggi.items():
    blocco_iniziale = len(righe)
    titolo(3, f"{p.get('nome', id_p)}  <sub>`{id_p}`</sub>")
    voce(f"CRE.{id_p}.nome", "nome a schermo", p.get("nome"))
    voce(f"CRE.{id_p}.nome_breve", "nome corto (schede in combattimento)", p.get("nome_breve"))
    voce(f"CRE.{id_p}.descrizione", "voce del bestiario", p.get("descrizione"))
    voce(f"CRE.{id_p}.descrizione_extra", "voce del bestiario, dopo averla studiata", p.get("descrizione_extra"))
    for i, d in enumerate(p.get("studio", []), 1):
        voce(f"CRE.{id_p}.studio{i}.domanda",
             "Studia › domanda (vuota = ne pesca una a caso dalle generiche)", d.get("domanda"))
        voce(f"CRE.{id_p}.studio{i}.risposta", "Studia › cosa risponde", d.get("risposta"))
    voce(f"CRE.{id_p}.studio_esaurito", "Studia › quando non ha più niente da dire",
         p.get("testo_studio_esaurito"))
    sc = p.get("studio_cedimento", {})
    if isinstance(sc, dict):
        sc = [sc]
    for i, s_ced in enumerate(sc or [], 1):
        if not isinstance(s_ced, dict):
            continue
        voce(f"CRE.{id_p}.cedimento{i}.domanda", "Studia › la domanda che la fa cedere", s_ced.get("domanda"))
        voce(f"CRE.{id_p}.cedimento{i}.risposta", "Studia › cosa risponde cedendo", s_ced.get("risposta"))
    voce(f"CRE.{id_p}.testo_cedimento", "quando cede", p.get("testo_cedimento"))
    voce(f"CRE.{id_p}.avviso_fuga", "se provi a scappare", p.get("avviso_fuga"))
    for chiave, etichetta in [
        ("combustione", "ogni turno che brucia"),
        ("rigenerazione", "quando si rigenera"),
        ("dialogo_soglia_hp", "quando scende sotto una soglia di vita"),
        ("mossa_soglia_hp", "mossa sotto soglia"),
        ("mossa_disperazione", "mossa della disperazione"),
        ("frenesia", "frenesia"),
        ("crisi_gelosia", "crisi di gelosia"),
        ("risparmio", "quando lo risparmi"),
        ("cura_su_morte_alleato", "quando muore un suo alleato"),
        ("rabbia_su_morte_alleato", "rabbia per un alleato caduto"),
        ("incontro_scriptato", "incontro preparato"),
        ("leva_obbligatoria_testo", "leva obbligatoria"),
    ]:
        v = p.get(chiave)
        if not isinstance(v, dict):
            continue
        for sotto in ("testo", "testo_turno", "annuncio", "frase", "testo_sblocco_bersaglio", "testo_fermo"):
            voce(f"CRE.{id_p}.{chiave}.{sotto}", etichetta, v.get(sotto))
    for i, mossa in enumerate(p.get("mosse", []), 1):
        if isinstance(mossa, dict):
            voce(f"CRE.{id_p}.mossa{i}.nome", "nome di una mossa", mossa.get("nome"))
            voce(f"CRE.{id_p}.mossa{i}.testo", "cosa si legge quando la usa", mossa.get("testo"))
            voce(f"CRE.{id_p}.mossa{i}.annuncio", "annuncio un turno prima", mossa.get("annuncio"))
    for i, leva in enumerate(p.get("leve", []), 1):
        if isinstance(leva, dict):
            voce(f"CRE.{id_p}.leva{i}.testo", "quando le mostri l'oggetto giusto", leva.get("testo"))
            voce(f"CRE.{id_p}.leva{i}.risposta", "cosa risponde", leva.get("risposta"))
            voce(f"CRE.{id_p}.leva{i}.testo_fermo", "se la mostri di nuovo", leva.get("testo_fermo"))
    # scontro guidato passo per passo (l'allenamento con Veronica)
    for i, passo in enumerate(p.get("tutorial_combattimento", {}).get("passi", []), 1):
        azione = str(passo.get("azione", "?")).upper()
        for quando, etichetta in [("prima", "prima che tu agisca"), ("dopo", "dopo che hai agito")]:
            for j, msg in enumerate(passo.get(quando, []), 1):
                voce(f"CRE.{id_p}.allenamento{i}.{quando}{j}",
                     f"allenamento, passo {i} ({azione}) — {etichetta}, " + sigla_messaggio(msg),
                     msg.get("testo", ""))
    for i, msg in enumerate(p.get("tutorial_combattimento", {}).get("finale", []), 1):
        voce(f"CRE.{id_p}.allenamento_finale{i}",
             "allenamento, la scena che lo chiude — " + sigla_messaggio(msg), msg.get("testo", ""))
    carta = p.get("carta", {})
    if isinstance(carta, dict):
        voce(f"CRE.{id_p}.carta.nome", "nome sulla carta collezionabile", carta.get("nome"))
        voce(f"CRE.{id_p}.carta.testo", "retro della carta collezionabile", carta.get("testo"))
    if len(righe) - blocco_iniziale <= 4:   # solo il titolo: niente da correggere
        del righe[blocco_iniziale:]

# ------------------------------------------------- 5. personaggi giocabili

titolo(1, "5. I personaggi giocabili")
nota("<sub>`data/classes.json`</sub>")
for id_c, c in classi.items():
    titolo(3, f"{c.get('nome', id_c)}  <sub>`{id_c}`</sub>")
    voce(f"CLA.{id_c}.nome", "nome a schermo", c.get("nome"))
    voce(f"CLA.{id_c}.descrizione", "descrizione nella scelta della squadra", c.get("descrizione"))
    voce(f"CLA.{id_c}.frase", "frase di presentazione", c.get("frase"))

# ------------------------------------------------------------- 6. oggetti

titolo(1, "6. Gli oggetti")
nota("<sub>`data/oggetti.json`</sub>")
for id_o, o in oggetti.items():
    titolo(3, f"{o.get('nome', id_o)}  <sub>`{id_o}`</sub>")
    voce(f"OGG.{id_o}.nome", "nome nella sacca e nei negozi", o.get("nome"))
    voce(f"OGG.{id_o}.descrizione", "descrizione (per gli oggetti chiave si legge raccogliendoli)",
         o.get("descrizione"))

# --------------------------------------------------------------- 7. il resto

stati = carica("data/stati.json").get("stati", {})
titolo(1, "7. Gli stati")
nota("<sub>`data/stati.json`</sub> — avvelenato, terrore, e compagnia.")
for id_s, s in stati.items():
    voce(f"STA.{id_s}.nome", "nome dello stato", s.get("nome"))
    voce(f"STA.{id_s}.testo_applicato", "quando colpisce qualcuno", s.get("testo_applicato"))
    voce(f"STA.{id_s}.testo_turno", "a ogni turno che dura", s.get("testo_turno"))
    voce(f"STA.{id_s}.testo_bloccato", "quando impedisce di agire", s.get("testo_bloccato"))
    voce(f"STA.{id_s}.testo_finito", "quando passa", s.get("testo_finito"))
    voce(f"STA.{id_s}.testo_immune", "quando non attecchisce", s.get("testo_immune"))

crescita = carica("data/crescita.json")
titolo(1, "8. Crescita: statistiche e abilità passive")
nota("<sub>`data/crescita.json`</sub> — i nomi che si leggono nel Diario.")
for id_stat, info in crescita.get("stat", {}).items():
    voce(f"CRES.stat.{id_stat}", "nome di una statistica", info.get("nome"))
    voce(f"CRES.stat.{id_stat}.desc", "descrizione della statistica", info.get("descrizione"))
for gruppo in ("passive_livello", "passive_soglia", "passive_rare"):
    for p in crescita.get(gruppo, []):
        voce(f"CRES.{p.get('id','?')}.nome", "nome di un'abilità passiva", p.get("nome"))
        voce(f"CRES.{p.get('id','?')}.desc", "cosa fa l'abilità passiva", p.get("descrizione"))

task = carica("data/task.json").get("task", [])
titolo(1, "9. Appunti del Diario")
nota("<sub>`data/task.json`</sub> — i pensieri del protagonista su dove andare.")
for t in task:
    voce(f"APP.{t['id']}.titolo", "titolo dell'appunto", t.get("titolo"))
    voce(f"APP.{t['id']}.testo", "il pensiero per esteso", t.get("testo"))

mappa = carica("data/mappa.json")
titolo(1, "10. Nomi dei luoghi")
nota("<sub>`data/mappa.json`</sub> — quello che si legge sulla mappa stellare e nel Vuoto.")
for punto in mappa.get("punti", []):
    voce(f"LUO.{punto['id']}.nome", "nome sulla mappa stellare", punto.get("nome"))
    voce(f"LUO.{punto['id']}.tema", "sottotitolo del mondo", punto.get("tema"))
    for v in punto.get("vuoti", []):
        voce(f"LUO.{v['id']}.nome", "nome di uno squarcio", v.get("nome"))
for percorso, sigla in [
    ("data/events_tutorial.json", "TUT"),
    ("data/vuoti/rocca_ossidiana.json", "OSS"),
    ("data/vuoti/casa_gigante.json", "CASA"),
    ("data/vuoti/squarcio_industriale.json", "IND"),
    ("data/vuoti/meridia.json", "MER"),
    ("data/vuoti/teatro_del_passato.json", "TEA"),
    ("data/vuoti/kizako_ala.json", "KIZ"),
    ("data/vuoti/fontana.json", "FON"),
]:
    dati = carica(percorso)
    for stanza in dati.get("mappa_dungeon", {}).get("stanze", []):
        voce(f"LUO.{sigla}.{stanza['id']}", "nome di una stanza sulla mappa della zona",
             stanza.get("nome"))

negozi = carica("data/negozi.json").get("negozi", [])
titolo(1, "11. Negozi")
nota("<sub>`data/negozi.json`</sub>")
for n in negozi:
    voce(f"NEG.{n['id']}.nome", "nome del negozio", n.get("nome"))
    voce(f"NEG.{n['id']}.saluto", "cosa dice entrando", n.get("saluto"))
    voce(f"NEG.{n['id']}.descrizione", "descrizione", n.get("descrizione"))

psichi = carica("data/psiche.json").get("psichi", {})
titolo(1, "12. Psichi")
nota("<sub>`data/psiche.json`</sub> — come reagisce un personaggio quando cade un compagno.")
for id_p, p in psichi.items():
    voce(f"PSI.{id_p}.nome", "nome della psiche", p.get("nome"))
    voce(f"PSI.{id_p}.descrizione", "descrizione", p.get("descrizione"))
    voce(f"PSI.{id_p}.testo", "cosa si legge quando scatta", p.get("testo"))

studio = carica("data/studio.json").get("domande_generiche", [])
titolo(1, "13. Domande generiche di Studia")
nota("<sub>`data/studio.json`</sub> — usate quando una creatura non ha una domanda sua.")
for i, d in enumerate(studio, 1):
    voce(f"STU.generica{i}", "domanda generica", d)

# ------------------------------------------------- appendice: cosa manca ancora

titolo(1, "Appendice — dove manca del testo da scrivere")
nota("Non ci sono frasi da correggere qui: ci sono buchi da riempire. Il bottone «Parla con la\n"
     "squadra» compare in ogni stanza in cui hai un compagno, ma una battuta esiste solo dove\n"
     "qualcuno l'ha scritta: altrove il compagno risponde «*non ha altro da dirti, qui*».")

VUOTI_APPENDICE = [
    ("La Casa Gigante", "data/vuoti/casa_gigante.json"),
    ("Cunicoli sotterranei di Jondoh", "data/vuoti/rocca_ossidiana.json"),
    ("Lo Squarcio Industriale", "data/vuoti/squarcio_industriale.json"),
    ("Meridia", "data/vuoti/meridia.json"),
    ("Il Teatro del Passato", "data/vuoti/teatro_del_passato.json"),
    ("Kizako Industries — Ala Dimenticata", "data/vuoti/kizako_ala.json"),
    ("La Fontana", "data/vuoti/fontana.json"),
    ("La campagna di Jerah", "data/events.json"),
]
scritte = set(dial.get("luoghi", {}).keys())

titolo(2, "Yhvina nella Casa Gigante, stanza per stanza")
nota("Yhvina (`insonne`) si unisce a te in `camera_da_letto` e resta fino alla fine dello\n"
     "squarcio: da lì in poi il bottone «Parla con la squadra» c'è ovunque, e dentro c'è solo lei.")
righe.append("| Stanza | Parla da sola nella scena | Premendo «Parla con la squadra» |")
righe.append("|---|---|---|")
casa = carica("data/vuoti/casa_gigante.json")
for id_nodo, nodo in casa.get("nodi", {}).items():
    quante = sum(1 for m in sequenza_di(nodo)
                 if m.get("tipo") == "dialogo" and m.get("chi") == "insonne")
    in_scena = "—" if quante == 0 else ("1 battuta" if quante == 1 else f"{quante} battute")
    risposta = "dice qualcosa" if id_nodo in scritte else "**muta**"
    righe.append(f"| `{id_nodo}` | {in_scena} | {risposta} |")
righe.append("")

titolo(2, "Tutte le stanze dove i compagni non hanno niente da dire")
nota("Per riempirne una, in `data/dialoghi.json` dentro `luoghi` si aggiunge una voce con\n"
     "**quell'id esatto**:\n\n"
     "```json\n"
     '"nome_della_stanza": {\n'
     '  "una_tantum": "dialogo_yhvina_nome_della_stanza",\n'
     '  "sequenza": [\n'
     '    { "tipo": "narrazione", "testo": "%s si ferma un attimo a guardare il soffitto." },\n'
     '    { "tipo": "dialogo", "chi": "insonne", "testo": "..." }\n'
     "  ]\n"
     "}\n"
     "```\n\n"
     "`%s` diventa il nome del compagno. Un `dialogo` senza `chi` è la battuta di chi hai davanti\n"
     "in quel momento, così la stessa scena vale per qualunque compagno. `una_tantum` la fa\n"
     "sentire una volta sola. L'introduzione e il tutorial non compaiono qui: là sei da solo,\n"
     "quindi il bottone non esiste proprio.")
for nome_umano, percorso in VUOTI_APPENDICE:
    dati = carica(percorso)
    mute = [n for n in dati.get("nodi", {}) if n not in scritte]
    if not mute:
        continue
    titolo(3, f"{nome_umano} — {len(mute)} stanze mute")
    for id_nodo in mute:
        nodo = dati["nodi"][id_nodo]
        etichetta = nodo.get("scena", "") if isinstance(nodo.get("scena"), str) else ""
        if not etichetta:
            for msg in sequenza_di(nodo):
                if msg.get("tipo", "narrazione") == "narrazione":
                    etichetta = msg.get("testo", "")
                    break
        etichetta = " ".join(etichetta.split())
        if len(etichetta) > 100:
            etichetta = etichetta[:100].rsplit(" ", 1)[0] + "…"
        righe.append(f"- `{id_nodo}` — {etichetta}" if etichetta else f"- `{id_nodo}`")
    righe.append("")

uscita = os.path.join(RADICE, "docs/testi_da_correggere.md")
with open(uscita, "w", encoding="utf-8") as f:
    f.write("\n".join(righe).rstrip() + "\n")

quante = sum(1 for r in righe if r.startswith("**`"))
print(f"scritto docs/testi_da_correggere.md — {quante} voci correggibili, {len(righe)} righe")
