# La mappa di zona: cosa non va, e tre strade

Bru, dopo aver fatto togliere il filo fra i bottoni dei piani e i pavimenti:
«ora accupiamoci della mappa riusciamo a migliorare anche questa?».

Le tavole si rifanno con `./prove/proposte_mappa.sh` (finiscono in
`scatti/proposte_mappa/`); il codice delle proposte sta in
`prove/ProposteMappa.gd` e `prove/mappa/`, ed e' provvisorio come quello delle
proposte della crescita: se ne va quando la mappa vera nasce dalla strada scelta.
Tutte le tavole disegnano la stessa Casa Gigante (17 stanze viste su 27, sei
piani, sei sulla scala del primo piano) e la stessa Sede, con le regole vere del
gioco: cosa sai di una stanza lo dice GameState, dove arrivi
IngressoNodo.raggiungibile.

## 1. Il mestiere della mappa

In Carnivalz la mappa non si consulta ogni tanto: **e' il modo in cui ci si
muove**. Da una stanza si apre la mappa, si clicca una stanza confinante e ci
si va. Quindi la si guarda a ogni passo, e a ogni passo deve rispondere, in
quest'ordine:

1. dove sono?
2. dove arrivo adesso, con un clic?
3. dove devo andare (il punto esclamativo)?
4. cosa ho gia' visto e cosa manca?
5. com'e' fatta la zona: cosa sta sopra e cosa sotto?

La mappa di oggi risponde bene alla 5 solo su una zona piccola, e risponde alla
2 a fatica dappertutto.

## 2. Cosa non va oggi (tavola `0_oggi`)

1. **Sei piani in un modellino solo.** La Casa Gigante ha sei piani: tutti
   accesi insieme, le lastre si coprono e non si capisce cosa sta sopra cosa. E'
   la critica che si fa piu' spesso alla mappa di Control («un groviglio» fra un
   piano e l'altro) e quella che si fa a Metroid Prime: ottima per quello che
   hai intorno, confusa sull'insieme. Oggi un piano solo si vede solo
   cliccandolo.
2. **Il modellino e' piccolo.** Ventisette stanze in un terzo della cornice: una
   stanza e' grande come una lettera. Il resto della cornice e' vuoto, perche' la
   Casa e' alta (sei piani) e la cornice e' larga.
3. **I nomi si coprono.** Ogni stanza ha il suo nome, tutti alla stessa misura e
   nello stesso bianco: «Il bivio» sopra «Il masso gigante», «Ingresso della
   citta'» sopra «Strade di periferia», e la scheda sopra «Sala di allenamento».
4. **Dove arrivo adesso?** Una stanza vicina e una lontana hanno lo stesso
   azzurro: la differenza e' qualche punto di luce in piu'. E' la domanda che il
   giocatore si fa a ogni passo.
5. **Due anelli uguali.** Il boss e' un anello, chi ti aspetta (Yhvina) e' un
   anello piu' piccolo, uno scontro duro e' un punto. Non c'e' una legenda.
6. **Le scale sono fili.** Un pozzo fra due piani e' un tubo sottile come un
   capello, e attraversa altre stanze.
7. **La riga in fondo ripete.** «Sei in: La scala» lo dice gia' la freccia sopra
   la stanza, e passando su una stanza lo ripete la scheda accanto. Intanto la
   riga ruba altezza alla mappa.

E un difetto che non e' di disegno: la mappa di zona e la mappa stellare (che
Bru ha approvato) parlano due lingue diverse. Vetro azzurro su arancio di qua,
serigrafia blu e crema di la'.

## 3. Cosa hanno in comune le tre strade

Le tre proposte cambiano lingua, ma tengono le stesse regole:

- **Un piano alla volta in primo piano**: quello in cui sei, appena apri. Gli
  altri ci sono, ma come contesto (spenti, in pila, o in sezione). Z e X, o un
  clic sul piano, cambiano piano.
- **Dove arrivi e' la cosa piu' forte dopo dove sei.** I corridoi che partono
  dalla tua stanza sono arancio, con la freccia; le stanze dove arrivi hanno il
  nome in una linguetta. Le altre il nome piccolo (se c'e' posto) o niente, e le
  stanze che non conosci un «?».
- **Sei stati, ognuno con due segni** (pieno e bordo, mai il colore da solo): sei
  qui, ci arrivi, ci sei stato, la conosci ma non ci sei stato, la intravedi,
  chiusa.
- **Le scale dicono dove portano**: «↑ Soffitta», «↓ Piano terra».
- **«Da qui si va»**: la scheda di destra elenca le uscite della stanza, con la
  freccia del piano. E' la stessa domanda della mappa, scritta: si legge anche
  senza guardare il disegno, e da tastiera si scorre.
- **Segni nuovi, con la legenda**: la corona per il boss, lo scoppio per lo
  scontro duro, la persona per chi ti aspetta, la porta con la freccia per
  l'uscita, il lucchetto. Il punto esclamativo resta quello approvato. Sono
  provvisori come oggi: un disegno di Bru in `art/icone_mappa/` vince sempre.
- **Via la riga in fondo**: la mappa si prende tutta l'altezza.
- **Chi c'e'**: dove ci sono personaggi, il segno della persona sopra la
  stanza e il nome nella scheda (sulle tavole della Sede, Veronica in palestra e
  la Dr. Reika in infermeria, per far vedere come verrebbe: oggi nessuna stanza
  ne ha).

## 4. Le tre strade

### A · La vetrina (`a1`, `a2`, `a3`)

Il plastico 3D resta, ma parla come la mappa stellare e il Vuoto: i quattro
inchiostri (nero, blu, crema, arancio), le linguette, la colonna delle schede a
destra (01 stanza, 02 da qui si va, 03 piani), il titolo in basso a sinistra.
I piani si aprono come una cassettiera: quello scelto in mezzo, quelli sopra e
sotto spenti e lontani, ridotti all'impronta delle stanze, e le scale sono pozzi
tratteggiati che vanno dritti al piano dove portano.

- per: e' la piu' vicina a Metroid Prime e a quello che c'e' gia'; le due mappe
  del gioco diventano sorelle; si gira ancora tutto intorno.
- contro: e' la piu' scura; il piano sopra e quello sotto si vedono solo a meta'.

### B · Il manifesto (`b1`, `b2`, `b3`)

La mappa parla come la pausa e la crescita: arancio col retino, nero pieno,
carta grigio caldo, etichette inclinate, ombre stampate. Ogni piano e' un
vassoio di cartoncino, le stanze sono blocchi neri, quella in cui sei e'
arancio. A sinistra i piani **in pila**, piccoli e interi, ognuno della misura
di tutta la zona (le stanze di sopra stanno sopra quelle di sotto): la pila e'
la pulsantiera, e dice su che piano sei. Quello scelto esce dalla pila e si apre
in grande.

- per: la piu' riconoscibile, la piu' «Carnivalz»; si legge come un cartello
  stradale; la pila mostra tutti i piani sempre, senza coprirsi.
- contro: non c'e' piu' il vetro olografico; i blocchi neri chiedono stanze non
  troppo piccole.

### C · Pianta e sezione (`c1`, `c2`, `c3`)

Come si disegna un edificio: un piano visto dall'alto (la pianta) e di fianco la
casa tagliata in due (la sezione), con tutti i piani uno sopra l'altro e le
scale che li legano. Resta nello schermo del cabinato, come oggi.

- per: la piu' leggibile; nessun piano copre mai un altro; i nomi stanno dentro
  le stanze; la sezione racconta la casa a colpo d'occhio (l'altare in fondo,
  la soffitta in cima).
- contro: niente modellino da girare: e' la meno spettacolare, e la piu'
  lontana da quello che Bru aveva chiesto («tridimensionale ma semplice come
  nelle mappe di Metroid»).

Si possono mescolare: per esempio B con la sezione di C al posto della pila, o
A con la pianta di C quando si sceglie un piano solo.

## 5. Cosa chiedo a Bru

1. Quale strada, o quale miscuglio.
2. Il modellino da girare serve ancora? In A e in B resta; in C no.
3. I nomi delle stanze lontane: sempre (piccoli, se c'e' posto, come nelle
   tavole) o solo passandoci sopra?
4. I segni nuovi (corona, scoppio, persona, porta) vanno bene finche' non arrivano
   i tuoi?

## 6. Come sono fatte le tavole

Le proposte sono disegnate in 2D da una proiezione assonometrica (senza
prospettiva: le stanze lontane restano grandi quanto le vicine, e un piano si
legge tutto alla stessa misura). E' anche come le farei nel gioco: la camera
3D per sapere dove sta ogni cosa, e il disegno in 2D per avere i bordi pieni,
le ombre stampate e le scritte del manifesto. Girare e inclinare restano
possibili, cambiano solo i due angoli.
