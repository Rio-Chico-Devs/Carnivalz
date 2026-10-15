# Le icone delle statistiche (generato, non scrivere qui a mano)

Rigenera con `./prove/icone.sh`. Il codice è `prove/IconeStatistiche.gd`; i file sono in
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
| Punti vita | il cuore + la cicatrice cucita | 0.311 | +5.4% | 26.0 | -3.0% | +0.1, -1.6 | da 11.0,17.0 a 89.0,87.0 |
| Attacco | la spada + il fendente | 0.278 | -5.9% | 28.9 | +7.7% | -0.6, -1.6 | da 12.0,10.5 a 93.7,91.9 |
| Difesa | lo scudo + i merli | 0.281 | -4.8% | 27.7 | +3.4% | +0.0, -2.4 | da 20.0,10.0 a 80.0,92.0 |
| Velocità | il fulmine + la sua eco | 0.305 | +3.4% | 25.3 | -5.6% | +1.3, -3.5 | da 11.0,8.0 a 91.8,96.0 |
| Intelligenza | l'occhio + la serratura | 0.311 | +5.5% | 27.1 | +1.0% | +0.0, -0.1 | da 4.0,20.0 a 96.0,80.0 |
| Forza mentale | la lanterna + il fuoco | 0.284 | -3.7% | 28.1 | +4.7% | +0.0, +0.7 | da 21.0,4.0 a 79.0,91.0 |
| Fattore | il fuoco + l'emblema | 0.294 | -0.4% | 25.2 | -6.0% | +1.0, +1.5 | da 23.1,4.0 a 76.9,92.0 |
| Maestria del dominio | la corona + la barra del dominio | 0.308 | +4.4% | 27.3 | +1.8% | +0.0, -1.9 | da 9.0,9.0 a 91.0,80.0 |
| Aura | il vortice + la scia | 0.284 | -3.8% | 25.7 | -4.0% | -1.1, +3.0 | da 16.7,4.0 a 85.4,90.5 |

Medie: pienezza 0.295, raggio 26.8.

- **Punti vita** (`hp`): il cuore e la cicatrice cucita. Chi tocca il confine e torna: il trauma ricucito è forza.
- **Attacco** (`attacco`): la spada e il fendente. Il colpo lascia uno squarcio alle spalle della lama.
- **Difesa** (`difesa`): lo scudo e i merli. L'unità è una struttura da difendere: lo scudo è una fortezza.
- **Velocità** (`velocita`): il fulmine e la sua eco. La stampa slitta fuori registro: la scia è il disallineamento.
- **Intelligenza** (`intelligenza`): l'occhio e la serratura. Vedere la via d'uscita: è la stat che fa fuggire.
- **Forza mentale** (`forza_mentale`): la lanterna e il fuoco. La fiamma dietro il vetro, che lo stress non spegne.
- **Fattore** (`fattore`): il fuoco e l'emblema. Nella fiamma, il rombo di Carnivalz: il disallineamento che arde in te.
- **Maestria del dominio** (`maestria_dominio`): la corona e la barra del dominio. La fascia della corona sono i tre segmenti della barra.
- **Aura** (`aura`): il vortice e la scia. L'energia che spendi sale dal vortice come una fiamma di spirito.

## Le distanze fra i contorni

Per ogni icona, la distanza più corta fra due contorni che non si toccano (in unità; il
taglio C è 5.0). A misura piena è sempre almeno C; piccola (taglio 9.0 a 16 pixel, 10.0 chiara
su scuro) almeno tre quarti del taglio.

| icona | a misura piena | piccola | piccola, chiara su scuro |
|---|---|---|---|
| Punti vita | 5.17 | 8.0 | 8.66 |
| Attacco | 5.04 | 8.29 | 8.9 |
| Difesa | 8.0 | 10.0 | 10.0 |
| Velocità | 5.0 | 9.0 | 10.0 |
| Intelligenza | 6.22 | 8.47 | 9.03 |
| Forza mentale | 5.0 | 8.13 | 8.72 |
| Fattore | 7.79 | 9.5 | 9.95 |
| Maestria del dominio | 5.0 | 9.0 | 10.0 |
| Aura | — | — | — |
