# I segni — come si disegna una mappa che si legge

`docs/dedalo.md` è lungo settecento righe e parla di come si progetta lo
**spazio**: Romero, Jaquays, il diagramma di Melan, Lynch, la tassonomia di
Ashwell, Boss Keys, Etrian, Hollow Knight. Di come si disegna il **diagramma
leggibile** di quello spazio non c'era una riga. Zero occorrenze di Bertin,
variabili visive, figura-sfondo, contrasto, daltonismo.

Il buco si è visto in fretta. Per mesi la mappa a quadretti ha disegnato le
stanze visitate come **niente** — un `bottone.flat = true` che buttava via ogni
`StyleBox` — e nessuna prova se n'era accorta, perché tutte guardavano il testo
e la posizione dei bottoni e nessuna aveva mai guardato la mappa *come
diagramma*. Bru, provandola: «la mappa è pessima, la dovrò disegnare io».
Il disegno mancava davvero, ma non era quello il problema.

Questo documento è l'altra metà di `dedalo.md`. Le fonti stanno in
`docs/fonti/`, estratte dai PDF col nostro `strumenti/sfoglia.py`.

---

## Stack 1 — Le variabili visive

Fonte: `docs/fonti/variabili-visive-bertin.md` — Axis Maps, *Cartography
Guide*, che è la sintesi del *Sémiologie graphique* di Jacques Bertin (1967).

Bertin chiama **variabili retiniche** i modi fondamentali in cui due simboli
grafici possono essere distinti. Le sue sette:

**posizione, dimensione, forma, valore (chiaroscuro), tinta, orientamento,
grana.** Più tardi Joel Morrison ha aggiunto **saturazione** e **disposizione**,
Alan MacEachren **nitidezza**, **risoluzione** e **trasparenza**.

Il pezzo che conta non è l'elenco: sono le quattro **proprietà**, perché dicono
a cosa serve ciascuna variabile e a cosa no.

| proprietà | cosa vuol dire | chi ce l'ha |
|---|---|---|
| **selettiva** | permette di isolare a colpo d'occhio un gruppo di segni | tutte tranne la **forma**, che secondo Bertin non è **mai** selettiva (e l'orientamento quando riempie un'area) |
| **associativa** | permette di vedere i segni come un gruppo *nonostante* la differenza | tutte tranne **valore** e **dimensione**, che sono dissociative |
| **ordinata** | ha una sequenza riconoscibile senza consultare la legenda | posizione, dimensione, valore. La **tinta no**: non c'è un ordine fra rosso, verde e blu |
| **quantitativa** | permette di stimare *quanto* è la differenza | solo **posizione** e **dimensione** |

Due citazioni che vale la pena tenere per esteso, perché sono le due che
cambiano le decisioni.

> An associative variable does not cause the visibility of the signs to vary.
> […] A dissociative variable causes the visibility of the signs to vary.
> — Bertin

> We must remember that quantitative perception represents an accurate
> approximation but not a precise measurement. — Bertin

E la regola pratica che ne tirano gli autori:

> A quick rule of thumb here is to avoid visual variables that are not
> selective (i.e., shape) if you want to highlight patterns.

### Cosa vuol dire per la nostra mappa

I tre stati di un quadratino sono codificati così:

| stato | come si vede | variabile di Bertin |
|---|---|---|
| ci sei stato | quadrato **pieno** | valore (il fondo c'è o non c'è) |
| lo intravedi | contorno + «?» | valore + forma |
| non lo sai | non c'è | posizione (assenza) |
| raggiungibile / lontano | stesso rosso, **scurito del 45%** | valore |
| **segreta** | **verde invece di rosso** | **tinta, e basta** |

Le prime quattro righe sono **codificate bene**, e adesso so perché: i tre stati
hanno un ordine naturale (ci sono stato > l'ho intravisto > non lo so), e il
valore è ordinato. Anche raggiungibile/lontano è un ordine, ed è di nuovo
valore. Il fatto che il valore sia **dissociativo** — cioè che rompa la
percezione di «gruppo» — qui è desiderato: una stanza lontana *deve* sembrare
meno presente.

L'ultima riga è **codificata male**, e per due motivi indipendenti:

1. la tinta **non è ordinata**: rosso e verde non hanno un sopra e un sotto, e
   infatti «segreta» non è un grado di «normale», è un'altra cosa — fin qui ci
   sta. Ma
2. la tinta è **l'unica** cosa che distingue le due, e chi non distingue rosso
   da verde non ha nessun altro appiglio. Il paragrafo sul contrasto qui sotto
   lo misura: **1,07:1**.

E un terzo punto che non avevo previsto: le nostre **icone** (boss, uscita,
obiettivo, scontro duro) sono **forma pura**, e la forma non è mai selettiva.
Vuol dire che un giocatore non può scorrere la mappa e isolare a colpo d'occhio
«tutte le uscite». Se quella è un'operazione che vogliamo gli riesca — e su una
mappa da ventisette stanze lo è — l'icona da sola non basta: ci vuole anche una
variabile selettiva accanto.

---

## Stack 2 — I cinque principi della cartografia

Fonte: `docs/fonti/principi-cartografia-esri.md` — Aileen Buckley (Esri),
estratto da *Map Use*, nona edizione.

> Five of these design principles form a system for seeing and understanding
> the relative importance of the content in the map and on the page. Without
> these primary principles, map-based communication is bound to fail.

**1. Leggibilità** — «the ability to be seen **and understood**». La riga che
ci riguarda:

> Geometric symbols are easier to read at smaller sizes, while more complex
> symbols require more space to be legible.

e

> unfamiliar symbols can confuse map readers and require the use of a legend.

Noi abbiamo `LATO_MINIMO := 30.0` pixel per un quadratino, e dentro quei trenta
pixel disegniamo icone a mano — teschio, bersaglio, croce. Sono simboli
complessi in uno spazio da simboli geometrici. Va misurato, non deciso a occhio.

**2. Contrasto visivo** —

> The higher the contrast between features, the more some features will stand
> out (usually those that are bigger, darker, or brighter).

> Low visual contrast works best for basemaps so that the overlaid thematic
> layers are more visually prominent.

Questa seconda frase è la regola che cercavo per la mappa disegnata: la pianta
di Bru è la **carta di base**, e deve stare a contrasto basso; le stanze e il
loro stato sono lo **strato tematico**, e stanno sopra. Il velo a 0.42 che ho
messo ieri sui riquadri sopra il disegno era la scelta giusta per istinto;
adesso ha un principio dietro.

Il documento nomina anche due trucchi che non usiamo: i **casing** (un contorno
attorno a una linea o a un simbolo, per staccarlo dallo sfondo) e le **maschere
del testo**. Il casing è esattamente quello che ho già fatto sui numeri di danno
— contorno nero attorno al bianco — e non l'ho mai fatto sui corridoi.

**3. Figura-sfondo** —

> the spontaneous separation of the primary area of interest in the foreground
> (the figure) from an amorphous background.

Le tecniche nominate, tutte disegnabili in un `_draw()`: **forma chiusa**,
**ombra portata**, **velatura** (screening), **illuminazione**, **vignettatura**.
La nostra mappa oggi non ne ha nessuna: le stanze stanno su un rettangolo scuro
e basta. La cornice è una forma chiusa a metà.

**4. Gerarchia visiva** — «graphically emphasizing the most important map
features and de-emphasizing those that are less important». E una riga secca:

> Labels remain on the highest visual plane to ensure legibility.

I nomi delle stanze, da noi, **non sono disegnati affatto**: si vedono solo
passandoci sopra col mouse. Sono sul piano più basso possibile, che è l'assenza.

**5. Proporzione** — equilibrio, simmetria, armonia. Il pezzo utile:

> Visual balance can be promoted by placing the map figure in the visual
> center of the layout, which is a point **just above the geometric center**.
> This is the point on which the eye first focuses.

Noi centriamo la mappa nel centro geometrico della cornice.

---

## Stack 4 — Il contrasto, misurato

La soglia di riferimento è **WCAG 1.4.11 (Non-text Contrast)**: un elemento
d'interfaccia, e **anche i suoi stati**, devono stare ad almeno **3:1** rispetto
a quello che hanno accanto. Il testo integrale del criterio non ce l'ho ancora
(vedi sotto); la formula del rapporto di contrasto sì, ed è quella che ho
applicato ai colori veri di `data/stile.json`.

| cosa | colori | rapporto | |
|---|---|---:|---|
| stanza visitata e raggiungibile | `#ed1c24` su nero | **4,79:1** | ok |
| stanza visitata ma **lontana** | `#820f13` su nero | **2,03:1** | **sotto** |
| stanza segreta (verde) | `#2a8f4a` su nero | **5,13:1** | ok |
| corridoi e griglia | `#5b5470` su nero | **2,95:1** | **sotto** |
| raggiungibile **contro** lontano | `#ed1c24` vs `#820f13` | **2,36:1** | **sotto** |
| normale **contro** segreta | `#ed1c24` vs `#2a8f4a` | **1,07:1** | **sotto** |

Tre cose vere, in ordine di gravità.

**Rosso e verde hanno la stessa luminosità.** 1,07:1 è, in pratica, identico.
Per chi non distingue rosso da verde — che è la forma più diffusa — le stanze
segrete e quelle normali sono **lo stesso quadrato**. È il caso da manuale, ed
è quello che Bertin prevede (tinta sola, non ordinata) e che le Game
Accessibility Guidelines vietano in una riga: nessuna informazione essenziale
affidata al solo colore. Non serve cambiare la tavolozza: basta che «segreta»
porti anche un secondo segno — un bordo diverso, una grana, un taglio
d'angolo — e la tinta diventa una conferma invece che l'unica prova.

**Una stanza dove sei stato ma da cui sei lontano è quasi invisibile**
(2,03:1). Lo `darkened(0.45)` fa il suo mestiere — dice «non ci si salta» — ma
lo dice troppo forte. C'è margine: a 0,30 si starebbe sopra soglia e si
leggerebbe lo stesso.

**Corridoi e griglia a 2,95:1** sono a un soffio, e sono la cosa che tiene
insieme la lettura della mappa: senza i corridoi i quadrati sono punti scollegati.

---

## Stack 5 — Godot: quello che dice davvero il manuale

Fonti: `docs/fonti/godot-control-classe.md` e
`docs/fonti/godot-zoom-e-trascinamento.md`.

### La trappola del `flat`, e perché nessuna prova la vedeva

Un `Button` con `flat = true` **non disegna il suo StyleBox**: salta il fondo e
disegna solo il testo. È un comportamento noto del motore (issue #45823, dove è
segnalato che un bottone piatto ignora gli stili *normal*, *hover* e *disabled*
ma non *focus*). Le nostre `vesti_pieno` e `vesti_vuoto` costruivano quaranta
righe di scatole che non arrivavano mai a schermo.

La lezione che resta scritta: le prove guardavano `text`, `position` e
`tooltip_text`, cioè **esattamente le proprietà che `flat` non tocca**. Una
prova che misura solo quello che il codice imposta, e mai quello che il motore
disegna, passa su una schermata vuota.

### `mouse_filter`: il testo vero, che è diverso dal riassunto

La ricerca web mi aveva dato: «PASS consuma l'evento, **e** lo passa anche al
genitore». Il manuale dice un'altra cosa:

> **MOUSE_FILTER_STOP** — The control will receive mouse movement input events
> and mouse button input events if clicked on through `_gui_input()`. […]
> These events are automatically marked as handled, and they will not
> propagate further to other controls. This also results in blocking signals
> in other controls.

> **MOUSE_FILTER_PASS** — […] **If this control does not handle the event**,
> the event will propagate up to its parent control if it has one. The event
> is bubbled up the node hierarchy until it reaches a non-`CanvasItem`, a
> control with `MOUSE_FILTER_STOP`, or a `CanvasItem` with `top_level` enabled.

> **MOUSE_FILTER_IGNORE** — The control will not receive any mouse movement
> input events nor mouse button input events […] This will not block other
> controls from receiving these events.

Cioè `PASS` passa **solo se l'evento non è stato gestito**, non sempre. È una
differenza che cambia il comportamento, ed è l'ennesima volta che un riassunto
dice una cosa e la fonte un'altra.

E una riga del manuale che sembra scritta per noi:

> Set `mouse_filter` to `MOUSE_FILTER_IGNORE` to tell a `Control` node to
> ignore mouse or touch events. **You'll need it if you place an icon on top
> of a button.**

Noi disegniamo le icone in `strato_sopra`, sopra i bottoni. Ho controllato:
`strato_sopra.mouse_filter` è già `IGNORE`, quindi la stanza con il punto
esclamativo — proprio quella dove il gioco ti sta dicendo di andare — è
cliccabile. Questa era già a posto; adesso c'è scritto perché.

### Zoom e trascinamento: la tecnica

Dal gist di thygrrr (Unlicense/CC0). Lo **zoom centrato sul cursore** è quattro
righe, e il trucco è tutto lì:

1. si prende la posizione del mouse **in coordinate del mondo**, prima di
   cambiare lo zoom;
2. si applica lo zoom;
3. si riprende la stessa posizione del mouse, adesso, in coordinate del mondo;
4. si sposta la vista di `(prima − dopo)`.

Il punto sotto il cursore resta fermo. Non c'entra niente `Camera2D` in sé:
vale per qualunque trasformazione, quindi vale anche per un `Control` scalato,
che è il nostro caso.

Gli altri pezzi utili:

- i passi di zoom sono **moltiplicativi e simmetrici** — `zoom *= 1/(1-passo)`
  per avvicinare, `zoom *= (1-passo)` per allontanare, con `passo = 0.1` —
  così zoom avanti e poi indietro torna esattamente dov'era;
- limiti `minZoom = 0.1`, `maxZoom = 5.0`;
- l'ammorbidimento è reso indipendente dal frame rate con
  `k = pow(morbidezza, FPS_DI_RIFERIMENTO * delta)`, `FPS_DI_RIFERIMENTO = 120`.
  Questa è una tecnica che serve anche altrove, non solo qui;
- **un avviso**: nei commenti, un lettore segnala che la prima versione, con lo
  zoom sul cursore acceso, **traballa** quando si zooma in fretta — su Godot
  **4.4.1**, cioè la nostra versione esatta. La seconda versione, con una molla
  criticamente smorzata (`SmoothDamp`) al posto dell'esponenziale, non ha il
  problema. Se lo facciamo, si parte da quella.

---

## Quello che non ho potuto studiare, e perché

**Le schermate di Hollow Knight.** Il PDF di Game UI Database è fatto di sole
immagini, e in fondo a ogni pagina c'è scritto che il contenuto del sito non può
essere usato per addestrare o alimentare sistemi di apprendimento automatico.
Non le leggo. Se ti servono quegli esempi, le tue schermate di un gioco che hai
— o una fonte senza quella clausola — vanno benissimo e valgono uguale.

**Il testo di WCAG 1.4.11.** La soglia 3:1 l'ho dalla ricerca; i numeri della
tabella li ho calcolati io con la formula standard, quindi quelli sono solidi.
Manca il testo del criterio, che serve per le eccezioni (cosa è «decorativo» e
cosa no).

**Krygier & Wood, *Making Maps*** — generalizzazione: cosa si toglie quando la
scala scende. È la domanda che si pone appena mettiamo lo zoom.

**Il posizionamento delle etichette.** Appena i nomi delle stanze si disegnano
davvero, diventa il problema numero uno: dove va il nome di una stanza perché
non copra un corridoio e non si accavalli col nome accanto.

---

## Le decisioni che ne escono

Scritte qui, non ancora fatte: Bru ha chiesto di studiare prima e di non
toccare niente.

1. **«Segreta» non può essere solo verde.** Un secondo segno, e la tinta resta
   come conferma. (1,07:1 — misurato)
2. **`darkened(0.45)` → `0.30`** per le stanze lontane: sopra soglia e si legge
   lo stesso. (2,03:1 → sopra 3:1)
3. **I nomi delle stanze si disegnano**, almeno su quelle visitate, e stanno sul
   piano più alto. (*«Labels remain on the highest visual plane»*)
4. **Figura-sfondo**: una delle cinque tecniche nominate — la vignettatura è la
   più economica in un `_draw()`.
5. **Casing sui corridoi**, che stanno a 2,95:1 e reggono la lettura di tutto.
6. **Le icone hanno bisogno di una variabile selettiva accanto**, perché la
   forma non è mai selettiva.
7. **Zoom e trascinamento**: si fa, e si parte dalla versione con la molla
   smorzata, non dall'esponenziale — il traballio è segnalato proprio su 4.4.1.
8. **Misurare se un'icona complessa si legge a 30 pixel**, invece di supporlo.
