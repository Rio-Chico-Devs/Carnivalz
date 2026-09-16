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

## La perdita di oggetti

Misurata a parte, e vale la pena ripeterla qui: **il gioco avviato da solo non
perde niente**. A perdere è la suite — coroutine ferme su un `await` dentro
combattimenti che una prova libera a metà volo, e in Godot 4 una coroutine
sospesa non si annulla. `prove/esegui.sh` fallisce se a perdere è il gioco.
