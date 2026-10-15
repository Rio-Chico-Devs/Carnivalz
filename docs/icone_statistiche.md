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
| Punti vita | il cuore + la cicatrice cucita | 0.311 | +4.8% | 26.0 | -3.4% | +0.1, -1.6 | da 11.0,17.0 a 89.0,87.0 |
| Attacco | la spada + il fendente | 0.278 | -6.4% | 28.9 | +7.2% | -0.6, -1.6 | da 12.0,10.5 a 93.7,91.9 |
| Difesa | lo scudo + i merli | 0.293 | -1.3% | 27.8 | +3.3% | +0.0, -2.4 | da 20.0,10.0 a 80.0,92.0 |
| Velocità | il fulmine + la sua eco | 0.305 | +2.9% | 25.3 | -6.0% | +1.3, -3.5 | da 11.0,8.0 a 91.8,96.0 |
| Intelligenza | l'occhio + la serratura | 0.311 | +4.9% | 27.1 | +0.6% | +0.0, -0.1 | da 4.0,20.0 a 96.0,80.0 |
| Forza mentale | la lanterna + il fuoco | 0.284 | -4.3% | 28.1 | +4.3% | +0.0, +0.7 | da 21.0,4.0 a 79.0,91.0 |
| Fattore | il fuoco + l'emblema | 0.294 | -1.0% | 25.2 | -6.4% | +1.0, +1.5 | da 23.1,4.0 a 76.9,92.0 |
| Maestria del dominio | la corona + la barra del dominio | 0.308 | +3.8% | 27.3 | +1.3% | +0.0, -1.9 | da 9.0,9.0 a 91.0,80.0 |
| Aura | il vortice + la scia | 0.286 | -3.5% | 26.7 | -1.0% | -1.5, +3.5 | da 16.2,4.0 a 84.5,91.6 |

Medie: pienezza 0.297, raggio 26.9.

- **Punti vita** (`hp`): il cuore e la cicatrice cucita. Chi tocca il confine e torna: il trauma ricucito è forza.
- **Attacco** (`attacco`): la spada e il fendente. Il colpo lascia uno squarcio alle spalle della lama.
- **Difesa** (`difesa`): lo scudo e i merli. L'unità è una struttura da difendere: lo scudo è una fortezza.
- **Velocità** (`velocita`): il fulmine e la sua eco. La stampa slitta fuori registro: la scia è il disallineamento.
- **Intelligenza** (`intelligenza`): l'occhio e la serratura. Vedere la via d'uscita: è la stat che fa fuggire.
- **Forza mentale** (`forza_mentale`): la lanterna e il fuoco. La fiamma dietro il vetro, che lo stress non spegne.
- **Fattore** (`fattore`): il fuoco e l'emblema. Nella fiamma, il rombo di Carnivalz: il disallineamento che arde in te.
- **Maestria del dominio** (`maestria_dominio`): la corona e la barra del dominio. La fascia della corona sono i tre segmenti della barra.
- **Aura** (`aura`): il vortice e la scia. L'energia che spendi sale dal vortice come una fiamma di spirito.
