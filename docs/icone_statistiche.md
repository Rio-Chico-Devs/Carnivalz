# Le icone delle statistiche (generato, non scrivere qui a mano)

Rigenera con `./prove/icone.sh`. Il codice è `prove/IconeStatistiche.gd`; i file sono in
`art/interfaccia/statistiche/proposta/`: un SVG e un PNG per icona, 480 × 480, nero su
trasparente. Nell'SVG ogni icona è un percorso solo con `fill-rule="evenodd"`. Sono una
proposta: il gioco legge `art/interfaccia/statistiche/<chiave>.png`, bianche su trasparente.

Ogni icona è due figure che ne fanno una terza. Il disegno sta su una griglia di 100
(4,8 pixel per unità nei file), area viva da 4 a 96; i tagli e i distacchi sono C = 5,
i bordi T = 10. La pienezza è l'inchiostro sul quadrato di 100, contata su una griglia
di punti ogni mezza unità.

| icona | le due figure | pienezza | dalla media | ingombro (unità) |
|---|---|---|---|---|
| Punti vita | il cuore + la cicatrice cucita | 0.320 | +7.6% | da 10.0,16.0 a 90.0,88.0 |
| Attacco | la spada + il fendente | 0.270 | -9.2% | da 4.0,4.0 a 89.6,91.0 |
| Difesa | lo scudo + i merli | 0.327 | +9.8% | da 18.0,8.0 a 82.0,94.0 |
| Velocità | il fulmine + la sua eco | 0.271 | -9.0% | da 18.0,4.0 a 82.0,96.0 |
| Intelligenza | l'occhio + la serratura | 0.317 | +6.4% | da 4.0,19.0 a 96.0,81.0 |
| Forza mentale | la lanterna + il fuoco | 0.266 | -10.7% | da 22.0,5.0 a 78.0,90.0 |
| Fattore | il fuoco + l'emblema | 0.309 | +3.8% | da 22.5,4.0 a 77.5,94.0 |
| Maestria del dominio | la corona + la barra del dominio | 0.320 | +7.4% | da 8.5,8.0 a 91.5,81.0 |
| Aura | la scintilla + l'emblema | 0.280 | -6.1% | da 4.0,4.0 a 96.0,96.0 |

Media 0.298.

- **Punti vita** (`hp`): il cuore e la cicatrice cucita. Chi tocca il confine e torna: il trauma ricucito è forza.
- **Attacco** (`attacco`): la spada e il fendente. Il colpo lascia uno squarcio alle spalle della lama.
- **Difesa** (`difesa`): lo scudo e i merli. L'unità è una struttura da difendere: lo scudo è una fortezza.
- **Velocità** (`velocita`): il fulmine e la sua eco. La stampa slitta fuori registro: la scia è il disallineamento.
- **Intelligenza** (`intelligenza`): l'occhio e la serratura. Vedere la via d'uscita: è la stat che fa fuggire.
- **Forza mentale** (`forza_mentale`): la lanterna e il fuoco. La fiamma dietro il vetro, che lo stress non spegne.
- **Fattore** (`fattore`): il fuoco e l'emblema. Nella fiamma, il rombo di Carnivalz: il disallineamento che arde in te.
- **Maestria del dominio** (`maestria_dominio`): la corona e la barra del dominio. La fascia della corona sono i tre segmenti della barra.
- **Aura** (`aura`): la scintilla e l'emblema. L'energia che spendi, col rombo di Carnivalz nel cuore.
