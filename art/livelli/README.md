# I livelli disegnati

Qui stanno i livelli fatti da **un disegno intero**, non da tessere: la mappa
è un PNG solo, e accanto c'è la sua **pianta**, un JSON con lo stesso nome
che dice dove si cammina.

    F6 su prove/LivelloProva.tscn                  le Pianure (P passa da lei a lui)
    prove/LivelloProva.tscn -- livello panottico   il Panottico
    python3 strumenti/livelli/ricalca_livello.py   rifà le mappe dai disegni di Bru

| livello | cos'è |
|---|---|
| `pianure` | **Le Pianure di Redenna**, il primo livello. È il disegno di Bru, fatto pixel art pulita e messo in ordine secondo la tabella di marcia del tutorial |
| `panottico` | **Il Panottico silenzioso**: dietro la porta enorme oltre l'altare della bambola, nella Casa Gigante. È il disegno di Bru («THE SILENT PANOPTICON»), pulito |

## La mappa: `<nome>.png`

- **Il disegno di Bru, fatto pixel art pulita.** Lo strumento toglie quello
  che non è mappa, o quello che va contro la tabella di marcia, e lo rende
  nitido. Bru: «bisogna rendere tutto più chiaro e bello da vedere per adesso
  è tutto blurroso».
- **Pulita.** Via la grana del JPG (ogni pixel prende la media dei vicini di
  colore quasi uguale, e i bordi restano), i contorni un poco più netti, e
  nelle Pianure i colori un poco più vivi.
- **Ingrandita poco, a blocchi interi.** Sullo schermo ogni pixel del disegno
  è un blocco di 2×2, nei due livelli:
  - le Pianure: il gioco le ingrandisce 2 volte (`scala`), e la telecamera 1;
    lei è alta come la capsula, e si vede un bel pezzo di prato;
  - il Panottico: il gioco 1 volta, la telecamera 2; lei è alta come le
    sagome nelle capsule.

  Prima le Pianure erano ingrandite 4 volte, col JPG dentro: era quello lo
  sfocato.
- **Provato e scartato: la griglia.** Il disegno delle Pianure ha un salto di
  colore ogni 2 pixel (è stato ingrandito due volte prima del JPG). Ricalcato
  un pixel ogni 2 torna di 668×392, ma alla grandezza del gioco viene a
  blocchi e perde il dettaglio delle chiome. Lo strumento sa ancora farlo
  (`griglia`, e nella pianta `pixel`).
- Vista **dall'alto e un po' di fronte**: i muri si vedono di faccia, i
  pavimenti da sopra.
- **Dove non c'è mappa è trasparente**: il gioco ci mette il buio.
- Niente scritte e niente legenda dentro il disegno: i nomi delle stanze li
  scrive il gioco quando ci entri.

Cosa toglie `strumenti/livelli/ricalca_livello.py`:

- **Il Panottico** (`strumenti/livelli/fogli/panottico.png`):
  - la scacchiera, il titolo, i nomi scritti fuori, la bussola e la legenda;
  - la scritta sul pavimento del corridoio in alto, rifatta con le piastrelle
    di sopra.
- **Le Pianure** (`strumenti/livelli/fogli/pianure.png`):
  - il riquadro nero col disegno della caverna, accanto all'albero: era
    un'etichetta, non un posto. Al suo posto il prato, il muretto e il bordo
    dell'albero;
  - la scorciatoia dal bivio all'arena: lì c'è una siepe di rovi, fatta coi
    grovigli della zona corrotta.

### Dove si cammina: `<passi>`

Una maschera, un pixel per pixel della mappa. La scrive lo strumento:

- il `pavimento` della pianta;
- meno gli `ostacoli` (colonne, tronchi, laghetti, il cratere);
- meno l'acqua e le chiome scure, riconosciute dal colore.

Fanno eccezione:

- dove la pianta dice `si_passa`: le scale e il ponticello;
- sotto le chiome che le passano davanti, dove lei ci va dietro e bloccano
  solo i tronchi.

Bru: «gli ostacoli, colonne, acqua etc devono esserci».

### Le cose alte: `<nome>_sopra.png`

Gli alberi che coprono chi ci passa dietro, ritagliati dalla mappa: sono i
pixel scuri (chiome e tronchi) dentro i rettangoli di `sopra`, e il resto è
trasparente. Il gioco li rimette esattamente al loro posto. Quando il piede di
lei è più su del piede dell'albero, l'albero è davanti a lei. Li scrive lo
stesso strumento.

## La pianta: `<nome>.json`

Tutti i numeri sono pixel del disegno (prima della `scala`):

- un rettangolo è `[x0, y0, x1, y1]`, con `x1` e `y1` fuori;
- un poligono è `[[x, y], [x, y], ...]`.

| chiave | cos'è |
|---|---|
| `nome` | il nome del livello, scritto sopra il nome di ogni stanza |
| `mappa` | il PNG |
| `scala`, `ingrandimento` | quante volte il gioco ingrandisce il disegno, e quanto la telecamera (se mancano, 1 e 3). `pixel`: quanti pixel del disegno fanno un pixel della mappa, se lo strumento l'ha ricalcata più piccola (se manca, 1) |
| `passi`, `si_passa` | la maschera di dove si cammina, e dove si passa anche se il colore dice acqua o chioma (le scale) |
| `limiti` | fin dove arriva la telecamera |
| `partenza`, `verso` | dove si entra, e da che parte si guarda (`[0, 1]` giù) |
| `stanze` | i nomi delle stanze (o delle tappe) col loro rettangolo (`rett`) o poligono (`poligono`): entrandoci compare il nome |
| `pavimento` | dove si cammina: rettangoli e poligoni |
| `ostacoli` | dove no, anche se è pavimento (le capsule, le colonne, i tronchi, i laghetti) |
| `porte` | una zona e dove porta (`a`, `verso`). Le porte chiuse del disegno si passano come negli Zelda: ci entri e sei dall'altra parte |
| `sopra_mappa`, `sopra` | le cose alte: il PNG e i rettangoli `[x0, y0, x1, y1, piede]` |
| `giro` | i punti del giro del pilota automatico |

Dove si cammina conta il **piede**, il punto per terra al centro dei piedi:
è un rettangolo di 10×6 pixel del mondo, come nei mondi, e il corpo sta
sopra.

Le prove (`prove/Prove.gd`, «i livelli disegnati si attraversano») guardano
ogni pianta:

- la mappa c'è, e la pianta ci sta dentro;
- si parte da un posto dove si sta;
- ogni porta porta in un posto dove si sta, e non dentro un'altra porta;
- il pilota fa tutto il giro passando da ogni stanza.

Il film del giro: `prove/LivelloProva.tscn -- livello <nome> film`.
