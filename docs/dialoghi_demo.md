# Tutti i dialoghi della demo

Istantanea generata dai file in `data/`. Ogni voce è nell'ordine in cui il giocatore la
incontra dentro il suo nodo. Legenda:

- **Nome:** «battuta» — un dialogo, con chi lo dice
- *corsivo* — narrazione (la voce che racconta da fuori, senza targhetta)
- `notifica` — il gioco che ti informa (hai raccolto, hai imparato)
- ▸ «testo» — l'etichetta di una scelta, cioè quello che il giocatore preme
- «Anonimo» è il protagonista: il nome vero lo sceglie il giocatore e viene sostituito a schermo

I titoletti `come_questo` sono gli id dei nodi: per cambiare un testo si cerca quell'id nel
file indicato e si modifica il campo `testo`.

---

## Introduzione

`data/events_intro.json`  ·  nodo iniziale: `monologo`

Il monologo che apre una partita nuova. Finita la sequenza il tutorial parte da solo.

### `monologo`

- **Anonimo:** «...»
- **Anonimo:** «... ...»
- **Anonimo:** «... ... ...»
- **Anonimo:** «Coordinate confermate, obiettivo localizzato, perimetro di azione calcolato...»
- **Anonimo:** «...»
- **Anonimo:** «Computer... lanciami il più possibile vicino alla fonte.»
- **Computer:** «Autorizzazione confermata. Buona fortuna unità 111»
- **Computer:** «lancio in...»  *(avanza da sola dopo 0.8s)*
- **Computer:** «3...»  *(avanza da sola dopo 0.9s)*
- **Computer:** «2...»  *(avanza da sola dopo 0.9s)*
- **Computer:** «1...»  *(avanza da sola dopo 0.9s)*
- **Computer:** «Per aspera, ad astra.»  *(avanza da sola dopo 1.1s)*
- **Anonimo:** «...»

---

## Tutorial — il pianeta dei goblin e il quartier generale

`data/events_tutorial.json`  ·  nodo iniziale: `inizio`

### `inizio`

- *In queste pianure il vento soffia gentile.<br>Piccole pozze d'acqua salutano il cielo con i loro riflessi mentre le foglie cambiano colore nel tempo...<br>Piccole creature primitive vivono spensierate in queste radure lontane, aspettando che quello stesso vento che soffia incessante li porti via...*
- `CARTA DEL TITOLO` — **Pianure di Redenna**
- **Anonimo:** «Dunque sarebbe questa la mia prima missione autonoma? Sembra un posto molto tranquillo, forse siamo in tempo per salvare queste pianure...»

**Tornandoci** ("Osserva la scena"):
- *Le pianure di Redenna si aprono davanti a te, tranquille come sembravano da lassù.*

**Scelte:**
  - ▸ «Fatti largo tra le pianure»  <sub>→ `primo_incontro`</sub>

### `primo_incontro`
<sub>il combattimento parte da solo</sub>

- *Tra le felci, qualcosa ti nota e si fa avanti, saltando fuori dal suo nascondiglio, ti aggredisce.*
- **Anonimo:** «Vediamo di finire presto: non ho tempo da perdere.»

### `dopo_primo_goblin`
<sub>alza `tut_primo_goblin`</sub>

- *Alcune creature sono malvage di natura, è tuo compito decidere il loro destino.*
- **Anonimo:** «Le creature qui sembrano molto deboli... Qualunque cosa stia causando questa anomalia non deve essere molto forte...»

**Scelte:**
  - ▸ «Continua per la tua strada»  <sub>→ `masso`</sub>

### `masso`

- *Il sentiero costeggia un masso coperto di muschio, accanto si trova un ruscello poco profondo. Sembra esserci qualcosa, nell'acqua bassa.*

**Scelte:**
  - ▸ «Ispeziona sotto il masso»  <sub>→ `due_nemici` · ottieni `fiala_hp`</sub>
  - ▸ «Prosegui senza fermarti»  <sub>→ `due_nemici`</sub>

### `due_nemici`
<sub>il combattimento parte da solo</sub>

- *Ti ritrovi in mezzo a una piccola radura fangosa. Le acque cristalline che emergono dai cumuli di fango umido creano un luccichio meraviglioso...*

### `bivio`
<sub>alza `tut_radura_superata`</sub>

- **Anonimo:** «Il sentiero sembra dividersi... ho un brutto presentimento... forse sarebbe meglio attraversare le pozze d'acqua.»
- *Il sentiero si dirama: da qui in poi conviene tenere d'occhio la mappa (bottone "Mappa"). Segna dove sei, e ti riporta nei posti che hai già visto senza doverli riattraversare a piedi.*

**Tornandoci** ("Osserva la scena"):
- *Il bivio: da una parte il sentiero scende verso le pozze d'acqua, dall'altra sale sulla collina. Più avanti, le urla.*

**Scelte:**
  - ▸ «Scendi verso le pozze d'acqua»  <sub>→ `pozze`</sub>
  - ▸ «Sali sulla collina»  <sub>→ `collina`</sub>
  - ▸ «Prosegui verso le urla»  <sub>se `tut_strada_aperta` — → `convergenza`</sub>

### `pozze`
<sub>il combattimento parte da solo</sub>

- **Anonimo:** «Un altro Goblin... e quella... cos'è? È enorme...»

### `pozze_ripulite`

- *Le pozze riflettono il cielo, immobili. Non è rimasto niente da affrontare, qui.*

**Scelte:**
  - ▸ «Prosegui verso le urla»  <sub>→ `convergenza`</sub>
  - ▸ «Torna al bivio»  <sub>→ `bivio`</sub>

### `dopo_pozze`
<sub>alza `tut_pozze_fatte`</sub>

- **Anonimo:** «Le pozze sono tranquille, ora. Da qui il sentiero risale verso le urla... ma posso ancora tornare indietro, se voglio dare un'occhiata alla collina.»

**Tornandoci** ("Osserva la scena"):
- *Le pozze riflettono il cielo, immobili. Da qui il sentiero risale verso le urla.*

**Scelte:**
  - ▸ «Prosegui verso le urla»  <sub>→ `convergenza`</sub>
  - ▸ «Apri la mappa»  <sub>→ mappa della zona</sub>

### `collina`
<sub>alza `tut_collina_vista`  ·  il combattimento parte da solo</sub>

- **Anonimo:** «Ho davvero un brutto presentimento...»
- *Senti un odore dolce... Una creatura appare dal nulla, avvolgendoti in un velo iridescente che ti ricorda l'abbraccio di una madre.*
- *La manifestazione ti osserva e ti accarezza. Hai un terribile presentimento...*

### `collina_ritorno`

- **Anonimo:** «Devo scoprire di più su quella creatura.»
- *Proprio al centro della collina la strana creatura volteggia, ignorando tutto il resto...*

**Tornandoci** ("Osserva la scena"):
- *In cima alla collina la creatura volteggia piano, senza badare a niente.*

**Scelte:**
  - ▸ «Combatti»  <sub>se NON `tut_collina_fatta` — COMBATTIMENTO: Manifestazione di un sogno</sub>
  - ▸ «Torna al bivio»  <sub>→ `bivio`</sub>

### `dopo_collina`
<sub>alza `tut_collina_fatta`</sub>

- **Anonimo:** «Non so cosa fosse... ma la collina è silenziosa, adesso.»

**Tornandoci** ("Osserva la scena"):
- *La collina è silenziosa. Non è rimasto niente, quassù.*

**Scelte:**
  - ▸ «Prosegui verso le urla»  <sub>→ `convergenza`</sub>
  - ▸ «Apri la mappa»  <sub>→ mappa della zona</sub>

### `convergenza`
<sub>alza `tut_strada_aperta`</sub>

- **Anonimo:** «Sembro essere vicino... sento delle urla incomprensibili...»

**Tornandoci** ("Osserva la scena"):
- *I due sentieri si ricongiungono qui. Le urla vengono da poco più avanti.*

**Scelte:**
  - ▸ «Scatta verso i rumori»  <sub>→ `boss`</sub>
  - ▸ «Apri la mappa»  <sub>→ mappa della zona</sub>

### `boss`
<sub>in scena: **Un goblin terribilmente arrabbiato** (al centro)  ·  il combattimento parte da solo</sub>

- *Al centro di una piccola arena di pietra e fango, un goblin terribilmente arrabbiato ti aspetta, i pugni già stretti.*
- **Un goblin terribilmente arrabbiato:** «?! ^?%&$!!»
- **Anonimo:** «Eccoti, facciamola finita.»
- **Un goblin terribilmente arrabbiato:** «Ah?! Ti carica a testa bassa!»

### `vittoria`

- *Dopo lo scontro, il vento si placa e l'atmosfera sembra essere meno tesa: i livelli di disallineamento sono normali.*
- **Anonimo:** «Sembra essere tutto finito...»
- *È ora di lasciare questo posto, altri compiti ti attendono.*

**Scelte:**
  - ▸ «Torna al quartier generale»  <sub>→ `hq_veronica_saluto`</sub>

### `sconfitta`

- *Mi risveglio fuori dalla spaccatura, la testa pesante. Anche un pianeta primitivo, a quanto pare, sa essere sorprendente.*

**Scelte:**
  - ▸ «Riprendi dall'ultimo salvataggio»

### `sconfitta_manifestazione`

- *Non ti risvegli. Non da questo sonno.*

**Scelte:**
  - ▸ «Riprendi dall'ultimo salvataggio»

### `hq_veronica_saluto`
<sub>in scena: **Veronica**</sub>

- **Veronica:** «Heilà, sei tornato! Com'è andata la tua prima missione da solo? Scommetto che l'hai completata al massimo della potenza!»
- **Anonimo:** «Ciao Veronica, la missione è andata come previsto. Alla fine non è stato affatto difficile.»
- **Veronica:** «Ha ha ha! Beh! Non c'era da aspettarsi di meno avendo un'allenatrice che ti spinge al massimo della potenza come me, giusto?»
- **Anonimo:** «A proposito, oggi abbiamo un altro incontro vero?»
- **Veronica:** «Puoi dirlo al massimo della potenza! Non ci andrò piano, come sempre. Ma prima dovresti passare in sala riunioni, sai come sono...»
- **Anonimo:** «Immaginavo. Allora non perdo altro tempo.»
- **Veronica:** «"Non perdo altro tempo"? Che cattivo. Come puoi trattare la tua amichetta di infanzia in questo modo?»
- **Veronica:** «Hey, mi stai ascoltando?»
- **Anonimo:** «Ci vediamo dopo per l'allenamento Veronica, grazie di tutto.»
- **Veronica:** «Che antipatico...»

**Scelte:**
  - ▸ «Vai in sala riunioni»  <sub>→ `hq_sala_riunioni_1`</sub>

### `hq_sala_riunioni_1`

- **Anonimo:** «Eccomi. Unità Pk09 a rapporto. Ho inoltrato il mio rapporto e le analisi fatte sul campo come sempre.»
- *Uno schermo oscurato si accende con un ronzio elettrico.*
- **??? (Organizzazione):** «Buongiorno unità Pk09, ci rallegriamo di ritrovarti operativo e in ottima salute. Proseguiamo a renderti grazie per i tuoi sforzi e ti confermiamo il successo dell'operazione.»
- **??? (Organizzazione):** «Vanno corretti alcuni errori grammaticali nelle pratiche, errore trascurabile, ma ci teniamo a fartelo presente. Per il resto hai già disponibile nel tuo diario gli eventi che vanno completati nell'arco della giornata.»
- **??? (Organizzazione):** «Le ricordiamo che il suo Diario è sempre consultabile: in cima vi troverà gli appunti sui luoghi dove deve recarsi e su ciò che le viene chiesto strada facendo, e sotto le sue statistiche, quali sue abitudini la stanno facendo crescere, le creature che ha studiato, i legami con la squadra e la nostra valutazione sul suo operato.»
- *Puoi aprire il Diario in qualunque momento premendo ESC: da lì passi anche allo storico di tutto quello che hai letto finora.*
- **??? (Organizzazione):** «Bene unità Pk09, la nostra attuale istanza si ritira per deliberare. Complimenti per il tuo recente successo, ci aspettiamo grandi cose da lei. Per aspera ad astra!»
- *Lo schermo si spegne con un ronzio elettrico.*
- **Anonimo:** «Bene, finalmente la parte noiosa è finita, odio le scartoffie... Dovrei vedermi con Veronica per il mio ultimo allenamento...»

**Scelte:**
  - ▸ «Vai ai campi di addestramento»  <sub>→ `hq_training_grounds`</sub>

### `hq_training_grounds`
<sub>in scena: **Veronica**</sub>

- **Veronica:** «Eccoti qui, al massimo della tua potenza spero. Sei pronto per un ultimo allenamento oltre ogni limite!?»
- **Anonimo:** «...»
- **Veronica:** «Cos'è quella faccia, non mi sembri esplodere di potenza...»
- **Anonimo:** «Scusami Veronica, sai come sono fatto, non sei mai cambiata da quando eravamo piccoli... sei sempre stata così... esplosiva...»
- **Veronica:** «Sempre! Che senso ha vivere se non lo si fa superando ogni limite immaginabile ogni giorno?»
- **Anonimo:** «Mi metti sempre di buon umore... Cominciamo...»
- **Veronica:** «Adesso le cose si fanno serie. Preparati.»

**Scelte:**
  - ▸ «Affronta l'allenamento»  <sub>→ `hq_scontro_veronica`</sub>

### `hq_scontro_veronica`
<sub>in scena: **Veronica** (al centro)  ·  il combattimento parte da solo</sub>

- *Veronica si mette in posizione. Questo non è un discorso: è un allenamento, e tocca a te muoverti.*

### `hq_infermeria`
<sub>in scena: **Dott.ssa Curie Heartlife**</sub>

- *Ti risvegli in infermeria.*
- **Dott.ssa Curie Heartlife:** «Ben svegliato, a pezzi come sempre vedo...»
- **Anonimo:** «Solito allenamento con Veronica...»
- **Dott.ssa Curie Heartlife:** «Se non fossi un dominatore di limiti saresti già morto, lo sai?»
- **Anonimo:** «...»
- **Anonimo:** «Non ho mai capito perché io e Veronica abbiamo questa... fortuna?»
- **Dott.ssa Curie Heartlife:** «Beh dovresti saperlo... solo individui con una forte forza di volontà e una fortunata costituzione diventano dominatori... Non è una fortuna, è un destino.»
- **Anonimo:** «Anche lei è una dominatrice se non sbaglio...»
- **Dott.ssa Curie Heartlife:** «Sì, ma non tutti i dominatori sono fatti per il combattimento: io sono specializzata nelle cure e nella conoscenza. Non mi sognerei mai di andarmene a zonzo per l'universo a... beh... lo sai... io non sono molto a favore della violenza...»
- **Anonimo:** «Qualcuno purtroppo deve farlo... E per fortuna ci sono persone come voi a darci una mano...»
- **Dott.ssa Curie Heartlife:** «Apprezzo le tue lodi... Ah! Dimenticavo, devi recarti nella sala riunioni: ti hanno affidato un bell'incarico, spero di non rivederti presto da queste parti <3»
- **Anonimo:** «Un bell'incarico... Questo vuol dire che ci rivedremo invece...»
- **Dott.ssa Curie Heartlife:** «È inevitabile...»

**Scelte:**
  - ▸ «Vai in sala riunioni»  <sub>→ `hq_sala_riunioni_2`</sub>

### `hq_sala_riunioni_2`
<sub>alza `tutorial_completato`</sub>

- **??? (Organizzazione):** «Salve unità Pk09, abbiamo analizzato i suoi dati, e siamo sicuri, oltre una certa soglia, che lei sia un candidato affidabile e adatto a farsi carico di alcune questioni abbastanza importanti...»
- **??? (Organizzazione):** «Come ben sa, il numero di dominatori è calato drasticamente di questi tempi e sempre più mondi e realtà vengono compromessi a causa delle anomalie che stiamo studiando...»
- **??? (Organizzazione):** «Non vogliamo compromettere la sua salute e la sua integrità, ma allo stesso tempo abbiamo bisogno che lei affini le sue abilità con alcuni casi di minore entità.»
- **??? (Organizzazione):** «Abbiamo aggiornato nelle sue planimetrie i luoghi d'interesse dove ci sarebbe bisogno di effettuare dei rilevamenti importanti, così come un punto anomalo dove i livelli di allineamento sono fuori controllo ma non in modo preoccupante: siamo sicuri che saprà gestire la situazione. Ha qualcosa da riferire?»
- **Anonimo:** «No, non mi piace perdere tempo, mi dirigo subito verso i luoghi d'interesse...»
- **??? (Organizzazione):** «Ottimo, sapevamo di poter contare su di lei, unità Pk09. Per aspera ad astra!»

**Scelte:**
  - ▸ «Torna alla mappa stellare»  <sub>→ fine campagna</sub>

---

# Il Vuoto Ardente — gli squarci

## Lo Squarcio Industriale

`data/vuoti/squarcio_industriale.json`  ·  nodo iniziale: `varco`

### `varco`

- *Lo squarcio si richiude alle tue spalle con un sospiro di vapore. Davanti: un complesso industriale gigantesco, macchine alte come palazzi, ruggine e sudore. Fa un caldo pazzesco. In lontananza, voci registrate parlano a nessuno.*

**Scelte:**
  - ▸ «Avanza nel corridoio dei tubi»  <sub>→ `corridoio_tubi`</sub>
  - ▸ «Torna nel Vuoto»  <sub>→ esci dallo squarcio</sub>

### `corridoio_tubi`

- *Tubi e valvole in ogni direzione, alcuni ancora caldi. Da qualche parte un programma si accende, borbotta qualcosa, si rispegne. Sembra tutto morto. Sembra.*

**Scelte:**
  - ▸ «Fruga in un armadietto arrugginito»  <sub>→ `corridoio_tubi` · ottieni `viti_e_bulloni`</sub>
  - ▸ «Verso la sala delle valvole»  <sub>→ `sala_valvole`</sub>
  - ▸ «Entra nel deposito»  <sub>→ `deposito`</sub>
  - ▸ «Torna al varco»  <sub>→ `varco`</sub>

### `deposito`

- *Scaffali piegati dal caldo, casse sventrate. Qualcuno ha vissuto qui, tra un turno e l'altro, per molto tempo.*

**Scelte:**
  - ▸ «Fruga nella cassa marchiata con una croce»  <sub>→ `deposito` · ottieni `fiala_hp`</sub>
  - ▸ «Svuota il barattolo di minuteria»  <sub>→ `deposito` · ottieni `viti_e_bulloni`</sub>
  - ▸ «Solleva la mattonella smossa»  <sub>→ `deposito`</sub>
  - ▸ «Svita una piastra di rivestimento»  <sub>→ `deposito` · ottieni `viti_e_bulloni`</sub>
  - ▸ «Torna nel corridoio»  <sub>→ `corridoio_tubi`</sub>

### `sala_valvole`

- *Una sala di valvole grandi come ruote di carro. Il metallo geme. Ogni tanto, dalle macerie, qualcosa si muove.*

**Scelte:**
  - ▸ «Recupera i bulloni caduti da una valvola»  <sub>→ `sala_valvole` · ottieni `viti_e_bulloni`</sub>
  - ▸ «Sali verso le schede madri giganti»  <sub>→ `sala_schede`</sub>
  - ▸ «Segui il nastro trasportatore»  <sub>→ `nastro`</sub>
  - ▸ «Torna nel corridoio»  <sub>→ `corridoio_tubi`</sub>

### `sala_schede`

- *Schede madri grandi come pareti, piste di rame come strade viste dall'alto. Una voce registrata ripete un annuncio di cui non esiste più il pubblico.*

**Scelte:**
  - ▸ «Stacca il componente che lampeggia verso l'alto»  <sub>→ `sala_schede` · ottieni `componente_elettronico`</sub>
  - ▸ «Recupera la fiala incastrata tra i condensatori»  <sub>→ `sala_schede` · ottieni `fiala_hp`</sub>
  - ▸ «Scendi al vecchio centro di controllo»  <sub>→ `centro_controllo`</sub>
  - ▸ «Torna alle valvole»  <sub>→ `sala_valvole`</sub>

### `centro_controllo`

- *Il vecchio centro di controllo: una fila di monitor spenti rivolti verso un'unica poltrona, ancora al centro della stanza. Sulla scrivania, diari rilegati a mano, pieni della stessa calligrafia nervosa.*

**Scelte:**
  - ▸ «Leggi il primo diario»  <sub>→ `diario_1`</sub>
  - ▸ «Leggi il secondo diario»  <sub>→ `diario_2`</sub>
  - ▸ «Leggi il terzo diario»  <sub>→ `diario_3`</sub>
  - ▸ «Apri il cassetto della scrivania»  <sub>→ `centro_controllo`</sub>
  - ▸ «Torna alle schede madri»  <sub>→ `sala_schede`</sub>

### `diario_1`

- *"Giorno 1. Il complesso è operativo. Ho detto ai capisquadra che voglio efficienza, non lamentele. Kizako."*

**Scelte:**
  - ▸ «Richiudi il diario»  <sub>→ `centro_controllo`</sub>

### `diario_2`

- *"Giorno 340 circa (ho perso il conto). Tre operai non si sono presentati oggi. Il caporeparto dice che 'vedono cose'. Ho ordinato di aumentare i turni ai restanti, per compensare. Non possiamo permetterci ritardi sulle consegne belliche. Kizako."*

**Scelte:**
  - ▸ «Richiudi il diario»  <sub>→ `centro_controllo`</sub>

### `diario_3`

- *"Ultimo giorno che scrivo qui. Il reparto montaggio non risponde più al citofono. Ho mandato una squadra a controllare: non è tornata nessuno. Non chiuderò l'impianto. Sposterò la produzione altrove. Questo posto, ormai, può tenersi quello che si è preso. Kizako."*

**Scelte:**
  - ▸ «Richiudi il diario»  <sub>→ `centro_controllo`</sub>

### `nastro`

- *Il nastro trasportatore corre ancora, a vuoto, trasportando niente da nessuna parte. Il caldo qui toglie il respiro.*

**Scelte:**
  - ▸ «Prendi la tanica di benzina sotto il rullo»  <sub>→ `nastro` · ottieni `benzina`</sub>
  - ▸ «Raccogli la bottiglia con lo straccio nel collo»  <sub>→ `nastro` · ottieni `molotov`</sub>
  - ▸ «Segui il nastro fino al cuore del complesso»  <sub>→ `cuore`</sub>
  - ▸ «Torna alle valvole»  <sub>→ `sala_valvole`</sub>

### `cuore`
<sub>alza `industriale_esplorato`</sub>

- *Il cuore del complesso: una turbina ferma, grande come una piazza. Sulle pale, qualcuno ha inciso dei nomi. Un'insegna sbiadita, ancora leggibile: KIZAKO INDUSTRIES. La voce registrata qui è più chiara: sta contando i pezzi prodotti, all'infinito.*

**Scelte:**
  - ▸ «Apri la cassetta degli incassi»  <sub>→ `cuore`</sub>
  - ▸ «Cerca tra le pale della turbina»  <sub>→ `cuore` · ottieni `fiala_hp`</sub>
  - ▸ «Esci nel piazzale della discarica»  <sub>→ `discarica`</sub>
  - ▸ «Torna al nastro»  <sub>→ `nastro`</sub>

### `discarica`

- *Un piazzale a cielo aperto, montagne di rottami più alte di una casa. Il sole rosso ci batte sopra senza pietà. Sotto le macerie, ogni tanto, qualcosa si sposta da sola.*

**Scelte:**
  - ▸ «Rovista tra i rottami più vicini»  <sub>→ `discarica` · ottieni `rottame_di_metallo`</sub>
  - ▸ «Scava sotto una montagna di lamiere»  <sub>→ `discarica` · ottieni `rottame_di_metallo`</sub>
  - ▸ «Controlla un container ribaltato»  <sub>→ `discarica`</sub>
  - ▸ «Va' verso la struttura tonda in fondo al piazzale»  <sub>→ `padiglione_e`</sub>
  - ▸ «Torna al cuore del complesso»  <sub>→ `cuore`</sub>

### `padiglione_e`

- *Il Padiglione E: una struttura tonda enorme, come un silo rovesciato, molto più grande di tutto il resto del complesso. Un unico portello sul fondo, sigillato, con una scritta ormai illeggibile sopra. Da sotto, un rombo bassissimo, quasi impercettibile, che non si ferma mai.*

**Scelte:**
  - ▸ «Prova a forzare il portello»  <sub>→ `padiglione_e_chiuso`</sub>
  - ▸ «Torna alla discarica»  <sub>→ `discarica`</sub>

### `padiglione_e_chiuso`

- *Non si muove di un millimetro: qualunque cosa lo tenga chiuso, non è fatta per cedere a mani nude. Qualunque cosa ci sia sotto, dovrà aspettare.*

**Scelte:**
  - ▸ «Torna al Padiglione E»  <sub>→ `padiglione_e`</sub>

### `espulso`

- *Le macerie ti si chiudono addosso e lo squarcio ti sputa fuori, nel Vuoto. Il complesso continua a scaldare il nulla.*

**Scelte:**
  - ▸ «Riprendi fiato nel Vuoto»  <sub>→ esci dallo squarcio</sub>

---

## Meridia

`data/vuoti/meridia.json`  ·  nodo iniziale: `varco`

### `varco`

- *Lo squarcio si apre su una città che non è la tua: insegne spente, auto abbandonate in mezzo alla strada, portiere aperte come se chi guidava fosse sceso di corsa e non fosse più tornato. Un cartello arrugginito dice ancora, a metà: MERIDIA — BENVEN... Il resto è caduto.*

**Scelte:**
  - ▸ «Avanza per la strada principale»  <sub>→ `strada_principale`</sub>
  - ▸ «Torna nel Vuoto»  <sub>→ esci dallo squarcio</sub>

### `strada_principale`

- *La strada principale di Meridia è un cimitero di vetrine rotte. Ogni tanto, tra le macerie, qualcosa si muove piano — o troppo in fretta.*

**Scelte:**
  - ▸ «Entra nel supermercato saccheggiato»  <sub>→ `supermercato`</sub>
  - ▸ «Entra nell'officina abbandonata»  <sub>→ `officina`</sub>
  - ▸ «Vai verso l'edicola»  <sub>→ `edicola`</sub>
  - ▸ «Torna al varco»  <sub>→ `varco`</sub>

### `supermercato`

- *Scaffali rovesciati, carrelli abbandonati a metà corsia. Qualcuno ha fatto scorte, prima della fine. Non è bastato.*

**Scelte:**
  - ▸ «Fruga tra gli scaffali caduti»  <sub>→ `supermercato` · ottieni `bastone`</sub>
  - ▸ «Svuota una cassa ancora chiusa»  <sub>→ `supermercato`</sub>
  - ▸ «Torna alla strada»  <sub>→ `strada_principale`</sub>

### `officina`

- *Un'officina meccanica, attrezzi sparsi ovunque. Un furgone è ancora sollevato sul ponte, come se il lavoro dovesse riprendere da un momento all'altro.*

**Scelte:**
  - ▸ «Recupera la spranga di ferro sul banco»  <sub>→ `officina` · ottieni `spranga_di_ferro`</sub>
  - ▸ «Forza l'armadietto degli attrezzi»  <sub>serve abilità `scasso` — → `officina` · ottieni `motosega`</sub>
  - ▸ «Torna alla strada»  <sub>→ `strada_principale`</sub>

### `edicola`

- *Un'edicola con la saracinesca a metà. Dentro, pile di giornali ingialliti, l'ultima consegna mai ritirata da nessuno.*

**Scelte:**
  - ▸ «Leggi la prima pagina rimasta»  <sub>→ `edicola` · ottieni `pagina_di_giornale_1`</sub>
  - ▸ «Leggi la seconda pagina rimasta»  <sub>→ `edicola` · ottieni `pagina_di_giornale_2`</sub>
  - ▸ «Leggi l'ultima edizione mai stampata»  <sub>→ `edicola` · ottieni `pagina_di_giornale_3`</sub>
  - ▸ «Vai verso il vicolo sul retro»  <sub>→ `vicolo`</sub>
  - ▸ «Torna alla strada»  <sub>→ `strada_principale`</sub>

### `vicolo`

- *Un vicolo stretto dietro l'edicola, cassonetti rovesciati, una scala antincendio che sale verso il nulla. L'aria qui è ancora più ferma.*

**Scelte:**
  - ▸ «Raccogli il mazzafrusto improvvisato»  <sub>→ `vicolo` · ottieni `mazzafrusto`</sub>
  - ▸ «Recupera lo sparachiodi caduto tra i cassonetti»  <sub>→ `vicolo` · ottieni `sparachiodi_arrugginito`</sub>
  - ▸ «Scendi verso i quartieri profondi»  <sub>→ `quartieri_profondi`</sub>
  - ▸ «Torna all'edicola»  <sub>→ `edicola`</sub>

### `quartieri_profondi`
<sub>alza `meridia_esplorata`</sub>

- *Più a fondo la città cambia: i palazzi si stringono, la luce non arriva più e il silenzio ha un peso diverso. Qui non si muove niente finché non decide di muoversi tutto insieme.*

**Scelte:**
  - ▸ «Continua a battere i quartieri profondi»  <sub>→ `quartieri_profondi`</sub>
  - ▸ «Torna al vicolo»  <sub>→ `vicolo`</sub>

### `espulso`

- *Le mani marce ti si chiudono attorno per un istante, poi lo squarcio ti strappa via, di nuovo nel Vuoto. Meridia resta lì, silenziosa e piena.*

**Scelte:**
  - ▸ «Riprendi fiato nel Vuoto»  <sub>→ esci dallo squarcio</sub>

---

## Cunicoli sotterranei di Jondoh

`data/vuoti/rocca_ossidiana.json`  ·  nodo iniziale: `varco`

### `varco`

- *In un angolo remoto, lontano dalle luci più calde e raggiunto solo da freddi e gelidi venti, lunghi cunicoli sono stati scavati nella fredda e dura ossidiana che ricopre questo sfortunato luogo.<br>"Stai lontano dai cunicoli", si diceva agli sfortunati esploratori che recuperavano il prezioso minerale da questo mondo primitivo. Quello che si cela sottoterra è un mondo che è meglio resti dimenticato...<br>Jondoh è il nome di questo pianeta, abbandonato da ogni luce, che ora ribolle e cerca disperatamente una nuova vita... Cosa si cela in fondo ai cunicoli di questo inferno nero?*
- `CARTA DEL TITOLO` — **Cunicoli sotterranei di Jondoh**
- **Anonimo:** «Questo posto... il solo respirare quest'aria mi rende profondamente triste... cosa sta succedendo in questo posto?»

**Tornandoci** ("Osserva la scena"):
- *Il varco resta aperto alle tue spalle, un taglio di luce fredda sulla parete nera. Davanti, il corridoio scende.*

**Scelte:**
  - ▸ «Scendi nel corridoio di ossidiana»  <sub>→ `corridoio_ossidiana`</sub>
  - ▸ «Torna nel Vuoto»  <sub>→ esci dallo squarcio</sub>

### `corridoio_ossidiana`

- *Il corridoio scende, tagliato nella roccia nera. Ai lati, nicchie scavate a mano, segni di graffi e un odore ferroso misto a qualcosa di dolce contraddistinguono questi cunicoli: una leggera polvere grigia, come un fondo sabbioso, ricopre il terreno su cui cammini. Il raschiare si fa più vicino: intorno a te, vari buchi dai quali provengono suoni di graffi e grugniti indistinguibili grondano una sostanza nera che si solidifica a contatto con l'aria.*

**Scelte:**
  - ▸ «Scendi nella fossa oscura»  <sub>→ `fossa_oscura`</sub>
  - ▸ «Entra nella sala del raccolto»  <sub>→ `sala_del_raccolto`</sub>
  - ▸ «Torna al varco»  <sub>→ `varco`</sub>

### `fossa_oscura`

- *Una fossa oscura dove piccole pietre illuminano quel poco che è visibile. Qualcosa si muove nel buio: non sai se sia ostile o meno, e lo stress sale preoccupantemente. In alto, incastrato tra due sporgenze di ossidiana, qualcosa luccica ancora.*

**Scelte:**
  - ▸ «Fruga nel buio»  <sub>→ `fossa_oscura`</sub>
  - ▸ «Procedi verso il fondo»  <sub>→ `fondo_del_fosso`</sub>
  - ▸ «Torna al corridoio»  <sub>→ `corridoio_ossidiana`</sub>

### `fondo_del_fosso`

- *Non sembra esserci altro. Senti qualcosa sballottato fra i tuoi piedi: uno zaino, di qualcuno più sfortunato di te...*

**Scelte:**
  - ▸ «Recupera ciò che trovi»  <sub>→ `fossa_oscura` · ottieni `fiala_hp`</sub>
  - ▸ «Torna alla fossa»  <sub>→ `fossa_oscura`</sub>

### `sala_del_raccolto`

- *Cos'è questo posto... c'è una puzza tremenda... quelli... sono cadaveri. Il modo in cui sono stati disposti e ridotti ti fa riflettere: ci sono dei sacchi cuciti in modo primitivo, sparsi in giro.*

**Scelte:**
  - ▸ «Fruga tra i sacchi marci»  <sub>→ `sala_del_raccolto`</sub>
  - ▸ «Recupera una fiala intatta tra le macerie»  <sub>→ `sala_del_raccolto` · ottieni `fiala_hp`</sub>
  - ▸ «Scendi verso la sala del lamento»  <sub>→ `sala_del_lamento`</sub>
  - ▸ «Torna al corridoio»  <sub>→ `corridoio_ossidiana`</sub>

### `sala_del_lamento`

- **Anonimo:** «...ma cosa è successo in questo posto?!»
- **Anonimo:** «Dall'alto, un essere scappa verso uno dei cunicoli: era enorme, e mi stava osservando... Sarà meglio sbrigarmi a estinguere la fonte di questa follia...»
- *Per terra trovi delle pergamene incomprensibili...*

**Tornandoci** ("Osserva la scena"):
- *La sala del lamento: pareti coperte di graffi fino a dove arriva il braccio di un uomo, e un'eco che non si decide a spegnersi.*

**Scelte:**
  - ▸ «Raccogli le pergamene»  <sub>se NON `oss_lamento_superato` — → `lamento_imboscata` · ottieni `pergamene_incomprensibili`</sub>
  - ▸ «Raccogli le pergamene»  <sub>se `oss_lamento_superato` — → `sala_del_lamento` · ottieni `pergamene_incomprensibili`</sub>
  - ▸ «Affronta ciò che urla nel buio»  <sub>se NON `oss_lamento_superato` — → `lamento_imboscata`</sub>
  - ▸ «Prosegui»  <sub>se `oss_lamento_superato` — → `dopo_lamento`</sub>
  - ▸ «Torna alla sala del raccolto»  <sub>se NON `oss_lamento_superato` — → `sala_del_raccolto`</sub>

### `lamento_imboscata`
<sub>il combattimento parte da solo</sub>

- *Una figura oscura ti travolge dal buio!*
- **Anonimo:** «!!!»

### `dopo_lamento`
<sub>alza `oss_lamento_superato`</sub>

- *Qualcosa, dentro di te, si fissa in questo punto. Non tornerai indietro da qui.*

**Scelte:**
  - ▸ «Prendi il ciondolo strappato al sacerdote»  <sub>→ `dopo_lamento` · ottieni `ciondolo_del_grande_viaggio`</sub>
  - ▸ «Prosegui più a fondo nei cunicoli»  <sub>→ `cunicolo_1`</sub>
  - ▸ «Prendi i cunicoli di destra, verso il ponte»  <sub>→ `ponte_approccio`</sub>

### `cunicolo_1`

- *Questi cunicoli sembrano non avere fine. Da qui la roccia si biforca in due direzioni diverse.*

**Scelte:**
  - ▸ «Vai a sinistra»  <sub>→ `cunicolo_2`</sub>
  - ▸ «Vai a destra»  <sub>→ `cunicolo_3`</sub>
  - ▸ «Torna alla mappa»  <sub>→ mappa della zona</sub>

### `cunicolo_2`

- *Il cunicolo di sinistra scende ancora, ma in fondo si intravede un bagliore instabile, come di torce accese da qualcun altro.*

**Scelte:**
  - ▸ «Prosegui verso il bagliore»  <sub>→ `piazza_sotterranea`</sub>
  - ▸ «Torna al bivio»  <sub>→ `cunicolo_1`</sub>
  - ▸ «Torna alla mappa»  <sub>→ mappa della zona</sub>

### `cunicolo_3`

- *Il cunicolo di destra sale, e un filo di vento gelido comincia a farsi sentire: da qualche parte, più avanti, c'è una via verso la superficie.*

**Scelte:**
  - ▸ «Sali verso la superficie»  <sub>→ `cargo_abbandonato`</sub>
  - ▸ «Torna al bivio»  <sub>→ `cunicolo_1`</sub>
  - ▸ «Torna alla mappa»  <sub>→ mappa della zona</sub>

### `piazza_sotterranea`
<sub>in scena: **Yara** (al centro)  ·  alza `oss_yara_conosciuta`</sub>

- *Nella piazza sotterranea trovi qualcuno di vivo, finalmente. Ti osserva a lungo, immobile, prima di abbassare la guardia.*
- **Yara:** «Non ne arrivano molti fin qui. Ancora meno ne escono.»
- **Yara:** «Jondoh è un pianeta minerario. Chi ci lavora non è nativo: sono schiavi, portati qui da altri mondi.»
- **Yara:** «Respirare le polveri, toccare la sostanza nera... li fa mutare. Regrediscono, e sviluppano una malvagità che prima non avevano.»
- **Yara:** «Per anni il problema è stato ignorato. Gli schiavi continuavano ad arrivare, i cunicoli continuavano a scavarsi.»
- **Yara:** «Poi sono cominciate le sparizioni. La prima fu mia sorella minore. La più piccola di tutti noi.»
- **Yara:** «Da quel giorno sono passati anni, e molti altri sono scomparsi in questi cunicoli.»
- **Yara:** «Il lavoro si è spostato tutto in superficie: i cunicoli erano considerati troppo pericolosi.»
- **Yara:** «Finché uno schiavo fu attaccato da un ghoul, in superficie. Il ghoul morì poco dopo: riescono a vivere solo qui sotto.»
- **Yara:** «Da allora qualcosa è cambiato. Sempre più persone sparite, attacchi sempre più frequenti.»
- **Yara:** «Ho passato anni a combattere queste cose. Non avrò pace finché non saprò la verità fino in fondo.»

**Scelte:**
  - ▸ «Chiedile di unirsi a te»  <sub>→ `yara_si_unisce` · recluta `sopravvissuta`</sub>
  - ▸ «Torna al cunicolo»  <sub>→ `cunicolo_2`</sub>
  - ▸ «Torna alla mappa»  <sub>→ mappa della zona</sub>

### `piazza_ritorno`
<sub>in scena: **Yara** (al centro)</sub>

- **Yara:** «Hey... ciao di nuovo...»

**Tornandoci** ("Osserva la scena"):
- *Yara è dove l'hai lasciata: la schiena contro la roccia, gli occhi puntati sulla galleria da cui sei arrivato.*

**Scelte:**
  - ▸ «Chiedile di unirsi a te»  <sub>→ `yara_si_unisce` · recluta `sopravvissuta`</sub>
  - ▸ «Torna al cunicolo»  <sub>→ `cunicolo_2`</sub>
  - ▸ «Torna alla mappa»  <sub>→ mappa della zona</sub>

### `piazza_con_yara`

- *C'è qualcosa di brillante per terra.*

**Tornandoci** ("Osserva la scena"):
- *La piazza è vuota, adesso: le torce consumate fino alla base, e il silenzio che si richiude ogni volta che smetti di parlare.*

**Scelte:**
  - ▸ «Raccogli l'oggetto brillante»  <sub>→ `piazza_con_yara` · ottieni `bomba_artigianale`</sub>
  - ▸ «Torna al cunicolo»  <sub>→ `cunicolo_2`</sub>
  - ▸ «Torna alla mappa»  <sub>→ mappa della zona</sub>

### `yara_si_unisce`
<sub>in scena: **Yara** (al centro)</sub>

- **Yara:** «Va bene. Non perché mi fidi di te: perché da sola non ci sono mai arrivata.»
- **Yara:** «Vado avanti io quando serve. Tu bada a non morire.»

**Tornandoci** ("Osserva la scena"):
- *Yara ti aspetta, già rivolta verso l'uscita della piazza.*

**Scelte:**
  - ▸ «Torna al cunicolo»  <sub>→ `cunicolo_2`</sub>
  - ▸ «Apri la mappa»  <sub>→ mappa della zona</sub>

### `cargo_abbandonato`

- *All'aperto trovi un cargo abbandonato, arrugginito, mezzo sepolto nella sabbia nera. All'interno, casse sfondate e provviste dimenticate da chissà quanto tempo.*

**Scelte:**
  - ▸ «Fruga tra le casse»  <sub>→ `cargo_abbandonato`</sub>
  - ▸ «Recupera una fiala»  <sub>→ `cargo_abbandonato` · ottieni `fiala_hp`</sub>
  - ▸ «Recupera un'altra fiala»  <sub>→ `cargo_abbandonato` · ottieni `fiala_hp`</sub>
  - ▸ «Recupera l'infuso antico»  <sub>→ `cargo_abbandonato` · ottieni `infuso_antico`</sub>
  - ▸ «Recupera il gel omega»  <sub>→ `cargo_abbandonato` · ottieni `omega_gel`</sub>
  - ▸ «Torna al cunicolo»  <sub>→ `cunicolo_3`</sub>
  - ▸ «Torna alla mappa»  <sub>→ mappa della zona</sub>

### `ponte_approccio`

- *Il cunicolo si apre su un grande ponte marcio, teso su un baratro che la luce non riesce a raggiungere. Oltre il ponte, il passaggio prosegue verso il basso.*

**Scelte:**
  - ▸ «Attraversa il grande ponte marcio»  <sub>se `oss_compagna_reclutata` — → `ponte_meta_compagna`</sub>
  - ▸ «Attraversa il grande ponte marcio»  <sub>se NON `oss_compagna_reclutata` — → `ponte_meta_solo`</sub>
  - ▸ «Torna alla mappa»  <sub>→ mappa della zona</sub>

### `ponte_meta_compagna`
<sub>in scena: **Yara** (al centro)</sub>

- **Yara:** «Stai attento: non sono mai riuscita ad attraversare questo ponte. Una creatura orribile vive nella parte inferiore. L'ho vista una sola volta, e mi è bastato...»

**Tornandoci** ("Osserva la scena"):
- *Le assi del ponte scricchiolano già sotto il primo passo. Sotto, solo buio.*

**Scelte:**
  - ▸ «Prosegui»  <sub>→ `ponte_centro`</sub>

### `ponte_meta_solo`

- **Anonimo:** «...i ponti non mi sono mai piaciuti...»

**Tornandoci** ("Osserva la scena"):
- *Le assi del ponte scricchiolano già sotto il primo passo. Sotto, solo buio.*

**Scelte:**
  - ▸ «Prosegui»  <sub>→ `ponte_centro`</sub>

### `ponte_centro`

- *Senti qualcosa muoversi sotto di te...*

**Scelte:**
  - ▸ «Prosegui?»  <sub>→ `ponte_quasi_fine`</sub>
  - ▸ «Torna indietro»  <sub>→ `ponte_approccio`</sub>

### `ponte_quasi_fine`

- *Sembra tutto ok: ormai sei a metà del ponte...*

**Scelte:**
  - ▸ «Prosegui?»  <sub>→ `ponte_attacco`</sub>

### `ponte_attacco`

- *Qualcosa sta salendo da sotto il ponte...*
- **Anonimo:** «Ecco cos'era questa puzza.»

**Scelte:**
  - ▸ «Reagisci»  <sub>se `oss_compagna_reclutata` — → `ponte_attacco_compagna`</sub>
  - ▸ «Reagisci»  <sub>se NON `oss_compagna_reclutata` — COMBATTIMENTO: Divoratore di Carcasse</sub>

### `ponte_attacco_compagna`
<sub>in scena: **Yara** (al centro)  ·  il combattimento parte da solo</sub>

- **Yara:** «Eccolo. È proprio quella creatura schifosa!»

### `oltre_ponte`

- *Attraversato il ponte, volgi lo sguardo all'indietro: altri vermi risalgono e divorano la carcassa di quello che hai appena ucciso... Ce n'era più di uno.*

**Scelte:**
  - ▸ «Continua»  <sub>se `oss_compagna_reclutata` — → `oltre_ponte_gratitudine`</sub>
  - ▸ «Entra nella cripta»  <sub>se NON `oss_compagna_reclutata` — → `cripta_senza_compagna`</sub>

### `oltre_ponte_gratitudine`
<sub>in scena: **Yara** (al centro)</sub>

- **Yara:** «Non ce l'avrei mai fatta da sola... Grazie per avermi fatto venire con te.»

**Tornandoci** ("Osserva la scena"):
- *Dall'altra parte del ponte l'aria è ancora più densa. Yara non guarda più indietro.*

**Scelte:**
  - ▸ «Entra nella cripta»  <sub>→ `cripta_con_compagna`</sub>

### `cripta_senza_compagna`

- *Si narra di esseri nati dal bitume più nero, che vivono negli incubi delle persone.<br>Esseri abietti che non hanno mai conosciuto la grazia di un tocco gentile.<br>Non conoscono pietà o rimorso, schiavi perfetti di un oscuro potere che tutto fa marcire.<br>In fondo, chi avrebbe mai fatto qualcosa per loro?<br>Benvenuto, nelle profondità marcite di Jondoh, possa la terra perdonare chi l'ha calpestata senza rispetto.*
- **Anonimo:** «C'è qualcuno che cammina...»
- **???:** «Nnnnghhh.... Yaaaargh...»
- **Anonimo:** «La situazione è chiara...»

**Tornandoci** ("Osserva la scena"):
- *La cripta è una galleria bassa di ossidiana lucida. Qualcosa continua a camminarci dentro, senza arrivare da nessuna parte.*

**Scelte:**
  - ▸ «Affronta l'abominio»  <sub>se NON `oss_cripta_superata` — COMBATTIMENTO: ???</sub>
  - ▸ «Intuisci il momento giusto e scivola oltre, nell'ombra»  <sub>serve abilità `sesto_senso` — → `altare_dei_sacrifici`</sub>
  - ▸ «Scendi verso l'altare»  <sub>se `oss_cripta_superata` — → `altare_dei_sacrifici`</sub>

### `cripta_con_compagna`
<sub>in scena: **Yara** (al centro)</sub>

- *Si narra di esseri nati dal bitume più nero, che vivono negli incubi delle persone.<br>Esseri abietti che non hanno mai conosciuto la grazia di un tocco gentile.<br>Non conoscono pietà o rimorso, schiavi perfetti di un oscuro potere che tutto fa marcire.<br>In fondo, chi avrebbe mai fatto qualcosa per loro?<br>Benvenuto, nelle profondità marcite di Jondoh, possa la terra perdonare chi l'ha calpestata senza rispetto.*
- **Anonimo:** «C'è qualcuno che cammina...»
- **Yara:** «Non sembra essere qualcuno, ma qualcosa...»
- **???:** «Nnnnghhh.... Yaaaargh...»
- **Anonimo:** «La situazione è chiara...»

**Tornandoci** ("Osserva la scena"):
- *La cripta è una galleria bassa di ossidiana lucida. Qualcosa continua a camminarci dentro, senza arrivare da nessuna parte.*

**Scelte:**
  - ▸ «Affronta l'abominio»  <sub>se NON `oss_cripta_superata` — COMBATTIMENTO: ???</sub>
  - ▸ «Intuisci il momento giusto e scivola oltre, nell'ombra»  <sub>serve abilità `sesto_senso` — → `altare_dei_sacrifici`</sub>
  - ▸ «Scendi verso l'altare»  <sub>se `oss_cripta_superata` — → `altare_dei_sacrifici`</sub>

### `sconfitta_immortale`

- *Non riesci a scrollartelo di dosso in tempo. Il buio, alla fine, non ha nemmeno bisogno di uccidere: basta che resti lì, finché non resta più nulla da opporgli.*

**Scelte:**
  - ▸ «Riprendi dall'ultimo salvataggio»

### `altare_dei_sacrifici`
<sub>alza `oss_cripta_superata`</sub>

- *Un altare scavato nella pietra nera: candele consumate fino alla base, cera colata sopra cera, e una scalinata che scende ancora, verso una luce rossastra.*

**Scelte:**
  - ▸ «Continua»  <sub>se `oss_compagna_reclutata` — → `altare_con_yara`</sub>
  - ▸ «Continua»  <sub>se NON `oss_compagna_reclutata` — → `altare_da_solo`</sub>

### `altare_da_solo`

- **Anonimo:** «Quella creatura non era pericolosa... eppure sembrava impossibile infliggergli del danno vero... anche se... sembrava comunque soffrire...»

**Tornandoci** ("Osserva la scena"):
- *L'altare è come l'hai lasciato: le candele consumate, la scalinata che scende verso la luce rossastra.*

**Scelte:**
  - ▸ «Scendi verso il trono»  <sub>→ `trono_marcio_senza_compagna`</sub>
  - ▸ «Torna alla cripta»  <sub>→ `cripta_senza_compagna`</sub>

### `altare_con_yara`
<sub>in scena: **Yara** (al centro)</sub>

- **Yara:** «Povera creatura... Cosa pensi sia successo a quella cosa?»
- **Anonimo:** «Questo posto... è qualcosa che non dovrebbe esistere... Non ho risposte alla tua domanda...»
- **Yara:** «Non perdonerò mai chi ha causato tutto questo.»
- **Anonimo:** «...»

**Tornandoci** ("Osserva la scena"):
- *L'altare è come l'avete lasciato: le candele consumate, la scalinata che scende verso la luce rossastra.*

**Scelte:**
  - ▸ «Scendi verso il trono»  <sub>→ `trono_marcio_con_compagna`</sub>
  - ▸ «Torna alla cripta»  <sub>→ `cripta_con_compagna`</sub>

### `trono_marcio_senza_compagna`
<sub>in scena: **Jongo Dongo** (al centro)</sub>

- *Qualcuno recita in una lingua a te sconosciuta dei canti mentre scendi gli ultimi gradini: le parole non vogliono dire niente, ma il ritmo è quello di una preghiera che non si è mai interrotta.*
- **Anonimo:** «Sei tu il responsabile di tutto questo?»
- **Jongo Dongo:** «Hmmm? Un piccolo sacrificio, per un grande risultato...»

**Scelte:**
  - ▸ «Affrontalo»  <sub>COMBATTIMENTO: Jongo Dongo</sub>

### `trono_marcio_con_compagna`
<sub>in scena: **Jongo Dongo** (al centro)  ·  alza `oss_yara_esplosa`</sub>

- *Qualcuno recita in una lingua a te sconosciuta dei canti mentre scendete gli ultimi gradini: le parole non vogliono dire niente, ma il ritmo è quello di una preghiera che non si è mai interrotta.*
- **Anonimo:** «Sei tu il responsabile di tutto questo?»
- **Jongo Dongo:** «Hmmm? Un piccolo sacrificio, per un grande risultato...»
- **Yara:** «Riconosco quella voce... È la stessa che ho sentito quel giorno. Non posso dimenticarla... Maledetto! Sei stato tu!»
- *Prima che tu possa fermarla, si lancia avventatamente contro Jongo Dongo, che non esita a trafiggerla.*
- **Yara:** «Ma... le... detto... muori...»
- **click* La ragazza salta in aria: Jongo Dongo viene avvolto dalle fiamme.*
- **Jongo Dongo:** «... Il dolore... non è altro che un mero ostacolo... sciocca ragazzina...»
- **Anonimo:** «... Avrei dovuto fermarla... La pagherai...»

**Scelte:**
  - ▸ «Affrontalo»  <sub>COMBATTIMENTO: Jongo Dongo</sub>

### `jongo_prima_caduta`
<sub>in scena: **Jongo Dongo** (al centro)  ·  il combattimento parte da solo</sub>

- **Anonimo:** «Finalmente questa storia ha una fine.»
- **Anonimo:** «... Come mai non percepisco alcun cambiamento?»
- *Jongo Dongo si rialza.*
- **Jongo Dongo:** «...»
- **Anonimo:** «... Come fa ad essere ancora in piedi?!»

### `vittoria`
<sub>in scena: **Jongo Dongo** (al centro)  ·  alza `quest_ossidiana`</sub>

- *Jongo Dongo cade in ginocchio, poi si sfalda: la maledizione che lo teneva in piedi si scioglie insieme a lui. Non chiede perdono. Dai rimasugli sparsi nel vento si alza una voce sinistra... "Eravamo così... vicini... il viaggio...". L'ossidiana intorno smette di sudare, l'aria si alleggerisce e in lontananza puoi percepire qualcosa che si addormenta dolcemente.*

**Scelte:**
  - ▸ «Torna nel Vuoto»  <sub>→ esci dallo squarcio</sub>

### `sconfitta_boss`

- **Jongo Dongo:** «Un nuovo sacrificio... Una nuova possibilità...»

**Scelte:**
  - ▸ «Riprendi dall'ultimo salvataggio»

### `espulso`

- *Il buio ti si richiude sopra come una fossa che si rinchiude. Quando riprendi fiato, sei di nuovo nel Vuoto. La Rocca di Ossidiana resta lì, marcia e paziente.*

**Scelte:**
  - ▸ «Riprendi fiato nel Vuoto»  <sub>→ esci dallo squarcio</sub>

---

## Il Teatro del Passato

`data/vuoti/teatro_del_passato.json`  ·  nodo iniziale: `foyer`

### `foyer`

- *Questo squarcio dà sul passato: un teatro nel suo giorno migliore. Il foyer profuma di velluto e cera. Da dentro arriva un applauso — no: il rumore di un solo paio di mani.*

**Scelte:**
  - ▸ «Pesca nella fontanella dei desideri»  <sub>→ `foyer`</sub>
  - ▸ «Entra in platea»  <sub>→ `platea`</sub>
  - ▸ «Passa dal botteghino»  <sub>→ `botteghino`</sub>
  - ▸ «Torna nel Vuoto»  <sub>→ esci dallo squarcio</sub>

### `platea`

- *In platea non c'è nessuno. Sul palco, un ragazzo si esibisce in acrobazie folli: salti che nessun corpo dovrebbe reggere, eppure atterra sempre. Si allena come se il mondo intero lo stesse guardando. Non lo guarda nessuno.*

**Scelte:**
  - ▸ «Resta a guardare le acrobazie»  <sub>→ `platea`</sub>
  - ▸ «Controlla sotto la poltrona numero 7»  <sub>→ `platea`</sub>
  - ▸ «Sali sul palcoscenico»  <sub>→ `palcoscenico`</sub>
  - ▸ «Sali in galleria»  <sub>→ `galleria`</sub>
  - ▸ «Torna nel foyer»  <sub>→ `foyer`</sub>

### `palcoscenico`

- *Da vicino il ragazzo è solo un ragazzo: fiato corto, mani fasciate, occhi che bruciano. Ti attraversa con lo sguardo — sei nel passato, per lui non esisti. Riparte da capo. Ancora. Ancora.*

**Scelte:**
  - ▸ «Apri il baule di scena»  <sub>→ `palcoscenico`</sub>
  - ▸ «Vai dietro le quinte»  <sub>→ `quinte`</sub>
  - ▸ «Scendi in platea»  <sub>→ `platea`</sub>

### `quinte`
<sub>alza `quest_teatro`</sub>

- *Dietro le quinte: corde, sacchi di sabbia, uno specchio con le lampadine. Infilata nella cornice dello specchio c'è una copia di uno strano biglietto.*

**Scelte:**
  - ▸ «Prendi la copia del biglietto»  <sub>→ `quinte` · ottieni `biglietto_strano`</sub>
  - ▸ «Torna sul palcoscenico»  <sub>→ `palcoscenico`</sub>

### `galleria`

- *Dalla galleria il palco sembra piccolo e il ragazzo un punto che vola. Il lampadario di cristallo trattiene la luce come fosse fiato.*

**Scelte:**
  - ▸ «Allunga la mano nella balaustra scollata»  <sub>→ `galleria`</sub>
  - ▸ «Scendi in platea»  <sub>→ `platea`</sub>

### `botteghino`

- *Il botteghino è ordinato, pronto per una fila che deve ancora arrivare. Il registro segna un solo biglietto venduto, prima fila.*

**Scelte:**
  - ▸ «Apri il doppio fondo del cassetto»  <sub>→ `botteghino`</sub>
  - ▸ «Torna nel foyer»  <sub>→ `foyer`</sub>

---

## La Casa Gigante

`data/vuoti/casa_gigante.json`  ·  nodo iniziale: `soglia`

### `soglia`

- *Mi diceva mia madre: i bravi bambini restano lontani dalla grande casa in mezzo al bosco, non si avvicinano neanche per cogliere un fiore coperto di rugiada.<br>I bambini che disobbediscono vengono trasformati in bellissime bambole di ottima fattura... con vestiti eleganti e accessori sgargianti.<br>Diventano i giocattoli dei demoni che hanno occupato la casa... ci giocano e ci giocano e ci giocano ancora...<br>Finché ogni cucitura non è recisa... finché ogni porcellana non è insudiciata... finché ogni filo non viene tirato.<br>Un tempo questa casa donava amore e riparo... o forse... solo l'illusione di una vita perfetta...*
- `CARTA DEL TITOLO` — **La Grande Magione Abbandonata**

**Tornandoci** ("Osserva la scena"):
- *La facciata della grande casa ti sovrasta, storta, con tutte le finestre buie tranne una.*

**Scelte:**
  - ▸ «Entra»  <sub>→ `salone`</sub>
  - ▸ «Torna nel Vuoto»  <sub>se NON `casa_yhvina` — → esci dallo squarcio</sub>
  - ▸ «Torna nel Vuoto»  <sub>se `casa_ricordo_sconfitto` — → esci dallo squarcio</sub>

### `salone`

- *Sembra tutto abbandonato da tantissimo tempo... la polvere è così fitta da sembrare una leggera nebbia...*

**Scelte:**
  - ▸ «Vai nella sala principale»  <sub>→ `sala_principale`</sub>
  - ▸ «Vai nell'ala destra»  <sub>→ `ala_destra`</sub>
  - ▸ «Vai nell'ala sinistra»  <sub>→ `ala_sinistra`</sub>
  - ▸ «Torna alla soglia»  <sub>→ `soglia`</sub>

### `sala_principale`

- *Sembra che le pareti siano addobbate con i quadri di gente che probabilmente viveva in questo posto...*

**Scelte:**
  - ▸ «Osserva il quadro dell'uomo»  <sub>→ `quadro_uomo`</sub>
  - ▸ «Osserva il quadro della donna»  <sub>→ `quadro_donna`</sub>
  - ▸ «Osserva il quadro di famiglia»  <sub>→ `quadro_famiglia`</sub>
  - ▸ «Fruga sotto i cuscini del divano»  <sub>→ `sala_principale`</sub>
  - ▸ «Vai in cucina»  <sub>→ `cucina`</sub>
  - ▸ «Sali le scale»  <sub>→ `scala`</sub>
  - ▸ «Torna al salone»  <sub>→ `salone`</sub>

### `ala_destra`

- *Alte colonne si ergono lungo un corridoio a scacchi: la polvere ha reso ormai le mattonelle bianche di un giallo ocra molto oscuro...*
- **Anonimo:** «... C'è qualcosa sotto questa piastrella.»
- **Anonimo:** «Sembra che non ci sia altro se non stanze completamente piene di macerie, oltre questo punto...»

**Tornandoci** ("Osserva la scena"):
- *Il corridoio a scacchi dell'ala destra, e in fondo le stanze sfondate dalle macerie. Non porta da nessuna parte.*

**Scelte:**
  - ▸ «Alza la piastrella»  <sub>→ `ala_destra` · ottieni `spilla_margherita`</sub>
  - ▸ «Torna al salone»  <sub>→ `salone`</sub>

### `ala_sinistra`

- **Anonimo:** «Mh... sembrerebbe non esserci nulla qui dentro. Certo che questa famiglia doveva possedere un'ingente quantità di soldi, per permettersi un posto del genere...»

**Tornandoci** ("Osserva la scena"):
- *L'ala sinistra: stanze grandi, vuote, e niente dentro a parte la polvere.*

**Scelte:**
  - ▸ «Torna al salone»  <sub>→ `salone`</sub>

### `quadro_uomo`

- *Sembra un uomo molto severo... le rughe sul suo volto fanno trasparire un'estrema tristezza e una rabbia sempre tenuta a bada.*

**Scelte:**
  - ▸ «Torna nella sala principale»  <sub>→ `sala_principale`</sub>

### `quadro_donna`

- *Una donna di una certa età... cos'ha in mano? Il suo sguardo non ti fa sentire al sicuro.*

**Scelte:**
  - ▸ «Torna nella sala principale»  <sub>→ `sala_principale`</sub>

### `quadro_famiglia`

- *Ci sono un uomo, una donna, una bambina con una bambola in braccio e una donna anziana in posa... la donna più anziana ha uno sguardo che farebbe gelare il sangue a molti... Non sembrano molto felici...*

**Scelte:**
  - ▸ «Torna nella sala principale»  <sub>→ `sala_principale`</sub>

### `mensola`

- *Tutti gli strumenti in questa cucina sembrano di ottima fattura, c'è un forte odore di ammoniaca e detersivi sopravvissuto anche al tempo...*
- **Anonimo:** «Queste sostanze sono molto pericolose se ingerite... cosa ci fanno in una cucina?»

**Tornandoci** ("Osserva la scena"):
- *La mensola dei detersivi, allineati come in una vetrina. L'odore di ammoniaca non se ne va.*

**Scelte:**
  - ▸ «Torna in cucina»  <sub>→ `cucina`</sub>

### `cucina`

- *Pentole in fila, un tavolo apparecchiato per tre da molto tempo, senza che nessuno l'abbia mai sparecchiato. In una credenza, bottiglie impolverate; in un'altra, qualcosa di dolce.*

**Scelte:**
  - ▸ «Fruga nella mensola»  <sub>→ `mensola`</sub>
  - ▸ «Stappa una bottiglia di vino di ottima qualità»  <sub>→ `cucina` · ottieni `vino_di_ottima_qualita`</sub>
  - ▸ «Fruga nella credenza dei dolci»  <sub>→ `cucina` · ottieni `merendine_scadute`</sub>
  - ▸ «Torna nella sala principale»  <sub>→ `sala_principale`</sub>

### `scala`

- *La scala sale attraverso piani che sembrano più numerosi di quanti dovrebbero essere.*
- **Anonimo:** «Questa casa è immensa... la maggior parte delle stanze sono vuote... come se qualcuno avesse portato via tutto...»

**Tornandoci** ("Osserva la scena"):
- *La scala, e i suoi piani che non finiscono mai. Da qui si arriva ovunque, in questa casa.*

**Scelte:**
  - ▸ «Entra nella stanza dei giochi»  <sub>→ `stanza_giochi`</sub>
  - ▸ «Sali fino alla soffitta»  <sub>→ `soffitta`</sub>
  - ▸ «Entra nel grande bagno»  <sub>→ `grande_bagno`</sub>
  - ▸ «Scendi nella sala principale»  <sub>→ `sala_principale`</sub>

### `grande_bagno`

- **Anonimo:** «Questo bagno è enorme... l'acqua non funziona più... un tempo deve essere stato bellissimo rilassarsi qui...»

**Tornandoci** ("Osserva la scena"):
- *Il grande bagno, le rubinetterie secche e la vasca piena di calcinacci.*

**Scelte:**
  - ▸ «Torna alla scala»  <sub>→ `scala`</sub>

### `stanza_giochi`

- *La stanza dei giochi: scaffali di giocattoli allineati come spettatori, un baule, e un mucchio di cuscini contro il muro. Tre fotografie, in cornici diverse, osservano la stanza da un comò.*

**Scelte:**
  - ▸ «Osserva la prima fotografia»  <sub>→ `foto_1`</sub>
  - ▸ «Osserva la seconda fotografia»  <sub>→ `foto_2`</sub>
  - ▸ «Osserva la terza fotografia»  <sub>→ `foto_3`</sub>
  - ▸ «Apri il baule dei giocattoli»  <sub>→ `stanza_giochi` · ottieni `fiala_hp`</sub>
  - ▸ «Scendi nella botola»  <sub>se `casa_botola` — → `stanza_studi`</sub>
  - ▸ «Torna alla scala»  <sub>→ `scala`</sub>

### `foto_1`

- *Una fotografia ingiallita: una ragazzina, forse sei o sette anni, gioca seduta per terra con una bambola fatta a mano. Sta ridendo.*

**Scelte:**
  - ▸ «Torna alla stanza dei giochi»  <sub>→ `stanza_giochi`</sub>

### `foto_2`

- *La stessa ragazzina, cresciuta: un vestito più elegante, una posa più composta. Tiene ancora la bambola, stretta contro il fianco, come se qualcuno potesse portargliela via da un momento all'altro.*

**Scelte:**
  - ▸ «Torna alla stanza dei giochi»  <sub>→ `stanza_giochi`</sub>

### `foto_3`

- *Una festa di compleanno: candeline, un tavolo pieno di regali che sembrano tutti uguali e tutti sbagliati. La ragazzina è al centro, la bambola in grembo. Non sorride, in questa.*

**Scelte:**
  - ▸ «Torna alla stanza dei giochi»  <sub>→ `stanza_giochi`</sub>

### `soffitta`

- **Anonimo:** «Questa vecchia soffitta sembra cadere a pezzi, se non fosse per la luce della luna che passa attraverso le fessure, non vedresti nulla...»

**Tornandoci** ("Osserva la scena"):
- *La soffitta: scatoloni ovunque, tutti con la stessa scritta a mano. Nessuno è mai stato buttato.*

**Scelte:**
  - ▸ «Rovista tra gli scatoloni»  <sub>→ `soffitta` · ottieni `collana_particolare`</sub>
  - ▸ «Controlla dentro un vecchio baule chiuso a chiave»  <sub>→ `soffitta`</sub>
  - ▸ «Un altro sottoscala porta più su, verso l'attico»  <sub>→ `attico`</sub>
  - ▸ «Torna alla scala»  <sub>→ `scala`</sub>

### `attico`

- *Salendo ancora più in alto la polvere sembra diminuire, in questo piccolo attico puoi respirare più liberamente...*
- **Anonimo:** «Sento uno strano potere... mi ricorda... Veronica? Non può essere...»

**Tornandoci** ("Osserva la scena"):
- *L'attico, basso e lungo. In fondo, sotto uno spiovente, una porta chiusa da cui filtra una luce fioca e costante.*

**Scelte:**
  - ▸ «Apri la porta della camera da letto»  <sub>→ `camera_da_letto`</sub>
  - ▸ «Torna alla soffitta»  <sub>→ `soffitta`</sub>

### `camera_da_letto`
<sub>in scena: **Yhvina**</sub>

- *Sembra esserci qualcuno...*
- **Yhvina:** «Eh? E tu chi sei? Non mi aspettavo di trovare qualcun altro...»
- **Yhvina:** «Hm... sembra che anche tu sia come me... Lo percepisci anche tu vero? Altrimenti non saresti qui... C'è qualcosa di estremamente sbagliato in questo posto...»
- **Anonimo:** «In realtà io sono qui per conto dell'organizzazione... questo squarcio dovrebbe essere di mia competenza... Tu come ci sei finita qui?»
- **Yhvina:** «Organizzazione? Io sono qui per puro caso... mi capita di addormentarmi e ritrovarmi in posti come questo... Da qualche parte deve esserci qualcuno... o meglio qualcosa... che genera tutto questo... Io voglio solo andare a casa e farmi una dormita.»
- **Anonimo:** «Pensandoci bene, abbiamo un obiettivo in comune... sarebbe una buona mossa proporle di andare a fondo in questa questione insieme...»

**Tornandoci** ("Osserva la scena"):
- *La camera da letto sotto lo spiovente: un materasso per terra, una lampada che nessuno spegne mai.*

**Scelte:**
  - ▸ «Chiedile di combattere al tuo fianco»  <sub>se NON `casa_ricordo_sconfitto` — → `yhvina_si` · recluta `insonne`</sub>
  - ▸ «"Ce la faccio da solo."»  <sub>→ `attico`</sub>

### `yhvina_si`
<sub>in scena: **Yhvina**</sub>

- *Proponi a Yhvina di unirsi a te.*
- **Anonimo:** «Ehm... perché mi guarda così? Cos'è quell'espressione disgustata...?»
- **Yhvina:** «Hmph... beh, una cosa è certa, prima finisce questa storia, meglio è... Ma non montarti la testa, una volta finita questa storia, ognuno per la sua strada.»
- *Le mani di Yhvina cambiano e il suo sguardo non ti rassicura per niente...*
- **Yhvina:** «Su, andiamo, abbiamo già perso fin troppo tempo.»

**Tornandoci** ("Osserva la scena"):
- *Yhvina è in piedi accanto alla porta, e aspetta che sia tu a muoverti.*

**Scelte:**
  - ▸ «Esci dalla camera»  <sub>→ `attico`</sub>

### `stanza_studi`

- *Sotto i cuscini, la botola dà su una stanza degli studi: scrivania, diplomi alle pareti, e un fascicolo lasciato aperto come se qualcuno l'avesse richiuso in fretta, tanti anni fa.*

**Scelte:**
  - ▸ «Leggi la cartella clinica»  <sub>→ `cartella_clinica`</sub>
  - ▸ «Prosegui nel tunnel»  <sub>→ `tunnel`</sub>
  - ▸ «Risali dalla botola»  <sub>→ `stanza_giochi`</sub>

### `cartella_clinica`

- *"...sbalzi di umore frequenti, episodi depressivi persistenti. Livelli di disallineamento anomali per l'età. Salute generale carente." La firma in fondo è illeggibile quanto il resto.*

**Scelte:**
  - ▸ «Richiudi il fascicolo»  <sub>→ `stanza_studi`</sub>

### `tunnel`

- *Un tunnel scavato a mano, stretto, che scende oltre le fondamenta della casa. L'aria si fa più fredda a ogni passo.*
- **Anonimo:** «L'aria è fredda... presumo che ci siamo...»
- **Yhvina:** «Lo senti anche tu, vero? Quello che vogliamo trovare si trova in fondo a questo tunnel...»

**Tornandoci** ("Osserva la scena"):
- *Il tunnel scavato a mano scende oltre le fondamenta. Più avanti, il freddo.*

**Scelte:**
  - ▸ «Avanza verso la luce in fondo»  <sub>→ `altare`</sub>
  - ▸ «Torna alla stanza degli studi»  <sub>→ `stanza_studi`</sub>

### `altare`

- *Un altare tributario, costruito con le mani: candele consumate, una foto incorniciata, e un mucchio di lettere ingiallite. Ai piedi dell'altare, buttata su un fianco, una bambola sporca di terra. Oltre le candele, nel buio, si intuisce qualcosa di enorme incassato nella parete di fondo.*

**Scelte:**
  - ▸ «Leggi le lettere»  <sub>se NON `casa_lettere_bruciate` — → `lettere_lettura`</sub>
  - ▸ «Brucia le lettere»  <sub>→ `lettere_bruciate`</sub>
  - ▸ «Stappa l'ultima bottiglia di vino di ottima qualità»  <sub>→ `altare` · ottieni `vino_di_ottima_qualita`</sub>
  - ▸ «Osserva da vicino la foto sull'altare»  <sub>se NON `casa_ricordo_sconfitto` — → `presentazione_ricordo`</sub>
  - ▸ «Guarda oltre l'altare, nel buio»  <sub>se NON `casa_ricordo_sconfitto` — → `porta_bloccata`</sub>
  - ▸ «L'altare è silenzioso, ora.»  <sub>se `casa_ricordo_sconfitto` — → `tunnel`</sub>
  - ▸ «Guarda oltre l'altare, nel buio»  <sub>se `casa_ricordo_sconfitto` — → `porta_enorme`</sub>
  - ▸ «Torna al tunnel»  <sub>→ `tunnel`</sub>

### `presentazione_ricordo`
<sub>il combattimento parte da solo</sub>

- *Quando si vuole bene a qualcuno, un legame viene creato... come migliaia di fili intrecciati diventa sempre più solido.<br>Che nessuno osi dividere quello che è stato unito dall'amore... Sono questioni superiori agli uomini...<br>Così... filo su filo si tesse una piccola bambola di pezza, non troppo bella non troppo brutta... ma colma di amore...<br>E con lo spezzarsi di quel legame... così come si sfalda una bambola, cominciò a sfaldarsi la fortuna di chi osò calpestare la tenerezza di un legame nato dal sentimento più puro...*
- `CARTA DEL TITOLO` — **Un tenero ricordo**

### `porta_bloccata`

- *Fai un passo oltre le candele, e la bambola si volta di scatto verso di te — non ti aveva mai guardato prima. Non si muove, non parla: si limita a restare tra te e il buio, e in qualche modo è più che sufficiente. Meglio non insistere. Non ancora.*

**Scelte:**
  - ▸ «Torna all'altare»  <sub>→ `altare`</sub>

### `porta_enorme`

- *Con la bambola non più a guardia, il passo oltre l'altare è libero: una porta enorme, sproporzionata perfino per questa casa, incassata nella roccia oltre le candele consumate. Nessuna maniglia, solo un meccanismo circolare al centro, coperto di polvere e fermo da chissà quanto.*

**Scelte:**
  - ▸ «Prova ad aprirla»  <sub>→ `tunnel`</sub>
  - ▸ «Non si muove di un millimetro. Non è ancora il momento.»  <sub>→ `altare`</sub>

### `lettere_lettura`

- *Sono lettere mai spedite, scritte dai genitori: parlano di rimorso, di quanto avrebbero voluto tornare indietro. "Se solo non avessimo preteso così tanto da te," dice una. Un'altra si interrompe a metà frase.*

**Scelte:**
  - ▸ «Richiudi le lettere»  <sub>→ `altare`</sub>

### `lettere_bruciate`

- *Le accendi una a una, sull'ultima candela ancora viva. Il rimorso di chi le ha scritte non serve più a nessuno: bruciano in fretta, come se anche loro non aspettassero altro.*

**Scelte:**
  - ▸ «Torna all'altare»  <sub>→ `altare`</sub>

### `ricordo_concluso`
<sub>alza `casa_ricordo_sconfitto`</sub>

- *Le cuciture non cedono: si strappano. La bambola si apre da sola lungo le giunture, un filo dopo l'altro, e ogni strappo suona come qualcosa che si rompe dentro un corpo vero.*
- *Le ombre nere escono da lei tutte insieme, si spargono sulle pareti e scappano in ogni direzione, disperdendosi con lamenti assordanti che ti restano nelle orecchie molto dopo che il buio le ha inghiottite.*
- **Un tenero ricordo:** «...volevo, giocare... ancora... un pò...»
- *Quello che resta a terra non somiglia più a niente. L'atmosfera trasuda una tristezza profonda e umida... sembra quasi di aver fatto la cosa sbagliata...*

**Scelte:**
  - ▸ «Raccogli ciò che resta»  <sub>→ `congedo_yhvina` · ottieni `prova_di_un_forte_amore`</sub>

### `ricordo_concluso_buono`
<sub>alza `casa_ricordo_sconfitto`</sub>

- *La bambola comincia a sfilacciarsi lo stesso, ma questa volta senza opporre resistenza: le ombre nere si ritirano piano dalle pareti, senza violenza.*
- **Un tenero ricordo:** «...Lilloh... sei tornata a giocare con me?»
- *Quello che resta, nell'aria, non è più dolore: solo quiete.*
- **Un tenero ricordo:** «Grazie... per non avermi dimenticata.»

**Scelte:**
  - ▸ «Raccogli ciò che resta»  <sub>→ `congedo_yhvina` · ottieni `prova_di_un_forte_amore`</sub>

### `congedo_yhvina`
<sub>in scena: **Yhvina**</sub>

- **Yhvina:** «Bene, sembrerebbe che il nostro lavoro qui sia terminato, sembra che potrò tornare finalmente a casa.»
- **Yhvina:** «Ecco che arriva... Bene. Se il destino vorrà, ci rivedremo ancora.»
- *Uno squarcio deforma Yhvina che scompare senza lasciare alcuna traccia... quando uno squarcio si chiude, tutto quello che ha portato viene riportato indietro.*
- *Il tuo compito sembra essere terminato.*

**Tornandoci** ("Osserva la scena"):
- *Dove c'era Yhvina non è rimasto niente. Il tuo compito, qui, è terminato.*

**Scelte:**
  - ▸ «Torna verso l'altare»  <sub>→ `altare`</sub>

### `cacciata`

- *Qualcosa ti solleva di peso e la casa ti scaraventa fuori, oltre lo squarcio. La ninna nanna riprende, stonata come prima.*

**Scelte:**
  - ▸ «Riprendi dall'ultimo salvataggio»

---

## Kizako Industries — Ala Dimenticata

`data/vuoti/kizako_ala.json`  ·  nodo iniziale: `portone`

### `portone`

- *Lo squarcio si apre su un'altra ala dello stesso complesso: più grande, più antica, sigillata da un portone che qualcuno ha divelto dall'interno. Sopra l'architrave, in lettere di metallo mezze cadute: KIZAKO INDUSTRIES. Sirene lontane suonano a intervalli, senza motivo. Le luci di cantiere si accendono e si spengono da sole.*

**Scelte:**
  - ▸ «Entra nel reparto montaggio»  <sub>→ `reparto`</sub>
  - ▸ «Torna nel Vuoto»  <sub>→ esci dallo squarcio</sub>

### `reparto`

- *Il reparto montaggio si perde nel buio. Nastri fermi, bracci meccanici piegati come schiene stanche. Ogni tanto qualcosa si muove tra i rottami: non macchine, non del tutto. Fa' Studia in combattimento, e sentirai chi erano.*

**Scelte:**
  - ▸ «Raggiungi la sala mensa»  <sub>→ `mensa`</sub>
  - ▸ «Sali alla passerella dei capisquadra»  <sub>→ `passerella`</sub>
  - ▸ «Torna al portone»  <sub>→ `portone`</sub>

### `mensa`

- *Una mensa aziendale immensa, tavoli in fila fino a perdersi. Su un muro, un orologio marcatempo fermo alle 19:47. Sotto, migliaia di cartellini timbrati e mai ritirati. Su una parete, un manifesto: 'IL RIPOSO È UN LUSSO CHE LA STORIA NON SI CONCEDE. — K.'*

**Scelte:**
  - ▸ «Fruga tra i cartellini»  <sub>→ `mensa`</sub>
  - ▸ «Recupera il tesserino di un caposquadra»  <sub>→ `mensa` · ottieni `componente_elettronico`</sub>
  - ▸ «Scendi negli archivi»  <sub>→ `archivi`</sub>
  - ▸ «Torna al reparto»  <sub>→ `reparto`</sub>

### `passerella`

- *Dalla passerella si domina tutto il reparto. Da qui i capisquadra guardavano gli operai come si guarda un formicaio. Una di quelle sagome di ferro è ancora qui, incastrata nella ringhiera, e urla con la voce di troppa gente.*

**Scelte:**
  - ▸ «Forza la cassaforte del capannone»  <sub>→ `passerella`</sub>
  - ▸ «Recupera la tanica lasciata sul ballatoio»  <sub>→ `passerella` · ottieni `benzina`</sub>
  - ▸ «Scendi negli archivi per la scala di servizio»  <sub>→ `archivi`</sub>
  - ▸ «Torna al reparto»  <sub>→ `reparto`</sub>

### `archivi`
<sub>alza `quest_kizako_ala`</sub>

- *Gli archivi della Kizako Industries. Faldoni di brevetti d'arma, bilanci gonfi, e una parete intera di fototessere di dipendenti, ognuna con una data di assunzione e nessuna data di uscita. In fondo, uno studio privato con una targa: DIR. KIZAKO.*

**Scelte:**
  - ▸ «Leggi un fascicolo a caso»  <sub>→ `fascicolo`</sub>
  - ▸ «Entra nello studio di Kizako»  <sub>→ `studio_kizako`</sub>
  - ▸ «Torna alla mensa»  <sub>→ `mensa`</sub>

### `fascicolo`

- *"Progetto di ottimizzazione del rendimento umano. Turni prolungati oltre soglia di crollo. Perdite accettabili. Nota a margine, altra grafia: 'Signore, alcuni non tornano a casa da settimane. Rispondono solo alle sirene.' Risposta, inchiostro rosso: 'Ottimo. Meno distrazioni.'"*

**Scelte:**
  - ▸ «Richiudi il fascicolo»  <sub>→ `archivi`</sub>

### `studio_kizako`

- *Lo studio è vuoto, pulito, gelido: l'unica stanza intatta di tutto il complesso. Nessun ritratto del padrone, da nessuna parte. Solo una lavagna piena di formule e, in un angolo, la sagoma di dove doveva esserci qualcosa di prezioso, ora sparito. Kizako non c'è. Kizako non c'è mai, nelle sue fabbriche. Ma le sue fabbriche sono ovunque.*

**Scelte:**
  - ▸ «Preleva la volontà lasciata sull'incudine dell'officina»  <sub>→ `studio_kizako` · ottieni `volonta_di_un_fabbro`</sub>
  - ▸ «Esci dagli archivi»  <sub>→ `archivi`</sub>

### `espulso`

- *Le sirene esplodono tutte insieme e le luci di cantiere ti accecano. Quando torni a vedere, sei fuori dallo squarcio. La fabbrica continua a produrre niente, per nessuno.*

**Scelte:**
  - ▸ «Riprendi fiato nel Vuoto»  <sub>→ esci dallo squarcio</sub>

---

## La Fontana

`data/vuoti/fontana.json`  ·  nodo iniziale: `fontana`

### `fontana`

- *Nessun deserto, nessuna fabbrica: qui c'è solo una luce chiara e sospesa, e al centro una fontana di pietra bianca, asciutta da sempre. Sul bordo, quattro incavi vuoti, ognuno della forma di qualcosa che non hai ancora. Chi la riempie, dice l'incisione, riporta indietro qualcuno.*

**Scelte:**
  - ▸ «Deponi ciò che hai raccolto e completa la Fontana»  <sub>→ `fontana_completa`</sub>
  - ▸ «Osserva gli incavi vuoti»  <sub>→ `incavi`</sub>
  - ▸ «Torna nel Vuoto»  <sub>→ esci dallo squarcio</sub>

### `incavi`

- *Quattro incavi, quattro forme: un'anima inquieta, dei ricordi felici, la volontà di un fabbro, un cuore di disallineamento. Sono cose che non si trovano in un posto solo: si raccolgono lungo tutta la strada. Finché mancano, la fontana resta asciutta.*

**Scelte:**
  - ▸ «Torna alla fontana»  <sub>→ `fontana`</sub>

### `fontana_completa`

- *I quattro pezzi trovano il loro posto. L'acqua sgorga dal nulla, limpida, e sale oltre il bordo senza traboccare. Dentro il riflesso prende forma qualcuno che il disallineamento aveva rubato al mondo. Si volta verso di te. [Un nuovo personaggio si unirà: lo gestiremo più avanti.]*

**Scelte:**
  - ▸ «Torna nel Vuoto»  <sub>→ esci dallo squarcio</sub>

---

## Qualcosa preme

`data/vuoti/qualcosa_preme.json`  ·  nodo iniziale: `soglia`

### `soglia`
<sub>alza `qualcosa_preme_toccato`  ·  ti sbatte fuori da solo</sub>

- *Lo squarcio non si apre su un luogo. Si apre su una pressione — enorme, senza forma, che ti schiaccia il petto prima ancora che tu abbia fatto un passo. Non c'è niente da vedere. C'è solo qualcosa, dall'altra parte, che si accorge di te. Il Vuoto stesso sembra volerti indietro.*

**Scelte:**
  - ▸ «...»  <sub>→ esci dallo squarcio</sub>

---

## La campagna di Jerah (il pianeta al centro)

`data/events.json`  ·  nodo iniziale: `inizio`

### `inizio`

- *L'incarico dell'Organizzazione è chiaro: trovare la fonte ed estinguerla, prima che questo mondo venga divorato. Davanti a te un deserto che brucia di una luce rossa che non viene dal sole. All'orizzonte, una plaza de toros in fiamme, e da lì un battito di tacchi e chitarre che sa di sfida. Due vie tagliano la sabbia rovente.*

**Scelte:**
  - ▸ «Taglia per le dune»  <sub>→ `bosco`</sub>
  - ▸ «Segui l'arroyo secco»  <sub>→ `fiume`</sub>

### `bosco`

- *Tra le dune, una vecchia biglietteria da corrida rovesciata, mezza sepolta. Dentro, monete sparse e una razione ancora sigillata.*

**Scelte:**
  - ▸ «Fruga tra i resti»  <sub>→ `sentiero_lanterne` · ottieni `razione_del_circo`</sub>
  - ▸ «Non toccare niente»  <sub>→ `sentiero_lanterne`</sub>

### `fiume`

- *L'arroyo è secco da secoli. Nella sabbia, mezza sepolta, una lanterna spenta che pulsa come un cuore.*

**Scelte:**
  - ▸ «Raccogli la lanterna»  <sub>→ `riva` · ottieni `lanterna_che_pulsa`</sub>
  - ▸ «Lasciala dov'è»  <sub>→ `riva`</sub>

### `riva`

- *Più avanti, un carro da mercante ribaltato, il carico sparso nella sabbia. Qualcuno è fuggito in fretta, o non è fuggito affatto.*

**Scelte:**
  - ▸ «Ispeziona il carico»  <sub>→ `sentiero_lanterne` · ottieni `tonico_calmante`</sub>
  - ▸ «Prosegui lungo l'arroyo»  <sub>→ `sentiero_lanterne`</sub>

### `sentiero_lanterne`

- *Una fila di torce di ferro nero si accende al tuo passaggio, una alla volta, come se qualcuno contasse i tuoi passi verso l'arena.*

**Scelte:**
  - ▸ «Seguile: che contino pure»  <sub>→ `radura`</sub>
  - ▸ «Spegnile a una a una, e respira»  <sub>→ `radura`</sub>

### `radura`

- *Il piazzale davanti alla plaza. Cactus alti come uomini, sombreros bruciati appesi ai pali. Sulla sabbia, immobile e spavaldo, un Fomentado in maschera di toro ti aspetta a braccia aperte.*

**Scelte:**
  - ▸ «Affrontala»  <sub>COMBATTIMENTO: Fomentado</sub>
  - ▸ «Aggirala nell'ombra, seguendo l'istinto»  <sub>serve abilità `sesto_senso` — → `campo_giostre`</sub>

### `campo_giostre`

- *Il patio delle cuadrillas, sotto le gradinate. Il toril con le sbarre divelte, una sala di specchi ancora accesa, e in fondo un carro con una lampada alla finestra.*

**Scelte:**
  - ▸ «Scendi nel toril»  <sub>→ `tunnel`</sub>
  - ▸ «Entra nella sala degli specchi»  <sub>→ `specchi`</sub>
  - ▸ «Bussa al carro illuminato»  <sub>→ `carovana`</sub>

### `tunnel`

- *Nel toril qualcuno ha smontato le sbarre pezzo per pezzo, e ha lasciato la cassa degli attrezzi. In un angolo, un petardo del vecchio spettacolo pirotecnico.*

**Scelte:**
  - ▸ «Prendi quello che serve»  <sub>→ `giostra_cavalli` · ottieni `petardo`</sub>
  - ▸ «Attraversa e basta»  <sub>→ `giostra_cavalli`</sub>

### `specchi`

- *Gli specchi non riflettono te: riflettono i mondi che non ci sono più. In uno di essi, una scheggia luccica a portata di mano. Guardare fa male.*

**Scelte:**
  - ▸ «Reggi lo sguardo e afferra la scheggia»  <sub>→ `giostra_cavalli` · ottieni `scheggia_di_specchio`</sub>
  - ▸ «Distogli lo sguardo e attraversa in fretta»  <sub>→ `giostra_cavalli`</sub>

### `carovana`
<sub>in scena: **Il Vecchio Proprietario del teatro**</sub>

- *In una terra molto, ma molto lontana, dove la luce del sole risplende ogni giorno...<br>Dove maghi, attori, acrobati e artisti di tutti i tipi si esibiscono in cerca di fama e di un'opportunità di rimanere nella storia...<br>Si annida una forza scottata dalla sua stessa passione.<br>Chi è stato consumato dal suo stesso talento si esibisce senza riposo, trascinato non da un obbligo, ma dalle proprie stesse emozioni e da un vento che soffia sempre più forte...<br>Benvenuti nelle terre consumate dalle fiamme della passione... Benvenuti ai deserti di Jondoh, il pianeta dello spettacolo.*
- **Il Vecchio Proprietario del teatro:** «Ciao straniero, è raro trovare qualcuno ancora sano in questi luoghi. Raccontami: cosa ti porta in questo mondo ormai divorato dalle fiamme?»
- **Anonimo:** «Sono qui per conto dell'Organizzazione, sembrerebbe che questo mondo sia ormai perduto. Dimmi, vecchio: cosa dannazione è successo in queste terre?»
- **Il Vecchio Proprietario del teatro:** «Ho ho ho, che giovane focoso che abbiamo qui! Vale, ti racconterò quel che so... Vuoi un sorso?»

**Scelte:**
  - ▸ «Accetta la bevanda»  <sub>→ `carovana_si`</sub>
  - ▸ «Rifiuta, preferisci ascoltare»  <sub>→ `carovana_no`</sub>

### `carovana_si`
<sub>in scena: **Il Vecchio Proprietario del teatro**</sub>

- **Anonimo:** «Grazie mille, ne avevo proprio bisogno.»

**Scelte:**
  - ▸ «Ascolta il suo racconto»  <sub>→ `carovana_racconto`</sub>

### `carovana_no`
<sub>in scena: **Il Vecchio Proprietario del teatro**</sub>

- **Anonimo:** «No, grazie: preferisco ascoltare la tua storia.»

**Scelte:**
  - ▸ «Ascolta il suo racconto»  <sub>→ `carovana_racconto`</sub>

### `carovana_racconto`
<sub>in scena: **Il Vecchio Proprietario del teatro**</sub>

- *[Qui andranno le cinque tavole disegnate da Bru sulla storia di Jerah — arte non ancora pronta.]*
- **Il Vecchio Proprietario del teatro:** «E questo è quel che posso dirti dal punto di vista di un vecchio che non si è mai pentito delle sue azioni...»
- **Il Vecchio Proprietario del teatro:** «Senti, so perché sei qui: permettimi di accompagnarti da lui, ti prego... Voglio solo parlarci un'ultima volta. Non m'importa quale sarà il mio destino, non sarò un peso...»

**Scelte:**
  - ▸ «Portalo con te fino al ruedo»  <sub>→ `giostra_cavalli` · recluta `vecchio_clown`</sub>
  - ▸ «È troppo pericoloso: lascialo alla sua veglia»  <sub>→ `giostra_cavalli`</sub>

### `giostra_cavalli`

- *Una giostra di cavalli da picador gira da sola, a luci spente. I cavalli di legno hanno tutti la testa voltata verso di te.*

**Scelte:**
  - ▸ «Ferma il meccanismo e recupera i Tazo incastrati»  <sub>→ `baraccone_premi`</sub>
  - ▸ «Passa oltre, senza guardarli negli occhi»  <sub>→ `baraccone_premi`</sub>

### `baraccone_premi`

- *Un banco di gioco all'ombra delle gradinate: tre bersagli di latta, una pistola a spuntoni incatenata al banco, e premi che nessuno ha mai vinto.*

**Scelte:**
  - ▸ «Gioca una partita (10 Tazo)»  <sub>→ `premio`</sub>
  - ▸ «I giochi truccati non ti fregano»  <sub>→ `proscenio`</sub>

### `premio`

- *Tre colpi, tre bersagli. Nel silenzio, il banco ti porge un toro di pezza con un occhio solo. Sembra sinceramente stupito che qualcuno abbia vinto.*

**Scelte:**
  - ▸ «Prendi il premio e va' verso il ruedo»  <sub>→ `proscenio` · ottieni `premio_di_pezza`</sub>

### `proscenio`

- *Sotto l'arco d'ingresso al ruedo c'è uno spiazzo riparato dal vento di sabbia. La fonte è vicina: si sente il calore. C'è tempo per un ultimo respiro.*

**Scelte:**
  - ▸ «Accendi un falò»  <sub>→ `falo`</sub>
  - ▸ «Avanti, senza fermarsi»  <sub>→ `palco`</sub>

### `falo`

- *Il fuoco prende in fretta, piccolo e amico in mezzo a tutto quel fuoco nemico. Qui il fragore dell'arena sembra più lontano. C'è tempo per respirare.*

**Scelte:**
  - ▸ «Mangia qualcosa e lascia che il fuoco parli»  <sub>→ `falo_notte`</sub>
  - ▸ «Meglio non perdere tempo»  <sub>→ `palco`</sub>

### `falo_notte`

- *Le braci calano. Qualcuno dovrebbe dire qualcosa, ma il silenzio va bene lo stesso.*

**Scelte:**
  - ▸ «Il Vecchio Proprietario del teatro apre la mano: un bottone dorato, del primo abito di luci di Jerah»  <sub>serve compagno `vecchio_clown` — → `palco` · ottieni `bottone_dorato`</sub>
  - ▸ «Verso il ruedo»  <sub>→ `palco`</sub>

### `palco`
<sub>in scena: **El Muy Bonito** (al centro)</sub>

- *Una strana musica latina comincia a inondare la sala, dalle fiamme e dal cumulo di rose si innalza una figura di rara bellezza, che ti squadra con un'espressione malvagia...*
- **El Muy Bonito:** «Vamos! Cosa ci fanno degli individui senza talento come voi qui? Perché non lasciate mai noi artisti in pace? Stavo cercando l'ispirazione! E ora tutto è perduto! Siate dannati...»
- **Anonimo:** «Fatti da parte.»
- **El Muy Bonito:** «Cosa?! Como te atreves... Es la ora...»
- **El Muy Bonito:** «DE MORIR!»

**Scelte:**
  - ▸ «Passa da lui»  <sub>COMBATTIMENTO: El Muy Bonito</sub>
  - ▸ «Scardina la botola e passa sotto il tablao»  <sub>serve abilità `scasso` — → `backstage`</sub>

### `backstage`

- *Il callejón dietro la barriera è un intrico di corde e drappi bruciacchiati. In alto, tra le travi di ferro nero, luccica qualcosa che nessuno dovrebbe aver lasciato lì.*

**Scelte:**
  - ▸ «Vola fin lassù, tra le travi»  <sub>serve abilità `volo` — → `segreto`</sub>
  - ▸ «Arrampicati a mani nude, presa dopo presa»  <sub>→ `segreto`</sub>
  - ▸ «Scosta l'ultimo drappo»  <sub>→ `boss`</sub>

### `segreto`

- *Tra le travi trovi la medaglia della vecchia plaza, incisa con un nome che non riesci a leggere. Nessuno la vedeva da anni.*

**Scelte:**
  - ▸ «Prendila e scendi nel ruedo»  <sub>→ `boss` · ottieni `medaglia_del_vecchio_circo`</sub>

### `boss`
<sub>in scena: **L'ultimo spettacolo di Jerah** (al centro)</sub>

- *Cosa spinge l'uomo a dare di più? Perché cerchiamo sempre l'approvazione di chi ci circonda? Forse tutta la vita è uno spettacolo... ma cosa succede se il protagonista viene privato del suo lieto fine? Le risate dei bambini si trasformano in delusione, gli sguardi vengono rivolti altrove... E tutto si perde sotto il sipario... Ma a volte... C'è tempo per un ultimo spettacolo, uno spettacolo... mai visto prima.*
- **L'ultimo spettacolo di Jerah:** «Sento... che non sei come gli altri... sei venuto... ad ammirare la mia Jerah?!»
- **L'ultimo spettacolo di Jerah:** «Benvenuto, {nome}. Ammira Jerah! AMAMI!»
- *Il deserto trattiene il fiato.*

**Scelte:**
  - ▸ «Estingui la fonte»  <sub>COMBATTIMENTO: L'ultimo spettacolo di Jerah</sub>

### `sconfitta`

- *Ti risvegli fuori dalla plaza, la testa che rimbomba come un tamburo. Il disallineamento ti ha risputato nella sabbia. Per stavolta.*

**Scelte:**
  - ▸ «Torna alla mappa stellare»  <sub>→ fine campagna</sub>

### `vittoria`
<sub>in scena: **L'ultimo spettacolo di Jerah**</sub>

- *Jerah si spegne senza una parola, gli occhi ancora sulle gradinate vuote. Non c'era più niente da salvare: il nucleo cede, e l'Organizzazione segna il pianeta come perduto. Nessuna rinascita, stavolta. Solo cenere dove c'era il fuoco.*

**Scelte:**
  - ▸ «Torna alla mappa stellare»  <sub>→ fine campagna</sub>

### `vittoria_eroe`
<sub>in scena: **L'ultimo spettacolo di Jerah** (al centro)</sub>

- *L'ultimo spettacolo di Jerah finisce così: un inchino vero, il primo da anni, la muleta abbassata nella sabbia. Il nucleo si imbeve di fattore di disallineamento e si riassorbe: una pangea nuova, vita nuova, tutte le anime in fila per rinascere — anche la sua. L'Organizzazione lo chiamerà esito eroe. Tu lo chiami com'era: uno spettacolo, finito bene.*

**Scelte:**
  - ▸ «Torna alla mappa stellare»  <sub>→ fine campagna</sub>

---

# Chiacchiere coi compagni (bottone «Dialoga»)

`data/dialoghi.json`. Funziona così: il bottone **Dialoga** compare in ogni nodo in cui hai
almeno un compagno. Cliccandolo si apre la lista dei presenti; scegliendone uno, il gioco
cerca in `luoghi` una voce **con lo stesso id del nodo in cui ti trovi**. Se non la trova —
o se l'hai già esaurita — il compagno dice «*non ha altro da dirti, qui*».

Quindi: una battuta esiste solo dove qualcuno l'ha scritta, stanza per stanza.

## `luoghi` — battute legate a una stanza precisa

### `stanza_giochi`
<sub>si può sentire una volta sola (`dialogo_casa_botola`)  ·  alza `casa_botola`</sub>

- *[nome del compagno] si ferma davanti ai cuscini ammucchiati contro il muro, fissandoli con curiosità.*
- **Yhvina:** «Hey, guarda qui, sembra esserci qualcosa sotto questo mucchio di cuscini... proviamo a spostarli?»
- *Tira un calcio violento contro i cuscini.*
- **[il compagno con cui stai parlando]:** «Ecco fatto... vedi? C'è un passaggio...»
- *Non ha perso molto tempo... Ma il risultato c'è.*

## `conversazioni` — due compagni che parlano tra loro

### `salone` — tra Sally e Vega
<sub>compare solo se sono entrambi in squadra; una volta sola</sub>

- **Sally:** «Ti giuro che in questa casa non c'è NIENTE di normale. Nemmeno un poster storto.»
- **Vega:** «O forse è normale, per chi ci ha vissuto. Non tutti i ricordi buttano giù i muri.»
- **Sally:** «Ai ricordi buoni non serve una casa gigante per starci dentro.»

**Puoi intervenire:** *Le due si voltano verso di te, aspettando che tu dica la tua.*
- ▸ «Mostra la collana trovata in soffitta»  <sub>serve `collana_particolare`</sub>
  - **Anonimo:** «Guardate: l'ho trovata in soffitta. Qualcuno di voi due la riconosce?»
  - **Vega:** «Vedi? Anche le cose piccole restano. Grazie per averla notata.»
  - <sub>legame +10</sub>
- ▸ «Prova a mediare tra le due»
  - **Anonimo:** «Magari ha ragione lei: a volte i ricordi fanno più rumore della verità.»
  - **Sally:** «...touché.»
  - <sub>legame +5</sub>
- ▸ «Resta in silenzio e lascia che continuino da sole»

---

# Yhvina nella Casa Gigante, stanza per stanza

Yhvina (id `insonne`) si unisce a te in `camera_da_letto` e resta fino alla fine dello
squarcio: da quel momento il bottone **Dialoga** c'è in ogni stanza, e dentro c'è solo lei.
Sotto, tutte le stanze della Casa Gigante nell'ordine in cui stanno nel file.

- **battute scritte** = Yhvina parla dentro la scena, da sola, senza che tu prema niente
- **Dialoga** = c'è una voce in `dialoghi.json` con l'id di quella stanza, quindi premendo
  «Dialoga → Yhvina» dice qualcosa
- **muta** = premendo «Dialoga → Yhvina» risponde solo *«Yhvina non ha altro da dirti, qui»*

| Stanza | In scena | Dialoga | Cosa manca |
|---|---|---|---|
| `soglia` | — | **muta** | una voce `"soglia"` in `dialoghi.json → luoghi` |
| `salone` | — | **muta** | una voce `"salone"` in `dialoghi.json → luoghi` |
| `sala_principale` | — | **muta** | una voce `"sala_principale"` in `dialoghi.json → luoghi` |
| `ala_destra` | — | **muta** | una voce `"ala_destra"` in `dialoghi.json → luoghi` |
| `ala_sinistra` | — | **muta** | una voce `"ala_sinistra"` in `dialoghi.json → luoghi` |
| `quadro_uomo` | — | **muta** | una voce `"quadro_uomo"` in `dialoghi.json → luoghi` |
| `quadro_donna` | — | **muta** | una voce `"quadro_donna"` in `dialoghi.json → luoghi` |
| `quadro_famiglia` | — | **muta** | una voce `"quadro_famiglia"` in `dialoghi.json → luoghi` |
| `mensola` | — | **muta** | una voce `"mensola"` in `dialoghi.json → luoghi` |
| `cucina` | — | **muta** | una voce `"cucina"` in `dialoghi.json → luoghi` |
| `scala` | — | **muta** | una voce `"scala"` in `dialoghi.json → luoghi` |
| `grande_bagno` | — | **muta** | una voce `"grande_bagno"` in `dialoghi.json → luoghi` |
| `stanza_giochi` | — | sì |  |
| `foto_1` | — | **muta** | una voce `"foto_1"` in `dialoghi.json → luoghi` |
| `foto_2` | — | **muta** | una voce `"foto_2"` in `dialoghi.json → luoghi` |
| `foto_3` | — | **muta** | una voce `"foto_3"` in `dialoghi.json → luoghi` |
| `soffitta` | — | **muta** | una voce `"soffitta"` in `dialoghi.json → luoghi` |
| `attico` | — | **muta** | una voce `"attico"` in `dialoghi.json → luoghi` |
| `camera_da_letto` | 3 battute scritte | **muta** | una voce `"camera_da_letto"` in `dialoghi.json → luoghi` |
| `yhvina_si` | 2 battute scritte | **muta** | una voce `"yhvina_si"` in `dialoghi.json → luoghi` |
| `stanza_studi` | — | **muta** | una voce `"stanza_studi"` in `dialoghi.json → luoghi` |
| `cartella_clinica` | — | **muta** | una voce `"cartella_clinica"` in `dialoghi.json → luoghi` |
| `tunnel` | 1 battuta scritta | **muta** | una voce `"tunnel"` in `dialoghi.json → luoghi` |
| `altare` | — | **muta** | una voce `"altare"` in `dialoghi.json → luoghi` |
| `presentazione_ricordo` | — | **muta** | una voce `"presentazione_ricordo"` in `dialoghi.json → luoghi` |
| `porta_bloccata` | — | **muta** | una voce `"porta_bloccata"` in `dialoghi.json → luoghi` |
| `porta_enorme` | — | **muta** | una voce `"porta_enorme"` in `dialoghi.json → luoghi` |
| `lettere_lettura` | — | **muta** | una voce `"lettere_lettura"` in `dialoghi.json → luoghi` |
| `lettere_bruciate` | — | **muta** | una voce `"lettere_bruciate"` in `dialoghi.json → luoghi` |
| `ricordo_concluso` | — | **muta** | una voce `"ricordo_concluso"` in `dialoghi.json → luoghi` |
| `ricordo_concluso_buono` | — | **muta** | una voce `"ricordo_concluso_buono"` in `dialoghi.json → luoghi` |
| `congedo_yhvina` | 2 battute scritte | **muta** | una voce `"congedo_yhvina"` in `dialoghi.json → luoghi` |
| `cacciata` | — | **muta** | una voce `"cacciata"` in `dialoghi.json → luoghi` |

Per riempirne una, in `data/dialoghi.json` dentro `luoghi`:

```json
"nome_della_stanza": {
  "una_tantum": "dialogo_yhvina_nome_della_stanza",
  "sequenza": [
    { "tipo": "narrazione", "testo": "%s si ferma un attimo a guardare il soffitto." },
    { "tipo": "dialogo", "chi": "insonne", "testo": "..." }
  ]
}
```

`%s` viene sostituito col nome del compagno. Un `dialogo` **senza** `chi` è la battuta di chi
hai davanti in quel momento (utile se la stessa scena deve valere per più compagni); con
`"chi": "insonne"` è per forza Yhvina. `una_tantum` la fa sentire una volta sola: senza,
si può risentire ogni volta che si torna nella stanza.

---

# Dove i compagni NON hanno niente da dire

Ogni riga è una stanza in cui il bottone «Dialoga» c'è ma la risposta è
«*non ha altro da dirti, qui*». Per riempirne una basta aggiungere a `luoghi` in
`data/dialoghi.json` una voce con **quell'id esatto**.

L'introduzione e il tutorial non compaiono qui: là il protagonista è da solo, quindi il
bottone «Dialoga» non esiste proprio.

## Lo Squarcio Industriale
<sub>`data/vuoti/squarcio_industriale.json` — 15 stanze/nodi senza battute dei compagni</sub>

- `varco` — Lo squarcio si richiude alle tue spalle con un sospiro di vapore. Davanti: un complesso industriale…
- `corridoio_tubi` — Tubi e valvole in ogni direzione, alcuni ancora caldi. Da qualche parte un programma si accende, borbotta…
- `deposito` — Scaffali piegati dal caldo, casse sventrate. Qualcuno ha vissuto qui, tra un turno e l'altro, per molto tempo.
- `sala_valvole` — Una sala di valvole grandi come ruote di carro. Il metallo geme. Ogni tanto, dalle macerie, qualcosa si muove.
- `sala_schede` — Schede madri grandi come pareti, piste di rame come strade viste dall'alto. Una voce registrata ripete un…
- `centro_controllo` — Il vecchio centro di controllo: una fila di monitor spenti rivolti verso un'unica poltrona, ancora al centro…
- `diario_1` — "Giorno 1. Il complesso è operativo. Ho detto ai capisquadra che voglio efficienza, non lamentele. Kizako."
- `diario_2` — "Giorno 340 circa (ho perso il conto). Tre operai non si sono presentati oggi. Il caporeparto dice che…
- `diario_3` — "Ultimo giorno che scrivo qui. Il reparto montaggio non risponde più al citofono. Ho mandato una squadra a…
- `nastro` — Il nastro trasportatore corre ancora, a vuoto, trasportando niente da nessuna parte. Il caldo qui toglie il…
- `cuore` — Il cuore del complesso: una turbina ferma, grande come una piazza. Sulle pale, qualcuno ha inciso dei nomi.…
- `discarica` — Un piazzale a cielo aperto, montagne di rottami più alte di una casa. Il sole rosso ci batte sopra senza…
- `padiglione_e` — Il Padiglione E: una struttura tonda enorme, come un silo rovesciato, molto più grande di tutto il resto del…
- `padiglione_e_chiuso` — Non si muove di un millimetro: qualunque cosa lo tenga chiuso, non è fatta per cedere a mani nude. Qualunque…
- `espulso` — Le macerie ti si chiudono addosso e lo squarcio ti sputa fuori, nel Vuoto. Il complesso continua a scaldare…

## Meridia
<sub>`data/vuoti/meridia.json` — 8 stanze/nodi senza battute dei compagni</sub>

- `varco` — Lo squarcio si apre su una città che non è la tua: insegne spente, auto abbandonate in mezzo alla strada,…
- `strada_principale` — La strada principale di Meridia è un cimitero di vetrine rotte. Ogni tanto, tra le macerie, qualcosa si muove…
- `supermercato` — Scaffali rovesciati, carrelli abbandonati a metà corsia. Qualcuno ha fatto scorte, prima della fine. Non è…
- `officina` — Un'officina meccanica, attrezzi sparsi ovunque. Un furgone è ancora sollevato sul ponte, come se il lavoro…
- `edicola` — Un'edicola con la saracinesca a metà. Dentro, pile di giornali ingialliti, l'ultima consegna mai ritirata da…
- `vicolo` — Un vicolo stretto dietro l'edicola, cassonetti rovesciati, una scala antincendio che sale verso il nulla.…
- `quartieri_profondi` — Più a fondo la città cambia: i palazzi si stringono, la luce non arriva più e il silenzio ha un peso diverso.…
- `espulso` — Le mani marce ti si chiudono attorno per un istante, poi lo squarcio ti strappa via, di nuovo nel Vuoto.…

## Cunicoli sotterranei di Jondoh
<sub>`data/vuoti/rocca_ossidiana.json` — 37 stanze/nodi senza battute dei compagni</sub>

- `varco` — Il varco resta aperto alle tue spalle, un taglio di luce fredda sulla parete nera. Davanti, il corridoio…
- `corridoio_ossidiana` — Il corridoio scende, tagliato nella roccia nera. Ai lati, nicchie scavate a mano, segni di graffi e un odore…
- `fossa_oscura` — Una fossa oscura dove piccole pietre illuminano quel poco che è visibile. Qualcosa si muove nel buio: non sai…
- `fondo_del_fosso` — Non sembra esserci altro. Senti qualcosa sballottato fra i tuoi piedi: uno zaino, di qualcuno più sfortunato…
- `sala_del_raccolto` — Cos'è questo posto... c'è una puzza tremenda... quelli... sono cadaveri. Il modo in cui sono stati disposti e…
- `sala_del_lamento` — La sala del lamento: pareti coperte di graffi fino a dove arriva il braccio di un uomo, e un'eco che non si…
- `lamento_imboscata` — Una figura oscura ti travolge dal buio!
- `dopo_lamento` — Qualcosa, dentro di te, si fissa in questo punto. Non tornerai indietro da qui.
- `cunicolo_1` — Questi cunicoli sembrano non avere fine. Da qui la roccia si biforca in due direzioni diverse.
- `cunicolo_2` — Il cunicolo di sinistra scende ancora, ma in fondo si intravede un bagliore instabile, come di torce accese…
- `cunicolo_3` — Il cunicolo di destra sale, e un filo di vento gelido comincia a farsi sentire: da qualche parte, più avanti,…
- `piazza_sotterranea` — Nella piazza sotterranea trovi qualcuno di vivo, finalmente. Ti osserva a lungo, immobile, prima di abbassare…
- `piazza_ritorno` — Yara è dove l'hai lasciata: la schiena contro la roccia, gli occhi puntati sulla galleria da cui sei arrivato.
- `piazza_con_yara` — La piazza è vuota, adesso: le torce consumate fino alla base, e il silenzio che si richiude ogni volta che…
- `yara_si_unisce` — Yara ti aspetta, già rivolta verso l'uscita della piazza.
- `cargo_abbandonato` — All'aperto trovi un cargo abbandonato, arrugginito, mezzo sepolto nella sabbia nera. All'interno, casse…
- `ponte_approccio` — Il cunicolo si apre su un grande ponte marcio, teso su un baratro che la luce non riesce a raggiungere. Oltre…
- `ponte_meta_compagna` — Le assi del ponte scricchiolano già sotto il primo passo. Sotto, solo buio.
- `ponte_meta_solo` — Le assi del ponte scricchiolano già sotto il primo passo. Sotto, solo buio.
- `ponte_centro` — Senti qualcosa muoversi sotto di te...
- `ponte_quasi_fine` — Sembra tutto ok: ormai sei a metà del ponte...
- `ponte_attacco` — Qualcosa sta salendo da sotto il ponte...
- `ponte_attacco_compagna`
- `oltre_ponte` — Attraversato il ponte, volgi lo sguardo all'indietro: altri vermi risalgono e divorano la carcassa di quello…
- `oltre_ponte_gratitudine` — Dall'altra parte del ponte l'aria è ancora più densa. Yara non guarda più indietro.
- `cripta_senza_compagna` — La cripta è una galleria bassa di ossidiana lucida. Qualcosa continua a camminarci dentro, senza arrivare da…
- `cripta_con_compagna` — La cripta è una galleria bassa di ossidiana lucida. Qualcosa continua a camminarci dentro, senza arrivare da…
- `sconfitta_immortale` — Non riesci a scrollartelo di dosso in tempo. Il buio, alla fine, non ha nemmeno bisogno di uccidere: basta…
- `altare_dei_sacrifici` — Un altare scavato nella pietra nera: candele consumate fino alla base, cera colata sopra cera, e una…
- `altare_da_solo` — L'altare è come l'hai lasciato: le candele consumate, la scalinata che scende verso la luce rossastra.
- `altare_con_yara` — L'altare è come l'avete lasciato: le candele consumate, la scalinata che scende verso la luce rossastra.
- `trono_marcio_senza_compagna` — Qualcuno recita in una lingua a te sconosciuta dei canti mentre scendi gli ultimi gradini: le parole non…
- `trono_marcio_con_compagna` — Qualcuno recita in una lingua a te sconosciuta dei canti mentre scendete gli ultimi gradini: le parole non…
- `jongo_prima_caduta` — Jongo Dongo si rialza.
- `vittoria` — Jongo Dongo cade in ginocchio, poi si sfalda: la maledizione che lo teneva in piedi si scioglie insieme a…
- `sconfitta_boss`
- `espulso` — Il buio ti si richiude sopra come una fossa che si rinchiude. Quando riprendi fiato, sei di nuovo nel Vuoto.…

## Il Teatro del Passato
<sub>`data/vuoti/teatro_del_passato.json` — 6 stanze/nodi senza battute dei compagni</sub>

- `foyer` — Questo squarcio dà sul passato: un teatro nel suo giorno migliore. Il foyer profuma di velluto e cera. Da…
- `platea` — In platea non c'è nessuno. Sul palco, un ragazzo si esibisce in acrobazie folli: salti che nessun corpo…
- `palcoscenico` — Da vicino il ragazzo è solo un ragazzo: fiato corto, mani fasciate, occhi che bruciano. Ti attraversa con lo…
- `quinte` — Dietro le quinte: corde, sacchi di sabbia, uno specchio con le lampadine. Infilata nella cornice dello…
- `galleria` — Dalla galleria il palco sembra piccolo e il ragazzo un punto che vola. Il lampadario di cristallo trattiene…
- `botteghino` — Il botteghino è ordinato, pronto per una fila che deve ancora arrivare. Il registro segna un solo biglietto…

## La Casa Gigante
<sub>`data/vuoti/casa_gigante.json` — 32 stanze/nodi senza battute dei compagni</sub>

- `soglia` — La facciata della grande casa ti sovrasta, storta, con tutte le finestre buie tranne una.
- `salone` — Sembra tutto abbandonato da tantissimo tempo... la polvere è così fitta da sembrare una leggera nebbia...
- `sala_principale` — Sembra che le pareti siano addobbate con i quadri di gente che probabilmente viveva in questo posto...
- `ala_destra` — Il corridoio a scacchi dell'ala destra, e in fondo le stanze sfondate dalle macerie. Non porta da nessuna…
- `ala_sinistra` — L'ala sinistra: stanze grandi, vuote, e niente dentro a parte la polvere.
- `quadro_uomo` — Sembra un uomo molto severo... le rughe sul suo volto fanno trasparire un'estrema tristezza e una rabbia…
- `quadro_donna` — Una donna di una certa età... cos'ha in mano? Il suo sguardo non ti fa sentire al sicuro.
- `quadro_famiglia` — Ci sono un uomo, una donna, una bambina con una bambola in braccio e una donna anziana in posa... la donna…
- `mensola` — La mensola dei detersivi, allineati come in una vetrina. L'odore di ammoniaca non se ne va.
- `cucina` — Pentole in fila, un tavolo apparecchiato per tre da molto tempo, senza che nessuno l'abbia mai sparecchiato.…
- `scala` — La scala, e i suoi piani che non finiscono mai. Da qui si arriva ovunque, in questa casa.
- `grande_bagno` — Il grande bagno, le rubinetterie secche e la vasca piena di calcinacci.
- `foto_1` — Una fotografia ingiallita: una ragazzina, forse sei o sette anni, gioca seduta per terra con una bambola…
- `foto_2` — La stessa ragazzina, cresciuta: un vestito più elegante, una posa più composta. Tiene ancora la bambola,…
- `foto_3` — Una festa di compleanno: candeline, un tavolo pieno di regali che sembrano tutti uguali e tutti sbagliati. La…
- `soffitta` — La soffitta: scatoloni ovunque, tutti con la stessa scritta a mano. Nessuno è mai stato buttato.
- `attico` — L'attico, basso e lungo. In fondo, sotto uno spiovente, una porta chiusa da cui filtra una luce fioca e…
- `camera_da_letto` — La camera da letto sotto lo spiovente: un materasso per terra, una lampada che nessuno spegne mai.
- `yhvina_si` — Yhvina è in piedi accanto alla porta, e aspetta che sia tu a muoverti.
- `stanza_studi` — Sotto i cuscini, la botola dà su una stanza degli studi: scrivania, diplomi alle pareti, e un fascicolo…
- `cartella_clinica` — "...sbalzi di umore frequenti, episodi depressivi persistenti. Livelli di disallineamento anomali per l'età.…
- `tunnel` — Il tunnel scavato a mano scende oltre le fondamenta. Più avanti, il freddo.
- `altare` — Un altare tributario, costruito con le mani: candele consumate, una foto incorniciata, e un mucchio di…
- `presentazione_ricordo` — Quando si vuole bene a qualcuno, un legame viene creato... come migliaia di fili intrecciati diventa sempre…
- `porta_bloccata` — Fai un passo oltre le candele, e la bambola si volta di scatto verso di te — non ti aveva mai guardato prima.…
- `porta_enorme` — Con la bambola non più a guardia, il passo oltre l'altare è libero: una porta enorme, sproporzionata perfino…
- `lettere_lettura` — Sono lettere mai spedite, scritte dai genitori: parlano di rimorso, di quanto avrebbero voluto tornare…
- `lettere_bruciate` — Le accendi una a una, sull'ultima candela ancora viva. Il rimorso di chi le ha scritte non serve più a…
- `ricordo_concluso` — Le cuciture non cedono: si strappano. La bambola si apre da sola lungo le giunture, un filo dopo l'altro, e…
- `ricordo_concluso_buono` — La bambola comincia a sfilacciarsi lo stesso, ma questa volta senza opporre resistenza: le ombre nere si…
- `congedo_yhvina` — Dove c'era Yhvina non è rimasto niente. Il tuo compito, qui, è terminato.
- `cacciata` — Qualcosa ti solleva di peso e la casa ti scaraventa fuori, oltre lo squarcio. La ninna nanna riprende,…

## Kizako Industries — Ala Dimenticata
<sub>`data/vuoti/kizako_ala.json` — 8 stanze/nodi senza battute dei compagni</sub>

- `portone` — Lo squarcio si apre su un'altra ala dello stesso complesso: più grande, più antica, sigillata da un portone…
- `reparto` — Il reparto montaggio si perde nel buio. Nastri fermi, bracci meccanici piegati come schiene stanche. Ogni…
- `mensa` — Una mensa aziendale immensa, tavoli in fila fino a perdersi. Su un muro, un orologio marcatempo fermo alle…
- `passerella` — Dalla passerella si domina tutto il reparto. Da qui i capisquadra guardavano gli operai come si guarda un…
- `archivi` — Gli archivi della Kizako Industries. Faldoni di brevetti d'arma, bilanci gonfi, e una parete intera di…
- `fascicolo` — "Progetto di ottimizzazione del rendimento umano. Turni prolungati oltre soglia di crollo. Perdite…
- `studio_kizako` — Lo studio è vuoto, pulito, gelido: l'unica stanza intatta di tutto il complesso. Nessun ritratto del padrone,…
- `espulso` — Le sirene esplodono tutte insieme e le luci di cantiere ti accecano. Quando torni a vedere, sei fuori dallo…

## La Fontana
<sub>`data/vuoti/fontana.json` — 3 stanze/nodi senza battute dei compagni</sub>

- `fontana` — Nessun deserto, nessuna fabbrica: qui c'è solo una luce chiara e sospesa, e al centro una fontana di pietra…
- `incavi` — Quattro incavi, quattro forme: un'anima inquieta, dei ricordi felici, la volontà di un fabbro, un cuore di…
- `fontana_completa` — I quattro pezzi trovano il loro posto. L'acqua sgorga dal nulla, limpida, e sale oltre il bordo senza…

## Qualcosa preme
<sub>`data/vuoti/qualcosa_preme.json` — 1 stanze/nodi senza battute dei compagni</sub>

- `soglia` — Lo squarcio non si apre su un luogo. Si apre su una pressione — enorme, senza forma, che ti schiaccia il…

## La campagna di Jerah
<sub>`data/events.json` — 26 stanze/nodi senza battute dei compagni</sub>

- `inizio` — L'incarico dell'Organizzazione è chiaro: trovare la fonte ed estinguerla, prima che questo mondo venga…
- `bosco` — Tra le dune, una vecchia biglietteria da corrida rovesciata, mezza sepolta. Dentro, monete sparse e una…
- `fiume` — L'arroyo è secco da secoli. Nella sabbia, mezza sepolta, una lanterna spenta che pulsa come un cuore.
- `riva` — Più avanti, un carro da mercante ribaltato, il carico sparso nella sabbia. Qualcuno è fuggito in fretta, o…
- `sentiero_lanterne` — Una fila di torce di ferro nero si accende al tuo passaggio, una alla volta, come se qualcuno contasse i tuoi…
- `radura` — Il piazzale davanti alla plaza. Cactus alti come uomini, sombreros bruciati appesi ai pali. Sulla sabbia,…
- `campo_giostre` — Il patio delle cuadrillas, sotto le gradinate. Il toril con le sbarre divelte, una sala di specchi ancora…
- `tunnel` — Nel toril qualcuno ha smontato le sbarre pezzo per pezzo, e ha lasciato la cassa degli attrezzi. In un…
- `specchi` — Gli specchi non riflettono te: riflettono i mondi che non ci sono più. In uno di essi, una scheggia luccica a…
- `carovana` — In una terra molto, ma molto lontana, dove la luce del sole risplende ogni giorno...

Dove maghi, attori,…
- `carovana_si`
- `carovana_no`
- `carovana_racconto` — [Qui andranno le cinque tavole disegnate da Bru sulla storia di Jerah — arte non ancora pronta.]
- `giostra_cavalli` — Una giostra di cavalli da picador gira da sola, a luci spente. I cavalli di legno hanno tutti la testa…
- `baraccone_premi` — Un banco di gioco all'ombra delle gradinate: tre bersagli di latta, una pistola a spuntoni incatenata al…
- `premio` — Tre colpi, tre bersagli. Nel silenzio, il banco ti porge un toro di pezza con un occhio solo. Sembra…
- `proscenio` — Sotto l'arco d'ingresso al ruedo c'è uno spiazzo riparato dal vento di sabbia. La fonte è vicina: si sente il…
- `falo` — Il fuoco prende in fretta, piccolo e amico in mezzo a tutto quel fuoco nemico. Qui il fragore dell'arena…
- `falo_notte` — Le braci calano. Qualcuno dovrebbe dire qualcosa, ma il silenzio va bene lo stesso.
- `palco` — Una strana musica latina comincia a inondare la sala, dalle fiamme e dal cumulo di rose si innalza una figura…
- `backstage` — Il callejón dietro la barriera è un intrico di corde e drappi bruciacchiati. In alto, tra le travi di ferro…
- `segreto` — Tra le travi trovi la medaglia della vecchia plaza, incisa con un nome che non riesci a leggere. Nessuno la…
- `boss` — Cosa spinge l'uomo a dare di più? Perché cerchiamo sempre l'approvazione di chi ci circonda? Forse tutta la…
- `sconfitta` — Ti risvegli fuori dalla plaza, la testa che rimbomba come un tamburo. Il disallineamento ti ha risputato…
- `vittoria` — Jerah si spegne senza una parola, gli occhi ancora sulle gradinate vuote. Non c'era più niente da salvare: il…
- `vittoria_eroe` — L'ultimo spettacolo di Jerah finisce così: un inchino vero, il primo da anni, la muleta abbassata nella…

---

# Battute in combattimento e testi di studio

`data/personaggi.json`. Qui stanno le voci dei nemici: quello che si scopre studiandoli, le
battute delle fasi dei boss e il retro delle carte collezionabili.

Quando una voce di `studio` non ha una `domanda` scritta, il gioco ne pesca una a caso da
`data/studio.json`: «Ti ascolto.», «Rivelami i tuoi desideri.», «Fammi capire cosa ti è successo.», «Rispondi.», «È ora di scoprire la verità.», «Giustifica le tue azioni.».

### Fomentado  <sub>`maschera_vuota`</sub>
- *Voce del bestiario:* Un'anima irrequieta spinta al suo limite dalla sua stessa passione, brucia forte, sempre! Finché non rimarrà che cenere.
- **Studia** ▸ «Rispondi.»
  - **Fomentado:** «¡Ándale! ...ándale... Non c'è tempo per fermarsi, lo spettacolo continua!»
- **Studia** ▸ «Fammi capire cosa succede...»
  - **Fomentado:** «¡Soy para todos! ...o para nadie. Pero nunca pararé!»
- *Ogni turno che brucia:* Il fuoco che porta dentro non si spegne mai: un altro pezzo di lui si consuma.
- *Retro della carta collezionabile:* Un folle talentuoso che non ha mai rinunciato ai suoi sogni, un esempio di vita... forse.

### El Muy Bonito  <sub>`giocoliere`</sub>
- *Voce del bestiario:* Una rara bellezza, un campione nella recita, ma il talento a volte può farti uscire fuori di testa.
- **Studia** ▸ «Rivelami i tuoi desideri»
  - **El Muy Bonito:** «¡No me digas lo que tengo que hacer, hombre! Soccombi dinnanzi a me, e brucia come io brucio nel cielo!»
- **Studia** ▸ «Ti ascolto.»
  - **El Muy Bonito:** «Guardatemi! GUARDATEMI!!!»
- *Ogni turno che brucia:* Le fiamme lo consumano un altro po'. Lui ne trae ancora più forza.
- *Retro della carta collezionabile:* Ho sempre voluto un suo autografo! - Fan.

### Oppresso  <sub>`comparsa_di_ruggine`</sub>
- *Voce del bestiario:* La ruggine ha preso il posto della pelle, sta ancora aspettando che il suo turno finisca...
- **Studia** ▸ «(ascolti il suo ultimo ricordo)»
  - **Oppresso:** «Taglia, separa, ricomincia... taglia, separa, ricomincia...»
- **Studia** ▸ «(ascolti ancora)»
  - **Oppresso:** «Acqua, ho bisogno di acqua...»
- *Retro della carta collezionabile:* Timbrava il cartellino anche il giorno in cui il mondo è finito.

### Capocantiere  <sub>`voce_registrata`</sub>
- *Voce del bestiario:* Gestire dieci... cento... no... mille operai insoddisfatti, non dà gratificazione alcuna.
- **Studia** ▸ «[una domanda a caso da studio.json]»
  - **Capocantiere:** «Hey, tu! Torna subito al lavoro!»
- **Studia** ▸ «[una domanda a caso da studio.json]»
  - **Capocantiere:** «Lavorate! Lavorate!»
- *Retro della carta collezionabile:* Urlava ordini anche quando non restava più nessuno ad ascoltarli.

### Emblema dell'oppressione  <sub>`operaio_posseduto`</sub>
- *Voce del bestiario:* Ferraglia tenuta insieme dallo spirito di un lavoratore che non è mai tornato a casa.
- **Studia** ▸ «(ascolti il suo ultimo ricordo)»
  - **Emblema dell'oppressione:** «signor... Kiz..a.. urgh... basta...»
- **Studia** ▸ «(ascolti ancora)»
  - **Emblema dell'oppressione:** «I miei bambini... devo tornare a casa...»
- *Retro della carta collezionabile:* Kizako Industries — dipendente n° illeggibile. Anzianità: eterna.

### Ferraglia Urlante  <sub>`ferraglia_urlante`</sub>
- *Voce del bestiario:* Una montagna di rottami saldati dal dolore. Sembra di sentire le urla di una protesta.
- **Studia** ▸ «(ascolti il suo ultimo ricordo)»
  - **Ferraglia Urlante:** «Non ce la faccio più! Voglio guardare la tivù!»
- **Studia** ▸ «(ascolti ancora)»
  - **Ferraglia Urlante:** «Qualcuno spenga le macchine! Non le sopporto più!»
- *Retro della carta collezionabile:* Non un operaio: un intero reparto, compresso in una cosa sola.

### Il Divoratore  <sub>`divoratore`</sub>
- *Voce del bestiario:* Una macchina che sembra uscita dai sogni di un pazzo, sembra divorare ogni cosa nel suo raggio d'azione, che sia viva o morta...
- **Studia** ▸ «Fa veramente paura...»
  - **Il Divoratore:** «RRRR RRRR»
- **Studia** ▸ «Non c'è nulla da osservare»
  - **Il Divoratore:** «*Rattle*»
- *Retro della carta collezionabile:* Questa macchina ci fornirà nuova energia dai rifiuti! Sono un genio! - Dr. Kizako, Genio Indiscusso

### Ghoul  <sub>`ghoul`</sub>
- *Voce del bestiario:* Carne marcia tenuta insieme dalla fame e da poco altro. Uno dei tanti che la Rocca di Ossidiana non ha mai lasciato andare.
- **Studia** ▸ «[una domanda a caso da studio.json]»
  - **Ghoul:** «Non sembra comprendere ragioni o avere una volontà.»
- *Retro della carta collezionabile:* Non ricorda il proprio nome. Ricorda solo la fame.

### Teschio Errante  <sub>`teschio_errante`</sub>
- *Voce del bestiario:* Un teschio che galleggia basso sull'ossidiana, a scatti, come se cercasse ancora il corpo perduto.
- **Studia** ▸ «[una domanda a caso da studio.json]»
  - **Teschio Errante:** «una cosa molto Metal.»
- *Retro della carta collezionabile:* Vaga da anni. Non ha mai smesso di cercare.

### Abominio Marcio  <sub>`abominio_marcio`</sub>
- *Voce del bestiario:* Più corpi fusi insieme dal marciume, tenuti in piedi da qualcosa che non è più vita. Una delle tante forme che prende la maledizione della Rocca.
- **Studia** ▸ «[una domanda a caso da studio.json]»
  - **Abominio Marcio:** «»
- *Retro della carta collezionabile:* Non è un solo mostro: sono tutti quelli che nessuno è venuto a seppellire.

### Madre in Lacrime  <sub>`madre_in_lacrime`</sub>
- *Voce del bestiario:* Piange lacrime di ossidiana per figli che non tornano, e non lascia avvicinare nessuno a quel dolore.
- **Studia** ▸ «[una domanda a caso da studio.json]»
  - **Madre in Lacrime:** «Lasciate stare i miei figli!»
- *Retro della carta collezionabile:* Nessuno ricorda più i nomi dei suoi figli. Lei sì.

### Stigma  <sub>`stigma`</sub>
- *Voce del bestiario:* Porta incisi sulla pelle i peccati di qualcun altro, marchiato da una colpa che non è la sua.
- **Studia** ▸ «[una domanda a caso da studio.json]»
  - **Stigma:** «Quel che non sai, quel che credi!»
- *Retro della carta collezionabile:* Il marchio non si cancella. Nemmeno con la morte.

### Diabolo  <sub>`diabolo`</sub>
- *Voce del bestiario:* Un piccolo demone da baraccone, cresciuto storto tra le fiamme della Rocca.
- **Studia** ▸ «[una domanda a caso da studio.json]»
  - **Diabolo:** «E' l'ora del male!»
- *Retro della carta collezionabile:* Rideva anche mentre bruciava. Forse rideva soprattutto per quello.

### Sadico  <sub>`sadico`</sub>
- *Voce del bestiario:* Trova piacere nel dolore altrui, l'unico linguaggio che la Rocca gli ha insegnato.
- **Studia** ▸ «[una domanda a caso da studio.json]»
  - **Sadico:** «Viooolenza!»
- *Retro della carta collezionabile:* Alla Rocca ha imparato una sola cosa: far male fa stare meglio.

### Jongo Dongo  <sub>`jongo_dongo`</sub>
- *Voce del bestiario:* Un tempo signore di queste terre. Sacrificò raccolti e famiglie intere per la propria fortuna, e non si è mai pentito: la maledizione delle famiglie in lutto lo ha fatto marcire vivo, ma non lo ha fermato.
- **Studia** ▸ «Che cosa hai fatto...»
  - **Jongo Dongo:** «Chi siete... voi... siete venuti a rubare nella nostra terra?!»
- **Studia** ▸ «Cosa è successo alla gente di queste terre?»
  - **Jongo Dongo:** «Non devo dare spiegazioni e chi vuole farci del male!»
- **Studia** ▸ «Non hai idea delle forze con cui stai giocando...»
  - **Jongo Dongo:** «Sono stato benedetto dalla verità del lungo viaggio!»
- **Studia** ▸ «Del lungo viaggio?»
  - **Jongo Dongo:** «Un piccolo sacrificio per un grande risultato. Voi... non potete capire...»
- *mossa_soglia_hp:* Jongo Dongo batte tre volte il palmo marcio sull'ossidiana: la terra gli restituisce tre ghoul insieme.
- *cura_su_morte_alleato:* Jongo Dongo respira a fondo mentre il ghoul si affloscia: quello che resta del suo servo gli rientra dentro. Recupera %d punti vita.
- *Mossa «?»:* Jongo Dongo affonda l'artiglio marcio con tutto il suo peso.
- *Mossa «?»:* Jongo Dongo cala il bastone dalla pietra marcia: dove tocca, la carne comincia a cedere.
- *Mossa «?»:* "IL VIAGGIO RICHIEDE SEMPRE IL SUO PREZZO!" Il grido vi si conficca dentro più delle unghie.
- *Mossa «?»:* Jongo Dongo si volta verso uno dei suoi ghoul, con la stessa calma di sempre: "Un piccolo sacrificio... per un grande risultato."
- *Mossa «?»:* Jongo Dongo batte il palmo marcio sull'ossidiana: la terra stessa gli restituisce un altro ghoul.
- *Retro della carta collezionabile:* "Un piccolo sacrificio per un grande risultato." Lo pensava anche l'ultima volta.

### Jongo Dongo  <sub>`jongo_dongo_risorto`</sub>
- *Voce del bestiario:* Ormai non rimane altro di lui che un corpo marcito che si muove solo grazie a una volontà misteriosa.
- **Studia** ▸ «[una domanda a caso da studio.json]»
  - **Jongo Dongo:** «»
- *Se lo studi ancora:* Qualcosa sembra risiedere dentro di lui...
- *Retro della carta collezionabile:* "Un piccolo sacrificio per un grande risultato." Lo pensava anche l'ultima volta.

### ???  <sub>`l_immortale`</sub>
- *Voce del bestiario:* Qualcosa che cammina nella cripta, e non si ferma per quanto lo si colpisca. Il suo vero nome è ancora un mistero.
- **Studia** ▸ «[una domanda a caso da studio.json]»
  - **???:** «»

### Sacerdote Folle  <sub>`sacerdote_folle`</sub>
- *Voce del bestiario:* Officiava i sacrifici della Rocca molto prima che Jongo Dongo ne facesse un culto. Recita ancora le sue litanie, anche se non è rimasto nessuno a rispondergli.
- **Studia** ▸ «[una domanda a caso da studio.json]»
  - **Sacerdote Folle:** «Continua a recitare, senza guardarti.»
- *Mossa «?»:* "Per il viaggio!" Il sacerdote colpisce recitando.
- *Mossa «?»:* "Unisciti al raccolto!" Il sacerdote colpisce recitando.
- *Mossa «?»:* "Portatelo da me!" Il sacerdote colpisce recitando.
- *Mossa «?»:* "Non c'è altra strada!" Il sacerdote colpisce recitando.
- *Mossa «?»:* Il sacerdote alza le braccia: un teschio errante risponde al richiamo.
- *Retro della carta collezionabile:* Ha smesso di distinguere la preghiera dalla minaccia. Forse non c'era mai stata differenza.

### Divoratore di Carcasse  <sub>`divoratore_di_carcasse`</sub>
- *Voce del bestiario:* Vive sotto il grande ponte marcio, nutrendosi di ciò che il ponte stesso lascia cadere. La puzza lo tradisce molto prima che si mostri.
- **Studia** ▸ «[una domanda a caso da studio.json]»
  - **Divoratore di Carcasse:** «»
- *Mossa «?»:* Il divoratore azzanna più volte, veloce.
- *Retro della carta collezionabile:* Non ha mai dovuto cacciare: gli basta aspettare sotto il ponte.

### Yara  <sub>`sopravvissuta`</sub>
- *Voce del bestiario:* L'unica sopravvissuta dei cunicoli di Jondoh. Anni a combattere ciò che si muove nel buio, in cerca di una sorella che nessuno le ha mai lasciata cercare davvero.

### Zombie Mostruoso  <sub>`zombie_mostruoso`</sub>
- *Voce del bestiario:* Qualcosa, in questo, ha continuato a crescere anche dopo la morte. Le braccia non sono più della stessa lunghezza.
- **Studia** ▸ «[una domanda a caso da studio.json]»
  - **Zombie Mostruoso:** «Un rantolo profondo, che sembra venire da più bocche insieme.»
- *Retro della carta collezionabile:* Non tutti marciscono allo stesso modo. Alcuni si gonfiano.

### Orrore di Meridia  <sub>`orrore_di_meridia`</sub>
- *Voce del bestiario:* Più corpi che si sono trovati nello stesso posto al momento sbagliato, e non si sono più separati.
- **Studia** ▸ «[una domanda a caso da studio.json]»
  - **Orrore di Meridia:** «»
- *Mossa «?»:* L'orrore sferza con tutte le braccia insieme.
- *Mossa «?»:* Più bocche affondano contemporaneamente.
- *Retro della carta collezionabile:* A Meridia nessuno è morto da solo. Alcuni non se ne sono accorti.

### Titano Zombie  <sub>`titano_zombie`</sub>
- *Voce del bestiario:* La cosa più grande che Meridia abbia partorito dopo la fine. Si ricuce da solo, e non ha mai imparato a fermarsi.
- **Studia** ▸ «[una domanda a caso da studio.json]»
  - **Titano Zombie:** «»
- *Mossa «?»:* Pugno devastante: il colpo si abbatte con tutto il peso della città morta.
- *Mossa «?»:* Il titano spazza l'aria davanti a sé: nessuno resta in piedi comodo.
- *Retro della carta collezionabile:* Nelle parti profonde della città c'è qualcosa che non smette di rialzarsi. Chi l'ha visto non è tornato a raccontarlo due volte.

### Zombie Cittadino  <sub>`zombie_cittadino`</sub>
- *Voce del bestiario:* Era qualcuno, a Meridia, prima del coprifuoco. Ora cammina piano, verso niente in particolare, con tutti gli altri.
- *Retro della carta collezionabile:* Meridia ne ha fatti a migliaia, tutti uguali.

### Infetto Rapido  <sub>`infetto_rapido`</sub>
- *Voce del bestiario:* Non tutti a Meridia sono diventati lenti. Questi corrono ancora, come se stessero ancora scappando da qualcosa.
- *Retro della carta collezionabile:* Corre da anni. Non si è mai fermato a chiedersi perché.

### Marionetta  <sub>`marionetta`</sub>
- *Voce del bestiario:* Legno, fili e un po' di rancore. Qualcuno la muoveva con affetto, una volta.
- *Retro della carta collezionabile:* I fili non li tiene più nessuno. Eppure si muove.

### Ombra del passato  <sub>`ombra_del_passato`</sub>
- *Voce del bestiario:* Un'ombra del passato, vive grazie ai sentimenti repressi di qualcuno che ricorda la persona da cui prende forma con sentimenti negativi.
- **Studia** ▸ «[una domanda a caso da studio.json]»
  - **Ombra del passato:** «»
- **Studia** ▸ «[una domanda a caso da studio.json]»
  - **Ombra del passato:** «»
- **Studia** ▸ «[una domanda a caso da studio.json]»
  - **Ombra del passato:** «»
- **Studia** ▸ «[una domanda a caso da studio.json]»
  - **Ombra del passato:** «»
- *Retro della carta collezionabile:* Le ombre del passato assumono la forma di persone ricordate con odio, parlano di fatti che hanno lasciato dei segni irremovibili nell'anima di qualcuno e sono forti quanto l'odio provato nei confronti di quelle persone.

### Un tenero ricordo  <sub>`tenero_ricordo`</sub>
- *Voce del bestiario:* Una bambola cucita a mano, Non ha un bel aspetto ma sembra essere stata amata. Qualcosa di oscuro si annida tra le cuciture.
- *Voce del bestiario (dopo averlo studiato):* {'richiede_oggetto': 'prova_di_un_forte_amore', 'testo': 'A volte un oggetto può amarti più di quanto chi dovrebbe farlo abbia mai fatto...'}
- **Studia** ▸ «[una domanda a caso da studio.json]»
  - **Un tenero ricordo:** «»
- **Studia** ▸ «[una domanda a caso da studio.json]»
  - **Un tenero ricordo:** «»
- *Quando cede:* Qualcosa, nella bambola, si ammorbidisce. Non è più solo dolore, quello che trema tra le sue cuciture.
- *Mossa «?»:* La bambola spalanca le cuciture e lancia una manciata di spilli.
- *Mossa «?»:* Un lamento terribile riempie la stanza. I cuori di tutti sobbalzano.
- *Mossa «?»:* La bambola si strappa una cucitura da sola, piano. Fa più male a voi che a lei.
- *Mossa «?»:* Dei fili scendono dal soffitto: una marionetta si alza da terra.
- **Leva** «"..."<br>"Lil..."<br>"...Loh?"»
- **Leva** «Un lamento sottile, quasi un sollievo: qualcosa che pesava da anni si è appena alleggerito.»
- *Retro della carta collezionabile:* Una Bambola che ha preso vita dai sentimenti puri di un bambino, a volte l'amore può trasformarsi in qualcosa di pauroso.

### L'ultimo spettacolo di Jerah  <sub>`jerah`</sub>
- *Voce del bestiario:* Un talento unico, forse 1 su 10milioni: il più grande spettacolo che il mondo abbia mai visto, una passione ardente, pericolosamente spenta... Il mondo intero arde, arde teatro del suo ultimo show.
- *Voce del bestiario (dopo averlo studiato):* {'richiede_oggetto': 'biglietto_strano', 'testo': "Sembrerebbe che il suo egoismo vacillasse di fronte all'unica prova di affetto sincero che abbia mai ricevuto. Anche una sola persona può cambiare il destino di un intero mondo grazie a un gesto di affetto."}
- **Studia** ▸ «Rivelami chi sei... Perché fai tutto questo?»
  - **L'ultimo spettacolo di Jerah:** «Cosa ne puoi sapere tu, di me, un pobre hombre che ha sacrificato tutto per dimostrare cosa valeva!»
- **Studia** ▸ «Abbiamo più cose in comune di quanto pensi, tu potresti aiutare a capirmi.»
  - **L'ultimo spettacolo di Jerah:** «¡Pobre hombre! ¡Muere!»
- **Studia** ▸ «Non ti do la colpa di tutto questo, voglio solo capire la tua storia...»
  - **L'ultimo spettacolo di Jerah:** «La mia storia è proprio quello che ha causato tutto questo, questo mondo non merita di essere salvato.»
- **Studia** ▸ «Forse questo mondo no, ma tu sì.»
  - **L'ultimo spettacolo di Jerah:** «...»
- *Studio che lo fa cedere:* [{'domanda': 'Vedo che hai capito quale è stato il nostro errore... Vale la pena... di ricominciare...', 'risposta': 'No. Per me è tardi... Ma cercherò di dare un bel finale a questa storia!'}, {'domanda': 'Vecchio Proprietario del teatro: È stato bello... lavorare con te, sai?...', 'risposta': "Grazie. Osservami, mentre cala il sipario per l'ultima volta, vecchio amico..."}]
- *Quando cede:* Jerah barcolla. "Qué espectáculo... voi due," mormora. L'arena intera trema con lui. Ma non smette di attaccare: "Non posso perdere!"
- *Mossa «?»:* ¡GRAN FINALE! Un muro di fiamme spazza tutta l'arena.
- *Mossa «?»:* ¡Vamos! ... Una folata di vento ardente ti infligge lo status in fiamme.
- *Mossa «?»:* Jerah schiva elegantemente tutti i tuoi colpi.
- *Mossa «?»:* Jerah batte il tacco tre volte: dal fumo sale un Fomentado.
- **Leva** «La medaglia della vecchia plaza ti scivola di tasca e rotola nella sabbia dell'arena. Jerah smette di sorridere.»
- **Leva** «Il biglietto ti scivola tra le dita e plana ai piedi di Jerah. Lui lo raccoglie come si raccoglie una cosa viva. Non dice perché.»
- **Leva** «Il Vecchio Proprietario del teatro scavalca la barriera ed entra nel ruedo, zoppicando. "Sono ancora qui, muchacho. Non me ne sono mai andato."»
- *Retro della carta collezionabile:* Era un giovane promettente, abbandonato da tutti, non mi sono mai pentito di avergli dato una possibilità. - Raphael Genio del Teatro

### Goblin Tipico  <sub>`goblin_tipico`</sub>
- *Voce del bestiario:* Verde, spelacchiato, armato di un bastone che ha trovato per terra. Non ha mai vinto una rissa in vita sua.
- **Studia** ▸ «[una domanda a caso da studio.json]»
  - **Goblin Tipico:** «Grugnisce, e nemmeno troppo convinto.»
- *Retro della carta collezionabile:* Ce ne sono a centinaia su questo pianeta. Nessuno li conta più.

### Slime Infimo  <sub>`slime_infimo`</sub>
- *Voce del bestiario:* Una pozza gelatinosa che si crede un mostro. Ci vuole più tempo a notarlo che a batterlo.
- **Studia** ▸ «[una domanda a caso da studio.json]»
  - **Slime Infimo:** «Non sembra avere nulla da dire. O da pensare.»
- *Retro della carta collezionabile:* Il gradino più basso della catena alimentare di questo pianeta. Forse anche più in basso.

### Tartaruga Innocente  <sub>`tartaruga_innocente`</sub>
- *Voce del bestiario:* Un guscio enorme e un aspetto che mette paura. Non ha mai fatto del male a nessuno.
- **Studia** ▸ «[una domanda a caso da studio.json]»
  - **Tartaruga Innocente:** «»
- *risparmio:* Decidi di lasciarla andare. Non c'era nessuna ragione di combatterla. Sul terreno, dove si trovava, resta una pietra liscia e fredda.
- *Mossa «?»:* La tartaruga si ritira nel guscio.
- *Retro della carta collezionabile:* Vecchia, lenta, spaventosa da guardare. Nient'altro.

### Manifestazione di un sogno  <sub>`manifestazione_di_un_sogno`</sub>
- *Voce del bestiario:* Una forma che non dovrebbe esistere ancora, presa in prestito da un sogno che qualcuno, su questo pianeta, sta ancora sognando.
- **Studia** ▸ «Cosa sei... Non ho mai visto qualcosa di simile...»
  - **Manifestazione di un sogno:** «Lasciati andare... Dormi...»
- **Studia** ▸ «Non riesco più... a ... restare in piedi... devo... scappare...»
  - **Manifestazione di un sogno:** «Sei stato molto bravo, ora riposa... per sempre... insieme a me...»
- *Se lo studi ancora:* La testa ti gira all'improvviso: non sei più in grado di studiare il nemico.
- *Retro della carta collezionabile:* Non tutto quello che si incontra va combattuto. Alcune cose vanno solo evitate.

### Un goblin terribilmente arrabbiato  <sub>`goblin_arrabbiato`</sub>
- *Voce del bestiario:* Non è mai stato bello, forte o rispettato, nemmeno tra i suoi. Il fattore di disallineamento gli ha dato l'unica cosa che gli mancava: qualcuno che lo temesse.
- **Studia** ▸ «Perché tutta questa rabbia?»
  - **Un goblin terribilmente arrabbiato:** «RABBIA! SOLO RABBIA!»
- **Studia** ▸ «Non hai altro da dire?»
  - **Un goblin terribilmente arrabbiato:** «Nessuno mi ha mai ascoltato prima. Perché dovrei parlare adesso?»
- *dialogo_soglia_hp:* Il goblin non accetta il suo destino: con le lacrime agli occhi, tenendo la sua mazza con le dita consunte, ti guarda con un odio indescrivibile. Il cuore di un perdente non vacilla mai. Preparati.
- *mossa_disperazione:* Ultima risorsa del perdente: un attacco suicida, colmo di rabbia.
- *rabbia_su_morte_alleato:* Il goblin arrabbiato ringhia: la morte del suo simile lo fa infuriare ancora di più. Il suo attacco cresce.
- *Mossa «?»:* Richiamo dei suoi simili: urla nella notte, e un goblin tipico risponde alla chiamata.
- *Mossa «?»:* Furia di un goblin: colpisce alla cieca, urlando.
- *Mossa «?»:* Pugno del vile: un colpo sferrato senza il minimo onore.
- *Mossa «?»:* Capriccio del goblin: si mette a battere i piedi e se la prende con tutto quello che ha intorno. Il suo attacco aumenta.
- *Mossa «?»:* Cattiveria innata: ti sferra tre attacchi deboli di fila.
- *Retro della carta collezionabile:* La prima fonte che l'Organizzazione ti manda a estinguere. Non tutte le fonti nascondono una tragedia.

### Veronica  <sub>`veronica`</sub>
- *Voce del bestiario:* La tua allenatrice, e l'amica d'infanzia che non ha mai imparato a dosare la forza.
- **Studia** ▸ «Veronica è stata la mia prima e forse unica amica... non mi ha mai abbandonato fin da quando eravamo piccoli...»
  - **Veronica:** «Hey! Cosa succede? Guarda che io sono qui!»
- *Se lo studi ancora:* Non c'è altro che tu possa capire di lei adesso: è già tutta lì, davanti a te.

