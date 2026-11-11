# I livelli disegnati

Qui stanno i livelli fatti da **una mappa intera**, non da tessere: la mappa
è un PNG solo, e accanto c'è la sua **pianta**, un JSON con lo stesso nome
che dice dove si cammina.

    F6 su prove/LivelloProva.tscn                  le Pianure (P passa da lei a lui)
    prove/LivelloProva.tscn -- livello panottico   il Panottico
    python3 strumenti/livelli/oggetti.py           rifà la libreria dei pezzi dai fogli di Bru
    python3 strumenti/livelli/compone.py           rifà le Pianure coi pezzi
    python3 strumenti/livelli/ricalca_livello.py   rifà il Panottico dal disegno di Bru

| livello | cos'è |
|---|---|
| `pianure` | **Le Pianure di Redenna**, il primo livello. È **composto coi pezzi** della libreria (`oggetti/`), sul disegno di Bru e secondo la tabella di marcia del tutorial |
| `panottico` | **Il Panottico silenzioso**: dietro la porta enorme oltre l'altare della bambola, nella Casa Gigante. È il disegno di Bru («THE SILENT PANOPTICON»), pulito |

## La libreria dei pezzi: `oggetti/`

Bru: «vorrei che i disegni fossero creati pixel per pixel non usando un
immagine ma proprio oggetti disegnati in pixel che poi vengono riutilizzati
nelle mappe». I pezzi vengono dai cinque fogli di Bru
(`strumenti/livelli/fogli/oggetti_*.png`: terreno, alberi, palude, caverna,
rovine), ricalcati da `strumenti/livelli/oggetti.py`:

- **un pezzo per file**, in `oggetti/<categoria>/<nome>.png`: alberi, pini,
  cespugli, rovi, rocce, il cratere, le canne, le cascate, le rupi, le scale,
  le colonne, gli archi, le trame del terreno (erba, sabbia, acqua, rovi);
- **ricalcati pixel per pixel**: un pixel ogni 2,5 del foglio, il colore che
  somiglia di più agli altri del quadretto (niente medie, niente sfocato);
- **una tavolozza sola** di 64 colori per tutti, così stanno bene insieme;
- **il contorno** col colore più scuro della loro tinta (le trame del terreno
  no: stanno una accanto all'altra);
- `oggetti/catalogo.json`: per ogni pezzo la misura, la categoria e il
  **piede**, il punto per terra che decide chi sta davanti.

Un pixel di un pezzo è un pixel del mondo, come lei: un albero è alto una
volta e mezza lei, un pino due, una colonna come lei.

## Le Pianure, composte: `pianure.png`, `pianure_pezzi.json`

`strumenti/livelli/compone.py` rifà le Pianure coi pezzi. Il disegno di Bru
(`strumenti/livelli/fogli/pianure.png`) dice **dove** stanno le cose, ma nella
mappa non ne entra nemmeno un pixel:

1. **Le classi del terreno.** Ogni pixel del disegno diventa erba, sentiero,
   acqua, rovi, parete, alberi o lastre, dal colore (le pareti di Bru sono
   grigie e a fenditure verticali). Poi si lisciano, e la pianta corregge:
   dove si cammina non ci sono pareti né acqua né alberi. Sul promontorio le
   pareti sono troppe e intrecciate: lì sono ricalcate a mano, l'orlo di cima
   punto per punto, ognuno con la sua altezza.
2. **Il terreno**, alla misura del mondo (2672×1568): le trame della
   libreria, e i bordi disegnati pixel per pixel (la riva, il ciglio del
   sentiero, il passaggio a scacchi fra il prato e i rovi).
3. **Le pareti**: la faccia di due rupi della libreria, ripetuta in larghezza
   e allungata in altezza, con l'orlo chiaro in cima e l'ombra per terra.
   Dove l'acqua scende da una parete, la cascata. Le scale e il ponticello
   disegnati gradino per gradino e asse per asse.
4. **Le cose.** Quelle messe a mano, dove le aveva disegnate Bru: la capsula,
   i muretti del recinto, il grande albero, il cratere, i pini sotto la
   sporgenza, le rovine della cima e del promontorio, la siepe di rovi sulla
   scorciatoia. E quelle seminate: gli alberi nei boschi, le canne nella
   palude, gli alberi secchi e i rovi nella zona corrotta, i cespugli sul
   prato; mai sui sentieri. Le cose che stanno in piedi sono **pezzi a
   parte** (`pianure_pezzi.json`): il gioco le mette insieme a lei in ordine
   di piede, e chi ha il piede più in basso sta davanti. Le cose piatte (il
   cratere) sono dipinte nel terreno.

Sullo schermo ogni pixel, della mappa, dei pezzi e di lei, è un blocco netto
di 2×2: la telecamera ingrandisce due volte.

## Il Panottico: `panottico.png`

- **Il disegno di Bru, fatto pixel art pulita.** Lo strumento toglie quello
  che non è mappa e lo rende nitido. Bru: «bisogna rendere tutto più chiaro e
  bello da vedere per adesso è tutto blurroso».
- **Pulito.** Via la grana del JPG (ogni pixel prende la media dei vicini di
  colore quasi uguale, e i bordi restano), i contorni un poco più netti.
- **Uno a uno**: un pixel del disegno è un pixel del mondo, la telecamera
  ingrandisce 2 volte; lei è alta come le sagome nelle capsule.
- Vista **dall'alto e un po' di fronte**: i muri si vedono di faccia, i
  pavimenti da sopra.
- **Dove non c'è mappa è trasparente**: il gioco ci mette il buio.
- Via la scacchiera, il titolo, i nomi scritti fuori, la bussola e la
  legenda; la scritta sul pavimento del corridoio in alto è rifatta con le
  piastrelle di sopra.

Provato e scartato, sul disegno delle Pianure prima dei pezzi: ricalcarlo un
pixel ogni 2 (veniva a blocchi), una tavolozza piccola (spariscono i
contorni), togliere la nebbia in automatico (macchie). Bru ha risolto la
questione: «sembra proprio ai», e ha mandato i fogli dei pezzi.

### Dove si cammina: `<passi>`

Una maschera, un pixel per pixel della mappa. Per le Pianure la scrive
`compone.py`:

- il `pavimento` della pianta;
- meno gli `ostacoli`;
- meno l'acqua e le pareti;
- meno i piedi dei pezzi (il tronco di un albero, la base di una colonna, le
  due gambe di un arco).

Fanno eccezione le scale e il ponticello (`si_passa`). Sotto le chiome ci si
cammina: lei ci passa dietro, e bloccano solo i tronchi.

Bru: «gli ostacoli, colonne, acqua etc devono esserci».

## La pianta: `<nome>.json`

Tutti i numeri sono unità del disegno (prima della `scala`):

- un rettangolo è `[x0, y0, x1, y1]`, con `x1` e `y1` fuori;
- un poligono è `[[x, y], [x, y], ...]`.

| chiave | cos'è |
|---|---|
| `nome` | il nome del livello, scritto sopra il nome di ogni stanza |
| `mappa` | il PNG |
| `scala`, `ingrandimento` | quanti pixel del mondo fa un'unità, e quanto ingrandisce la telecamera (se mancano, 1 e 3). `pixel`: quante unità fanno un pixel della mappa (le Pianure: 0,5, la mappa è alla misura del mondo; se manca, 1) |
| `passi`, `si_passa` | la maschera di dove si cammina, e dove si passa anche se lì c'è acqua o parete (le scale, il ponticello) |
| `limiti` | fin dove arriva la telecamera |
| `partenza`, `verso` | dove si entra, e da che parte si guarda (`[0, 1]` giù) |
| `stanze` | i nomi delle stanze (o delle tappe) col loro rettangolo (`rett`) o poligono (`poligono`): entrandoci compare il nome |
| `pavimento` | dove si cammina: rettangoli e poligoni |
| `ostacoli` | dove no, anche se è pavimento (le capsule, le colonne, i tronchi, i laghetti) |
| `porte` | una zona e dove porta (`a`, `verso`). Le porte chiuse del disegno si passano come negli Zelda: ci entri e sei dall'altra parte |
| `pezzi` | il file dei pezzi che stanno in piedi: `[file, x, y, x e y del piede nel disegno del pezzo]`, in pixel del mondo |
| `giro` | i punti del giro del pilota automatico |

Dove si cammina conta il **piede**, il punto per terra al centro dei piedi:
è un rettangolo di 10×6 pixel del mondo, come nei mondi, e il corpo sta
sopra.

Le prove (`prove/Prove.gd`, «i livelli disegnati si attraversano») guardano
ogni pianta:

- la mappa c'è, e la pianta ci sta dentro;
- ogni pezzo ha il suo disegno, e sta dentro la mappa;
- si parte da un posto dove si sta;
- ogni porta porta in un posto dove si sta, e non dentro un'altra porta;
- il pilota fa tutto il giro passando da ogni stanza.

Il film del giro: `prove/LivelloProva.tscn -- livello <nome> film`.
