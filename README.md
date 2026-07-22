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

## Palco dialoghi
Sopra il box del narratore ci sono due spazi per i disegni: a **sinistra sempre il
protagonista** (o un alternativo, chiave `sinistra` nel nodo), a **destra l'interlocutore**
(chiave `destra`). I dialoghi sono discussioni tra almeno due persone, quindi gli spazi sono
solo due. Se il nodo ha la chiave `centro`, quel personaggio parla da solo al centro e gli
spazi laterali spariscono.

## Combattimento
Numeri piccoli e leggibili, ma con scelte vere:
- Stats per combattente (nei dati): **hp, attacco, difesa, velocità, fattore**. Danno =
  attacco (+1 se il fattore arde) − difesa del bersaglio, minimo 0
- Party e nemici in un'unica fila d'iniziativa per **velocità**, ricalcolata a ogni giro
- **Menu azioni**: Attacca · Difenditi (difesa +2 fino al prossimo turno) · Abilità
  (**Studia** sempre disponibile) · Oggetti (consumabili dalla sacca) · Alleati (gli ospiti
  come il Vecchio Clown: un assist a combattimento, non sono veri combattenti)
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
domanda/risposta nella lista `studio` di ogni personaggio (anche i nemici comuni). Chi viene
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
  di Meteora al falò richiede legame ≥ 40)

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
- **Bottino comune** (`bottino_comune` nei dati: lista `{oggetto, chance}`) — consumabili tipo
  fiala HP, va nella sacca
- **Carta** (`carta`: `{id, nome, rarita, testo, chance?}`) — se manca `chance` è **garantita**
  (nemici unici: miniboss e boss); con `chance` è un drop **raro** (comuni: 3–5%). Rarità:
  comune · non_comune · rara · epica · leggendaria

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
- **Fratture nascoste**: nel `mappa.json`, un vuoto con `nascosto: true` appare solo se soddisfa
  `richiede_oggetti` (possiedi quegli oggetti) o `richiede_flags` (tutte quelle quest completate).
  Sulle scelte, `richiede_oggetti` gate una scelta finché non hai tutti i pezzi (la Fontana)
- Mosse boss extra: `autolesione` (si ferisce, stress a tutta la squadra) e
  `attacco_tutti` con campo `stress` (il lamento della bambola)

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
      "destra": "meteora",
      "centro": "imbonitore",
      "scelte": [
        { "testo": "...", "vai": "altro_nodo", "richiede": "volo", "recluta": "meteora", "oggetto": "lanterna", "lascia": "meteora", "reset": true },
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
    passato, casa gigante + zona nascosta di Meteora), agguati random,
    loot una tantum, stanze segrete, miniboss Un tenero ricordo
11. ✅ Menu principale + collezioni: album carte, bestiario, compendio
    oggetti; drop comuni e carte (rare/garantite) dai nemici
12. ✅ Rework mondo di Jerah (corrida/fiamme), rebalance (danno scala col
    livello, Jerah 35 HP, bambola 66 HP), alleata temporanea Yhvina,
    fratture gated da quest (Ala Kizako, Fontana coi 4 pezzi)
13. ⬜ Gli altri 5 vuoti principali e la crepa post-Vuoto 5 (contenuti di Bru)
14. ⬜ Salvataggio (serializzare GameState — ora anche le collezioni)
15. ⬜ Le 10 classi vere (varianti M/F) e la sezione studio come schermata
