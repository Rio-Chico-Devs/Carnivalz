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
var somma_fotogrammi := 0.0
# quante volte al secondo si rifanno le cose costose
var menu_prima := 0
var schede_prima := 0
var disegni_prima := 0

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
	var fine := Time.get_ticks_msec() + int(SECONDI * 1000.0)
	while Time.get_ticks_msec() < fine and is_instance_valid(scontro):
		await get_tree().process_frame
		campiona(scontro)
	if is_instance_valid(scontro):
		schede_fatte = int(scontro.campo.aggiornamenti) - schede_prima
	disegni_fatti = int(Disegni.ricerche) - disegni_prima
	stampa(chi)
	get_tree().quit()

func campiona(scontro: Node) -> void:
	campioni += 1
	var quanto := get_process_delta_time()
	somma_fotogrammi += quanto
	fotogramma_piu_lento = maxf(fotogramma_piu_lento, quanto)
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
	# IL NUMERO CHE CONTA. Il giocatore e' pronto ad agire, e il pannello dei
	# comandi non c'e': quello che vede e' un menu che non risponde, e il primo
	# click lo mangia il box del testo. Bru: «il primo click e' andato a vuoto
	# il secondo no, e' come se fosse lento a ripristinare l'interfaccia».
	if bool(scontro.menu_acceso) and not comandabile:
		menu_acceso_ma_coperto += 1
	if not scontro.voce.coda.is_empty():
		con_testo_in_coda += 1
	if not scontro.il_tempo_scorre():
		tempo_fermo += 1

func quota(quanti: int) -> String:
	if campioni <= 0:
		return "n/d"
	return "%5.1f%%" % (100.0 * float(quanti) / float(campioni))

var schede_fatte := 0
var disegni_fatti := 0

func stampa(chi: String) -> void:
	print("\n=== INTERFACCIA DI COMBATTIMENTO, %s (%d fotogrammi in %.0fs) ===" % [
			chi, campioni, SECONDI])
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
