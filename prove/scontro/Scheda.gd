extends Control
# LA SCHEDA DI UNO DELLA SQUADRA (ProposteScontro.gd).
#
# Oggi ogni compagno e' un ritratto grande quanto una cartolina, nero e vuoto
# finche' non ci sono i disegni, e la sua vita e' una barra di otto pixel che
# galleggia nell'arancio lì sotto, con «HP» scritto a dieci pixel: il posto
# va a quello che non dice niente, e le cose che contano - quanta vita ti
# resta, se ti basta l'aura - sono le piu' piccole della schermata.
#
# Qui e' il contrario. La scheda e' un foglio di sbieco sulla spina, col
# ritratto piccolo e le barre lunghe e spesse DENTRO il foglio, ognuna col suo
# segno (il palloncino, il fuoco fatuo, la corona: le icone delle statistiche
# che Bru ha visto) e la vita sempre scritta. Chi ha il turno fa un passo
# avanti verso la creatura: la scheda si allarga e il ritratto esce dal foglio
# inclinato. Il suo ECG e' sotto le schede, in cima ai suoi comandi
# (Programma.gd): dentro la scheda era una striscia di trenta pixel, e Bru:
# «non si vede l'ecg».
#
# Gli status ci sono sempre, piccoli: «se stanno bene ci stara l'icona
# normale» (Bru). Si fanno notare quando c'e' qualcosa da leggere.

const Spina := preload("res://prove/scontro/Spina.gd")
const IS := preload("res://scripts/crescita/IconeStatistiche.gd")
const CORPO_COSTO := 15    # il cartellino rosso del costo, sulla barra dell'aura

var dove := Rect2()        # il rettangolo della scheda, sullo schermo (il lato sinistro va di sbieco)
var attiva := 0.0          # 0 a riposo, 1 quando ha il turno (lo anima chi la usa)
var colpo := 0.0           # 1 quando ha appena preso un colpo
var libero := false        # il posto di un compagno che non c'e'
var dati := {}             # nome, iniziale, hp, hp_max, aura, aura_max, dominio (0..1), stati, morale, stress, tu
var prenota_aura := 0      # l'aura della mossa che stai guardando nella lista


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


func ritratto() -> Rect2:
	var lato := lerpf(68.0, 112.0, attiva)
	return Rect2(dove.position + Vector2(18.0, lerpf(12.0, -20.0, attiva)), Vector2(lato, lato))


func _draw() -> void:
	if dove.size.x <= 0.0:
		return
	var foglio := Spina.sbieco(dove)
	if libero:
		Spina.carta(self, foglio, Color(Stile.colore("plancia_pannello"), 0.55), 3.0, false)
		Spina.scritta(self, Caratteri.titolo(), dove.get_center() + Vector2(-8, 8), "POSTO LIBERO", 20,
				Stile.colore("tratto"), HORIZONTAL_ALIGNMENT_CENTER)
		return
	var carta := Stile.colore("plancia_pannello").lerp(Stile.colore("box_fondo"), attiva)
	Spina.carta(self, foglio, carta, lerpf(4.0, 5.0, attiva))
	disegna_ritratto()
	disegna_barre()
	disegna_status()


func disegna_ritratto() -> void:
	var r := ritratto()
	var centro := r.get_center()
	draw_set_transform(centro, deg_to_rad(-3.5 * attiva))
	var qui := Rect2(r.position - centro, r.size)
	Manifesto.rettangolo(self, Rect2(qui.position + Manifesto.OMBRA * attiva, qui.size), Stile.colore("bordo"))
	Manifesto.rettangolo(self, qui, Stile.colore("bordo"))
	Manifesto.rettangolo(self, qui.grow(-3.0), Stile.colore("cornice_turno") if attiva > 0.5 else Stile.colore("bordo"))
	Manifesto.rettangolo(self, qui.grow(-6.0), Stile.colore("quadro_vuoto").lerp(Stile.colore("pericolo"), colpo * 0.7))
	Spina.scritta(self, Caratteri.titolo(), Vector2(0, qui.size.y * 0.3), String(dati.get("iniziale", "?")),
			int(qui.size.y * 0.78), Stile.colore("tratto"), HORIZONTAL_ALIGNMENT_CENTER)
	draw_set_transform(Vector2.ZERO)


func righe() -> Array:
	# le tre barre: chiave dell'icona, quanta, tinta, alta, numero scritto
	var hp := float(dati.get("hp", 0))
	var hp_max := maxf(float(dati.get("hp_max", 1)), 1.0)
	var aura := float(dati.get("aura", 0))
	var aura_max := maxf(float(dati.get("aura_max", 1)), 1.0)
	return [
		["hp", hp / hp_max, Stile.colore("bordo"), lerpf(14.0, 20.0, attiva), "%d/%d" % [hp, hp_max]],
		# IL NUMERO DELL'AURA SOLO A CHI HA IL TURNO: e' l'unica barra che si
		# spende a prezzo fisso (docs/schermata_combattimento.md §8)
		["aura", aura / aura_max, Stile.colore("accento_su_carta"), lerpf(9.0, 13.0, attiva),
				"%d/%d" % [aura, aura_max] if attiva > 0.5 else ""],
		["maestria_dominio", float(dati.get("dominio", 0.0)), Stile.colore("barra_dominio"), lerpf(6.0, 8.0, attiva), ""],
	]


func barre() -> Array:
	# DOVE STA OGNI BARRA: [riga di righe(), rettangolo della barra]. Le
	# disegna disegna_barre(), le misura la prova (che stiano nel foglio).
	# A RIPOSO la scheda e' alta 84: nome, tre barre e nove pixel di carta
	# sotto. Le barre partivano piu' giu' e la corona finiva sul bordo
	var x0 := ritratto().end.x + 16.0
	var x1 := dove.end.x - 16.0
	var y := dove.position.y + lerpf(32.0, 46.0, attiva)
	var fuori := []
	for riga: Array in righe():
		var alta := float(riga[3])
		var dopo_icona := x0 + icona(alta) + 8.0
		var spazio_numero := 84.0 if String(riga[4]) != "" else 0.0
		fuori.append([riga, Rect2(Vector2(dopo_icona, y), Vector2(x1 - dopo_icona - spazio_numero, alta))])
		y += alta + lerpf(7.0, 11.0, attiva)
	return fuori


func icona(alta: float) -> float:
	return alta + lerpf(6.0, 10.0, attiva)


func prenota() -> float:
	# l'aura che spenderesti, in quota della barra
	return float(prenota_aura) / maxf(float(dati.get("aura_max", 1)), 1.0)


func disegna_barre() -> void:
	var x0 := ritratto().end.x + 16.0
	var x1 := dove.end.x - 16.0
	var font := Caratteri.titolo()
	var carta := Stile.colore("plancia_pannello").lerp(Stile.colore("box_fondo"), attiva)
	# IL NOME, e quando ha il turno «TOCCA A TE» al posto del nome: la fascia del
	# turno che Bru ha visto (FasciaTurno.gd), nello stesso posto - una cosa
	# sola da leggere invece di due
	var nome := String(dati.get("nome", "")).to_upper()
	if attiva > 0.5:
		nome = "TOCCA A %s" % ("TE" if bool(dati.get("tu", false)) else nome)
	Spina.etichetta(self, Vector2(x0 + 6.0, dove.position.y + lerpf(8.0, 10.0, attiva)), nome, int(lerpf(16.0, 19.0, attiva)))
	for posto: Array in barre():
		var riga: Array = posto[0]
		var barra: Rect2 = posto[1]
		var alta := barra.size.y
		var lato := icona(alta)
		IS.disegna(self, String(riga[0]), Vector2(x0 + lato * 0.5, barra.get_center().y), lato, Stile.colore("bordo"), carta)
		var spende := String(riga[0]) == "aura" and prenota_aura > 0
		Spina.barra(self, barra, float(riga[1]), riga[2], false, prenota() if spende else 0.0, true)
		var numero := String(riga[4])
		if numero != "":
			Spina.scritta(self, font, Vector2(x1, barra.get_center().y + 8.0), numero, int(lerpf(17.0, 20.0, attiva)),
					Stile.colore("bordo"), HORIZONTAL_ALIGNMENT_RIGHT)
		if spende:
			Spina.etichetta(self, cartellino(barra, float(riga[1])).position, "-%d" % prenota_aura, CORPO_COSTO,
					Stile.colore("pericolo"), Stile.colore("testo"))


func cartellino(barra: Rect2, quota: float) -> Rect2:
	# QUANTO TI COSTA, in rosso SUL pezzo a righe che se ne andrebbe: accanto al
	# numero toccava la fine della barra, e diceva la stessa cosa due volte
	var testo := "-%d" % prenota_aura
	var largo := Caratteri.titolo().get_string_size(testo, HORIZONTAL_ALIGNMENT_LEFT, -1, CORPO_COSTO).x + CORPO_COSTO
	var alto := CORPO_COSTO * 1.3
	var mezzo := barra.position.x + barra.size.x * (quota - minf(prenota(), quota) * 0.5)
	return Rect2(Vector2(mezzo - largo * 0.5, barra.get_center().y - alto * 0.5), Vector2(largo, alto))


func disegna_status() -> void:
	# piccoli, in alto a destra; uno grigio e calmo se non c'e' niente
	var stati: Array = dati.get("stati", [])
	if stati.is_empty():
		stati = [""]
	var lato := 22.0
	var x := dove.end.x - 14.0 - lato
	for stato in stati:
		var r := Rect2(Vector2(x, dove.position.y + 9.0), Vector2(lato, lato))
		draw_circle(r.get_center(), lato * 0.5 + 2.0, Stile.colore("bordo"), true, -1.0, true)
		IconeStato.disegna(self, String(stato), r)
		x -= lato + 6.0
