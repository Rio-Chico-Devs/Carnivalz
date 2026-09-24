class_name GregariNemici
extends Control

# I QUADRATINI DI CHI STA COL BOSS.
#
# Bru: «dobbiamo anche pensare a un qualcosa nell'interfaccia che permetta di
# avere altri nemici, tipo in basso a sinistra dentro il riquadro del boss se
# ci sono piu' nemici, ad esempio quelli che evoca aggiungeremo dei piccoli
# quadrati 1:1 con la pic dei nemici comuni».
#
# PRIMA SI SCHIACCIAVANO NELLO STESSO POSTO. La plancia ha un riquadro solo per
# il nemico («non ci saranno piu' di un nemico»), e ogni creatura in piu' ci
# finiva dentro accanto alla prima: due disegni nella stessa cornice, e il nome
# sulla fascia rossa riscritto dall'ultimo arrivato - sopra il goblin
# arrabbiato si leggeva GOBLIN TIPICO. E quando il goblin tipico cadeva, il
# riquadro che sfumava via era quello del boss, perche' la "scheda" di tutti e
# due era lo stesso pannello.
#
# Adesso il riquadro grande resta di chi e' entrato per primo - il disegno, il
# nome, quello che hai studiato - e chi si aggiunge prende un quadratino suo in
# basso a sinistra: la sua faccia, una barra della sua vita, e ci si clicca
# sopra per colpirlo come si clicca sul boss. Quando cade sfuma, e gli altri
# scorrono a riempire il posto.
#
# LA BARRA E' UNA SCELTA MIA. Di una creatura la vita esatta si scopre
# studiandola (Campo.conosciuta), e qui non c'e' nessun numero: c'e' solo quanto
# ne resta a occhio. In un quadratino cosi' piccolo e' l'unico modo di vedere
# che i colpi stanno servendo a qualcosa.

const LATO_QUOTA := 0.24     # il lato, rispetto all'altezza del riquadro del boss
const LATO_MINIMO := 44.0
const LATO_MASSIMO := 110.0
const MARGINE := 10.0
const SPAZIO := 8.0

var fila: Array[QuadrettoNemico] = []


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(disponi)


func aggiungi(id_personaggio: String) -> QuadrettoNemico:
	var nuovo := QuadrettoNemico.new(id_personaggio)
	add_child(nuovo)
	fila.append(nuovo)
	# chi cade sfuma e poi si nasconde (Campo.congeda): a quel punto il suo
	# posto si libera e gli altri scorrono
	nuovo.visibility_changed.connect(disponi)
	disponi()
	return nuovo


func lato() -> float:
	return clampf(size.y * LATO_QUOTA, LATO_MINIMO, LATO_MASSIMO)


func disponi() -> void:
	var l := lato()
	var x := MARGINE
	for quadretto in fila:
		if not quadretto.visible:
			continue
		quadretto.position = Vector2(x, size.y - MARGINE - l)
		quadretto.size = Vector2(l, l)
		x += l + SPAZIO


# --- un quadratino ---------------------------------------------------------

class QuadrettoNemico:
	extends Control

	# UN NODO SOLO, CHE DISEGNA TUTTO: la faccia, il bordo, la barra. E' la
	# stessa scelta del riquadro della raffica - pochi nodi con dentro di piu'
	# costano meno di tanti nodi piccoli, e qui ce ne possono essere due o tre
	# che si ridisegnano a ogni colpo.

	const RITRATTO := preload("res://scripts/Ritratto.gd")
	const BORDO := 3.0
	const ALTEZZA_VITA := 7.0

	var id_personaggio := ""
	var faccia: Texture2D = null
	var iniziale := ""
	var quota_vita := 1.0

	func _init(id: String) -> void:
		id_personaggio = id
		var dati: Dictionary = GameState.personaggi.get(id, {})
		var percorso: String = RITRATTO.percorso_immagine(id, dati, "neutra")
		if percorso != "":
			faccia = load(percorso)
		iniziale = String(dati.get("nome", id)).left(1).to_upper()
		mouse_filter = Control.MOUSE_FILTER_STOP
		mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		tooltip_text = String(dati.get("nome_breve", dati.get("nome", id)))

	func imposta_vita(quota: float) -> void:
		quota = clampf(quota, 0.0, 1.0)
		if is_equal_approx(quota, quota_vita):
			return
		quota_vita = quota
		queue_redraw()

	func _draw() -> void:
		var tutto := Rect2(Vector2.ZERO, size)
		draw_rect(tutto, Stile.colore("sfondo"))
		var dentro := tutto.grow(-BORDO)
		if faccia != null:
			# 1:1 e piena: si ritaglia il centro del disegno invece di
			# schiacciarlo, come fa un'icona
			var misura := faccia.get_size()
			var lato_sorgente := minf(misura.x, misura.y)
			var sorgente := Rect2((misura - Vector2(lato_sorgente, lato_sorgente)) * 0.5,
					Vector2(lato_sorgente, lato_sorgente))
			draw_texture_rect_region(faccia, dentro, sorgente)
		else:
			var font := get_theme_default_font()
			var corpo := int(dentro.size.y * 0.5)
			draw_string(font, Vector2(dentro.position.x, dentro.get_center().y + corpo * 0.35),
					iniziale, HORIZONTAL_ALIGNMENT_CENTER, dentro.size.x, corpo,
					Stile.colore("testo_smorzato"))
		# la vita, in fondo e dentro il bordo: rossa quello che manca, chiara
		# quello che resta
		var barra := Rect2(Vector2(dentro.position.x, dentro.end.y - ALTEZZA_VITA),
				Vector2(dentro.size.x, ALTEZZA_VITA))
		draw_rect(barra, Stile.colore("pericolo"))
		draw_rect(Rect2(barra.position, Vector2(barra.size.x * quota_vita, barra.size.y)),
				Stile.colore("testo"))
		draw_rect(tutto, Stile.colore("bordo_acceso"), false, BORDO)
