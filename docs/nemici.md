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

### Cos'è una «battuta»

Non ci sono più i turni: ogni creatura ha una **ricarica** che scorre da sola, e quando
finisce quella creatura agisce. Una *battuta* è un suo ciclo di ricarica — «per 3 battute»
vuol dire **tre volte che tocca a lei**, non tre secondi e non tre tue mosse.

Il che vuol dire due cose che vale la pena avere in testa:

- **dura più a lungo su una creatura lenta.** La ricarica esce dalla velocità: un corazzato
  che si irrigidisce «per 3 battute» resta chiuso cinque o sei secondi buoni, un veloce che
  fa la stessa cosa poco più di due. È coerente — sono anche tre sue azioni in tutti e due
  i casi — ma a schermo si sente come una durata diversa;
- **il conto scala all'inizio del suo turno, non alla fine.** Una mossa lanciata alla sua
  battuta N protegge per tutta la N, la N+1 e la N+2, e all'inizio della N+3 è già scaduta:
  copre le sue due azioni successive e tutto il tempo che ci sta in mezzo, compreso quello
  in cui la stai colpendo tu.

Lo stesso potenziamento **non si somma con se stesso**: rifarlo rinnova la durata, non
raddoppia il numero. Due mosse *diverse* che alzano la stessa statistica si sommano ancora.

## Il tecno log

Di ogni creatura c'è una **scheda di specie** che lo Studio riempie a strati, uno per
volta: il primo studio dice chi è e da dove viene, il secondo com'è fatta, il terzo come si
comporta. In gioco si legge nel Bestiario; qui sotto c'è già tutta, perché è il documento
su cui si correggono i testi — e i testi non si correggono tre righe per volta.

La **Filogenesi** è il campo che Bru ha chiesto per primo: il corpo d'origine. A Meridia la
stessa infezione ha preso corpi diversi, e la scheda lo dice — il Cittadino e l'Infetto
Rapido sono tutti e due *umana*, il Divoratore di Carcasse è *ferina*, la Robo Pattuglia è
*meccanica*. **Denominazione**, **Areale** e **Metamorfosi** non sono scritti a mano: il
nome è quello della creatura, l'areale esce da dove compare davvero nei file delle zone, e
la metamorfosi dice «osservata» solo se hai incontrato anche la forma in cui si trasforma.

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

**Tecno log**

| Campo | Rilevamento |
| --- | --- |
| Denominazione | Goblin Tipico |
| Classificazione | forma vulgaris — rango infra-specifico |
| Filogenesi | ferina |
| Areale | Il pianeta del risveglio |
| Fenotipo | degenerato |
| Stadio | I |
| Morfologia | Un metro e poco piu'. Scheletro leggero, spalle asimmetriche, mani sproporzionate rispetto agli avambracci. Tegumento verdastro, spelacchiato a chiazze, spesso escoriato sulle nocche. |
| Fisiologia | Metabolismo rapido e disordinato, temperatura sopra la norma. Non regge il digiuno e non regge i colpi: cede al primo trauma serio. |
| Habitus | Sta curvo anche da fermo, con il peso su una gamba sola. Guarda in basso e di lato, mai davanti. |
| Etologia | Attacca solo se convinto di essere in vantaggio numerico, e cambia idea appena non lo e' piu'. Raccoglie a terra qualunque cosa possa essere impugnata. |
| Metamorfosi | non osservata |
| Ecologia | Vive ai margini di gruppi piu' grandi, dai quali viene tollerato e derubato. Non forma legami stabili. |

*Studi necessari per la pagina intera: 3.*

### Slime Infimo — livello 1, comune
*Una pozza gelatinosa che si crede un mostro. Ci vuole più tempo a notarlo che a batterlo.*

`slime_infimo` · ♥ 86 · attacco 6 · difesa 1 · velocità 2 · xp 2

| Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --- | --- | --- | --- | --- | --- |
| Bava appiccicosa | nessun danno: lascia addosso **Lentezza** | — | sempre | sorteggio | 4 battute |
| Si ricompone | **si rimette in piedi** (+30% della vita massima) | — | sotto il 40% di vita | priorità 6 | 4 battute |

**Tecno log**

| Campo | Rilevamento |
| --- | --- |
| Denominazione | Slime Infimo |
| Classificazione | forma vulgaris — rango infra-specifico |
| Filogenesi | indeterminata |
| Areale | Il pianeta del risveglio |
| Fenotipo | ibrido mutato |
| Stadio | I |
| Morfologia | Massa gelatinosa senza scheletro ne' organi distinguibili, volume variabile fra i venti e i quaranta litri. La superficie e' l'unica parte con una struttura: piu' densa, quasi una pelle. |
| Fisiologia | Non ha temperatura propria. Assorbe e rilascia acqua a seconda dell'ambiente; il danno che subisce si richiude da solo se gli si lascia il tempo. |
| Habitus | Nessuna postura: si accumula. Da fermo e' indistinguibile da una pozza. |
| Etologia | Reagisce alla vibrazione, non alla luce. Non insegue: aspetta, e si sposta di pochi centimetri per volta verso quello che si muove. |
| Metamorfosi | non osservata |
| Ecologia | Riempie gli avvallamenti e i sottoscala. Non compete con nessuno perche' non toglie niente a nessuno. |

*Studi necessari per la pagina intera: 3.*

### Tartaruga Innocente — livello 1, corazzato
*Un guscio enorme e un aspetto che mette paura. Non ha mai fatto del male a nessuno.*

`tartaruga_innocente` · ♥ 555 · attacco 0 · difesa 6 · velocità 2 · xp 2

| Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --- | --- | --- | --- | --- | --- |
| Si ritira nel guscio | alza la guardia | — | sempre | sorteggio | — |
| Dentro il guscio | **si rimette in piedi** (+15% della vita massima) | — | sotto il 50% di vita | priorità 6 | 4 battute |

**Tecno log**

| Campo | Rilevamento |
| --- | --- |
| Denominazione | Tartaruga Innocente |
| Classificazione | forma loricata — rango infra-specifico |
| Filogenesi | ferina |
| Areale | Il pianeta del risveglio |
| Fenotipo | ipertrofico |
| Stadio | II |
| Morfologia | Carapace di oltre due metri di diametro, cresciuto ben oltre le proporzioni dell'animale che lo porta. Il collo e gli arti sono rimasti quelli di un esemplare comune. |
| Fisiologia | Metabolismo lentissimo, temperatura costante. La resistenza al danno e' quasi interamente meccanica: il guscio. |
| Habitus | Si muove pochissimo e si ritira alla minima ombra. Da fuori sembra una minaccia; da dentro e' un animale spaventato. |
| Etologia | NON ATTACCA MAI. Non e' stato osservato un solo caso di aggressione, nemmeno sotto danno prolungato. Alza la difesa e aspetta che la cosa passi. |
| Metamorfosi | non osservata |
| Ecologia | Occupa lo spazio e non lo contende. Nessun predatore noto: nessuno ci guadagna abbastanza da insistere. |

*Studi necessari per la pagina intera: 3.*

### Infetto Rapido — livello 2, veloce
*Non tutti a Meridia sono diventati lenti. Questi corrono ancora, come se stessero ancora scappando da qualcosa.*

`infetto_rapido` · ♥ 94 · attacco 7 · difesa 0 · velocità 6 · xp 6

| Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --- | --- | --- | --- | --- | --- |
| Raffica di unghiate | 2 colpi su bersagli a caso | ×0.60 → 4 a colpo (8 totali) | sempre | sorteggio | — |

**Tecno log**

| Campo | Rilevamento |
| --- | --- |
| Denominazione | Infetto Rapido |
| Classificazione | forma agilis — rango infra-specifico |
| Filogenesi | umana |
| Areale | Meridia |
| Fenotipo | atrofico |
| Stadio | II |
| Morfologia | Corpo adulto ridotto: massa magra sotto la meta' della norma, tendini accorciati, mandibola prominente. La perdita di peso e' quello che l'ha reso veloce. |
| Fisiologia | Metabolismo acceso, temperatura alta, autonomia brevissima. Corre finche' regge e poi crolla, ma finche' regge non lo si stacca. |
| Habitus | Non sta mai in piedi del tutto: parte accovacciato. |
| Etologia | Insegue. E' l'unica forma di Meridia che insegue davvero, e lo fa a raffiche di colpi rapidi invece che con un colpo solo. |
| Metamorfosi | non osservata |
| Ecologia | Batte le strade laterali e i cortili. Le colonne di cittadini lo evitano. |

*Studi necessari per la pagina intera: 3.*

### Nuvola di Marciume — livello 2, veloce
*Un pezzo della coltre che copre Meridia, sceso più in basso degli altri. Non insegue nessuno: capita addosso.*

`nuvola_di_marciume` · ♥ 94 · attacco 7 · difesa 0 · velocità 6 · xp 6 · elemento veleno

| Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --- | --- | --- | --- | --- | --- |
| Capita addosso | colpisce **tutta la squadra** | ×0.55 → 4 | sempre | sorteggio | — |
| Spore | nessun danno: lascia addosso **Veleno** | — | sempre | sorteggio | 3 battute |

**Tecno log**

| Campo | Rilevamento |
| --- | --- |
| Denominazione | Nuvola di Marciume |
| Classificazione | forma nebulae |
| Filogenesi | indeterminata |
| Areale | Meridia |
| Fenotipo | ibrido mutato |
| Stadio | II |
| Morfologia | Nessun corpo solido: sospensione di particolato organico che mantiene coesione entro un raggio di due metri. Al centro si intravede materiale non identificato. |
| Fisiologia | Non ha organi. Corrode per contatto prolungato e non si puo' colpire in un punto solo: quello che si disperde rientra. |
| Habitus | Fluttua a mezzo metro da terra e scende quando l'aria si ferma. |
| Etologia | Non insegue nessuno: capita addosso. Rilascia spore che continuano a lavorare dopo che si e' allontanata. |
| Metamorfosi | non osservata |
| Ecologia | E' un pezzo della coltre che copre Meridia, sceso piu' in basso degli altri. Dove staziona, il resto non cresce. |

*Studi necessari per la pagina intera: 3.*

### Zombie Cittadino — livello 2, comune
*Era qualcuno, a Meridia, prima del coprifuoco. Ora cammina piano, verso niente in particolare, con tutti gli altri.*

`zombie_cittadino` · ♥ 125 · attacco 8 · difesa 2 · velocità 2 · xp 5

| Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --- | --- | --- | --- | --- | --- |
| Passo pesante | un colpo pesante su uno solo | ×1.20 → 10 | sempre | sorteggio | — |
| In mezzo agli altri | si chiude (difesa +2 per 3 battute) | — | con almeno 1 alleati in piedi | sorteggio | 4 battute |

**Tecno log**

| Campo | Rilevamento |
| --- | --- |
| Denominazione | Zombie Cittadino |
| Classificazione | forma vulgaris — rango infra-specifico |
| Filogenesi | umana |
| Areale | Meridia |
| Fenotipo | degenerato |
| Stadio | I |
| Morfologia | Adulto di Meridia, conservato quasi per intero. Vestiti ancora allacciati, scarpe ancora ai piedi. La decomposizione e' ferma a uno stadio che non progredisce. |
| Fisiologia | Metabolismo assente, temperatura ambientale. Non si nutre e non si consuma: quello che lo tiene in piedi non passa dallo stomaco. |
| Habitus | Cammina piano, in linea, con gli altri. Verso niente in particolare. |
| Etologia | Non insegue e non evita: procede. Diventa aggressivo solo a contatto, e allora colpisce con il peso, non con le mani. |
| Metamorfosi | non osservata |
| Ecologia | Si muove in colonne lungo le strade principali. Dove passa la colonna, le altre forme si fanno da parte. |

*Studi necessari per la pagina intera: 3.*

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

**Tecno log**

| Campo | Rilevamento |
| --- | --- |
| Denominazione | Fomentado |
| Classificazione | forma vulgaris — rango infra-specifico |
| Filogenesi | umana |
| Areale | Il Vuoto Ardente |
| Fenotipo | degenerato |
| Stadio | II |
| Morfologia | Corpo umano adulto, svuotato. Il volto non c'e' piu': al suo posto una superficie liscia che riflette il calore. Le mani conservano i calli del mestiere di prima. |
| Fisiologia | Temperatura costantemente sopra i sessanta gradi. Brucia dall'interno e non si spegne; il combustibile e' quello che era la sua passione. |
| Habitus | Cammina veloce e diritto, come chi e' in ritardo. Non si guarda intorno. |
| Etologia | Si avvicina fino al contatto e brucia. Sotto una certa soglia di danno rilascia tutto quello che le resta in una sola vampata. |
| Metamorfosi | non osservata |
| Ecologia | Non compete e non collabora: attraversa. Dove passa, quello che resta e' cenere fredda. |

*Studi necessari per la pagina intera: 3.*

### Zombie Mostruoso — livello 3, comune
*Qualcosa, in questo, ha continuato a crescere anche dopo la morte. Le braccia non sono più della stessa lunghezza.*

`zombie_mostruoso` · ♥ 164 · attacco 10 · difesa 3 · velocità 3 · xp 9

| Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --- | --- | --- | --- | --- | --- |
| Braccio lungo | un colpo pesante su uno solo | ×1.50 → 15 | sempre | sorteggio | — |

**Tecno log**

| Campo | Rilevamento |
| --- | --- |
| Denominazione | Zombie Mostruoso |
| Classificazione | forma vulgaris — rango infra-specifico |
| Filogenesi | umana |
| Areale | Meridia |
| Fenotipo | ipertrofico |
| Stadio | II |
| Morfologia | Corpo umano che ha continuato a crescere dopo la morte, in modo asimmetrico: un braccio arriva a terra, l'altro e' rimasto quello di prima. La gabbia toracica si e' aperta e richiusa male. |
| Fisiologia | Nessun metabolismo, ma una crescita attiva che non si ferma. La massa aumenta senza che entri nulla dall'esterno: e' il substrato stesso a moltiplicarsi. |
| Habitus | Sbilanciato in avanti, si trascina appoggiandosi al braccio lungo. |
| Etologia | Usa il braccio lungo per arrivare da fuori portata, ed e' l'unica cosa che sa fare. Non cambia mai approccio. |
| Metamorfosi | non osservata |
| Ecologia | Stessa origine del cittadino, esito diverso. La differenza fra i due non e' stata spiegata da nessuno. |

*Studi necessari per la pagina intera: 3.*

### Oppresso — livello 4, corazzato
*La ruggine ha preso il posto della pelle, sta ancora aspettando che il suo turno finisca...*

`comparsa_di_ruggine` · ♥ 277 · attacco 10 · difesa 13 · velocità 3 · xp 16

| Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --- | --- | --- | --- | --- | --- |
| Si irrigidisce | si chiude (difesa +3 per 3 battute) | — | sempre | sorteggio | 3 battute |
| Colpo di ruggine | colpisce e **apre la guardia** | ×1.00 → 10 | sempre | sorteggio | — |

**Tecno log**

| Campo | Rilevamento |
| --- | --- |
| Denominazione | Oppresso |
| Classificazione | forma loricata — rango infra-specifico |
| Filogenesi | umana |
| Areale | Lo Squarcio Industriale — Kizako Industries — Ala Dimenticata |
| Fenotipo | ibrido mutato |
| Stadio | II |
| Morfologia | Ossido metallico cresciuto al posto del derma, saldato all'osso in piu' punti. Le articolazioni si aprono a scatti e stridono. |
| Fisiologia | Metabolismo quasi fermo. Alta resistenza meccanica, nessuna capacita' di rigenerare: quello che si spezza resta spezzato. |
| Habitus | In piedi, immobile, con lo sguardo verso un punto che non c'e'. Sta ancora aspettando che il suo turno finisca. |
| Etologia | Reagisce solo a chi le passa davanti. Si irrigidisce prima di incassare, e cerca di aprire la guardia di chi ha di fronte. |
| Metamorfosi | non osservata |
| Ecologia | Presidia i corridoi di passaggio. Non si sposta dal reparto in cui e' stata assegnata. |

*Studi necessari per la pagina intera: 3.*

### El Muy Bonito — livello 4, particolare
*Una rara bellezza, un campione nella recita, ma il talento a volte può farti uscire fuori di testa.*

`giocoliere` · ♥ 340 · attacco 15 · difesa 7 · velocità 5 · xp 29 · elemento fuoco

| Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --- | --- | --- | --- | --- | --- |
| Torce in aria | 2 colpi su bersagli a caso | ×0.75 → 11 a colpo (22 totali) | sempre | sorteggio | — |
| Numero col fuoco | un colpo pesante su uno solo | ×1.60 → 24 | sempre | sorteggio | — |
| Gran finale | colpisce **tutta la squadra** | ×1.10 → 17 | sotto il 35% di vita | priorità 7 | — |

**Tecno log**

| Campo | Rilevamento |
| --- | --- |
| Denominazione | El Muy Bonito |
| Classificazione | forma aberrans — rango infra-specifico |
| Filogenesi | umana |
| Areale | Il Vuoto Ardente |
| Fenotipo | ibrido mutato |
| Stadio | II |
| Morfologia | Corpo adulto in buone condizioni apparenti, con il volto conservato meglio del resto. Le mani hanno acquisito una terza articolazione per dito. |
| Fisiologia | Temperatura elevata alle estremita'. Manipola il fuoco senza subirne il danno, ma la pelle sotto le mani e' ormai carbone. |
| Habitus | Sta in scena anche quando non c'e' scena: piedi in terza posizione, mento alto. |
| Etologia | Alterna colpi rapidi a un numero preparato. Ridotto male lo esegue comunque, e lo chiama gran finale. |
| Metamorfosi | non osservata |
| Ecologia | Non compete con le altre forme: le usa come pubblico. Il talento, a volte, ti fa uscire di testa. |

*Studi necessari per la pagina intera: 3.*

### Robo Pattuglia — livello 4, corazzato
*Una macchina di sorveglianza che non ha mai ricevuto l'ordine di smettere. Esegue un regolamento che nessuno applica più.*

`robo_pattuglia` · ♥ 277 · attacco 10 · difesa 13 · velocità 3 · xp 16 · elemento elettrico

| Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --- | --- | --- | --- | --- | --- |
| Scarica di avvertimento | un colpo pesante su uno solo | ×1.25 → 13 | sempre | sorteggio | — |
| Protocollo di contenimento | si chiude (difesa +3 per 3 battute) | — | sempre | sorteggio | 3 battute |
| Riparazione d'emergenza | **si rimette in piedi** (+22% della vita massima) | — | sotto il 35% di vita | priorità 8 | 5 battute |

**Tecno log**

| Campo | Rilevamento |
| --- | --- |
| Denominazione | Robo Pattuglia |
| Classificazione | unita' di sorveglianza |
| Filogenesi | meccanica |
| Areale | Lo Squarcio Industriale |
| Fenotipo | integro |
| Stadio | I |
| Morfologia | Telaio di sorveglianza su tre punti d'appoggio, piastre sovrapponibili, un solo sensore frontale. Nessuna alterazione: e' esattamente com'e' uscito. |
| Fisiologia | Alimentazione residua. Ripara i propri circuiti sotto una certa soglia di danno, e lo dice ad alta voce mentre lo fa. |
| Habitus | Percorre lo stesso tratto avanti e indietro, alla stessa velocita'. |
| Etologia | Avverte prima di colpire. Scarica solo dopo l'avviso, ed esegue un regolamento che nessuno applica piu'. |
| Metamorfosi | non osservata |
| Ecologia | Non fa parte della catena alimentare. E' arredamento che ha continuato a funzionare. |

*Studi necessari per la pagina intera: 3.*

### Capocantiere — livello 4, comune
*Gestire dieci... cento... no... mille operai insoddisfatti, non dà gratificazione alcuna.*

`voce_registrata` · ♥ 207 · attacco 13 · difesa 5 · velocità 4 · xp 13

| Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --- | --- | --- | --- | --- | --- |
| Richiamo disciplinare | un colpo pesante su uno solo | ×1.35 → 18 | sempre | sorteggio | — |
| Ordine urlato | nessun danno: lascia addosso **Demotivazione** | — | sempre | sorteggio | 4 battute |

**Tecno log**

| Campo | Rilevamento |
| --- | --- |
| Denominazione | Capocantiere |
| Classificazione | forma vocis |
| Filogenesi | artificiale |
| Areale | Lo Squarcio Industriale |
| Fenotipo | artefatto |
| Stadio | I |
| Morfologia | Non c'e' un corpo. L'emissione arriva dagli altoparlanti di reparto, e la posizione cambia con quelli. |
| Fisiologia | Nessuna fisiologia. Il danno che subisce e' il danno che subiscono i diffusori. |
| Habitus | Nessun portamento: solo un volume che sale. |
| Etologia | Ripete ordini a cui non risponde piu' nessuno. Sotto stress alza il tono e la squadra ne risente. |
| Metamorfosi | non osservata |
| Ecologia | Regola il comportamento delle altre forme del reparto, che si dispongono ancora secondo i suoi turni. |

*Studi necessari per la pagina intera: 3.*

### Emblema dell'oppressione — livello 5, comune
*Ferraglia tenuta insieme dallo spirito di un lavoratore che non è mai tornato a casa.*

`operaio_posseduto` · ♥ 245 · attacco 15 · difesa 6 · velocità 5 · xp 18

| Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --- | --- | --- | --- | --- | --- |
| Chiave inglese | un colpo pesante su uno solo | ×1.45 → 22 | sempre | sorteggio | — |
| Straordinario non pagato | si potenzia l'attacco (+3 per 3 battute) | — | sotto il 50% di vita | priorità 4 | 5 battute |

**Tecno log**

| Campo | Rilevamento |
| --- | --- |
| Denominazione | Emblema dell'oppressione |
| Classificazione | forma vulgaris — rango infra-specifico |
| Filogenesi | meccanica |
| Areale | Lo Squarcio Industriale — Kizako Industries — Ala Dimenticata |
| Fenotipo | ricomposto |
| Stadio | II |
| Morfologia | Ferraglia tenuta insieme in forma umanoide: due gambe, un braccio piu' lungo dell'altro, un attrezzo saldato al posto della mano. |
| Fisiologia | Nessun metabolismo. Si muove finche' regge la struttura, e la struttura regge parecchio. |
| Habitus | Sta come stava alla catena: leggermente piegato in avanti, il peso sul lato dell'attrezzo. |
| Etologia | Colpisce con la chiave inglese e insiste sempre sullo stesso punto. Quando e' ridotto male accelera invece di fermarsi. |
| Metamorfosi | non osservata |
| Ecologia | Occupa la sua postazione e la difende. Non insegue oltre il limite del suo reparto. |

*Studi necessari per la pagina intera: 3.*

### Operaio Sfruttato — livello 5, particolare
*Non difende i file: difende le ore che ci ha lasciato dentro. Toccarli è toccare l'unica cosa che gli è rimasta.*

`operaio_sfruttato` · ♥ 404 · attacco 18 · difesa 8 · velocità 5 · xp 39

| Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --- | --- | --- | --- | --- | --- |
| Difende le sue ore | si chiude (difesa +2 per 3 battute) | — | sempre | sorteggio | 3 battute |
| Esplosione di rabbia | un colpo pesante su uno solo | ×2.00 → 36 | sotto il 40% di vita | priorità 6 | 4 battute |

**Tecno log**

| Campo | Rilevamento |
| --- | --- |
| Denominazione | Operaio Sfruttato |
| Classificazione | forma aberrans — rango infra-specifico |
| Filogenesi | umana |
| Areale | Lo Squarcio Industriale |
| Fenotipo | degenerato |
| Stadio | II |
| Morfologia | Corpo adulto consumato: massa muscolare ridotta, mani ingrossate, colonna deformata dalla postura di vent'anni. |
| Fisiologia | Metabolismo al minimo, temperatura bassa. Regge molto piu' di quanto sembri, e non per costituzione. |
| Habitus | Sta davanti a quello che sorveglia, mai di fianco. Le braccia sono sempre fra te e i suoi fascicoli. |
| Etologia | Difende, non attacca, finche' non lo si porta allo stremo: sotto una certa soglia esce tutto quello che non ha mai detto. |
| Metamorfosi | non osservata |
| Ecologia | Legato a un luogo preciso e a niente altro. Non difende i file: difende le ore che ci ha lasciato dentro. |

*Studi necessari per la pagina intera: 3.*

### Orrore di Meridia — livello 5, particolare
*Più corpi che si sono trovati nello stesso posto al momento sbagliato, e non si sono più separati.*

`orrore_di_meridia` · ♥ 404 · attacco 18 · difesa 8 · velocità 5 · xp 39

| Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --- | --- | --- | --- | --- | --- |
| Bracciata | un colpo pesante su uno solo | ×1.40 → 25 | sempre | sorteggio | — |
| Morsi | 2 colpi su bersagli a caso | ×0.60 → 11 a colpo (22 totali) | sempre | sorteggio | — |
| Si ricompone | **si rimette in piedi** (+20% della vita massima) | — | sotto il 30% di vita | priorità 7 | 5 battute |

**Tecno log**

| Campo | Rilevamento |
| --- | --- |
| Denominazione | Orrore di Meridia |
| Classificazione | forma aberrans — rango infra-specifico |
| Filogenesi | umana |
| Areale | Meridia |
| Fenotipo | ricomposto |
| Stadio | III |
| Morfologia | Piu' corpi adulti fusi lungo i piani di contatto. Il numero esatto non e' determinabile: le teste rilevate variano fra tre e cinque a seconda dell'angolo. |
| Fisiologia | Metabolismi multipli non sincronizzati. Quando una parte cede, un'altra la sostituisce: si ricompone prendendo da se' stesso. |
| Habitus | Occupa piu' spazio di quanto serva. Si muove tutto insieme e in ritardo su se' stesso. |
| Etologia | Colpisce con tutte le braccia disponibili e morde con tutte le bocche disponibili. Ridotto male, si rimescola. |
| Metamorfosi | non osservata |
| Ecologia | Si sono trovati nello stesso posto al momento sbagliato, e non si sono piu' separati. Continua ad aggregare. |

*Studi necessari per la pagina intera: 3.*

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

**Tecno log**

| Campo | Rilevamento |
| --- | --- |
| Denominazione | Il Divoratore |
| Classificazione | forma vorax |
| Filogenesi | meccanica |
| Areale | Lo Squarcio Industriale |
| Fenotipo | artefatto |
| Stadio | III |
| Morfologia | Struttura cilindrica con apertura anteriore continua. Interno rivestito di lame contrapposte che ruotano in fasi alternate. |
| Fisiologia | Consuma quello che ingerisce, e non distingue fra vivo e morto. Quello che toglie non lo disperde: lo trattiene. |
| Habitus | Avanza in linea retta. Non gira: si riposiziona. |
| Etologia | Aspira quello che ha davanti e mastica. Sotto danno accelera l'aspirazione invece di ritirarsi. |
| Metamorfosi | non osservata |
| Ecologia | In cima alla catena del reparto per assenza di concorrenza. Non ha predatori perche' non ha nulla che valga la pena mangiare. |

*Studi necessari per la pagina intera: 3.*

### Ferraglia Urlante — livello 6, corazzato
*Una montagna di rottami saldati dal dolore. Sembra di sentire le urla di una protesta.*

`ferraglia_urlante` · ♥ 381 · attacco 14 · difesa 18 · velocità 4 · xp 26

| Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --- | --- | --- | --- | --- | --- |
| Valanga di rottami | colpisce **tutta la squadra** | ×0.85 → 12 | sempre | sorteggio | — |
| Urlo di lamiera | nessun danno: lascia addosso **Terrore** | — | sempre | sorteggio | 5 battute |
| Si ricompatta | **si rimette in piedi** (+20% della vita massima) | — | sotto il 30% di vita | priorità 7 | 6 battute |

**Tecno log**

| Campo | Rilevamento |
| --- | --- |
| Denominazione | Ferraglia Urlante |
| Classificazione | forma loricata — rango infra-specifico |
| Filogenesi | meccanica |
| Areale | Kizako Industries — Ala Dimenticata |
| Fenotipo | ricomposto |
| Stadio | III |
| Morfologia | Ammasso di rottami di piu' provenienze, saldati da un calore che non e' quello di una fornace. Nessuna simmetria, nessun fronte riconoscibile. |
| Fisiologia | Nessun metabolismo. Alta inerzia: si muove poco ma quello che si muove pesa. Riprende forma raccogliendo da terra quello che ha perso. |
| Habitus | Non ha portamento. Occupa. |
| Etologia | Si sposta di un metro e quel metro basta. L'emissione sonora che la accompagna induce panico misurabile a distanza. |
| Metamorfosi | non osservata |
| Ecologia | Cresce a spese del reparto: ogni pezzo che si stacca da una macchina prima o poi finisce addosso a lei. |

*Studi necessari per la pagina intera: 3.*

### Un goblin terribilmente arrabbiato — livello 6, fonte
*Non è mai stato bello, forte o rispettato, nemmeno tra i suoi. Il fattore di disallineamento gli ha dato l'unica cosa che gli mancava: qualcuno che lo temesse.*

`goblin_arrabbiato` · ♥ 1125 · attacco 25 · difesa 14 · velocità 6 · xp 152

| Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --- | --- | --- | --- | --- | --- |
| Richiamo dei suoi simili | chiama 1 × `goblin_tipico` | — | sempre | sorteggio | — |
| Furia di un goblin | un colpo pesante su uno solo | ×1.30 → 33 | sempre | sorteggio | — |
| Pugno del vile | un colpo pesante su uno solo | ×1.20 → 30 | sempre | sorteggio | — |
| Capriccio del goblin | si potenzia l'attacco (+9 per 3 battute) | — | sempre | sorteggio | — |
| Cattiveria innata | 3 colpi su bersagli a caso | ×0.50 → 13 a colpo (39 totali) | sempre | sorteggio | — |

Ha anche **mossa_disperazione** (scritta a mano nei suoi dati, non nella tabella).

**Tecno log**

| Campo | Rilevamento |
| --- | --- |
| Denominazione | Un goblin terribilmente arrabbiato |
| Classificazione | forma princeps — rango infra-specifico |
| Filogenesi | ferina |
| Areale | Il pianeta del risveglio |
| Fenotipo | ipertrofico |
| Stadio | III |
| Morfologia | Stessa specie del comune, portata a due volte e mezzo la taglia. La crescita e' avvenuta in fretta e male: le articolazioni non hanno tenuto il passo, le spalle sono piu' alte del collo. |
| Fisiologia | Metabolismo bruciato, temperatura alta e instabile. Regge una quantita' di danno che nel comune sarebbe letale tre volte. |
| Habitus | Non sta mai fermo. Anche a riposo continua a spostare il peso da un piede all'altro. |
| Etologia | Chiama i suoi simili e li usa come schermo. Sotto sforzo si potenzia con scatti d'ira che non sembrano diretti a nessuno in particolare. |
| Metamorfosi | non osservata |
| Ecologia | Ha preso il posto di un capobranco che non c'era. Il disallineamento gli ha dato l'unica cosa che gli mancava: qualcuno che lo temesse. |

*Studi necessari per la pagina intera: 3.*

### Ghoul — livello 8, comune
*Carne marcia tenuta insieme dalla fame e da poco altro. Uno dei tanti che la Rocca di Ossidiana non ha mai lasciato andare.*

`ghoul` · ♥ 366 · attacco 23 · difesa 10 · velocità 6 · xp 30

| Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --- | --- | --- | --- | --- | --- |
| Morso famelico | colpisce e **si nutre** (il 50% del danno torna a lei) | ×1.20 → 28 | sempre | sorteggio | — |
| Artigliata | un colpo pesante su uno solo | ×1.45 → 33 | sempre | sorteggio | — |

**Tecno log**

| Campo | Rilevamento |
| --- | --- |
| Denominazione | Ghoul |
| Classificazione | forma vulgaris — rango infra-specifico |
| Filogenesi | umana |
| Areale | Cunicoli sotterranei di Jondoh |
| Fenotipo | degenerato |
| Stadio | II |
| Morfologia | Corpo adulto scarnificato, tenuto insieme da tessuto connettivo indurito. Le unghie sono l'unica struttura cresciuta dopo la morte, e sono cresciute molto. |
| Fisiologia | Non digerisce: assorbe. Quello che toglie a un altro corpo lo rimette sul proprio, e si vede a occhio nudo. |
| Habitus | Curvo, con le mani sempre davanti all'altezza del petto. |
| Etologia | Morde e non lascia andare. Alterna il morso alla sciabolata di unghie a seconda della distanza. |
| Metamorfosi | non osservata |
| Ecologia | La forma piu' diffusa della Rocca. Uno dei tanti che Jondoh non ha mai lasciato andare. |

*Studi necessari per la pagina intera: 3.*

### ??? — livello 8, particolare
*Qualcosa che cammina nella cripta, e non si ferma per quanto lo si colpisca. Il suo vero nome è ancora un mistero.*

`l_immortale` · ♥ 120 · attacco 5 · difesa 0 · velocità 7 · xp 67 · elemento oscuro

| Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --- | --- | --- | --- | --- | --- |
| Non si ferma | un colpo pesante su uno solo | ×1.00 → 5 | sempre | sorteggio | — |

**Tecno log**

| Campo | Rilevamento |
| --- | --- |
| Denominazione | ??? |
| Classificazione | non classificabile |
| Filogenesi | indeterminata |
| Areale | Cunicoli sotterranei di Jondoh |
| Fenotipo | integro |
| Stadio | III |
| Morfologia | Umanoide, statura media, avvolto. Nessuna parte del corpo e' stata osservata direttamente, e nessuno strumento ha restituito una misura stabile. |
| Fisiologia | Il danno non lo ferma. E' stato colpito fino alla distruzione apparente in undici occasioni, e in undici occasioni ha ripreso a camminare. |
| Habitus | Cammina. Non e' veloce, e non gli serve esserlo. |
| Etologia | Colpisce piano e senza variare. Non insegue oltre la cripta, ma dentro la cripta non si ferma mai. |
| Metamorfosi | non osservata |
| Ecologia | Non ha posto nella catena: nessuna forma della Rocca lo tocca e lui non tocca loro. Il suo vero nome e' ancora un mistero. |

*Studi necessari per la pagina intera: 3.*

### Madre in Lacrime — livello 8, comune
*Piange lacrime di ossidiana per figli che non tornano, e non lascia avvicinare nessuno a quel dolore.*

`madre_in_lacrime` · ♥ 366 · attacco 23 · difesa 10 · velocità 6 · xp 30

| Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --- | --- | --- | --- | --- | --- |
| Lacrime di ossidiana | colpisce **tutta la squadra** | ×0.70 → 16 | sempre | sorteggio | — |
| Non avvicinarti | un colpo pesante su uno solo | ×1.50 → 35 | sempre | sorteggio | — |

**Tecno log**

| Campo | Rilevamento |
| --- | --- |
| Denominazione | Madre in Lacrime |
| Classificazione | forma vulgaris — rango infra-specifico |
| Filogenesi | umana |
| Areale | Cunicoli sotterranei di Jondoh |
| Fenotipo | ibrido mutato |
| Stadio | II |
| Morfologia | Corpo adulto femminile con inclusioni di ossidiana lungo gli zigomi e il collo. Le lacrime sono vetro nero e non si fermano. |
| Fisiologia | Produzione continua di materiale minerale a partire dal proprio tessuto. Si sta consumando per farlo, e non smette. |
| Habitus | Sta chinata su qualcosa che non c'e', e non lascia avvicinare. |
| Etologia | Colpisce chi si avvicina, e il pianto raggiunge tutti. Non attacca per prima se si resta lontani. |
| Metamorfosi | non osservata |
| Ecologia | Non contende niente e non si sposta. Piange figli che non tornano, e la Rocca la lascia in pace. |

*Studi necessari per la pagina intera: 3.*

### Teschio Errante — livello 8, comune
*Un teschio che galleggia basso sull'ossidiana, a scatti, come se cercasse ancora il corpo perduto.*

`teschio_errante` · ♥ 366 · attacco 23 · difesa 10 · velocità 6 · xp 30

| Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --- | --- | --- | --- | --- | --- |
| Carica a scatti | 2 colpi su bersagli a caso | ×0.65 → 15 a colpo (30 totali) | sempre | sorteggio | — |
| Sguardo vuoto | nessun danno: lascia addosso **Terrore** | — | sempre | sorteggio | 5 battute |

**Tecno log**

| Campo | Rilevamento |
| --- | --- |
| Denominazione | Teschio Errante |
| Classificazione | forma capitis |
| Filogenesi | umana |
| Areale | Cunicoli sotterranei di Jondoh |
| Fenotipo | atrofico |
| Stadio | III |
| Morfologia | Solo il cranio, senza mandibola in un terzo dei casi rilevati. Nessun corpo, nessun collegamento visibile a una massa che lo sostenga. |
| Fisiologia | Nessun metabolismo. Si mantiene a mezzo metro dall'ossidiana e non scende. Il danno strutturale e' l'unico che conta. |
| Habitus | Si sposta a scatti, come una fotografia che si muove male. |
| Etologia | Carica ripetuta a distanza breve. L'osservazione prolungata delle orbite produce panico misurabile. |
| Metamorfosi | non osservata |
| Ecologia | Cerca ancora il corpo perduto. Segue chi ne ha uno. |

*Studi necessari per la pagina intera: 3.*

### Diabolo — livello 9, comune
*Un piccolo demone da baraccone, cresciuto storto tra le fiamme della Rocca.*

`diabolo` · ♥ 405 · attacco 26 · difesa 11 · velocità 7 · xp 35

| Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --- | --- | --- | --- | --- | --- |
| Forconata | 2 colpi su bersagli a caso | ×0.70 → 18 a colpo (36 totali) | sempre | sorteggio | — |
| Sberleffo | nessun danno: lascia addosso **Confusione** | — | sempre | sorteggio | 5 battute |

**Tecno log**

| Campo | Rilevamento |
| --- | --- |
| Denominazione | Diabolo |
| Classificazione | forma vulgaris — rango infra-specifico |
| Filogenesi | ferina |
| Areale | Cunicoli sotterranei di Jondoh |
| Fenotipo | ibrido mutato |
| Stadio | I |
| Morfologia | Ottanta centimetri, bipede, corna corte e ricurve, coda prensile. Le proporzioni sono da cucciolo, l'eta' stimata no. |
| Fisiologia | Metabolismo rapido, temperatura alta. Regge poco ma si riprende in fretta. |
| Habitus | Non sta fermo un secondo e ti gira intorno mentre parli. |
| Etologia | Due colpi bassi dati con troppo entusiasmo, e una presa in giro che manda le persone fuori bersaglio. |
| Metamorfosi | non osservata |
| Ecologia | Cresciuto storto fra le fiamme della Rocca. Segue le forme piu' grandi e ne raccoglie gli scarti. |

*Studi necessari per la pagina intera: 3.*

### Sadico — livello 9, comune
*Trova piacere nel dolore altrui, l'unico linguaggio che la Rocca gli ha insegnato.*

`sadico` · ♥ 405 · attacco 26 · difesa 11 · velocità 7 · xp 35

| Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --- | --- | --- | --- | --- | --- |
| Taglio lento | un colpo pesante su uno solo | ×1.20 → 31 | sempre | sorteggio | — |
| Infierisce | un colpo pesante su uno solo | ×1.90 → 49 | se qualcuno di voi è sotto il 40% | priorità 7 | 2 battute |

**Tecno log**

| Campo | Rilevamento |
| --- | --- |
| Denominazione | Sadico |
| Classificazione | forma vulgaris — rango infra-specifico |
| Filogenesi | umana |
| Areale | Cunicoli sotterranei di Jondoh |
| Fenotipo | integro |
| Stadio | II |
| Morfologia | Corpo adulto senza alterazioni fisiche rilevanti. E' l'unico caso in cui la deformazione non e' del corpo. |
| Fisiologia | Fisiologia nella norma. Nessuna resistenza particolare: e' pericoloso per come sceglie, non per come e' fatto. |
| Habitus | Si muove con calma, e la calma e' la parte peggiore. |
| Etologia | Taglia piano finche' hai da perdere. Si china su chi sta gia' male, e quello e' il momento in cui colpisce forte. |
| Metamorfosi | non osservata |
| Ecologia | Il dolore altrui e' l'unico linguaggio che la Rocca gli ha insegnato. Le altre forme lo evitano. |

*Studi necessari per la pagina intera: 3.*

### Stigma — livello 9, comune
*Porta incisi sulla pelle i peccati di qualcun altro, marchiato da una colpa che non è la sua.*

`stigma` · ♥ 405 · attacco 26 · difesa 11 · velocità 7 · xp 35

| Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --- | --- | --- | --- | --- | --- |
| Colpa altrui | un colpo pesante su uno solo | ×1.45 → 38 | sempre | sorteggio | — |
| Marchio | nessun danno: lascia addosso **Veleno** | — | sempre | sorteggio | 4 battute |

**Tecno log**

| Campo | Rilevamento |
| --- | --- |
| Denominazione | Stigma |
| Classificazione | forma vulgaris — rango infra-specifico |
| Filogenesi | umana |
| Areale | Cunicoli sotterranei di Jondoh |
| Fenotipo | degenerato |
| Stadio | II |
| Morfologia | Adulto con incisioni profonde su tutta la superficie dorsale, disposte in ordine leggibile. Le incisioni non guariscono e non sanguinano. |
| Fisiologia | Metabolismo rallentato. Il segno che lascia addosso continua a lavorare da solo per un tempo lungo. |
| Habitus | Sta dritto e si lascia guardare. E' l'unica cosa che gli e' rimasta. |
| Etologia | Colpisce e marchia. Il marchio e' la parte che conta: il colpo e' un pretesto. |
| Metamorfosi | non osservata |
| Ecologia | Porta i peccati di qualcun altro. Chi glieli ha incisi non e' mai stato identificato. |

*Studi necessari per la pagina intera: 3.*

### Abominio Marcio — livello 10, particolare
*Più corpi fusi insieme dal marciume, tenuti in piedi da qualcosa che non è più vita. Una delle tante forme che prende la maledizione della Rocca.*

`abominio_marcio` · ♥ 737 · attacco 34 · difesa 18 · velocità 9 · xp 86 · elemento veleno

| Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --- | --- | --- | --- | --- | --- |
| Sputo marcio | un colpo pesante su uno solo | ×1.30 → 44 | sempre | sorteggio | — |
| Abbraccio di carne | colpisce e **si nutre** (il 50% del danno torna a lei) | ×1.40 → 48 | sempre | sorteggio | — |
| Si ricuce | **si rimette in piedi** (+25% della vita massima) | — | sotto il 35% di vita | priorità 8 | 5 battute |

**Tecno log**

| Campo | Rilevamento |
| --- | --- |
| Denominazione | Abominio Marcio |
| Classificazione | forma aberrans — rango infra-specifico |
| Filogenesi | indeterminata |
| Areale | — non ancora rilevato |
| Fenotipo | ricomposto |
| Stadio | III |
| Morfologia | Piu' corpi fusi dal marciume, di specie diverse: sono stati riconosciuti segmenti umani e segmenti animali nello stesso soggetto. |
| Fisiologia | Fermentazione attiva. Si ricuce da solo, e quello che ti toglie se lo rimette addosso. Emette continuamente materiale volatile tossico. |
| Habitus | Occupa lo spazio in altezza piu' che in larghezza. Ondeggia. |
| Etologia | Sputo a distanza, presa a contatto, e sotto pressione si rimescola e riparte. |
| Metamorfosi | non osservata |
| Ecologia | Una delle tante forme che prende la maledizione della Rocca. Continua ad aggregare quello che trova. |

*Studi necessari per la pagina intera: 3.*

### Titano Zombie — livello 10, particolare
*La cosa più grande che Meridia abbia partorito dopo la fine. Si ricuce da solo, e non ha mai imparato a fermarsi.*

`titano_zombie` · ♥ 737 · attacco 34 · difesa 18 · velocità 9 · xp 86

| Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --- | --- | --- | --- | --- | --- |
| Pugno devastante | toglie **metà** della vita che ti resta | come il suo colpo normale | sempre | sorteggio | — |
| Spazzata | colpisce **tutta la squadra** | ×0.70 → 24 | sempre | sorteggio | — |

Ha anche **rigenerazione** (scritta a mano nei suoi dati, non nella tabella).

**Tecno log**

| Campo | Rilevamento |
| --- | --- |
| Denominazione | Titano Zombie |
| Classificazione | forma aberrans — rango infra-specifico |
| Filogenesi | umana |
| Areale | Meridia |
| Fenotipo | ipertrofico |
| Stadio | III |
| Morfologia | Oltre quattro metri. Struttura ossea moltiplicata invece che ingrandita: doppie file di costole, articolazioni supplementari alle ginocchia. |
| Fisiologia | Rigenerazione attiva e continua: recupera meta' di quello che ha appena incassato. Sotto un certo numero di colpi una gamba cede, e allora si ferma a ricucirsi. |
| Habitus | In piedi, sempre. Si abbassa solo quando cede. |
| Etologia | Spazza l'area davanti a se' e chiude la distanza con un colpo che toglie meta' di quello che ti resta. Non ha imparato a fermarsi. |
| Metamorfosi | non osservata |
| Ecologia | La cosa piu' grande che Meridia abbia partorito dopo la fine. Le altre forme non le si avvicinano. |

*Studi necessari per la pagina intera: 3.*

## Livelli 11-15 — la Rocca e la Casa

### Divoratore di Carcasse — livello 11, comune
*Vive sotto il grande ponte marcio, nutrendosi di ciò che il ponte stesso lascia cadere. La puzza lo tradisce molto prima che si mostri.*

`divoratore_di_carcasse` · ♥ 486 · attacco 32 · difesa 14 · velocità 9 · xp 43 · elemento veleno

| Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --- | --- | --- | --- | --- | --- |
| Morso multiplo | 2 colpi su bersagli a caso | ×0.55 → 18 a colpo (36 totali) | sempre | sorteggio | — |
| Si ingozza | **si rimette in piedi** (+20% della vita massima) | — | sotto il 35% di vita | priorità 7 | 5 battute |

**Tecno log**

| Campo | Rilevamento |
| --- | --- |
| Denominazione | Divoratore di Carcasse |
| Classificazione | forma vulgaris — rango infra-specifico |
| Filogenesi | ferina |
| Areale | Cunicoli sotterranei di Jondoh |
| Fenotipo | ipertrofico |
| Stadio | II |
| Morfologia | Quadrupede di grossa taglia con cranio sproporzionato e dentatura a piu' file. Il collo e' piu' spesso della testa. |
| Fisiologia | Digestione rapidissima. Mangia quello che trova e ne ricava vita a vista d'occhio; sotto pressione mangia di piu', non di meno. |
| Habitus | Sta basso, con il muso a terra. La puzza lo tradisce molto prima che si mostri. |
| Etologia | Morsi rapidi e ripetuti. Ferito, si volta verso quello che il ponte ha lasciato cadere e si ingozza. |
| Metamorfosi | non osservata |
| Ecologia | Vive sotto il grande ponte marcio e ripulisce quello che cade. Nessuno gli contende quel posto. |

*Studi necessari per la pagina intera: 3.*

### Sacerdote Folle — livello 11, comune
*Officiava i sacrifici della Rocca molto prima che Jongo Dongo ne facesse un culto. Recita ancora le sue litanie, anche se non è rimasto nessuno a rispondergli.*

`sacerdote_folle` · ♥ 486 · attacco 32 · difesa 14 · velocità 9 · xp 43 · elemento oscuro

| Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --- | --- | --- | --- | --- | --- |
| Litania: «Per il viaggio!» | un colpo pesante su uno solo | ×1.20 → 38 | sempre | sorteggio | — |
| Litania: «Unisciti al raccolto!» | un colpo pesante su uno solo | ×1.20 → 38 | sempre | sorteggio | — |
| Litania: «Portatelo da me!» | un colpo pesante su uno solo | ×1.20 → 38 | sempre | sorteggio | — |
| Litania: «Non c'è altra strada!» | un colpo pesante su uno solo | ×1.20 → 38 | sempre | sorteggio | — |
| Richiamo dei teschi | chiama 1 × `teschio_errante` | — | sempre | sorteggio | — |
| Litania che rimargina | **si rimette in piedi** (+20% della vita massima) | — | sotto il 35% di vita | priorità 7 | 5 battute |

**Tecno log**

| Campo | Rilevamento |
| --- | --- |
| Denominazione | Sacerdote Folle |
| Classificazione | forma sacerdotis |
| Filogenesi | umana |
| Areale | Cunicoli sotterranei di Jondoh |
| Fenotipo | integro |
| Stadio | II |
| Morfologia | Adulto in paramenti, conservato. Nessuna alterazione fisica: la deformazione e' nel calendario che continua a seguire. |
| Fisiologia | Fisiologia nella norma, con una resistenza alla fatica non spiegabile. Le ferite si chiudono al ritmo della recita. |
| Habitus | In piedi, le braccia leggermente aperte, rivolto a un altare che non c'e' piu'. |
| Etologia | Alterna quattro colpi rituali e chiama teschi. Ridotto male, recita piu' in fretta e si rimargina. |
| Metamorfosi | non osservata |
| Ecologia | Officiava i sacrifici molto prima che Jongo Dongo ne facesse un culto. Non e' rimasto nessuno a rispondergli. |

*Studi necessari per la pagina intera: 3.*

### Jongo Dongo — livello 12, fonte
*Un tempo signore di queste terre. Sacrificò raccolti e famiglie intere per la propria fortuna, e non si è mai pentito: la maledizione delle famiglie in lutto lo ha fatto marcire vivo, ma non lo ha fermato.*

`jongo_dongo` · ♥ 1857 · attacco 48 · difesa 30 · velocità 10 · xp 329 · elemento veleno

| Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --- | --- | --- | --- | --- | --- |
| Colpo marcio | un colpo pesante su uno solo | ×1.40 → 67 | sempre | sorteggio | — |
| Bastone di pietra marcia | un colpo pesante su uno solo | ×1.15 → 55 | sempre | sorteggio | — |
| Grido del raccolto | colpisce **tutta la squadra** | ×0.70 → 34 | sempre | sorteggio | — |
| Un piccolo sacrificio | uccide un suo alleato per farsi più forte | — | sempre | sorteggio | — |
| Raccolto di carne | chiama 1 × `ghoul` | — | sempre | sorteggio | — |
| Maledizione di chi muore | colpisce **tutta la squadra** | ×1.00 → 48 | sotto il 25% di vita | priorità 7 | — |

Ha anche **mossa_soglia_hp** (scritta a mano nei suoi dati, non nella tabella).

**Tecno log**

| Campo | Rilevamento |
| --- | --- |
| Denominazione | Jongo Dongo |
| Classificazione | forma princeps — rango infra-specifico |
| Filogenesi | umana |
| Areale | Cunicoli sotterranei di Jondoh |
| Fenotipo | degenerato |
| Stadio | III |
| Morfologia | Adulto di corporatura importante, marcito in piedi. La pelle si e' aperta lungo le linee di tensione e non si e' richiusa; sotto, il tessuto e' ancora attivo. |
| Fisiologia | Putrefazione controllata: si consuma e continua. Emette veleno da tutta la superficie. Il calo di funzione non ha mai raggiunto l'arresto. |
| Habitus | Sta come stava da vivo, e questa e' la cosa che colpisce di piu' chi lo vede. |
| Etologia | Colpo d'artiglio, bastone, grido che raggiunge tutti. Chiama ghoul dall'ossidiana e ne sacrifica uno per farsi piu' forte. |
| Metamorfosi | non osservata |
| Ecologia | Era il signore di queste terre. Sacrifico' raccolti e famiglie intere per la propria fortuna, e non si e' mai pentito. |

*Studi necessari per la pagina intera: 3.*

### Donna Spinosa — livello 13, comune
*Cresciuta in una vasca con un cartellino che diceva un'altra cosa. Sta ferma finché non le passi accanto, e allora si ricorda di essere stata progettata.*

`donna_spinosa` · ♥ 568 · attacco 38 · difesa 17 · velocità 10 · xp 51 · elemento veleno

| Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --- | --- | --- | --- | --- | --- |
| Spine sottili | un colpo pesante su uno solo | ×1.20 → 46 | sempre | sorteggio | — |
| Spine a tappeto | colpisce **tutta la squadra** | ×0.75 → 29 | sempre | sorteggio | — |

**Tecno log**

| Campo | Rilevamento |
| --- | --- |
| Denominazione | Donna Spinosa |
| Classificazione | forma vulgaris — rango infra-specifico |
| Filogenesi | vegetale |
| Areale | La Casa Gigante |
| Fenotipo | ibrido mutato |
| Stadio | II |
| Morfologia | Struttura arborea su impianto umanoide. Le spine sono modificazioni dei rami secondari e coprono tutta la superficie dorsale. |
| Fisiologia | Fotosintesi residua piu' assorbimento diretto. Le spine rilasciano un composto che continua a lavorare dopo il contatto. |
| Habitus | Immobile finche' non le si passa accanto. Poi si ricorda di essere stata progettata. |
| Etologia | Attacco di contatto e apertura a raggiera quando ha piu' di un bersaglio vicino. Non insegue oltre due passi. |
| Metamorfosi | non osservata |
| Ecologia | Cresciuta in una vasca con un cartellino che diceva un'altra cosa. Quello che doveva essere non risulta agli atti. |

*Studi necessari per la pagina intera: 3.*

### Marionetta — livello 13, comune
*Legno, fili e un po' di rancore. Qualcuno la muoveva con affetto, una volta.*

`marionetta` · ♥ 568 · attacco 38 · difesa 17 · velocità 10 · xp 51 · elemento oscuro

| Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --- | --- | --- | --- | --- | --- |
| Colpo di legno | un colpo pesante su uno solo | ×1.45 → 55 | sempre | sorteggio | — |
| Fili che stringono | nessun danno: lascia addosso **Lentezza** | — | sempre | sorteggio | 4 battute |
| Si rimette i fili | **si rimette in piedi** (+20% della vita massima) | — | sotto il 30% di vita | priorità 7 | 6 battute |

**Tecno log**

| Campo | Rilevamento |
| --- | --- |
| Denominazione | Marionetta |
| Classificazione | forma vulgaris — rango infra-specifico |
| Filogenesi | artificiale |
| Areale | La Casa Gigante |
| Fenotipo | artefatto |
| Stadio | II |
| Morfologia | Legno di conifera, snodi in ottone, un metro e dieci. I fili non sono agganciati a nulla di visibile e restano tesi. |
| Fisiologia | Nessuna fisiologia. Il danno che conta e' quello agli snodi; il resto si puo' sostituire, e a quanto pare si sostituisce da solo. |
| Habitus | Sta appesa anche quando cammina: il peso non arriva mai del tutto ai piedi. |
| Etologia | Colpisce con il braccio ruotando sul perno, e usa i fili per rallentare chi le sta davanti. Ridotta male, se li riannoda addosso. |
| Metamorfosi | non osservata |
| Ecologia | Qualcuno la muoveva con affetto, una volta. Adesso i fili scendono dal soffitto e nessuno li tiene. |

*Studi necessari per la pagina intera: 3.*

### Jongo Dongo — livello 14, fonte
*Ormai non rimane altro di lui che un corpo marcito che si muove solo grazie a una volontà misteriosa.*

`jongo_dongo_risorto` · ♥ 2147 · attacco 56 · difesa 36 · velocità 12 · xp 384 · elemento veleno

| Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --- | --- | --- | --- | --- | --- |
| Mano marcia | un colpo pesante su uno solo | ×1.50 → 84 | sempre | sorteggio | — |
| Respiro di putredine | colpisce **tutta la squadra** | ×0.90 → 50 | sempre | sorteggio | — |
| Volonta' misteriosa | **si rimette in piedi** (+18% della vita massima) | — | sotto il 30% di vita | priorità 8 | 6 battute |

**Tecno log**

| Campo | Rilevamento |
| --- | --- |
| Denominazione | Jongo Dongo |
| Classificazione | forma princeps — rango infra-specifico |
| Filogenesi | umana |
| Areale | Cunicoli sotterranei di Jondoh |
| Fenotipo | ricomposto |
| Stadio | III |
| Morfologia | Lo stesso corpo, rimesso insieme dopo la distruzione. Le linee di frattura sono visibili e non corrispondono a come si era spezzato. |
| Fisiologia | Non c'e' piu' niente da consumare, e continua lo stesso. Sotto una certa soglia il corpo si tiene su per una ragione che non e' fisiologica. |
| Habitus | Piu' lento di prima, e piu' dritto. |
| Etologia | Mano marcia, respiro di putredine, e una tenuta che non dovrebbe esserci. |
| Metamorfosi | non osservata |
| Ecologia | Non rimane altro di lui che un corpo marcito che si muove grazie a una volonta' misteriosa. La volonta' non e' la sua. |

*Studi necessari per la pagina intera: 3.*

### Ombra del passato — livello 14, comune
*Un'ombra del passato, vive grazie ai sentimenti repressi di qualcuno che ricorda la persona da cui prende forma con sentimenti negativi.*

`ombra_del_passato` · ♥ 607 · attacco 41 · difesa 18 · velocità 10 · xp 55 · elemento oscuro

| Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --- | --- | --- | --- | --- | --- |
| Rinfaccia | un colpo pesante su uno solo | ×1.50 → 62 | sempre | sorteggio | — |
| Si nutre del rancore | colpisce e **si nutre** (il 60% del danno torna a lei) | ×1.20 → 49 | sotto il 50% di vita | priorità 5 | 3 battute |

**Tecno log**

| Campo | Rilevamento |
| --- | --- |
| Denominazione | Ombra del passato |
| Classificazione | forma umbrae |
| Filogenesi | indeterminata |
| Areale | La Casa Gigante |
| Fenotipo | artefatto |
| Stadio | III |
| Morfologia | Nessuna massa misurabile. La sagoma corrisponde a una persona precisa, diversa per ogni osservatore, e i contorni sono piu' netti dove il ricordo e' piu' recente. |
| Fisiologia | Non ha corpo da danneggiare. Si consolida in proporzione al rancore che le si porta, e si nutre di quello che toglie. |
| Habitus | Sta ferma a distanza di conversazione. Non si avvicina mai piu' di cosi'. |
| Etologia | Parla prima di colpire, e quello che dice e' vero. Sotto pressione smette di parlare e comincia a prendere. |
| Metamorfosi | non osservata |
| Ecologia | Vive dei sentimenti repressi di chi la incontra. Senza qualcuno che ricordi, non c'e'. |

*Studi necessari per la pagina intera: 3.*

### Un tenero ricordo — livello 15, fonte
*Una bambola cucita a mano, Non ha un bel aspetto ma sembra essere stata amata. Qualcosa di oscuro si annida tra le cuciture.*

`tenero_ricordo` · ♥ 6660 · attacco 27 · difesa 12 · velocità 13 · xp 411 · elemento oscuro

| Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --- | --- | --- | --- | --- | --- |
| Spilli | un colpo pesante su uno solo | ×1.30 → 35 | sempre | sorteggio | — |
| Lamento | colpisce **tutta la squadra** | ×0.70 → 19 | sempre | sorteggio | — |
| Si strappa una cucitura | si ferisce da sola, e la cosa vi pesa addosso | **5 fisso** | sempre | sorteggio | — |
| Richiamo delle marionette | chiama 1 × `marionetta` | — | sempre | sorteggio | — |
| Si ricuce le cuciture | **si rimette in piedi** (+15% della vita massima) | — | sotto il 25% di vita | priorità 6 | 6 battute |

Ha anche **frenesia** (scritta a mano nei suoi dati, non nella tabella).

**Tecno log**

| Campo | Rilevamento |
| --- | --- |
| Denominazione | Un tenero ricordo |
| Classificazione | forma amoris |
| Filogenesi | artificiale |
| Areale | La Casa Gigante |
| Fenotipo | artefatto |
| Stadio | III |
| Morfologia | Bambola di pezza cucita a mano, quaranta centimetri, imbottitura non identificata. Le cuciture sono state rifatte molte volte e da mani diverse. |
| Fisiologia | Nessuna fisiologia. Il filo rientra da solo nei buchi. Il contenuto dell'imbottitura non e' stato campionato: chi ci ha provato non ha finito. |
| Habitus | Sta seduta. Anche quando si muove, l'impressione e' che sia sempre seduta. |
| Etologia | Spilli, lamento, e un'autolesione che fa piu' male a chi guarda che a lei. Chiama marionette dal soffitto. |
| Metamorfosi | non osservata |
| Ecologia | Al centro della casa, e la casa le sta intorno. E' stata amata: e' questo il problema. |

*Studi necessari per la pagina intera: 3.*

### Volto sulla parete — livello 15, miniboss
*Quello che è rimasto della capofamiglia, cresciuto dentro la parete insieme a tutto il resto. Difende ancora i risultati di ricerche che non servono più a nessuno.*

`volto_sulla_parete` · ♥ 1733 · attacco 57 · difesa 32 · velocità 13 · xp 264 · elemento veleno

| Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --- | --- | --- | --- | --- | --- |
| Radici che stringono | un colpo pesante su uno solo | ×1.30 → 74 | sempre | sorteggio | — |
| Sfogo di spore | colpisce **tutta la squadra** | ×0.70 → 40 | sempre | sorteggio | — |
| Assorbe dalla parete | **si rimette in piedi** (+20% della vita massima) | — | sotto il 30% di vita | priorità 8 | 5 battute |

**Tecno log**

| Campo | Rilevamento |
| --- | --- |
| Denominazione | Volto sulla parete |
| Classificazione | forma dominans — rango infra-specifico |
| Filogenesi | umana |
| Areale | La Casa Gigante |
| Fenotipo | ricomposto |
| Stadio | III |
| Morfologia | Volto adulto femminile cresciuto dentro la parete portante, con propaggini radicali che percorrono l'intera stanza. La parete e' parte del soggetto. |
| Fisiologia | Metabolismo condiviso con la struttura dell'edificio: assorbe dalla parete quello che le viene tolto. Non e' separabile da dove sta. |
| Habitus | Non ha portamento: ha esposizione. Ti guarda da un'altezza che non hai scelto tu. |
| Etologia | Radici che stringono, e nube di spore quando ha piu' di un bersaglio. Sotto una certa soglia riprende dalla parete. |
| Metamorfosi | non osservata |
| Ecologia | Difende ancora i risultati di ricerche che non servono piu' a nessuno. Era la capofamiglia. |

*Studi necessari per la pagina intera: 3.*

## Livelli 16 e oltre — le fonti

### L'ultimo spettacolo di Jerah — livello 18, fonte
*Un talento unico, forse 1 su 10milioni: il più grande spettacolo che il mondo abbia mai visto, una passione ardente, pericolosamente spenta... Il mondo intero arde, arde teatro del suo ultimo show.*

`jerah` · ♥ 2710 · attacco 74 · difesa 46 · velocità 14 · xp 488 · elemento fuoco

| Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --- | --- | --- | --- | --- | --- |
| ¡Gran finale! | colpisce **tutta la squadra** | ×0.85 → 63 | sempre | sorteggio | — |
| ¡Vamos! | ti dà fuoco (9 a battuta) | — | sempre | sorteggio | — |
| Capote | si chiude (difesa +14 per 2 battute) | — | sempre | sorteggio | — |
| Llamada | chiama 1 × `maschera_vuota` | — | sempre | sorteggio | — |
| Fiamma disperata | colpisce **tutta la squadra** | ×1.30 → 96 | sotto il 30% di vita | priorità 7 | 4 battute |

**Tecno log**

| Campo | Rilevamento |
| --- | --- |
| Denominazione | L'ultimo spettacolo di Jerah |
| Classificazione | forma princeps — rango unico |
| Filogenesi | umana |
| Areale | Il Vuoto Ardente |
| Fenotipo | ibrido mutato |
| Stadio | III |
| Morfologia | Adulto, corporatura da ballerino, in abito di scena intatto. La combustione parte dall'interno e non ha ancora consumato il tessuto: e' la parte che non torna. |
| Fisiologia | Temperatura interna incompatibile con la vita, mantenuta stabile. Non brucia il suo combustibile: lo rinnova. |
| Habitus | In scena, sempre. Anche da solo, anche adesso. |
| Etologia | Muro di fiamme su tutta l'arena, vento ardente che appicca, schivate eleganti, e un Fomentado chiamato dal fumo. Alle strette, non chiude lo spettacolo. |
| Metamorfosi | non osservata |
| Ecologia | Il mondo intero arde, teatro del suo ultimo show. Le altre forme del Vuoto sono comparse. |

*Studi necessari per la pagina intera: 3.*
