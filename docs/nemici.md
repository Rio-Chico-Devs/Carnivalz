# Il bestiario, e cosa sa fare

> **Generato dal gioco**, non scritto a mano: `./strumenti/nemici.sh`. I numeri qui sotto
> sono gli stessi che il combattimento usa in campo — escono dalla curva dei ruoli
> (`data/ruoli.json`) e dalle mosse dichiarate in `data/personaggi.json`. Se cambi un
> livello o una quota, rilancia lo strumento e questa pagina si aggiorna da sola.

## Come si leggono i numeri

- Le **statistiche** sono quelle della creatura al suo livello base. In gioco una creatura
  non scende mai troppo sotto il tuo livello (il disallineamento la tira su), e quando
  viene tirata su **rifà il conto sulla stessa curva** — quindi resta la stessa creatura,
  più grande, non una creatura diversa.
- Il **danno di una mossa** è una *quota* dell'attacco che la creatura ha in quel momento.
  «×1,4» vuol dire una volta e mezza scarsa il suo colpo normale, a qualunque livello.
  Una mossa con un numero fisso è un'eccezione dichiarata, e qui è segnata come tale.
- **Quando** dice a quale condizione la mossa esiste. Una mossa fuori condizione non entra
  nemmeno nel sorteggio: non è che «capita di rado», è che non c'è.
- **Scelta** dice che quella mossa non si sorteggia: se la condizione c'è, la creatura la
  *sceglie* (vince la priorità più alta). È lì che vive la sua testa.
- **Ricarica** è quante sue battute deve aspettare prima di rifarla.

## La regola che vale per tutte

Sotto il **30% della sua vita** una creatura è *alle strette*: colpisce il **30% in più**
e comincia a scegliere le mosse invece di sorteggiarle — chi sa curarsi si cura, chi ha un
ultimo colpo in canna lo tira. Non è scritto creatura per creatura: è una riga sola in
`data/ruoli.json`, così non può mancare a metà bestiario.

## Livelli 1-5 — il tutorial e le prime crepe

### Goblin Tipico — livello 1, comune
*Verde, spelacchiato, armato di un bastone che ha trovato per terra. Non ha mai vinto una rissa in vita sua.*

`goblin_tipico` · ♥ 86 · attacco 6 · difesa 1 · velocità 2 · xp 2

| Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --- | --- | --- | --- | --- | --- |
| Sassata | un colpo pesante su uno solo | ×1.30 → 8 | sempre | sorteggio | — |
| Si copre la testa | alza la guardia | — | sotto il 35% di vita | priorità 5 | 3 battute |

### Slime Infimo — livello 1, comune
*Una pozza gelatinosa che si crede un mostro. Ci vuole più tempo a notarlo che a batterlo.*

`slime_infimo` · ♥ 86 · attacco 6 · difesa 1 · velocità 2 · xp 2

| Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --- | --- | --- | --- | --- | --- |
| Bava appiccicosa | nessun danno: lascia addosso **Lentezza** | — | sempre | sorteggio | 4 battute |
| Si ricompone | **si rimette in piedi** (+30% della vita massima) | — | sotto il 40% di vita | priorità 6 | 4 battute |

### Tartaruga Innocente — livello 1, corazzato
*Un guscio enorme e un aspetto che mette paura. Non ha mai fatto del male a nessuno.*

`tartaruga_innocente` · ♥ 555 · attacco 0 · difesa 6 · velocità 2 · xp 2

| Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --- | --- | --- | --- | --- | --- |
| si_ritira_nel_guscio | alza la guardia | — | sempre | sorteggio | — |
| Dentro il guscio | **si rimette in piedi** (+15% della vita massima) | — | sotto il 50% di vita | priorità 6 | 4 battute |

### Infetto Rapido — livello 2, veloce
*Non tutti a Meridia sono diventati lenti. Questi corrono ancora, come se stessero ancora scappando da qualcosa.*

`infetto_rapido` · ♥ 94 · attacco 7 · difesa 0 · velocità 6 · xp 6

| Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --- | --- | --- | --- | --- | --- |
| Raffica di unghiate | 2 colpi su bersagli a caso | ×0.60 → 4 a colpo (8 totali) | sempre | sorteggio | — |

### Nuvola di Marciume — livello 2, veloce
*Un pezzo della coltre che copre Meridia, sceso più in basso degli altri. Non insegue nessuno: capita addosso.*

`nuvola_di_marciume` · ♥ 94 · attacco 7 · difesa 0 · velocità 6 · xp 6 · elemento veleno

| Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --- | --- | --- | --- | --- | --- |
| Capita addosso | colpisce **tutta la squadra** | ×0.55 → 4 | sempre | sorteggio | — |
| Spore | nessun danno: lascia addosso **Veleno** | — | sempre | sorteggio | 3 battute |

### Zombie Cittadino — livello 2, comune
*Era qualcuno, a Meridia, prima del coprifuoco. Ora cammina piano, verso niente in particolare, con tutti gli altri.*

`zombie_cittadino` · ♥ 125 · attacco 8 · difesa 2 · velocità 2 · xp 5

| Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --- | --- | --- | --- | --- | --- |
| Passo pesante | un colpo pesante su uno solo | ×1.20 → 10 | sempre | sorteggio | — |
| In mezzo agli altri | si chiude (difesa +2 per 3 battute) | — | con almeno 1 alleati in piedi | sorteggio | 4 battute |

### Manifestazione di un sogno — livello 3, miniboss
*Una forma che non dovrebbe esistere ancora, presa in prestito da un sogno che qualcuno, su questo pianeta, sta ancora sognando.*

`manifestazione_di_un_sogno` · ♥ 439 · attacco 14 · difesa 5 · velocità 4 · xp 41 · elemento psico

Nessuna mossa: il suo turno lo detta un copione (tutorial o incontro scriptato).

### Fomentado — livello 3, comune
*Un'anima irrequieta spinta al suo limite dalla sua stessa passione, brucia forte, sempre! Finché non rimarrà che cenere.*

`maschera_vuota` · ♥ 164 · attacco 10 · difesa 3 · velocità 3 · xp 9 · elemento fuoco

| Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --- | --- | --- | --- | --- | --- |
| Vampata | un colpo pesante su uno solo | ×1.40 → 14 | sempre | sorteggio | — |
| Ultima fiammata | un colpo pesante su uno solo | ×2.30 → 23 | sotto il 30% di vita | priorità 7 | — |

### Zombie Mostruoso — livello 3, comune
*Qualcosa, in questo, ha continuato a crescere anche dopo la morte. Le braccia non sono più della stessa lunghezza.*

`zombie_mostruoso` · ♥ 164 · attacco 10 · difesa 3 · velocità 3 · xp 9

| Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --- | --- | --- | --- | --- | --- |
| Braccio lungo | un colpo pesante su uno solo | ×1.50 → 15 | sempre | sorteggio | — |

### Oppresso — livello 4, corazzato
*La ruggine ha preso il posto della pelle, sta ancora aspettando che il suo turno finisca...*

`comparsa_di_ruggine` · ♥ 277 · attacco 10 · difesa 13 · velocità 3 · xp 16

| Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --- | --- | --- | --- | --- | --- |
| Si irrigidisce | si chiude (difesa +3 per 3 battute) | — | sempre | sorteggio | 3 battute |
| Colpo di ruggine | colpisce e **apre la guardia** | ×1.00 → 10 | sempre | sorteggio | — |

### El Muy Bonito — livello 4, particolare
*Una rara bellezza, un campione nella recita, ma il talento a volte può farti uscire fuori di testa.*

`giocoliere` · ♥ 340 · attacco 15 · difesa 7 · velocità 5 · xp 29 · elemento fuoco

| Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --- | --- | --- | --- | --- | --- |
| Torce in aria | 2 colpi su bersagli a caso | ×0.75 → 11 a colpo (22 totali) | sempre | sorteggio | — |
| Numero col fuoco | un colpo pesante su uno solo | ×1.60 → 24 | sempre | sorteggio | — |
| Gran finale | colpisce **tutta la squadra** | ×1.10 → 17 | sotto il 35% di vita | priorità 7 | — |

### Robo Pattuglia — livello 4, corazzato
*Una macchina di sorveglianza che non ha mai ricevuto l'ordine di smettere. Esegue un regolamento che nessuno applica più.*

`robo_pattuglia` · ♥ 277 · attacco 10 · difesa 13 · velocità 3 · xp 16 · elemento elettrico

| Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --- | --- | --- | --- | --- | --- |
| Scarica di avvertimento | un colpo pesante su uno solo | ×1.25 → 13 | sempre | sorteggio | — |
| Protocollo di contenimento | si chiude (difesa +3 per 3 battute) | — | sempre | sorteggio | 3 battute |
| Riparazione d'emergenza | **si rimette in piedi** (+22% della vita massima) | — | sotto il 35% di vita | priorità 8 | 5 battute |

### Capocantiere — livello 4, comune
*Gestire dieci... cento... no... mille operai insoddisfatti, non dà gratificazione alcuna.*

`voce_registrata` · ♥ 207 · attacco 13 · difesa 5 · velocità 4 · xp 13

| Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --- | --- | --- | --- | --- | --- |
| Richiamo disciplinare | un colpo pesante su uno solo | ×1.35 → 18 | sempre | sorteggio | — |
| Ordine urlato | nessun danno: lascia addosso **Demotivazione** | — | sempre | sorteggio | 4 battute |

### Emblema dell'oppressione — livello 5, comune
*Ferraglia tenuta insieme dallo spirito di un lavoratore che non è mai tornato a casa.*

`operaio_posseduto` · ♥ 245 · attacco 15 · difesa 6 · velocità 5 · xp 18

| Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --- | --- | --- | --- | --- | --- |
| Chiave inglese | un colpo pesante su uno solo | ×1.45 → 22 | sempre | sorteggio | — |
| Straordinario non pagato | si potenzia l'attacco (+3 per 3 battute) | — | sotto il 50% di vita | priorità 4 | 5 battute |

### Operaio Sfruttato — livello 5, particolare
*Non difende i file: difende le ore che ci ha lasciato dentro. Toccarli è toccare l'unica cosa che gli è rimasta.*

`operaio_sfruttato` · ♥ 404 · attacco 18 · difesa 8 · velocità 5 · xp 39

| Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --- | --- | --- | --- | --- | --- |
| Difende le sue ore | si chiude (difesa +2 per 3 battute) | — | sempre | sorteggio | 3 battute |
| Esplosione di rabbia | un colpo pesante su uno solo | ×2.00 → 36 | sotto il 40% di vita | priorità 6 | 4 battute |

### Orrore di Meridia — livello 5, particolare
*Più corpi che si sono trovati nello stesso posto al momento sbagliato, e non si sono più separati.*

`orrore_di_meridia` · ♥ 404 · attacco 18 · difesa 8 · velocità 5 · xp 39

| Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --- | --- | --- | --- | --- | --- |
| bracciata | un colpo pesante su uno solo | **18 fisso** | sempre | sorteggio | — |
| morsi | 2 colpi su bersagli a caso | **9 fisso** | sempre | sorteggio | — |
| Si ricompone | **si rimette in piedi** (+20% della vita massima) | — | sotto il 30% di vita | priorità 7 | 5 battute |

### Veronica — livello 5, miniboss
*La tua allenatrice, e l'amica d'infanzia che non ha mai imparato a dosare la forza.*

`veronica` · ♥ 600 · attacco 18 · difesa 6 · velocità 6 · xp 0

Nessuna mossa: il suo turno lo detta un copione (tutorial o incontro scriptato).

## Livelli 6-10 — il mestiere

### Il Divoratore — livello 6, particolare
*Una macchina che sembra uscita dai sogni di un pazzo, sembra divorare ogni cosa nel suo raggio d'azione, che sia viva o morta...*

`divoratore` · ♥ 468 · attacco 21 · difesa 10 · velocità 6 · xp 48

| Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --- | --- | --- | --- | --- | --- |
| Morso che divora | colpisce e **si nutre** (il 60% del danno torna a lei) | ×1.30 → 27 | sempre | sorteggio | — |
| Aspirazione | colpisce **tutta la squadra** | ×0.75 → 16 | sempre | sorteggio | — |

### Ferraglia Urlante — livello 6, corazzato
*Una montagna di rottami saldati dal dolore. Sembra di sentire le urla di una protesta.*

`ferraglia_urlante` · ♥ 381 · attacco 14 · difesa 18 · velocità 4 · xp 26

| Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --- | --- | --- | --- | --- | --- |
| Valanga di rottami | colpisce **tutta la squadra** | ×0.85 → 12 | sempre | sorteggio | — |
| Urlo di lamiera | nessun danno: lascia addosso **Terrore** | — | sempre | sorteggio | 5 battute |
| Si ricompatta | **si rimette in piedi** (+20% della vita massima) | — | sotto il 30% di vita | priorità 7 | 6 battute |

### Un goblin terribilmente arrabbiato — livello 6, fonte
*Non è mai stato bello, forte o rispettato, nemmeno tra i suoi. Il fattore di disallineamento gli ha dato l'unica cosa che gli mancava: qualcuno che lo temesse.*

`goblin_arrabbiato` · ♥ 1125 · attacco 25 · difesa 14 · velocità 6 · xp 152

| Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --- | --- | --- | --- | --- | --- |
| richiamo_dei_suoi_simili | chiama 1 × `goblin_tipico` | — | sempre | sorteggio | — |
| furia_di_un_goblin | un colpo pesante su uno solo | **9 fisso** | sempre | sorteggio | — |
| pugno_del_vile | un colpo pesante su uno solo | **9 fisso** | sempre | sorteggio | — |
| capriccio_del_goblin | si potenzia l'attacco (+9 per 3 battute) | — | sempre | sorteggio | — |
| cattiveria_innata | 3 colpi su bersagli a caso | **5 fisso** | sempre | sorteggio | — |

Ha anche **mossa_disperazione** (scritta a mano nei suoi dati, non nella tabella).

### Ghoul — livello 8, comune
*Carne marcia tenuta insieme dalla fame e da poco altro. Uno dei tanti che la Rocca di Ossidiana non ha mai lasciato andare.*

`ghoul` · ♥ 366 · attacco 23 · difesa 10 · velocità 6 · xp 30

| Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --- | --- | --- | --- | --- | --- |
| Morso famelico | colpisce e **si nutre** (il 50% del danno torna a lei) | ×1.20 → 28 | sempre | sorteggio | — |
| Artigliata | un colpo pesante su uno solo | ×1.45 → 33 | sempre | sorteggio | — |

### ??? — livello 8, particolare
*Qualcosa che cammina nella cripta, e non si ferma per quanto lo si colpisca. Il suo vero nome è ancora un mistero.*

`l_immortale` · ♥ 120 · attacco 5 · difesa 0 · velocità 7 · xp 67 · elemento oscuro

| Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --- | --- | --- | --- | --- | --- |
| Non si ferma | un colpo pesante su uno solo | ×1.00 → 5 | sempre | sorteggio | — |

### Madre in Lacrime — livello 8, comune
*Piange lacrime di ossidiana per figli che non tornano, e non lascia avvicinare nessuno a quel dolore.*

`madre_in_lacrime` · ♥ 366 · attacco 23 · difesa 10 · velocità 6 · xp 30

| Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --- | --- | --- | --- | --- | --- |
| Lacrime di ossidiana | colpisce **tutta la squadra** | ×0.70 → 16 | sempre | sorteggio | — |
| Non avvicinarti | un colpo pesante su uno solo | ×1.50 → 35 | sempre | sorteggio | — |

### Teschio Errante — livello 8, comune
*Un teschio che galleggia basso sull'ossidiana, a scatti, come se cercasse ancora il corpo perduto.*

`teschio_errante` · ♥ 366 · attacco 23 · difesa 10 · velocità 6 · xp 30

| Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --- | --- | --- | --- | --- | --- |
| Carica a scatti | 2 colpi su bersagli a caso | ×0.65 → 15 a colpo (30 totali) | sempre | sorteggio | — |
| Sguardo vuoto | nessun danno: lascia addosso **Terrore** | — | sempre | sorteggio | 5 battute |

### Diabolo — livello 9, comune
*Un piccolo demone da baraccone, cresciuto storto tra le fiamme della Rocca.*

`diabolo` · ♥ 405 · attacco 26 · difesa 11 · velocità 7 · xp 35

| Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --- | --- | --- | --- | --- | --- |
| Forconata | 2 colpi su bersagli a caso | ×0.70 → 18 a colpo (36 totali) | sempre | sorteggio | — |
| Sberleffo | nessun danno: lascia addosso **Confusione** | — | sempre | sorteggio | 5 battute |

### Sadico — livello 9, comune
*Trova piacere nel dolore altrui, l'unico linguaggio che la Rocca gli ha insegnato.*

`sadico` · ♥ 405 · attacco 26 · difesa 11 · velocità 7 · xp 35

| Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --- | --- | --- | --- | --- | --- |
| Taglio lento | un colpo pesante su uno solo | ×1.20 → 31 | sempre | sorteggio | — |
| Infierisce | un colpo pesante su uno solo | ×1.90 → 49 | se qualcuno di voi è sotto il 40% | priorità 7 | 2 battute |

### Stigma — livello 9, comune
*Porta incisi sulla pelle i peccati di qualcun altro, marchiato da una colpa che non è la sua.*

`stigma` · ♥ 405 · attacco 26 · difesa 11 · velocità 7 · xp 35

| Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --- | --- | --- | --- | --- | --- |
| Colpa altrui | un colpo pesante su uno solo | ×1.45 → 38 | sempre | sorteggio | — |
| Marchio | nessun danno: lascia addosso **Veleno** | — | sempre | sorteggio | 4 battute |

### Abominio Marcio — livello 10, particolare
*Più corpi fusi insieme dal marciume, tenuti in piedi da qualcosa che non è più vita. Una delle tante forme che prende la maledizione della Rocca.*

`abominio_marcio` · ♥ 737 · attacco 34 · difesa 18 · velocità 9 · xp 86 · elemento veleno

| Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --- | --- | --- | --- | --- | --- |
| Sputo marcio | un colpo pesante su uno solo | ×1.30 → 44 | sempre | sorteggio | — |
| Abbraccio di carne | colpisce e **si nutre** (il 50% del danno torna a lei) | ×1.40 → 48 | sempre | sorteggio | — |
| Si ricuce | **si rimette in piedi** (+25% della vita massima) | — | sotto il 35% di vita | priorità 8 | 5 battute |

### Titano Zombie — livello 10, particolare
*La cosa più grande che Meridia abbia partorito dopo la fine. Si ricuce da solo, e non ha mai imparato a fermarsi.*

`titano_zombie` · ♥ 737 · attacco 34 · difesa 18 · velocità 9 · xp 86

| Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --- | --- | --- | --- | --- | --- |
| pugno_devastante | toglie **metà** della vita che ti resta | come il suo colpo normale | sempre | sorteggio | — |
| spazzata | colpisce **tutta la squadra** | **9 fisso** | sempre | sorteggio | — |

Ha anche **rigenerazione** (scritta a mano nei suoi dati, non nella tabella).

## Livelli 11-15 — la Rocca e la Casa

### Divoratore di Carcasse — livello 11, comune
*Vive sotto il grande ponte marcio, nutrendosi di ciò che il ponte stesso lascia cadere. La puzza lo tradisce molto prima che si mostri.*

`divoratore_di_carcasse` · ♥ 486 · attacco 32 · difesa 14 · velocità 9 · xp 43 · elemento veleno

| Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --- | --- | --- | --- | --- | --- |
| morso_multiplo | 2 colpi su bersagli a caso | **9 fisso** | sempre | sorteggio | — |
| Si ingozza | **si rimette in piedi** (+20% della vita massima) | — | sotto il 35% di vita | priorità 7 | 5 battute |

### Sacerdote Folle — livello 11, comune
*Officiava i sacrifici della Rocca molto prima che Jongo Dongo ne facesse un culto. Recita ancora le sue litanie, anche se non è rimasto nessuno a rispondergli.*

`sacerdote_folle` · ♥ 486 · attacco 32 · difesa 14 · velocità 9 · xp 43 · elemento oscuro

| Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --- | --- | --- | --- | --- | --- |
| litania_1 | un colpo pesante su uno solo | **14 fisso** | sempre | sorteggio | — |
| litania_2 | un colpo pesante su uno solo | **14 fisso** | sempre | sorteggio | — |
| litania_3 | un colpo pesante su uno solo | **14 fisso** | sempre | sorteggio | — |
| litania_4 | un colpo pesante su uno solo | **14 fisso** | sempre | sorteggio | — |
| richiamo_dei_teschi | chiama 1 × `teschio_errante` | — | sempre | sorteggio | — |
| Litania che rimargina | **si rimette in piedi** (+20% della vita massima) | — | sotto il 35% di vita | priorità 7 | 5 battute |

### Jongo Dongo — livello 12, fonte
*Un tempo signore di queste terre. Sacrificò raccolti e famiglie intere per la propria fortuna, e non si è mai pentito: la maledizione delle famiglie in lutto lo ha fatto marcire vivo, ma non lo ha fermato.*

`jongo_dongo` · ♥ 1857 · attacco 48 · difesa 30 · velocità 10 · xp 329 · elemento veleno

| Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --- | --- | --- | --- | --- | --- |
| colpo_marcio | un colpo pesante su uno solo | **18 fisso** | sempre | sorteggio | — |
| bastone_di_pietra_marcia | un colpo pesante su uno solo | **14 fisso** | sempre | sorteggio | — |
| grido_del_raccolto | colpisce **tutta la squadra** | **5 fisso** | sempre | sorteggio | — |
| sacrificio | uccide un suo alleato per farsi più forte | — | sempre | sorteggio | — |
| raccolto_di_carne | chiama 1 × `ghoul` | — | sempre | sorteggio | — |
| Maledizione di chi muore | colpisce **tutta la squadra** | ×1.00 → 48 | sotto il 25% di vita | priorità 7 | — |

Ha anche **mossa_soglia_hp** (scritta a mano nei suoi dati, non nella tabella).

### Donna Spinosa — livello 13, comune
*Cresciuta in una vasca con un cartellino che diceva un'altra cosa. Sta ferma finché non le passi accanto, e allora si ricorda di essere stata progettata.*

`donna_spinosa` · ♥ 568 · attacco 38 · difesa 17 · velocità 10 · xp 51 · elemento veleno

| Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --- | --- | --- | --- | --- | --- |
| spine_sottili | un colpo pesante su uno solo | **8 fisso** | sempre | sorteggio | — |
| Spine a tappeto | colpisce **tutta la squadra** | ×0.75 → 29 | sempre | sorteggio | — |

### Marionetta — livello 13, comune
*Legno, fili e un po' di rancore. Qualcuno la muoveva con affetto, una volta.*

`marionetta` · ♥ 568 · attacco 38 · difesa 17 · velocità 10 · xp 51 · elemento oscuro

| Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --- | --- | --- | --- | --- | --- |
| Colpo di legno | un colpo pesante su uno solo | ×1.45 → 55 | sempre | sorteggio | — |
| Fili che stringono | nessun danno: lascia addosso **Lentezza** | — | sempre | sorteggio | 4 battute |
| Si rimette i fili | **si rimette in piedi** (+20% della vita massima) | — | sotto il 30% di vita | priorità 7 | 6 battute |

### Jongo Dongo — livello 14, fonte
*Ormai non rimane altro di lui che un corpo marcito che si muove solo grazie a una volontà misteriosa.*

`jongo_dongo_risorto` · ♥ 2147 · attacco 56 · difesa 36 · velocità 12 · xp 384 · elemento veleno

| Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --- | --- | --- | --- | --- | --- |
| Mano marcia | un colpo pesante su uno solo | ×1.50 → 84 | sempre | sorteggio | — |
| Respiro di putredine | colpisce **tutta la squadra** | ×0.90 → 50 | sempre | sorteggio | — |
| Volonta' misteriosa | **si rimette in piedi** (+18% della vita massima) | — | sotto il 30% di vita | priorità 8 | 6 battute |

### Ombra del passato — livello 14, comune
*Un'ombra del passato, vive grazie ai sentimenti repressi di qualcuno che ricorda la persona da cui prende forma con sentimenti negativi.*

`ombra_del_passato` · ♥ 607 · attacco 41 · difesa 18 · velocità 10 · xp 55 · elemento oscuro

| Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --- | --- | --- | --- | --- | --- |
| Rinfaccia | un colpo pesante su uno solo | ×1.50 → 62 | sempre | sorteggio | — |
| Si nutre del rancore | colpisce e **si nutre** (il 60% del danno torna a lei) | ×1.20 → 49 | sotto il 50% di vita | priorità 5 | 3 battute |

### Un tenero ricordo — livello 15, fonte
*Una bambola cucita a mano, Non ha un bel aspetto ma sembra essere stata amata. Qualcosa di oscuro si annida tra le cuciture.*

`tenero_ricordo` · ♥ 6660 · attacco 27 · difesa 12 · velocità 13 · xp 411 · elemento oscuro

| Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --- | --- | --- | --- | --- | --- |
| spilli | un colpo pesante su uno solo | **14 fisso** | sempre | sorteggio | — |
| lamento | colpisce **tutta la squadra** | **9 fisso** | sempre | sorteggio | — |
| autolesione | si ferisce da sola, e la cosa vi pesa addosso | **5 fisso** | sempre | sorteggio | — |
| richiamo_marionette | chiama 1 × `marionetta` | — | sempre | sorteggio | — |
| Si ricuce le cuciture | **si rimette in piedi** (+15% della vita massima) | — | sotto il 25% di vita | priorità 6 | 6 battute |

Ha anche **frenesia** (scritta a mano nei suoi dati, non nella tabella).

### Volto sulla parete — livello 15, miniboss
*Quello che è rimasto della capofamiglia, cresciuto dentro la parete insieme a tutto il resto. Difende ancora i risultati di ricerche che non servono più a nessuno.*

`volto_sulla_parete` · ♥ 1733 · attacco 57 · difesa 32 · velocità 13 · xp 264 · elemento veleno

| Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --- | --- | --- | --- | --- | --- |
| radici_che_stringono | un colpo pesante su uno solo | **14 fisso** | sempre | sorteggio | — |
| sfogo_di_spore | colpisce **tutta la squadra** | **11 fisso** | sempre | sorteggio | — |
| Assorbe dalla parete | **si rimette in piedi** (+20% della vita massima) | — | sotto il 30% di vita | priorità 8 | 5 battute |

## Livelli 16 e oltre — le fonti

### L'ultimo spettacolo di Jerah — livello 18, fonte
*Un talento unico, forse 1 su 10milioni: il più grande spettacolo che il mondo abbia mai visto, una passione ardente, pericolosamente spenta... Il mondo intero arde, arde teatro del suo ultimo show.*

`jerah` · ♥ 2710 · attacco 74 · difesa 46 · velocità 14 · xp 488 · elemento fuoco

| Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --- | --- | --- | --- | --- | --- |
| gran_finale | colpisce **tutta la squadra** | **9 fisso** | sempre | sorteggio | — |
| incendia | ti dà fuoco (9 a battuta) | — | sempre | sorteggio | — |
| capote | si chiude (difesa +14 per 2 battute) | — | sempre | sorteggio | — |
| llamada | chiama 1 × `maschera_vuota` | — | sempre | sorteggio | — |
| Fiamma disperata | colpisce **tutta la squadra** | ×1.30 → 96 | sotto il 30% di vita | priorità 7 | 4 battute |
