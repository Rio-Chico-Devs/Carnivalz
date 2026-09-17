class_name VoceCombattimento
extends RefCounted

# Come il combattimento parla, e come aspetta.
#
# Prima tutto finiva in un diario che si allungava all'infinito in caratteri
# minuscoli: un blocco compresso che nessuno legge, dove il resoconto del tuo
# attacco di tre turni fa stava ancora li' a rubare spazio a quello che conta
# adesso. Ora l'informazione e' divisa in tre canali, ognuno con un mestiere solo:
#
#   il campo    -> lo STATO: barre e numeri di vita sulle schede, sempre
#                  visibili, da guardare di sfuggita (vedi Campo.gd)
#   i numeri    -> il COLPO: il danno vola sopra la scheda di chi lo prende e
#      volanti      sparisce. E' un evento, non una riga di registro
#   il box      -> il MOMENTO: un messaggio alla volta, nello stesso box e con
#                  lo stesso corpo del testo dei dialoghi. Si legge, e poi
#                  lascia il posto al successivo
#
# Chi vuole rileggere tutto ha lo storico in pausa (ESC): ogni riga passa anche
# di la'. Il diario infinito non serve piu' a nessuno.
#
# Due velocita', ed e' la differenza che fa il ritmo:
#   scrivi()       -> ordinaria (attacchi, guardie, buff). Scorre da sola dopo
#                     il tempo di lettura, non chiede niente
#   scrivi_forte() -> conseguenza (risparmiare una creatura, un KO, un boss che
#                     cede, un bottino). ASPETTA un click: e' un momento che
#                     deve pesare, non una riga da far scorrere
#
# Chi produce testo non aspetta niente: accoda e prosegue. E' il giro dei turni
# che, ai suoi punti di respiro, chiama svuota_coda() e fa leggere.
#
# MODALITA' MUTA. Con "muta" acceso non esiste nessun box, nessun numero che
# vola, nessuna attesa: la coda si svuota tutta insieme eseguendo solo gli
# effetti. E' quello che permette al giocatore automatico di giocare migliaia
# di scontri in pochi secondi passando per lo stesso identico motore che gira
# quando ci sei tu. Non e' una simulazione del combattimento: e' il
# combattimento, senza la parte che si guarda.

var albero: SceneTree          # per i timer e i frame: un RefCounted non ce l'ha
var box                        # BoxTesto, nullo se muta
var area_avanza: Button        # la zona cliccabile "vai avanti", nulla se muta
var volanti: Control           # dove nascono i numeri che salgono, nullo se muta
var muta := false

var coda: Array[Dictionary] = []   # {tipo, chi, testo, forte, effetto}
var salta_messaggio := false       # un click chiede di passare avanti
var sta_svuotando := false         # c'e' gia' qualcuno che sta facendo leggere
# In tempo reale nessun messaggio puo' fermare il mondo aspettando un click:
# anche quelli "forti" scorrono da soli, solo con piu' calma
var tempo_reale := false

func _init(albero_scena: SceneTree, silenziosa := false) -> void:
	albero = albero_scena
	muta = silenziosa

func collega(box_testo, zona_avanza: Button, contenitore_volanti: Control) -> void:
	box = box_testo
	area_avanza = zona_avanza
	volanti = contenitore_volanti

# --- accodare ---

func scrivi(riga: String, tipo := "narrazione", chi := "") -> void:
	# messaggio ordinario: si legge da solo e scorre
	accoda(riga, tipo, chi, false)

func scrivi_forte(riga: String, tipo := "narrazione", chi := "") -> void:
	# messaggio che cambia le cose: aspetta un click, non scorre via
	accoda(riga, tipo, chi, true)

func accoda_effetto(effetto: Callable) -> void:
	# un battito senza parole: il numero che vola, il lampo sulla scheda. Sta
	# nella coda come tutto il resto, cosi' succede al momento giusto e non tre
	# messaggi prima
	coda.append({"tipo": "narrazione", "chi": "", "testo": "", "forte": false, "effetto": effetto})

func accoda(riga: String, tipo: String, chi: String, forte: bool, effetto := Callable()) -> void:
	if riga.strip_edges() == "":
		return
	coda.append({
		"tipo": tipo, "chi": chi, "testo": riga, "forte": forte, "effetto": effetto,
	})
	# tutto quello che si legge in combattimento finisce anche nello storico
	# della pausa: se qualcosa e' scorso via troppo in fretta, e' li'
	GameState.registra_storico(tipo, chi, riga)

# --- far leggere ---

func viva() -> bool:
	# I NODI CHE USO ESISTONO ANCORA?
	#
	# Ogni attesa qui dentro passa da await, e durante un await la scena puo'
	# CAMBIARE: lo scontro finisce, il giocatore torna al menu, una stanza
	# manda altrove. change_scene_to_file libera la vecchia scena - e con lei il
	# box e la zona cliccabile - ma l'albero sopravvive, quindi la coroutine si
	# risveglia lo stesso al fotogramma dopo e va a scrivere su roba che non
	# c'e' piu'. Godot lo segnala, e il giocatore vede degli errori mentre esce.
	#
	# Quindi dopo ogni attesa si chiede se si e' ancora vivi, e se no si smette
	# in silenzio: non c'e' piu' nessuno a cui far leggere niente.
	return not muta and is_instance_valid(box) and is_instance_valid(area_avanza)

func svuota_coda() -> void:
	# un messaggio alla volta, nell'ordine in cui e' successo. Il box e' lo
	# stesso dei dialoghi: stesso corpo del testo, stessa macchina da scrivere,
	# stesse pause sulla punteggiatura.
	#
	# E UNO ALLA VOLTA VALE ANCHE PER CHI SVUOTA.
	#
	# In tempo reale la coda ha due padroni: la pompa dei messaggi, che gira per
	# tutto lo scontro, e chi ogni tanto si ferma ad aspettare che si sia letto
	# tutto - il lancio di un minigioco, la fine di uno studio. Quelli partono da
	# _process, cioe' MENTRE la pompa sta gia' leggendo.
	#
	# Se capitano insieme, due cicli pescano dalla stessa coda: il secondo chiama
	# box.mostra() sopra la battuta che il primo sta ancora facendo leggere, e
	# quella battuta sparisce senza essere mai stata letta. E' esattamente il
	# caso della riga di Veronica prima delle Collisioni infinite.
	#
	# E c'e' di peggio: salta_messaggio e area_avanza sono UNO SOLO. Due attese
	# in parallelo se li rubano a vicenda - un click ne salta due, e la prima
	# smette di essere cliccabile quando la seconda finisce.
	#
	# Chi arriva secondo quindi non legge niente: aspetta che il primo abbia
	# finito, che e' esattamente quello che aveva chiesto.
	if sta_svuotando:
		while sta_svuotando and albero != null:
			await albero.process_frame
		return
	sta_svuotando = true
	while not coda.is_empty():
		var msg: Dictionary = coda.pop_front()
		var testo := String(msg.testo)
		# "viva()" e non "not muta": la scena puo' essere sparita mentre si
		# leggeva la battuta prima, e allora il box e' un riferimento a qualcosa
		# che non c'e' piu'. Gli effetti invece si applicano lo stesso - sono
		# cose che succedono nel mondo, non a schermo
		if viva() and testo != "":
			box.mostra(String(msg.tipo), testo, String(msg.chi))
		var effetto: Callable = msg.get("effetto", Callable())
		if effetto.is_valid():
			effetto.call()
		if not viva():
			continue   # muta, o senza piu' schermo: niente da guardare e niente da aspettare
		if testo == "":
			await attendi_colpo()   # solo il colpo: il tempo di vederlo
		else:
			await attendi_lettura(testo, bool(msg.forte))
		if not viva():
			break   # la scena e' cambiata mentre si leggeva: non c'e' piu' nessuno
	if viva():
		box.nascondi_indicatore()
	sta_svuotando = false

func attendi_lettura(testo: String, forte: bool) -> void:
	if not viva():
		return
	salta_messaggio = false
	area_avanza.visible = true
	# 1. finche' scrive, un click completa il testo invece di saltarlo
	while viva() and box.sta_scrivendo:
		if salta_messaggio:
			salta_messaggio = false
			box.completa()
			break
		await albero.process_frame
	# 2. poi: i messaggi forti aspettano il click, gli altri il tempo di lettura.
	# Il triangolino resta acceso solo sui forti, cosi' vuol dire una cosa sola:
	# "questo sta aspettando te"
	if not viva():
		return
	if forte and not tempo_reale:
		while viva() and not salta_messaggio:
			await albero.process_frame
	else:
		box.nascondi_indicatore()
		# process_always = false: il conto si ferma se apri la pausa
		var attesa := albero.create_timer(tempo_di_lettura(testo), false)
		while viva() and attesa.time_left > 0.0 and not salta_messaggio:
			await albero.process_frame
	if not viva():
		return
	salta_messaggio = false
	area_avanza.visible = false

func attendi_colpo() -> void:
	# il tempo di vedere il numero salire, saltabile con un click come il resto
	if not viva():
		return
	salta_messaggio = false
	area_avanza.visible = true
	var attesa := albero.create_timer(
			Stile.tempo("colpo_a_schermo") / maxf(Impostazioni.velocita_testo, 0.1), false)
	while viva() and attesa.time_left > 0.0 and not salta_messaggio:
		await albero.process_frame
	if not viva():
		return
	salta_messaggio = false
	area_avanza.visible = false

func tempo_di_lettura(testo: String) -> float:
	# quanto resta a schermo un messaggio ordinario: proporzionale a quanto e'
	# lungo, con un minimo perche' anche "Si difende." vuole il suo istante.
	# Segue la velocita' del testo scelta nelle opzioni
	var secondi := clampf(float(testo.length()) / 26.0, 0.6, 2.8)
	return secondi / maxf(Impostazioni.velocita_testo, 0.1)

func avanza() -> void:
	salta_messaggio = true

# --- il colpo che si vede ---

func numero_volante(scheda: Control, testo: String, tinta: Color, grande := false,
		sbandata := 0.0) -> void:
	# il danno non e' una riga di registro: e' una cosa che succede addosso a
	# qualcuno. Sale dalla scheda di chi lo prende e svanisce.
	#
	# "grande" e' per i critici: numero piu' grosso, sale piu' in alto e resta a
	# schermo piu' a lungo. Un critico deve interrompere la lettura, un colpo
	# normale no - e' la stessa differenza fra scrivi() e scrivi_forte().
	#
	# "sbandata" sposta il numero di lato: serve alle raffiche, dove venti colpi
	# uno sopra l'altro sarebbero una colonna illeggibile.
	if muta or scheda == null or not is_instance_valid(scheda):
		return
	var etichetta := Label.new()
	etichetta.text = testo
	etichetta.add_theme_color_override("font_color", tinta)
	etichetta.add_theme_font_size_override("font_size",
			Stile.dimensione("titolo") if grande else Stile.dimensione("sezione"))
	etichetta.mouse_filter = Control.MOUSE_FILTER_IGNORE
	volanti.add_child(etichetta)
	var centro := scheda.global_position + scheda.size * Vector2(0.5, 0.25)
	etichetta.global_position = centro - Vector2(etichetta.size.x * 0.5 - sbandata, 0)
	var durata := 1.15 if grande else 0.75
	var salita := etichetta.create_tween()
	salita.set_parallel(true)
	salita.tween_property(etichetta, "global_position:y",
			centro.y - (86.0 if grande else 54.0), durata)
	salita.tween_property(etichetta, "modulate:a", 0.0, durata).set_delay(0.2)
	if grande:
		# il critico entra con uno scatto: si vede che e' successo qualcosa
		etichetta.pivot_offset = etichetta.size * 0.5
		etichetta.scale = Vector2(0.6, 0.6)
		salita.tween_property(etichetta, "scale", Vector2.ONE, 0.18) \
				.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	salita.chain().tween_callback(etichetta.queue_free)

func suono(nome: String) -> void:
	# colpo, cura, raccolta, conferma: sintetizzati finche' non esistono i file
	# veri (vedi Sintesi.gd). Il giocatore automatico non sente niente
	if not muta:
		AudioManager.interfaccia(nome)

func lampeggia(scheda: Control, tinta: Color) -> void:
	if muta or scheda == null or not is_instance_valid(scheda):
		return
	# IL LAMPO VA SULLA FACCIA, NON SU TUTTA LA SCHEDA. Uno slot contiene il
	# ritratto, le tre barre e i riquadri di stato: tingendo tutto, nel momento
	# in cui prendi un colpo - cioe' l'istante in cui guardi la vita - le barre
	# diventano viola e non si leggono piu'. Si e' visto fotografando un colpo a
	# meta' volo. La faccia basta: e' la parte grande, ed e' quella che "reagisce".
	var dove := scheda
	if scheda is SlotCompagno:
		dove = (scheda as SlotCompagno).ritratto
	Stile.lampeggia(dove, tinta)
