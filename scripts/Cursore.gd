extends Node

# IL CURSORE NON SI PERDE.
#
# Bru: «a volte sul menu principale il cursore sparisce, e torna appena la
# schermata si chiude». Il gioco non nasconde mai il mouse (non c'e' un solo
# mouse_mode nel codice, e le forme che usa - freccia, manina, presa - sono
# tutte visibili). La causa sta sotto, nel motore, e si legge nel sorgente di
# Godot 4.7 (platform/windows/display_server_windows.cpp):
#
#   - la finestra non ha un cursore suo (wc.hCursor = nullptr);
#   - Godot chiama SetCursor solo quando la FORMA cambia (cursor_set_shape
#     esce subito se e' la stessa), quando il mouse rientra nella finestra, o
#     quando cambia il mouse_mode.
#
# Se qualcosa fuori dal gioco spegne il cursore mentre la freccia e' gia'
# dentro la finestra (l'editor, che col gioco incorporato nella vista «Game»
# ne divide l'input; o il sistema), Godot non lo riaccende finche' la forma
# non cambia o il mouse non esce e rientra. Sul menu principale niente la
# cambia: le voci non hanno la manina. Chi spenga il cursore, da qui non si
# vede; che poi resti spento, si'.
#
# Qui il gioco glielo ridice da se': quando il menu si apre, quando la
# finestra riprende il fuoco, quando il mouse rientra, e a ogni movimento (al
# piu' due volte al secondo) ripassa per un'altra forma e torna a quella di
# prima. Se il cursore c'era non cambia niente; se era spento, si riaccende.

const OGNI_MS := 500    # al piu' una ripassata ogni mezzo secondo di movimento

# il DisplayServer vero; le prove ne passano uno finto che si segna le chiamate
# (in --headless il DisplayServer non fa niente, e una prova lo saprebbe solo
# fidandosi)
var schermo: Object = DisplayServer
var ultima_ripassata := -OGNI_MS


func _ready() -> void:
	# anche a gioco in pausa: il menu della pausa e' fatto di mouse
	process_mode = Node.PROCESS_MODE_ALWAYS


func _notification(cosa: int) -> void:
	if cosa in [NOTIFICATION_APPLICATION_FOCUS_IN, NOTIFICATION_WM_WINDOW_FOCUS_IN, NOTIFICATION_WM_MOUSE_ENTER]:
		rimetti()


func _input(evento: InputEvent) -> void:
	if evento is InputEventMouseMotion and Time.get_ticks_msec() - ultima_ripassata >= OGNI_MS:
		ripassa_la_forma()


func rimetti() -> void:
	# il mouse si vede, e la forma viene ridetta al sistema
	if schermo.mouse_get_mode() != DisplayServer.MOUSE_MODE_VISIBLE:
		schermo.mouse_set_mode(DisplayServer.MOUSE_MODE_VISIBLE)
	ripassa_la_forma()


func ripassa_la_forma() -> void:
	# cursor_set_shape con la forma che c'e' gia' non arriva al sistema: si
	# passa da un'altra e si torna. Le due chiamate cadono nello stesso
	# fotogramma, e a schermo resta solo l'ultima. Dalla freccia si passa per
	# CAN_DROP, che su Windows e' la stessa freccia (IDC_ARROW)
	ultima_ripassata = Time.get_ticks_msec()
	var forma: int = schermo.cursor_get_shape()
	var altra := DisplayServer.CURSOR_CAN_DROP if forma == DisplayServer.CURSOR_ARROW else DisplayServer.CURSOR_ARROW
	schermo.cursor_set_shape(altra)
	schermo.cursor_set_shape(forma)
