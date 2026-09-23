class_name VoceMenu
extends Control

# UNA VOCE DI MENU CHE REAGISCE. E' il pezzo che si ripete su ogni schermata -
# pausa, menu principale, Sede, negozio - quindi il movimento si decide qui una
# volta, e ogni schermata lo eredita uguale (Carbon, «semantic consistency»).
#
# COM'E' FATTA, e ognuna delle tre cose risponde a un pilastro del disegno:
#
#   la LASTRA   dietro la voce accesa: un parallelogramma cremisi, coi lati
#               tagliati in obliquo e inclinato come il nastro (-3,5 gradi),
#               con sotto una sfoglia bianca che sporge di qualche pixel. Carta
#               ritagliata e sovrapposta: e' il rosso, nero e bianco a strati di
#               Persona 5, fatto con i colori di Carnivalz
#   il TESTO    rosso quando la voce e' spenta (e' cosi' nel disegno di Bru),
#               bianco sulla lastra quando e' accesa
#   il SEGNO    a sinistra, in una corsia sua: il testo parte sempre dalla
#               stessa x
#
# COME SI MUOVE (i gesti sono in Movimento.gd):
#
#   entra     scivola da sinistra e si accende, al suo turno nella cascata
#   sfioro    la lastra si srotola da sinistra e la voce avanza di un passo;
#             forma e colore su due molle diverse, come fa Material. Il mouse
#             e la tastiera sono LA STESSA COSA: passarci sopra col puntatore
#             le da' il fuoco, cosi' non ci sono mai due voci accese
#   pressione la gelatina (la X e poi la Y) quando premi, un lampo bianco e
#             uno scoppio di schegge quando rilasci - che e' il momento in cui
#             il clic vale
#   rifiuto   la scossa, per la voce che adesso non si puo' scegliere
#
# PERCHE' LA VOCE STA SU UN BINARIO SUO. Questo nodo e' il binario: sta nella
# colonna del menu e prende la misura che la colonna gli da', mentre il bottone
# ci sta sopra libero. Non e' una complicazione per gusto: un contenitore di
# Godot, a ogni riordino, rimette a posto la posizione dei figli E ANCHE la
# scala e la rotazione (Container::fit_child_in_rect, nel sorgente 4.4:
# set_rotation(0) e set_scale(1, 1)). Una voce animata direttamente dentro la
# colonna verrebbe raddrizzata a ogni riordino. Sul binario no.
#
# NON SI ASPETTA MAI. La voce e' cliccabile dal primo fotogramma, anche mentre
# e' ancora trasparente e sta arrivando: l'animazione racconta, non sbarra.
#
# IL MOVIMENTO RIDOTTO spegne gli spostamenti, non le informazioni: le voci
# compaiono dissolvendosi, sul posto; la lastra c'e' lo stesso, ma senza
# srotolarsi; il rifiuto non scuote, lampeggia di rosso e suona.

signal scoppio(dove: Vector2)

const SPAZIO_SEGNO := 48       # la corsia del segno: il testo parte sempre da qui
const LATO_SEGNO := 30.0
const MARGINE_DESTRO := 16
const MARGINE_VERTICALE := 8
const ENTRA_DA := -48.0        # da quanti pixel a sinistra arriva
const SPORGE := 24.0           # di quanto la lastra comincia prima della voce
const TAGLIO := 0.35           # i lati obliqui: per ogni pixel d'altezza, tanto di lato
const SFOGLIA := Vector2(6, 5) # dove sta la sfoglia bianca, sotto quella rossa
const LAMPO := 0.07            # il bianco della pressione (Carbon, fast-01)
const COLORI_TESTO := ["font_color", "font_hover_color", "font_pressed_color",
		"font_focus_color", "font_hover_pressed_color", "font_disabled_color"]

var bottone: Button
var segno: Segno
var ritardo := 0.0
var orologio := -1.0           # da quanto e' cominciata la cascata; < 0 = gia' entrata
var entrata := 1.0             # quanto e' entrata, 0..1, gia' passato per la curva
var accesa: Movimento.Molla    # la forma: 0 spenta, 1 accesa
var tinta: Movimento.Molla     # il colore: 0 rosso su nero, 1 bianco su rosso
var premuta := -1.0            # secondi dalla pressione; < 0 = no
var rifiutata := -1.0
var lampo := 0.0
var silenzio := false
# UNA VOCE INERTE si puo' sfiorare ma premerla non fa niente: e' la sezione del
# Diario in cui sei gia', l'oggetto del negozio che non ti puoi permettere.
# Premuta, non finge una conferma: dice di no (rifiuta)
var inerte := false
var ultima_tinta := Color(0, 0, 0, 0)


static func nuova(nome_segno: String, testo: String, corpo := 0) -> VoceMenu:
	# nome_segno "" = nessun segno, ma la corsia resta: il testo parte sempre
	# dalla stessa x, anche in un elenco dove solo una voce ha il segno
	var voce := VoceMenu.new()
	voce.costruisci(nome_segno, testo, corpo if corpo > 0 else Stile.dimensione("sezione"))
	return voce


func costruisci(nome_segno: String, testo: String, corpo: int) -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	accesa = Movimento.molla("forma")
	tinta = Movimento.molla("colore")
	bottone = Button.new()
	bottone.text = testo
	bottone.alignment = HORIZONTAL_ALIGNMENT_LEFT
	bottone.autowrap_mode = TextServer.AUTOWRAP_OFF
	Stile.imposta_corpo(bottone, corpo)
	# niente riquadro, niente cornice del fuoco: a dire dove sei c'e' la lastra,
	# che si vede molto di piu' di un filetto bianco
	for stato in ["normal", "hover", "pressed", "focus", "disabled", "hover_pressed"]:
		var vuota := StyleBoxEmpty.new()
		vuota.content_margin_left = SPAZIO_SEGNO
		vuota.content_margin_right = MARGINE_DESTRO
		vuota.content_margin_top = MARGINE_VERTICALE
		vuota.content_margin_bottom = MARGINE_VERTICALE
		bottone.add_theme_stylebox_override(stato, vuota)
	add_child(bottone)
	segno = Segno.nuovo(nome_segno, Stile.colore("accento"), LATO_SEGNO)
	segno.visible = nome_segno != ""
	bottone.add_child(segno)
	colora(0.0)
	bottone.minimum_size_changed.connect(func() -> void:
		update_minimum_size()
		impagina())
	bottone.mouse_entered.connect(sfiorata)
	bottone.focus_entered.connect(accendi)
	bottone.focus_exited.connect(spegni)
	bottone.button_down.connect(giu)
	bottone.pressed.connect(premi)
	set_process(false)


func _get_minimum_size() -> Vector2:
	if bottone == null:
		return Vector2.ZERO
	var m := bottone.get_combined_minimum_size()
	return Vector2(m.x + Movimento.misura("scivolo") + SFOGLIA.x, m.y)


func _notification(cosa: int) -> void:
	if cosa == NOTIFICATION_RESIZED:
		impagina()


func _process(delta: float) -> void:
	avanza(delta)


func impagina() -> void:
	if bottone == null:
		return
	bottone.size = bottone.get_combined_minimum_size()
	bottone.position.y = floorf((size.y - bottone.size.y) * 0.5)
	# il perno al centro, ricalcolato a ogni misura nuova: col perno di serie
	# (l'angolo in alto a sinistra) la gelatina gonfierebbe la voce verso destra
	bottone.pivot_offset = bottone.size * 0.5
	segno.size = Vector2(LATO_SEGNO, LATO_SEGNO)
	segno.position = Vector2(floorf((SPAZIO_SEGNO - LATO_SEGNO) * 0.5) - 4.0,
			floorf((bottone.size.y - LATO_SEGNO) * 0.5))
	applica()


# --- i gesti ------------------------------------------------------------------

func entra(quando: float) -> void:
	# comincia a entrare fra "quando" secondi: lo decide chi fa la cascata
	ritardo = quando
	orologio = 0.0
	entrata = 0.0
	applica()
	set_process(true)


func sfiorata() -> void:
	if not bottone.has_focus():
		bottone.grab_focus()


func accendi() -> void:
	accesa.obiettivo = 1.0
	tinta.obiettivo = 1.0
	if Movimento.ridotto():
		accesa.salta_a(1.0)
		tinta.salta_a(1.0)
	if not silenzio:
		Movimento.suona("sfioro")
	sveglia()


func spegni() -> void:
	accesa.obiettivo = 0.0
	tinta.obiettivo = 0.0
	if Movimento.ridotto():
		accesa.salta_a(0.0)
		tinta.salta_a(0.0)
	sveglia()


func prendi_il_fuoco_in_silenzio() -> void:
	# la voce che ha il fuoco quando il menu si apre: si accende, ma senza il
	# tocco - non l'ha sfiorata nessuno, e sopra c'e' gia' il suono dell'apertura
	silenzio = true
	bottone.grab_focus()
	silenzio = false


func giu() -> void:
	if not Movimento.ridotto() and not inerte:
		premuta = 0.0
		sveglia()


func premi() -> void:
	if inerte:
		rifiuta()
		return
	Movimento.suona("pressione")
	lampo = LAMPO
	scoppio.emit(segno.get_global_rect().get_center())
	sveglia()


func rifiuta() -> void:
	# la voce che adesso non si puo' scegliere: dice di no, e lo dice subito
	Movimento.suona("rifiuto")
	lampo = LAMPO
	if not Movimento.ridotto():
		rifiutata = 0.0
	sveglia()


func sveglia() -> void:
	applica()
	set_process(true)


# --- il tempo -------------------------------------------------------------------

func avanza(dt: float) -> void:
	if orologio >= 0.0:
		orologio += dt
		var durata := Movimento.durata("colore" if Movimento.ridotto() else "voce")
		var u := clampf((orologio - ritardo) / durata, 0.0, 1.0)
		entrata = Movimento.curva("entrata", u)
		if u >= 1.0:
			orologio = -1.0
			entrata = 1.0
	accesa.passo(dt)
	tinta.passo(dt)
	premuta = scorri(premuta, dt, Movimento.durata_gelatina())
	rifiutata = scorri(rifiutata, dt, Movimento.durata_scossa())
	lampo = maxf(lampo - dt, 0.0)
	applica()
	set_process(in_moto())


func scorri(orologio_gesto: float, dt: float, fine: float) -> float:
	if orologio_gesto < 0.0:
		return orologio_gesto
	var dopo := orologio_gesto + dt
	return dopo if dopo < fine else -1.0


func in_moto() -> bool:
	return orologio >= 0.0 or not accesa.ferma() or not tinta.ferma() \
			or premuta >= 0.0 or rifiutata >= 0.0 or lampo > 0.0


func applica() -> void:
	if bottone == null:
		return
	var arrivo := 0.0 if Movimento.ridotto() else ENTRA_DA * (1.0 - entrata)
	var scossa := Movimento.scossa(rifiutata) if rifiutata >= 0.0 else 0.0
	bottone.position.x = arrivo + Movimento.misura("scivolo") * accesa.valore + scossa
	bottone.modulate.a = entrata
	bottone.scale = Vector2.ONE + (Movimento.gelatina(premuta) if premuta >= 0.0 else Vector2.ZERO)
	colora(tinta.valore)
	queue_redraw()


func colora(quanto: float) -> void:
	# durante il lampo la lastra diventa bianca: il testo torna rosso, se no per
	# settanta millesimi sarebbe bianco su bianco
	var c := Stile.colore("accento").lerp(Stile.colore("testo"), clampf(quanto, 0.0, 1.0))
	if lampo > 0.0:
		c = Stile.colore("accento")
	if c == ultima_tinta:
		return
	ultima_tinta = c
	for stato in COLORI_TESTO:
		bottone.add_theme_color_override(stato, c)
	segno.tinta = c
	segno.queue_redraw()


# --- il disegno -------------------------------------------------------------------

func _draw() -> void:
	# la lastra fa parte della voce: se la voce sta ancora arrivando, la lastra
	# arriva con lei - la principale ha il fuoco da subito ma entra per ultima
	var quanto := accesa.valore * entrata
	if quanto <= 0.002 and lampo <= 0.0:
		return
	var alto := bottone.position.y
	var h := bottone.size.y
	var piena := bottone.position.x + bottone.size.x
	var destra := lerpf(-SPORGE, piena, clampf(maxf(quanto, 1.0 if lampo > 0.0 else 0.0), 0.0, 1.2))
	var centro := Vector2((piena - SPORGE) * 0.5, alto + h * 0.5)
	draw_set_transform(centro, Stile.angolo("inclinazione_nastro"))
	var sinistra := -SPORGE - centro.x
	var fine := destra - centro.x
	draw_colored_polygon(lastra(sinistra + SFOGLIA.x, fine + SFOGLIA.x, -h * 0.5 + SFOGLIA.y, h),
			Color(Stile.colore("bordo_acceso"), clampf(tinta.valore * entrata, 0.0, 1.0)))
	var rosso := Stile.colore("accento").lerp(Stile.colore("bordo_acceso"), 1.0 if lampo > 0.0 else 0.0)
	draw_colored_polygon(lastra(sinistra, fine, -h * 0.5, h), rosso)
	draw_set_transform(Vector2.ZERO)


static func lastra(sinistra: float, destra: float, alto: float, h: float) -> PackedVector2Array:
	# un parallelogramma coi lati tagliati in avanti, come una lettera corsiva:
	# spinge l'occhio nella direzione in cui si legge
	var obliquo := TAGLIO * h
	var fine := maxf(destra, sinistra)
	return PackedVector2Array([
		Vector2(sinistra + obliquo, alto), Vector2(fine + obliquo, alto),
		Vector2(fine, alto + h), Vector2(sinistra, alto + h)])


# --- per chi guarda da fuori (le prove) ----------------------------------------------

func quota_visibile() -> float:
	return bottone.modulate.a
