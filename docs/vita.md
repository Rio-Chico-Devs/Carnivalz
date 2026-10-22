# Più vita e movimento nello scontro

Bru:

> «cominciamo a lavorare sui minigiochi e gli effetti del gioco ora [...] mi
> fai degli esempi di animazioni che diano più vita e movimento al gioco?»

I menu hanno già il loro vocabolario di movimento (`docs/animazione.md`), e il
menu principale si muove già (la ruota gira, le lampadine tremano, la
parallasse). La parte ferma era **lo scontro**: a riposo non si muoveva niente
tranne l'ECG, il turno passava accendendo una cornice, la Mattanza partiva
come un comando qualunque, e il minigioco erano cerchi rossi su nero.

## 1. Cosa ha deciso Bru

Sei esempi girati come film (il respiro, le braci, lo squarcio, il turno, la
Mattanza, il minigioco). Bru:

> «bene, mattanza approvata, bellissima ma vogliamo che la barra sia più
> grande dentro ci metteremo un artwork, bello anche lo spacco che ti
> introduce al combattimento, bello tutto tranne le particelle che si muovono
> nello sfondo e le immagini che galleggiano»

| esempio | | adesso |
|---|---|---|
| lo squarcio d'entrata | approvato | nel gioco: `scripts/Squarcio.gd` |
| la Mattanza | approvata, con la fascia **più grande** per l'artwork | nel gioco: `scripts/combattimento/TaglioMattanza.gd` |
| il turno che passa | approvato | nel gioco: `scripts/combattimento/FasciaTurno.gd` |
| il minigioco col corpo | approvato, poi **rifatto** giocando: niente cerchio che si chiude (§5); approvato di nuovo («bello mi piace!»); il vetro rifatto da capo («sembra quasi fatto su paint»), poi «già meglio», con la luce fredda | nel gioco: `scripts/combattimento/RiquadroRaffica.gd` |
| il riflesso sui vetri | approvato, poi **no** giocando (§6) | tolto |
| il BOND (la purificazione, §8) | approvato dopo tre giri | nel gioco: `scripts/combattimento/LuceBond.gd` |
| le braci che salgono | **no** | tolte |
| chi combatte che respira | **no** («le immagini che galleggiano») | tolto |

I film adesso si girano **dal gioco vero** (`prove/ProposteVita.gd` fa
succedere le cose, non le disegna):

```
./prove/film_vita.sh              # tutti, in scatti/proposte_vita/ (un .mp4 ciascuno)
./prove/film_vita.sh mattanza     # uno solo
```

Nell'editor: `prove/ProposteVita.tscn`, F6 (fa la Mattanza).

## 2. Lo squarcio (l'entrata nello scontro)

La schermata da cui arrivi si **crepa** lungo una linea storta (lo squarcio dei
Carnivalz), la crepa si accende, le due metà volano via girando un poco, e
sotto lo scontro entra a pezzi: il nemico e la sua scheda da sinistra, la
squadra dall'alto, per ultimo il quadrante dei comandi.

- **Chi lo fa**: `Transizioni.gd`, che fa tutti i cambi di scena. Verso lo
  scontro, al posto del velo nero, fotografa lo schermo e ci mette sopra la
  foto (non si vede niente cambiare), cambia scena sotto, e la foto si rompe.
  Lo scontro, nel suo `_ready`, chiama `Squarcio.entra_a_pezzi`: i pezzi
  entrano solo se si arriva da uno squarcio, mai nelle prove che aprono lo
  scontro a mano.
- **Quanto**: dalla crepa all'ultimo pezzo fermo poco più di mezzo secondo,
  meno della dissolvenza che sostituisce (0,7 s andata e ritorno). Mentre la
  foto si rompe i clic non passano.
- **Movimento ridotto**, o senza finestra da fotografare: la dissolvenza di
  sempre.

## 3. La Mattanza

Il **taglio a tutto schermo** quando parte: un lampo, tre fasce di traverso che
entrano da parti opposte, **la nera alta metà schermo** (per l'artwork), la
parola MATTANZA che cade come un timbro con le schegge, e tutto che esce
dall'altra parte; poi lo scontro sbanda e si comincia a battere.

- **L'artwork**: `art/mattanza/<id del personaggio>.png` (per il protagonista
  `anonimo.png`). Sta nella parte sinistra della fascia nera, alto quanto la
  fascia, tagliato dai suoi bordi storti, e scivola piano mentre tutto è fermo.
  Finché non c'è, al suo posto c'è l'iniziale grande. Il disegno può essere
  largo quanto vuoi: si vede fino a poco più di metà schermo, il resto lo
  copre la parola. Per stare larghi: **1100 px di altezza**, sfondo
  trasparente, la fascia è inclinata di 7 gradi e il disegno gira con lei.
- **Non fa aspettare**: il suo orologio è quello dello scontro (lo fa avanzare
  `Mattanza.passa`), e intanto il mondo e la barra stanno fermi. La finestra
  comincia quando il taglio è finito. In tutto 1,1 s; il **primo tasto o
  clic lo salta** (e non è ancora un colpo).
- **Movimento ridotto**: solo la fascia nera con la parola, ferma, per 0,6 s.

## 4. Il turno che passa

- Lo slot di chi tocca **si alza** (+3,5%) e si inclina di un grado, con un
  rimbalzo corto; gli altri tornano giù. Due turni di fila in fretta non lo
  lasciano alzato: il movimento di prima si ferma.
- Sotto il suo schermo entra una **fascia**: «TOCCA A VERONICA», «TOCCA A TE»
  (nera, scritta arancio). Un nome lungo stringe la scritta invece di uscire
  dallo schermo. La fascia resta finché il turno è suo.
- Quando tocca al **nemico** il suo schermo si accende di rosso due volte e
  sobbalza, e la fascia è rossa: «TOCCA A MARIONETTA».
- Dove: `Slot.imposta_turno` (che reagiva già solo ai cambi) e
  `Campo.evidenzia` per il nemico.
- **Movimento ridotto**: niente inclinazione e niente rimbalzo; la fascia
  compare sul posto.

## 5. Il minigioco col corpo (Collisioni infinite)

Bru, giocandolo:

> «quando si chiude quelle linee sono brutte da vedere e il fatto che si
> chiuda è noioso sembra che ti colpisca piano, facciamo che compaiono di botto
> uno ad uno dodici pugni poi devi cliccare quando si illuminano, una volta che
> ci prendi il pugno o viene parato o lo ricevi, così è più dinamico, ordine in
> cui si illuminano è randomico»

Il cerchio che si stringeva e le tacche che correvano non ci sono più. Adesso
(le regole in `docs/raffica.md` §7):

- **Compaiono di botto**, uno ogni 0,12 s, ognuno al suo posto: si piantano un
  filo più grandi, con un lampo bianco, e rientrano in un attimo. Ognuno fa un
  tonfo.
- **Spenti sono in penombra**: rosso scuro, bordo sottile. Dodici a schermo
  insieme, mai uno sopra l'altro.
- **Acceso** è il rosso pieno col bordo bianco e un alone che pulsa; scatta in
  avanti e poi **si gonfia sempre più in fretta** e trema: è un pugno che ti
  arriva in faccia. Quando è gonfio del tutto ti prende: il tempo che resta,
  detto senza un cerchio. Negli ultimi istanti il bianco gli sale dentro.
- **La parata**: un anello che si allarga di più di prima, la parola come un
  **timbro** sulla fascia nera (arancio), le schegge, il piano che sobbalza,
  il contatore che fa la gelatina.
- **Il colpo preso**: il riquadro si accende di rosso, la parola va sulla
  fascia rossa, lo scontro sbanda forte, e **il vetro dello schermo si rompe**
  dal punto in cui il pugno ti ha preso (`scripts/combattimento/VetroRotto.gd`).
  Prima erano sei rami corti rossi e bianchi; Bru: «concentriamoci più che
  altro sull'effetto vetro rotto quando ricevi i colpi nel videogioco
  attualmente è abbastanza brutto». Adesso è la lingua delle crepe
  dell'orologio approvate (`Crepe.gd`):
  - nel punto dell'impatto il vetro è schiacciato, chiaro, con un lampo;
  - da lì corrono fino al bordo del vetro da cinque a sette crepe principali,
    quasi dritte, con lo strappo secco, e qualcuna si biforca;
  - intorno all'impatto ci sono le crepe minute, e fra le principali tre giri
    di ragnatela, con qualche buco;
  - ogni faccia prende la luce a modo suo, un luccichio le attraversa dal
    centro, e qualche scheggia salta via e cade;
  - un pugno diverso rompe il vetro in un modo diverso.

  **Le linee, rifatte** (Bru: «va fatto ancora meglio sono le linee da
  migliorare»). Erano tre difetti insieme:
  - **tremavano**: passi di cinque pixel ognuno storto di un poco, e il poco si
    sommava. Adesso tratti lunghi e dritti, uno strappo secco ogni tanto, e la
    crepa torna sempre verso la sua direzione; la ragnatela è fatta di corde
    quasi dritte con un gomito solo;
  - **erano doppie**: l'ombra era la stessa riga spostata di un pixel in basso
    a destra, e da vicino se ne leggevano due, sfocate. Adesso sotto c'è un
    alone scuro centrato e sopra un filo solo, nitido, che si assottiglia;
  - **il bordo**: il filo era un poligono che si ritirava di mezzo pixel e
    sotto i due pixel si rovesciava. Adesso è una striscia di triangoli che
    sfuma di traverso: liscia a qualunque larghezza, e nei gomiti non si
    strozza.

  E il filo si muove: la punta che corre è più chiara, e appena le crepe sono
  al bordo un riflesso le percorre dall'impatto in fuori. Le crepe corrono in
  un decimo di secondo, il vetro resta un secondo e sfuma, perché i pugni dopo
  vanno letti.

  **Il vetro rifatto da capo.** Bru, sul vetro che si spaccava: «non ci
  siamo, non è ancora di qualità sembra quasi fatto su paint». Era vero, e il
  perché si vede mettendolo accanto a quello che ha approvato, lo squarcio
  d'entrata: lì la crepa si accende (un cuore bianco e un alone caldo) e le
  due metà volano via portandosi dietro l'immagine vera. Il vetro invece era
  fatto di disegni sopra lo schermo: schegge bianche piatte, un cerchio bianco
  come onda, un disco bianco come cratere, macchie scure come buchi, una
  tinta uguale su tutto un pezzo. Le tecniche dei giochi che lo fanno bene
  dicono la stessa cosa: i pezzi portano con sé l'immagine dello schermo e
  volano verso la camera girando, con un bordo che prende la luce; la
  rifrazione e i riflessi diversi da pezzo a pezzo fanno quasi tutto
  ([Voronoi screen shatter](https://godotshaders.com/shader/simple-glass-broken/),
  [Impact Glass](https://godotshaders.com/shader/impact-glass-shader/),
  [broken_glass, col bordo illuminato](https://pub.dev/packages/broken_glass),
  il finale dell'All-Out Attack di Persona 5). Adesso, nell'ordine in cui
  succede:
  - **il fermo sul colpo**: per 0,07 s si ferma tutto, col pugno gonfio
    arrivato sul vetro; un lampo appena (un battito) e il bagliore morbido
    dove ha preso;
  - **le crepe che si accendono**: corrono in un decimo di secondo con la
    punta che brilla, e appena rotte bruciano - un cuore quasi bianco e un
    alone del colore della luce, sommati a quello che c'è sotto, come la crepa
    dello squarcio - poi in un quarto di secondo si raffreddano;
  - **le crepe incise**: una crepa è un taglio con due pareti, e si disegna
    così: un filo scuro dalla parte in ombra, uno chiaro dalla parte della
    luce (che viene dall'alto a sinistra), in mezzo il taglio che si
    assottiglia e che non è uguale dappertutto, perché dove gira un poco
    prende la luce. Da vicino ha i denti: mezzo pixel di qua e di là ogni tre
    pixel;
  - **il vetro schiacciato**: dove il pugno ha preso, una trentina di
    crepoline storte e quaranta granelli, su un velo appena chiaro;
  - **l'onda**: non più un cerchio bianco, ma una deformazione - un anello
    che si allarga e spinge in fuori quello che c'è dietro - con sopra un velo
    di luce morbido;
  - **i pezzi** (`scripts/combattimento/LastreVetro.gd`): il vetro si taglia
    lungo le crepe, e ogni pezzo mostra quello che c'è dietro spostato per
    conto suo (`shaders/vetro_lastre.gdshader`), con un riflesso che gli
    scivola sopra da un lato all'altro. Un pezzo si sposta solo quando le
    crepe l'hanno tagliato tutto: prima un pezzo grande tagliava i pugni lungo
    una crepa che non c'era ancora. Nel colpo strappano, poi si assestano;
  - **i pezzi che saltano**: quelli attaccati all'impatto si portano dietro il
    loro pezzo di immagine e ti vengono addosso ingrandendosi, girano anche in
    profondità (si schiacciano fino a rovesciarsi), lampeggiano quando si
    girano verso la luce; hanno lo spessore del vetro di taglio, verdino, e il
    bordo chiaro dove guarda la luce e scuro dove no;
  - **i buchi**: dove un pezzo è saltato resta il buio, col vetro di taglio
    tutto intorno;
  - **il rosso**: non più un velo piatto su tutto, ma i bordi del riquadro che
    si arrossano verso dentro, come quando si stringono gli occhi;
  - **COLPITO** cade di fianco al pugno, verso il centro: sopra copriva il
    punto in cui il vetro si spacca.

  **La luce è fredda**, quella di un vetro vero (`VetroRotto.TINTA`). Le
  proposte erano due, uguali in tutto tranne il colore delle crepe accese:
  calda, l'arancio della crepa dello squarcio, e fredda. Bru: «si già meglio,
  la seconda è quella che mi è piaciuta di più».

  Tutto sta in quattro tele per vetro (`TeleVetro.gd`): i pezzi che guardano
  dietro, il vetro, i pezzi che saltano, la luce che si somma. Una per vetro
  perché l'onda è dello shader, e due colpi vicini hanno due onde.
- I timbri restano dentro il riquadro: vicino al bordo un timbro tagliato non
  si legge.
- **Movimento ridotto**: i pugni non scattano e non si gonfiano (lo dice la
  luce), niente schegge, niente scossa; le parole compaiono ferme. Il vetro
  rotto c'è subito, intero, senza lampo né schegge né riflesso né onda, e le
  crepe non si accendono; i pezzi sono spostati ma fermi, senza strappo, e
  non saltano via; poi sfuma.

## 6. Il riflesso sui vetri: tolto

C'era: ogni tanto sul vetro di un cabinato passava una lama di luce di
traverso, tre quarti di secondo ogni quattro secondi e mezzo, ogni vetro col
suo tempo. Stava nel vetro di tutti i cabinati (`Manifesto.Vetro`), quindi
nello scontro e nella schermata del racconto. Approvato negli esempi, ma
giocando Bru:

> «quei riflessi durante il combattimento e i dialoghi sono molto fastidiosi»

Tolto del tutto: il vetro è l'anello e il filo, e non si muove.
`prova_i_vetri_stanno_fermi` controlla che non torni niente sopra i vetri.
La lezione: una cosa che si ripete da sola mentre leggi o combatti disturba,
anche se in un film di tre secondi è bella.

## 7. Le prove

`prova_il_taglio_della_mattanza`, `prova_lo_squarcio_d_entrata`,
`prova_il_turno_si_vede_col_corpo`, `prova_la_raffica_col_corpo`: la fascia
alta metà schermo, l'iniziale e
l'artwork dentro la fascia, il mondo fermo sotto il taglio, il tasto che lo
salta senza colpire, la durata; lo squarcio solo verso lo scontro e mai col
movimento ridotto, le metà che volano, i pezzi che entrano solo arrivando dallo
squarcio e il quadrante per ultimo; le fasce del turno, «TOCCA A TE», il
rosso del nemico, lo slot che non resta alzato; i pugni che compaiono di botto,
quello acceso che si gonfia (e resta nel suo spazio), niente più cerchio né
tacche, i timbri nero e rosso dentro il piano, le schegge, la scossa, il vetro.
Ognuna col suo caso del movimento ridotto. Verificate rompendo apposta il
codice in 32 modi (con quella del riflesso, che non c'è più); le Collisioni
nuove e le linee del vetro in altri 38 (`docs/raffica.md` §7).

Per il BOND: `prova_la_luce_del_bond_quando_medi`,
`prova_la_luce_del_bond_lettera_per_lettera`,
`prova_la_luce_del_bond_col_movimento_ridotto`. Controllano:
- che mediando parta, sopra tutto lo scontro, e che il clic sia suo;
- che le parole, il pannello del racconto e la barra della Mattanza aspettino,
  che il box riparta pulito, e che la luce vada avanti da sola;
- che si salti sfumando, e che da muti non si apra;
- il contorno vero di ogni lettera (i giri, il punto più basso, la misura);
- i tempi e le pose di ognuna, il riempimento, l'oro, la riga col rombo;
- l'uscita da sinistra e la durata;
- il movimento ridotto.

Verificate rompendo apposta il codice in 29 modi.

## 8. Il BOND: solo la scritta, e la luce

Bru: «per il bond ci vuole qualcosa di più felice e tranquillo». Il primo
giro aveva i due personaggi (il filo, l'alba, l'anello), e Bru: «no
nessuno mi piace non ci devono essere i personaggi nel bond solo la scritta
animata in modo angelico e pacifico tipo purificazione».

Quindi solo la parola. Il BOND è la mediazione: la creatura non la abbatti,
la liberi da quello che l'ha deformata (`docs/mediazione.md`). Si fa con la
luce, che **lava** lo scontro. Ed è il contrario della Mattanza in ogni
scelta:

| la Mattanza | il BOND |
|---|---|
| fasce di traverso, lampo, scossa, schegge | luce morbida, niente scatti |
| entra di scatto, esce di scatto | comincia piano e finisce piano |
| nero e rosso | il fantasma color crema dello scontro, la parola d'oro |
| 1,1 s | 3,5 s, e un clic la salterebbe |

Com'è fatto: tre strati.

- **Il lavaggio**: uno shader legge lo scontro sotto e lo scolora, lo
  schiarisce e lo sfoca, finché ne resta un fantasma color crema.
- **La parola**, disegnata bianca: uno shader la sfoca, la dora (oro chiaro in
  alto, ambra in basso), ci fa passare un riflesso e le mette intorno il
  bagliore.
- **Gli ornamenti**, disegnati e dorati con lei: la riga col rombo.

Le tre proposte di sola scritta erano la purificazione (un'onda di luce dal
basso), l'aureola (luce dall'alto, lettere come piume) e la calligrafia (luce
dal centro, Bond scritto a mano). Bru: «mi piace il primo, ma va migliorato
manipolando ogni singola lettera e anche mettendoci più lavoro nelle
animazioni».

### La purificazione, lettera per lettera (nel gioco)

Bru: «si dai mettila». È nel gioco: `scripts/combattimento/LuceBond.gd`, con
`LetteraBond.gd` (il contorno di ogni lettera) e i due shader
`shaders/bond_lavaggio.gdshader` e `shaders/bond_doratura.gdshader`. Il film si
gira dallo scontro vero, mediando con la Tartaruga: `./prove/film_bond.sh`
(nell'editor `prove/ProposteBond.tscn` e F6). In tutto 3,5 secondi:

1. **L'onda** sale dal basso, col bordo che ondeggia piano come la marea, e
   lava lo scontro.
2. **Ogni lettera nasce per conto suo.** Ha i suoi tempi: prima la O, poi la
   N, la B, la D. Arriva da una posa sua, un poco girata, più bassa e più in
   fuori, e si posa frenando. Dentro, tre tempi:
   - **la luce sale lungo il contorno.** Due punte partono dal punto più basso
     e si incontrano in cima. È il contorno vero del carattere, letto dal font,
     coi buchi della B, della O e della D. Dove la luce tocca la lettera per la
     prima volta si accende un seme;
   - **si riempie dal basso**, come un vaso, col pelo della luce chiaro;
   - **si raffredda in oro.** Appena piena splende di più, poi respira piano,
     ognuna col suo passo.
3. **La riga** si apre sotto la parola. Il rombo arriva girando di un quarto,
   e due comete di luce corrono dal centro alle punte.
4. **Il riflesso** passa sulla parola, e ogni lettera si accende quando la
   tocca.
5. **L'uscita.** Le lettere salgono una alla volta, da sinistra, e si
   sciolgono in luce. La riga si ritira nel rombo, che sale con loro. Poi una
   seconda onda porta via la luce verso l'alto, e lo scontro torna coi suoi
   colori, dal basso.

Ogni lettera ha il suo CanvasGroup e il suo shader, quindi la sua sfocatura,
il suo oro, il suo riempimento e il suo bagliore. Sopra ci sono le tracce
della luce sui contorni e le scintille (le punte, i semi, le comete).

Nello scontro:

- **Quando parte**: quando medi (col tasto BOND o con la voce Mediazione),
  prima di tutto il resto. Sta sopra tutto lo scontro, anche sopra il box.
- **Il mondo aspetta**: finché la luce copre, i turni, le barre e la Mattanza
  stanno fermi, e il racconto della mediazione («Lo lasci andare: …») comincia
  quando la luce se n'è andata, su una pagina bianca (la battuta di prima non
  resta nel box). La luce invece va avanti da sola: se dipendesse
  dallo scontro, e lo scontro aspettasse lei, resterebbero fermi tutti e due.
- **Sotto la luce lo scontro è fermo** com'era quando hai mediato (una foto): la
  creatura è ancora lì finché la luce la copre, e non c'è più quando la seconda
  onda riporta lo scontro vero.
- **Il primo tasto o clic la salta**: se ne va sfumando in un quarto di secondo.
- **Movimento ridotto**: niente onde e niente lettere in volo. Lo scontro si lava
  tutto insieme e la parola d'oro, ferma, compare e sparisce (1,4 s).
- **Da muti** (il simulatore, le prove) non si apre: non c'è niente da guardare.

## 9. Cosa resta da decidere

1. I **minigiochi**: oggi ci sono la raffica (Collisioni infinite), il
   braccio di ferro della Mazzata e il colpo di grazia della Mattanza. Quali
   altri hai in mente?
