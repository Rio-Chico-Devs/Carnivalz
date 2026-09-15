# La schermata di combattimento

Questo documento esiste per un errore. Quando Bru ha mandato i disegni, quello
della schermata di **dialogo** è finito subito nel codice e nei dati — colori,
misure, il nastro, il box bianco — e infatti quella schermata è esattamente
com'era disegnata. Del **combattimento** invece è rimasto solo *come deve
funzionare*, sparso fra i commenti. Il *com'è fatto* non l'ha scritto nessuno,
e quando l'immagine non è più stata davanti agli occhi non c'era niente a cui
tornare.

Quindi: qui dentro ci va tutto quello che Bru ha detto della schermata di
combattimento, con le sue parole, **prima** di scrivere una riga di codice.

---

## La disposizione

> ✅ **fatta** — `scripts/combattimento/Plancia.gd` costruisce tutto da queste misure

Misurata sui tre disegni di Bru, che sono 1920×1080. **Tutto è in frazioni** di
larghezza e altezza, non in pixel: la finestra può essere di qualunque misura e
il disegno deve restare quello.

I numeri stanno in `data/stile.json` sotto `combattimento`, non nel codice.

```
┌─────────────────┐  ┌───────┐ ┌───────┐ ┌───────┐
│                 │  │ slot1 │ │ slot2 │ │ slot3 │
│   BOX NEMICO    │  └───────┘ └───────┘ └───────┘
│  (il disegno)   │   HP ▬▬▬    HP ▬▬▬    HP ▬▬▬
│                 │   AURA ▬▬   AURA ▬▬   AURA ▬▬
│                 │   ﹇ ▬▬▬     ﹇ ▬▬▬     ﹇ ▬▬▬
│                 │      ▪          ▪          ▪    ← status
└─────────────────┘  ┌────────────────────────────┐
┌─────────────────┐  │ ┌──────────┐  ATTACCHI     │
│ NOME SU ROSSO   │  │ │   ECG    │  DIFESA       │
│ HP: ???         │  │ └──────────┘  SKILL        │
└─────────────────┘  │ Morale  Stress OGGETTI     │
                     │ [MATTANZA][BOND] FUGA      │
                     └────────────────────────────┘
```

| | x | y | largh. | alt. |
|---|--:|--:|--:|--:|
| box nemico | 0.021 | 0.023 | 0.372 | 0.695 |
| scheda nemico | 0.021 | 0.745 | 0.363 | 0.218 |
| — la sua fascia rossa | | | | 0.30 della scheda |
| slot compagni (fila) | 0.407 | 0.023 | 0.585 | 0.347 |
| — un ritratto | | | 0.191 | |
| — lo stacco fra due | | | 0.005 | |
| barre | | 0.384 | | 0.079 |
| status | | 0.489 | 0.083 | 0.083 |
| quadrante | 0.409 | 0.606 | 0.573 | 0.357 |

E dentro il quadrante, in frazioni **del quadrante**:

| | x | y | largh. | alt. |
|---|--:|--:|--:|--:|
| ECG | 0.032 | 0.065 | 0.522 | 0.338 |
| Morale / Stress | 0.036 | 0.470 | | |
| MATTANZA | 0.032 | 0.610 | 0.236 | 0.234 |
| BOND | 0.305 | 0.610 | 0.250 | 0.234 |
| lista comandi | 0.582 | 0.100 | | |

### Il linguaggio visivo

È lo stesso della schermata di dialogo: **fondo nero**, pannelli col **bordo
nero spesso** e l'interno **bianco**. Il colore acceso solo dove conta.

| | |
|---|---|
| barra HP | arancio ambra |
| barra AURA | lilla chiaro |
| barra dominio | rosso, e la sua etichetta è un **ricciolo** rosso, non una parola |
| fascia col nome del nemico | rossa, scritta bianca in maiuscoletto |
| gli `???` dell'HP sconosciuto | rossi |
| ECG | pannello scuro (grigio-bruno), linea del colore della vita |
| MATTANZA | tassello nero, scritta rossa sgranata |
| BOND | tassello nero, scritta arancio |
| status | tassello nero quadrato, simbolo colorato |

### Due cose decise leggendo il disegno

**Lo sfondo è bianco.** Nei tre disegni la schermata sta su una pagina bianca, e
non è un dettaglio del mockup: è quella pagina che fa *esistere* i bordi neri
spessi dei pannelli. Provata su nero — che è il fondo della schermata di
dialogo — i bordi sparivano e restavano quattro rettangoli che galleggiavano nel
buio. Il riquadro del nemico resta nero dentro: è l'unico, e ci sta la creatura.

Se il fondo deve essere nero è un valore solo in `data/stile.json`
(`sfondo_combattimento`), ma allora i bordi vanno ripensati.

### Una cosa che il disegno dice diversamente

Nel disegno la seconda barra è etichettata **HYPE**. La decisione successiva di
Bru la sposta: «hp è hp, la seconda sarà **aura** non hype, la terza sarà la
barra dominio, e l'hype è l'xp come prima [...] e così è deciso definitivamente».

Il disegno è più vecchio di quella frase, quindi vale la frase: sullo schermo
c'è scritto **AURA**. Se invece deve restare HYPE, è una parola in
`data/stile.json` e si cambia in un secondo.

### Le tre facce del quadrante

I tre disegni mostrano lo stesso rettangolo che fa tre cose diverse:

1. **comandi** — ECG, Morale/Stress, MATTANZA e BOND, e la lista verticale
   ATTACCHI · DIFESA · SKILL · OGGETTI · FUGA
2. **lista** — le voci di un comando che ne ha una (gli attacchi, le skill, gli
   oggetti), disposte su più colonne
3. **parlato e minigiochi** — la narrazione, i dialoghi, e i minigiochi

---

## I combattenti

- **Fino a 3 slot per i compagni.**
- **Un nemico solo.** «non ci saranno più di un nemico». Nel box grande c'è il
  disegno del nemico.
- Ogni nemico ha **le sue dinamiche di combattimento e i suoi minigiochi**.
- Un'orda è **un nemico solo** che si indebolisce perdendo vita: «se per esempio
  abbiamo un orda di zombie, quel combattimento funzionerà che più perde vita il
  nemico orda di zombie più diventa debole».

## Le quattro misure, decise una volta per tutte

Bru: «hp è hp, la seconda sarà aura non hype, la terza sarà la barra dominio, e
l'hype è l'xp come prima, è l'aura che va consumata per le mosse, si riempie
dopo il combattimento o con oggetti o skill particolari di alcuni personaggi, la
barra dominio misura quando scatta la mattanza, e così è deciso definitivamente».

| | cos'è | come si riempie |
|---|---|---|
| **HP** | la vita | cure, oggetti |
| **Aura** | il mana: si spende per le mosse, più la mossa è forte più ne vuole | **non** dentro lo scontro: dopo, o con oggetti, o con skill particolari |
| **Dominio** | misura quando scatta la Mattanza | combattendo |
| **Hype** | è l'XP, la progressione | come prima |

## L'ECG

> ✅ **fatto** — `scripts/combattimento/Ecg.gd` (le regole) e `Tracciato.gd` (il disegno)

Bru: «vogliamo una sorta di ecg che si muova simulando le condizioni dei
personaggi, se ha tanto stress ci vuole che sia nervoso con ecg irregolare e
movimentato, la linea è rossa quando ferito gravemente meno del 25% di hp,
gialla sopra il 25% ma meno del 75% verde sopra il 75%».

Due informazioni in una riga sola: il **colore** dice la vita, il **movimento**
dice lo stress. Gli estremi cadono dove li ha messi lui — al 25% esatto è già
gialla («rossa *sotto* il 25%»), al 75% esatto è ancora gialla («verde *sopra*
il 75%»). Chi è a terra fa una riga dritta.

I tre colori stanno in `data/stile.json` (`ecg_verde`, `ecg_giallo`, `ecg_rosso`).

## Gli status

«quei riquadri vicino alla vita sono gli status».

## Il menu dei comandi

«se premi su attacco vedi una lista degli attacchi disponibili, stessa cosa le
skill, invece per difesa non ce lista, per fuga neanche, per oggetti invece la
lista di oggetti utilizzabili».

| comando | apre una lista? |
|---|---|
| Attacco | sì — gli attacchi disponibili |
| Skill | sì |
| Difesa | **no** |
| Fuga | **no** |
| Oggetti | sì — quelli utilizzabili |

## BOND e MATTANZA

«quando uno dei personaggi è pronto per legare col nemico il tasto bond si
illumina, quando la mattanza è pronta si illumina quella».

Due tasti che **non** si accendono a comando: si accendono quando la cosa è
pronta, e finché non lo sono stanno spenti. È l'unico avviso che il giocatore
riceve, quindi deve vedersi senza cercarlo.

## Il quadrante

> ✅ **fatto per la parte minigiochi** — `scripts/combattimento/Minigioco.gd`

«quel quadrante sotto avrà varie funzioni durante il turno del nemico dovrai
completare dei minigiochi per salvarti dai suoi colpi o diminuire i danni
complessivi a seconda dell'attacco lanciato».

E ci passa anche tutto il parlato: «il suo dialogo appare dove mettiamo i
minigiochi e così anche quelli dei nemici e protagonisti più la narrazione del
combattimento».

Una superficie sola che a turno **racconta** e **gioca**. Oggi è il box del
combattimento, e il minigioco ci si stende sopra.

## Il box del nemico

«nel box del boss ci vanno le info che si scoprono con lo studio».

Quindi quel riquadro non è decorazione: è il tecno log che si riempie strato per
strato mentre studi, e all'inizio è quasi vuoto.

---

## Disposizione

*(da riempire guardando il disegno)*


---

# Analisi, componente per componente

Fatta dopo aver costruito la schermata, **misurando** invece di dare pareri: i
contrasti sono rapporti WCAG calcolati sui colori veri di `data/stile.json`, le
misure del testo vengono dai numeri della plancia. Dove ho consultato linee
guida pubbliche l'ho scritto.

Tre difetti erano reali e misurabili, e riguardavano proprio le cose più
urgenti. Sono già sistemati. Il resto è elencato con la sua diagnosi.

## Quello che è stato corretto

### 1. La linea rossa dell'ECG era la meno visibile di tutte

Contrasto misurato: **1.91**. Il rosso su quel bruno erano quasi lo stesso
colore. È il segnale che dice *stai per morire*, ed era il meno leggibile della
schermata — mentre il giallo stava a 5.13 e il verde a 4.44.

Fondale portato da `#5a4a46` a `#1e1817`: il rosso passa a **4.00**, il giallo a
10.5, il verde a 9.2. Resta un bruno scuro, come nel disegno.

### 2. Di una barra non si capiva quanto fosse piena

Contrasto fra il pieno e il vuoto: **HP 1.07, AURA 1.05**. Cioè il pieno e il
vuoto avevano quasi la stessa luminosità: si distinguevano *solo* dalla tinta.
Per una barra è il difetto peggiore possibile — la sua unica funzione è dire
quanto ne resta.

Traccia vuota da `#c9c9c9` a `#333333`: HP **7.16**, AURA **7.30**, dominio
**3.19**.

### 3. MATTANZA e BOND da spenti non si vedevano proprio

Contrasto **1.85** sul tassello nero: non si capiva nemmeno che ci fosse un
tasto. Nel disegno si vedono anche da spenti. Portato a **3.24**.

### 4. Il colore non può essere l'unica cosa che dice la vita

[Le linee guida sull'accessibilità dei giochi](https://gameaccessibilityguidelines.com/ensure-no-essential-information-is-conveyed-by-a-fixed-colour-alone/)
sono esplicite: nessuna informazione essenziale deve passare da un colore solo.
Fra l'8% e il 10% dei maschi non distingue bene rosso e verde, e un segnale
costruito su *verde = tutto bene / rosso = stai per morire* per loro non esiste.

Misurato sulla nostra palette: fra verde e giallo passano **0.086 di
luminosità** — senza il colore sono lo stesso grigio.

Adesso la linea lo dice due volte: **col colore e con lo spessore** (1.6 / 2.4 /
3.4 px). Una linea grossa si vede anche in bianco e nero. Gli status erano già a
posto: sono simboli diversi, non tre cerchi di tre colori.

### 5. Il combattimento si giocava solo col mouse

Ogni voce del menu aveva `focus_mode = NONE`. Il codice che dava il fuoco alla
prima voce utile **c'era già** e non aveva mai funzionato, perché un bottone col
fuoco spento il fuoco non lo prende. Adesso le frecce scorrono e INVIO sceglie,
e la voce col fuoco porta una barretta rossa a sinistra — una forma, non solo un
colore.

Trovandolo sono venuti fuori altri due difetti che nessuno avrebbe visto:

- **il menu si riempiva dentro una faccia nascosta.** La plancia nasceva sul
  parlato e non la cambiava mai nessuno: le voci esistevano e non si vedevano.
  Adesso il menu, accendendosi, chiede al pannello di mostrarsi.
- **la voce col fuoco spariva.** Godot per un bottone col fuoco usa
  `font_focus_color`, che veniva dal tema del resto del gioco — fatto per il
  fondo scuro. Sul bianco del quadrante la parola non c'era più: restava la
  barretta e basta.

### 6. Il velo rosso del pericolo non si spegneva

Trovato fotografando: quattro bordi rossi addosso a una squadra a vita piena. Si
confrontava *"è cambiato il numero?"* quando l'invariante vera è *"lo schermo
mostra un numero diverso da quello giusto?"*.

## Quello che non ho toccato, e perché

### Di chi sono ECG, Morale e Stress?

Sono singolari, ma i personaggi sono tre. Si legge la condizione di **chi ha il
turno** — e il turno si vede, perché gli altri slot si sbiadiscono. Ma su fondo
bianco *sbiadire* fa sembrare gli altri **disattivati**, non "non tocca a loro":
funzionava sul nero, non funziona sul bianco. Andrebbe girato — una cornice
accesa su chi tocca invece di spegnere gli altri.

### L'aura senza numero

Per gli HP la forma basta. Per l'**aura** no: se una mossa costa 5 e devi
decidere se puoi permettertela, una barra ti fa tirare a indovinare. Il numero
servirebbe **solo su chi ha il turno** — uno da leggere, non tre.

### MATTANZA e BOND spariscono quando apri una lista

Il quadrante fa tre mestieri. Se scegli un attacco proprio mentre la mattanza
diventa pronta, il segnale non lo vedi: è l'unico avviso che arriva.

### Il testo a finestre piccole — falso allarme

Il progetto usa `stretch/mode = canvas_items` a 1280×720: la tela è sempre
quella e viene scalata. Un testo di 14px resta 14px logici a qualunque misura di
finestra. Non c'è niente da sistemare.

### Il resto della palette, misurato

| | rapporto | |
|---|--:|---|
| testo delle barre, voci del menu, Morale/Stress | 16.87 | ✅ |
| BOND acceso sul tassello | 10.36 | ✅ |
| iniziale del ripiego | 6.21 | ✅ |
| MATTANZA accesa sul tassello | 4.58 | ✅ |
| nome del nemico sulla fascia rossa | 3.94 | ✅ come testo grande |
| voce di menu spenta | 3.08 | ✅ |

---

# Secondo giro: i bug dentro il codice

Il primo giro guardava com'è fatta la schermata. Questo guarda **come si
comporta mentre gira** — e qui i difetti si misurano col cronometro, non col
righello.

## 1. L'ECG rallentava sempre di più, e non smetteva

Il tracciato teneva in memoria **ogni battito da quando lo scontro era
cominciato**, e li rileggeva tutti per ogni campione, sessanta volte al secondo.
Un battito più vecchio di un intervallo non contribuisce niente — `onda()` gli
risponde zero — quindi erano riletture di roba morta.

Misurato: in due minuti di scontro l'elenco passa da **11 a 196** battiti. Dopo
cinque minuti sono settecento, riletti quarantamila volte al secondo. E il conto
peggiora da solo più lo scontro dura: uno scontro lungo — cioè un boss —
rallentava proprio quando conta.

## 2. Il disco si interrogava a ogni colpo

Misurato: cercare un ritratto lungo tutta la catena di ripiego costa **0.10 ms**,
un controllo d'esistenza **0.024 ms**. Sembra niente finché non si guarda quante
volte succedeva:

- **il ritratto** si ricercava a ogni aggiornamento di scheda — uno per colpo,
  per stato, per battuta, per tre compagni — anche quando la faccia non doveva
  cambiare affatto;
- **le icone di stato** chiedevano al disco *dentro il disegno*, cioè
  potenzialmente a ogni fotogramma: nove domande per fotogramma con tre compagni.

Il punto non è il millisecondo: è che quelle chiamate toccano il disco, e un
disco che si sveglia in mezzo a uno scontro in tempo reale si sente. Adesso la
faccia si cerca solo quando cambia la condizione, e i simboli si chiedono una
volta sola.

## 3. Tutto lo slot si rifaceva a ogni colpo

`imposta_status` rimetteva in riga ritratto, tre barre e tre riquadri a ogni
aggiornamento. Ma i riquadri si spostano solo quando cambia il **loro numero**.

## 4. Il lampo di un colpo copriva le barre

Trovato fotografando un colpo a metà volo: tingendo tutto lo slot, nell'istante
in cui prendi un colpo — che è esattamente l'istante in cui guardi quanta vita ti
resta — **HP, AURA e dominio diventavano tutti viola**. Adesso reagisce la
faccia, che è la parte grande ed è quella che deve "reagire".

## 5. Mancava l'opzione per ridurre il movimento

[Le linee guida](https://gameaccessibilityguidelines.com/avoid-flickering-images-and-repetitive-patterns/)
e la [guida Xbox 118](https://learn.microsoft.com/en-us/gaming/accessibility/xbox-accessibility-guidelines/118)
mettono "disattiva la scossa dello schermo" fra le opzioni **da offrire**, non
fra quelle carine da avere: scossa e lampi sono fra i motivi per cui una persona
con mal di movimento, emicrania o epilessia fotosensibile smette di giocare. Le
linee guida segnalano anche che le combinazioni ad alto contrasto più rischiose
sono proprio **rosso su nero** — che è metà della nostra palette.

Il gioco aveva già testo grande, alto contrasto e velocità del testo. Questa
mancava, e il combattimento trema a ogni colpo.

**Riduci il movimento** toglie la scossa e trasforma il lampo in una tinta che
arriva e se ne va piano. Non toglie nessuna informazione: il numero del danno, il
colore dell'elemento e il suono restano.

## Una cosa che non ho chiuso

Le prove finiscono con `ObjectDB instances leaked at exit`. Ci ho provato: il
riproduttore minimo — costruire e distruggere una plancia — **si pianta a sua
volta**, e non sono arrivato in fondo. Resta aperto, e non è una cosa che si
vede giocando: è roba che non viene liberata quando il gioco si chiude.

## Fonti

- [Game Accessibility Guidelines — nessuna informazione da un colore solo](https://gameaccessibilityguidelines.com/ensure-no-essential-information-is-conveyed-by-a-fixed-colour-alone/)
- [Xbox Accessibility Guideline 103](https://learn.microsoft.com/en-us/gaming/accessibility/xbox-accessibility-guidelines/103)
- [Designing a practical HUD](https://rocketbrush.com/blog/designing-practical-and-pretty-hud-in-video-games)
- [Game Accessibility Guidelines — evitare immagini lampeggianti](https://gameaccessibilityguidelines.com/avoid-flickering-images-and-repetitive-patterns/)
- [Xbox Accessibility Guideline 118 — fotosensibilità](https://learn.microsoft.com/en-us/gaming/accessibility/xbox-accessibility-guidelines/118)
- [Xbox Accessibility Guideline 117 — mal di movimento](https://learn.microsoft.com/en-us/xbox/accessibility/xbox-accessibility-guidelines/117)
- [Motion sickness accessibility in video games](https://madelinemiller.dev/blog/motion-sickness-accessibility/)
