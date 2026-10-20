# Come si pensa un'icona: il metodo di Bru

## 1. Le parole di Bru

Bru disegna per lavoro, e mi ha spiegato dove sbaglio:

> «prendi sul serio i miei consigli... uso te per snellire, ma io ci metto
> sempre mano... quando disegno io cerco prima delle figure che astrattamente
> raffigurino l'anima dell'icona, peccato? la mela. la combino poi con altri
> temi come peccato = oscurità e cosa ricorda l'oscurità? degli occhi cattivi,
> come quelli di Gengar, ma non basta: che contorno gli do? le fiamme di Imu
> di One Piece, una mela con occhi malvagi circondata da fiamme. ma come lo
> disegno? deve essere bello, occhi leggermente come se la testa fosse
> inclinata verso giù, mela tonda in prospettiva e un cerchio come le opere
> giapponesi che abbiamo visto ma fatto di fiamme, la parte inferiore
> interrotta per dare bellezza»

> «difesa -> scudo sì, ma chi difende? un eroe, chi ha forza, quindi combino
> scudo a segni allegorici di eroi, che può essere un simbolo di giustizia o
> altro, in questo caso userei anche la parola guardiano che ha a che fare con
> la difesa, protezione, quindi una croce ospedaliera non religiosa, siccome è
> tabù, ma come gioco con lo scudo?»

> «attacco -> spada e ok... ma è banale, lo vedi sempre... cosa si vede poco
> come attacco? un pugno? che simboli rappresentano l'attacco? attacco di
> cosa? normale giusto? allora la figura deve essere basica, ecco come
> ragiono, poi le forme devono essere compatibili fra di loro, questo è il
> tema giusto? su quello costruisco il tutto, angoli, dimensioni, geometrie
> tutte coerenti l'una con l'altra per dare solidità al tema del gioco»

## 2. Il metodo, un passo alla volta

1. **L'anima.** Prima una figura che raffiguri il concetto in astratto: il
   peccato è la mela. Non l'oggetto più ovvio (la spada per l'attacco), ma
   quello che ne porta il senso.
2. **Le domande.** Di cosa? Chi? La difesa: chi difende? Un eroe, un
   guardiano. L'attacco: attacco di cosa? Quello normale, quindi la figura è
   basica. La risposta decide anche **quanto** è complicata l'icona: la
   statistica di base ha la figura più semplice.
3. **I temi accostati.** Cosa ricorda? Il peccato è oscurità, e l'oscurità
   sono occhi cattivi. Il guardiano è protezione, quindi la croce
   ospedaliera. I tabù si evitano: la croce religiosa no.
4. **Il contorno.** Che contorno gli do? Le fiamme di Imu; il cerchio delle
   opere giapponesi (i kamon), fatto di fiamme.
5. **Come si disegna.** Deve essere bello: la mela tonda in prospettiva, gli
   occhi come se la testa fosse inclinata in giù (un atteggiamento, non un
   oggetto fermo), il cerchio interrotto in basso.
6. **Il tema del set.** Le forme compatibili fra loro: prima si decide se il
   tema è quello giusto, poi angoli, dimensioni e geometrie coerenti per
   tutte, così il set dà solidità al tema del gioco.
7. **Bru ci mette mano.** Io servo a snellire: proposte e varianti da cui
   partire, non il disegno finito.

Le misure (pienezza, centri, tagli, `docs/icone_da_disegnare.md`) vengono
**dopo**: servono a rifinire un'idea che regge, non a trovarla.

## 3. Dove sbagliavo

- **Partivo dalle misure.** Bru: «si potrebbe passare un esame di misure ma
  non di design». Le icone erano pesate e centrate, ma non dicevano
  abbastanza.
- **"Due figure in una" come formula.** Accostavo due oggetti (il cuore e il
  palloncino, la spada e la maschera) invece di cercare l'anima e farle delle
  domande.
- **Niente gerarchia.** Non chiedendo «attacco di cosa?», l'attacco normale
  aveva un disegno complicato quanto il Fattore, che è il critico.
- **Niente carattere.** Bru dà alla figura un'espressione e un atteggiamento
  (gli occhi cattivi, la testa inclinata); le mie erano oggetti fermi.
- **Il circo alla lettera.** La colombina, il palloncino della fiera: ma i
  Carnivalz «non sono veri tendoni: sono mondi in fiamme, realtà distorte da
  una fonte» (`docs/storia.md`).

## 4. L'Attacco, col metodo

**L'anima.** Attacco di cosa? Quello normale: il colpo che dai a ogni turno
(nei dati cresce con gli attacchi sferrati). Quindi la figura deve essere
basica: **il pugno**. Si vede poco come icona d'attacco (lì c'è sempre la
spada), e non ha bisogno di niente per essere capito.

**Le strade scartate, e perché:**

- *La spada*: banale, la si vede sempre.
- *Il colpo a stella* (l'urto dei fumetti): nei giochi è il critico, e il
  critico è il Fattore.
- *Il tirapugni con gli spuntoni*: disegnato, diventa una corona, e la corona
  è la Maestria.
- *Le quattro nocche astratte* (quattro cerchi in arco sopra un cuscinetto):
  diventano un'impronta di zampa.
- *Il segno della rabbia dei manga* accanto al pugno: a 26 pixel diventa una
  scintilla, e la scintilla è già del Fattore.
- *Il pugno alzato*: è un simbolo politico. Come la croce religiosa, meglio
  evitarlo: il pugno qui è girato verso chi guarda o di lato, mai alzato.

**Come si disegna.** Il pugno visto davanti, una sagoma sola con poche linee
in negativo: tre tagli fra le dita e il bordo del pollice. Le dita in cima
seguono un arco (la prospettiva da sotto: il medio è il più alto, il mignolo
il più basso), il pollice attraversa in basso e si piega dove finisce.

**Il contorno.** L'anello delle opere giapponesi, aperto in basso come ha
detto Bru: due cerchi, quello dentro sceso un poco, così l'anello è spesso in
cima e si assottiglia verso l'apertura. Per l'attacco il pugno può stare
dentro l'anello, oppure **sfondarlo**: l'anello si rompe dove passa il pugno.

Le miniature sono in `docs/schizzi/attacco/` (SVG da aprire e ridisegnare, e
due fogli PNG):

| | cosa |
|---|---|
| `A_pugno_dritto.svg` | il pugno, dritto come le icone approvate |
| `A1_pugno_inclinato.svg` | il pugno inclinato: il colpo che arriva |
| `B_pugno_nell_anello.svg` | il pugno nell'anello aperto in basso |
| `B1_pugno_che_sfonda.svg` | il pugno che sfonda l'anello |
| `miniature.png` | le quattro, grandi e a 26 pixel |
| `accanto_alle_approvate.png` | accanto a Difesa, Velocità e Intelligenza, come nella scheda |

## 5. La compatibilità con le approvate

Le tre approvate (Difesa, Velocità, Intelligenza) hanno in comune:

- sono **dritte e simmetriche**, viste di fronte;
- sono fatte di **rette, angoli a 45° e un cerchio o una lente**;
- hanno **un vuoto dentro** (lo scudo dentro lo scudo, l'occhio, lo spazio
  fra i due galloni): non sono macchie piene;
- nessuna ha un contorno intorno.

Il pugno, accanto a loro, è più **pieno** e più **morbido**. Per stare con le
altre gli servirebbe un vuoto in più (il pollice staccato del tutto, per
esempio) e angoli con gli stessi raggi dello scudo. L'anello, invece, è una
scelta di tutto il set: se l'Attacco ce l'ha e le altre no, l'Attacco sembra
di un'altra famiglia.

## 6. Le domande per Bru

1. **L'anello aperto in basso è il tema del set?** Se sì, lo prendono tutte
   (anche le approvate), ognuna a modo suo: il peccato con le fiamme,
   l'attacco che lo sfonda. Se no, resta il pugno da solo.
2. **Il pugno è l'anima giusta per l'attacco normale?** Oppure c'è un'altra
   figura basica che preferisci.
3. **Dritto o inclinato?** Dritto sta meglio con le approvate; inclinato ha
   l'atteggiamento del colpo.
