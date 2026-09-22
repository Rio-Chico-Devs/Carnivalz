# Le fonti che non riesco a scaricare

Da dentro questa sessione ogni dominio risponde **403** dal proxy di policy:
la documentazione di Godot, i PDF dei paper, i blog. La ricerca web funziona,
ma restituisce **sintesi** — e una sintesi mi ha già fatto leggere al contrario
uno studio da 45.000 giocatori (vedi `docs/tutorial.md`, sezione 0).

Quindi: Bru le scarica, io le leggo qui.

## Come metterle

Un file per fonte, con un nome che dica cos'è:

```
docs/fonti/godot-inputevent.md
docs/fonti/command-pattern.md
docs/fonti/chi2012-tutorials.pdf
```

**Il formato non conta**: `.md`, `.txt` e `.pdf` li leggo tutti. Non serve
pulire, riformattare o tagliare — il testo incollato così com'è va benissimo, e
anzi è meglio: quello che a te sembra un pezzo inutile a volte è la riga che
cambia la conclusione.

**Metti il link in cima al file**, una riga sola. Serve a sapere cosa stiamo
citando quando lo citiamo, e a ritrovarlo fra sei mesi.

## Cosa c'è qui dentro

I PDF non hanno una prima riga dove mettere il link, quindi stanno qui.

| file | cos'è | link |
|---|---|---|
| `chi2012-tutorial-complessita.pdf` | Andersen, O'Rourke, Liu, Snider, Lowdermilk, Truong, Cooper, Popović — *The Impact of Tutorials on Games of Varying Complexity*, CHI 2012 | https://grail.cs.washington.edu/projects/gameplay-analytics/chi2012-tutorial.pdf |
| `command-pattern-nystrom.pdf` | Robert Nystrom — *Command*, in *Game Programming Patterns* | https://gameprogrammingpatterns.com/command.html |
| `input-buffering-wayline.md` | Gemma Ellison — *Input Buffering: The Key to Responsive Game Feel* | https://www.wayline.io/blog/input-buffering-responsive-game-feel |
| `faulkner-cinque-utenti.pdf` | Laura Faulkner — *Beyond the five-user assumption*, Behavior Research Methods 35(3), 2003 | https://link.springer.com/article/10.3758/BF03195514 |
| `show-or-tell-fdg2024.pdf` | Anderson, Carpenter, Hussein, DeLiema — *Show or Tell?*, FDG 2024 | https://doi.org/10.1145/3649921.3650021 |
| `gdscript-guida-di-stile.pdf` | *GDScript style guide*, documentazione ufficiale di Godot | https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html |
| `complessita-cognitiva-sonar.pdf` | G. Ann Campbell — *Cognitive Complexity: a new way of measuring understandability*, SonarSource | https://www.sonarsource.com/resources/cognitive-complexity/ |
| `celeste-player.cs` + `celeste-player-readme.md` | Noel Berry e Maddy Thorson — il codice del movimento di Celeste, pubblicato dagli autori | https://github.com/NoelFB/Celeste/tree/master/Source/Player |
| `parnas-decomposizione-moduli.pdf` | D.L. Parnas — *On the Criteria To Be Used in Decomposing Systems into Modules*, CACM 15(12), 1972 | https://dl.acm.org/doi/10.1145/361598.361623 |
| `variabili-visive-bertin.md` | Axis Maps, *Cartography Guide* — le sette variabili visive di Bertin e le loro quattro proprietà | https://www.axismaps.com/guide/visual-variables |
| `principi-cartografia-esri.md` | Aileen Buckley (Esri) — *Primary Design Principles for Cartography*, da *Map Use*, nona edizione | https://www.esri.com/arcgis-blog/products/arcgis-pro/mapping/primary-design-principles-for-cartography |
| `godot-control-classe.md` | *Control*, riferimento di classe di Godot | https://docs.godotengine.org/en/stable/classes/class_control.html |
| `godot-zoom-e-trascinamento.md` | thygrrr — *Godot Zoom and Pan, smooth & cursor-centric Camera2D motion* (Unlicense/CC0), coi commenti | https://gist.github.com/thygrrr/8288cabeb5cd25031ce6132c4a886311 |
| `euristiche-giocabilita-play.md` | Desurvire e Wiberg — *Game Usability Heuristics (PLAY)*, il seguito di HEP (CHI 2004) | https://ocw.metu.edu.tr/pluginfile.php/4129/mod_resource/content/0/ceit706_2/10/game_usability-_heuristics.pdf |
| `persona5-intervista-interfaccia.md` | Masayoshi Sutou (art director, Atlus) intervistato da *Famitsu* #1449, traduzione Play-Asia | https://personacentral.com/persona-5-interview-ui-design-sound-music/ |
| `ffxvi-interfaccia-durczok.md` | Paweł Durczok — *The Final Fantasy XVI interface: a Cabinet of Curiosities* | https://medium.com/@I_am_PD/the-final-fantasy-xvi-interface-a-cabinet-of-curiosities-c0fc7fc554b1 |
| `godot-inputevent-classe.pdf` | *InputEvent*, riferimento di classe di Godot | https://docs.godotengine.org/en/stable/classes/class_inputevent.html |

## I PDF adesso si leggono da soli

`strumenti/sfoglia.py` tira fuori il testo da un PDF con la sola zlib — niente
librerie, niente rete, che da qui non esce comunque.

```
python3 strumenti/sfoglia.py docs/fonti/qualcosa.pdf > docs/fonti/qualcosa.md
```

Non è banale come sembra, e le due trappole valgono scritte perché tutte e due
producono **testo leggibile e sbagliato**, che è il modo più facile di citare
male una fonte:

- un PDF stampato dal browser incorpora font **sottoinsieme**, e ogni font ha
  la sua tabella `ToUnicode`. Fondendole tutte in una sola esce «The defaut
  curs+r shape f+r this c+ntr+»: la «o» diventa «+» e la «l» sparisce, senza
  nessun errore da nessuna parte;
- certe tabelle non traducono affatto alcuni glifi e li mandano nell'**area a
  uso privato**, che non è un carattere, è un buco. La «l» della documentazione
  di Godot finiva in `U+E050`, duemila volte.

E una terza, scoperta col documento delle euristiche: certi PDF — quelli fatti
da LaTeX o da Word — **non hanno nessuna tabella ToUnicode**, perche' usano font
veri con codifica standard e i codici SONO gia' i caratteri. Arrendersi li'
vuol dire consegnare un file vuoto per dieci pagine piene di testo: e' successo,
un byte in uscita.

Quando restano glifi che non sa tradurre, lo strumento li segna con `�`
e lo dice su stderr, invece di consegnare un testo che sembra a posto.

## Perché non le committiamo e basta

Le committiamo eccome — stanno qui dentro apposta. Questa cartella non è
codice e non entra in nessun tetto strutturale: è la biblioteca del progetto.

## Quello che mi manca ancora (in ordine di quanto cambia il gioco)

Bru: «fammi un elenco del resto delle fonti che non hai potuto vedere per
intero». Questa è la lista, ricavata rileggendo cosa i documenti citano
davvero, non a memoria.

### 0. LA MAPPA — quello che serve adesso

Il buco l'ho trovato rileggendo `docs/dedalo.md`: Romero, Jaquays, il diagramma
di Melan, Lynch, la tassonomia di Ashwell, Boss Keys, Etrian, Hollow Knight —
**tutta progettazione dello spazio**. Di come si disegna il *diagramma
leggibile* di quello spazio non c'è una riga. Zero occorrenze di Bertin,
variabili visive, figura-sfondo, contrasto, daltonismo. Ed è esattamente dove
stava il difetto: le stanze visitate non si vedevano, e nessuno se n'era
accorto perché nessuno aveva mai guardato la mappa *come diagramma*.

**Arrivate il 22 settembre** (Bru: «ti passo quelle che ho reputato valide»),
lette per intero e studiate in `docs/segni.md`:

- ✅ **Bertin / variabili visive** → `variabili-visive-bertin.md`
- ✅ **I cinque principi della cartografia** → `principi-cartografia-esri.md`
- ✅ **Godot `Control`** → `godot-control-classe.md`
- ✅ **Zoom e trascinamento** → `godot-zoom-e-trascinamento.md`
- ⛔ **Game UI Database, Hollow Knight** — è fatto di **sole immagini**, e in
  fondo a ogni pagina c'è scritto che il contenuto del sito non può essere
  usato per addestrare o alimentare sistemi di apprendimento automatico. Non
  l'ho letto e non lo leggerò. Per quegli esempi servono **tue schermate** di
  un gioco che hai, o una fonte senza quella clausola.

**Quello che resta da procurare**, in ordine:

| # | cosa | perché a noi | link |
|---|---|---|---|
| **1** | **Schermate-mappa, come immagini** — ma non da Game UI Database (vedi sopra) | Devo vedere come segnano *stato* (visitato / intravisto / ignoto), dove mettono i nomi, come si legge il «sei qui» | — |
| **2** | **La tua pianta del complesso**, anche a matita fotografata | Le coordinate me le prendo da quella. Non serve finita: il PNG buono lo infili dopo senza toccare niente | — |
| **3** | **Krygier & Wood, *Making Maps*** (libero, testo intero) | Generalizzazione: cosa si toglie quando la scala scende. È la domanda che si pone **appena** mettiamo lo zoom | https://colorado.pressbooks.pub/makingmaps/chapter/cartographic-design-process/ |
| **4** | **Dove si mette il nome di una stanza** — posizionamento delle etichette | Appena i nomi si disegnano davvero, diventa il problema numero uno: non coprire un corridoio, non accavallarsi col nome accanto | https://en.wikipedia.org/wiki/Typography_(cartography) — https://arxiv.org/pdf/2507.22952 |
| **5** | **WCAG 1.4.11, testo del criterio** | La soglia 3:1 ce l'ho e i rapporti li ho **calcolati** (`docs/segni.md`). Manca il testo per le eccezioni: cosa conta come «decorativo» | https://www.w3.org/WAI/WCAG21/Understanding/non-text-contrast.html |
| **6** | **Game Accessibility Guidelines**, la pagina sul colore | La regola la conosco; serve la formulazione esatta e gli esempi | https://gameaccessibilityguidelines.com/ensure-no-essential-information-is-conveyed-by-a-fixed-colour-alone/ |

**Le previsioni che avevo fatto sulle sintesi, verificate sul testo vero:**

- ✅ «posizione e dimensione sono le uniche che comunicano una quantità» — **giusto**
- ✅ «per l'ordine il chiaroscuro batte la tinta» — **giusto**: valore è ordinato, tinta no
- ❌ «tinta, forma e orientamento servono a raggruppare, non a ordinare» —
  **impreciso**: avevo confuso due proprietà diverse. La tinta è *sia* selettiva
  *sia* associativa; la **forma** è associativa ma secondo Bertin non è **mai**
  selettiva. È una distinzione che cambia cosa possiamo chiedere alle icone.
- ❌ «PASS consuma l'evento e lo passa anche al genitore» — **sbagliato**: il
  manuale dice che passa **solo se il controllo non l'ha gestito**.

Due su quattro. È il motivo per cui le sintesi non bastano.

**Una nota sul proxy**, perché è cambiato: ieri GitHub passava (è così che ho
letto il sorgente di Celeste). Oggi **WebFetch è bloccato su tutto** — ho
provato anche `anthropic.com` — e `curl` non esce proprio. Resta solo la
ricerca, che dà sintesi.

### 0-bis. I MENU — la prossima tornata

Bru: «creazione di menu, inventory, weapons, money counter, xp counter e
organizzazione menu vari». Prima di cercare ho guardato cosa abbiamo davvero,
se no la ricerca esce generica:

- **la pausa è una lista di sette voci di solo testo**, allineate a sinistra,
  con «Tazo 30» e «Lv 1» in alto a destra e metà schermo vuoto (`scatti/menu.png`);
- `scripts/Pausa.gd` è **893 righe** e contiene già diario, storico, zaino a
  **scomparti con capienza**, equipaggiamento, squadra;
- la valuta si chiama **Tazo**, e l'XP è mascherato da **hype** — Bru:
  «facciamo che spendi xp ma maschereremo l'xp con il termine hype»;
- il livello **non esiste separato**: è quanti nodi hai comprato. Quindi la
  schermata dei nodi *è* la schermata di livello, e sono la stessa cosa.

Questo cambia cosa serve: non «come si fa un inventario», ma **come si presenta
un inventario a capienza limitata**, **come si anima un contatore che il
giocatore spende**, e **come si organizza un menu che ha già sei sezioni**.

#### Le immagini — e qui c'è un problema di licenza da sciogliere tu

| # | cosa | link |
|---|---|---|
| **1** | **Interface In Game** — 16.214 schermate catalogate per *Inventory, Menu, Progress, Stats, Store, Skill tree*. È l'alternativa a Game UI Database. **Controlla tu i termini d'uso prima di mandarmi roba da lì**: non riesco ad aprirlo e non voglio ripetere il caso qui sotto | https://interfaceingame.com/screenshots/ |
| **2** | ⛔ **Game UI Database** — continua a uscire per ogni gioco che hai nominato (Persona 5, River City Girls 1 e 2, FFXVI). **Non lo uso**: dichiara che il contenuto non può alimentare sistemi di apprendimento automatico | — |
| **3** | **Il manuale ufficiale di Yu-Gi-Oh GX: Duel Academy** (GBA), in PDF. È una **fonte primaria**: descrive il PDA, l'editor del mazzo e come sono organizzate le voci su uno schermo minuscolo | https://www.videogamemanual.com/gba/Yu-Gi-Oh!%20GX%20-%20Duel%20Academy%20(USA).pdf |

#### I testi, in ordine di quanto cambiano la nostra interfaccia

| # | cosa | a cosa ci serve | link |
|---|---|---|---|
| **4** | **Desurvire, Kaplan, Toth — *Heuristic Evaluation for Playability* (CHI 2004)**, e il seguito **PLAY** | È l'unica lista di euristiche fatta **per i giochi** invece che per i siti. Serve come cancello: una schermata o le passa o no. Il PDF di PLAY sembra scaricabile libero | https://dl.acm.org/doi/10.1145/985921.986102 — https://ocw.metu.edu.tr/pluginfile.php/4129/mod_resource/content/0/ceit706_2/10/game_usability-_heuristics.pdf |
| **5** | **Celia Hodent — *The Gamer's Brain*** | Carico cognitivo applicato ai menu. La riga che ho già visto citata: «the workload in a game must be dedicated to the core experience you want to offer, **not in figuring out menus**». Va letta per esteso, non citata così | https://celiahodent.com/video-game-ux-psychology/ |
| **6** | **Fagerholt & Lorentzon — *Beyond the HUD*** (tesi di laurea, Chalmers) | È da qui che vengono i quattro termini che tutto il mestiere usa: **diegetico, meta, spaziale, non-diegetico**. Ci serve per decidere cosa sono Tazo e hype: numeri sullo schermo o cose del mondo. *Nota: le citazioni danno 2008 in un posto e 2009 in un altro — da verificare sul documento* | https://www.semanticscholar.org/paper/16ee02a8839923752c6bc93f294bec67d73a586e |
| **7** | **Intervista agli autori dell'interfaccia di Persona 5** — Masayoshi Sutoh (art director e capo UI) e Kazuhisa Wada, da CEDEC+KYUSHU 2017 | È il menu di JRPG più celebrato degli ultimi dieci anni e la nostra tavolozza è **la sua**: rosso cremisi su nero, testo bianco. Ci serve il ragionamento, non le schermate | https://personacentral.com/persona-5-interview-ui-design-sound-music/ |
| **8** | **Timothy Cain — *Inventory UI: Grid vs. List*** | Cain è l'autore del primo Fallout. Noi abbiamo una **lista a scomparti con capienza**, cioè esattamente il caso di mezzo fra i due | https://rpgwatch.com/show/newsbit?newsbit=56159 |
| **9** | **Paweł Durczok — *The Final Fantasy XVI interface: a Cabinet of Curiosities*** | Una demolizione seria, schermata per schermata, di un menu di Final Fantasy moderno — fatta da un progettista, non da un recensore | https://medium.com/@I_am_PD/the-final-fantasy-xvi-interface-a-cabinet-of-curiosities-c0fc7fc554b1 |
| **10** | **Jonasson & Purho — *Juice it or lose it*** (Nordic Game Jam 2012), e **Swink, *Game Feel*** | Per i contatori: Tazo e hype sono numeri che **si spendono**, e il momento della spesa è quello che deve dare soddisfazione | https://www.youtube.com/watch?v=Fy0aCDmgnxg |
| **11** | **River City Girls** — accrediti e interviste sull'interfaccia (WayForward, UI di Nick Bozic) | L'hai nominato tu ed è il caso più vicino a noi per tono: pixel, negozio, mosse comprate al dojo. Non ho trovato una demolizione seria — se ne conosci una, è quella che manca | — |

**Arrivate il 22 settembre** (Bru: «questi sono quelli per cui vale la pena
spendere tempo»), lette per intero e studiate in `docs/menu.md`:

- ✅ **PLAY, le euristiche misurate** → `euristiche-giocabilita-play.md`
- ✅ **Persona 5, l'intervista a Sutou** → `persona5-intervista-interfaccia.md`
- ✅ **FFXVI demolito da Durczok** → `ffxvi-interfaccia-durczok.md`

Resta da procurare: Hodent, Fagerholt & Lorentzon, Cain su griglia contro
lista, e una demolizione seria di River City Girls, che non esiste o non
l'ho trovata.

**Quello che ho già ricavato dalle sintesi, e che NON è ancora una fonte:**

- Fitts: su un menu lineare il tempo per arrivare a una voce dipende da distanza
  e dimensione del bersaglio, quindi le voci lontane costano più delle vicine;
  su un menu radiale il tempo è uniforme. La nostra pausa è lineare e lunga sette.
- Heuristic Evaluation for Playability nasce nel 2004 da Desurvire, Kaplan e
  Toth; PLAY è la versione rifatta con gente di Activision, THQ, Relic e altri.
- Resident Evil originale: **6 caselle** con Chris, **8** con Jill, e le casse
  nelle stanze sicure. È il precedente esatto del nostro zaino a capienza.
- Persona 5: ogni voce del menu è animata, e i dati della GUI stanno già in
  memoria così il menu si apre **senza attesa**. Se è vero, è una regola
  implementativa, non estetica.

Tutto questo è **di seconda mano**. Sulla mappa, due previsioni su quattro
fatte così si sono rivelate sbagliate.

### 1. Le cose su cui poggiano decisioni GIÀ PRESE

**Il carico cognitivo — Sweller.** Dopo che Andersen, «Show or Tell?» e
Faulkner hanno smontato quello che ci avevo costruito sopra, **questo è
l'unico puntello rimasto** di tutto il verdetto sul tutorial
(`docs/tutorial.md` §1, §2). Non ho mai letto una fonte primaria: lo cito da
sintesi. Se dice una cosa diversa, §2 resta senza fondamenta.
- Sweller, *Cognitive Load During Problem Solving: Effects on Learning*,
  Cognitive Science 12(2), 1988 — l'originale
- **Più utile ancora:** Kalyuga, Ayres, Chandler, Sweller, *The Expertise
  Reversal Effect*, Educational Psychologist 38(1), 2003. Dice che
  l'istruzione esplicita aiuta i principianti e **danneggia** gli esperti: è
  esattamente la domanda «il tutorial va saltabile?», e nessuno degli studi
  che ho letto la tocca.

**Kelleher e Pausch — gli Stencils.** *Stencils-based tutorials: design and
evaluation*, CHI 2005. È **l'unico studio che sostiene il blocco del menu**,
e lo conosco solo dalla frase con cui lo descrive Andersen. Il blocco è codice
già spedito (`Menu.principale`, il parametro `spento`). Se Stencils non dice
quello che Andersen riporta, il menu va sbloccato.

**Godot: `mouse_filter` e la propagazione dell'input — ANCORA APERTO.** Bru ha
procurato il riferimento di classe di `InputEvent`: utile (ha già fatto
togliere una guardia ridondante dal codice della Mattanza), ma **non è la
pagina che serviva**. L'affermazione da verificare resta: «un `Button` con
`disabled = true` non emette `pressed` ma si prende lo stesso il click». Ci
credo per averlo visto, non per averlo letto. Se le regole di propagazione
sono diverse c'è forse un rimedio migliore (`mouse_filter = PASS`), e quasi
sicuramente altri punti morti che non ho trovato.
- Manca: **`Control` (riferimento di classe), la proprietà `mouse_filter`** —
  https://docs.godotengine.org/en/stable/classes/class_control.html
- Manca: *Using InputEvent*, il tutorial (diverso dal riferimento di classe) —
  https://docs.godotengine.org/en/stable/tutorials/inputs/inputevent.html

### 2. I numeri che il giocatore SENTE, e che oggi non hanno nessuna fonte

**Le finestre di input: la parata e la raffica.** ~~Serve il sorgente di
Celeste~~ — **preso**, sta qui in `celeste-player.cs` (GitHub non passa dal
proxy che blocca tutto il resto). Le costanti vere di un gioco spedito e
famoso per i controlli stretti:

| costante | valore | cos'è |
|---|---:|---|
| `JumpGraceTime` | **0,10 s** | il *coyote time*: salti ancora per 100 ms dopo essere uscito dalla piattaforma |
| `CeilingVarJumpGrace` | 0,05 s | |
| `WallSpeedRetentionTime` | 0,06 s | |
| `DashTime` | 0,15 s | quanto dura lo scatto |
| `DashCooldown` | 0,20 s | |
| `DashAttackTime` | 0,30 s | quanto resta "offensivo" lo scatto |

**Il metro che mancava:** in Celeste le finestre di *perdono* stanno fra 0,05
e 0,10 s, quelle di *azione* fra 0,15 e 0,35 s. La raffica di Veronica dà
**0,75 s per pugno**: sette volte la finestra di perdono più larga di Celeste.
Il che va benissimo — si clicca col mouse un bersaglio che si sposta, non si
preme un tasto sapendo già dove — ma adesso è un numero con un riferimento
accanto invece di un numero scelto a sentimento.

**Quello che NON c'è**: la costante del buffer d'input vero. Sta in
`VirtualButton` del motore Monocle, che non è nel sorgente pubblicato. Se la
trovi, è l'ultimo pezzo.

**Godot: prestazioni e profiling.** Ho citato «l'editor aggiunge overhead a
ogni fotogramma, profila una build esportata». Tutta la tornata
sull'«ingiocabile» è misurata con `prove/misura.sh`, che gira in headless. Se
quella frase ha eccezioni, i numeri di `Misura.gd` possono essere fuorvianti.
- `docs.godotengine.org` → sezione *Optimization*, e *Overview of debugging
  tools* / il profiler

**Un teardown serio di un tutorial JRPG.** L'avevi offerto e non è mai
arrivato. Sto disegnando la lezione di Veronica contro **quello che immagino
faccia Yu-Gi-Oh GX**, non contro qualcosa di misurato. Va bene qualsiasi cosa
battuta per battuta: GX, Persona, un Final Fantasy.

### 3. Le regole di struttura che applico a ogni commit

**Ousterhout, *A Philosophy of Software Design*.** «Moduli profondi contro
moduli sottili», «un passacarte è una bandiera rossa», «la lunghezza da sola
è raramente una ragione per spezzare». Le uso come **regole** in ogni
decisione strutturale — hanno prodotto `Stati.gd`, `Intenzione.gd`, e la
rimozione di tre passacarte. Non ho mai letto il libro. (Se non si trova:
vanno benissimo le slide del suo talk o del corso di Stanford.)

**Sonar, *Clean as You Code*.** Il cancello strutturale È questa idea
(cricchetto sul codice nuovo). Ho il paper sulla complessità cognitiva, non
questo.

**Connascenza — Page-Jones, o il talk di Jim Weirich.** Citata una volta
sola: la più bassa della lista.

### Quello che NON serve procurare

- **Lo studio del MIT sull'istruzione esplicita e i bambini col giocattolo.**
  È un'analogia fra psicologia dello sviluppo e un'interfaccia di
  combattimento. Anche se è accurato, il transfer non c'è: **lo tolgo invece
  di verificarlo.**
- **Nielsen 1993 e Virzi 1992**, gli originali della regola dei cinque
  utenti: superati per il nostro scopo da Faulkner, che adesso ho per intero.
