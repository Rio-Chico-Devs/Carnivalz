class_name Conto
extends RefCounted

# UN NUMERO CHE SI MUOVE SOTTO GLI OCCHI, E CHE NON FA MAI ASPETTARE NESSUNO.
#
# Tazo che scendono comprando, l'hype che sale, una statistica che cresce: sono
# i momenti in cui il giocatore scopre a cosa e' servito quello che ha fatto, e
# un numero che cambia di colpo non lo racconta. Pero':
#
#   ANIMARE SI', SBARRARE MAI.
#
# Paweł Durczok, smontando l'interfaccia di Final Fantasy XVI, chiama "peccato
# capitale" una schermata che non si chiude finche' l'animazione non e' finita,
# e l'esempio che porta e' esattamente questo: il riassunto di fine scontro dove
# esperienza, punti, soldi e fama salgono con l'ammorbidimento, "which prolongs
# the tail end", e solo dopo si puo' chiudere. "You'll be seeing hundreds of
# those screens during the course of the game."
#
# Qui la separazione e' netta e sta tutta in subito(): l'animazione e' un
# regalo, non un pedaggio. Chiunque puo' interromperla in qualunque momento e
# il numero e' gia' quello giusto - e chi chiama subito() NON DEVE aspettare
# niente, perche' non c'e' niente da aspettare.
#
# La regola per chi lo usa: l'azione del giocatore fa il suo mestiere E salta
# l'animazione, nello stesso istante. Non "il primo clic salta, il secondo
# agisce": quello e' lo stesso difetto con un vestito diverso.

const DURATA := 0.45      # quanto ci mette a percorrere tutta la distanza
const PASSO_MINIMO := 0.16   # ...ma anche un +1 si deve vedere

var etichetta: Label
var formato := "%d"
var mostrato := 0         # il numero che si legge adesso
var meta := 0             # dove sta andando
var tempo: Tween = null


static func su(quale: Label, come := "%d") -> Conto:
	var c := Conto.new()
	c.etichetta = quale
	c.formato = come
	return c


func scrivi(valore: int) -> void:
	# il valore di partenza, quello che c'e' prima che succeda qualcosa: si
	# scrive e basta, non si anima. Un contatore che sale da zero ogni volta
	# che apri il menu non racconta niente, fa solo aspettare
	ferma()
	meta = valore
	mostrato = valore
	ridisegna()


func vai_a(valore: int) -> void:
	if valore == meta:
		return
	meta = valore
	if Impostazioni.movimento_ridotto or not vivo():
		subito()
		return
	var distanza := absi(meta - mostrato)
	var quanto := clampf(float(distanza) / 60.0, PASSO_MINIMO, DURATA)
	ferma()
	tempo = etichetta.create_tween()
	tempo.tween_method(passa_per, float(mostrato), float(meta), quanto) \
			.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


func subito() -> void:
	# LA PORTA DI SERVIZIO, e non e' un caso limite: e' il modo normale in cui
	# questo contatore finisce quando il giocatore ha fretta. Non aspetta
	# niente, non restituisce niente da aspettare, e dopo di lei il numero e'
	# quello vero.
	ferma()
	mostrato = meta
	ridisegna()


func in_corso() -> bool:
	return tempo != null and tempo.is_valid() and tempo.is_running()


func passa_per(valore: float) -> void:
	mostrato = int(round(valore))
	ridisegna()


func ferma() -> void:
	if tempo != null and tempo.is_valid():
		tempo.kill()
	tempo = null


func vivo() -> bool:
	return etichetta != null and is_instance_valid(etichetta) and etichetta.is_inside_tree()


func ridisegna() -> void:
	if vivo():
		etichetta.text = formato % mostrato


static func salta(elenco: Array) -> void:
	# quello che chiama chi riceve un'azione del giocatore: tutti i numeri in
	# volo atterrano, e poi l'azione va avanti per la sua strada
	for c in elenco:
		if c is Conto:
			(c as Conto).subito()
