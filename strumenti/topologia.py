#!/usr/bin/env python3
"""Misura la FORMA delle mappe di Carnivalz, e scrive docs/topologia.md.

	./strumenti/topologia.py

Non guarda cosa c'e' scritto in una stanza: guarda come le stanze sono
attaccate fra loro. E' l'equivalente di quello che nei giochi da tavolo si
chiama un "diagramma di Melan" - si butta via tutto (le distanze, le direzioni,
i testi) e resta solo il traliccio: chi confina con chi.

PERCHE' SERVE. Una mappa si giudica male leggendola. Otto file di stanze sono
quattromila righe di testo, e nessuno che le legga puo' dire "questa zona e' un
corridoio travestito da labirinto" - si sente giocando, dopo un'ora, quando e'
tardi. Il traliccio invece lo dice in un secondo.

LE MISURE, e cosa vogliono dire. Ognuna risponde a una domanda che qualcuno si
e' gia' posto prima di noi (vedi docs/dedalo.md):

  anelli        Quanti giri chiusi esistono. Zero = un albero, cioe' un
                corridoio con dei vicoli ciechi: vai avanti, torni indietro
                dalla stessa strada. E' la misura di Jaquays.
  scorciatoie   Gli anelli non sono tutti uguali. Un arco fra due stanze
                confinanti e' un anello che non si sente; uno che collega la
                stanza 2 alla stanza 10 e' una scorciatoia vera. Qui si contano
                solo quelli che saltano almeno tre stanze.
  bivi          Quante stanze offrono una scelta VERA - cioe' almeno due strade
                che non siano "torna indietro". Una mappa dove quasi nessuna
                stanza e' un bivio non e' una mappa, e' una fila.
  sostanza      Quante stanze hanno qualcosa dentro: un agguato, un oggetto, un
                tazo, una bandierina, una porta che si apre. Le altre sono
                passaggi: si attraversano e basta.
  cancelli      Le scelte chiuse da una condizione, e - quando si riesce a
                capirlo - quanto dista la chiave dalla serratura. Una serratura
                accanto alla sua chiave e' un dosso, non una porta chiusa.

Una nota su cosa NON dice: niente di tutto questo parla della qualita' di
quello che c'e' scritto dentro le stanze. Una zona puo' avere una topologia
perfetta e leggersi malissimo. Questo strumento misura lo scheletro.
"""

import json
import os
import re
import sys
from collections import Counter, defaultdict, deque

RADICE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CARTELLA_ZONE = os.path.join(RADICE, "data", "vuoti")
USCITA = os.path.join(RADICE, "docs", "topologia.md")

# Le chiavi che spostano il giocatore da qualche parte. Vanno cercate
# RICORSIVAMENTE: una destinazione puo' stare in fondo a una scelta, dentro il
# dizionario "combatti" di quella scelta, dentro l'agguato del nodo, o dentro un
# vai_se_flag. La prima versione di questo conto le cercava solo al primo
# livello, e faceva risultare irraggiungibili undici stanze che invece si
# raggiungono benissimo - dopo un combattimento. Un misuratore che sbaglia in
# questo modo e' peggio che non averlo: manda a cercare un guasto che non c'e'.
DESTINAZIONI = ("vai", "se_vinci", "se_vinci_eroe", "se_perdi", "se_fuggi")

# Le chiavi che rendono una stanza "qualcosa" invece che "un passaggio"
SOSTANZA_SCELTA = ("oggetto", "tazo", "flag", "combatti", "una_tantum",
                   "recluta_temporaneo", "piazza_proiettore", "legame", "stress")
SOSTANZA_NODO = ("agguato", "task", "sblocca_stanze", "salva_checkpoint",
                 "combattimento_automatico")

# "Torna al salone", "Esci", "Risali le scale": una scelta che riporta indietro
# non e' una strada nuova, e contarla come tale gonfia ogni statistica
RITORNO = re.compile(r"^(torna|torni|indietro|risali|riscendi|esci|vattene|vai via)", re.I)

# I nodi in cui si finisce PERDENDO. Le loro connessioni sembrano scorciatoie
# lunghissime - da fondo dungeon ti ritrovi all'ingresso - ma non sono una cosa
# che il giocatore trova: e' una cosa che gli succede.
SCONFITTA = ("cacciata", "espulso", "espulsione", "game_over", "sconfitta", "perdi")


def destinazioni_di(nodo):
	fuori = set()

	def scava(o):
		if isinstance(o, dict):
			for chiave, valore in o.items():
				if chiave in DESTINAZIONI and isinstance(valore, str) and valore:
					fuori.add(valore)
				else:
					scava(valore)
		elif isinstance(o, list):
			for x in o:
				scava(x)

	# la "sequenza" e' testo e basta: dentro non ci sono strade
	scava({k: v for k, v in nodo.items() if k != "sequenza"})
	for stanza in nodo.get("sblocca_stanze", []) or []:
		fuori.add(stanza)
	return fuori


def e_ritorno(scelta):
	return bool(RITORNO.match(str(scelta.get("testo", "")))) \
		or bool(scelta.get("torna_vuoto")) or bool(scelta.get("torna_a_mappa"))


def ha_sostanza(nodo):
	if any(k in nodo for k in SOSTANZA_NODO):
		return True
	for scelta in nodo.get("scelte", []):
		if any(k in scelta for k in SOSTANZA_SCELTA):
			return True
	return False


def e_di_sconfitta(nome):
	return any(pezzo in nome for pezzo in SCONFITTA)


def analizza(percorso):
	dati = json.load(open(percorso, encoding="utf-8"))
	nodi = dati.get("nodi", {})
	inizio = dati.get("nodo_iniziale", "")
	archi = {k: {x for x in destinazioni_di(v) if x in nodi} for k, v in nodi.items()}

	# quanto dista ogni stanza dall'ingresso, contando le porte
	distanza = {inizio: 0} if inizio in nodi else {}
	coda = deque(distanza)
	while coda:
		qui = coda.popleft()
		for la in archi.get(qui, ()):
			if la not in distanza:
				distanza[la] = distanza[qui] + 1
				coda.append(la)

	# il traliccio, senza direzione: A->B e B->A sono la stessa porta.
	#
	# Fuori i cappi su se stessi. Una stanza che rimanda a se stessa esiste
	# davvero in questi dati - "Fruga sotto i cuscini del divano" ti lascia dove
	# sei - ma non e' una porta: e' un'azione. Contarla come anello faceva
	# sembrare la mappa piu' intrecciata di quanto sia, ed e' esattamente la
	# bugia che questo strumento deve evitare.
	lati = set()
	cappi = 0
	for a, verso in archi.items():
		for b in verso:
			if a == b:
				cappi += 1
			else:
				lati.add(tuple(sorted((a, b))))

	vicini = defaultdict(set)
	for a, b in lati:
		vicini[a].add(b)
		vicini[b].add(a)
	visti, pezzi = set(), 0
	for stanza in nodi:
		if stanza in visti:
			continue
		pezzi += 1
		coda = deque([stanza])
		visti.add(stanza)
		while coda:
			qui = coda.popleft()
			for la in vicini.get(qui, ()):
				if la not in visti:
					visti.add(la)
					coda.append(la)
	# numero ciclomatico: quanti giri chiusi indipendenti ci sono
	anelli = len(lati) - len(nodi) + pezzi

	scorciatoie, da_sconfitta = [], 0
	for a, b in lati:
		if a not in distanza or b not in distanza:
			continue
		salto = abs(distanza[a] - distanza[b])
		if salto < 3:
			continue
		if e_di_sconfitta(a) or e_di_sconfitta(b):
			da_sconfitta += 1
		else:
			scorciatoie.append((a, b, salto))

	bivi = Counter()
	scelte_totali = ritorni = 0
	for nodo in nodi.values():
		scelte = nodo.get("scelte", [])
		scelte_totali += len(scelte)
		avanti = [s for s in scelte if not e_ritorno(s)]
		ritorni += len(scelte) - len(avanti)
		bivi[len(avanti)] += 1

	# dove si accende ogni bandierina, per poter dire quanto dista la chiave
	accende = defaultdict(list)

	def cerca_flag(o, dove):
		if isinstance(o, dict):
			for chiave, valore in o.items():
				if chiave in ("flag", "una_tantum") and isinstance(valore, str):
					accende[valore].append(dove)
				else:
					cerca_flag(valore, dove)
		elif isinstance(o, list):
			for x in o:
				cerca_flag(x, dove)

	for nome, nodo in nodi.items():
		cerca_flag(nodo, nome)

	cancelli = []
	for nome, nodo in nodi.items():
		for scelta in nodo.get("scelte", []):
			flag = scelta.get("richiede_flag")
			if not flag:
				continue
			sorgenti = accende.get(flag, [])
			dove_chiave = min((distanza.get(x, 99) for x in sorgenti), default=None)
			cancelli.append({
				"flag": flag,
				"serratura": distanza.get(nome, -1),
				"chiave": dove_chiave if sorgenti else None,
			})

	return {
		"nome": os.path.basename(percorso).replace(".json", ""),
		"nodi": len(nodi), "lati": len(lati), "pezzi": pezzi, "anelli": anelli,
		"cappi": cappi,
		"raggiungibili": len(distanza),
		"profondita": max(distanza.values()) if distanza else 0,
		"scorciatoie": scorciatoie, "sbalzi_da_sconfitta": da_sconfitta,
		"bivi": bivi, "scelte": scelte_totali, "ritorni": ritorni,
		"sostanza": sum(1 for n in nodi.values() if ha_sostanza(n)),
		"agguati": sum(1 for n in nodi.values() if "agguato" in n),
		"cancelli": cancelli,
		"orfani": sorted(k for k in nodi if k not in distanza),
	}


def scrivi(zone):
	r = []
	tot = Counter()
	bivi_tot = Counter()
	for z in zone:
		for k in ("nodi", "lati", "anelli", "scelte", "ritorni", "sostanza", "agguati"):
			tot[k] += z[k]
		tot["scorciatoie"] += len(z["scorciatoie"])
		tot["cappi"] += z["cappi"]
		tot["sbalzi"] += z["sbalzi_da_sconfitta"]
		tot["cancelli"] += len(z["cancelli"])
		bivi_tot.update(z["bivi"])
	senza_scelta = bivi_tot[0] + bivi_tot[1]

	r.append("# Topologia delle mappe (generato, non scrivere qui a mano)\n")
	r.append("Prodotto da `strumenti/topologia.py`. Guarda **come sono attaccate** le stanze, non")
	r.append("cosa c'e' scritto dentro. Le domande che risponde, e da dove vengono, stanno in")
	r.append("`docs/dedalo.md`.\n")
	r.append("- **anelli** — giri chiusi indipendenti. Zero = un albero, cioe' un corridoio con")
	r.append("  vicoli ciechi: si va avanti e si torna dalla stessa strada")
	r.append("- **scorciatoie** — archi che saltano almeno tre stanze. Sono gli anelli che si")
	r.append("  *sentono*. Escluse quelle prodotte da una sconfitta: quelle non le trovi, ti capitano")
	r.append("- **bivi** — stanze che offrono almeno due strade che non siano «torna indietro»")
	r.append("- **sostanza** — stanze con qualcosa dentro. Le altre si attraversano e basta\n")
	r.append("## Il quadro\n")
	r.append("| zona | stanze | porte | anelli | scorciatoie | bivi | con sostanza | agguati | cancelli | profondita' |")
	r.append("|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|")
	for z in zone:
		veri_bivi = sum(v for k, v in z["bivi"].items() if k >= 2)
		r.append("| %s | %d | %d | %d | %d | %d | %d | %d | %d | %d |" % (
			z["nome"], z["nodi"], z["lati"], z["anelli"], len(z["scorciatoie"]),
			veri_bivi, z["sostanza"], z["agguati"], len(z["cancelli"]), z["profondita"]))
	r.append("| **tutte** | **%d** | **%d** | **%d** | **%d** | **%d** | **%d** | **%d** | **%d** | |" % (
		tot["nodi"], tot["lati"], tot["anelli"], tot["scorciatoie"],
		sum(v for k, v in bivi_tot.items() if k >= 2), tot["sostanza"],
		tot["agguati"], tot["cancelli"]))
	r.append("")
	r.append("## Quante scelte offre una stanza\n")
	r.append("Senza contare «torna indietro»: quelle non sono una strada nuova.\n")
	r.append("| scelte vere | stanze | |")
	r.append("|--:|--:|---|")
	for k in sorted(bivi_tot):
		r.append("| %d | %d | %s |" % (k, bivi_tot[k], "█" * bivi_tot[k]))
	r.append("")
	r.append("**%d stanze su %d (%.0f%%) non offrono nessuna scelta**: una strada sola, o nessuna.  "
			% (senza_scelta, tot["nodi"], 100.0 * senza_scelta / max(tot["nodi"], 1)))
	r.append("**%d scelte su %d (%.0f%%) sono «torna indietro».**  "
			% (tot["ritorni"], tot["scelte"], 100.0 * tot["ritorni"] / max(tot["scelte"], 1)))
	r.append("Altre **%d** sono cappi: ti lasciano dove sei (frugare, osservare, raccogliere).\n" % tot["cappi"])
	r.append("## Le scorciatoie vere\n")
	r.append("Archi che saltano almeno tre stanze e che **non** sono l'espulsione dopo una sconfitta.\n")
	r.append("| zona | da | a | salta |")
	r.append("|---|---|---|--:|")
	for z in zone:
		for a, b, salto in sorted(z["scorciatoie"], key=lambda x: -x[2]):
			r.append("| %s | `%s` | `%s` | %d |" % (z["nome"], a, b, salto))
	r.append("")
	r.append("In piu' ci sono **%d** archi lunghi prodotti da una sconfitta, che portano fuori." % tot["sbalzi"])
	r.append("Non contano come scorciatoie: non sono una cosa che trovi, sono una cosa che ti succede.\n")
	r.append("## I cancelli: quanto dista la chiave dalla serratura\n")
	r.append("Una serratura accanto alla sua chiave e' un dosso, non una porta chiusa.")
	r.append("«chiave fuori zona» vuol dire che la bandierina si accende altrove — in un dialogo,")
	r.append("in un incarico, in un evento — e non e' un errore.\n")
	r.append("| zona | condizione | chiave | serratura | distanza |")
	r.append("|---|---|--:|--:|--:|")
	for z in zone:
		for c in z["cancelli"]:
			if c["chiave"] is None or c["chiave"] >= 99:
				r.append("| %s | `%s` | — | %d | chiave fuori zona |" % (z["nome"], c["flag"], c["serratura"]))
			else:
				r.append("| %s | `%s` | %d | %d | %d |" % (
					z["nome"], c["flag"], c["chiave"], c["serratura"],
					abs(c["serratura"] - c["chiave"])))
	r.append("")
	orfani = [(z["nome"], z["orfani"]) for z in zone if z["orfani"]]
	if orfani:
		r.append("## Stanze che non si raggiungono\n")
		for nome, elenco in orfani:
			r.append("- **%s**: %s" % (nome, ", ".join("`%s`" % x for x in elenco)))
		r.append("")
	else:
		r.append("## Stanze che non si raggiungono\n")
		r.append("Nessuna: da ogni ingresso si arriva a ogni stanza della sua zona.\n")
	return "\n".join(r) + "\n"


def main():
	percorsi = sorted(
		os.path.join(CARTELLA_ZONE, f)
		for f in os.listdir(CARTELLA_ZONE) if f.endswith(".json"))
	zone = [analizza(p) for p in percorsi]
	with open(USCITA, "w", encoding="utf-8") as f:
		f.write(scrivi(zone))
	print("scritto %s (%d zone, %d stanze)"
			% (os.path.relpath(USCITA, RADICE), len(zone), sum(z["nodi"] for z in zone)))
	return 0


if __name__ == "__main__":
	sys.exit(main())
