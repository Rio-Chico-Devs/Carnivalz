# Ricerca: presentazione, transizioni, dialoghi, negozio

Ricerca sola, niente codice scritto. Ogni sezione dice **cosa dicono le fonti**, poi **come sta
messo Carnivalz adesso**, poi **cosa cambierei**. In fondo c'è la classifica per resa/costo.

Le fonti sono in fondo. Dove un dato è un numero preciso (millisecondi, curve) viene da
documentazione di prodotto (Material Design, Nielsen Norman Group, Ren'Py); dove è un principio
viene da pratica documentata (film editing, postmortem di sviluppatori, database di UI).

---

## 1. Transizioni: hanno una grammatica, e la stiamo ignorando

Il montaggio cinematografico usa tre transizioni e ognuna **vuol dire una cosa precisa**:

| Transizione | Cosa significa | Quando |
|---|---|---|
| **Taglio** (cut) | stesso momento, punto di vista diverso | ci si sposta dentro la stessa scena |
| **Dissolvenza incrociata** | è passato del tempo | ellissi, ricordi, sogni |
| **Fade a nero** | un pensiero narrativo è **finito** | fine capitolo, morte, stacco tra due storie |

Il fade a nero «fornisce una pausa visiva, una lavagna pulita tra due scene, mettendo
intenzionalmente distanza tra loro». È la transizione **più forte** che esiste.

**Come sta messo Carnivalz.** `Transizioni.vai()` fa il fade a nero per **ogni** cambio di
schermata: 38 chiamate, tutte uguali. Aprire la mappa della zona, entrare in un negozio, tornare
al Vuoto — tutto viene raccontato come «fine di un capitolo». Grammaticalmente è come mettere un
punto fermo in mezzo a una frase. E costa 0.35s + 0.35s = **0.7 secondi ogni volta**, il che è
molto quando lo fai venti volte in una sessione.

**Cosa cambierei.** Tre transizioni invece di una, scelte da chi chiama:

- `Transizioni.taglio(scena)` — mappa zona, negozio, compendio, pausa. Istantanea o quasi
  (~120ms di velo leggero, mai nero pieno). Sono sguardi, non stacchi
- `Transizioni.dissolvi(scena)` — passaggio tra due luoghi dello stesso squarcio, tempo che passa
- `Transizioni.vai(scena)` — **resta il fade a nero**, ma solo dove serve davvero: entrare e
  uscire da uno squarcio, morire, finire una campagna, la carta del titolo di un luogo nuovo

Il fade a nero usato di rado torna a pesare. Adesso non pesa più niente perché è ovunque.

---

## 2. Durate e curve: i numeri esistono, e li stiamo sbagliando

**Durate.** Material Design: 150–200ms su desktop per movimenti piccoli, ~300ms per transizioni
standard, 225ms per elementi che entrano senza spostare altro. NN/g aggiunge una cosa utile: la
durata **scala con la dimensione e la distanza** — un elemento piccolo che si muove poco deve
essere più rapido di un pannello grande che attraversa lo schermo. E la soglia pratica: «se i
tester aspettano che i menu finiscano di scorrere, la durata va tagliata».

**Curve.** Questa è la parte che ci manca del tutto. Material definisce quattro curve e dice
esattamente quando usarle:

| Curva | Godot | Per cosa |
|---|---|---|
| **Decelerazione** `cubic-bezier(0, 0, .2, 1)` | `EASE_OUT` | qualcosa che **entra** e si deve posare |
| **Accelerazione** `cubic-bezier(.4, 0, 1, 1)` | `EASE_IN` | qualcosa che **esce per sempre** |
| **Standard** | `EASE_IN_OUT` | qualcosa che si muove **dentro** lo schermo |
| **Sharp** | `EASE_IN_OUT` rapida | esce ma **tornerà** dallo stesso punto |

E la regola che vale più di tutte, dai testi sul game feel: **mai lineare**. «Niente in natura si
muove a velocità costante: il movimento lineare sembra meccanico e morto.» Per movimenti bruschi
esponenziali, per movimenti morbidi quadratici.

**Come sta messo Carnivalz.** Ogni singolo tween del progetto — il velo delle transizioni, la
macchina da scrivere, il battito del triangolino, il lampeggio sui colpi, i numeri volanti, la
dissolvenza dei ritratti — è **lineare**, perché non chiamiamo mai `set_ease()` né `set_trans()`.
Sono 19 `create_tween()` in tutto il progetto e **nessuno** chiama quei due metodi: l'ho
verificato con un grep prima di scriverlo. È letteralmente la cosa più economica che si possa
migliorare in tutto Carnivalz — una riga per tween, zero rischi, e cambia la sensazione di tutto.

**Cosa cambierei.** Un metodo solo in `Stile.gd` — qualcosa come `Stile.curva(tween, "entra")` —
che applica la coppia giusta di `set_trans`/`set_ease`, così le curve stanno nel linguaggio
visivo insieme a colori e tempi, e non sparse nei venti punti che creano tween.

---

## 3. Ritratti: la posizione è decisa, quindi deve variare tutto il resto

Sinistra protagonista, destra tutto il resto: non si discute, e la ricerca è d'accordo — la
**costanza spaziale** è quello che rende un ritratto leggibile senza doverlo guardare. Se la
posizione è fissa, allora deve parlare **lo stato**.

Quello che fanno le visual novel per far sembrare un ritratto una persona:

- **chi parla si distingue senza leggere il nome.** Noi lo facciamo già (`imposta_attenuato()`)
- **il rimbalzo quando comincia a parlare.** In Ren'Py è il classico `talkbounce`: la sprite sale
  di pochi pixel e ritorna, ~0.1s su e 0.15s giù. È la cosa che dà «l'illusione che sulla scena
  ci sia davvero una persona, con tutti i piccoli tic che uno ha quando parla». Con arte statica
  disegnata a mano è il **90% della resa del Live2D per cinque righe di codice**
- **entrare ed uscire dal proprio lato.** Chi entra scivola dentro dal bordo a cui appartiene con
  curva di decelerazione; chi esce se ne va dallo stesso bordo con accelerazione. Comparire e
  sparire di colpo è la cosa che fa sembrare i ritratti adesivi appiccicati sullo sfondo
- **animazioni che sostituiscono la camera.** Sprite che rimbalzano per la sorpresa, che si
  inclinano per sussurrare, che si allungano ridendo: «servono a dare enfasi al dialogo senza
  dover muovere la camera». Per noi che la camera non ce l'abbiamo, è l'unica leva che resta

**Una cosa tecnica importante per te che disegni.** La documentazione Ren'Py avverte: una sprite
che si muove **deve avere bordi trasparenti** nella direzione in cui si muove, altrimenti si vede
il taglio netto contro il bordo dello schermo. Quando disegni i ritratti, lascia un margine
trasparente a sinistra e a destra — se poi vogliamo farli entrare scivolando, serve.

**Come sta messo Carnivalz.** Abbiamo attenuazione e dissolvenza. Non abbiamo né rimbalzo né
entrata/uscita laterale: i ritratti appaiono e spariscono.

---

## 4. Il box del testo: dove siamo già a posto, e cosa manca

Le fonti sull'argomento battono tutte sullo stesso chiodo — leggibilità prima di tutto, contrasto,
niente muri di testo, niente transizioni lente e non saltabili. Cose che abbiamo già sistemato:
box di dimensione fissa, macchina da scrivere con pause sulla punteggiatura, click che completa,
velocità del testo nelle opzioni, storico per rileggere.

Restano due cose che le fonti citano come standard e che noi non abbiamo:

- **auto-avanzamento come impostazione del giocatore.** Noi abbiamo `attesa` per messaggio (l'ho
  fatto per il conto alla rovescia), ma non un interruttore «vai avanti da solo» nelle opzioni.
  Chi vuole leggere senza cliccare mille volte non può
- **saltare quello che ha già letto.** Alla seconda partita, o dopo un game over che ti rimanda
  indietro di due stanze, rileggere tutto è la cosa che fa chiudere il gioco. Lo standard è un
  tasto tenuto premuto che accelera **solo il testo già visto**, e che si ferma da solo quando
  arriva qualcosa di nuovo o una scelta

---

## 5. Il negozio: la ricerca dice una cosa sola, ed è quella che ci manca

Tutto il materiale su shop e inventario converge su una frase: **«il problema vero è il
confronto»**. Non «cosa fa questo oggetto», ma **«questo oggetto è meglio di quello che ho
addosso adesso?»**. Le soluzioni documentate sono sempre le stesse tre:

1. **il delta, non il valore assoluto.** Non «difesa +1», ma «difesa 0 → 1» rispetto a chi lo
   indosserebbe
2. **freccia e colore.** ▲ verde se è un miglioramento, ▼ rosso se è un peggioramento, «visibile
   in tutte le schermate dove l'inventario è interattivo — negozio, fucina, alchimista»
3. **il confronto contro l'equipaggiato**, non contro il vuoto

**Come sta messo Carnivalz.** Il negozio rifatto ieri mostra l'effetto **assoluto** («difesa +1»,
«+8 vita»), quanti ne hai già e quanto ti resta in tasca. Sono le tre domande giuste, ma la
seconda è risposta male: sapere che ne hai già uno non è sapere se conviene.

**Cosa cambierei.** Per gli equipaggiabili, il negozio dovrebbe far scegliere «per chi?» — o
almeno mostrare il delta sul protagonista — e stampare `difesa 2 → 3 ▲`. Con gli stigmi, che
danno e tolgono, il delta è ancora più necessario: `stigma del muto → difesa 2 → 4 ▲, attacco
3 → 2 ▼` è una decisione; «difesa +2, attacco −1» è un indovinello.

Sull'economia, il resto della ricerca conferma quello che abbiamo già impostato: rubinetti e
scarichi in equilibrio, consumabili come spesa di routine («abbondanza motivata»: sempre
abbastanza per comprare qualcosa, mai abbastanza perché non conti), e un livello di lusso caro
per chi accumula.

---

## 6. Spettacolo: due tecniche che non abbiamo e che costano niente

- **hit-stop / micro-pausa.** «Una micro-pausa, spesso di soli 40–80 millisecondi, vende il peso
  di un colpo meglio di qualsiasi animazione.» Si congela tutto per un istante nel momento
  dell'impatto. È la singola tecnica con il miglior rapporto resa/righe di codice che esista
- **screen shake.** «Sposta la camera di pochi pixel su esplosioni e colpi pesanti, poi lasciala
  assestare in fretta»: 0.1–0.3s, direzione randomizzata, **scalata all'evento** e smorzata con
  una curva. Fondamentale il «scalata all'evento»: se trema per tutto, non vuol dire più niente.
  Da noi: niente sul colpo normale, un tremito piccolo sul critico, uno vero sullo SLAUGHTER e
  sulle mosse dei boss

Abbiamo già i numeri volanti e il lampo rosso, che sono gli altri due pezzi della stessa
famiglia. Mancano questi due, e sono quelli che si sentono di più.

---

## 7. Codice: cosa insegna Dialogic, e cosa fanno i tween di Godot

**Sui tween di Godot 4**, tre cose utili che stiamo già sfruttando a metà:

- partono da soli e sono **legati al nodo che li crea**: quando il nodo esce dall'albero vengono
  ripuliti, niente tween orfani che continuano a girare. Noi ci contiamo già
- **in Godot 4 i tweener sono sequenziali di default**: `set_parallel(true)` per tutta la catena,
  o `.parallel()` per il singolo passo. Serve per fare due cose insieme (salire e sbiadire) —
  già usato nei numeri volanti
- `set_ease()` e `set_trans()` sono lì apposta e **non li chiamiamo mai** (vedi §2)

**Su Dialogic** (il sistema di dialoghi di riferimento per Godot) la lezione architetturale è una
sola, e riguarda noi: Dialogic è fatto a **sottosistemi** — Testo, Ritratti, Scelte, Audio,
Sfondi, Variabili, Salvataggio — e i nodi si trovano **per gruppo, non per posizione
nell'albero**, «così i sottosistemi possono interagire con questi nodi indipendentemente da dove
stanno nella scena».

Da noi `Main.gd` conosce il percorso esatto di ogni nodo (`%SlotSinistra`, `%BoxTesto`, …) e fa
tutto: coda dei messaggi, palco, scelte, mappa, compagni, appunti. Funziona, ed è ancora
governabile. Ma se i ritratti devono imparare a entrare, uscire, rimbalzare e cambiare
espressione, quella logica non va aggiunta dentro `Main.gd`: va messa in `Ritratto.gd`, che
espone `entra()`, `esci()`, `parla()`, e `Main` gli dice solo **cosa succede**, non come farlo
vedere. È lo stesso principio per cui il combattimento adesso accoda messaggi invece di
disegnarli: chi decide non deve sapere come si mette in scena.

---

## 8. In ordine di resa per costo

1. **Curve di easing su tutti i tween** — mezz'ora, zero rischi, cambia la sensazione di tutto.
   Oggi è tutto lineare, e il lineare si vede
2. **Taglio invece del fade a nero per menu e mappe** — restituisce peso al fade e toglie 0.7
   secondi a ogni sguardo alla mappa
3. **Hit-stop 60ms sul colpo** — poche righe, è la tecnica che «vende il peso» più di ogni altra
4. **Delta nel negozio (`difesa 2 → 3 ▲`)** — trasforma il negozio da elenco a decisione
5. **Rimbalzo del ritratto quando uno comincia a parlare** — cinque righe per il 90% dell'effetto
   «è una persona»
6. **Entrata/uscita laterale dei ritratti** — serve che i tuoi disegni abbiano il margine
   trasparente ai lati, quindi va deciso *prima* che li disegni
7. **Screen shake graduato** — solo su critico, slaughter e mosse dei boss
8. **Auto-avanzamento e salto del già letto nelle opzioni** — qualità della vita, si sente alla
   seconda partita

I punti 1, 2 e 3 li farei subito e insieme: sono tutti e tre economici e agiscono su cose che il
giocatore sente in ogni singolo minuto di gioco.

---

## Fonti

**Transizioni e montaggio**
- [On Fading to Black: The Hows, the Whens, and the Whys — PremiumBeat](https://www.premiumbeat.com/blog/how-when-why-fade-black/)
- [How Does a Dissolve Differ From a Fade Transition? — Boris FX](https://borisfx.com/blog/how-does-a-dissolve-differ-from-a-fade-transition/)
- [Fades to Black and Dissolves — Film Editing Pro](https://www.filmeditingpro.com/fades-to-black-and-dissolves-what-you-need-to-know/)
- [Transitions — Ren'Py Documentation](https://www.renpy.org/doc/html/transitions.html)

**Durate e curve**
- [Duration & easing — Material Design](https://m1.material.io/motion/duration-easing.html)
- [Movement — Material Design](https://m1.material.io/motion/movement.html)
- [Executing UX Animations: Duration and Motion Characteristics — Nielsen Norman Group](https://www.nngroup.com/articles/animation-duration/)
- [5 Rules for Motion in UI Transitions](https://www.equal.design/blog/5-rules-for-motion-in-ui-transitions)

**Ritratti e messa in scena**
- [Transforms (ATL) — Ren'Py Documentation](https://www.renpy.org/doc/html/transforms.html)
- [Transform Properties — Ren'Py Documentation](https://www.renpy.org/doc/html/transform_properties.html)
- [Character Sprites – An Anatomy Of Visual Novels — Fuwanovel](https://forums.fuwanovel.moe/blogs/entry/4351-character-sprites-%E2%80%93-an-anatomy-of-visual-novels/)
- [Sprites, Camera, Action!: Visual Novel Cinematography — ingthing develops](https://ingthing.dev/sprites-camera-action-osas/)
- [Making a character sprite bounce when they start speaking — Lemma Soft](https://lemmasoft.renai.us/forums/viewtopic.php?t=44977)

**Box del testo e dialoghi**
- [Mastering RPG Dialog Boxes: From Functional to Fantastic — HowToMakeAnRPG](https://howtomakeanrpg.com/a/what-makes-a-good-dialog-box.html)
- [The Wonderful World of Text Boxes](https://awcreativewritingblog.wordpress.com/2016/10/28/the-wonderful-world-of-text-boxes/)
- [RPGs and their Dialogue Systems — Konrad Hughes](https://konradhughes.com/dev-blog/rpgs-and-their-dialogue-systems)

**Negozio, inventario, economia**
- [10 Simple ways you can improve your game inventory screen](https://thewingless.com/index.php/2021/07/26/10-simple-ways-you-can-improve-your-videogame-inventory-screen-game-ui-ux-design-course/)
- [Game UI Database — Inventory: Inspect Item](https://www.gameuidatabase.com/index.php?scrn=77)
- [UX and UI in game design: HUD, inventory, menus](https://medium.com/@brdelfino.work/ux-and-ui-in-game-design-exploring-hud-inventory-and-menus-5d8c189deb65)
- [The Fundamentals Of Game Economy Design](https://alts.co/the-fundamentals-of-game-economy-design-from-basics-to-advanced-strategies/)

**Game feel e spettacolo**
- [How to Make Your Game Feel Good: A Guide to Game Feel and Juice](https://egmatic.com/blog/how-to-make-your-game-feel-good)
- [Squeezing more juice out of your game design — GameAnalytics](https://www.gameanalytics.com/blog/squeezing-more-juice-out-of-your-game-design)
- [Game Feel (dispensa universitaria, Uni Bayreuth)](https://medienwissenschaft.uni-bayreuth.de/wp-content/uploads/GxD-10-Game-Feel.pdf)

**Codice**
- [Dialogic 2 — Documentazione](https://docs.dialogic.pro/)
- [Character System — Dialogic (DeepWiki)](https://deepwiki.com/dialogic-godot/documentation/2-character-system)
- [GDScript Tweens Cheat Sheet — SyntaxCache](https://www.syntaxcache.com/gdscript/cheatsheet/tweens)
- [Godot Tween set_parallel — Bugnet](https://bugnet.io/blog/fix-godot-tween-parallel-not-running-concurrently)
