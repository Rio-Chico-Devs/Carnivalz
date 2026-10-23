extends Control
# IL PROGRAMMA (ProposteScontro.gd): i comandi di chi ha il turno.
#
# Oggi il quadrante fa quattro mestieri - i comandi, le liste, il racconto, i
# minigiochi - in un rettangolo solo, e per questo e' piccolo per tutti e
# quattro: la raffica gioca in 730 per 190 pixel, il racconto sta in tre
# righe. Qui ogni mestiere ha il suo posto: il racconto va sotto la creatura
# (la sua didascalia), il minigioco sul suo schermo, e questo pannello fa una
# cosa sola, scegliere. Sta sotto le schede, sulla spina: chi decide, la sua
# aura e i suoi comandi sono una colonna sola, e l'occhio scende invece di
# attraversare lo schermo a zig-zag.
#
# Comandi: le cinque voci a sinistra, e a destra due righe su quella che stai
# guardando - un nuovo giocatore non sa cos'e' SKILL. Liste: due colonne, col
# costo di ogni mossa nel segno dell'aura (e sulla scheda il pezzo di barra
# che spenderesti pulsa). Sotto, sempre, MATTANZA e BOND: spenti finche' non
# sono pronti, e quando si accendono non li copre niente.

const Spina := preload("res://prove/scontro/Spina.gd")
const IS := preload("res://scripts/crescita/IconeStatistiche.gd")
const COMANDI := ["ATTACCHI", "DIFESA", "SKILL", "OGGETTI", "FUGA"]
const SPIEGA := {
	"ATTACCHI": "Il colpo normale e le mosse d'arma. Si sceglie poi chi colpire.",
	"DIFESA": "Ti pari fino al tuo prossimo turno: il colpo che arriva fa meno male.",
	"SKILL": "Studiare la creatura, e le tue abilità. Quasi tutte costano aura.",
	"OGGETTI": "Quello che hai nella sacca e si può usare in combattimento.",
	"FUGA": "Provi ad andartene. Non sempre riesce.",
}

var dove := Rect2()
var modo := "comandi"       # o "lista"
var scelta := 0
var lista: Array = []       # [nome, costo d'aura (-1: nessuno), nota]
var spenti: Array[String] = ["OGGETTI"]
var mattanza := 0.0         # 0..1: quanto e' accesa
var bond := 0.0
var su := 1.0               # 0: sceso fuori dallo schermo (non tocca a nessuno della squadra)


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


func _draw() -> void:
	if su <= 0.0 or dove.size.x <= 0.0:
		return
	var giu := Vector2(0, 260.0 * (1.0 - su) * (1.0 - su))
	var r := Rect2(dove.position + giu, dove.size)
	Spina.carta(self, Spina.sbieco(r), Stile.colore("box_fondo"), 5.0)
	var sinistra := r.position.x + 26.0
	if modo == "comandi":
		disegna_comandi(r, sinistra)
	else:
		disegna_lista(r, sinistra)
	disegna_tasti(r)


func voce(dove_scritta: Vector2, testo: String, corpo: int, accesa: bool, spenta: bool) -> void:
	var font := Caratteri.titolo()
	if accesa:
		var largo := font.get_string_size(testo, HORIZONTAL_ALIGNMENT_LEFT, -1, corpo).x
		var alto := corpo * 1.18
		var fascia := PackedVector2Array([dove_scritta + Vector2(-14, -alto * 0.86), dove_scritta + Vector2(largo + 22, -alto * 0.86),
				dove_scritta + Vector2(largo + 14, alto * 0.32), dove_scritta + Vector2(-22, alto * 0.32)])
		Manifesto.poligono(self, fascia, Stile.colore("bordo"))
		Manifesto.poligono(self, PackedVector2Array([dove_scritta + Vector2(-34, -alto * 0.62), dove_scritta + Vector2(-22, -alto * 0.27),
				dove_scritta + Vector2(-34, alto * 0.08)]), Stile.colore("pericolo"))
	var tinta := Stile.colore("testo") if accesa else (Stile.colore("comando_spento") if spenta else Stile.colore("bordo"))
	Spina.scritta(self, font, dove_scritta, testo, corpo, tinta)


func disegna_comandi(r: Rect2, sinistra: float) -> void:
	var passo := 31.0
	for i in COMANDI.size():
		var y := r.position.y + 40.0 + passo * i
		voce(Vector2(sinistra + 12.0 - Spina.PENDENZA * (y - r.position.y), y), COMANDI[i], 27, i == scelta,
				COMANDI[i] in spenti)
	# DUE RIGHE SU QUELLO CHE STAI GUARDANDO, scritte col carattere del racconto
	var testo := String(SPIEGA.get(COMANDI[clampi(scelta, 0, COMANDI.size() - 1)], ""))
	var x := r.position.x + 230.0
	Spina.etichetta(self, Vector2(x, r.position.y + 16.0), "COSA FA", 13, Stile.colore("bordo"), Stile.colore("box_fondo"))
	a_capo(Vector2(x, r.position.y + 62.0), r.end.x - 22.0 - x, testo, 18)


func a_capo(da: Vector2, largo: float, testo: String, corpo: int) -> void:
	var font := Caratteri.dialoghi()
	var riga := ""
	var y := da.y
	for parola in testo.split(" "):
		var prova := parola if riga == "" else riga + " " + parola
		if font.get_string_size(prova, HORIZONTAL_ALIGNMENT_LEFT, -1, corpo).x > largo and riga != "":
			draw_string(font, Vector2(da.x, y), riga, HORIZONTAL_ALIGNMENT_LEFT, -1, corpo, Stile.colore("bordo"))
			y += corpo * 1.3
			riga = parola
		else:
			riga = prova
	draw_string(font, Vector2(da.x, y), riga, HORIZONTAL_ALIGNMENT_LEFT, -1, corpo, Stile.colore("bordo"))


func disegna_lista(r: Rect2, sinistra: float) -> void:
	var righe := 4
	var colonna := (r.size.x - 60.0) * 0.5
	var font := Caratteri.voci_strette()
	for i in lista.size():
		var c := floori(float(i) / float(righe))
		var y := r.position.y + 38.0 + 32.0 * (i % righe)
		var x := sinistra + 12.0 + c * colonna - Spina.PENDENZA * (y - r.position.y)
		var mossa: Array = lista[i]
		voce(Vector2(x, y), String(mossa[0]), 22, i == scelta, false)
		var costo := int(mossa[1])
		if costo >= 0:
			# IL COSTO NEL SEGNO DELL'AURA, a destra della voce: si legge senza
			# leggere, e la stessa icona e' sulla barra che si svuotera'
			var cx := x + colonna - 40.0
			IS.disegna(self, "aura", Vector2(cx, y - 8.0), 20.0, Stile.colore("bordo"), Stile.colore("box_fondo"))
			Spina.scritta(self, font, Vector2(cx + 13.0, y), str(costo), 20, Stile.colore("bordo"))
		elif String(mossa[2]) != "":
			Spina.scritta(self, font, Vector2(x + colonna - 14.0, y), String(mossa[2]), 16, Stile.colore("tratto"),
					HORIZONTAL_ALIGNMENT_RIGHT)


func disegna_tasti(r: Rect2) -> void:
	# MATTANZA E BOND, sempre al loro posto in fondo al programma
	var y := r.end.y - 58.0
	var x := r.position.x + 22.0 - Spina.PENDENZA * (r.size.y - 58.0)
	for tasto: Array in [["MATTANZA", mattanza, Stile.colore("mattanza")], ["BOND", bond, Stile.colore("bond")]]:
		var largo := 168.0
		var pillola := Rect2(Vector2(x, y), Vector2(largo, 42.0))
		var stile := Manifesto.stile_pillola(Stile.colore("bordo"))
		draw_style_box(stile, pillola)
		var acceso := float(tasto[1])
		var tinta: Color = Stile.colore("spento").lerp(tasto[2], acceso)
		if acceso > 0.0:
			var alone := Manifesto.stile_pillola(Color(tasto[2], 0.0))
			alone.shadow_color = Color(tasto[2], 0.55 * acceso)
			alone.shadow_size = int(10.0 * acceso)
			draw_style_box(alone, pillola)
		Spina.scritta(self, Caratteri.titolo(), pillola.get_center() + Vector2(0, 8), String(tasto[0]), 21, tinta,
				HORIZONTAL_ALIGNMENT_CENTER)
		x += largo + 14.0
	Spina.scritta(self, Caratteri.dialoghi(), Vector2(r.end.x - 22.0, y + 27.0), "INVIO sceglie", 14,
			Stile.colore("tratto"), HORIZONTAL_ALIGNMENT_RIGHT)
