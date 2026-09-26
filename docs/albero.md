# L'albero di crescita: cosa fanno i giochi riusciti, e cosa fa il nostro

Bru, il 26 settembre: «documentiamoci anche sullo skill tree di evoluzione dei
personaggi».

L'ho preso nei due sensi. Il primo: cosa fanno i giochi che ci sono riusciti,
Nintendo prima di tutto, e cosa ha scritto chi li ha disegnati. Il secondo:
com'è fatta **davvero** la nostra costellazione, non come la descrivono i
documenti. Il secondo ha dato le notizie più grosse, quindi comincio da lì.

---

## 0. In breve

1. **Oggi, in partita, il personaggio non cresce affatto.** Nessuno schermo
   spende l'hype. Il livello resta 1 per tutta la demo, e le azioni fatte (i
   colpi, le difese, gli studi) non diventano mai statistiche: si convertono
   solo quando compri un nodo. Lo dimostra il codice (§3.1). Da oggi lo stampa
   anche l'automa a fine partita.
2. **Anche con uno schermo, l'albero non si comincerebbe.** I nodi si aprono
   col livello, il primo dal 21 o dal 25. Il livello però sale solo comprando
   nodi. Da una partita nuova, con dieci milioni di hype in tasca, si arriva al
   livello 3 e ci si ferma (§3.2).
3. **L'hype, appena si potrà spendere, correrà troppo.** Uno scontro comune al
   livello 8 compra tre nodi del tronco. Comprando appena si può, il livello 18
   (la fine della demo) arriva in **14 scontri**, e la costellazione intera in
   **23** (§3.4).
4. **Alcuni numeri del progetto non tornano fra loro** (§3.3). Un personaggio
   completo costa 130.000 hype, non 13.000. «Dentro i 60 nodi» ne stanno 80. E
   il livello 130 dei bivi non si raggiunge: col livello uguale ai nodi, il
   massimo è 61. C'è un modo di rimettere quasi tutto d'accordo con una sola
   decisione (§4.1), ed è tua.
5. **Una cosa l'ho corretta.** Il protagonista imparava da solo sei mosse di
   Veronica e di Yhvina (la Provocazione all'8, la Veglia al 16…). Adesso ogni
   linea ha un padrone scritto nei dati (§3.7).

Le fonti dicono cose chiare su tre punti che ci riguardano:
- le scelte piccole a ogni salita (Paper Mario, BotW);
- il limite che fa il gioco (Pokémon, Kid Icarus, Paper Mario);
- cosa succede quando il mondo cresce col tuo livello e le statistiche crescono
  con quello che fai (Final Fantasy II, Oblivion).

---

## 1. Prima una cosa sulle fonti

La rete è chiusa come per il tutorial: il proxy risponde 403 a tutto, e funziona
solo la ricerca, che restituisce sintesi. Quindi ogni fonte porta il suo
livello, come in `tutorial.md` §6.1:

| livello | cosa vuol dire |
|---|---|
| **L** — letta | letta per intero: sta in `docs/fonti/` |
| **R** — riscontrata | lo stesso fatto, o la stessa citazione, da **testate diverse e indipendenti**; l'originale non l'ho aperto |
| **S** — sintesi | una sintesi sola, o testate minori. Un indizio, non una fonte |

Qui non c'è **nessuna L**. Nessuna proposta del §4 si regge su una S da sola.
Gli originali da scaricare sono in fondo (§6).

---

## 2. Cosa fanno i giochi riusciti

### 2.1 Nintendo

**Paper Mario: Il Portale Millenario — a ogni livello una scelta, piccola e
netta.** *(R: Super Mario Wiki, Game8, Game Rant, Destructoid.)*

- A ogni salita scegli una di tre cose: HP (+5), FP (+5) o BP (+3).
- **Il livello non alza mai l'attacco.** L'attacco lo danno le medaglie, e le
  medaglie costano BP.
- Tre righe di regola bastano a far sì che ogni salita sia una domanda:
  resistere di più, fare più mosse speciali, o portare più medaglie?

**Paper Mario — le medaglie hanno un budget, e si tolgono.** *(R: Paper Mario
Wiki, Mario Wiki, StrategyWiki.)*

- *Power Plus* dà +1 all'attacco e costa 6 BP; le medaglie vanno da 0 a 7 BP.
- Togliere una medaglia **restituisce i BP**. Quindi si prova, si cambia, si
  riprova, senza perdere niente.
- Il vincolo non è «cosa hai comprato» ma «cosa ti porti addosso oggi».

**Super Mario RPG — lo stesso gesto, nel 1996.** *(R: Game8, Nintendo Life,
Game Rant, Dot Esports.)* A ogni livello un bonus a scelta fra tre:
- vita;
- attacco e difesa fisici;
- attacco e difesa magici.

**Mario & Luigi: Superstar Saga — la scelta con un rendimento che cala.** *(S:
Mario Wiki.)*
- A ogni livello scegli la statistica e fermi una roulette a tempo.
- Se insisti troppo sulla stessa statistica, escono numeri più bassi.

**Zelda: Breath of the Wild — quattro sfere, cuore o vigore.** *(R: GameWith,
Game Rant, Zelda Dungeon.)*
- Con quattro Sfere Spirituali, davanti a una statua, scegli un contenitore di
  cuore o uno di vigore.
- Le sfere non bastano a riempire tutti e due.

**BotW — e un modo di tornare indietro, piccolo.** *(R: Zelda Dungeon Wiki,
Zelda Wiki, Gamer Guides.)*
- La Statua Cornuta di Hateno ti ricompra un cuore o un vigore per 100 rupie, e
  te li rivende per 120.
- Cambiare idea costa 20 rupie, e sta in un angolo del villaggio che si trova
  solo se ti ci porta un bambino.
- È la risposta di Nintendo al pentimento: **si può, costa poco, ma bisogna
  volerlo.**

**Kid Icarus: Uprising — i poteri a incastro.** *(S: Iwata Asks, capitolo
«Powers and Weapons», nella sintesi della ricerca.)*
- I poteri sono pezzi di forme diverse da incastrare in una griglia.
- Quelli più forti occupano più spazio.
- Dalla sintesi, Sakurai: *non puoi avere tutti i poteri che vuoi, devi farli
  stare nel pannello*, e li scegli pensando all'arma che porti.

**Pokémon — quattro mosse, e il perché.** *(S: Kazumasa Iwao, Game Freak, nella
sintesi della ricerca.)*
- Con più di quattro mosse diventerebbe troppo difficile leggere cosa può fare
  l'avversario.
- Con tre o meno, le specie si distanzierebbero troppo.
- Quattro è il numero che ci rivedono di continuo e tengono.

**Xenoblade Chronicles 3 — le classi degli Eroi.** *(S: «Ask the Developer»
vol. 6, cap. 3, sul sito Nintendo, nella sintesi.)*
- Quando un Eroe si unisce, i sei possono prenderne la classe.
- Ogni classe ha cinque Arti.
- Una frase riguarda anche noi: i consigli spiegano le Arti nuove, ma *«i
  giocatori devono capirle non solo leggendo le istruzioni, ma anche
  provandole».*

**Xenoblade Chronicles (Wii)**: rami di abilità, uno solo attivo alla volta.
*(S: Xenoblade Wiki.)*

**Fire Emblem: Path of Radiance — l'esperienza bonus da distribuire.** *(R: Fire
Emblem Wiki, Fire Emblem WoD.)*
- A fine capitolo arriva esperienza bonus, secondo come l'hai giocato.
- Alla base la dai **a chi vuoi**, anche a chi non ha combattuto.
- È il precedente più vicino al nostro hype unico: il problema che risolve è lo
  stesso (chi resta indietro), ed è di casa Nintendo.

**Miyamoto, 1992 — la ragione di fondo.** *(R: la traduzione di shmuplations,
ripresa da Nintendo Life e ResetEra.)*

> *«Non mi interessano i sistemi in cui tutto è deciso da statistiche e
> numeri.»* E poi: quando la spada diventa due o quattro volte più potente,
> *«quando la muovi dovrebbe davvero sembrare e suonare più affilata, più
> letale».*

La crescita, per lui, **si sente**, non si legge.

### 2.2 Gli altri, e chi ha scritto di mestiere

**Sid Meier, GDC 2012** — già in `lezioni.md` §6. *(R.)* Se il giocatore sceglie
sempre la prima di tre opzioni, non è una scelta interessante.

**Salen e Zimmerman, *Rules of Play*.** *(R: Wikipedia, MIT Press, dispense
universitarie.)* Il gioco ha significato quando il rapporto fra un'azione e il
suo esito è:
- **discernibile** — lo vedi;
- **integrato** — pesa su tutto il resto.

Un nodo che dà +1% a qualcosa è integrato, ma non discernibile.

**World of Warcraft — Greg Street, dicembre 2011.** *(R: Engadget, PC Gamer.)*

> *«Abbiamo provato il modello dell'albero dei talenti per sette anni.
> Pensiamo che sia difettoso alla radice, e non riparabile.»*

- Gli alberi finivano in una build «giusta» per classe, copiata da tutti.
- In *Mists of Pandaria* li hanno sostituiti con **meno scelte, che contano**:
  una fra tre, a intervalli.

**Diablo III — Jay Wilson e il Duriel di ghiaccio.** *(R: Diablo Wiki, IGN via
Blizzplanet, PureDiablo.)*
- In Diablo II aveva messo tutti i punti nella maga del gelo, senza sapere cosa
  lo aspettava.
- Poi aveva trovato Duriel, resistente al gelo, e un muro.
- In Diablo III: niente punti. Un'abilità nuova quasi a ogni livello, tutte
  provabili; il vincolo è quante ne tieni sui tasti.

**Diablo II, patch 1.13 (2010).** *(R: Diablo Wiki, Blizzplanet.)* Dieci anni
dopo l'uscita arriva il ripensamento:
- uno gratuito come premio di una missione;
- poi un oggetto raro per rifarlo quante volte vuoi.

**Josh Sawyer, *Pillars of Eternity* — niente build trappola.** *(R: PCGamesN,
Thumbsticks, GDC Vault «Gods and Dumps».)*
- Una trappola non è un personaggio del 15% più debole. È uno *«totalmente
  fregato»*.
- Evitarla richiede di conoscere il sistema o di sapere già cosa arriverà.
- Il sistema deve premiare chiunque, comunque scelga.

**Soren Johnson, *Water Finds a Crack*.** *(R: Designer Notes, e le molte
riprese.)*

> *«Se gliene dai l'occasione, i giocatori ottimizzeranno il gioco fino a
> togliergli il divertimento.»*

E subito dopo: una delle responsabilità del progettista è proteggere il
giocatore da se stesso.

**Final Fantasy II — la crescita per uso, e il suo prezzo.** *(R: Final Fantasy
Wiki, RPG Site, Wikipedia.)*
- Le statistiche crescono con quello che fai: la vita, subendo danni.
- Il modo migliore di diventare forti è **picchiare i propri compagni**.
- Il comando per colpire un alleato serviva a svegliare chi dormiva.
- Chi ha disegnato il sistema non l'aveva previsto.

**Oblivion — il mondo che cresce con te.** *(S: Game Rant e le discussioni dei
giocatori.)*
- I nemici scalano col livello, e il livello sale allenando le abilità.
- Chi gioca normalmente sale «male» e si trova il mondo più forte di lui. A
  volte, **salire di livello peggiora la partita**.

**Final Fantasy X — la Sferografia.** *(R: Final Fantasy Wiki, Jegged, EIP.)*
- Nella versione standard ognuno parte nella sua zona, su un sentiero quasi
  lineare per gran parte del gioco.
- Nella versione esperta tutti partono dal centro, liberi, ed è sconsigliata a
  chi è nuovo.

**Final Fantasy XII — la scacchiera unica e il suo rimedio.** *(R sui fatti:
Jegged, Final Fantasy Wiki. S sulla frase di Ito.)*
- Una scacchiera sola per tutti rendeva tutti uguali.
- La versione *Zodiac* ha dato a ognuno dei lavori, e la scelta non si disfa.
- Dalla sintesi, Hiroyuki Ito voleva la tensione dei giochi di una volta, in
  cui non si poteva tornare indietro.

**Path of Exile — l'albero che spaventa.** *(S: intervista a Chris Wilson su
Fandom.)*
- Dentro lo studio si discuteva di una vista semplificata per i nuovi.
- L'altra parte ha tenuto l'albero intero, perché è l'identità del gioco.
- Nel seguito hanno tracciato percorsi più chiari verso gli archetipi.

**Skyrim — le costellazioni, e le abilità leggendarie.** *(R: UESP, Elder
Scrolls Wiki.)*
- Gli alberi dei talenti sono **disegnati come costellazioni nel cielo**.
- Fino alla patch 1.9 i talenti erano al massimo 81.
- Poi un'abilità al massimo può diventare «leggendaria»: torna a 15 e
  restituisce i suoi talenti da rispendere.

È il gemello del nostro «a livello 130 torni sui bivi».

**Hades — lo Specchio della Notte.** *(R sul meccanismo: Hades Wiki, GameSkinny.
S sulla frase di Supergiant.)*
- Ogni riga ha due versioni, rossa e verde, e si passa dall'una all'altra
  liberamente.
- Il rimborso totale costa una chiave.
- Lo scopo è renderti più forte da un tentativo all'altro, insieme a quello che
  tu impari.

**Dark Souls — le anime sono moneta ed esperienza.** *(R: Dark Souls Wiki,
Fextralife.)*
- Il livello è quante volte hai comprato un punto.
- Ogni anima spesa per salire è un'anima non spesa dal mercante.
- È il gemello del nostro «il livello è quanti nodi hai comprato».

**Dragon Quest XI — il ripensamento a pagamento.** *(R: Game Rant, Gamers
Heroes, GameFAQs.)* Presto nella storia, in chiesa o alle statue, restituisci i
punti di un albero intero a 20 monete l'uno.

---

## 3. Com'è fatto davvero il nostro

Le cifre di questa sezione vengono da sonde lanciate sul motore vero (Godot 4.7),
non da conti a mano. Le sonde non restano nel progetto; le prove sì (§3.7).

### 3.1 In partita il personaggio non cresce

- Comprare un nodo è `GameState.sblocca_nodo`. Nessuna scena lo chiama: lo
  chiamano solo le prove.
- Le statistiche guadagnate giocando si convertono in `applica_crescita_livello`.
  Ci si arriva solo comprando un nodo, oppure dal simulatore, che la chiama da
  sé.
- Le passive di livello si controllano allo stesso momento.

Quindi, in una partita vera, dall'inizio alla fine della demo:

| | cosa succede |
|---|---|
| livello | **1**, sempre |
| hype | si accumula e non si spende |
| attacchi, difese, studi… | si contano, e **non diventano mai statistiche** |
| passive di livello | nessuna |
| schermata di salita | mai |
| diario della pausa, «Cosa ti sta cambiando» | dice «3 / 5 verso +1 Attacco», ma il +1 non arriva: al quinto colpo il numero torna a 0 / 5, come se l'avesse dato |

`critica.md` diceva *«Comprare c'è. Vedere cosa hai comprato, no.»* Era
ottimista: comprare c'è nel motore, **non in partita**. L'ho corretto lì.

Da oggi l'automa lo stampa a fine giro: livello, hype guadagnato, hype da
spendere, azioni mai convertite.

### 3.2 L'albero non si aprirebbe nemmeno con uno schermo

Nei dati, ogni nodo si apre a un livello (il campo `livello`). Il livello, però,
è quanti nodi hai comprato. Le due regole insieme si chiudono a vicenda.

La sonda:
- partita nuova, protagonista, **dieci milioni di hype**;
- compra tutto quello che si può, finché si può.

Risultato: **livello 3, speso zero**.
- Ha «comprato» Mattanza e Spezza spazio, che costano zero e si aprono al
  livello 1.
- Poi 52 nodi restano chiusi: il primo che costa si apre al 25 (Pietà, Terra
  bruciata, Colpo più pesante).
- Veronica e Yhvina si fermano allo stesso punto: i loro gradi II si aprono al 21.

Le prove non se ne accorgevano perché portano il personaggio al livello voluto
con `porta_al_livello`. È una scorciatoia che in partita non esiste.

**Da dove viene.** Nei dati convivono tre generazioni di regole:

| generazione | come si sale | cosa ne resta nei dati |
|---|---|---|
| 1 | esperienza, curva fino a 130 | `fabbisogno_xp`, `livello_massimo: 130`, passive fino al 130 |
| 2 | un punto ogni 4 livelli dal 25 | i campi `livello` dei nodi, la nota `_nota_punti` |
| 3 | il livello è quanti nodi compri | `livello_di`, l'hype |

La terza è quella decisa, ma i nodi si aprono ancora con le regole della
seconda. La costellazione disegnata doveva sostituirle, perché sul disegno un
nodo si apre quando è **collegato** a uno che hai. Il disegno però non c'è.

### 3.3 I numeri che non tornano

| cosa | dice | ma |
|---|---|---|
| Un personaggio completo | **13.000 hype** (`manuale.md` §5) | Tronco 20×1 + Braccia 18×2 + Punte 14×3 + Stelle 8×4 = **130 punti = 130.000 hype**. Il conto era mio, e sbagliato di dieci volte. L'ho corretto |
| Cosa c'è dentro i 60 nodi | 38 statistiche · 18 mosse · 24 passive | 38 + 18 + 24 = **80**. O sono gli 80 disegnati, o uno dei tre numeri è diverso |
| Il ritorno sui bivi | «a livello 130» | Col livello uguale ai nodi, il massimo è **61** (60 comprabili + 1) |
| Le passive di livello | 16, dal 10 al 130 | **10 su 16** stanno sopra il 61. Anche il *Preferito del gatto*, garantito al 120 |
| I gradi VI | Annichilazione totale al 61, Pace assoluta al 65 | Il 61 si raggiunge solo comprando tutto il resto; il 65 **mai** |
| Ogni frattura ricomincia da 1 | `punto.md` | Allora i 130.000 hype vanno guadagnati **dentro una frattura** |

Un'osservazione, non una prova: **24 passive** è esattamente quante ce ne sono
già in `crescita.json` (16 di livello, 7 di soglia, 1 rara). Forse le 24 della
costellazione sono queste.

### 3.4 L'hype, appena si potrà spendere, correrà

L'esperienza di una creatura segue la vecchia curva, fatta per un fabbisogno
che cresceva come livello^1,5. Il costo di un nodo invece è fisso: 1000, 2000,
3000 o 4000. Una creatura comune del tuo livello vale:

| livello | hype a scontro | nodi del tronco a scontro |
|--:|--:|--:|
| 1 | 200 | 0,2 |
| 3 | 912 | 0,9 |
| 8 | 3.046 | **3** |
| 18 | 6.977 | **7** |
| 40 | 13.565 | 13,6 |

Comprando appena si può, ai costi delle fasce:

| arrivare al livello | 2 | 10 | **18** | 39 | **61** |
|---|--:|--:|--:|--:|--:|
| scontri | 5 | 12 | **14** | 18 | **23** |

**Limiti della sonda.** È un personaggio solo, sempre contro creature del suo
livello, che compra subito. Con tre personaggi servono circa il triplo dei nodi.
Restano comunque poche decine di scontri per l'intera costellazione.

È lo stesso difetto che `ruoli.json` racconta dei tempi dell'esperienza: *«nessuno
l'aveva mai misurato»*.

### 3.5 Crescere per azioni + comprare il livello + un mondo che scala

Sono tre decisioni buone, ognuna da sola:
- le statistiche crescono con quello che fai;
- il livello lo compri tu;
- il mondo si regola sul livello della squadra.

Insieme fanno Final Fantasy II più Oblivion. **È una previsione dal codice, non
una misura.**

- **Tesoreggiare conviene.** Le azioni si accumulano senza limite, e al
  prossimo nodo si convertono tutte insieme.
  - Chi resta basso apposta combatte un mondo basso e mette da parte azioni.
  - Al primo acquisto si trova le statistiche di dieci livelli, contro un mondo
    salito di uno.
  - `critica.md` diceva che l'hype ha tolto il tesoreggiamento. Ha tolto quello
    dell'esperienza, ma ne ha aperto un altro, quello delle azioni.
- **Chi gioca «male» sale male.** Il mondo si regola su un giocatore tipo.
  - Il giocatore tipo dà 30 colpi a livello, cioè +6 di attacco a livello.
  - Chi colpisce meno, e compra lo stesso, si trova il mondo più forte di lui.
  - È la trappola di Oblivion, e `bilanciamento.md` ne ha già visto
    un'avvisaglia: il Volto sulla parete, curandosi, si vince il 57% delle
    volte al 18 e il 4% al 25.

### 3.6 Quanto vale un nodo statistica

In un livello, il giocatore tipo si guadagna circa:

| statistica | a livello |
|---|--:|
| attacco | +6 |
| vita | +47 |
| difesa | +1,3 |
| forza mentale | +1,5 |

I nodi statistica oggi danno:

| nodo | dà |
|---|--:|
| Colpo più pesante I, II, III | +6, +10, +16 di attacco |
| Fondo del serbatoio I, II | +60, +110 di vita |

Cioè più o meno **quanto il livello di mondo che fanno salire**. Un nodo
statistica tiene il passo; la crescita vera viene dalle azioni. Con 38 nodi
statistica su 60 è una cosa da sapere prima di disegnarli.

### 3.7 Cosa ho corretto

**Una linea adesso ha un padrone.** In `classes.json` ogni personaggio dice le
sue linee (`"linee"`):
- il protagonista: Flagello, Annichilazione, Mantra;
- Veronica: Richiamo, Carica, Baluardo;
- Yhvina: Lama, Richiamo, Veglia.

Prima non lo diceva nessuno, e succedevano due cose.

- **Il protagonista imparava da solo i gradi I degli altri**: sei mosse.
  - La Provocazione di Veronica e il Taglio corto di Yhvina all'8.
  - La Carica e il Piccolo richiamo al 12.
  - Piantati e la Veglia al 16.
  - Al livello 18 sapeva 17 cose; adesso 11.
  - Il simulatore misurava lui.
- **Chiunque poteva comprare i gradi di chiunque.** Il commento nel codice
  diceva che Veronica non doveva imparare il Flagello; il controllo però c'era
  solo per lei, e solo per le mosse che arrivano col livello.

Le prove nuove, in `prova_linee_abilita`:
- ogni linea ha **un padrone solo**, ed esiste davvero;
- ogni personaggio, al livello massimo e con tutto in mano, vede nel menu **un
  grado per linea sua e zero delle altrui**;
- il protagonista non sa e non può comprare niente di una linea non sua.

Le ho validate rompendo il codice apposta, sei volte: **6 su 6 prese.**

### 3.8 Cosa resta aperto nel motore, e perché non l'ho toccato

- **I nodi senza linea non hanno padrone.** Pietà, Astio e Vendetta sono
  meccaniche del protagonista, ma Veronica al livello 30 le troverebbe in
  vendita. Chi le possiede è una domanda di progetto: tre righe di dati quando
  me lo dici.
- **I nodi gratuiti si «comprano» e contano come livello.** Mattanza e Spezza
  spazio fanno salire di due livelli senza spendere. Non l'ho tolto: la Veglia
  di Yhvina (grado I, gratuito) oggi si ottiene solo così. Nella sua classe c'è
  `veglia`, che non è un'abilità di combattimento (in `abilita.json` non c'è), e
  non `veglia_i`, il grado I della linea. Va sistemato insieme, col disegno.
- **L'apertura dei nodi.** Col disegno diventa «collegato a un nodo che hai».
  Cambiarla prima vorrebbe dire inventarmi io la forma della costellazione.

---

## 4. Cosa ne viene per Carnivalz

Tutto quello che segue è **mio**, e nessuna di queste è ancora nel gioco. Le
decisioni sono tue; accanto a ognuna le fonti che la reggono.

### 4.1 Una decisione che ne sistema quattro: il livello è quanti *punti* hai speso

**Oggi:** livello = nodi comprati + 1, massimo 61.

**Se invece fosse punti spesi + 1**, con i costi delle fasce:
- il tronco dà un livello a nodo, le stelle esterne quattro;
- la costellazione completa fa **130 punti**, esattamente il `livello_massimo`
  che sta già nei dati;
- «a livello 130 torni sui bivi» diventa vero: quando hai finito il tuo ramo,
  prendi gli altri;
- le passive dal 65 al 130 e i gradi VI tornano raggiungibili.

Il 130 che sembrava un errore, così, sarebbe la cosa giusta con la regola
sbagliata. *(Dark Souls: il livello è la somma di quello che hai comprato — R.)*

### 4.2 Il prezzo di un nodo segue la curva, e tu scegli il ritmo

Una formula sola rimette a posto il §3.4: il costo in hype di un punto sale col
livello, sulla stessa curva dell'esperienza delle creature. Così «quanti scontri
per salire» torna a essere il numero che `ruoli.json` già controlla (5, più 0,35
a livello).

Se il prezzo seguisse la curva che c'è già, arrivare al 18 costerebbe circa **130
scontri** invece di 14. **Quanti ne vuoi?** È la domanda di ritmo della demo, e la risposta è una
cifra in `regole.json`.

### 4.3 Un tronco provvisorio, per la demo, finché non arriva il disegno

La demo finisce al 18: sono **17 nodi del tronco**, cioè la parte più lineare
della costellazione.
- FFX dà ai nuovi proprio questo: un sentiero quasi dritto all'inizio *(R)*.
- Path of Exile ha imparato a tracciare percorsi chiari *(S)*.

Propongo di mettere i primi 20 nodi in fila, comprabili in ordine, in una
schermata semplice dentro la Scheda della squadra. Quando arriva il disegno, la
fila diventa il suo tronco.

Così la demo **cresce**. Oggi no, ed è la cosa che un giocatore noterebbe per
prima.

### 4.4 Le «stelle doppie»: la scelta dentro il nodo

- 38 nodi statistica su 60 sono il rischio di Greg Street *(R)*: tanti +qualcosa
  che nessuno sceglie davvero.
- Paper Mario, Super Mario RPG e BotW fanno l'opposto *(R)*: a ogni salita una
  scelta piccola e netta fra due o tre cose.

Propongo che un nodo statistica, al momento di comprarlo, **ti faccia scegliere
fra due statistiche**, per esempio vita o attacco. Il disegno resta fisso, un
punto è un punto, ma ogni punto è una domanda.

### 4.5 Le passive con un limite, e si cambiano

- Paper Mario: medaglie con budget, che si tolgono restituendo i BP *(R)*.
- Kid Icarus: la griglia *(S)*. Pokémon: le quattro mosse *(S)*. Diablo III:
  tutto provabile, poco sui tasti *(R)*.

La lezione, in tutte e quattro: **il limite è il gioco, e cambiare idea non
costa**. Propongo:
- le passive si **sbloccano** sulla costellazione;
- se ne **portano** tre o quattro alla volta, cambiandole dalla Scheda.

Risolve metà del problema del ripensamento (§4.7) senza nessun ripensamento, e
dà alle 24 passive, che secondo i documenti portano la novità, un posto dove
vedersi.

### 4.6 Le azioni si convertono con un tetto

Contro il tesoreggiamento del §3.5, il rimedio più piccolo è un tetto per
livello.
- A ogni salita si convertono al massimo, per esempio, due livelli tipo di
  azioni per statistica.
- Il resto non si perde: passa al livello dopo.
- La crescita resta quello che hai fatto. Solo, non arriva tutta in una volta a
  chi si è tenuto basso apposta.

*(Soren Johnson e Final Fantasy II — R.)*

Il rimedio più grande sarebbe regolare il mondo su `hype_accumulato` (quanto hai
giocato) invece che sui livelli. Però tocca una tua decisione, «il mondo sulla
media della squadra», e per questo la metto solo come alternativa.

### 4.7 Tornare indietro: sì o no, ma senza trappole

Oggi non si torna indietro, se non al 130. Le fonti si dividono.

**Contro il ripensamento**, per la tensione:
- FFXII *Zodiac* *(S sulla frase di Ito)*.

**A favore, a prezzo piccolo**:
- BotW *(R)*, Dragon Quest XI *(R)*, Hades *(R)*;
- Diablo II, che l'ha aggiunto dopo dieci anni *(R)*.

Sawyer mette la condizione *(R)*: **se non si torna indietro, non devono
esistere trappole**. Nessun nodo deve rendere un personaggio «totalmente
fregato», e nessun ramo deve chiudersi contro un boss, come il Duriel di Wilson
*(R)*.

Se tieni il no, ogni linea deve reggere da sola la partita, e va provato. Se
scegli il sì, propongo un ripensamento a pagamento in hype, alla Sede, per
un'intera linea alla volta, come Dragon Quest XI.

### 4.8 Si deve vedere, e sentire

Salen e Zimmerman *(R)* chiedono che l'effetto sia discernibile; Miyamoto *(R)*
che la spada più forte **suoni** più affilata.

Il Resoconto sa già dire il perché di una salita («per i colpi che hai tirato»):
- quel momento va dato **a ogni acquisto**;
- il numero nuovo va mostrato **sul colpo dopo**, non solo in una tabella.

### 4.9 L'hype unico ha un precedente buono

L'esperienza bonus di Fire Emblem *(R)* è la stessa idea: un mucchio che dai a
chi vuoi, per non lasciare indietro nessuno. La tua regola del mondo «sulla
media» è la contromisura giusta a chi lo versa tutto su uno solo. Qui non
cambierei niente.

---

## 5. Le domande per te

Una riga per risposta basta.

1. **Il livello è quanti nodi o quanti punti hai speso?** (§4.1) Con i punti
   tornano il 130, le passive alte e i gradi VI.
2. **Quanti scontri vuoi per arrivare al 18?** (§4.2) Coi prezzi di oggi 14;
   col prezzo che segue la curva circa 130.
3. **Il tronco provvisorio per la demo** (§4.3): sì o aspettiamo il disegno?
4. **Le stelle doppie** (§4.4) e **le passive con un limite** (§4.5): ti piacciono?
5. **Il tetto alle azioni** (§4.6): sì?
6. **Tornare indietro** (§4.7): no (e allora niente trappole, provato), o sì a
   pagamento?
7. **38 · 18 · 24**: quale dei tre numeri è diverso, visto che fanno 80?
8. **Pietà, Astio, Vendetta** sono solo del protagonista?

---

## 6. Fonti

Le ho viste tutte attraverso le sintesi della ricerca: **nessuna è letta per
intero**. Il livello è accanto a ognuna nel §2.

**Nintendo**
- [Level up — Super Mario Wiki](https://www.mariowiki.com/Level_up)
- [Paper Mario TTYD: What Stat Should You Level Up First — Game Rant](https://gamerant.com/paper-mario-the-thousand-year-door-what-stat-level-up-first-hp-fp-bp/)
- [What stats should you improve when leveling up in Paper Mario: TTYD — Destructoid](https://www.destructoid.com/what-stats-should-you-improve-when-leveling-up-in-paper-mario-ttyd/)
- [Badge Point — Paper Mario Wiki](https://papermario.fandom.com/wiki/Badge_Point)
- [Power Plus — Paper Mario Wiki](https://papermario.fandom.com/wiki/Power_Plus)
- [Paper Mario: The Thousand-Year Door/Badges — StrategyWiki](https://strategywiki.org/wiki/Paper_Mario:_The_Thousand-Year_Door/Badges)
- [Super Mario RPG: Levelling Guide — Nintendo Life](https://www.nintendolife.com/guides/super-mario-rpg-levelling-guide-level-up-bonuses-what-stats-should-i-improve)
- [Level Up Guide and Best Level Up Bonus — Game8](https://game8.co/games/Super-Mario-RPG/archives/432460)
- [Bonus Level Up Roulette — Mario Wiki](https://mario.fandom.com/wiki/Bonus_Level_Up_Roulette)
- [BotW: Heart Container or Stamina Vessel? — Game Rant](https://gamerant.com/breath-of-the-wild-heart-container-or-stamina-vessel/)
- [Horned Statue — Zelda Dungeon Wiki](https://www.zeldadungeon.net/wiki/Horned_Statue)
- [Iwata Asks: Kid Icarus: Uprising — 5. Powers and Weapons — Nintendo](https://www.nintendo.com/en-gb/Iwata-Asks/Iwata-Asks-Kid-Icarus-Uprising/Iwata-Asks-Kid-Icarus-Uprising/5-Powers-and-Weapons/5-Powers-and-Weapons-207807.html)
- [Ask the Developer Vol. 6, Xenoblade Chronicles 3 – Chapter 3 — Nintendo](https://www.nintendo.com/en-gb/News/2022/July/Ask-the-Developer-Vol-6-Xenoblade-Chronicles-3-Chapter-3-2245603.html)
- [Skill Tree — Xenoblade Wiki](https://xenoblade.fandom.com/wiki/Skill_Tree)
- [Bonus experience — Fire Emblem Wiki](https://fireemblemwiki.org/wiki/Bonus_experience)
- [Going Big — Game Informer (Game Freak)](https://gameinformer.com/feature/2019/11/13/going-big)
- [The Future of RPGs – 1992 Developer Interviews — shmuplations](https://shmuplations.com/futureofrpgs/)
- [Is Zelda An RPG, Or Not? — Nintendo Life](https://www.nintendolife.com/news/2021/03/talking_point_is_zelda_an_rpg_or_not)

**Gli altri, e il mestiere**
- [GDC 2012: Sid Meier on how to see games as sets of interesting decisions — Game Developer](https://www.gamedeveloper.com/design/gdc-2012-sid-meier-on-how-to-see-games-as-sets-of-interesting-decisions)
- [Meaningful play — Wikipedia](https://en.wikipedia.org/wiki/Meaningful_play)
- [Ghostcrawler on the philosophy behind the Mists of Pandaria talent trees — Engadget](https://www.engadget.com/2011-12-08-ghostcrawler-on-seeing-the-forest-for-the-talent-trees.html)
- [Mists of Pandaria will fix Talents "once and for all" — PC Gamer](https://www.pcgamer.com/mists-of-pandaria-will-fix-talents-once-and-for-all-say-blizzard/)
- [IGN: Blizzard On Ditching Skill Points in Diablo III — Blizzplanet](https://diablo.blizzplanet.com/blog/comments/ign-blizzard-on-ditching-skill-points-in-diablo-iii)
- [Skill trees — Diablo Wiki](https://www.diablowiki.net/Skill_trees)
- [Patch 1.13 (Diablo II) — Diablo Wiki](https://diablo-archive.fandom.com/wiki/Patch_1.13_(Diablo_II))
- [Obsidian's Josh Sawyer talks "choice and consequence" — PCGamesN](https://www.pcgamesn.com/pillars-of-eternity/obsidian-s-josh-sawyer-talks-choice-and-consequence-in-building-pillars-of-eternity-characters)
- [Gods and Dumps: Attribute Tuning in Pillars of Eternity — GDC Vault](https://gdcvault.com/play/1023481/Gods-and-Dumps-Attribute-Tuning)
- [GD Column 17: Water Finds a Crack — Designer Notes](https://www.designer-notes.com/game-developer-column-17-water-finds-a-crack/)
- [Final Fantasy II — Wikipedia](https://en.wikipedia.org/wiki/Final_Fantasy_II)
- [Final Fantasy II leveling system explained — RPG Site](https://www.rpgsite.net/feature/11516-final-fantasy-ii-how-to-level-up-and-an-explanation-on-the-leveling-system)
- [The Pros and Cons of Oblivion Remastered Keeping the Original's Level Scaling — Game Rant](https://gamerant.com/oblivion-remastered-level-scaling-progression-bad-good/)
- [Sphere Grid — Final Fantasy Wiki](https://finalfantasy.fandom.com/wiki/Sphere_Grid)
- [Jobs — Final Fantasy XII — Jegged](https://jegged.com/Games/Final-Fantasy-XII/Jobs/)
- [Interview: Chris Wilson on Path of Exile 2's Origins — Fandom](https://www.fandom.com/articles/2050-interview-chris-wilson-on-path-of-exile-2s-origins)
- [Skyrim:Skills — UESP](https://en.uesp.net/wiki/Skyrim:Skills)
- [Mirror of Night — Hades Wiki](https://hades.fandom.com/wiki/Mirror_of_Night)
- [Soul — Dark Souls Wiki](https://darksouls.fandom.com/wiki/Soul)
- [How To Refund Skill Points In Dragon Quest 11 — Game Rant](https://gamerant.com/dragon-quest-11-dq11-how-to-respec-echoes-of-an-elusive-age/)

### Da scaricare, per passare da R e S a L

In ordine di quanto cambierebbero le conclusioni:

1. **Iwata Asks: Kid Icarus Uprising, cap. 5** — è l'unica fonte Nintendo di
   prima mano sul limite come gioco, e l'ho solo in sintesi.
2. **Ask the Developer, Xenoblade Chronicles 3, cap. 3** — la frase sul capire
   provando.
3. **Game Informer, «Going Big» (2019)** — le quattro mosse di Pokémon.
4. **Engadget, Ghostcrawler, dicembre 2011** — il testo intero del «difettoso
   alla radice».
5. **Josh Sawyer, «Gods and Dumps»**, GDC 2016 — le build trappola.
6. **Soren Johnson, «Water Finds a Crack»** — breve.
7. **shmuplations, «The Future of RPGs», 1992** — Miyamoto per intero.

Come in `docs/fonti/README.md`: una pagina salvata (anche «Salva con nome», o il
testo incollato) in `docs/fonti/`, con il link in cima.
