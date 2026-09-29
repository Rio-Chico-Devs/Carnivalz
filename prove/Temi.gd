extends RefCounted

# PROPOSTE DI TEMA PER TUTTA L'INTERFACCIA: anteprime per Bru, non il gioco.
#
# Bru, 30 settembre, mandando un'immagine arancio, nera e grigio caldo: «basandoti
# sui colori di quest'ultima e gli stili grafici, possiamo uniformare l'ui
# generale? mi dai delle anteprime da cui scegliere?». Dall'immagine si prende
# la LINGUA - i tre colori, il retino a puntini delle ombre, gli anelli appena
# visibili nel fondo, le etichette nere con la scritta chiara - non i suoi
# marchi, i suoi caratteri o i suoi disegni.
#
# I colori misurati sull'immagine (i dieci piu' frequenti): arancio #F4931B,
# nero quasi puro, grigio caldo #D8CFC7 e il suo retino #B9B2AC.
#
# Le schermate sono quelle vere, ricolorate: Stile legge tutti i colori da
# data/stile.json, e qui si riscrivono prima di costruirle.
#
#   ./prove/scatto.sh plancia tema=arcade
#   ./prove/scatto.sh nodo infermeria_risveglio 5 tema=notte

const ARANCIO := "#f4931b"
const ARANCIO_SCURO := "#d97c0c"
const NERO := "#0b0908"
const NERO_CALDO := "#1f1b18"
const CREMA := "#d8cfc7"
const CREMA_CHIARA := "#ece6df"
const RETINO := "#b9b2ac"
const ROSSO := "#c8281e"   # l'unico colore in piu': il pericolo deve restare pericolo

# quello che hanno in comune tutti e tre: il nero, il grigio caldo al posto del
# bianco, l'arancio al posto del cremisi
const COMUNI := {
	"pannello": NERO, "pannello_chiaro": NERO_CALDO, "bordo": NERO, "tratto": "#4a423c",
	"bordo_acceso": CREMA, "testo": CREMA, "testo_smorzato": "#9a918a", "velo": NERO,
	"box_fondo": CREMA_CHIARA, "box_testo": NERO, "nastro_testo": NERO,
	"pericolo": ROSSO, "malvagio": ROSSO, "barra_dominio": ROSSO, "fascia_nemico": NERO,
	"plancia_pannello": CREMA, "barra_hp": ARANCIO, "barra_aura": "#8c847e",
	"bond": ARANCIO, "spento": "#6b645e", "barra_vuota": "#3a3430", "comando_spento": "#8c847e",
}

const TEMI := {
	"arcade": {
		"_come": "l'arancio a tutto campo, come l'immagine: fondi arancio, pannelli neri, etichette nere con la scritta chiara",
		"sfondo": ARANCIO, "sfondo_combattimento": ARANCIO, "quadro_vuoto": ARANCIO_SCURO,
		"accento": NERO, "nastro": CREMA, "mattanza": CREMA, "narrazione": NERO, "barra_hp": CREMA_CHIARA,
		"barra_aura": "#5e5751",
		"menu_notte_alto": ARANCIO, "menu_notte_basso": "#e8850f", "menu_lontano": "#c96f12",
		"menu_sagoma": NERO, "menu_sagoma_chiara": "#2a211a", "menu_primo_piano": NERO,
		"menu_luna": CREMA, "menu_nebbia": "#f7a94a", "menu_lampadina": "#fff1dd",
		"menu_voce": NERO, "menu_chiaro": NERO, "menu_scia": "#f7a94a", "menu_macchia": NERO,
		"menu_spruzzo": "#2a211a", "menu_descrizione": NERO, "menu_riga": CREMA,
		"menu_riga_bordo": NERO, "menu_riga_accesa": CREMA_CHIARA, "menu_riga_accesa_bordo": NERO,
	},
	"notte": {
		"_come": "il nero fa da fondo e l'arancio accende: e' il tema piu' vicino a com'e' adesso, col cremisi diventato arancio",
		"sfondo": NERO, "sfondo_combattimento": CREMA, "quadro_vuoto": NERO_CALDO,
		"accento": ARANCIO, "nastro": ARANCIO, "mattanza": ARANCIO,
		"menu_notte_alto": NERO, "menu_notte_basso": "#2a211a", "menu_lontano": "#3a2c20",
		"menu_sagoma": "#171311", "menu_sagoma_chiara": "#2a211a", "menu_primo_piano": NERO,
		"menu_luna": ARANCIO, "menu_nebbia": "#4a3522", "menu_lampadina": "#ffe2b8",
		"menu_voce": "#9a918a", "menu_chiaro": CREMA, "menu_scia": ARANCIO, "menu_macchia": ARANCIO,
		"menu_spruzzo": ARANCIO_SCURO, "menu_descrizione": CREMA, "menu_riga": NERO,
		"menu_riga_bordo": "#3a3430", "menu_riga_accesa": NERO_CALDO, "menu_riga_accesa_bordo": ARANCIO,
	},
	"carta": {
		"_come": "il grigio caldo fa da fondo, come la carta del cabinato: scritte ed etichette nere, arancio per il turno e la voce scelta",
		"sfondo": CREMA, "sfondo_combattimento": CREMA, "quadro_vuoto": RETINO,
		"accento": NERO, "nastro": ARANCIO, "mattanza": ARANCIO, "narrazione": NERO,
		"menu_notte_alto": CREMA, "menu_notte_basso": "#c9bfb6", "menu_lontano": RETINO,
		"menu_sagoma": NERO, "menu_sagoma_chiara": "#3a3430", "menu_primo_piano": NERO,
		"menu_luna": ARANCIO, "menu_nebbia": CREMA_CHIARA, "menu_lampadina": "#fff8ee",
		"menu_voce": "#3a3430", "menu_chiaro": NERO, "menu_scia": ARANCIO, "menu_macchia": ARANCIO,
		"menu_spruzzo": ARANCIO_SCURO, "menu_descrizione": NERO, "menu_riga": CREMA_CHIARA,
		"menu_riga_bordo": RETINO, "menu_riga_accesa": CREMA, "menu_riga_accesa_bordo": NERO,
	},
}


static func applica(nome: String) -> void:
	# si riscrivono i colori, e Stile rifa' il tema dei controlli con quelli
	if not TEMI.has(nome):
		push_error("tema di prova '%s' sconosciuto (ci sono %s)" % [nome, ", ".join(TEMI.keys())])
		return
	var colori: Dictionary = Stile.dati.get("colori", {})
	for chiave in COMUNI:
		colori[chiave] = COMUNI[chiave]
	for chiave in TEMI[nome]:
		if not String(chiave).begins_with("_"):
			colori[chiave] = TEMI[nome][chiave]
	Stile.dati["colori"] = colori
	Stile.applica()


static func decora(radice: Node, nome: String) -> void:
	# IL RETINO E GLI ANELLI dietro il fondo piu' grande della schermata
	var piu_grande: ColorRect = null
	for nodo in radice.find_children("*", "ColorRect", true, false):
		var piatto := nodo as ColorRect
		if piatto.is_visible_in_tree() and piatto.color.a > 0.5 and piatto.size.x >= 900.0 \
				and (piu_grande == null or piatto.get_rect().get_area() > piu_grande.get_rect().get_area()):
			piu_grande = piatto
	if piu_grande != null:
		var trama := Trama.new()
		trama.tinta = piu_grande.color
		piu_grande.add_child(trama)
		trama.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	accenti(radice, nome)


static func accenti(radice: Node, nome: String) -> void:
	# UN ACCENTO SOLO NON BASTA quando il fondo e' chiaro o arancio: li'
	# l'accento e' nero (le etichette nere dell'immagine), ma sulle superfici
	# nere serve una luce. Per l'anteprima si divide a mano in quattro punti;
	# nel gioco vero diventerebbero voci loro in stile.json
	var luce := Color(CREMA) if nome == "arcade" else Color(ARANCIO)
	var tasto_fondo := Color(ARANCIO) if nome == "notte" else Color(NERO)
	if nome != "notte":
		for voce in radice.find_children("*", "VoceMacchia", true, false):
			if nome == "arcade":
				voce.set("tinta_accesa", luce)   # la voce scelta, sulla macchia nera
				voce.call("colora", 1.0 if (voce.get("bottone") as Control).has_focus() else 0.0)
		for slot in radice.find_children("*", "SlotCompagno", true, false):
			if bool(slot.get("tocca_a_lui")):
				(slot.get("cornice") as ColorRect).color = luce   # chi ha il turno
	for nodo in radice.find_children("*", "", true, false):
		var plancia: Variant = nodo.get("plancia")
		if plancia is PlanciaCombattimento and nome != "notte":
			# il riquadro della creatura e' nero dentro, come nel disegno di Bru
			var dentro := (plancia as PlanciaCombattimento).interno_di((plancia as PlanciaCombattimento).box_nemico)
			for piatto in dentro.get_children():
				if piatto is ColorRect:
					(piatto as ColorRect).color = Color(NERO)
		var tasto: Variant = nodo.get("icona_menu")
		if tasto is Button:
			var fondo := (tasto as Button).get_theme_stylebox("normal").duplicate() as StyleBoxFlat
			if fondo != null:
				fondo.bg_color = tasto_fondo
				fondo.border_color = Color(NERO) if nome == "notte" else luce
				for stato in ["normal", "hover", "pressed", "focus"]:
					(tasto as Button).add_theme_stylebox_override(stato, fondo)


class Trama extends Control:
	# gli anelli larghi e appena piu' chiari del fondo, centrati fuori schermo a
	# destra, e il retino a puntini che si addensa verso l'angolo in basso
	var tinta := Color.ORANGE

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		var chiaro := tinta.lightened(0.028)
		var centro := Vector2(size.x * 1.05, size.y * 0.45)
		var raggio := size.x * 0.18
		while raggio < size.x * 1.3:
			draw_arc(centro, raggio, 0.0, TAU, 160, chiaro, size.x * 0.03, true)
			raggio += size.x * 0.11
		var scuro := tinta.darkened(0.09)
		var passo := 11.0
		var y := 0.0
		var riga := 0
		while y < size.y + passo:
			var x := (passo * 0.5) if riga % 2 == 1 else 0.0
			while x < size.x + passo:
				# piu' fitti e piu' grossi verso l'angolo in basso a sinistra
				var quanto := clampf((y / size.y) * 1.3 - (x / size.x) * 1.1 - 0.25, 0.0, 1.0)
				if quanto > 0.05:
					draw_circle(Vector2(x, y), passo * 0.42 * quanto, scuro)
				x += passo
			y += passo * 0.87
			riga += 1
