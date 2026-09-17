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
