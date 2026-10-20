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

## 2. Come funziona

Ogni stanza ha un **ambiente**: quello della zona (`"ambiente"` nel
`mappa_dungeon`) o il suo, se e' diverso (`"ambiente"` sulla stanza). Il codice
sta in tre file:

- `scripts/AmbientiPlastico.gd` decide che forma ha una stanza e come si va da
  una all'altra, ambiente per ambiente;
- `scripts/ArrediPlastico.gd` disegna i **dettagli**, quello da cui una stanza
  si riconosce (`"dettaglio"` sulla stanza);
- `scripts/FormePlastico.gd` ha le forme: contorni morbidi, prismi, cupole,
  colline, sentieri, gallerie, alberi, colonne.

| ambiente | la stanza | da una stanza all'altra |
|---|---|---|
| `edificio` | la scatola di sempre (la Sede, il complesso) | il corridoio a tubo, il pozzo fra due piani |
| `magione` | stanze attaccate come in una casa, con le finestre sui muri di fuori | una porta nel muro; fra due piani una scala a gradini |
| `laboratorio` | come la magione, col tetto a pannelli e gli sfiati | una porta |
| `giardino` | un prato con la siepe e un albero | un sentiero |
| `natura` | una radura dal bordo storto, con l'erba e gli alberi | un sentiero che serpeggia, e sale se sale |
| `cunicoli` | una caverna dalla volta storta | una galleria che si allarga e si stringe |

I dettagli: `alberone`, `masso`, `pozze`, `collina` (la stanza in cima e sotto
la collina fino al piano di sotto), `tartaruga`, `falo`, `atterraggio`,
`cartello`, `grotta` (stalagmiti), `ponte` (sopra il vuoto), `fossa`, `piazza`
e `sala` (le colonne), `cargo`, `varco` (l'anello da cui si entra), `serra`,
`vasche`, `scaffali`, `altare`, `spiovente` (il tetto), `cancello`, `fiori`.

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

**Le Pianure di Redenna** (`natura`): radure con l'erba e gli alberi, il
sentiero che serpeggia dal punto d'atterraggio al bivio, il fuoco del goblin,
l'albero grande, il masso, il cartello del bivio, le pozze, la tartaruga, e il
promontorio: la cima sta un piano sopra, e sotto c'e' la collina che sale dalla
pianura. La piccola caverna e il suo fondo sono caverne vere, con la galleria
che scende dall'albero. Il pasto del goblin e il masso si sono spostati di una
casella, perche' la valle non andasse dritta come un righello.

**La Casa Gigante** (`magione`), rifatta come l'ha descritta Bru:

- al centro la magione, tre stanze per tre a piano terra (la stanza degli
  studi, la sala principale, la cucina; l'ala sinistra, il salone, l'ala
  destra), con la soglia davanti;
- i piani di sopra **sopra** quelli di sotto: la scala sopra la sala
  principale, la stanza dei giochi sopra la stanza degli studi (la botola
  scende dritta), il bagno sopra la cucina, la soffitta sopra la scala, e in
  cima l'attico e la camera da letto sotto il tetto a spiovente;
- sotto le fondamenta il tunnel e l'altare, che sono cunicoli;
- **ai fianchi i giardini**: a est il giardino grande, il giardino nord, i
  fiori del giardino est, l'albero grande e la serra del vivaio (che scende in
  caverna); a ovest il giardino ovest;
- **dall'altra parte i laboratori**: oltre il giardino ovest, il grande
  laboratorio, la sala delle matrici con gli scaffali, il deposito chimico con
  le vasche.

E' una mia lettura delle parole di Bru («ai fianchi i giardini e i laboratori
dall'altra parte»): giardini sui due lati della casa, laboratori oltre quello
di ovest, lontani dal giardino grande. I piani delle stanze sono quelli di
prima, quindi «Sali» porta ancora su e «Scendi» giu'.

**La Rocca di Ossidiana**, i cunicoli di Jondoh (`cunicoli`): caverne e
gallerie; le sale del raccolto e del lamento e la piazza sotterranea sono
scavate e hanno le colonne, la fossa oscura e' un imbuto, il grande ponte
marcio e' un ponte sopra il baratro, il varco e' l'anello da cui si entra, il
cargo e' un container abbandonato.

## 4. Le altre zone

La Sede e il complesso restano `edificio`: sono un edificio. Meridia e lo
Squarcio Industriale per ora anche: se va bene la strada, la citta' puo'
diventare isolati e strade (il parco un prato), lo Squarcio tubi, nastri e
vasche. Basta un ambiente nuovo in AmbientiPlastico e la parola nei dati.

## 5. Le prove

- `prova_mappe`: ambienti e dettagli sono parole che il plastico conosce, i
  `percorsi` vanno fra stanze legate davvero, e su un plastico due stanze non
  stanno sulla stessa casella **dello stesso piano**.
- `prova_le_zone_somigliano_al_loro_posto`: le radure non sono scatole, fra
  due radure c'e' un sentiero e fra due caverne una galleria, le stanze della
  magione si toccano e hanno le finestre solo sui muri di fuori, i piani della
  magione stanno sopra il piano terra, i giardini stanno ai fianchi e i
  laboratori dall'altra parte.

`strumenti/genera_mappe.py` scrive la griglia di `docs/mappe.md` un piano alla
volta quando due stanze di piani diversi stanno sulla stessa casella.
