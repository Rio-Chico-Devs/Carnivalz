# I mondi da esplorare: come si generano, e con che stile

> Bru: «mi piacerebbe che esplorassi come in the legend of zelda, i vecchi
> giochi, a link to the past o the minish cap, ma con la differenza che è solo
> un gioco di progressi, dove rendi autonome le zone spendendo risorse fino a
> colonizzare tutto il pianeta». Poi: «dobbiamo concentrarci per generare le
> mappe e i mondi da esplorare che siano coerenti con il nostro stile».

È una **prova**: nel gioco non cambia niente. Prende il posto della raccolta
stampata (`docs/pianeti_giochi.md` §9), che a Bru non piaceva: «anche peggio di
prima, hai solo aggiunto roba in più».

    F6 su prove/MondoProva.tscn   un pianeta da giocare (N un altro, B l'altro bioma, M la mappa)
    ./prove/mondi.sh              controllo, pilota, panoramiche, film: in scatti/mondi/
    ./prove/mondi.sh controllo    solo il controllo dei semi e il pilota automatico
    ./prove/mondi.sh tessere      riscrive in art/pianeti/ i PNG che mancano

## 1. Cosa c'è

Tre pezzi separati, apposta:

| | file | cosa fa |
|---|---|---|
| **il generatore** | `prove/MondoGenera.gd` | da un numero (il seme) e un bioma fa un pianeta: terreno, regioni, confini, passaggi, fari, vene, decori. Solo dati, niente disegno |
| **le tessere** | `art/pianeti/<bioma>/*.png` | i disegni. Ognuno si sostituisce da solo (`art/pianeti/README.md`). Se un file manca lo disegna `prove/MondoTessere.gd` |
| **la prova** | `prove/MondoProva.gd` | mette insieme le due cose e ci fa camminare: telecamera, collisioni, cosa si paga, la corruzione, la mappa |

Il generatore non sa niente di come è disegnato il mondo, e le tessere non
sanno niente di come è fatto. Per questo un disegno nuovo di Bru, o fatto con
uno strumento, entra nel gioco **senza toccare il codice**, e ogni pianeta
generato lo usa subito.

## 2. Le regole dello stile

Il problema dei giri prima era disegnare col codice a misura di schermo e poi
coprire con gli effetti. Qui è il contrario: **pixel art piccola e onesta,
nessun filtro sopra**. Le regole stanno anche nel README delle tessere; queste
sono quelle che fanno «nostro» un pianeta:

1. **Vista dall'alto e un po' di fronte, 16 pixel per casella, ingrandita
   tre volte.** È la vista degli Zelda a 16 bit: si capisce cosa è muro e
   cosa è pavimento, e i pezzi si ripetono.
2. **Luce dall'alto a sinistra, sempre.** Ogni cosa ha la sua ombra ovale per
   terra.
3. **Una tavolozza piccola per bioma**, con le ombre che virano al freddo e le
   luci al caldo. La natura cambia da pianeta a pianeta: prati e acqua chiara
   sulle Pianure; sabbia rossa, erba bruciata, agavi, alberi secchi e lava
   intorno al Vuoto Ardente, il mondo di Jerah.
4. **L'Organizzazione ha la sua livrea, uguale su ogni pianeta**: i quattro
   inchiostri della mappa stellare (`data/stile.json`). Carta crema, segnale
   arancio, fondo scuro, inchiostro blu. Il faro, le case, i lampioni, la
   capsula: si vede da lontano dove è arrivata lei.
5. **Il Carnivalz è la corruzione.** Una regione non ancora tua è spenta e
   virata verso il colore della fonte (prugna sulle Pianure, rosso brace
   sull'Ardente), e ci crescono i rovi. Non è un disegno diverso: è il gioco
   che toglie colore (`prove/mondo_corruzione.gdshader`).
6. **Il prima e il dopo sono la ricompensa.** Ripari il faro e il colore
   torna a onda, i rovi se ne vanno, compaiono le case e i campi. È il momento
   «area restored» dell'immagine di Gardenscapes, a modo nostro.
7. **Le scritte restano del gioco**: le etichette del manifesto in Archivo
   corsivo, nitide sopra la pixel art.

## 3. Come è fatto un pianeta

1. **L'isola.** Rumore e una caduta verso i bordi; si tiene il pezzo di terra
   più grande e si levigano le punte larghe una casella.
2. **Le regioni** (da 6 a 10). La prima è dove si atterra, a sud. Ogni
   casella va al seme di regione più vicino *camminando*, con un costo che
   ondeggia: così i confini girano come fiumi.
3. **La fila.** Dalla prima regione, in larghezza: ogni regione ha un
   genitore, quella da cui ci si arriva. È l'ordine in cui si apre il
   pianeta.
4. **Le altezze.** Quasi metà delle regioni sta in alto (mai la prima, mai due
   di fila). Dove l'alto finisce verso sud c'è la parete della rupe, alta due
   caselle.
5. **I confini.** Fra due regioni non si passa mai: un fiume, un bosco fitto,
   i rovi del Carnivalz, o la rupe se le altezze sono diverse.
6. **I passaggi.** Fra ogni regione e il suo genitore, un varco nel confine,
   chiuso da una cosa da pagare: il ponte da riparare, i rovi da bruciare, la
   scala da rifare. Il costo cresce con la distanza dall'atterraggio.
7. **Il cuore, le vene, il forziere.** Il faro va nel punto più interno della
   regione; tre vene lontane fra loro (quarzo vicino all'atterraggio, poi
   ferro, poi cristallo); un forziere nell'angolo più nascosto, una regione sì
   e una no.
8. **I sentieri.** Dal faro ai passaggi e alla capsula: terra battuta che gira
   un po', e le strade si uniscono.
9. **Il vestito.** Sabbia lungo il mare, chiazze di terra dove è secco, macchie
   d'erba alta, boschetti, sassi, fiori, i rovi dentro le regioni selvagge, e i
   posti delle case intorno a ogni faro.

**Il controllo** (`MondoGenera.controlla`) prova che il pianeta si finisce:
dalla capsula si arriva solo nella prima regione, e ogni passaggio pagato apre
esattamente la regione dopo e nient'altro. Ogni faro, vena e forziere si
raggiunge. Un seme che non passa (circa uno su quindici) si scarta, e si prova
il successivo, sempre nello stesso ordine: lo stesso numero dà sempre lo
stesso pianeta. `./prove/mondi.sh controllo` lo fa su trenta semi per bioma.

**Il pilota automatico** gioca da solo: se ha di che pagare la prossima cosa
ci va, se no va alla vena che serve. Colonizza un pianeta intero in quattro o
cinque minuti di gioco, ed è anche lui una prova: `mondi.sh` si ferma se non
finisce.

## 4. Come si gioca (la prova)

- Si atterra nella prima regione, **selvaggia**: spenta, con i rovi.
- Si scava nelle vene (E): cinque pezzi alla volta, e la vena ricresce.
- Si **ripara il faro**: la regione diventa **autonoma**. Il colore torna a
  onda, compaiono le case, e da lì in poi la regione **manda una risorsa ogni
  sei secondi** anche mentre sei altrove.
- Si paga il **passaggio** verso la regione dopo, e si ricomincia.
- **M** apre la mappa del pianeta: solo quello che hai visto, le regioni tue
  accese, i fari.
- Tutti i fari accesi: **pianeta colonizzato, 100%**.

## 5. Le tessere vere: come farle senza che il mondo cambi stile

Il codice ha disegnato tessere provvisorie ma in regola. Per quelle vere ci
sono tre strade, e si possono mescolare, un file alla volta:

- **A mano, in Aseprite** (o qualunque programma a pixel): si apre il PNG, si
  ridisegna, si salva con lo stesso nome. Le misure e il piede di ogni cosa
  sono nel README.
- **Con PixelLab**: genera terreni a 16 pezzi che si raccordano, personaggi in
  4 e 8 direzioni e oggetti. Conviene dargli **la tavolozza del bioma** e
  **la tessera di adesso come riferimento**, e chiedere la stessa vista. I
  terreni vanno rimessi nell'ordine del README: un terreno a 16 pezzi ha gli
  stessi pezzi, magari in un altro ordine.
- **Con Retro Diffusion** (dentro Aseprite): utile per le trame dei terreni,
  con la tavolozza bloccata.

In tutti e tre i casi valgono le regole del §2. La più facile da rompere è la
luce: un pezzo con la luce da destra si vede subito, anche se è bellissimo.
Su Steam la grafica fatta con l'AI va dichiarata nella pagina del gioco.

## 6. I protagonisti

> Bru: «se ti mando un disegno del personaggio principale riesci a creare
> l'omino a sua somiglianza?»; poi i disegni di lui e di lei. Sul primo giro
> (24×32): «bisogna lavorarci meglio»; e: «non disegnare la bocca, fai meglio
> gli occhi, anche l'anatomia e i frame di animazione devono essere meglio».
> Poi il «tactical RPG sprite sheet» dei due: «ecco degli esempi, riesci a
> farli uguali o meglio?». Sui chibi ridisegnati: «no devi farli uguali»; e
> col foglio del passo di lei: «cominciamo con la female per ora».

Nel gioco **P** passa dall'uno all'altra; dalla riga di comando
`protagonista lei`.

### Lei: uguale al foglio di Bru

`strumenti/protagonisti/ricalca.py` scrive `art/pianeti/protagonista/lei.png`
dal foglio di Bru, che sta nel progetto (`strumenti/protagonisti/fogli/lei.png`).
Non si ridisegna niente: si ricostruiscono i pixel del foglio.

- **La griglia.** Il foglio è un JPG ingrandito: ogni pixel del disegno è un
  quadretto di circa 4,5 pixel dell'immagine, sbavato. Per ogni fotogramma lo
  strumento trova dove cadono i bordi dei quadretti, in larghezza e in altezza.
- **I colori.** Per ogni quadretto si prende il colore più rappresentativo dei
  pixel interni, non la media, che impasterebbe il contorno col fondo. Poi si
  toglie la scacchiera.
- **La pulizia.** Bru: «possiamo rendere i disegni più chiari e puliti?». Il
  ricalco così com'è era scuro e sporco di JPG, e sull'erba del pianeta si
  perdeva. Il disegno resta quello del foglio; cambiano solo la luce e lo
  sporco:
  - i colori si schiariscono un poco (la luminosità alla 0,82) e si accendono
    (la saturazione per 1,25);
  - ogni colore va sulla rampa del suo materiale: capelli e top lavanda,
    pelle, fascia prugna, ottone e lenti rosa degli occhialoni, stivali e
    guanti, shorts;
  - un puntino che non ha vicini del suo materiale prende quello dei vicini;
  - dentro ogni materiale i toni si fanno a macchie piene;
  - il bordo della figura diventa un contorno scuro netto.

  `ricalca.py fedele` rifà la versione di prima, senza pulizia.
- **La misura.** Davanti e dietro lei è alta 50 pixel, quindi i fotogrammi
  sono 32×56. Il gioco ricava la misura dal foglio e mette i piedi al centro,
  tre righe sopra il fondo.
- **Il passo.** Bru: «bisogna migliorare le animazioni di movimento». Davanti
  il foglio ha due fotogrammi con la stessa posa: in tutti e due la gamba
  destra è avanti. Dietro ce n'è uno solo buono, perché il «back frame 1» ha
  la giacca nera e i pantaloni a righe di lui. Così lei non alternava mai le
  gambe e sembrava strisciare.

  Il primo giro (gambe che cambiavano di uno o due pixel su otto tempi) era
  «già meglio ma bisogna ancora lavorarci un pochino». Bru ha mandato come
  esempio il passo di Samarie (*Fear and Hunger: Termina*). Lì quello che
  conta è:
  - il ritmo a tre pose: un passo, in piedi, l'altro passo, in piedi;
  - le pose grandi e chiare.

  Adesso `strumenti/protagonisti/passo.py` fa così:
  - **davanti e dietro**, con le gambe del foglio separate:
    - il piede che va avanti scende di due pixel e va un poco in fuori;
    - quello dietro si alza di tre;
    - nei passi il busto è un pixel più giù che in piedi;
    - le braccia vanno al contrario delle gambe;
  - **di lato** le gambe del foglio erano corte e tutte e due dello stesso
    scuro: non si leggevano. Si tengono testa, busto e braccio del foglio (la
    testa del primo tempo, ingranditi fino all'altezza di davanti), e le gambe
    le disegna lo strumento, articolate:
    - coscia, risvolto e stivale, coi colori di lei;
    - la gamba lontana più scura;
    - nei passi un piede lontano davanti e uno dietro, in punta;
    - il braccio vicino va al contrario.
- **Nel gioco** il passo va avanti di un tempo ogni 5 pixel di strada fatta, e
  non più a tempo, così i piedi non pattinano. Ogni posa tiene due tempi
  (10 pixel). Da fermi, ogni tanto, c'è il respiro: il busto scende di un
  pixel e risale. Il foglio ha dieci colonne: fermo, il respiro e gli otto
  tempi.
- **L'aspetto.** Bru ha mandato il suo disegno di lei: «miglioriamo l'aspetto
  del personaggio, sopra la testa non ha degli occhiali ma un cerchio d'oro».
  Il foglio del passo, fatto con l'AI, le metteva degli occhialoni e la pelle
  chiara. `strumenti/protagonisti/aspetto.py` la veste come nel disegno,
  sopra il ricalco pulito:
  - la fascia cremisi, con la luce sopra, l'ombra sotto e le stelle chiare,
    che segue la testa in ogni vista;
  - il cerchio d'oro sul lato destro della testa: davanti a sinistra di chi
    guarda, di lato tondo, da dietro di taglio sul bordo;
  - le lenti e l'ottone degli occhialoni diventano fascia;
  - la pelle abbronzata, gli occhi viola-magenta, e guanti, stivali e shorts
    di nero lucido.

  Per riconoscere i materiali del ricalco si usano sempre i colori del foglio
  (`MATERIALI`); poi ogni tono si dipinge col colore del disegno (`ASPETTO`).
- **Cosa la pulizia toglie**: la boccuccia del foglio, perché è un puntino solo
  e lo prende per sporco.

### Lui: ridisegnato a mano, per ora

`strumenti/protagonisti/disegna.py` scrive `art/pianeti/protagonista/lui.png`
(32×48, i piedi a 16, 45; dieci colonne come lei, con i suoi quattro tempi
tenuti per due colonne ciascuno).

- **Chibi, dal primo foglio di Bru.** Proporzioni e colori sono presi dal
  ricalco. Ogni pezzo è ridisegnato a mano lettera per lettera (`lui.py`):
  niente bocca, la luce sempre dall'alto a sinistra.
- **Il passo ha quattro tempi**: un piede avanti, il passaggio con l'altra
  gamba piegata, l'altro piede avanti, di nuovo il passaggio. Le braccia vanno
  al contrario delle gambe; quando i due piedi sono a terra il corpo scende di
  un pixel. Di lato braccia e gambe sono arti articolati (`lato.py`,
  `arti.py`), con lo stivale e il guanto in fondo.
- **Lui** ha:
  - i capelli a punte;
  - la sciarpa bianca arrotolata, con le code che di lato ondeggiano;
  - la giacca nera aperta sugli addominali e le maniche arrotolate;
  - i guanti senza dita e i jeans scuri strappati;
  - lo spadone sulla schiena.
- **Il prossimo passo è farlo uguale come lei.** Serve un foglio del suo passo
  come quello di lei: nel primo foglio lui è quasi sempre fermo.

## 7. Le domande per Bru

1. **La direzione è questa?** Pixel art a 16 pixel, vista alla Zelda, prima e
   dopo come ricompensa.
2. **Le tessere vere**: le disegni tu, proviamo con PixelLab (serve un
   account; con una chiave posso generarle io e metterle al loro posto), o un
   artista?
3. **I biomi**: per adesso Pianure e Ardente. Quali pianeti vuoi, e da quali
   mondi vengono? Ogni Vuoto potrebbe avere i suoi.
4. **Il pianeta**: grande così (sei-dieci regioni, quattro o cinque minuti per
   finirlo col pilota, di più a mano) o più grande e più lento?
5. **I protagonisti** (§6) adesso sono chibi alti più di tre caselle: le case e gli
   alberi del mondo sono rimasti piccoli. Li ingrandiamo (case da 3-4 caselle,
   alberi più alti), o teniamo i protagonisti più bassi?
6. **Il resto del foglio di Bru** (le icone delle armi, le pozioni, la moneta,
   gli effetti, le teste per i ritratti): li rifacciamo nello stesso modo, e
   dove vanno nel gioco?
