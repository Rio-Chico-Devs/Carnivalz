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
