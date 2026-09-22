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
| `godot-inputevent-classe.pdf` | *InputEvent*, riferimento di classe di Godot | https://docs.godotengine.org/en/stable/classes/class_inputevent.html |

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

Le tre cose in cima **non sono documenti, sono immagini**: con l'ECG il salto
l'ha fatto la foto, non i paper.

| # | cosa | perché a noi | link |
|---|---|---|---|
| **1** | **Schermate-mappa vere, come immagini.** Hollow Knight, Metroid, Etrian, Dead Cells — quelle che ti piacciono | Devo vedere come segnano *stato* (visitato / intravisto / ignoto), dove mettono i nomi, come si legge il "sei qui". Descritto non basta | https://www.gameuidatabase.com/gameData.php?id=113 |
| **2** | **La tua pianta del complesso**, anche a matita fotografata | Le coordinate me le prendo da quella. Non serve finita: il PNG buono lo infili dopo senza toccare niente | — |
| **3** | **Bertin, *Sémiologie graphique* (1967)** — o la sintesi di Axis Maps, che è bloccata | Le sette variabili visive e quale porta quale tipo di informazione. Noi codifichiamo tre stati con tinta + chiaroscuro: è la scelta giusta o no? Va deciso su una regola, non a occhio | https://www.axismaps.com/guide/visual-variables — https://karlsluis.medium.com/before-tufte-there-was-bertin-63af71ceaa62 |
| **4** | **Figura-sfondo e gerarchia visiva in cartografia** | I cinque principi (leggibilità, contrasto, figura-sfondo, gerarchia, proporzione) con le regole pratiche e le misure minime dei simboli | https://www.esri.com/arcgis-blog/products/arcgis-pro/mapping/primary-design-principles-for-cartography — https://en.wikipedia.org/wiki/Figure-ground_(cartography) |
| **5** | **Krygier & Wood, *Making Maps*** (libero, testo intero) | È il manuale: processo cartografico, generalizzazione, cosa si toglie quando la scala scende | https://colorado.pressbooks.pub/makingmaps/chapter/cartographic-design-process/ |
| **6** | **Dove si mette il nome di una stanza** — posizionamento delle etichette | Oggi i nomi si vedono solo passandoci sopra col mouse. Su una pianta è un problema studiato, non una questione di gusto | https://en.wikipedia.org/wiki/Typography_(cartography) — https://arxiv.org/pdf/2507.22952 |
| **7** | **Game Accessibility Guidelines** — «nessuna informazione essenziale affidata al solo colore» | La nostra mappa **è rossa su nero** e distingue raggiungibile da lontano col chiaro-scuro dello stesso rosso. Il chiaroscuro regge al daltonismo, la tinta no: va verificato, non sperato | https://gameaccessibilityguidelines.com/ensure-no-essential-information-is-conveyed-by-a-fixed-colour-alone/ |
| **8** | **WCAG 1.4.11, contrasto del non-testo** | La regola è 3:1 fra un elemento d'interfaccia e quello che ha accanto. I nostri quadratini spenti su nero non so se ci arrivano | https://www.w3.org/WAI/WCAG21/Understanding/non-text-contrast.html |
| **9** | **Godot: `Control`, `Button`, `StyleBox`** — le pagine di classe | La trappola di ieri (`flat` che butta via lo StyleBox) è **documentata come bug del motore**: issue #45823. Mi serve il testo vero di quelle pagine, non il riassunto | https://docs.godotengine.org/en/stable/classes/class_control.html — https://docs.godotengine.org/en/stable/classes/class_button.html — https://github.com/godotengine/godot/issues/45823 |
| **10** | **Zoom e trascinamento su una tela in Godot** | È uno dei buchi dichiarati in `docs/mappe.md`. Tutto quello che si trova parla di `Camera2D`; noi siamo su `Control`, che si trasforma in un altro modo | https://gist.github.com/thygrrr/8288cabeb5cd25031ce6132c4a886311 — https://www.gdquest.com/tutorial/godot/2d/camera-zoom/ |

**Quello che ho già capito dalle sintesi, e che va confermato sul testo vero**
(lo segno perché di seconda mano mi sono già sbagliata):

- Bertin: *posizione* e *dimensione* sarebbero le uniche due variabili che
  comunicano bene una quantità; per l'**ordine** il chiaroscuro batterebbe la
  tinta; tinta, forma e orientamento servirebbero a raggruppare, non a ordinare.
  Se è vero, i nostri tre stati sono codificati bene (pieno/vuoto = forma,
  chiaro/scuro = ordine) e male allo stesso tempo (rosso/verde per segreta =
  sola tinta).
- Hollow Knight: le zone inesplorate sarebbero **a contorno**, le esplorate
  piene, e le ignote assenti del tutto — cioè i nostri stessi tre stati. Ma la
  mappa lì è *diegetica*: la compri da Cornifer e si aggiorna solo sulle panchine.
- Etrian Odyssey: il passo del giocatore colora la casella, e le icone (porte,
  passaggi nascosti, casse) le mette il giocatore a mano, con un limite per piano.
- WCAG 1.4.11: 3:1, e vale **anche per gli stati** di un elemento, non solo per
  l'elemento a riposo.
- Godot `mouse_filter`: `STOP` consuma, `PASS` consuma *e* passa al genitore,
  `IGNORE` scarta. Per far funzionare un bottone, tutto ciò che gli sta sopra
  nell'albero dovrebbe essere su `IGNORE`.

**Una nota sul proxy**, perché è cambiato: ieri GitHub passava (è così che ho
letto il sorgente di Celeste). Oggi **WebFetch è bloccato su tutto** — ho
provato anche `anthropic.com` — e `curl` non esce proprio. Resta solo la
ricerca, che dà sintesi.

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
