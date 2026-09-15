class_name RitrattiCombattimento
extends RefCounted

# QUALE FACCIA HA ADESSO.
#
# Bru: «quando subisci danno il portrait cambia con uno per low damage, mid
# damage heavy damage e ko, a seconda degli status disegnerò portrait per ogni
# personaggio ovviamente, disegnerò anche un portrait generico per un
# personaggio ko».
#
# LE SOGLIE SONO QUELLE DELL'ECG, e non per comodità: sono le stesse che ha
# dettato lui per la linea del cuore (rossa sotto il 25%, verde sopra il 75%).
# Tenendole uguali, la faccia e la linea non possono mai dire due cose diverse -
# quando il tracciato diventa giallo, il ritratto cambia nello stesso istante, e
# il giocatore impara UNA soglia invece di due.
#
#   sano          vita piena, non l'ha ancora toccato nessuno
#   ferito_lieve  sopra il 75%
#   ferito_medio  fra il 25% e il 75%
#   ferito_grave  sotto il 25%
#   ko            a terra
#
# NON SI DECIDE MAI SU UN PIXEL. Una faccia che cambia esattamente al 75% e
# torna indietro al 74.9% sfarfalla, e in un combattimento in tempo reale la
# vita ci passa sopra di continuo. La banda e' APPICCICOSA: per peggiorare basta
# scendere sotto la soglia, per migliorare bisogna risalirci sopra di un
# margine. E' lo stesso mestiere dell'isteresi del contatore di battiti.
#
# IL RIPIEGO E' UNA CATENA, e serve a Bru piu' di ogni altra cosa qui dentro:
# i ritratti li sta disegnando adesso, uno per volta. Ogni pezzo che manca
# scivola su quello dopo, e al fondo c'e' sempre qualcosa - fino all'iniziale
# disegnata dal codice. Nessun file mancante lascia mai un buco nero a schermo.

const CARTELLA := "res://art/personaggi/"
const MARGINE := 0.04   # quanto bisogna risalire per tornare a una banda migliore

# in ordine, dalla piu' sana alla peggiore
const BANDE := ["sano", "ferito_lieve", "ferito_medio", "ferito_grave", "ko"]

static func banda_nuda(quota_hp: float) -> String:
	# la banda secondo la sola vita, senza memoria di dov'era prima
	if quota_hp <= 0.0:
		return "ko"
	if quota_hp >= 1.0:
		return "sano"
	if quota_hp < EcgCombattimento.QUOTA_ROSSA:
		return "ferito_grave"
	if quota_hp > EcgCombattimento.QUOTA_VERDE:
		return "ferito_lieve"
	return "ferito_medio"

static func banda(quota_hp: float, banda_prima := "") -> String:
	# QUELLA APPICCICOSA. Peggiorare e' immediato - un colpo che ti porta sotto
	# il quarto si deve vedere subito - mentre per tornare indietro bisogna
	# risalire di un margine: cosi' una cura che ti rimette appena sopra la
	# soglia non fa lampeggiare la faccia avanti e indietro a ogni tick.
	var adesso := banda_nuda(quota_hp)
	if banda_prima == "" or banda_prima == adesso:
		return adesso
	var quanto_prima := BANDE.find(banda_prima)
	var quanto_adesso := BANDE.find(adesso)
	if quanto_prima < 0 or quanto_adesso < 0:
		return adesso
	if quanto_adesso > quanto_prima:
		return adesso   # si peggiora subito
	# si migliora solo se la vita e' salita OLTRE la soglia, non appena sopra
	return adesso if banda_nuda(quota_hp - MARGINE) == adesso else banda_prima

static func candidati(id_personaggio: String, quota_hp: float,
		stati: Array[String], banda_prima := "") -> Array[String]:
	# I POSTI DOVE GUARDARE, IN ORDINE. Il primo file che esiste vince.
	#
	# A TERRA VINCE SEMPRE IL KO, e prima del suo c'e' quello generico: Bru ha
	# detto che lo disegna una volta sola per tutti, quindi un personaggio senza
	# il suo ha comunque una faccia da svenuto e non una faccia sorridente con
	# la barra a zero.
	#
	# POI LO STATUS, E SOLO DOPO LA FERITA. E' una scelta e si puo' ribaltare in
	# una riga: la vita e' gia' scritta in due posti - la barra e il colore
	# dell'ECG - mentre di essere in fiamme lo dice solo un riquadro piccolo.
	# Il ritratto e' lo spazio piu' grande che c'e', e conviene darlo alla cosa
	# che altrimenti si vede meno.
	var sua := CARTELLA + id_personaggio + "/"
	var dove: Array[String] = []
	var quale := banda(quota_hp, banda_prima)
	if quale == "ko":
		dove.append(sua + "ko.png")
		dove.append(CARTELLA + "ko.png")   # quello generico, disegnato una volta per tutti
	else:
		for id_stato in stati:
			dove.append(sua + id_stato + ".png")
		dove.append(sua + quale + ".png")
	dove.append(sua + "sano.png")
	dove.append(sua + "neutra.png")   # la posa dei dialoghi: meglio di niente
	return dove

static func scegli(id_personaggio: String, quota_hp: float, stati: Array[String],
		banda_prima := "", singolo := "") -> String:
	# il primo che esiste davvero, o "" se non c'e' proprio niente (e allora
	# tocca all'iniziale disegnata dal codice)
	for percorso in candidati(id_personaggio, quota_hp, stati, banda_prima):
		if ResourceLoader.exists(percorso):
			return percorso
	if singolo != "" and ResourceLoader.exists(singolo):
		return singolo   # la vecchia immagine unica del personaggio
	return ""

static func posto_vuoto() -> String:
	# «finché non hai compagni quei riquadri in più per i compagni avranno
	# un'immagine che ti darò»: uno slot senza nessuno dentro non sparisce, resta
	# li' col suo disegno - tre riquadri fanno vedere quanto grande puo'
	# diventare la squadra, e uno che sparisce lo nasconde.
	var percorso := CARTELLA + "slot_vuoto.png"
	return percorso if ResourceLoader.exists(percorso) else ""
