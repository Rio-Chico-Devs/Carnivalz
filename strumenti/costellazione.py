#!/usr/bin/env python3
"""Legge la costellazione disegnata da Bru e ne tira fuori le coordinate dei nodi.

Bru disegna il percorso di crescita come un emblema o una costellazione, e segna
i punti di sviluppo in MAGENTA PURO (#FF00FF). Quel colore in un disegno non
capita mai per caso, quindi qui si possono cercare quei pixel, raggrupparli in
macchie e prendere il centro di ognuna: sono i nodi, con le loro coordinate.

    python3 strumenti/costellazione.py art/percorsi/anonimo.png

Stampa il JSON dei nodi e scrive accanto al disegno una copia numerata, cosi'
Bru vede quale numero e' quale nodo e puo' dire cosa danno senza toccare le
coordinate.

Niente PIL e niente numpy: non ci sono in questo ambiente e non vale la pena
aggiungere una dipendenza per leggere un PNG. zlib e struct bastano.
"""
import json
import struct
import sys
import zlib

MAGENTA = (255, 0, 255)
TOLLERANZA = 40          # quanto puo' sbagliare il colore (antialiasing dei bordi)
MINIMO_PIXEL = 6         # sotto questa dimensione e' sporco, non un nodo


def leggi_png(percorso):
	"""Ritorna (larghezza, altezza, righe) con righe[y][x] = (r, g, b)."""
	dati = open(percorso, "rb").read()
	if dati[:8] != b"\x89PNG\r\n\x1a\n":
		raise SystemExit("%s non e' un PNG" % percorso)
	pos, pezzi, testa = 8, [], None
	while pos < len(dati):
		lunghezza, tipo = struct.unpack(">I4s", dati[pos:pos + 8])
		corpo = dati[pos + 8:pos + 8 + lunghezza]
		if tipo == b"IHDR":
			testa = struct.unpack(">IIBBBBB", corpo)
		elif tipo == b"IDAT":
			pezzi.append(corpo)
		elif tipo == b"IEND":
			break
		pos += 12 + lunghezza
	larghezza, altezza, profondita, colore, _, _, intreccio = testa
	if profondita != 8 or intreccio != 0:
		raise SystemExit("serve un PNG a 8 bit non interlacciato (questo e' %d bit%s)"
				% (profondita, ", interlacciato" if intreccio else ""))
	canali = {0: 1, 2: 3, 3: 1, 4: 2, 6: 4}.get(colore)
	if canali is None or colore == 3:
		raise SystemExit("salva senza tavolozza: serve RGB o RGBA")
	grezzo = zlib.decompress(b"".join(pezzi))

	# I PNG filtrano ogni riga rispetto alla precedente: qui si disfa il filtro.
	# E' l'unico pezzo noioso, ma e' cinque righe di specifica e non cambia mai.
	passo = larghezza * canali
	righe, precedente = [], bytearray(passo)
	for y in range(altezza):
		inizio = y * (passo + 1)
		filtro = grezzo[inizio]
		riga = bytearray(grezzo[inizio + 1:inizio + 1 + passo])
		for i in range(passo):
			a = riga[i - canali] if i >= canali else 0
			b = precedente[i]
			c = precedente[i - canali] if i >= canali else 0
			if filtro == 1:
				riga[i] = (riga[i] + a) & 0xFF
			elif filtro == 2:
				riga[i] = (riga[i] + b) & 0xFF
			elif filtro == 3:
				riga[i] = (riga[i] + (a + b) // 2) & 0xFF
			elif filtro == 4:
				p = a + b - c
				pa, pb, pc = abs(p - a), abs(p - b), abs(p - c)
				vicino = a if (pa <= pb and pa <= pc) else (b if pb <= pc else c)
				riga[i] = (riga[i] + vicino) & 0xFF
		righe.append([tuple(riga[x * canali:x * canali + 3]) for x in range(larghezza)])
		precedente = riga
	return larghezza, altezza, righe


def e_magenta(pixel):
	return (abs(pixel[0] - MAGENTA[0]) <= TOLLERANZA
			and abs(pixel[1] - MAGENTA[1]) <= TOLLERANZA
			and abs(pixel[2] - MAGENTA[2]) <= TOLLERANZA)


def macchie(larghezza, altezza, righe):
	"""Raggruppa i pixel magenta vicini: ogni gruppo e' un nodo."""
	visto = [[False] * larghezza for _ in range(altezza)]
	trovate = []
	for y in range(altezza):
		for x in range(larghezza):
			if visto[y][x] or not e_magenta(righe[y][x]):
				continue
			# riempimento a coda, non ricorsivo: una macchia grossa
			# manderebbe in overflow la ricorsione di Python
			coda, gruppo = [(x, y)], []
			visto[y][x] = True
			while coda:
				cx, cy = coda.pop()
				gruppo.append((cx, cy))
				for dx in (-1, 0, 1):
					for dy in (-1, 0, 1):
						nx, ny = cx + dx, cy + dy
						if 0 <= nx < larghezza and 0 <= ny < altezza \
								and not visto[ny][nx] and e_magenta(righe[ny][nx]):
							visto[ny][nx] = True
							coda.append((nx, ny))
			if len(gruppo) >= MINIMO_PIXEL:
				trovate.append(gruppo)
	return trovate


def main():
	if len(sys.argv) < 2:
		raise SystemExit(__doc__)
	percorso = sys.argv[1]
	larghezza, altezza, righe = leggi_png(percorso)
	gruppi = macchie(larghezza, altezza, righe)
	# in ordine di lettura: dall'alto al basso, da sinistra a destra. Cosi' i
	# numeri che Bru vede sul disegno seguono l'occhio invece dell'ordine in cui
	# il computer li ha incontrati
	centri = []
	for g in gruppi:
		cx = sum(p[0] for p in g) / len(g)
		cy = sum(p[1] for p in g) / len(g)
		centri.append((round(cx), round(cy), len(g)))
	centri.sort(key=lambda c: (c[1] // 60, c[0]))

	nodi = {}
	for i, (x, y, quanti) in enumerate(centri, 1):
		nodi["n%02d" % i] = {
			"x": x, "y": y,
			"_pixel": quanti,
			"da_riempire": {"cosa": "???", "costo": 1, "collega": []},
		}
	uscita = {
		"_nota": ("Coordinate estratte dal disegno, non scritte a mano. Il magenta puro "
				"segna i nodi; questo file dice dove sono. Cosa dia ciascuno lo scrive Bru "
				"in 'da_riempire'."),
		"disegno": percorso,
		"dimensione": [larghezza, altezza],
		"nodi": nodi,
	}
	print(json.dumps(uscita, ensure_ascii=False, indent="\t"))
	print("\n%d nodi trovati in %dx%d" % (len(nodi), larghezza, altezza), file=sys.stderr)


if __name__ == "__main__":
	main()
