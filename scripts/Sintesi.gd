class_name Sintesi
extends RefCounted

# Suoni fatti a mano, campione per campione, senza nessun file.
#
# Il gioco non ha un solo file audio, e ne avrà solo quando Bru li farà. Nel
# frattempo restare muti non è neutrale: un testo che scorre in silenzio non
# sembra "in attesa dell'audio", sembra morto. La cosa che in Undertale fa
# sembrare il testo *parlato* non è la musica, è il blip per carattere,
# intonato diverso per ogni personaggio — e un blip è un'onda quadra di
# cinquanta millesimi di secondo, cioè mille numeri in fila.
#
# Quindi li generiamo. Ogni personaggio ha la sua altezza e la sua forma
# d'onda, ricavate dal suo nome quando non stanno nei dati: due personaggi
# diversi suonano diversi, sempre, e lo stesso personaggio suona sempre uguale.
#
# SONO SEGNAPOSTO, ED È IL PUNTO. Ogni suono sintetizzato ha un percorso file
# corrispondente (res://audio/ui/<nome>.wav, res://audio/voci/...): appena quel
# file esiste, vince lui e la sintesi si fa da parte. Non c'è niente da
# ricablare — si copia un .wav nella cartella.

const CAMPIONAMENTO := 22050

# --- onde ---

static func _onda(forma: String, fase: float) -> float:
	# fase in giri (0..1), non in radianti: si legge meglio
	match forma:
		"quadra":
			return 1.0 if fmod(fase, 1.0) < 0.5 else -1.0
		"sega":
			return 2.0 * fmod(fase, 1.0) - 1.0
		"triangolo":
			var t := fmod(fase, 1.0)
			return 4.0 * absf(t - 0.5) - 1.0
		"rumore":
			return randf_range(-1.0, 1.0)
		_:
			return sin(fase * TAU)

static func tono(altezza: float, durata: float, forma := "quadra",
		decadimento := 40.0, ampiezza := 0.3, altezza_finale := -1.0) -> AudioStreamWAV:
	# Un suono solo: altezza in hertz, durata in secondi, decadimento = quanto
	# in fretta si spegne (piu' alto = piu' secco). Con "altezza_finale" scivola
	# da una nota all'altra: e' quello che distingue un "sale" da un "scende",
	# ed e' tutta la differenza tra il suono di una cura e quello di un errore.
	var campioni := maxi(int(durata * CAMPIONAMENTO), 1)
	var dati := PackedByteArray()
	dati.resize(campioni * 2)
	var fase := 0.0
	for i in range(campioni):
		var avanzamento := float(i) / float(campioni)
		var nota := altezza if altezza_finale < 0.0 else lerpf(altezza, altezza_finale, avanzamento)
		fase += nota / float(CAMPIONAMENTO)
		var inviluppo := exp(-avanzamento * decadimento * durata)
		# i primi millesimi salgono invece di partire di scatto: senza questo
		# ogni suono comincia con un clic
		inviluppo *= minf(float(i) / maxf(CAMPIONAMENTO * 0.002, 1.0), 1.0)
		var valore := int(clampf(_onda(forma, fase) * inviluppo * ampiezza, -1.0, 1.0) * 32767.0)
		dati.encode_s16(i * 2, valore)
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = CAMPIONAMENTO
	wav.stereo = false
	wav.data = dati
	return wav

# --- la voce di un personaggio ---

static func voce_da_nome(nome: String) -> Dictionary:
	# Chi non ha una voce scritta nei dati se la prende dal proprio nome: lo
	# stesso nome da sempre lo stesso suono, nomi diversi danno suoni diversi.
	# Nessuna casualita': non si puo' avere un personaggio che oggi parla in un
	# modo e domani in un altro.
	var impronta := absi(hash(nome))
	var forme := ["quadra", "triangolo", "sega", "seno"]
	return {
		# poco piu' di un'ottava e mezza di scelta: sotto diventa un rutto,
		# sopra un fischio
		"altezza": 200.0 + float(impronta % 26) * 14.0,
		"forma": forme[(impronta / 26) % forme.size()],
	}

static func blip(nome: String, dati_voce: Dictionary = {}) -> AudioStreamWAV:
	var voce := voce_da_nome(nome)
	var altezza := float(dati_voce.get("altezza", voce["altezza"]))
	var forma := String(dati_voce.get("forma", voce["forma"]))
	return tono(altezza, 0.055, forma, 60.0, 0.22)

static func blip_narrazione() -> AudioStreamWAV:
	# la voce che racconta dall'esterno non e' nessuno: piu' bassa, piu' morbida,
	# piu' silenziosa di chiunque parli nella stanza
	return tono(150.0, 0.05, "seno", 70.0, 0.13)

# --- i suoni dell'interfaccia ---

static func interfaccia(nome: String) -> AudioStreamWAV:
	match nome:
		"conferma":
			return tono(520.0, 0.09, "triangolo", 32.0, 0.28, 700.0)
		"annulla":
			return tono(420.0, 0.10, "triangolo", 32.0, 0.24, 260.0)
		"colpo":
			# secco e sporco: e' l'unico che non deve suonare intonato
			return tono(150.0, 0.13, "rumore", 45.0, 0.30, 60.0)
		"cura":
			return tono(600.0, 0.20, "seno", 14.0, 0.24, 900.0)
		"raccolta":
			return tono(700.0, 0.16, "triangolo", 20.0, 0.24, 1050.0)
		"errore":
			return tono(220.0, 0.16, "quadra", 26.0, 0.22, 160.0)
		_:
			return tono(440.0, 0.08, "seno", 40.0, 0.2)
