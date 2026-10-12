# La revisione profonda — 9 ottobre 2026

Bru, prima di provare il gioco: *«lancia una review deep di quello che abbiamo
fatto fino ad ora, dobbiamo essere sicuri non ci siano punti morti, punti in cui
sei bloccato, deadlock o altri problemi».*

Qui c'è cosa ho guardato, come, cosa ho trovato e cosa no. E dove gli strumenti
non arrivano, perché un «tutto a posto» senza i suoi limiti è un'opinione.

---

## In breve

| # | Cosa | Gravità | Stato |
|--:|---|---|---|
| 1 | **Il primo giorno si poteva bloccare per sempre.** In sala comunicazioni, dopo la chiamata di Veronica, accanto ad «Apri il data pad» c'era il tasto della mappa. Chi lo premeva ritrovava la sala già «dopo», con solo «Torna alla mappa»: il data pad non tornava più, la sala di proiezione restava chiusa e la prima missione non partiva mai. Prima di qualunque salvataggio: partita da ricominciare | **blocca il gioco** | corretto, prova, tre sabotaggi |
| 2 | **Scelte a tempo scadute tutte = schermata senza niente da premere.** Oggi nessun nodo usa scelte a tempo; quando arriveranno coi tuoi dialoghi, un nodo con solo scelte da eroe e da villain lasciate scadere sarebbe rimasto fermo | latente | corretto nel motore, più una regola sui dati, prova, sabotaggio |
| 3 | **Il Vuoto poteva diventare sordo.** Se una frattura non si apriva (file rotto), la guardia contro il doppio clic restava accesa e nessun altro clic funzionava | bassa (solo con dati rotti) | corretto, prova, sabotaggio |
| 4 | **L'icona della Guida sbiadita ma accesa.** Mentre si legge sta sotto l'area del testo (voluto), ma per il motore era un bottone acceso: 14 «fantasmi» per l'automa | bassa | ora è disabilitata mentre si legge; prova, tre sabotaggi |
| 5 | **Il cursore che sparisce sul menu** (lo hai visto tu). Il gioco non lo nasconde mai; Godot su Windows non lo riaccende se qualcosa da fuori lo spegne e la forma non cambia, e sul menu non cambia mai | fastidiosa | il gioco ora glielo ridice da sé; prova, otto sabotaggi. La causa esterna non l'ho vista |

E quello che **non** ho trovato, cercandolo:

- nessun'altra prigione e nessun altro punto morto in 11 zone su 12, esplorate fino in fondo;
- nella Casa Gigante, la dodicesima, nessuno nelle 900.000 situazioni guardate (non è esaustiva: vedi sotto);
- nessuna attesa (`await`) che possa restare appesa e bloccare il gioco;
- nessun ciclo che possa girare all'infinito;
- nessuna guardia «sto partendo» che resti accesa, a parte quella del Vuoto (voce 3);
- nessuno scontro senza fine nei dati;
- l'automa: zero errori e zero blocchi in tutte le fratture, giocate con clic veri.

---

## Come ho cercato

### 1. L'esploratore: tutte le strade, non una

Lo strumento nuovo di questa revisione è `prove/Esploratore.gd` (`./prove/esplora.sh`).

Le prove che c'erano guardano **un nodo alla volta**: ha un'uscita? La
destinazione esiste? L'automa gioca **una partita alla volta**. Nessuno dei due
vede un punto morto fatto di due nodi giusti messi nell'ordine sbagliato. Il
difetto 1 era esattamente così: ogni nodo, preso da solo, era a posto.

L'esploratore gioca **ogni combinazione**:
- ogni scelta visibile;
- ogni stanza della mappa in cui si entra;
- ogni scontro vinto, perso e fuggito;
- ogni agguato che scatta e che non scatta;
- ogni dialogo coi compagni che accende un flag.

Ogni situazione nuova (dove sei, più quello che conta di ciò che sai) se la
ricorda. Alla fine chiede, all'indietro, di ognuna:

- **prigione**: da qui non si esce più dalla zona;
- **punto morto**: da qui la zona non si finisce più, nemmeno uscendo e rientrando, perché un flag perso resta perso;
- **errore**: una strada che finisce dove il gioco non sa dove mandarti (la rete di sicurezza, un nodo che non c'è, una mappa senza niente da premere).

**Usa le regole del gioco, non una copia.** Per poterlo fare ho portato fuori da
`Main.gd` e da `MappaZona.gd` le regole che decidono:

| regola | funzione | prima stava in |
|---|---|---|
| quali scelte si vedono | `IngressoNodo.scelta_visibile` | `Main.ricostruisci_scelte` |
| cosa fa una scelta | `IngressoNodo.effetti_della_scelta` | `Main._su_scelta` |
| dove si cammina sulla mappa | `IngressoNodo.raggiungibile` | `MappaZona.si_puo_andare` |
| in quali stanze si entra | `IngressoNodo.si_entra` | `MappaZona._su_stanza` |

Il gioco ora chiama queste funzioni, e l'esploratore chiama le stesse. Il
comportamento è identico: la suite intera lo conferma. Di passaggio due funzioni
di `Main` sono scese sotto il tetto di complessità, e le loro eccezioni sono
state tolte dalla prova sulla struttura.

**Le zone si giocano in fila, come le gioca chi gioca.** Il primo giorno parte da
una partita nuova; le Pianure da come finisce il primo giorno; la Sede, il Vuoto
e le fratture da come finiscono le Pianure. La meta di una frattura è quello che
il resto del gioco le chiede in `mappa.json`: i flag per l'anomalia e per le
fratture nascoste. Un game over dentro una frattura riporta al salvataggio della
Sede, e da lì si rientra.

| zona | situazioni | esito |
|---|--:|---|
| il primo giorno (complesso) | 110 | **50 prigioni prima della correzione**, poi pulito |
| Pianure di Redenna | 9.606 | pulito |
| la Sede | 32 | pulito |
| il Vuoto Ardente (anomalia) | 1.100 | pulito |
| Squarcio Industriale | 350 | pulito |
| Teatro del Passato | 13 | pulito |
| Cunicoli di Jondoh (Rocca) | 2.995 | pulito |
| Meridia | 568 | pulito |
| Qualcosa preme | 2 | pulito |
| Kizako Industries | 12 | pulito |
| La Fontana | 3 | pulito |
| Casa Gigante | 900.000+ | **nessun difetto in quelle guardate; non finita** |

**La Casa Gigante non si finisce di esplorare**, e lo dico invece di nasconderlo.
Ha dodici indizi indipendenti (le tre foto, la spilla, il filo, i fiori, la
mensola…), che fanno circa quattromila combinazioni per ogni stanza. In 14
minuti l'esploratore ne ha guardate 900.000 senza trovare una prigione o un punto
morto, ma non tutte. Nella suite gira tutto il resto in una dozzina di secondi
(`prova_la_storia_non_ha_punti_morti`); la Casa si guarda a parte.

**L'esploratore ha sbagliato quattro volte, e le ho corrette tutte:**

1. `reset_campagna` svuota sul posto il dizionario dei nodi, e le fotografie
   delle situazioni lo condividevano. Dopo il primo «perso» sparivano i nodi di
   tutte le altre strade, e uscivano decine di «nodo inesistente» finti.
2. Contava come porte anche le scelte di bottino che riportano allo stesso
   nodo («Recupera i bulloni» con `vai` verso la stanza in cui sei già). Le
   combinazioni esplodevano oltre il milione.
3. Credeva che l'icona della Guida comparisse in ogni zona dopo le Pianure.
   Invece compare solo dove la Guida ha battute (`IconaGuida.metti`), e ha
   segnalato quattro difetti che non esistevano.
4. **Un sabotaggio gli è sfuggito.** Togliendo a Meridia il flag che la
   completa, diceva «tutto a posto», perché ricavava la meta dai flag accesi
   nel file stesso: sparito il flag, spariva anche la meta. Adesso la meta è
   ancorata al `flag_completamento` dichiarato dalla frattura, e c'è un
   controllo in più: ogni flag che `mappa.json` chiede deve essere la meta di
   qualche zona.

### 2. Le attese che possono non tornare

Nel codice del gioco ci sono 36 `await`. Li ho letti tutti:

- **Transizioni**: girano anche in pausa (`PROCESS_MODE_ALWAYS`) e non perdono richieste. La pausa non si apre durante una transizione, e «Torna al menu» chiude la pausa prima di partire.
- **Il racconto in combattimento (Voce.gd)**: ogni attesa esce per tempo, per clic (anche da tastiera) o perché la scena non c'è più.
- **La caduta nel pozzo della mappa stellare**: l'animazione è locale e nessuno la interrompe.
- **Il giro del data pad**: chiudere il data pad, ESC, o la scena che va avanti lo chiudono. Un passo che non riconosce va avanti da solo.
- **Le scelte che si rompono**: un orologio liberato prima di rompersi lascia appesa solo l'animazione, non il gioco.

Poi le **guardie** (`partendo`, `in_corso`, `chiusa`, `sta_svuotando`…): si
spengono su ogni strada, tranne quella del Vuoto (voce 3). Poi i **cicli**
`while`: tutti avanzano di un passo sempre positivo, quindi nessuno gira
all'infinito.

### 3. Il combattimento

- **Come finisce**: vittoria, sconfitta o fuga (`verifica_fine_scontro`). Chi decide se c'è ancora qualcuno in piedi non conta gli oggetti di scena, che non agiscono.
- **Dove porta**: ogni scontro nei dati ha `se_vinci` e `se_perdi` verso nodi che esistono; l'esploratore li percorre tutti.
- **Gli scontri «infiniti» del simulatore**: la tabella di `docs/bilanciamento.md` ne mostra 426 righe. Sono quasi tutte di chi non attacca mai («difendi») o gioca a caso, e 60 giri sono solo il limite della misura.
- **La Tartaruga Gigante**, che non finisce con nessuna strategia del simulatore, si chiude col legame: la Guida lo propone al secondo turno. Il simulatore non sa usarlo, l'automa sì, e la supera.

### 4. L'automa, dopo la Sede

Il giro di sempre si fermava alla Sede: tutto quello che viene dopo non l'aveva
mai giocato nessuno con clic veri. Adesso l'automa sa partire da lì:

```
./prove/automa.sh esplora 1 1500 sede                  # Sede, mappa stellare, Vuoto
./prove/automa.sh esplora 3 900 frattura:meridia       # dentro una frattura
```

| giro | tempo di gioco | errori | blocchi |
|---|--:|--:|--:|
| dalla Sede, seme 1 | 25 min | 0 | 0 |
| dalla Sede, seme 2 | 25 min | 0 | 0 |
| sette fratture (Squarcio, Meridia, Rocca, Casa, Teatro, Kizako, Fontana) | 15 min l'una | 0 | 0 |

Dalla Sede l'automa arriva nel Vuoto ma si perde fra segreti e sonde, e non
entra nelle fratture: è il motivo della partenza `frattura:`.

In tre fratture segnalava un **fantasma**: un controllo visibile e acceso che il
clic non raggiunge. Era il riquadro del nemico in combattimento, coperto
dall'area che fa avanzare il racconto mentre una battuta aspetta il clic. È
voluto: sul nemico si clicca quando tocca a te, non mentre si legge.

L'automa adesso non lo conta più, ma **solo nella plancia di combattimento**.
L'icona del menu coperta dalla stessa area era un fantasma vero, nella prima
caccia (`docs/caccia.md`), e deve restare tale. In più ora scrive dove sta il
fantasma: prima diceva solo «|Control».

Nel giro di sempre, dal menu, di fantasmi ne contava **14**, tutti uguali:
l'icona «?» della Guida, coperta dall'area del testo a ogni scena delle Pianure
e della Sede. Anche quello è voluto (la Guida porta via dalla scena, e a metà
dialogo se ne perderebbe il resto), ma l'icona era solo *sbiadita*: per il
motore restava un bottone acceso. Adesso mentre si legge è **disabilitata**
davvero, e torna accesa a testo finito. Con questo non c'è niente da esentare:
l'automa la salta perché è spenta, non perché gliel'ho detto io. Prova estesa,
tre sabotaggi su tre presi.

---

## I difetti, uno per uno

### 1. Gli ordini di Veronica e il tasto della mappa

`comunicazioni_ordini` accende `ordini_ricevuti` e ha una scelta sola, «Apri il
data pad», che porta a `data_pad_istruzioni`. È l'**unico** posto che accende
`data_pad_spiegato`, e quel flag apre la sala di proiezione e quindi la prima
missione. Ma il nodo sta nella stanza «sala_comunicazioni», che sta sulla mappa
del complesso, e allora accanto alla scelta compariva il tasto **Mappa**.

Chi lo premeva e tornava in sala trovava la regola `ordini_ricevuti →
sala_comunicazioni_dopo`: una sala con solo «Torna alla mappa». Il data pad non
si apriva più, la proiezione restava «pomeriggio» per sempre. L'esploratore ha
contato 50 situazioni da cui la storia non andava più avanti, tutte dopo quel
tasto.

**Correzione, in due pezzi:**
- `comunicazioni_ordini` è `senza_mappa`: gli ordini si chiudono aprendo il data pad, come dice il testo;
- la sala dopo gli ordini è «dopo» solo se il data pad è stato spiegato. Chi ha gli ordini e non il data pad ritrova la chiamata, e da lì «Apri il data pad».

Basterebbe uno dei due: li ho messi tutti e due, perché il secondo regge anche
se un giorno quella scena cambia. Le prove sono `prova_dagli_ordini_si_esce_aprendo_il_data_pad`
e l'esploratore; ho tolto le correzioni una alla volta e insieme, e ogni volta
una prova cadeva.

### 2. Le scelte a tempo che scadono tutte

La rete di sicurezza di `Main` («se non c'è niente da premere si torna alla
mappa») guardava solo **quando le scelte si aprono**. Una scelta a tempo che
scade si rompe ed esce dalla colonna: se scadevano tutte, la schermata restava
vuota.

Oggi non succede, perché nessun nodo ha scelte a tempo. Ma tu hai detto che i
tempi li darai coi dialoghi, quindi la regola si scrive adesso:
- **nei dati**, accanto alle scelte che scadono ce ne vuole una che non scade (per esempio «Resta in silenzio»). Una prova lo pretende;
- **nel motore**, se scadono tutte lo stesso, si esce dalla rete di sicurezza come quando le scelte non ci sono (`Main.se_non_resta_niente_si_esce`), una volta sola.

### 3. Il Vuoto sordo

`Vuoto._su_conferma` accendeva `partendo` **prima** di sapere se la frattura si
apriva. Con un file rotto la frattura non partiva, `partendo` restava acceso e il
Vuoto ignorava ogni clic; restava solo il tasto della mappa stellare. Adesso si
accende solo se si parte davvero, e una frattura che non si apre lo scrive come
avviso.

### 4. Il cursore che sparisce sul menu (segnalato da Bru, 11 ottobre)

«A volte sul menu principale il cursore sparisce, e torna appena la schermata si
chiude.» Non l'ho potuto riprodurre qui (non c'è un Windows né l'editor), quindi
ecco cosa ho verificato e cosa no:

- **il gioco non nasconde mai il mouse**: nessun `mouse_mode` in tutto il codice, e
  le forme che usa (freccia, manina, presa) sono tutte visibili;
- **nel sorgente di Godot 4.7, su Windows**, la finestra non ha un cursore suo e
  Godot lo ridice al sistema solo quando la forma cambia, quando il mouse rientra
  o quando cambia il `mouse_mode`. Se qualcosa fuori dal gioco lo spegne mentre la
  freccia è già dentro (l'editor, che col gioco incorporato nella vista «Game» ne
  divide l'input, o il sistema), resta spento finché la forma non cambia. Sul menu
  niente la cambia;
- **chi lo spegne non l'ho trovato**: da qui non si vede. Bru usa Windows (12
  ottobre), quindi il meccanismo sopra è proprio il suo; il codice
  dell'editor che incorpora il gioco (`editor/run/`) il cursore non lo tocca mai.

`scripts/Cursore.gd` (autoload) glielo ridice da sé: quando il menu si apre,
quando la finestra riprende il fuoco, quando il mouse rientra, e muovendo il
mouse, al più due volte al secondo. Passa per un'altra forma e torna a quella di
prima, nello stesso fotogramma: se il cursore c'era non cambia niente. La prova
(`prova_il_cursore_non_resta_spento`) usa un DisplayServer finto che si segna le
chiamate, e tiene fermo anche che nessuno script usi `mouse_mode`; 8 sabotaggi su
8 presi.

---

## Cose che restano, e sono tue

- **L'officina della Sede è chiusa per sempre**: la apre `eto_incontrato`, che nessuna scena accende. È scritto nei dati come contenuto che manca (Eto va incontrato da qualche parte), non come guasto.
- **«Una crepa che pulsa»** (`frattura_post_v5`) chiede `vuoto5_completo`, che nessuno accende, e non ha un file: è un segnaposto e resta nascosta.
- **Le scelte a tempo**: quando le scrivi, mettine sempre una che non scade.

## Cosa questa revisione non guarda

- **il bilanciamento**: l'esploratore dà ogni scontro per vincibile e perdibile. Quanto è difficile lo misura il simulatore (`./prove/simula.sh`), che va rilanciato quando i numeri cambiano;
- **lo schermo**: cosa si vede e se si legge lo guardano l'automa e gli scatti, non l'esploratore;
- **la Casa Gigante fino in fondo**: 900.000 situazioni sì, tutte no;
- **alcune semplificazioni dell'esploratore**: i proiettori non contano (aggiungono scorciatoie e non tolgono strade); il bottino che dà solo oggetti che nessuno chiede non fa situazioni nuove; i Tazo contano solo per le soglie che qualche scelta chiede.
