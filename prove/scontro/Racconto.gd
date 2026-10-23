extends Control
# IL RACCONTO (ProposteScontro.gd): quello che si dice nello scontro.
#
# Bru: «il suo dialogo appare dove mettiamo i minigiochi e così anche quelli
# dei nemici e protagonisti più la narrazione del combattimento». Oggi e' il
# quadrante, e ci stanno tre righe. Qui il racconto prende il posto della
# fascia col nome, sotto la creatura: e' la sua didascalia - quello che succede
# a lei e intorno a lei - largo quanto il cartellone. Quando finisce la fascia
# torna su.
#
# E' il box dei dialoghi (BoxTesto.gd) nella sua lingua: il foglio chiaro, il
# contorno nero, il nome di chi parla sull'etichetta nera; la narrazione in
# corsivo e senza nome. In questa proposta e' disegnato a mano: nel gioco
# sarebbe il box vero.

const Spina := preload("res://prove/scontro/Spina.gd")
const ALTO := 562.0
const BASSO := 704.0
const LETTERE_AL_SECONDO := 55.0

var chi := ""               # vuoto: e' la narrazione
var testo := ""
var da := 0.0               # da quanto e' cominciata la battuta
var su := 0.0               # 1: il box e' al suo posto


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


func dici(nuovo_chi: String, nuovo_testo: String) -> void:
	chi = nuovo_chi
	testo = nuovo_testo
	da = 0.0


func _draw() -> void:
	if su <= 0.0:
		return
	var giu := Vector2(0, 190.0 * (1.0 - su) * (1.0 - su))
	var foglio := Spina.sposta(PackedVector2Array([Vector2(16, ALTO), Vector2(Spina.diagonale(ALTO), ALTO),
			Vector2(Spina.diagonale(BASSO), BASSO), Vector2(16, BASSO)]), giu)
	Spina.carta(self, foglio, Stile.colore("box_fondo"), 5.0)
	var corpo := 23
	var font := Caratteri.dialoghi("corsivo" if chi == "" else "dritto")
	var y := ALTO + 50.0 + giu.y
	if chi != "":
		Spina.etichetta(self, Vector2(34, ALTO - 16.0 + giu.y), chi.to_upper(), 20)
		y += 6.0
	var visibili := int(da * LETTERE_AL_SECONDO)
	var scritto := testo.substr(0, visibili)
	var largo := Spina.diagonale(BASSO) - 70.0
	var riga := ""
	for parola in scritto.split(" "):
		var prova := parola if riga == "" else riga + " " + parola
		if font.get_string_size(prova, HORIZONTAL_ALIGNMENT_LEFT, -1, corpo).x > largo - 40.0 and riga != "":
			draw_string(font, Vector2(42, y), riga, HORIZONTAL_ALIGNMENT_LEFT, -1, corpo, Stile.colore("box_testo"))
			y += corpo * 1.35
			riga = parola
		else:
			riga = prova
	draw_string(font, Vector2(42, y), riga, HORIZONTAL_ALIGNMENT_LEFT, -1, corpo, Stile.colore("box_testo"))
	if visibili >= testo.length():
		# il triangolo che dice «puoi andare avanti», come nel box vero
		var p := Vector2(Spina.diagonale(BASSO) - 36.0, BASSO - 26.0 + giu.y + 3.0 * sin(da * 6.0))
		Manifesto.poligono(self, PackedVector2Array([p + Vector2(-9, -6), p + Vector2(9, -6), p + Vector2(0, 6)]),
				Stile.colore("bordo"))
