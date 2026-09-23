class_name LunaPark
extends Control

# IL FONDALE DEL MENU PRINCIPALE: un luna park di notte, disegnato.
#
# Nel riferimento di Bru (il menu di Borderlands 2) dietro le voci c'e' una
# scena vera - montagne, rocce, il mare - tutta in una famiglia di blu, piu'
# scura a sinistra dove stanno le scritte. Un disegno di Carnivalz per il menu
# non c'e' ancora; finche' non arriva, la scena e' questa: sagome in blu notte
# su un cielo che schiarisce verso l'orizzonte, una luna, la ruota panoramica
# che gira piano, il tendone, i fili di lampadine, la nebbia bassa.
#
# PROSPETTIVA AEREA, per dare profondita' senza un pixel di 3D: piu' una cosa
# e' lontana, piu' e' chiara e smorzata (la collina); piu' e' vicina, piu' e'
# scura e netta (lo steccato). E' come il riferimento separa i suoi piani.
#
# LA PARALLASSE: col mouse i piani si spostano di quantita' diverse, di piu'
# quelli vicini - come se la camera si muovesse di poco. Le voci del menu stanno
# ferme: sono l'interfaccia, non la scena.
#
# QUANDO ARRIVA IL DISEGNO VERO: art/menu/sfondo.png, e vince lui (con la
# parallasse leggera e la stessa vignettatura). Non c'e' niente da ricablare.
#
# Col movimento ridotto: la ruota e' ferma, le lampadine non tremano, la
# parallasse non c'e'. Il luna park resta tutto.

const DISEGNO := "res://art/menu/sfondo.png"
const RIFERIMENTO := Vector2(1280, 720)
const GIRO := 0.05                 # radianti al secondo: un giro in due minuti
const RUOTA := Vector2(1015, 330)
const RAGGIO_RUOTA := 205.0
const CABINE := 16
const LUNA := Vector2(720, 128)   # fra le voci e la ruota: dietro il pannello delle partite dava fastidio
const PROFONDITA := {"luna": 0.05, "colline": 0.15, "ruota": 0.35, "tendone": 0.5,
		"luci": 0.75, "terra": 1.0}

var giro := 0.0
var tempo := 0.0
var mira_x: Movimento.Molla
var mira_y: Movimento.Molla
var stelle: Array[Vector3] = []
var puntatore_finto := Vector2(-1.0, -1.0)
var disegno: Texture2D = null


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	mira_x = Movimento.molla("quinte")
	mira_y = Movimento.molla("quinte")
	var dado := RandomNumberGenerator.new()
	dado.seed = 20260923
	for i in 60:
		stelle.append(Vector3(dado.randf_range(0.0, 1280.0), dado.randf_range(0.0, 400.0),
				dado.randf_range(0.2, 0.7)))
	if ResourceLoader.exists(DISEGNO):
		disegno = load(DISEGNO)


func _process(delta: float) -> void:
	avanza(delta)


func avanza(dt: float) -> void:
	if not Movimento.ridotto():
		giro = fmod(giro + GIRO * dt, TAU)
		tempo += dt
	var mira := dove_mira()
	mira_x.obiettivo = mira.x
	mira_y.obiettivo = mira.y
	mira_x.passo(dt)
	mira_y.passo(dt)
	queue_redraw()


func dove_mira() -> Vector2:
	if Movimento.ridotto() or size.x <= 0.0:
		return Vector2.ZERO
	var dove := puntatore_finto if puntatore_finto.x >= 0.0 else get_local_mouse_position()
	var mezzo := size * 0.5
	return ((dove - mezzo) / mezzo).clamp(Vector2(-1, -1), Vector2(1, 1))


func strato(nome: String) -> void:
	# da qui in poi si disegna nelle coordinate del riferimento (1280x720), con
	# lo spostamento di parallasse di quel piano
	var scala := size / RIFERIMENTO
	var quanto := Movimento.misura("parallasse") * 1.5 * float(PROFONDITA.get(nome, 0.0))
	var spostamento := -Vector2(mira_x.valore, mira_y.valore) * quanto
	draw_set_transform(spostamento * scala, 0.0, scala)


func _draw() -> void:
	if size.x <= 0.0:
		return
	if disegno != null:
		strato("colline")
		draw_texture_rect(disegno, Rect2(Vector2(-32, -18), RIFERIMENTO + Vector2(64, 36)), false)
	else:
		cielo()
		strato("luna")
		luna()
		strato("colline")
		colline()
		nebbia(500.0, 60.0, 0.22)
		strato("ruota")
		ruota()
		strato("tendone")
		tendone()
		nebbia(600.0, 50.0, 0.18)
		strato("luci")
		fili_di_luci()
		strato("terra")
		terra()
	draw_set_transform(Vector2.ZERO, 0.0, size / RIFERIMENTO)
	vignetta()
	draw_set_transform(Vector2.ZERO)


# --- i piani, dal fondo --------------------------------------------------------

func cielo() -> void:
	draw_set_transform(Vector2.ZERO, 0.0, size / RIFERIMENTO)
	var alto := Stile.colore("menu_notte_alto")
	var basso := Stile.colore("menu_notte_basso")
	fascia(-60.0, 520.0, alto, basso)
	fascia(520.0, 780.0, basso, Stile.colore("menu_sagoma"))
	for i in stelle.size():
		var s := stelle[i]
		var luce := s.z * (0.75 + 0.25 * sin(tempo * 1.3 + float(i) * 2.1))
		draw_rect(Rect2(s.x, s.y, 2.0, 2.0), Color(Stile.colore("menu_luna"), luce))


func fascia(da: float, a: float, sopra: Color, sotto: Color) -> void:
	draw_polygon(PackedVector2Array([Vector2(-80, da), Vector2(1360, da), Vector2(1360, a), Vector2(-80, a)]),
			PackedColorArray([sopra, sopra, sotto, sotto]))


func luna() -> void:
	var chiara := Stile.colore("menu_luna")
	# l'alone: cerchi sempre piu' larghi e piu' tenui, che e' com'e' fatto un
	# bagliore quando non si ha uno shader per sfocarlo
	for anello: Array in [[3.4, 0.03], [2.5, 0.05], [1.8, 0.08], [1.3, 0.13]]:
		draw_circle(LUNA, 62.0 * float(anello[0]), Color(chiara, float(anello[1])))
	draw_circle(LUNA, 62.0, Color(chiara, 0.92))
	for macchia: Vector3 in [Vector3(-18, -12, 14), Vector3(16, 8, 10), Vector3(-6, 22, 7)]:
		draw_circle(LUNA + Vector2(macchia.x, macchia.y), macchia.z, Color(Stile.colore("menu_lontano"), 0.12))


func colline() -> void:
	var punti := PackedVector2Array()
	var x := -80.0
	while x <= 1360.0:
		punti.append(Vector2(x, 515.0 + 24.0 * sin(x * 0.006) + 12.0 * sin(x * 0.017 + 1.0)))
		x += 40.0
	punti.append(Vector2(1360, 780))
	punti.append(Vector2(-80, 780))
	draw_colored_polygon(punti, Stile.colore("menu_lontano"))
	# le tende lontane sulla cresta, piccole e chiare: la distanza si vede cosi'
	for cima: Vector2 in [Vector2(170, 490), Vector2(250, 500), Vector2(330, 486), Vector2(430, 498)]:
		draw_colored_polygon(PackedVector2Array([cima, cima + Vector2(22, 26), cima + Vector2(-22, 26)]),
				Stile.colore("menu_lontano").lightened(0.06))


func nebbia(y: float, alta: float, forza: float) -> void:
	var nulla := Color(Stile.colore("menu_nebbia"), 0.0)
	var piena := Color(Stile.colore("menu_nebbia"), forza)
	fascia(y - alta, y, nulla, piena)
	fascia(y, y + alta, piena, nulla)


func ruota() -> void:
	var nera := Stile.colore("menu_sagoma")
	# le gambe e la traversa: il cavalletto su cui gira
	draw_line(RUOTA, Vector2(905, 650), nera, 12.0)
	draw_line(RUOTA, Vector2(1125, 650), nera, 12.0)
	draw_line(Vector2(935, 570), Vector2(1095, 570), nera, 6.0)
	draw_arc(RUOTA, RAGGIO_RUOTA, 0.0, TAU, 96, nera, 7.0, true)
	draw_arc(RUOTA, RAGGIO_RUOTA * 0.9, 0.0, TAU, 96, nera, 3.0, true)
	draw_arc(RUOTA, 40.0, 0.0, TAU, 32, nera, 5.0, true)
	draw_circle(RUOTA, 14.0, nera)
	for i in CABINE:
		var angolo := giro + TAU * float(i) / float(CABINE)
		var bordo := RUOTA + Vector2.from_angle(angolo) * RAGGIO_RUOTA
		draw_line(RUOTA + Vector2.from_angle(angolo) * 14.0, bordo, nera, 3.0)
		# le cabine stanno sempre dritte, appese: e' quello che le fa sembrare
		# cabine e non denti di un ingranaggio
		draw_line(bordo, bordo + Vector2(0, 10), nera, 2.0)
		draw_rect(Rect2(bordo + Vector2(-11, 10), Vector2(22, 17)), nera)
	lampadine_su_un_cerchio(RUOTA, RAGGIO_RUOTA, 32, giro)


func lampadine_su_un_cerchio(centro: Vector2, raggio: float, quante: int, sfasamento: float) -> void:
	for j in quante:
		lampadina(centro + Vector2.from_angle(sfasamento + TAU * float(j) / float(quante)) * raggio, j)


func lampadina(dove: Vector2, indice: int) -> void:
	var luce := 0.7 + 0.3 * sin(tempo * 2.1 + float(indice) * 1.7)
	var colore := Stile.colore("menu_lampadina")
	draw_circle(dove, 7.0, Color(colore, 0.1 * luce))
	draw_circle(dove, 2.6, Color(colore, 0.85 * luce))


func tendone() -> void:
	var nera := Stile.colore("menu_sagoma")
	var chiara := Stile.colore("menu_sagoma_chiara")
	var cima := Vector2(690, 350)
	var gronda := 525.0
	# il tetto a spicchi, uno scuro e uno meno: le strisce del tendone
	var spicchi := 8
	for i in spicchi:
		var da := lerpf(505.0, 875.0, float(i) / float(spicchi))
		var a := lerpf(505.0, 875.0, float(i + 1) / float(spicchi))
		draw_colored_polygon(PackedVector2Array([cima, Vector2(a, gronda), Vector2(da, gronda)]),
				chiara if i % 2 == 0 else nera)
	# il festone sotto la gronda
	var x := 515.0
	while x <= 866.0:
		draw_circle(Vector2(x, gronda), 14.0, nera)
		x += 30.0
	draw_rect(Rect2(525, gronda, 330, 118), nera)
	for k in 6:
		draw_rect(Rect2(540 + k * 52, gronda + 14, 22, 104), chiara)
	draw_colored_polygon(PackedVector2Array([Vector2(690, 560), Vector2(726, 645), Vector2(654, 645)]),
			Stile.colore("menu_primo_piano"))
	draw_line(cima, cima + Vector2(0, -44), nera, 3.0)
	draw_colored_polygon(PackedVector2Array([cima + Vector2(0, -44), cima + Vector2(30, -36),
			cima + Vector2(0, -28)]), Stile.colore("menu_luna").darkened(0.35))
	for passo in 9:
		var t := float(passo + 1) / 10.0
		lampadina(cima.lerp(Vector2(505, gronda), t), passo)
		lampadina(cima.lerp(Vector2(875, gronda), t), passo + 20)


func fili_di_luci() -> void:
	for filo: Array in [[Vector2(560, -10), Vector2(1320, 70), 70.0], [Vector2(780, -20), Vector2(1320, 18), 40.0]]:
		var da: Vector2 = filo[0]
		var a: Vector2 = filo[1]
		var pancia := float(filo[2])
		var tratto := PackedVector2Array()
		for i in 25:
			var t := float(i) / 24.0
			tratto.append(da.lerp(a, t) + Vector2(0, pancia * 4.0 * t * (1.0 - t)))
		draw_polyline(tratto, Color(Stile.colore("menu_primo_piano"), 0.9), 1.5, true)
		for i in range(1, 24, 2):
			lampadina(tratto[i], i + int(pancia))


func terra() -> void:
	var nera := Stile.colore("menu_primo_piano")
	var punti := PackedVector2Array([Vector2(-80, 655)])
	var x := -80.0
	while x <= 1360.0:
		punti.append(Vector2(x, 652.0 + 6.0 * sin(x * 0.02)))
		x += 60.0
	punti.append(Vector2(1360, 780))
	punti.append(Vector2(-80, 780))
	draw_colored_polygon(punti, nera)
	# lo steccato: paletti e corda, il piano piu' vicino e piu' scuro
	var palo := 560.0
	while palo <= 1330.0:
		draw_rect(Rect2(palo, 608, 8, 48), nera)
		var corda := PackedVector2Array()
		for i in 9:
			var t := float(i) / 8.0
			corda.append(Vector2(palo + 4.0 + 56.0 * t, 616.0 + 10.0 * 4.0 * t * (1.0 - t)))
		draw_polyline(corda, nera, 3.0, true)
		palo += 56.0


# LA VIGNETTATURA, e quanto scurisce in ogni punto. Nel riferimento la parte
# sinistra e' un po' piu' scura del resto - le voci smorzate si leggono perche'
# dietro di loro c'e' poco - ma e' ancora blu, non nera: #2c465f, misurato. Il
# primo tentativo la faceva quasi nera, e la macchia d'inchiostro dietro la
# voce scelta spariva, nero su nero. La macchia si vede solo su un fondo che
# nero non e'.
const BUIO_SINISTRA := 0.35
const FINE_SINISTRA := 640.0
const BUIO_SOPRA := 0.4
const FINE_SOPRA := 170.0
const BUIO_SOTTO := 0.6
const INIZIO_SOTTO := 470.0


func vignetta() -> void:
	var buio := Stile.colore("menu_macchia")
	var niente := Color(buio, 0.0)
	draw_polygon(PackedVector2Array([Vector2(0, 0), Vector2(FINE_SINISTRA, 0), Vector2(FINE_SINISTRA, 720),
			Vector2(0, 720)]), PackedColorArray([Color(buio, BUIO_SINISTRA), niente, niente,
			Color(buio, BUIO_SINISTRA)]))
	fascia(-10.0, FINE_SOPRA, Color(buio, BUIO_SOPRA), niente)
	fascia(INIZIO_SOTTO, 730.0, niente, Color(buio, BUIO_SOTTO))


# --- per chi controlla che le scritte si leggano (le prove) ---------------------

func cielo_a(y: float) -> Color:
	# il colore del cielo a quest'altezza, nel riferimento 1280x720
	if y <= 520.0:
		return Stile.colore("menu_notte_alto").lerp(Stile.colore("menu_notte_basso"), clampf((y + 60.0) / 580.0, 0.0, 1.0))
	return Stile.colore("menu_notte_basso").lerp(Stile.colore("menu_sagoma"), clampf((y - 520.0) / 260.0, 0.0, 1.0))


func buio_a(punto: Vector2) -> float:
	# quanta vignettatura c'e' in un punto: le tre fasce si sommano come veli
	var sinistra := BUIO_SINISTRA * clampf(1.0 - punto.x / FINE_SINISTRA, 0.0, 1.0)
	var sopra := BUIO_SOPRA * clampf(1.0 - (punto.y + 10.0) / (FINE_SOPRA + 10.0), 0.0, 1.0)
	var sotto := BUIO_SOTTO * clampf((punto.y - INIZIO_SOTTO) / (730.0 - INIZIO_SOTTO), 0.0, 1.0)
	var passa := (1.0 - sinistra) * (1.0 - sopra) * (1.0 - sotto)
	return 1.0 - passa


func fondo_a(punto: Vector2) -> Color:
	# il cielo in quel punto con sopra la vignettatura: e' il fondo su cui sta
	# una scritta del menu dove non c'e' nessuna sagoma
	return cielo_a(punto.y).lerp(Stile.colore("menu_macchia"), buio_a(punto))
