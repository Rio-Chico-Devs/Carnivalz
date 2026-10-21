class_name LuceBond
extends Control
# LA LUCE DEL BOND: quando medi, la purificazione si vede a tutto schermo.
#
# Bru, sulle proposte: «solo la scritta animata in modo angelico e pacifico
# tipo purificazione»; poi, sulla purificazione: «va migliorato manipolando
# ogni singola lettera e anche mettendoci più lavoro nelle animazioni»; e,
# vista quella lettera per lettera: «si dai mettila» (docs/vita.md).
#
# Il BOND e' la mediazione: la creatura non la abbatti, la liberi da quello che
# l'ha deformata. Quindi la luce lava, e ogni lettera nasce dalla luce:
#   1. l'ONDA sale dal basso, col bordo che ondeggia come la marea, e lava lo
#      scontro: ne resta un fantasma color crema, sfocato (bond_lavaggio)
#   2. ogni LETTERA ha i suoi tempi (prima la O, poi la N, la B, la D) e arriva
#      da una posa sua, un poco girata, piu' bassa e piu' in fuori. La luce sale
#      lungo il suo contorno vero (LetteraBond, TracceBond, ScintilleBond), la
#      lettera si riempie dal basso come un vaso, si raffredda in oro, si
#      raddrizza e si posa
#   3. sotto si apre la RIGA (RigaBond), il rombo arriva girando di un quarto,
#      due comete corrono alle punte
#   4. passa un RIFLESSO, e ogni lettera si accende quando la tocca; poi
#      respirano piano, ognuna col suo passo
#   5. le lettere SALGONO una alla volta, da sinistra, e si sciolgono in luce;
#      la riga si ritira nel rombo, e una seconda onda porta via la luce
#
# IL MONDO ASPETTA. Finche' la luce copre (copre()), Combattimento._process
# non fa passare niente - turni, barre, Mattanza - e VoceCombattimento non fa
# leggere: il racconto della mediazione comincia quando la luce se n'e' andata.
# Lei invece si fa avanzare da sola, col suo _process: se dipendesse dallo
# scontro, e lo scontro aspettasse lei, resterebbero fermi tutti e due. Il primo
# tasto o clic la salta: se ne va in un quarto di secondo, senza strappi. Col
# movimento ridotto niente onde e niente lettere in volo: la parola d'oro
# compare e sparisce sul posto.

signal finito

const DURATA := 3.5
const DURATA_RIDOTTA := 1.4
const SFUMA := 0.25          # quanto ci mette ad andarsene quando la salti
const PAROLA := "BOND"
# ogni lettera ha i suoi tempi e la sua posa d'arrivo
const NASCE := [0.62, 0.4, 0.5, 0.72]       # quando la luce comincia a salirle addosso
const GIRO := [-0.06, 0.045, -0.04, 0.06]   # quanto e' girata, prima di posarsi
const FUORI := [-12.0, -4.0, 4.0, 12.0]     # quanto e' spostata in fuori
const SALE := [2.3, 2.38, 2.46, 2.54]       # quando se ne va, da sinistra
const RIFLESSO := 1.75                      # quando passa il riflesso
const TORNA := 2.75                         # quando la seconda onda porta via la luce
const LAVAGGIO := preload("res://shaders/bond_lavaggio.gdshader")
const DORATURA := preload("res://shaders/bond_doratura.gdshader")

static var aperta: LuceBond = null   # quella che sta coprendo lo scontro adesso

var orologio := 0.0
var in_corso := false
var ridotto := false
var saltata := -1.0          # da quanto la stai saltando (-1: non la stai saltando)
var lato := Vector2(1280, 720)
var con_foto := 0.0          # 1 se sotto la luce c'e' la foto dello scontro (fotografa)
var corpo := 120
var velo: ShaderMaterial
var lettere: Array[LetteraBond] = []
var dorature: Array[ShaderMaterial] = []
var tracce: TracceBond
var scintille: ScintilleBond
var ornamento: RigaBond
var oro_ornamento: ShaderMaterial
var posto_ornamento := Vector2.ZERO
var largo_riga := 0.0


static func sullo_scontro(scontro: Combattimento) -> LuceBond:
	# solo dove c'e' uno schermo e il tempo scorre: da muti (il simulatore, le
	# prove) non c'e' niente da guardare, e nessun _process a farla avanzare
	if not scontro.tempo_reale or scontro.muto:
		return null
	return apri(scontro)


static func apri(dove: Control) -> LuceBond:
	var luce := LuceBond.new()
	luce.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dove.add_child(luce)
	luce.costruisci(dove.size)
	aperta = luce
	return luce


static func copre() -> bool:
	return aperta != null and is_instance_valid(aperta) and aperta.in_corso


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP   # il clic che la salta e' suo
	ridotto = Movimento.ridotto()


func costruisci(schermo: Vector2) -> void:
	in_corso = true
	lato = schermo
	corpo = int(lato.y * 0.17)
	var centro := Vector2(lato.x * 0.5, lato.y * 0.47)
	var lavaggio := ColorRect.new()
	lavaggio.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lavaggio.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	velo = materiale(LAVAGGIO)
	velo.set_shader_parameter("centro", centro / lato)
	lavaggio.material = velo
	add_child(lavaggio)
	fotografa()
	var alto_basso := Vector2(centro.y - corpo * 0.35, centro.y + corpo * 0.35) / lato.y
	metti_le_lettere(centro, alto_basso)
	oro_ornamento = materiale(DORATURA, alto_basso)
	ornamento = RigaBond.new()
	ornamento.alto = corpo * 0.07
	posto_ornamento = Vector2(centro.x, centro.y + corpo * 0.65)
	ornamento.position = posto_ornamento
	gruppo_dorato(oro_ornamento).add_child(ornamento)
	var oro_tracce := materiale(DORATURA, alto_basso)
	oro_tracce.set_shader_parameter("bianco", 0.3)
	oro_tracce.set_shader_parameter("bagliore", 1.0)
	tracce = TracceBond.new()
	tracce.lettere = lettere
	gruppo_dorato(oro_tracce).add_child(tracce)
	# le punte di luce: quasi bianche, col bagliore largo
	var oro_scintille := materiale(DORATURA, alto_basso)
	oro_scintille.set_shader_parameter("bianco", 0.85)
	oro_scintille.set_shader_parameter("bagliore", 1.5)
	scintille = ScintilleBond.new()
	scintille.lettere = lettere
	scintille.riga = ornamento
	gruppo_dorato(oro_scintille).add_child(scintille)
	avanza(0.0)


func fotografa() -> void:
	# lo scontro com'era quando hai mediato: sotto la luce resta fermo cosi'
	# (bond_lavaggio). Senza finestra non c'e' niente da fotografare
	if DisplayServer.get_name() == "headless" or not is_inside_tree():
		return
	var immagine := get_viewport().get_texture().get_image()
	if immagine == null or immagine.is_empty():
		return
	immagine.generate_mipmaps()
	con_foto = 1.0
	velo.set_shader_parameter("foto", ImageTexture.create_from_image(immagine))
	velo.set_shader_parameter("con_foto", con_foto)


func metti_le_lettere(centro: Vector2, alto_basso: Vector2) -> void:
	# ognuna al suo posto: larga quanto dice il font, con l'aria fra l'una e
	# l'altra; ognuna nel suo gruppo, col suo oro
	var font := Caratteri.nomi()
	var spazio := corpo * 0.3
	var larghi: Array[float] = []
	var totale := spazio * float(PAROLA.length() - 1)
	for i in PAROLA.length():
		larghi.append(font.get_string_size(PAROLA[i], HORIZONTAL_ALIGNMENT_LEFT, -1, corpo).x)
		totale += larghi[i]
	largo_riga = totale * 0.5 + corpo * 0.5
	var x := centro.x - totale * 0.5
	for i in PAROLA.length():
		var oro := materiale(DORATURA, alto_basso)
		var lettera := LetteraBond.new(font, PAROLA[i], corpo, Vector2(x + larghi[i] * 0.5, centro.y), larghi[i])
		gruppo_dorato(oro).add_child(lettera)
		lettere.append(lettera)
		dorature.append(oro)
		x += larghi[i] + spazio


static func materiale(shader: Shader, alto_basso := Vector2.ZERO) -> ShaderMaterial:
	var fatto := ShaderMaterial.new()
	fatto.shader = shader
	if alto_basso != Vector2.ZERO:
		fatto.set_shader_parameter("alto_basso", alto_basso)
	return fatto


func gruppo_dorato(oro: ShaderMaterial) -> CanvasGroup:
	# il foglio in cui si disegna bianco e la doratura colora: largo abbastanza
	# da tenerci il bagliore
	var gruppo := CanvasGroup.new()
	gruppo.use_mipmaps = true
	gruppo.fit_margin = 120.0
	gruppo.clear_margin = 120.0
	gruppo.material = oro
	add_child(gruppo)
	return gruppo


# --- la mano ------------------------------------------------------------------

func _gui_input(evento: InputEvent) -> void:
	if evento is InputEventMouseButton and (evento as InputEventMouseButton).pressed:
		salta()
		accept_event()


func _input(evento: InputEvent) -> void:
	# il tasto che fa scorrere il testo la salta, e non arriva a nessun altro
	if in_corso and evento.is_action_pressed("ui_accept"):
		salta()
		get_viewport().set_input_as_handled()


func salta() -> void:
	# il primo tasto o clic la manda via: in fretta, ma sfumando
	if in_corso and saltata < 0.0:
		saltata = 0.0


func chiudi() -> void:
	in_corso = false
	if aperta == self:
		aperta = null
	finito.emit()
	queue_free()


# --- il tempo -----------------------------------------------------------------

func _process(delta: float) -> void:
	avanza(Tempo.passo(delta))   # dopo una sospensione non salta avanti di colpo


static func morbido(u: float) -> float:
	# comincia piano e finisce piano
	return 0.5 - 0.5 * cos(PI * clampf(u, 0.0, 1.0))


static func frena(u: float) -> float:
	# arriva e si posa
	return 1.0 - pow(1.0 - clampf(u, 0.0, 1.0), 3.0)


func fase(da: float, quanto: float) -> float:
	return morbido((orologio - da) / quanto)


func durata() -> float:
	return DURATA_RIDOTTA if ridotto else DURATA


func avanza(delta: float) -> void:
	if not in_corso:
		return
	if saltata >= 0.0:
		saltata += delta
		modulate.a = 1.0 - clampf(saltata / SFUMA, 0.0, 1.0)
		if saltata >= SFUMA:
			chiudi()
		return
	orologio += delta
	if ridotto:
		avanza_ridotto()
	else:
		onde()
		for i in lettere.size():
			muovi_lettera(i)
		muovi_ornamento()
	tracce.queue_redraw()
	scintille.queue_redraw()
	if orologio >= durata():
		chiudi()


func riflesso_x() -> float:
	return lerpf(0.15, 1.0, fase(RIFLESSO, 0.7))


func onde() -> void:
	var torna := fase(TORNA, DURATA - TORNA)
	velo.set_shader_parameter("fronte", lerpf(1.35, -0.4, fase(0.0, 1.15)))
	velo.set_shader_parameter("coda", lerpf(1.45, -0.45, torna))
	velo.set_shader_parameter("cresta", 0.75 * (1.0 - fase(0.65, 0.6)))
	velo.set_shader_parameter("scia", 0.6 * sin(torna * PI))
	velo.set_shader_parameter("quanto", 0.93)
	velo.set_shader_parameter("sogno", 2.6)
	velo.set_shader_parameter("alone", 0.45 * fase(0.35, 0.9) * (1.0 - fase(2.3, 0.6)))
	velo.set_shader_parameter("tempo", orologio)


func muovi_lettera(i: int) -> void:
	var lettera := lettere[i]
	var oro := dorature[i]
	var nasce := float(NASCE[i])
	# arriva dalla sua posa e si posa; se ne va salendo
	var arriva := frena(orologio - nasce)
	var parte := fase(float(SALE[i]), 0.55)
	lettera.position = lettera.posto + Vector2(float(FUORI[i]) * (1.0 - arriva), 22.0 * (1.0 - arriva) - 44.0 * parte)
	lettera.rotation = float(GIRO[i]) * (1.0 - arriva)
	lettera.scale = Vector2.ONE * (1.0 + 0.06 * (1.0 - arriva) + 0.04 * parte)
	# la luce sale lungo il contorno, poi la lettera si riempie dal basso
	lettera.traccia = fase(nasce, 0.55)
	lettera.traccia_luce = 1.0 - fase(nasce + 0.6, 0.35)
	var riempie := fase(nasce + 0.22, 0.55)
	var sotto := lettera.position.y + corpo * 0.38
	var sopra := lettera.position.y - corpo * 0.38
	oro.set_shader_parameter("riempi", lerpf(sotto, sopra, riempie) / lato.y if riempie < 1.0 else -1.0)
	lettera.luce = 1.0 - fase(float(SALE[i]) + 0.12, 0.4)
	lettera.queue_redraw()
	# piena e' ancora luce, poi si raffredda in oro; andando via torna luce
	oro.set_shader_parameter("bianco", maxf(0.5 * (1.0 - fase(nasce + 0.55, 0.55)), 0.9 * parte))
	oro.set_shader_parameter("sfoca", 16.0 * parte)
	oro.set_shader_parameter("lucido", riflesso_x())
	# il bagliore: forte appena piena, poi respira col suo passo; e quando il
	# riflesso la tocca si accende
	var piena := fase(nasce + 0.45, 0.35) * (1.0 - fase(nasce + 0.8, 0.6))
	var respiro := 0.08 * sin(orologio * 2.6 + float(i) * 1.3) * fase(nasce + 0.9, 0.5)
	var tocco := exp(-pow((riflesso_x() - lettera.position.x / lato.x) / 0.05, 2.0))
	oro.set_shader_parameter("bagliore", (0.45 + 0.7 * piena + respiro + 0.6 * tocco) * fase(nasce, 0.3) * (1.0 - parte))


func muovi_ornamento() -> void:
	# la riga si apre, il rombo arriva girando, due comete corrono alle punte;
	# alla fine la riga si ritira nel rombo, e il rombo sale con le lettere
	var chiude := fase(2.3, 0.4)
	var parte := fase(2.55, 0.45)
	var arriva := frena((orologio - 1.4) / 0.6)
	ornamento.mezza = largo_riga * fase(1.4, 0.7) * (1.0 - chiude)
	ornamento.rombo = arriva
	ornamento.giro_rombo = PI * 0.5 * (1.0 - arriva)
	ornamento.corsa = (orologio - 1.75) / 0.55
	ornamento.luce = 1.0 - parte
	ornamento.position = posto_ornamento + Vector2(0.0, -44.0 * parte)
	ornamento.queue_redraw()
	oro_ornamento.set_shader_parameter("bianco", maxf(0.5 * (1.0 - fase(1.6, 0.6)), 0.9 * parte))
	oro_ornamento.set_shader_parameter("sfoca", 16.0 * parte)
	oro_ornamento.set_shader_parameter("bagliore", 0.6 * (1.0 - parte))
	oro_ornamento.set_shader_parameter("lucido", riflesso_x())


func avanza_ridotto() -> void:
	# MOVIMENTO RIDOTTO: lo scontro si lava tutto insieme e la parola d'oro,
	# ferma e gia' posata, compare e sparisce sul posto
	var c := fase(0.0, 0.25) * (1.0 - fase(DURATA_RIDOTTA - 0.25, 0.25))
	velo.set_shader_parameter("fronte", -1.0)
	velo.set_shader_parameter("coda", 2.0)
	velo.set_shader_parameter("marea", 0.0)
	velo.set_shader_parameter("quanto", 0.93 * c)
	velo.set_shader_parameter("sogno", 2.6 * c)
	# la foto lascia il posto allo scontro di adesso mentre e' tutto lavato
	velo.set_shader_parameter("con_foto", con_foto * (1.0 - fase(DURATA_RIDOTTA - 0.5, 0.2)))
	velo.set_shader_parameter("alone", 0.45 * c)
	for i in lettere.size():
		lettere[i].luce = c
		lettere[i].traccia = 0.0
		lettere[i].queue_redraw()
		dorature[i].set_shader_parameter("bagliore", 0.45 * c)
	ornamento.mezza = largo_riga
	ornamento.rombo = 1.0
	ornamento.luce = c
	ornamento.queue_redraw()
	oro_ornamento.set_shader_parameter("bagliore", 0.6 * c)
