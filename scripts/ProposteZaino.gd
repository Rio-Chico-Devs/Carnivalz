class_name ProposteZaino
extends RefCounted

# LE PROPOSTE DELLO ZAINO, da far scegliere a Bru (9 ottobre: «ok molto
# meglio lo zaino, vedi se puoi ancora fare meglio mandami altri esempi
# altrimenti approviamo questo»). PROVVISORIO: quando Bru sceglie, la proposta
# scelta entra in Zaino.gd e RigaZaino.gd e questo file se ne va.
#
# Sono quattro modi di disegnare la stessa cosa - gli stessi dati, gli stessi
# tasti, le stesse prove:
#
#   cabinato   com'e' oggi: la lista nello schermo di un cabinato, l'oggetto
#              grande sulla fascia nera, la scheda nell'altro schermo
#   fasce      la lista sta sull'arancio, una fascia nera storta per riga come
#              le voci della pausa; quella scelta esce dalla fila, chiara, con
#              la sfoglia nera sotto. La piu' «manifesto»
#   taccuino   la lista e' un foglio chiaro scritto in nero, diviso in sezioni
#              per quello che fanno gli oggetti (VITA, AURA, STRESS...), e la
#              riga scelta passata con l'evidenziatore arancio. La piu' ordinata
#   vetrina    la lista stretta, solo i nomi; l'oggetto scelto enorme al centro
#              col suo nome: per quando arriveranno i disegni di Bru, che
#              diventano la cosa piu' grande a schermo
#
# Nello zaino un tasto in alto (PROPOSTA 1/4) gira fra le quattro.

const PROPOSTE := ["cabinato", "fasce", "taccuino", "vetrina"]
const NOMI := {"cabinato": "CABINATO", "fasce": "FASCE", "taccuino": "TACCUINO", "vetrina": "VETRINA GRANDE"}

static var scelta := "cabinato"


static func gira() -> void:
	scelta = PROPOSTE[posmod(PROPOSTE.find(scelta) + 1, PROPOSTE.size())]


static func etichetta() -> String:
	return "PROPOSTA %d/%d" % [PROPOSTE.find(scelta) + 1, PROPOSTE.size()]


static func misure(quale: String) -> Dictionary:
	# dove sta ogni cosa, proposta per proposta. "elenco" e' lo spazio della
	# lista (lo schermo, il foglio, o solo l'arancio), "riga" la prima riga
	var m := {
		"elenco": SchedaZaino.SCHERMO_ELENCO,
		"riga": Rect2(SchedaZaino.PRIMA_RIGA, Vector2(SchedaZaino.LARGO_RIGA, RigaZaino.ALTO)),
		"passo": SchedaZaino.PASSO_RIGA,
		"visibili": SchedaZaino.VISIBILI,
		"banda": SchedaZaino.BANDA,
		"immagine": SchedaZaino.IMMAGINE,
		"lato_sagoma": 210.0,
		"quanti": Rect2(800, 80, 180, 76),
		"nome_sulla_fascia": Rect2(),
		"y_riquadri": SchedaZaino.Y_RIQUADRI,
		"su_carta": false,
		"gruppi": false,
	}
	match quale:
		"fasce":
			m["elenco"] = Rect2(18, 70, 560, 648)
			m["riga"] = Rect2(48, 142, 500, 50)
			m["passo"] = 58.0
			m["su_carta"] = true
		"taccuino":
			m["elenco"] = Rect2(22, 74, 632, 636)
			m["riga"] = Rect2(46, 142, 584, 48)
			m["passo"] = 52.0
			m["visibili"] = 10
			m["su_carta"] = true
			m["gruppi"] = true
		"vetrina":
			m["elenco"] = Rect2(18, 70, 424, 648)
			m["riga"] = Rect2(40, 142, 368, 40)
			m["passo"] = 44.0
			m["visibili"] = 12
			m["banda"] = [Vector2(640, 62), Vector2(1010, 62), Vector2(830, 720), Vector2(460, 720)]
			m["immagine"] = Rect2(500, 120, 450, 370)
			m["lato_sagoma"] = 300.0
			m["quanti"] = Rect2(500, 590, 450, 44)
			m["nome_sulla_fascia"] = Rect2(470, 512, 500, 64)
			m["y_riquadri"] = 112.0
	return m


# --- i fondi -------------------------------------------------------------------

static func fondo(tela: CanvasItem, quale: String, m: Dictionary) -> void:
	var banda: Array = m["banda"]
	var striscia := PackedVector2Array()
	for p: Vector2 in [banda[0], banda[0] + Vector2(-5, 0), banda[3] + Vector2(-5, 0), banda[3]]:
		striscia.append(p - Vector2(14, 0))
	Manifesto.poligono(tela, striscia, Stile.colore("bordo_acceso"))
	Manifesto.poligono(tela, PackedVector2Array(banda), Stile.colore("bordo"))
	Manifesto.disegna_schermo(tela, SchedaZaino.SCHERMO_DETTAGLIO)
	match quale:
		"cabinato", "vetrina":
			Manifesto.disegna_schermo(tela, m["elenco"])
		"taccuino":
			Manifesto.carta(tela, m["elenco"], Stile.colore("box_fondo"), 5.0, true, Vector2(0.15, 0.95))
		"fasce":
			# niente schermo: le fasce stanno sull'arancio. Solo un filo nero
			# sotto il conto dei posti, come una riga di titolo
			tela.draw_rect(Rect2(48, 128, 500, 3), Stile.colore("bordo"))


# --- le righe ------------------------------------------------------------------

static func fondo_della_riga(r: RigaZaino) -> void:
	match r.stile:
		"fasce": fascia(r)
		"taccuino": evidenziatore(r)


static func fascia(r: RigaZaino) -> void:
	# una fascia storta come le voci della pausa: nera, chiara se scelta, con
	# la sfoglia nera sotto (arancio sull'arancio della pagina non si vedeva)
	var forma := sagoma_della_fascia(r)
	if r.scelta:
		var sfoglia := forma.duplicate()
		for i in sfoglia.size():
			sfoglia[i] += Vector2(6, 5)
		Manifesto.poligono(r, sfoglia, Stile.colore("bordo"))
	var tinta := Stile.colore("bordo_acceso") if r.scelta \
			else Stile.colore("bordo").lerp(Stile.colore("pannello_chiaro"), clampf(r.accesa.valore, 0.0, 1.0))
	Manifesto.poligono(r, forma, tinta)


static func sagoma_della_fascia(r: RigaZaino) -> PackedVector2Array:
	var storto := r.size.y * Manifesto.INCLINA
	return PackedVector2Array([Vector2(storto, 0), Vector2(r.size.x, 0), Vector2(r.size.x - storto, r.size.y),
			Vector2(0, r.size.y)])


static func evidenziatore(r: RigaZaino) -> void:
	# sul foglio: una riga di matita sotto ogni voce; quella scelta passata con
	# l'evidenziatore, storto come una passata vera
	var alto := r.size.y
	if r.scelta:
		var storto := alto * Manifesto.INCLINA * 0.5
		Manifesto.poligono(r, PackedVector2Array([Vector2(storto, 3), Vector2(r.size.x, 1), Vector2(r.size.x - storto, alto - 2),
				Vector2(0, alto - 4)]), Stile.colore("accento"))
		return
	r.draw_rect(Rect2(0, 0, r.size.x, alto), Color(Stile.colore("accento"), 0.25 * clampf(r.accesa.valore, 0.0, 1.0)))
	var x := r.x_testo()
	while x < r.size.x:
		r.draw_rect(Rect2(x, alto - 1.0, 4, 1), Color(Stile.colore("box_testo"), 0.35))
		x += 8.0


static func titoletto(r: RigaZaino) -> void:
	# il titolo di una sezione del taccuino: cosa fanno gli oggetti che seguono
	var f := Caratteri.titolo()
	if f == null:
		return
	var testo := String(r.voce["gruppo"])
	var nero := Stile.colore("box_testo")
	var y := r.size.y - 12.0
	r.draw_string(f, Vector2(4, y), testo, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, nero)
	var fine := 4.0 + f.get_string_size(testo, HORIZONTAL_ALIGNMENT_LEFT, -1, 16).x + 10.0
	r.draw_rect(Rect2(fine, y - 6.0, r.size.x - fine - 40.0, 2.0), nero)
	var conto := "%d" % int(r.voce.get("quanti", 0))
	r.draw_string(Caratteri.tondo(900), Vector2(r.size.x - 30.0, y), conto, HORIZONTAL_ALIGNMENT_RIGHT, 30, 13, nero)


# --- le sezioni del taccuino ---------------------------------------------------

static func con_i_gruppi(righe: Array[Dictionary]) -> Array[Dictionary]:
	# ordinati per tipo, gli oggetti che fanno la stessa cosa stanno gia'
	# insieme: qui ci si mette sopra il titolo della sezione
	var con: Array[Dictionary] = []
	var ultimo := ""
	for riga in righe:
		var gruppo := gruppo_di(String(riga["oggetto"]))
		if gruppo != ultimo:
			con.append({"gruppo": gruppo, "quanti": 0})
			ultimo = gruppo
		con.append(riga)
	# il conto di ogni sezione: quante righe ci sono sotto
	var titolo := -1
	for i in con.size():
		if con[i].has("gruppo"):
			titolo = i
		elif titolo >= 0:
			con[titolo]["quanti"] = int(con[titolo]["quanti"]) + 1
	return con


static func gruppo_di(id_oggetto: String) -> String:
	# la sezione: quello che l'oggetto fa per primo (VITA, AURA, STRESS,
	# DANNI...), le cure, o il suo tipo se non fa niente in combattimento
	var effetto := Merce.effetto_di(GameState.dati_oggetto(id_oggetto))
	for chiave in Merce.EFFETTI:
		if effetto.has(chiave):
			return String(Merce.EFFETTI[chiave][1])
	if effetto.has("cura_stato") or effetto.has("cura_stati") or effetto.has("rigenerazione_battute"):
		return "CURE"
	return String(ElencoZaino.NOMI_TIPI.get(Merce.tipo_oggetto(id_oggetto), "ALTRO")).to_upper()
