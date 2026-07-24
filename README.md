# Carnivalz

RPG d'avventura narrativa dark fantasy: illustrazioni statiche, mappa stellare + eventi + scelte.
I mondi collassano, le realtà si fondono, e chi tocca il confine matura il fattore Carnivalz:
l'Organizzazione manda il party a estinguere le fonti prima che i pianeti vengano divorati.
Storia completa (canone): `docs/storia.md`.
Motore in Godot (GDScript), **contenuti tutti nei JSON** sotto `data/` — mai hardcodati negli script.
Il protagonista è l'**Anonimo**: il gioco si vive in prima persona attraverso le sue avventure.

## Come si avvia
Aprire `project.godot` con Godot 4.7+ (versione standard). Flusso:
**mappa stellare** ("!" dove un Carnivalz sta avendo luogo) → click → **selezione del party**
(solo le classi sbloccate; l'Anonimo c'è sempre) → **campagna narrata** → fine → mappa.

## Struttura
- `scenes/Mappa.tscn` + `scripts/Mappa.gd` — mappa stellare (main scene), marker data-driven
- `scenes/Selezione.tscn` + `scripts/Selezione.gd` — menu del party: mostra solo le classi
  sbloccate e si riadatta man mano che i personaggi entrano o escono dai disponibili
- `scenes/Main.tscn` + `scripts/Main.gd` — motore eventi + palco dialoghi
- `scenes/Combattimento.tscn` + `scripts/Combattimento.gd` — combattimento a turni
- `scenes/Ritratto.tscn` + `scripts/Ritratto.gd` — ritratto riusabile (immagine o placeholder)
- `scripts/GameState.gd` — autoload: roster, party, inventario, livelli, RNG seedato, JSON
- `data/classes.json` — classi giocabili (`protagonista` + lista con id, nome, hp, velocita, abilita, ritratto)
- `data/personaggi.json` — personaggi non giocabili (ritratti nei dialoghi + stat/xp se combattono)
- `data/psiche.json` — le psichi e i loro effetti (reazione al KO di un compagno)
- `data/regole.json` — numeri di bilanciamento (hp, danno, stress, fattore, xp, legame)
- `data/events.json` — campagna di prova
- `data/mappa.json` — sfondo e punti della mappa stellare
- `art/` — illustrazioni di Bru: `art/mappa.png` (sfondo mappa), `art/personaggi/<id>.png`
  (ritratti). Finché mancano: placeholder generati (cielo stellato / iniziale del nome)

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
`Main._ready()`), il box del narratore è una striscia sottile e fissa in basso (bordo bianco,
sfondo nero). Sopra il box, l'etichetta **`%NomeParlante`** mostra sempre chi sta "parlando":
di default il **protagonista** (la narrazione è il suo dialogo interiore — non serve un
narratore esterno), il personaggio in `centro` quando parla da solo, il compagno scelto con
"Parla con la squadra". Stessa trattazione in combattimento: il nemico al centro
(`%NemicoCentro`) è sempre grande, il Diario è la striscia in basso. **Mancano ancora**: un
font monospace "pixel" per il testo (per ora resta il font di sistema — se Bru fornisce un
`.ttf` lo si aggiunge come tema) e gli sfondi di scena a piena pagina (per ora resta il
`ColorRect` a tinta unita).

**Notifiche di raccolta oggetti**: `Main.pickup()` non scrive più nel box del narratore (si
perdeva nel cambio nodo, ed era comunque fuori posto). Mostra invece un **toast** indipendente
(`mostra_toast()`): un piccolo pannello in alto che appare in fade, resta a schermo un paio di
secondi e sparisce da solo. Per gli oggetti chiave (di solito indizi/lore, come le pagine di
giornale di Meridia) il toast include anche la descrizione e resta a schermo più a lungo (5s
invece di 2.2s).

## Combattimento
Numeri piccoli e leggibili, ma con scelte vere:
- Stats per combattente (nei dati): **hp, attacco, difesa, velocità, fattore**. Danno =
  attacco (+1 se il fattore arde) − difesa del bersaglio, minimo 0
- Party e nemici in un'unica fila d'iniziativa per **velocità**, ricalcolata a ogni giro
- **Menu azioni**: Attacca · Difenditi (difesa +2 fino al prossimo turno) · Abilità
  (**Studia** sempre disponibile) · Oggetti (consumabili dalla sacca) · Alleati (gli ospiti
  come il Vecchio Proprietario del teatro: un assist a combattimento, non sono veri combattenti)
- **Danno del party scala col livello**: `danno = attacco + ⌊(liv−1) × 0.5⌋` (+ fattore, + oggetti).
  HP del party restano 5 (semplici); i boss hanno grandi riserve (Jerah 35, la bambola 66) →
  la difficoltà sta nel non morire durante scontri lunghi. `bonus_attacco_per_livello` in regole
- I **boss hanno mosse pesate** nei dati (`mosse`: attacco_forte, attacco_tutti,
  buff_difesa, buff_fattore, evoca + `peso_attacco_normale`): ogni scontro è unico
- **Alleato temporaneo**: `recluta_temporaneo` (+`livello_alleato`) mette un compagno in squadra
  solo per lo squarcio corrente; `congeda` (o l'uscita dallo squarcio) lo rimanda via. Yhvina
  nella Casa Gigante
- Il danno **subìto dal party cala in proporzione al livello** (probabilità di assorbire:
  (livello − 1) × 10%, tetto 50%, + fattore/200)
- Vittoria: XP e **Tazo** a tutto il party (somma di `xp` e `tazo` dei nemici). Sconfitta:
  nodo `se_perdi` o ritorno alla mappa
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
studiato finisce nel registro `studiati` (base per la futura sezione studio/codex).

I boss **possono o non possono essere convinti** (`convincibile` nei dati della fonte: i
malvagi, che manipolano il fattore, hanno `false` e la speranza non esiste per loro).
Se la fonte è convincibile compare la **Speranza**:
- **Leve** (lista `leve`): oggetti nell'inventario, ospiti temporanei (chiave evento
  `ospite`) o compagni nel party — applicate all'inizio dello scontro, con il loro testo
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

## Esperienza e legame
- **XP**: la vittoria dà XP a tutto il party; livello massimo **130**, fabbisogno
  `xp_base × livello^1.5`, e i 30 livelli dopo il 100 sono ostici (fabbisogno ×5)
- **Legame** (0–100): si coltiva interagendo e prendendosi cura dei compagni (chiave
  `legame` sulle scelte) e **cala di continuo** (−1 a ogni scelta). Un legame alto fa
  apparire gli eventi rari: chiave `richiede_legame` sulle scelte (es. la stella caduta
  di Niru al falò richiede legame ≥ 40)

## Dialogare con i compagni
Nella schermata eventi (campagna o squarcio) compare "Parla con la squadra" quando il party
ha almeno un compagno oltre al protagonista. Clic → scegli un compagno → se `data/dialoghi.json`
ha una voce per il nodo corrente (`luoghi.<id_nodo>`) la mostra (con `%s` sostituito dal nome
di chi parla), altrimenti un fallback generico. Le voci con `una_tantum` si dicono una volta
sola e possono impostare un `flag` — usato per sbloccare scelte altrimenti nascoste (es. la
botola sotto i cuscini nella Casa Gigante: nessuno la nota, da soli). Dopo la battuta le
scelte si ricostruiscono, così l'eventuale sblocco appare subito.

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
`richiede_flag` per farli apparire). Gli squarci usano il motore eventi con stanze
collegate nei due sensi (perlustrazione libera):
- **`agguato`** su un nodo: `{probabilita, gruppi: [[ids]...], se_perdi}` — tirato una
  volta per stanza a visita (seedato); vinto lo scontro si torna nella stanza; a ogni
  rientro nello squarcio gli agguati si resettano (i nemici rispuntano)
- **`una_tantum`** su una scelta: appare solo se il flag non è mai stato preso, e lo
  imposta scegliendola (loot permanente: Tazo, oggetti). `flag` (su scelta o nodo) +
  `richiede_flag`/`richiede_non_flag` per stanze segrete e boss che non rispawnano
- **`torna_vuoto`** su una scelta: esce dallo squarcio (gli alleati temporanei restano fuori)
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
`richiede_legame` (legame ≥ soglia), `richiede_ospite` (quell'ospite con te), `recluta`,
`oggetto` (va nello slot giusto in base al tipo), `lascia`, `ospite` (personaggio temporaneo
per la campagna), `tazo` (±; se negativa e non puoi pagare, la scelta non appare), `stress`
(± a tutto il party), `legame` (±), `sblocca_negozio`, `combatti` (lista di id nemici;
`se_vinci`/`se_vinci_eroe`/`se_perdi` destinazioni), `reset` (fine campagna: inventario,
Tazo, roster, livelli, stress e legame restano, gli ospiti no).

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
18. ⬜ Gli altri 5 vuoti principali e la crepa post-Vuoto 5 (contenuti di Bru)
19. ⬜ Le 10 classi vere (varianti M/F) e la sezione studio come schermata —
    roster e nomi/classe fissati in `classes.json` (Sally-Troublemaker,
    Vega-Hope, Niru-Meteora, Fio-Sognatrice, Yhvina-Insonne, Rio-Collezionista,
    Bero-Mecha, Mockingbear-Fanatico, Mr. Eto-Mente), stat ancora segnaposto
    per i nuovi; mancano ancora abilità/mosse/ritratti per ognuno
20. ✅ Pianeta tutorial ("Il piccolo Carnivalz"): primo punto della mappa,
    sblocca il mondo di Jerah solo al completamento (`richiede_flag` sui
    punti). Insegna Studio/risparmio (Tartaruga Innocente) e Fuggi
    (Manifestazione di un sogno); boss finale non convincibile, forte quanto
    un nemico normale
