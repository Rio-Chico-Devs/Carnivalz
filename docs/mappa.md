# La mappa di zona: ogni zona somiglia al suo posto

## 1. Cosa ha deciso Bru

Dopo il filo dei piani tolto, avevo proposto tre mappe nuove (una vetrina nella
lingua della mappa stellare, un plastico di carta arancio e nero, una pianta
con la sezione). Bru:

> «ti dirò, mi piaceva quella di prima più che quelle proposte, volevo solo
> che le parti della mappa somigliassero di più alle ambientazioni tipo nelle
> pianure del risveglio siamo nella natura nella grande magione in una magione
> enorme con ai fianchi i giardini e i laboratori dall'altra parte, nei
> cunicoli deve proprio sembrare cunicoli»

Quindi il plastico resta com'era: il vetro, la luce azzurra, i bottoni dei
piani, la scheda della stanza, i comandi. Cambia **la forma dei pezzi**. Le
tre proposte sono uscite dal progetto (stanno nella storia di git, commit
4665c96, se un giorno servisse riprenderne un pezzo).

Al primo giro le stanze avevano anche le cose dentro: alberi, erba, siepi,
finestre, il masso, la tartaruga, le colonne, gli scaffali. Bru:

> «bene come distribuzione inteso come collocazione spaziale delle cose ci
> siamo ma non c'era bisogno di mettere alberi ed erbetta, troppi dettagli
> creano confusione, l'importante è avere una resa delle altezze e di come è
> conformato lo spazio, non degli elementi al suo interno»

Adesso ci sono solo contorni, spessori, quote e passaggi.

## 2. Come funziona

Ogni stanza ha un **ambiente**: quello della zona (`"ambiente"` nel
`mappa_dungeon`) o il suo, se e' diverso (`"ambiente"` sulla stanza). Il codice
sta in tre file:

- `scripts/AmbientiPlastico.gd` decide che forma ha una stanza e come si va da
  una all'altra, ambiente per ambiente;
- `scripts/ArrediPlastico.gd` disegna i **dettagli**: non oggetti, ma lo
  spazio di una stanza quando non e' quello del suo ambiente (`"dettaglio"`
  sulla stanza);
- `scripts/FormePlastico.gd` ha le forme: contorni morbidi, prismi, cupole,
  colline, sentieri, gallerie.

| ambiente | la stanza | da una stanza all'altra |
|---|---|---|
| `edificio` | la scatola di sempre (la Sede, il complesso) | il corridoio a tubo, il pozzo fra due piani |
| `magione` | scatole attaccate come le stanze di una casa | una porta nel muro; fra due piani una scala a gradini |
| `laboratorio` | come la magione: un altro edificio | una porta |
| `giardino` | un'aiuola dal contorno regolare, alzata da terra | un sentiero |
| `natura` | una radura dal bordo storto, alzata da terra | un sentiero che serpeggia, e sale se sale |
| `cunicoli` | una caverna dalla volta storta | una galleria che si allarga e si stringe |

I dettagli: `collina` (la stanza in cima e sotto la collina fino al piano di
sotto), `fossa` (tutto scende verso il fondo), `ponte` (un'asse sopra il
vuoto), `spiovente` (il tetto a due falde), `serra` (la volta a botte),
`sala` e `piazza` (una caverna scavata, dal contorno piu' regolare).

Le forme storte sono storte sempre allo stesso modo: il caso viene dal nome
della stanza, e la mappa non cambia sagoma a ogni apertura. Le radure escono un
po' dalla loro cella (la natura non sta in fila); le stanze della magione si
toccano (fra due stanze c'e' un muro, non un vicolo). Il pavimento di un piano
con prati o caverne e' il contorno morbido del terreno, e sotto terra e'
tratteggiato.

`"percorsi"` sulla mappa dice per dove passa un sentiero che non deve tagliare
in mezzo a qualcosa: nella Casa Gigante il sentiero dal giardino al giardino
ovest gira davanti alla casa invece di attraversarla.

Per cliccare non cambia niente: la stanza si clicca sulla sua sagoma di prima,
le icone e i nomi stanno dove stavano.

## 3. Le tre zone

**Le Pianure di Redenna** (`natura`): radure alzate da terra, il sentiero che
serpeggia dal punto d'atterraggio al bivio, e il promontorio: la cima sta un
piano sopra, e sotto c'e' la collina che sale dalla pianura. La piccola
caverna e il suo fondo sono caverne, con la galleria che scende dall'albero.
Il pasto del goblin e il masso si sono spostati di una casella, perche' la
valle non andasse dritta come un righello.

**La Casa Gigante** (`magione`), rifatta come l'ha descritta Bru:

- al centro la magione, tre stanze per tre a piano terra (la stanza degli
  studi, la sala principale, la cucina; l'ala sinistra, il salone, l'ala
  destra), con la soglia davanti;
- i piani di sopra **sopra** quelli di sotto: la scala sopra la sala
  principale, la stanza dei giochi sopra la stanza degli studi (la botola
  scende dritta), il bagno sopra la cucina, la soffitta sopra la scala, e in
  cima l'attico e la camera da letto sotto il tetto a spiovente;
- sotto le fondamenta il tunnel e l'altare, che sono cunicoli;
- **ai fianchi i giardini**: a est il giardino grande, il giardino nord, il
  giardino est, l'albero grande e la serra del vivaio (che scende in caverna);
  a ovest il giardino ovest;
- **dall'altra parte i laboratori**: oltre il giardino ovest, il grande
  laboratorio, la sala delle matrici e il deposito chimico.

E' una mia lettura delle parole di Bru («ai fianchi i giardini e i laboratori
dall'altra parte»): giardini sui due lati della casa, laboratori oltre quello
di ovest, lontani dal giardino grande. I piani delle stanze sono quelli di
prima, quindi «Sali» porta ancora su e «Scendi» giu'.

**La Rocca di Ossidiana**, i cunicoli di Jondoh (`cunicoli`): caverne e
gallerie; le sale del raccolto e del lamento e la piazza sotterranea sono
scavate, piu' regolari; la fossa oscura e' un imbuto, il grande ponte marcio e'
un'asse sopra il baratro.

## 4. Le altre zone

La Sede e il complesso restano `edificio`: sono un edificio. Meridia e lo
Squarcio Industriale per ora anche: se va bene la strada, la citta' puo'
diventare isolati e strade (il parco un prato), lo Squarcio tubi, nastri e
vasche, sempre solo come forma dello spazio. Basta un ambiente nuovo in
AmbientiPlastico e la parola nei dati.

## 5. Le prove

- `prova_mappe`: ambienti e dettagli sono parole che il plastico conosce, i
  `percorsi` vanno fra stanze legate davvero, e su un plastico due stanze non
  stanno sulla stessa casella **dello stesso piano**.
- `prova_le_zone_somigliano_al_loro_posto`: le radure non sono scatole, fra
  due radure c'e' un sentiero e fra due caverne una galleria, le stanze della
  magione si toccano, i piani della magione stanno sopra il piano terra, i
  giardini stanno ai fianchi e i laboratori dall'altra parte, il sentiero fra
  i giardini non taglia la casa, la Sede e' ancora a scatole; e una stanza
  senza dettaglio e' un pezzo solo (velo e spigoli), cioe' niente cose dentro.

`strumenti/genera_mappe.py` scrive la griglia di `docs/mappe.md` un piano alla
volta quando due stanze di piani diversi stanno sulla stessa casella.
