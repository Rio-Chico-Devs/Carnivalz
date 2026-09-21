class_name IntenzioneCombattimento
extends RefCounted

# IL CLICK ARRIVATO PRESTO NON SI BUTTA, SI TIENE.
#
# Bru, provando: «il primo click su DIFESA non fa niente». Era vero, e non era
# un difetto isolato: agisci_ora usciva in silenzio quando la ricarica non era
# finita, e un bottone `disabled` in Godot non emette nemmeno `pressed` pur
# mangiandosi il click. Quindi ogni comando dato un attimo troppo presto
# spariva, senza che niente lo dicesse.
#
# E' il caso da manuale dell'input buffering. Ellison (docs/fonti/
# input-buffering-wayline.md): «se quella pressione cade anche solo pochi
# millisecondi prima che si apra la finestra, e' semplicemente persa. Il
# personaggio resta fermo, il giocatore si sente truffato».
#
# Ed e' anche, alla lettera, il Command di Nystrom (docs/fonti/
# command-pattern-nystrom.pdf): l'azione qui e' gia' un oggetto - un Dictionary
# {"tipo": ..., "id": ...} - e «e' qui che sfruttiamo il fatto che il comando e'
# una chiamata reificata: possiamo RITARDARE il momento in cui viene eseguita».
# Chi produce il comando (il menu) e chi lo consuma (l'orologio) non si parlano:
# si parlano attraverso questo posto, che e' l'unico a sapere quando si puo'.
#
# UNA CASELLA SOLA, NON UNA CODA, E VINCE L'ULTIMO. Ellison elenca fra le
# trappole il «sovraccarico della coda» e prescrive di «limitare la dimensione
# della coda e dare priorita' agli input piu' recenti». Se clicchi ATTACCA e poi
# DIFESA, volevi DIFESA: accodarli tutti e due li eseguirebbe tutti e due, ed e'
# esattamente il "controllo appiccicoso" che lo stesso articolo descrive come il
# rovescio della medaglia.
#
# NESSUNA SCADENZA A TEMPO, MA SI VEDE. Un timer qui non ha un valore giusto: la
# ricarica va da 0.45s a 4s, e una finestra da 0.2s come quella dell'articolo -
# pensata per i picchiaduro - lascerebbe morto lo stesso il click dato a meta'
# ricarica. L'intenzione quindi resta finche' non parte, non la sostituisci, o
# non la annulla un fatto: scontro chiuso, lezione in corso, comando passato a
# un altro. E il menu la SCRIVE in cima, cosi' non e' mai una sorpresa: il
# rimedio all'appiccicoso e' farlo vedere, non accorciarlo di nascosto.
#
# PERCHE' UN FILE SUO. Stessa misura fatta per Stati.gd: questo blocco chiama
# SETTE cose del motore e ha un mestiere solo, con un confine netto - qui dentro
# non si esegue nessuna azione, si decide soltanto SE E QUANDO farla partire.
# L'esecuzione resta di agisci_ora, dov'era.

var scontro: Combattimento
var azione: Dictionary = {}   # cosa aspetta. Vuoto = niente in attesa
var di := ""                  # l'id di chi l'ha chiesta

func _init(nodo_scontro: Combattimento) -> void:
	scontro = nodo_scontro

func ricorda(comando: Dictionary) -> void:
	# UN CLICK DATO PRESTO E' UNA DECISIONE, NON UN ERRORE.
	if not scontro.in_corso or comando.is_empty():
		return
	# DURANTE LA LEZIONE, SOLO QUELLO CHE VERONICA CHIEDE.
	#
	# Qui prima c'era un rifiuto secco: durante un passo del tutorial non si
	# teneva da parte NIENTE. La ragione era buona - un comando messo in coda
	# mentre lei parla partirebbe da solo appena finisce, e vedresti succedere
	# una cosa che non hai appena chiesto (Ellison chiama «input contestuale»
	# lo spegnere il buffer durante le scene di intermezzo).
	#
	# Ma la regola era TROPPO LARGA, e lo strumento di misura l'ha beccata:
	# Veronica chiede ATTACCA, tu premi ATTACCA un attimo prima che la ricarica
	# finisca, e non succede niente. E' lo stesso difetto che Bru aveva
	# segnalato - «il primo click non fa niente» - sopravvissuto dentro la
	# lezione, cioe' esattamente dove fa piu' danno: e' li' che il giocatore
	# sta imparando se i suoi comandi contano.
	#
	# La regola giusta e' piu' stretta: si tiene da parte SOLO l'azione che il
	# passo chiede. Non puoi accodare altro (la lezione resta una cosa per
	# volta), e che non parta mentre lei parla lo garantisce gia'
	# momento_buono(), che rifiuta la fase "racconto".
	if not azione_ammessa_dalla_lezione(comando):
		return
	# DI CHI ERA. Fra il click e il momento in cui parte, chi comandi puo'
	# cambiare: se cadi e ne comandi un altro, l'abilita' che avevi scelto non e'
	# piu' sua, e fargliela fare lo stesso sarebbe peggio che perdere il click
	azione = comando.duplicate(true)
	di = String(scontro.combattente_comandato().get("id", ""))

func azione_ammessa_dalla_lezione(comando: Dictionary) -> bool:
	# fuori dalla lezione tutto e' ammesso; dentro, solo cio' che il passo chiede
	var passo: Dictionary = scontro.passo_tutorial()
	if passo.is_empty():
		return true
	# e nemmeno si tiene da parte, se lei non ha ancora parlato: accodare
	# adesso vorrebbe dire far partire l'azione appena finisce di annunciarla
	if not scontro.passo_gia_spiegato():
		return false
	return String(passo.get("azione", "")) == String(comando.get("tipo", ""))

func scorda() -> void:
	azione = {}
	di = ""

func nome() -> String:
	# COME SI CHIAMA QUELLO CHE ASPETTA: non il Dictionary, non il tipo - la riga
	# da scrivere nel menu. Cosi' la coda resta un fatto del motore e il menu
	# resta un disegno
	if azione.is_empty():
		return ""
	var tipo := String(azione.get("tipo", ""))
	var id_cosa := String(azione.get("id", ""))
	match tipo:
		"difendi":
			return "Difesa"
		"fuggi":
			return "Fuga"
		"attacca":
			return "Attacco"
		"abilita":
			return String(GameState.abilita_combattimento(id_cosa).get("nome", id_cosa))
		"oggetto", "leva":
			return String(GameState.dati_oggetto(id_cosa).get("nome", id_cosa))
		"alleato":
			return String(GameState.personaggi.get(id_cosa, {}).get("nome", id_cosa))
	return tipo

func momento_buono() -> bool:
	# OGNI COSA A SUO TEMPO. Mentre c'e' da leggere, o mentre si sta cliccando
	# sui pugni, l'intenzione aspetta: e' la stessa regola del sequenziatore,
	# detta dalla parte del giocatore invece che da quella dell'orologio
	if scontro.fase_adesso() in ["racconto", "minigioco", "chiuso"]:
		return false
	return scontro.giocatore_pronto()

func smaltisci() -> void:
	# IL CONSUMATORE. Nystrom: «del codice - il gestore dell'input o l'IA -
	# PRODUCE comandi e li mette nel flusso; altro codice li consuma e li
	# invoca». Qui il flusso e' lungo uno, e il consumo e' il battito del mondo.
	if azione.is_empty():
		return
	# si butta via solo se lo scontro e' finito, o se nel frattempo la lezione
	# ha cambiato passo e quello che aspettava non e' piu' cio' che viene chiesto
	if not scontro.in_corso or not azione_ammessa_dalla_lezione(azione):
		scorda()
		return
	if not momento_buono():
		return
	if String(scontro.combattente_comandato().get("id", "")) != di:
		# comanda un altro: quello che avevi chiesto non vale piu' per lui
		scorda()
		return
	# SI SCORDA PRIMA DI ESEGUIRE, e agisci_ora lo rifa'. Sembra doppio, e lo e':
	# nessuno dei due da solo verrebbe preso da un sabotaggio, l'ho provato. Ma
	# eseguire un'azione fa scrivere, fa aggiornare le schede e puo' rientrare
	# qui dentro nello stesso giro: se la casella fosse ancora piena, lo stesso
	# comando partirebbe due volte. Meglio due righe che una corsa.
	var parte := azione
	scorda()
	scontro.agisci_ora(parte)
	if scontro.menu != null:
		scontro.menu.principale()
