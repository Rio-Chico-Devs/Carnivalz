# Carnivalz

RPG d'avventura narrativa dark fantasy: illustrazioni statiche, mappa stellare + eventi + scelte.
I mondi collassano, le realtà si fondono, e chi tocca il confine matura il fattore Carnivalz:
l'Organizzazione manda il party a estinguere le fonti prima che i pianeti vengano divorati.
Storia completa (canone): `docs/storia.md`.
Motore in Godot (GDScript), **contenuti tutti nei JSON** sotto `data/` — mai hardcodati negli script.
Il protagonista è l'**Anonimo**: il gioco si vive in prima persona attraverso le sue avventure.
Al via di una nuova partita (menu principale) il giocatore può scegliere un nome per lui — se
lo lascia vuoto resta "Anonimo". Il nome scelto sostituisce quello di default ovunque (box
dialoghi, ritratti, party) e va nel salvataggio (`GameState.imposta_nome_protagonista()`); un
messaggio di `sequenza` può richiamarlo esplicitamente con `{nome}` (es. la battuta di
benvenuto di Jerah).

## Come si avvia
Aprire `project.godot` con Godot 4.7+ (versione standard). Main scene: `scenes/Splash.tscn`.
Flusso completo:
**loghi d'apertura** (studio + personale, saltabili con un clic) → **menu principale** (Start /
Opzioni / Extra) → Start → **Nuova partita** (nome del protagonista) → **introduzione** (crawl di
lore a schermo nero + monologo del protagonista) → il **tutorial parte da solo** (nessuna
selezione del punto, vedi `avvio_automatico` sotto) → da lì in poi, il normale giro
**mappa stellare** ("!" dove un Carnivalz sta avendo luogo) → click → **selezione del party**
(solo le classi sbloccate; l'Anonimo c'è sempre) → **campagna narrata** → fine → mappa.
**Continua**/**Carica partita** (una partita già esistente) saltano loghi e introduzione e vanno
dritti in mappa.

### Aprire il progetto da uno zip

**Scompatta lo zip con il sistema operativo** (tasto destro → *Estrai tutto*), poi in Godot:
*Importa* → scegli il `project.godot` estratto.

Non usare *Importa* direttamente sul `.zip`: quel bottone è pensato per i **pacchetti di asset**
della libreria, non per un progetto intero, ed è molto più schizzinoso.

Lo zip si costruisce con `./strumenti/pacchetto.sh`, che usa `git archive`. Fatto a mano con
`zip` su un elenco di file l'archivio finisce **senza le voci di cartella**, e allora Godot non
riesce a creare le cartelle annidate: si becca un elenco di *"failed extraction from package"*
su `prove/`, `strumenti/` e `scripts/combattimento/` che non spiega perché. È già successo.

## Struttura
- `scenes/Splash.tscn` + `scripts/Splash.gd` — loghi d'apertura (studio/personale, placeholder
  testuali finché mancano le immagini in `art/branding/`), poi il menu
- `scenes/Menu.tscn` + `scripts/Menu.gd` — **la schermata principale**: le cinque partite in
  chiaro (una riga vuota si comincia, una piena si continua, la ✕ la cancella) / Opzioni /
  Extra / Esci. Non c'è più nessun passaggio "Start → cosa vuoi fare?" (vedi *Gerarchia*)
- `scenes/Opzioni.tscn` + `scripts/Opzioni.gd` — audio, grafica, accessibilità (vedi sotto)
- `scenes/Extra.tscn` + `scripts/Extra.gd` — collezioni (album/bestiario/oggetti), carica
  codice, social e ringraziamenti
- `scenes/Intro.tscn` + `scripts/Intro.gd` — crawl introduttivo (solo per una nuova partita)
- `scenes/Sede.tscn` + `scripts/Sede.gd` — **la Sede**: l'unità dell'Organizzazione in cui sei
  di stanza, e il posto sicuro del gioco (qui si salva, da solo). Stanze data-driven da
  `data/sede.json`
- `scenes/Mappa.tscn` + `scripts/Mappa.gd` — la proiezione del settore, guardata dal tavolo
  tattico della Sala operativa della Sede: marker data-driven
- `scenes/MappaZona.tscn` + `scripts/MappaZona.gd` — mappa dungeon della zona corrente, se ne
  ha una (`mappa_dungeon`, vedi sotto)
- `scenes/Selezione.tscn` + `scripts/Selezione.gd` — menu del party: mostra solo le classi
  sbloccate e si riadatta man mano che i personaggi entrano o escono dai disponibili
- `scenes/Main.tscn` + `scripts/Main.gd` — motore eventi + palco dialoghi
- `scenes/Combattimento.tscn` + `scripts/Combattimento.gd` — combattimento in tempo reale
- `scenes/Ritratto.tscn` + `scripts/Ritratto.gd` — ritratto riusabile (immagine o placeholder)
- `scripts/GameState.gd` — autoload: roster, party, inventario, livelli, RNG seedato, JSON
- `scripts/Stile.gd` — autoload: il linguaggio visivo del gioco, letto da `data/stile.json` e
  applicato come `Theme` globale (vedi sotto)
- `scripts/Transizioni.gd` — autoload: dissolvenza in nero tra una schermata e l'altra (vedi sotto)
- `scripts/BoxTesto.gd` + `scenes/BoxTesto.tscn` — il box del testo con macchina da scrivere,
  usato dalla schermata eventi (vedi sotto)
- `scripts/Impostazioni.gd` — autoload: impostazioni utente persistite a parte (vedi sotto)
- `scripts/Pausa.gd` — autoload: menu di pausa, storico dei dialoghi e Diario, aperti con ESC
  da qualunque schermata di gioco (vedi sotto)
- `data/classes.json` — classi giocabili (`protagonista` + lista con id, nome, hp, velocita, abilita, ritratto)
- `data/personaggi.json` — personaggi non giocabili (ritratti nei dialoghi + `livello`/`ruolo` se combattono)
- `data/ruoli.json` — la curva e i ruoli da cui escono i numeri di ogni creatura
- `data/abilita.json` — abilità, linee di potenziamento, punti e classi d'arma
- `data/psiche.json` — le psichi e i loro effetti (reazione al KO di un compagno)
- `data/regole.json` — numeri di bilanciamento (hp, danno, stress, fattore, xp, legame)
- `data/events.json` — campagna di prova
- `data/events_intro.json` — l'introduzione (monologo prima del tutorial)
- `data/task.json` — gli appunti del Diario: dove andare e cosa qualcuno ti ha chiesto (vedi sotto)
- `data/codici.json` — codici riscattabili da Extra (vuoto per ora: `{codice, testo, effetto}`)
- `data/mappa.json` — sfondo e punti della mappa stellare
- `data/sede.json` — la Sede: nome, descrizione, presidio richiesto e stanze
- `scripts/PannelloOpzioni.gd` — l'elenco delle opzioni, definito una volta sola e usato sia
  dalla schermata principale sia dalla pausa
- `prove/` — le prove del progetto (`./prove/esegui.sh`) e il giocatore automatico
  (`./prove/simula.sh`), entrambi descritti in fondo
- `art/` — illustrazioni di Bru: `art/mappa.png` (sfondo mappa), `art/personaggi/<id>.png`
  (ritratti), `art/branding/logo_studio.png`/`logo_personale.png` (loghi d'apertura). Finché
  mancano: placeholder generati (cielo stellato / iniziale del nome / testo)

## Stile visivo, box del testo e transizioni
Prima di questo sistema ogni schermata dichiarava i suoi colori/font/dimensioni a mano — risultato:
niente era davvero coerente, e cambiare "il colore del gioco" avrebbe voluto dire toccare quindici
file. Ora tutto passa da tre pezzi, in un posto solo:

- **`data/stile.json`**: l'unica fonte del linguaggio visivo. Font (di sistema o un `.ttf` messo
  in `art/font/`, a scelta di Bru), scala tipografica (titolo/sezione/corpo/nome/piccolo/minuscolo
  — sei taglie, sempre le stesse, mai un `font_size` a occhio dentro una scena), colori (viola-nero
  da sottosuolo, un solo accento caldo color ottone — il rosso e il verde sono riservati a
  danno/cura, non decorano nient'altro), forme (raggio degli angoli, spessore dei bordi,
  padding) e tempi (durata di ogni animazione: dissolvenza, transizione tra scene, lampeggio di un
  colpo, carta del titolo, macchina da scrivere).
- **`scripts/Stile.gd`** (autoload, prima di `Impostazioni`): legge quel JSON una volta sola e
  costruisce un `Theme` di Godot applicato alla radice dell'albero (`get_tree().root.theme`) —
  ogni schermata lo eredita senza fare nulla. Chi disegna qualcosa a mano (mappa, menu,
  combattimento) chiede i valori con `Stile.colore("accento")`, `Stile.dimensione("piccolo")`,
  `Stile.tempo("transizione_scena")` invece di scriverseli in giro. Offre anche piccoli aiutanti
  condivisi: `Stile.scelta(bottone)` (le opzioni di dialogo si allineano a sinistra, a piena
  larghezza, come righe di un elenco — non pulsanti da modulo), `Stile.lampeggia(nodo, colore)`
  (un colpo subito si vede sul ritratto, non solo si legge nel diario), `Stile.titolo_schermata()`,
  `Stile.etichetta_piccola()`. L'**alto contrasto** delle Opzioni non sostituisce questo tema: gli
  chiede di ricostruirsi con i colori del testo portati a un giallo ad alta visibilità
  (`Stile.imposta_alto_contrasto()`), lasciando intatti font, bordi e spaziature — l'accessibilità
  non deve far sembrare un altro gioco.
- **`scripts/BoxTesto.gd`** + **`scenes/BoxTesto.tscn`**: il riquadro dove il gioco parla,
  usato dalla schermata eventi. Tre trattamenti, decisi tutti qui e non nei singoli script:
  **dialogo** (targhetta col nome di chi parla, testo dritto), **narrazione** (niente targhetta,
  corsivo, colore smorzato — non è Anonimo che parla, è chi racconta dall'esterno), **notifica**
  (centrato, colore accento — il gioco che informa, non la storia). Il testo si scrive **a
  macchina** (`visible_ratio` animato in un `Tween`, velocità in caratteri/secondo da
  `data/stile.json` × il moltiplicatore delle Opzioni): un primo click lo completa subito, il
  successivo passa avanti. Finita la scrittura pulsa un "▼" in basso a destra — l'unico segnale
  di "premi per continuare" in tutto il gioco, sempre nello stesso posto. **Altezza sempre
  fissa** (`Stile.forma("altezza_box")`, `fit_content` spento apposta): un messaggio più lungo
  di un altro non fa più crescere il box e spingere su/giù i ritratti sopra — se un testo non
  ci sta, scorre dentro il box (`scroll_active`), il box non si muove mai. Lo scroll si
  resetta in cima a ogni nuovo messaggio (`mostra()`).
- **Box disegnato a mano**: `Stile.stile_box_testo()` è la cornice condivisa dal box eventi e
  dal diario di combattimento. Con la sezione `"box"` di `data/stile.json` a `usa_texture:
  false` (default) resta il box piatto qui sotto; con `usa_texture: true` + un'immagine in
  `"texture"` diventa uno `StyleBoxTexture` a **nove riquadri**: i margini (`margine_sinistro`/
  `destro`/`alto`/`basso`) restano fissi alla dimensione disegnata, il centro si allunga per
  qualunque testo.
- **Bottoni disegnati a mano**: stessa idea, `Stile.stile_bottone_texture()` + la sezione
  `"bottone_texture"` di `data/stile.json`. Un solo frame disegnato (lo stato "normale") basta
  per tutti e cinque gli stati di un bottone: sopra/premuto/spento/a fuoco derivano dalla stessa
  immagine ricolorata (`modulate_color` — più chiara, più scura, semitrasparente, calda), non
  richiedono cinque disegni separati. Senza immagine `stile_bottone()` ripiega sul bottone
  piatto già in uso.
- **Sfondo de Il Vuoto**: `Vuoto.gd` leggeva solo un cielo stellato disegnato a codice
  (`_draw()`); ora, se il punto in `data/mappa.json` ha un campo `"sfondo"` con un'immagine
  valida, quella sostituisce il cielo segnaposto (stesso pattern già usato da `Mappa.gd` per lo
  sfondo della mappa stellare e da `MappaZona.gd` per lo sfondo di una zona).
- **`scripts/Transizioni.gd`** (autoload, `CanvasLayer` sopra tutto): un velo nero cala,
  la scena cambia mentre lo schermo è coperto, il velo si rialza. `Transizioni.vai(percorso)` ha
  sostituito ogni `get_tree().change_scene_to_file()` del progetto — un cambio di schermata non è
  mai più uno scatto secco, ed è impossibile entrare due volte nella stessa stanza per un doppio
  click (il velo assorbe l'input finché non è finito).

### Una schermata che non si muove mai
Prima, ogni click faceva ballare mezza schermata: compariva il triangolino "vai avanti" e il box
cresceva di una riga, comparivano le scelte e il box saliva, il nome di chi parla appariva e
spariva e il testo saltava su e giù. Ora la schermata eventi è a tre fasce fisse e **niente di
quello che compare o sparisce può spostare il resto**:

- barra di stato in alto;
- in mezzo il palco dei ritratti, con a destra la **colonna delle scelte** — larghezza sempre
  riservata (`forme.larghezza_scelte`) anche quando è vuota, altrimenti i ritratti si
  restringerebbero di colpo a ogni fine testo. Lì dentro stanno le scelte del nodo, "Parla con
  la squadra", "Mappa" e la lista dei compagni: le scelte sono righe di un elenco, e una scelta
  lunga va a capo da sola invece di essere tagliata (`Stile.scelta()`);
- il box del testo inchiodato in basso a un'altezza decisa una volta sola in `BoxTesto._ready()`.

Dentro il box valgono le stesse regole: il **triangolino non sta nel flusso** (è un fratello del
contenitore, sovrapposto in basso a destra — se stesse nella colonna, il box crescerebbe ogni
volta che compare) e la **targhetta col nome non si nasconde mai**: quando non parla nessuno
resta lì vuota, tenendo la sua riga.

### Il ritmo della macchina da scrivere
Il testo non scorre a velocità costante: si ferma dove si fermerebbe una voce. Una virgola è un
respiro corto, un punto una pausa vera, i puntini di sospensione un silenzio — il giocatore
riceve la frase a pezzi di senso compiuto invece che a filo continuo. Tecnicamente il tween di
`visible_ratio` non è più uno solo: `BoxTesto.respiri()` legge il testo senza bbcode
(`get_parsed_text()`, così gli indici combaciano) e ne ricava i punti dove fermarsi, e la
scrittura diventa una catena di pezzi separati da `tween_interval()`. Le durate stanno in
`data/stile.json`, sezione `"ritmo"` (`pausa_virgola`, `pausa_punto`, `pausa_sospensione`) e si
accorciano se il giocatore ha alzato la velocità del testo nelle opzioni. Non si respira mai
sull'ultima punteggiatura di un messaggio: lì la pausa la fa già il giocatore, col click.

Nella **schermata eventi** (`Main.gd`) questi pezzi si compongono così: non c'è più un bottone
"Continua" incastonato tra le scelte — un'area invisibile copre tutto lo schermo mentre si legge
(clic ovunque, o Invio/Spazio da tastiera, fanno la stessa cosa), e le scelte vere compaiono solo
quando la coda dei messaggi è vuota **e** il box ha finito di scrivere: non si clicca mai per
sbaglio su un'opzione mentre si sta ancora leggendo. Chi sta parlando resta a piena opacità, chi
non ha la battuta in quel momento si attenua (`Ritratto.imposta_attenuato()`) — l'occhio va da
solo su chi ha la voce, senza dover leggere il nome. Un messaggio `"titolo"` (il nome di un
luogo) non entra nel box: prende tutto lo schermo come una carta da film, e **aspetta un click
esplicito** prima di sciogliersi (non un timer) — è un momento che merita si guardi, non un
ostacolo da far sparire in automatico. La prima scelta/bottone utile di ogni schermo prende il
fuoco della tastiera da solo: il gioco si può giocare interamente senza mouse.

## Pausa, Diario, Zaino (ESC)

Un velo sopra la scena viva, non una schermata: si apre da ovunque — mappa, stanza, Vuoto,
combattimento — senza cambiare scena e senza perdere il posto in cui si era. Mentre è aperto
l'albero è in pausa: i tween si fermano, i timer del combattimento si fermano, niente va avanti
alle spalle del giocatore.

**Un pannello alla volta**, mai due cose insieme: *Riprendi · Storico · Diario · Personaggio e
squadra · Zaino · Opzioni · Torna al menu principale*.

**Tazo e livello sono sempre in alto a destra**, in ogni pannello. Li disegna `intestazione()`,
non i singoli pannelli: così nessuno può dimenticarseli. Prima erano sepolti dentro una sezione
del Diario, e per sapere quanti soldi si avevano bisognava navigare.

### Il Diario ha un indice

Le sette sezioni (*Appunti, Stato, Cosa ti sta cambiando, Abilità passive, Squadra,
Osservazioni, Organizzazione*) erano impilate nello stesso scorrevole: per arrivare all'ultima
si rotolava per due schermate passando in mezzo a tutto il resto. Adesso **indice a sinistra,
una sezione alla volta a destra**, con quella aperta segnata in ottone. Un diario non è un
tabulato: è un posto dove si va a cercare una cosa precisa.

### Lo Zaino

Mancava del tutto: per sapere cosa si aveva addosso bisognava aprire la scheda di un personaggio
e guardare cosa si poteva equipaggiare — che è un'altra domanda. Adesso è un pannello suo, uno
scomparto alla volta (*Consumabili · Armi · Accessori · Oggetti speciali · Ricordi e chiavi*),
ognuno con la sua capienza. Gli oggetti uguali si contano su una riga sola (`×3`), e un'arma
equipaggiata è segnata **in uso — Yhvina**: resta nello zaino, è una regola dello zaino, e qui è
l'unico posto dove si vede.

### Aperta da una stanza della Sede

`Pausa.apri_su("diario" | "equipaggiamento" | "inventario")` apre un pannello **senza passare dal
menu di pausa**: serve alla Sede, dove *Alloggi* e *Archivio* sono stanze di un posto, non voci
di un menu.

Questo aveva un bug, ed era mio: si cliccava *Alloggi*, si tornava indietro, e ci si ritrovava
nel **menu di pausa** in mezzo alla Sede senza aver mai premuto ESC. Adesso `modo_diretto` dice
da dove si è arrivati, e `indietro()` è una funzione sola che decide dove tornare — così non c'è
un pannello che se lo ricorda e uno che se lo dimentica.

## Appunti del Diario (`data/task.json`)
La guida del gioco. Non una lista di obiettivi con le spunte in un pannello a parte: sono i
pensieri del protagonista quando mette a fuoco che c'è un posto dove deve andare o una cosa che
qualcuno gli ha chiesto — *"Ho notato degli strani cambiamenti in quella regione... forse dovrei
dare un'occhiata."* Stanno in cima al Diario, in corsivo, con il colore delle narrazioni: la
stessa voce con cui il gioco racconta, non un'interfaccia che dà ordini.

**Vivono sui flag.** Il campo `richiede_flags` dice quando un appunto compare (tutti alzati),
`chiuso_da` quando si segna come fatto. Nessun nodo deve ricordarsi di aprire o chiudere niente:
`GameState.imposta_flag()` chiama `aggiorna_task()` e il mondo si aggiorna da solo, ovunque sia
successa la cosa — dentro uno squarcio, in un dialogo, a fine combattimento. `chiuso_da` vuoto
significa "non si chiude": è un seme lasciato lì per i mondi che verranno (le pergamene da far
leggere a Curie, la pressione senza nome dietro *Qualcosa preme*).

Per gli appunti che nascono da una conversazione e non da uno stato del mondo, un nodo, una
scelta o una battuta di un compagno possono anche aprirli a mano con `"task": "id"` (o una
lista) e chiuderli con `"chiudi_task"`. Il campo `da` porta l'id di chi te l'ha chiesto: il
Diario lo cerca sia tra i personaggi che tra le classi, così funziona sia per un png che per un
compagno in squadra.

**Come si annunciano.** Un appunto nuovo chiude la coda dei messaggi del nodo, non la apre:
prima si vive la scena che l'ha fatto nascere, poi il protagonista ci ragiona sopra. Una
notifica fa da intestazione ("Il Diario si è aggiornato"), poi arrivano i pensieri veri come
narrazioni — al massimo `APPUNTI_LETTI_A_VOCE` (2) per volta, perché la fine del tutorial ne
apre quattro insieme e scaricarli tutti addosso al giocatore sarebbe una lista travestita da
monologo. Il resto si legge nel Diario.

**Ordine delle operazioni.** In `aggiorna_task()` si chiude prima e si apre dopo: un appunto che
nascerebbe già risolto (raccogli la spilla dopo aver battuto il ricordo) non lampeggia per un
istante come nuovo. Quali appunti siano aperti e quali chiusi è progresso di partita e sta nel
salvataggio; caricando una partita vecchia, `aggiorna_task()` la riallinea dai flag che ha già
in mano — e poi svuota le notifiche, così non ti annuncia come appena successe cose fatte ore
prima.

## Opzioni e Impostazioni.gd
Audio (volume generale/musica/effetti, bus separati "Musica"/"Effetti" creati al volo in
`AudioManager._assicura_bus()` — niente file di bus layout da mantenere), grafica (schermo
intero) e accessibilità: testo più grande via `content_scale_factor`, alto contrasto (delegato a
`Stile.imposta_alto_contrasto()`, vedi sopra), e **velocità del testo** (cursore 0..1 che
scala `Impostazioni.velocita_testo` tra 0.4× e 3×, moltiplicato per i caratteri/secondo di
`data/stile.json` — da "si legge parola per parola" a "quasi tutto insieme", per chi preferisce
leggere più in fretta o più lentamente della macchina da scrivere di base). Tutto applicato e
salvato subito a ogni modifica in `user://impostazioni.cfg`, **indipendente dagli slot di
salvataggio** della partita (persiste tra una partita e l'altra).

L'**elenco** delle opzioni sta in `scripts/PannelloOpzioni.gd` e non altrove: sia la schermata
`Opzioni.tscn` sia il pannello *Opzioni* della pausa lo chiedono a lui. Prima la pausa ne
mostrava due su sei (i volumi), e chi alzava il contrasto in gioco non lo trovava; adesso
aggiungerne una la fa comparire in tutti e due i posti, perché non c'è nessun altro posto dove
metterla.

## Extra: carica codice
`GameState.codici` (da `data/codici.json`, vuoto per ora) e `GameState.riscatta_codice(testo)`:
un codice riscattato sblocca un `effetto` (`oggetto` e/o `tazo`, riusando `aggiungi_oggetto()`/
`modifica_tazo()`) una sola volta, ricordato in `user://codici_riscattati.cfg` — fuori dagli slot
di salvataggio, cosa persiste come l'album delle carte anche a nuova partita. Per ora la lista
codici è vuota: la schermata Extra è pronta, i codici veri arriveranno dopo.

## Introduzione e avvio automatico di una campagna (`avvio_automatico`)
Un nodo evento può avere `"avvio_automatico": {"id_punto", "file_eventi"}`: a fine sequenza,
invece di scelte, `Main.avvia_automatico()` chiama `GameState.avvia_carnivalz()` con quei dati e
ricarica lo stesso nodo (`mostra_nodo()`), senza cambiare scena — usato da `events_intro.json`
per far partire il tutorial da solo (`id_punto: "tutorial"`) appena finisce il monologo del
protagonista: il giocatore non sceglie lui il punto di partenza, a differenza del normale click
su un marker della mappa stellare.

## Mappa dungeon di una zona (`mappa_dungeon`)
Un file eventi (`data/events_*.json` o uno squarcio in `data/vuoti/*.json`) può avere un campo
di primo livello `"mappa_dungeon": {"sfondo", "stanze": [{"id", "nome", "pos"}], "connessioni":
[["id_a", "id_b"], ...]}`, dove ogni `"id"` di stanza è anche l'id di un nodo in `"nodi"`. Se
presente, la zona si esplora liberamente invece che in un ordine lineare imposto: dalla
schermata `MappaZona.tscn` si clicca una stanza **sbloccata** per entrarci
(`GameState.nodo_corrente = id; torna a Main.tscn`).

La mappa è un **grafo**: le `"connessioni"` sono gli archi, disegnati come linee (`Line2D`) tra
le posizioni delle due stanze. Finché non la esplori è solo un insieme di linee parziali:
- una connessione non si disegna affatto se **nessuna** delle due estremità è ancora scoperta
  (`GameState.stanza_sbloccata()`, vedi sotto)
- se **una** estremità è scoperta, la linea appare, e l'altra estremità mostra un punto muto,
  senza nome né interazione (`MappaZona.connessa_a_scoperta()`) — sai solo che lì c'è qualcosa
- solo le stanze davvero sbloccate mostrano un bottone vero, cliccabile, col loro nome
- **Sblocco**: la stanza `nodo_iniziale` della zona è sempre sbloccata
  (`GameState.stanza_iniziale_zona`); le altre si sbloccano con il campo nodo
  `"sblocca_stanze": ["id1", "id2"]` (letto in `Main.mostra_nodo()` alla prima visita del nodo
  che le sblocca). Lo stato vive nei flag di `GameState` (namespaced per zona,
  `GameState.stanza_sbloccata()`/`sblocca_stanza()`), quindi zone diverse possono riusare gli
  stessi id di stanza senza scontrarsi, e persiste nel salvataggio come qualunque altro flag
- **Tornare alla mappa**: una scelta con `"torna_a_mappa": true` porta a `MappaZona.tscn` invece
  che a un altro nodo (`Main._su_scelta()`). C'è anche un bottone **Mappa** accanto a "Parla con
  la squadra", per consultarla/spostarsi in qualunque momento, non solo a fine stanza. Compare
  **solo quando il nodo corrente è una delle stanze della mappa**
  (`GameState.stanza_nella_mappa()`): fuori dalla sezione esplorabile (prologhi lineari, scene
  al quartier generale) non avrebbe senso e resta nascosto
- **Zona ripulita**: `combattimento_automatico` e `agguato` accettano un campo opzionale
  `"salta_se_flag"` — se quel flag è impostato (tipicamente quello del nodo di vittoria sul boss
  della zona, via il campo `"flag"` già esistente sui nodi), il combattimento non parte più:
  si salta dritti a `se_vinci` (`combattimento_automatico`) o l'imboscata non tenta più nulla
  (`agguato`). Così, dopo il boss, la zona si rivisita senza più nemici
- **In uso**: `data/vuoti/rocca_ossidiana.json` (Cunicoli sotterranei di Jondoh) — solo la
  sezione post-checkpoint (il labirinto di cunicoli, la piazza sotterranea, il cargo
  abbandonato, l'approccio al ponte marcio) è su `mappa_dungeon`; l'ingresso lineare (varco →
  corridoio → fossa → sala del raccolto → sala del lamento) e la parte finale forzata (ponte →
  cripta → altare → trono) restano scelte dirette come nel resto del gioco
- **In uso anche nel tutorial** (`data/events_tutorial.json`), dove serve a *insegnare* la
  mappa: dal bivio in poi (bivio, pozze, collina, convergenza) si esplora liberamente. Prima
  era un bivio esclusivo — scelto un ramo si finiva dritti al boss — e quindi era impossibile
  prendere la Pietra Quieta dalla tartaruga (pozze) e poi usarla contro la manifestazione
  (collina). I due scontri usano `"salta_se_flag"` così una stanza già ripulita non li rilancia
  a ogni rivisita
- Non usa (per ora) `"salta_se_flag"`/`combattimento_automatico`: Jondoh usa solo `"combatti"`
  sulle scelte, che non ha un equivalente diretto. Il boss finale (Jongo Dongo) è identico in
  entrambi i casi: con/senza l'alleata cambia solo la scena (il suo sacrificio, narrato e
  senza effetto meccanico sul boss — vedi "Il Vuoto" più sotto), non la difficoltà
- **`"flag_completamento"`** in `mappa_dungeon`: una volta impostato quel flag (di solito lo
  stesso della vittoria sul boss), `GameState.stanza_sbloccata()` ritorna sempre true per
  quella zona — **tutte** le sue stanze restano liberamente visitabili da quel momento, anche
  quelle mai scoperte in quella run, non solo quelle sbloccate sul momento. Non riguarda i
  passaggi fuori da `mappa_dungeon` (es. il grande ponte marcio di Jondoh, a senso unico per
  sempre "per via dei vermi": quello resta bloccato anche a zona completata)

## Gerarchia delle schermate: dove sta cosa

Una regola sola, e vale in tutte e due le direzioni.

**La schermata principale** decide *quale partita* e *se cominciarla o continuarla*. Lì e solo
lì si carica, si comincia, si cancella. Cinque righe, una per partita: vuota → nuova partita
(chiede il nome, poi l'introduzione), piena → si continua, la ✕ la cancella con una conferma
davanti. Nessun "Start" che apre un sotto-menu che chiede cos'altro volevi fare.

**Dentro il gioco** si gioca. Le opzioni si possono guardare (ESC → Opzioni: sono le stesse
della schermata principale, perché l'elenco è uno solo — `PannelloOpzioni`), ma di salvataggi
non si parla più: il gioco scrive da solo, sempre nella partita scelta all'inizio, ogni volta
che rientri alla Sede. Niente selettore di slot in mezzo a una partita, niente modo di
sovrascrivere per sbaglio il file di qualcun altro.

La regola non è un'intenzione: è una prova. `prova_gerarchia_schermate()` legge i sorgenti e
fallisce se uno script che non sia `GameState` o `Menu` nomina la gestione degli slot, o se
uno che non sia `Sede`/`IngressoNodo` chiama `GameState.salva()`.

## La Sede (`data/sede.json`, `scripts/Sede.gd`)

**Dove sei quando non sei dentro un Carnivalz.** Prima il gioco non aveva un "dove": si usciva
dal menu e ci si trovava sospesi su una mappa stellare, senza che nessuno avesse mai detto da
dove la si stesse guardando.

Sei di stanza in un'**unità dell'Organizzazione**. Non è un ufficio: è un presidio, e va
difeso. Ogni unità deve tenere in casa un numero minimo di dominatori — sotto quella soglia è
scoperta. Ci sono anche le forze militari, che fanno i turni sul perimetro e sanno benissimo
di non avere il fattore Carnivalz; il che non vuol dire che siano innocue (chi è addestrato
come si deve, o attrezzato come il **Dott. Eto**, sta al passo con gente che piega la realtà
usando la testa e la tecnologia).

Le stanze sono voci di `data/sede.json`: `id`, `nome`, `descrizione`, `azione`
(`mappa` | `negozio` | `squadra` | `diario` | `testo`) e, se serve, `richiede_flag` +
`testo_chiusa`. Aggiungerne una non richiede una riga di codice. `squadra` e `diario` non
cambiano schermata: aprono il pannello della pausa sopra la Sede, e si torna dov'eri.

Da qui si va alla **Sala operativa**, cioè alla mappa stellare. È l'unico collegamento
obbligatorio, e c'è una prova che fallisce se sparisce.

## Salvataggio: una partita, un file

**Una partita = uno slot.** Lo slot si sceglie dalla schermata principale, una volta; da lì in
poi `GameState.salva()` scrive sempre in `user://salvataggio_slot_<n>.json`
(`GameState.slot_corrente`). Non esiste più un autosalvataggio unico separato dagli slot: era
la sorgente della confusione (il giocatore doveva sapere quale dei due stesse usando).

**Quando si salva:** rientrando alla **Sede**, da solo. Mai nel Vuoto, mai dentro uno
squarcio, mai in combattimento. Non c'è un bottone: rientrare *è* il salvataggio.

**Partite vecchie:** `GameState.recupera_salvataggio_vecchio()` gira all'apertura della
schermata principale. Se esiste il vecchio `user://salvataggio.json` e non c'è ancora nessuna
partita nel nuovo formato, diventa la **partita 1**. Chi stava giocando riapre e ritrova la sua
roba, non cinque righe vuote.

**Nuova partita** azzera il progresso di storia (le collezioni album/bestiario/oggetti restano,
sono meta). Non si salva a metà campagna/squarcio: si riparte sempre dallo stato "overworld".

### Il game over ricarica davvero

*"Riprendi dall'ultimo salvataggio"* non lo faceva: rifaceva la zona tenendo lo stato che c'era
in memoria. Le fiale usate restavano usate, i Tazo spesi restavano spesi — il bottone mentiva, e
chi moriva dopo aver speso mezza sacca ricominciava senza. Il motivo scritto nel codice era che
il salvataggio era *un file solo condiviso da tutte le partite*: non è più vero da quando una
partita è uno slot, e con il motivo è caduta anche la scelta.

Adesso `GameState.game_over()` rilegge il file della partita e dice cosa ha fatto:

| esito | quando | dove si finisce |
|---|---|---|
| `salvataggio` | c'è un file **di questa partita** | ricaricato: alla Sede, com'eri all'ultimo salvataggio |
| `zona` | nessun salvataggio ancora (tutorial) | si rifà la zona dal suo inizio |
| `""` | né l'uno né l'altra | alla Sede |

`partita_su_file` è la riga che evita l'errore peggiore: chi comincia una partita **nuova** in
uno slot già occupato e muore prima di aver salvato non deve ritrovarsi addosso l'inventario
della partita di prima. Finché questa partita non ha scritto lei quel file, quel file non è suo.

Nel tutorial un salvataggio non esiste ancora, quindi lì il bottone dice *"Rialzati e
ricomincia"*: prometteva una cosa che il gioco non poteva mantenere.

`prova_game_over_ricarica_davvero()` salva, consuma, muore e controlla che sia tornato tutto —
e che una partita senza file non peschi quello di un'altra.

**`"salva_checkpoint": true`** su un nodo (es. `dopo_lamento` nei Cunicoli di Jondoh) chiama
`GameState.salva()` lì per lì, dentro lo squarcio — un'eccezione deliberata alla regola sopra,
per non perdere Tazo/oggetti/flag raccolti in un dungeon molto lungo. **Non** fa però riprendere
la partita da quel punto: `_leggi_salvataggio()` torna comunque sempre a uno stato overworld
pulito (party/nodo/eventi azzerati), quindi un game_over dopo il checkpoint riporta comunque
alla Sede — si perde la posizione nel dungeon, non il bottino raccolto prima. Un vero
"riprendi da qui dentro lo squarcio" richiederebbe salvare anche `eventi`/`nodo_corrente`/
`carnivalz_corrente`/`mappa_zona`/party e non azzerarli al caricamento: non ancora fatto.

## Dove sei già stato

Tre stati, tre colori, **gli stessi in tutto il gioco** (`Stile.segna_visita`):

| stato | segno | colore | quando |
|---|---|---|---|
| `nuovo` | `•` | ottone (accento) | non ci hai mai messo piede |
| `visto` | — | smorzato | ci sei già stato |
| `chiuso` | `✓` | verde | non c'è più niente da fare (lo dice un flag) |

Il pallino non è decorazione: chi non distingue bene i colori deve poter vedere lo stesso quali
posti gli restano. Ogni schermata che li usa mostra la legenda (`Stile.legenda_visite()`).

Si applica a: i punti della **mappa stellare**, gli squarci del **Vuoto**, le stanze della
**mappa di zona**, le stanze della **Sede** e le **scelte di un dialogo che portano altrove**
(solo quelle con `vai`: una battuta non è un posto). Non è uno spoiler — dice che quella porta
non l'hai aperta, non cosa c'è dietro.

Il conto lo tiene `GameState.zone_visitate` (mondo) e `nodi_visitati` (stanze), tutti e due nel
salvataggio. Un salvataggio vecchio, che non aveva `zone_visitate`, se lo ricostruisce dai flag
delle stanze (`<zona>__stanza__<id>`): sono già la prova di dove sei stato.

Opzionale nei dati: `"flag_completato"` su un punto della mappa o su uno squarcio dice quale
flag lo dichiara `chiuso`.

## Palco dialoghi (con espressioni)

**Ogni personaggio è una libreria di immagini, e ogni battuta ne sceglie una.**

I file stanno in `art/personaggi/<id>/<espr>.png`. Le 16 espressioni canoniche (`neutra`,
`arrabbiata`, `felice`, `carina`, `infastidita`, `disgusto`, `speciale`, `dialogo`, `delusa`,
`petrificata`, `annoiata`, `pensiero`, `sorpresa`, `sforzo`, `cool`, `decisa`) sono una
convenzione, non una gabbia: `espr` è semplicemente il nome del file, quindi una scena può
chiedere `"espr": "sotto_la_pioggia"` e basta disegnare `sotto_la_pioggia.png`.

Fallback, in quest'ordine: l'espressione chiesta → `neutra.png` → il vecchio file singolo
`art/personaggi/<id>.png` → un segnaposto con l'iniziale. Si disegna a poco a poco senza
rompere niente.

**Chi la sceglie, e quando:**

| dove | effetto |
|---|---|
| `"destra": { "id": "jerah", "espr": "arrabbiata" }` | la faccia con cui **entra in scena** |
| `espr_sinistra` / `espr_destra` / `espr_centro` sul nodo | idem, forma breve |
| **`"espr"` su un messaggio della `sequenza`** | **cambia la faccia di chi sta parlando, battuta per battuta** |

L'ultima riga è quella che fa di una conversazione una scena invece di una sequenza di
didascalie: la stessa persona dice tre righe e cambia espressione tre volte, come farebbe un
attore. Un'espressione **dura finché qualcuno non la cambia** — una battuta senza `espr` non
riporta la faccia a neutra — e non tocca chi non sta parlando.

Funzionava solo a metà: `espr` su un messaggio veniva applicato **unicamente** nelle scene a un
personaggio solo (`centro`); in un dialogo a due veniva letto e buttato via, senza nessun errore.
Adesso `aggiorna_espressione()` cerca chi parla su tutti e tre i lati del palco.
`prova_espressione_per_battuta()` mette due personaggi in scena, fa parlare quello di destra e
fallisce se il suo ritratto non cambia.

Dettagli sui file in `art/personaggi/README.md`; l'elenco completo dei nomi esatti, generato dai
dati, in `docs/immagini.md`.
Sopra il box del narratore ci sono due spazi per i disegni: a **sinistra sempre il
protagonista** (o un alternativo, chiave `sinistra` nel nodo), a **destra l'interlocutore**
(chiave `destra`). I dialoghi sono discussioni tra almeno due persone, quindi gli spazi sono
solo due. Se il nodo ha la chiave `centro`, quel personaggio parla da solo al centro e gli
spazi laterali spariscono.

**Stile cinematografico** (stile Undertale, su indicazione di Bru): i ritratti riempiono
quasi tutto lo schermo (`Ritratto.imposta_grande(true)`, chiamato su tutti e tre gli slot in
`Main._ready()` e sul combattente centrale in combattimento), il box del testo
(`scenes/BoxTesto.tscn`, vedi la sezione "Stile visivo, box del testo e transizioni" più sopra)
è una striscia bassa e fissa in basso, con font, bordi e colori che vengono tutti da `Stile.gd`.
Un cambio di ritratto o di espressione non è mai uno scatto: la vecchia immagine sfuma nella
nuova (`Ritratto.dissolvi_ingresso()`). La Cornice del ritratto è un `PanelContainer`, e il tema
globale dà a ogni `PanelContainer` un pannello scuro bordato (utile per le schede del
Compendio/Bestiario) — ma un personaggio "grande" deve galleggiare sulla scena, non stare
dentro una scatola: `imposta_grande(true)` spegne quel pannello apposta
(`StyleBoxEmpty`), `imposta_grande(false)` lo ripristina per i ritratti piccoli (fila di
combattenti, schermo di selezione del party), dove la cornice visibile è invece voluta.
**Mancano ancora** gli sfondi di scena a piena pagina (per ora resta il `ColorRect` a tinta
unita, colore `Stile.colore("sfondo")`); il font è già configurabile da `data/stile.json` senza
toccare il codice, appena Bru fornisce un `.ttf`.

**Coda di messaggi sequenziali, con macchina da scrivere**: il box mostra **un messaggio alla
volta**, mai testo misto o sovrapposto (`Main.coda_messaggi`, `avanza_messaggio()`). Il testo
si scrive carattere per carattere; un click lo completa, il successivo passa al messaggio
seguente — non c'è più un bottone "▸ Continua" incastonato tra le scelte: un'area invisibile
(`AreaAvanza`) copre l'intero schermo mentre si legge, così qualunque click (o Invio/Spazio)
fa la cosa giusta. Quando l'ultimo messaggio della coda è seguito solo da scelte vere, queste
compaiono automaticamente **appena il box ha finito di scrivere** (`azione_a_fine_testo`),
senza bisogno di un click a vuoto che lascerebbe la schermata identica. Ogni nodo evento può
avere una `"sequenza"` (lista ordinata di messaggi tipizzati) invece del vecchio `"testo"` unico:
- **`narrazione`**: la voce narrante descrive la scena in **seconda persona** ("ti nota",
  "il tuo compito"), sempre in *corsivo*, senza nome — non è Anonimo che parla, è chi
  racconta la sua storia dall'esterno
- **`dialogo`**: un personaggio parla (`chi`), il suo nome compare centrato sul box
  (etichetta **`%NomeParlante`**) e il testo non è in corsivo. Include Anonimo stesso: le
  sue battute e i suoi pensieri in prima persona sono `dialogo` con `chi: "anonimo"`, mai
  narrazione
- **`notifica`**: oggetti/Tazo raccolti (`Main.pickup()`, i guadagni di Tazo in
  `_su_scelta()`); centrata e in grassetto nel box, **una voce alla volta**, mai
  insieme ad altro testo — per darle lo stesso peso di narrazione e dialogo
- **`titolo`**: rivela il nome di un luogo (es. "Pianure di Redenna" nel tutorial). Non entra
  nel box: prende tutto lo schermo come una carta da film (velo scuro + testo grande in
  `Stile.colore("accento")`) e **aspetta un click esplicito** ("▸ continua") prima di
  sciogliersi — non un timer, perché un nome di luogo merita di essere letto con calma
- **`immagine`**: un'illustrazione a schermo intero (`file`, sotto `art/illustrazioni/`) col
  `testo` come didascalia. Usa lo stesso velo della carta del titolo, perché fa la stessa
  cosa: prende lo schermo, aspetta un click, poi la scena riprende. **Se il disegno non c'è
  ancora resta la didascalia** e la scena si legge lo stesso — ma proprio per questo un
  percorso storto sarebbe identico a un disegno non ancora fatto, quindi
  `prova_illustrazioni` pretende didascalia + percorso dentro `art/illustrazioni/`, e in più
  che ogni file messo lì sia chiamato da qualche scena (vedi `art/illustrazioni/README.md`)

Un nodo senza `"sequenza"` continua a funzionare col vecchio campo `"testo"` (diventa
un'unica narrazione: `sequenza_di()` è retrocompatibile, nessun contenuto esistente va
riscritto per forza). Stessa filosofia in combattimento: il nemico al centro
(`%NemicoCentro`) è sempre grande, il Diario è la striscia in basso.

## Combattimento
Numeri piccoli e leggibili, ma con scelte vere:
- Stats per combattente (nei dati): **hp, attacco, difesa, velocità, fattore**. Danno =
  attacco (+1 se il fattore arde) − difesa del bersaglio, minimo 0
- Party e nemici in un'unica fila d'iniziativa per **velocità**, ricalcolata a ogni giro
- **Menu azioni**: Attacca · Difenditi · Abilità (**Studia** sempre disponibile) · Oggetti
  (consumabili dalla sacca) · Alleati (gli ospiti come il Vecchio Proprietario del teatro: un
  assist a combattimento, non sono veri combattenti)
- **Studia si mira come Attacca**: con più creature in campo si sceglie chi guardare, non si
  prende quella che capita per prima. Con un solo nemico vivo il menu non compare e si studia
  quello direttamente — così il tutorial (un nemico alla volta) resta a un click, come prima
- **Difenditi è cumulativo ma a rendimento decrescente**: ogni uso in più si avvicina a un
  tetto senza mai raggiungerlo — `bonus += (tetto − bonus) × decadimento`
  (`difesa_difenditi_tetto`/`difesa_difenditi_decadimento` in regole.json, default 6 e 0.5:
  +3, +4.5, +5.25, +5.6… fino al prossimo turno). Si azzera (`difesa_accumulo`) appena si fa
  qualunque altra azione: o si tiene la guardia con continuità, o si rischia attaccando, mai
  entrambe le cose insieme — e il tetto resta comunque sotto l'attacco della maggior parte dei
  nemici, quindi il danno subìto non scende mai davvero a zero solo restando sulla difensiva
- **Danno del party scala col livello**: `danno = attacco + ⌊(liv−1) × 1.0⌋` (+ fattore, + oggetti).
  Attacco base del protagonista **3** (`data/crescita.json`, stat "attacco"), non più 1: con
  attacco 1 diversi nemici comuni (marionette, ombre) erano matematicamente immuni ai colpi
  normali a inizio partita, perché danno − difesa restava a zero. HP del party restano 5
  (semplici); i boss hanno grandi riserve (Jerah 35, la bambola 666) → la difficoltà sta nel
  non morire durante scontri lunghi. `bonus_attacco_per_livello` in regole (ora 1.0, non più 0.5)
- I **boss hanno mosse pesate** nei dati (`mosse`: attacco_forte, attacco_tutti,
  buff_difesa, buff_fattore, evoca + `peso_attacco_normale`): ogni scontro è unico
- **Mosse "telegrafate"** (`"telegrafata": true` + `"testo_annuncio"`): la prima volta che il
  pool pesato la estrae, il nemico non la esegue subito — la "carica" (mostra solo l'annuncio,
  quel turno non fa danno) e la mossa arriva garantita al turno successivo
  (`mossa_in_carica` sul combattente). Dà al giocatore un giro per reagire (difendersi, curarsi,
  ecc.) prima del colpo grosso — premia chi legge i segnali, non solo chi picchia più forte.
  Prima ad averla: `colpo_marcio` di Jongo Dongo
- **Tutorial guidato in combattimento** (`"tutorial_combattimento"` su un nemico): uno script a
  passi che detta, turno per turno, cosa il giocatore deve fare. Ogni passo ha `azione`
  (`attacca` / `difendi` / `oggetto`, con `oggetto` opzionale per imporre quale), i messaggi
  `prima` (l'istruzione) e `dopo` (la reazione). Il menu azioni si riduce a quella sola voce,
  **evidenziata e pulsante** (`bottone_azione(..., evidenziato)`), le altre restano visibili ma
  spente; **Abilità → Studia resta sempre libero**, perché guardare non è mai un errore e non
  consuma il passo. Il portatore dello script **non agisce di suo**: le sue reazioni sono i
  testi dei passi, non tiri di dado. `oggetti_forniti` garantisce che il giocatore abbia gli
  oggetti richiesti; a passi finiti va in scena `finale` e lo scontro si chiude per copione
  (`sconfitta_scriptata()`), non per vittoria. Un passo può imporre l'esito con
  `"hp_protagonista"` / `"hp_nemico"`: sono i punti vita che il copione prevede dopo quel
  colpo, applicati subito dopo i messaggi `dopo` (`applica_hp_scriptati()`) — è così che il
  pugno di Veronica ti lascia a 1 e la bomba al nitro lascia lei a 1. Per lo stesso motivo,
  **in un combattimento tutorial gli accessori equipaggiati vengono spenti** (niente scudo
  contro gli stati, niente resurrezione a metà vita): la scena deve andare come è scritta.
  Le battute `dopo` arrivano **a azione risolta**, non prima, così commentano quello che è
  appena successo. Primo caso: l'allenamento con **Veronica** al
  quartier generale, che insegna Attacca, Difenditi, gli oggetti curativi e quelli offensivi —
  ed essendo `invincibile` non può essere uccisa per sbaglio
- **HP incatenati tra scontri**: a fine combattimento gli hp rimasti restano in
  `GameState.hp_persistenti` e il combattimento successivo riparte da lì; si recupera tutto
  appena si mette piede in una stanza **senza** che scatti un agguato (`Main.mostra_nodo()`).
  Così le ondate di Meridia danno l'impressione di uno scontro incessante invece di resettarsi
  ogni volta. Un nodo può chiedere `"mantieni_hp": true` per non far recuperare nemmeno lì:
  serve alle fasi di uno stesso boss, dove in mezzo c'è solo una scena (Jongo Dongo)
- **`"mossa_soglia_hp"`** su un nemico: `{frazione_hp, ...mossa}` — una mossa forzata, una volta
  sola, quando scende sotto quella frazione di vita (Jongo Dongo evoca tre ghoul a metà)
- Una mossa può avere `"stato"` (applica quello stato al bersaglio colpito) e
  `"richiede_flag"`/`"richiede_non_flag"` (esiste solo in certe condizioni di storia: il bastone
  dalla pietra marcia di Jongo Dongo sparisce se Yara si è fatta esplodere addosso a lui)
- La mossa `"sacrificio"` non viene nemmeno estratta se non c'è nessun alleato da sacrificare
- **Lo Slaughter non colpisce mai il party**: è un colpo di fortuna che vale solo contro i
  nemici comuni, in nessun caso contro i personaggi giocanti
- **`"rigenerazione"`** su un nemico: a ogni suo turno recupera **metà del danno che ha subito
  l'ultima volta** (`ultimo_danno_subito`); se in un turno non ne subisce, recupera comunque
  metà dell'ultimo valore registrato — quindi vale colpire in fretta, non forte. Dopo
  `colpi_prima_della_gamba` colpi incassati gli cede una gamba: resta fermo `turni_fermo` turni
  a ricucirsi, senza attaccare (una sola volta per scontro). È il **Titano Zombie**, l'incontro
  casuale più duro dei quartieri profondi di Meridia — non un boss né una fonte: la creatura
  più potente che quella frattura abbia prodotto, e un bersaglio da farming di alto livello
- **Mossa `"meta_vita"`**: toglie sempre **metà dei punti vita attuali** del bersaglio,
  ignorando difesa, livello e critici; sotto `hp_soglia_ko` (5) è invece un KO secco. Non
  uccide mai per il solo dimezzamento (lascia almeno 1 hp): o sei già quasi morto, o
  sopravvivi. È il "Pugno devastante" del Titano — ed è `telegrafata`, quindi hai un turno
  per curarti o difenderti
- **`"crisi_gelosia"`** su un nemico: nata da invidia verso il legame del party, tanto più
  probabile per giro quanto più `GameState.legame` è alto (`GameState.rng.randf() <
  legame × moltiplicatore_probabilita`, verificata a ogni suo turno). Una volta innescata dura
  `durata_turni` (un paio): difesa giù di `riduzione_difesa` per quei turni e una probabilità
  (`probabilita_inerte`) di restare inerte, saltando il turno del tutto. A differenza di
  "convinto"/cedimento non è mai definitiva: prendersi cura della squadra destabilizza il
  nemico più spesso, non lo sconfigge da solo. Prima ad averla: Jongo Dongo (numeri di
  partenza, da confermare)
- **Abilità di classe extra** (in `abilita` su una classe, il bottone in "Abilità" compare da
  solo): `"provocazione"` (i nemici colpiscono solo chi ha provocato) e `"attacco_area"`
  (colpisce tutti i nemici vivi, danno = attacco × `moltiplicatore_attacco_area` in regole.json,
  0.6 di default) — Yara (`sopravvissuta`, nei Cunicoli di Jondoh) è la prima ad averla
- Effetti oggetto in combattimento, oltre a hp/stress/speranza/danno: `"difesa_incontro"` (buff
  difesa che dura tutto lo scontro, non un turno solo come Difenditi) e `"cura_stati"` (azzera
  `stati_attivi`) — es. il Gel Omega
- **Nemico `"invincibile": true`**: il suo hp non arriva mai a 0 sul serio — `_su_ko()` lo
  intercetta prima, gli resetta hp a hp_max e mostra un testo, senza contare come vittoria
  (`vivi(false)` non si svuota mai: la vittoria resta semplicemente irraggiungibile). Pensato
  per scontri "non si vince, si sopravvive": vedi `"blocca_fuga_turni"` sotto
- **`"blocca_fuga_turni": N`** su un nemico: `Fuggi` resta disabilitato finché non è passato
  quel numero di giri (`giro_corrente`, si azzera a ogni scontro); un `"avviso_fuga":
  {turno, richiede_compagno, testo}` mostra una battuta una tantum in quel turno, solo se il
  compagno indicato è in squadra. Prima combinazione: l'Immortale nella cripta di Jondoh
  (invincibile + fuga bloccata 5 turni), pensato per fuggire (`"se_fuggi"` sulla scelta
  `"combatti"`) invece che vincere
- **Alleato temporaneo**: `recluta_temporaneo` (+`livello_alleato`) mette un compagno in squadra
  solo per lo squarcio/campagna corrente; `congeda` (o l'uscita dallo squarcio) lo rimanda via.
  Yhvina nella Casa Gigante; il Vecchio Proprietario del teatro nel mondo di Jerah (20 hp,
  attacco 0 — può essere colpito e cadere, ma non fa mai male sul serio). Deve stare in
  `classes.json` (non basta `personaggi.json`): `recluta_temporaneo()` lo richiede
- **`bottino_presenza`** su una classe: un alleato temporaneo può garantire un oggetto a ogni
  vittoria semplicemente per essere stato in squadra (`{oggetto, chance}`, risolto in
  `Combattimento.risolvi_drop()` insieme al resto del bottino) — es. la bottiglia di liquore
  del Vecchio Proprietario del teatro
- Il danno **subìto dal party cala in proporzione al livello** (probabilità di assorbire:
  (livello − 1) × 10%, tetto 50%, + fattore/200)
- Vittoria: XP e **Tazo** a tutto il party (somma di `xp` e `tazo` dei nemici). Sconfitta:
  nodo `se_perdi` o ritorno alla mappa
- **Presentazione dei colpi**: chi subisce danno e resta in piedi lampeggia di rosso
  (`Stile.lampeggia()`, chiamato in `attacca()`) — un colpo si vede sul ritratto, non solo si
  legge nel diario. Un nemico che cade **esce di scena in dissolvenza** invece di sparire di
  scatto (`aggiorna_scheda()` → `congeda_dal_campo()`); un invincibile che si rialza rientra
  allo stesso modo, non "riappare" dal nulla. Ogni cambio di schermata (vittoria, sconfitta,
  fuga) passa da `Transizioni.vai()`, mai da un `change_scene_to_file()` diretto
- **Nulla si chiude da solo**: a combattimento risolto (vittoria o sconfitta) compare un
  bottone "▸ Continua" (`mostra_continua_fine()`) al posto del vecchio timer automatico;
  il giocatore decide quando lasciare la schermata
- Tutti i numeri stanno in `data/regole.json`; l'RNG è quello seedato di GameState

### Come parla il combattimento
Prima tutto finiva in un diario che si allungava all'infinito in caratteri minuscoli: un blocco
di testo compresso che nessuno legge, dove il resoconto del tuo attacco di tre turni fa stava
ancora lì a rubare spazio a quello che conta adesso. Il problema non era la scrittura, era che
un canale solo stava facendo tre mestieri diversi. Ora sono tre canali, ognuno col suo:

| Canale | Cosa dice | Quando lo guardi |
|---|---|---|
| **il campo** (schede, barre di vita) | lo **stato**: quanta vita, che stati addosso | di sfuggita, sempre |
| **i numeri volanti** | il **colpo**: `−4` che sale dalla scheda di chi lo prende e svanisce | nell'istante in cui succede |
| **il box** (lo stesso dei dialoghi) | il **momento**: un messaggio alla volta, poi lascia il posto | mentre lo leggi |
| **lo storico** (ESC) | tutto quello che è passato | dopo, se ti è sfuggito qualcosa |

La conseguenza più visibile: **un colpo normale non produce più nessuna riga di testo**. Vedi il
numero salire, la scheda lampeggiare e la barra scendere — dirlo anche a parole era ridondante, e
sono proprio quelle righe che riempivano il diario di rumore. Il box resta libero per le cose che
vanno dette: un critico, un colpo parato, uno stato che attecchisce, una creatura che parla.

**Due velocità, ed è lì che nasce il ritmo.** `scrivi()` è ordinario (guardie, buff, veleno):
resta a schermo il tempo di leggerlo — proporzionale alla lunghezza, minimo 0.6s — e scorre da
solo, senza chiedere niente. `scrivi_forte()` è una conseguenza (risparmiare una creatura, un
boss che cede, un compagno a terra, un bottino, una mossa annunciata, tutto ciò che si scopre
Studiando): **aspetta un click**, e solo su questi il triangolino resta acceso — così quel
simbolo vuole dire una cosa sola, "questo sta aspettando te". Un click salta comunque avanti in
qualunque momento, e in pausa il conto si ferma.

Sotto c'è una coda (`coda_diario`). Chi produce testo non aspetta nessuno: accoda e prosegue. È
il giro dei turni che la svuota nei suoi punti di respiro — a fine turno, e **prima di mostrare
il menu delle azioni**, così non si sceglie mai con dei messaggi ancora da leggere. Una voce
della coda può portarsi dietro un `Callable`: è così che il numero volante, il lampo sulla scheda
e la barra della vita scattano nel messaggio giusto e non tre messaggi prima.

**Le conseguenze si dicono.** Risparmiare una creatura muoveva legame e stress in silenzio: ora
dopo la scena arriva la riga che dice cosa hai appena scambiato (*"Lo lasci andare: il legame
della squadra sale di 10, lo stress cala di 5, da lui non prendi né esperienza né Tazo."*). Il
bottino non è più una riga in coda a un elenco ma un messaggio suo, centrato, che aspetta.

## Inventario, Tazo e negozi
- **Sacca**: massimo 20 oggetti **utilizzabili** (consumabili). Slot separati per
  **collezionabili** (materiali per l'Artigiano), **oggetti chiave** e **carte da gioco**.
  Il tipo sta in `data/oggetti.json`; effetti: `hp`, `stress`, `speranza`, `danno`
- **Tazo**: la valuta universale (canone in docs/storia.md). Si guadagna da nemici
  (`tazo` nei loro dati), esplorazione e quest (chiave evento `tazo`, anche negativa
  per pagare); si parte con 30
- **Negozi** (`data/negozi.json`, scena Negozio dalla mappa): all'inizio solo l'Emporio
  dell'Organizzazione; il negozio di **Nyu** si sblocca incontrando Sally (chiave evento
  `sblocca_negozio`), la bottega dell'**Artigiano** più avanti — lui **baratta** materiali
  collezionati (`baratti`: richiede → produce). Lo stock evolve con le fonti estinte
  (campo `da_fonti`)

## Equipaggiamento: sette slot per personaggio
Ogni membro della squadra ha i suoi slot, e **quello che porta vale solo per lui**: un amuleto
addosso a Yhvina non protegge il protagonista. Si vestono da `ESC → Equipaggiamento`.

| Slot | Quanti | Cosa decide |
|---|---|---|
| **Arma** | 1 | come colpisci |
| **Stigma** | 1 | un patto: dà e toglie |
| **Accessori** | 4 | i piccoli aggiustamenti, che si sommano |
| **Ultima risorsa** | 1 | la rete che scatta quando stai per cadere |

Gli slot non sono numeri: se fossero sette caselle che fanno la stessa cosa sarebbero solo sette
occasioni di sommare +1. Ognuno ha un mestiere diverso, e uno — lo stigma — **non è un bonus**:
`stigma_del_veglio` dà aura per turno e toglie vita massima, `stigma_del_muto` dà difesa e toglie
attacco. I malus entrano nella stessa somma dei bonus, quindi indossarne uno è una decisione, non
un miglioramento gratuito.

**Ultima risorsa** tiene un consumabile qualunque che *non scegli di usare*: scatta da solo
appena la vita scende sotto `ultima_risorsa_soglia` (un quarto), una volta sola per scontro, e
rende `ultima_risorsa_bonus` in più (+20%). Una Fiala HP che di solito ne dà 20 lì ne dà 24 — ma
la tieni ferma lì invece di poterla usare quando decidi tu. È il tipico scambio che rende uno
slot interessante: comodità contro controllo.

I bonus numerici (`attacco`, `difesa`, `velocita`, `hp_max`, `aura_max`, `aura_per_turno`,
`resistenza_maledizione`) entrano nelle statistiche quando il combattente viene costruito. Le
protezioni speciali restano attaccate a chi le porta: `scudo_primo_stato` respinge il primo male
che prende **lui**, `resurrezione_dimezzata` rimette in piedi **lui**. Prima erano globali: una
Pietra Quieta addosso a chiunque proteggeva tutta la squadra.

## L'aura
Una seconda risorsa, per personaggio, che si spende per **forzare il mondo**: Provocazione costa
3, Colpo d'area 4 (`regole.json`). Torna da sola un punto a turno, quindi a fine scontro non è
mai un problema — dentro un turno lungo bisogna sceglierne l'uso. **Studia non costa e non
costerà mai niente**: guardare una creatura è il cuore del gioco, non una risorsa da amministrare.

Il massimo è `aura_iniziale` (10), o il campo `aura` della classe se ce l'ha, più quello che dà
l'equipaggiamento. Si legge sulla scheda accanto alla vita, e si ricarica con Fiala d'aura (+6) o
Essenza d'aura (+14).

## Come è fatto un negozio
Prima era un elenco piatto di righe uguali: nome, descrizione poetica, prezzo. Per decidere
dovevi già sapere cosa fa un oggetto e cosa hai in tasca. Ora ogni riga risponde da sola alle tre
domande che uno si fa davanti a uno scaffale:

- **che cosa fa** — l'effetto in numeri (`+8 vita`, `difesa +1`, `toglie sonno`), generato dalle
  stesse chiavi che legge il combattimento: un oggetto nuovo si racconta da solo, senza toccare
  `Negozio.gd`. La descrizione poetica resta, ma sotto
- **ne ho già** — quanti ne hai in sacca, o chi lo porta addosso se è roba da indossare.
  Comprare il secondo amuleto uguale dev'essere una scelta, non una distrazione
- **me lo posso permettere** — il prezzo e **quanti Tazo ti restano dopo**. Se non puoi, il
  bottone è spento e c'è scritto quanto ti manca; se la sacca è piena lo dice invece di lasciarti
  premere a vuoto

Lo scaffale è diviso per mestiere (da usare in combattimento / armi e stigmi / accessori), così
si sceglie tra tre categorie invece di leggere quindici righe tutte uguali. I baratti
dell'Artigiano dicono cosa ti manca invece di limitarsi a fallire.

## Psiche, stress, fattore Carnivalz
Ogni personaggio ha una **psiche** (`psiche` nella classe, definizioni in `data/psiche.json`):
quando un compagno va a terra, ognuno accusa il colpo a modo suo —
- **Rabbia** (`attacco_extra`): in rari casi (35%) attacca di nuovo nello stesso turno
- **Depressione** (`difesa_giu`): la difesa cala, subisce +1 danno
- **Concentrazione** (`fattore_su`): il fattore Carnivalz sale (+25)

Il **fattore Carnivalz** (0–100, base per classe in `fattore_base`) è volontà + talento:
dà probabilità pari al fattore di fare +1 danno e metà fattore di assorbire un colpo —
ma tenerlo acceso costa **stress** a ogni azione (+1 ogni 25 di fattore). Lo **stress**
(0–100) resta addosso anche fuori dal combattimento; a 80+ il personaggio è *sopraffatto*
e il fattore si spegne. Si scarica parlando, mangiando, con gli oggetti: chiave `stress`
negativa sulle scelte degli eventi (es. il falò: `"stress": -30`).

## Studio, speranza e i due esiti
I Carnivalz sono mondi distorti da una fonte che ha subito ingiustizie (canone in
`docs/storia.md`). **Studio** è un'abilità di classe (`"studio"` in `abilita`, ce l'ha
l'Anonimo): al posto di attaccare intavola un dialogo e **il nemico risponde** — coppie
domanda/risposta nella lista `studio` di ogni personaggio (anche i nemici comuni), oppure
una singola `osservazione` (corsivo, senza scambio) per chi non può davvero rispondere.
**Studio è sempre disponibile**, anche su nemici muti (robot, zombie, creature che non
parlano): se un nemico non ha proprio uno `studio` nei dati, esce comunque una riga scritta
("non sembra rispondere ad alcun quesito") invece di non succedere nulla. Chi viene
studiato finisce nel registro `studiati` (base per la futura sezione studio/codex). Gli scambi
di uno stesso personaggio, esauriti, ricominciano dal primo (`indice_studio % scambi.size()`)
— a meno che i dati abbiano `"testo_studio_esaurito"`: da quel punto in poi (`volte_studiato`
oltre la dimensione del pool) compare quel testo fisso invece di ripetere da capo il ciclo —
usato dalla manifestazione di un sogno (2 scambi, poi "la testa ti gira...").

I boss **possono o non possono essere convinti** (`convincibile` nei dati della fonte: i
malvagi, che manipolano il fattore, hanno `false` e la speranza non esiste per loro).
Se la fonte è convincibile compare la **Speranza**:
- **Leve** (lista `leve`): ospiti temporanei (`"ospite"`), compagni nel party (`"compagno"`)
  o flag di storia (`"flag"`, es. un'azione fatta prima dello scontro) valgono per il solo
  fatto di esserci: si applicano all'inizio dello scontro, con il loro testo. Le leve
  **`"oggetto"`, invece, vanno giocate**: averle in tasca non basta, compaiono nel menu
  **Oggetti** come voce "Mostra: <nome>" e costano un turno (`leve_utilizzabili()` /
  `usa_leva()`). Mostrare la cosa giusta alla creatura giusta è una mossa, non un passivo:
  chi ha esplorato deve comunque capire *quando* usarla. Il menu le elenca anche se sono
  oggetti chiave (che non stanno nella sacca), e ognuna si può giocare una volta sola per
  scontro (`leve_giocate`). Una leva può anche avere `"turni_fermo"` + `"testo_fermo"`: per
  quei turni la fonte non agisce affatto, mostrando quel testo al posto della mossa normale
  (prima combinazione: la spilla a margherita contro Un tenero ricordo, Casa Gigante)
- **`leva_obbligatoria`** sulla fonte: l'id di una leva `"oggetto"` senza la quale il
  cedimento non avviene **mai**, per quanta speranza si accumuli. Serve agli scontri lunghi,
  dove la speranza passiva (+2 a giro, +3 a colpo incassato) arriverebbe a 100 da sola e
  regalerebbe il finale buono a chi non ha trovato niente: Un tenero ricordo cede solo a chi
  le mostra la spilla a margherita, e la mostra davvero
- **Studia** sulla fonte: +10 speranza a scambio
- **Sopportare i colpi**: +3 quando un personaggio subisce o assorbe e resta in piedi
- **Prolungare lo scontro**: +2 a ogni giro completo

Alla soglia (`speranza_soglia`) la fonte **cede** (`testo_cedimento`) ma **continua ad
attaccare**: a ogni suo turno, con probabilità 50%, perde statistiche (fattore −10,
velocità −1, 1 danno a se stessa) fino alla sconfitta; gli scambi di studio passano a
`studio_cedimento`. Non esiste una conclusione 100% felice: cambia solo come muore —
fonte convinta → nodo `se_vinci_eroe` (pangea, reincarnazione), altrimenti `se_vinci`
(il pianeta viene distrutto). I nomi dei boss sono poetici (`nome` per il ritratto,
`nome_breve` per log e bottoni): il primo è **«L'ultimo spettacolo di Jerah»**.

## Crescita del protagonista (`data/crescita.json`)
Le stat **non salgono da sole con il livello**: salgono in base a *quello che hai fatto*. Ogni
azione riempie un contatore (`GameState.registra_azione()`); a ogni passaggio di livello i
contatori diventano punti stat e si azzerano (`applica_crescita_livello()`), col resto che
avanza al livello dopo.
- **Le stat**: `hp`, `attacco`, `difesa`, `velocita`, `intelligenza` (aumenta la probabilità di
  fuggire), `forza_mentale` (resistenza allo stress: attutisce lo stress in arrivo) e `fattore`
  (**Dominio**, già Fattore Carnivalz: alimenta critici e Slaughter). Solo il protagonista le usa —
  `Combattimento.aggiungi_combattente()` legge `GameState.stat_di()` per lui e i valori fissi di
  `classes.json` per tutti gli altri
- **Cosa alimenta cosa** (campo `crescita`, `ogni` = quante azioni per un punto): attaccare →
  attacco, incassare danni → hp, difendersi → difesa, studiare e fuggire → intelligenza, usare
  oggetti → hp, esplorare stanze nuove → velocità, accumulare stress → forza mentale, mettere a
  segno critici → fattore
- **Resistenze agli stati**: subire uno stato allena la resistenza a *quello* stato
  (`registra_stato_subito()`); ogni `soglia_punto` volte vale un punto, e al massimo si diventa
  immuni. Vale solo per il protagonista
- **Passive**: si sbloccano da sole e vengono annunciate come notifica appena si torna a una
  schermata di eventi (`Main.notifiche_passive()`). Tre famiglie in `crescita.json` —
  `passive_soglia` (valori di stat raggiunti: Altruismo, Furia, Perspicacia acuta, Leadership,
  Karma positivo, Benedizione dell'agnello, Disastro vivente), `passive_livello` (dal livello 10
  al 130: Non c'è tempo!, Trinità, Crudeltà, Infinito, Una nuova alba…) e `passive_rare`
  (Preferito del gatto: estratta a ogni livello con probabilità bassissima, garantita al 120)
- **Effetti già attivi**: i bonus al drop (`bonus_drop`: La tua immondizia è il mio tesoro,
  Tryharder), quelli alla carta (`bonus_carta`: Illuminazione 1 e 2) e Crudeltà
  (`slaughter_bonus` contro nemici molto sotto livello) sono letti dai dati e applicati.
  **Le altre passive sono dichiarate e si sbloccano, ma il loro effetto non è ancora
  implementato**: sono elencate qui e in `crescita.json` come contratto da riempire

## Via i turni: il combattimento in tempo reale
I nemici non aspettano che tu scelga. Ognuno ha una **ricarica** che scorre da sola; quando
finisce, agisce. Se stai fermo, ti arrivano addosso lo stesso — è questo che rende il gioco
frenetico pur restando una schermata ferma.
- **Una battuta è un ciclo di ricarica tuo**, non un tempo globale. Così «tre turni di veleno»
  vuol dire tre tue battute, esattamente come prima, e tutto quello che contava i turni —
  stati, Astio, guardia a scatti, rigenerazione — continua a funzionare senza sapere che il
  mondo è cambiato sotto. Era la traduzione giusta: un turno *è* sempre stato «la prossima
  volta che tocca a te»
- **Il tempo si ferma solo quando il gioco ha qualcosa da dirti**: mentre **studi** una
  creatura e mentre un **boss esegue uno script**. Senza, studiare sarebbe una punizione —
  apri una pagina di testo e intanto ti picchiano in tre — e lo Studio è il cuore del gioco.
  `ferma_il_tempo()` si annida, e riparte da solo quando non c'è più niente da leggere
- **Un motore, due orologi.** In gioco il tempo lo dà `_process(delta)`. Nelle prove e nel
  giocatore automatico c'è un orologio virtuale che *salta* al prossimo momento in cui
  qualcuno agisce: non misura un gioco diverso, perché l'ordine delle azioni esce dalle stesse
  ricariche — cambia solo se il tempo lo conta un cronometro o l'aritmetica
- **Sul nemico si clicca**: il colpo normale non è una voce di menu, è la creatura stessa —
  ci si martella sopra, e se la ricarica non è pronta il click non conta. Il menu resta per
  quello che non si fa colpendo: difendersi, gli attacchi d'arma, gli speciali, gli oggetti,
  gli alleati, la fuga
- **Il menu non sparisce mai, si spegne**: mentre ricarichi i bottoni restano al loro posto
  in grigio invece di essere cancellati. Si vede lo stesso che non è il tuo momento, e si
  continua a leggere cosa si potrà fare — prima, per metà dello scontro, sotto non c'era
  niente. Dopo ogni scelta il menu torna al principale da solo
- **Le parole scorrono, il mondo non si ferma**: `pompa_messaggi()` svuota la coda in
  parallelo al tempo, e i messaggi «forti» in tempo reale non aspettano più un click. Senza
  quella pompa non arrivava a schermo un solo numero di danno e lo scontro non si chiudeva
  mai — nel motore a turni erano il ciclo a fare tutte e due le cose
- **Il party agisce da solo**; tu comandi un personaggio alla volta (`id_comandato`) e gli
  altri se la cavano con `azione_automatica()`
- I nemici di livello basso fanno **meno male** di prima: in tempo reale i colpi arrivano più
  spesso, e la difficoltà la fa la fretta con cui devi decidere, non la cifra del danno

## La Mattanza: la barra si svuota, e finché si svuota tu batti (`abilita.json` → `mattanza`)
È la cosa che la barra di dominio serve a comprare, e l'unico momento del gioco in cui il
combattimento passa dalle mani invece che dalle scelte. Bru: «quando riempi almeno una barra
puoi andare in mattanza, **solo in quel momento**; la mattanza consuma tutta la barra e finché
non è consumata potrai premere spazio per colpire numerose volte il nemico, con un valore di
ogni colpo pari a 1/10 del tuo attacco attuale».
- **La soglia è a segmenti pieni** (`dominio_minimo`: 1). Mezza barra non apre niente: è quello
  che rende il dominio una cosa che si *aspetta* invece di un contatore che sale. Nel menu la
  voce resta spenta finché non è ora — un bottone acceso che poi risponde «non hai abbastanza
  dominio» è un bottone che ha mentito, quindi il menu e il motore fanno la stessa domanda a
  `dominio_sufficiente()`, non due domande somiglianti
- **Non ha un prezzo, ha un serbatoio** (`consuma_tutto`): si porta via *tutta* la barra, e
  quanta ce n'era decide quanto dura la finestra (`secondi_per_segmento`, 2,2 s per segmento —
  una barra sola dà poco più di due secondi, tre ne danno quasi sette). Per questo tenersela da
  parte è una scelta e non solo pazienza
- **La durata è la barra stessa che si scarica.** Non c'è un secondo contatore accanto a quello
  vero: guardi la barra scendere e sai quanto ti resta. Il dominio viene riscritto ogni frame
  dal residuo, così un colpo incassato — che normalmente ricarica — non può allungare la
  finestra all'infinito
- **Ogni pressione di spazio è un colpo** da `frazione_attacco` (un decimo) del tuo attacco di
  adesso, e va **diritto**: ignora la difesa. È il motivo per cui vale la pena tenersela per i
  corazzati, invece di essere l'ennesima cosa che contro un corazzato non serve. `is_echo()` è
  esclusa apposta: tenere premuto non vale come martellare
- **Il mondo va avanti mentre batti** (`ferma_il_tempo: false`): sei chiuso lì a pestare e le
  creature ti picchiano, quindi *quando* la chiami conta. Metti `true` nei dati se preferisci
  che diventi un momento tuo e basta
- **Nelle prove qualcuno batte al posto tuo**: nell'orologio virtuale non esiste una barra
  spaziatrice, quindi la finestra si risolve tutta insieme a `pressioni_al_secondo` (6). Senza,
  il simulatore direbbe che la Mattanza non fa danno — e ricalibreremmo il gioco su un'abilità
  che non ha mai colpito
- Si prova in `prova_mattanza_svuota_la_barra()`, che la misura muta e poi ne apre una vera per
  premere spazio davvero

## Le creature capiscono come stanno (`personaggi.json` → `mosse`, `ruoli.json` → `disperazione`)
Bru: «dobbiamo dare un set di attacchi a ogni nemico che o fanno danno o fanno cose... quando i
nemici sono a fin di vita diventano più ostici, devono capire la loro condizione e usare le mosse
a loro disposizione **saggiamente** — se hanno pochi punti vita devono capirlo, e se hanno
attacchi che li curano li attivano».
- **Ogni creatura che combatte ha un set di mosse.** Erano trenta su trentanove a non averne
  nessuna: tiravano il loro colpo normale finché uno dei due cadeva. Una creatura senza mosse
  non è un nemico facile, è un nemico che non c'è — e nessuna prova poteva accorgersene, perché
  il motore funzionava benissimo: era il bestiario a essere vuoto
- **Il valore di una mossa è una quota del suo attacco** (`quota: 1.4` = una volta e mezza scarsa
  il suo colpo normale), non un numero scritto. Un numero scritto resta fermo mentre la creatura
  viene tirata su dal disallineamento: le mosse dei boss valevano **un terzo** del loro stesso
  colpo normale, ferme alla scala di prima del riscalamento. Ora una mossa è calibrata a
  qualunque livello, e ricalibrare resta una riga in `ruoli.json`
- **Prima il giudizio, poi il caso.** Ogni mossa può dichiarare `quando` (le condizioni perché
  esista: `vita_sotto`, `bersaglio_vita_sotto`, `alleati_almeno`, `battuta_almeno`, `senza_stato`,
  …), `priorita` (se > 0 e le condizioni ci sono, la mossa si **sceglie** invece di sorteggiarla —
  vince la più alta) e `ricarica` (quante sue battute prima di rifarla). Una cura a priorità alta
  sotto il 30% di vita non è una possibilità su cinque: è quello che una creatura ferita *fa*
- **Una cura senza ricarica non rende lo scontro difficile: lo rende infinito.** La mossa migliore
  resta la migliore anche il giro dopo. È una regola provata, non una raccomandazione
- **Tre tipi nuovi**: `cura` (si rimette in piedi, o rimette in piedi un alleato), `rubavita`
  (colpisce e si nutre di quello che toglie) e `stato` (nessun danno: solo quello che ti lascia
  addosso). Undici creature ora sanno rimettersi in piedi
- **Alle strette diventano peggiori**, e vale per *tutte*: sotto il 30% della vita una creatura
  colpisce il 30% in più e comincia a scegliere. È una riga sola in `ruoli.json`, non una cosa
  scritta creatura per creatura — così non può mancare a metà bestiario. Ed è **dedotta**, non
  memorizzata: non esiste il caso di una creatura disperata a vita piena
- **Il documento**: [`docs/nemici.md`](docs/nemici.md) — statistiche e set di mosse di tutte e 39
  le creature, con i valori calcolati. Lo **genera il gioco** (`./strumenti/nemici.sh`) dagli
  stessi numeri che usa in campo: un documento scritto a mano racconta il gioco del giorno in cui
  è stato scritto, e nessuno se ne accorge finché non ci si fida
- **Una creatura non spreca mai la sua battuta.** Bru: «se si parla di ricarica della mossa è ok
  — non può usare *quella* mossa per tre battute — ma se il nemico rimane fermo per tre battute
  non va bene». La ricarica toglie la mossa, non il turno: quello che `mossa_eseguibile()` scarta
  fa cadere la creatura sul suo colpo normale. Ci passano tutte e cinque le strade che portano a
  una mossa (sorteggio, giudizio, soglia di vita, disperazione, mossa annunciata), perché finché
  il controllo stava dentro il solo sorteggio le altre quattro lo scavalcavano. Non parte: un
  richiamo col campo già pieno, una guardia già al massimo, una cura a vita piena, un sacrificio
  senza alleati, uno stato su chi ce l'ha già, un incendio su chi già brucia, un potenziamento
  ancora acceso
- **Lo stesso potenziamento si rinnova, non si somma.** Ogni uso appendeva un buff nuovo: il
  goblin arrabbiato si sommava +9 di attacco all'infinito e Jerah +14 di difesa finché non lo si
  scalfiva più — una somma senza tetto, invisibile perché a schermo compare solo il totale. Due
  mosse *diverse* sulla stessa statistica si sommano ancora
- Si prova in `prova_ogni_creatura_ha_un_set_di_mosse()` (i dati),
  `prova_le_creature_capiscono_come_stanno()` (la testa) e
  `prova_nessuna_creatura_perde_la_battuta()`, che fa giocare a ognuna 24 battute **col colpo
  normale tolto dal sorteggio**: col peso normale una creatura tira spesso un pugno, e un pugno
  non è mai una battuta persa — la prova passerebbe anche col motore rotto

## Il drop crea dipendenza: il drop c'è sempre (`ruoli.json` → `drop_garantito`)
La dipendenza non nasce dai premi grossi: nasce dal fatto che **non esca mai niente**. Dieci
scontri di fila a mani vuote e non si combatte più volentieri — e nessuna tabella di
bilanciamento se ne accorge, perché il gioco resta «equilibrato» e smette solo di tirare.
- Ogni creatura lascia **sempre** qualcosa, e il pavimento viene **prima** di tutti i tiri di
  dado: pochi Tazo, un **Frammento di vita**, o **Cianfrusaglia**. Le probabilità escono dal
  ruolo, non da quaranta righe scritte a mano; una creatura può dichiarare un suo
  `drop_garantito` e allora vince quello — è il posto dove darle *qualcosa di suo*
- **La pila** è uno scomparto a parte, e non è un dettaglio: se la roba da vendere finisse
  nella sacca, ogni scontro riempirebbe lo spazio dei consumabili e il giocatore passerebbe la
  partita a buttare via cose invece che a combattere. Nella pila si accumula e basta. Non è
  una lista ma **un conto per tipo**: 999 cianfrusaglie sono un numero, non 999 voci. 99 per
  tipo, **999 per la cianfrusaglia**, l'unica che lasciano tutti
- **Frammento di vita**: non ridà una cifra, apre una rigenerazione di **3 battute al 10%**.
  È poca apposta — il valore non sta nel quanto, sta nel *quando* lo prendi

## La barra di dominio è energia (`regole.json` → `dominio`)
Non più un contatore passivo: una risorsa che entra ed esce. Si riempie **attaccando,
cogliendo in pieno, abbattendo qualcuno e incassando**; ha **tre segmenti — verde, blu,
rossa** — e gli attacchi speciali li spendono.
- **Spezza spazio** (una barra intera) e **Mattanza** (una barra e mezza) ci sono dall'inizio
- **Maestria del dominio** (fino a 100 punti): la barra si riempie prima e si consuma meno.
  È la statistica di chi gioca sugli speciali invece che sui colpi normali — la scelta stile
  Dark Souls fra alzare le basi e alzare quello che ci fai. A 100 punti uno speciale costa il
  40% in meno, **mai meno di mezza barra**: sotto quella soglia la barra smetterebbe di essere
  una risorsa

## La mappa di zona: si cammina, e si cammina al buio
Dalla mappa **non ci si teletrasporta**, e adesso ci si può anche esplorare — prima no, ed era
il difetto che la rendeva inutilizzabile: `si_puo_andare()` pretendeva che la stanza fosse
*già* sbloccata, ma una stanza si sblocca solo se un evento la nomina. Quindi i punti
interrogativi invitavano ad andarci e poi rispondevano «da questa parte non si passa». Una
mappa su cui non si può esplorare non è una mappa, è un disegno.
- **Nei posti confinanti ci si va sempre**, scoperti o no: andarci *è* il modo di scoprirli.
  Entrare in una stanza la sblocca (`IngressoNodo.applica_effetti`)
- Il resto della mappa resta guardabile e non raggiungibile: si vede che c'è, si vede che non
  ci si salta
- **I proiettori sono una rete, non un ritorno alla base**: se ne piantano più d'uno per zona,
  e si salta da uno all'altro **solo stando su un proiettore**, e solo verso un proiettore in
  un posto dove sei già stato. Se sei in mezzo al niente, cammini

## La guardia a scatti (come in Pokémon)
Difendersi alza la difesa di **uno scatto**, e lo scatto **resta fino alla fine dello
scontro**: difendersi cinque volte vale cinque volte. Prima era un buff da un turno che si
azzerava appena facevi altro, quindi difendersi cinque volte valeva quanto difendersi una —
fra una e l'altra dovevi pur combattere.
- Ogni scatto in su vale meno del precedente (`(2+n)/2`), e sopra `difesa_scatti_massimi` (6)
  non si sale: non si diventa mai inattaccabili stando fermi
- **Certi colpi la aprono**: una mossa con `abbassa_difesa` fa scendere gli scatti, anche
  sotto zero, e allora si incassa più del normale. Serve perché senza qualcosa che la faccia
  scendere, chiudersi sarebbe una strada senza rischio — e una strada senza rischio non è una
  scelta, è l'unica cosa sensata da fare
- Il `difesa_scatto_piatto` esiste perché qui la difesa base può essere **zero** (il
  protagonista al livello 1 non ne ha), e qualunque moltiplicatore per zero resta zero

## Salire di livello si vede
In Carnivalz le statistiche non salgono col livello: salgono con quello che hai fatto, e
diventano punti proprio al passaggio di livello. Quello è l'unico momento in cui il giocatore
scopre **a cosa è servito giocare come ha giocato**, quindi lo dice: il livello raggiunto,
ogni statistica cresciuta con prima → dopo, e i punti abilità disponibili
(`GameState.salite_di_livello`, mostrate da `Main.notifiche_salite_di_livello()`).

## Abilità, progressione e armi (`data/abilita.json`)
Le abilità stavano in `regole.json` in mezzo ai numeri di bilanciamento, ed erano quattro. Ora
hanno un file loro, perché sono diventate una **progressione**: non solo cosa sa fare un
personaggio, ma quando lo impara e cosa può diventare.
- **Fino al livello 24 le abilità arrivano da sole** ai livelli scritti nei dati: Astio (5),
  Vendetta (8), Flagello (11), Mantra (14), Annichilazione (19). Sono il mestiere di base, non
  una scelta
- **Dal 25 arrivano i punti**, uno ogni quattro livelli, e li spendi sui nodi che il tuo
  livello ha aperto — l'idea di Bru del sistema a distribuzione di punti stile Final Fantasy
  XIII. **Le due scelte che aveva descritto escono da sole da questa regola** e non sono
  scritte come casi particolari: al 25 hai un punto e davanti Pietà o Terra bruciata, al 29
  ne hai un altro e davanti quello che non hai preso più Annichilazione II
- **Le linee** sono abilità che crescono. Di una linea si conosce **un grado solo**, il più
  alto: Terra bruciata prende il posto di Flagello nel menu invece di stargli accanto —
  altrimenti dopo cinque potenziamenti il menu sarebbe una lista di sei versioni della stessa
  cosa. `prova_linee_abilita` fallisce se due gradi della stessa linea risultano noti insieme
  - **Flagello** → Terra bruciata → Maelstrom → Devastazione → Apocalisse → *Fine karmica*
  - **Annichilazione** I→V → *Annichilazione totale* (KO al 50/55/58/62/65/**70%**)
  - **Mantra** I→V → *Pace assoluta*
- **I nodi che non sono abilità**: potenziamenti dell'attacco normale, della vita e della
  barra di dominio. Costano punti come tutto il resto, così anche "non prendere niente di
  nuovo" è una scelta
- **Le armi portano i loro attacchi** (`attacchi` sull'oggetto): equipaggiare un'arma fa
  comparire una serie di attacchi suoi, e il danno è **l'attacco base del personaggio più il
  bonus dell'arma per quell'attacco**. Cambiare arma non cambia un numero, cambia cosa puoi
  fare. Le classi d'arma dicono chi impugna cosa: il protagonista usa qualunque arma come
  **catalizzatore** (non combatte con l'arma, combatte *attraverso* l'arma), Veronica le
  **pesanti**, Yhvina **artigli e glifi**
- **Fattore Carnivalz e barra di dominio sono due cose diverse**, e per un giorno si sono
  chiamate tutte e due «Dominio». Il **Fattore** è la brace che alimenta critici e Slaughter
  (chiave interna `fattore`, parte da 15); la **barra di dominio** è l'energia a tre segmenti
  che si riempie combattendo e si spende sugli speciali. Con quel nome in comune, la barra
  sulla schermata dei dialoghi mostrava la statistica e risultava già carica a inizio partita
- **La barra vive solo nel combattimento e si azzera a ogni scontro**: non è una risorsa che
  ti porti in giro per la mappa. La schermata dei dialoghi non mostra né lei né le
  statistiche — quelle si consultano nel Diario

## Da dove escono i numeri delle creature (`data/ruoli.json`)
Nessuna creatura ha più `hp`, `attacco`, `difesa`, `velocita`, `xp` e `tazo` scritti nel suo
record. Dichiara due cose — a che **livello** sta e che **ruolo** ha — e i numeri escono da
`ruoli.json` (`GameState.stat_di_ruolo()`, chiamata dall'unico imbuto che già esisteva,
`stat_nemico()`). Prima erano 40 creature × 6 numeri scritti a mano in momenti diversi:
bastava aggiungere contenuto perché il gioco si sbilanciasse in un punto qualunque, e
ricalibrare voleva dire ripassarli tutti.
- **`ruoli.json` non ha numeri suoi: ha quote del protagonista.** Il riferimento a un dato
  livello è `GameState.stat_eroe_tipo()`, cioè quanto vale davvero il protagonista lì —
  stat base di `crescita.json` più i punti che uno che ha giocato fin lì ha guadagnato, con
  la stessa stima (`profilo_giocatore_tipo`) che usa il giocatore automatico, letta dallo
  stesso posto. Quindi **le due curve non possono divergere: è una sola**. Se cambi la
  crescita del protagonista, tutte le creature si spostano con lui nello stesso istante
- **I ruoli** (`comune`, `veloce`, `corazzato`, `particolare`, `miniboss`, `fonte`,
  `oggetto_scena`) sono moltiplicatori sulla curva, e dicono *come si combatte* contro quella
  creatura — non che cosa è nella storia (quella resta `categoria`, per musica e aperture)
- **Le manopole**, tutte in `ruoli.json`: `quota_hp` e `quota_attacco` (quanto vale una
  creatura rispetto a te), `scontri_per_livello` (il ritmo: quante creature comuni del tuo
  livello per salire di livello — l'esperienza non è scelta, è il fabbisogno diviso per
  quel numero) e `deriva_attacco_per_livello` (quanto il tardo gioco si fa più duro oltre
  alla semplice crescita dei numeri). **Ricalibrare il gioco intero è cambiare una riga**
- **I tazo hanno una curva loro** (`tazo.base`, `tazo.per_livello`), e non è una svista:
  l'esperienza insegue un fabbisogno che cresce come `livello^1.5`, i soldi inseguono un
  negozio con i prezzi scritti a mano e fermi (una razione 10, un frammento 150). Agganciarli
  all'esperienza sembrava più elegante — una curva in meno — ma raddoppiava i soldi del tardo
  gioco e affamava il livello 1. Restano due numeri in un posto solo, non uno per creatura
- **Le eccezioni sono dichiarate**: una creatura può ancora scrivere un numero a mano e quel
  numero vince, ma deve dire *perché* (campo `fuori_curva`) — `prova_curva_creature` fallisce
  se non lo fa, e fallisce anche al contrario, se una ragione resta lì a descrivere un numero
  che non c'è più. Le eccezioni attuali sono cinque e sono tutte scelte narrative (la
  Tartaruga Innocente che è un indovinello, l'Immortale che non va battuto, il goblin del
  tutorial che deve essere un macellaio, Veronica che è scriptata, la bambola che si vince
  con le leve)
- **Una creatura tirata su dal disallineamento** non è più «la sua stat base più una
  percentuale per livello di scarto»: è la stat che ha una creatura *del suo ruolo a quel
  livello*, presa dalla stessa curva. Il vecchio +13% per livello faceva una cosa che nessuno
  aveva mai visto, perché il simulatore non guardava sopra il livello 8: **i boss diventavano
  più difficili man mano che salivi** (dal 18 al 25 il protagonista cresce di 1,2 volte, un
  nemico livellato col +13% cresceva di 1,5 — Jerah si vinceva il 100% delle volte al livello
  18 e il 29% al 25). `prova_salire_di_livello_non_peggiora` adesso lo impedisce:
  una creatura tirata su può avvicinarsi a una nata al tuo livello, mai superarla
- La tabella dei numeri che ne escono, livello per livello e ruolo per ruolo, sta in
  `docs/bilanciamento.md` — generata, non scritta a mano

## Esperienza e legame
- **XP**: la vittoria dà XP a tutto il party; livello massimo **130**, fabbisogno
  `xp_base × livello^1.5`, e i 30 livelli dopo il 100 sono ostici (fabbisogno ×5)
- **XP a rendimento decrescente** (`Combattimento.xp_effettiva()`): ogni nemico ha un
  `"livello"` consigliato nei dati (1 di default); superato quel livello, il party guadagna
  `−xp_penalita_per_livello_extra` (15%) per ogni livello di scarto, con un pavimento a
  `xp_minimo_percentuale` (10%). Così una **farm zone non diventa mai del tutto inutile**, ma
  smette in fretta di essere la scorciatoia migliore: gli zombie comuni (livello 1) rendono
  quasi nulla già al livello 10, mentre il Titano Zombie (livello 10) resta remunerativo molto
  più a lungo. Chi vuole farmare può farlo, ma perde tempo rispetto ad avanzare
- **Legame** (0–100): si coltiva interagendo e prendendosi cura dei compagni (chiave
  `legame` sulle scelte) e **cala di continuo** (−1 a ogni scelta). Un legame alto fa
  apparire gli eventi rari: chiave `richiede_legame` sulle scelte (es. la stella caduta
  di Niru al falò richiede legame ≥ 40)

## Dialogare con i compagni
Nella schermata eventi (campagna o squarcio) compare "Parla con la squadra" quando il party
ha almeno un compagno oltre al protagonista — **solo a coda di messaggi vuota**: durante la
lettura di una sequenza il bottone resta nascosto, non "sfarfalla" a seconda del punto in cui
ti trovi. Clic → scegli un compagno → se `data/dialoghi.json` ha una voce per il nodo corrente
(`luoghi.<id_nodo>`, formato `sequenza`) la mostra (narrazioni con `%s` sostituito dal nome di
chi parla, dialoghi col nome del compagno centrato), altrimenti un fallback generico. Le voci
con `una_tantum` si dicono una volta sola e possono impostare un `flag` — usato per sbloccare
scelte altrimenti nascoste (es. la botola sotto i cuscini nella Casa Gigante: nessuno la nota,
da soli). Dopo la battuta le scelte si ricostruiscono, così l'eventuale sblocco appare subito.

**Mediazione**: se due compagni presenti nel party stanno discutendo tra loro in un nodo
(`data/dialoghi.json` → `conversazioni.<id_nodo>`, chiave `tra: [id1, id2]`), "Parla con la
squadra" mostra anche un'opzione per assistere alla conversazione. Dopo le loro battute, se la
voce ha una `mediazione` il giocatore può intervenire: le opzioni possono richiedere un oggetto
in sacca (`richiede_oggetto`, es. mostrare un ricordo trovato altrove) per sbloccarsi, e ognuna
assegna un bonus/malus di `legame`. Ciò che dice Anonimo (`battuta`) e l'eventuale replica del
compagno (`risposta`) sono pagine di dialogo vere e proprie, mai testo nascosto nell'etichetta
del bottone — il bottone descrive l'azione ("Mostra la collana..."), non la battuta stessa.

## Drop, carte e collezioni
Alla vittoria, ogni nemico sconfitto può lasciare:
- **Bottino comune** (`bottino_comune` nei dati: lista `{oggetto, chance}`) — consumabili/materiali
  tipo fiala HP o rottame di metallo, va nella sacca o tra i collezionabili
- **Carta** (`carta`: `{id, nome, rarita, testo, chance?}`) — se manca `chance` è **garantita**
  (nemici unici: miniboss e boss); con `chance` è un drop **raro** (comuni 3–5%, "particolari" fino
  al 6%). Rarità: comune · non_comune · rara · epica · leggendaria
- **Drop raro** (`drop_raro`: `{chance, tazo, oggetto, peso_tazo, peso_oggetto}`) — usato dai
  nemici rari come il Divoratore: con probabilità `chance` scatta un premio unico, scelto a peso
  tra un grosso bonus Tazo o un oggetto speciale (es. il Convertitore)
- **"Il mondo è il mio Tesoro"** (arma forgiata dall'Artigiano con Convertitore + rottami):
  finché la possiedi, **raddoppia** la chance di carta e di drop raro su ogni vittoria

Tre **collezioni** meta (menu principale), che si popolano da sole e non si perdono a fine
campagna (in `GameState`: `carte`, `bestiario`, `oggetti_catalogo`):
- **Album delle carte** — una carta per nemico; slot "???" finché non la ottieni
- **Bestiario** — voce al **primo incontro** (registrata in combattimento). Alcuni nemici hanno
  una `descrizione_extra` con gate `richiede_oggetto`/`richiede_flag`: si svela quando possiedi
  l'oggetto o hai il flag (Jerah col biglietto, la bambola con la Prova di un forte amore)
- **Oggetti** (compendio) — voce quando ottieni un oggetto almeno una volta (qualsiasi via:
  drop, evento, negozio, baratto — tutto passa da `aggiungi_oggetto`)

Schermate: `Menu.tscn` (scena d'avvio) → Album/Bestiario/Compendio, che estendono la base
`Collezione.gd`. Si raggiunge il menu anche dalla mappa (bottone "Menu").

## Il Vuoto
Ogni punto "!" apre il suo **sistema deformato** (scena Vuoto): il pianeta al centro
(→ selezione party → campagna) e gli **squarci** intorno, definiti in `mappa.json`
(`vuoti` del punto: id, nome, pos, file_eventi, `nascosto` + `richiede_oggetti`/
`richiede_flags` per farli apparire). Gli squarci usano il motore eventi con stanze
collegate nei due sensi (perlustrazione libera).

**Le fratture non sono quest.** Sono frazioni del mondo vero, aperte come conseguenza del
Carnivalz: non contengono una fonte e non si "completano" sconfiggendo qualcosa. Le prime
del Vuoto Ardente (Meridia, Squarcio Industriale) si chiudono semplicemente esplorandole fino
in fondo — il flag che impostano è di **esplorazione** (`meridia_esplorata`,
`industriale_esplorato`), non di quest. La fonte non sta qui: si incontra nelle fratture più
avanti. Fanno eccezione i luoghi che una fonte ce l'hanno davvero (la Casa Gigante con la
bambola, i Cunicoli di Jondoh con Jongo Dongo), dove il flag è legato allo scontro.
- **`agguato`** su un nodo: `{probabilita, gruppi: [[ids]...], se_perdi}` — tirato una
  volta per stanza a visita (seedato); vinto lo scontro si torna nella stanza; a ogni
  rientro nello squarcio gli agguati si resettano (i nemici rispuntano). Con
  `"ripetibile": true` la stanza non si esaurisce mai: continua a generare scontri a ogni
  ingresso anche nella stessa visita — è così che funziona una **farm zone** (Meridia)
- **`una_tantum`** su una scelta: appare solo se il flag non è mai stato preso, e lo
  imposta scegliendola (loot permanente: Tazo, oggetti). `flag` (su scelta o nodo) +
  `richiede_flag`/`richiede_non_flag` per stanze segrete e boss che non rispawnano
- **`torna_vuoto`** su una scelta: esce dallo squarcio (gli alleati temporanei restano fuori)
- **`game_over`** su una scelta: sconfitta seria (tipicamente contro una vera fonte, ma è una
  scelta del content author nodo per nodo — il tutorial, per esempio, la usa per ogni scontro).
  **Non si viene sbalzati sulla mappa stellare**: `GameState.game_over()` rientra nella zona in
  cui si stava giocando e la fa ripartire dal suo `nodo_iniziale` (`file_eventi_corrente`),
  restituendo `false` solo se non c'è una zona in cui tornare — solo in quel caso si finisce
  sulla mappa. **Non ricarica il salvataggio**: l'autosalvataggio è un file solo, condiviso da
  tutte le partite, e rileggerlo alla morte significava ritrovarsi addosso l'inventario di
  un'altra sessione. La penalità della morte è rifare il livello, non perdere la partita in
  corso. Le sconfitte comuni, dove non serve, restano un `se_perdi` qualsiasi
- **`vai_se_flag`** su un nodo: `{flag, vai}` — se quel flag è impostato, entrando in quel nodo
  se ne mostra un altro al suo posto (`Main.mostra_nodo()`, prima di qualunque altro effetto).
  Serve alle stanze che cambiano alla seconda visita: la collina del tutorial mostra l'agguato
  della manifestazione solo la prima volta, poi una scena diversa con la scelta se affrontarla
- **`scena`** su un nodo: la descrizione del posto *com'è adesso* (stringa, o una sequenza di
  messaggi). Alla **prima visita** il nodo gioca la sua `sequenza`/`testo` per intero, dialoghi
  compresi; da lì in avanti mostra la `scena` al suo posto (`Main.contenuto_nodo()`, che legge
  `nodi_visitati`). Serve a non far risentire le stesse battute ogni volta che si torna
  indietro — il difetto più fastidioso di un dungeon esplorabile in qualunque ordine. Quando
  un nodo sta mostrando la sua scena compare anche il bottone **"Osserva la scena"**, che la
  ridescrive senza costare niente (non muove il legame, non fa scattare agguati). I nodi che
  sono già una pura descrizione di stanza non hanno bisogno di `scena`: il loro `testo` è
  giusto che si rilegga ogni volta
- **`combattimento_automatico`** su un nodo: `{nemici, se_vinci, se_perdi, se_fuggi}` — a fine
  sequenza il combattimento parte da solo, senza mostrare scelte (`Main.avvia_combattimento_
  automatico()`). Usato quando non c'è davvero nulla da scegliere: lo scontro è inevitabile
- Testo d'apertura del combattimento (`Combattimento._ready()`): "Ora di combattere." per i
  nemici comuni/particolari, la frase drammatica ("Il disallineamento fa spazio: si combatte.")
  solo se tra i nemici presenti c'è un boss o un miniboss (`categoria_migliore_presente()`,
  condivisa con `avvia_musica_e_voce()` per la scelta della musica)
- **`espulsione_automatica`** su un nodo: nessuna scelta reale, dopo una breve pausa si torna
  da soli al Vuoto (usato per fratture-segnale come "Qualcosa preme")
- **Fratture nascoste**: nel `mappa.json`, un vuoto con `nascosto: true` appare solo se soddisfa
  `richiede_oggetti` (possiedi quegli oggetti) o `richiede_flags` (tutte quelle quest completate).
  Sulle scelte, `richiede_oggetti` gate una scelta finché non hai tutti i pezzi (la Fontana;
  la porta enorme nella Casa Gigante, sigillata finché non esisterà il `meccanismo_del_varco`
  — pezzo di una frattura futura, per ora irraggiungibile di proposito)
- Mosse boss extra: `autolesione` (si ferisce, stress a tutta la squadra),
  `attacco_tutti` con campo `stress` (il lamento della bambola), `sacrificio`
  (uccide un suo alleato evocato per aumentare il proprio fattore — se non ha
  nessuno da sacrificare, attacca lui stesso; usata da Jongo Dongo), e `incendia`
  (appicca il fuoco a un membro del party a caso, vedi Combustione sotto).
  `attacco_tutti` e `autolesione` accettano anche i campi `legame` (modifica il
  legame di squadra, un solo valore globale) e `maledizione` (infligge lo stato
  Maledizione, vedi sotto, a tutto il party vivo)
- `evoca` accetta anche `quantita` (default 1, es. il goblin arrabbiato ne evoca 2 in un
  colpo solo) e `una_tantum` su qualunque mossa (non solo `evoca`): una mossa `una_tantum`
  esce dal pool pesato del nemico non appena eseguita una volta, per il resto del combattimento
  (`nemico.mosse_usate`, popolato in `Combattimento.esegui_mossa()` e filtrato in
  `turno_nemico_normale()` — i dati originali non vengono mai mutati, così l'elenco mosse
  torna intatto a un nuovo combattimento)
- **`rabbia_su_morte_alleato`** su un personaggio: `{id_alleato, valore_attacco, testo}` — ogni
  volta che un alleato con quell'id muore in questo combattimento (es. un goblin tipico evocato
  dal goblin arrabbiato), l'attacco del portatore aumenta in modo permanente per il resto dello
  scontro (`Combattimento.verifica_rabbia_su_morte()`, chiamata da `_su_ko()`)
- **`cura_su_morte_alleato`** su un personaggio: `{id_alleato, valore, testo}` — ogni volta che
  un alleato con quell'id cade, il portatore recupera quei punti vita (fino al suo massimo).
  Jongo Dongo si rimette in sesto di 20 hp per ogni ghoul che muore, compresi quelli che
  sacrifica lui stesso: ripulire il campo dai suoi servi smette di essere gratis
  (`Combattimento.verifica_cura_su_morte()`, chiamata da `_su_ko()`)
- I combattenti nemici con `hp_nascosti` (impostato in automatico per ogni boss — `categoria_di()
  == "boss"` — e per i nemici con `incontro_scriptato`, come la manifestazione di un sogno)
  mostrano "♥ ???" al posto degli hp esatti: il giocatore non sa mai quanto gli manca per
  abbatterli (`Combattimento.aggiorna_scheda()`)
- **`studio_compulsivo`**: abilità passiva di classe (`classes.json`, campo `abilita`, stesso
  meccanismo di `provocazione`). Se chi usa Studia ce l'ha, e il bersaglio ha `hp_nascosti`,
  quello studio strappa al nemico i suoi punti vita esatti per il resto dello scontro
  (`Combattimento.studia()`) — l'unico modo di svelare gli hp di un boss. Per ora nessuna classe
  ce l'ha ancora: da assegnare a un personaggio quando Bru decide chi
- `buff_attacco`: come `buff_difesa` ma sul proprio attacco (`attacco_di()`, somma i buff
  attivi come già fa `difesa_di()` per la difesa)
- `attacco_multiplo`: `{valore, colpi}` — più colpi deboli in fila sullo stesso tipo di
  bersaglio (es. Cattiveria innata del goblin arrabbiato del tutorial, 3 colpi)
- **`dialogo_soglia_hp`** su un personaggio: `{hp_soglia, testo}` — un messaggio che compare
  una sola volta, alla prima discesa dell'hp sotto quella soglia (es. il goblin arrabbiato che
  non accetta il suo destino)
- **`mossa_disperazione`** su un personaggio: `{hp_soglia, valore_alto, valore_normale, testo}`
  — sotto quella soglia di hp la mossa pesata normale è sostituita da questa, forzata ogni
  turno; il danno è `valore_normale` se il bersaglio si è difeso l'ultimo turno, `valore_alto`
  altrimenti (Combattimento.esegui_mossa_disperazione())
- **`incontro_scriptato`** su un personaggio: un intero combattimento scritto a mano invece
  che pesato — fase di paralisi iniziale (il giocatore non può agire, testo dedicato), un
  primo tentativo di Fuggi che fallisce sempre ma **senza nessun rischio** (dal secondo in poi
  funziona normalmente: nessun tiro di dado, nessuno stato applicato — il "fallimento" è solo
  narrativo). Fuori da queste fasi il nemico non attacca mai davvero: ogni suo turno è solo
  narrazione a zero danno, secondo l'elenco `testi_inerti` (`Combattimento.esegui_turno_inerte()`,
  un testo diverso e sempre più inquietante ogni turno, mai un attacco pesato). Se l'incontro si
  trascina oltre l'ultimo testo della lista senza che il giocatore fugga (o vinca), lei tenta
  "Chiamata di Morfeo" (`esegui_scena_fatale()`): applica lo stato `sonno` al bersaglio con
  `applica_stato()` come qualunque altro stato — se attecchisce per davvero è game over
  (`testo_fatale_protagonista`/`testo_fatale_bacio` → `sconfitta_scriptata()`), **l'unico modo
  normale di perdere questo scontro**. Ma se il giocatore ha equipaggiato un accessorio con
  `scudo_primo_stato` (es. la Pietra Quieta), il primo tentativo viene respinto e l'accessorio si
  spezza (`testo_scudo_rotto`); lei ritenta una seconda volta più avanti, fallisce di nuovo
  (ormai immune, `testo_morfeo_fallito`), e al secondo fallimento si dissolve in un vortice di
  rabbia (`esegui_vortice_di_rabbia()`): una **vittoria alternativa**, mai raggiunta a forza di
  colpi, che paga xp pari al boss della zona (`xp_vittoria_alternativa`) più un accessorio
  garantito (`oggetto_vittoria_alternativa`, non soggetto a chance — il Ricordo del Passato).
  Usato per ora solo dalla manifestazione di un sogno nel tutorial (insegna Fuggi con un limite
  di tempo vero, non solo per finta, senza però punire l'atto di provarci)
- **`danno_fisso_su_attacco`** su un personaggio: ogni "Attacca" del giocatore contro di lui
  vale sempre esattamente questo danno, bypassando del tutto difesa/critico/fattore
  (`Combattimento.attacca()`, controllato prima della formula normale). Serve per i bersagli
  scriptati con difesa "vera" nei dati ma che il design vuole colpibili per un danno fisso
  basso: impostare solo `attacco`/`valore_attacco` non basterebbe, perché la difesa verrebbe
  comunque sottratta dopo (rischiando di azzerare un danno fisso basso). Usato dalla
  manifestazione di un sogno (sempre 1 danno a colpo)

### Combustione (nemici che bruciano)
Un nemico può avere `combustione` nei dati: a ogni suo turno subisce `danno_per_turno`
e, se presente, il suo `attacco` sale di `bonus_attacco` — entrambi si accumulano turno
dopo turno finché resta "in fiamme". Senza `attiva_da_studio` è attiva già dal primo turno
(Fomentado, che brucia di suo per natura); con `attiva_da_studio: N` si innesca dopo essere
stato **studiato N volte** (El Muy Bonito: il suo stesso talento, messo sotto esame, lo
manda a fuoco — e più brucia più diventa pericoloso, finché non lo consuma). La stessa
logica di combustione è generica: la mossa boss `incendia` (es. Jerah) la assegna a **un
membro del party a caso** invece che al nemico stesso, con `valore` come `danno_per_turno`.

### Stati generici e resistenze per personaggio (`data/stati.json`)
Oltre alla combustione (che resta un caso a parte, sopra), esiste un motore generico per
gli altri stati, definiti in `data/stati.json` per **tipo** meccanico (riutilizzabile da più
stati con nomi diversi):
- `salta_turno` — congelamento, sonno, egocentrismo: il bersaglio salta un numero
  casuale di turni (`salta_turno_durata_massima` in `regole.json`)
- `salta_turno` + `"contagiosa": true` — demotivazione: come sopra, ma si propaga
  subito a tutto il resto della squadra del bersaglio
- `forza_attacco` — Berserk: per `forza_azione_durata` turni il personaggio può solo attaccare
  (menu azioni bypassato, bersaglio nemico scelto a caso)
- `colpisci_a_caso` — Confusione: mentre attiva, metà delle volte che scegli "Attacca"
  il colpo va a un bersaglio a caso, alleati compresi
- `dot_crescente` — Veleno: danno a ogni turno che cresce di 1 ad ogni tick
- `dot_condizionale` — Decomposizione: danno a ogni turno, ma **solo se** quel turno hai
  scelto un'azione offensiva; Difenditi/Studia lo evitano
- `velocita` — Rapidità/Lentezza: modificano la velocità effettiva (`velocita_effettiva()`,
  usata per l'ordine di iniziativa) finché lo stato resta attivo
- `countdown` — Maledizione: al primo colpo parte un conto alla rovescia di
  `maledizione_countdown_iniziale` turni (default 9); ogni applicazione successiva lo
  accorcia di `maledizione_accelerazione_per_stack` (default 1); a zero il personaggio muore

Ogni personaggio (in `personaggi.json`/`classes.json`) può dichiarare una chiave
**`resistenze`**: `{ "stress": "invertito", "oscuro": "ipersensibile", "psico": "immune" }`.
Tre valori possibili: **normale** (default, nessuna voce necessaria), **immune** (lo stato/
elemento non lo tocca per nulla) e, a seconda del contesto, **invertito** (solo per `stress`
e legame/morale: l'effetto si capovolge, es. più stress lo rende più forte anziché più
vulnerabile) oppure **ipersensibile** (per stati/elementi: l'effetto è amplificato — countdown
più veloce, stato più lungo, danno raddoppiato).

### Critico e Slaughter
Ogni colpo può critare: chance base `critico_chance_base` + un bonus proporzionale allo
**stress del bersaglio** (`critico_bonus_per_stress`) — più è stressato, più è vulnerabile ai
critici, a meno che non abbia una `resistenze.stress` invertita (allora funziona al contrario,
es. un personaggio "motivato dallo stress") o immune (nessun effetto). Il critico moltiplica
il danno (`critico_moltiplicatore`) e riduce la difesa effettiva del bersaglio
(`critico_riduzione_difesa`). Separato dal critico: **Slaughter**, una probabilità bassissima
(`slaughter_probabilita_base`) di KO istantaneo anche su un attacco normale, con un overlay a
schermo intero in fade (`art/fx/slaughter.png`, ancora da disegnare — senza l'immagine
l'effetto scatta comunque, solo senza illustrazione). Chi è immune o invertito sullo stress
non può subire uno Slaughter.

**Lo Slaughter vale solo sui nemici comuni.** Boss e fonti (`fonte: true`), miniboss
(chi ha `frenesia`), creature `categoria: "particolare"`, incontri scriptati
(`incontro_scriptato`, es. la manifestazione di un sogno) e nemici `invincibile` non possono
mai essere liquidati da un colpo di fortuna: le loro scene devono poter arrivare fino in fondo.
Il party invece resta esposto allo Slaughter come prima.

### Provocazione
Nuova abilità di classe (gate: `"provocazione"` in `abilita`, per ora solo Mockingbear,
classe Fanatico): per `forza_azione_durata` turni, i nemici sono forzati a colpire chi ha
provocato invece di scegliere a caso — utile per proteggere i compagni più fragili dietro un tank.

### Risparmia (studiando certi nemici puoi risparmiarli)
Un personaggio può avere nei dati una chiave `risparmio` ({`legame`, `stress`, `oggetto`,
`testo`, `studi_richiesti`}): studiarlo lo risparmia — esce dal combattimento, il legame di
squadra sale, lo stress scende. Gli altri nemici dello stesso combattimento restano.

**Risparmiare rende più esperienza che uccidere**: `xp_effettiva × xp_risparmio_moltiplicatore`
(1.25 in `regole.json`), quindi la Tartaruga Innocente vale 19 invece di 15. Il perché è di
design, non di bilancio: capire una creatura fino a non doverla più uccidere è la cosa
difficile, e il gioco deve premiarla — altrimenti la via gentile costa e basta. **Nessun Tazo**
però: non si fruga addosso a chi hai lasciato vivo. E dopo la scena il gioco te lo dice in
chiaro (*"ne ricavi 19 esperienza invece dei 15 che ti avrebbe dato da morto"*), perché uno
scambio che il giocatore non vede non è una scelta.

`studi_richiesti` (1 se non specificato) dice **quante volte va studiata** prima che si possa
lasciarla andare: certe creature cedono al primo sguardo, altre vanno ascoltate a lungo prima
di ragionare. Se il giocatore preferisce comunque attaccarla si comporta come un nemico
qualsiasi (xp normale, Tazo e carta inclusi).

### Colpi che non si possono parare (`dialogo_soglia_hp.danno_fisso_dopo`)
`dialogo_soglia_hp` fa dire una battuta a un nemico quando scende sotto una soglia di vita. Con
in più `danno_fisso_dopo`, da quel momento **ogni suo attacco infligge esattamente quel danno**:
niente difesa sottratta, niente critico, niente riduzione da livello, niente schivata. Alzare la
guardia smette di servire. Il gioco non lo dice: il giocatore se ne accorge dai numeri, ed è
esattamente il senso di quel "Preparati". Usato dal goblin arrabbiato del tutorial (5 danni
fissi sotto i 5 hp).

Attenzione a chi ha mosse multi-colpo: il danno fisso vale **per ogni colpo**, quindi la
"Cattiveria innata" del goblin (3 colpi) fa 15 su un protagonista che ne ha 20.

### Fuggi
Azione disponibile nel menu (bottone disabilitato se non si può fuggire): esce dal
combattimento senza xp/tazo/drop e senza alcuna penalità. Destinazione: `se_fuggi` sulla
scelta `combatti` (o sull'`agguato`, dove di default punta alla stessa stanza — fuggire da
un'imboscata casuale non costa nulla); se `se_fuggi` non è specificato, si usa `se_perdi`
come fallback. **Non si può fuggire dai boss** (c'è una `fonte` nello scontro) **né se
almeno un membro del party ha lo stato Terrore** attivo (`fuga_possibile()`).

### Terrore
Nuovo stato (tipo `"terrore"` in `data/stati.json`): quando infierto, alza notevolmente lo
stress di chi lo subisce (`terrore_stress_incremento`) e abbassa subito il legame di squadra
(`terrore_legame_decremento`, globale). Finché resta attivo su almeno un membro del party,
blocca l'azione Fuggi (vedi sopra). Agganciabile alle mosse boss con la chiave
`"terrore": true` su `attacco_tutti` (colpisce tutto il party).

### Studio sui nemici comuni: domande generiche
Per i nemici comuni non serve scrivere una domanda su misura: se uno scambio in `studio`
ha solo `risposta` (senza `domanda`), il gioco pesca la battuta del giocatore a caso da
`data/studio.json` (`domande_generiche`). Le risposte restano scritte per ogni personaggio;
solo boss e creature particolari hanno anche la domanda scritta apposta.

### Frenesia (miniboss con conto alla rovescia)
Un nemico può avere nei dati una chiave `frenesia` (non serve essere una fonte): a una
`soglia_hp` innesca un conto alla rovescia (`conteggio` turni). Se arriva a zero: maleficio,
KO totale del party. Si ferma **Studiando** il nemico durante la frenesia — rivela un
**bersaglio extra** (`bersaglio_extra`, un oggetto di scena come "le lettere sull'altare",
con la sua `bersaglio_extra_hp`) attaccabile come un nemico normale; distruggendolo il conto
si ferma e il nemico, invece di attaccare, recita `testo_fermata` (una riga a turno) prima
di tornare al comportamento normale. Usato dal miniboss "Un tenero ricordo" nella Casa
Gigante.

## Formato dati

### mappa.json
```json
{
  "sfondo": "res://art/mappa.png",
  "punti": [
    { "id": "...", "nome": "...", "pos": [x, y], "attivo": true, "file_eventi": "res://data/....json" }
  ]
}
```
Posizioni in coordinate 1280×720 (design resolution, stretch `canvas_items`). Solo i punti
con `attivo: true` mostrano il "!". Nuove campagne = nuovo JSON + nuovo punto, zero codice.

**Il tutorial non è un punto della mappa.** Le Pianure di Redenna partono da sole a fine
introduzione (`avvio_automatico` in `events_intro.json`, che chiama `avvia_carnivalz("tutorial",
…)` senza passare da `mappa.json`): la mappa stellare si vede solo dopo, e l'unico punto
raggiungibile è **Il Vuoto Ardente**. Un game over nel tutorial ti rifà il tutorial, non ti
sbalza in orbita.

### events.json (una campagna)
```json
{
  "nodo_iniziale": "inizio",
  "nodi": {
    "id_nodo": {
      "testo": "narratore...",
      "sinistra": "anonimo",
      "destra": "niru",
      "centro": "imbonitore",
      "scelte": [
        { "testo": "...", "vai": "altro_nodo", "richiede": "volo", "recluta": "niru", "oggetto": "lanterna", "lascia": "niru", "reset": true },
        { "testo": "Affrontalo", "combatti": ["imbonitore"], "se_vinci": "vittoria", "se_perdi": "sconfitta" }
      ]
    }
  }
}
```
Chiavi nodo (opzionali): `sinistra` (default: protagonista), `destra`, `centro` (esclude i lati).
Chiavi effetto sulle scelte (tutte opzionali): `vai`, `richiede` (abilità nel party),
`richiede_legame` (legame ≥ soglia), `richiede_ospite` (quell'ospite con te), `richiede_compagno`
(quella classe nel party — es. un alleato temporaneo reclutato prima), `recluta`,
`oggetto` (va nello slot giusto in base al tipo), `lascia`, `ospite` (personaggio temporaneo
per la campagna, solo assist fuori combattimento), `recluta_temporaneo` + `livello_alleato`
(alleato temporaneo che combatte davvero, deve stare in `classes.json`), `tazo` (±; se negativa
e non puoi pagare, la scelta non appare), `stress` (± a tutto il party), `legame` (±),
`sblocca_negozio`, `combatti` (lista di id nemici; `se_vinci`/`se_vinci_eroe`/`se_perdi`
destinazioni), `reset` (fine campagna: inventario, Tazo, roster, livelli, stress e legame
restano, gli ospiti no), `game_over` (sconfitta contro una vera fonte: si ricarica l'ultimo
salvataggio, vedi sezione Combattimento).

Un messaggio `dialogo` nella `sequenza` può avere `espr` per cambiare l'espressione del
personaggio a metà conversazione (solo per scene `centro`, un solo personaggio a schermo —
es. il giocoliere che perde il sorriso un attimo prima del combattimento).

Qualunque messaggio della `sequenza` può avere `attesa` (secondi): finito di scriversi non
aspetta il click, conta quel tempo e passa avanti da solo. Serve a scandire un momento invece
di lasciarlo in mano al ritmo del giocatore — il conto alla rovescia del lancio
nell'introduzione è una pagina per cifra, `"3..."` `"2..."` `"1..."`, ognuna con la sua attesa.
Cliccare comunque salta avanti subito: un contatore interno impedisce che il click e il timer
avanzino due volte. Il timer rispetta la pausa, quindi aprire ESC ferma anche il conto.

## Documento delle correzioni (`docs/testi_da_correggere.md`)
Non un documento da leggere: un documento da **correggere**. Ogni singola cosa che il giocatore
può leggere — battute, narrazioni, etichette dei bottoni, righe del diario di combattimento,
nomi degli oggetti, voci del bestiario, appunti del Diario — compare una volta sola, con un
identificatore stabile e una freccia sotto dove scrivere la versione giusta:

```
**`TUT.inizio.3`** · battuta di Anonimo
> Dunque sarebbe questa la mia prima missione autonoma?
>
> →
```

Riconsegnato, le correzioni si applicano cercando l'ID: `TUT.inizio.3` è il terzo messaggio del
nodo `inizio` di `events_tutorial.json`, `UI.Combattimento.042` è la quarantaduesima scritta di
`Combattimento.gd`. **Copre anche le scritte scritte a mano dentro gli script** (menu, bottoni,
diario di combattimento), che non erano mai passate sotto gli occhi di nessuno. In fondo
un'appendice sui buchi da riempire: la tabella di Yhvina stanza per stanza nella Casa Gigante e
tutti i nodi dove i compagni non hanno ancora niente da dire.

È un'istantanea generata: si rifà con `python3 strumenti/genera_testi.py` dopo aver toccato i
JSON o gli script. Non è una fonte — la fonte restano `data/` e `scripts/`.

## Le prove (`prove/`)
In un gioco fatto di dati, la maggior parte degli errori **non è un errore di compilazione**. Un
`"vai": "collina_ovest"` scritto dove il nodo si chiama `collina_est` compila benissimo: è un
vicolo cieco che il giocatore trova venti minuti dopo, in un ramo che nessuno ripercorre a mano
ogni volta. Lo stesso vale per un nemico evocato da una mossa e mai definito, un oggetto messo in
vendita che non esiste, un appunto del Diario appeso a un flag che nessun nodo alza mai.

`prove/Prove.tscn` + `prove/Prove.gd` sono un programma che apre il progetto **dentro Godot vero**,
con gli autoload caricati, e attraversa i dati come li attraversa il gioco. Non legge i JSON per
conto suo: usa `GameState`, quindi se una regola cambia nel motore le prove cambiano con lui.

```
./prove/esegui.sh                 # oppure: GODOT=/percorso/godot ./prove/esegui.sh
```

Tre passi, in ordine di gravità: **importa** le risorse, **avvia** il gioco headless
(`--quit-after 240`: se un autoload esplode all'avvio si sa subito), poi le **verifiche** —
oggi 4367, raggruppate in una quarantina di famiglie.

**Lo script guarda anche gli errori di Godot, non solo il verdetto delle prove.** In GDScript
un errore a runtime interrompe la funzione in cui succede e ridà il controllo a chi l'ha
chiamata, che tira dritto: una prova che esplode a metà non conta le sue verifiche e non
lascia nessun fallimento, quindi il totale cala di qualche numero e in fondo compare lo stesso
"PASSATE, nessun problema". È successo davvero (una prova leggeva un file di eventi nel modo
sbagliato): due `SCRIPT ERROR` nell'output, e verde. Nessun contatore dentro `Prove.gd` può
accorgersene, perché il codice che dovrebbe accorgersene è proprio quello che non viene
eseguito — se ne accorge chi guarda da fuori, e `esegui.sh` fallisce se Godot ha stampato
anche un solo errore.

| Cosa controlla | Perché |
|---|---|
| dati caricati | i JSON esistono, si leggono, non sono vuoti |
| ogni destinazione punta a un nodo che esiste | i vicoli ciechi (`vai`, `se_vinci`, `se_perdi`, `se_fuggi`, scelte, `vai_se_flag`) |
| nessun nodo orfano | contenuto scritto e mai raggiungibile: lavoro buttato |
| creature dei combattimenti e delle evocazioni | un boss che evoca un id inesistente crasha a metà scontro |
| agguati | i gruppi random del Vuoto — i riferimenti a nemici più numerosi del gioco |
| ogni oggetto nominato esiste | pickup, bottini, leve dello Studio, premi, `oggetti_forniti` |
| negozi | ogni voce in vendita ha un oggetto e un prezzo |
| appunti del Diario | ogni `richiede_flags`/`chiuso_da` è un flag che qualcuno alza davvero |
| mappa stellare e mappe delle zone | ogni stanza è un nodo, ogni connessione unisce stanze vere |
| equipaggiamento | slot, tipi ammessi e somma dei bonus/malus |
| crescita e statistiche | ogni azione tracciata punta a una statistica esistente |
| salvataggio | si scrive, si rilegge, e quello che torna è quello che era |
| tutte le scene si caricano | una `.tscn` rotta si scopre qui, non aprendola |

Escono con codice **0** se passa tutto, **1** se no, quindi valgono in una pipeline:
`.github/workflows/prove.yml` le fa girare a ogni push e su ogni pull request, sulla stessa
versione di Godot dichiarata in `project.godot`. Una modifica che rompe qualcosa si vede prima,
non giocando.

**Quando si aggiunge una prova.** Ogni volta che un bug è arrivato fino a Bru: prima la verifica
che lo avrebbe preso, poi la correzione. Le prove non sono un adempimento, sono la memoria degli
errori già fatti — l'unica parte del progetto che non dimentica.

## Il giocatore automatico (`prove/Simulatore.gd`)
Le prove dicono che i dati sono coerenti. Non dicono se il gioco è **giocabile**. Il
bilanciamento di Carnivalz era indovinato: i punti vita e l'attacco di ogni creatura scritti a
occhio e mai verificati da nessuno, perché per verificarli bisognerebbe giocare lo stesso scontro
venti volte di fila.

```
./prove/simula.sh          # ~8 minuti, riscrive docs/bilanciamento.md
./strumenti/nemici.sh      # pochi secondi, riscrive docs/nemici.md
```

**Non è una simulazione.** Non c'è nessun modello semplificato: viene istanziata
`Combattimento.tscn` e giocata dal motore vero, con `Voce`/`Campo`/`Menu` in modalità muta. È lo
stesso codice che gira quando ci giochi tu, senza la parte che si guarda — per questo lo scorporo
di `Combattimento.gd` non era pulizia ma una capacità. Ogni scontro si risolve dentro `add_child`,
quindi 99.000 partite stanno in otto minuti.

Quattro modi di giocare, scelti perché misurano cose diverse: **attacca** (la durata vera),
**difendi** (non attacca mai — se vince, quello scontro è rotto), **studia** (la strada che il
gioco vorrebbe insegnare: dice se è percorribile), **casuale** (il pavimento). Cinque livelli del
protagonista, semi fissi: due esecuzioni danno lo stesso risultato, quindi una differenza nella
tabella è sempre una differenza nel gioco.

Il numero che conta è nella prima tabella di `docs/bilanciamento.md`: **a che livello ogni
scontro diventa giusto**, cioè da dove in poi si vince almeno l'80% delle volte andandoci dritto.

**Il simulatore misura il giocatore che esiste davvero.** Per mesi non è stato così: alzava solo
il livello, e nel gioco le statistiche non salgono col livello — salgono con quello che hai fatto.
Misurava quindi uno arrivato al livello 8 senza aver mai combattuto, e la tabella diceva
"equilibrato" mentre chi ci giocava non scendeva mai sotto metà vita. Adesso `cresci_fino_a()`
applica il `profilo_giocatore_tipo` di `crescita.json` prima di ogni scontro. Se quella stima è
sbagliata, tutta la tabella è sbagliata: è il numero più importante del file.

## Lo zaino: quattro scomparti, tre con un tetto
Non è un mucchio. Ogni categoria ha la sua capacità, e si allarga comprando spazio al negozio.

| scomparto | base | come cresce | al massimo |
|---|--:|---|--:|
| **consumabili** | 20 | *Spazio nella realtà* ×10 | 75 |
| **armi** | 5 | *Frammento — rastrelliera* ×10 | 30 |
| **accessori** | 10 | *Frammento — vassoio* ×10 | 50 |
| **oggetti speciali** | ∞ | — | ∞ |

Gli oggetti speciali (stigmi, ricordi, chiavi) **non hanno limite**: sono la storia che ti porti
dietro, non zavorra da amministrare. Le tabelle stanno in `regole.json` sotto `zaino` e sono la
capacità **totale** a ogni acquisto, non l'incremento — così i numeri nel file sono gli stessi che
il giocatore legge al negozio.

Comprare uno spazio è l'unico acquisto che **non ti lascia niente in mano**: allarga e basta.
Un'arma equipaggiata **resta nello zaino**, segnata `· in uso ·` — impugnarla non è metterla via.

## Compagni temporanei e definitivi
Chi ti accompagna per un tratto combatte al tuo fianco ma **non gli si affida niente**: la scheda
lo dice al posto degli slot (*«È con te solo per un tratto»*). Le tue cose gliele dai solo quando
resta. E se un compagno definitivo lascia la squadra, il suo equipaggiamento **torna nello zaino**
— era tuo, gliel'avevi prestato.

## Carte: doppioni, rarità, finiture
Un doppione non è un drop sprecato: **si accumula**, e si vende o si scambia con i personaggi che
incontri. L'unica copia che non si cede mai è l'ultima — l'album non si buca.

- **Rarità**, in ordine: comune · ordinaria · fuori dal comune · eccentrica · ricercata · di classe
  · fuori serie
- **Finiture**, sempre più rare: normale · con stile · proibita

`carte` resta l'elenco di quelle viste almeno una volta (è quello che l'Album conta);
`carte_copie` tiene quante ne hai e con che finitura.

## La scheda del personaggio (`scripts/Personaggio.gd`)
ESC → **Personaggio e squadra**. Vive dentro la Pausa e non come schermata a sé, così si apre da
ovunque — mappa, stanza, Vuoto, combattimento — senza cambiare scena e senza perdere il posto.

Tre regole, prese da chi questo mestiere lo fa da vent'anni, e ognuna risponde a un errore che
questa schermata fa quasi sempre:

1. **Tutto su una schermata.** Statistiche ed equipaggiamento non si separano in due pagine: chi
   cambia un accessorio vuole vedere subito cosa succede alle sue statistiche, non ricordarsele
   mentre naviga. È la schermata più visitata del gioco e tradizionalmente la più confusa.
2. **Sempre la differenza, mai solo il numero.** Un oggetto non dice «difesa +2»: dice **`+2`
   accanto a quello che porti adesso**, col segno e col colore. La decisione deve costare un
   secondo, non un calcolo.
3. **Quello che non puoi ancora usare si vede lo stesso, e si capisce perché.** Uno slot chiuso
   nascosto è un premio che non sai di poter vincere; uno slot chiuso che dice *«si apre al livello
   15»* è un motivo per continuare.

Tre colonne senza sottomenu: **chi è** (ritratto grande, nome, classe, livello, psiche) · **cosa
porta** (arma, stigma, ultima risorsa, accessori) · **quanto vale** (statistiche, e in fase di
scelta la differenza). In alto le linguette dei compagni — la squadra si guarda da qui, senza
uscire. In basso il Diario.

### Gli accessori si aprono a poco a poco
Non sono quattro dal primo minuto: all'inizio ce n'è **uno solo**, perché decidere cosa portare
deve essere una scelta e non un modulo da riempire. Poi se ne apre uno per ogni soglia in
`regole.json`:

```json
"slot_accessori_base": 1,
"slot_accessori_per_livello": [6, 15, 30],
"slot_accessori_da_abilita": {"collezione": 4, "innesti": 1}
```

Due classi ne hanno di più per un **talento loro**, dichiarato tra le loro abilità: **Bero** ne ha
uno in più per gli innesti (5), **Rio** ne ha quattro in più perché colleziona — e arriva a **8**,
che è il suo modo di essere forte. La scheda lo dice a parole sotto lo slot (*«grazie al tuo
talento: collezione»*): un premio che non sai di aver vinto non è un premio. Spostare il talento
su un'altra classe è una riga di JSON.

Il confronto tra oggetti è un **conto puro**: somma quello che dà il nuovo, sottrae quello che dava
il vecchio, senza equipaggiare niente a nessuno. La prima versione invece provava sul campo — e non
rimetteva tutto a posto: con gli slot pieni l'oggetto non entrava ma veniva tolto lo stesso a chi
ce l'aveva. Bastava **scorrere l'elenco** per spogliare un compagno. Preso da
`prova_scheda_personaggio()` al primo giro.

## Il gioco ha una voce (`scripts/Sintesi.gd`)
Non c'è un solo file audio nel progetto, e ce ne saranno solo quando li farà Bru. Ma restare muti
non è neutrale: un testo che scorre in silenzio non sembra *in attesa dell'audio*, sembra morto.

La cosa che nei giochi fa sembrare **parlato** un testo scritto non è la musica — è il colpetto di
voce per gruppo di lettere, intonato diverso per ogni personaggio. E un colpetto di voce è un'onda
quadra di cinquanta millesimi di secondo, cioè mille numeri in fila. Quindi li calcoliamo:
`Sintesi.gd` costruisce ogni suono campione per campione all'avvio.

L'altezza e la forma d'onda di un personaggio vengono **dal suo nome**: due personaggi suonano
sempre diversi, lo stesso personaggio sempre uguale, e non c'è niente da configurare. Chi vuole
sceglierselo lo mette nei dati:

```json
"voce": {"altezza": 320, "forma": "sega"}
```

Sei suoni d'interfaccia (`conferma`, `annulla`, `colpo`, `cura`, `raccolta`, `errore`) e il blip
della narrazione, più basso e più morbido, perché la voce che racconta dall'esterno non è nessuno.
Durante i respiri sulla punteggiatura le lettere non avanzano, quindi **la voce si ferma da sola
dove si fermerebbe una vera**.

**Sono segnaposto, ed è il punto.** Ogni suono ha un percorso file corrispondente
(`res://audio/ui/<nome>.wav`): appena quel file esiste, vince lui e la sintesi si fa da parte. Non
c'è niente da ricablare — si copia un `.wav` nella cartella.

## Come comincia uno scontro (`apertura`)
Ogni combattimento cominciava con un menu. Ora comincia con la **creatura**: un gesto o una frase,
prima che il giocatore possa fare qualsiasi cosa. Un campo nei dati del personaggio:

```json
"apertura": "Ritira la testa nel guscio prima ancora che tu faccia un passo. Non attacca. Aspetta."
"apertura": {"tipo": "dialogo", "testo": "Un altro. Sempre un altro. Non finite mai di arrivare."}
```

Parla solo la creatura principale — in un'imboscata da tre, tre battute di presentazione sarebbero
un'attesa e non un'entrata. Ce l'hanno per ora tartaruga, goblin tipico, goblin arrabbiato,
manifestazione e Jerah: le altre sono da scrivere.

## Lo studio si vede
Studiare era una cosa che si **leggeva**: premevi, usciva del testo, e sullo schermo non cambiava
niente. Il giocatore capiva sempre di più e non lo vedeva da nessuna parte. Ora la scheda di una
creatura si riempie a strati, uno per studio:

| studi | cosa sai |
|--:|---|
| 0 | `♥ ???` — «non l'hai ancora guardata» |
| 1 | i punti vita esatti, stress, fattore, stati addosso |
| 2 | quanto para e quanto picchia (`Dif`, `Att`) |

Per le creature che si possono lasciare andare compare anche **`capita 1/3`**: quante volte l'hai
guardata e quante ne servono. Senza, il risparmio arrivava dal nulla — studi, studi, e a un certo
punto succede qualcosa; con, si vede arrivare, ed è una cosa che si sceglie invece che una che
capita. I boss restano a `???` comunque (scelta più vecchia e più importante di questa), e
`"studio_rivela": false` in `regole.json` riporta tutto com'era.

## Esportare il gioco (`export_presets.cfg`)
Fino a qui Carnivalz si poteva solo **aprire** nell'editor: non esisteva nessun modo di darlo a
qualcuno che Godot non ce l'ha. Ora ci sono due destinazioni pronte, Linux e Windows:

```
godot --headless --export-release "Linux"   build/Carnivalz.x86_64
godot --headless --export-release "Windows" build/Carnivalz.exe
```

Servono i template di esportazione installati (Editor → Gestisci template): sono il guscio
dell'eseguibile, pesano un giga e non stanno nel repo. `exclude_filter` tiene fuori dal pacchetto
quello che serve a noi e non al giocatore (`prove/`, `strumenti/`, `docs/`, i `.md`). La pipeline
esporta e **fa partire l'eseguibile** a ogni push: che il gioco si possa consegnare è una proprietà
verificata come le altre.

## I numeri del combattimento

Vita e danno sono grandi apposta: un colpo che toglie 1 su 5 punti vita è aritmetica, uno che
ne toglie 27 su 140 è una botta. Ma la scala non era il problema vero. Il problema era un altro,
ed è costato metà del bilanciamento del gioco.

### La crescita correva trenta volte più veloce del mondo

In Carnivalz le statistiche **non salgono col livello**: salgono con quello che fai
(`data/crescita.json`). Il contenuto invece è scritto a mano, con numeri fissi. Se la crescita
corre più del contenuto, da un certo punto in poi non si perde più.

Era esattamente così. `attacchi_sferrati: ogni 5, punti 3`, con una trentina di colpi per
livello, vuol dire **+18 di attacco per livello su una base di 9**: la potenza triplicava a ogni
passaggio di livello.

| protagonista *vero* | hp | attacco | creature della prima zona |
|---|--:|--:|---|
| livello 1 | 100 | 9 | 135 hp, 6 attacco |
| livello 3 | 375 | 45 | 135 hp, 6 attacco |
| livello 5 | 665 | 81 | 135 hp, 6 attacco |

Al terzo livello uccidevi in quattro colpi e ti servivano sessanta colpi per morire. Da lì in poi
la difficoltà non esisteva più.

**Perché nessuno se n'era accorto**: la tabella di bilanciamento misurava un protagonista che
alzava solo il livello, cioè uno **arrivato al livello 8 senza aver mai combattuto**. Un
giocatore che non esiste. La tabella diceva "equilibrato" mentre chi ci giocava davvero non
scendeva mai sotto metà vita.

Adesso il giocatore automatico simula quello vero: `profilo_giocatore_tipo` in `crescita.json`
dice quante volte un giocatore compie ogni azione per ogni livello guadagnato, e sia il
simulatore sia le prove partono da lì (**un posto solo**, o prima o poi direbbero due cose
diverse). La curva è stata addolcita: raddoppi ogni quattro-cinque livelli invece che a ogni
livello, e al 20 sei circa **nove volte** quello che eri.

`prova_crescita_non_scappa()` controlla la **pendenza**: nessuna stat può più che moltiplicarsi
per 1,6 da un livello al successivo, e dal livello 1 al 20 la crescita totale deve stare fra 4×
e 18×. Sono paletti larghi — servono a fermare una valanga, non a impedire di ritoccare i numeri.

### La difesa riduce, non cancella. Mai zero.

Il secondo motivo per cui non si moriva mai. *"Il protagonista para troppo spesso i colpi"* —
vero, ed erano **due meccanismi diversi che stampavano lo stesso messaggio**:

1. la difesa si sottraeva dal danno e si teneva il massimo con zero: difesa ≥ attacco → il colpo
   spariva. Con `Difenditi` che accumula, e con l'equipaggiamento addosso, era la norma;
2. una **probabilità di annullare del tutto il colpo**, `0,1` per livello con tetto `0,5`: al
   livello 6 **metà dei colpi subiti spariva nel nulla**, a caso, senza che a schermo succedesse
   niente.

Un colpo che non fa niente non è un evento: è un buco nel ritmo. Adesso due regole sole:

| | |
|---|---|
| la corazza **vince** (difesa ≥ colpo) | passa **1**. Un graffio, mai zero |
| la corazza **perde** | passa quel che resta, ma mai meno di `danno_minimo_percentuale` (10%) del colpo pieno |

Il livello toglie una **percentuale** (`0,02` per livello, tetto `0,35`), non annulla a caso. Chi
ha 0 di attacco continua a non fare male.

Il primo caso è quello che rende possibile una creatura come la **Tartaruga Innocente**: 555
punti vita e `"difesa_per_turno": 3` — a ogni suo turno la corazza cresce di tre punti e non
torna più indietro. Arriva il momento in cui il tuo colpo passa per 1, e con quella vita non la
abbatti in nessun modo. Non è un muro ingiusto: è il gioco che dice, con i numeri invece che con
una riga di testo, che quella creatura non va picchiata — va capita.

`prova_la_difesa_riduce_non_cancella()` verifica tutti e due i rami;
`prova_corazza_che_cresce()` verifica che la corazza arrivi davvero a fermare un colpo, e che ci
metta abbastanza turni perché si capisca cosa sta succedendo.

### Una fonte non si supera farmando

Le creature comuni restano al massimo tre livelli sotto di te, e va bene: sono il paesaggio, e
attraversarlo più in fretta **è** la ricompensa per essere diventato forte. Una fonte no: quella
è il motivo per cui sei lì. `scarto_livello_boss: 0` — boss, fonti e miniboss stanno **sempre
almeno al tuo livello**, per sempre.

`prova_i_boss_non_si_superano_farmando()` controlla tutte e due le facce: che nessuna fonte
scenda sotto di te a nessun livello, e che qualche creatura comune resti sotto — altrimenti
livellare non servirebbe a niente.

### Le stat riallineate a una curva

Le stat delle creature erano state scritte a mano in momenti diversi e non seguivano nessuna
curva: un Ghoul di livello 8 aveva 350 hp, un Oppresso di livello 4 ne aveva 270, contro un
protagonista che nel frattempo era triplicato. Sono state ricalcolate **partendo da quanto deve
durare uno scontro e quanto deve costarti**, non dai numeri:

| | turni | quanta vita ti costa |
|---|--:|--:|
| comune | 8 | 30% |
| particolare | 12 | 45% |
| miniboss | 16 | 60% |
| **fonte / boss** | 20 | 62% |

Da lì discendono hp, attacco e difesa — non il contrario. La difesa sta sotto un terzo del tuo
attacco al livello a cui la incontri: sopra quella soglia la corazza vincerebbe e passeresti a 1,
che è un effetto voluto solo dove è voluto. Il carattere di ogni creatura è conservato entro
±25% rispetto alle sue pari, così "questa è più grossa di quella" resta vero.

Restano fuori dal riallineamento, di proposito: la Tartaruga (555, decisa a mano), l'Immortale
(è una battuta), la Manifestazione di un sogno (scena, non scontro), Veronica (tutorial) e la
vita di Un tenero ricordo (6660 è un simbolo).

### Dove siamo adesso

Ogni creatura al livello a cui la incontri, misurata attaccando e basta (niente oggetti, niente
abilità — è il pavimento):

| | vinte | giri | quanta vita ti costa |
|---|--:|--:|--:|
| creature comuni lv 1–3 | 100% | 5–6 | ~25% |
| creature comuni lv 4–9 | 100% | 6–12 | 25–45% |
| creature particolari (Divoratore) | 53% | 15 | 97% |
| **goblin arrabbiato** (fonte) | 73% | **28** | 90% |
| fonti incontrate sotto livello | 0–45% | — | tutta |

Il goblin arrabbiato è tornato quello che deve essere: ventotto turni, e ci arrivi con il fiato
corto. Il Divoratore è una monetina lanciata in aria se ti limiti a picchiare — e smette di
esserlo appena usi qualcosa.

### I numeri hanno un colore

Un numero rosso dice *quanto*. Il colore dice *cosa*.

| | |
|---|---|
| colpo normale | rosso |
| **critico** | oro, più grande, entra con uno scatto e resta più a lungo |
| fuoco / gelo / veleno / elettrico / psico / oscuro / sacro | il colore del suo elemento |
| cura | verde |

Lo dichiarano i dati, non il codice: `"elemento"` su un'arma (cambiare arma cambia il colore dei
tuoi numeri), su una mossa di una creatura, sulla creatura stessa, su uno stato in `stati.json`
(il veleno vola verde acido), su un oggetto (il petardo fa fuoco) e su un'abilità. I colori
stanno in `stile.json` → `colori_danno`. `prova_colori_del_danno()` fallisce se qualcuno usa un
elemento che non ha un colore — altrimenti l'errore non si vedrebbe: sarebbe semplicemente rosso
come tutti gli altri.

## Le abilità di combattimento (`regole.json` → `abilita_combattimento`)

Non stanno nel codice. Una classe prende un'abilità scrivendone l'id nel suo campo `abilita`
(`classes.json`), e il menu costruisce il bottone da questa tabella. Il motore conosce quattro
**tipi**:

| tipo | cosa fa |
|---|---|
| `provoca` | i nemici prendono di mira chi provoca, e nessun altro |
| `area` | un colpo solo su tutti, a frazione dell'attacco (`moltiplicatore`) |
| `raffica` | **tanti** colpi piccoli distribuiti a caso, ignorando le difese |
| `carica` | questo turno non fai niente; il prossimo colpo vale `moltiplicatore` volte tanto |

Un'abilità di un tipo che il motore non sa eseguire fa fallire le prove
(`prova_abilita_di_combattimento`), invece di comparire nel menu e non fare niente.

**Bombardamento** (`raffica`, di Bero — è un Mecha): 12 colpi al livello 1, `+0.5` per livello,
fino a 50. Ogni colpo vale una frazione dell'attacco (`frazione_danno`), quindi resta piccolo
apposta: la sensazione voluta è la scarica, non il singolo numero. A schermo **non** diventano
venti messaggi in coda — sarebbero venti attese: parte tutto da un effetto solo, i numeri si
accendono uno dietro l'altro a `PASSO_RAFFICA` di distanza, e il box scrive una riga sola
("*Bombardamento: 14 colpi. In tutto, 41 danni.*").

**Sovraccarico** (`carica`, del protagonista e di Niru): salti il turno, il prossimo attacco
vale ×4 — bonus di livello compreso, altrimenti a livello alto caricare sarebbe un modo di
picchiare *meno*. Mentre sei carico la tua scheda lo dice ("· carico"). È una scommessa: se
cadi prima di scaricare, hai buttato un turno.

## Il livello delle creature segue il tuo

**Nessuna creatura scende mai più di 3 livelli sotto il protagonista**
(`scarto_livello_massimo` in `regole.json`). Sopra può stare quanto vuole — il goblin arrabbiato
del tutorial resta il macellaio che deve essere.

Non è un livellamento amministrativo per non annoiare il giocatore: è la storia. Un dominatore
porta addosso il fattore Carnivalz, e il disallineamento **si nutre di quello**. Più sei forte
tu, più è forte ciò che ti viene incontro; e più è forte una fonte, più è forte quello che le
vive intorno — che è anche il motivo per cui zone diverse hanno creature diverse.

In pratica: `GameState.livello_nemico(id)` è `max(livello base, tuo livello − 3)`, e
`GameState.stat_nemico(id, chiave)` alza hp/attacco/difesa/xp/tazo delle percentuali in
`crescita_nemico_per_livello`. **Chi non scala:** le creature con `incontro_scriptato` (sono
scene, non scontri: i loro numeri sono battute) e chi lo dichiara con
`"scala_col_giocatore": false` — la Tartaruga Innocente non deve diventare un mostro perché sei
salito di livello.

Ogni creatura ha adesso un `livello` base che dice **quanto è profondo il posto in cui vive**
(tutorial 1–6, Squarcio Industriale 4–6, Meridia 2–10, Cunicoli di Jondoh 8–14, Kizako 12,
Casa Gigante 13–15, la campagna di Jerah 16–18). Le stat non cambiano per questo: cambiano il
pavimento di livello e il calo di xp quando torni indietro. **Sono numeri miei, da correggere.**

## Convenzioni
- Codice e chiavi JSON in italiano
- RNG solo seedato (`GameState.rng`), mai `randi()` sparsi: determinismo e multiplayer futuro
- Il numero totale di classi non va mai mostrato: il menu elenca solo le sbloccate
- `.godot/` fuori dal repo

## Roadmap
1. ✅ Vertical slice: motore eventi + gating per abilità
2. ✅ Mappa stellare con marker "!" data-driven
3. ✅ Selezione party adattiva + palco dialoghi con ritratti
4. ✅ Combattimento a turni base (velocità, rabbia, livelli)
5. ✅ Psiche, stress, fattore Carnivalz, XP fino al 130, legame
6. ✅ Primo dungeon completo: il Carnivalz del Bosco (bivi, 3 scontri,
   3 reclutabili su strade alternative, falò, segreti, fonte)
7. ✅ Speranza ed esito eroe: leve, ospiti temporanei, due finali
8. ✅ Studio (dialoghi con risposta), convincibilità, cedimento del boss
9. ✅ Dungeon 1 in solitaria e più lungo; menu azioni; stats estese e mosse
   boss; sacca/collezionabili/chiavi/carte; Tazo; negozi (Organizzazione
   attivo, Nyu e Artigiano pronti nei dati)
10. ✅ Il Vuoto: squarci esplorabili e rivisitabili (industriale, teatro del
    passato, casa gigante + zona nascosta di Niru), agguati random,
    loot una tantum, stanze segrete, miniboss Un tenero ricordo
11. ✅ Menu principale + collezioni: album carte, bestiario, compendio
    oggetti; drop comuni e carte (rare/garantite) dai nemici
12. ✅ Rework mondo di Jerah (corrida/fiamme), rebalance (danno scala col
    livello, Jerah 35 HP, bambola 66 HP), alleata temporanea Yhvina,
    fratture gated da quest (Ala Kizako, Fontana coi 4 pezzi)
13. ✅ Impianto audio (musica per contesto, versi nemici, voci boss)
14. ✅ Ritratti a espressioni (16 pose per i dialoghi) + salvataggio (autosave +
    5 slot manuali, solo dalla mappa stellare; "Continua"/"Carica partita" dal menu)
15. ✅ Squarcio Industriale allungato (Discarica col Divoratore, Vecchio
    Centro di Controllo con diari di Kizako, Padiglione E sigillato);
    porta enorme nella Casa Gigante (bloccata dalla bambola, poi sigillata
    fino a una frattura futura); drop raro e arma "Il mondo è il mio
    Tesoro"
16. ✅ La Rocca di Ossidiana: macro-frattura opzionale con boss proprio,
    Jongo Dongo (non convincibile, si sacrifica i propri ghoul per
    potenziarsi — nuova mossa "sacrificio")
17. ✅ Meridia (città zombie, terreno di farming, mondo perduto ricorrente
    con lore a pagine di giornale) e "Qualcosa preme" (frattura-segnale,
    espulsione automatica) — **il primo Vuoto è completo nella sua forma
    base**: 6 fratture attorno al pianeta di Jerah
17b. ✅ **Il Vuoto Ardente** (ex "L'ultimo spettacolo di Jerah": il Vuoto non porta più il nome
    del suo boss). Ordine di apertura: prima Meridia e lo Squarcio Industriale — semplici
    frazioni del mondo vero, senza fonte, che si chiudono esplorandole; solo dopo compaiono
    la Casa Gigante e il Teatro del Passato. Meridia è farm zone: agguati ripetibili, gruppi
    fino a 3 nemici, quartieri profondi con Zombie Mostruoso, Orrore di Meridia e il raro
    Titano Zombie
18. ⬜ Gli altri 5 vuoti principali e la crepa post-Vuoto 5 (contenuti di Bru). Dopo il Vuoto 7,
    alcuni livelli già visti ripiombano nel caos: si ripercorrono per estinguere i 4 cavalieri
    a guardia del boss finale del gioco — solo battendoli tutti si sblocca l'ultimo Vuoto
19. ⬜ Le 10 classi vere (varianti M/F) e la sezione studio come schermata —
    roster e nomi/classe fissati in `classes.json` (Sally-Troublemaker,
    Vega-Hope, Niru-Meteora, Fio-Sognatrice, Yhvina-Insonne, Rio-Collezionista,
    Bero-Mecha, Mockingbear-Fanatico, Mr. Eto-Mente), stat ancora segnaposto
    per i nuovi; mancano ancora abilità/mosse/ritratti per ognuno
20. ✅ Pianeta tutorial (in-fiction "Pianure di Redenna"): non è un punto della mappa,
    parte da solo a fine introduzione e sblocca il mondo di Jerah al completamento
    (`richiede_flag` sui punti). Insegna Studio/risparmio (Tartaruga Innocente) e Fuggi (Manifestazione di
    un sogno, `incontro_scriptato`); boss finale (goblin arrabbiato) non convincibile, con
    mosse pesate + `dialogo_soglia_hp` + `mossa_disperazione`. Dopo la vittoria segue un
    intermezzo al quartier generale dell'Organizzazione (Veronica, Dott.ssa Curie, una
    figura misteriosa dietro uno schermo oscurato) — un secondo "combattimento" contro
    Veronica, interamente narrato (non un vero Combattimento.tscn: è scriptato e
    invincibile, serve solo a ripassare i comandi), prima di sbloccare Jerah per davvero.
    Segnaposto ancora da costruire: la schermata del "Diario" (task/legami/statistiche) e
    una vera mappa del quartier generale (per ora sono solo nodi narrativi)
21. ✅ **Le prove** (`prove/`, 1347 verifiche) e la pipeline che le fa girare a ogni push. Fino a
    qui il progetto era stato verificato **leggendolo**: nessuno aveva mai fatto girare il gioco
    per controllare, e un id sbagliato dentro un JSON non è un errore di compilazione. Ora si
    controlla eseguendo
22. ✅ **Scorporo di `Combattimento.gd`** (2284 → 1871 righe) per **layer**, non per funzione:
    `Regole` (matematica pura, zero effetti), `Voce` (coda, box, attese), `Campo` (schede),
    `Menu` (bottoni). Il motore dei turni resta grosso e in un file solo — mosse, stati e
    incontri scriptati si tengono per mano davvero, spezzarli sarebbe stato spostare righe
    dietro un oggetto-contesto. Quello che è cambiato è che le tre parti che si guardano hanno
    una **modalità muta**, ed è questa che sblocca il **giocatore automatico**: 99.000 partite
    giocate dal motore vero danno, per la prima volta, un bilanciamento misurato invece che
    indovinato (`docs/bilanciamento.md`)

23. ✅ **Lo Squarcio Industriale riscritto e allungato** (testi di Bru). La zona non comincia
    più dal corridoio dei tubi: corridoi a luce intermittente, sala vetrata sulla catena di
    montaggio, e il **Robo Pattuglia** che si presenta in binario prima di eseguire l'ordine.
    Dal corridoio dei tubi si può **andare ancora più a fondo**: corridoi che non finiscono
    mai, una porta che cede, e dentro la **stanza degli schermi** — che riprendono il
    protagonista da ogni angolazione — con i file della direzione ancora aperti. Se ne leggono
    tre pagine su sei, poi l'**Operaio Sfruttato** difende il suo lavoro e nello scontro il
    computer si rompe: le altre tre restano lì (appunto aperto, servirà uno strumento). Solo
    dopo aver visto quella stanza le tre entrate del corridoio hanno un nome — *sala delle
    valvole*, *Deposito*, *Sala informatica* — e il vecchio centro di controllo coi diari di
    Kizako si raggiunge **solo dalla Sala informatica**. Nuovo tipo di messaggio `immagine`:
    un'illustrazione a schermo intero con didascalia, che senza il disegno resta comunque
    leggibile
24. ✅ **Meridia riscritta** (testi di Bru) e **`docs/mappe.md`**. La zona non butta più il
    giocatore in mezzo agli zombie: si arriva su una collina che affaccia sulla città, si
    scende per le strade di periferia, si entra, e solo dopo l'Organizzazione dà il compito
    («studia il quartiere est»). Da lì tre direzioni — la strada principale, il parco, la
    struttura abbandonata — e due scene scritte: il **garage sotterraneo** (quattro piani
    fino a un cumulo di macerie da cui sale aria: si potrà scendere più avanti) che uscendo
    fa scattare l'agguato di quello che ti seguiva da quando sei entrato, e il **parco**, dove
    la fiala nel lago prosciugato chiama giù dal cielo una **Nuvola di Marciume**.
    `docs/mappe.md` si rigenera dai dati (`python3 strumenti/genera_mappe.py`) e disegna ogni
    zona due volte: la **griglia** (le stanze una rispetto all'altra, come le vedrà il
    giocatore) e il **percorso** (la zona ripercorsa dall'ingresso, con oggetti, agguati,
    scontri scritti, flag e requisiti di ogni ramo)
25. ✅ **La mappa a quadratini.** Le stanze non stanno più a coordinate libere in pixel: ognuna
    occupa una o più **celle** di una griglia (`cella`, e `dimensione` per quelle grandi), così
    il salone si vede largo e il vivaio si vede scendere. Tre stati, e sono l'unica cosa che
    conta: **pieno** dove sei stato (rosso, o verde per una zona segreta), **`?` acceso** su
    quello che sai raggiungibile e non hai ancora battuto — cliccabile, ci si va — e **`?`
    spento** su quello che confina con un posto noto, che cliccato dice perché non si passa
    ancora invece di non fare niente. Quello che non confina con niente di noto non viene
    disegnato affatto: la mappa si costruisce camminando. Icone (`icona`) disegnate dal codice
    finché non arrivano i disegni: mettere `art/icone_mappa/<icona>.png` le sostituisce senza
    toccare una riga. Due stanze non possono finire sullo stesso quadratino — `prova_mappe`
    tiene il conto di ogni cella occupata, perché una sovrapposizione a schermo non è un
    errore, è un quadrato che ne copre un altro e lo rende incliccabile.
    **Dalla mappa non ci si teletrasporta**: si va solo dove si andrebbe a piedi, cioè in una
    stanza che confina con quella in cui sei. Una mappa che porta ovunque cancella
    l'esplorazione senza che nessuno se ne accorga — si continua a giocare, semplicemente il
    mondo non ha più distanze. L'unica eccezione è il **proiettore**, in dotazione al
    dominatore: in alcune stanze compare la scelta di piantarlo lì
    (`"piazza_proiettore": true`), e da quel momento la mappa ci riporta da qualunque punto
    della zona. Ne esiste **uno solo** e piantarlo altrove lo sposta — è quello che rende
    «dove lo ancoro» una decisione invece di una comodità che si accumula.
    Restano: zoom e trascinamento, una mappa **per piano** invece di una per zona, gli eventi
    che compaiono sulla mappa dopo uno scontro (e **scadono** se il giocatore perde troppo
    tempo), e la **mappa totale a contorni**
25b. ✅ **`strumenti/controlla_testi.py`**: cerca nei testi che il giocatore legge gli errori
    che in italiano si fanno sempre e che si riconoscono con certezza — «perchè» senza accento
    acuto, «un pò», «qual'è», refusi noti, e soprattutto l'**accento scritto con l'apostrofo**
    (`finche'`, `sara'`), che nei commenti del codice è la convenzione e nei dati finisce a
    schermo tale e quale. Poche regole che non sbagliano mai, non tante che gridano al lupo:
    un controllo che dà falsi allarmi smette di essere letto dopo due giri.
    `python3 strumenti/controlla_testi.py --correggi` sistema quelle sicure
26. ✅ **La Casa Gigante esce di casa** (testi di Bru). Dalla soglia si può anche non entrare: sul
    fianco c'è l'ingresso ai **giardini tropicali**, e da lì tre sentieri. A **est**, in fondo,
    un albero con dentro un volto: la **custode dei giardini**, un tempo capo ricerca al fianco
    della capofamiglia, demansionata per essersi rifiutata di lavorare a quello che le
    chiedevano. Parla solo a chi le mostra la spilla a margherita, e da lì in poi è il banco
    degli indizi della zona *e* il suo pezzo di lore più lungo. A **ovest** il **grande
    laboratorio** (matrice di accesso, diserbante, diari di ricerca); a **nord** il **vivaio**,
    murato da rovi che si rigenerano finché non arriva il diserbante, e in fondo al vivaio il
    miniboss **Volto sulla parete** — quel che resta della capofamiglia — che custodisce l'**ID**
    con cui si apre la botola. La botola adesso ha una serratura vera: la matrice da sola
    risponde «UTENTE NON IDENTIFICATO. ID VUOTO.». Yhvina non serve più solo per un
    combattimento: attraversa tutta la parte nuova, e in fondo all'albero della lore c'è la
    scena che decide se sarà reclutabile più avanti nel gioco
27. ✅ **Le leve di tipo «bersaglio»** (testi di Bru). Una leva non è più solo un oggetto da
    mostrare o un flag alzato prima dello scontro: può essere **qualcosa che sta nella stanza e
    che studiando si sveglia**. Nella Casa Gigante le lettere sull'altare non si bruciano più
    prima del combattimento — studiando la bambola abbastanza volte cominciano a vibrare,
    diventano attaccabili, e distruggerle è la leva. Nei dati è
    `{"tipo": "bersaglio", "dopo_studi": N, "hp": N, "testo_comparsa": …}` sulla creatura.
    Le lettere sono anche quello che alimenta la **frenesia**: distrutte prima della soglia, il
    conto alla rovescia non parte affatto — altrimenti chi usa la meccanica che il gioco gli ha
    appena insegnato si ritroverebbe punito, senza più niente da colpire per fermare il conto
28. ⬜ **Modalità post-gioco**: *Boss Rush* (risfidare ogni boss di fila) e *Fonte delle Memorie*
    (risfidare ogni tipo di nemico incontrato). Si aprono a gioco finito; l'infrastruttura c'è già
    — il bestiario sa chi hai incontrato e il giocatore automatico sa già montare uno scontro
    qualunque senza passare da una stanza