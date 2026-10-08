class_name IconaMessaggi
extends Button

# I MESSAGGI SONO UN'ICONCINA, in basso a destra del data pad. Bru, 28
# settembre: «messaggi creeremo un'iconcina in basso a destra cosi' da
# sfruttare meglio gli spazi, quando avrai messaggi nuovi dovrebbe muoversi
# con un'animazione tipo tilt, come un telefono che squilla di quelli vecchi,
# ma in modo carino, tipo ogni quarto di secondo tilta tipo biru biru biru,
# pausa di 2 secondi». Prima erano una voce dell'indice del Data pad, col
# numero dei non letti fra parentesi.
#
# LO SQUILLO: tre colpi, uno ogni quarto di secondo. Ogni colpo e' la
# campanella di un telefono a disco - si piega da una parte, scatta dall'altra,
# torna dritta - e il colpo dopo parte dal lato opposto. Poi due secondi fermo,
# e da capo, finche' c'e' qualcosa da leggere; letto tutto, sta zitta. I numeri
# stanno in data/stile.json, sezione "squillo". Con «meno movimento» nelle
# opzioni non squilla: resta il numero.
#
# Il segno dentro e' una busta (Segno "messaggi"): il giorno che c'e' il
# disegno, art/segni/messaggi.png vince, come per tutti i segni.

signal aperta

const LATO := 64.0
const DI_SERIE := {"ogni": 0.25, "colpi": 3, "pausa": 2.0, "angolo": 13.0}
# un colpo, in quarti: di quanto si piega (in parti dell'angolo) e in che
# frazione del colpo ci arriva. Il rimbalzo al contrario e' piu' piccolo, e
# l'ultimo tratto la rimette dritta: tre tempi, come «bi-ru»
const COLPO := [[1.0, 0.3], [-0.6, 0.35], [0.0, 0.35]]

var numero: Label
var squillo: Tween


static func misura(nome: String) -> float:
	return float((Stile.dati.get("squillo", {}) as Dictionary).get(nome, DI_SERIE[nome]))


static func passi_dello_squillo() -> Array:
	# [[rotazione in gradi, secondi], ...] per un giro intero: i colpi, poi la
	# pausa (rotazione 0). Una lista, cosi' la prova misura lo stesso squillo
	# che si vede
	var passi: Array = []
	for colpo in int(misura("colpi")):
		var verso := 1.0 if colpo % 2 == 0 else -1.0
		for tempo: Array in COLPO:
			passi.append([misura("angolo") * float(tempo[0]) * verso, misura("ogni") * float(tempo[1])])
	passi.append([0.0, misura("pausa")])
	return passi


func _ready() -> void:
	custom_minimum_size = Vector2(LATO, LATO)
	size = Vector2(LATO, LATO)
	pivot_offset = size * 0.5    # la campanella gira sul suo centro, non sull'angolo
	focus_mode = Control.FOCUS_ALL
	# nera col bordo chiaro e l'ombra piena: si vede sull'arancio del manifesto
	# e sul nero dei pannelli
	var fondo := StyleBoxFlat.new()
	fondo.bg_color = Stile.colore("bordo")
	fondo.set_border_width_all(3)
	fondo.border_color = Stile.colore("testo")
	fondo.set_corner_radius_all(14)
	fondo.shadow_color = Stile.colore("bordo")
	fondo.shadow_size = 1
	fondo.shadow_offset = Manifesto.OMBRA * 0.6
	for stato in ["normal", "hover", "pressed", "focus", "disabled"]:
		add_theme_stylebox_override(stato, fondo)
	var busta := Segno.nuovo("messaggi", Stile.colore("testo"), LATO * 0.6)
	add_child(busta)
	busta.size = busta.custom_minimum_size
	busta.position = (size - busta.size) * 0.5
	# il numero dei non letti, sull'angolo: bianco col testo nero, come il
	# cartellino dei Tazo
	numero = Label.new()
	numero.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	numero.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	numero.add_theme_font_override("font", Caratteri.titolo())
	numero.add_theme_font_size_override("font_size", 18)
	numero.add_theme_color_override("font_color", Stile.colore("box_testo"))
	var cartellino := StyleBoxFlat.new()
	cartellino.bg_color = Stile.colore("testo")
	cartellino.set_corner_radius_all(12)
	numero.add_theme_stylebox_override("normal", cartellino)
	numero.size = Vector2(24, 24)
	numero.position = Vector2(LATO - 16.0, -8.0)
	numero.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(numero)
	pressed.connect(func() -> void: aperta.emit())
	aggiorna()


func aggiorna() -> void:
	var nuovi := Messaggi.non_letti()
	numero.text = str(nuovi)
	numero.visible = nuovi > 0
	tooltip_text = "Messaggi" if nuovi == 0 else "Messaggi: %d da leggere" % nuovi
	if nuovi > 0 and not Movimento.ridotto():
		squilla()
	else:
		zitta()


func squilla() -> void:
	if squillo != null and squillo.is_valid():
		return
	squillo = create_tween().set_loops()
	var passi := passi_dello_squillo()
	for passo: Array in passi.slice(0, -1):
		squillo.tween_property(self, "rotation", deg_to_rad(float(passo[0])), float(passo[1])) \
				.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	squillo.tween_interval(float(passi.back()[1]))   # la pausa: ferma, dritta


func zitta() -> void:
	if squillo != null and squillo.is_valid():
		squillo.kill()
	squillo = null
	rotation = 0.0


func sta_squillando() -> bool:
	return squillo != null and squillo.is_valid() and squillo.is_running()
