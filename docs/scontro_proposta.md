# La schermata di combattimento: una proposta mia

> Bru: «sapresti aggiustare nel tutto la schermata di combattimento in modo
> migliore? il design era mio ma voglio vederti provare con una tua idea dopo
> tutto quello che abbiamo studiato»

È una **proposta**, e non tocca il gioco. La schermata vera resta quella di Bru
(`docs/schermata_combattimento.md`); questa vive in
`prove/ProposteScontro.tscn` coi suoi pezzi in `prove/scontro/`, ed è fatta coi
pezzi veri del gioco dove servono: il minigioco è la raffica vera
(`MinigiocoCombattimento`, `RiquadroRaffica`, il vetro che si spacca), l'ECG è
`TracciatoEcg`, le icone sono quelle delle statistiche, i colori e i caratteri
sono quelli di `data/stile.json`. Se piace, si porta nel gioco (in fondo, come).

    ./prove/film_scontro.sh      il film (38 s) e sette scatti in scatti/proposte_scontro/
    nell'editor                  prove/ProposteScontro.tscn, F6; TAB salta al momento dopo

---

## 1. Come l'ho guardata

Prima di proporre ho fotografato la schermata di oggi in tutti i suoi momenti
(i comandi, una lista, il racconto della lezione, la raffica, la Mattanza) e ho
riletto quello che abbiamo studiato: le variabili visive di Bertin
(`docs/segni.md`), Persona 5 e Sid Meier (`docs/mestiere.md`,
`docs/lezioni.md`), la leggibilità misurata, il metodo di Bru per le icone
(`docs/metodo_icone.md`), gli effetti di vita (`docs/vita.md`).

## 2. Cosa non funziona oggi, misurato

Misure sulla tela del gioco, 1280×720, dai numeri di `data/stile.json`.

**1. Il posto va a quello che non dice niente.** I tre ritratti dei compagni
sono 244×250 pixel l'uno: un quinto dello schermo, e finché non ci sono i
disegni sono tre iniziali su fondo nero (e un riquadro vuoto). La vita e
l'aura di ognuno - le cose che guardi a ogni colpo - sono barre alte una
dozzina di pixel che galleggiano nell'arancio sotto i ritratti, con «HP» e
«AURA» scritti a dieci. Bertin: solo la **posizione** e la **grandezza** dicono
«quanto»; una barra di dodici pixel lo dice appena.

**2. L'occhio fa lo zig-zag a ogni decisione.** Chi ha il turno sta in alto al
centro, il suo ECG e il suo morale in basso al centro, i suoi comandi in basso
a destra, il bersaglio a sinistra. Per decidere una mossa si attraversa lo
schermo tre volte. Quello che va insieme non sta insieme.

**3. Il quadrante fa quattro mestieri, e per questo è piccolo per tutti.**
Comandi, liste, racconto, minigiochi: 733×257 pixel, uno alla volta. La
raffica gioca lì dentro (dodici pugni in una striscia), il racconto ha tre
righe, la lezione di Veronica ne mostra due e mezza.

**4. La struttura vuota si vede più delle cose.** Lo slot libero, i tre gettoni
grigi degli status quando tutti stanno bene: sono forme grandi che non
misurano niente, e a colpo d'occhio sembrano pulsanti.

**5. Non si vede chi tocca dopo.** Lo scontro va a giri, in ordine di velocità
(`Combattimento.gd`, `Turni.gd`): l'ordine il motore ce l'ha, lo schermo no. È
la domanda che decide se curare adesso o dopo.

## 3. L'anima, col metodo di Bru

Il metodo (`docs/metodo_icone.md`): prima la figura che porta il senso, poi le
domande, i temi accostati, il contorno, come si disegna bello, e il tema del
set; le misure dopo.

- **L'anima.** Un Carnivalz è «una festa per chi ha subito ingiustizie»
  (`docs/storia.md`). Uno scontro è lo spettacolo di quella festa: **il
  manifesto di un incontro**. La creatura è l'attrazione della serata, la
  squadra sono gli sfidanti.
- **Le domande.** Chi è la star? La creatura: è lei che i disegni di Bru
  riempiranno, e il riquadro più grande è il suo. Chi deve decidere? Chi ha il
  turno: tutto quello che gli serve gli sta accanto. Chi guarda? Il giocatore,
  che a ogni momento deve sapere dove guardare.
- **I temi accostati.** I manifesti degli incontri di boxe e di lotta (i nomi
  enormi, il «faccia a faccia», le fasce di traverso), le locandine del luna
  park, i picchiaduro da sala giochi (la barra della vita lunga, lo schermo del
  cabinato), Persona 5 (un colore solo per l'urgenza, le linee che guidano
  l'occhio).
- **Il contorno.** Una diagonale sola che taglia lo schermo dall'alto a destra
  al basso a sinistra: di qua la creatura, di là gli sfidanti.
- **Il set.** Tutti i pezzi hanno il lato su quella diagonale, alla stessa
  pendenza e alla stessa distanza (`prove/scontro/Spina.gd`): il cartellone,
  le schede, il programma, il racconto.

## 4. Tre miniature, e la scelta

Prima di costruire, tre disposizioni a blocchi, giudicate a occhio:

| | com'era | perché no, o perché sì |
|---|---|---|
| A, faccia a faccia | creatura a sinistra, squadra in colonna a destra, i comandi in mezzo | i comandi finivano sopra il disegno della creatura |
| B, cabinato | la vita del nemico in alto come in un picchiaduro, il palco largo al centro, la squadra in basso | chiarissima, il palco più largo per i minigiochi, ma anonima: potrebbe essere qualunque gioco |
| **C, manifesto** | la creatura che sborda, la fascia rossa del nome di traverso, gli sfidanti a scala | aveva un'anima. Le informazioni della squadra però erano piccole |

La proposta è **C**, con dentro le schede leggibili e il palco grande di B.

## 5. La proposta, pezzo per pezzo

**Il cartellone** (`Cartellone.gd`). Lo schermo della creatura: il cabinato del
manifesto (l'ombra piena, il contorno nero, la cornice chiara, il vetro scuro),
in alto a sinistra, col lato destro sulla diagonale. È il riquadro più grande
della schermata, perché la creatura è la star. Quando attacca, lo schermo lo
usa il minigioco.

**La fascia** (`Fascia.gd`). Il nome su una fascia **rossa** di traverso che
entra nel cartellone, come il titolo di un manifesto. È rossa perché qui il
rosso vuol dire una cosa sola - il pericolo - e il pericolo è lei. Sotto, la sua
vita: non più «HP: ???» scritto, ma **una barra vera col pieno coperto da un
tratteggio** finché non la studi. Studiandola il tratteggio se ne va e compare
il numero. Sotto ancora, quello che hai scoperto, sulle strisce nere. Un'orda
porta il suo «×7» accanto al nome, sempre.

**Le schede** (`Scheda.gd`). Una per compagno, di sbieco sulla diagonale. Il
ritratto è piccolo (68 pixel, 112 per chi ha il turno) e le barre sono lunghe e
spesse **dentro** il foglio, ognuna col suo segno (il palloncino, il fuoco
fatuo, la corona). Sul foglio chiaro il pieno è scuro: la vita nera, l'aura
color ruggine, il dominio rosso, sul vuoto chiaro del foglio (una barra piena e
chiara su un foglio chiaro si legge vuota: è la prima cosa che ha mostrato lo
scatto; e col vuoto grigio l'aura stava a 2,7 di contrasto, l'ha trovato la
prova - adesso vita 16, aura 4,6, dominio 3,5). La vita è sempre
scritta; l'aura solo a chi ha il turno, come oggi. Chi ha il turno **fa un
passo avanti** verso la creatura: la scheda si allarga, il ritratto esce dal
foglio inclinato, il nome diventa «TOCCA A TE». Il suo ECG non sta nella
scheda: sta grande in cima ai suoi comandi (qui sotto). Gli status ci sono
sempre ma piccoli, in un angolo: l'icona calma quando stanno bene, come ha
chiesto Bru. La squadra del film è di tre; con un posto libero, il posto è una
striscia bassa: lì andrà il disegno di Bru.

**Il programma** (`Programma.gd`). I comandi di chi ha il turno, sotto le
schede, sulla stessa diagonale: chi decide, la sua aura e i suoi comandi sono
una colonna sola, e l'occhio scende invece di attraversare lo schermo. Fa un
mestiere solo, scegliere. In cima c'è **il monitor di chi decide**: il suo ECG
per tutta la larghezza del programma (la linea è di 419×52 pixel) e sotto,
nello stesso vetro scuro, il morale e lo stress, lo stress in giallo da 50 in
su. Sta fra la scheda di chi decide e i suoi comandi: l'occhio ci passa sopra
scendendo. Le cinque voci a sinistra, e a destra **due righe su
quella che stai guardando**: un nuovo giocatore non sa cos'è SKILL. Nelle
liste, due colonne col costo di ogni mossa nel segno dell'aura; e sulla scheda
il pezzo di barra che spenderesti si fa a righe, col «-5» rosso sopra.
MATTANZA e BOND sono sempre in fondo, spenti finché non sono pronti; quando si
accendono non li copre niente. Quando non tocca a nessuno della squadra il
programma scende fuori dallo schermo.

**La fila del giro** (`FilaGiro.gd`). In alto a destra: «GIRO 1», poi un gettone
per ognuno nell'ordine del giro, quello di adesso più grande e cerchiato, la
creatura in rosso, chi ha già agito più spento. È l'informazione che oggi
manca.

**Il racconto** (`Racconto.gd`). Quello che si dice nello scontro prende il
posto della fascia, sotto la creatura: è la sua didascalia, larga quanto il
cartellone - quattro righe comode invece di tre strette. È il box dei dialoghi
nella sua lingua (il foglio chiaro, il nome sull'etichetta nera, la narrazione
in corsivo). Quando finisce, la fascia torna su.

**Il minigioco.** Quando la creatura attacca, la raffica si stende sul vetro
del suo schermo: 678×426 pixel invece del quadrante di 733×257, cioè una volta
e mezza l'area e alta il 66% in più. E i pugni ti arrivano addosso da dove
arriva lei: è il suo schermo che si spacca. Ogni colpo preso si vede sulla
scheda di chi lo prende, che trema, perde la vita e fa saltare fuori il numero.
Il piano dei pugni è più quadrato del quadrante, e i pugni sono quelli che ci
stanno radi: coprono un terzo del piano, come nella raffica approvata
(`docs/raffica.md`, «Quanto è grande»).

## 6. Il film, momento per momento

| s | momento | cosa si vede |
|--:|---|---|
| 0 | ingresso | il cartellone entra da sinistra, le tre schede da destra, la fila dall'alto (Yhvina ha già agito) |
| 1,6 | tocca a te | la tua scheda avanti, il programma col tuo ECG in cima: ATTACCHI → DIFESA → SKILL, con la spiegazione che cambia |
| 5,4 | la lista | SKILL: Sovraccarico (5), Onda psichica (3): l'aura che spenderesti si fa a righe |
| 9,2 | studio | il racconto prende il posto della fascia |
| 11,4 | la scoperta | la fascia torna, il tratteggio della vita se ne va, compaiono «TETRO» e «COLPISCE A RAFFICA» |
| 13,4 | tocca a lei | la fila passa alla M, lo schermo si accende di rosso due volte, «TOCCA A MARIONETTA» |
| 14,4 | parla | la sua battuta, nella didascalia |
| 17,2 | la raffica | Collisioni infinite sul suo schermo, giocata dalla mano del film (otto parate su dodici); i colpi presi, a turno sulle tre schede |
| 31,8 | tocca a Veronica | la sua scheda avanti, il suo ECG e il suo stress nel monitor; il suo dominio si riempie e MATTANZA si accende |

Le battute («Ballate con me...», «Studi la marionetta...»), le due righe di
spiegazione dei comandi e le note dello studio sono **mie, provvisorie**.

## 7. Cosa resta di Bru, e cosa cambia

Resta tutto quello che la schermata **fa**: le cinque voci e quali aprono una
lista; l'ECG (il colore dice la vita, il movimento lo stress, lo spessore per
chi non distingue i colori); morale e stress di chi ha il turno; il numero
dell'aura solo a chi decide; MATTANZA e BOND che si accendono da soli e non
spariscono mentre scegli; gli status con l'icona calma; il posto libero col
suo disegno; l'orda col suo numero sempre visibile; lo studio che scopre la
creatura; «TOCCA A TE»; un nemico solo, fino a tre compagni; il racconto e i
minigiochi dove c'era il quadrante, cioè nel posto che si prende la scena. E
resta la sua lingua: il manifesto arancio, nero e grigio caldo, le ombre
piene, le etichette inclinate, il cabinato.

Cambia **dove stanno le cose**, e quanto sono grandi.

## 8. Cosa non so, e cosa chiedere a Bru

1. **La diagonale.** È l'idea della proposta. Se non piace, la disposizione
   regge anche dritta - ma perde il «faccia a faccia».
2. **La fascia rossa.** Oggi l'etichetta del nome è nera; nel primo disegno di
   Bru era rossa. Qui è rossa perché il rosso è il pericolo.
3. **Il racconto al posto della fascia.** Mentre qualcuno parla, il nome e la
   vita della creatura escono dallo schermo. Si può tenere la fascia e mettere
   il racconto sopra la creatura, in basso nel suo schermo.
4. **Il minigioco sullo schermo della creatura.** Bru l'aveva messo dove sta il
   racconto; qui sono due posti diversi, perché sono due cose diverse che non
   succedono mai insieme ma vogliono misure diverse.
5. **La fila del giro.** È nuova: serve, o è una cosa in più da leggere?
6. **Le spiegazioni sotto i comandi.** Utili all'inizio; forse da spegnere nelle
   opzioni dopo il tutorial.

## 9. Il secondo giro: i tre appunti di Bru

> Bru, visto il film: «non è male se non fosse per il fatto che ci dovrebbero
> essere 3 personaggi la distribuzione dei pugni è troppo appiccicata e non si
> vede l'ecg»

| l'appunto | com'era | com'è adesso |
|---|---|---|
| tre personaggi | tu, Veronica e un posto libero | tu, Veronica e Yhvina, coi punti vita veri (`data/classes.json`: 100, 160, 130); la fila del giro in ordine di velocità - Yhvina, tu, la marionetta, Veronica; i colpi della raffica presi a turno dai tre. Le schede a riposo sono alte 84, quella di chi decide 118, e il programma comincia a 400 |
| i pugni appiccicati | sullo schermo della creatura (654×358) i pugni erano di 129 pixel: coprivano due terzi del piano e si toccavano | 91 pixel, un terzo del piano, come nella raffica approvata. La regola è nel gioco vero (`Collisioni.lato_pugno`): nel quadrante di oggi il pugno non cambia |
| l'ECG che non si vede | una striscia alta una trentina di pixel dentro la scheda di chi decide | un monitor in cima al programma: la linea è di 419×52 pixel, con morale e stress sotto, nello stesso vetro |

E tre cose viste negli scatti mentre si rifaceva: le barre delle schede a
riposo toccavano il bordo (la corona del dominio finiva sul filo); il «-5»
rosso del costo stava sulla fine della barra dell'aura, adesso sta sul pezzo a
righe che spenderesti; il programma, abbassato durante la raffica, sbucava in
fondo allo schermo.

## 10. La prova

`prova_la_proposta_di_schermata` fa girare tutto il copione a passi fissi e
misura le regole scritte qui, a ogni passo: le schede sulla diagonale (a GOLA
dal cartellone, chi ha il turno un passo avanti e non di più); nessun pezzo
sopra un altro (cartellone, schede, programma, racconto); in ogni momento la
sua cosa (il programma su quando scegli e giù nella raffica, il racconto al
posto della fascia, a Veronica tocca davvero); la raffica giocata e chiusa
prima della fine; il minigioco tutto dentro il vetro, e più grande del
quadrante di oggi; il pieno delle barre sulle schede staccato dal vuoto almeno
3:1. Dal secondo giro anche: la squadra di tre; l'ECG grande almeno 380×50,
acceso e sopra il programma ogni volta che si sceglie; le barre e le loro icone
dentro il foglio della scheda; il costo rosso sul pezzo che si spende; i pugni
nel vetro misurati col raggio che il riquadro disegna davvero (nessuno ne tocca
un altro, e insieme coprono al più un terzo). Verificata rompendo apposta la
proposta in 7 modi, e al secondo giro in altri 11 (fra cui la squadra di due,
l'ECG basso, stretto, spento o sotto il programma come prima, i pugni grandi
come prima): li prende tutti.

## 11. Se piace: come si porta nel gioco

La plancia è già fatta per cambiare disposizione senza toccare lo scontro: chi
ci lavora sopra (il campo, il menu, la voce, i minigiochi) riceve i nodi e non
sa dove stanno (`Plancia.gd`). Il passaggio sarebbe:

1. le misure della nuova disposizione in `data/stile.json`, accanto a quelle di
   oggi, e la diagonale come una misura;
2. `Scheda` al posto di `SlotCompagno` (le barre dentro, il passo avanti col
   turno);
3. il quadrante diviso: il programma (il monitor con l'ECG di chi decide, i
   comandi e le liste) da una parte, il
   minigioco sullo schermo della creatura, il box vero (`BoxTesto`) nella
   didascalia;
4. la fila del giro dai dati di `Turni.gd`;
5. le prove di oggi sulla plancia (che misurano dove stanno le cose) rifatte
   sulle misure nuove, e gli scatti.

Si può fare a pezzi: le schede da sole, per esempio, migliorano la schermata di
oggi anche senza il resto.
