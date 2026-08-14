# Il bestiario, e cosa sa fare

> **Generato dal gioco**, non scritto a mano: `./strumenti/nemici.sh`. I numeri qui sotto
> sono gli stessi che il combattimento usa in campo — escono dalla curva dei ruoli
> (`data/ruoli.json`) e dalle mosse dichiarate in `data/personaggi.json`. Se cambi un
> livello o una quota, rilancia lo strumento e questa pagina si aggiorna da sola.

> ⚠️ **Non correggere questo file: si riscrive da capo a ogni lancio.** Le fonti sono
> `data/personaggi.json` (mosse e frasi) e `data/tecnolog.json` (le schede di specie). Se ti
> torna comodo scrivere le correzioni qui sopra il testo vecchio, va benissimo — ma mandamele
> prima che qualcuno rilanci lo strumento, se no vanno perse.

## Come si leggono i numeri

- Le **statistiche** sono quelle della creatura al suo livello base. In gioco una creatura
  non scende mai troppo sotto il tuo livello (il disallineamento la tira su), e quando
  viene tirata su **rifà il conto sulla stessa curva** — quindi resta la stessa creatura,
  più grande, non una creatura diversa.
- Il **Valore** di una mossa si legge in due pezzi: il `×numero` è quante volte il suo colpo
  normale vale quella mossa, e dopo la freccia c'è lo stesso conto già fatto per questa
  creatura al suo livello. Qui sotto c'è un esempio intero, con tutto quello che succede al
  colpo prima che ti arrivi addosso. Una mossa con un numero fisso è un'eccezione
  dichiarata, e qui è segnata come tale.
- **Cosa fa** è una descrizione che lo strumento ricava dal tipo di mossa: serve a te per
  capirla in un colpo d'occhio, e **in gioco non compare da nessuna parte**. Il grassetto lì
  dentro è solo tipografia di questa pagina (evidenzia la parola che conta: il nome di uno
  stato, «tutta la squadra»). La frase che si legge davvero a schermo quando la mossa parte è
  un'altra cosa, ed è sotto ogni tabella, nel **Motto**: quella si può riscrivere parola per
  parola, ed è raccolta tutta insieme in fondo alla pagina.
- **Quando** dice a quale condizione la mossa esiste. Una mossa fuori condizione non entra
  nemmeno nel sorteggio: non è che «capita di rado», è che non c'è.
- **Scelta** dice che quella mossa non si sorteggia: se la condizione c'è, la creatura la
  *sceglie* (vince la priorità più alta). È lì che vive la sua testa.
- **Ricarica** è quante sue battute deve aspettare prima di rifarla.
- Ogni creatura ha **sei caselle**, anche quando ne usa tre: le libere sono il posto dove
  decidere cosa aggiungere. Una casella libera non è una mossa debole — non esiste: il
  sorteggio non la pesca, e la creatura tira il suo colpo normale come se non ci fosse.

### Da «×1.30 → 8» a quanto fa male davvero

Le due metà dicono la stessa cosa in due lingue.

**Goblin Tipico** ha attacco 6. La sua «Bastonata» vale `×1.30`, cioè 1.30 volte
il suo colpo normale: 6 × 1.30 fa **8**, ed è il numero dopo la freccia.

Il `×1.30` è la regola, e vale **a qualunque livello**: è una frazione dell'attacco che la
creatura ha *in quel momento*, quindi se lei cresce cresce anche il colpo. Il numero dopo
la freccia è solo lo stesso conto già fatto per questa creatura al suo livello base.

E soprattutto: quello è **il colpo che parte, non quello che ti arriva**. Prima di
toccarti passa da qui, in quest'ordine:

1. **se coglie in pieno** (critico) il colpo si moltiplica per **×1,5** e la tua difesa
   conta il 50% di meno;
2. **si toglie la tua difesa** — punto per punto, dal colpo;
3. **sotto il pavimento non si scende.** Se la tua difesa regge il colpo intero passa **1**:
   un graffio, mai zero, così un numero vola sempre. Se non lo regge, passa quel che resta
   ma **mai meno del 10% del colpo pieno** — la corazza riduce, non cancella;
4. **il tuo livello smorza il resto**: 2% in meno per ogni livello oltre il primo, fino a un
   massimo del 35%. Vale solo per la tua squadra: è il premio per aver giocato.

Quindi quel **8** è il colpo su un bersaglio nudo. Addosso a te arriva quasi sempre più
piccolo, e più grosso solo in due casi: quando coglie in pieno, e quando la creatura è
alle strette — la regola qui sotto, che la fa colpire più forte proprio mentre muore.

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

La **Filogenesi** è il corpo d'origine: a Meridia la stessa infezione ha preso corpi diversi,
e la scheda lo dice — il Cittadino e l'Infetto Rapido sono tutti e due *umana*, il Divoratore
di Carcasse è *ferina*, la Robo Pattuglia è *meccanica*, l'Oppresso è *rancore*.

La **Specie** è il nome della cosa, non un aggettivo su come è venuta: *Zombie*, *Slime*,
*Robot*. È il campo che lega creature diverse — Zombie Cittadino, Zombie Mostruoso e Orrore
di Meridia sono la stessa specie a tre **Stadi**, e i due campi si leggono insieme. La
**Classificazione** è il rango sulla scala di quella specie: base → variante base → superiore
→ avanzato → calamità, più le forme che non stanno su nessuna scala (onirica, speciale).

L'**Areale** è la **regione grande, non la stanza**: l'Oppresso lo incontri nello Squarcio
Industriale, ma la sua regione è *Geodos*, di cui lo Squarcio è solo una frattura. La
traduzione da zona a regione sta in un posto solo (`areale_per_zona`), così ribattezzare un
mondo è una riga; e una specie che vive dove il gioco non ti porta ancora può scriversi
l'areale a mano — lo Slime è su tre pianeti anche se lo incontri in una radura sola.

**Denominazione** e **Metamorfosi** non si scrivono mai a mano: il nome è quello della
creatura, e la metamorfosi dice «osservata» solo se hai incontrato anche la forma in cui si
trasforma. È il tuo registro, non un'enciclopedia.

## La regola che vale per tutte

Sotto il **30% della sua vita** una creatura è *alle strette*: colpisce il **30% in più**
e comincia a scegliere le mosse invece di sorteggiarle — chi sa curarsi si cura, chi ha un
ultimo colpo in canna lo tira. Non è scritto creatura per creatura: è una riga sola in
`data/ruoli.json`, così non può mancare a metà bestiario.

## Livelli 1-5 — il tutorial e le prime crepe

### Goblin Tipico — livello 1, comune
*Verde, spelacchiato, armato di un bastone che ha trovato per terra. Non ha mai vinto una rissa in vita sua.*

`goblin_tipico` · ♥ 86 · attacco 6 · difesa 1 · velocità 2 · xp 2

**Mosse: 3 su 6 caselle.**

| # | Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --: | --- | --- | --- | --- | --- | --- |
| 1 | Bastonata | un colpo pesante su uno solo | ×1.30 → 8 | sempre | sorteggio | — |
| 2 | Difesa Goblin! | alza la guardia | — | sotto il 35% di vita | priorità 5 | 2 battute |
| 3 | Ultima risorsa | si potenzia (attacco +3, difesa +2, velocita +2, per 3 battute) | — | sotto il 35% di vita | priorità 6 | 1 battute |
| 4 | — | *casella libera* | — | — | — | — |
| 5 | — | *casella libera* | — | — | — | — |
| 6 | — | *casella libera* | — | — | — | — |

**Motto** — quello che si legge in campo quando la mossa parte:

1. Il goblin stringe il bastone con tutte e due le mani e mena alla cieca.
2. «Difesa Goblin!» — e si copre la testa con le braccia.
3. Il goblin capisce che non c'è più niente da perdere, e smette di ragionare.

**Tecno log**

| Campo | Rilevamento |
| --- | --- |
| Denominazione | Goblin Tipico |
| Classificazione | rango base |
| Filogenesi | ferina |
| Areale | Pianure selvagge di Canuka Rei |
| Specie | Goblin |
| Stadio | I |
| Morfologia | Un metro e poco piu'. Scheletro leggero, spalle asimmetriche, mani sproporzionate rispetto agli avambracci. Tegumento verdastro, spelacchiato a chiazze, spesso escoriato sulle nocche. |
| Habitus | Sta curvo anche da fermo, con il peso su una gamba sola. Guarda in basso e di lato, mai davanti. |
| Metamorfosi | non osservata |
| Ecologia | Vive ai margini di gruppi piu' grandi, dai quali viene tollerato e derubato. Non forma legami stabili. |

*Studi necessari per la pagina intera: 3.*

### Slime Infimo — livello 1, comune
*Una pozza gelatinosa che si crede un mostro. Ci vuole più tempo a notarlo che a batterlo.*

`slime_infimo` · ♥ 86 · attacco 6 · difesa 1 · velocità 2 · xp 2

**Mosse: 3 su 6 caselle.**

| # | Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --: | --- | --- | --- | --- | --- | --- |
| 1 | Bava appiccicosa | nessun danno: lascia addosso **Lentezza** | — | sempre | sorteggio | 4 battute |
| 2 | Si ricompone | **si rimette in piedi** (+20% della vita massima) | — | sotto il 40% di vita | priorità 6 | 4 battute |
| 3 | Colpo dello slime | un colpo pesante su uno solo | ×1.30 → 8 | sempre | sorteggio | 2 battute |
| 4 | — | *casella libera* | — | — | — | — |
| 5 | — | *casella libera* | — | — | — | — |
| 6 | — | *casella libera* | — | — | — | — |

**Motto** — quello che si legge in campo quando la mossa parte:

1. Lo slime si allunga e lascia una bava che rallenta ogni movimento.
2. Lo slime si raccoglie su se stesso e torna tondo.
3. Si raccoglie tutto da una parte e ti si getta contro.

**Tecno log**

| Campo | Rilevamento |
| --- | --- |
| Denominazione | Slime Infimo |
| Classificazione | rango base |
| Filogenesi | indeterminata |
| Areale | Pianure selvagge di Canuka Rei · Gombok 2 · Profondità di Derios Nu |
| Specie | Slime |
| Stadio | I |
| Morfologia | Massa gelatinosa senza scheletro ne' organi distinguibili, volume variabile fra i venti e i quaranta litri. La superficie e' l'unica parte con una struttura: piu' densa, quasi una pelle. |
| Habitus | Nessuna postura: si accumula. Da fermo e' indistinguibile da una pozza. |
| Metamorfosi | non osservata |
| Ecologia | Riempie gli avvallamenti e i sottoscala. Non compete con nessuno perche' non toglie niente a nessuno. |

*Studi necessari per la pagina intera: 3.*

### Tartaruga Innocente — livello 1, corazzato
*Un guscio enorme e un aspetto che mette paura. Non ha mai fatto del male a nessuno.*

`tartaruga_innocente` · ♥ 555 · attacco 0 · difesa 6 · velocità 2 · xp 2

**Mosse: 2 su 6 caselle.**

| # | Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --: | --- | --- | --- | --- | --- | --- |
| 1 | Si ritira nel guscio | alza la guardia | — | sempre | sorteggio | — |
| 2 | Dentro il guscio | **si rimette in piedi** (+15% della vita massima) | — | sotto il 50% di vita | priorità 6 | 4 battute |
| 3 | — | *casella libera* | — | — | — | — |
| 4 | — | *casella libera* | — | — | — | — |
| 5 | — | *casella libera* | — | — | — | — |
| 6 | — | *casella libera* | — | — | — | — |

**Motto** — quello che si legge in campo quando la mossa parte:

1. La tartaruga si ritira nel guscio.
2. La tartaruga si tira dentro il guscio, e dentro il guscio si rimette.

**Tecno log**

| Campo | Rilevamento |
| --- | --- |
| Denominazione | Tartaruga Innocente |
| Classificazione | rango superiore |
| Filogenesi | ferina |
| Areale | Il pianeta del risveglio |
| Specie | Tartaruga |
| Stadio | II |
| Morfologia | Carapace di oltre due metri di diametro, cresciuto ben oltre le proporzioni dell'animale che lo porta. Il collo e gli arti sono rimasti quelli di un esemplare comune. |
| Habitus | Si muove pochissimo e si ritira alla minima ombra. Da fuori sembra una minaccia; da dentro e' un animale spaventato. |
| Metamorfosi | non osservata |
| Ecologia | Occupa lo spazio e non lo contende. Nessun predatore noto: nessuno ci guadagna abbastanza da insistere. |

*Studi necessari per la pagina intera: 3.*

### Infetto Rapido — livello 2, veloce
*Non tutti a Meridia sono diventati lenti. Questi corrono ancora, come se stessero ancora scappando da qualcosa.*

`infetto_rapido` · ♥ 94 · attacco 7 · difesa 0 · velocità 6 · xp 6

**Mosse: 1 su 6 caselle.**

| # | Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --: | --- | --- | --- | --- | --- | --- |
| 1 | Raffica di unghiate | 2 colpi su bersagli a caso | ×0.60 → 4 a colpo (8 totali) | sempre | sorteggio | — |
| 2 | — | *casella libera* | — | — | — | — |
| 3 | — | *casella libera* | — | — | — | — |
| 4 | — | *casella libera* | — | — | — | — |
| 5 | — | *casella libera* | — | — | — | — |
| 6 | — | *casella libera* | — | — | — | — |

**Motto** — quello che si legge in campo quando la mossa parte:

1. Arriva addosso prima che tu decida da che parte guardare.

**Tecno log**

| Campo | Rilevamento |
| --- | --- |
| Denominazione | Infetto Rapido |
| Classificazione | rango variante base |
| Filogenesi | umana |
| Areale | Meridia |
| Specie | Zombie |
| Stadio | II |
| Morfologia | Corpo adulto allungato: massa magra sotto la metà della norma, tendini allungati, mandibola non visibile. Presenta delle strane orecchie mutate. |
| Habitus | Tende a restare immobile per poi scattare in velocità verso la sua vittima. |
| Metamorfosi | non osservata |
| Ecologia | Non sembra avere alcuno scopo, come la sua forma base. |

*Studi necessari per la pagina intera: 3.*

### Nuvola di Marciume — livello 2, veloce
*Un pezzo della coltre che copre Meridia, sceso più in basso degli altri. Non insegue nessuno: capita addosso.*

`nuvola_di_marciume` · ♥ 94 · attacco 7 · difesa 0 · velocità 6 · xp 6 · elemento veleno

**Mosse: 2 su 6 caselle.**

| # | Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --: | --- | --- | --- | --- | --- | --- |
| 1 | Travolgere | colpisce **tutta la squadra** | ×0.55 → 4 | sempre | sorteggio | — |
| 2 | Spore | nessun danno: lascia addosso **Veleno** | — | sempre | sorteggio | 3 battute |
| 3 | — | *casella libera* | — | — | — | — |
| 4 | — | *casella libera* | — | — | — | — |
| 5 | — | *casella libera* | — | — | — | — |
| 6 | — | *casella libera* | — | — | — | — |

**Motto** — quello che si legge in campo quando la mossa parte:

1. Scende tutta insieme e vi passa sopra.
2. Respiri, e te ne accorgi dopo.

**Tecno log**

| Campo | Rilevamento |
| --- | --- |
| Denominazione | Nuvola di Marciume |
| Classificazione | rango variante base |
| Filogenesi | indeterminata |
| Areale | Meridia · Nautilus 5 · Avamposto sconosciuto |
| Specie | Nimbo |
| Stadio | I |
| Morfologia | Nessun corpo solido: sospensione di particolato organico che mantiene coesione entro un raggio di due metri. Al centro si intravede materiale non identificato. |
| Habitus | Fluttua e sembra osservare i dintorni in cerca di qualcosa. |
| Metamorfosi | non osservata |
| Ecologia | È un pezzo della coltre che copre Meridia. Sembra causare una decomposizione molto rallentata nelle forme di vita organiche. |

*Studi necessari per la pagina intera: 3.*

### Zombie Cittadino — livello 2, comune
*Questo esemplare sembra essere il più comune e debole della sua specie. Non sembra avere alcuna volontà.*

`zombie_cittadino` · ♥ 125 · attacco 8 · difesa 2 · velocità 2 · xp 5

**Mosse: 3 su 6 caselle.**

| # | Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --: | --- | --- | --- | --- | --- | --- |
| 1 | Agitazione | un colpo pesante su uno solo | ×1.20 → 10 | sempre | sorteggio | — |
| 2 | In mezzo agli altri | si chiude (difesa +2 per 3 battute) | — | con almeno 1 alleati in piedi | sorteggio | 4 battute |
| 3 | Zombie style | **non fa niente**: è solo il suo motto | — | sempre | sorteggio | 3 battute |
| 4 | — | *casella libera* | — | — | — | — |
| 5 | — | *casella libera* | — | — | — | — |
| 6 | — | *casella libera* | — | — | — | — |

**Motto** — quello che si legge in campo quando la mossa parte:

1. Si agita tutto insieme e ti viene addosso.
2. Si infila fra i suoi, e i suoi si chiudono intorno.
3. Si guarda intorno senza alcuno scopo...

**Tecno log**

| Campo | Rilevamento |
| --- | --- |
| Denominazione | Zombie Cittadino |
| Classificazione | rango base |
| Filogenesi | umana |
| Areale | Meridia |
| Specie | Zombie |
| Stadio | I |
| Morfologia | Adulto di Meridia, sesso indistinguibile. Non resta altro che un guscio senza alcuno scopo; la decomposizione è ferma a uno stadio che non progredisce. |
| Habitus | Cammina piano, spesso in gruppo, senza alcuna meta... I movimenti repentini attirano la sua attenzione. |
| Metamorfosi | non osservata |
| Ecologia | Non ha alcun rapporto fruttifero con l'ambiente: non si nutre, non nutre, totalmente inutile. |

*Studi necessari per la pagina intera: 3.*

### Manifestazione di un sogno — livello 3, miniboss
*Una manifestazione traslucida che sfida l'impossibile. Queste creature sembrano riflettere quel che scorgono nelle profondità dei rimpianti di chi incontrano.*

`manifestazione_di_un_sogno` · ♥ 439 · attacco 14 · difesa 5 · velocità 4 · xp 41 · elemento psico

Sei caselle, tutte libere: il suo turno lo detta un copione (tutorial o incontro scriptato).

**Tecno log**

| Campo | Rilevamento |
| --- | --- |
| Denominazione | Manifestazione di un sogno |
| Classificazione | forma onirica |
| Filogenesi | onirica |
| Areale | Dynapia · Profondità del sogno di Rui · Negaton 1 · Pianure selvagge di Canuka Rei |
| Specie | Onirico |
| Stadio | III |
| Morfologia | Non ha una struttura stabile: i bordi si spostano se la si guarda troppo a lungo. Le misure prese in due momenti diversi non coincidono. |
| Habitus | Sta ferma al centro del campo e non cerca posizione: e' il campo a disporsi intorno a lei. |
| Metamorfosi | non osservata |
| Ecologia | Non appartiene a questo ecosistema e non lo tocca. E' presa in prestito da un sogno che qualcuno, su questo pianeta, sta ancora facendo. |

*Studi necessari per la pagina intera: 3.*

### Fomentado — livello 3, comune
*Un'anima irrequieta spinta al suo limite dalla sua stessa passione. Brucia forte, sempre! Finché non rimarrà che cenere.*

`maschera_vuota` · ♥ 164 · attacco 10 · difesa 3 · velocità 3 · xp 9 · elemento fuoco

**Mosse: 3 su 6 caselle.**

| # | Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --: | --- | --- | --- | --- | --- | --- |
| 1 | Vampata | un colpo pesante su uno solo | ×1.40 → 14 | sempre | sorteggio | — |
| 2 | Ultima fiammata | un colpo pesante su uno solo | ×2.30 → 23 | sotto il 30% di vita | priorità 7 | — |
| 3 | Esibizionista | si potenzia (attacco +3, velocita +2, per 3 battute) | — | sempre | sorteggio | 1 battute |
| 4 | — | *casella libera* | — | — | — | — |
| 5 | — | *casella libera* | — | — | — | — |
| 6 | — | *casella libera* | — | — | — | — |

**Motto** — quello che si legge in campo quando la mossa parte:

1. La maschera avvampa: per un istante ha di nuovo un volto.
2. L'ultima fiammata se lo porta via insieme a te.
3. Si sta... esibendo?

**Tecno log**

| Campo | Rilevamento |
| --- | --- |
| Denominazione | Fomentado |
| Classificazione | rango base |
| Filogenesi | umana |
| Areale | Il Vuoto Ardente |
| Specie | Feticcio |
| Stadio | I |
| Morfologia | Corpo umano adulto, indole focosa. Sembra sprigionare energia in ogni sua mossa, ed è avvolto da fiamme ardenti. |
| Habitus | Suole esibirsi in diversi numeri di intrattenimento finché non viene notato. |
| Metamorfosi | non osservata |
| Ecologia | Brucia tutto quello con cui viene a contatto, consuma tutto quello che tocca, e ha una forte sinergia con i suoi simili. |

*Studi necessari per la pagina intera: 3.*

### Zombie Mostruoso — livello 3, comune
*Questo esemplare ha subito deformazioni alle braccia e alle sue dimensioni. Ha uno sguardo assente, e condivide lo stato di demenza dei suoi simili.*

`zombie_mostruoso` · ♥ 164 · attacco 10 · difesa 3 · velocità 3 · xp 9

**Mosse: 5 su 6 caselle.**

| # | Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --: | --- | --- | --- | --- | --- | --- |
| 1 | Falciata | un colpo pesante su uno solo | ×1.50 → 15 | sempre | sorteggio | — |
| 2 | Tritatutto | colpisce **tutta la squadra** | ×1.10 → 11 | sempre | sorteggio | 2 battute |
| 3 | Moan | si potenzia (attacco +5, velocita -1, per 3 battute) | — | sempre | sorteggio | 3 battute |
| 4 | Incitamento delle masse | **potenzia i suoi** (velocita +2, per 3 battute) | — | sotto il 50% di vita | sorteggio | 2 battute |
| 5 | Catastrofe | 20 colpi su bersagli a caso | ×0.05 → 1 a colpo (20 totali) | sotto il 50% di vita | sorteggio | 4 battute |
| 6 | — | *casella libera* | — | — | — | — |

**Motto** — quello che si legge in campo quando la mossa parte:

1. Il braccio lungo arriva da dove non te lo aspetti, e passa su tutti e due.
2. Fa girare le braccia lunghe come una macchina che nessuno ha spento.
3. Un rantolo indefinito, che dura troppo.
4. Ooooooouhh...
5. Raccoglie mezzo isolato e lo tira addosso a tutti, un pezzo per volta.

**Tecno log**

| Campo | Rilevamento |
| --- | --- |
| Denominazione | Zombie Mostruoso |
| Classificazione | rango superiore |
| Filogenesi | umana |
| Areale | Meridia |
| Specie | Zombie |
| Stadio | II |
| Morfologia | Questi esemplari sono enormi e deformi. Sono in grado di fomentare gli altri loro simili e presentano delle deviazioni assenti nelle forme inferiori di questa specie. |
| Habitus | Sbilanciato in avanti, si trascina appoggiandosi al braccio lungo. |
| Metamorfosi | non osservata |
| Ecologia | Stessa origine del cittadino, esito diverso. La differenza fra i due non e' stata spiegata da nessuno. |

*Studi necessari per la pagina intera: 3.*

### Oppresso — livello 4, corazzato
*Si tratta della manifestazione di un'anima perduta, con dei forti rancori legati al suo passato.*

`comparsa_di_ruggine` · ♥ 277 · attacco 10 · difesa 13 · velocità 3 · xp 16

**Mosse: 3 su 6 caselle.**

| # | Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --: | --- | --- | --- | --- | --- | --- |
| 1 | Vita di ruggine | alza la guardia | — | sempre | sorteggio | 3 battute |
| 2 | Colpo di ruggine | colpisce e **apre la guardia** | ×1.00 → 10 | sempre | sorteggio | — |
| 3 | Lamento | si potenzia l'attacco (+4 per 3 battute) | — | sempre | sorteggio | 2 battute |
| 4 | — | *casella libera* | — | — | — | — |
| 5 | — | *casella libera* | — | — | — | — |
| 6 | — | *casella libera* | — | — | — | — |

**Motto** — quello che si legge in campo quando la mossa parte:

1. La ruggine si addensa e si stratifica addosso a quello che resta di lui.
2. Un accumulo di ruggine materializzata ti arriva addosso.
3. Bastaaaaaaaa!

**Tecno log**

| Campo | Rilevamento |
| --- | --- |
| Denominazione | Oppresso |
| Classificazione | rango base |
| Filogenesi | rancore |
| Areale | Geodos |
| Specie | Incarnazione |
| Stadio | I |
| Morfologia | Ossido metallico concentrato sotto forma di un'ombra del passato. |
| Habitus | Impossibile determinare il momento della materializzazione: varie forme appaiono all'improvviso. |
| Metamorfosi | non osservata |
| Ecologia | Non sembra avere alcuna funzione. L'unica correlazione osservabile è il legame all'ambiente nel quale si materializza. |

*Studi necessari per la pagina intera: 3.*

### El Muy Bonito — livello 4, particolare
*Vamos! Ammirate el Muy Bonito, y despues a morir!*

`giocoliere` · ♥ 340 · attacco 15 · difesa 7 · velocità 5 · xp 29 · elemento fuoco

**Mosse: 6 su 6 caselle.**

| # | Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --: | --- | --- | --- | --- | --- | --- |
| 1 | Acrobazia folle | 2 colpi su bersagli a caso | ×0.75 → 11 a colpo (22 totali) | sempre | sorteggio | — |
| 2 | Posa minacciosa | nessun danno: lascia addosso **Lentezza** | — | sempre | sorteggio | 2 battute |
| 3 | Gran finale | colpisce **tutta la squadra** | ×1.10 → 17 | sotto il 35% di vita | priorità 7 | — |
| 4 | Vamos! | 25 colpi su bersagli a caso | ×0.04 → 1 a colpo (25 totali) | sotto il 50% di vita | sorteggio | 4 battute |
| 5 | Flashy Punch | colpisce e **apre la guardia** | ×1.30 → 20 | sempre | sorteggio | 2 battute |
| 6 | Flashy Kick | un colpo pesante su uno solo | ×1.15 → 17 | sempre | sorteggio | 2 battute |

**Motto** — quello che si legge in campo quando la mossa parte:

1. «Miren!» — e comincia a girare su se stesso con le torce accese.
2. La sua presenza infiamma l'aria.
3. «Se e' l'ultimo, che sia il migliore!»
4. Vamos!
5. Flaaashy... Punch!
6. Flaaashy... Kick!

**Tecno log**

| Campo | Rilevamento |
| --- | --- |
| Denominazione | El Muy Bonito |
| Classificazione | forma speciale |
| Filogenesi | umana |
| Areale | Il Vuoto Ardente |
| Specie | Feticcio |
| Stadio | III |
| Morfologia | Corpo adulto in eccellenti condizioni apparenti, volto e fattezze conservate. Le fiamme che lo avvolgono hanno un'armonia diversa rispetto a quelle delle specie inferiori: non bruciano, ma accompagnano i suoi movimenti ottenendo un effetto rigenerativo. |
| Habitus | Tende a rimanere sempre in posa. Si erge in difesa di colui che gli ha fornito il riconoscimento che ha sempre cercato. |
| Metamorfosi | non osservata |
| Ecologia | Il suo ruolo è difendere a ogni costo la fonte. Sembra non esserci un legame affettivo, ma un legame di rispetto e devozione che contraddistingue il rapporto fra la fonte e questo soggetto. |

*Studi necessari per la pagina intera: 3.*

### Robo Pattuglia — livello 4, corazzato
*Questo macchinario sembra avere la funzione di tenere in ordine e pattugliare i corridoi della struttura che gli è stata affidata.*

`robo_pattuglia` · ♥ 277 · attacco 10 · difesa 13 · velocità 3 · xp 16 · elemento elettrico

**Mosse: 3 su 6 caselle.**

| # | Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --: | --- | --- | --- | --- | --- | --- |
| 1 | Scarica di avvertimento | un colpo pesante su uno solo | ×1.25 → 13 | sempre | sorteggio | — |
| 2 | Protocollo di contenimento | alza la guardia | — | sempre | sorteggio | 3 battute |
| 3 | Riparazione d'emergenza | **si rimette in piedi** (+22% della vita massima) | — | sotto il 35% di vita | priorità 8 | 5 battute |
| 4 | — | *casella libera* | — | — | — | — |
| 5 | — | *casella libera* | — | — | — | — |
| 6 | — | *casella libera* | — | — | — | — |

**Motto** — quello che si legge in campo quando la mossa parte:

1. «Noi vogliamo solo il vostro bene!»
2. «Soggetto pericoloso! Rafforzare le difese!»
3. «Vrrr... clank... riparazioni eseguite!»

**Tecno log**

| Campo | Rilevamento |
| --- | --- |
| Denominazione | Robo Pattuglia |
| Classificazione | rango base |
| Filogenesi | meccanica |
| Areale | Geodos |
| Specie | Robot |
| Stadio | I |
| Morfologia | L'unità presenta lievi danni in superficie, tuttavia sembra essere completamente operativa. È composta da un'unità centrale dalla quale spuntano due pinze prensili e quattro piedi appuntiti che la sorreggono quando non si sposta rotolando. |
| Habitus | Percorre lo stesso tratto avanti e indietro, alla stessa velocita'. |
| Metamorfosi | non osservata |
| Ecologia | Non fa parte della catena alimentare. E' arredamento che ha continuato a funzionare. |

*Studi necessari per la pagina intera: 3.*

### Capocantiere — livello 4, comune
*Un'incarnazione delle figure di comando che gestivano i dipendenti del complesso.*

`voce_registrata` · ♥ 207 · attacco 13 · difesa 5 · velocità 4 · xp 13

**Mosse: 2 su 6 caselle.**

| # | Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --: | --- | --- | --- | --- | --- | --- |
| 1 | Richiamo disciplinare | un colpo pesante su uno solo | ×1.35 → 18 | sempre | sorteggio | — |
| 2 | Rabbia repressa | si potenzia l'attacco (+4 per 3 battute) | — | sempre | sorteggio | 4 battute |
| 3 | — | *casella libera* | — | — | — | — |
| 4 | — | *casella libera* | — | — | — | — |
| 5 | — | *casella libera* | — | — | — | — |
| 6 | — | *casella libera* | — | — | — | — |

**Motto** — quello che si legge in campo quando la mossa parte:

1. «Quello che stai facendo risulta in una nota.»
2. «AL LAVORO!»

**Tecno log**

| Campo | Rilevamento |
| --- | --- |
| Denominazione | Capocantiere |
| Classificazione | rango base |
| Filogenesi | umana |
| Areale | Geodos |
| Specie | Feticcio |
| Stadio | I |
| Morfologia | Non c'e' un corpo. L'emissione arriva dagli altoparlanti di reparto, e la posizione cambia con quelli. |
| Habitus | Nessun portamento: solo un volume che sale. |
| Metamorfosi | non osservata |
| Ecologia | Regola il comportamento delle altre forme del reparto, che si dispongono ancora secondo i suoi turni. |

*Studi necessari per la pagina intera: 3.*

### Emblema dell'oppressione — livello 5, comune
*Sembra che un cumulo di oggetti venga tenuto insieme da una manifestazione che si nutre della rabbia conservata nel complesso.*

`operaio_posseduto` · ♥ 290 · attacco 16 · difesa 5 · velocità 5 · xp 18

**Mosse: 3 su 6 caselle.**

| # | Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --: | --- | --- | --- | --- | --- | --- |
| 1 | Rabbia della macchina | 7 colpi su bersagli a caso | ×0.20 → 3 a colpo (21 totali) | sempre | sorteggio | — |
| 2 | A ritroso | **si rimette in piedi** (+20% della vita massima) | — | sotto il 50% di vita | priorità 4 | 5 battute |
| 3 | Astio Infinito | **non smette** finché non cade: colpisce tutta la squadra a ogni loro battuta | come il suo colpo normale | sotto il 20% di vita | priorità 5 | 5 battute |
| 4 | — | *casella libera* | — | — | — | — |
| 5 | — | *casella libera* | — | — | — | — |
| 6 | — | *casella libera* | — | — | — | — |

**Motto** — quello che si legge in campo quando la mossa parte:

1. Sette colpi di ferraglia, uno dietro l'altro, senza mai fermarsi.
2. Si ferma, e per un attimo la ferraglia si rimette a posto da sola.
3. Un vento tagliente, colmo di malvagità, si alza e non cala più.

**Tecno log**

| Campo | Rilevamento |
| --- | --- |
| Denominazione | Emblema dell'oppressione |
| Classificazione | rango avanzato |
| Filogenesi | umana |
| Areale | Geodos |
| Specie | Feticcio |
| Stadio | II |
| Morfologia | La creatura appare come un cumulo di ferraglia che presenta vari nuclei spiritici, i quali la tengono insieme in un tentativo di possessione. |
| Habitus | Aggredisce tutto quello che entra nel suo raggio d'azione. Non è possibile osservare nessun altro tipo di comportamento non violento. |
| Metamorfosi | non osservata |
| Ecologia | Non ha alcuna funzione nell'ambiente se non quella di consumarne l'energia negativa per potenziarsi. |

*Studi necessari per la pagina intera: 3.*

### Operaio Sfruttato — livello 5, particolare
*Una manifestazione del rancore serbato a causa di anni di sfruttamento e violenze continue dei lavoratori del complesso.*

`operaio_sfruttato` · ♥ 404 · attacco 18 · difesa 8 · velocità 5 · xp 39

**Mosse: 3 su 6 caselle.**

| # | Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --: | --- | --- | --- | --- | --- | --- |
| 1 | Resisto ancora | alza la guardia | — | sempre | sorteggio | 3 battute |
| 2 | Esplosione di rabbia | un colpo pesante su uno solo | da ×1.20 a **×2.60** (22 → **47**) più è ridotta male | sotto il 40% di vita | priorità 6 | 4 battute |
| 3 | Rivoluzione | colpisce **tutta la squadra** | ×0.90 → 16 | sempre | sorteggio | 2 battute |
| 4 | — | *casella libera* | — | — | — | — |
| 5 | — | *casella libera* | — | — | — | — |
| 6 | — | *casella libera* | — | — | — | — |

**Motto** — quello che si legge in campo quando la mossa parte:

1. Tiene stretti i denti e non si sposta di un passo.
2. Vent'anni tutti insieme, e non ne resta niente per dopo.
3. Un colpo di vento concentrato in un urlo.

**Tecno log**

| Campo | Rilevamento |
| --- | --- |
| Denominazione | Operaio Sfruttato |
| Classificazione | rango base |
| Filogenesi | umana |
| Areale | Geodos |
| Specie | Feticcio |
| Stadio | II |
| Morfologia | Corpo adulto consumato: massa muscolare ridotta, mani ingrossate, colonna deformata dalla postura di vent'anni. |
| Habitus | Sta davanti a quello che sorveglia, mai di fianco. Le braccia sono sempre fra te e i suoi fascicoli. |
| Metamorfosi | non osservata |
| Ecologia | Legato a un luogo preciso e a niente altro. Non difende i file: difende le ore che ci ha lasciato dentro. |

*Studi necessari per la pagina intera: 3.*

### Orrore di Meridia — livello 5, particolare
*Più corpi che si sono trovati nello stesso posto al momento sbagliato, e non si sono più separati.*

`orrore_di_meridia` · ♥ 404 · attacco 18 · difesa 8 · velocità 5 · xp 39

**Mosse: 6 su 6 caselle.**

| # | Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --: | --- | --- | --- | --- | --- | --- |
| 1 | Terremoto | colpisce **tutta la squadra** | ×1.40 → 25 | sempre | sorteggio | — |
| 2 | Spazzata | colpisce **tutta la squadra** | ×0.60 → 11 | sempre | sorteggio | — |
| 3 | Si rimescola | **si rimette in piedi** (+20% della vita massima) | — | sotto il 30% di vita | priorità 7 | 5 battute |
| 4 | Presenza colossale | **non fa niente**: è solo il suo motto | — | sempre | sorteggio | 3 battute |
| 5 | Discesa colossale | **si annuncia una battuta prima**, poi colpisce **tutta la squadra** | **l'80% della vita che ti resta** | sotto il 15% di vita | priorità 8 | 2 battute |
| 6 | Benedizione del colosso | **si rimette in piedi** (+50% della vita massima) | — | dopo essere rinata | priorità 9 | — |

**Motto** — quello che si legge in campo quando la mossa parte:

1. Appoggia il peso da un lato, e il pavimento risponde.
2. Un braccio solo, largo quanto la stanza, che passa sopra tutti.
3. I corpi si rimescolano, e quello che mancava lo prendono da un altro.
4. Si ferma. Guarda il cielo. Non ti sta pensando.
5. Ricade a terra, e la terra non regge.
6. Resta immobile, e quello che si era staccato torna al suo posto.

**Non è una mossa: torna in piedi una volta sola.** Quando cade, si rialza con il **25%** della vita massima.
Dalla seconda volta muore come chiunque. È lì che lo scontro cambia faccia.

**Tecno log**

| Campo | Rilevamento |
| --- | --- |
| Denominazione | Orrore di Meridia |
| Classificazione | rango calamita' |
| Filogenesi | umana |
| Areale | Meridia |
| Specie | Zombie |
| Stadio | VI |
| Morfologia | La creatura presenta una conformazione semplice ma enorme. La superficie del corpo è cosparsa di una sostanza melmosa che dona beneficio allo strato superficiale; proporzioni enormi, oltre misura. |
| Habitus | Non sembra essere aggressiva se non provocata, tuttavia causa una continua distruzione intorno a sé. Non sembra avere alcun interesse se non nel cielo, che guarda costantemente. Travolge tutto quello che trova camminando in circolo, e non esce mai dalla circonferenza creata dal suo movimento. |
| Metamorfosi | non osservata |
| Ecologia | Non ha alcun ruolo se non quello di girare intorno a un perno fisso, in attesa di qualcosa... |

*Studi necessari per la pagina intera: 3.*

### Veronica — livello 5, miniboss
*La tua allenatrice, e l'amica d'infanzia che non ha mai imparato a dosare la forza.*

`veronica` · ♥ 600 · attacco 18 · difesa 6 · velocità 6 · xp 0

Sei caselle, tutte libere: il suo turno lo detta un copione (tutorial o incontro scriptato).

**Tecno log**

| Campo | Rilevamento |
| --- | --- |
| Denominazione | Veronica |
| Classificazione | soggetto umano |
| Filogenesi | umana |
| Areale | Il pianeta del risveglio |
| Specie | Umano |
| Stadio | I |
| Morfologia | Nessuna alterazione. E' una persona. |
| Habitus | Sta dritta e vicino. Troppo vicino. |
| Metamorfosi | non osservata |
| Ecologia | Non e' una creatura del Vuoto: e' quello che c'era prima del Vuoto. |

*Studi necessari per la pagina intera: 3.*

## Livelli 6-10 — il mestiere

### Il Divoratore — livello 6, particolare
*Una macchina che sembra uscita dai sogni di un pazzo, sembra divorare ogni cosa nel suo raggio d'azione, che sia viva o morta...*

`divoratore` · ♥ 468 · attacco 21 · difesa 10 · velocità 6 · xp 48

**Mosse: 2 su 6 caselle.**

| # | Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --: | --- | --- | --- | --- | --- | --- |
| 1 | Morso che divora | colpisce e **si nutre** (il 60% del danno torna a lei) | ×1.30 → 27 | sempre | sorteggio | — |
| 2 | Aspirazione | colpisce **tutta la squadra** | ×0.75 → 16 | sempre | sorteggio | — |
| 3 | — | *casella libera* | — | — | — | — |
| 4 | — | *casella libera* | — | — | — | — |
| 5 | — | *casella libera* | — | — | — | — |
| 6 | — | *casella libera* | — | — | — | — |

**Motto** — quello che si legge in campo quando la mossa parte:

1. Le lame girano, prendono, e quello che prendono non torna.
2. Tutto quello che sta nel suo raggio comincia a scivolare verso il centro.

**Tecno log**

| Campo | Rilevamento |
| --- | --- |
| Denominazione | Il Divoratore |
| Classificazione | rango avanzato |
| Filogenesi | meccanica |
| Areale | Geodos |
| Specie | Robot |
| Stadio | III |
| Morfologia | Struttura cilindrica con apertura anteriore continua. Interno rivestito di lame contrapposte che ruotano in fasi alternate. |
| Habitus | Avanza in linea retta. Non gira: si riposiziona. |
| Metamorfosi | non osservata |
| Ecologia | In cima alla catena del reparto per assenza di concorrenza. Non ha predatori perche' non ha nulla che valga la pena mangiare. |

*Studi necessari per la pagina intera: 3.*

### Ferraglia Urlante — livello 6, corazzato
*Una montagna di rottami saldati dal dolore. Sembra di sentire le urla di una protesta.*

`ferraglia_urlante` · ♥ 381 · attacco 14 · difesa 18 · velocità 4 · xp 26

**Mosse: 3 su 6 caselle.**

| # | Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --: | --- | --- | --- | --- | --- | --- |
| 1 | Valanga di rottami | colpisce **tutta la squadra** | ×0.85 → 12 | sempre | sorteggio | — |
| 2 | Urlo di lamiera | nessun danno: lascia addosso **Terrore** | — | sempre | sorteggio | 5 battute |
| 3 | Si ricompatta | **si rimette in piedi** (+20% della vita massima) | — | sotto il 30% di vita | priorità 7 | 6 battute |
| 4 | — | *casella libera* | — | — | — | — |
| 5 | — | *casella libera* | — | — | — | — |
| 6 | — | *casella libera* | — | — | — | — |

**Motto** — quello che si legge in campo quando la mossa parte:

1. La montagna si sposta di un metro, e un metro basta.
2. Il rumore non e' un rumore: e' una protesta di mille voci saldate insieme.
3. I rottami si richiamano da terra e tornano al loro posto.

**Tecno log**

| Campo | Rilevamento |
| --- | --- |
| Denominazione | Ferraglia Urlante |
| Classificazione | rango superiore |
| Filogenesi | meccanica |
| Areale | Geodos |
| Specie | Robot |
| Stadio | III |
| Morfologia | Ammasso di rottami di piu' provenienze, saldati da un calore che non e' quello di una fornace. Nessuna simmetria, nessun fronte riconoscibile. |
| Habitus | Non ha portamento. Occupa. |
| Metamorfosi | non osservata |
| Ecologia | Cresce a spese del reparto: ogni pezzo che si stacca da una macchina prima o poi finisce addosso a lei. |

*Studi necessari per la pagina intera: 3.*

### Un goblin terribilmente arrabbiato — livello 6, fonte
*Non è mai stato bello, forte o rispettato, nemmeno tra i suoi. Il fattore di disallineamento gli ha dato l'unica cosa che gli mancava: qualcuno che lo temesse.*

`goblin_arrabbiato` · ♥ 1125 · attacco 25 · difesa 14 · velocità 6 · xp 152

**Mosse: 5 su 6 caselle.**

| # | Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --: | --- | --- | --- | --- | --- | --- |
| 1 | Richiamo dei suoi simili | chiama 1 × `goblin_tipico` | — | sempre | sorteggio | — |
| 2 | Furia di un goblin | un colpo pesante su uno solo | ×1.30 → 33 | sempre | sorteggio | — |
| 3 | Pugno del vile | un colpo pesante su uno solo | ×1.20 → 30 | sempre | sorteggio | — |
| 4 | Capriccio del goblin | si potenzia l'attacco (+9 per 3 battute) | — | sempre | sorteggio | — |
| 5 | Cattiveria innata | 3 colpi su bersagli a caso | ×0.50 → 13 a colpo (39 totali) | sempre | sorteggio | — |
| 6 | — | *casella libera* | — | — | — | — |

**Motto** — quello che si legge in campo quando la mossa parte:

1. Richiamo dei suoi simili: urla nella notte, e un goblin tipico risponde alla chiamata.
2. Furia di un goblin: colpisce alla cieca, urlando.
3. Pugno del vile: un colpo sferrato senza il minimo onore.
4. Capriccio del goblin: si mette a battere i piedi e se la prende con tutto quello che ha intorno. Il suo attacco aumenta.
5. Cattiveria innata: ti sferra tre attacchi deboli di fila.

Ha anche **mossa_disperazione** (scritta a mano nei suoi dati, non nella tabella).

**Tecno log**

| Campo | Rilevamento |
| --- | --- |
| Denominazione | Un goblin terribilmente arrabbiato |
| Classificazione | rango calamita' |
| Filogenesi | ferina |
| Areale | Il pianeta del risveglio |
| Specie | Goblin |
| Stadio | III |
| Morfologia | Stessa specie del comune, portata a due volte e mezzo la taglia. La crescita e' avvenuta in fretta e male: le articolazioni non hanno tenuto il passo, le spalle sono piu' alte del collo. |
| Habitus | Non sta mai fermo. Anche a riposo continua a spostare il peso da un piede all'altro. |
| Metamorfosi | non osservata |
| Ecologia | Ha preso il posto di un capobranco che non c'era. Il disallineamento gli ha dato l'unica cosa che gli mancava: qualcuno che lo temesse. |

*Studi necessari per la pagina intera: 3.*

### Ghoul — livello 8, comune
*Carne marcia tenuta insieme dalla fame e da poco altro. Uno dei tanti che la Rocca di Ossidiana non ha mai lasciato andare.*

`ghoul` · ♥ 366 · attacco 23 · difesa 10 · velocità 6 · xp 30

**Mosse: 2 su 6 caselle.**

| # | Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --: | --- | --- | --- | --- | --- | --- |
| 1 | Morso famelico | colpisce e **si nutre** (il 50% del danno torna a lei) | ×1.20 → 28 | sempre | sorteggio | — |
| 2 | Artigliata | un colpo pesante su uno solo | ×1.45 → 33 | sempre | sorteggio | — |
| 3 | — | *casella libera* | — | — | — | — |
| 4 | — | *casella libera* | — | — | — | — |
| 5 | — | *casella libera* | — | — | — | — |
| 6 | — | *casella libera* | — | — | — | — |

**Motto** — quello che si legge in campo quando la mossa parte:

1. Il ghoul morde e non lascia andare: quello che ti toglie se lo tiene.
2. Le unghie sono l'unica cosa che gli e' cresciuta dopo la morte.

**Tecno log**

| Campo | Rilevamento |
| --- | --- |
| Denominazione | Ghoul |
| Classificazione | rango base |
| Filogenesi | umana |
| Areale | Jondoh |
| Specie | Zombie |
| Stadio | II |
| Morfologia | Corpo adulto scarnificato, tenuto insieme da tessuto connettivo indurito. Le unghie sono l'unica struttura cresciuta dopo la morte, e sono cresciute molto. |
| Habitus | Curvo, con le mani sempre davanti all'altezza del petto. |
| Metamorfosi | non osservata |
| Ecologia | La forma piu' diffusa della Rocca. Uno dei tanti che Jondoh non ha mai lasciato andare. |

*Studi necessari per la pagina intera: 3.*

### ??? — livello 8, particolare
*Qualcosa che cammina nella cripta, e non si ferma per quanto lo si colpisca. Il suo vero nome è ancora un mistero.*

`l_immortale` · ♥ 120 · attacco 5 · difesa 0 · velocità 7 · xp 67 · elemento oscuro

**Mosse: 1 su 6 caselle.**

| # | Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --: | --- | --- | --- | --- | --- | --- |
| 1 | Non si ferma | un colpo pesante su uno solo | ×1.00 → 5 | sempre | sorteggio | — |
| 2 | — | *casella libera* | — | — | — | — |
| 3 | — | *casella libera* | — | — | — | — |
| 4 | — | *casella libera* | — | — | — | — |
| 5 | — | *casella libera* | — | — | — | — |
| 6 | — | *casella libera* | — | — | — | — |

**Motto** — quello che si legge in campo quando la mossa parte:

1. Continua a camminare, e continua a colpire. Non e' veloce. Non serve.

**Non muore mai.** Abbatterlo non serve: si rialza sempre, e da questo scontro
si esce in un altro modo.

**Tecno log**

| Campo | Rilevamento |
| --- | --- |
| Denominazione | ??? |
| Classificazione | non classificabile |
| Filogenesi | indeterminata |
| Areale | Jondoh |
| Specie | Indeterminato |
| Stadio | III |
| Morfologia | Umanoide, statura media, avvolto. Nessuna parte del corpo e' stata osservata direttamente, e nessuno strumento ha restituito una misura stabile. |
| Habitus | Cammina. Non e' veloce, e non gli serve esserlo. |
| Metamorfosi | non osservata |
| Ecologia | Non ha posto nella catena: nessuna forma della Rocca lo tocca e lui non tocca loro. Il suo vero nome e' ancora un mistero. |

*Studi necessari per la pagina intera: 3.*

### Madre in Lacrime — livello 8, comune
*Piange lacrime di ossidiana per figli che non tornano, e non lascia avvicinare nessuno a quel dolore.*

`madre_in_lacrime` · ♥ 366 · attacco 23 · difesa 10 · velocità 6 · xp 30

**Mosse: 2 su 6 caselle.**

| # | Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --: | --- | --- | --- | --- | --- | --- |
| 1 | Lacrime di ossidiana | colpisce **tutta la squadra** | ×0.70 → 16 | sempre | sorteggio | — |
| 2 | Non avvicinarti | un colpo pesante su uno solo | ×1.50 → 35 | sempre | sorteggio | — |
| 3 | — | *casella libera* | — | — | — | — |
| 4 | — | *casella libera* | — | — | — | — |
| 5 | — | *casella libera* | — | — | — | — |
| 6 | — | *casella libera* | — | — | — | — |

**Motto** — quello che si legge in campo quando la mossa parte:

1. Piange, e quello che cade taglia.
2. «Non toccarli.» Non c'e' nessuno da toccare.

**Tecno log**

| Campo | Rilevamento |
| --- | --- |
| Denominazione | Madre in Lacrime |
| Classificazione | rango base |
| Filogenesi | umana |
| Areale | Jondoh |
| Specie | Zombie |
| Stadio | II |
| Morfologia | Corpo adulto femminile con inclusioni di ossidiana lungo gli zigomi e il collo. Le lacrime sono vetro nero e non si fermano. |
| Habitus | Sta chinata su qualcosa che non c'e', e non lascia avvicinare. |
| Metamorfosi | non osservata |
| Ecologia | Non contende niente e non si sposta. Piange figli che non tornano, e la Rocca la lascia in pace. |

*Studi necessari per la pagina intera: 3.*

### Teschio Errante — livello 8, comune
*Un teschio che galleggia basso sull'ossidiana, a scatti, come se cercasse ancora il corpo perduto.*

`teschio_errante` · ♥ 366 · attacco 23 · difesa 10 · velocità 6 · xp 30

**Mosse: 2 su 6 caselle.**

| # | Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --: | --- | --- | --- | --- | --- | --- |
| 1 | Carica a scatti | 2 colpi su bersagli a caso | ×0.65 → 15 a colpo (30 totali) | sempre | sorteggio | — |
| 2 | Sguardo vuoto | nessun danno: lascia addosso **Terrore** | — | sempre | sorteggio | 5 battute |
| 3 | — | *casella libera* | — | — | — | — |
| 4 | — | *casella libera* | — | — | — | — |
| 5 | — | *casella libera* | — | — | — | — |
| 6 | — | *casella libera* | — | — | — | — |

**Motto** — quello che si legge in campo quando la mossa parte:

1. Si avvicina a scatti, come una fotografia che si muove male.
2. Le orbite ti guardano, e la cosa peggiore e' che ci si vede dentro.

**Tecno log**

| Campo | Rilevamento |
| --- | --- |
| Denominazione | Teschio Errante |
| Classificazione | rango superiore |
| Filogenesi | umana |
| Areale | Jondoh |
| Specie | Zombie |
| Stadio | III |
| Morfologia | Solo il cranio, senza mandibola in un terzo dei casi rilevati. Nessun corpo, nessun collegamento visibile a una massa che lo sostenga. |
| Habitus | Si sposta a scatti, come una fotografia che si muove male. |
| Metamorfosi | non osservata |
| Ecologia | Cerca ancora il corpo perduto. Segue chi ne ha uno. |

*Studi necessari per la pagina intera: 3.*

### Diabolo — livello 9, comune
*Un piccolo demone da baraccone, cresciuto storto tra le fiamme della Rocca.*

`diabolo` · ♥ 405 · attacco 26 · difesa 11 · velocità 7 · xp 35

**Mosse: 2 su 6 caselle.**

| # | Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --: | --- | --- | --- | --- | --- | --- |
| 1 | Forconata | 2 colpi su bersagli a caso | ×0.70 → 18 a colpo (36 totali) | sempre | sorteggio | — |
| 2 | Sberleffo | nessun danno: lascia addosso **Confusione** | — | sempre | sorteggio | 5 battute |
| 3 | — | *casella libera* | — | — | — | — |
| 4 | — | *casella libera* | — | — | — | — |
| 5 | — | *casella libera* | — | — | — | — |
| 6 | — | *casella libera* | — | — | — | — |

**Motto** — quello che si legge in campo quando la mossa parte:

1. Due colpi bassi, dati con troppo entusiasmo.
2. Ti imita mentre ti muovi, e ti viene voglia solo di prenderlo.

**Tecno log**

| Campo | Rilevamento |
| --- | --- |
| Denominazione | Diabolo |
| Classificazione | rango base |
| Filogenesi | ferina |
| Areale | Jondoh |
| Specie | Ferino |
| Stadio | I |
| Morfologia | Ottanta centimetri, bipede, corna corte e ricurve, coda prensile. Le proporzioni sono da cucciolo, l'eta' stimata no. |
| Habitus | Non sta fermo un secondo e ti gira intorno mentre parli. |
| Metamorfosi | non osservata |
| Ecologia | Cresciuto storto fra le fiamme della Rocca. Segue le forme piu' grandi e ne raccoglie gli scarti. |

*Studi necessari per la pagina intera: 3.*

### Sadico — livello 9, comune
*Trova piacere nel dolore altrui, l'unico linguaggio che la Rocca gli ha insegnato.*

`sadico` · ♥ 405 · attacco 26 · difesa 11 · velocità 7 · xp 35

**Mosse: 2 su 6 caselle.**

| # | Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --: | --- | --- | --- | --- | --- | --- |
| 1 | Taglio lento | un colpo pesante su uno solo | ×1.20 → 31 | sempre | sorteggio | — |
| 2 | Infierisce | un colpo pesante su uno solo | ×1.90 → 49 | se qualcuno di voi è sotto il 40% | priorità 7 | 2 battute |
| 3 | — | *casella libera* | — | — | — | — |
| 4 | — | *casella libera* | — | — | — | — |
| 5 | — | *casella libera* | — | — | — | — |
| 6 | — | *casella libera* | — | — | — | — |

**Motto** — quello che si legge in campo quando la mossa parte:

1. Non ha fretta. Non ne ha mai avuta.
2. Aspettava questo momento: si china su chi sta peggio.

**Tecno log**

| Campo | Rilevamento |
| --- | --- |
| Denominazione | Sadico |
| Classificazione | rango base |
| Filogenesi | umana |
| Areale | Jondoh |
| Specie | Umano |
| Stadio | II |
| Morfologia | Corpo adulto senza alterazioni fisiche rilevanti. E' l'unico caso in cui la deformazione non e' del corpo. |
| Habitus | Si muove con calma, e la calma e' la parte peggiore. |
| Metamorfosi | non osservata |
| Ecologia | Il dolore altrui e' l'unico linguaggio che la Rocca gli ha insegnato. Le altre forme lo evitano. |

*Studi necessari per la pagina intera: 3.*

### Stigma — livello 9, comune
*Porta incisi sulla pelle i peccati di qualcun altro, marchiato da una colpa che non è la sua.*

`stigma` · ♥ 405 · attacco 26 · difesa 11 · velocità 7 · xp 35

**Mosse: 2 su 6 caselle.**

| # | Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --: | --- | --- | --- | --- | --- | --- |
| 1 | Colpa altrui | un colpo pesante su uno solo | ×1.45 → 38 | sempre | sorteggio | — |
| 2 | Marchio | nessun danno: lascia addosso **Veleno** | — | sempre | sorteggio | 4 battute |
| 3 | — | *casella libera* | — | — | — | — |
| 4 | — | *casella libera* | — | — | — | — |
| 5 | — | *casella libera* | — | — | — | — |
| 6 | — | *casella libera* | — | — | — | — |

**Motto** — quello che si legge in campo quando la mossa parte:

1. Ti addosso il peso di una cosa che non hai fatto.
2. Un segno ti resta sulla pelle, e da li' comincia a fare male.

**Tecno log**

| Campo | Rilevamento |
| --- | --- |
| Denominazione | Stigma |
| Classificazione | rango base |
| Filogenesi | umana |
| Areale | Jondoh |
| Specie | Zombie |
| Stadio | II |
| Morfologia | Adulto con incisioni profonde su tutta la superficie dorsale, disposte in ordine leggibile. Le incisioni non guariscono e non sanguinano. |
| Habitus | Sta dritto e si lascia guardare. E' l'unica cosa che gli e' rimasta. |
| Metamorfosi | non osservata |
| Ecologia | Porta i peccati di qualcun altro. Chi glieli ha incisi non e' mai stato identificato. |

*Studi necessari per la pagina intera: 3.*

### Abominio Marcio — livello 10, particolare
*Più corpi fusi insieme dal marciume, tenuti in piedi da qualcosa che non è più vita. Una delle tante forme che prende la maledizione della Rocca.*

`abominio_marcio` · ♥ 737 · attacco 34 · difesa 18 · velocità 9 · xp 86 · elemento veleno

**Mosse: 3 su 6 caselle.**

| # | Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --: | --- | --- | --- | --- | --- | --- |
| 1 | Sputo marcio | un colpo pesante su uno solo | ×1.30 → 44 | sempre | sorteggio | — |
| 2 | Abbraccio di carne | colpisce e **si nutre** (il 50% del danno torna a lei) | ×1.40 → 48 | sempre | sorteggio | — |
| 3 | Si ricuce | **si rimette in piedi** (+25% della vita massima) | — | sotto il 35% di vita | priorità 8 | 5 battute |
| 4 | — | *casella libera* | — | — | — | — |
| 5 | — | *casella libera* | — | — | — | — |
| 6 | — | *casella libera* | — | — | — | — |

**Motto** — quello che si legge in campo quando la mossa parte:

1. Qualcosa gli sale su dal petto e ti arriva addosso.
2. Ti stringe, e per un momento non si capisce piu' dove finisci tu.
3. I corpi si rimescolano, e quello che era aperto adesso e' chiuso.

**Tecno log**

| Campo | Rilevamento |
| --- | --- |
| Denominazione | Abominio Marcio |
| Classificazione | rango avanzato |
| Filogenesi | indeterminata |
| Areale | — non ancora rilevato |
| Specie | Zombie |
| Stadio | III |
| Morfologia | Piu' corpi fusi dal marciume, di specie diverse: sono stati riconosciuti segmenti umani e segmenti animali nello stesso soggetto. |
| Habitus | Occupa lo spazio in altezza piu' che in larghezza. Ondeggia. |
| Metamorfosi | non osservata |
| Ecologia | Una delle tante forme che prende la maledizione della Rocca. Continua ad aggregare quello che trova. |

*Studi necessari per la pagina intera: 3.*

### Titano Zombie — livello 10, particolare
*La cosa più grande che Meridia abbia partorito dopo la fine. Si ricuce da solo, e non ha mai imparato a fermarsi.*

`titano_zombie` · ♥ 737 · attacco 34 · difesa 18 · velocità 9 · xp 86

**Mosse: 2 su 6 caselle.**

| # | Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --: | --- | --- | --- | --- | --- | --- |
| 1 | Pugno devastante | **si annuncia una battuta prima**, poi toglie **metà** della vita che ti resta | come il suo colpo normale | sempre | sorteggio | — |
| 2 | Spazzata | colpisce **tutta la squadra** | ×0.70 → 24 | sempre | sorteggio | — |
| 3 | — | *casella libera* | — | — | — | — |
| 4 | — | *casella libera* | — | — | — | — |
| 5 | — | *casella libera* | — | — | — | — |
| 6 | — | *casella libera* | — | — | — | — |

**Motto** — quello che si legge in campo quando la mossa parte:

1. Pugno devastante: il colpo si abbatte con tutto il peso della città morta.
2. Il titano spazza l'aria davanti a sé: nessuno resta in piedi comodo.

Ha anche **rigenerazione** (scritta a mano nei suoi dati, non nella tabella).

**Tecno log**

| Campo | Rilevamento |
| --- | --- |
| Denominazione | Titano Zombie |
| Classificazione | rango avanzato |
| Filogenesi | umana |
| Areale | Meridia |
| Specie | Zombie |
| Stadio | III |
| Morfologia | Oltre quattro metri. Struttura ossea moltiplicata invece che ingrandita: doppie file di costole, articolazioni supplementari alle ginocchia. |
| Habitus | In piedi, sempre. Si abbassa solo quando cede. |
| Metamorfosi | non osservata |
| Ecologia | La cosa piu' grande che Meridia abbia partorito dopo la fine. Le altre forme non le si avvicinano. |

*Studi necessari per la pagina intera: 3.*

## Livelli 11-15 — la Rocca e la Casa

### Divoratore di Carcasse — livello 11, comune
*Vive sotto il grande ponte marcio, nutrendosi di ciò che il ponte stesso lascia cadere. La puzza lo tradisce molto prima che si mostri.*

`divoratore_di_carcasse` · ♥ 486 · attacco 32 · difesa 14 · velocità 9 · xp 43 · elemento veleno

**Mosse: 2 su 6 caselle.**

| # | Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --: | --- | --- | --- | --- | --- | --- |
| 1 | Morso multiplo | 2 colpi su bersagli a caso | ×0.55 → 18 a colpo (36 totali) | sempre | sorteggio | — |
| 2 | Si ingozza | **si rimette in piedi** (+20% della vita massima) | — | sotto il 35% di vita | priorità 7 | 5 battute |
| 3 | — | *casella libera* | — | — | — | — |
| 4 | — | *casella libera* | — | — | — | — |
| 5 | — | *casella libera* | — | — | — | — |
| 6 | — | *casella libera* | — | — | — | — |

**Motto** — quello che si legge in campo quando la mossa parte:

1. Il divoratore azzanna più volte, veloce.
2. Si volta verso quello che il ponte ha lasciato cadere, e mangia.

**Tecno log**

| Campo | Rilevamento |
| --- | --- |
| Denominazione | Divoratore di Carcasse |
| Classificazione | rango base |
| Filogenesi | ferina |
| Areale | Jondoh |
| Specie | Ferino |
| Stadio | II |
| Morfologia | Quadrupede di grossa taglia con cranio sproporzionato e dentatura a piu' file. Il collo e' piu' spesso della testa. |
| Habitus | Sta basso, con il muso a terra. La puzza lo tradisce molto prima che si mostri. |
| Metamorfosi | non osservata |
| Ecologia | Vive sotto il grande ponte marcio e ripulisce quello che cade. Nessuno gli contende quel posto. |

*Studi necessari per la pagina intera: 3.*

### Sacerdote Folle — livello 11, comune
*Officiava i sacrifici della Rocca molto prima che Jongo Dongo ne facesse un culto. Recita ancora le sue litanie, anche se non è rimasto nessuno a rispondergli.*

`sacerdote_folle` · ♥ 486 · attacco 32 · difesa 14 · velocità 9 · xp 43 · elemento oscuro

**Mosse: 6 su 6 caselle.**

| # | Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --: | --- | --- | --- | --- | --- | --- |
| 1 | Litania: «Per il viaggio!» | un colpo pesante su uno solo | ×1.20 → 38 | sempre | sorteggio | — |
| 2 | Litania: «Unisciti al raccolto!» | un colpo pesante su uno solo | ×1.20 → 38 | sempre | sorteggio | — |
| 3 | Litania: «Portatelo da me!» | un colpo pesante su uno solo | ×1.20 → 38 | sempre | sorteggio | — |
| 4 | Litania: «Non c'è altra strada!» | un colpo pesante su uno solo | ×1.20 → 38 | sempre | sorteggio | — |
| 5 | Richiamo dei teschi | chiama 1 × `teschio_errante` | — | sempre | sorteggio | — |
| 6 | Litania che rimargina | **si rimette in piedi** (+20% della vita massima) | — | sotto il 35% di vita | priorità 7 | 5 battute |

**Motto** — quello che si legge in campo quando la mossa parte:

1. "Per il viaggio!" Il sacerdote colpisce recitando.
2. "Unisciti al raccolto!" Il sacerdote colpisce recitando.
3. "Portatelo da me!" Il sacerdote colpisce recitando.
4. "Non c'è altra strada!" Il sacerdote colpisce recitando.
5. Il sacerdote alza le braccia: un teschio errante risponde al richiamo.
6. Recita piu' in fretta, e le ferite si chiudono al ritmo delle parole.

**Tecno log**

| Campo | Rilevamento |
| --- | --- |
| Denominazione | Sacerdote Folle |
| Classificazione | rango base |
| Filogenesi | umana |
| Areale | Jondoh |
| Specie | Umano |
| Stadio | II |
| Morfologia | Adulto in paramenti, conservato. Nessuna alterazione fisica: la deformazione e' nel calendario che continua a seguire. |
| Habitus | In piedi, le braccia leggermente aperte, rivolto a un altare che non c'e' piu'. |
| Metamorfosi | non osservata |
| Ecologia | Officiava i sacrifici molto prima che Jongo Dongo ne facesse un culto. Non e' rimasto nessuno a rispondergli. |

*Studi necessari per la pagina intera: 3.*

### Jongo Dongo — livello 12, fonte
*Un tempo signore di queste terre. Sacrificò raccolti e famiglie intere per la propria fortuna, e non si è mai pentito: la maledizione delle famiglie in lutto lo ha fatto marcire vivo, ma non lo ha fermato.*

`jongo_dongo` · ♥ 1857 · attacco 48 · difesa 30 · velocità 10 · xp 329 · elemento veleno

**Mosse: 6 su 6 caselle.**

| # | Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --: | --- | --- | --- | --- | --- | --- |
| 1 | Colpo marcio | **si annuncia una battuta prima**, poi un colpo pesante su uno solo | ×1.40 → 67 | sempre | sorteggio | — |
| 2 | Bastone di pietra marcia | un colpo pesante su uno solo | ×1.15 → 55 | sempre | sorteggio | — |
| 3 | Grido del raccolto | colpisce **tutta la squadra** | ×0.70 → 34 | sempre | sorteggio | — |
| 4 | Un piccolo sacrificio | uccide un suo alleato per farsi più forte | — | sempre | sorteggio | — |
| 5 | Raccolto di carne | chiama 1 × `ghoul` | — | sempre | sorteggio | — |
| 6 | Maledizione di chi muore | colpisce **tutta la squadra** | ×1.00 → 48 | sotto il 25% di vita | priorità 7 | — |

**Motto** — quello che si legge in campo quando la mossa parte:

1. Jongo Dongo affonda l'artiglio marcio con tutto il suo peso.
2. Jongo Dongo cala il bastone dalla pietra marcia: dove tocca, la carne comincia a cedere.
3. "IL VIAGGIO RICHIEDE SEMPRE IL SUO PREZZO!" Il grido vi si conficca dentro più delle unghie.
4. Jongo Dongo si volta verso uno dei suoi ghoul, con la stessa calma di sempre: "Un piccolo sacrificio... per un grande risultato."
5. Jongo Dongo batte il palmo marcio sull'ossidiana: la terra stessa gli restituisce un altro ghoul.
6. Quello che ha fatto marcire lui, adesso lo passa a voi.

Ha anche **mossa_soglia_hp** (scritta a mano nei suoi dati, non nella tabella).

**Tecno log**

| Campo | Rilevamento |
| --- | --- |
| Denominazione | Jongo Dongo |
| Classificazione | rango calamita' |
| Filogenesi | umana |
| Areale | Jondoh |
| Specie | Umano |
| Stadio | III |
| Morfologia | Adulto di corporatura importante, marcito in piedi. La pelle si e' aperta lungo le linee di tensione e non si e' richiusa; sotto, il tessuto e' ancora attivo. |
| Habitus | Sta come stava da vivo, e questa e' la cosa che colpisce di piu' chi lo vede. |
| Metamorfosi | non osservata |
| Ecologia | Era il signore di queste terre. Sacrifico' raccolti e famiglie intere per la propria fortuna, e non si e' mai pentito. |

*Studi necessari per la pagina intera: 3.*

### Donna Spinosa — livello 13, comune
*Cresciuta in una vasca con un cartellino che diceva un'altra cosa. Sta ferma finché non le passi accanto, e allora si ricorda di essere stata progettata.*

`donna_spinosa` · ♥ 568 · attacco 38 · difesa 17 · velocità 10 · xp 51 · elemento veleno

**Mosse: 2 su 6 caselle.**

| # | Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --: | --- | --- | --- | --- | --- | --- |
| 1 | Spine sottili | un colpo pesante su uno solo | ×1.20 → 46 | sempre | sorteggio | — |
| 2 | Spine a tappeto | colpisce **tutta la squadra** | ×0.75 → 29 | sempre | sorteggio | — |
| 3 | — | *casella libera* | — | — | — | — |
| 4 | — | *casella libera* | — | — | — | — |
| 5 | — | *casella libera* | — | — | — | — |
| 6 | — | *casella libera* | — | — | — | — |

**Motto** — quello che si legge in campo quando la mossa parte:

1. Le spine entrano piano, quasi con gentilezza. Il bruciore arriva dopo.
2. Si apre tutta insieme, e per un metro intorno non si sta.

**Tecno log**

| Campo | Rilevamento |
| --- | --- |
| Denominazione | Donna Spinosa |
| Classificazione | rango base |
| Filogenesi | vegetale |
| Areale | La Casa Gigante |
| Specie | Flora |
| Stadio | II |
| Morfologia | Struttura arborea su impianto umanoide. Le spine sono modificazioni dei rami secondari e coprono tutta la superficie dorsale. |
| Habitus | Immobile finche' non le si passa accanto. Poi si ricorda di essere stata progettata. |
| Metamorfosi | non osservata |
| Ecologia | Cresciuta in una vasca con un cartellino che diceva un'altra cosa. Quello che doveva essere non risulta agli atti. |

*Studi necessari per la pagina intera: 3.*

### Marionetta — livello 13, comune
*Legno, fili e un po' di rancore. Qualcuno la muoveva con affetto, una volta.*

`marionetta` · ♥ 568 · attacco 38 · difesa 17 · velocità 10 · xp 51 · elemento oscuro

**Mosse: 3 su 6 caselle.**

| # | Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --: | --- | --- | --- | --- | --- | --- |
| 1 | Colpo di legno | un colpo pesante su uno solo | ×1.45 → 55 | sempre | sorteggio | — |
| 2 | Fili che stringono | nessun danno: lascia addosso **Lentezza** | — | sempre | sorteggio | 4 battute |
| 3 | Si rimette i fili | **si rimette in piedi** (+20% della vita massima) | — | sotto il 30% di vita | priorità 7 | 6 battute |
| 4 | — | *casella libera* | — | — | — | — |
| 5 | — | *casella libera* | — | — | — | — |
| 6 | — | *casella libera* | — | — | — | — |

**Motto** — quello che si legge in campo quando la mossa parte:

1. Un braccio di legno gira su un perno e arriva duro.
2. I fili non tengono su lei: tengono giu' te.
3. Raccoglie i suoi fili da terra e se li riannoda addosso.

**Tecno log**

| Campo | Rilevamento |
| --- | --- |
| Denominazione | Marionetta |
| Classificazione | rango base |
| Filogenesi | artificiale |
| Areale | La Casa Gigante |
| Specie | Automa |
| Stadio | II |
| Morfologia | Legno di conifera, snodi in ottone, un metro e dieci. I fili non sono agganciati a nulla di visibile e restano tesi. |
| Habitus | Sta appesa anche quando cammina: il peso non arriva mai del tutto ai piedi. |
| Metamorfosi | non osservata |
| Ecologia | Qualcuno la muoveva con affetto, una volta. Adesso i fili scendono dal soffitto e nessuno li tiene. |

*Studi necessari per la pagina intera: 3.*

### Jongo Dongo — livello 14, fonte
*Ormai non rimane altro di lui che un corpo marcito che si muove solo grazie a una volontà misteriosa.*

`jongo_dongo_risorto` · ♥ 2147 · attacco 56 · difesa 36 · velocità 12 · xp 384 · elemento veleno

**Mosse: 3 su 6 caselle.**

| # | Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --: | --- | --- | --- | --- | --- | --- |
| 1 | Mano marcia | un colpo pesante su uno solo | ×1.50 → 84 | sempre | sorteggio | — |
| 2 | Respiro di putredine | colpisce **tutta la squadra** | ×0.90 → 50 | sempre | sorteggio | — |
| 3 | Volonta' misteriosa | **si rimette in piedi** (+18% della vita massima) | — | sotto il 30% di vita | priorità 8 | 6 battute |
| 4 | — | *casella libera* | — | — | — | — |
| 5 | — | *casella libera* | — | — | — | — |
| 6 | — | *casella libera* | — | — | — | — |

**Motto** — quello che si legge in campo quando la mossa parte:

1. La mano arriva piano, e non e' piu' una mano.
2. Espira, e l'aria intorno smette di essere aria.
3. Il corpo non dovrebbe reggere. Qualcosa lo tiene su lo stesso.

**Tecno log**

| Campo | Rilevamento |
| --- | --- |
| Denominazione | Jongo Dongo |
| Classificazione | rango calamita' |
| Filogenesi | umana |
| Areale | Jondoh |
| Specie | Zombie |
| Stadio | III |
| Morfologia | Lo stesso corpo, rimesso insieme dopo la distruzione. Le linee di frattura sono visibili e non corrispondono a come si era spezzato. |
| Habitus | Piu' lento di prima, e piu' dritto. |
| Metamorfosi | non osservata |
| Ecologia | Non rimane altro di lui che un corpo marcito che si muove grazie a una volonta' misteriosa. La volonta' non e' la sua. |

*Studi necessari per la pagina intera: 3.*

### Ombra del passato — livello 14, comune
*Un'ombra del passato, vive grazie ai sentimenti repressi di qualcuno che ricorda la persona da cui prende forma con sentimenti negativi.*

`ombra_del_passato` · ♥ 607 · attacco 41 · difesa 18 · velocità 10 · xp 55 · elemento oscuro

**Mosse: 2 su 6 caselle.**

| # | Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --: | --- | --- | --- | --- | --- | --- |
| 1 | Rinfaccia | un colpo pesante su uno solo | ×1.50 → 62 | sempre | sorteggio | — |
| 2 | Si nutre del rancore | colpisce e **si nutre** (il 60% del danno torna a lei) | ×1.20 → 49 | sotto il 50% di vita | priorità 5 | 3 battute |
| 3 | — | *casella libera* | — | — | — | — |
| 4 | — | *casella libera* | — | — | — | — |
| 5 | — | *casella libera* | — | — | — | — |
| 6 | — | *casella libera* | — | — | — | — |

**Motto** — quello che si legge in campo quando la mossa parte:

1. Ti dice una cosa vera, e detta da lei fa male il doppio.
2. Piu' le pensi contro, piu' si fa solida.

**Tecno log**

| Campo | Rilevamento |
| --- | --- |
| Denominazione | Ombra del passato |
| Classificazione | rango avanzato |
| Filogenesi | indeterminata |
| Areale | La Casa Gigante |
| Specie | Ombra |
| Stadio | III |
| Morfologia | Nessuna massa misurabile. La sagoma corrisponde a una persona precisa, diversa per ogni osservatore, e i contorni sono piu' netti dove il ricordo e' piu' recente. |
| Habitus | Sta ferma a distanza di conversazione. Non si avvicina mai piu' di cosi'. |
| Metamorfosi | non osservata |
| Ecologia | Vive dei sentimenti repressi di chi la incontra. Senza qualcuno che ricordi, non c'e'. |

*Studi necessari per la pagina intera: 3.*

### Un tenero ricordo — livello 15, fonte
*Una bambola cucita a mano, Non ha un bel aspetto ma sembra essere stata amata. Qualcosa di oscuro si annida tra le cuciture.*

`tenero_ricordo` · ♥ 6660 · attacco 27 · difesa 12 · velocità 13 · xp 411 · elemento oscuro

**Mosse: 5 su 6 caselle.**

| # | Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --: | --- | --- | --- | --- | --- | --- |
| 1 | Spilli | un colpo pesante su uno solo | ×1.30 → 35 | sempre | sorteggio | — |
| 2 | Lamento | colpisce **tutta la squadra** | ×0.70 → 19 | sempre | sorteggio | — |
| 3 | Si strappa una cucitura | si ferisce da sola, e la cosa vi pesa addosso | **5 fisso** | sempre | sorteggio | — |
| 4 | Richiamo delle marionette | chiama 1 × `marionetta` | — | sempre | sorteggio | — |
| 5 | Si ricuce le cuciture | **si rimette in piedi** (+15% della vita massima) | — | sotto il 25% di vita | priorità 6 | 6 battute |
| 6 | — | *casella libera* | — | — | — | — |

**Motto** — quello che si legge in campo quando la mossa parte:

1. La bambola spalanca le cuciture e lancia una manciata di spilli.
2. Un lamento terribile riempie la stanza. I cuori di tutti sobbalzano.
3. La bambola si strappa una cucitura da sola, piano. Fa più male a voi che a lei.
4. Dei fili scendono dal soffitto: una marionetta si alza da terra.
5. Il filo rientra da solo nei buchi, come se qualcuno la stesse ancora rammendando.

Ha anche **frenesia** (scritta a mano nei suoi dati, non nella tabella).

**Tecno log**

| Campo | Rilevamento |
| --- | --- |
| Denominazione | Un tenero ricordo |
| Classificazione | rango calamita' |
| Filogenesi | artificiale |
| Areale | La Casa Gigante |
| Specie | Automa |
| Stadio | III |
| Morfologia | Bambola di pezza cucita a mano, quaranta centimetri, imbottitura non identificata. Le cuciture sono state rifatte molte volte e da mani diverse. |
| Habitus | Sta seduta. Anche quando si muove, l'impressione e' che sia sempre seduta. |
| Metamorfosi | non osservata |
| Ecologia | Al centro della casa, e la casa le sta intorno. E' stata amata: e' questo il problema. |

*Studi necessari per la pagina intera: 3.*

### Volto sulla parete — livello 15, miniboss
*Quello che è rimasto della capofamiglia, cresciuto dentro la parete insieme a tutto il resto. Difende ancora i risultati di ricerche che non servono più a nessuno.*

`volto_sulla_parete` · ♥ 1733 · attacco 57 · difesa 32 · velocità 13 · xp 264 · elemento veleno

**Mosse: 3 su 6 caselle.**

| # | Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --: | --- | --- | --- | --- | --- | --- |
| 1 | Radici che stringono | un colpo pesante su uno solo | ×1.30 → 74 | sempre | sorteggio | — |
| 2 | Sfogo di spore | colpisce **tutta la squadra** | ×0.70 → 40 | sempre | sorteggio | — |
| 3 | Assorbe dalla parete | **si rimette in piedi** (+20% della vita massima) | — | sotto il 30% di vita | priorità 8 | 5 battute |
| 4 | — | *casella libera* | — | — | — | — |
| 5 | — | *casella libera* | — | — | — | — |
| 6 | — | *casella libera* | — | — | — | — |

**Motto** — quello che si legge in campo quando la mossa parte:

1. Le radici escono dal pavimento e stringono: dove toccano, la pelle cambia colore.
2. La parete si apre e sputa una nube di spore su tutta la stanza.
3. La parete si muove dietro di lei, e le rida' quello che le hai tolto.

**Tecno log**

| Campo | Rilevamento |
| --- | --- |
| Denominazione | Volto sulla parete |
| Classificazione | rango avanzato |
| Filogenesi | umana |
| Areale | La Casa Gigante |
| Specie | Incarnazione |
| Stadio | III |
| Morfologia | Volto adulto femminile cresciuto dentro la parete portante, con propaggini radicali che percorrono l'intera stanza. La parete e' parte del soggetto. |
| Habitus | Non ha portamento: ha esposizione. Ti guarda da un'altezza che non hai scelto tu. |
| Metamorfosi | non osservata |
| Ecologia | Difende ancora i risultati di ricerche che non servono piu' a nessuno. Era la capofamiglia. |

*Studi necessari per la pagina intera: 3.*

## Livelli 16 e oltre — le fonti

### L'ultimo spettacolo di Jerah — livello 18, fonte
*Un talento unico, forse 1 su 10milioni: il più grande spettacolo che il mondo abbia mai visto, una passione ardente, pericolosamente spenta... Il mondo intero arde, arde teatro del suo ultimo show.*

`jerah` · ♥ 2710 · attacco 74 · difesa 46 · velocità 14 · xp 488 · elemento fuoco

**Mosse: 5 su 6 caselle.**

| # | Mossa | Cosa fa | Valore | Quando | Scelta | Ricarica |
| --: | --- | --- | --- | --- | --- | --- |
| 1 | ¡Gran finale! | colpisce **tutta la squadra** | ×0.85 → 63 | sempre | sorteggio | — |
| 2 | ¡Vamos! | ti dà fuoco (9 a battuta) | — | sempre | sorteggio | — |
| 3 | Capote | si chiude (difesa +14 per 2 battute) | — | sempre | sorteggio | — |
| 4 | Llamada | chiama 1 × `maschera_vuota` | — | sempre | sorteggio | — |
| 5 | Fiamma disperata | colpisce **tutta la squadra** | ×1.30 → 96 | sotto il 30% di vita | priorità 7 | 4 battute |
| 6 | — | *casella libera* | — | — | — | — |

**Motto** — quello che si legge in campo quando la mossa parte:

1. ¡GRAN FINALE! Un muro di fiamme spazza tutta l'arena.
2. ¡Vamos! ... Una folata di vento ardente ti infligge lo status in fiamme.
3. Jerah schiva elegantemente tutti i tuoi colpi.
4. Jerah batte il tacco tre volte: dal fumo sale un Fomentado.
5. «Lo spettacolo non finisce finche' non lo decido io.»

**Tecno log**

| Campo | Rilevamento |
| --- | --- |
| Denominazione | L'ultimo spettacolo di Jerah |
| Classificazione | rango calamita' |
| Filogenesi | umana |
| Areale | Il Vuoto Ardente |
| Specie | Umano |
| Stadio | III |
| Morfologia | Adulto, corporatura da ballerino, in abito di scena intatto. La combustione parte dall'interno e non ha ancora consumato il tessuto: e' la parte che non torna. |
| Habitus | In scena, sempre. Anche da solo, anche adesso. |
| Metamorfosi | non osservata |
| Ecologia | Il mondo intero arde, teatro del suo ultimo show. Le altre forme del Vuoto sono comparse. |

*Studi necessari per la pagina intera: 3.*

## Tutti i motti

Ogni frase che una creatura dice in campo, tutte di fila. È la pagina su cui si sente se
parlano con voci diverse — e quali creature non hanno ancora niente da dire.

**Goblin Tipico**

1. Il goblin stringe il bastone con tutte e due le mani e mena alla cieca.
2. «Difesa Goblin!» — e si copre la testa con le braccia.
3. Il goblin capisce che non c'è più niente da perdere, e smette di ragionare.

**Slime Infimo**

1. Lo slime si allunga e lascia una bava che rallenta ogni movimento.
2. Lo slime si raccoglie su se stesso e torna tondo.
3. Si raccoglie tutto da una parte e ti si getta contro.

**Tartaruga Innocente**

1. La tartaruga si ritira nel guscio.
2. La tartaruga si tira dentro il guscio, e dentro il guscio si rimette.

**Infetto Rapido**

1. Arriva addosso prima che tu decida da che parte guardare.

**Nuvola di Marciume**

1. Scende tutta insieme e vi passa sopra.
2. Respiri, e te ne accorgi dopo.

**Zombie Cittadino**

1. Si agita tutto insieme e ti viene addosso.
2. Si infila fra i suoi, e i suoi si chiudono intorno.
3. Si guarda intorno senza alcuno scopo...

**Fomentado**

1. La maschera avvampa: per un istante ha di nuovo un volto.
2. L'ultima fiammata se lo porta via insieme a te.
3. Si sta... esibendo?

**Zombie Mostruoso**

1. Il braccio lungo arriva da dove non te lo aspetti, e passa su tutti e due.
2. Fa girare le braccia lunghe come una macchina che nessuno ha spento.
3. Un rantolo indefinito, che dura troppo.
4. Ooooooouhh...
5. Raccoglie mezzo isolato e lo tira addosso a tutti, un pezzo per volta.

**Oppresso**

1. La ruggine si addensa e si stratifica addosso a quello che resta di lui.
2. Un accumulo di ruggine materializzata ti arriva addosso.
3. Bastaaaaaaaa!

**El Muy Bonito**

1. «Miren!» — e comincia a girare su se stesso con le torce accese.
2. La sua presenza infiamma l'aria.
3. «Se e' l'ultimo, che sia il migliore!»
4. Vamos!
5. Flaaashy... Punch!
6. Flaaashy... Kick!

**Robo Pattuglia**

1. «Noi vogliamo solo il vostro bene!»
2. «Soggetto pericoloso! Rafforzare le difese!»
3. «Vrrr... clank... riparazioni eseguite!»

**Capocantiere**

1. «Quello che stai facendo risulta in una nota.»
2. «AL LAVORO!»

**Emblema dell'oppressione**

1. Sette colpi di ferraglia, uno dietro l'altro, senza mai fermarsi.
2. Si ferma, e per un attimo la ferraglia si rimette a posto da sola.
3. Un vento tagliente, colmo di malvagità, si alza e non cala più.

**Operaio Sfruttato**

1. Tiene stretti i denti e non si sposta di un passo.
2. Vent'anni tutti insieme, e non ne resta niente per dopo.
3. Un colpo di vento concentrato in un urlo.

**Orrore di Meridia**

1. Appoggia il peso da un lato, e il pavimento risponde.
2. Un braccio solo, largo quanto la stanza, che passa sopra tutti.
3. I corpi si rimescolano, e quello che mancava lo prendono da un altro.
4. Si ferma. Guarda il cielo. Non ti sta pensando.
5. Ricade a terra, e la terra non regge.
6. Resta immobile, e quello che si era staccato torna al suo posto.

**Il Divoratore**

1. Le lame girano, prendono, e quello che prendono non torna.
2. Tutto quello che sta nel suo raggio comincia a scivolare verso il centro.

**Ferraglia Urlante**

1. La montagna si sposta di un metro, e un metro basta.
2. Il rumore non e' un rumore: e' una protesta di mille voci saldate insieme.
3. I rottami si richiamano da terra e tornano al loro posto.

**Un goblin terribilmente arrabbiato**

1. Richiamo dei suoi simili: urla nella notte, e un goblin tipico risponde alla chiamata.
2. Furia di un goblin: colpisce alla cieca, urlando.
3. Pugno del vile: un colpo sferrato senza il minimo onore.
4. Capriccio del goblin: si mette a battere i piedi e se la prende con tutto quello che ha intorno. Il suo attacco aumenta.
5. Cattiveria innata: ti sferra tre attacchi deboli di fila.

**Ghoul**

1. Il ghoul morde e non lascia andare: quello che ti toglie se lo tiene.
2. Le unghie sono l'unica cosa che gli e' cresciuta dopo la morte.

**???**

1. Continua a camminare, e continua a colpire. Non e' veloce. Non serve.

**Madre in Lacrime**

1. Piange, e quello che cade taglia.
2. «Non toccarli.» Non c'e' nessuno da toccare.

**Teschio Errante**

1. Si avvicina a scatti, come una fotografia che si muove male.
2. Le orbite ti guardano, e la cosa peggiore e' che ci si vede dentro.

**Diabolo**

1. Due colpi bassi, dati con troppo entusiasmo.
2. Ti imita mentre ti muovi, e ti viene voglia solo di prenderlo.

**Sadico**

1. Non ha fretta. Non ne ha mai avuta.
2. Aspettava questo momento: si china su chi sta peggio.

**Stigma**

1. Ti addosso il peso di una cosa che non hai fatto.
2. Un segno ti resta sulla pelle, e da li' comincia a fare male.

**Abominio Marcio**

1. Qualcosa gli sale su dal petto e ti arriva addosso.
2. Ti stringe, e per un momento non si capisce piu' dove finisci tu.
3. I corpi si rimescolano, e quello che era aperto adesso e' chiuso.

**Titano Zombie**

1. Pugno devastante: il colpo si abbatte con tutto il peso della città morta.
2. Il titano spazza l'aria davanti a sé: nessuno resta in piedi comodo.

**Divoratore di Carcasse**

1. Il divoratore azzanna più volte, veloce.
2. Si volta verso quello che il ponte ha lasciato cadere, e mangia.

**Sacerdote Folle**

1. "Per il viaggio!" Il sacerdote colpisce recitando.
2. "Unisciti al raccolto!" Il sacerdote colpisce recitando.
3. "Portatelo da me!" Il sacerdote colpisce recitando.
4. "Non c'è altra strada!" Il sacerdote colpisce recitando.
5. Il sacerdote alza le braccia: un teschio errante risponde al richiamo.
6. Recita piu' in fretta, e le ferite si chiudono al ritmo delle parole.

**Jongo Dongo**

1. Jongo Dongo affonda l'artiglio marcio con tutto il suo peso.
2. Jongo Dongo cala il bastone dalla pietra marcia: dove tocca, la carne comincia a cedere.
3. "IL VIAGGIO RICHIEDE SEMPRE IL SUO PREZZO!" Il grido vi si conficca dentro più delle unghie.
4. Jongo Dongo si volta verso uno dei suoi ghoul, con la stessa calma di sempre: "Un piccolo sacrificio... per un grande risultato."
5. Jongo Dongo batte il palmo marcio sull'ossidiana: la terra stessa gli restituisce un altro ghoul.
6. Quello che ha fatto marcire lui, adesso lo passa a voi.

**Donna Spinosa**

1. Le spine entrano piano, quasi con gentilezza. Il bruciore arriva dopo.
2. Si apre tutta insieme, e per un metro intorno non si sta.

**Marionetta**

1. Un braccio di legno gira su un perno e arriva duro.
2. I fili non tengono su lei: tengono giu' te.
3. Raccoglie i suoi fili da terra e se li riannoda addosso.

**Jongo Dongo**

1. La mano arriva piano, e non e' piu' una mano.
2. Espira, e l'aria intorno smette di essere aria.
3. Il corpo non dovrebbe reggere. Qualcosa lo tiene su lo stesso.

**Ombra del passato**

1. Ti dice una cosa vera, e detta da lei fa male il doppio.
2. Piu' le pensi contro, piu' si fa solida.

**Un tenero ricordo**

1. La bambola spalanca le cuciture e lancia una manciata di spilli.
2. Un lamento terribile riempie la stanza. I cuori di tutti sobbalzano.
3. La bambola si strappa una cucitura da sola, piano. Fa più male a voi che a lei.
4. Dei fili scendono dal soffitto: una marionetta si alza da terra.
5. Il filo rientra da solo nei buchi, come se qualcuno la stesse ancora rammendando.

**Volto sulla parete**

1. Le radici escono dal pavimento e stringono: dove toccano, la pelle cambia colore.
2. La parete si apre e sputa una nube di spore su tutta la stanza.
3. La parete si muove dietro di lei, e le rida' quello che le hai tolto.

**L'ultimo spettacolo di Jerah**

1. ¡GRAN FINALE! Un muro di fiamme spazza tutta l'arena.
2. ¡Vamos! ... Una folata di vento ardente ti infligge lo status in fiamme.
3. Jerah schiva elegantemente tutti i tuoi colpi.
4. Jerah batte il tacco tre volte: dal fumo sale un Fomentado.
5. «Lo spettacolo non finisce finche' non lo decido io.»

