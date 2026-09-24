class_name TurniCombattimento
extends RefCounted

# I TURNI: UN GIRO ALLA VOLTA, E IN OGNI GIRO OGNUNO AGISCE UNA VOLTA.
#
# Bru, provando le Pianure: «non ci sono i turni il goblin mi attacca di
# continuo, lo scontro con le rane diventa un casino ci vogliono i turni». E
# dopo: «ok vai coi turni».
#
# PRIMA C'ERANO LE RICARICHE. Ognuno aveva un tempo suo che scorreva da solo, e
# quando finiva agiva - che tu avessi scelto o no. Un goblin il doppio piu'
# veloce di te colpiva due volte per ogni tua mossa, e un'orda di cinque rane
# era un rumore continuo. Era quello che Bru aveva chiesto allora («i nemici
# non aspetteranno che tu scelga»), ed e' quello che adesso non vuole piu'.
#
# ADESSO C'E' IL GIRO. All'inizio di ogni giro si mettono in fila tutti quelli
# che possono agire, e agiscono uno alla volta:
#
#   - IN ORDINE DI VELOCITA'. «La precedenza la ha chi ha la velocita'
#     maggiore» (Bru). A pari velocita' va prima la squadra, e fra due della
#     stessa parte chi e' entrato prima nello scontro
#   - NESSUNO AGISCE DUE VOLTE NELLO STESSO GIRO. Essere piu' veloce di te vuol
#     dire muovere prima di te, non muovere di piu': e' esattamente il goblin
#     che «mi attacca di continuo»
#   - MA CHI E' MOLTO PIU' LENTO DI TE PUO' SALTARE UN GIRO. Il goblin
#     arrabbiato e' stato scritto «lento» apposta (velocita' 1 contro il tuo
#     3): a fare paura dovevano essere la Mazzata e i goblin che chiama, non il
#     suo colpo. Con un turno a giro pieno picchiava due volte e mezzo quello
#     per cui era stato misurato, e non si batteva piu' (0 vittorie su 24).
#     Quindi ognuno ha un RITMO - la sua velocita' rispetto alla tua, fino a
#     uno - e lo accumula giro dopo giro: quando arriva a un turno intero,
#     muove. Chi e' veloce quanto te o di piu' muove sempre; chi va alla meta'
#     muove un giro si' e uno no; nessuno scende sotto RITMO_MINIMO. E' la
#     stessa proporzione delle ricariche di prima, tolta la parte che faceva
#     agire i veloci due volte
#   - AL PRIMO GIRO UN'IMBOSCATA RIBALTA LA FILA: «se i nemici tendono imboscate
#     o ti colgono di sorpresa hanno la precedenza come turno». Chi l'ha tesa
#     muove tutto prima degli altri, e fra loro decide di nuovo la velocita'
#   - LA FILA DI UN GIRO NON CAMBIA A META'. Un rallentamento preso adesso
#     conta dal giro dopo; chi arriva a scontro in corso (un goblin evocato)
#     entra nella fila del giro dopo; chi cade prima del suo turno lo salta
#
# QUANDO TOCCA A TE, IL MONDO ASPETTA. Senza tempo: finche' non scegli, non si
# muove niente. E' la cosa che mancava.
#
# QUI SI DECIDE SOLO CHI. Cosa fa chi ha il turno, e quando si puo' passare al
# prossimo (finche' c'e' da leggere, o si sta parando, no), lo decide lo
# scontro: vedi Combattimento.avanza_turni.

var scontro: Combattimento
var giro := 0                            # il giro in corso; 0 = non e' ancora cominciato niente
var da_muovere: Array[Dictionary] = []   # chi deve ancora agire in questo giro, in ordine
var di_turno: Dictionary = {}            # chi ha il turno adesso; vuoto = nessuno
var precedenza := ""                     # chi apre il primo giro: "nemici", "squadra", o la velocita'
var fermi: Array[Dictionary] = []        # chi in questo giro non ce la fa a muoversi (e' lento)

func _init(nodo_scontro: Combattimento) -> void:
	scontro = nodo_scontro

func tocca_a(combattente: Dictionary) -> bool:
	# lo stesso combattente, non uno uguale: due goblin tipici sono due dizionari
	# con gli stessi numeri, e il turno e' di uno solo dei due
	return not di_turno.is_empty() and is_same(di_turno, combattente)

func passa_a(combattente: Dictionary) -> void:
	# il turno dato a mano. Serve alle prove, e a chi deve far agire qualcuno
	# fuori fila senza rompere il giro
	di_turno = combattente

func fine_turno() -> void:
	di_turno = {}

func prossimo() -> Dictionary:
	# chi agisce adesso: il primo della fila che puo' ancora farlo. Se la fila e'
	# vuota comincia un giro nuovo. Vuoto se non resta nessuno che possa agire
	di_turno = {}
	for tentativo in 2:
		while not da_muovere.is_empty():
			var chi: Dictionary = da_muovere.pop_front()
			if in_gioco(chi):
				di_turno = chi
				return chi
		nuovo_giro()
	return {}

func nuovo_giro() -> void:
	giro += 1
	scontro.giro_corrente = giro
	da_muovere.clear()
	fermi.clear()
	for combattente in fila():
		if prende_slancio(combattente):
			da_muovere.append(combattente)
		else:
			fermi.append(combattente)
			di_la_lentezza(combattente)

func di_la_lentezza(combattente: Dictionary) -> void:
	# LA PRIMA VOLTA CHE SALTA UN GIRO, SI DICE. Un nemico che non attacca senza
	# una ragione a schermo sembra un difetto; una riga sola, poi basta
	if bool(combattente.get("lentezza_detta", false)):
		return
	combattente.lentezza_detta = true
	var testo := String(GameState.regole.get("tempo", {}).get("testo_lento", ""))
	if testo != "":
		scontro.scrivi(testo % String(combattente.get("nome", "")))

func prende_slancio(combattente: Dictionary) -> bool:
	# IL RITMO SI ACCUMULA: chi muove al 40% arriva a un turno intero due giri
	# su cinque. Al primo giro muovono tutti - si parte pari, e l'imboscata
	# deve poter colpire subito
	var ritmo := ritmo_di(combattente)
	if giro == 1:
		combattente.slancio = 1.0 - ritmo
	combattente.slancio = float(combattente.get("slancio", 0.0)) + ritmo
	if float(combattente.slancio) < 1.0 - 0.001:
		return false
	combattente.slancio = float(combattente.slancio) - 1.0
	return true

func ritmo_di(combattente: Dictionary) -> float:
	# quanti turni per giro, fra RITMO_MINIMO e uno. IL RIFERIMENTO E' IL
	# PROTAGONISTA, come lo era per le ricariche: un "lento" e' lento rispetto a
	# chi giochi, al livello 1 come al 30, e salendo di velocita' gli altri ti
	# sembrano piu' lenti
	var dati: Dictionary = GameState.regole.get("tempo", {})
	var riferimento := float(dati.get("velocita_riferimento", 3))
	for altro in scontro.combattenti:
		if altro.giocatore and String(altro.get("id", "")) == GameState.id_protagonista:
			riferimento = float(RegoleCombattimento.velocita_effettiva(altro))
			break
	var mia := float(RegoleCombattimento.velocita_effettiva(combattente))
	return clampf(mia / maxf(riferimento, 1.0), float(dati.get("ritmo_minimo", 0.4)), 1.0)

func fila() -> Array[Dictionary]:
	var chi: Array[Dictionary] = []
	for combattente in scontro.combattenti:
		if in_gioco(combattente):
			chi.append(combattente)
	chi.sort_custom(viene_prima)
	return chi

func in_gioco(combattente: Dictionary) -> bool:
	# un oggetto di scena (una leva, un bersaglio da rompere) sta in campo ma non
	# agisce; chi e' a terra nemmeno
	return int(combattente.get("hp", 0)) > 0 \
			and not bool(combattente.get("oggetto_scena", false)) \
			and scontro.combattenti.any(func(c: Dictionary) -> bool: return is_same(c, combattente))

func viene_prima(a: Dictionary, b: Dictionary) -> bool:
	if giro == 1 and (precedenza == "nemici" or precedenza == "squadra"):
		var di_a := bool(a.giocatore) == (precedenza == "squadra")
		var di_b := bool(b.giocatore) == (precedenza == "squadra")
		if di_a != di_b:
			return di_a
	var veloce_a := RegoleCombattimento.velocita_effettiva(a)
	var veloce_b := RegoleCombattimento.velocita_effettiva(b)
	if veloce_a != veloce_b:
		return veloce_a > veloce_b
	if bool(a.giocatore) != bool(b.giocatore):
		return bool(a.giocatore)
	return int(a.get("indice", 0)) < int(b.get("indice", 0))

func prossimi() -> Array[Dictionary]:
	# chi muovera' dopo chi ha il turno, fino alla fine del giro: quello che si
	# puo' mostrare a schermo senza promettere niente sul giro dopo
	var chi: Array[Dictionary] = []
	for combattente in da_muovere:
		if in_gioco(combattente):
			chi.append(combattente)
	return chi
