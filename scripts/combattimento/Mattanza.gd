class_name MattanzaCombattimento
extends RefCounted

# --- MATTANZA: la barra si svuota, e finche' si svuota tu batti --------------
#
# Bru: "quando riempi almeno una barra, puoi andare in mattanza, SOLO in quel
# momento; la mattanza consuma tutta la barra e finche' non e' consumata potrai
# premere spazio per colpire numerose volte il nemico".
#
# E poi, sul come si batte: «calcola che per la mattanza il giocatore puo'
# cliccare furiosamente: fai il minimo danno possibile per click o preme barra
# spaziatrice. Quando la mattanza inizia l'immagine del nemico trema a ogni
# input, ogni colpo puo' fare critico, e quando finisce hai un minigioco con una
# barra che scorre velocemente: se clicchi nel momento giusto in cui si allinea
# con un punto random sulla barra infliggi del danno bonus».
#
# Tre cose, e sono tutte e tre la stessa cosa vista da angoli diversi:
#
#   la SOGLIA e' a segmenti pieni - mezza barra non apre niente. E' quello che
#   rende la barra una cosa che si aspetta invece di un contatore che sale;
#
#   il COSTO e' tutto quello che c'e'. Non e' un prezzo, e' un serbatoio: quanta
#   barra avevi decide quanto dura la finestra E quanto pesa il colpo di grazia,
#   quindi tenerla da parte e' davvero una scelta e non solo pazienza;
#
#   la DURATA e' la barra stessa che si scarica. Non c'e' un secondo contatore
#   accanto a quello vero: guardi la barra scendere e sai quanto ti resta. Per
#   questo il dominio viene riscritto ogni frame dal residuo - se un colpo
#   incassato lo ricaricasse mentre martelli, la mattanza non finirebbe piu'.
#
# IL COLPO VALE IL MINIMO (un punto, "danno_per_colpo"), e non una quota
# dell'attacco: chi martella con due dita fa quindici colpi al secondo, e con un
# decimo dell'attacco la Mattanza la vinceva la mano invece della barra. Il
# grosso sta nel colpo di grazia (ColpoDiGrazia.gd), che si prende col tempismo
# e non con la velocita'.
#
# E' UN MODULO A PARTE per la stessa ragione della Mazzata: Combattimento.gd e'
# il file piu' grande del gioco, e questa e' una cosa che si capisce da sola -
# una finestra con un inizio, una fine e un minigioco in coda.
#
# Quanti colpi entrano lo decidi tu con le mani. Il giocatore automatico le mani
# non ce l'ha: nelle prove batte a "pressioni_al_secondo", e il colpo di grazia
# lo centra "riuscita_automatica" volte su una. Stanno nei dati accanto al resto
# perche' sono stime dichiarate, non numeri nascosti.

var scontro: Combattimento
var grazia: ColpoDiGraziaCombattimento

var attiva := false          # dall'apertura alla fine del colpo di grazia
var martella := false        # la barra si sta scaricando: ogni tasto e' un colpo
var chi: Dictionary = {}
var bersaglio: Dictionary = {}
var dati: Dictionary = {}
var rimasto := 0.0           # quanto dominio resta da bruciare
var scarico := 0.0           # quanto ne brucia al secondo
var segmenti := 0.0          # quante barre ha bruciato: pesano sul colpo di grazia
var colpi := 0
var critici := 0
var danno_colpi := 0
var danno_grazia := 0
var azione_in_attesa: Dictionary = {}   # il passo di tutorial che aspetta la fine
var tempo_fermato := false

func _init(nodo_scontro: Combattimento, muto: bool) -> void:
	scontro = nodo_scontro
	grazia = ColpoDiGraziaCombattimento.new(muto)
	grazia.centrato.connect(_centrato)
	grazia.finito.connect(_grazia_finita)

func collega(dove: Control, plancia: PlanciaCombattimento, sopra: Control) -> void:
	grazia.collega(dove, plancia, sopra)

func in_mano() -> bool:
	# il colpo di grazia si prende il quadrante e la mano, come la raffica
	return grazia.attivo

# --- l'apertura -------------------------------------------------------------

func avvia(chi_batte: Dictionary, su: Dictionary, dati_abilita: Dictionary) -> void:
	if attiva:
		return   # una alla volta: la seconda si porterebbe via una barra gia' vuota
	var serbatoio := RegoleCombattimento.svuota_dominio(chi_batte)
	if serbatoio <= 0:
		return
	var per_segmento := maxf(float(GameState.regole.get("dominio", {}).get("per_segmento", 100)), 1.0)
	segmenti = float(serbatoio) / per_segmento
	var durata := float(dati_abilita.get("secondi_per_segmento", 2.2)) * segmenti
	scontro.scrivi(String(dati_abilita.get("testo_uso", "[i]%s non smette più.[/i]")) % chi_batte.nome)
	chi = chi_batte
	bersaglio = su
	dati = dati_abilita
	colpi = 0
	critici = 0
	danno_colpi = 0
	danno_grazia = 0
	rimasto = float(serbatoio)
	scarico = float(serbatoio) / maxf(durata, 0.01)
	chi.dominio = serbatoio
	scontro.aggiorna_scheda(chi)
	attiva = true
	martella = true
	if not dal_vivo():
		# NESSUNA MANO DA QUESTA PARTE. Senza schermo non esiste una barra
		# spaziatrice e non esiste un frame: la finestra si risolve tutta
		# adesso, con le battute che ci batterebbe una persona. Se qui non
		# succedesse niente, il simulatore direbbe che la Mattanza non fa danno -
		# e ricalibreremmo il gioco intero su un'abilita' che non ha mai colpito
		var quante := maxi(int(round(durata * float(dati.get("pressioni_al_secondo", 6.0)))), 1)
		for volta in quante:
			if not colpo():
				break
		chiudi_finestra()
		return
	if bool(dati.get("ferma_il_tempo", false)):
		scontro.ferma_il_tempo()
		tempo_fermato = true
	scontro.menu.principale()   # sotto compare come si batte, e nient'altro

func dal_vivo() -> bool:
	return scontro.tempo_reale and not scontro.muto

func chiamabile() -> bool:
	var tu: Dictionary = scontro.combattente_comandato()
	var passo: Dictionary = scontro.passo_tutorial()
	return scontro.in_corso and not attiva and not tu.is_empty() \
			and GameState.abilita_usabili(String(tu.id)).has("mattanza") \
			and not RegoleCombattimento.solo_attacchi(tu) \
			and scontro.dominio_sufficiente(tu, GameState.abilita_combattimento("mattanza")) \
			and (passo.is_empty() or String(passo.get("id", "")) == "mattanza")

func sospesa() -> bool:
	# MENTRE SI LEGGE, LA FINESTRA ASPETTA: non si scarica e non colpisce, e
	# SPAZIO torna a far scorrere il testo. Senza, la barra correva sotto le
	# parole - «non smette più», un KO, l'orda che si indebolisce - e i secondi
	# se ne andavano a leggere
	return scontro.il_mondo_aspetta_che_si_legga()

# --- la mano ----------------------------------------------------------------

func prende(evento: InputEvent) -> bool:
	# SPAZIO: un colpo mentre la barra si scarica, il tiro durante il colpo di
	# grazia. Mentre si legge non e' suo: fa scorrere il testo
	if not attiva or not evento.is_action_pressed("ui_accept"):
		return false
	if grazia.attivo:
		return grazia.premi_col_tasto()
	if not martella or sospesa():
		return false
	colpo()
	return true

func clic_su(su: Dictionary) -> bool:
	# IL CLIC SUL NEMICO E' UN COLPO, come lo spazio. Bru: «la mattanza non
	# causa mai alcun danno, dovrebbe permetterti di fare danni cliccando sul
	# nemico». E nel colpo di grazia e' il tiro: chi gioca col mouse ha il
	# puntatore sul nemico da tutta la raffica, e non deve correre al riquadro
	if not attiva:
		return false
	if grazia.attivo:
		grazia.premi_col_tasto()
	elif martella and not sospesa():
		colpo(su)
	return true

func colpo(su: Dictionary = {}) -> bool:
	# un colpo, e dice se ha senso continuare. Va DIRITTO, senza passare dalla
	# difesa: cosi' la Mattanza e' la risposta ai corazzati invece dell'ennesima
	# cosa che contro un corazzato non serve. Col clic il colpo va su chi hai
	# cliccato
	if chi.is_empty() or int(chi.get("hp", 0)) <= 0 or not scontro.in_corso:
		return false
	if int(su.get("hp", 0)) > 0:
		bersaglio = su
	bersaglio = bersaglio_vivo()
	if bersaglio.is_empty():
		return false
	# «ogni colpo puo' fare critico»: con la stessa regola di tutti gli altri
	# colpi - il cinque per cento, lo stress di chi lo prende, il Terrore che
	# lo blocca - perche' un critico che segue regole sue non si impara
	var critico := RegoleCombattimento.tenta_critico(bersaglio) \
			and not RegoleCombattimento.critico_bloccato(chi)
	var danno := danno_del_colpo(dati, critico)
	colpi += 1
	danno_colpi += danno
	if critico:
		critici += 1
	# SUBITO, non in coda al racconto: in coda i numeri uscivano uno ogni mezzo
	# secondo, a finestra gia' chiusa
	scontro.colpisci_diretto(bersaglio, danno, String(dati.get("elemento", "")), dal_vivo(), critico)
	var immagine: Variant = bersaglio.get("immagine", null)
	if is_instance_valid(immagine):
		scontro.impatto.tremito(immagine as Control)
	return scontro.in_corso

func bersaglio_vivo() -> Dictionary:
	# il bersaglio e' caduto sotto i colpi: si passa al prossimo, non ci si
	# ferma. Chi sta martellando non ha il tempo di riscegliere
	if not bersaglio.is_empty() and int(bersaglio.get("hp", 0)) > 0:
		return bersaglio
	var restanti: Array[Dictionary] = scontro.vivi(false)
	return restanti[0] if not restanti.is_empty() else {}

static func danno_del_colpo(dati_abilita: Dictionary, critico: bool) -> int:
	# il minimo, e il critico ci aggiunge almeno un punto: moltiplicato e
	# arrotondato, un colpo da uno resterebbe uno, e un critico che non si
	# distingue da un colpo normale e' un numero grande che mente
	var base := maxi(int(dati_abilita.get("danno_per_colpo", 1)), 1)
	if not critico:
		return base
	var molt := float(GameState.regole.get("critico_moltiplicatore", 1.5))
	return maxi(int(round(base * molt)), base + 1)

# --- il tempo ---------------------------------------------------------------

func passa(delta: float) -> bool:
	# true = il colpo di grazia si e' preso questo fotogramma, e il mondo aspetta
	if grazia.attivo:
		grazia.passa(delta)
		return true
	if not martella:
		return false
	if scontro.gioco_con_la_mano():
		# SOTTO LA RAFFICA O LA MAZZA LA BARRA ASPETTA: la mano e' loro, e il
		# colpo di grazia partirebbe sopra di loro, nello stesso quadrante
		return false
	if not sospesa():
		rimasto -= scarico * delta
	# la barra E' il cronometro: si riscrive dal residuo, cosi' niente di quello
	# che succede intorno (un colpo incassato che ricarica) puo' allungare la
	# finestra all'infinito
	chi.dominio = maxi(int(round(rimasto)), 0)
	scontro.aggiorna_scheda(chi)
	if rimasto <= 0.0 or not scontro.in_corso or int(chi.get("hp", 0)) <= 0:
		chiudi_finestra()
	return false

# --- la fine ----------------------------------------------------------------

func chiudi_finestra() -> void:
	# LA BARRA E' VUOTA: resta il colpo di grazia, se c'e' ancora qualcuno da
	# colpire e qualcuno che colpisce. Chi e' caduto martellando non tira
	martella = false
	if chi.is_empty():
		finisci()
		return
	chi.dominio = 0
	scontro.aggiorna_scheda(chi)
	bersaglio = bersaglio_vivo()
	if bersaglio.is_empty() or int(chi.get("hp", 0)) <= 0 or not scontro.in_corso:
		finisci()
		return
	var parametri: Dictionary = dati.get("colpo_di_grazia", {})
	# nell'allenamento la prima volta e' guidata: lo dice il passo, non la Mattanza
	var guidata := bool(scontro.passo_tutorial().get("grazia_guidata", false))
	if not dal_vivo() or not grazia.avvia(parametri, guidata):
		centra_da_solo(parametri)
		finisci()

func centra_da_solo(parametri: Dictionary) -> void:
	# la mano automatica non ha un tempismo: prende la media. Il colpo pieno per
	# quante volte su una lo centrerebbe una persona - una stima dichiarata nei
	# dati, come le pressioni al secondo, perche' il simulatore misuri la
	# Mattanza che giochi tu e non una che centra sempre o non centra mai
	var quota := clampf(float(parametri.get("riuscita_automatica", 0.5)), 0.0, 1.0)
	var danno := int(round(danno_di_grazia(chi, dati, segmenti) * quota))
	if danno <= 0:
		return
	danno_grazia = danno
	scontro.colpisci_diretto(bersaglio, danno, String(dati.get("elemento", "")))

static func danno_di_grazia(chi_batte: Dictionary, dati_abilita: Dictionary, barre: float) -> int:
	# IL DANNO BONUS: il tuo attacco, per ogni barra bruciata. Diritto come i
	# colpi - e' la stessa Mattanza, non un attacco nuovo
	var parametri: Dictionary = dati_abilita.get("colpo_di_grazia", {})
	var per_barra := float(parametri.get("attacco_per_barra", 1.0))
	return maxi(int(round(RegoleCombattimento.attacco_di(chi_batte) * per_barra * barre)), 1)

func _centrato() -> void:
	# l'immagine si e' appena frantumata: il danno arriva adesso, non a fine
	# minigioco, o il numero comparirebbe a pezzi gia' spariti
	var su := bersaglio_vivo()
	if su.is_empty() or not scontro.in_corso:
		return
	danno_grazia = danno_di_grazia(chi, dati, segmenti)
	scontro.colpisci_diretto(su, danno_grazia, String(dati.get("elemento", "")), true)

func _grazia_finita(_esito: Dictionary) -> void:
	finisci()

func finisci() -> void:
	# TUTTO A POSTO, comunque sia finita: la barra a zero, il riepilogo nel box,
	# il tempo che riparte, il passo del tutorial che aspettava, il menu
	var era_attiva := attiva
	attiva = false
	martella = false
	grazia.interrompi()
	if not chi.is_empty():
		chi.dominio = 0
		scontro.aggiorna_scheda(chi)
		scontro.scrivi(String(dati.get("testo_fine", "[i]%s si ferma: %d colpi.[/i]"))
				% [chi.nome, colpi])
	if tempo_fermato:
		tempo_fermato = false
		scontro.riprendi_il_tempo()
	rimasto = 0.0
	scarico = 0.0
	chi = {}
	bersaglio = {}
	dati = {}
	var azione := azione_in_attesa
	azione_in_attesa = {}
	if scontro.in_corso and not azione.is_empty():
		scontro.avanza_tutorial(azione)   # adesso Veronica puo' commentare
	if era_attiva and dal_vivo() and scontro.in_corso:
		scontro.menu.principale()
