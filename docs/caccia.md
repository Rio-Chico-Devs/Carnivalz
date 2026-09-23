# La caccia ai difetti — 23 settembre 2026

Bru: *«studia bene tutto quello che abbiamo fatto fino ad ora, fai un bug
hunting professionale e documentati oltre sui punti più deboli, mettici tutto
il tempo di cui hai bisogno»*.

Questa pagina dice cosa ho trovato, come l'ho trovato, cosa ho corretto e cosa
no — e anche dove gli strumenti che ho costruito per cercare sbagliavano loro,
perché uno strumento di misura che non si controlla è un'opinione.

---

## In breve

| # | Cosa | Gravità | Da quando | Stato |
|--:|---|---|---|---|
| 1 | **Il colpo dato durante la ricarica colpiva una copia della creatura.** Chi martella il nemico — il modo di giocare che il gioco chiede — non gli toglieva quasi mai vita | **grave** | 21/09 (`884c613`) | corretto, prova, sabotaggio |
| 2 | **Arrivando da un'altra schermata si vedeva la stanza, non il nodo.** Dopo l'allenamento si saltava il risveglio con la Dr. Reika; scelta la prima missione, la scena di Veronica ricominciava all'infinito | **grave** | 22/09 (`54128b2`, mio) | corretto, prova su 18 nodi, sabotaggio |
| 3 | **Il boss del livello dei goblin non si batte.** Livello 6, 1.125 punti vita, in un livello che si gioca al livello 1: un giocatore che attacca e basta gli toglie 4 punti e cade in 15 secondi. Il simulatore del progetto dice «mai» | **blocca il tutorial** | da sempre | **non toccato**: è bilancio, ed è il livello che stai rifacendo |
| 4 | **«Testo più grande» rompeva tre schermate.** Nella pausa spariva **Opzioni** — cioè il posto dove il testo grande si spegne — e «Torna al menu principale»; nel Diario le ultime voci e «Indietro»; nella Sede il pannello di destra usciva dallo schermo | alta (accessibilità) | da sempre | corretto, verificato con la sonda e con gli scatti |
| 5 | **L'icona del menu non si premeva mentre scorre un dialogo**: cliccarla mandava avanti la battuta | media | da sempre | corretto, prova, sabotaggio |
| 6 | **I salvataggi si potevano rovinare.** Il file si azzerava prima di scriverci, l'esito della scrittura non lo guardava nessuno, e non c'era nessuna copia di riserva: un file rovinato era una partita persa | media (raro, ma totale) | da sempre | corretto, prova, due sabotaggi |
| 7 | La pausa che si chiude si prendeva il primo clic per 150 ms | bassa | da sempre | corretto, prova, sabotaggio |
| 8 | **Le prove giravano su Godot 4.4.1**, che senza finestra **misura i caratteri finti**. Il progetto è per la 4.7 | metodo | da sempre | suite passata sulla 4.7; `esegui.sh` avvisa |
| 9 | Minori: `{protagonista}` nella scheda di Veronica nel tecno log (oggi non si vede), una prova che contava gli accessori messi senza guardarli, la colonna della pausa a 5 pixel dal fondo anche a scala normale | bassa | — | corrette o segnalate |

**I due difetti gravi erano tutti e due invisibili alle prove, e per la stessa
ragione: le prove guardavano lo stato, nessuna guardava cosa arrivava davvero.**
Li ha trovati un giocatore finto che gioca con clic veri.

---

## Come ho cacciato

### 1. La versione vera del motore

Il progetto dichiara `config/features = "4.7"`, e le prove girano su 4.4.1 da
sempre — perché era quello che si riusciva a scaricare (`docs/godot.md`). Oggi
la 4.7 si scarica. Suite su 4.7: **verde, 38.228 verifiche**. Su 4.4.1:
37.704. Stesse prove, **524 verifiche di differenza**.

Tutte in una prova sola, quella delle liste del combattimento, e la ragione è
questa:

| a 16 punti | altezza della riga | ascendente | discendente |
|---|--:|--:|--:|
| 4.4.1 senza finestra | **48** | 32 | 16 |
| 4.4.1 con finestra (xvfb) | 23 | 18 | 5 |
| 4.7 senza finestra | 23 | 18 | 5 |

**Godot 4.4.1 senza finestra misura ogni riga alta tre volte il corpo.** Le
larghezze sono giuste (221 contro 222 pixel), le altezze no. Quindi ogni prova
che chiedeva «questo testo ci sta in altezza?» misurava un testo che non
esiste: righe del doppio, liste che credevano di tenere quattro voci invece di
cinque. Erano prove prudenti — sbagliavano per eccesso — ma sbagliavano. Il
commento in `Plancia.adatta_lista`, «a 720p col font di ripiego sono quattro,
non cinque», viene da lì.

Adesso la suite gira sulla 4.7 e `esegui.sh` avvisa se il Godot che si usa è
più vecchio di quello del progetto.

### 2. L'analisi statica

Tutti gli avvisi di GDScript portati al livello di errore, su tutti gli script:
**`scripts/` è pulito.** In `Prove.gd` diciassette divisioni intere (volute) e
una variabile contata e mai letta — che era una prova a metà (voce 9).

Con in più gli avvisi sui tipi non sicuri escono 502 segnalazioni: quasi tutte
`String(qualcosa)` su valori che arrivano dai JSON. È rumore, non difetti. Più
interessanti le 40 **funzioni il cui risultato viene buttato**: fra queste
c'erano la scrittura dei salvataggi e il loro esito (voce 6).

### 3. I dati e i testi

Graffe, accordi `{m|f}`, BBCode aperti e mai chiusi, flag letti e mai scritti
in tutti i file di eventi: pulito. Tranne `{protagonista}`, che compare tre
volte nella scheda di Veronica in `data/tecnolog.json` e che nessuno
sostituisce — il resto del gioco usa `{nome}`. Oggi quella sezione
(«dominatori») non la legge nessuno schermo, quindi non si vede; il giorno che
si mostra, esce la parola fra graffe.

### 4. La sonda dei bordi

Ventiquattro schermate, a scala normale e col testo grande: per ogni scritta
visibile, si guarda se sta dentro lo schermo e dentro il riquadro che la
ritaglia. Riusa le preparazioni di `prove/scatto.sh`, quindi guarda le stesse
schermate che guardiamo con gli occhi. Ha trovato la voce 4, e dopo le
correzioni dice zero dappertutto.

### 5. L'automa

`prove/automa.sh` — **un giocatore che non si stanca**. Parte dallo splash e
gioca con clic e tasti veri: preme quello che trova a schermo, fa scorrere i
dialoghi, entra nelle stanze, combatte. Non chiama nessuna funzione del gioco.

- **esplora**: su ogni schermata sceglie la cosa che ha toccato meno volte lì.
  Così, a giri, prova ogni risposta e apre ogni porta. In combattimento
  attacca come farebbe una persona, e fugge di rado.
- **scimmia**: clic ovunque, anche dove non c'è niente, tasti a caso, pause
  aperte e chiuse, martellate.

Segnala tre cose: ogni **errore** del motore (con la scena, il nodo della
storia e l'ultima azione fatta — sulla 4.7 si può ascoltare il registro degli
errori da dentro, `OS.add_logger`), ogni **blocco** (un minuto di gioco senza
che cambi niente) e ogni **fantasma** (un bottone acceso e visibile che un clic
non raggiunge).

In tutto: **22 giri, 869 minuti di gioco, circa 126.000 azioni.** Col tempo
fisso (`--fixed-fps 60`) e senza finestra, un'ora di gioco dura pochi minuti.

**Errori del motore: zero. Blocchi veri: zero.** Quello che ha trovato:

- girava in tondo sulla sala di proiezione per ventisette minuti → voce 2;
- perdeva il primo goblin trentasei volte su trentasei → voce 1, e poi la 3;
- l'icona del menu coperta durante i dialoghi → voce 5;
- la pausa che ruba il clic → voce 7.

### 6. Il giocatore ideale

Quando l'automa perdeva sempre, la domanda era: è lui che gioca male, o è lo
scontro? Ho scritto il giocatore più semplice possibile — un clic sulla
creatura ogni tre decimi di secondo, e basta — e ho stampato la vita di tutti
ogni secondo. **In cinquanta secondi il goblin non ha perso un punto.** Il
racconto diceva «Colpo critico! Anonimo coglie Goblin Tipico in pieno». Da lì
alla causa, una riga.

---

## I difetti, uno per uno

### 1. Il colpo che colpiva una copia

`Intenzione.gd` tiene da parte il comando dato prima che la ricarica finisca e
lo fa partire appena tocca a te. Per tenerlo, lo copiava:
`comando.duplicate(true)`. Il `true` vuol dire copia **profonda**, e la
documentazione di Godot dice esattamente cosa fa: *«all nested arrays and
dictionaries are also duplicated (recursively)»* (`docs/fonti/godot-4.7-scrivere-e-copiare.md`).
Il comando contiene la creatura bersaglio, che è un dizionario — quindi veniva
copiata anche lei. L'attacco partiva, il danno veniva sottratto, il critico
veniva annunciato: **alla copia.**

Chi martella la creatura dà quasi ogni clic durante la ricarica, quindi quasi
ogni colpo passava dalla coda. In pratica: si colpiva solo aspettando la barra
piena e cliccando una volta. Il contrario di come è disegnato il colpo normale.

**Perché le prove non l'hanno visto:** la prova del comando tenuto da parte
usava DIFESA, che non ha bersaglio. **Correzione:** copia superficiale — si
copia il comando, non la creatura. **Prova:** la stessa, con un attacco dato
durante la ricarica che deve togliere vita al goblin in campo. **Sabotaggio:**
rimesso `duplicate(true)`, la prova dice «il goblin in campo è ancora a 86 su
86: ha colpito una copia».

### 2. La stanza al posto del nodo

Quando si entra in un nodo da un'altra schermata (dal combattimento, dalla
mappa, dal menu), `IngressoNodo` decide il verdetto e lo lascia pronto; la
schermata dei dialoghi, appena nasce, lo raccoglie chiedendolo per
`GameState.nodo_corrente`. Ma per un nodo che sta dentro una stanza,
`nodo_corrente` è **la stanza**: il risveglio in infermeria lascia
`infermeria`, la partenza lascia `sala_proiezione`. Il nome non coincideva, il
verdetto pronto finiva nel cestino, e si rientrava nella stanza — la cui regola
mandava altrove.

- Dopo l'allenamento, invece del risveglio con la Dr. Reika si leggeva
  *«Hey ciao di nuovo, hai dimenticato qualcosa?»*.
- Scelta la prima missione sulla mappa, la sala di proiezione rimandava alla
  scena di Veronica, che riapriva la mappa: **all'infinito**. Il livello dei
  goblin non si raggiungeva.

L'ho introdotto io, nella consegna del 22, quando ho messo i nodi dentro le
loro stanze. **La prova di allora guardava il verdetto in partenza, non cosa
arrivava a schermo.** Correzione: il verdetto si riconosce per nome o per
stanza. Prova nuova: per ognuno dei 18 nodi che stanno in una stanza non loro,
con tutti i flag della stanza accesi, si apre la schermata vera e si guarda
cosa mostra. Sabotaggio: 11 rossi, fra cui il risveglio e la partenza.

### 3. Il boss che non si batte

Non l'ho toccato, e lo dico subito perché è la cosa che conta di più per il
lavoro che stai per fare. `goblin_arrabbiato`: livello 6, 1.125 punti vita,
difesa 14. La scheda dice *«sta sopra la curva apposta, perché il tutorial deve
finire con uno scontro che si ricorda»*. Misurato:

- il giocatore ideale, al livello 1, gli toglie **4 punti** e cade in **15
  secondi**;
- `docs/bilanciamento.md` lo segna come «**mai**»: a nessun livello si vince
  l'80% delle volte andandoci dritto;
- l'automa, dopo la correzione del colpo, vince i goblin, arriva al boss e
  perde ogni volta.

Ha un meccanismo a metà vita (`dialogo_soglia_hp`, e poi un danno fisso), ma a
metà vita non ci si arriva. Com'è oggi, **il livello dei goblin non si finisce
e alla Sede non si arriva giocando.** Nessuna prova se n'era accorta, perché
nessuna prova gioca il boss per davvero. È una decisione tua — la curva, il
boss, o una sconfitta scritta — ed è il momento giusto per prenderla.

### 4. Il testo grande

«Testo più grande» ingrandisce **tutta** l'interfaccia del 25%, quindi lo
schermo utile scende da 1280×720 a 1024×576. Il menu principale e le
collezioni erano già provati a quella scala; **le schermate di gioco no.**

- **Pausa**: la colonna già a scala normale arrivava a 5 pixel dal fondo; col
  testo grande «Opzioni» e «Torna al menu principale» finivano sotto il bordo.
  Opzioni è dove il testo grande si spegne.
- **Diario**: «Organizzazione» e «Indietro» fuori schermo.
- **Sede**: la riga «Dominatori in forza … sotto organico» non andava a capo e
  allargava la colonna oltre il bordo, trascinandosi fuori la scheda.

Correzione della pausa: **si stringe l'aria, non le lettere** — prima quanto
basta della spaziatura fra le voci, poi il margine dentro ogni voce. A scala
normale cambia di due pixel; col testo grande ci sta tutto, e il foglio nero si
allarga della stessa scala perché le voci non finiscano sulla striscia rossa.
Nella Sede le due righe lunghe vanno a capo. Verificato con la sonda e con gli
scatti a tutte e due le scale.

**Un limite che resta:** le linee guida chiedono di più. WCAG 1.4.4 — scritto
per il web, qui lo uso come metro — chiede testo ingrandibile *«up to 200
percent without loss of content or functionality»*. Noi arriviamo al 125%.

### 5. L'icona del menu

`AreaAvanza` è un bottone trasparente grande quanto lo schermo, messo per
ultimo nella scena: è quello che fa andare avanti il testo. Stava sopra
l'icona del menu. Adesso l'icona sta sopra di lui, e si nasconde solo quando il
cartello di un titolo si prende lo schermo.

### 6. I salvataggi

Tre cose, tutte prese dal motore (`docs/fonti/godot-4.7-scrivere-e-copiare.md`):

- aprire in scrittura **azzera il file subito** (*«it is truncated to zero
  length»*): un gioco chiuso in quell'istante lasciava un file vuoto, e nel
  menu la partita diventava «Anonimo, livello 1»;
- Godot ha già il rimedio, `OS.set_use_file_access_save_and_swap`: si scrive
  su un file temporaneo accanto e lo si scambia col vero solo alla chiusura —
  `rename()` su Linux, `ReplaceFileW` su Windows, ritentato fino a mille volte
  se un antivirus tiene il file. **Non si poteva fare a mano con un rename:** su
  Windows `DirAccess.rename` prima cancella la destinazione e poi sposta, e in
  mezzo il file non c'è;
- `store_string` dice se è riuscita, e nessuno lo guardava.

Adesso c'è `scripts/FileSicuro.gd`: scrive accanto e scambia, rilegge per
controllare, e tiene la versione di prima come **riserva**. Se il file
principale non si legge, si riprende la riserva: si perde un salvataggio, non
la partita. E se il disco non scrive, la Sede lo dice al giocatore invece di
lasciargli credere che la partita sia al sicuro.

### 7. La pausa che ruba il clic

Il commento in `Pausa.chiudi` diceva «il velo smette di prendere i clic
nell'istante in cui chiudi». Il velo sì; il contenitore delle voci e
l'istantanea sfocata no — i contenitori e le immagini di Godot, di loro,
lasciano passare il mouse ma lo *prendono*. Per i 150 ms della dissolvenza il
primo clic dato al gioco finiva a loro.

---

## Anche l'automa sbagliava

Cinque falsi allarmi, tutti suoi, prima che le sue segnalazioni valessero
qualcosa. Li scrivo perché sono gli stessi errori che fa chi prova a mano:

1. **I nomi che Godot inventa** (`@Button@17`) cambiano a ogni apertura: per
   l'automa ogni campo di testo era una cosa mai vista, e ci restava incollato.
2. **Una memoria senza pagine**: contava «ESC» come una cosa sola in tutte le
   pagine, e girava in tondo fra EXTRA e la pagina del codice per dieci minuti.
3. **La mira**: calcolava il centro dei bottoni senza contare il livello della
   pausa, le rotazioni e la scala del testo grande. Dava per coperti bottoni
   perfettamente premibili. (È stato proprio sbagliando la mira col testo
   grande che ho visto che il testo grande rompeva la pausa.)
4. **La fretta**: mirava le scelte mentre stavano ancora entrando.
5. **L'anello**: partendo da un punto della storia era lui la scena corrente,
   il primo cambio di scena lo liberava, e ogni suo passo diventava un errore
   che lui stesso registrava. **Un file di registro da tre gigabyte**, prima del
   tetto a trenta errori.

E una cosa che l'automa fa apposta: **mette da parte le tue opzioni e le tue
partite prima di giocare, e le rimette alla fine.** La prima volta ha acceso il
testo grande e l'alto contrasto e li ha salvati — e gli scatti fatti dopo erano
tutti a testo grande senza che nessuno l'avesse chiesto.

---

## I punti deboli, e cosa dicono le fonti

### Le prove guardano lo stato, lo schermo no

È la terza volta che lo scrivo (`docs/processi.md`, «Non noto alcun
cambiamento»; `docs/tutorial.md`, sezione 5). Oggi due difetti gravi su due
erano di questo tipo. La risposta non è un'altra regola da ricordare: è far
giocare qualcuno. **Prima di ogni zip, un giro dell'automa** — dal menu fino a
dove arriva la storia — costa pochi minuti e avrebbe preso tutti e due.

### Le creature sono dizionari

In combattimento una creatura è un `Dictionary`, e un dizionario si porta in
giro per riferimento. Basta una copia profonda in un punto qualunque perché
due parti del gioco parlino di due creature diverse credendo di parlare della
stessa — e niente si rompe, niente dà errore: il danno va da un'altra parte.
Oggi nel gioco non c'è più nessuna copia profonda (le ho cercate tutte). A
lungo andare la difesa vera è che una creatura sia **un oggetto**, non un
valore: è un cambio grosso, e non l'ho fatto.

### Due significati per «dove sei»

`GameState.nodo_corrente` vuol dire a volte il nodo, a volte la stanza. Il
difetto 2 è nato esattamente lì. La correzione lo tampona in un punto; la cosa
pulita sarebbe tenere due nomi per due cose.

### Il salvataggio

Vedi sopra. Resta aperta una cosa: nel menu, una partita ripresa dalla riserva
non lo dice. Si carica e basta.

### Il testo grande

Vedi sopra: 125% contro il 200% di WCAG. Le *Xbox Accessibility Guidelines*
(la 101, sul testo) dicono la stessa cosa del 200% **secondo la sintesi di una
ricerca web**: la pagina da qui non si apre, quindi non la cito come letta.

### La versione del motore

Il verde valeva su un Godot che non è il tuo e che misurava il testo in modo
finto. Adesso è il tuo.

---

## Cosa resta aperto

1. **Il boss dei goblin** (voce 3) — tua, e dentro il livello che stai rifacendo.
2. Testo grande oltre il 125%.
3. La partita ripresa dalla riserva non lo dice.
4. `{protagonista}` in `tecnolog.json`: da decidere quando la sezione
   «dominatori» si mostrerà.
5. L'automa non arriva ancora alla Sede, per via del boss. Quando il boss si
   batterà, il giro «dal menu alla Sede» diventa una prova vera.

---

## Fonti

Lette alla fonte, e salvate in `docs/fonti/`:

- il sorgente di Godot 4.7 — `FileAccess`, `OS`, `DirAccess`, `Dictionary` e i
  driver dei file (`godot-4.7-scrivere-e-copiare.md`);
- WCAG 2.2, criterio 1.4.4 (`wcag-1.4.4-ridimensionare-il-testo.md`).

**Non lette** (bloccate da questa rete): le *Xbox Accessibility Guidelines*,
le *Game Accessibility Guidelines*, e i paper sul test automatico dei giochi.
L'automa è costruito senza di loro: la sua regola — su ogni schermata, la cosa
toccata meno volte — è mia, non una tecnica citata.

---

*La caccia · 23 settembre 2026 · ramo `claude/inizio-progetto-dya2lr`*
