# Le sagome della strada A: il canone e le misure (generato, non scrivere qui a mano)

Rigenera con `./prove/sagome_a.sh`. Il codice è `prove/SagomeA.gd`; i file da misurare
sono in `art/interfaccia/statistiche/strada_a/`: un SVG e un PNG per sagoma, 480 × 480,
nero su trasparente. Nell'SVG ogni sagoma è un percorso solo con `fill-rule="evenodd"`.

## Il canone

| | moduli | pixel a 480 |
|---|---|---|
| la griglia | 20 × 20 | 480 × 480 |
| il modulo | 1 | 24 |
| il margine (l'area viva va da 1 a 19) | 1 | 24 |
| **C**, il taglio: ogni vuoto, ogni distacco fra due parti | 1 | 24 |
| **T**, il tratto: ogni parte sottile, e quello che separa un taglio dal bordo | 2 | 48 |

- **Gli angoli dei lati:** 0°, 45°, 90°, 135°; e solo per il fulmine e la brace la pendenza
  2 : 1 (63,43° e 116,57°).
- **Dritte:** niente piega del corsivo. La piega deformerebbe gli spessori: a 45° un tratto
  verrebbe più grosso del 10% e quello opposto più sottile del 10%.
- **Le coordinate** dei pieni stanno sul mezzo modulo (12 pixel). Non ci stanno quelle girate
  (la spada è costruita dritta e girata di 45°, i raggi corti dell'aura) e quelle fatte
  rientrando un bordo di T o di C: lì comanda la distanza.
- **Gli anelli:** livello 0 il pieno, 1 i tagli dentro il pieno, 2 i pieni dentro i tagli,
  3 i fori dentro quelli.
- **La pienezza** è l'inchiostro sul quadrato dell'area viva (18 × 18 moduli).

## Il peso, tutte insieme

| sagoma | pienezza | dalla media | ingombro (moduli) |
|---|---|---|---|
| Punti vita | 0.362 | +5.3% | 15 × 12.5 |
| Attacco | 0.314 | -8.6% | 17.324 × 17.324 |
| Difesa | 0.369 | +7.5% | 12 × 14 |
| Velocità | 0.346 | +0.6% | 18 × 18 |
| Intelligenza | 0.317 | -7.8% | 18 × 12 |
| Forza mentale | 0.367 | +6.7% | 13 × 14.5 |
| Fattore | 0.376 | +9.3% | 14 × 17 |
| Maestria del dominio | 0.327 | -4.8% | 17 × 10 |
| Aura | 0.315 | -8.4% | 18 × 18 |

Media 0.344.

## Punti vita (`hp`)

- **File:** `art/interfaccia/statistiche/strada_a/hp.svg` e `.png`
- **Ingombro:** da 2.5,3.5 a 17.5,16 moduli (360 × 300 pixel a 480)
- **Pienezza:** 0.362 (inchiostro 117.25 moduli quadrati)
- **Direzioni dei lati:** 0°, 45°, 90°, 135°
- **Le parti, come sono costruite:**
  - luce (taglio): 1 moduli (24 px)
  - luce, lunga: 1.5 moduli (36 px)
  - fra la luce e il bordo: 2 moduli (48 px)
- **Gli spessori, misurati sul disegno finito** (la distanza minima fra i bordi):
  - taglio dal pieno che lo contiene: 2 moduli (48 px)

I lati, anello per anello, in pixel a 480:

| anello | lato | da | a | lungo | direzione |
|---|---|---|---|---|---|
| pieno 1 | 1 | 240, 144 | 300, 84 | 84.853 | 135° |
| pieno 1 | 2 | 300, 84 | 360, 84 | 60 | 0° |
| pieno 1 | 3 | 360, 84 | 420, 144 | 84.853 | 45° |
| pieno 1 | 4 | 420, 144 | 420, 204 | 60 | 90° |
| pieno 1 | 5 | 420, 204 | 240, 384 | 254.558 | 135° |
| pieno 1 | 6 | 240, 384 | 60, 204 | 254.558 | 45° |
| pieno 1 | 7 | 60, 204 | 60, 144 | 60 | 90° |
| pieno 1 | 8 | 60, 144 | 120, 84 | 84.853 | 135° |
| pieno 1 | 9 | 120, 84 | 180, 84 | 60 | 0° |
| pieno 1 | 10 | 180, 84 | 240, 144 | 84.853 | 45° |
| taglio 1 | 1 | 111.213, 160.669 | 136.669, 135.213 | 36 | 135° |
| taglio 1 | 2 | 136.669, 135.213 | 153.64, 152.184 | 24 | 45° |
| taglio 1 | 3 | 153.64, 152.184 | 128.184, 177.64 | 36 | 135° |
| taglio 1 | 4 | 128.184, 177.64 | 111.213, 160.669 | 24 | 45° |

## Attacco (`attacco`)

- **File:** `art/interfaccia/statistiche/strada_a/attacco.svg` e `.png`
- **Ingombro:** da 1.338,1.338 a 18.662,18.662 moduli (415.779 × 415.779 pixel a 480)
- **Pienezza:** 0.314 (inchiostro 101.75 moduli quadrati)
- **Direzioni dei lati:** 0°, 45°, 90°, 135°
- **Le parti, come sono costruite:**
  - lama: 5 moduli (120 px)
  - scanalatura (taglio): 1 moduli (24 px)
  - filo della lama: 2 moduli (48 px)
  - guardia: 2 moduli (48 px)
  - impugnatura: 2 moduli (48 px)
- **Gli spessori, misurati sul disegno finito** (la distanza minima fra i bordi):
  - taglio dal pieno che lo contiene: 2 moduli (48 px)

I lati, anello per anello, in pixel a 480:

| anello | lato | da | a | lungo | direzione |
|---|---|---|---|---|---|
| pieno 1 | 1 | 447.889, 116.963 | 227.272, 337.581 | 312 | 135° |
| pieno 1 | 2 | 227.272, 337.581 | 278.184, 388.492 | 72 | 45° |
| pieno 1 | 3 | 278.184, 388.492 | 244.243, 422.434 | 48 | 135° |
| pieno 1 | 4 | 244.243, 422.434 | 167.875, 346.066 | 108 | 45° |
| pieno 1 | 5 | 167.875, 346.066 | 116.963, 396.978 | 72 | 135° |
| pieno 1 | 6 | 116.963, 396.978 | 116.963, 447.889 | 50.912 | 90° |
| pieno 1 | 7 | 116.963, 447.889 | 32.111, 447.889 | 84.853 | 0° |
| pieno 1 | 8 | 32.111, 447.889 | 32.111, 363.037 | 84.853 | 90° |
| pieno 1 | 9 | 32.111, 363.037 | 83.022, 363.037 | 50.912 | 0° |
| pieno 1 | 10 | 83.022, 363.037 | 133.934, 312.125 | 72 | 135° |
| pieno 1 | 11 | 133.934, 312.125 | 57.567, 235.757 | 108 | 45° |
| pieno 1 | 12 | 57.567, 235.757 | 91.508, 201.816 | 48 | 135° |
| pieno 1 | 13 | 91.508, 201.816 | 142.419, 252.728 | 72 | 45° |
| pieno 1 | 14 | 142.419, 252.728 | 363.037, 32.111 | 312 | 135° |
| pieno 1 | 15 | 363.037, 32.111 | 447.889, 32.111 | 84.853 | 0° |
| pieno 1 | 16 | 447.889, 32.111 | 447.889, 116.963 | 84.853 | 90° |
| taglio 1 | 1 | 363.037, 99.993 | 380.007, 116.963 | 24 | 45° |
| taglio 1 | 2 | 380.007, 116.963 | 227.272, 269.698 | 216 | 135° |
| taglio 1 | 3 | 227.272, 269.698 | 210.302, 252.728 | 24 | 45° |
| taglio 1 | 4 | 210.302, 252.728 | 363.037, 99.993 | 216 | 135° |

## Difesa (`difesa`)

- **File:** `art/interfaccia/statistiche/strada_a/difesa.svg` e `.png`
- **Ingombro:** da 4,3 a 16,17 moduli (288 × 336 pixel a 480)
- **Pienezza:** 0.369 (inchiostro 119.686 moduli quadrati)
- **Direzioni dei lati:** 0°, 45°, 90°, 135°
- **Le parti, come sono costruite:**
  - scaglione (taglio): 1 moduli (24 px)
  - fra lo scaglione e la punta: 4 moduli (96 px)
  - fra lo scaglione e i fianchi: 2 moduli (48 px)
- **Gli spessori, misurati sul disegno finito** (la distanza minima fra i bordi):
  - taglio dal pieno che lo contiene: 2 moduli (48 px)

I lati, anello per anello, in pixel a 480:

| anello | lato | da | a | lungo | direzione |
|---|---|---|---|---|---|
| pieno 1 | 1 | 120, 72 | 360, 72 | 240 | 0° |
| pieno 1 | 2 | 360, 72 | 384, 96 | 33.941 | 45° |
| pieno 1 | 3 | 384, 96 | 384, 264 | 168 | 90° |
| pieno 1 | 4 | 384, 264 | 240, 408 | 203.647 | 135° |
| pieno 1 | 5 | 240, 408 | 96, 264 | 203.647 | 45° |
| pieno 1 | 6 | 96, 264 | 96, 96 | 168 | 90° |
| pieno 1 | 7 | 96, 96 | 120, 72 | 33.941 | 135° |
| taglio 1 | 1 | 336, 176.236 | 240, 272.236 | 135.764 | 135° |
| taglio 1 | 2 | 240, 272.236 | 144, 176.236 | 135.764 | 45° |
| taglio 1 | 3 | 144, 176.236 | 144, 142.294 | 33.941 | 90° |
| taglio 1 | 4 | 144, 142.294 | 240, 238.294 | 135.764 | 45° |
| taglio 1 | 5 | 240, 238.294 | 336, 142.294 | 135.764 | 135° |
| taglio 1 | 6 | 336, 142.294 | 336, 176.236 | 33.941 | 90° |

## Velocità (`velocita`)

- **File:** `art/interfaccia/statistiche/strada_a/velocita.svg` e `.png`
- **Ingombro:** da 1,1 a 19,19 moduli (432 × 432 pixel a 480)
- **Pienezza:** 0.346 (inchiostro 112 moduli quadrati)
- **Direzioni dei lati:** 0°, 116.57°, 135°
- **Le parti, come sono costruite:**
  - punta tronca: 3 moduli (72 px)
  - braccio, in orizzontale al gradino: 7 moduli (168 px)

I lati, anello per anello, in pixel a 480:

| anello | lato | da | a | lungo | direzione |
|---|---|---|---|---|---|
| pieno 1 | 1 | 264, 24 | 336, 24 | 72 | 0° |
| pieno 1 | 2 | 336, 24 | 240, 216 | 214.663 | 116.57° |
| pieno 1 | 3 | 240, 216 | 456, 216 | 216 | 0° |
| pieno 1 | 4 | 456, 216 | 216, 456 | 339.411 | 135° |
| pieno 1 | 5 | 216, 456 | 144, 456 | 72 | 0° |
| pieno 1 | 6 | 144, 456 | 240, 264 | 214.663 | 116.57° |
| pieno 1 | 7 | 240, 264 | 24, 264 | 216 | 0° |
| pieno 1 | 8 | 24, 264 | 264, 24 | 339.411 | 135° |

## Intelligenza (`intelligenza`)

- **File:** `art/interfaccia/statistiche/strada_a/intelligenza.svg` e `.png`
- **Ingombro:** da 1,4 a 19,16 moduli (432 × 288 pixel a 480)
- **Pienezza:** 0.317 (inchiostro 102.578 moduli quadrati)
- **Direzioni dei lati:** 0°, 45°, 90°, 135°
- **Le parti, come sono costruite:**
  - bordo della lente: 2 moduli (48 px)
  - fra il bordo e l'iride: 1 moduli (24 px)
  - iride, apotema: 3 moduli (72 px)
  - pupilla, mezza diagonale: 1.5 moduli (36 px)
- **Gli spessori, misurati sul disegno finito** (la distanza minima fra i bordi):
  - taglio dal pieno che lo contiene: 2 moduli (48 px)
  - pieno dentro dal taglio che lo contiene: 1 moduli (24 px)
  - foro dal pieno dentro che lo contiene: 1.5 moduli (36 px)

I lati, anello per anello, in pixel a 480:

| anello | lato | da | a | lungo | direzione |
|---|---|---|---|---|---|
| pieno 1 | 1 | 24, 240 | 168, 96 | 203.647 | 135° |
| pieno 1 | 2 | 168, 96 | 312, 96 | 144 | 0° |
| pieno 1 | 3 | 312, 96 | 456, 240 | 203.647 | 45° |
| pieno 1 | 4 | 456, 240 | 312, 384 | 203.647 | 135° |
| pieno 1 | 5 | 312, 384 | 168, 384 | 144 | 0° |
| pieno 1 | 6 | 168, 384 | 24, 240 | 203.647 | 45° |
| taglio 1 | 1 | 292.118, 144 | 388.118, 240 | 135.764 | 45° |
| taglio 1 | 2 | 388.118, 240 | 292.118, 336 | 135.764 | 135° |
| taglio 1 | 3 | 292.118, 336 | 187.882, 336 | 104.236 | 0° |
| taglio 1 | 4 | 187.882, 336 | 91.882, 240 | 135.764 | 45° |
| taglio 1 | 5 | 91.882, 240 | 187.882, 144 | 135.764 | 135° |
| taglio 1 | 6 | 187.882, 144 | 292.118, 144 | 104.236 | 0° |
| pieno dentro 1 | 1 | 210.177, 168 | 269.823, 168 | 59.647 | 0° |
| pieno dentro 1 | 2 | 269.823, 168 | 312, 210.177 | 59.647 | 45° |
| pieno dentro 1 | 3 | 312, 210.177 | 312, 269.823 | 59.647 | 90° |
| pieno dentro 1 | 4 | 312, 269.823 | 269.823, 312 | 59.647 | 135° |
| pieno dentro 1 | 5 | 269.823, 312 | 210.177, 312 | 59.647 | 0° |
| pieno dentro 1 | 6 | 210.177, 312 | 168, 269.823 | 59.647 | 45° |
| pieno dentro 1 | 7 | 168, 269.823 | 168, 210.177 | 59.647 | 90° |
| pieno dentro 1 | 8 | 168, 210.177 | 210.177, 168 | 59.647 | 135° |
| foro 1 | 1 | 240, 204 | 276, 240 | 50.912 | 45° |
| foro 1 | 2 | 276, 240 | 240, 276 | 50.912 | 135° |
| foro 1 | 3 | 240, 276 | 204, 240 | 50.912 | 45° |
| foro 1 | 4 | 204, 240 | 240, 204 | 50.912 | 135° |

## Forza mentale (`forza_mentale`)

- **File:** `art/interfaccia/statistiche/strada_a/forza_mentale.svg` e `.png`
- **Ingombro:** da 4.5,2.5 a 17.5,17 moduli (312 × 348 pixel a 480)
- **Pienezza:** 0.367 (inchiostro 118.75 moduli quadrati)
- **Direzioni dei lati:** 0°, 45°, 90°, 135°
- **Le parti, come sono costruite:**
  - la mente (taglio), mezza diagonale: 2.5 moduli (60 px)
- **Gli spessori, misurati sul disegno finito** (la distanza minima fra i bordi):
  - taglio dal pieno che lo contiene: 2.5 moduli (60 px)

I lati, anello per anello, in pixel a 480:

| anello | lato | da | a | lungo | direzione |
|---|---|---|---|---|---|
| pieno 1 | 1 | 168, 408 | 168, 360 | 48 | 90° |
| pieno 1 | 2 | 168, 360 | 108, 300 | 84.853 | 45° |
| pieno 1 | 3 | 108, 300 | 108, 144 | 156 | 90° |
| pieno 1 | 4 | 108, 144 | 192, 60 | 118.794 | 135° |
| pieno 1 | 5 | 192, 60 | 288, 60 | 96 | 0° |
| pieno 1 | 6 | 288, 60 | 372, 144 | 118.794 | 45° |
| pieno 1 | 7 | 372, 144 | 372, 180 | 36 | 90° |
| pieno 1 | 8 | 372, 180 | 420, 228 | 67.882 | 45° |
| pieno 1 | 9 | 420, 228 | 372, 228 | 48 | 0° |
| pieno 1 | 10 | 372, 228 | 372, 288 | 60 | 90° |
| pieno 1 | 11 | 372, 288 | 336, 324 | 50.912 | 135° |
| pieno 1 | 12 | 336, 324 | 312, 324 | 24 | 0° |
| pieno 1 | 13 | 312, 324 | 312, 408 | 84 | 90° |
| pieno 1 | 14 | 312, 408 | 168, 408 | 144 | 0° |
| taglio 1 | 1 | 240, 120 | 300, 180 | 84.853 | 45° |
| taglio 1 | 2 | 300, 180 | 240, 240 | 84.853 | 135° |
| taglio 1 | 3 | 240, 240 | 180, 180 | 84.853 | 45° |
| taglio 1 | 4 | 180, 180 | 240, 120 | 84.853 | 135° |

## Fattore (`fattore`)

- **File:** `art/interfaccia/statistiche/strada_a/fattore.svg` e `.png`
- **Ingombro:** da 3,1 a 17,18 moduli (336 × 408 pixel a 480)
- **Pienezza:** 0.376 (inchiostro 121.682 moduli quadrati)
- **Direzioni dei lati:** 0°, 45°, 63.43°, 90°, 116.57°, 135°
- **Le parti, come sono costruite:**
  - fra il cuore e il bordo: 2 moduli (48 px)
- **Gli spessori, misurati sul disegno finito** (la distanza minima fra i bordi):
  - taglio dal pieno che lo contiene: 2 moduli (48 px)

I lati, anello per anello, in pixel a 480:

| anello | lato | da | a | lungo | direzione |
|---|---|---|---|---|---|
| pieno 1 | 1 | 240, 24 | 312, 168 | 160.997 | 63.43° |
| pieno 1 | 2 | 312, 168 | 360, 120 | 67.882 | 135° |
| pieno 1 | 3 | 360, 120 | 408, 216 | 107.331 | 63.43° |
| pieno 1 | 4 | 408, 216 | 408, 312 | 96 | 90° |
| pieno 1 | 5 | 408, 312 | 288, 432 | 169.706 | 135° |
| pieno 1 | 6 | 288, 432 | 192, 432 | 96 | 0° |
| pieno 1 | 7 | 192, 432 | 72, 312 | 169.706 | 45° |
| pieno 1 | 8 | 72, 312 | 72, 252 | 60 | 90° |
| pieno 1 | 9 | 72, 252 | 120, 156 | 107.331 | 116.57° |
| pieno 1 | 10 | 120, 156 | 156, 192 | 50.912 | 45° |
| pieno 1 | 11 | 156, 192 | 240, 24 | 187.83 | 116.57° |
| taglio 1 | 1 | 309.373, 342.745 | 268.118, 384 | 58.343 | 135° |
| taglio 1 | 2 | 268.118, 384 | 211.882, 384 | 56.236 | 0° |
| taglio 1 | 3 | 211.882, 384 | 170.627, 342.745 | 58.343 | 45° |
| taglio 1 | 4 | 170.627, 342.745 | 240, 204 | 155.122 | 116.57° |
| taglio 1 | 5 | 240, 204 | 309.373, 342.745 | 155.122 | 63.43° |

## Maestria del dominio (`maestria_dominio`)

- **File:** `art/interfaccia/statistiche/strada_a/maestria_dominio.svg` e `.png`
- **Ingombro:** da 1.5,5 a 18.5,15 moduli (408 × 240 pixel a 480)
- **Pienezza:** 0.327 (inchiostro 106 moduli quadrati)
- **Direzioni dei lati:** 0°, 45°, 90°, 135°
- **Le parti, come sono costruite:**
  - segmento: 5 moduli (120 px)
  - fra i segmenti: 1 moduli (24 px)
  - contorno del terzo: 2 moduli (48 px)
  - dentro il terzo (taglio): 1 moduli (24 px)
  - fra il segno e la barra: 1 moduli (24 px)
- **Gli spessori, misurati sul disegno finito** (la distanza minima fra i bordi):
  - taglio dal pieno che lo contiene: 2 moduli (48 px)
  - fra due pieno staccati: 1 moduli (24 px) — 3 volte
  - fra due pieno staccati: 7 moduli (168 px)
  - fra due pieno staccati: 8.078 moduli (193.866 px)
  - fra due pieno staccati: 3.182 moduli (76.368 px)

I lati, anello per anello, in pixel a 480:

| anello | lato | da | a | lungo | direzione |
|---|---|---|---|---|---|
| pieno 1 | 1 | 36, 192 | 156, 192 | 120 | 0° |
| pieno 1 | 2 | 156, 192 | 156, 360 | 168 | 90° |
| pieno 1 | 3 | 156, 360 | 36, 360 | 120 | 0° |
| pieno 1 | 4 | 36, 360 | 36, 192 | 168 | 90° |
| pieno 2 | 1 | 180, 192 | 300, 192 | 120 | 0° |
| pieno 2 | 2 | 300, 192 | 300, 360 | 168 | 90° |
| pieno 2 | 3 | 300, 360 | 180, 360 | 120 | 0° |
| pieno 2 | 4 | 180, 360 | 180, 192 | 168 | 90° |
| pieno 3 | 1 | 324, 192 | 444, 192 | 120 | 0° |
| pieno 3 | 2 | 444, 192 | 444, 360 | 168 | 90° |
| pieno 3 | 3 | 444, 360 | 324, 360 | 120 | 0° |
| pieno 3 | 4 | 324, 360 | 324, 192 | 168 | 90° |
| pieno 4 | 1 | 336, 120 | 432, 120 | 96 | 0° |
| pieno 4 | 2 | 432, 120 | 384, 168 | 67.882 | 135° |
| pieno 4 | 3 | 384, 168 | 336, 120 | 67.882 | 45° |
| taglio 1 | 1 | 372, 240 | 396, 240 | 24 | 0° |
| taglio 1 | 2 | 396, 240 | 396, 312 | 72 | 90° |
| taglio 1 | 3 | 396, 312 | 372, 312 | 24 | 0° |
| taglio 1 | 4 | 372, 312 | 372, 240 | 72 | 90° |

## Aura (`aura`)

- **File:** `art/interfaccia/statistiche/strada_a/aura.svg` e `.png`
- **Ingombro:** da 1,1 a 19,19 moduli (432 × 432 pixel a 480)
- **Pienezza:** 0.315 (inchiostro 102 moduli quadrati)
- **Direzioni dei lati:** 0°, 45°, 90°, 135°
- **Le parti, come sono costruite:**
  - raggio: 2 moduli (48 px)
  - fra i raggi e il rombo: 1 moduli (24 px)
- **Gli spessori, misurati sul disegno finito** (la distanza minima fra i bordi):
  - fra due pieno staccati: 1 moduli (24 px) — 8 volte
  - fra due pieno staccati: 2.536 moduli (60.853 px) — 8 volte
  - fra due pieno staccati: 7.071 moduli (169.706 px) — 4 volte
  - fra due pieno staccati: 8.986 moduli (215.657 px) — 8 volte
  - fra due pieno staccati: 12 moduli (288 px) — 2 volte
  - fra due pieno staccati: 5 moduli (120 px) — 4 volte
  - fra due pieno staccati: 9.071 moduli (217.706 px) — 2 volte

I lati, anello per anello, in pixel a 480:

| anello | lato | da | a | lungo | direzione |
|---|---|---|---|---|---|
| pieno 1 | 1 | 240, 120 | 360, 240 | 169.706 | 45° |
| pieno 1 | 2 | 360, 240 | 240, 360 | 169.706 | 135° |
| pieno 1 | 3 | 240, 360 | 120, 240 | 169.706 | 45° |
| pieno 1 | 4 | 120, 240 | 240, 120 | 169.706 | 135° |
| pieno 2 | 1 | 216, 24 | 264, 24 | 48 | 0° |
| pieno 2 | 2 | 264, 24 | 264, 96 | 72 | 90° |
| pieno 2 | 3 | 264, 96 | 216, 96 | 48 | 0° |
| pieno 2 | 4 | 216, 96 | 216, 24 | 72 | 90° |
| pieno 3 | 1 | 359.397, 86.662 | 393.338, 120.603 | 48 | 45° |
| pieno 3 | 2 | 393.338, 120.603 | 333.941, 180 | 84 | 135° |
| pieno 3 | 3 | 333.941, 180 | 300, 146.059 | 48 | 45° |
| pieno 3 | 4 | 300, 146.059 | 359.397, 86.662 | 84 | 135° |
| pieno 4 | 1 | 456, 216 | 456, 264 | 48 | 90° |
| pieno 4 | 2 | 456, 264 | 384, 264 | 72 | 0° |
| pieno 4 | 3 | 384, 264 | 384, 216 | 48 | 90° |
| pieno 4 | 4 | 384, 216 | 456, 216 | 72 | 0° |
| pieno 5 | 1 | 393.338, 359.397 | 359.397, 393.338 | 48 | 135° |
| pieno 5 | 2 | 359.397, 393.338 | 300, 333.941 | 84 | 45° |
| pieno 5 | 3 | 300, 333.941 | 333.941, 300 | 48 | 135° |
| pieno 5 | 4 | 333.941, 300 | 393.338, 359.397 | 84 | 45° |
| pieno 6 | 1 | 264, 456 | 216, 456 | 48 | 0° |
| pieno 6 | 2 | 216, 456 | 216, 384 | 72 | 90° |
| pieno 6 | 3 | 216, 384 | 264, 384 | 48 | 0° |
| pieno 6 | 4 | 264, 384 | 264, 456 | 72 | 90° |
| pieno 7 | 1 | 120.603, 393.338 | 86.662, 359.397 | 48 | 45° |
| pieno 7 | 2 | 86.662, 359.397 | 146.059, 300 | 84 | 135° |
| pieno 7 | 3 | 146.059, 300 | 180, 333.941 | 48 | 45° |
| pieno 7 | 4 | 180, 333.941 | 120.603, 393.338 | 84 | 135° |
| pieno 8 | 1 | 24, 264 | 24, 216 | 48 | 90° |
| pieno 8 | 2 | 24, 216 | 96, 216 | 72 | 0° |
| pieno 8 | 3 | 96, 216 | 96, 264 | 48 | 90° |
| pieno 8 | 4 | 96, 264 | 24, 264 | 72 | 0° |
| pieno 9 | 1 | 86.662, 120.603 | 120.603, 86.662 | 48 | 135° |
| pieno 9 | 2 | 120.603, 86.662 | 180, 146.059 | 84 | 45° |
| pieno 9 | 3 | 180, 146.059 | 146.059, 180 | 48 | 135° |
| pieno 9 | 4 | 146.059, 180 | 86.662, 120.603 | 84 | 45° |

