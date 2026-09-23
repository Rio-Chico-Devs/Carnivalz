# La raffica: come si fa un evento di tempismo che si gioca davvero

Bru, provando le Collisioni infinite:

> concentriamoci sul videogioco cerca documentazione su performance e come fare
> meglio questo evento, come gestirlo, come fare in modo di renderlo davvero
> giocabile, l'evento deve trovarsi dentro il riquadro, invece vedo apparire
> cerchi rossi sull'interfaccia di combattimento, quando parte un evento
> ovviamente deve avere un riquadro suo da inizio evento a fine, ogni pugno deve
> rimanere visibile per 2 secondi, e ne deve apparire un altro ogni secondo

Prima si è studiato, poi si è costruito. Questo è lo studio, con le fonti e
con quello che ne è venuto fuori.

---

## 1. Cosa c'era, misurato

| cosa | com'era | perché era un difetto |
|---|---|---|
| dove stava | uno strato **trasparente** che copiava il rettangolo del box e ci si stendeva sopra | sotto restavano ECG, Morale/Stress, MATTANZA/BOND, i comandi: i pugni ci atterravano in mezzo (è lo scatto di Bru) |
| quando valeva il clic | ogni pugno era un `Button` | un Button di Godot scatta al **rilascio** (vedi §3): la parata arrivava in ritardo di tutto il clic |
| il bersaglio | il rettangolo del Button | gli angoli del quadrato contavano, e lì a schermo non c'è niente |
| i tempi | visibile 0,75 s, uno ogni 0,55 s che scendeva a 0,30 s, con ±35% di sbandamento | illeggibile: Bru lo aveva già detto una volta («scompaiono troppo velocemente») |
| leggere e parare | si parava per l'80% del tempo in cui si vedeva | un numero solo: più tempo per leggere voleva dire più tempo per parare, quindi l'unico modo di renderlo difficile era renderlo illeggibile |
| i nodi | dodici `Button` creati a ogni raffica e distrutti alla fine | allocazioni proprio nel momento in cui mirate |

---

## 2. osu!: leggere e parare sono due numeri diversi

osu! è il gioco che ha risolto questo problema meglio di chiunque, da quasi
vent'anni (è del 2007): cerchi che compaiono sullo schermo e vanno cliccati al momento
giusto. Le fonti sono primarie — la loro wiki e il loro **codice sorgente**,
presi dai repository (`ppy/osu-wiki`, `ppy/osu`).

**Approach Rate — il tempo per LEGGERE** (`wiki/Beatmap/Approach_rate`):

> The duration of a hit object that stays visible on the screen (without mods)
> ranges from 1800ms at AR0 to 450ms at AR10.

Nel sorgente (`OsuHitObject.cs`): `PREEMPT_MIN = 450`, `PREEMPT_MID = 1200`,
`PREEMPT_MAX = 1800`.

**Overall Difficulty — il tempo per PARARE** (`wiki/Beatmap/Overall_difficulty`):

| giudizio | finestra (ms, ± attorno al momento giusto) |
|--:|:--|
| 300 | `80 - 6 × OD` |
| 100 | `140 - 8 × OD` |
| 50 | `200 - 10 × OD` |

Cioè a OD0 la finestra più larga è ±200 ms, a OD10 la più stretta ±20 ms.
Nel sorgente (`OsuHitWindows.cs`) c'è anche `MISS_WINDOW = 400`: un clic più
di 400 ms in anticipo non viene nemmeno giudicato.

**Il cerchio di avvicinamento** (`DrawableHitCircle.cs`): parte a `Scale = 4`
e si stringe con `ApproachCircle.ScaleTo(1f, HitObject.TimePreempt)` — cioè
arriva sul bersaglio in esattamente il tempo di lettura. Dalla wiki
(`Hit_object/Hit_circle`): «Once the approach circle overlaps the hit circle,
the player must click or tap the hit circle».

**Notelock** (`Judgement/Notelock`): se due cerchi si sovrappongono, il
secondo aspetta che il primo sia giudicato.

### Cosa se ne ricava

I due secondi di Bru sono **più di AR0**: più leggibile di qualunque mappa di
osu!. E allora la difficoltà non può più stare nella fretta — deve stare nel
momento. È esattamente la separazione di osu!.

---

## 3. Godot: il clic, il tempo, i nodi

Fonti: la documentazione ufficiale (repository `godotengine/godot-docs`) e la
scheda delle classi nel sorgente del motore 4.4 (`godotengine/godot`,
`doc/classes/`).

**Il Button scatta al rilascio.** `BaseButton.xml`: `action_mode` ha
`default="1"`, che è `ACTION_MODE_BUTTON_RELEASE`:

> Require a press and a subsequent release before considering the button
> clicked.

E il segnale `pressed` «is on `button_down` if `action_mode` is
`ACTION_MODE_BUTTON_PRESS` and on `button_up` otherwise». In un gioco di
tempismo è un ritardo regalato.

**Lo schermo è in ritardo.** `tutorials/audio/sync_with_audio.rst`:

> Graphics APIs display two or three frames late.

A 60 Hz sono 33–50 ms: chi preme quando *vede* il cerchio chiudersi preme
sempre un po' tardi.

**Ogni nodo costa.** `tutorials/performance/cpu_optimization.rst`:

> every node has a cost. [...] Each node is handled individually in the Godot
> renderer. Therefore, a smaller number of nodes with more in each can lead to
> better performance.

**Il primo disegno può scattare.** `tutorials/performance/pipeline_compilations.rst`:
con il renderer Compatibility l'unico rimedio è «preloading materials,
shaders, and particles by displaying them for at least one frame».

**Disegnare a ogni fotogramma** (`tutorials/2d/custom_drawing_in_2d.rst`): si
chiama `queue_redraw()` quando serve ridisegnare, anche a ogni fotogramma per
un'animazione.

---

## 4. Accessibilità

Qui i siti diretti erano bloccati e ho letto **solo le sintesi della ricerca
web**, non i testi interi. Le riporto come tali.

- **Game Accessibility Guidelines**, *Include an option to adjust the game
  speed*: i problemi di tempismo preciso si alleviano molto con una scelta
  della velocità di gioco.
  <https://gameaccessibilityguidelines.com/include-an-option-to-adjust-the-game-speed/>
- **Xbox Accessibility Guideline 107**: evitare le meccaniche che chiedono
  molte pressioni in poco tempo (i QTE), o dare un'alternativa.
  <https://learn.microsoft.com/en-us/gaming/accessibility/xbox-accessibility-guidelines/107>
- **Xbox Accessibility Guideline 116** (limiti di tempo): i tempi che sono il
  cuore della meccanica **non** sono coperti da questa linea guida.
  <https://learn.microsoft.com/en-us/gaming/accessibility/xbox-accessibility-guidelines/116>
- AbleGamers, *Slow It Down*:
  <https://accessible.games/accessible-player-experiences/challenge-patterns/slow-it-down/>

---

## 5. Cosa è stato fatto, e perché

**Un riquadro suo.** La raffica è una faccia del pannello, come i comandi e il
parlato: quando parte, le altre si spengono (anche MATTANZA e BOND), e lei è
opaca, con la fascia rossa del titolo e il contatore «3 / 12». Ha un inizio
(«Clicca ogni pugno quando il cerchio si chiude su di lui.») e una fine
(«Fermati 9 su 12 — 7 in pieno · 2 di striscio · 3 a segno»), nello stesso
riquadro. Un clic salta l'inizio e chiude la fine: animare sì, sbarrare mai.

**I tempi di Bru, come regola.** Un pugno ogni 1,0 s, ognuno visibile 2,0 s:
mai più di due insieme. Lo sbandamento c'è ancora, ma è un parametro della
raffica (`"sbandamento"`), di serie zero.

**Leggere e parare separati.** Attorno a ogni pugno c'è il cerchio di
avvicinamento, che si chiude in esattamente due secondi. Il giudizio:

| quando clicchi | cosa succede |
|---|---|
| prima che compaia | niente |
| fra la comparsa e 0,20 s prima dell'impatto | **di striscio**: metà danno (per eccesso) |
| da 0,20 s prima a 0,12 s dopo l'impatto | **parata piena**: zero danno |
| dopo | ti ha preso: danno pieno |

Un clic su un pugno fa **sempre** qualcosa (non esiste il clic in cui non
succede niente), e pararli tutti senza danno resta difficile — che è il
«senno sei invincibile» di Bru. La finestra piena (0,32 s) sta fra l'«ok» e il
«meh» di OD0: larga, perché è un tutorial e la mano deve anche arrivarci. È
asimmetrica per il ritardo dello schermo (§3). Si giudica **una volta sola**:
cliccare a ripetizione non paga.

**Il clic vale quando premi**, e solo dentro il **cerchio** (più 8 pixel di
tolleranza, legge di Fitts). Se due pugni si toccano vince quello che arriva
prima, come nel notelock di osu!.

**Un nodo solo che disegna.** I pugni sono disegni dentro un nodo; le poche
scritte (PARATA, DI STRISCIO, COLPITO) sono quattro etichette create una volta e
riusate. Durante la raffica non si crea e non si distrugge niente. Il disegno
del pugno si carica quando la raffica viene collegata, non al primo pugno.

**Il riscontro.** Parata piena: anello bianco che si allarga; di striscio:
giallo; preso: lampo rosso. Le scritte hanno il contorno scuro (la stessa
fasciatura della mappa) perché possono finire sopra un pugno o sopra il lampo.
Con il movimento ridotto restano le parole, spariscono gli anelli.

**Tastiera.** Invio para il pugno che sta per arrivare, con le stesse finestre.

---

## 6. Quello che resta, e che decide Bru

- **Un'opzione di velocità dei minigiochi** (§4). Le manopole ci sono già nei
  dati (`durata`, `intervallo`, `finestra_prima`, `finestra_dopo`); manca la
  voce nelle Opzioni che le moltiplichi. È il prossimo passo per
  l'accessibilità.
- **La parata piena ha un premio?** Oggi toglie tutto il danno e basta. Potrebbe
  caricare la Mattanza, o l'hype. È una scelta di bilanciamento, non tecnica.
- **L'accelerazione verso la fine** non c'è più: Bru ha chiesto «uno al
  secondo». Se la rivuole, è `"intervallo_finale"` nei dati della raffica.
- **Il disegno del pugno**: `art/minigiochi/pugno.png` prende il posto del
  cerchio rosso senza toccare il codice.
- **I numeri delle finestre** vanno confermati giocando: 0,20 s e 0,12 s sono
  ragionati, non ancora provati da una mano vera.
- **Un caso limite, vecchio quanto lo scontro**: se una Mattanza finisce mentre
  la raffica è in corso, la sua riga di chiusura accende `AreaAvanza` (il
  bottone a tutto schermo che fa avanzare il testo), che sta sopra il pannello
  e si prenderebbe i clic sui pugni. Succedeva identico col vecchio strato. Non
  l'ho toccato alla cieca: va deciso se durante un minigioco il testo aspetta.
