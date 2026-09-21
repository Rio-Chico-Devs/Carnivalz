# Chi gira, quando, e chi tocca cosa

> Audit dei processi e sottoprocessi di Carnivalz. Bru: «dai un occhio soprattutto
> ai processi e sottoprocessi, in modo che niente si accavalli o ci siano
> contrasti e la performance sia ben pensata e strutturata».
>
> Questo documento è la mappa che ne è uscita, più i difetti trovati. Ogni
> correzione ha una prova, e ogni prova è stata validata rompendo apposta quello
> che misura.

## La mappa

Sei cose girano da sole, e nessun'altra:

| chi | quando gira | si ferma da solo? |
|---|---|---|
| `Frantumi._process` | mentre le schegge cadono | sì, `set_process(false)` e si libera |
| `BoxTesto._process` | mentre la macchina da scrivere scrive | sì, `set_process(false)` |
| `MappaZona._process` | solo se il `!` è in vista | sì, `set_process(obiettivo_in_vista)` |
| `Orologio._process` | solo a orologio acceso | sì, esce subito se spento |
| `Tracciato._process` | mentre l'ECG **si vede** | sì, esce se non è in vista |
| `Combattimento._process` | durante uno scontro in tempo reale | sì, esce se non è avviato |

E una coroutine sola che vive quanto lo scontro: **`pompa_messaggi`**, avviata una
volta da `esegui_scontro` (l'orologio virtuale delle prove è il ramo *else*: o
l'una o l'altro, mai tutte e due).

## I difetti trovati

### 1. Due padroni sulla stessa coda

In tempo reale la coda dei messaggi aveva **due** svuotatori: la pompa, che gira
per tutto lo scontro, e chi ogni tanto si ferma ad aspettare che si sia letto
tutto — il lancio di un minigioco parte da `battuta_di`, cioè da `_process`,
**mentre la pompa sta già leggendo**.

Due cicli pescavano dalla stessa coda: il secondo chiamava `box.mostra()` sopra
la battuta che il primo stava facendo leggere, e quella spariva senza essere mai
stata letta. È esattamente la riga di Veronica prima delle Collisioni infinite.

Peggio: `salta_messaggio` e `area_avanza` sono **uno solo**. Due attese in
parallelo se li rubavano — un click ne saltava due, e la prima smetteva di essere
cliccabile quando finiva la seconda.

Adesso chi arriva secondo non legge: aspetta che il primo abbia finito, che è
esattamente quello che aveva chiesto.

> **La prima prova che ho scritto per questo è passata col sabotaggio dentro.**
> Contava le battute arrivate — e con due svuotamenti in parallelo arrivano tutte
> lo stesso, solo sovrapposte. Riscritta per misurare **quanto sono distanti**:
> senza la guardia, fra la prima e la seconda passano **zero millesimi**.

### 2. Svuotare un contenitore non lo svuotava

`queue_free()` non libera adesso: libera a fine fotogramma, e fino ad allora i
figli vecchi **sono ancora figli**. Chi svuota *e riempie* nella stessa chiamata
per un fotogramma ne ha il doppio, e chi conta i figli legge il numero vecchio.

Il difetto era già stato corretto a mano nel menu di combattimento, **in un posto
solo**. Erano dieci: le scelte della storia, i bottoni della mappa, le voci del
negozio, i menu dei compagni. Adesso la versione giusta sta in `Albero.svuota()`.

Il sabotaggio dà 11 fallimenti, e uno li riassume tutti:
*«girando le pagine si vedono 34 voci su 25»*.

### 3. Il disco interrogato dentro il disegno

«Se il disegno c'è vince lui» è una buona regola, ma era scritta **dentro il
disegno**:

```gdscript
if ResourceLoader.exists(percorso):
    var texture: Texture2D = load(percorso)
```

Sulla mappa quel disegno si rifà a ogni fotogramma finché il `!` pulsa: sessanta
controlli sul filesystem al secondo per un file che c'è o non c'è da quando il
gioco è partito. `load()` almeno passa per la cache delle risorse;
`ResourceLoader.exists()` no, quello guarda davvero.

Adesso c'è `Disegni.texture()`, che ricorda — **anche il no**, che è la risposta
più frequente finché i disegni di Bru non ci sono. `IconeStato` aveva già l'idea
giusta a metà: ricordava se il file esisteva, e poi lo ricaricava lo stesso.

Due controlli, non uno: il contatore `Disegni.ricerche` misura che la cache
funzioni, e una prova sul **sorgente** vieta `ResourceLoader.exists` e `load(`
dentro qualunque `_draw`, `_process` o `disegna*`. Il contatore non basterebbe:
non si accorgerebbe di qualcuno che smette di usare `Disegni` del tutto.

### 4. L'ECG: una fila che scorreva, e che non dormiva mai

`spingi()` faceva scorrere tutto l'array di un posto — **239 scritture per
campione, 60 campioni al secondo**, per tutta la durata di ogni scontro. Fa la
stessa identica cosa muovere il punto di partenza: la storia è un **anello**.

E campionava anche da nascosto. Il quadrante fa tre mestieri e ne mostra uno per
volta: mentre scegli da una lista, o mentre il box racconta, l'ECG non è a
schermo — e ora non lavora.

### 5. Il crash: la scena cambia mentre il box parla

Il più serio di tutti, e non dava un errore — dava un **crash del motore**.

Ogni attesa della voce passa da `await`, e durante un `await` la scena può
cambiare: lo scontro finisce, il giocatore torna al menu, una stanza lo manda
altrove. `change_scene_to_file` libera la vecchia scena — e con lei il box e la
zona cliccabile — ma **l'albero sopravvive**, quindi la coroutine si risveglia lo
stesso al fotogramma dopo e va a scrivere su roba che non c'è più.

Adesso dopo ogni attesa la voce si chiede se è ancora viva, e se no smette in
silenzio. Gli effetti in coda si applicano comunque: sono cose che succedono nel
mondo, non a schermo.

> **La prova ha trovato da sola un secondo punto scoperto** che non avevo visto:
> `svuota_coda` mostrava la battuta controllando solo `muta`, non se il box
> esistesse ancora. E col sabotaggio rimesso dentro la suite non fallisce:
> **crasha, signal 11**. È la dimostrazione più netta che si potesse avere.

## I passi usciti puliti

Vale la pena scriverli, perché "ho guardato e non c'era niente" è un risultato:

- **Segnali doppi.** In Godot 4 una connessione identica ripetuta è già un
  errore, e la suite fallisce sugli errori. Le connessioni con `bind` diverso —
  che *non* darebbero errore — stanno tutte su nodi appena creati.
- **Tween che si accavallano.** Ognuno o è ucciso prima (`tween_testo`,
  `tween_indicatore`, `tween_sfondo`, `tween_nastro`, `tween_scossa`,
  `tween_allarme`), o nasce su un nodo appena creato. `Stile.pulsa` e
  `Stile.lampeggia` usano `nodo.create_tween()`, quindi muoiono col nodo.
  Un sospetto sul box del testo era **sbagliato**: `ferma_tween()` c'era già.
- **Costruire stringhe o nodi a ogni fotogramma.** Due `_draw` allocano un RNG,
  ma girano solo al ridimensionamento.

## Dove si salva

> «non puoi salvare a metà scontro, il salvataggio solo fuori dalle fratture,
> nelle fratture al massimo ci sono checkpoint» — Bru

La regola era già rispettata, ma **niente la difendeva**: il salvataggio si chiama
da due posti soli, e bastava una riga in più da qualche parte — un bottone
«salva» nella pausa, un salvataggio a fine scontro «per comodità» — perché
cadesse in silenzio.

| dove | perché è lecito |
|---|---|
| `Sede._ready` | rientrare alla Sede **è** il salvataggio: fuori dalle fratture |
| `IngressoNodo`, dietro `salva_checkpoint` | il checkpoint di una zona lunga |

Adesso una prova gira su tutti gli script e boccia qualunque terzo punto. E un
checkpoint **non è un punto da cui si riparte**: tiene il bottino — flag, tazo,
oggetti — ma ricaricando si torna fuori, con `nodo_corrente` vuoto, la mappa
della zona scaricata e le stanze ripulite di nuovo da ripulire.

## Una giornata camminata per davvero

C'era già una prova «passo per passo», ma cammina i **dati**: questo nodo porta a
quello. Adesso ce n'è una che cammina il **mondo** — dopo ogni tappa, quali flag
ci sono, quanti tazo, quali appunti, quali messaggi.

Con due domande che nessuno faceva:

- **nessun flag del futuro.** Dopo il risveglio in infermeria, `ordini_ricevuti`
  non deve esserci ancora: una tappa che si accende da sola è un pezzo di storia
  saltato;
- **entrare due volte non conta due volte.** Un nodo si può rivisitare — la mappa
  lo permette apposta — e gli effetti di una seconda visita sono la classe di
  difetto che nessuno prova mai. Sabotato: i 3000 tazo di benvenuto diventano
  **15030**.

## Sotto le dita di chi prova

### Il combattimento

Le difese c'erano già ed erano giuste — `riarma()` scatta **prima** di eseguire,
quindi il secondo click trova la ricarica azzerata — ma niente le congelava.
Adesso: tre click nello stesso fotogramma fanno arrivare un colpo solo,
martellare durante la ricarica non fa niente, attacco e fuga insieme ne passa
uno, a scontro finito non si agisce più, e **la pausa ferma il mondo** (in tempo
reale una pausa che non ferma l'orologio vuol dire prendere botte mentre leggi).

> Il primo sabotaggio che ho provato — spostare `riarma()` *dopo* l'azione — non
> ha rotto niente, e aveva ragione lui: `esegui_azione` non aspetta mai, quindi
> lì l'ordine non cambia nulla. Quello che la prova difende è `riarma` in sé:
> toltolo, **tre click fanno tre colpi**.

### Il minigioco

Il segnale `finito` è tutto: è lì che il combattimento riprende, si applica il
danno e il tutorial va avanti. Sei prove lo inchiodano — una raffica finisce una
volta sola, il tempo che scorre dopo la fine non ripete niente, cliccare a
raffica finita non fa danni, pararli tutti costa zero, non pararne nessuno costa
tutto, e da muto l'esito arriva subito.

> Una mia prova era sbagliata e **il gioco aveva ragione**: cliccare tutti i
> pugni a tempo zero non para niente, perché si para *solo dentro la finestra* —
> ed è il cuore del minigioco. Riscritta come una mano perfetta.

### L'orologio delle scelte a tempo

Cinque prove: scade una volta sola, fermarlo vuol dire che non scade, la lancetta
non risale mai, due orologi insieme scadono nell'ordine giusto, e si fermano con
la pausa.

E una **sesta che non ha un `esigi()`**: disegna l'orologio da pieno a zero con
fotogrammi veri, e l'assertore è `esegui.sh`, che boccia la suite se Godot stampa
un errore. Ne stampava cinque.

**Il difetto**: quando il tempo finisce la quota è zero e l'angolo è TAU, quindi
l'ultimo punto dell'arco torna esattamente sul primo — e un poligono chiuso su se
stesso non si può tagliare in triangoli. Con una scelta a tempo a schermo la
console si riempiva di `triangulation failed`, tanto che un errore vero ci sarebbe
finito in mezzo senza farsi notare.

> Trovato **per esclusione**, e vale la pena dirlo: la mia prima ipotesi era la
> fetta troppo sottile appena parte. Provate una per una, né una soglia
> sull'angolo minimo né un punto in più sull'arco cambiavano niente. Era solo il
> giro intero. La correzione è un `minf(angolo, TAU - 0.01)`.

## Chi controlla i controlli

Le prove sui dati leggono i file che ci sono e dicono che va tutto bene. Ma la
domanda vera è un'altra: **se Bru sbaglia scrivendo un file nuovo, queste prove
se ne accorgono?** Una rete mai provata con un sasso è il disegno di una rete.

Adesso ai raccoglitori si danno dati sbagliati apposta — un flag che nessuno
accende, un oggetto che nessuno lascia cadere, una destinazione inventata, un
gruppo misto — e si guarda che li vedano. Sabotando il raccoglitore dei flag, la
prova delle porte chiuse «guarda nel vuoto»: ed è esattamente quello che avrebbe
fatto in silenzio.

E una cosa che taceva: **un nemico inventato scendeva in campo lo stesso**, con
statistiche di ripiego e il suo id come nome. Si combatteva contro
`goblin_tipco` senza che niente lo dicesse. Adesso lo dice.

## La perdita di oggetti

Misurata a parte, e vale la pena ripeterla qui: **il gioco avviato da solo non
perde niente**. A perdere è la suite — coroutine ferme su un `await` dentro
combattimenti che una prova libera a metà volo, e in Godot 4 una coroutine
sospesa non si annulla. `prove/esegui.sh` fallisce se a perdere è il gioco.

## La struttura, misurata

Fin qui l'audit aveva guardato **il comportamento**: chi gira, chi si accavalla,
chi perde oggetti. Non aveva mai guardato **la forma del codice**, ed è una cosa
diversa: un gioco può funzionare benissimo e restare impossibile da mantenere.

I numeri di partenza:

| | |
|---|---|
| `scripts/` in tutto | 18 183 righe in 940 funzioni |
| `Combattimento.gd` | **4 596 righe — un quarto di tutto il codice** |
| `GameState.gd` | 2 511 |
| `Main.gd` | 1 415 |
| la funzione più lunga (`esegui_mossa`) | 318 righe |
| annidamento massimo (`GameState.cerca_creature`) | 8 livelli |
| mestieri dichiarati da `Combattimento.gd` nei suoi stessi commenti | 14 |

### `esegui_mossa`: 318 righe → 69

Una battuta in cima e poi un `match` con ventitré rami che facevano ventitré
mestieri diversi — curare, evocare, trasformarsi, incendiare — dentro la stessa
graffa. Adesso sono ventitré funzioni con un nome, e `esegui_mossa` fa una cosa
sola: la contabilità della mossa, e poi smistare.

La suite è rimasta **verde e identica**, e non basta. «Identica» non vuol dire
«verificata»: se le prove percorrevano cinque rami su ventitré, diciotto
estrazioni erano state fatte alla cieca. Le due prove che mancavano:

- **il ramo «X» chiama `mossa_X`, e basta** — letto dal sorgente, più il verso
  opposto (una funzione estratta che nessun ramo chiama è irraggiungibile). È il
  modo in cui un'estrazione a ventitré mani si sbaglia davvero: il ramo `cura`
  che finisce per chiamare `mossa_rubavita`. A schermo non si vede, e nessuna
  prova di comportamento lo nota — una mossa sbagliata è comunque una mossa che
  funziona. Sabotato apposta: **solo questa prova se n'è accorta**.
- **ogni ramo si percorre per davvero**, con una mossa vera dal bestiario o una
  fatta a mano quando nessuno la usa.

La prima versione della seconda prova misurava la cosa sbagliata — leggeva
`ultima_mossa_tipo`, che `esegui_mossa` scrive **prima** del `match`: svuotando
un ramo sarebbe passata lo stesso. Terzo errore della stessa famiglia in questo
audit, preso prima di consegnarlo.

### `buff_fattore`: nessuno ce l'ha

Ventidue rami su ventitré li dichiara qualche creatura. Quello no. Non è codice
morto: è **l'unico tipo di mossa che sappia alzare il Fattore Carnivalz**, perché
`potenziamento` passa dai buff e un buff di stat `fattore` non lo legge nessuno
(`Regole.gd` guarda solo attacco, difesa e velocità). Sta nel README e sa
descriversi nella scheda nemici. È **contenuto che manca, non codice da
togliere**, e la scelta è di Bru. Intanto è scritto col perché in
`RAMI_SENZA_CREATURA`, il ramo viene percorso lo stesso, e se domani qualcuno lo
usa la prova chiede di togliere l'eccezione.

### Quale pezzo staccare: misurato, non scelto a occhio

Il piano era di portare fuori **le abilità**. Prima di spostare quattrocento
righe ho misurato quanto costa staccare ogni blocco — quante funzioni del motore
continuerebbe a chiamare da fuori, e quante variabili del nodo:

| blocco | righe | funzioni del motore | variabili del nodo |
|---|---|---|---|
| abilità (Astio, Vendetta, Mantra, Flagello, Mattanza…) | 422 | **25** | **7** |
| stati + combustione | 249 | **6** | 0 |
| abilità di Veronica e Yhvina | 440 | 26 | — |

Le abilità **non sono un modulo**: sono codice che vive dentro il motore. Le
venticinque chiamate sarebbero diventate altrettante `scontro.qualcosa()`
dinamiche, perdendo il controllo dei tipi su tutte, per guadagnare un file in
più e niente altro. E il blocco non è nemmeno completo: metà delle abilità che
`usa_abilita` smista (`attacco_area`, `carica`, `guardia`, `copertura`…) stanno
altrove nel file. **Piano cambiato sui numeri.**

`Stati.gd` invece è un taglio pulito: 249 righe, un mestiere solo, e delle sei
funzioni del motore che continua a chiamare **quattro servono solo a dire una
frase**. Qui dentro non si decide chi attacca chi, non si calcola un danno, non
si tocca la plancia: si legge `stati.json` e si applica.

`Combattimento.gd`: **4 596 → 4 420 righe**, e un mestiere in meno dei quattordici.

### Cosa resta aperto

`GameState.gd` (2 511 righe), `Main.gd` (1 415), `aggiungi_combattente` (164),
`mossa_eseguibile` (124), `applica_stato` (118), `_leggi_salvataggio` (120), gli
otto livelli di annidamento in `GameState.cerca_creature`. E dentro
`Combattimento.gd` i tre blocchi pesanti — il tempo (705), la scelta delle mosse
(687), la risoluzione dei colpi (631) — che per ora **non conviene staccare**, e
adesso c'è la tabella che dice perché.

## Il tetto, e come si comporta la rete

Le due estrazioni qui sopra hanno rimesso a posto quello che c'era. Non
impediscono a niente di ricrescere: fra sei mesi `esegui_mossa` può tornare a
trecento righe e la suite resterebbe verde, perché il gioco non sarebbe rotto.

Adesso c'è un tetto, e **le soglie sono misurate, non scelte**:

| | mediana | 90° | 99° | tetto | eccezioni |
|---|---|---|---|---|---|
| 964 funzioni, in righe | 11 | 32 | 86 | **100** | 7 |
| 49 file, in righe | 182 | 662 | — | **700** | 4 |
| annidamento | 1 | 2 | 4 | **4** | 4 |

Cento righe per funzione sta **sopra** il 99° percentile: non è una regola presa
da un libro, è quello che questo codice già fa da solo 957 volte su 964.

L'annidamento conta solo le righe che **aprono un blocco** (`if`, `for`,
`while`, `match`). Contare l'indentazione di tutte le righe sembrava più
semplice e misurava un'altra cosa: una condizione spezzata su due righe con la
barra, o un `Dictionary` scritto su più righe, stanno rientrati di tre tab senza
essere annidati per niente, e il numero veniva su gonfiato — 8 livelli invece
dei 7 veri, e undici funzioni "colpevoli" invece di quattro.

**Come si comporta la rete:**

- una cosa nuova sopra il tetto → fallisce: il codice non peggiora;
- un'eccezione che cresce → fallisce: quelle che ci sono non si allargano;
- un'eccezione che scende sotto il tetto → fallisce, e chiede di togliersi
  dall'elenco: la rete si stringe, non si allenta;
- un'eccezione per una cosa che non esiste più → fallisce;
- un'eccezione senza una motivazione vera → fallisce. Un elenco senza perché è
  solo un modo lento di spegnere il controllo.

Quello che **non** fa: stringersi da sola quando una cosa cala restando sopra il
tetto. Se `Combattimento.gd` scende da 4421 a 3000 righe, nell'elenco resta
scritto 4421 finché qualcuno non aggiorna il numero. È un compromesso voluto —
se ogni miglioramento facesse fallire la suite, la prima cosa che si impara è a
spegnerla.

E quello che non misura: `prove/`. Questo file è oltre settemila righe e non
passerebbe nessuno dei tre tetti. Non è una svista: un file di prove cresce di
una funzione ogni volta che si prova una cosa in più, quindi un tetto lì
fallirebbe a ogni prova nuova, e si imparerebbe ad alzare il numero senza
guardare. Una rete che si impara a disinnescare non protegge più niente.

**Validata rompendola sei volte**: una funzione lunga nuova, una funzione
annidata nuova, un'eccezione cresciuta, un'eccezione scesa sotto il tetto,
un'eccezione per un file che non esiste, un'eccezione con `"perche": "boh"`.
Tutte e sei nominate per nome, con la misura vera nel messaggio.

## La revisione della revisione

Bru: «documentati su controllo qualità, ordine e leggibilità, modularità e
product engineering, e poi rivedi il tuo lavoro così capisci». Fatto in
quest'ordine, e il primo tetto ad andare giù è stato il mio.

### 1. La metrica era quella debole

Avevo messo tre tetti: righe per file, righe per funzione, profondità
dell'annidamento. Due su tre misurano male, e la letteratura lo dice da anni.

Sulla **lunghezza**: McConnell, in *Code Complete*, cita sei studi in cui le
funzioni più lunghe non avevano più difetti — e in diversi casi costavano meno e
si leggevano meglio. Il numero di righe misura quanto una funzione è *grande*,
non quanto è *difficile*.

Sull'**annidamento**: il difetto era mio. Misuravo il punto più profondo, quindi
una funzione con un solo `if` dentro due cicli e una annidata dalla prima riga
all'ultima prendevano lo stesso voto.

Adesso il garbuglio si misura con la **complessità cognitiva** — la metrica che
SonarSource ha inventato proprio perché la ciclomatica misura bene la
testabilità e male la leggibilità. Somma invece di prendere il massimo, e fa
pagare la profondità a ogni punto in cui succede.

**La prova che la metrica vecchia guardava altrove**: fra le quattro funzioni più
ingarbugliate del progetto, **due non erano mai comparse**.

| funzione | garbuglio | righe | annidamento | la vedeva il tetto vecchio? |
|---|---|---|---|---|
| `Combattimento.risolvi_drop` | 63 | 47 | 5 | solo per l'annidamento |
| `Combattimento.mossa_eseguibile` | 52 | 123 | 5 | sì |
| `Main.ricostruisci_scelte` | **48** | 58 | 3 | **no** |
| `GameState.cerca_creature` | 44 | 44 | 7 | sì |
| `Combattimento._ready` | **41** | 61 | 2 | **no** |

Non sono lunghe e non sono profonde: sono catene di condizioni piatte.

La soglia è **15**, che è insieme il predefinito di Sonar e il 95° percentile di
questo codice — le due cose cadono nello stesso punto, ed è il miglior argomento
possibile per una soglia. Le 35 eccezioni portano il numero misurato; **sopra 30
serve anche il perché**, perché sotto è debito che si tiene d'occhio e sopra è un
difetto, che va chiamato per nome. Il tetto sulle righe resta ma **declassato**:
non è più il controllo principale, è una rete grossolana contro la funzione che
diventa un file.

Validata rompendola con la forma esatta che il tetto vecchio non vedeva: venti
`if` in fila, 43 righe, due livelli di profondità. Garbuglio 20 → bocciata.

### 2. Tre passacarte, e una funzione vuota nata da una mia regola

La regola del Passo 15 diceva: «il ramo X chiama `mossa_X`, punto». Mi ha fatto
scrivere tre funzioni che non servivano a niente:

```gdscript
func mossa_difendi(nemico, _mossa) -> void:   difendi(nemico)
func mossa_orda(nemico, mossa) -> void:       marea(nemico, mossa)
func mossa_scena(_nemico, mossa) -> void:     pass
```

Un salto in più, un nome in più, zero complessità nascosta — ed è precisamente la
bandiera rossa che Ousterhout chiama **passacarte**, e il difetto che Google mette
per primo dopo il progetto: *codice più complicato del necessario*. L'ultima è
peggio delle altre: una funzione **vuota**, nata solo per far contenta una prova
che avevo scritto io.

La regola giusta non è «niente eccezioni», è «le eccezioni si dichiarano». Ora il
ramo chiama la funzione che fa la cosa anche quando si chiama diversamente, e
`RAMI_CABLATI_ALTROVE` dice quale e perché. La protezione contro il cablaggio
sbagliato resta intera.

### 3. Il tipo che si può mettere, e quello che non si deve

La guida di stile di Godot è netta: tipare tutto quello che si può — gli errori
si prendono al parse invece che in partita, e il bytecode è più veloce. I moduli
del combattimento tenevano un `var scontro` **senza tipo**: 44 chiamate che
nessuno controllava.

Ho provato se un riferimento ciclico fra `class_name` regge in Godot 4.4 — regge.
`Combattimento` ha un `class_name`, e `Stati.gd` dichiara
`var scontro: Combattimento`: **23 chiamate dinamiche diventate statiche**.

Su `Menu.gd` la stessa cosa fa cadere la suite in sei punti, e tipando anche il
parametro di `_init` **la pianta oltre i seicento secondi dentro il parser**. Il
motivo non è un bug: lì passa anche un `FintoScontro`, un oggetto che risponde
alle sole cinque domande che il menu fa davvero, e serve perché uno scontro vero
gira in tempo reale e non finisce — la prima versione di quella prova accendeva un
combattimento intero per premere quattro voci di menu, e la suite si piantava.

Quindi: **tipi statici** contro **sostituibilità**, che l'ISO 25010 chiama
testabilità e mette dentro la manutenibilità esattamente come la modularità.
Vince la seconda, perché il menu non usa il combattimento: gli fa cinque domande,
e dipendere da cinque domande invece che da una classe da quattromila righe è la
dipendenza più stretta possibile, non la più larga. Il difetto vero non era il
tipo mancante: era che **non c'era scritto perché mancava**. Adesso c'è.

### 4. Quello che ho trovato e NON ho toccato

La guida di stile di Godot fissa l'ordine delle dichiarazioni: costanti, statiche,
`@export`, `var`, `@onready`. Sei file non lo rispettano, 84 dichiarazioni in
tutto — quasi sempre `@onready` prima dei `var` normali.

Non l'ho sistemato, e la ragione è la stessa che vale per tutto il resto: in
`Combattimento.gd` i nodi `@onready` stanno raggruppati in cima **con un commento
che dice cosa sono**, e sotto c'è «i quattro collaboratori». Riordinare per
soddisfare la convenzione spezzerebbe un raggruppamento che serve a chi legge — e
lo scopo della convenzione è servire chi legge. Sta scritto qui perché sia una
scelta e non una svista; se Bru preferisce l'ordine canonico, è mezz'ora di
lavoro meccanico.

### 5. Quello che so di non avere

Le sabotature funzionano — ne ho fatte sedici in questi passi, e ogni volta ho
guardato che il messaggio nominasse la cosa giusta. Ma è **mutation testing fatto
a mano**: Google lo fa girare su ogni modifica per 6000 ingegneri, io lo faccio
quando me ne ricordo. I mutanti che scelgo sono probabilmente migliori dei loro
(li scelgo sapendo dove fa male), ma non sono ripetibili: fra sei mesi nessuno
saprà quali erano. Registrarli in modo che si rigiochino da soli è il pezzo che
manca, ed è il prossimo lavoro serio sulle prove.

## Il sequenziatore: una fase alla volta

Bru, provando: *«non è reattivo […] quando dovevo premere su difesa ci ho
cliccato e il primo click è andato a vuoto»*. E: **«tutto deve essere misurato»**.

Quindi prima lo strumento — `./prove/misura.sh` fa girare uno scontro **vero**
per dodici secondi campionando a ogni fotogramma — e il primo numero ha
ribaltato la diagnosi.

| | prima | dopo |
|---|---|---|
| menu a schermo (scontro normale) | 44% | **71%** |
| **pronto ma coperto** (scontro normale) | — | **0,2%** |
| **pronto ma coperto** (tutorial) | **76%** | **0,0%** |
| ridisegni di scheda in 12s | 6 | 8 |
| letture dal disco in 12s | 0 | 0 |

«Pronto ma coperto» è la quota di tempo in cui il giocatore può agire e il
pannello dei comandi **non è a schermo**: lì ogni click lo mangia il box del
testo. Nel tutorial era tre quarti del tempo.

**E la parola «performance» non reggeva.** Il costo per fotogramma era già
minimo — otto ridisegni in dodici secondi, **zero** letture dal disco. Il gioco
non sprecava lavoro: rendeva le cose disponibili al momento sbagliato. Sono due
difetti diversi, e chiamare «lentezza» il secondo avrebbe mandato a ottimizzare
codice già a posto.

### La causa: cinque booleani per una cosa sola

Le fasi c'erano già, ma non avevano un nome: erano sparse in `menu_acceso`,
`tempo_fermo`, `lezione_in_corso`, `minigioco.attivo`, `coda.is_empty()`. Cinque
booleani che potevano dire cose diverse insieme — e lo dicevano.

Bru: *«basta creare una lista di priorità: quando scatta un evento il box fa una
cosa, finisce l'evento e non ci sono altri dialoghi? torna il menu […] ogni cosa
a suo tempo e in modo organizzato»*. È alla lettera quello che la letteratura
chiama macchina a stati: *«un combattimento JRPG è una sequenza di fasi distinte,
un candidato perfetto per una FSM»*.

Cinque fasi: `chiuso`, `minigioco`, `racconto`, `comandi`, `attesa`. Due regole:

- **fase `comandi` → il quadrante mostra il menu, sempre**;
- **fase `racconto` → il mondo non avanza, sempre.** Bru: *«mentre ci sono i
  dialoghi tutto si incentra nella lettura […] se il nemico dice "adesso il mio
  colpo migliore!", il dialogo prima e poi colpisce»*.

**La fase non si tiene in una variabile: si chiede ai fatti.** Una fase salvata
può restare indietro, ed è esattamente così che questa roba si rompe — il
pannello dice una cosa e il motore un'altra. Una prova verifica anche questo,
leggendo il sorgente.

### Due cose che resto a dire invece di nasconderle

**Lo 0,2% che resta** è il fotogramma fra il cambio di fase e il ridisegno del
pannello. Un click che arriva proprio lì si perde ancora: un caso su cinquecento,
non la causa di quello che Bru ha sentito, ma esiste.

**Il metro era sbagliato la prima volta.** Misuravo `menu_acceso`, che è uno dei
booleani stantii che il sequenziatore ha sostituito: restava vero mentre il
giocatore *non* poteva agire, e contava come click a vuoto quella che era solo
lettura. Uno strumento va tarato come il codice che misura.

## Il comando dato presto: `Intenzione.gd`

Lo 0,2% qui sopra non era lo 0,2%. Il conto della fase guardava dove finiva il
click, non se l'azione partiva: e l'azione poteva non partire anche a pannello
acceso, perché **`agisci_ora` usciva in silenzio quando la ricarica non era
finita**. Bru lo aveva detto in una riga — «la prima volta che clicco su difesa
non fa niente» — e io avevo letto "il pannello non c'era".

### La cosa che nessuno guardava: un bottone spento mangia il click

In Godot un `Button` con `disabled = true` **non emette `pressed`**, e siccome
il suo `mouse_filter` resta `STOP` **si prende lo stesso l'evento**. Il menu
spegneva le voci mentre ricaricavi (`fermo or ...`, dieci volte in
`Menu.principale`), quindi il click non veniva né servito né sentito: spariva
dentro un bottone grigio. Non c'era nessun punto del codice in cui potesse
essere ricordato.

### Cosa dicono le fonti (e cosa non dicono)

Ellison, *Input Buffering* (`docs/fonti/input-buffering-wayline.md`): «se quella
pressione cade anche solo pochi millisecondi prima che si apra la finestra, è
semplicemente persa». Il rimedio è «una coda che tiene gli input, pronta a
eseguirli appena lo stato del gioco lo permette».

Nystrom, *Command* (`docs/fonti/command-pattern-nystrom.pdf`): l'azione qui è
già un oggetto — `{"tipo": "difendi"}` — quindi *«è qui che sfruttiamo il fatto
che il comando è una chiamata reificata: possiamo **ritardare** il momento in
cui viene eseguita»*. E il pezzo che è servito di più: *«del codice produce
comandi e li mette nel flusso, altro codice li consuma e li invoca. Mettendo
quella coda in mezzo abbiamo disaccoppiato il produttore dal consumatore.»*

**Quello che NON ho preso.** Nystrom scrive che «in un certo senso il Command
pattern è un modo di emulare le closure nei linguaggi che non ce l'hanno» —
GDScript le ha. Quindi niente ventitré classi comando: l'azione resta il
Dictionary che era già, e il pattern qui vale per **dove** il comando aspetta,
non per come è fatto.

### Le due decisioni che potevano andare storte

**Una casella sola, non una coda.** Ellison elenca fra le trappole il
«sovraccarico della coda» e prescrive di «dare priorità agli input più
recenti». Se clicchi ATTACCA e poi DIFESA volevi DIFESA: accodarli entrambi li
eseguirebbe entrambi, ed è il «controllo appiccicoso» che lo stesso articolo
descrive come il rovescio della medaglia.

**Nessuna scadenza a tempo — ma si vede.** L'articolo propone 0.2s, misura da
picchiaduro. Qui la ricarica va da 0.45s a 4s: 0.2s lascerebbe morto lo stesso
il click dato a metà ricarica. Quindi l'intenzione resta finché non parte, non
la sostituisci, o non la annulla un fatto (scontro chiuso, lezione in corso,
comando passato a un altro) — e **il menu la scrive in cima**: `⏳ in coda:
Difesa`. Il rimedio all'appiccicoso è farlo vedere, non accorciarlo di nascosto.

### E resta la regola di Bru

«Mentre ci sono i dialoghi tutto si incentra nella lettura.» Vale anche per un
comando già dato: `momento_buono()` rifiuta le fasi `racconto`, `minigioco` e
`chiuso`. Durante la lezione di Veronica il buffer è **spento del tutto** —
Ellison, fra le tecniche avanzate: «input contestuale: puoi disattivare l'input
buffering durante le scene di intermezzo».

### Il conto della struttura

Il blocco valeva 115 righe dentro `Combattimento.gd`. Novantasette sono uscite
in `Intenzione.gd` — stessa misura fatta per `Stati.gd`: **sette chiamate al
motore, un mestiere solo**, e un confine netto (qui non si esegue niente, si
decide *se e quando*). In più è sparito `esegui_turno`, un passacarte a
`battuta_di` che non chiamava più nessuno. Netto: **+24 righe**, e il tetto è
stato alzato da 4544 a 4569 **scrivendo il conto per intero** nella riga
dell'eccezione, non ritoccando il numero.

### Il buco che il sabotaggio ha trovato nella mia prova

Quattro sabotaggi su `Intenzione.gd`. Tre presi. Il quarto — *la lezione non
ferma più il buffer* — **è passato verde**, perché la verifica stava dentro un
`if not passo_tutorial().is_empty():` e in quello scontro (un goblin, non
l'allenamento) il tutorial è vuoto: il ramo non entrava mai. Una prova che
salta se stessa in silenzio è peggio di una prova che manca, perché **si conta
lo stesso**. Adesso il passo si mette a mano e c'è una verifica che controlla
di averlo acceso davvero.

Il quinto sabotaggio è stato inutile in modo interessante: togliere `scorda()`
da `smaltisci()` non rompe niente, perché `agisci_ora` lo rifà. Le due righe
restano — eseguire un'azione può rientrare nello stesso giro — ma adesso il
codice dice che sono doppie apposta.

## Il metro era sbagliato: la complessità cognitiva, letta dalla specifica

Il cancello strutturale si fida di `complessita_cognitiva()`, e quella funzione
l'avevo scritta **a memoria da una sintesi**. Con la specifica di Campbell in
mano (`docs/fonti/complessita-cognitiva-sonar.pdf`) una delle quattro regole
era sbagliata.

**Come la contavo:** «la riga contiene un `and`? +1. Contiene un `or`? +1.»

**Come si conta:**

> *«La complessità cognitiva non incrementa per ogni operatore logico binario.
> […] Capire la seconda riga di ogni coppia non è molto più difficile della
> prima»* — `a and b` contro `a and b and c and d`.

Cioè: una **sequenza** di operatori uguali vale **uno**. Si paga solo quando
l'operatore **cambia**. `a and b or c and d` vale tre, non due.

**Cosa è cambiato misurando.** Undici funzioni si sono spostate — dieci in su
(la più colpita, `condizioni_mossa`, da 21 a 25) e una in giù. Il numero non
scendeva quasi mai perché il mio conto *sottostimava* le condizioni alternate,
che sono proprio quelle faticose da leggere.

**E il calo ha trovato altro.** `battuta_di` era registrata a 38 e misurava 30:
era calata da sola in qualche rifacimento precedente, e la rete non se n'era
accorta perché **un calo che resta sopra il tetto passa in silenzio, per
scelta** (se ogni miglioramento facesse fallire la suite, la prima cosa che si
impara è a spegnerla). Ho ritarato tutte e trentaquattro le voci sulla misura
vera: la rete si stringe.

**Adesso il metro ha una prova sua** (`prova_il_metro_del_garbuglio_e_quello_giusto`),
e i casi non me li sono inventati: sono **gli esempi che la specifica porta
scritti**, tradotti da `&&`/`||` a `and`/`or`, più l'esempio completo con l'`if`
che vale 4. Più due regole che distinguono questa metrica da quella ciclomatica
e che *non* avevo sbagliato: un `match` vale **uno** per tutto il blocco (è il
motivo per cui `esegui_azione` non è punita per avere ventitré casi), e
`else`/`elif` prendono il punto ma **non** la profondità. Sabotata tornando alla
regola vecchia: quattro verifiche rosse sul metro, più nove sui tetti.

**Cosa resta approssimato, e lo dico qui.** La specifica conta anche le
sotto-sequenze fra parentesi come sequenze a sé (`a and !(b and c)` vale tre):
per farlo servirebbe un parser. E una condizione spezzata su più righe con la
barra si conta riga per riga, quindi può pagare più del dovuto.

## La guida di stile ufficiale di Godot, misurata

`docs/fonti/gdscript-guida-di-stile.pdf`. Misurato invece che ricordato:

**Quello che era già a posto.** Zero violazioni della regola sugli operatori a
capo — *«quando si spezza un'espressione condizionale su più righe, le parole
chiave `and`/`or` vanno messe all'inizio della riga di continuazione, non in
fondo alla precedente»*: 92 continuazioni, 92 conformi. I segnali sono tutti al
passato (`finito`, `scaduto`, `scrittura_finita`). Nessuna costante fuori da
`CONSTANT_CASE`.

**Una violazione vera, e l'ho corretta.** `Collezione.gd` aveva `extends` prima
di `class_name`. L'ordine della guida è: `@tool`, `class_name`, `extends`,
doc comment, segnali, enum, costanti, variabili, `_init`, `_ready`, `_process`,
il resto. Una riga.

**Due scarti che NON correggo, e il perché.**

*Le parentesi invece della barra.* La guida preferisce `(...)` a `\` perché
*«con le barre devi assicurarti che l'ultima riga non finisca con una barra»*.
Qui ci sono 92 continuazioni con la barra. Cambiarle tutte è un rumore enorme
in `git blame` per zero cambiamenti di comportamento, e la trappola che la
guida cita — la barra finale — non si è mai verificata. Se un giorno si tocca un
file per altro, si convertono quelle.

*I nomi dei file.* La guida vuole `snake_case` per i nomi dei file
(`combattimento.gd`), noi abbiamo `Combattimento.gd` in **103 file**.
Rinominarli rompe ogni percorso `res://`, ogni `preload` e ogni riferimento di
scena. È uno scarto dichiarato, non una svista: il nome del file segue il nome
della classe, che è la convenzione opposta ma coerente dentro il progetto.

## Parnas, e perché la mia giustificazione era della forma sbagliata

`docs/fonti/parnas-decomposizione-moduli.pdf`. Il criterio con cui ho deciso
cosa estrarre l'avevo riassunto così: «nascondi la decisione di progetto che
cambierà». Il paper lo dice quasi uguale, quindi il riassunto reggeva:

> *«Proponiamo invece che si cominci da un elenco di decisioni di progetto
> difficili, o di decisioni che è probabile cambino. Ogni modulo è poi
> disegnato per nascondere una di quelle decisioni dalle altre.»*

Ma la frase dopo è quella che non avevo, e mi riguarda:

> *«Poiché, nella maggior parte dei casi, le decisioni di progetto trascendono
> il tempo di esecuzione, **i moduli non corrisponderanno ai passi del
> processo**.»*

E prima, più netta: *«l'ordine nel tempo in cui ci si aspetta che il
processamento avvenga non dovrebbe essere usato nel decomporre in moduli»*, e
*«è quasi sempre scorretto cominciare la decomposizione di un sistema in moduli
sulla base di un diagramma di flusso»*.

### Cosa ne esce per Carnivalz

**Le due estrazioni fatte passano, e adesso so perché.** Non perché chiamavano
«solo sei» o «solo sette» funzioni del motore — quella era una misura di
accoppiamento, utile ma non il criterio. Passano perché **nascondono una
decisione**: `Stati.gd` nasconde cosa fa `stati.json` addosso a un
combattente, `Intenzione.gd` nasconde *quando* un comando dato presto può
partire. E la politica di quest'ultimo — una casella sola, vince l'ultimo,
nessuna scadenza a tempo — è esattamente il genere di cosa che cambierà dopo il
primo playtest vero. È un modulo di Parnas per il motivo di Parnas.

**La giustificazione del file grosso, invece, era della forma sbagliata.**
Avevo scritto che i tre blocchi che restano sono «il tempo, la scelta delle
mosse, la risoluzione dei colpi». Sono **passi del processo**: è letteralmente
il diagramma di flusso che Parnas chiama quasi sempre scorretto come punto di
partenza. Non li stacco lo stesso — ma la ragione che avevo dato (chiamano
decine di funzioni del motore) è una conseguenza, non una causa.

### Due fonti che si contraddicono, e le tengo tutte e due

La ragione *buona* per non staccarli non è mia: è dei due programmatori di
Celeste (`docs/fonti/celeste-player-readme.md`), che sullo stesso problema
scrivono l'opposto di Parnas:

> *«Non avremmo spostato gli stati in classi separate. [...] Uno dei motivi per
> cui ci piace avere un file grosso con qualche metodo enorme è che ci piace
> tenere il codice sequenziale per la manutenibilità. [...] In un platform come
> Celeste il comportamento del giocatore va ordinato e tarato molto
> strettamente, e questo stile di codice è stata una scelta consapevole.»*

Parnas parla di un sistema dove le decisioni trascendono il tempo di
esecuzione. Celeste parla di codice dove **il tempo di esecuzione È la cosa da
tarare**. La risoluzione di un colpo in Carnivalz — a terra, schivata, danno,
impatto, stati, KO — è il secondo caso, non il primo.

Non scelgo fra le due e non fingo che dicano la stessa cosa: sono scritte
tutte e due nella riga dell'eccezione, così chi la legge fra sei mesi vede il
disaccordo invece di una regola inventata da me.

## La pagina di Godot ha trovato una guardia che non serviva

`docs/fonti/godot-inputevent-classe.pdf`. **Non è la pagina che avevo chiesto**
— serviva `Control.mouse_filter`, questo è il riferimento di `InputEvent` — ma
ha trovato lo stesso qualcosa.

In `_unhandled_input` c'era:

```gdscript
if mattanza_attiva and evento.is_action_pressed("ui_accept") and not evento.is_echo():
```

con un commento che diceva che `is_echo()` era «esclusa apposta», perché tenere
premuto lo spazio non deve valere come martellare. La firma vera è
`is_action_pressed(action, allow_echo := false, exact_match := false)`, e la
documentazione dice che il metodo torna vero *«se l'azione corrisponde a questo
evento, è premuta, e non è un evento di eco [...] a meno che allow_echo sia
vero»*. Cioè **la guardia era ridondante**, e il commento accanto diceva che
stava facendo un lavoro che non faceva — che è la cosa peggiore delle due.

**Non mi sono fidata del PDF**: l'ho chiesto al motore, costruendo un
`InputEventKey` con `echo = true`. Risultato: `is_action_pressed("ui_accept")`
→ `false`, con `allow_echo = true` → `true`. Confermato.

Tolta la riga, e al suo posto c'è `prova_tenere_premuto_non_e_martellare`.
Perché il comportamento adesso dipende da **un valore predefinito dell'API che
nel codice non si vede più**: esattamente il tipo di dipendenza invisibile che
un giorno si rompe in silenzio.

**Quello che resta aperto** è ciò per cui avevo chiesto la pagina: se un
`Button` con `disabled = true` si mangi il click invece di lasciarlo passare.
È l'affermazione su cui poggia tutta la correzione del click perso, e la so
per averla vista, non per averla letta. Serve `Control.mouse_filter`.

## Lo strumento mentiva, e dentro la bugia c'era un difetto vero

`prove/misura.sh` stampava **«CLICK ANDATI A SEGNO 0 su 8 (0%)»**, e io ci
avevo scritto accanto *«non fidarsi, non è tarato»*. Ci ho convissuto per
giorni. Tarandolo sono venute fuori due cose rotte, una mia e una del gioco.

**La mia.** Mandavo la pressione del mouse **senza prima muovere il cursore**.
Godot decide quale `Control` riceve un click dal controllo sotto il mouse, e
quello si aggiorna col *movimento*: senza un `InputEventMouseMotion` il click
non arrivava a nessuno. `gui_get_hovered_control()` tornava `null`.

**Quella del gioco, che senza la prima non avrei mai visto.** Rimesso a posto
il cursore, i click continuavano a sparire — e la diagnostica diceva perché:

```
premo '▶ ATTACCHI'  fase=attesa  pronto=false  passo_lezione=true  chiede='attacca'
perso: modo=comandi battute=0 coda=''
```

Veronica chiede ATTACCA. Il giocatore preme ATTACCA. La ricarica non è
finita. E **non succede niente**: `Intenzione.ricorda` rifiutava *qualunque*
comando durante un passo del tutorial.

Era lo stesso difetto che Bru aveva segnalato — «il primo click non fa niente»
— **sopravvissuto dentro la lezione**, cioè esattamente dove fa più danno: è lì
che il giocatore sta imparando se i suoi comandi contano.

### La regola era giusta, ma troppo larga

Avevo spento il buffer durante la lezione per una ragione buona: un comando
messo in coda mentre Veronica parla partirebbe da solo appena lei finisce, e
vedresti succedere una cosa che non hai appena chiesto.

Ma quella preoccupazione riguarda la fase **`racconto`**, e da quella ci
difende già `momento_buono()`. La regola giusta è più stretta: durante la
lezione si tiene da parte **solo l'azione che il passo chiede**. La lezione
resta una cosa per volta, e il click sull'azione richiesta smette di morire.

### Cosa è cambiato, misurato

| | prima | dopo |
|---|---:|---:|
| click andati a segno | **0 su 8 (0%)** | **8 su 8 (100%)** |
| menu a schermo | 13,9% | **28,2%** |
| testo in coda | 78,3% | **63,5%** |
| fase `racconto` | 78,3% | **63,5%** |
| schede ridisegnate | 1 | 5 |

La lezione scorre più in fretta perché i comandi adesso arrivano. Una regola
di tre righe.

### La cosa da ricordare

**Uno strumento che stampa un numero di cui non ti fidi non è inutile: è
pericoloso.** L'avevo marcato «non tarato» e ci ho convissuto, e dentro quel
numero c'era un difetto del gioco che nessuna delle 34.000 verifiche vedeva —
perché nessuna prova preme un bottone vero con un mouse vero.

**Nota sul costo per fotogramma, che NON ho usato.** Lo strumento dice 27 ms di
media e 85 ms nel peggiore. Non ne concludo niente sulle prestazioni vere: qui
gira su `llvmpipe`, cioè rasterizzazione software sotto `xvfb`. È il caso di
cui avverte la documentazione di Godot — profila una build esportata. Quel
numero serve solo a confrontare un prima e un dopo sulla stessa macchina.
