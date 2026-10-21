class_name FuocoPerso
extends RefCounted
# LA FINESTRA PERDE IL FUOCO, IL GIOCO SI FERMA. Un alt-tab, una notifica che
# ruba la finestra, un clic sull'editor: il gioco continuava a correre senza
# nessuno davanti, e una scelta a tempo scadeva, un colpo di grazia si perdeva.
# Solo dove ESC aprirebbe la pausa, e si spegne nelle opzioni (Grafica).
#
# MA SI FERMA COM'E', e il menu compare quando torni. Prima la pausa si apriva
# subito, sopra lo schermo: e lo Strumento di cattura, che il fuoco lo prende,
# fotografava il menu. Bru, due volte: «non riesco a farti screen» e «quando
# apro lo snipping tool va in menu di pausa e perdo la schermata in cui ero».
# Adesso, finche' sei fuori, lo schermo resta quello di prima (si ferma solo il
# tempo); al ritorno trovi la pausa aperta e decidi tu quando ripartire. F12
# resta (Foto.gd): fa la foto da dentro.
#
# Lo usa Pausa.gd, che riceve gli avvisi della finestra.

var pausa                  # il menu di pausa (l'autoload Pausa)
var fermo := false         # fermo perche' la finestra ha perso il fuoco: il menu arriva al ritorno


func _init(menu_di_pausa: Node) -> void:
	pausa = menu_di_pausa


func notifica(cosa: int) -> void:
	if cosa == Node.NOTIFICATION_APPLICATION_FOCUS_OUT:
		ferma_senza_menu()
	elif cosa == Node.NOTIFICATION_APPLICATION_FOCUS_IN:
		al_ritorno()


func ferma_senza_menu() -> void:
	# il tempo si ferma, lo schermo no: niente velo, niente menu, niente
	# sfocatura. Se e' gia' fermo (la pausa aperta con ESC) non si tocca niente
	var albero: SceneTree = pausa.get_tree()
	if not Impostazioni.pausa_fuori or fermo or albero.paused or not pausa.pausabile():
		return
	fermo = true
	albero.paused = true


func al_ritorno() -> void:
	# tornato il fuoco, la pausa che il gioco si era presa diventa il menu
	if not fermo:
		return
	fermo = false
	if pausa.pausabile():
		pausa.apri()
	else:
		pausa.get_tree().paused = false
