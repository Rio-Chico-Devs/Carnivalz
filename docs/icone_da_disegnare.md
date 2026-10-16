# Le icone delle statistiche, se le disegni tu

Bru: «le faccio io le icone dammi le misure di cui hai bisogno». Queste sono le
misure. Il modello su cui disegnare è `art/interfaccia/statistiche/modello.svg`
(e `modello.png`, 1000 × 1000, per chi disegna a pixel).

## 1. Cosa consegnare

- **Nove icone**, coi nomi delle chiavi:
  - `hp`, `attacco`, `difesa`, `velocita`, `aura`: queste cinque le mostra già
    la scheda della squadra;
  - `intelligenza`, `forza_mentale`, `fattore`, `maestria_dominio`: le usano la
    crescita e la roulette.
- **Il formato:**
  - meglio l'**SVG** (vettoriale): ne ricavo io i PNG a ogni grandezza;
  - se non puoi, **PNG 512 × 512**.
- **Una tinta sola, piena, su trasparente.** Meglio bianca, va bene anche nera.
  - I vuoti sono buchi veri (trasparenti), non bianco sopra il nero.
  - Niente ombre, contorni, sfumature né texture. L'ombra arancio del timbro e
    il colore li mette il gioco.
- **Il quadrato intero**, anche se l'icona è più stretta: l'area viva conta
  nel file. Il gioco lo disegna a tutto riquadro, senza tagliare niente.

## 2. La griglia

Tutte le misure sono **su 100 unità**, il lato del quadrato:

| se lavori su | 1 unità vale |
|---|---|
| un riquadro 100 × 100 (Figma, Illustrator) | 1 px: le misure sono quelle |
| un PNG 512 × 512 | 5,12 px |
| il modello PNG 1000 × 1000 | 10 px |

Nel modello ci sono:

- **l'area viva**, il quadrato scuro da 4 a 96: niente ne esce;
- **le forme chiave** (le linee arancio chiaro), riportate dalle icone di
  Material:
  - il cerchio di diametro 83;
  - il quadrato di 75;
  - il rettangolo alto 67 × 83 e quello largo 83 × 67.
  Dicono quanto spazio prende di solito una forma tonda, quadrata, alta o
  larga. Una figura a punta o di sbieco può arrivare fino all'area viva;
- **la griglia di 10 e gli assi**;
- in alto a sinistra, fuori dall'area, **i due campioni**: il taglio (5) e il
  bordo (10).

## 3. Gli spessori

| cosa | quanto |
|---|---|
| **Taglio**: un vuoto fra due pezzi, o una linea in negativo | almeno **5** |
| **Bordo**: il contorno pieno di un oggetto (l'occhio, lo scudo) | **10** |
| Il pieno più sottile (un filo, un manico) | almeno **5** |
| Due contorni vicini | o si toccano, o stanno ad almeno **5** |
| Il pezzo più piccolo staccato dagli altri | almeno 5 × 5 |

Perché 5: nella scheda l'icona è alta 26 pixel (su un foglio di 1280 × 720).
Lì 5 unità sono 1,3 pixel, il minimo che si vede ancora come vuoto. Sotto, il
taglio si chiude e due pezzi diventano una macchia.

## 4. Il peso e il centro

Le nove devono sembrare **macchie uguali** quando le sfochi.

- **L'inchiostro** (la parte piena) fra il **27% e il 32%** del quadrato. Le
  nove di adesso stanno fra 0,275 e 0,311, la media è 0,295. Fra loro, al
  massimo l'8% di differenza.
- **Il centro visivo** (a metà fra il centro del suo ingombro e il centro della
  sua massa) entro 4 unità dal centro del quadrato. Una figura pesante in basso
  va alzata un poco.
- **La grandezza**: due figure con lo stesso inchiostro, una raccolta e una
  sparsa, non sembrano grandi uguali. Le nove di adesso hanno la massa sparsa in
  modo simile, entro il 10%.

Questi conti li faccio io sui tuoi file e ti dico cosa spostare.

## 5. Le grandezze a cui si vedono

Sul foglio di 1280 × 720. Il gioco lo ingrandisce allo schermo: a 1920 × 1080
tutto è una volta e mezza, a 3840 × 2160 tre volte.

| dove | quanto |
|---|---|
| la scheda della squadra | **26 px**, in un quadratino scuro, a tutto riquadro |
| la roulette e la crescita | da 24 a 64 px |
| il bivio, sbiadita dietro le due scelte | 640 px |

La prova da fare: **guardale a 26 pixel, chiare su scuro**. Se un dettaglio
sparisce, va ingrandito o tolto. Se vuoi tenere un dettaglio fine nella versione
grande, fammi anche una **versione piccola** con quel dettaglio tolto e i tagli
più larghi (9 unità): la uso sotto i 32 pixel.

## 6. Le curve

- Fra una curva e una retta, o fra due curve, **nessun gomito**: la tangente
  continua.
- **Pochi nodi**, messi agli estremi (in alto, in basso, a destra, a sinistra
  della curva), con le maniglie dritte. Più nodi, più bozzi.
- Le figure tonde vere sono cerchi, non curve tirate a mano.

## 7. Quando me le mandi

Le metto in `art/interfaccia/statistiche/<chiave>.png` (bianche): è il file che
la scheda legge già. Le misuro (area viva, peso, grandezza, centro, i tagli più
stretti) e ti scrivo cosa non torna. Poi le rimetto nelle proposte della
crescita al posto di quelle disegnate dal codice.
