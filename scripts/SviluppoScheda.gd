class_name SviluppoScheda
extends Control

# LO SVILUPPO: come sta crescendo chi guardi, nella scheda della squadra.
#
# Bru, 28 settembre: «le stats non devono stare dentro il data pad, da opzioni
# possiamo andare su squadra e personaggio e' li' che troviamo le info di
# squadra personaggio tra cui stat cosa ti sta cambiando etc, averlo anche su
# datapad e' disorganizzazione [...] cosa ti sta cambiando lo chiameremo
# sviluppo». Qui sono finite le pagine che il Data pad ha lasciato: Stato,
# Cosa ti sta cambiando, Abilita' passive, Squadra, e le resistenze che stavano
# nelle Osservazioni.
#
#   esperienza     quanta ne hai, e quanta ne manca al livello dopo
#   crescita       il fattore Carnivalz: ogni gesto ripetuto alza una
#                  statistica, e la riga dice quanto manca al prossimo punto
#   guadagnati     i punti che ci hai gia' preso, sopra la base
#   passive        le abilita' che funzionano senza che tu le chiami
#   resistenze     agli stati, guadagnate subendoli
#
# Crescono cosi' solo il protagonista e i suoi gesti: di un compagno si
# vedono l'esperienza e lo stress.

# la spiegazione a destra, nel riquadro del dettaglio: e' mia, da girare
const SPIEGAZIONE := "Quello che fai, ripetuto, ti cambia: ogni riga dice quanto manca al prossimo punto di una statistica. Le abilità passive funzionano senza che tu le chiami."
const MARGINE := 10.0

var scorri: ScrollContainer
var righe: VBoxContainer


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	scorri = ScrollContainer.new()
	scorri.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scorri)
	scorri.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, int(MARGINE))
	# a destra l'aria per la barra che scorre: i numeri non ci finiscono sotto
	var aria := MarginContainer.new()
	aria.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	aria.add_theme_constant_override("margin_right", 14)
	scorri.add_child(aria)
	righe = VBoxContainer.new()
	righe.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	righe.add_theme_constant_override("separation", 3)
	aria.add_child(righe)


func _draw() -> void:
	# lo stesso fondo delle statistiche: e' la stessa scheda, un'altra pagina
	draw_rect(Rect2(Vector2.ZERO, size), Color(Stile.colore("pannello_chiaro"), 0.85))
	draw_rect(Rect2(Vector2.ZERO, size), Color(Stile.colore("testo"), 0.1), false, 1.0)


func mostra(id: String) -> void:
	Albero.svuota(righe)
	scorri.scroll_vertical = 0
	var livello := GameState.livello_di(id)
	var xp := int(GameState.xp.get(id, 0))
	var serve := maxi(GameState.fabbisogno_xp(livello), 1)
	titoletto("ESPERIENZA")
	riga("Livello %d" % livello, "%d / %d verso il %d" % [xp, serve, livello + 1], float(xp) / float(serve))
	if id != GameState.id_protagonista:
		riga("Stress", "%d / 100" % GameState.stress_di(id), float(GameState.stress_di(id)) / 100.0)
		return
	crescita()
	guadagnati()
	passive()
	resistenze()


func crescita() -> void:
	var regole: Dictionary = GameState.crescita.get("crescita", {})
	if regole.is_empty():
		return
	titoletto("CRESCITA")
	for azione: String in regole:
		var regola: Dictionary = regole[azione]
		var ogni := maxi(int(regola.get("ogni", 1)), 1)
		var fatte := int(GameState.contatori.get(azione, 0)) % ogni
		riga(maiuscola(String(regola.get("racconto", azione))), "%d / %d  → +%d %s" % [fatte, ogni,
				int(regola.get("punti", 1)), nome_stat(String(regola.get("stat", "")))], float(fatte) / float(ogni))


func guadagnati() -> void:
	var scritte := 0
	for chiave: String in GameState.crescita.get("stat", {}):
		var punti := int(GameState.punti_stat.get(chiave, 0))
		if punti <= 0:
			continue
		if scritte == 0:
			titoletto("PUNTI GUADAGNATI")
		scritte += 1
		riga(nome_stat(chiave), "+%d   (base %d)" % [punti, GameState.stat_base_di(chiave)])


func passive() -> void:
	titoletto("ABILITÀ PASSIVE")
	var nessuna := true
	for gruppo in ["passive_livello", "passive_soglia", "passive_rare"]:
		for voce: Dictionary in GameState.crescita.get(gruppo, []):
			if not GameState.ha_passiva(String(voce.get("id", ""))):
				continue
			nessuna = false
			riga(String(voce.get("nome", "")), "")
			nota(String(voce.get("descrizione", "")))
	if nessuna:
		nota("Nessuna, per ora.")


func resistenze() -> void:
	if GameState.resistenze_stato.is_empty():
		return
	titoletto("RESISTENZE")
	for chiave: String in GameState.resistenze_stato:
		var nome := String(GameState.stati.get(chiave, {}).get("nome", chiave))
		riga(nome, "+%d" % int(GameState.resistenze_stato[chiave]))


static func maiuscola(testo: String) -> String:
	return testo.left(1).to_upper() + testo.substr(1)


static func nome_stat(chiave: String) -> String:
	return String(GameState.crescita.get("stat", {}).get(chiave, {}).get("nome", chiave))


# --- i pezzi ----------------------------------------------------------------------

func titoletto(testo: String) -> void:
	var t := Tavola.scritta(testo, 16, Stile.colore("testo"), Caratteri.titolo())
	t.custom_minimum_size = Vector2(0, 28)
	t.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	righe.add_child(t)


func riga(sinistra: String, destra: String, quota := -1.0) -> void:
	var fila := HBoxContainer.new()
	fila.mouse_filter = Control.MOUSE_FILTER_IGNORE
	righe.add_child(fila)
	var nome := Tavola.scritta(sinistra, 13, Stile.colore("testo"), Caratteri.tondo(800))
	nome.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	nome.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	fila.add_child(nome)
	if destra != "":
		fila.add_child(Tavola.scritta(destra, 13, Stile.colore("testo_smorzato"), Caratteri.tondo(800),
				HORIZONTAL_ALIGNMENT_RIGHT))
	if quota >= 0.0:
		righe.add_child(barretta(clampf(quota, 0.0, 1.0)))


func nota(testo: String) -> void:
	var n := Tavola.scritta(testo, 12, Stile.colore("testo_smorzato"), Caratteri.tondo(600))
	n.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	n.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	righe.add_child(n)


func barretta(quota: float) -> Control:
	# quanto manca, a colpo d'occhio: la stessa barra sottile del legame
	var vuota := ColorRect.new()
	vuota.color = Stile.colore("barra_vuota")
	vuota.custom_minimum_size = Vector2(0, 3)
	vuota.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var piena := ColorRect.new()
	piena.color = Stile.colore("accento")
	piena.mouse_filter = Control.MOUSE_FILTER_IGNORE
	piena.anchor_bottom = 1.0
	piena.anchor_right = quota
	vuota.add_child(piena)
	return vuota
