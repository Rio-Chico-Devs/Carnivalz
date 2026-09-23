# Il movimento dell'interfaccia: aprire, puntare, premere

Bru:

> documentati sugli effetti animati per apertura menu, selezione col mouse,
> hovering, transform, paralax effect, fake 3d dynamics, alto design, ricerca
> minuziosa, giochi che ottengono effetti bellissimi sono ad esempio persona,
> hollow knight [...] Fluidità e Tempistiche (Choreography): Gli elementi
> secondari appaiono con leggeri ritardi (staggered animations), mentre i
> pulsanti d'azione principale chiudono la sequenza per guidare l'occhio del
> giocatore. Feedback Contestuale: Ogni click o pressione di tasto innesca
> minuscole reazioni visive (rimbalzi, cambi di colore, particelle) che rendono
> il gioco vivo. Coerenza Artistica: L'animazione rispetta i pilastri visivi
> del gioco

E prima, sulla raffica: «non rallentiamo niente». Vale anche qui: niente di
quello che segue deve far aspettare il giocatore.

Questo è lo studio. Prima si è deciso, poi si è costruito: quello che è già nel
gioco sta al §7.

---

## 0. Com'è Carnivalz oggi, misurato

| cosa | quanto | cosa vuol dire |
|---|---|---|
| menu che si aprono con un'animazione | **0** su 7 (Pausa, menu principale, Opzioni, Negozio, Sede, mappa, mappa di zona) | tutti compaiono di colpo, tutto insieme |
| bottoni che reagiscono al mouse con un movimento | **0** | l'hover è solo un cambio di colore del tema |
| suoni d'interfaccia in tutto il gioco | **9** chiamate | la maggior parte dei clic è muta |
| animazioni (tween) in tutto il gioco | 28, in 16 file | quasi tutte nello scontro, nel dialogo, nelle transizioni |
| curve di movimento usate | 5 diverse (`SINE`, `BACK`, `CUBIC`, `QUAD`, `QUART`), ognuna scelta a mano | nessun vocabolario comune: due cose che fanno lo stesso mestiere si muovono in due modi |
| tempi già centralizzati | 13 in `data/stile.json` → `tempi` | una base c'è |

Il combattimento è la parte più viva (lampi, scossa, ECG, bagliore). Tutto il
resto — i menu, cioè quello che si tocca più spesso — è fermo.

---

## 1. Coreografia: in che ordine compaiono le cose

### La fonte che conferma il principio di Bru

**IBM Carbon Design System**, `elements/motion/choreography` (testo preso dal
loro repository, `carbon-design-system/carbon-website`):

> When multiple elements need to animate, distribute their entrances over time
> instead of introducing everything at once. [...] staggering the entrance of
> table content by 20 ms significantly reduces the cognitive load. Depending on
> the number of staggered elements, the delay should be adjusted to ensure that
> total time is still within 500 ms.

> Sequence the loading of page content when possible. Start with the most
> stable content, such as static content and header, and end with the most
> important information, such as the primary button or a calculation result,
> to focus the user's attention on them.

E la tabella dell'ordine:

| # | categoria | esempi |
|---|---|---|
| 1 | contenuto statico | la cornice, la navigazione |
| 2 | contenuto statico del corpo | titoli, testo, immagini |
| 3 | contenuto dinamico | il contenuto di una tabella, i risultati |
| 4 | **azione principale** | il bottone principale |
| 5 | contenuto animato | le visualizzazioni di dati |

**Attenzione**: fra le sintesi della ricerca web ce n'era una che diceva il
contrario («lead with the most important element»), attribuita a Material. Il
testo originale di Carbon dà ragione a Bru. Material 1 (la pagina
*Choreography*) non l'ho potuta leggere — è fra i link bloccati in fondo.

**Issara Willenskomer**, *The UX in Motion Manifesto* (2017, letto solo in
sintesi): fra i dodici principi, *Offset & Delay* — ritardi diversi su oggetti
diversi dicono le relazioni e la gerarchia fra loro.

### Quanto deve durare

| fonte | numero |
|---|---|
| Material (sorgente, `docs/theming/Motion.md`) | 16 durate da **50 ms** a **1000 ms**; «duration should increase as the area/traversal of an animation increases» |
| Material, `MaterialFade.java` — **menu e dialoghi** | entrata **400 ms**, uscita **150 ms**; entra da **scala 0,8** ed è già tutto opaco al **30%** della durata |
| Material, `MaterialFadeThrough.java` | 450 ms, scala di partenza **0,92**; il vecchio sparisce nel primo **35%** |
| Carbon, `overview.mdx` | bottoni e interruttori **70 ms**; dissolvenze **110 ms**; piccole espansioni **150 ms**; notifiche **240 ms**; grandi espansioni **400 ms**; oscurare lo sfondo **700 ms** |
| NN/g, Laubheimer (letto in sintesi) | la maggior parte fra **100 e 500 ms**; un riscontro semplice **~100 ms**; «at 500ms, animations start to feel like a real drag» |

Due cose che ne vengono fuori:

1. **L'uscita è più veloce dell'entrata** (Material: 150 contro 400). Quando
   chiudi un menu hai già deciso: non devi guardarlo andare via.
2. **La sequenza intera sta sotto il mezzo secondo** (Carbon). Con venti voci a
   20 ms l'una, l'ultima parte dopo 380 ms: il tetto tiene anche le liste
   lunghe, a patto che ogni voce si muova in fretta.

### Le curve

| fonte | curva | per cosa |
|---|---|---|
| Material | `cubic-bezier(0.05, 0.7, 0.1, 1)` | *emphasized decelerate*: cose che **entrano** |
| Material | `cubic-bezier(0.3, 0, 0.8, 0.15)` | *emphasized accelerate*: cose che **escono** |
| Material | `cubic-bezier(0.2, 0, 0, 1)` | *standard*: cose che si muovono restando a schermo |
| Carbon | `cubic-bezier(0, 0, 0.3, 1)` / `(0, 0, 0.38, 0.9)` | entrata *expressive* / *productive* |

In Godot (`Tween.xml`, sorgente 4.4) non ci sono bezier ma ci sono le famiglie:
`TRANS_EXPO`/`QUINT` con `EASE_OUT` sono le più vicine all'*emphasized
decelerate*, con `EASE_IN` all'*accelerate*.

### Il controesempio: FFXVI

Durczok, *The Final Fantasy XVI interface* (PDF che mi hai passato): il fuoco
animato in fondo ai menu è «an effect thematically apt», e della camera che gira
attorno al protagonista a ogni cambio di schermata scrive «Visually it's an
attractive effect» —
ma le transizioni vanno «at sub-30fps with a noticeable judder and some delay».
La mappa viene caricata ogni volta che la apri. **Bello e lento è peggio di
brutto e veloce.**

### Il modello: Persona 5

Masayoshi Sutou, intervista Famitsu (PDF che mi hai passato):

> Each entry on the menu screen is animated and due to the fact that a lot of
> the GUI's data is found in the Resident Areas memory as soon as you press the
> button to bring up the menu it will pop up without any lag whatsoever, this
> was something that I was very particular about.

> First we have to figure out the concept and lay out design for the UI and
> what components would need to react in what ways.

Tutte e due le cose insieme: **ogni voce animata, e zero attesa**. E la
coreografia si decide *prima*, sul disegno — non si aggiunge dopo.

---

## 2. Riscontro: ogni gesto ha una risposta

### Le molle di Material — e perché non rimbalzano

Material (`Motion.md`) usa molle con smorzamento e rigidità, e per un bottone
premuto ne usa **due**:

> button's shape and color when pressed, use two springs: a
> `motionSpringFastSpatial` spring to animate the button's shape/size and a
> `motionSpringFastEffects` spring to animate the button's color.

| molla | smorzamento | rigidità | **calcolato**: si ferma in | supera il bersaglio |
|---|---|---|---|---|
| FastSpatial (forma, misura di un bottone) | 0,9 | 1400 | 181 ms | 0,1% |
| FastEffects (colore, opacità) | 1 | 3800 | 155 ms | 0 |
| DefaultSpatial (pannelli a metà schermo) | 0,9 | 700 | 249 ms | 0,1% |
| SlowSpatial (tutto lo schermo) | 0,9 | 300 | 367 ms | 0,1% |

(I tempi li ho calcolati io integrando le molle con le loro costanti.)

Cioè: **la forma e il colore si muovono con due molle diverse**, e nessuna delle
due rimbalza davvero. Material è sobrio apposta. Carbon dà un nome alla
differenza:

> *Productive* motion creates a sense of efficiency and responsiveness, while
> remaining subtle and out of the way. [...] *Expressive* motion delivers
> enthusiastic, vibrant, and highly visible movement. Use expressive motion for
> significant moments such as opening a new page.

### Il rimbalzo vero: *Juice it or lose it*

Martin Jonasson e Petri Purho, talk alla Nordic Game del 2012. Il codice della
demo è pubblico (`grapefrukt/juicy-breakout`), quindi i numeri sono quelli veri.

**Il "jelly"** — il colpo su un mattone (`Block.as`, `jellyEffect`):

- la **X** si allarga del 20% in **50 ms**, poi torna a 1 in **600 ms** con
  curva *elastica*;
- la **Y** fa lo stesso, ma parte **50 ms dopo**.

È quello sfasamento fra X e Y che lo fa sembrare gelatina e non un semplice
ingrandimento.

**L'entrata dei mattoni**: da 500 pixel più su, con rotazione casuale fino a
±45° e scala 0,2, in **0,7 s**, con un **ritardo casuale** per ognuno — la
cascata — e curve a scelta: lineare, *quad out*, *back out*, *bounce out*.

**La scossa** (`Shaker.as`) non è un tremolio a caso a ogni fotogramma: è una
molla. Riceve una spinta, e attrito (0,1) ed elasticità (0,1) la riportano a
zero da sola.

**Il fermo immagine** (`Freezer.as`): il tempo rallenta, resta fermo fino a
320 ms, e riparte con una dissolvenza d'entrata e d'uscita.

Il principio, nel loro README, su due righe:

> A juicy game feels alive and responds to everything you do
> tons of cascading action and response for minimal user input.

### Il suono è metà del riscontro

Tsuchiya, sound designer di Persona 5, stessa intervista Famitsu:

> I base my thoughts around "If it moves, it'll make a sound".

Da noi 9 suoni d'interfaccia in tutto il gioco. È il pezzo più economico e più
lontano.

### Le quattro parti di una microinterazione

Dan Saffer, *Microinteractions* (O'Reilly, 2013 — letto in sintesi): **trigger**
(cosa la fa partire), **regole** (cosa succede), **riscontro** (come te lo
dice), **cicli e modi** (come cambia nel tempo). Serve come controllo: ogni
reazione che aggiungiamo deve avere tutte e quattro.

---

## 3. Coerenza artistica

**Carbon, *Semantic consistency*:**

> When elements convey the same meaning or perform the same function, use the
> same motion for them, and vice-versa.

**Material**: «use an easing and duration theme attribute so your animations
tie in with animations used by Material components, bringing motion
consistency». Cioè un **vocabolario** — pochi movimenti con un nome — e non una
curva scelta a mano per ogni tween, che è quello che abbiamo oggi.

**Persona 5** (Sutou): cremisi, nero e testo bianco, «I tend to not add
gradations». Il movimento segue: grafico, angolato, rapidissimo.

**Hollow Knight** (letto solo in sintesi: PC Gamer, un'analisi dell'interfaccia
su *The Picky Champy*): gli ornamenti dei menu e dei riquadri vengono dalle
decorazioni gotiche dei timpani francesi, le stesse del mondo di gioco.
L'interfaccia non è appoggiata sul mondo, è fatta della stessa materia.

### I pilastri di Carnivalz, com'è disegnato oggi

Non li invento: sono nei tuoi disegni e in `data/stile.json`.

- **nero pieno e bordi spessi** (`bordo_plancia` = 8);
- **cremisi** come accento (`accento` #e8123c), e le **fasce rosse** dei nomi;
- il **nastro rosa inclinato** (`inclinazione_nastro` = −3,5°): l'unica
  diagonale della schermata;
- il riquadro scuro dell'**ECG** con la linea che si illumina.

È un linguaggio grafico, piatto e tagliente, più vicino a Persona che a Hollow
Knight. Quindi il movimento giusto per noi è **secco, angolato e veloce**: le
cose entrano scivolando lungo la diagonale del nastro, i colori scattano, e il
bagliore è l'unica cosa morbida. Non fluttua niente.

---

## 4. Le tecniche, in Godot, senza shader

La regola del progetto resta: niente shader, perché Godot senza finestra non li
compila e nessuna prova li può attraversare. Tutto quello che segue si fa con
trasformazioni e disegni.

### Hover e pressione: scala, rotazione, perno

`Control.xml` (sorgente 4.4):

> By default, the node's pivot is its top-left corner. When you change its
> rotation or scale, it will rotate or scale around this pivot. Set this
> property to size / 2 to pivot around the Control's center.

> [scale] This property is mainly intended to be used for animation purposes.

Due trappole:

1. **Senza spostare il perno**, un bottone che si ingrandisce cresce verso destra
   e verso il basso invece che dal centro.
2. **Dentro un contenitore** la misura la decide il contenitore
   («Container nodes update this property automatically»): il perno calcolato
   una volta diventa sbagliato al primo ridimensionamento. Va ricalcolato a ogni
   `resized`.

Il vantaggio: `scale`, `rotation` e `modulate` **non cambiano l'impaginazione**,
quindi animarli non costringe il contenitore a ridisporre tutto a ogni
fotogramma. Animare `position` o `size` dentro un contenitore sì.

**Ma c'è una terza trappola, e l'ho trovata solo nel sorgente.** Un contenitore,
a ogni riordino, non rimette a posto soltanto posizione e misura dei figli:
rimette a posto **anche la scala e la rotazione**. In `scene/gui/container.cpp`
(4.4.1), alla fine di `fit_child_in_rect`:

```cpp
p_child->set_rect(r);
p_child->set_rotation(0);
p_child->set_scale(Vector2(1, 1));
```

Quindi un bottone che fa la gelatina dentro una colonna viene raddrizzato a metà
strada ogni volta che la colonna si riordina (un'etichetta che va a capo, un
testo che cambia). Per questo ogni voce di menu sta su un **binario suo**: un
`Control` semplice che la colonna misura, con il bottone appoggiato sopra
libero. C'è una prova che guarda succedere la trappola e guarda il binario
resisterle.

### Le curve e le catene: `Tween`

`Tween.xml` (sorgente 4.4): ci sono `TRANS_BACK` (esce un po' oltre e rientra),
`TRANS_ELASTIC` (oscilla), `TRANS_BOUNCE`, `TRANS_SPRING`; `parallel()` e
`set_parallel()` per muovere più cose insieme; ritardi per la cascata. E una
regola: «Tweens are not designed to be reused» — un tween per animazione, e
quello vecchio si ferma con `kill()` prima di farne partire un altro.

`TRANS_SPRING` però **non ha parametri**: le molle di Material (smorzamento e
rigidità) vanno scritte a mano, come fa la scossa di *Juice it or lose it*. Sono
dieci righe, e sono matematica pura: si provano senza aprire una finestra.

### La parallasse

Willenskomer (in sintesi): *Parallax* — oggetti dell'interfaccia che si muovono
a velocità diverse, e aiutano a concentrarsi sul contenuto principale.

In **Hollow Knight** (e **Silksong**, 80.lv, letto in sintesi) i piani disegnati
a mano stanno su un **vero asse Z** di una camera prospettica: la parallasse
esce da sola dalla prospettiva. Più un piano è lontano, più si muove piano.

In Godot `Parallax2D` (`Parallax2D.xml`) segue la **camera**: `scroll_scale` 1
va alla stessa velocità, meno di 1 sembra più lontano. Nei nostri menu una
camera non c'è: la parallasse si fa a mano, spostando ogni strato di
*(posizione del mouse − centro) × profondità*, smorzato con una molla.

### Il finto 3D

**Balatro**: la carta che si inclina sotto il mouse è uno **shader** che
ruota i vertici in X e Y e ci applica una prospettiva (le versioni pubbliche per
Godot sono su godotshaders.com). Per noi è vietato.

**Come si ottiene senza shader**: si disegna la carta come **poligono** con
`draw_polygon`, calcolando a mano dove finiscono i quattro angoli ruotati in 3D
e proiettati. Un quadrilatero diviso in due triangoli deforma la texture (la
mappatura è affine), quindi la carta si divide in una **griglia di quadratini**
(8×8 basta a nasconderlo). Se la carta contiene testo, prima si disegna in una
`SubViewport` e poi si usa la sua immagine come texture. La proiezione è una
funzione pura: si prova con i numeri, come i contrasti della mappa.

Willenskomer chiama questo *Dimensionality*: gli oggetti hanno un davanti, un
dietro e un'origine nello spazio.

### Le particelle

`CPUParticles2D` le calcola sulla CPU e le disegna con il materiale normale
della tela: niente shader nostri. In alternativa, come per la raffica, un nodo
solo che disegna tutto.

---

## 5. Cosa propongo, in ordine

**Prima il vocabolario, poi le schermate.** Se si comincia dalle schermate si
rifà quello che c'è oggi: cinque curve scelte una per una.

1. **Un modulo di movimento** con pochi gesti che hanno un nome, e i loro tempi
   in `data/stile.json` accanto a quelli che ci sono già:
   - **entrata** e **uscita** — l'uscita più veloce dell'entrata;
   - **cascata** — 20–40 ms fra una voce e l'altra, tutta la sequenza entro
     500 ms, **l'azione principale per ultima**;
   - **hover** — forma e colore su due molle diverse (Material), con perno al
     centro ricalcolato ai ridimensionamenti;
   - **pressione** — il jelly: X e poi Y 50 ms dopo;
   - **rifiuto** — la scossa a molla, per il clic che non si può fare;
   - per ognuno, **un suono** («If it moves, it'll make a sound»).
2. **Le schermate, una per volta**, dalla più usata: Pausa, menu principale,
   Sede, Negozio, Opzioni, mappe. Il menu dello scontro per ultimo, perché è
   quello dove un fotogramma perso costa di più.
3. **Parallasse e finto 3D** dove c'è qualcosa da mettere in profondità — cioè
   quando arrivano i tuoi disegni. Su riquadri piatti e colori pieni non c'è
   niente da far scorrere a velocità diverse.

**Quello che ogni pezzo deve rispettare, con una prova ciascuno:**

- **non si aspetta mai**: un clic durante un'animazione fa quello che deve fare
  subito (è la regola di `Conto.gd`: animare sì, sbarrare mai);
- **i tempi stanno nei tetti**: niente sopra i 500 ms tranne i cambi di
  schermata;
- **il movimento ridotto spegne i movimenti** ma non le informazioni;
- **niente sotto i 60 fotogrammi**: si misura il tempo di un fotogramma mentre
  il menu si apre. È esattamente dove FFXVI è caduto.

---

## 6. Link che non riesco ad aprire

Se me li passi in PDF li leggo per intero e sostituisco le sintesi.

| cosa | link |
|---|---|
| Material 1, *Choreography* — per verificare l'ordine delle entrate | https://material.io/archive/guidelines/motion/choreography.html |
| NN/g, Laubheimer — *Executing UX Animations: Duration and Motion Characteristics* | https://www.nngroup.com/articles/animation-duration/ |
| Willenskomer — *The UX in Motion Manifesto* | https://medium.com/ux-in-motion/creating-usability-with-motion-the-ux-in-motion-manifesto-a87a4584ddc |
| Mark Tan — *Persona 5: A masterclass in UI design* | https://medium.com/@marktan_98815/persona-5-a-masterclass-in-ui-design-6e0470d2020f |
| Kinga Olszewska — *Persona 5 UI, controversial, yet brilliant* | https://medium.com/@kinga.olszewska/interface-so-good-that-people-make-cosplay-of-it-persona-5-ui-controversial-yet-brilliant-ac1ec4b95229 |
| *Hollow Knight: interface design analysis* | https://champicky.com/2022/03/23/hollow-knight-interface-design-analysis/ |
| PC Gamer — l'arte disegnata a mano di Hollow Knight | https://www.pcgamer.com/hollow-knights-charming-art-sets-the-bar-for-hand-drawn-games/ |
| 80.lv — i piani di Silksong | https://80.lv/articles/hollow-knight-silksong-s-game-world-isn-t-actually-2d |
| Il talk *Juice it or lose it* (video) | http://www.youtube.com/watch?v=Fy0aCDmgnxg |

Non riesco nemmeno a vedere i video: se trovi i talk con la trascrizione, o
schermate di Persona 5 e Hollow Knight **da una fonte senza divieto di uso per
l'apprendimento automatico** (Game UI Database lo vieta, quindi quelle non le
uso), sono la cosa che servirebbe di più per la parte "come si vede".

---

## 7. Cosa è stato costruito (il menu di pausa)

**Il vocabolario** — `scripts/Movimento.gd`, con i tempi in `data/stile.json`
sotto `movimento`:

| gesto | cosa fa | tempi |
|---|---|---|
| entrata | arriva in fretta e si posa | 240 ms, *emphasized decelerate* |
| uscita | parte piano e se ne va | 150 ms, *emphasized accelerate* |
| cascata | secondari dall'alto, principale per ultima | 30 ms fra l'una e l'altra, tutto entro 500 ms |
| sfioro | la lastra si srotola, la voce avanza di 16 px | due molle: forma (FastSpatial) e colore (FastEffects) |
| pressione | gelatina: X +8% in 50 ms, Y 50 ms dopo, ritorno elastico | 0,55 s in tutto |
| rifiuto | scossa smorzata di 8 px | 0,3 s |
| cambio di pannello | il vecchio si dissolve, poi entra il nuovo | *fade through*, soglia 0,35 |

Ogni gesto ha il suo suono (Tsuchiya: «If it moves, it'll make a sound»):
sfioro → un tic cortissimo su un lettore suo, pressione → conferma, rifiuto →
errore, apertura e chiusura → una spazzata in su e una in giù. Sono in
`Sintesi.gd` e si sostituiscono copiando un `.wav` in `audio/ui/`.

**I pezzi**, ognuno riusabile nelle prossime schermate:

- `VoceMenu.gd` — la voce: testo rosso sul nero da spenta, bianco su una
  **lastra** cremisi storta di −3,5° quando ha il fuoco, con una sfoglia bianca
  sotto che sporge (carta ritagliata a strati). Il mouse e la tastiera sono la
  stessa cosa: passarci sopra le dà il fuoco, quindi c'è sempre una voce accesa
  sola. Una voce **inerte** (la pagina in cui sei già, l'oggetto che non puoi
  comprare) premuta dice di no invece di fingere una conferma.
- `Cartiglio.gd` — la fascia storta con una scritta: il titolo (cremisi, scritta
  bianca) e il cartellino dei Tazo (bianco, scritta nera). Entra srotolandosi.
- `Quinte.gd` — dietro le voci, tre fogli tagliati in obliquo (bianco, cremisi,
  nero) che arrivano uno dopo l'altro, e la **parola grande** del pannello in
  cinque copie a strati. Col mouse gli strati si spostano di quantità diverse
  (parallasse) e le copie della parola si aprono come una scritta scolpita: è
  il finto 3D, ricavato dalla parallasse, senza shader e senza 3D.
- `Schegge.gd` — alla pressione, sette triangoli di carta volano via lungo la
  diagonale e spariscono in un terzo di secondo.

**Le regole, ognuna con la sua prova** (tutte verificate rompendo apposta il
codice e guardando la prova fallire):

- le curve coincidono con le cubiche di Material punto per punto;
- le molle si assestano nei tempi di Material, non rimbalzano, e fanno la stessa
  strada a 30 e a 240 fotogrammi al secondo;
- nella cascata Riprendi entra per ultima, le altre dall'alto, tutto entro
  mezzo secondo;
- un clic su una voce ancora trasparente fa subito quello che deve;
- chiudendo, il gioco riparte nell'istante del clic e il velo che sfuma non
  prende clic;
- il pannello che se ne va non prende né clic né fuoco;
- col movimento ridotto le voci compaiono sul posto, la lastra c'è subito, la
  parallasse sta ferma, le schegge non scoppiano, il rifiuto lampeggia invece di
  scuotere;
- i conti di un fotogramma dell'entrata stanno sotto i 2 ms (senza finestra non
  si misura il disegno: questa è solo la parte che scriviamo noi).

**Quello che manca, in ordine:** Sede, Negozio (dove la voce inerte serve
davvero: l'oggetto che non ti puoi permettere), Opzioni (le intestazioni grigie
e le caselle quasi invisibili vanno rifatte), mappe, e per ultimo il menu dello
scontro. Il menu principale è al §8.

---

## 8. Il menu principale, sul riferimento di Bru

Bru ha mandato il menu principale di Borderlands 2 come riferimento («la nostra
è 2/10, questa è 9/10»), chiedendo di guardarne il layout preciso, il carattere,
gli effetti dietro il testo e la teoria del colore, e di dare al menu più passi
e più organizzazione. L'immagine è sua; qui c'è solo quello che se n'è misurato
(ingrandendola e campionando i colori).

**Il layout**, in frazioni dello schermo (su 736×414):

| cosa | dove | qui |
|---|---|---|
| testata «MAIN MENU», piccola e tonda, su una scia di luce | 7,7% da sinistra, ~9% dall'alto | «MENU PRINCIPALE», stesso posto |
| voci, maiuscole strette, una sotto l'altra | dal 12% al 54%, passo 5,65% | passo di 40 pixel a 720 |
| la voce scelta: gialla, col simbolo a sinistra e una macchia d'inchiostro nera dietro | — | cremisi, col rombo di Carnivalz, macchia quasi nera |
| descrizione della voce, con una pennellata chiara dietro l'inizio del titolo | in basso a sinistra, dall'83% | appesa al 96,5% e cresce verso l'alto: al massimo titolo e tre righe |
| la squadra: titolo con contatore, quattro righe, la prima accesa | in alto a destra, dal 71% | le cinque partite, la più recente accesa |
| i comandi | in basso a destra | INVIO Seleziona, ESC Indietro, cliccabili |

**Il colore.** Nel riferimento tutto quello che non è scelto sta in una
famiglia sola di blu (la scena, le voci spente `#527690`, la testata
`#a5c4c9`); la scelta è l'unico colore caldo, dall'altra parte del cerchio. Qui
la notte del luna park e le voci spente sono blu, la scelta è il cremisi di
Carnivalz. Una prova misura che ogni colore del menu stia fra 180° e 260° di
tinta e a più di 120° dal cremisi.

**La macchia fa un lavoro.** Il cremisi dritto sul cielo sta fra 2,6 e 3,5:1 a
seconda della riga: nelle righe basse sotto il 3:1 del testo grande. Sulla
macchia sta a 4,3:1 su tutte. È la ragione per cui nel riferimento il giallo ha
il nero dietro. (Il primo tentativo scuriva la sinistra dello schermo quasi al
nero, e la macchia spariva: nero su nero. Nel riferimento la sinistra è ancora
blu, `#2c465f`.)

**I caratteri.** Anton per le voci (pesante e stretto, il più vicino fra quelli
liberi al carattere del riferimento) e Nunito, tondo, per le scritte piccole:
due caratteri per due mestieri, come nel riferimento. Tutti e due OFL, dentro
`art/font/` con le licenze. Anton a corpo 31 ha una riga di 48 pixel; le voci
sono tutte maiuscole, quindi si toglie l'aria sopra e sotto (una FontVariation
con le spaziature negative) e il passo torna a 40.

**I passi.** Un titolo («premi un tasto»), poi il menu, che le partite non le
mostra: stanno dietro CONTINUA (la più recente), NUOVA PARTITA (dove, poi chi
sei), CARICA PARTITA (quale, o quale cancellare). ESC torna indietro di un passo.
Il titolo si vede una volta per sessione. I consigli che stavano sotto il menu
sono diventati una voce, COME SI GIOCA, e si leggono nella descrizione.

**Il fondale** è un luna park disegnato a sagome (la ruota che gira in due
minuti, il tendone, i fili di lampadine, la nebbia), con la prospettiva aerea
e la parallasse col mouse. Aspetta un disegno vero: `art/menu/sfondo.png`
prende il suo posto senza toccare il codice.

**Una trappola trovata strada facendo**: senza finestra (`--headless`) Godot non
sa l'altezza vera di un carattere — Anton risulta alto 93 pixel a corpo 31
invece di 48, e succede anche caricandolo dal file. Le larghezze invece sono
giuste. Quando una prova ha bisogno di un'altezza la legge dalle tabelle del
file TTF (`head` e `hhea`: salita e discesa sulle unità del quadrato), e prima
controlla il metodo su due valori noti: Anton 31 → 48, Nunito 18 → 26.

## 9. Ogni percorso torna indietro, ogni cosa ha il suo spazio

Bru, esplorando il menu: da OGGETTI c'era solo «torna al menu», da OPZIONI non
c'era modo di tornare indietro. La regola adesso è una sola, e una prova la
cammina tutta: **da ogni posto si torna al passo prima, e il cursore si ritrova
sulla voce da cui si era partiti.**

- **OPZIONI ed EXTRA non sono più scene a parte**: sono passi del menu, con la
  loro testata, la descrizione, i comandi e ESC. Dentro EXTRA, CARICA UN CODICE
  è un passo anche lui; l'esito del codice si legge nella descrizione.
- **OPZIONI è un elenco di sezioni** (AUDIO, GRAFICA, ACCESSIBILITÀ), e ogni
  sezione è un passo suo, come nel riferimento. Tutte insieme non ci stavano: a
  testo normale «Velocità del testo» finiva sotto la descrizione e ci si
  arrivava solo con una barra grigia che tagliava la luna. L'elenco resta uno
  solo (`PannelloOpzioni.SEZIONI`): la pausa le mostra tutte, il menu una alla
  volta, e una prova conta che la somma sia la stessa.
- **La riga col fuoco si vede**: una banda scura come la macchia d'inchiostro
  e un filo cremisi a sinistra, sulle caselle e sui cursori (che il loro fuoco
  non lo disegnano: la banda la prende la riga). Prima era il riquadro bianco
  di serie sulle caselle, e niente sui cursori.
- **ALBUM, BESTIARIO e OGGETTI** restano scene loro (sono lunghe), ma col telaio
  del menu: stesso fondale velato, testata, comandi con «ESC Indietro».
  Tornando, il menu riapre COLLEZIONI con la voce da cui si era entrati
  (`MenuPrincipale.ritorno`, che si consuma una volta). Le frecce e pagina
  su/giù scorrono l'elenco.
- **Tornare è un legame, non un salto**: ogni «indietro» porta con sé il nome
  della voce da riaccendere (`pagina_carica.bind("CANCELLA UNA PARTITA")`).
- **Le opzioni si leggono**: le sezioni erano grigie a metà trasparenza (circa
  2,3:1); adesso prendono il colore del posto in cui stanno (chiaro nel menu,
  cremisi nella pausa), e caselle e cursori hanno un disegno visibile.

**Lo spazio** si controlla a scala 1 e a 1,25 («Testo più grande», che porta lo
spazio logico a 1024×576), su ogni passo:

| cosa | regola |
|---|---|
| la colonna delle voci | finisce sopra la zona della descrizione (74%) e non tocca il pannello |
| il pannello a destra | ancorato al bordo destro (94%), cresce verso sinistra: non esce mai |
| la descrizione | appesa in basso, cresce in su; titolo su una riga, corpo al massimo tre, e non tocca i comandi; le righe si bilanciano (la larghezza più stretta che tiene lo stesso numero di righe), così l'ultima non resta con una parola sola - prima succedeva in sedici voci, quasi tutte col testo più grande |
| le opzioni | una sezione per passo: ci stanno senza scorrere; la colonna arriva fino al pannello con le ancore, e se «testo più grande» si accende da lì si stringe da sola |
| le collezioni | l'elenco che scorre e i comandi stanno dentro lo schermo; la barra è sottile, azzurra, e l'elenco le lascia 24 pixel |

Le prove sono state messe alla prova rompendo apposta il codice, un pezzo alla
volta (venti sabotaggi: le righe non bilanciate, bilanciate e non usate o
strette oltre il numero di righe, una sezione fuori dal menu, le righe di una
sezione perse, tutte le opzioni di nuovo in un passo, le opzioni fin dentro il
pannello, un indietro senza la voce - dal menu e da una sezione -, il pannello
ancorato a sinistra, una collezione senza ESC, l'elenco attaccato alla barra,
il ritorno ignorato o mai consumato, quattro righe di descrizione, la
descrizione non appesa in basso, le frecce che non scorrono, la pausa sopra
OGGETTI, l'altezza letta dal font): ognuno fa fallire una prova, con una frase
che dice cosa si è rotto.

