# Gli ambienti — disegnare in pixel, costruire le zone, nascondere i segreti

> **Quarto documento di studio**, dopo `godot.md`, `mestiere.md` e `lezioni.md` (che ha già Zelda,
> Super Metroid e le regole di Romero: qui non si ripetono). Raccolto il **28 novembre 2026**.
> Bru: *«Dai ultimo sforzo di ricerca per tecniche di disegno pixel e ambientazioni zone segrete
> e altro».*
>
> Stesso limite di `lezioni.md`: la rete di questa sessione non apre i siti, quindi le pagine sono
> lette attraverso i riassunti delle ricerche. Ogni affermazione ha la fonte in fondo; dove la
> fonte è debole (un forum, una pagina di vendita) è scritto.
>
> Lo scopo non è un manuale: è **cosa cambiare nelle nostre scene** (Parte 4), dopo le critiche di
> Bru alla scena dell'albero (*«la strada lineare, troppo piccola, poca fantasia, grotta visibile,
> tutto troppo lineare e prevedibile»*) e dopo la prova a griglia bocciata (*«era meglio prima»*).

---

| Parte | Cosa |
| --- | --- |
| **1 · Disegnare l'ambiente** | alberi, terra, oggetti, colori, rupi, rocce, acqua, vita |
| **2 · Costruire una zona** | punti di riferimento, guidare senza dire, percorsi, raccontare col posto |
| **3 · Le zone segrete** | insegnare a cercare, quanti e dove, l'indizio, nascondere con la camera, il mistero |
| **4 · Carnivalz** | le regole che adottiamo, la scena dell'albero rifatta, le scene dopo |

---

## In breve: le dieci cose

1. **Gli alberi non si mettono in fila.** Le file di alberi fanno sembrare una mappa meno
   naturale; mai più di due alberi grandi vicini; più specie e più misure. La prova a griglia è
   caduta anche per questo.
2. **Prima la sagoma, poi i grappoli, poi la luce; il dettaglio per ultimo.**
3. **La terra deve respirare.** La ripetizione si nasconde in una trama costante, si lascia spazio
   vuoto, qualche fiore qua e là. Due trame fitte una accanto all'altra stancano l'occhio.
4. **Le cose si staccano dal terreno** per luminosità e saturazione; il contorno scuro va sulle
   cose, non sul terreno.
5. **Una luce sola, da un angolo.** Ombre fredde e luci calde, spostando la tinta di 15-25 gradi
   lungo la rampa.
6. **Un'altezza si legge solo con luce e materiale diversi.** Una striscia grigia fra due prati
   uguali è un sentiero, non una rupe.
7. **Ogni zona ha un punto di riferimento** che si vede da lontano e tira verso di sé.
8. **Il segreto si insegna presto e si mostra, non si spiega.** Si fa capire che lì c'è qualcosa,
   non come ci si arriva.
9. **Al massimo un segreto per schermata,** sempre con lo stesso "linguaggio". In Zelda le pareti
   che si rompono sono sempre dello stesso tipo.
10. **La Guida non deve spiegare tutto.** Un compagno che parla troppo uccide la curiosità.

---

# Parte 1 · Disegnare l'ambiente

## Gli alberi e il fogliame

Il metodo di Raymond Schlitter (Slynyrd, *Pixelblog 44*) costruisce l'albero visto dall'alto a
**moduli**, ognuno col suo posto. Prima si mettono i rami piatti, poi si ombreggia secondo la luce
scelta, definendo **rami chiari, medi e scuri**: tre toni per ramo.

La sagoma viene prima di tutto:
- la chioma come **cerchi di diametri diversi** messi insieme;
- poi qualche pixel aggiunto lungo il bordo, per un contorno ruvido e naturale;
- il dettaglio resta sciolto, *«just enough to give the impression of a leafy texture»*: l'occhio
  completa da solo.

Alcuni grappoli gettano l'ombra su quelli più in basso accanto a loro.

Da *Pixelblog 21*: con forme semplici e simmetria, una massa di bosco fitto si fa anche con un solo
pezzo di base. Questo non contraddice la regola 1: un solo pezzo va bene per il **muro di chiome
lontano**. Gli alberi che stanno dove si cammina devono essere vari e non in fila.

## La terra

*Pixelblog 20*: la ripetizione fa parte del fascino, ma bisogna *«hide the patterns within
consistent non-distracting textures»*.
- Un prato fatto con una sola casella diventa monotono, per quanto bella sia la casella.
- Varianti coi fiori, ogni tanto.
- Spazio vuoto, che riduce il rumore e *«lets the environment breathe»*.
- Le giunte si nascondono coi grappoli che scavalcano il bordo della casella.

Due trame fitte una accanto all'altra stancano l'occhio: lo spazio vuoto vale. I sentieri lasciati
in parte ricoperti dall'erba sembrano meno finti (blog di RPG Maker, *Mapping Forests*).

## Le cose contro il terreno

- La guida di stile LPC chiede che gli oggetti **non si confondano col terreno**: diversi per
  colore, luminosità e saturazione.
- Il contorno:
  - il *sel-out* è un contorno fatto coi colori stessi dell'oggetto, un gradino più scuri;
  - dove il contorno cadrebbe su una superficie dello stesso colore, si può togliere (Lospec);
  - gli oggetti col contorno quasi nero si staccano meglio su un terreno di colore simile;
  - un talk su Pixel Perfect (pixel art in un gioco 3D) mostra che contornare tutto nella scena
    distrugge la leggibilità.
- *Secret of Mana* non usa il nero: contorna con un colore locale più scuro.
- Troppo contrasto nel piccolo indebolisce la forma grande. Sui pezzi piccoli i grappoli di colore
  rendono il dettaglio meglio del retino (*dithering*).
- I grappoli importanti non devono toccarsi, se non per gli angoli: insieme fanno forme irregolari
  e rumore. Le forme chiave si ripetono uguali, per coerenza.

## I colori

- La **rampa dritta**, che cambia solo la luminosità, è l'errore tipico dei principianti. Lungo la
  rampa si sposta anche la tinta.
- La convenzione più comune è **ombre verso il blu-viola e luci verso il giallo**. Con una luce
  fredda si fa il contrario.
- **15-25 gradi** di spostamento sembrano naturali; da 30 in su l'effetto è stilizzato.
- I materiali morbidi vogliono meno spostamento di quelli duri.
- La saturazione spesso è massima a metà rampa.
- Questi numeri sono regole pratiche, non studi.

## La luce: niente cuscino, niente bande

- Le **bande** (*banding*) nascono quando due strisce di colori diversi finiscono allineate sullo
  stesso asse.
- L'ombra **a cuscino** è la forma peggiore delle bande: strisce concentriche che seguono il
  contorno invece della luce. Il rimedio è scegliere una direzione della luce e tenerla.
- In pixel art si preferiscono passaggi netti fra luce e ombra.

## Rupi e altezze

- Schlitter (*Pixelblog 3*): **la profondità viene quasi tutta dalla luce**.
  - Piccole sporgenze e cenge che prendono la luce in modo diverso aiutano.
  - Una luce forte da un angolo dà più drammaticità.
  - La regolarità conta più del realismo: angoli puliti.
- Il problema dell'altezza, detto bene (pagina del set *Verdant 02*): una striscia grigia fra due
  prati identici non è una rupe, è un sentiero. La parete deve sembrare alta, non solo un confine.
- Dai commenti a un set di rupi: le scale si leggono male guardandole dall'alto della rupe.
- Blog di RPG Maker sulle rupi:
  - le ombre squadrate automatiche non vanno sulle rupi arrotondate;
  - non ammucchiare troppe cose uguali in un punto;
  - niente file o quadrati di decorazioni.

## Le rocce

- I massi sono tondi, ma con **facce piatte o spigolose**; la luce si mette senza rigidità
  (tutorial su itch).
- Con la luce a 45 gradi in alto a sinistra, i lati ricevono luce come la cima, e le fessure
  rivolte al sole sono più chiare.
- Le crepe: si buttano giù scure, poi si ombreggia dentro o si sfumano nella roccia.
- Il muschio sta sopra e fra le rocce. Il bordo della roccia contro il muschio va schiarito, così il
  muschio si stacca.

## L'acqua

Non ho trovato un vero tutorial, solo set di caselle (fonti deboli). Due cose utili:
- **sfasare l'animazione della riva** di un fotogramma ogni due caselle, perché la costa non pulsi
  tutta insieme;
- **acqua bassa e acqua alta** in due toni; più fotogrammi rendono l'animazione più morbida.

## La vita

Fonti deboli (guide di strumenti, commenti su itch), ma concordi:
- movimenti **piccoli e in ciclo**: l'acqua che luccica, l'erba e le foglie che ondeggiano, le
  lucciole, la polvere, gli uccelli sullo sfondo;
- i movimenti grandi e veloci impastano i bordi netti che fanno sembrare pixel la pixel art.

---

# Parte 2 · Costruire una zona

## Il punto di riferimento

Il punto di riferimento (*weenie*, dall'aneddoto di Walt Disney; il castello di Disneyland è
l'esempio classico) **tira il giocatore verso una zona e lo orienta**. In *God of War* è la cima
della montagna. *Breath of the Wild* e *Tears of the Kingdom* usano le montagne per **nascondere la
vista** e i posti alti per **concentrare l'esplorazione**.

*The Level Design Book* tratta la composizione come la disposizione di tutto nello spazio:
- punti di riferimento, vedute, modi di avvicinarsi;
- però **contesta le "linee guida"** come strumento vero;
- e considera un errore curare un'inquadratura precisa.

Un corso universitario aggiunge che le linee guida **spingono, non obbligano**.

Per noi la telecamera è fissa dall'alto ma segue Lei, quindi le inquadrature non si compongono una
per una. Contano i punti di riferimento e le forme grandi.

## Guidare senza dire

Unity mette gli aiuti su una scala, dal più sottile al più evidente: una crepa leggera in un muro
la nota qualcuno, una fila di oggetti da raccogliere la notano quasi tutti. Gli strumenti:
- **la luce** tira l'occhio: un fascio di luce su uno scrigno, una porta che brilla più in là;
- **il contrasto**: l'occhio va dove colore, forma, luce o movimento cambiano. Una porta chiara in
  un paesaggio scuro non si perde;
- **il colore come lingua**: se tutto ciò che si può usare ha lo stesso colore, il giocatore lo
  impara.

Un recensore sui forum di RPG Maker: *«a clear path is always more important than making something
pretty»*.
La strada principale si deve leggere sempre; il mistero sta ai lati.

## I percorsi

- **Un bosco si progetta come un dungeon**, almeno nella pianta (blog di RPG Maker).
- *A Link to the Past*, il Mondo della Luce (serie *Overworld Overload*):
  - è un mondo a labirinto;
  - molte strade scoperte dopo sono **scorciatoie verso posti già raggiungibili** per una via più
    lunga;
  - i cancelli sono pochi, per lasciare libertà;
  - il mondo invoglia a esplorare e insieme accompagna da una zona all'altra.
- *Link's Awakening*: in teoria si va dappertutto fin dall'inizio. L'isola è una **scatola dei
  giochi** dove qualcosa può essere nascosto ovunque.
- **Il kishōtenketsu** di Nintendo (Koichi Hayashida, dai fumetti), in quattro tempi:
  1. presentare una cosa dove sbagliare non costa;
  2. svilupparla;
  3. il colpo di scena, dove il modo solito non funziona più;
  4. la chiusa.

## Raccontare col posto

Harvey Smith e Matthias Worch, GDC 2010, *«What Happened Here?»*. Raccontare con l'ambiente
significa disporre lo spazio di gioco in modo che le sue cose si leggano come un insieme che ha un
senso.
- Gli strumenti:
  - gli oggetti e come sono messi;
  - gli eventi;
  - le superfici, la luce, la composizione;
  - i sistemi del gioco che reagiscono.
- Il giocatore ricostruisce da solo la storia, e questo lo lega al gioco. Non tutti la ricostruiscono
  uguale, e va bene.

*Hyper Light Drifter* lo porta all'estremo: quasi niente testo.
- Un titano mezzo affondato in una laguna, con la testa e le dita che fanno da isole.
- Corpi giganti fra le rovine ricoperte di verde.

La critica avverte che a volte è troppo evocativo: non spiega né le meccaniche né la storia.

---

# Parte 3 · Le zone segrete

## Insegnare che i segreti esistono

- *Rayman Legends*: i primi livelli fanno capire che esistono strade nascoste, così il giocatore
  impara a cercarle prima che i segreti diventino difficili.
- *Specter of Torment* (Yacht Club), tre regole:
  - le strade segrete **vanno in un'altra direzione** rispetto a quella principale;
  - sono **più difficili** da raggiungere;
  - molte stanze cieche stanno dietro **muri che si rompono**, e così il giocatore si abitua a
    controllarli sempre.
- *King Knight*: sulla mappa del mondo le strade normali sono verdi, quelle segrete rosse.

## Quanti, e dove

- *A Link to the Past* (Anatomy of Games):
  - la regola non detta è **una porta nascosta al massimo per schermata**. Non tutte ne hanno una,
    nessuna ne ha due;
  - le cose più rare (i cuori nascosti, i negozi più convenienti) si mostrano solo a chi guarda;
  - le pareti che si fanno saltare sono **solo un tipo di casella**: la parete piatta della
    montagna, girata come la porta di un negozio. È un linguaggio coerente.
- Miyamoto nel 1992:
  - i muri normali fanno *«ting»*, quelli che si rompono suonano vuoti: un indizio col suono;
  - ammise che gli dava fastidio che esplodessero solo i muri crepati.
- Nel primo *Zelda*, secondo un'analisi di un fan (fonte debole), in una schermata col segreto
  c'è **un cespuglio che non è uguale agli altri**.
- GMTK su *Animal Well*: l'autore sta attento a **quante cose sta facendo penzolare** davanti al
  giocatore nello stesso momento. Uno dei suoi trucchi è un muro che si rompe **solo da un lato**:
  una scorciatoia che si scopre da dietro.
- Uno studio con 254 giocatori (Gómez-Maureira e altri, 2021) ha provato quattro schemi di livello
  pensati per la curiosità. **Funzionano**, ma meno quando il giocatore ha **un obiettivo
  esplicito** o è pagato per arrivarci. Quindi i segreti rendono di più nei momenti calmi, quando
  l'obiettivo non incalza.

## L'indizio

- Da un forum di *Doom*: **far capire che c'è qualcosa, non come ci si arriva.**
- Indizi sottili:
  - **i graffi per terra** per una strada nascosta;
  - una scala o una porta a senso unico per una scorciatoia.
- Le crepe nei muri sono un invito a provare (TechRadar). Il lavoro del designer è nascondere,
  restando ovvio per chi osserva.
- Dietro una crepa non c'è sempre lo stesso premio, quindi non sai cosa troverai.

## Nascondere con la camera fissa

- *Tunic* (blog di Unity):
  - la **vista senza prospettiva** è il cuore del trucco. Con una telecamera in prospettiva, la
    strada nascosta dietro una cascata si vedrebbe subito;
  - i segreti stanno fuori vista finché non ci torni **da un'altra direzione**;
  - Andrew Shouldice parla di *«content for no one»*: segreti che pochi troveranno, apposta;
  - la critica: a volte la camera fissa copre troppo, e non si capisce quanto è alto un ripiano.
- *Hyper Light Drifter*:
  - passaggi nascosti nei muri;
  - **sentieri fra gli alberi dove non pensavi di passare**;
  - piattaforme che sembrano irraggiungibili;
  - passaggi segreti nel nero fra due muri;
  - Alex Preston voleva essere sottile e implicito, perché spiegare rovina il mistero.
  - Anche qui la critica nota qualche passo falso.

**La nostra camera è dello stesso tipo:** fissa dall'alto, senza prospettiva, coi pezzi messi in
ordine di piede insieme a Lei. Quello che sta dietro una chioma o un cespuglio si nasconde da solo.
È esattamente l'idea di Bru della grotta dietro l'arbusto.

## Mistero e meraviglia

Rune Skovbo Johansen (*Designing for a Sense of Mystery and Wonder*):
- il mistero nasce dall'**esplorazione**, non dalla storia;
- **curiosità dall'esito sconosciuto**: non sapere cosa si trova;
- fra i tipi di curiosità e i tipi di premio serve un rapporto **molti a molti**;
- **sconosciuto non vuol dire casuale**;
- i santuari di *Breath of the Wild* hanno sempre la stessa entrata, quindi sai già cosa c'è
  dentro e il mistero cala. *A Link to the Past* sembra più misterioso.

Game Maker's Toolkit (*The Secret to Designing Mysterious Games*):
- **la porta chiusa** è il mistero per eccellenza: ti chiedi cosa c'è dietro e come aprirla;
- non bisogna metterne troppe insieme;
- **un compagno chiacchierone che spiega tutto** rovina la curiosità: il confronto è fra il
  silenzio di *The Talos Principle* e il seguito, più parlato.

---

# Parte 4 · Carnivalz

## 4.1 Le regole di disegno: quelle che abbiamo già, quelle da prendere

**Già fatte:**
- le rampe spostano la tinta:
  - la `CHIOMA` va dal viola scuro (47, 41, 67) al giallo-verde (199, 220, 138);
  - il `TRONCO` va dal blu-viola al marrone caldo;
- una luce sola, da in alto a sinistra;
- il contorno scuro sulle cose, mai sul terreno;
- la vita: il vento sui fiori e sul prato, le ombre delle nuvole, il sole fra le foglie.

**Da prendere:**
1. **Alberi mai in fila e mai tutti uguali.**
   - Due o tre specie per scena, di misure diverse; al massimo due alberi grandi vicini.
   - I muri di bosco come masse irregolari.
   - È il motivo per cui la griglia non andava: *«lined up trees always make a map look less
     natural»*.
2. **La terra si calma vicino alle cose importanti.** La radura di prima, più ricca, è piaciuta più
   della prova calma: la ricchezza resta. Vicino a quello che deve attirare l'occhio (il cespuglio
   della grotta, il posto della Guida), la terra si fa più quieta.
3. **Le rupi.** La nostra `rupe` ha già parete, orlo d'erba e ombra. Mancano le piccole cenge e
   sporgenze che prendono la luce, e un pianerottolo leggibile in cima alle scale.
4. **Le rocce** con le facce piatte, le crepe ombreggiate dentro e il bordo schiarito contro il
   muschio.
5. **La vita che manca:**
   - le farfalle sui fiori;
   - gli uccellini che volano via quando Lei si avvicina (è anche un indizio: il movimento tira
     l'occhio);
   - le lucciole vicino alla grotta;
   - le foglie che cadono dal grande albero.

## 4.2 La scena dell'albero, rifatta con quello che abbiamo imparato

Le critiche di Bru, una per una:

| Critica | Cosa insegna la ricerca | Cosa facciamo |
| --- | --- | --- |
| la strada lineare | i percorsi a labirinto con scorciatoie (*A Link to the Past*); un bosco come un dungeon | due giri attorno all'albero che si riuniscono a nord: lungo la pozza sui sassi del guado, o fra le radici; più un vicolo cieco col premio (un ripiano accanto alla cascatella) |
| troppo piccola | il punto di riferimento si vede da lontano | la mappa più grande; il grande albero si vede già dal ruscello, in cima allo schermo, e la strada ci gira attorno invece di andarci dritta |
| poca fantasia | raccontare col posto (*«What Happened Here?»*) | le tracce del goblin possessivo che trascina il suo bottino nella grotta |
| la grotta visibile | la camera fissa nasconde da sola (*Tunic*, *Hyper Light Drifter*) | la bocca della grotta dietro un cespuglio fitto, disegnato davanti a lei; il varco è di fianco |
| prevedibile | il kishōtenketsu; curiosità dall'esito sconosciuto | presentare (i coniglietti sotto l'albero), sviluppare (lo slime che li guarda), il colpo di scena (se parli forte lo slime ti nota: c'è già nella storia), la chiusa (dopo lo scontro, la calma: è il momento della curiosità) |

**Gli indizi della grotta**, dal più sottile al più evidente: far capire che c'è qualcosa, non come
arrivarci.
1. **Il cespuglio diverso dagli altri**: più scuro, più fitto, un'altra specie (il primo *Zelda*).
2. **I graffi nell'erba** che ci vanno dietro: il goblin possessivo trascina lì le sue cose. È
   insieme l'indizio della strada nascosta e la storia del posto.
3. **Un coniglio che scappa dietro il cespuglio e sparisce**: il movimento tira l'occhio.
4. **Un luccichio fra le foglie**: la pietra che il goblin custodisce (`tut_pietra_presa`). La luce
   tira l'occhio.

Le regole intorno:
- **Un solo segreto per schermata.**
- **La Guida tace.** Non dice "c'è una grotta dietro il cespuglio"; al massimo commenta dopo.
- **Il segreto si trova dopo lo scontro con lo slime,** quando l'obiettivo non incalza (lo studio
  sulla curiosità).

Il gioco è già pronto per questo: l'entrata nella caverna chiede `tut_caverna_vista`. Il flag si
accende quando Lei va dietro il cespuglio e vede la bocca; da lì compare *«Entra nella piccola
caverna»*.

## 4.3 Le scene dopo, una riga ciascuna

- **Il masso gigante**:
  - si vede già dall'uscita nord dell'albero;
  - le fiale sulla piattaforma si vedono prima di poterle prendere, e la scaletta è la strada.
- **Il bivio**: due direzioni leggibili, ognuna col suo punto di riferimento. L'arco sul
  promontorio in alto, i luccichii delle pozze a sinistra.
- **Le pozze**: una fila di sassi sott'acqua, che si vede solo dalle increspature, porta a un
  isolotto. È il segreto della zona.
- **La tartaruga gigante**: si vede da lontano, come il titano di *Hyper Light Drifter*: punto di
  riferimento e storia insieme.
- **Il promontorio**: la veduta. Dalla cima si vede la zona corrotta, così il posto stesso mostra
  la meta successiva.
- **Verso le urla**: la corruzione cresce a poco a poco, dal prato al secco al viola. La storia la
  racconta il posto.
- **La siepe di rovi**: più avanti si apre dall'altro lato e diventa la scorciatoia per tornare al
  bivio (una scorciatoia verso un posto noto, come in *A Link to the Past*; aperta da un solo lato,
  come in *Animal Well*).

---

## Fonti

**Disegnare l'ambiente**
- [Pixelblog 44 — Top Down Trees — Raymond Schlitter](https://www.slynyrd.com/blog/2023/5/22/pixelblog-44-top-down-trees)
- [Pixelblog 21 — Top Down Objects — Raymond Schlitter](https://www.slynyrd.com/blog/2019/9/18/pixelblog-21-top-down-objects)
- [Pixelblog 20 — Top Down Tiles — Raymond Schlitter](https://www.slynyrd.com/blog/2019/8/27/pixelblog-20-top-down-tiles)
- [Pixelblog 43 — Top Down Tiles Part 2 — Raymond Schlitter](https://www.slynyrd.com/blog/2023/3/26/pixelblog-43-top-down-tiles-part-2)
- [Pixelblog 3 — Graphical Projection — Raymond Schlitter](https://www.slynyrd.com/blog/2018/3/14/pixelblog-3-graphical-projections-1)
- [Pixelblog 15 — Plant Life — Raymond Schlitter](https://www.slynyrd.com/blog/2019/3/7/pixelblog-15-plant-life)
- [LPC Style Guide — OpenGameArt](https://lpc.opengameart.org/static/LPC-Style-Guide/build/styleguide.html)
- [New less Zelda-like trees, and a tutorial — IndieDB](https://indiedb.com/news/new-less-zelda-like-trees-and-tutorial-on-how-i-did-them)
- [Pixel Art Outlines, Part 2: Using Color — Lospec](https://lospec.com/articles/pixel-art-outlines-part-2-using-color)
- [Pixel tutorial: selective outlines — itch.io](https://itch.io/t/2422252/pixel-tutorial-selective-outlines)
- [Drawing the Line on 3D Pixel Art — Pixel Perfect (trascrizione)](https://sozai.app/transcript/drawing-the-line-on-3d-pixel-art-pixel-perfect-transcript)
- [Pixel Art Palette Generator: Hue-Shifted Ramps — Ziva](https://ziva.sh/tools/pixel-art-palette-generator)
- [Color Palettes — GameDev.net](https://www.gamedev.net/articles/visual-arts/color-palettes-r4964/)
- [Hue shifting — PixelJoint (forum)](https://pixeljoint.com/forum/forum_posts.asp?TID=15138)
- [How to start making pixel art #6 — Pixel Grimoire](https://medium.com/pixel-grimoire/how-to-start-making-pixel-art-6-a74f562a4056)
- [How to start making pixel art #4 — Pixel Grimoire](https://medium.com/pixel-grimoire/how-to-start-making-pixel-art-4-f57f51dcfa02)
- [Banding e pillow shading (cita *Pixel Logic* di Michael Azzi) — TU Delft](https://repository.tudelft.nl/file/File_65d43acd-9779-4eab-999b-9bcd4f0a96a9)
- [Verdant 02 — Elevation Tileset — itch.io](https://csaf.itch.io/verdant-02-elevation)
- [A-mazing Tileset #4 — Cliffs — itch.io](https://pixiatrist.itch.io/amazingtileset4)
- [Tips and Tricks: Mapping Cliffs — RPG Maker](https://rpgmakerweb.com/blog/tips-and-tricks-mapping-cliffs)
- [Mapping Forests — RPG Maker](https://www.rpgmakerweb.com/blog/mapping-forests)
- [Map making, a set of guidelines (forest) — rpgmaker.net](https://www.rpgmaker.net/tutorials/597)
- [Tips on making good forests — rpgmaker.net (forum)](https://rpgmaker.net/forums/topics/7215/?p=2)
- [Pixel tutorial: boulders — itch.io](https://itch.io/t/1467381/pixel-tutorial-boulders)
- [Pixel tutorial: desert rock — itch.io](https://itch.io/t/2094789/pixel-tutorial-desert-rock)
- [Drawing terrain — NESdev](https://nesdev.org/wiki/Drawing_terrain)
- [Caves — GameDev.net](https://www.gamedev.net/blogs/entry/2259033-caves)
- [Animated water tiles — OpenGameArt](https://opengameart.org/content/animated-water-tiles-0)
- [Animated ocean tileset — OpenGameArt](https://opengameart.org/content/animated-ocean-tileset)
- [From Trees to Forests: drawing greenery — Clip Studio Tips](https://tips.clip-studio.com/en-us/articles/7598)
- [Animare la pixel art: i movimenti in ciclo — Kling (guida di uno strumento, fonte debole)](https://kling.ai/topics/animate-pixel-art-ai)
- [Spotlight 12: background animations — itch.io (devlog, fonte debole)](https://itch.io/devlog/616896/spotlight-12-background-animations.amp)

**Costruire una zona**
- [Level design basics: Guiding players without telling them — Unity](https://unity.com/blog/level-design-basics)
- [Composition — The Level Design Book](https://book.leveldesignbook.com/process/blockout/massing/composition)
- [Level Design II — Carthage College](https://sites.google.com/carthage.edu/game-design/lessons/level-design-ii)
- [Tears of the Kingdom succeeds because everything is a mystery — The Escapist](https://escapistmagazine.com/tears-of-the-kingdom-succeeds-because-everything-is-a-mystery)
- [Overworld Overload, part 2 — Game Developer](https://www.gamedeveloper.com/disciplines/overworld-overload-an-analysis-of-link-to-the-past-s-light-world-part-2)
- [Overworld Overload, part 3 — Game Developer](https://www.gamedeveloper.com/design/overworld-overload-an-analysis-of-link-to-the-past-s-light-world-part-3)
- [Why Zelda: Link's Awakening is literally my dream game — Nintendo Life](https://www.nintendolife.com/news/2021/03/feature_why_zelda_linkrs_awakening_is_literally_my_dream_game)
- [The Hidden Structure of the Overworld of Link's Awakening — Set Side B](https://setsideb.com/?p=133)
- [Nintendo's level design secrets in four steps — MCV](https://www.mcvuk.com/development/video-nintendos-level-design-secrets-in-four-steps)
- [What Happened Here? Environmental Storytelling — GDC Vault](https://www.gdcvault.com/play/1012647)
- [Harvey Smith on environmental storytelling — Nieman Storyboard](https://niemanstoryboard.org/2011/01/14/harvey-smith-on-environmental-storytelling-and-embedding-narrative/)
- [Opened World: Fragility — Haywire](https://haywiremag.com/columns/opened-world-fragility/)
- [Hyper Light Drifter — Slant Magazine](https://www.slantmagazine.com/games/hyper-light-drifter)
- [Behind the scenes of Hyper Light Drifter's wordless world — Kill Screen](https://killscreen.com/building-wordless-world-hyper-light-drifter)
- [Hyper Light Drifter: «fantastic combat but all show no tell» — Giant Bomb (recensione di un utente)](https://giantbomb.com/user-reviews/uid/6072/fantastic-combat-but-all-show-no-tell)

**Le zone segrete**
- [Secrets design in Rayman Legends — Game Developer](https://gamedeveloper.com/design/secrets-design-in-rayman-legends)
- [Specter of Torment level design deep dive 5/5 — Yacht Club Games](https://www.yachtclubgames.com/blog/specter-of-torment-level-design-deep-dive-5-of-5)
- [King Knight's map building: secret paths — Game Developer](https://gamedeveloper.com/design/king-knight-s-map-building-secret-paths)
- [Anatomy of Games su A Link to the Past (archivio)](https://www.quaddicted.com/webarchive/www.anatomyofgames.com_20170315/index.html%3Fp=5791.html)
- [L'intervista a Miyamoto del 1992 su A Link to the Past — My Nintendo News](https://mynintendonews.com/2016/12/21/a-fully-translated-1992-link-to-the-past-interview-with-miyamoto-has-surfaced/)
- [Gaming and the lost art of keeping a secret — TechRadar](https://www.techradar.com/news/gaming/gaming-and-the-lost-art-of-keeping-a-secret-1329677)
- [Legend of Zelda: i segreti dei cespugli (analisi di un fan)](https://jeah.net/~obakesan/ld1/Secrets.html)
- [Good ways to make secrets — Doomworld (forum)](https://test.doomworld.com/forum/topic/111352-good-ways-to-make-secrets)
- [The Art of Level Design: Patterns and Checkpoints — Parsers](https://parsers.vc/news/241006-the-art-of-level-design--patterns-and)
- [Smoke, mirrors and scrolling textures: behind the scenes of Tunic — Unity](https://blog.unity.com/games/smoke-mirrors-and-scrolling-textures-behind-the-scenes-of-tunic)
- [Designing content for "no one" — intervista sul team di Tunic, Game Developer](https://www.gamedeveloper.com/design/designing-content-for-no-one-an-interview-with-the-team-behind-tunic)
- [Tunic review — Wireframe](https://wireframe.raspberrypi.com/articles/tunic-review-sly-fox-adventure-is-more-than-just-a-zelda-bootleg)
- [Hyper Light Drifter beginner's tips — Twinfinite](https://twinfinite.net/ps4/hyper-light-drifter-beginners-tips/3/)
- [Hyper Light Drifter — TV Tropes](https://tvtropes.org/pmwiki/pmwiki.php/VideoGame/HyperlightDrifter)
- [Playing the opening hours of Hyper Light Drifter's mysterious world — Game Informer](https://gameinformer.com/games/hyper_light_drifter/b/pc/archive/2016/03/22/playing-the-opening-hours-of-hyper-light-drifter%27s-mysterious-world)
- [Hyper Light Drifter — PopMatters](https://www.popmatters.com/hyper-light-drifter-2495428736.html)
- [Designing for a sense of mystery and wonder — Rune Skovbo Johansen](https://blog.runevision.com/2021/02/designing-for-sense-of-mystery-and.html)
- [The Secret to Designing Mysterious Games — Game Maker's Toolkit](https://gmtk.substack.com/p/the-secret-to-designing-mysterious)
- [Level Design Patterns That Invoke Curiosity-Driven Exploration — Gómez-Maureira e altri, 2021](https://research.tudelft.nl/en/publications/level-design-patterns-that-invoke-curiosity-driven-exploration-an)

---

*Gli ambienti · raccolto il 28 novembre 2026 · ramo `claude/inizio-progetto-dya2lr`*
