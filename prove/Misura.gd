extends Node

# IL CRONOMETRO DELL'INTERFACCIA DI COMBATTIMENTO.
#
# Bru: «la performance non e' il massimo, non e' reattivo [...] tutto deve
# essere misurato e si deve essere sicuri che parta al tempo giusto».
#
# Le prove dicono se una cosa SUCCEDE. Non dicono QUANDO, ne' per quanto, ne'
# quante volte al secondo - e "non e' reattivo" e' esattamente una domanda di
# quando. Questo non e' una prova e non fallisce: fa girare uno scontro vero
# per qualche secondo campionando a ogni fotogramma, e poi stampa dei numeri.
#
#   ./prove/misura.sh              lo scontro del tutorial (Veronica)
#   ./prove/misura.sh marionetta   uno scontro normale
#
# Serve un display vero (xvfb-run basta): senza finestra il tempo reale non
# gira come gira davanti a un giocatore, e misurare il muto sarebbe misurare
# un altro gioco.

const SECONDI := 12.0

var campioni := 0
var con_menu_a_schermo := 0      # il menu e' la faccia in mostra
var menu_acceso_ma_coperto := 0  # puoi agire, e il menu NON si vede: click a vuoto
var con_testo_in_coda := 0
var tempo_fermo := 0
var facce: Dictionary = {}
var cambi_di_faccia := 0
var ultima_faccia := ""
var fotogramma_piu_lento := 0.0
const SOGLIA_SCATTO := 0.050   # 50 ms: due volte e mezzo un fotogramma a 60
var scatti: Array[Dictionary] = []
var rifacimenti: Array[String] = []
var chiuso_prima := false
var secondi_misurati := 0.0
var somma_fotogrammi := 0.0
# quante volte al secondo si rifanno le cose costose
var menu_prima := 0
var schede_prima := 0
var disegni_prima := 0
var hp_prima := 0
var hp_dopo := 0
var fasi: Dictionary = {}
var azioni_nemico := 0
# LA MISURA CHE CONTA DAVVERO: quanti click vanno a segno.
#
# Le altre dicono cosa c'e' a schermo. Questa preme. Ogni tanto si manda un
# click VERO - parse_input_event, la stessa porta da cui passa il mouse di Bru -
# sul primo bottone del menu, e si guarda se e' successo qualcosa. E' l'unico
# modo di rispondere a "il primo click e' andato a vuoto" con un numero.
# QUANTI FOTOGRAMMI ASPETTARE UNA RISPOSTA. Prima era uno solo, e "0 su 8"
# poteva voler dire sia "il gioco perde i click" sia "ho guardato troppo
# presto". Input.parse_input_event passa dal viewport e la risposta puo'
# arrivare uno o due fotogrammi dopo; dieci sono larghi ma onesti - se dopo
# dieci fotogrammi non e' successo niente, quel click e' perso davvero.
const FOTOGRAMMI_DI_GRAZIA := 10
var attesa_del_click := 0
var click_tentati := 0
var click_a_segno := 0
var battute_prima_del_click := 0
var click_in_volo := false
var modo_prima_del_click := ""

func _ready() -> void:
	var argomenti := OS.get_cmdline_user_args()
	var chi := String(argomenti[0]) if argomenti.size() > 0 else "veronica"
	GameState.nuova_partita()
	GameState.nemici_combattimento = [chi]
	var scontro: Node = load("res://scenes/Combattimento.tscn").instantiate()
	add_child(scontro)
	await get_tree().process_frame
	menu_prima = 0
	schede_prima = int(scontro.campo.aggiornamenti)
	disegni_prima = int(Disegni.ricerche)
	for c in scontro.combattenti:
		if c.giocatore:
			hp_prima += int(c.hp)
	# SI MISURA FINCHE' SI GIOCA. Misurando a tempo fisso, uno scontro che
	# finisce presto lasciava nove secondi di post mortem dentro le medie: la
	# marionetta uccideva il protagonista in tre secondi e poi lo strumento
	# contava altri nove secondi di fase "chiuso" come se fossero gioco - con
	# sessanta "scatti" che non erano lentezza dell'interfaccia, erano una
	# schermata di fine partita misurata come se fosse un combattimento.
	var fine := Time.get_ticks_msec() + int(SECONDI * 1000.0)
	while Time.get_ticks_msec() < fine and is_instance_valid(scontro) \
			and bool(scontro.in_corso):
		await get_tree().process_frame
		campiona(scontro)
	secondi_misurati = float(campioni) / 60.0
	if is_instance_valid(scontro) and not bool(scontro.in_corso):
		chiuso_prima = true
	if is_instance_valid(scontro):
		schede_fatte = int(scontro.campo.aggiornamenti) - schede_prima
		for c in scontro.combattenti:
			if c.giocatore:
				hp_dopo += int(c.hp)
		azioni_nemico = int(scontro.giro_corrente)
	disegni_fatti = int(Disegni.ricerche) - disegni_prima
	stampa(chi)
	get_tree().quit()

func campiona(scontro: Node) -> void:
	campioni += 1
	var quanto := get_process_delta_time()
	somma_fotogrammi += quanto
	# DOVE SCATTA, non solo quanto. Un massimo da solo non si puo' correggere:
	# dice che c'e' uno scatto, non cosa lo ha causato. Qui si tiene il ritratto
	# del mondo nel fotogramma piu' caro, e i piu' cari si stampano in fondo.
	if quanto > fotogramma_piu_lento:
		fotogramma_piu_lento = quanto
	if quanto > SOGLIA_SCATTO and scontro.plancia != null:
		scatti.append({
			"ms": 1000.0 * quanto,
			"al_secondo": float(campioni) / 60.0,
			"fase": String(scontro.fase_adesso()),
			"faccia": String(scontro.plancia.faccia_adesso),
			"in_coda": scontro.voce.coda.size(),
			"scrive": bool(scontro.voce.box.sta_scrivendo) if scontro.voce.box != null else false,
			"minigioco": bool(scontro.minigioco.attivo) if scontro.minigioco != null else false,
			"pugni": (scontro.minigioco.pugni.size() if scontro.minigioco != null else 0),
		})
	if scontro.plancia == null:
		return
	var faccia := String(scontro.plancia.faccia_adesso)
	facce[faccia] = int(facce.get(faccia, 0)) + 1
	if faccia != ultima_faccia:
		cambi_di_faccia += 1
		ultima_faccia = faccia
	var comandabile := faccia == "comandi" or faccia == "lista"
	if comandabile:
		con_menu_a_schermo += 1
	# IL NUMERO CHE CONTA, e la sua prima versione era sbagliata: guardava
	# menu_acceso, che e' uno dei booleani stantii che il sequenziatore ha
	# sostituito - restava vero mentre il giocatore NON poteva agire, e contava
	# come click a vuoto una cosa che era solo lettura.
	#
	# La domanda giusta e' un'altra: la FASE dice che tocca a te, e il pannello
	# mostra altro? Li' un click va a vuoto per davvero. Col sequenziatore deve
	# essere zero per costruzione, e se non lo e' e' un difetto.
	if scontro.has_method("fase_adesso") and String(scontro.fase_adesso()) == "comandi" \
			and not comandabile:
		menu_acceso_ma_coperto += 1
	if not scontro.voce.coda.is_empty():
		con_testo_in_coda += 1
	if not scontro.il_tempo_scorre():
		tempo_fermo += 1
	if scontro.has_method("fase_adesso"):
		var f := String(scontro.fase_adesso())
		fasi[f] = int(fasi.get(f, 0)) + 1
	# quante volte al secondo il menu si RICOSTRUISCE, e quando. Un bottone
	# rifatto fra la pressione e il rilascio non emette mai "pressed": il click
	# sparisce, ed e' esattamente «clicco e non succede niente»
	var ora: int = scontro.menu.ricostruzioni
	if ora != menu_prima:
		rifacimenti.append("%4.1fs  x%d  fase=%s  coda=%d" % [
				float(campioni) / 60.0, ora - menu_prima,
				String(scontro.fase_adesso()), scontro.voce.coda.size()])
		menu_prima = ora
	prova_un_click(scontro)

func prova_un_click(scontro: Node) -> void:
	# il fotogramma dopo un click si guarda se ha prodotto una battuta
	if click_in_volo:
		attesa_del_click -= 1
		if attesa_del_click <= 0:
			click_in_volo = false
		# "a segno" non vuol dire "ha attaccato": premere ATTACCHI apre una
		# lista, e quella e' una risposta buona quanto un colpo. Va a vuoto solo
		# un click a cui NON e' seguito niente
		if int(scontro.battute_del_giocatore) > battute_prima_del_click \
				or String(scontro.menu.modo) != modo_prima_del_click \
				or String(scontro.nome_azione_in_coda()) != "":
			click_a_segno += 1
			click_in_volo = false
		return
	# si preme solo quando un giocatore vero premerebbe: quando il menu c'e'
	if campioni % 8 != 0 or scontro.plancia == null:
		return
	var bottone := primo_bottone(scontro.plancia.comandi)
	if bottone == null or not bottone.is_visible_in_tree() or bottone.disabled:
		return
	click_tentati += 1
	battute_prima_del_click = int(scontro.battute_del_giocatore)
	modo_prima_del_click = String(scontro.menu.modo)
	click_in_volo = true
	attesa_del_click = FOTOGRAMMI_DI_GRAZIA
	var dove := bottone.get_global_rect().get_center()
	# PRIMA SI MUOVE IL CURSORE. Qui stava il difetto dello strumento: mandavo
	# solo la pressione, e Godot decide QUALE Control riceve un click dal
	# controllo sotto il mouse - che si aggiorna con il MOVIMENTO, non con la
	# pressione. Senza questa riga gui_get_hovered_control() e' nullo, il click
	# non arriva a nessuno, e lo strumento stampava "0 su 8" come se a perderli
	# fosse il gioco. Era lo strumento.
	var spostamento := InputEventMouseMotion.new()
	spostamento.position = dove
	spostamento.global_position = dove
	Input.parse_input_event(spostamento)
	for premuto in [true, false]:
		var evento := InputEventMouseButton.new()
		evento.button_index = MOUSE_BUTTON_LEFT
		evento.pressed = premuto
		evento.position = dove
		evento.global_position = dove
		Input.parse_input_event(evento)

func primo_bottone(dove: Node) -> Button:
	if dove == null:
		return null
	for figlio in dove.get_children():
		if figlio is Button:
			return figlio
		var dentro := primo_bottone(figlio)
		if dentro != null:
			return dentro
	return null

func quota(quanti: int) -> String:
	if campioni <= 0:
		return "n/d"
	return "%5.1f%%" % (100.0 * float(quanti) / float(campioni))

var schede_fatte := 0
var disegni_fatti := 0

func stampa(chi: String) -> void:
	# ATTENZIONE, E STA SCRITTO QUI PERCHE' NON SI USI UN NUMERO DI CUI NON CI
	# SI FIDA: la riga dei click e' ANCORA DA TARARE. Non so se un click finto
	# mandato con parse_input_event raggiunga davvero il bottone sotto xvfb, e
	# ADESSO E' TARATO, e come lo so: tarandolo ho trovato un difetto vero.
	# Lo strumento stampava "0 su 8" e io l'avevo marcato "non fidarsi". Due
	# cose erano rotte, una mia e una del gioco.
	#   1. Mandavo la pressione senza prima MUOVERE il cursore. Godot decide chi
	#      riceve un click dal controllo sotto il mouse, che si aggiorna col
	#      movimento: senza quello il click non arrivava a nessuno.
	#   2. Rimesso a posto quello, i click continuavano a sparire - e non per
	#      colpa dello strumento. Durante la lezione il buffer dei comandi era
	#      spento del tutto, quindi premere l'azione che Veronica chiede un
	#      attimo prima della ricarica non faceva niente. Corretto in
	#      Intenzione.azione_ammessa_dalla_lezione.
	# Morale: uno strumento che stampa un numero di cui non ti fidi non e'
	# inutile, e' pericoloso - l'avevo marcato "non tarato" e ci ho convissuto
	# per giorni con dentro un difetto del gioco.
	print("\n=== INTERFACCIA DI COMBATTIMENTO, %s (%d fotogrammi) ===" % [chi, campioni])
	if chiuso_prima:
		print("  lo scontro e' finito dopo ~%.1fs: da li' in poi non si misura" % secondi_misurati)
	print("  fotogramma medio      %6.2f ms   (il piu' lento: %.1f ms)" % [
			1000.0 * somma_fotogrammi / maxf(float(campioni), 1.0),
			1000.0 * fotogramma_piu_lento])
	print("  menu a schermo        %s" % quota(con_menu_a_schermo))
	print("  PRONTO MA COPERTO     %s   <- qui i click vanno a vuoto" % quota(menu_acceso_ma_coperto))
	print("  testo in coda         %s" % quota(con_testo_in_coda))
	print("  tempo fermo           %s" % quota(tempo_fermo))
	print("  cambi di faccia       %d   (%.1f al secondo)" % [
			cambi_di_faccia, float(cambi_di_faccia) / SECONDI])
	for f in facce:
		print("    faccia '%-8s'    %s" % [f, quota(int(facce[f]))])
	print("  schede ridisegnate    %d   (%.1f al secondo)" % [
			schede_fatte, float(schede_fatte) / SECONDI])
	print("  disegni chiesti al disco  %d" % disegni_fatti)
	print("  LO SCONTRO PROGREDISCE?   hp della squadra %d -> %d   (giri: %d)" % [
			hp_prima, hp_dopo, azioni_nemico])
	for f in fasi:
		print("    fase '%-10s'    %s" % [f, quota(int(fasi[f]))])
	if click_tentati > 0:
		print("  CLICK ANDATI A SEGNO  %d su %d   (%.0f%%)" % [
				click_a_segno, click_tentati,
				100.0 * float(click_a_segno) / float(click_tentati)])
	else:
		print("  CLICK ANDATI A SEGNO  nessun tentativo: il menu non e' mai stato premibile")
	print("  RICOSTRUZIONI DEL MENU: %d" % rifacimenti.size())
	for r in rifacimenti:
		print("    " + r)
	if scatti.is_empty():
		print("  nessuno scatto sopra %d ms" % int(1000.0 * SOGLIA_SCATTO))
	else:
		scatti.sort_custom(func(a, b): return float(a["ms"]) > float(b["ms"]))
		print("  SCATTI sopra %d ms: %d" % [int(1000.0 * SOGLIA_SCATTO), scatti.size()])
		for i in mini(scatti.size(), 6):
			var sc: Dictionary = scatti[i]
			print("    %6.1f ms  a %4.1fs  fase=%-9s faccia=%-8s coda=%d scrive=%s minigioco=%s pugni=%d" % [
					sc["ms"], sc["al_secondo"], sc["fase"], sc["faccia"],
					sc["in_coda"], sc["scrive"], sc["minigioco"], sc["pugni"]])
