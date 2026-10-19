# Le icone delle statistiche (generato, non scrivere qui a mano)

Rigenera con `./prove/icone.sh`. Il codice è `scripts/crescita/IconeStatistiche.gd`; i file sono in
`art/interfaccia/statistiche/proposta/`: un SVG e un PNG per icona, 480 × 480, nero su
trasparente. Nell'SVG ogni icona è un percorso solo con `fill-rule="evenodd"`. Sono una
proposta: il gioco legge `art/interfaccia/statistiche/<chiave>.png`, bianche su trasparente.

Ogni icona è due figure che ne fanno una terza. Il disegno sta su una griglia di 100
(4,8 pixel per unità nei file), area viva da 4 a 96; i tagli e i distacchi sono C = 5,
i bordi T = 10. La pienezza è l'inchiostro sul quadrato di 100, contata su una griglia
di punti ogni mezza unità.

I file sono il disegno a misura piena. Sotto i 32 pixel il gioco le disegna coi tagli più
larghi (mai sotto 1,4 pixel, a mezze unità), e timbrate l'ombra è la sagoma chiusa:
i vuoti fra un pezzo e l'altro restano del colore del fondo.

Le correzioni ottiche si misurano (la foto «misure» delle proposte): la pienezza entro l'8%
dalla media, la grandezza (il raggio d'inerzia, quanto la massa è sparsa attorno al suo
centro) entro il 10%, il centro visivo (a metà fra il centro dell'ingombro e il baricentro)
entro 4 unità dal centro. E niente fili: due contorni o si toccano o stanno ad almeno un
taglio.

| icona | le due figure | pienezza | dalla media | raggio | dalla media | centro visivo | ingombro (unità) |
|---|---|---|---|---|---|---|---|
| Punti vita | il cuore + il palloncino | 0.306 | +3.5% | 24.3 | -9.4% | +0.3, -2.5 | da 15.0,12.0 a 85.0,95.9 |
| Attacco | la spada + la maschera | 0.275 | -7.0% | 28.1 | +4.7% | -0.9, +0.9 | da 9.0,9.0 a 91.0,91.0 |
| Difesa | lo scudo + i merli | 0.281 | -4.8% | 27.7 | +3.3% | +0.0, -2.4 | da 20.0,10.0 a 80.0,92.0 |
| Velocità | il gallone + il suo doppio | 0.294 | -0.4% | 27.5 | +2.5% | -2.0, +0.0 | da 5.8,15.0 a 90.2,85.0 |
| Intelligenza | l'occhio + la serratura | 0.311 | +5.5% | 27.1 | +0.9% | +0.0, -0.1 | da 4.0,20.0 a 96.0,80.0 |
| Forza mentale | il rombo + il brillante | 0.304 | +2.9% | 27.9 | +4.1% | +0.0, +2.5 | da 4.0,16.0 a 96.0,96.0 |
| Fattore | la bomba + la scintilla | 0.298 | +0.8% | 25.1 | -6.6% | +1.6, +2.3 | da 14.5,4.0 a 96.0,90.5 |
| Maestria del dominio | la corona + la barra del dominio | 0.308 | +4.3% | 27.3 | +1.6% | +0.0, -1.9 | da 9.0,9.0 a 91.0,80.0 |
| Aura | il vortice + la fiamma | 0.281 | -4.7% | 26.6 | -0.9% | -2.0, +2.4 | da 18.0,4.0 a 82.0,92.0 |

Medie: pienezza 0.295, raggio 26.9.

- **Punti vita** (`hp`): il cuore e il palloncino. La vita è un palloncino della fiera: ogni colpo che incassi la gonfia un po' di più.
- **Attacco** (`attacco`): la spada e la maschera. L'elsa è una colombina di carnevale: il Carnivalz è la festa di chi ha subito un torto.
- **Difesa** (`difesa`): lo scudo e i merli. L'unità è una struttura da difendere: lo scudo è una fortezza.
- **Velocità** (`velocita`): il gallone e il suo doppio. Il segno dell'avanti veloce: dove gli altri fanno un passo, tu ne fai due.
- **Intelligenza** (`intelligenza`): l'occhio e la serratura. Vedere la via d'uscita: è la stat che fa fuggire.
- **Forza mentale** (`forza_mentale`): il rombo e il brillante. La pressione fa i diamanti: la forza mentale cresce con lo stress che reggi.
- **Fattore** (`fattore`): la bomba e la scintilla. La brace corre lungo la miccia, il critico è lo scoppio. Il riflesso è il rombo di Carnivalz.
- **Maestria del dominio** (`maestria_dominio`): la corona e la barra del dominio. La fascia della corona sono i tre segmenti della barra.
- **Aura** (`aura`): il vortice e la fiamma. Il segno sulla pancia di Jalhalla, capovolto: un fuoco fatuo che sale dal vortice.

## Le distanze fra i contorni

Per ogni icona, la distanza più corta fra due contorni che non si toccano (in unità; il
taglio C è 5.0). A misura piena è sempre almeno C; piccola (taglio 9.0 a 16 pixel, 10.0 chiara
su scuro) almeno tre quarti del taglio.

| icona | a misura piena | piccola | piccola, chiara su scuro |
|---|---|---|---|
| Punti vita | 7.58 | 7.58 | 7.58 |
| Attacco | 5.11 | 7.22 | 7.73 |
| Difesa | 8.0 | 9.6 | 10.0 |
| Velocità | 5.0 | 9.0 | 10.0 |
| Intelligenza | 6.22 | 8.47 | 9.03 |
| Forza mentale | — | — | — |
| Fattore | 6.4 | 8.7 | 9.12 |
| Maestria del dominio | 5.0 | 9.0 | 10.0 |
| Aura | — | — | — |
