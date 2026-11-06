# I giochi dei pianeti: una proposta

> Bru: «ho avuto un'idea, in alcuni pianeti potrai fare dei minigiochi come
> quelli che vedi nelle ads del telefono che però poi risultano false e ti
> costringono a giocare quei noiosi giochi di match, per esempio, in
> determinati pianeti potrai spendere soldi e risorse per fare upgrade a delle
> basi tipo tower defense, il plot è che a un certo punto dopo i tuoi successi
> l'organizzazione ti permetterà di organizzare insediamenti e resistenze su
> alcuni pianeti, poi avremo anche giochi di raccolta, oltre che puoi trovare
> pianeti con materiali da prelevare possiamo farlo interagibile come garden
> scapes, ma solo la parte in cui accumula risorse e apre cancelli per avanzare
> e automatizza le raccolte»

E prima ancora, quando sono nati i pianeti del Vuoto (`scripts/Vuoto.gd`):

> «metteremo dei pianeti intorno a ogni vuoto, che sono visitabili per
> acquisire nuove risorse tramite videogiochi, potrei trovarci collezionabili,
> oggetti, minerali, tazo e risorse per l'organizzazione»

È una **proposta**: nel gioco non cambia niente. Le tavole sono disegnate nella
lingua del Vuoto. Nomi, testi e numeri sono miei, d'esempio.

Bru, sul primo giro: «ok ma i giochi devono essere fatti meglio di come sono ora
e dobbiamo renderli leggermente diversi». Il **secondo giro** è il §8: ogni gioco
ha una decisione vera e un'idea nostra, e le tavole sono rifatte.

    ./prove/proposte_pianeti.sh     le nove tavole, in scatti/proposte_pianeti/

---

## 1. In una riga

I pianeti delle risorse **ci sono già**: girano intorno al Vuoto Ardente, hanno
la sonda che trova giacimenti (`scripts/Sonde.gd`), e la loro scheda dice
«Esplorazione in arrivo». Manca il gioco. La proposta prevede **tre specie di
pianeta**, ognuna col suo gioco. Tutte e tre passano per **le riserve**, così
si risponde anche alla decisione rimasta in sospeso dall'8 ottobre
(`docs/da_fare.md`: dove si vedono, a cosa servono, se hanno un tetto).

| | la raccolta | la resistenza | le pubblicità |
|---|---|---|---|
| **cos'è** | Gardenscapes, solo la parte che accumula | una tower defense | i giochi che le pubblicità promettono |
| **dove si gioca** | sul tavolo della Sala operativa | sul tavolo della Sala operativa | sul data pad, in verticale |
| **quando arriva** | da subito | dopo il primo Carnivalz spento | quando trovi il pianeta |
| **prende dalle riserve** | minerali, tazo (cancelli, macchine) | minerali, tazo, Organizzazione | niente |
| **dà alle riserve** | minerali, materiali | Organizzazione, tazo | tazo, collezionabili |

Le due che si comandano stanno sul **tavolo della Sala operativa**: stesso fondo,
stesse schede a destra, stesse etichette del Vuoto. Non ci vai di persona: comandi
da lì, come dalla mappa stellare. Solo le pubblicità escono dal tavolo, perché
il loro posto è un telefono, e il telefono del gioco è il data pad.

## 2. La raccolta (tavola 1)

*Il primo giro. Le novità del secondo sono nel §8.*

**Cosa si vede.** La superficie del pianeta come un plastico. Ci sono dei
**campi** dal contorno storto, alzati da terra come le radure delle Pianure. Fra
un campo e l'altro c'è un sentiero, e su quasi ogni sentiero un **cancello**. I
campi chiusi sono solo un contorno tratteggiato col punto di domanda. Nel campo
d'atterraggio c'è **il modulo**: da lì quello che raccogli parte per le riserve.

**Il giro.**

1. Nei campi aperti ci sono le **vene**. Una vena piena ha il giro arancio:
   clic, e dà quello che ha (+6 minerali). Poi si ricarica, piano.
2. Un **cancello** costa riserve (40 minerali e 300 tazo). Aperto, fa vedere un
   campo nuovo, con vene diverse: ferro dopo il quarzo, materiali per
   l'Artigiano, a volte un oggetto.
3. Su una vena si costruisce una **macchina**: la trivella raccoglie da sola
   fino a riempirsi (18/30), il nastro porta tutto al modulo. Migliorandola,
   raccoglie più in fretta e tiene di più.
4. In fondo all'ultimo cancello c'è **un segreto**, come quelli del Vuoto: un
   oggetto unico o un collezionabile, una volta sola.

**Le macchine sono la sonda.** È la cosa che lega la proposta al gioco di oggi.
Adesso la sonda di un pianeta trova un giacimento ogni 8-20 minuti di gioco e
ne tiene da parte al massimo tre (`ogni_minuti`, `massimo`, `giacimenti` in
`mappa.json`). Ogni macchina costruita **cambia questi numeri**: più spesso, più
giacimenti tenuti, una risorsa nuova nella tabella. L'automazione non è un
sistema nuovo: è quello che c'è già, che migliora. «Estrai le risorse» dal Vuoto
resta com'è.

**Da Gardenscapes prendo** l'accumulo, i cancelli e l'automazione, come ha
chiesto Bru. **Non prendo** il match-3, l'arredamento, le stelle per livello e
la storia della villa.

**Il tempo è tempo di gioco**, come per le sonde (`GameState._process`, che con
la pausa si ferma): una vena si ricarica mentre giochi, anche altrove. Non conta
l'orologio vero. Niente «torna fra quattro ore».

## 3. La resistenza: insediamenti e resistenze (tavola 2)

*Il primo giro. Le novità del secondo sono nel §8.*

**La trama c'è già nel canone** (`docs/storia.md`, «Le unità»). L'Organizzazione
è divisa in unità, e un'unità è «una struttura da difendere». Ogni unità deve
tenere in casa **un numero minimo di dominatori**. Le **forze militari** fanno i
turni sul perimetro e non hanno il fattore Carnivalz. E il Vuoto attira «mondi
che cominciano a essere infettati».

La proposta segue quella trama.

1. Dopo i tuoi successi (propongo: **il primo Carnivalz spento**, quello di
   Jerah) arriva un messaggio sul data pad, come la quota dei 3000 tazo. Ha il
   tono dell'Organizzazione: «A seguito dei risultati ottenuti, le è affidato il
   comando di un avamposto».
2. Alcuni pianeti del Vuoto che l'infezione sta raggiungendo diventano posti
   dove aprire **un avamposto**.
3. Sul pianeta si apre una frattura piccola, e dalla frattura escono le creature
   del Vuoto (lo stesso bestiario degli scontri, in piccolo).

**La mia lettura di «insediamenti e resistenze»** (da confermare):

- **l'insediamento** è l'avamposto che fondi su un pianeta ancora sano: lo
  costruisci, lo migliori, ogni tanto viene messo alla prova;
- **la resistenza** è su un pianeta già toccato, dove c'è gente che resiste da
  sola. Tu la rifornisci e la difendi: gli assedi sono più duri, ma salvi persone,
  e questo fa storia.

**Il gioco.** Una tower defense a **piazzole fisse**. Ci sono la frattura, la
strada che serpeggia fino all'avamposto, i posti dove costruire, le ondate. Le
torri sono **le forze militari**, non dominatori:

- **la postazione** colpisce uno alla volta, lontano;
- **il mortaio** colpisce in un'area;
- **la rete** rallenta.

Ogni torre si migliora con minerali e tazo; si smonta e restituisce una parte di
quello che è costato. Le **risorse per l'Organizzazione** servono per le cose
grosse: aprire un avamposto nuovo, alzare le mura, sbloccare una piazzola.

**Il dominatore di turno.** È la regola del canone (il numero minimo di
dominatori) fatta gioco. Durante l'assedio un compagno del party sta
sull'avamposto come **pedina con una mossa sola**, del suo elemento, una volta
per ondata. Nella tavola è Yhvina. È il punto in cui la tower defense tocca il
gioco grande: chi scegli conta.

**Tempo reale, con la pausa e la velocità doppia.** La tower defense vive di
quello. Le raffiche dello scontro sono già in tempo reale. In pausa si costruisce
e si migliora.

**Gli assedi aspettano.** Arrivano come i giacimenti: un messaggio dice
«l'avamposto è sotto pressione», e l'assedio aspetta che tu vada. **Perdere non
toglie quello che hai costruito**: le mura vanno giù e si riparano spendendo.

**Cosa dà.**

- Tazo e **risorse per l'Organizzazione**.
- **Un soldato come Aiutante** negli scontri, finché l'avamposto tiene: la voce
  «Aiutante» del menu dello scontro c'è già.
- **Storia**: la gente salvata. Qualcuno, più avanti, si ricorda di te.

## 4. Le pubblicità (tavola 3)

*Il primo giro. Le novità del secondo sono nel §8.*

**La mia lettura.** Le pubblicità dei giochi da telefono mostrano giochini
furbi: tira il perno, la torre dei numeri, le porte che moltiplicano. Poi scarichi
il gioco, e il gioco è un altro: un match-3 noioso. Qui quei giochini **esistono
davvero**, e sono belli proprio perché sono semplici: trenta secondi a livello.

**Il pianeta.** Propongo **«il pianeta che promette»** (nome provvisorio), un
mondo fatto di pubblicità. La fonte del suo Carnivalz era qualcuno che ha passato
la vita a girare pubblicità di giochi che non esistevano, e il Carnivalz gliele
ha fatte diventare vere. Dentro c'è **l'omino che sbaglia apposta**, ogni volta,
da sempre: quello che nelle pubblicità finisce nella lava perché tu pensi «io
avrei fatto meglio». Il premio finale è **salvarlo**. È uno scherzo amaro, nel
tono del gioco: il Carnivalz è «una festa per chi ha subito ingiustizie».

**Il telefono è il data pad.** Trovato il pianeta (è nascosto, come le fratture
nascoste: compare con un oggetto o un flag), comincia a mandarti **pubblicità
nei messaggi**: «Il 90% sbaglia! Tu no?». Lo scherzo passa per la sezione
Messaggi che c'è già. Il gioco si apre sul data pad tenuto in verticale, coi
colori sguaiati di una pubblicità, apposta fuori dalla tavolozza del gioco.

**I cinque giochi** sono i classici delle pubblicità.

1. **Tira il perno.** Oro, lava, acqua, mostri dietro dei perni: l'ordine giusto
   porta il tesoro all'omino.
2. **La torre dei numeri.** Hai un numero e mangi solo chi ha un numero più
   piccolo, poi cresci.
3. **Le porte.** Una folla che corre sceglie fra ×2, +10, −5, e alla fine si
   scontra con la folla nemica.
4. **Disegna la linea.** Un tratto per proteggerlo dalle api per dieci secondi.
5. **Scegli quello giusto.** Tre oggetti, una situazione, uno solo salva.

**La satira sta nella cornice, non nel gioco.** La scritta che urla, la mano che
indica la mossa sbagliata, la crocetta finta in alto, «GIOCA ORA» che non porta
da nessuna parte («non c'è niente da scaricare: si gioca qui»). C'è anche uno
**scherzo grosso**, se lo vuoi: una volta sola il pianeta fa il bidone. Parte un
match-3 noioso, e dopo tre secondi l'omino lo rompe.

**Cosa dà:**

- tazo a ogni livello;
- **i collezionabili** che le sonde non trovano (sono unici: si trovano giocando,
  dice già `Sonde.gd`);
- alla fine, l'omino salvo.

## 5. Il giro delle riserve (tavola 4): la risposta a `da_fare.md`

| risorsa | da dove viene | dove va |
|---|---|---|
| **minerali** | raccolta, sonde | cancelli e macchine della raccolta; torri e mura degli avamposti |
| **risorse per l'Organizzazione** | avamposti che tengono, alcune sonde | aprire avamposti, le migliorie grosse, merce nuova all'Emporio |
| **tazo** | tutto | tutto (resta la moneta di sempre) |
| **materiali per l'Artigiano** | i campi più lontani della raccolta | la bottega dell'Artigiano, che «crafta dalle cose che raccogli» |
| **collezionabili** | le pubblicità, i segreti | l'Album |

Le tre domande di `da_fare.md`:

- **Dove si vedono.** Una pagina «Riserve» nel data pad, i numeri in alto nel
  Vuoto accanto ai tazo, e nella barra di ogni gioco dei pianeti (le tavole la
  disegnano in alto a destra).
- **A cosa servono.** Vedi la tabella. Tornano al gioco grande in quattro modi:
  merce all'Emporio, materiali all'Artigiano, Aiutanti negli scontri, storia.
- **Il tetto.** Le riserve non ce l'hanno: sono i tuoi risparmi. I tetti stanno
  nelle macchine e nelle sonde (c'è già: `massimo`), e si alzano migliorandole.

## 6. Cosa non prendiamo dai giochi da telefono

- l'orologio vero e il «torna fra quattro ore»: qui conta il tempo di gioco;
- le vite, l'energia, le attese, i video per continuare;
- una seconda moneta da comprare, o un muro di difficoltà per venderti un aiuto;
- perdere quello che hai costruito.

La presa in giro resta nella finzione: sono i giochi a essere veri.

## 7. Come si farebbe, quando si decide

- `mappa.json`: un pianeta col suo gioco dice `"gioco": {"specie": "raccolta",
  "dati": "res://data/pianeti/<id>.json"}`. `file_eventi` resta per chi si
  esplora a eventi, come una frattura.
- `Vuoto._su_conferma`: un pianeta col `gioco` apre la sua scena; i giacimenti
  pronti si estraggono come oggi.
- Tre scene (`scenes/pianeti/Raccolta.tscn`, `Resistenza.tscn`,
  `Pubblicita.tscn`), coi numeri in `data/pianeti/`.
- Lo stato (campi aperti, macchine, avamposti) accanto a quello delle sonde in
  `GameState.sonde`, che si salva già.
- L'ordine che propongo:
  1. **la raccolta**: è la più piccola, chiude la decisione delle riserve e usa
     le sonde;
  2. **le pubblicità**: giochi chiusi in sé, uno alla volta;
  3. **la resistenza**: è la più grande, e ha bisogno della trama.

## 8. Il secondo giro: meglio, e un po' diversi

> Bru: «ok ma i giochi devono essere fatti meglio di come sono ora e dobbiamo
> renderli leggermente diversi»

L'ho letto così: i giochi da telefono a cui somigliano sono fatti male, e i
nostri non devono esserne la copia. Il difetto è sempre lo stesso: **non c'è
niente da decidere**. Si tira il perno che si vede, si mangia il più piccolo, si
sceglie il numero più grande. Ogni gioco adesso ha **una decisione vera**, e
**un'idea nostra** presa da quello che Carnivalz ha già: lo stress, la speranza,
gli elementi, lo Studio. Ho cambiato anche i nomi, così si vede che sono un'altra
cosa.

**Le due cose che valgono per tutte e cinque le pubblicità** (tavola 3):

- **La mano.** La pubblicità vuole vederti sbagliare. In ogni gioco c'è la sua
  mano, con un anello rosso che si riempie mentre esiti: pieno, gioca lei, e
  gioca la mossa sbagliata. Più vai avanti, meno aspetta. È il cattivo del
  pianeta, e dà un po' di fretta a giochi che altrimenti sarebbero solo pazienza.
- **L'omino ha lo stress e la speranza**, come i personaggi degli scontri. È lo
  stesso in tutti e cinque. Ogni sbaglio gli dà stress: con lo stress alto trema,
  un perno gli scivola, il corteo si sparpaglia. Ogni vittoria gli dà speranza:
  piena, all'ultimo livello esce dalla pubblicità.

**I cinque**, ognuno con la sua tavola (3a-3e): il gioco in grande, a sinistra
cosa cambia, a destra i tre passi della soluzione.

| di solito | cosa non va | il nostro | la decisione vera |
|---|---|---|---|
| tira il perno | un ordine giusto solo, si vede subito | **i perni**: le sostanze si mescolano (acqua sulla lava fa pietra, gelo sull'acqua ghiaccio, lava sul ghiaccio vapore) | quale miscela ti serve, e in che ordine; spesso le strade sono due e una vale più tazo |
| la torre dei numeri | mangi sempre il più piccolo e vinci | **la torre che cresce**: i mostri crescono di uno a ogni tua mossa, le pozioni moltiplicano, le trappole dimezzano, le stanze al buio si guardano con le occhiate | l'ordine: la pozione presa subito fa perdere, presa per ultima fa vincere |
| le porte che moltiplicano | scegli il numero più grande | **il corteo**: tre elementi in cerchio (fuoco batte natura, natura acqua, acqua fuoco), e chi batte vale doppio | diventare l'elemento che batte chi ti aspetta in fondo, anche con meno gente |
| disegna la linea | un muro a caso, decide la fisica | **il tratto**: tre secondi per vedere da dove arrivano, l'inchiostro è poco e quello che avanza diventa tazo, il tratto si crepa a ogni colpo | dove mettere poco inchiostro, nel posto giusto |
| scegli quello giusto | si tira a indovinare | **la prova**: c'è sempre una ragione nella scena (il mostro ha la chiave al collo), e uno studio per livello dice com'è fatto un oggetto | guardare bene, e spendere lo studio dove serve |

Gli esempi delle tavole tornano coi numeri. Nella torre: 9 mangia il 4 (13, gli
altri crescono), l'occhiata trova un 8 (21), la pozione per ultima porta a 42
contro un 33. Se prendi la pozione per prima finisci a 32 contro 33. Nel corteo:
×2 natura (10), l'acqua diventa natura (18), e 18 che vale doppio fa 36 contro 30.
Il +10 fuoco che indica la mano porterebbe 22 fuochi contro un muro d'acqua.

**La raccolta** (tavola 1), con due cose nuove:

- **Il polso.** Una vena pronta batte. Cliccata sul battito dà la metà in più
  (+9 invece di +6). Raccogliere non è più solo cliccare: è cliccare bene.
- **Il bivio.** Il Cratere costa 100 minerali, oppure 30 col ferro delle Forre.
  Puoi pagare tanto e subito, o fare prima le Forre e pagare meno.

**La resistenza** (tavola 2), con due cose nuove:

- **I soldati hanno lo stress.** Non hanno il fattore Carnivalz: quando un mostro
  grosso passa vicino, chi è dentro la postazione si spaventa e spara più piano
  (l'anello rosso intorno alla torre; a 70 trema). La mossa del dominatore di
  turno li calma. Le mura che cadono li spaventano tutti.
- **Gli elementi e le resistenze degli scontri.** Le torri hanno un elemento (il
  mortaio è fuoco, la rete è gelo) e i mostri sono quelli del bestiario, con le
  loro immunità. «IN ARRIVO» dice chi viene, e quello che hai **studiato** in
  scontro c'è scritto: «ABOMINIO: IMMUNE AL FUOCO». Le torri si scelgono
  sull'ondata, non una volta per tutte.

## 9. Le domande per Bru

1. **Il secondo giro** (§8): le novità di ogni gioco ti piacciono? Ce n'è una
   che toglieresti, o una che spingeresti di più?
2. **Pubblicità**: ho capito bene, sono i giochini che le pubblicità mostrano,
   fatti veri? E lo scherzo del match-3 che parte e si rompe, una volta sola, sì
   o no?
3. **Insediamenti e resistenze**: va bene la mia lettura (l'insediamento lo
   fondi su un pianeta sano, la resistenza la sostieni dove c'è già gente che
   resiste)?
4. **Tower defense**: tempo reale con la pausa (la mia proposta) o a turni?
5. **Il dominatore di turno**: un compagno del party sull'avamposto con una
   mossa sola durante l'assedio, ti piace?
6. **Quando** l'Organizzazione ti affida il primo avamposto: dopo Jerah?
7. **Raccolta**: va bene tempo di gioco e non orologio vero? E le macchine che
   migliorano la sonda di quel pianeta?
8. **Da quale** cominciamo? Io direi la raccolta.

## Le tavole

- `1_raccolta.png`: la Piana di Quarzo aperta, la vena che batte (+9 al polso),
  la trivella col nastro verso il modulo, il cancello per le Forre apribile
  (arancio) e quello per il Cratere che costa meno col ferro.
- `2_resistenza.png`: l'ondata 3 di 8; la postazione scelta col suo raggio e lo
  stress a 70, il mortaio di fuoco che l'abominio non sente, la rete di gelo, tre
  posti liberi; le mura a 14/20, Yhvina che calma i soldati, e il messaggio
  dell'Organizzazione.
- `3_pubblicita.png`: i cinque giochi sul data pad, la mano e l'omino.
- `3a_perni.png` … `3e_prova.png`: un gioco per tavola, in grande, coi tre passi
  della soluzione a destra.
- `4_il_giro.png`: le tre specie intorno alle riserve, cosa entra (pieno) e cosa
  esce (tratteggiato), e cosa torna al gioco grande.
