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

## Struttura
- `scenes/Splash.tscn` + `scripts/Splash.gd` — loghi d'apertura (studio/personale, placeholder
  testuali finché mancano le immagini in `art/branding/`), poi il menu
- `scenes/Menu.tscn` + `scripts/Menu.gd` — menu principale: Start (Continua/Carica
  partita/Nuova partita) / Opzioni / Extra
- `scenes/Opzioni.tscn` + `scripts/Opzioni.gd` — audio, grafica, accessibilità (vedi sotto)
- `scenes/Extra.tscn` + `scripts/Extra.gd` — collezioni (album/bestiario/oggetti), carica
  codice, social e ringraziamenti
- `scenes/Intro.tscn` + `scripts/Intro.gd` — crawl introduttivo (solo per una nuova partita)
- `scenes/Mappa.tscn` + `scripts/Mappa.gd` — mappa stellare, marker data-driven
- `scenes/MappaZona.tscn` + `scripts/MappaZona.gd` — mappa dungeon della zona corrente, se ne
  ha una (`mappa_dungeon`, vedi sotto)
- `scenes/Selezione.tscn` + `scripts/Selezione.gd` — menu del party: mostra solo le classi
  sbloccate e si riadatta man mano che i personaggi entrano o escono dai disponibili
- `scenes/Main.tscn` + `scripts/Main.gd` — motore eventi + palco dialoghi
- `scenes/Combattimento.tscn` + `scripts/Combattimento.gd` — combattimento a turni
- `scenes/Ritratto.tscn` + `scripts/Ritratto.gd` — ritratto riusabile (immagine o placeholder)
- `scripts/GameState.gd` — autoload: roster, party, inventario, livelli, RNG seedato, JSON
- `scripts/Stile.gd` — autoload: il linguaggio visivo del gioco, letto da `data/stile.json` e
  applicato come `Theme` globale (vedi sotto)
- `scripts/Transizioni.gd` — autoload: dissolvenza in nero tra una schermata e l'altra (vedi sotto)
- `scripts/BoxTesto.gd` + `scenes/BoxTesto.tscn` — il box del testo con macchina da scrivere,
  usato dalla schermata eventi (vedi sotto)
- `scripts/Impostazioni.gd` — autoload: impostazioni utente persistite a parte (vedi sotto)
- `data/classes.json` — classi giocabili (`protagonista` + lista con id, nome, hp, velocita, abilita, ritratto)
- `data/personaggi.json` — personaggi non giocabili (ritratti nei dialoghi + stat/xp se combattono)
- `data/psiche.json` — le psichi e i loro effetti (reazione al KO di un compagno)
- `data/regole.json` — numeri di bilanciamento (hp, danno, stress, fattore, xp, legame)
- `data/events.json` — campagna di prova
- `data/events_intro.json` — l'introduzione (monologo prima del tutorial)
- `data/codici.json` — codici riscattabili da Extra (vuoto per ora: `{codice, testo, effetto}`)
- `data/mappa.json` — sfondo e punti della mappa stellare
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
  qualunque testo. Cinque proposte di cornice disegnabile a mano (ognuna presa da un materiale
  già nel gioco: l'ossidiana di Jondoh, una locandina di circo strappata, il sipario di Jerah,
  il rammendo di una bambola) sono in un artifact di preview mostrato a Bru in chat, con le
  dimensioni di tela e i margini consigliati per ciascuna.
- **`scripts/Transizioni.gd`** (autoload, `CanvasLayer` sopra tutto): un velo nero cala,
  la scena cambia mentre lo schermo è coperto, il velo si rialza. `Transizioni.vai(percorso)` ha
  sostituito ogni `get_tree().change_scene_to_file()` del progetto — un cambio di schermata non è
  mai più uno scatto secco, ed è impossibile entrare due volte nella stessa stanza per un doppio
  click (il velo assorbe l'input finché non è finito).

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

## Salvataggio
Si salva **solo dalla mappa stellare** — mai nel Vuoto, mai dentro un carnivalz/squarcio,
mai in combattimento. Due meccanismi, entrambi via `GameState._scrivi_salvataggio(percorso)`
(stesso stato meta: livelli, xp, stress, legame, Tazo, sacca/collezionabili/chiavi/carte,
bestiario, compendio oggetti, negozi, flag, classi sbloccate):
- **Autosalvataggio**: `GameState.salva()`/`carica()`, un solo file (`user://salvataggio.json`),
  scritto ogni volta che si entra nella mappa. Dal menu, **Continua** lo ricarica al volo.
- **Salvataggi manuali**: `GameState.salva_slot(n)`/`carica_slot(n)`, **5 slot** al massimo
  (`GameState.SLOT_MASSIMO`, un file per slot). Sulla mappa, il bottone **Salva** apre un
  selettore degli slot (con anteprima: Tazo/fonti estinte/legame) e sovrascrive quello scelto;
  dal menu, **Carica partita** apre lo stesso selettore in lettura (solo gli slot occupati sono
  cliccabili).

**Nuova partita** azzera il progresso di storia (le collezioni album/bestiario/oggetti restano,
sono meta). Non si salva a metà campagna/squarcio: si riparte sempre dallo stato "overworld".

**`"salva_checkpoint": true`** su un nodo (es. `dopo_lamento` nei Cunicoli di Jondoh) chiama
`GameState.salva()` lì per lì, dentro lo squarcio — un'eccezione deliberata alla regola sopra,
per non perdere Tazo/oggetti/flag raccolti in un dungeon molto lungo. **Non** fa però riprendere
la partita da quel punto: `_leggi_salvataggio()` torna comunque sempre a uno stato overworld
pulito (party/nodo/eventi azzerati), quindi un game_over dopo il checkpoint riporta comunque
alla mappa stellare — si perde la posizione nel dungeon, non il bottino raccolto prima. Un vero
"riprendi da qui dentro lo squarcio" richiederebbe salvare anche `eventi`/`nodo_corrente`/
`carnivalz_corrente`/`mappa_zona`/party e non azzerarli al caricamento: non ancora fatto.

## Palco dialoghi (con espressioni)
Ogni personaggio ha 16 **espressioni** per i dialoghi in `art/personaggi/<id>/<espr>.png`
(neutra, arrabbiata, felice, carina, infastidita, disgusto, speciale, dialogo, delusa,
petrificata, annoiata, pensiero, sorpresa, sforzo, cool, decisa). Fallback: espressione →
`neutra.png` → vecchio file singolo → iniziale. Nei nodi, i lati indicano l'espressione con
`{ "id": "jerah", "espr": "arrabbiata" }` o con `espr_sinistra`/`espr_destra`/`espr_centro`.
Dettagli in `art/personaggi/README.md`.
Sopra il box del narratore ci sono due spazi per i disegni: a **sinistra sempre il
protagonista** (o un alternativo, chiave `sinistra` nel nodo), a **destra l'interlocutore**
(chiave `destra`). I dialoghi sono discussioni tra almeno due persone, quindi gli spazi sono
solo due. Se il nodo ha la chiave `centro`, quel personaggio parla da solo al centro e gli
spazi laterali spariscono.

**Stile cinematografico** (stile Undertale, su indicazione di Bru): i ritratti riempiono
quasi tutto lo schermo (`Ritratto.imposta_grande(true)`, chiamato su tutti e tre gli slot in
`Main._ready()`), il box del testo (`scenes/BoxTesto.tscn`, vedi la sezione "Stile visivo, box
del testo e transizioni" più sopra) è una striscia bassa e fissa in basso, con font, bordi e
colori che vengono tutti da `Stile.gd`. Un cambio di ritratto o di espressione non è mai uno
scatto: la vecchia immagine sfuma nella nuova (`Ritratto.dissolvi_ingresso()`). **Mancano
ancora** gli sfondi di scena a piena pagina (per ora resta il `ColorRect` a tinta unita, colore
`Stile.colore("sfondo")`); il font è già configurabile da `data/stile.json` senza toccare il
codice, appena Bru fornisce un `.ttf`.

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

## Equipaggiamento (accessori)
Un nuovo tipo di oggetto, `"tipo": "accessorio"` in `data/oggetti.json`. A differenza dei
consumabili (usati e persi in combattimento) o delle collezioni passive, un accessorio si
**equipaggia** dal Compendio (`Compendio.gd`, un bottone sulla sua scheda se lo possiedi) — **uno
solo alla volta** (`GameState.accessorio_equipaggiato`) — e il suo effetto (`effetto_equipaggiato`)
è passivo, letto una volta a inizio combattimento (`Combattimento._ready()`).

**Il primo accessorio raccolto si equipaggia da solo** (`GameState.aggiungi_oggetto()`, solo se
non ne hai già uno addosso): "avere" la Pietra Quieta deve bastare a proteggerti senza passare
dal Compendio — il gioco non ha ancora insegnato che esista. Con uno già equipaggiato, il
cambio resta una scelta esplicita. Attenzione quando si scrive contenuto: un accessorio **non
finisce nella sacca** e quindi non compare nel menu "Oggetti" in combattimento; agisce da solo.
- **`scudo_primo_stato`**: il primo stato subito in quel combattimento viene respinto e non ha
  effetto; il bersaglio diventa immune a *quello stesso stato* per il resto dello scontro
  (`combattente.immunita_temporanea`, controllato in `resistenza_di()`). L'accessorio si
  consuma (sparisce) nel momento in cui scatta (`GameState.consuma_accessorio_equipaggiato()`).
  Esempio: la **Pietra Quieta**, lasciata dalla Tartaruga Innocente se la risparmi
- **`resurrezione_dimezzata`**: se chi lo indossa morirebbe, l'accessorio si spezza e lo riporta
  in vita a metà dei suoi hp massimi, una volta sola per combattimento (`Combattimento._su_ko()`,
  controllato prima di qualunque altra risoluzione del KO). Esempio: il **Ricordo del Passato**
- Gli accessori posseduti vivono in `GameState.accessori` (mai consumati dall'uso, a differenza
  della sacca); si azzerano a nuova partita come il resto dell'inventario, non sono una
  collezione meta

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
  (Fattore Carnivalz: alimenta critici e Slaughter). Solo il protagonista le usa —
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
Un personaggio può avere nei dati una chiave `risparmio` ({`legame`, `stress`, `testo`}):
se presente, **studiarlo lo risparmia automaticamente** appena finisce lo scambio — esce dal
combattimento (niente xp/tazo/drop per lui), il legame di squadra sale, lo stress della
squadra scende. Gli altri nemici dello stesso combattimento restano e vanno affrontati
normalmente. Se il giocatore preferisce comunque attaccarlo invece di studiarlo, si comporta
come un nemico qualsiasi (xp/tazo/carta inclusi). Usato dalla Tartaruga Innocente nel tutorial.

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
