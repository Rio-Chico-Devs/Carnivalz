# I simboli: cosa ho imparato dai maestri, e come lo uso

> **Com'è finita.** La strada dei mon (§2, §6) Bru l'ha scartata: «no dai non ci
> siamo». Poi, sulla tavola delle tre strade: «queste icone mi piacevano, bisognava
> solo migliorarle e renderle più precise e pulite», e le sagome della strada A sono
> state ricostruite su un canone misurabile (`prove/SagomeA.gd`, misure in
> [`docs/sagome_a.md`](sagome_a.md), file in `art/interfaccia/statistiche/strada_a/`).
> Su quelle: «si potrebbe passare un esame di misure ma non di design, non ricordano
> abbastanza quel che devono ricordare e non hanno quel qualcosa di design che per
> esempio combina due icone per crearne una». Le statistiche adesso sono
> `scripts/crescita/IconeStatistiche.gd`: ognuna due figure del mondo di Carnivalz che ne fanno
> una terza, con curve vere e il peso bilanciato. Dopo la seconda revisione di Bru
> (§8) sono il cuore-palloncino, la spada mascherata, lo scudo-fortezza, i due
> galloni, l'occhio con la serratura, il brillante, la bomba, la corona con la barra
> e il fuoco fatuo di Jalhalla. Idee, pesi e ingombri in
> [`docs/icone_statistiche.md`](icone_statistiche.md); i file in
> `art/interfaccia/statistiche/proposta/`. Le sagome A restano, coi loro file e la
> loro prova, ma le proposte non le usano più. Le letture qui sotto restano valide.

Bru, sulle icone delle statistiche: «siamo sulla strada giusta, tieni questa
ma migliorale, non hanno ancora quel qualcosa che le renda uniche [...]
educhiamoci dai maestri, cerca risorse per migliorare le tue capacità di
design, se non riesci ad accedere a qualcosa mandami il link».

Dalla sessione cloud i siti non si aprono, così Bru li ha visitati e mi ha
mandato i PDF: «ti passo quelli interessanti, quello che ritengo più utile è
quello sui disegni e icone giapponesi e l'arte giapponese». Poi: «dobbiamo
studiare di più, ci vogliono più riferimenti grafici e proprio cose che ti
facciano capire concetti di pulizia del logo, astrazione, simbologia e
design», e un secondo giro di PDF (correzioni ottiche, sporgenza, Sagi Haviv,
Logobook, i simboli AIGA/DOT).

Questa pagina dice:
- cosa c'è scritto davvero in quei testi (§1, le due letture);
- come è entrato nelle icone (§2) e la pulizia che ne è venuta, con le misure
  (§2.1);
- cosa avevo ricavato prima dai soli riassunti dei motori di ricerca (§3);
- le fonti (§4) e cosa resta da leggere (§5);
- Vita, Attacco e Difesa rifatte a fondo: le lezioni su simbolismo, due figure
  in una, composizione e geometria, le strade provate e le tre proposte (§6);
- la revisione delle icone sotto la lente: misure ottiche, fili, piccole (§7);
- le icone rifatte da capo dopo la seconda critica di Bru: la regola nuova, le
  strade tenute e scartate, l'Aura misurata sul segno di Jalhalla e senza
  bozzi (§8).

Il codice è in `scripts/crescita/SimboliCrescita.gd` (`mon`, `sagoma`, `statistica`,
`ottica`); le tavole di studio in `prove/StudioSegni.gd`. Le immagini sono
nelle foto delle proposte:
- «statistiche», «simboli», i giri della roulette, «bivio»;
- le tre tavole di studio: «studio_occhio», «studio_pieno»,
  «studio_astrazione»;
- le lezioni e le tre icone: «lezioni», «vita», «attacco», «difesa»
  (`prove/TreIcone.gd`).

## 1. Le letture vere

### I kamon

Fonte: Gianfranco Chicco, *Kamon, the Original Logos of Japan* (29 novembre
2024). È la lettura che Bru ritiene più utile.

**Da dove vengono.** I *mon* (紋), o *kamon* (家紋, «stemma di famiglia»),
nascono nel periodo Heian, alla fine dell'XI secolo. Si ispiravano ai
fenomeni naturali ed erano «una stenografia visiva per l'identità».
- Gli aristocratici li mettevano sui carri a buoi, per dire proprietà e rango.
- Dal periodo Kamakura i samurai li portavano in battaglia, per distinguere
  gli amici dai nemici.
- Dopo il 1603 passano alla gente comune: i mercanti li mettono sulle
  botteghe, gli attori kabuki sui costumi. I motivi si allargano dalle piante
  e dagli animali agli attrezzi, ai motivi astratti e ai giochi di parole.

**Quanti sono e come si cercano.** Shoryu Hatoba stima più di 50.000 motivi
storici, raccolti in cataloghi spessi. Nelle foto, le pagine dei cataloghi
sono griglie di stemmi chiari in quadrati o cerchi neri.

**Gli attrezzi.** Le regole sono severe: «solo rette e cerchi». Gli attrezzi
dei *monsho uwaeshi*, gli artigiani degli stemmi:
- il compasso di bambù con la punta a pennello (*bun-mawashi*);
- la bacchetta di vetro per le rette;
- il bastoncino d'inchiostro, la pietra da inchiostro, il contagocce;
- nella foto, anche il righello e il pennello.

**Spessore e spazio.** Yoho Hatoba: «i kamon hanno linee molto delicate, di
spessore costante. Per noi questo, e lo spazio fra le linee, sono la cosa più
importante».

**Uno stemma che racconta.** Il kamon di Chicco unisce tre cose della sua
storia:
- le piume di falco del *Takanoha*, uno dei cinque grandi motivi storici,
  assottigliate. Rifanno le ali dell'aquila asburgica dello stemma di
  famiglia;
- 17 linee, il suo numero;
- al centro un fiore di gelsomino, il profumo di casa. È un motivo nuovo
  nel canone.

Ne viene una girandola dentro un anello di 17 tacche.

**Il «Mon Mandala».** Dopo essere passati a Illustrator, i Hatoba hanno
mostrato le centinaia di cerchi di costruzione che di solito si cancellano.

**Principi e uso.**
- I Hatoba li riassumono in simmetria, semplicità ed equilibrio.
- Un kamon si usa come timbro: Chicco ci timbra lettere e cartoline, in
  rosso.
- Logo e kamon non sono la stessa cosa: il logo è di un'azienda, il kamon
  di una famiglia e della sua tradizione. Si sovrappongono nel dire
  un'identità.

**Due versioni dello stesso stemma.** Prima dei kamon, Chicco racconta lo
stemma occidentale della famiglia. A dodici anni il padre gli regala un anello
con la versione *semplificata*, che porta tutti i giorni. Quella *elaborata*
la usa nelle occasioni.

### Mark Holt sulla griglia di Aicher

Fonte: Quentin Newark, *This sporting myth*, Eye, 5 agosto 2025.

**Il difetto.** Fra il 1967 e il 1972 Aicher e Gerhard Joksch disegnarono i
pittogrammi di Monaco '72 su una griglia semplice. Holt ha trovato il punto
debole (il «tallone d'Aicher»): «un braccio o una gamba fatti di due pezzi,
uno ortogonale e uno a 45°, non possono avere lo stesso spessore» su quella
griglia.

**La correzione.** Holt ha ridisegnato una griglia a 45° molto più fine. Ora:
- gli arti a 45° hanno lo stesso spessore di quelli dritti;
- gli spazi sono tutti uguali;
- le teste cadono sempre negli stessi posti.

**Come andò davvero.** Joksch schizzava a mano libera su carta da lucido,
altri ripassavano in bella. Nessuno controllava ogni pittogramma sulla
griglia: contavano l'aspetto e il significato.

Nelle foto i pittogrammi sono chiari dentro quadrati pieni.

### Otl Aicher

Fonte: Wikipedia.
- Per Monaco '72 consultò Masaru Katsumie, che aveva disegnato Tokyo '64, e
  partì in parte dalla sua iconografia.
- Usò sistemi di griglie e una tavolozza scelta per i Giochi.
- Lo scopo di ogni pittogramma era essere un segno chiaro dell'attività e
  restare comprensibile a tutti.
- Da lì vengono i pittogrammi del DOT americano (1974), poi usati in tutto il
  mondo.
- I colori distinguevano i settori: stampa, servizi tecnici, ospiti,
  pubblico.

### Susan Kare

Fonte: AIGA, medaglia 2018.
- Icone «audaci e intelligenti», con «arguzia e umanità memorabili».
- Veniva dalla scultura. Per lo schermo partì da mosaico, ricamo e
  puntinismo, su carta millimetrata di 32 per 32.
- Ogni icona partiva da una funzione («avvio», «debug») e diventava una
  metafora. Le fonti andavano dalle leggende dei pirati ai geroglifici.
- Il ⌘ viene dalla croce di San Giovanni, trovata in un vecchio libro di
  simboli.
- Per il carattere Chicago usò solo linee orizzontali, verticali o a 45°.
- I suoi principi: semplicità, chiarezza, bellezza. Conta molto il contesto
  e la metafora.
- Lavora dentro una griglia che mostra i limiti dello schermo dove l'icona
  verrà vista.
- Ogni icona dev'essere facile da capire *e* da ricordare.

### Le icone di gioco

Fonte: *Game Icon Design: Store and In-Game*, madegooddesigns, 7 giugno 2026.

**Si disegna la famiglia, non l'icona.** Le icone di una famiglia vanno
disegnate insieme:
- stesso stile: tratto, dettaglio, luce, prospettiva;
- stessa griglia e stessi margini;
- una cornice che dica la categoria. Il colore va sostenuto dalla forma, per
  chi non distingue i colori.

**La prova della sagoma.** Riempi l'icona tutta di nero. Se due sagome sono
uguali, sotto pressione si sbaglia a cliccare. Prima viene la forma; il
colore e i dettagli sono un aiuto in più.

**Gli errori più comuni.**
- Troppo dettaglio: se hai dubbi, togli finché resta un'idea sola.
- Distinguere le icone solo col colore.
- Mescolare stili diversi.

**Come si giudica.** Si disegna grande e si giudica alla misura più piccola,
sul fondo vero.

### Le correzioni ottiche (seconda lettura)

Fonte: Ian Paget (Logo Geek), *Optical corrections every logo designer should
know about*.

**La griglia è una guida.** «A volte la griglia va ignorata, e si corregge a
occhio, perché il disegno *sembri* fatto sulla griglia.»
- La G di Google: una versione «corretta» con la griglia perfetta sembra
  sbilanciata, quella imperfetta sembra perfetta.

**La sporgenza.** Un cerchio alto quanto un quadrato sembra più piccolo:
bisogna farlo sporgere un poco.

**La Gestalt.** L'occhio raggruppa le parti in un tutto: somiglianza,
continuità, chiusura, vicinanza, figura e fondo.
- Il panda del WWF si legge per chiusura, anche se è fatto di macchie
  staccate.
- «Bisogna disegnare non solo quello che c'è, ma anche quello che non c'è.»

**L'irraggiamento.** Lo stesso marchio chiaro su scuro sembra più grasso che
scuro su chiaro. La versione chiara va assottigliata, e quanto lo decide
l'occhio.

### La sporgenza

Fonte: Fábio Duarte Martins (Scannerlicker), *The Art of Eyeballing, parte
III: Overshooting*.

**Cos'è.** La sporgenza è la correzione ottica di una forma rispetto al suo
rettangolo di costruzione, per l'equilibrio percepito. La massa visiva non è
l'altezza e non è l'area.

**Quadrato, cerchio e triangolo.**
- Alti uguali, il cerchio e il triangolo sembrano più piccoli.
- Con l'area uguale, il triangolo diventa enorme.
- La soluzione:
  - il triangolo poggia sulla riga (la base piatta è stabile e non va
    corretta) e sporge con la punta;
  - il cerchio sporge un poco sopra e sotto;
  - ognuno è un po' rimpicciolito.

**Anche in orizzontale.** Lo spazio attorno a un cerchio o a un triangolo
sembra più largo di quello fra due quadrati: si stringe.

**Le controforme.** Quando una forma ha un vuoto dentro, il vuoto conta più
della forma: più è spesso il tratto, più va corretto.

**Il metodo.** Non c'è un numero giusto: si prova e si decide.

### Sagi Haviv (Chermayeff & Geismar & Haviv)

Fonte: *Logo Design Love*, intervista.
- «Scegliere un marchio non è questione di cosa piace o non piace: è
  questione di cosa funziona.»
- Un simbolo ci vuole solo se c'è una buona ragione.
- **La presentazione è tutto.** Il marchio di A/X (Armani Exchange), mostrato
  di corsa su un foglio bianco, fu rifiutato. Mostrato nelle applicazioni
  (pubblicità, vetrine, cartelloni), fu approvato subito.
- La difficoltà è ridurre una cosa all'essenza e camminare sul filo fra
  semplice e distintivo.
- Se un marchio è semplice e distintivo regge qualunque trattamento o filtro,
  e si anima da solo. Deve però funzionare fermo, non essere il fotogramma di
  un'animazione.
- Prima la matita, sempre.
- Nelle immagini dell'intervista:
  - Conservation International: un anello e una barra, una persona e un mondo
    con due sole forme;
  - Ron Brown: un triangolo di sei pezzi staccati da tagli uguali.

### Logobook

Fonte: *New website Logobook archives logos going back to the '50s*, Creative
Review.

**Com'è fatto.** È un archivio di marchi dagli anni '50, tutti in bianco e
nero e divisi per tema (lettere, forme, oggetti, natura, settori). «I marchi
migliori di sempre stanno bene in bianco e nero quanto a colori.»

**Cosa si vede nelle pagine.**
- Quasi sempre una massa grande, un cerchio, un quadrato o una goccia, con
  uno, due o tre tagli che portano l'idea. Esempi: Macel Pin (la goccia nel
  disco), Better Place, Gas und Wasserwerke (la fiamma vuota dentro la B),
  Frontier Airlines di Saul Bass.
- Il ritmo dei segni ripetuti: IBM di Paul Rand, Fiera Milano, il pino fatto
  di 木 ripetuti di Ken Miki.
- Il contenitore comune (cerchio, quadrato, scudo), e il motivo che a volte
  lo attraversa.

### I simboli AIGA/DOT, misurati

Fonte: SEGD, *AIGA/DOT Symbols for Transportation*, il PDF vettoriale dei 50
simboli (1974–79), di pubblico dominio. Li hanno disegnati Roger Cook e Don
Shanosky, col comitato di Thomas Geismar, Seymour Chwast, Rudolph de Harak,
John Lees e Massimo Vignelli.

Ho reso il PDF a 100 dpi e misurato ogni simbolo. Il modulo è l'altezza tipica
dei simboli più alti.

**Quanto inchiostro.** I simboli coprono in media il 32% del quadrato del
modulo, da 0,14 (le scale) a 0,55 (divieto d'accesso).

**Le frecce.** Hanno tutte lo stesso inchiostro, 0,30, dritte e oblique.
- Il gambo obliquo ha lo stesso spessore di quello dritto (0,183 contro 0,185
  del modulo): la regola di Holt rispettata.
- Le oblique sono costruite apposta per avere lo stesso peso.

**I tratti.** Nei simboli fatti di linee (busta, gruccia, scale mobili, taxi,
autobus) il tratto sta fra il 6 e il 10% del modulo.

## 2. Come sono entrate: i mon di Carnivalz

Le statistiche sono diventate *mon*: stemmi dritti dentro un anello, costruiti
con una legge sola.

| la lezione | la regola nelle icone |
|---|---|
| Compasso e righello (i kamon) | Il compasso fa solo l'anello, la cornice comune. Tutto il resto è righello, a 0, 45 e 90 gradi. Ho provato anche un ricciolo e degli archi per la Maestria: dentro un anello un cerchio diventa subito un segno che esiste già (©, la freccia del «ricarica», lo spinner, lo yin e yang). È la stessa ragione per cui i nostri simboli non avevano curve. |
| Spessore costante e spazio costante (Yoho Hatoba; Holt) | Uno spessore solo, `W` = 1,8 su 24, per l'anello e per ogni linea. Uno spazio solo, `TAGLIO` = 1,2, fra due parti e fra il motivo e l'anello. I contorni si fanno rientrando la sagoma (`Geometry2D.offset_polygon`), così lo spessore è uguale in ogni direzione, 45° compresi. È il problema di Holt, risolto dalla costruzione. |
| La cornice dice la categoria (i cataloghi; le icone di gioco) | Le statistiche stanno nell'anello, le passive nel rombo, le abilità senza cornice. |
| Le teste negli stessi posti (Holt); un segno che attraversa tutto (Wyman) | Il cuore, il rombo arancio dell'emblema, sta sempre al centro e ha sempre la stessa misura. È incastonato con un taglio scuro: il crema e l'arancio fanno poco contrasto, il taglio li stacca. In ogni mon l'arancio è una cosa sola; nella Maestria del dominio è il terzo segmento della barra. |
| Simmetria, semplicità, equilibrio | I mon stanno dritti e simmetrici, non pendono più come le scritte. A pendere è il timbro quando si preme: il foglietto della foto «statistiche», le tasche che girano con la ruota. |
| Il kamon è un timbro | Deve bastare una tinta: senza arancio il cuore resta pieno nel suo taglio, e il mon si legge lo stesso. Prova «una tinta». Prima il cuore diventava un buco: vedi §2.1. |
| La prova della sagoma (le icone di gioco) | Senza anello e riempiti, i nove motivi sono tutti diversi. Prova «la sagoma». Forza mentale e Fattore prima avevano la stessa sagoma; ora uno è il rombo intero e l'altro lo stesso rombo spezzato. |
| L'anello di tutti i giorni (Chicco); grande e poi piccolo | Sotto i 20 pixel l'anello si toglie e il motivo prende il suo posto: dentro un anello così piccolo non si legge niente. Prova «piccole». |
| Il Mon Mandala | La costruzione resta a vista nella foto: la griglia, i cerchi del compasso, le rette a 45°. |
| L'occhio corregge la griglia (Holt su Aicher) | A 45° la punta del cuore finiva sul tratteggio, e il cuore sembrava tozzo: l'occhio l'ha allungata. Si vede nella costruzione. |
| Tre cose della storia (il kamon di Chicco) | L'anello è la ruota dove le statistiche si vincono. Il cuore è l'emblema di Carnivalz. Il motivo è la metafora. |
| Un'idea, facile da capire e da ricordare (Kare) | Una metafora a testa, e niente dettagli minuti. |

I nove mon:

| statistica | il motivo |
|---|---|
| Punti vita | il cuore: due lobi a rombo e la punta allungata |
| Attacco | la lama di sbieco a 45°; il cuore incastonato alla base, la guardia staccata da un taglio |
| Difesa | lo scudo, col cuore per borchia |
| Velocità | il fulmine; il cuore dove i due colpi si toccano |
| Intelligenza | l'occhio a lente con gli spigoli a 45°; la pupilla è il cuore |
| Forza mentale | allineati: l'anello, il rombo e il cuore hanno lo stesso centro |
| Fattore | disallineati: lo stesso rombo spezzato, con le due metà scivolate. Nei dati il Fattore è «quanto il disallineamento arde in te» |
| Maestria del dominio | la barra del dominio a tre segmenti, pendenti come nel manifesto, col terzo acceso |
| Aura | l'emblema: il rombo grande col cuore, i due piccoli sopra e sotto, i fantasmi ai lati dietro, staccati da un taglio |

**Dove si vedono.**
- Nella roulette le tasche prese portano il mon intero, come un gettone vinto.
- Nel bivio, dietro le due scelte, c'è il mon gigante e sbiadito, come lo
  stemma stampato su una tenda.
- Nella scheda c'è a 22 pixel, con l'anello.

Abilità e passive sono ancora i timbri pendenti di prima. Se i mon vanno bene
a Bru, la stessa legge (compasso e righello, uno spessore e un taglio, dritti)
passa anche a loro.

### 2.1 La pulizia: cosa è cambiato dopo la seconda lettura

**Il banco.** Ho fatto un banco (`Godot`, poi misure in Python, solo per lo
studio): disegna i nove motivi senza anello neri su bianco, e misura
l'inchiostro sul quadrato del motivo, come per i simboli AIGA/DOT.

**Prima della pulizia** l'inchiostro andava da 0,17 a 0,39: più del doppio fra
il più leggero e il più pesante.

| | Vita | Attacco | Difesa | Velocità | Intelligenza | Forza m. | Fattore | Maestria | Aura |
|---|---|---|---|---|---|---|---|---|---|
| prima | 0,38 | 0,17 | 0,39 | 0,26 | 0,21 | 0,19 | 0,17 | 0,29 | 0,24 |
| dopo | 0,30 | 0,27 | 0,31 | 0,28 | 0,28 | 0,29 | 0,27 | 0,29 | 0,27 |

Con l'anello, dopo, i mon stanno tutti fra 0,41 e 0,43.

Cosa è cambiato, e da quale lettura:

1. **Il cuore non è più un buco** (la prova a una tinta, Logobook). Nero su
   bianco il banco ha mostrato due difetti:
   - dove il cuore sta nel vuoto (l'occhio, la Forza mentale) spariva, e
     l'occhio non aveva la pupilla;
   - sulla lama faceva un buco che la spezzava.

   Ora il cuore resta un rombo pieno staccato dal suo taglio: arancio se c'è
   l'arancio, se no del colore del segno.
2. **Lo stesso peso per tutti** (Scannerlicker, le frecce AIGA/DOT):
   - la Vita e la Difesa rimpicciolite a 0,93;
   - la lama dell'Attacco più larga, con la guardia più spessa;
   - il fulmine più grasso;
   - l'occhio, il rombo della Forza mentale e quello del Fattore più grandi;
   - l'emblema dell'Aura più grande.
3. **La sporgenza** (Scannerlicker, Logo Geek). Le parti piatte del motivo
   stanno dentro il raggio 9; le punte arrivano a 9,4, perché una punta sembra
   più corta di quanto è.
4. **L'irraggiamento** (Logo Geek):
   - lo spessore base è passato da 1,8 a 2,0;
   - quando il mon è chiaro su fondo scuro, le linee scendono a 0,88 e i tagli
     salgono a 1,18 (`ottica`).

   La tavola «studio_occhio» mette lo stesso mon com'era e corretto, uno
   accanto all'altro.
5. **Pieno e vuoto** (Logobook, Haviv). La tavola «studio_pieno» mette i nove
   mon in tre trattamenti, grandi e piccoli:
   - **il tratto:** com'è ora;
   - **il pieno:** il disco chiaro col motivo tagliato in negativo, la strada
     dei marchi, che pesa di più e regge meglio le misure piccole;
   - **il nudo:** il motivo da solo.

   È una scelta di Bru, non l'ho cambiata da solo.
6. **Dal disegno al segno** (McCloud, Kare, Haviv). La tavola
   «studio_astrazione» porta la Vita e l'Attacco dal disegno illustrato al
   mon, in cinque passi, e ogni passo toglie una cosa sola:
   1. il disegno: contorno, luci, ombre, dettagli;
   2. la sagoma;
   3. il righello;
   4. il segno col cuore dell'emblema;
   5. il mon nell'anello.
7. **La presentazione** (Haviv). I mon si giudicano anche nella roulette,
   nella scheda e nel bivio, non solo nel catalogo: per questo le foto le
   mostrano tutte.

## 3. Le lezioni dai riassunti, prima dei PDF

Queste vengono dai riassunti dei motori di ricerca, non dai testi interi.

- **Paul Rand** e **Chermayeff & Geismar & Haviv**:
  - un segno appropriato, distintivo, memorabile, semplice a ogni misura;
  - la semplicità viene da sola quando l'idea è buona;
  - la prova dello scarabocchio: chi l'ha visto una volta lo ridisegna a
    memoria.
- **Masaru Katsumi e Yoshiro Yamashita** (Tokyo 1964):
  - i primi pittogrammi olimpici, poche forme geometriche;
  - Katsumi disse di essere partito dai kamon.
- **Lance Wyman** (Messico 1968):
  - per ogni cosa un gesto riconoscibile;
  - una cornice comune;
  - un segno solo (le strisce concentriche) che attraversa tutto.
- **Isotype** (Neurath, Gerd Arntz):
  - il contrasto netto della xilografia;
  - un segno base qualificato da un secondo segno;
  - la quantità si dice ripetendo il segno, non ingrandendolo.
- **Bruno Munari**, *Design e comunicazione visiva* (1968): un segno si
  giudica giusto o sbagliato rispetto a un principio, non bello o brutto.
- **I sistemi di icone di oggi**:
  - forme chiave per dare a tutte lo stesso peso visivo;
  - un tratto solo e uno spazio minimo fra i tratti;
  - le icone più dense sembrano più pesanti.

## 4. Le fonti

I PDF mandati da Bru, seconda lettura (letti per intero):
- Ian Paget, [*Optical corrections every logo designer should know about*](https://logogeek.uk/logo-design/optical-corrections/) (Logo Geek)
- Fábio Duarte Martins, [*The Art of Eyeballing, parte III: Overshooting*](https://scannerlicker.net/writings/2014/09/03/the-art-of-eyeballing-part-3-overshooting/) (Scannerlicker)
- [*An interview with Sagi Haviv*](https://www.logodesignlove.com/sagi-haviv-interview) (Logo Design Love)
- [*New website Logobook archives logos going back to the '50s*](https://www.creativereview.co.uk/logobook-archives-logos-going-back-50s/) (Creative Review)
- [*AIGA/DOT Symbols for Transportation*](https://segd.org/resources/aiga-dot-symbols-for-transportation/) (SEGD, PDF vettoriale)

I PDF mandati da Bru, prima lettura (letti per intero):
- Gianfranco Chicco, [*Kamon, the Original Logos of Japan*](https://www.gchicco.com/kamon-the-original-logos-of-japan/)
- Quentin Newark, [*This sporting myth*](https://www.eyemagazine.com/blog/post/this-sporting-myth) (Eye, su Mark Holt)
- [Otl Aicher, Wikipedia](https://en.wikipedia.org/wiki/Otl_Aicher)
- [2018 AIGA Medalist: Susan Kare](https://www.aiga.org/membership-community/aiga-awards/2018-aiga-medalist-susan-kare)
- [*Game Icon Design: Store and In-Game*](https://madegooddesigns.com/game-icon-design/)

Dai motori di ricerca (solo i riassunti):
- Otl Aicher: [Smithsonian](https://www.smithsonianmag.com/innovation/this-graphic-artists-olympic-pictograms-changed-urban-design-forever-180978256/),
  [Cooper Hewitt](https://cooperhewitt.org/?p=27675)
- Susan Kare: [intervista (MacTech)](https://www.mactech.com/2003/06/12/original-mac-icon-designer-interviewed),
  [Creative Bloq](https://creativebloq.com/apple/mac-os-icons-susan-kare-5132740)
- Paul Rand e la prova del marchio: [The Next Web](https://thenextweb.com/news/how-good-is-your-logo)
- Chermayeff & Geismar & Haviv: [intervista a Sagi Haviv](https://www.logodesignlove.com/sagi-haviv-interview),
  [Print](https://www.printmag.com/branding-identity-design/marks-men-an-interview-with-ivan-chermayeff-tom-geismar-and-sagi-haviv-of-chermayeff-geisma/),
  [99% Invisible con Tom Geismar](https://99percentinvisible.org/episode/making-mark-visual-identity-tom-geismar/)
- Tokyo 1964: [Japan House LA](https://japanhousela.com/articles/graphic-designing-the-olympic-games),
  [typeroom](https://typeroom.eu/tokyo-1964-the-emblem-the-posters-the-pictograms-and-the-film-that-changed-olympics-forever)
- I kamon: [Mon (emblem), Wikipedia](https://en.wikipedia.org/wiki/Mon_(emblem)),
  [The Art of Kamon (Tokyo)](https://www.tokyoupdates.metro.tokyo.lg.jp/en/post-293/),
  [kamon sui kimono](https://kyotokimono.com/blogs/kimono-mania/japaniese-kamon-family-crests)
- Lance Wyman: [Herman Miller, «Talking Pictures»](https://www.hermanmiller.com/why/talking-pictures.html),
  [SEGD](https://segd.org/resources/1968-mexico-city-olympics-0/),
  [99% Invisible, Mexico 68](https://99percentinvisible.org/episode/mexico-68/transcript/)
- Isotype: [Wikipedia](https://en.wikipedia.org/wiki/Isotype_(picture_language)),
  [Stanford, Neurath](https://plato.stanford.edu/entries/neurath/visual-education.html),
  [Gerd Arntz](https://gerdarntz.org/content/gerd-arntz.html)
- Munari: [Wikipedia](https://en.wikipedia.org/wiki/Bruno_Munari),
  [articolo su *Disegno*](https://disegno.unioneitalianadisegno.it/index.php/disegno/article/download/817/1141/8143)
- Il simbolo AIGA/DOT (1974): [AIGA Symbol Signs](https://aiga.org/resources/symbol-signs),
  [Atlas Obscura](https://www.atlasobscura.com/articles/how-the-universal-symbols-for-escalators-restrooms-and-transport-were-designed)
- Le icone nei design system: [GitLab](https://design.gitlab.com/product-foundations/iconography),
  [Sky](https://sky-ui.cf.sky.com/skycons/design-guidelines),
  [Volue Wave](https://wave.volue.com/tokens/icon-design-guidelines)

## 5. Cosa resta da leggere

Per le lezioni del §6 (composizione, due figure in una, simbolismo,
geometria) da qui ho letto solo i riassunti. Per leggerle davvero:
- Eli Kince, *Visual Puns in Design*: la scheda è su
  [People's Graphic Design Archive](https://peoplesgdarchive.org/item/3989/visual-puns-in-design-the-pun-used-as-a-communication-tool);
- Shigeo Fukuda, *Victory 1945*: [People's Graphic Design Archive](https://peoplesgdarchive.org/item/19639/victory-1945-2)
  e il profilo su [It's Nice That](https://www.itsnicethat.com/articles/shigeo-fukuda);
- Noma Bar, le immagini con doppia lettura:
  [designboom](https://www.designboom.com/design/noma-bar-illustrated-illusions/);
- il mitate: [Mitate-e, Wikipedia](https://en.wikipedia.org/wiki/Mitate-e);
- Gui Bonsiepe e la retorica visiva: l'articolo su
  [Visible Language](https://journals.uc.edu/index.php/vl/article/download/5794/4658/7471) (PDF);
- figura e sfondo: [Interaction Design Foundation, le leggi della Gestalt](https://ixdf.org/literature/article/the-laws-of-figure-ground-praegnanz-closure-and-common-fate-gestalt-principles-3);
- il centro ottico: [Duke, «Graphic design: the optical center»](https://sites.math.duke.edu/education/ccp/resources/write/design/graphic7.html);
- icona, indice, simbolo: [il glossario dell'Università di Chicago](https://csmt.uchicago.edu/glossary2004/symbolindexicon.htm).

Della lista mandata a Bru sono arrivati Logo Geek, Scannerlicker (parte III),
Haviv, Logobook e AIGA/DOT. Restano, in ordine di utilità:
- Adrian Frutiger, *Segni e simboli*: i capitoli sugli elementi del segno;
- il catalogo di kamon (*Japanese Design Motifs*, Matsuya 1913, di pubblico
  dominio) e le varianti dello stesso motivo (Seido);
- la presentazione di Paul Rand per NeXT;
- le pagine di Kuwayama, *Trademarks & Symbols* (1973);
- Scannerlicker, parti I e II;
- McCloud, il capitolo 2 di *Understanding Comics*.

Se Bru li trova, in PDF o in immagini:

1. **Un catalogo di kamon vero**, anche poche pagine: le varianti dello stesso
   motivo (con e senza anello, uno, due, tre) e le costruzioni a compasso.
   Dopo il testo di Chicco è la cosa più utile.
2. **Il libretto di Mark Holt**, *The myth of Otl Aicher's pictogram grid*,
   con la sua griglia fine.
3. **Le tavole dei pittogrammi**: Monaco '72, Tokyo '64, Messico '68.
4. **The Vignelli Canon** (Massimo Vignelli, 2010), il PDF gratuito.
5. **Il libro dei 50 simboli AIGA/DOT**, per le correzioni ottiche.
6. **Persona 5**: l'intervista sulla UI e delle schermate delle statistiche
   (anche dal Game UI Database).
7. **Munari, *Design e comunicazione visiva***: i capitoli sui segni.

## 6. Vita, Attacco, Difesa, a fondo

Bru: «molto bene, ma bisogna andare oltre, lavoriamo a fondo su icona attacco
difesa e vita, tutto l'impegno su queste per ora, ti serve anche qualche
lezione su composizione, uso di due figure per crearne un altra, simbolismo e
cura delle geometrie».

### 6.1 Le lezioni

Queste vengono da ricerche (riassunti, non testi interi: i link per leggerle
davvero sono in §5). La tavola «lezioni» le mette in figura.

**Icona, indice, simbolo** (Charles S. Peirce). Un segno può stare per una
cosa in tre modi:
- **icona:** le somiglia (un ritratto, una mappa);
- **indice:** ne è la traccia o l'effetto (il fumo per il fuoco, l'impronta);
- **simbolo:** vale per un'intesa che si impara (le lettere, il cuore per la
  vita).

Quasi ogni segno mescola i tre. Gui Bonsiepe, a Ulm negli anni '60, ha
portato le figure della retorica nelle immagini: la metafora, la metonimia (la
parte per il tutto, l'effetto per la causa), l'iperbole.

Per una statistica servono l'icona o il simbolo più noto. L'indice racconta un
momento (il battito, il fendente), non una qualità.

**Due figure per farne una terza.**
- **Il mitate** (見立て), alla base dell'estetica giapponese: vedere una cosa
  come un'altra. A teatro un ventaglio fa le nuvole, una coppa di sakè la
  luna.
- **Shigeo Fukuda**, *Victory 1945* (1975): il proiettile che rientra nella
  bocca del cannone. Una forma sola, due letture.
- **Noma Bar**: «massima comunicazione con elementi minimi».
- **Lo spazio negativo**: la freccia di FedEx fra la E e la X. Il vaso di
  Rubin, che è anche due profili. Funziona quando la figura nascosta
  rinforza il messaggio. Paul Rand trovava la freccia di FedEx troppo
  nascosta.
- Eli Kince, *Visual Puns in Design*, divide i giochi visivi in tre tipi:
  letterali, suggestivi (due simboli ne fanno uno), comparativi.

**La composizione.**
- **Il centro ottico** sta un poco sopra quello geometrico (circa un ottavo
  dell'altezza): l'occhio pesa di più l'alto. Una cosa al centro esatto
  sembra un po' bassa.
- **Le direzioni:** l'orizzontale e la base piatta sono stabilità; la
  diagonale è movimento; la simmetria è calma.

**La cura della geometria.**
- Poche misure che tornano.
- Le curve e le rette si toccano senza scalini.
- Le griglie pubblicate dopo (quella della mela di Apple) spesso sono
  inventate a posteriori: la geometria serve a costruire, non a giustificare.

### 6.2 Le strade

Per ognuna delle tre statistiche ho provato otto strade e le ho giudicate col
banco: grandi, a 44 pixel, riempite (la sagoma). Le tavole «vita», «attacco» e
«difesa» le mostrano tutte, tenute e scartate, col perché. Le strade sono in
`prove/TreIcone.gd`.

| | tenute | scartate, e perché |
|---|---|---|
| Vita | il cuore nel cuore; due rombi e un cuneo; a tacche | il contorno (da piccolo un groviglio), la goccia (l'HP di troppi giochi, sembra una gemma), il battito (l'icona della salute di ogni app), tre rombi (troppo vicina al marchio di un'automobile), in due (dice la fine) |
| Attacco | la spada che esce; la spada nell'anello; a stampo | la lama a rombo (un pennino, una lancia), il colpo al cuore (la lama copre il cuore), il fendente (anello e barra di traverso = divieto), la punta (un cursore), le spade incrociate (l'icona della battaglia di ogni gioco) |
| Difesa | un quadrato e mezzo rombo; a lamelle; com'era | due piastre (sembra «scarica»), il guscio kikkō (un dado da bullone), il bordo (il distintivo dell'antivirus), il riparo (la casa), l'abbraccio (il simbolo del codice, `< >`) |

### 6.3 Le tre proposte (ora nei mon)

- **Vita: il cuore nel cuore.** Due figure ne fanno una terza: due rombi di
  raggio 4, coi centri a 3,6 dall'asse, e un cuneo dai loro vertici esterni.
  - La punta è un triangolo equilatero, a 60°: a 45° il cuore sembrava tozzo
    (si vede nella costruzione del foglio delle statistiche).
  - Dentro, il cuore dell'emblema ha la forma di un cuore: è l'unico mon dove
    il rombo arancio cambia forma. È un gioco di parole, come quelli dei
    kamon.
  - Da piccolo resta un punto arancio, come negli altri.
- **Attacco: la spada che esce.** La diagonale è il movimento.
  - La lama è un rettangolo con l'angolo del rombo per punta (90°).
  - La guardia cade a 0,618 della spada.
  - La punta buca l'anello: è l'unico mon che rompe la cornice, e l'attacco è
    proprio questo, uscire. Un taglio attorno alla lama interrompe l'anello.
- **Difesa: un quadrato e mezzo rombo.**
  - Il quadrato è la stabilità; sotto c'è la metà bassa del rombo
    dell'emblema, larga quanto il quadrato.
  - Lo scudo è alto una volta e mezza la larghezza, e la punta è a 45°,
    parallela ai lati del cuore.
  - Il cuore sta nel baricentro della figura, al centro del mon.

Pesi misurati col banco, senza anello: Vita 0,28, Attacco 0,33, Difesa 0,31.
Con l'anello: 0,41, 0,41, 0,43. Sono nella fascia degli altri sei.

Ognuna ha due alternative tenute, nelle tavole. La scelta è di Bru.

## 7. La revisione delle icone nuove, sotto la lente

Bru: «continua a studiare [...] rivaluta il tuo lavoro, pensaci su,
confrontalo con risorse esterne». Le icone sono quelle di
`scripts/crescita/IconeStatistiche.gd` (due figure in una). Qui c'è cosa ho letto, cosa
ho misurato e cosa è cambiato. Gli strumenti e le regole di misura restano; le
figure di Vita, Attacco, Velocità, Forza mentale, Fattore e Aura sono state
rifatte da capo dopo (§8).

### 7.1 Le letture

Dalla cloud i siti non si aprono: sono riassunti delle ricerche, con le fonti.

- **Le forme chiave di Material** (material.io, *System icons*). La griglia è
  di 24 con un'area viva di 20. Le forme chiave sono il quadrato di 18, il
  cerchio di 20, il rettangolo verticale 16 × 20 e quello orizzontale
  20 × 16. Riportate su 100: 75, 83, 67 × 83, 83 × 67. Dicono quanto spazio
  prende di solito una forma di quel genere.
- **Le correzioni ottiche** (Slava Shestopalov, *Optical effects in user
  interfaces*, ripreso da iconscout e icons8).
  - L'occhio pesa l'area, non il riquadro: un quadrato pesa più di un cerchio
    alto uguale.
  - La prova più semplice è sfocare: se le forme diventano macchie uguali,
    pesano uguale.
  - Le forme non quadrate possono sporgere dall'area, quelle quadrate
    rientrano.
- **Il centro ottico.** Un programma centra il riquadro, l'occhio centra la
  massa: il triangolo del «play» si sposta a destra (railsdesigner, Framer).
  Non c'è un numero fisso: si sposta a occhio.
- **Le piccole** (Font Awesome, Sky, Semrush, ServiceNow). I bordi che cadono
  fra due pixel si sfumano. Le distanze fra le forme vanno tenute sui 2 pixel
  a 16–24 (Sky, Semrush), con mezzo pixel di tolleranza.
- **La coerenza di un set** (IBM, Volvo, Vic Bell, Recraft).
  - Un valore solo per ogni cosa: lo spessore, il raggio degli angoli, i
    terminali, gli angoli delle oblique.
  - Lo stesso spazio occupato nell'area viva.
  - Un'icona nuova deve rispettare prima le regole, poi il concetto: un raggio
    sbagliato stona comunque.
- **I kamon** (Core77, Morse Museum): cerchio, simmetria, poche forme
  astratte, leggibili a un colore solo.
- **Il tomoe e lo hitodama** (Wikipedia, yokai.jp). Il tomoe è la «virgola»
  vorticosa dei mon, simbolo di Hachiman, il dio dei guerrieri. Lo hitodama
  è la fiamma dell'anima, con la coda: è il segno di Jalhalla capovolto, cioè
  la nostra Aura.
- **Persona 5** (Redbrick, Mechanics of Magic, Inverse). Forme angolose e
  colori forti dappertutto; ma una critica (Inverse) dice che a volte lo
  stile passa davanti alla leggibilità. Da noi la leggibilità viene prima.

Da qui vengono le lezioni già in §1 rilette con le misure: la sporgenza
(Martins), l'irraggiamento (Paget), le oblique di Holt, il giudizio alla
misura più piccola sul fondo vero (le icone di gioco).

### 7.2 Gli strumenti

- **La tavola «misure»** (`prove/TavolaMisure.gd`). Per ognuna delle nove:
  - le forme chiave di Material sotto il disegno;
  - il baricentro e il centro visivo;
  - la prova della sfocatura;
  - la sagoma;
  - i numeri;
  - la resa a 24 e 16 pixel sul fondo della scheda.
- **I numeri** (`IconeStatistiche`):
  - la pienezza (l'inchiostro);
  - il raggio d'inerzia (quanto la massa è sparsa attorno al suo centro: due
    icone con lo stesso inchiostro e raggi diversi non sembrano grandi
    uguali);
  - il centro visivo (a metà fra il centro dell'ingombro e il baricentro: una
    regola di mestiere per trovare chi è fuori posto);
  - le distanze fra tutti i contorni (`distacchi`).

- **La tavola «costruzione»** (`prove/TavolaCostruzione.gd`). Ogni icona,
  mentre si costruisce, lascia le sue guide: i cerchi, i centri, le tangenti,
  i punti di controllo delle curve, la linea di mezzo del ricciolo, e una nota
  che le spiega. La tavola le disegna in arancio sotto l'icona, sulla griglia
  di 10. È il «Mon Mandala» dei Hatoba: i cerchi di costruzione che di solito
  si cancellano. Serve a vedere che ogni curva viene da qualcosa, e a misurarla.

### 7.3 Cosa hanno trovato, e cosa è cambiato

| | prima | dopo |
|---|---|---|
| pienezza, dalla media | da -10% a +11% | da -6% a +5% |
| raggio d'inerzia, dalla media | da -11% (Velocità) a +15% (Attacco) | da -6% a +7% |
| centro visivo, il più lontano | Attacco a -6,6, -4,9; Velocità a -6,7 in alto; Aura a +6,3 in basso | Velocità a -3,5 in alto, Aura a +3,5 in basso: due forme a punta |
| fili (distanze fra 0 e un taglio) | 5 | 0 |

- **Attacco.** La falce in alto a sinistra tirava tutta la massa da quella
  parte. La spada si è rimpicciolita (0,9) e spostata verso il basso a destra.
  La falce si è scostata dall'asse, perché la guardia, che sporge di traverso
  proprio verso di lei, le arrivava a 0,4. La punta della lama è più acuta:
  a 90°, girata di 45°, sembrava un angolo squadrato.
- **Difesa.** Era la più grande (raggio +7%): ora è più stretta, con tre merli
  uguali di 14 e due feritoie di 9.
- **Velocità.** Era la più piccola (raggio -11%) e pesava in alto. Il fulmine
  è stato ridisegnato:
  - i fianchi lunghi tutti alla stessa pendenza;
  - il gradino di destra più alto di quello di sinistra;
  - parte da 8 e non da 4 (la punta in basso tira la massa in alto);
  - è più largo.
- **Fattore** più largo, **Aura** più in alto, **Forza mentale** con la
  cornice della lanterna spessa T come i bordi delle altre.
- **I fili.**
  - La cicatrice stava a 1,3 dal bordo del cuore.
  - La falce stava a 0,4 dalla guardia.
  - L'iride stava a 1 dalle palpebre: ora le tocca, e il bianco dell'occhio è
    fatto di due pezzi.
  - L'anello della lanterna era spesso 4: ora 5.
  - Le fessure della corona erano larghe 5 in orizzontale ma 4,5 di traverso
    (la regola di Holt): ora 5,4 in orizzontale, 5 di traverso.
- **Le piccole.** Coi tagli più larghi i dettagli si stringono o spariscono,
  come fa chi disegna una versione piccola:
  - la cicatrice si accorcia;
  - la scanalatura della spada sparisce sotto i 7 di taglio;
  - l'anello della lanterna diventa una palla;
  - la serratura e il rombo nel fuoco si stringono.
- **L'irraggiamento.** Chiare su scuro (la scheda, i timbri), i tagli sono un
  decimo più larghi.

La prova `prova_le_icone_si_reggono` controlla tutto questo:
- la pienezza entro l'8%;
- il raggio entro il 10% (è una misura più grossolana);
- il centro visivo entro 4;
- nessun filo, a misura piena, piccola e chiara su scuro;
- l'irraggiamento.

È validata con sedici sabotaggi, presi tutti.

### 7.4 Quello che i numeri non dicono

- Il raggio e il centro visivo sono regole di mestiere, non leggi. Per le
  forme a punta (il fulmine, l'Aura, la punta dello scudo) il centro visivo
  resta qualche unità fuori: la punta conta nell'ingombro più di quanto pesi.
- L'Attacco è il più sparso (raggio +7%): una spada di sbieco con la sua
  falce occupa la diagonale. Più piccola diventava tozza; ho scelto la forma.
- **Le rifiniture viste in grande** (a 640 pixel, sulla griglia):
  - L'Aura aveva un gomito dove la coda entra nel ricciolo: lo spessore
    cresceva e calava con uno spigolo, e lo spigolo passava nel contorno. Ora
    sale e scende con curve lisce, e la punta della coda si affina come una
    pennellata.
  - Lo scudo aveva in cima, sotto le feritoie, un muro di 14 contro i 10 dei
    fianchi: ora è 10.
  - L'anello della lanterna è disegnato con più lati, così misura 5 esatti.
- **Il peso nella scheda.** Le icone ci stanno in 26 pixel, chiare su scuro, coi
  tagli più larghi. Misurate così, lo scudo pesava il 13% meno degli altri a 16
  pixel: il taglio cresceva anche attorno alla cinta. Ora quei 3 in più calano
  quando il taglio cresce. Nella scheda stanno tutte entro il 10% (l'occhio è
  il più pesante, +9%), e la prova lo controlla.
- **Niente dettagli sotto il taglio.** La regola dei fili vale anche per le
  sporgenze: un gradino più piccolo di C da piccolo diventa un dentino
  confuso.
  - Il pomo della spada sporgeva dal manico di 2 per parte: ora 5.
  - La base della lanterna sporgeva di 4: ora 5.
  - In cima al tetto restava una spalla di un'unità sotto l'anello: ora il tetto
    finisce a filo.
- **I pixel.** Ho pensato di allineare i lati dritti alla griglia dei pixel,
  come si fa con le icone piccole. Ma il gioco sfuma ogni bordo di un pixel e
  un quarto a cavallo del bordo vero (`Manifesto.poligono`): allineato o no, il
  bordo resta morbido uguale. Non serve.
- **Due somiglianze col resto del gioco, da decidere.** In combattimento i
  riquadri degli status (`scripts/combattimento/IconeStato.gd`, dal disegno di
  Bru) usano la fiamma per «in fiamme» e la saetta per «lentezza», «frastornato»
  e «sonno».
  - La Velocità è un fulmine: lo stesso segno, con un significato opposto.
    La scia fuori registro la distingue, e anche i colori: lo status è giallo
    in un tassello nero, la statistica è crema col timbro arancio.
  - Il Fattore è un fuoco, ma porta il rombo dell'emblema in mezzo.

  Sono contesti diversi (la scheda e la crescita da una parte, la vita in
  battaglia dall'altra), ma lo stesso gioco.

### 7.5 Le metafore, rilette con le ricerche sul riconoscimento

- **McDougall e Isherwood (2009, *Behavior Research Methods*).** All'inizio
  conta la **distanza semantica**, cioè quanto l'icona è vicina a quello che
  vuol dire: spiega fino al 55% di quanto bene si riconosce. Con l'uso conta
  di più la familiarità.
- **Zheng, Silvennoinen e Kujala (Jyväskylä).** La concretezza è quello che
  avvicina di più un'icona al suo significato; la bellezza aiuta poco l'uso.
- **Le convenzioni dei giochi** (Improbable Island, OpenGameArt, Inkwell):
  - cuore per la vita, spada per l'attacco, scudo per la difesa;
  - per la velocità il classico è lo stivale alato (o le impronte);
  - per l'intelligenza e la volontà non c'è un segno fisso.

| statistica | la nostra figura | distanza dal significato | perché va bene lo stesso |
|---|---|---|---|
| Vita | cuore | vicinissima | la convenzione più forte che c'è |
| Attacco | spada | vicina | la convenzione |
| Difesa | scudo | vicina | la convenzione |
| Velocità | fulmine | media (il classico è lo stivale alato) | il fulmine era già nel gioco per la velocità; la scia dice il movimento |
| Intelligenza | occhio con serratura | media | nel gioco è la fuga: vedere la via d'uscita |
| Forza mentale | lanterna | lontana | si impara; nella scheda il nome sta sempre accanto all'icona; e nei giochi con lo stress (Darkest Dungeon) la luce è proprio quello che lo tiene basso |
| Fattore | fuoco con l'emblema | lontana | è un concetto solo di Carnivalz: nessuna icona nota lo dice |
| Maestria | corona con la barra | media | la corona è la maestria; la barra lega il segno al dominio |
| Aura | ricciolo con la coda | lontana | l'energia che si spende; lo hitodama dà al segno una storia |

Le ricerche dicono che le figure lontane si imparano con l'uso. Nella scheda e
nella crescita il nome sta sempre accanto all'icona: l'icona deve farsi
riconoscere al secondo sguardo, non spiegarsi da sola. Le tre statistiche che
si guardano di più (vita, attacco, difesa) sono anche quelle con le figure più
vicine.

**I contorni e i pieni.** Le regole dei set chiedono uno stile solo: o tratto
o pieno. Le nostre sono pieni coi tagli. Dove l'oggetto ha un bordo (l'occhio,
lo scudo, la lanterna) il bordo è spesso T, sempre lo stesso: è il pieno di un
oggetto che ha un bordo, non un'icona a tratto. La lanterna ha i montanti
spessi T e i traversi spessi C, come i telai veri.

## 8. Rifatte da capo: la seconda revisione di Bru

Bru, sulla revisione del §7: «ancora non ci siamo le icone che effettivamente
sono migliorate sono: intelligenza e le frecce [...] come ti viene in mente di
mettere la cicatrice in mezzo al cuore? terribile... l'aura non è perfettamente
curvilinea sembra abbia bozzi [...] l'icona attacco è totalmente da rifare [...]
così come quella della lanterna che è un'idea proprio senza fantasia come la
fiamma, non c'è stato impegno».

Aveva ragione su tutto. Il §7 aveva corretto i numeri (pesi, centri, fili) su
idee che non reggevano: una cicatrice messa sopra un cuore, una falce messa
accanto a una spada, una fiamma messa dentro una lanterna. Sono figure **una
accanto all'altra**. L'occhio con la serratura funziona perché l'iride **è** la
serratura.

### 8.1 La regola nuova

- **La prima figura si legge da sola.** La seconda è il premio di chi guarda.
  È la regola dei marchi a spazio negativo (Creative Bloq, *19 brilliant
  examples of negative space*): la figura nascosta non deve servire a capire,
  e il marchio non deve perdere niente se uno non la vede.
- **Le due figure si fondono**, non si sommano: una parte della prima fa da
  seconda (l'iride e la serratura, la fascia della corona e la barra).
- **Prima le idee, poi i numeri.** Per ognuna delle quattro da rifare ho
  schizzato da sette a sedici strade e le ho giudicate grandi, a 64, 32, 24 e
  16 pixel, chiare su scuro. Solo dopo ho misurato.

### 8.2 Le strade, tenute e scartate

| statistica | tenuta | scartate, e perché |
|---|---|---|
| Vita | **il palloncino**: il cuore è un palloncino della fiera, col nodo, il filo e il riflesso | la fiala (il cuore come pozione: buona, seconda scelta), il cuore mezzo pieno (sembra un triangolo nel cuore), la chiave a carica (fa rima con la serratura dell'Intelligenza), il cuore nel cuore (piatto), la croce (l'icona di ogni farmacia), la foglia d'edera (la vena lo spacca: sembra un cuore rotto) |
| Attacco | **la spada mascherata**: l'elsa è una colombina, la maschera del carnevale veneziano | la spada di picche (un cartello di pericolo), la picca e la guardia a picche (una pala), il tirapugni (una corona coi denti), la Z di Zorro (la Z del sonno), il coltello che inchioda la carta (affollato), la sciabola (un coltello da cucina, e leggera), il guantone (una nuvola), la mazza (un martello da artigiano o da giudice), i graffi (fili), la spada nel rombo e l'asso di spade (una croce), la lancia da giostra (un trapano) |
| Velocità | **i due galloni**: la scelta di Bru fra le frecce | il fulmine (lo stesso segno dello status «lentezza»), tre galloni (fitti da piccoli), la freccia con l'eco |
| Forza mentale | **il brillante**: il rombo dell'emblema tagliato in cima diventa un diamante | l'ancora (è il legame, nella storia), la trottola, la maschera (una faccia), il loto (sembra una foglia di canapa), la palla in equilibrio (un pedone), la perla nella conchiglia (una persona in una ciotola), l'incudine (l'artigiano) |
| Fattore | **la bomba**: la miccia accesa è la brace, la scintilla il critico, il riflesso il rombo | il rombo fuori registro (astratto), il rombo a strisce sfasate (un albero di Natale), la candela accesa dai due capi (un fornello), l'asso infuocato, lo scoppio di rombi (una rosa dei venti), la brace a rombo (affollata), il cappello del giullare (la stessa sagoma della corona) |

La spada mascherata è stata provata dritta e di sbieco. Dritta, appesantita
perché pesasse come le altre, diventava una faccia mascherata col cappello a
punta. Di sbieco si legge subito come arma; perché non si allargasse troppo
(il raggio d'inerzia) sta in un quadrato di 82, e il pomo resta un rombo dritto.

### 8.3 L'Aura senza bozzi

La critica era precisa: il bordo ondeggiava. Il ricciolo del §7 era costruito
così:

- una curva cubica e una spirale, attaccate;
- allargate con le normali stimate dai punti vicini;
- uno spessore fatto a tratti.

Ogni attacco lasciava un piccolo salto di curvatura, e l'occhio li vede.

Gli strumenti nuovi:

- **Il pettine della curvatura**, come nei programmi per disegnare caratteri:
  da ogni punto del bordo esce un dente lungo quanto la curva gira lì. Se la
  cresta dei denti è liscia, il bordo è liscio. È nella tavola «costruzione»,
  sopra l'Aura (`IconeStatistiche.curvatura`).
- **Il conto dei bozzi** (`IconeStatistiche.bozzi`): le volte che la curvatura
  smette di crescere e cala, a meno di 3 unità dal cambio prima. Le gobbe vere
  di una figura stanno lontane fra loro; un bordo a bozzi cambia ogni unità o
  due. Il ricciolo di prima ne aveva **59**, quello nuovo **0**. È una prova
  della suite.

Il segno, misurato:

1. La foto di Jalhalla, ritagliata e ridotta a bianco e nero; lo scheletro
   (Zhang-Suen) dà la linea di mezzo, la distanza dal fondo dà lo spessore.
2. La linea di mezzo del segno capovolto, letta così:
   - dalla punta scende girando in senso orario (la pancia, da 50° a circa
     145°);
   - poi si flette e si avvolge in senso antiorario per circa 470°;
   - il ricciolo è un ovale 1,65 : 1;
   - la pancia è larga 0,22 dell'altezza, il ricciolo 0,09.
3. La curva nuova è data dalla sua **curvatura lungo la lunghezza**, che non salta mai:
   - sulla coda, una gobba oraria che sfuma nella curvatura del ricciolo;
   - poi una spirale logaritmica, il cui raggio di curvatura cala dritto;
   - tutto allargato in orizzontale per l'ovale.
   Sette numeri, trovati con una ricerca che ricalca la linea misurata: lo
   scarto medio è il **2% dell'altezza**.
4. Lo spessore è più pieno del segno, come le altre icone:
   - nasce dalla punta;
   - si gonfia nella pancia (0,36 dell'altezza);
   - corre nel ricciolo (0,185);
   - chiude in tondo.
   Tutte funzioni lisce, e le normali sono quelle vere della curva.
5. Un ultimo gomito l'ha trovato il pettine ingrandito sette volte: dove
   cominciava la fine tonda (radice di 1 − x²) lo spessore cambiava curvatura di
   colpo. Ora è radice di 1 − x⁶, piatta in partenza fino alla derivata quinta.

### 8.4 Le misure

Tutte dentro le regole del §7 (il rapporto è `docs/icone_statistiche.md`):

- **pesi** fra −7% (la spada, che è fatta di lame) e +5,5% (l'occhio);
- **raggi** entro il 10%;
- **centri visivi** entro 2,5;
- **niente fili**, nemmeno a 16 pixel chiare su scuro. Piccole:
  - gli occhi della maschera si stringono;
  - il riflesso della bomba rientra;
  - la miccia si accorcia;
  - i due galloni si allontanano.

La prova delle icone è stata sabotata in venti modi (l'aura fuori dall'area,
il riflesso fuori dal palloncino, gli occhi che da piccoli non si stringono, la
scintilla attaccata alla miccia, le frecce strette, le normali stimate a
occhio, lo spessore a gradini...): li ha presi tutti.

### 8.5 Cosa resta a Bru

Le alternative tenute sono nelle strade sopra: la fiala per la Vita, i tre
galloni o la freccia con l'eco per la Velocità. Le metafore del §7.5 cambiano
così:

| statistica | figura | distanza dal significato |
|---|---|---|
| Vita | cuore-palloncino | vicinissima: è un cuore |
| Attacco | spada mascherata | vicina: è una spada |
| Velocità | due galloni | vicina: l'avanti veloce di ogni lettore |
| Forza mentale | brillante | media: la pressione che fa i diamanti si spiega in una riga |
| Fattore | bomba | media: il potenziale che esplode, i critici |
| Aura | fuoco fatuo | lontana, ma con la sua storia: il segno di Jalhalla |
