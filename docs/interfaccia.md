# Il negozio e la scheda della squadra

Le due schermate rifatte sugli schemi di Bru: il negozio (dalla Sede) e la
scheda della squadra (ESC → Personaggio e squadra). La struttura è quella dei
suoi riferimenti. La scheda è specchiata come ha chiesto: il personaggio e le
carte a destra, le informazioni a sinistra. I colori e le forme sono quelli del
gioco.

| cosa | dove |
|---|---|
| il foglio da 1280×720 su cui è disegnato tutto | `scripts/Tavola.gd` |
| il negozio | `scripts/Negozio.gd`, `Vetrina.gd`, `CartaNegozio.gd` |
| cosa si vende, se si può prendere, cosa fa un oggetto | `scripts/Merce.gd` |
| la scheda della squadra | `scripts/Personaggio.gd`, `CartaSquadra.gd`, `SlotScheda.gd`, `StatisticheScheda.gd`, `VoceCandidato.gd`, `FiguraIntera.gd` |
| quanto vale un compagno, cosa gli cambia un oggetto | `scripts/Corredo.gd` |
| i tasti a fascia storta (COMPRA, le linguette, Indietro) | `scripts/TastoObliquo.gd` |
| la descrizione che scorre | `scripts/TestoCheScorre.gd` |
| i disegni a forme che tengono il posto a quelli veri | `scripts/Sagome.gd` |

## Il foglio

Bru disegna a 1280×720, la misura del gioco. Qui dentro si ragiona in pixel del
suo disegno: una carta sta a 40,400 perché nello schema sta lì. Chi apre lo
schema e il codice legge gli stessi numeri.

Il foglio poi si scala intero finché ci sta, e si centra. **Con «testo più
grande»** lo schermo utile scende a 1024×576 e il foglio si rimpicciolisce di un
quinto. Così resta intero, ma **in queste due schermate il testo grande non
ingrandisce niente**. È una scelta da rivedere con Bru, se il testo grande deve
valere anche qui. I corpi non scendono mai sotto i 12-13 pixel apposta
(`prova_la_tavola_sta_intera_anche_col_testo_grande`).

## La lingua visiva

- **Nero** di fondo (`sfondo`), con la trama a puntini appena visibile: dice
  "carta", non "vuoto".
- **Cremisi** (`accento`, #e8123c) è l'unico colore caldo. Sta sulla fascia storta
  (la vetrina del negozio, la fascia dietro il personaggio) e su quello che è
  scelto.
- **La sfoglia bianca** sfalsata sotto quello che è scelto, sulle carte, sulle
  caselle e sui tasti. È la lastra doppia delle voci della pausa: carta
  ritagliata e incollata.
- **Tutto pende** con la stessa pendenza delle fasce (0,48): le carte dello
  scaffale, la vetrina, la fascia del personaggio. I tasti usano il taglio dei
  cartigli (0,35).
- **Anton** per numeri e titoli, **Nunito** per le scritte da leggere.

## Il negozio

| nello schema di Bru | qui | x, y, largo, alto |
|---|---|---|
| le linguette in alto | **i negozi aperti**, uno per linguetta (interpretazione mia) | da 180,10, fino a x 940 |
| il numero grande a sinistra | i Tazo in tasca, che scendono quando compri | 108,104,520,124 |
| il testo sotto | la descrizione dell'oggetto scelto: l'effetto in numeri, la descrizione, quanti ne hai già. **Scorre** se è lunga | 115,276,460,100 |
| le carte in basso | lo scaffale: 5 carte alla volta, parallelogrammi larghi 122 in cima, alti 190, che scendono di 91 a sinistra | la prima a 40,400, poi ogni 129 |
| sotto le carte | due o tre parole: se la puoi prendere (SACCA PIENA, MANCANO 12, 1/3 MATERIALI, GIÀ TUO...) | larghe 118, una per carta |
| le frecce in basso | pagina prima e dopo, e dove sei ("DA USARE IN COMBATTIMENTO · 2 DI 14") | 40,640 e 98,640 |
| F, la fascia scura obliqua | **la vetrina cremisi**: prezzo, disegno grande, nome, e tre riquadri con quello che fa in numeri | fascia da (980,0)-(1295,0) a (634,720)-(949,720) |
| G, il blocco accanto | quanti Tazo ti **restano** (o ti mancano), quanti ne **hai** (con la miniatura), e **COMPRA**, che se non si può dice perché proprio sotto (interpretazione mia) | 1070,372 · 1060,468 · 1030,566,240,50 |

Un baratto dell'Artigiano mostra BARATTO al posto del prezzo. I riquadri
diventano i materiali, uno per materiale, con i doppioni insieme: "1/2" sopra
ROTTAME DI METALLO, in cremisi finché non li hai tutti.

## La scheda della squadra

| nello schema di Bru | qui | x, y, largo, alto |
|---|---|---|
| in alto | INDIETRO, DATA PAD, e il cartiglio SQUADRA | 16,10 · a destra |
| l'emblema e il nome | l'emblema, il nome (si stringe se è lungo), il livello in cremisi, la classe | 38,102,97,103 · 153,116,280,56 |
| D7, la barra | **il legame della squadra** (interpretazione mia), con la psiche sotto a sinistra | 40,210,453,6 |
| E, le statistiche | vita, attacco, difesa, velocità, aura. Quello che viene dall'equipaggiamento sta tra parentesi e col suo colore. Scegliendo un oggetto la riga dice dove andresti: "18 → 24" | 45,272,440,176 |
| F1-F3, le tre caselle in basso | **il carosello dell'equipaggiamento** (interpretazione mia): al centro lo slot su cui sei, ai lati il precedente e il successivo. Gira in tondo | 44,513,123,154 · 189,477,164,208 · 372,513,121,154 |
| C, il personaggio | la figura intera, sulla fascia cremisi | 500,62,490,658 |
| B1-B3, le carte | la squadra: tre carte alla volta. Con più di tre compagni compaiono le frecce e il conto ("2–4 DI 4"), e la fila segue chi scegli | 1002,119 poi ogni 107, larghe 249, alte 84 |
| sotto le carte | il dettaglio dello slot al centro. Quando apri uno slot diventa **la scelta di cosa metterci**: ogni candidato dice cosa cambia rispetto a quello che porti | 1002,430,249,256 |

Chi è con te **solo per un tratto** ha la carta con scritto DI PASSAGGIO, e
niente carosello: non gli si affida niente finché non resta.

## Come si usa

**Negozio.** Col mouse: clic su una carta, clic su COMPRA; la rotella scorre lo
scaffale. Con la tastiera:
- le frecce scorrono le carte, e in fondo dicono di no;
- INVIO sulla carta scelta porta su COMPRA, un altro INVIO compra;
- da COMPRA, dalle linguette e dalle frecce di pagina si torna sempre alla carta
  scelta, mai a quella più vicina.

Comprare non aspetta niente: i Tazo se ne vanno subito e il numero li insegue.

**Scheda.** La tastiera sta tutta sul carosello:
- destra e sinistra girano gli slot;
- su e giù cambiano compagno, per tutta la squadra;
- INVIO apre lo slot, ESC chiude la scelta e poi la scheda.

Aperta la scelta, le frecce restano lì dentro: se ne esce con CHIUDI, con ESC o
col mouse. Col mouse:
- clic sulle carte;
- la rotella sulla fila per il compagno dopo, sul carosello per girarlo;
- clic sulle caselle laterali per girare.

## Come si muove

Tutti i tempi sono quelli del vocabolario (`data/stile.json`, sezione
`movimento`). Nessun gesto supera il mezzo secondo e niente fa aspettare.

- **Entrata**: prima il guscio (la barra, la vetrina), poi le carte in cascata,
  per ultima l'azione principale (COMPRA). È l'ordine della pausa. Se
  un'entrata riparte mentre la precedente è a metà (due linguette di fila), la
  vecchia si ferma e i pezzi tornano al loro posto vero.
- **Passarci sopra**: il bordo si accende su una molla (colore) e la carta si
  alza o si sporge su un'altra (forma), come vuole Material.
- **Premere**: la gelatina. **Non si può**: una scossa breve e il suono del
  rifiuto, mai un tasto morto.
- **Cambiare oggetto o compagno**: il disegno nuovo arriva scivolando da destra.
  Lo scaffale e il carosello scivolano di mezza carta. Tenendo giù la freccia,
  ogni scivolata ferma quella prima.
- **La descrizione lunga scorre** alla velocità di chi legge:
  - prima resta ferma il tempo di leggere l'inizio;
  - poi sale di una riga ogni `lettura.riga` secondi (2,5, un tempo mio);
  - in fondo si ferma, poi torna in cima dissolvendosi;
  - col mouse sopra si ferma; la rotella la sposta a mano;
  - un testo che ci sta non si muove mai.
- **Col movimento ridotto** niente si sposta: i colori cambiano subito, le cose
  entrano dissolvendosi, la descrizione gira pagina invece di scorrere.

## I disegni da fare, e le misure

L'elenco di chi manca, con i nomi esatti dei file, sta in `docs/immagini.md`
(sezione *Il negozio e la scheda della squadra*). Qui ci sono le misure. Sono
in pixel del foglio 1280×720: **conviene disegnare al doppio** (colonna *da
fare*), perché su uno schermo grande il foglio si ingrandisce. PNG con
trasparenza.

| file | dove si vede | riquadro sul foglio | come ci entra | da fare |
|---|---|---|---|---|
| `art/oggetti/<id>.png` | vetrina | 215×285 | intero, centrato | circa 430×570, o quadrato 512×512 |
| (lo stesso) | carta dello scaffale | 97×97 | intero, centrato | |
| (lo stesso) | miniatura accanto a "×N" | 86×86 | intero, centrato | |
| (lo stesso) | casella del carosello | 90×90 al centro, 67×67 ai lati | intero, centrato | |
| `art/personaggi/<id>/intero.png` | figura al centro della scheda | largo 490, alto fino a 710 | scalato alla larghezza, **appoggiato in basso**; se è più alto esce dal fondo, come nel riferimento | 980×1400 circa |
| `art/personaggi/<id>/carta.png` | ritratto nella carta della squadra | 113×76 | **riempie** il riquadro tagliando quello che avanza (una fototessera): il viso al centro | 240×160 |
| `art/personaggi/<id>/emblema.png` | accanto al nome | 97×103 | intero, centrato | 200×200 |
| `art/interfaccia/statistiche/<chiave>.png` | icone delle statistiche | 24×24 su un quadrato nero | intero, centrato; meglio bianco su trasparente | 52×52 |

Il file vince sempre sul disegno a forme. Un disegno non quadrato non viene
schiacciato: entra intero nel suo riquadro
(`Sagome.dentro`, provato da `prova_col_movimento_ridotto_la_nuova_interfaccia_sta_ferma`).

La cartella di un compagno è quella delle sue espressioni, col suo **id**: i
disegni di Yhvina vanno in `art/personaggi/insonne/`. Veronica come compagna di
squadra ha id `brawler` (`art/personaggi/brawler/`), diverso dalla Veronica dei
dialoghi (`art/personaggi/veronica/`). Oggi `brawler` non la usa nessuno script:
è da decidere se tenerlo.

## Le mie interpretazioni, da confermare

- Le **linguette** in cima al negozio sono i negozi aperti.
- Il **blocco G** è quanti Tazo ti restano, quanti ne hai già, e COMPRA.
- Le **tre caselle in basso** nella scheda sono il carosello
  dell'equipaggiamento: arma, stigma, ultima risorsa, poi gli accessori.
  Quelli aperti, più uno chiuso col lucchetto, che dice che la strada continua.
- La **barra D7** è il legame della squadra.
- **Il testo grande** non ingrandisce queste due schermate: le scala intere.

## Testi scritti da me, provvisori

Tutti da rivedere; stanno anche in `docs/testi_da_correggere.md` (sezione 1,
*Negozio* e *Scheda della squadra*).

**Negozio**
- TAZO IN TASCA
- Qui oggi non c'è niente da comprare.
- sotto le carte: SI PUÒ FARE, 1/3 MATERIALI, MANCANO 12, GIÀ TUO, IN SACCA ×2, SACCA PIENA, NIENTE POSTO, AL MASSIMO
- sotto COMPRA: ti mancano 12 Tazo, ti manca un materiale / ti mancano 2 materiali, ce l'hai già, la sacca è piena, non hai più posto per tenerlo, più spazio di così non c'è
- nella vetrina: IN CAMBIO DI, BARATTA, TI RESTANO / TI MANCANO / MATERIALI, IN SACCA / POSSEDUTI / ALLARGATO
- nei riquadri: VITA, STRESS, DANNI, VITA A BATTUTA, BATTUTE, OGNI MALE, SCUDO, RINASCITA
- le categorie: Da usare in combattimento, Armi e stigmi, Accessori, Altro, Baratti
- il danno col suo elemento: "6 danni da fuoco" (psichici, oscuri, elettrici, da veleno)
- il Frammento di vita: "rigenera il 10% della vita a battuta, per 3 battute"

**Scheda**
- SQUADRA, CLASSE, LIVELLO, PSICHE · …, LEGAME DELLA SQUADRA …, STATISTICHE
- + METTI QUALCOSA, SI APRE AL LIVELLO 6, COSA METTERCI, TOGLI, CHIUDI, DI PASSAGGIO
- Vuoto. Premi la casella al centro per vedere cosa puoi metterci.
- È con te solo per un tratto: non gli si affida ancora niente.
- Quando resterà con te, qui vedrai cosa porta addosso.
- Non hai niente da mettere qui.

## La revisione

Dopo averle costruite le ho riguardate pezzo per pezzo: funzioni, animazioni,
tastiera e mouse, tempi, organizzazione del codice. Quello che non andava, e che
adesso ha una prova che si rompe se torna:

1. **Il negozio faceva pagare per niente.**
   - Un'arma (o un accessorio, uno stigma, una chiave) che avevi già si pagava,
     e non arrivava niente.
   - La sacca allargata con lo spazio nella realtà per il negozio restava piena
     a 20: leggeva il tetto scritto nelle regole, non quello vero.
   - Tutti e due c'erano già prima del rifacimento.
2. **Il conto dei materiali era sbagliato**: la vetrina diceva "1/3" e i tre
   riquadri dicevano tutti NO.
3. **Il Petardo si descriveva "elemento +0"**, e il Frammento di vita con le
   chiavi grezze dei dati. Zaino e negozio descrivevano gli oggetti in due modi
   diversi: adesso le parole sono quelle del negozio dappertutto.
4. **Con quattro compagni il quarto non si raggiungeva**, né col mouse né con la
   tastiera.
5. **Passando a un compagno di passaggio la tastiera perdeva il fuoco**: il
   carosello spariva e con lui il posto dove stava il fuoco.
6. **Nella scelta dell'oggetto**:
   - freccia su dal primo candidato cambiava compagno e chiudeva tutto;
   - l'anteprima delle statistiche restava quella dell'ultimo oggetto sfiorato.
7. **Cambiando un accessorio** il nuovo finiva in fondo alla fila, e il carosello
   restava su uno slot vuoto.
8. **Nel negozio**:
   - le linguette si rifacevano a ogni acquisto (la gelatina a metà, il fuoco
     perso);
   - da COMPRA, dalle linguette e dalle frecce di pagina il fuoco finiva sulla
     carta più vicina, che veniva scelta al posto di quella giusta.
9. **Due entrate di fila lasciavano le carte storte** per sempre. Due giri del
   carosello o due scivolate dello scaffale si contendevano la stessa posizione.
10. **Col movimento ridotto** la carta della squadra si sporgeva e il disegno
    della vetrina scivolava.
11. **Scritte che uscivano dal loro posto**:
    - la riga sotto le carte finiva sotto quella accanto;
    - i nomi dei materiali si sovrapponevano;
    - "PROTAGONIST" era tagliato;
    - la descrizione lunga si fermava a metà riga.
12. **I disegni non quadrati venivano schiacciati** nelle carte e nelle caselle.
13. **Le carte della squadra chiedevano al disco** se esiste il ritratto a ogni
    fotogramma di animazione. Adesso lo chiedono una volta sola.

Ogni prova è stata validata rompendo apposta il codice che protegge: 28 rotture,
tutte prese.

Poi le ha usate l'automa, partendo dal negozio con Tazo, materiali e una squadra
di quattro (`./prove/automa.sh scimmia 3 300 negozio`). Ha fatto un giro
d'esplorazione, 845 azioni, e due giri di clic e tasti a caso, più di mille
azioni ciascuno, passando da ESC alla scheda. Nessun errore, nessun blocco,
nessun bottone irraggiungibile. L'unica cosa rimasta: chiudendo il gioco mentre
un suono sta ancora suonando, Godot segnala quel suono come non liberato. È
l'audio, non queste schermate, e succede solo in uscita.
