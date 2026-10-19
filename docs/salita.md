# La salita di livello: la schermata vera

Bru: «cominciamo a fare la schermata di crescita vera proponimi dei design e ci
lavoriamo insieme, le animazioni che ho visto per la ruota per cosa erano
destinate? quando le avrei viste nel gioco?»

## 1. A cosa servivano i film della ruota

Erano prove di come si sarebbero mosse le schermate della crescita. Le ha girate
`prove/ProposteCrescita.gd` (`-- film ...`), servivano per scegliere l'aspetto, e
nel gioco non ci sono mai state.

- **`in_movimento.mp4`**: le tre schermate approvate, in movimento:
  - la **ruota**: la lancetta scorre sulle tasche e la ruota ci arriva con una
    molla; la lastra a sinistra cambia (ARRIVI AL, PIÙ AVANTI, GIÀ PRESO);
  - il **bivio**: si sceglie una strada, il taglio si sposta, si prende, l'altra
    strada viene spazzata via e compare il timbro LIVELLO 8;
  - le **passive**: si porta una passiva nel terzo alloggio.
- **`i_sette_giri.mp4`**: il giro chiuso che passa al prossimo, col sipario
  («TERZO GIRO · LIVELLI 41–60») e un aspetto nuovo, fino al 130.

Nel gioco si sarebbero viste **ogni volta che si spende un punto** (1000 hype),
cioè ogni volta che si sale di livello. Il passaggio fra un giro e l'altro si
sarebbe visto al 20, al 40 e così via; nella beta, che si ferma al 20, c'è al suo
posto il giro chiuso col tetto.

Non si vedono perché **manca proprio questa schermata**. Comprare un livello il
gioco lo sa già fare (`GameState.sblocca_nodo`, che converte anche le azioni in
statistiche), ma lo chiamano solo le prove. Il trucco dell'hype riempie il
mucchio, e poi non c'è un tasto per spenderlo.

## 2. Cosa deve dire la schermata, a ogni punto speso

1. **Si sale di un livello.** Un punto è una tasca, cioè un livello.
2. **Si sceglie una strada del bivio**, per esempio più vita o più attacco.
3. **Le azioni diventano statistiche, col loro perché.**
   - Viene da `GameState.applica_crescita_livello`: «+6 attacco per i colpi che
     hai tirato (30)».
   - È l'unico momento in cui si scopre a cosa è servito giocare come si è
     giocato.
   - Oggi lo dice solo una riga di testo nel resoconto (`Resoconto.gd`).
4. **A certi livelli arriva un'abilità o una passiva.**

## 3. Tre direzioni

Le tavole sono in `scatti/proposte_salita/`, si rifanno con
`./prove/proposte_salita.sh` e vengono da `prove/ProposteSalita.gd`. I numeri
sono veri:

- il protagonista d'esempio passa dal 7 all'8: il bivio è fra vita e attacco, e
  arriva Vendetta;
- le azioni sono quelle del giocatore tipo di `crescita.json`, convertite con gli
  stessi conti del gioco.

| | come | pro | contro |
|---|---|---|---|
| **A · Il banco** | Uno schermo solo: la ruota resta e cambia la lastra a sinistra (cosa dà, poi le due strade, poi cosa è cresciuto). | È la più veloce: cinque punti di fila senza cambiare schermo. | Il bivio approvato diventa due schede piccole. |
| **B · Tre tempi** | Ogni momento a tutto schermo: la ruota, il bivio approvato, il salto (il livello enorme e il perché), la carta di quello che arriva. | Usa i pezzi approvati così come sono, e il perché ha un momento suo. | Sono più schermate per punto. ESC salta tutto, sempre. |
| **C · La ruota gira** | Solo la ruota, al centro: il mozzo si spacca in due lungo il taglio del bivio, e la carta esce dalla tasca. | È la più da luna park: la ruota è il palco. | Il bivio sta in un cerchio, e il perché in una colonna stretta. |

Nelle barrette di crescita i colori sono sempre gli stessi:

- **grigio**: quello che avevi;
- **pieno**: quello che ti hanno dato le azioni;
- **arancio**: quello che ti ha dato la strada.

Il perché è scritto sotto, negli stessi colori.

**Il consiglio: la B.**

- Mette in fila proprio le tre schermate approvate e aggiunge il salto, cioè il
  momento che oggi manca (albero.md 4.8: «si deve vedere, e sentire»).
- Nella beta si sale diciannove volte in tutto, e ogni salita può prendersi il
  suo spazio.
- Chi ha fretta preme ESC.
- Dalla C si può prendere la carta che esce dalla tasca.

## 4. Da dove ci si entra

- **Dalla pausa**: una voce «Crescita» fra Zaino e Personaggio e squadra, col
  numero dei punti da spendere quando ce ne sono.
- **Dal resoconto di fine scontro**: dove oggi dice «Hai N punti da spendere», un
  tasto per andarci subito.
- **Le schede in alto** (Anonimo, Veronica, Yhvina): l'hype è di tutta la
  squadra, e si sceglie su chi spenderlo.

## 5. Le domande per Bru

Le animazioni sono approvate (§6). Sono fatte sulla B, ma la scelta fra A, B e
C non l'ha detta: resta la domanda 1, insieme alle altre.

1. A, B o C? Oppure un pezzo di una dentro l'altra.
2. Si entra dalla pausa e dal resoconto: va bene così?
3. Il punto più grosso, che è anche quello di albero.md §5 (domande 1 e 3).
   - La ruota è **tutta** la crescita: un punto, una tasca, un livello.
   - Allora l'albero a costellazione con i nodi ai livelli 25, 29… non serve più.
   - Senza questa risposta la schermata si può disegnare, ma non attaccare al
     gioco.
4. Veronica e Yhvina hanno la loro ruota, con le loro tasche, nella stessa
   schermata?

## 6. I film: la salita e oltre il 20

Bru: «bisogna animare la crescita di livello e quando la ruota supera il 20
esponendo la nuova ruota».

**Approvati.** Bru, visti i due film: «mi piacciono molto queste animazioni,
approvate!». La schermata vera si muove così.

Li gira `./prove/film_salita.sh` (serve ffmpeg) con `prove/FilmSalita.gd`, e
finiscono in `scatti/proposte_salita/`. Seguono la B, la strada consigliata,
perché Bru non ne ha scelta un'altra. Ogni pezzo vale anche per la A e per la C.

**`salita.mp4`** (18 secondi), dal 7 all'8:

1. **PRENDI.** Il punto lascia il contatore, che passa da 3 a 2, e vola nella
   tasca sotto la lancetta, che si accende d'arancio.
2. **La lastra.** Fra un momento e l'altro passa una lastra nera, da sinistra a
   destra, come nella pausa.
3. **Il bivio** approvato, coi suoi tempi.
4. **Il salto.**
   - Il 7 cade, l'8 arriva dall'alto, batte e trema.
   - La carta del perché entra girando.
   - Ogni riga compare, crescono le azioni (il pezzo pieno), poi la strada (il
     pezzo arancio), e il numero conta.
5. **La carta di Vendetta.** Sale dal basso girando, batte con un lampo e la
   attraversa un riflesso. I raggi dietro girano piano.
6. **Di nuovo la ruota.**
   - Il timbro cade sulla tasca dell'8, e la tasca resta scura anche sotto la
     lancetta.
   - Il mozzo rotola dal 7 all'8.
   - La lastra dice GIÀ PRESO, con la strada vera (più attacco).
   - La lancetta passa al 9.

**`oltre_il_20.mp4`** (8 secondi), dal 19 al 20 e oltre:

1. Il timbro cade sul 20 e il mozzo rotola dal 19 al 20.
2. Il giro chiuso si accende: una luce fa il giro delle tasche, come le
   lampadine della ruota vera, poi lampeggiano tutte. Nel mozzo compare
   COMPLETO.
3. **AL SECONDO GIRO**: un giro di vittoria, un giro intero della ruota.
4. La ruota si crepa dal mozzo lungo il taglio storto del bivio.
5. Le due metà volano via, una in alto a sinistra e una in basso a destra, e
   **sotto c'è la ruota nuova**, che entra girando e si ferma sul 21.
   - Per spaccarla, la ruota vecchia si disegna anche in un SubViewport; le
     metà sono due pezzi della sua immagine.
6. Il nome del giro (II, SECONDO GIRO, LIVELLI 21–40) arriva come un timbro, e
   se ne va.

Nella beta non si vede: il 20 è il tetto, e al suo posto c'è il giro chiuso col
lucchetto.

Il bivio è nel primo film e non nel secondo. È disegnato per il livello
d'esempio, e il secondo film comincia quando si torna sulla ruota.

## 7. Nel gioco: la Crescita

Bru: «ogni personaggio ha la sua ruota poi le customizzaremo quando avrò tutti i
disegni finiti, le animazioni vanno bene le ultime che mi hai fatto vedere».
Quindi è la B, coi movimenti dei film, e una ruota per personaggio.

**Dove.** Nella pausa c'è la voce **Crescita**, fra Zaino e Personaggio e
squadra. Quando ci sono punti da spendere, la voce lo dice («Crescita · 3
punti»).
- In combattimento la ruota si apre ma si guarda e basta: salire a metà scontro
  cambierebbe i colpi in volo.

**Come.**
- La schermata è `scripts/SchedaCrescita.gd`. Sotto ha quattro livelli in
  `scripts/crescita/`: lo stato, la ruota disegnata, i pezzi che si muovono, i
  momenti a tutto schermo.
- Le regole della ruota sono in `scripts/Crescita.gd`.
- I numeri sono in `data/ruote.json`.
- **Un punto, una tasca, un livello.** Un punto sono 1000 hype
  (`hype_per_punto`), e l'hype è della squadra: si sceglie su chi spenderlo.
- **Il bivio.** Ogni tasca ha due strade, dalle coppie del suo personaggio:
  - il protagonista ha quelle delle proposte approvate;
  - Veronica, che incassa, gira fra vita, difesa, attacco e velocità;
  - Yhvina, che è veloce, fra velocità, attacco, vita e difesa.

  Ai compagni la ruota offre solo vita, attacco, difesa e velocità, perché le
  altre statistiche in combattimento contano solo per il protagonista.
- **La strada si vede.** Quella presa vale nella scheda della squadra e in
  combattimento, per tutti.
- **Le azioni diventano statistiche.** Per il protagonista, prendere la tasca
  converte le azioni fatte giocando, come faceva comprare un nodo. Il salto lo
  racconta riga per riga.
- **Il tetto.** Nella beta è il 20. Oltre, la ruota si spacca e scopre il giro
  dopo; per aprirlo basta alzare `tetto` in `ruote.json`. L'ho provato col
  tetto alzato e funziona.
- **I tasti.**
  - Sulla ruota: su e giù la girano, INVIO prende, destra e sinistra cambiano
    personaggio, ESC torna alla pausa.
  - Nel bivio: destra, sinistra o clic per scegliere, INVIO prende, ESC ci
    ripensa (il punto torna nel contatore).
  - Nel salto e sulle carte: INVIO va avanti (la prima volta finisce
    l'animazione), ESC salta tutto.
  - Col mouse: le linguette dei personaggi, INDIETRO, PRENDI e la rotella.

**Cosa arriva.** Arriva comunque, qualunque strada prendi, e la ruota lo dice
prima: le abilità che il gioco dà da sole a quel livello e le passive di
`crescita.json`. Una prova controlla, livello per livello fino al 130, che la
ruota prometta esattamente quello che il gioco dà.

**Cosa è cambiato sotto.**
- Il livello conta anche le tasche: nodi + tasche + 1.
- I nodi dell'albero restano per i salvataggi e per `porta_al_livello`, ma
  nessuno li compra più.
- I pezzi disegnati della crescita (`PezziCrescita`, `SimboliCrescita`,
  `IconeStatistiche`) sono passati da `prove/` a `scripts/crescita/`, perché
  `prove/` non entra nel gioco esportato.

## 8. Ancora da decidere

1. **Quanto dà una strada.** Oggi: +15 vita, +2 attacco, +1 difesa, velocità,
   intelligenza e forza mentale, +2 fattore. Sono numeri miei, segnati come
   provvisori in `ruote.json`.
   - Il metro: un livello di azioni del giocatore tipo dà circa +6 attacco e
     +45 vita, e la strada ne vale un terzo.
   - Le creature si regolano sul protagonista tipo senza la ruota, quindi la
     strada è un vantaggio vero. Va tenuta piccola, o va messa nel conto delle
     creature.
2. **Le scelte dal 25 in su.** Erano scelte fra nodi, «al 25 Pietà o Terra
   bruciata». Nella ruota possono diventare bivi fra due abilità invece che fra
   due statistiche. Nella beta non servono: il tetto è il 20.
3. **I compagni.** Le prime abilità delle loro linee le hanno già dall'inizio
   (sono nella loro classe), quindi nella beta la loro ruota ha solo bivi.
   Restano così, o le facciamo arrivare al loro livello come al protagonista?
4. **Le passive in tre alloggi** (approvate) non ci sono ancora: oggi una
   passiva sbloccata vale da sola.
5. **Le ruote personalizzate**: quando arrivano i tuoi disegni.
