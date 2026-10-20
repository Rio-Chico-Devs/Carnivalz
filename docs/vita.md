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
| il minigioco col corpo | approvato | nel gioco: `scripts/combattimento/RiquadroRaffica.gd` |
| il riflesso sui vetri | approvato | nel gioco: `scripts/RiflessoVetro.gd` |
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

- **L'anticipo**: nell'ultimo mezzo secondo prima che un pugno arrivi, otto
  tacche corrono verso di lui.
- **La parata**: un anello che si allarga di più di prima, la parola come un
  **timbro** sulla fascia nera (arancio), le schegge, il piano che sobbalza,
  il contatore che fa la gelatina.
- **Il colpo preso**: il riquadro si accende di rosso, lo schermo si
  **crepa** dal punto in cui ti ha preso, la parola sulla fascia rossa, e lo
  scontro sbanda forte.
- I timbri restano dentro il riquadro: vicino al bordo un timbro tagliato non
  si legge.
- **Movimento ridotto**: niente tacche, niente schegge, niente scossa; le
  parole compaiono ferme.

## 6. Il riflesso sui vetri

Ogni tanto sul vetro di un cabinato passa una lama di luce di traverso: tre
quarti di secondo ogni quattro secondi e mezzo, un decimo di bianco. Ogni
vetro ha il suo tempo, mai due insieme. Sta nel vetro di tutti i cabinati
(`Manifesto.Vetro`), quindi anche nella schermata del racconto. Disegna solo
mentre passa. **Movimento ridotto**: non passa.

## 7. Le prove

`prova_il_taglio_della_mattanza`, `prova_lo_squarcio_d_entrata`,
`prova_il_turno_si_vede_col_corpo`, `prova_la_raffica_col_corpo`,
`prova_il_riflesso_sui_vetri`: la fascia alta metà schermo, l'iniziale e
l'artwork dentro la fascia, il mondo fermo sotto il taglio, il tasto che lo
salta senza colpire, la durata; lo squarcio solo verso lo scontro e mai col
movimento ridotto, le metà che volano, i pezzi che entrano solo arrivando dallo
squarcio e il quadrante per ultimo; le fasce del turno, «TOCCA A TE», il
rosso del nemico, lo slot che non resta alzato; l'anticipo solo nell'ultimo
mezzo secondo, i timbri nero e rosso dentro il piano, le schegge, la scossa;
i riflessi sfalsati. Ognuna col suo caso del movimento ridotto. Verificate
rompendo apposta il codice in 32 modi.

## 8. Il BOND: tre proposte

Bru: «per il bond ci vuole qualcosa di più felice e tranquillo». Il BOND è la
mediazione: la creatura la lasci vivere, la raggiungi (`docs/mediazione.md`).
Quindi il contrario della Mattanza in ogni scelta:

| la Mattanza | il BOND |
|---|---|
| fasce di traverso | linee orizzontali e cerchi |
| entra di scatto, esce di scatto | si muove piano, comincia e finisce morbido |
| nero e rosso | crema, oro, l'arancio del gioco |
| lampo, scossa, schegge | niente di tutto questo |
| uno solo che colpisce | due che si avvicinano |

Le tre proposte (`prove/ProposteBond.gd`, `./prove/film_bond.sh`, nell'editor
`ProposteBond.tscn` e F6), un secondo e tre quarti ciascuna:

- **Il filo**: una fascia chiara entra dritta, i due si guardano dai due
  lati, un filo arancio li unisce ondeggiando e al centro si fa il nodo: il
  rombo del gioco, con una luce che si allarga piano.
- **L'alba**: un sole sale dall'orizzonte nero coi raggi che girano piano, i
  due si camminano incontro sull'orizzonte, e BOND è scritto nel sole.
- **L'anello**: due metà d'anello, una arancio e una nera, scivolano una verso
  l'altra e si chiudono intorno ai due. È l'anello aperto del mon (quello del
  pugno dell'Attacco) che qui si chiude.

Al posto delle lettere andrebbero gli artwork dei due: chi media e la creatura.
Come la Mattanza, un clic la salterebbe e il mondo starebbe fermo sotto.

## 9. Cosa resta da decidere

1. Quale delle tre per il **BOND** (o cosa prendere da ognuna).
2. I **minigiochi**: oggi ci sono la raffica (Collisioni infinite), il
   braccio di ferro della Mazzata e il colpo di grazia della Mattanza. Quali
   altri hai in mente?
