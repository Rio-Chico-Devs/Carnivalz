# Il dedalo — come si progetta una mappa, e com'è fatta la nostra

> **Cos'è questo documento.** Uno studio serio su come si progettano gli spazi di un gioco, preso da
> chi l'ha fatto bene e da chi l'ha criticato — e poi la nostra mappa messa sotto lo stesso righello,
> misurata e non raccontata.
>
> **Come l'ho fatto, e cosa questo comporta.** Il recupero diretto delle pagine è bloccato dal proxy
> di rete di questa macchina: ho potuto usare solo la ricerca, quindi quello che segue sono
> **sintesi dei risultati di ricerca, non pagine che ho aperto e letto riga per riga**. Ho tenuto
> solo ciò che tornava da più fonti indipendenti, e ogni sezione porta i link: se una cosa ti serve
> davvero, vale la pena aprirla tu.
>
> La parte finale — **Stack 6** — non ha questo problema: quella è misurata sui nostri file, e si
> rigenera con `./strumenti/topologia.py`.

---

## Perché proprio la mappa

Perché è la cosa che decide tutto il resto e non se ne accorge nessuno. Il combattimento lo giudichi
in dieci minuti; la mappa la giudichi dopo un'ora, quando ti accorgi che stai camminando in una fila
indiana travestita da labirinto — e a quel punto hai già smesso.

E perché da noi la mappa **non è fatta di terreno**: è fatta di stanze e di scelte scritte. Questo
cambia quali maestri servono. Miyamoto e Romero servono per il ragionamento; ma per la forma vera
delle nostre zone contano di più la scuola del dungeon da tavolo e quella dei libri-gioco, che
lavorano esattamente sul nostro materiale — nodi e archi.

---

## Stack 1 — La grammatica minima: una stanza, un percorso

### Il metodo in quattro passi

È la cosa più nota e più fraintesa di Nintendo. Non è «fai un livello facile poi uno difficile»: è
una struttura narrativa giapponese, **kishōtenketsu**, applicata allo spazio. Il direttore di *Super
Mario 3D Land* Koichi Hayashida la spiega così: prima **impari** a usare una cosa, poi la stessa cosa
ti viene riproposta in una situazione **un po' più complicata**, poi succede qualcosa di
**inaspettato** che ti costringe a ripensarla, e alla fine hai modo di **dimostrare** che l'hai
capita.

Le quattro parti in italiano: *introduci · sviluppa · ribalta · concludi*.

La parte che tutti saltano è la terza. Senza il ribaltamento hai una curva di difficoltà, non un
insegnamento: il giocatore fa la stessa cosa tre volte con numeri più grandi. Il ribaltamento è il
momento in cui il gioco ti dice «e adesso?» — ed è l'unico dei quattro passi che produce un ricordo.

- [Nintendo Life — Nintendo's Four Step Stage Design](https://www.nintendolife.com/news/2015/03/video_nintendos_four_step_stage_design_is_why_you_love_super_mario_games_so_much)
- [MCV/Develop — Nintendo's level design secrets in four steps](https://mcvuk.com/business-news/publishing/video-nintendos-level-design-secrets-in-four-steps/)
- [Game Developer — The secret to Mario level design](https://www.gamedeveloper.com/design/the-secret-to-i-mario-i-level-design)

### Le otto regole di Romero

Scritte durante *DOOM*, e hanno trent'anni che reggono. Le prime quattro sono di texture e
illuminazione e a noi non servono. Le altre quattro sì, e sono le più importanti:

| | Regola | Cosa vuol dire da noi |
| --: | --- | --- |
| 5 | Se il giocatore vede fuori, deve poterci arrivare | Se lo descrivi, deve esistere. Un giardino nominato e non visitabile è una bugia |
| 6 | Ogni livello ha più di un'area segreta | Il premio per chi guarda, non per chi passa |
| 7 | Il percorso fa **ripassare** dagli stessi posti, per capire meglio lo spazio | Un anello, non una fila |
| 8 | Diversi punti di riferimento **riconoscibili**, per orientarsi | Stanze che si distinguono l'una dall'altra |

Romero ha anche detto la cosa che sta sotto tutte: la regola vera è **fare in modo che il giocatore
guardi ogni parete di una stanza**, e con un percorso lineare non sarebbe stato possibile.

- [I Cast Light — John Romero's Level Design Rules for DOOM](https://icastlight.blogspot.com/2024/01/lessons-from-hell-john-romeros-level.html)
- [Doom Wiki — Tips for creating good WADs](https://doomwiki.org/wiki/Tips_for_creating_good_WADs)
- [GamesRadar — How Romero's FPS design rules live on](https://www.gamesradar.com/were-still-doomed-how-john-romeros-fps-design-rules-live-on-in-call-of-duty-modern-warfare-3/)

### Il giardino in miniatura

L'altra parola di Miyamoto è **hakoniwa**, «giardino in scatola». L'idea è che uno spazio piccolo e
curato produca più esplorazione di uno spazio grande e vuoto: la libertà si ottiene per
**riduzione e suggerimento**, non per estensione. È il concetto che gli ha fatto nascere il primo
Zelda, ed è descritto come il tentativo di rimettere in una scatola i boschi della sua infanzia.

Detto in negativo, e serve a noi: **una zona non diventa interessante aggiungendo stanze.**

- [Medium — Kishōtenketsu & Hakoniwa: How Nintendo Inspires My Designs](https://openedsource.medium.com/kish%C5%8Dtenketsu-hakoniwa-dd5a568da169)
- [Design Philosophy: Miyamoto, The Player Is the Protagonist](https://blakecrosley.com/blog/design-philosophy-shigeru-miyamoto)

---

## Stack 2 — La mappa come un oggetto solo

### Jaquaysing: il vocabolario di chi fa dungeon

Il testo di riferimento è una serie di articoli di Justin Alexander del 2010, nata studiando le mappe
di **Jennell Jaquays** per le prime avventure di D&D. Jaquays faceva una cosa che quasi nessuno
faceva: nelle *Caverns of Thracia* il primo livello ha **tre ingressi diversi**.

Le tecniche, e sono esattamente cinque:

1. **Ingressi multipli** — non si entra da una porta sola
2. **Anelli e scorciatoie** — un dungeon ben fatto è pieno di giri che si chiudono
3. **Accesso a metà** — una strada alternativa che ti butta *in mezzo* invece che all'inizio
4. **Passaggi segreti e dislivelli** — premiano la curiosità e rinfrescano zone già percorse
5. **Sottolivelli** — pezzi che stanno di lato al percorso principale, non dopo

E la ragione di fondo: **i percorsi lineari, nell'architettura vera, sono l'eccezione**. Un edificio
fatto di stanze in fila non è un edificio, è un corridoio.

- [The Alexandrian — Xandering the Dungeon](https://thealexandrian.net/wordpress/13085/roleplaying-games/xandering-the-dungeon)
- [The Alexandrian — Parte 2: le tecniche](https://thealexandrian.net/wordpress/13103/roleplaying-games/xandering-the-dungeon-part-2-xandering-techniques)
- [Sly Flourish — A Simpler Checklist for Engaging Dungeon Maps](https://slyflourish.com/simpler_jaquay_style_maps.html)

### Il diagramma di Melan: come si *misura* una mappa

Questa è la cosa più utile che ho trovato in tutto lo studio, e l'ho implementata.

Un **diagramma di Melan** (nato nel 2006 su un forum, poi ripreso dall'Alexandrian) prende una mappa
e le toglie tutto: distanze, direzioni, forme, testi. Resta solo la **topologia** — quali stanze
confinano con quali. E a quel punto la domanda «questa mappa è un labirinto o una fila?» smette di
essere un'opinione e diventa un disegno che si guarda.

Il punto delicato: *distanze e direzioni non contano, conta solo il rapporto di vicinato*. È
esattamente la struttura dei nostri file di zona, che di distanze e direzioni non ne hanno proprio.

→ **Da qui è nato `strumenti/topologia.py`**, che fa questo sulle nostre otto zone e scrive
`docs/topologia.md`. Lo Stack 6 è tutto costruito su quello.

- [The Alexandrian — How to Use a Melan Diagram](https://thealexandrian.net/wordpress/45711/roleplaying-games/xandering-the-dungeon-addendum-how-to-use-a-melan-diagram)
- [Dungeons as networks](https://homicidallyinclinedpersonsofnofixedaddress.com/2023/12/23/dungeons-as-networks/)

### Lordran, e la frase che vale il documento

Su *Dark Souls* la cosa che torna da ogni fonte è che la mappa **veniva prima**: deciso cosa doveva
succedere in un'area, FromSoftware ne disegnava subito la pianta grezza, e solo dopo i dettagli. Il
mondo non è stato riempito, è stato costruito.

E poi la frase che riassume tutto meglio di qualsiasi teoria:

> **In Dark Souls non trovi scorciatoie: trovi come un'area è collegata a un'altra.**

È la differenza fra un ascensore messo lì per farti risparmiare tempo e la scoperta che due posti che
credevi lontani si toccano. La prima è comodità, la seconda è conoscenza — e la conoscenza è la cosa
che il giocatore si porta a casa.

Firelink Shrine funziona da centro perché tutte le strade ne escono come radici, si allontanano, e
poi tornano ad avvolgerla.

- [TheGamer — Dark Souls 1: FromSoftware's magnum opus of interconnected level design](https://www.thegamer.com/dark-souls-1-fromsoftwares-magnum-opus-of-interconnected-level-design/)
- [Medium — World Design lessons from FromSoftware](https://medium.com/@Jamesroha/world-design-lessons-from-fromsoftware-78cadc8982df)
- [Dark Souls Design Works — intervista](https://darksouls.wiki.fextralife.com/Dark+Souls+1+-+Design+Works+Interview)

### La villa di Resident Evil: lo sblocco ricorsivo

La Villa Spencer è descritta come **un avversario**: un posto da battere in astuzia, non da
attraversare. Il meccanismo che la regge ha un nome preciso — *recursive unlocking*: la mappa è
architettata perché il giocatore avanzi a un ritmo **che decide lui**, e in ogni momento ci sono
due o tre serrature aperte contemporaneamente.

Questa è la cosa da rubare: non «una chiave apre una porta», ma **più chiavi in circolo insieme**,
così chi gioca sceglie quale filo tirare.

- [GamesRadar — Hostile Architecture: Resident Evil's Spencer Mansion wants to kill you](https://www.gamesradar.com/hostile-architecture-resident-evils-spencer-mansion-wants-to-kill-you/)
- [Recursive Unlocking: Analyzing Resident Evil's Map Design](https://horror.dreamdawn.com/?p=81213)
- [GamesRadar — Mikami sulla lavorazione di Resident Evil](https://www.gamesradar.com/making-of-resident-evil-shinji-mikami-interview/)

### Hollow Knight: la mappa come personaggio

Qui la scelta forte è che **la mappa te la devi guadagnare**. Cornifer, il cartografo, ti vende
mappe incomplete; per aggiornarle devi sederti su una panchina. Anche i segnaposti comprati al
negozio segnano solo posti dove **sei già stato**.

L'effetto: Hollownest all'inizio è volutamente confusa, e il momento in cui la capisci è un premio,
non un dato di partenza. Le panchine fanno il resto — sono i punti fermi che rendono sopportabile
perdersi.

- [SUPERJUMP — Getting Lost (by Design) in Hollow Knight](https://www.superjumpmagazine.com/getting-lost-by-design-in-hollow-knight/)
- [Kirbylife — A Review of Masterful Map Design and Exploration](https://kirbylife.co.uk/2025/01/05/hollow-knight-a-review-of-masterful-map-design-and-exploration/)

---

## Stack 3 — Guidare senza dire

### Lynch: cinque parole per un posto

*The Image of the City* è del 1960, parla di città vere, ed è diventato il vocabolario standard del
level design. Kevin Lynch dice che chiunque si costruisce in testa l'immagine di un posto usando
cinque cose:

| | | Da noi |
| --- | --- | --- |
| **Percorsi** | le strade su cui ti muovi | le scelte «vai a…» |
| **Bordi** | i confini, ciò che non attraversi | i cancelli, le porte chiuse |
| **Quartieri** | zone con un carattere comune | il piano di sopra, i giardini, i sotterranei |
| **Nodi** | i punti di giunzione dove si decide | i bivi veri |
| **Punti di riferimento** | le cose che vedi da lontano e per cui ti orienti | ci arrivo nello Stack 6, ed è il nostro buco |

La parola chiave è **leggibilità**: uno spazio leggibile è uno di cui riesci a farti una mappa
mentale corretta. Non «uno che non ti perde»: uno che, **quando ti perde, ti lascia il modo di
ritrovarti**.

- [ArtStation — The 5 Ingredients of Game Town Design](https://www.artstation.com/blogs/jesus_machina/RL1vR/02-the-5-ingredients-of-game-town-design)
- [Urban Design Lab — The Image of the City](https://urbandesignlab.in/the-image-of-the-city-by-kevin-lynch/)

### La regola del triangolo

Da una presentazione CEDEC 2017 del direttore di *Breath of the Wild* Hidemaro Fujibayashi e
dell'artista Makoto Yonezu. Ogni ostacolo del mondo è pensato come un triangolo — ci vai **sopra**
o ci giri **intorno** — e i triangoli hanno tre taglie con tre mestieri diversi:

- **grandi** → punti di riferimento, li vedi da lontano e ti ci orienti
- **medi** → ti **nascondono** la vista, così dietro c'è una sorpresa
- **piccoli** → fanno il ritmo, il passo, la texture del terreno

Il risultato che cercavano è una frase sola: **«cosa c'è dietro quella roccia?»**. Le due domande che
genera sono *sorpresa* («cosa c'è dietro?») e *scelta* («ci vado sopra, a destra o a sinistra?»).

Tradotto per un gioco di stanze scritte: **ogni stanza dovrebbe o farti vedere qualcosa di lontano,
o nascondertelo.** Una stanza che non fa né l'una né l'altra è un corridoio.

- [Nintendo Life — Breath of the Wild's design is all about triangles](https://www.nintendolife.com/news/2017/10/zelda_breath_of_the_wilds_ingenious_design_is_all_about_triangles_apparently)
- [80.lv — The Design Secrets of Breath of the Wild](https://80.lv/articles/the-design-secrets-of-breath-of-the-wild)
- [Radiator Blog — Spatial composition and flow in Breath of the Wild](https://www.blog.radiator.debacle.us/2017/10/open-world-level-design-spatial.html)

### Mostrare la meta prima di poterla raggiungere

È la tecnica più economica di tutto il level design, e ha un nome: **prefigurazione**. Far vedere
presto, e da lontano, il posto dove il giocatore arriverà molto dopo. L'esempio canonico è la
Cittadella di *Half-Life 2*: la vedi per tutta la partita, e ogni volta che la guardi misuri quanto
sei avanzato.

Fa tre cose insieme: **anticipazione** (c'è un posto), **orientamento** (so dov'è) e
**avanzamento** (adesso è più vicino). Tre cose con una riga di descrizione.

Sotto ci sta un principio: **mostra, non dire.** Il giocatore deve sempre sapere *dove* deve
arrivare; i passi per arrivarci sono affar suo — quello è il viaggio. E l'avvertimento contrario, che
vale quanto la regola: un livello pieno zeppo di segnaposti e briciole *«fa sembrare tutto
Disneyland»*.

- [The Level Design Book — Wayfinding](https://book.leveldesignbook.com/process/blockout/wayfinding)
- [Shape of Play — Foreshadowing in level design](https://shapeofplay.wordpress.com/2013/04/18/foreshadow-level-design/)
- [Medium — Follow the breadcrumbs: the basic techniques of level design](https://medium.com/my-games-company/follow-the-breadcrumbs-the-basic-techniques-of-level-design-754820499a1b)

### Cancelli e valvole, e come si guarda un'inquadratura

Dal *Level Design Book*, che è la raccolta più ordinata che ho trovato, tre parole che tornano utili:

- **affordance** — qualsiasi cosa che, guardandola, ti dice cosa puoi farci. Le affordance
  *tirano*: il giocatore va verso ciò che sembra utilizzabile
- **cancello** — impedisce di arrivare da qualche parte finché non succede qualcosa
- **valvola** — un passaggio a senso unico. Serve nei giochi lineari: chiude alle spalle

E un esempio di mestiere che vale la pena avere in testa: i progettisti di Valve orientavano gli
stipiti delle porte **verso** le piazze importanti, e ci facevano volare sopra degli uccelli, per
spostare lo sguardo del giocatore su quello che contava. Nessuno glielo diceva a parole.

- [The Level Design Book — Wayfinding](https://book.leveldesignbook.com/process/blockout/wayfinding)
- [The Level Design Book — Pacing](https://book.leveldesignbook.com/process/preproduction/pacing)

### Il tornare indietro: quando è scoperta e quando è corvée

La critica al *backtracking* è vecchia e feroce: molti lo considerano **riempitivo**, un modo di
allungare il gioco riciclando spazio. Le fonti concordano su dove sta la linea:

> Funziona quando **torni con qualcosa di nuovo** e quel qualcosa apre pezzi di mappa che prima non
> potevi toccare. Non funziona quando rifai la stessa strada per lo stesso motivo.

E l'immagine che descrive il momento buono: essere lontanissimo dall'inizio, usare un potere nuovo,
e scoprire una scorciatoia che riduce **venti minuti a due**.

- [Nintendojo — The Backtracking Metroidvania Paradox](https://www.nintendojo.com/features/editorials/the-backtracking-metroidvania-paradox)
- [ResetEra — What exactly is the appeal of Metroidvania backtracking?](https://www.resetera.com/threads/what-exactly-is-supposed-to-be-the-appeal-of-metroidvania-style-backtracking.37675/)

### Il modo più facile di sbagliare: la mappa a puntini

La critica agli open world degli ultimi quindici anni è quasi unanime, e riguarda **le mappe piene di
icone**: torri che rivelano il territorio, punti interrogativi, collezionabili, avamposti. L'accusa
non è «ci sono troppe cose»: è che quei mondi **non sono costruiti attorno alla scoperta, ma attorno
alla ritenzione** — tenerti lì, non farti trovare qualcosa.

E la controprova più interessante: **togliere le icone non basta.** Se sotto le icone c'è contenuto
indifferenziato, senza icone il giocatore non ha nemmeno più il modo di evitare la roba inutile. Il
guasto sta nella mappa, non nella sua interfaccia.

- [TheGamer — You can't fix open world games by taking away the map markers](https://www.thegamer.com/open-world-games-fix-map-markers-elden-ring-assassins-creed/)
- [KeenGamer — Open World Fatigue in Gaming](https://www.keengamer.com/articles/features/opinion-pieces/open-world-fatigue-in-gaming/)

---

## Stack 4 — Il nostro caso speciale: una mappa fatta di scelte scritte

Qui si esce dal level design e si entra in un'altra letteratura, che è quella giusta per noi.

### La tassonomia di Ashwell

L'articolo di riferimento sui giochi a scelte è *Standard Patterns in Choice-Based Games* di Sam Kabo
Ashwell (2015). Identifica le forme ricorrenti, e sono un vocabolario che ci mancava:

| Forma | Com'è fatta | Quando serve |
| --- | --- | --- |
| **Caverna del tempo** | si ramifica e non ritorna mai | racconti brevissimi, molte riletture |
| **Guanto di sfida** | quasi lineare, le diramazioni sono brevi e rientrano | una storia sola, ben raccontata |
| **Rami e strozzature** | ti allarghi, poi tutto ripassa da un punto comune | **far crescere il personaggio** tenendo la trama governabile |
| **Cappello parlante** | il primo pezzo ti smista, poi i rami sono lineari | quando le strade sono identità diverse |
| **Mappa aperta** | giri liberamente in uno spazio | l'esplorazione è il punto |
| **Anello che cresce** | passi sempre dallo stesso punto, ma ogni giro sblocca cose nuove | routine, luoghi familiari, tempo che passa |

Le sotto-strutture che ricorrono ovunque: **strozzature**, **rientri** e **vicoli mortali**.

La nota di Ashwell che conta più delle categorie: **non sono categorie**. Quasi ogni opera vera ne
mescola più di una — e sapere *quale* stai usando in *quale* punto è l'unica cosa che rende la scelta
deliberata invece che accidentale.

- [Standard Patterns in Choice-Based Games](https://heterogenoustasks.wordpress.com/2015/01/26/standard-patterns-in-choice-based-games/)
- [IFWiki — la voce](https://www.ifwiki.org/Standard_Patterns_in_Choice-Based_Games)

### Oltre la ramificazione: le strutture a qualità

Emily Short descrive tre modi di uscire dall'albero delle scelte, e uno è già mezzo nostro:

- **guidata dalle qualità** (*quality-based*, la struttura di *Fallen London*): non esiste un albero.
  Esistono pezzi di storia, ciascuno con le sue condizioni; in ogni momento il gioco ti mostra quelli
  **legali adesso**, e scegli tu. Lo stato del mondo sostituisce la ramificazione.
- **guidata dalla salienza**: come sopra, ma è il gioco a scegliere quale pezzo è il più pertinente
  in quel momento, invece di mostrarteli tutti.
- **a tappe** (*waypoint*): punti fissi obbligati, con libertà totale fra l'uno e l'altro.

Da noi le bandierine (`flag`, `una_tantum`, `richiede_flag`) sono già un sistema a qualità **usato
come se fosse un albero**: le usiamo per aprire e chiudere singole scelte, non per far comparire
contenuto. È una differenza grossa e ci torno alla fine.

- [Emily Short — Beyond Branching: Quality-Based, Salience-Based, and Waypoint](https://emshort.blog/2016/04/12/beyond-branching-quality-based-and-salience-based-narrative-structures/)
- [Emily Short — Small-Scale Structures in CYOA](https://emshort.blog/2016/11/05/small-scale-structures-in-cyoa/)
- [Emily Short — Survey of Storylets-based Design](https://emshort.blog/2019/01/06/kreminski-on-storylets/)

### Missione e spazio sono due cose diverse

Joris Dormans, studiando un dungeon di *Twilight Princess*, ha isolato una distinzione che sembra
ovvia e non lo è: un livello è fatto di **due strutture sovrapposte**.

- la **missione** — la sequenza di cose che devi fare
- lo **spazio** — la pianta, cioè dove sono le stanze

Sono separabili: la stessa missione può stare dentro piante diversissime, e la stessa pianta può
ospitare missioni diverse. E c'è una frase che è quasi una ricetta: **serrature e chiavi servono a
trasformare una missione lineare in uno spazio ramificato.**

Ha anche una tassonomia delle chiavi, e la useremo:

- **consumabile** o **permanente** (si spende, o resta)
- **specifica** o **generica** (apre quella porta, o una porta di quel tipo)

- [Adventures in level design: Generating missions and spaces](https://www.researchgate.net/publication/228994305_Adventures_in_level_design_Generating_missions_and_spaces_for_action_adventure_games)
- [BorisTheBrave — Lock and Key Dungeons](https://www.boristhebrave.com/2021/02/27/lock-and-key-dungeons/)

### Boss Keys: qualcuno l'ha già fatto, su Zelda, con i grafi

Mark Brown ha passato anni a ridisegnare **ogni dungeon di Zelda come un grafo** di serrature e
chiavi, per rispondere a tre domande secche:

1. ci sono percorsi che si ramificano?
2. il giocatore **sceglie** davvero quale prendere?
3. quanto si deve tornare indietro?

Il risultato è che tutti i dungeon della serie si lasciano raggruppare in tre famiglie. Non ci serve
la classificazione: ci serve **il metodo** — ridurre a grafo, e poi porre quelle tre domande. È
esattamente quello che fa il nostro `topologia.py`.

- [Room Escape Artist — Boss Keys: an analysis of Zelda dungeons](https://roomescapeartist.com/2017/09/10/boss-keys-analysis-zelda-dungeons/)
- [Hyrule University — Review of Boss Keys](https://hyruleuniversity.wordpress.com/2017/09/29/review-of-boss-keys/)

### Come si scrivono le uscite di una stanza

Dalla pratica della narrativa interattiva, dove il problema è vecchio di quarant'anni:

- **non elencare le uscite meccanicamente.** «Puoi andare a nord, sud e ovest» è la forma da evitare;
  la forma buona le mette nella prosa: *«un passaggio poco profondo scende, e un altro più ripido
  sale»*
- in una descrizione di stanza ci sono **da una a tre cose essenziali** da far passare. Non di più
- le uscite vanno **segnalate**, in prosa o altrove: se il giocatore non sa dove può andare, non sta
  scegliendo, sta indovinando

- [IF Forum — How do you describe a room's exits?](https://intfiction.org/t/how-do-you-describe-a-rooms-exits/9433)
- [Inform Designer's Manual §51 — The room description](https://www.inform-fiction.org/manual/html/s51.html)
- [IF Forum — How to write good room descriptions](https://intfiction.org/t/how-to-write-good-room-descriptions/9237)

### Etrian Odyssey: e se disegnare la mappa fosse il gioco

Vale la pena citarlo perché è la posizione più estrema possibile sull'argomento. *Etrian Odyssey*
mette la mappa sullo schermo di sotto del DS come un foglio a quadretti **vuoto**, e non la disegna:
la disegni tu, piano per piano, mentre cammini. A differenza di ogni altro dungeon crawler, che la
riempie da solo.

Per moltissimi giocatori **quella è la ragione per cui ci giocano.** Con un vincolo interessante: si
può disegnare male o bene, ma i simboli sono quelli dati dal gioco, non liberi.

Il motivo per cui lo metto qui: noi una mappa a quadretti ce l'abbiamo già (`mappa_dungeon` nei file
di zona) e la riempiamo noi. Non sto dicendo di copiare Etrian — sto dicendo che **la mappa è un
posto dove si può mettere del gioco**, e da noi oggi è solo un rendiconto.

- [Retronauts — Etrian Odyssey V, a DIY tribute to the art of game mapping](https://retronauts.com/article/611/etrian-odyssey-v-a-diy-tribute-to-the-art-of-game-mapping)
- [Screen Rant — Beautifully remastered dungeon crawling cartography](https://screenrant.com/etrian-odyssey-origins-collection-switch-review/)

### E la scelta che non è una scelta

L'*illusione della scelta* è quando il giocatore crede di scegliere ma o non c'è una vera
alternativa, o le conseguenze sono trascurabili. La definizione positiva che torna da più fonti:
**una scelta vera è fatta di possibilità in conflitto** — se non c'è conflitto, non c'è scelta.

E l'avvertimento pratico: le emozioni positive che una scelta produce **si rovesciano in negativo**
nel momento in cui il giocatore capisce che non contava niente. Meglio non offrirla.

- [Game Developer — Illusion of choice is better than choice](https://www.gamedeveloper.com/design/illusion-of-choice-is-better-than-choice-choices-and-illusions-as-narrative-mechanics)
- [Wayline — The Illusion of Choice: when branching narratives lead back to the same path](https://www.wayline.io/blog/illusion-of-choice-branching-narratives)

---

## Stack 5 — Cosa hanno fatto i nostri parenti stretti

### EarthBound: nessun overworld, apposta

Itoi ha deciso di **non avere una mappa del mondo separata** perché non voleva che restasse una
distinzione fra «la città» e «fuori». Conseguenza diretta: ogni città è stata disegnata per essere
diversa da tutte le altre — perché non c'era un contenitore neutro a fare da collante.

È una scelta che ha un prezzo e un guadagno, e li ha entrambi: niente respiro fra un posto e
l'altro, ma nessun posto che si assomigli.

- [Wikipedia — EarthBound](https://en.wikipedia.org/wiki/EarthBound)
- [EarthBound Wiki — The World of Mother 2](https://earthbound.fandom.com/wiki/The_World_of_Mother_2)

### Pokémon: i cancelli che invecchiano male

Il sistema delle MN è il caso di studio su come **non** fare i cancelli. Le mappe sono disegnate con
bordi attraversabili in una direzione sola e con oggetti raggiungibili solo tornando indietro con
l'abilità giusta. Funziona; ma la critica, ormai consolidata, è che le MN **tassano la squadra**: sei
costretto a portarti dietro creature che sanno quelle mosse, e la quarta generazione — Scalata Roccia,
Nebbianiente — è il momento in cui il costo ha superato il beneficio.

La lezione per noi: **una chiave che occupa uno slot non è gratis.** Se un cancello si apre solo
portandosi dietro qualcosa, quel qualcosa deve valere anche per altro.

- [PokéCommunity — Fangame Tutorials: Mapping Routes](https://daily.pokecommunity.com/2017/09/14/fangame-tutorials-mapping-routes/)
- [Pokémon Workshop — Good practices in Level Design](https://pokemonworkshop.com/en/learn/good-practices-in-level-design)
- [FreakyTrigger — Going Back To My Routes: Sinnoh](https://freakytrigger.co.uk/ft/2017/03/going-back-to-my-routes-sinnoh)

### Fear and Hunger: la mappa che non ti lascia imparare

Il parente più stretto per tono, e fa una cosa che va capita bene prima di copiarla: le piante **non
sono casuali**, sono un insieme di varianti prestabilite — tre o quattro per area — ricombinate a
ogni partita. Non è generazione procedurale: è **impedire la memorizzazione** senza rinunciare al
disegno a mano.

E c'è un dettaglio crudele all'ingresso: due strade, e se ci metti troppo a sceglierne una, un branco
di cani ti viene addosso. **La mappa ti mette fretta.**

- [Fear & Hunger Wiki — Dungeons of Fear & Hunger](https://fearandhunger.fandom.com/wiki/Dungeons_of_Fear_%26_Hunger)
- [Wikipedia — Fear & Hunger](https://en.wikipedia.org/wiki/Fear_%26_Hunger)

---

## Stack 6 — Carnivalz: la mappa vera, misurata

Tutto quello che segue esce da `strumenti/topologia.py`, che legge gli otto file di zona e ne
ricava lo scheletro. Si rigenera in un secondo, e sta in `docs/topologia.md`.

> **Una cosa mia, prima di cominciare.** La prima versione del misuratore diceva che **undici stanze
> erano irraggiungibili**. Stavo per scrivertelo come un guasto. Non lo era: cercavo le destinazioni
> solo al primo livello di ogni scelta, e mi sfuggivano quelle che stanno dentro l'esito di un
> combattimento (`se_vinci`, `se_perdi`). Corretto il conto, **tutte le stanze si raggiungono, e ogni
> zona è un pezzo solo.** Lo scrivo perché un misuratore che manda a caccia di guasti inesistenti è
> peggio di nessun misuratore — e questo è il secondo che mi succede in due giorni.

### Il quadro

| zona | stanze | porte | anelli | scorciatoie | bivi veri | con sostanza | agguati | cancelli |
| --- | --: | --: | --: | --: | --: | --: | --: | --: |
| Casa Gigante | 79 | 114 | 36 | 10 | 21 | 30 | 10 | 11 |
| Rocca Ossidiana | 37 | 58 | 22 | 3 | 13 | 21 | 3 | 8 |
| Meridia | 28 | 50 | 23 | 8 | 8 | 14 | 5 | 0 |
| Squarcio Industriale | 27 | 49 | 23 | 3 | 9 | 12 | 6 | 0 |
| Kizako Ala | 8 | 10 | 3 | 0 | 4 | 4 | 3 | 0 |
| Teatro del Passato | 6 | 5 | 0 | 0 | 4 | 6 | 0 | 0 |
| Fontana | 3 | 2 | 0 | 0 | 1 | 1 | 0 | 0 |
| Qualcosa Preme | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| **tutte** | **189** | **288** | **107** | **24** | **60** | **88** | **27** | **19** |

### La cosa buona, e non me l'aspettavo

**107 anelli su 189 stanze.** La mappa **non è un albero.** Secondo il righello di Jaquays — che è il
più severo che esista su questo — le nostre zone sono strutturalmente non lineari: ci sono giri che
si chiudono, quasi ovunque. Squarcio Industriale ha 23 anelli su 27 stanze, che è una densità alta.

Se mi avessi chiesto a occhio prima di misurare, avrei detto il contrario.

### Le tre cose che non vanno

**1. Gli anelli quasi non si sentono.**

Su 288 porte, **222 (il 77%) collegano stanze confinanti** — cioè alla stessa distanza
dall'ingresso, o a una di scarto. Altre 28 saltano due stanze. Le porte che ne saltano almeno tre
sono 38, e di queste **14 sono l'espulsione dopo una sconfitta**: non le trovi, ti capitano.

**Restano 24 vere scorciatoie in tutto il gioco.** E guardandole una per una, quasi nessuna è la cosa
che Dark Souls chiama scorciatoia: sono soprattutto i ritorni dopo un pezzo scritto (`dopo_ondate`,
`dopo_volto`, `dopo_operaio`). Sono transizioni narrative, non conoscenza dello spazio.

> Tradotto: abbiamo gli anelli sulla carta e non l'esperienza degli anelli. Nessuno dirà mai
> «ah, ma allora il vivaio dà sul giardino est».

**2. Due stanze su tre non fanno scegliere niente.**

| scelte vere (senza «torna indietro») | stanze |
| --: | --: |
| 0 | 52 |
| 1 | 77 |
| 2 | 24 |
| 3 | 16 |
| 4 | 13 |
| 5+ | 7 |

**129 stanze su 189, cioè il 68%, offrono una strada sola o nessuna.** E dall'altra parte: su 420
scelte in tutto il gioco, **154 (il 37%) sono «torna indietro»**, e altre 41 sono cappi che ti
lasciano dove sei.

Quindi il bilancio vero del budget di scelte è: più di un terzo serve a tornare sui propri passi, un
decimo a frugare, e quello che resta è distribuito su una minoranza di stanze.

**3. Più di metà delle stanze sono vuote.**

**101 stanze su 189 non hanno niente dentro**: nessun agguato, nessun oggetto, nessun tazo, nessuna
bandierina, nessuna porta che si apra. Si attraversano e basta. Alla Casa Gigante — la zona più
grande, 79 stanze — ne hanno qualcosa **30**.

E gli agguati sono **27 su 189**: il 14%. Un corridoio dove non succede niente quattro volte su
cinque non è tensione, è tragitto.

### I cancelli: 19, e quasi tutti sono dossi

Delle 19 scelte chiuse da una condizione, la distanza fra dove si accende la bandierina e dove serve
è quasi sempre **zero, uno o due stanze**. Le uniche due che valgono davvero:

| zona | condizione | distanza chiave-serratura |
| --- | --- | --: |
| Casa Gigante | `casa_ricordo_sconfitto` | **9** |
| Rocca Ossidiana | `oss_compagna_reclutata` | **5** |

Le altre sono serrature messe accanto alla loro chiave. Nella lingua di Dormans: chiavi
**specifiche** e **consumabili**, usate una volta, a un passo dalla porta. Non trasformano una
missione lineare in uno spazio ramificato — è proprio il lavoro che una serratura dovrebbe fare.

E c'è un dato che dice la stessa cosa da un'altra angolazione: **sei zone su otto non hanno nemmeno
un cancello.** Due sono monconi da tre e da una stanza, e va bene così — ma le altre quattro no:
**Meridia (28 stanze), Squarcio Industriale (27), Kizako, il Teatro.** Si entra e si cammina.

### Quale forma abbiamo, secondo Ashwell

Guardando la forma e non le intenzioni, le nostre zone sono **guanti di sfida con rientro**: un
percorso principale, diramazioni corte che tornano subito, e una strozzatura a ogni boss. La Casa
Gigante prova ad essere una **mappa aperta** ed è la sola che ci si avvicini.

Non è una condanna — il guanto di sfida è la forma giusta per raccontare una storia sola e
raccontarla bene, ed è quello che la Casa Gigante fa con l'incipit migliore del gioco. Ma è utile
saperlo: **oggi non stiamo facendo una mappa aperta, ne stiamo scrivendo una che le somiglia.**

### Il ritmo: quanto spesso succede qualcosa

Questo non me l'aspettavo, e ribalta una convinzione che avevo.

La critica classica agli RPG a turni è che **gli scontri casuali sono troppi**: un combattimento ogni
pochi passi trasforma un dungeon in una palude, e un sistema di combattimento anche affascinante
viene ridotto in polvere dal doverlo rifare cento volte. È la lamentela numero uno del genere, e la
ragione per cui gli scontri casuali sono quasi spariti dagli RPG moderni.

Noi abbiamo il problema **opposto**, ed è più grave.

| zona | stanze | con agguato | scontri attesi ad attraversarla tutta |
| --- | --: | --: | --: |
| Casa Gigante | 79 | 10 (13%) | **3,4** |
| Rocca Ossidiana | 37 | 3 (8%) | **1,0** |
| Meridia | 28 | 5 (18%) | 2,6 |
| Squarcio Industriale | 27 | 6 (22%) | 2,0 |
| Kizako Ala | 8 | 3 (38%) | 1,3 |
| Teatro · Fontana · Qualcosa Preme | 10 | 0 | 0 |

**Settantanove stanze per tre combattimenti e mezzo.** La Rocca Ossidiana ne ha trentasette per
**uno**. Non è un gioco che interrompe troppo: è un gioco in cui, fra un momento e l'altro, si
cammina per venti stanze vuote.

E il combattimento è la parte del gioco che funziona meglio — è quella su cui c'è tutto il lavoro di
questi giorni: il fermo immagine, i tipi che si vedono, il tetto alla cura. Lo stiamo usando **tre
volte per zona.**

Le probabilità, fra l'altro, sono tutte strette fra 0,30 e 0,65 (media 0,38): non c'è nessuna zona
che sia più pericolosa di un'altra, e nessuna stanza che sia più pericolosa delle sue vicine. Anche
il pericolo è piatto.

- [Medium — Pacing and level design in JRPGs](https://medium.com/@MammonMachine/nobody-cares-about-it-but-it-s-the-only-thing-that-matters-pacing-and-level-design-3ed043dc3309)
- [Random encounters, less is more](https://matthewmarchitto.substack.com/p/random-encounters-less-is-more)

### Cosa manca, in ordine di quanto costa poco

**Punti di riferimento.** Nel senso di Lynch e di Romero: non ne abbiamo nessuno. Non esiste un
posto che si veda da un'altra stanza, che venga nominato da lontano, che serva a orientarsi. È la
cosa più economica di tutte da aggiungere, perché **è testo**: basta che una stanza nomini un'altra
stanza. «Dalla finestra del ballatoio si vede il vivaio, laggiù in fondo al giardino». Quello è un
punto di riferimento, e costa una riga.

E attenzione alla regola 5 di Romero, che a questo punto diventa un vincolo: **se lo nomini, ci si
deve poter andare.**

**Scorciatoie che si aprono e restano aperte.** Adesso le bandierine aprono *scelte*; nessuna apre
una *porta permanente* verso un pezzo lontano. Una sola, alla Casa Gigante — «adesso dall'attico si
scende direttamente nel salone» — cambierebbe il modo in cui si sente tutta la zona. Vale più di
dieci stanze nuove.

**Sostanza nelle stanze vuote, o meno stanze.** Sono le due uniche strade e vanno bene entrambe.
Hakoniwa dice che una zona non migliora aggiungendo stanze: la Casa Gigante con 50 stanze piene
sarebbe un posto migliore della Casa Gigante con 79 di cui 49 vuote. Se invece restano tutte, ognuna
deve guadagnarsi il posto — anche solo con una frase che nomina qualcosa che si vede.

**Le bandierine come qualità, non come interruttori.** Ne abbiamo già il meccanismo. Oggi
`richiede_flag` spegne una scelta; nella struttura a qualità di *Fallen London* la stessa bandierina
**fa comparire** contenuto. La differenza per chi gioca è enorme: nel primo caso il mondo è una
serie di porte chiuse, nel secondo è un posto che risponde. Non serve codice nuovo — serve usarlo
al contrario.

**Più cose che succedono, e non distribuite a caso.** Il ritmo non si aggiusta alzando le
probabilità: si aggiusta decidendo **dove**. Una zona dovrebbe avere posti che sai essere pericolosi
e posti che sai essere sicuri — è quello che fanno le panchine di *Hollow Knight*, al contrario. Oggi
ogni agguato ha più o meno la stessa probabilità di ogni altro, quindi il pericolo non è
un'informazione: è rumore. Tre stanze al 70% in fondo a un corridoio, e il resto tranquillo, si
leggono; ventisette stanze al 38% no.

**Un ingresso in più, da qualche parte.** La tecnica numero uno di Jaquays, e non ne abbiamo nessuna
zona che ce l'abbia. Anche uno solo, anche in una sola zona, insegnerebbe al giocatore che questo è
un gioco in cui le cose si possono raggiungere da più parti — e da lì in poi guarderebbe tutto il
resto in un altro modo.

### Il numero

Se devo dare un voto alla mappa con la stessa durezza della critica generale:

| | |
| --- | --: |
| **Struttura** (c'è un traliccio, non è una fila) | **7** |
| **Densità** (cosa c'è dentro le stanze) | **4** |
| **Orientamento** (punti di riferimento, leggibilità) | **2** |
| **Serrature e chiavi** (fanno il loro mestiere?) | **3** |
| **La mappa come un oggetto solo** (scorciatoie, conoscenza) | **3** |
| **Ritmo** (ogni quanto succede qualcosa) | **3** |

Lo scheletro è migliore di quanto pensassi e la carne è meno di quanta pensassi. Che è, quasi parola
per parola, la stessa cosa che è venuta fuori dalla critica di ieri: **i sistemi sono avanti, il
contenuto è indietro.** Solo che stavolta la parte che manca non sono disegni, è testo — ed è roba
che possiamo fare senza aspettare nessuno.

---

*Il dedalo · studio scritto il 12 settembre 2026 · ramo `claude/inizio-progetto-dya2lr`*
*Le misure si rifanno con `./strumenti/topologia.py`; le fonti sono sintesi di ricerca, non pagine aperte.*
