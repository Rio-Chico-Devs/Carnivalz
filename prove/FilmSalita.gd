extends "res://prove/ProposteSalita.gd"

# LA SALITA IN MOVIMENTO. Provvisorio come ProposteSalita, da cui prende tutti
# i pezzi. Bru: «bisogna animare la crescita di livello e quando la ruota
# supera il 20 esponendo la nuova ruota». Due film, sulla strada consigliata
# (la B, tre tempi). Approvati: «mi piacciono molto queste animazioni,
# approvate!» (docs/salita.md §6).
#
#   salita       dal 7 all'8, tutto:
#                  - PRENDI: il punto vola dal contatore alla tasca;
#                  - il bivio approvato;
#                  - il salto: il 7 cade, arriva l'8, le barrette crescono un
#                    pezzo alla volta (prima le azioni, poi la strada) col loro
#                    perche';
#                  - la carta di Vendetta;
#                  - di nuovo la ruota: il timbro cade sulla tasca, il mozzo
#                    passa all'8, la lancetta va al 9
#   oltre_il_20  dal 19 al 20 e oltre:
#                  - il timbro sul 20, e il giro si accende tutto;
#                  - AL SECONDO GIRO: un giro di vittoria;
#                  - la ruota si crepa lungo il taglio del bivio, le due meta'
#                    volano via, e sotto c'e' quella nuova, che entra girando
#                    e si ferma sul 21
#
# Fra un momento e l'altro passa una lastra nera, come nella pausa. Per
# spaccare la ruota la si disegna anche in un SubViewport, e le due meta' sono
# due pezzi della sua immagine.
#
#   ./prove/film_salita.sh        li gira (Movie Maker) in scatti/proposte_salita/
#   nell'editor: FilmSalita.tscn, F6 (destra: l'altro film)

# i momenti di ogni film, e quanto durano
const FILM := {
	"salita": [["ruota", 2.4], ["bivio", 3.8], ["salto", 4.6], ["carta", 3.4], ["ritorno", 3.6]],
	"oltre_il_20": [["ritorno", 7.8]],
}
# quando (secondi dall'inizio del momento) e cosa succede da solo
const BATTUTE := {
	"salita": {
		"ruota": [[1.0, "prendi"]],
		"bivio": [[1.1, "avanti"], [1.8, "avanti"], [2.5, "conferma"]],
		"ritorno": [[0.5, "timbro"], [1.7, "gira"]],
	},
	"oltre_il_20": {
		"ritorno": [[0.5, "timbro"], [1.3, "accendi"], [2.8, "vittoria"], [3.85, "crepa"], [4.2, "spacca"]],
	},
}
const TENDINA := 0.5        # la lastra fra due momenti: copre a meta'
const CADE := 0.3           # il timbro, dall'alto alla tasca
const VOLA := 0.5           # il punto, dal contatore alla tasca
const TAGLIO := Vector2(0.158, -0.987)   # il taglio storto del bivio, verso l'alto
const DOVE_PUNTO := Vector2(124, 104)    # il terzo gettone del contatore

var film := ""
var momenti: Array = []
var film_zero := 0.0        # quando e' cominciato il film (in tempo)
var indice_momento := -1
var momento := ""
var momento_a := 0.0        # quando e' cominciato il momento (in tempo)
var battute: Array = []
# quando e' successa ogni cosa (in tempo); negativo: non ancora
var prendi_a := -10.0
var timbro_a := -10.0
var livello_timbrato := 0
var timbrato := false
var accendi_a := -10.0
var vittoria_a := -10.0
var crepa_a := -10.0
var spacca_a := -10.0
var rullo_a := -10.0
var rullo_da := 0
# i fogli: sotto la ruota (o il momento a tutto schermo), poi le meta' della
# ruota spaccata, poi la lastra; sopra i tasti, e sopra tutto la tendina
var sotto: Disegno
var spacco: Disegno
var tasti_qui: Control
var vecchia: SubViewport
var vecchia_tela: Disegno


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	prepara_arrivi()
	scelte[LIVELLO + 1] = STRADA
	# la ruota vecchia, disegnata a parte: quando si spacca servono i suoi pezzi
	vecchia = SubViewport.new()
	vecchia.size = Vector2i(roundi(Tavola.LARGO), roundi(Tavola.ALTO))
	vecchia.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(vecchia)
	vecchia_tela = Disegno.new()
	vecchia_tela.come = film_vecchia
	vecchia.add_child(vecchia_tela)
	Manifesto.trama_dietro(vecchia_tela).show_behind_parent = true
	var argomenti := OS.get_cmdline_user_args()
	var dopo_film := argomenti.find("film") + 1
	var quale := String(argomenti[dopo_film]) if dopo_film > 0 and dopo_film < argomenti.size() else ""
	gira_film(quale if FILM.has(quale) else "salita")


func _unhandled_input(evento: InputEvent) -> void:
	if evento.is_action_pressed("ui_right") or evento.is_action_pressed("ui_left"):
		gira_film("oltre_il_20" if film == "salita" else "salita")


func gira_film(nome: String) -> void:
	film = nome
	momenti = (FILM[nome] as Array).duplicate(true)
	if tavola != null:
		tavola.queue_free()
	tavola = Tavola.su(self)
	tela = null
	strato(film_sotto)
	sotto = tela
	strato(film_spacco)
	spacco = tela
	strato(film_sopra)
	tasti_qui = Control.new()
	tasti_qui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tavola.add_child(tasti_qui)
	strato(film_tendina)
	grana()
	film_zero = tempo
	indice_momento = -1
	prendi_a = -10.0
	timbro_a = -10.0
	timbrato = false
	accendi_a = -10.0
	vittoria_a = -10.0
	crepa_a = -10.0
	spacca_a = -10.0
	rullo_a = -10.0
	cambiato_a = -10.0
	beta = false
	# il protagonista: al 7 col 8 sotto la lancetta, o al 19 col 20
	adesso = LIVELLO if nome == "salita" else 19
	guardato = adesso + 1
	vista = float(guardato)
	spinta_vista = 0.0
	entra_nel_momento(0, 0.0)


func entra_nel_momento(quale: int, da: float) -> void:
	indice_momento = quale
	momento = String(momenti[quale][0])
	momento_a = film_zero + da
	battute = ((BATTUTE[film] as Dictionary).get(momento, []) as Array).duplicate(true)
	# la ruota e' gia' li' sotto la tendina; il bivio entra coi suoi tempi
	inizio = momento_a if momento == "bivio" else momento_a - 20.0
	if momento == "bivio":
		a_destra = true
		peso = 1.0
		spinta_peso = 0.0
		preso_a = -1.0
	tasti_del_momento()


func tasti_del_momento() -> void:
	# i tasti di ogni momento, in un contenitore loro: sotto la tendina
	Albero.svuota(tasti_qui)
	var da := tavola.get_child_count()
	match momento:
		"ruota", "ritorno":
			tasti_quadrante()
		"bivio":
			tasti_bivio()
		_:
			comandi(Vector2(40, 676), [["INVIO", "avanti"], ["ESC", "salta tutto"]], P.CARTA)
	var nuovi: Array[Node] = []
	for i in range(da, tavola.get_child_count()):
		nuovi.append(tavola.get_child(i))
	for nuovo in nuovi:
		tavola.remove_child(nuovo)
		tasti_qui.add_child(nuovo)


func _process(delta: float) -> void:
	tempo += delta
	# il momento: si cambia a meta' della tendina, quando copre tutto
	var nel_film := tempo - film_zero
	var da := 0.0
	var quale := 0
	while quale < momenti.size() - 1 and nel_film >= da + float(momenti[quale][1]):
		da += float(momenti[quale][1])
		quale += 1
	if quale != indice_momento:
		entra_nel_momento(quale, da)
	while not battute.is_empty() and tempo - momento_a >= float(battute[0][0]):
		battuta(String((battute.pop_front() as Array)[1]))
	# il timbro tocca la tasca: si sale, e il mozzo rotola
	if timbro_a >= 0.0 and not timbrato and tempo >= timbro_a + CADE:
		timbrato = true
		rullo_da = adesso
		adesso = livello_timbrato
		rullo_a = tempo
	var ruota := molla(vista, spinta_vista, float(guardato), delta)
	vista = ruota.x
	spinta_vista = ruota.y
	var taglio := molla(peso, spinta_peso, 1.0 if a_destra else 0.0, delta)
	peso = taglio.x
	spinta_peso = taglio.y
	# le scosse: quando il timbro batte, e quando la ruota si crepa
	var scossa := 0.0
	if timbrato:
		scossa = maxf(scossa, 8.0 * (1.0 - clampf((tempo - timbro_a - CADE) / 0.25, 0.0, 1.0)))
	if crepa_a >= 0.0 and spacca_a < 0.0:
		scossa = maxf(scossa, 4.0)
	var spinta := Vector2(sin(tempo * 91.0), cos(tempo * 73.0)) * scossa
	sotto.position = spinta
	spacco.position = spinta
	for figlio in tavola.get_children():
		if figlio is Disegno:
			(figlio as Control).queue_redraw()
	vecchia_tela.queue_redraw()


func battuta(quale: String) -> void:
	match quale:
		"prendi":
			prendi_a = tempo
		"avanti":
			if preso_a < 0.0:
				a_destra = not a_destra
		"conferma":
			preso_a = tempo
		"timbro":
			timbro_a = tempo
			livello_timbrato = adesso + 1
		"gira":
			guardato += 1
		"accendi":
			accendi_a = tempo
		"vittoria":
			vittoria_a = tempo
		"crepa":
			crepa_a = tempo
		"spacca":
			# sotto c'e' gia' quella nuova: parte indietro di qualche tasca, e ci arriva girando
			spacca_a = tempo
			guardato = adesso + 1
			vista = float(guardato) - 6.0
			spinta_vista = 0.0


# --- i fogli -------------------------------------------------------------------------------

func film_sotto(t: CanvasItem) -> void:
	match momento:
		"bivio":
			disegna_bivio(t)
		"salto":
			salto_animato(t)
		"carta":
			carta_animata(t)
		_:
			# prima che si spacchi c'e' la ruota di adesso; dopo, quella nuova
			if spacca_a >= 0.0:
				ruota_sotto(t, giro_di(guardato), vista)
			else:
				ruota_sotto(t, giro_di(adesso if timbrato else guardato), vista_della_vecchia())


func film_vecchia(t: CanvasItem) -> void:
	# la ruota del giro chiuso, sempre ferma com'era quando si spacca
	if film == "oltre_il_20":
		ruota_sotto(t, 0, vista_della_vecchia())


func film_spacco(t: CanvasItem) -> void:
	if crepa_a >= 0.0 and spacca_a < 0.0:
		crepa(t, clampf((tempo - crepa_a) / 0.3, 0.0, 1.0))
	if spacca_a >= 0.0:
		meta_che_volano(t, clampf((tempo - spacca_a) / 0.8, 0.0, 1.0))


func film_sopra(t: CanvasItem) -> void:
	if momento != "ruota" and momento != "ritorno":
		return
	fascia_del_giro(t)
	lastra_film(t)
	punto_che_vola(t)
	if prendi_a >= 0.0:
		scatto(t, "PRENDI · 1 PUNTO", clampf((tempo - prendi_a) / 0.35, 0.0, 1.0))
	if vittoria_a >= 0.0:
		scatto(t, "AL SECONDO GIRO", clampf((tempo - vittoria_a) / 0.35, 0.0, 1.0))


func film_tendina(t: CanvasItem) -> void:
	# la lastra nera che passa fra due momenti, da sinistra a destra: a meta'
	# copre tutto, ed e' li' che il momento cambia
	var nel_film := tempo - film_zero
	var confine := 0.0
	for i in momenti.size() - 1:
		confine += float(momenti[i][1])
		var q := (nel_film - confine) / TENDINA + 0.5
		if q <= 0.0 or q >= 1.0:
			continue
		var x := lerpf(-1900.0, 1500.0, smoothstep(0.0, 1.0, q))
		var forma := PackedVector2Array([Vector2(x, -20), Vector2(x + 1700, -20), Vector2(x + 1500, 740), Vector2(x - 200, 740)])
		var dietro := PackedVector2Array()
		for punto in forma:
			dietro.append(punto + Vector2(-26, 0))
		Manifesto.poligono(t, dietro, P.ARANCIO)
		P.lastra(t, forma, P.NERO, P.CREMA, 18.0)


# --- la ruota, divisa in due: quella che gira, e la lastra ---------------------------------

func ruota_sotto(t: CanvasItem, g: int, v: float) -> void:
	# il campo, la ruota, il mozzo: come disegna_quadrante, coi pezzi del film sopra
	var tm := tema(g)
	match String(tm["campo"]):
		"nero":
			t.draw_rect(Rect2(0, 0, 1280, 720), P.NERO)
			Manifesto.retino(t, Rect2(0, 0, 1280, 720), Color(P.ARANCIO, 0.07), Vector2(1.0, 1.0))
		"carta":
			t.draw_rect(Rect2(0, 0, 1280, 720), P.CREMA)
			Manifesto.retino(t, Rect2(0, 0, 1280, 720), Color(P.NERO, 0.07), Vector2(1.0, 1.0))
	ruota_giro(t, tm, g, v, 20.0)
	luci_del_giro(t, g, v)
	tasca_timbrata(t, tm, g, v)
	bagliore(t)
	mozzo(t, tm, g)
	if g == 0 and accendi_a >= 0.0 and tempo - accendi_a > 0.8:
		var testo := "COMPLETO"
		P.etichetta(t, CENTRO + Vector2(-(P.larghezza(testo, 20) + 22.0) * 0.5, 84), testo, 20, P.ARANCIO, P.NERO)
	legenda(t)


func vista_della_vecchia() -> float:
	# nel giro di vittoria la ruota fa un giro intero, e si ferma dov'era
	if vittoria_a < 0.0:
		return vista
	var k := clampf((tempo - vittoria_a) / 1.0, 0.0, 1.0)
	var v := 20.0 + 20.0 * k * k * (3.0 - 2.0 * k)
	return fposmod(v - 1.0, 20.0) + 1.0


func lastra_film(t: CanvasItem) -> void:
	# la lastra di disegna_quadrante, col dente che fa da lancetta
	var tm := tema(giro_di(guardato))
	P.lastra(t, PackedVector2Array(LASTRA_QUADRANTE), P.NERO, P.CREMA, 16.0)
	var bordo := lerpf(606.0, 440.0, (CENTRO.y + 20.0) / 760.0) + 14.0
	Manifesto.poligono(t, PackedVector2Array([Vector2(bordo, CENTRO.y - 22), Vector2(bordo + 34, CENTRO.y),
			Vector2(bordo, CENTRO.y + 22)]), P.CREMA)
	pannello_quadrante(t, guardato)
	testata(t, "CRESCITA", true, tm["campo"] == "nero", adesso)


func pannello_quadrante(t: CanvasItem, livello: int) -> void:
	# quello della ruota, coi gettoni del film: il terzo parte quando prendi
	super(t, livello)
	t.draw_rect(Rect2(26, 80, 420, 60), P.NERO)
	var r := 15.0
	var partito := film == "oltre_il_20" or (prendi_a >= 0.0 and tempo >= prendi_a)
	var scorre := 1.0 if film == "oltre_il_20" else (frena(clampf((tempo - prendi_a - VOLA) / 0.25, 0.0, 1.0))
			if prendi_a >= 0.0 else 0.0)
	var resto := HYPE % per_punto()
	for i in 2:
		P.gettone(t, DOVE_PUNTO + Vector2(r * 2.6 * (i - 2), 0), r, 1.0, P.CREMA, Color(P.CREMA, 0.14))
	if r * (1.0 - scorre) > 1.5:
		P.gettone(t, DOVE_PUNTO, r * (1.0 - scorre), 0.0 if partito else 1.0, P.CREMA, Color(P.CREMA, 0.14))
	P.gettone(t, DOVE_PUNTO + Vector2(r * 2.6 * (1.0 - scorre), 0), r, float(resto) / per_punto(), P.CREMA,
			Color(P.CREMA, 0.14))
	var x := DOVE_PUNTO.x + r * 2.6 * (2.0 - scorre) - 4.0
	P.scritta(t, Vector2(x, DOVE_PUNTO.y + 6), "%d PUNTI" % (2 if partito else 3), 18, P.CREMA)
	P.scritta(t, Vector2(x, DOVE_PUNTO.y + 26), "%s/%s al prossimo" % [migliaia(resto), migliaia(per_punto())], 13, P.CREMA,
			Caratteri.tondo(900))


func numero_del_mozzo(t: CanvasItem, tm: Dictionary) -> void:
	# quando il timbro batte il numero rotola: il vecchio cade, il nuovo
	# arriva dall'alto e rimbalza
	var k := clampf((tempo - rullo_a) / 0.5, 0.0, 1.0) if rullo_a >= 0.0 else 1.0
	if k >= 1.0:
		super(t, tm)
		return
	# il vecchio se ne va presto, cosi' i due non si accavallano
	var via := clampf(k * 2.2, 0.0, 1.0)
	if via < 1.0:
		numero_nel_mozzo(t, tm, str(rullo_da), Vector2(0, 150.0 * via * via), 1.0 - via)
	var arriva := clampf((k - 0.2) / 0.8, 0.0, 1.0)
	if arriva > 0.0:
		numero_nel_mozzo(t, tm, str(adesso), Vector2(0, -110.0 * (1.0 - rimbalza(arriva))), clampf(arriva * 3.0, 0.0, 1.0))


# --- i pezzi della ruota che si muovono --------------------------------------------------------

func centro_della_tasca(g: int, v: float, livello: int) -> Array:
	# dove sta una tasca, come la mette ruota_giro: angolo, quanto esce, centro
	var passo := TAU / spicchi_del_giro(g)
	var a := PI + passo * (livello - v)
	var fuori := maxf(0.0, 1.0 - absf(livello - v))
	var o := CENTRO + Vector2.from_angle(a) * 12.0 * fuori
	return [a, fuori, o, o + Vector2.from_angle(a) * (R_DENTRO + R_FUORI + 40.0 * fuori) * 0.5]


func tasca_timbrata(t: CanvasItem, tm: Dictionary, g: int, v: float) -> void:
	# il timbro: la tasca presa, nei colori delle prese, cade dall'alto (piu'
	# grande e trasparente) e resta. Sotto la lancetta la ruota mostra le tasche
	# tutte chiare, prese o no: il timbro la tiene scura finche' non se ne va
	if timbro_a < 0.0 or giro_di(livello_timbrato) != g:
		return
	var k := clampf((tempo - timbro_a) / CADE, 0.0, 1.0)
	var dove: Array = centro_della_tasca(g, v, livello_timbrato)
	var a := float(dove[0])
	var fuori := float(dove[1])
	var mezzo := TAU / spicchi_del_giro(g) * 0.5 - deg_to_rad(1.1) + 0.04 * fuori
	var c: Vector2 = dove[3]
	var alfa := clampf(k * 2.5, 0.0, 1.0)
	P.gira(t, c, 0.0, lerpf(2.1, 1.0, k * k))
	var qui: Vector2 = dove[2] - c
	P.spicchio(t, qui, R_DENTRO + 4.0 * fuori, R_FUORI + 36.0 * fuori, a - mezzo, a + mezzo, velo(tm["presa"], alfa),
			velo(P.NERO, alfa), 3.0)
	var lato := 42.0 * sqrt(20.0 / spicchi_del_giro(g))
	simbolo_tasca(t, livello_timbrato, Vector2(0, -18) * fuori, lato + 10.0 * fuori, velo(tm["presa_segno"], alfa),
			tm["presa"], velo(tm["presa_ombra"], alfa), true)
	if fuori > 0.0:
		P.scritta(t, Vector2(-40, 12 + 28 * fuori), str(livello_timbrato), roundi(18 + 12 * fuori),
				velo(tm["presa_segno"], alfa), null, HORIZONTAL_ALIGNMENT_CENTER, 80)
	P.dritto(t)
	if timbrato:
		raggi_del_colpo(t, c, clampf((tempo - timbro_a - CADE) / 0.4, 0.0, 1.0), 70.0, P.CREMA)


func bagliore(t: CanvasItem) -> void:
	# il punto arriva nella tasca: si accende d'arancio
	if prendi_a < 0.0 or timbro_a >= 0.0:
		return
	var k := (tempo - prendi_a - VOLA) / 0.5
	if k < 0.0 or k > 1.0:
		return
	var dove: Array = centro_della_tasca(0, vista, adesso + 1)
	var a := float(dove[0])
	var fuori := float(dove[1])
	var mezzo := TAU / 20.0 * 0.5 + 0.04 * fuori
	P.spicchio(t, dove[2], R_DENTRO + 4.0 * fuori, R_FUORI + 36.0 * fuori, a - mezzo, a + mezzo, Color(P.ARANCIO, 0.75 * (1.0 - k)))
	raggi_del_colpo(t, dove[3], k, 70.0, P.CREMA)


static func raggi_del_colpo(t: CanvasItem, c: Vector2, k: float, r: float, tinta: Color) -> void:
	# il colpo: tratti che scappano dal centro e si spengono
	if k <= 0.0 or k >= 1.0:
		return
	for i in 12:
		var verso := Vector2.from_angle(TAU * i / 12.0 + 0.2)
		var da := c + verso * (r + 60.0 * frena(k))
		var fino := c + verso * (r + 26.0 + 110.0 * frena(k))
		t.draw_line(da, fino, Color(P.NERO, 1.0 - k), 9.0, true)
		t.draw_line(da, fino, Color(tinta, 1.0 - k), 4.0, true)


func luci_del_giro(t: CanvasItem, g: int, v: float) -> void:
	# il giro chiuso si accende: una luce fa il giro delle tasche, come le
	# lampadine della ruota vera, poi lampeggiano tutte insieme
	if accendi_a < 0.0 or g != 0:
		return
	var tc := tempo - accendi_a
	if tc < 0.0 or tc > 1.5:
		return
	var n := spicchi_del_giro(g)
	var passo := TAU / n
	var mezzo := passo * 0.5 - deg_to_rad(1.1)
	for k in n:
		var livello := primo_del_giro(g) + k
		var luce := clampf(1.0 - absf(tc - k * 0.035) / 0.09, 0.0, 1.0)
		if tc > 0.8:
			luce = maxf(luce, (0.5 + 0.5 * cos((tc - 0.8) * TAU * 2.5)) * (1.0 - (tc - 0.8) / 0.7))
		if luce <= 0.0:
			continue
		var a := PI + passo * (livello - v)
		P.spicchio(t, CENTRO, R_DENTRO, R_ORLO, a - mezzo, a + mezzo, Color(P.ARANCIO, 0.9 * luce))


func punto_che_vola(t: CanvasItem) -> void:
	# PRENDI: il punto lascia il contatore e vola nella tasca sotto la lancetta
	if prendi_a < 0.0:
		return
	var k := (tempo - prendi_a) / VOLA
	if k < 0.0 or k >= 1.0:
		return
	var e := k * k * (3.0 - 2.0 * k)
	var fino: Vector2 = centro_della_tasca(0, vista, adesso + 1)[3]
	var arco := Vector2(430, -70)
	for scia in 3:
		var s := maxf(e - 0.07 * (scia + 1), 0.0)
		var q := DOVE_PUNTO.lerp(arco, s).lerp(arco.lerp(fino, s), s)
		P.rombo(t, q, 10.0 + 8.0 * s, Color(P.ARANCIO, 0.45 - 0.13 * scia))
	var dove := DOVE_PUNTO.lerp(arco, e).lerp(arco.lerp(fino, e), e)
	P.gira(t, dove, 360.0 * e)
	P.rombo(t, Vector2(5, 5), 15.0 + 13.0 * sin(e * PI), P.NERO)
	P.rombo(t, Vector2.ZERO, 15.0 + 13.0 * sin(e * PI), P.ARANCIO, P.NERO, 3.0)
	P.dritto(t)


func scatto(t: CanvasItem, testo: String, k: float) -> void:
	# il tasto premuto: un contorno che si allarga dall'etichetta e si spegne
	if k <= 0.0 or k >= 1.0:
		return
	var r := Rect2(30, 624, P.larghezza(testo, 26) + 26.0 * 1.1, 26.0 * 1.35)
	t.draw_rect(r.grow(4.0 + 26.0 * frena(k)), Color(P.ARANCIO, 1.0 - k), false, 4.0)


# --- oltre il 20: la ruota si spacca -----------------------------------------------------------

func crepa(t: CanvasItem, k: float) -> void:
	# la crepa parte dal mozzo e corre lungo il taglio del bivio, nei due versi
	var a_lato := Vector2(-TAGLIO.y, TAGLIO.x)
	var lungo := 460.0 * frena(k)
	for verso: float in [-1.0, 1.0]:
		var linea := PackedVector2Array([CENTRO])
		var s := 0.0
		var i := 0
		while s < lungo:
			s = minf(s + 22.0, lungo)
			i += 1
			linea.append(CENTRO + TAGLIO * s * verso + a_lato * (6.0 if i % 2 == 0 else -6.0))
		if linea.size() > 1:
			t.draw_polyline(linea, P.NERO, 11.0, true)
			t.draw_polyline(linea, P.CREMA, 4.0, true)


func meta_che_volano(t: CanvasItem, k: float) -> void:
	# le due meta' della ruota vecchia (la sua immagine, dal SubViewport): una
	# vola in alto a sinistra, l'altra in basso a destra, e sotto c'e' la nuova
	if k >= 1.0:
		return
	var e := k * k
	var a_lato := Vector2(-TAGLIO.y, TAGLIO.x)
	var cima := CENTRO + TAGLIO * (-CENTRO.y / TAGLIO.y)
	var fondo_taglio := CENTRO + TAGLIO * ((Tavola.ALTO - CENTRO.y) / TAGLIO.y)
	var pezzi := [PackedVector2Array([Vector2(0, 0), cima, fondo_taglio, Vector2(0, Tavola.ALTO)]),
			PackedVector2Array([cima, Vector2(Tavola.LARGO, 0), Vector2(Tavola.LARGO, Tavola.ALTO), fondo_taglio])]
	var immagine := vecchia.get_texture()
	for lato in 2:
		var verso := -1.0 if lato == 0 else 1.0
		var via := (a_lato * 950.0 - TAGLIO * 330.0) * verso * e
		var giro := deg_to_rad(10.0) * verso * e
		var uv := PackedVector2Array()
		var dove := PackedVector2Array()
		var ombra := PackedVector2Array()
		for punto: Vector2 in pezzi[lato]:
			uv.append(punto / Vector2(Tavola.LARGO, Tavola.ALTO))
			var q := CENTRO + (punto - CENTRO).rotated(giro) + via
			dove.append(q)
			ombra.append(q + Vector2(16, 16))
		Manifesto.poligono(t, ombra, Color(P.NERO, 0.45))
		t.draw_colored_polygon(dove, Color.WHITE, uv, immagine)
		# il bordo del taglio, come cartone tagliato
		t.draw_line(dove[1] if lato == 0 else dove[0], dove[2] if lato == 0 else dove[3], P.ARANCIO, 8.0, true)


func fascia_del_giro(t: CanvasItem) -> void:
	# scoperta la ruota nuova, il suo nome arriva come un timbro, poi se ne va
	if spacca_a < 0.0:
		return
	var k := tempo - spacca_a - 0.75
	if k < 0.0 or k > 1.95:
		return
	var g := giro_di(guardato)
	var tm := tema(g)
	var entra := rimbalza(clampf(k / 0.35, 0.0, 1.0))
	var esce := frena(clampf((k - 1.6) / 0.35, 0.0, 1.0))
	P.gira(t, CENTRO + Vector2(40 + 1100.0 * esce, 10), -6.0, lerpf(1.8, 1.0, entra))
	var fascia := PackedVector2Array([Vector2(-420, -120), Vector2(460, -120), Vector2(420, 130), Vector2(-460, 130)])
	var ombra := PackedVector2Array()
	for punto in fascia:
		ombra.append(punto + Vector2(12, 12))
	Manifesto.poligono(t, ombra, P.ARANCIO)
	P.lastra(t, fascia, P.NERO, P.CREMA, 14.0)
	P.scritta(t, Vector2(-440, -40), ROMANI[g], 96, Color(P.ARANCIO, 0.9), Caratteri.titolo(), HORIZONTAL_ALIGNMENT_CENTER, 880)
	var nome := String(tm["nome"])
	P.ritagliata(t, Vector2(-440, 30), nome, P.corpo_che_entra(nome, 80, 780.0), P.CREMA, P.NERO, 0, P.ARANCIO,
			Vector2(8, 8), null, HORIZONTAL_ALIGNMENT_CENTER, 880)
	P.scritta(t, Vector2(-440, 74), "LIVELLI %d–%d" % [primo_del_giro(g), ultimo_del_giro(g)], 26, P.ARANCIO, null,
			HORIZONTAL_ALIGNMENT_CENTER, 880)
	var accende := rimbalza(clampf((k - 0.3) / 0.25, 0.0, 1.0))
	for i in giri():
		var q := Vector2((i - (giri() - 1) * 0.5) * 30.0, 106)
		if i < g:
			P.rombo(t, q, 9.0, P.CREMA)
		elif i == g:
			P.rombo(t, q, 12.0 * accende, P.ARANCIO, P.CREMA, 2.0)
		else:
			P.rombo(t, q, 8.0, Color(0, 0, 0, 0), Color(P.CREMA, 0.3), 2.0)
	P.dritto(t)


# --- il salto e la carta, in movimento ---------------------------------------------------------

func salto_animato(t: CanvasItem) -> void:
	# disegna_salto, un pezzo alla volta: le scritte entrano, il 7 cade e
	# arriva l'8, la carta del perche' entra girando, e ogni riga cresce
	var p := tempo - momento_a
	P.lastra(t, PackedVector2Array([Vector2(-20, -20), Vector2(560, -20), Vector2(420, 740), Vector2(-20, 740)]), P.NERO,
			P.CREMA, 16.0)
	retino_a_salire(t, Rect2(0, 330, 470, 390), Color(P.ARANCIO, 0.5))
	P.etichetta(t, Vector2(36 + entra_da_sinistra(p, 0.05), 40), "ANONIMO", 22, P.ARANCIO, P.NERO, P.CREMA)
	P.scritta(t, Vector2(40 + entra_da_sinistra(p, 0.12), 140), "SALE AL", 30, P.CARTA)
	P.scritta(t, Vector2(40 + entra_da_sinistra(p, 0.2), 208), "LIVELLO", 72, P.CREMA)
	# il numero: c'e' il 7, cade giu'; dall'alto arriva l'8, batte e trema
	var cade := clampf((p - 0.5) / 0.28, 0.0, 1.0)
	if cade < 1.0:
		P.ritagliata(t, Vector2(26, 610 + 760.0 * cade * cade), str(LIVELLO), 430, P.CREMA, P.NERO, 14, P.TRATTO, Vector2(16, 16))
	var arriva := clampf((p - 0.62) / 0.4, 0.0, 1.0)
	if arriva > 0.0:
		var trema := Vector2(sin(p * 83.0), cos(p * 71.0)) * 10.0 * (1.0 - clampf((p - 1.02) / 0.3, 0.0, 1.0)) \
				if p >= 1.02 else Vector2.ZERO
		P.ritagliata(t, Vector2(26, 610 - 760.0 * (1.0 - rimbalza(arriva))) + trema, str(LIVELLO + 1), 430, P.ARANCIO, P.NERO,
				14, P.CREMA, Vector2(16, 16))
		raggi_del_colpo(t, Vector2(150, 455), clampf((p - 1.02) / 0.45, 0.0, 1.0), 170.0, P.CREMA)
	P.scritta(t, Vector2(320, 600), "DI 20", 26, velo(P.CARTA, clampf((p - 1.1) / 0.3, 0.0, 1.0)))
	# la carta del perche', da destra
	var carta := rimbalza(clampf((p - 0.4) / 0.55, 0.0, 1.0))
	P.gira(t, Vector2(598 + 820.0 * (1.0 - carta), 92), lerpf(-16.0, -2.5, carta))
	P.cartoncino(t, Rect2(0, 0, 640, 470), P.CREMA, 5.0, Vector2(12, 12), true)
	P.etichetta(t, Vector2(22, -22), "COSA HAI FATTO, E COSA TI HA DATO", 18, P.NERO, P.CREMA)
	var y := 52.0
	var i := 0
	for voce: Dictionary in cresciute():
		# ogni riga: compare, crescono le azioni, poi (se c'e') la strada
		var da := 1.15 + 0.5 * i
		var comparsa := clampf((p - da) / 0.22, 0.0, 1.0)
		var azioni_fatte := frena(clampf((p - da - 0.12) / 0.4, 0.0, 1.0))
		var strada_fatta := frena(clampf((p - da - 0.5) / 0.3, 0.0, 1.0))
		y += riga_cresciuta(t, voce, Vector2(30, y), 580.0, false, true, azioni_fatte, strada_fatta, comparsa) + 4.0
		i += 1
	P.dritto(t)
	var fascia := frena(clampf((p - 3.4) / 0.35, 0.0, 1.0))
	if fascia <= 0.0:
		return
	P.gira(t, Vector2(760 + 700.0 * (1.0 - fascia), 618), -2.5)
	t.draw_rect(Rect2(6, 6, 480, 44), P.NERO)
	t.draw_rect(Rect2(0, 0, 480, 44), P.ARANCIO)
	t.draw_rect(Rect2(0, 0, 480, 44), P.NERO, false, 3.0)
	var x := 16.0 + P.scritta_larga(t, Vector2(16, 31), "POI ARRIVA", 20, P.NERO)
	P.rombo(t, Vector2(x + 26, 22), 17.0, P.NERO)
	S.disegna(t, simbolo_di("abilita", ARRIVA), Vector2(x + 26, 22), 22.0, P.ARANCIO, P.NERO)
	P.scritta(t, Vector2(x + 52, 32), String(abilita(ARRIVA).get("nome", ARRIVA)).to_upper() + "  ▸", 24, P.NERO)
	P.dritto(t)


static func entra_da_sinistra(p: float, da: float) -> float:
	return -460.0 * (1.0 - frena(clampf((p - da) / 0.3, 0.0, 1.0)))


func carta_animata(t: CanvasItem) -> void:
	# disegna_arriva in movimento: i raggi girano piano, la carta sale dal
	# basso girando, batte (un lampo), e un riflesso la attraversa
	var p := tempo - momento_a
	raggiera(t, Vector2(640, 380), 28, P.BRUNO, P.NERO, p * 0.12)
	P.scritta(t, Vector2(46 + entra_da_sinistra(p, 0.25), 300), "ARRIVA", 62, P.CREMA)
	P.ritagliata(t, Vector2(46 + entra_da_sinistra(p, 0.33), 362), "UN'ABILITÀ", 46, P.ARANCIO, P.NERO, 10, P.NERO, Vector2(5, 5))
	P.scritta(t, Vector2(48 + entra_da_sinistra(p, 0.41), 398), "al livello %d, con qualunque strada" % (LIVELLO + 1), 16,
			P.CARTA, Caratteri.tondo(800))
	var vola := rimbalza(clampf((p - 0.15) / 0.55, 0.0, 1.0))
	carta_abilita(t, Vector2(650, lerpf(1120.0, 384.0, vola)), lerpf(26.0, -4.0, vola), lerpf(0.7, 1.0, vola),
			clampf((p - 0.95) / 0.55, 0.0, 1.0))
	var lampo := clampf((p - 0.7) / 0.2, 0.0, 1.0)
	if lampo > 0.0 and lampo < 1.0:
		t.draw_rect(Rect2(0, 0, 1280, 720), Color(P.CREMA, 0.22 * (1.0 - lampo)))
	var destra := clampf((p - 1.1) / 0.3, 0.0, 1.0)
	P.scritta(t, Vector2(916, 300), "DOVE LA TROVI", 14, velo(P.CARTA, destra), Caratteri.tondo(900))
	P.a_capo(t, Rect2(916, 308, 330, 80), "In combattimento, fra le abilità di Anonimo. Da adesso c'è sempre.", 18,
			velo(P.CREMA, destra), Caratteri.tondo(800))
	var sotto_ancora := clampf((p - 1.3) / 0.3, 0.0, 1.0)
	P.scritta(t, Vector2(916, 420), "PERCHÉ È ARRIVATA", 14, velo(P.CARTA, sotto_ancora), Caratteri.tondo(900))
	P.a_capo(t, Rect2(916, 428, 330, 80), "Non si sceglie e non costa punti: arriva da sola, al suo livello.", 18,
			velo(P.CREMA, sotto_ancora), Caratteri.tondo(800))
