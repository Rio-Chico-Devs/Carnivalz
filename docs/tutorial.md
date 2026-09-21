# Insegnare a giocare

Ricerca fatta su richiesta di Bru («educati su come fare tutorial efficaci, sul
linguaggio che usi, su stratagemmi per godot, come conviene programmarlo e come
si evitano errori»), e poi applicata al tutorial che c'è.

La prima cosa che ha bocciato è il lavoro di ieri.

## 0. Come mi sono sbagliato, e come me ne sono accorto

Bru: «approfondisci le ricerche mai essere sicuri di se stessi». Aveva ragione a
dirlo su questo documento, perché la prima versione conteneva tre errori miei.

**Ho generalizzato da ricerca sbagliata.** Quasi tutte le regole che avevo citato
— «gameplay entro 60 secondi», «i modali sono un anti-pattern», «7 utenti su 10
abbandonano nella prima settimana» — vengono da **onboarding mobile e SaaS**,
dove l'economia è opposta: utenti gratuiti che se ne vanno con un tap, e la
metrica è la ritenzione a un giorno. Carnivalz è un RPG narrativo, con un
personaggio che parla: chi lo apre ha già deciso di leggere.

**Ho letto uno studio al contrario.** Avevo citato Andersen et al. (CHI 2012,
**oltre 45.000 giocatori**) come argomento contro i tutorial. Dice l'opposto: i
tutorial aumentano il tempo di gioco **fino al 29% nel gioco più complesso**, e
non servono nei giochi le cui meccaniche *«si possono scoprire
sperimentando»*. Carnivalz ha aura, dominio, ECG, stress, otto status, Mattanza
e una ricarica in tempo reale: non si scopre sperimentando.

**Ho preso uno studio pilota per una prova.** Lo studio sui tutorial impliciti su
cui mi appoggiavo ha **47 partecipanti**, ed è gli autori stessi a scrivere che
*«c'erano solo tre giocatori inesperti nella versione esplicita, il che potrebbe
aver reso certi risultati accidentali»*. L'ho citato come se fosse assodato.

## 0-bis. Il quarto errore, che è dentro la correzione del secondo

Bru mi ha procurato il PDF (`docs/fonti/chi2012-tutorial-complessita.pdf`),
perché da qui quel dominio risponde 403. L'ho letto tutto, non la sintesi.

La correzione che avevo scritto sopra — «dice l'opposto, i tutorial aumentano il
tempo di gioco fino al 29%» — **è giusta**. Ma nel farla ho fatto lo stesso
sbaglio in direzione opposta: ho usato quello studio come se autorizzasse la
lezione di Veronica. **Gli autori dicono espressamente di no.**

**Loro scrivono, in conclusione:** *«i nostri giochi non sono rappresentativi
dei giochi commerciali, e di conseguenza non possiamo trarre alcuna conclusione
sull'efficacia dei tutorial nei giochi che i giocatori devono comprare.»* I tre
giochi (Refraction, Hello Worlds, Foldit) sono gratuiti e si aprono in un
browser o si scaricano: chi li prova non ha investito niente. Carnivalz sì.

**E c'è di peggio, per il tutorial che ho scritto.** La loro Ipotesi 3 era che
togliere libertà al giocatore per concentrare l'attenzione su un elemento
dell'interfaccia migliorasse l'apprendimento — la tecnica *stenciling* di
Kelleher e Pausch, usata da Plants vs. Zombies, SimCity 4, CityVille. Risultato:

> *«Non abbiamo trovato prove a sostegno della pratica di limitare la libertà
> del giocatore allo scopo di concentrare la sua attenzione su determinati
> oggetti dell'interfaccia. […] Può anche essere che ai giocatori non piaccia
> vedersi limitare la libertà, e che questo annulli gli effetti positivi
> sull'apprendimento.»*

**La lezione di Veronica fa esattamente quello**: blocca il menu sull'azione
richiesta e illumina un pezzo solo dello schermo per volta.

Tre cose vanno dette, e nessuna cancella il colpo:

1. **Misurano un'altra cosa.** Le loro variabili sono livelli completati, tempo
   di gioco e tasso di ritorno: **coinvolgimento**, non comprensione. Kelleher e
   Pausch, che misuravano l'apprendimento, hanno trovato il contrario — con gli
   Stencils gli utenti finivano *«più in fretta e con meno errori»*. I due studi
   non si contraddicono: rispondono a domande diverse.
2. **Hanno provato solo testo e figure.** Lo scrivono: *«anche se i tutorial dei
   videogiochi includono spesso audio, animazioni e video, noi abbiamo esaminato
   soltanto tutorial fatti di immagini e testo.»* La lezione di Veronica è un
   personaggio che parla e un'interfaccia che pulsa. È fuori dal loro campione.
3. **Il blocco qui è anche narrativo.** Veronica non è un cartello: è un
   personaggio che ti dà ordini in una sala di allenamento. — Questa terza però
   **è una mia giustificazione, non una prova**: non ho nessuno studio che la
   sostenga, e va trattata come un'ipotesi da verificare guardando qualcuno
   giocare.

**Cosa cambio, concretamente:** niente, per ora, nel codice — ma la lezione non
si appoggia più a questo studio. E il blocco del menu passa da «scelta fondata»
a **scelta da verificare**, prima nella lista delle cose da guardare in un
playtest vero.

*(Quando ho scritto questa riga pensavo che restasse «Show or Tell?» a reggere.
Poi ho letto anche quello: §0-ter.)*

**Un'ultima riga dallo stesso studio**, che vale come avvertimento generale: il
pulsante di aiuto su richiesta — la cosa che sembra sempre gratis da aggiungere —
in Refraction ha **ridotto i progressi del 12% e il tempo di gioco del 15%**.
Aggiungere un modo di chiedere aiuto non è neutro.

## 0-ter. E poi è caduto anche l'altro puntello

Bru ha procurato anche «Show or Tell?» e Faulkner — le due fonti su cui, tolto
Andersen, reggeva tutto il resto. Lette per intero, tolgono altro.

### «Show or Tell?» non dice quello che gli ho fatto dire

Avevo scritto che è «lo studio più recente e più pertinente» e che dice che
«l'istruzione diretta all'inizio funziona». Gli autori dicono una cosa più
stretta, e in un punto dicono l'opposto:

> *«Non vediamo alcuna differenza fra i gruppi nella comprensione delle
> meccaniche di base del gioco, indipendentemente dal metodo usato per
> trasmetterla.»*

E, sulla raccomandazione:

> *«Non stiamo suggerendo che questo sia l'approccio migliore, dato che i
> giocatori hanno capito le meccaniche altrettanto bene in tutte le versioni.»*

> *«Questo suggerisce che il modo in cui i designer costruiscono i livelli
> iniziali di un gioco può essere fatto **in qualunque maniera desiderino**,
> senza alcuna alterazione dell'esperienza che i giocatori avranno.»*

**Quello che lo studio mostra davvero** è più modesto e resta in piedi: con il
tutorial esplicito i giocatori hanno avuto *«una vita più facile»* nei primi
sette livelli — difficoltà percepita più bassa, meno annullamenti e riavvii,
più probabilità di finire in venti minuti. **Non** hanno imparato meglio, e
**non** si sono annoiati di più.

**Due cose che gli autori stessi mettono nel conto.** Primo, una randomizzazione
andata storta: *«i giocatori della versione con tutorial hanno incidentalmente
ottenuto punteggi più bassi sull'esperienza di gioco generale, nonostante le
condizioni fossero assegnate a caso»* — cioè il gruppo favorito era anche quello
meno esperto. Secondo, e per Carnivalz è quello che conta:

> *«Questo studio non mostra, tuttavia, che i giocatori del tutorial siano più
> preparati ad affrontare contenuti più impegnativi senza una guida esplicita.»*

**È esattamente la promessa che fa la lezione di Veronica.** Non è smentita: non
è misurata, da nessuno dei due studi che avevo citato.

### Faulkner: avevo sbagliato un numero, e avevo perso quello importante

Avevo scritto «cinque persone possono trovarne il **95%** oppure il 55%». Il 95%
non è di lì: è il *minimo* a venti utenti. La Tabella 2 dello studio — 60 utenti
veri, campionati a caso in gruppi da 100:

| utenti | minimo trovato | media | dev. std. |
|---:|---:|---:|---:|
| 5 | **55%** | 85,55% | 9,30 |
| 10 | 82% | 94,69% | 3,22 |
| 15 | 90% | 97,05% | 2,12 |
| 20 | **95%** | 98,40% | 1,61 |
| 30 | 97% | 99,00% | 1,13 |
| 50 | 98% | 100% | 0 |

Il numero che avevo perso è **la media a cinque: 85,55%**. Cioè in media cinque
persone bastano davvero. Il problema non è la media, è **il pavimento**: la
stessa procedura può darti il 99% o il 55%, e **non c'è modo di sapere quale
delle due ti è capitata**. Con dieci il pavimento sale a 82%, con venti a 95%.

Faulkner chiude con una riga che vale per come lavoriamo qui: *«l'argomento più
forte per fare test di usabilità non è che si può fare a poco prezzo con cinque
utenti, ma che le conseguenze di non trovare i problemi sono abbastanza gravi da
giustificare l'investimento».*

## 1. Quello che dice la ricerca, con le sue misure

**L'istruzione esplicita non costa niente, e leviga l'inizio.** «Show or Tell?»
(FDG 2024, **75 giocatori**, su *Baba Is You*): con il tutorial diretto i
giocatori hanno percepito una difficoltà minore, hanno dovuto annullare o
ricominciare meno spesso, e avevano più probabilità di finire tutti i livelli in
venti minuti. **Ma hanno capito le meccaniche esattamente quanto gli altri**, e
gli altri non si sono annoiati di più (§0-ter). Quindi non è un argomento «a
favore»: è un argomento che dice **che la scelta è quasi gratis**.

**A favore, se il gioco è complesso** — ma vale per i giochi gratuiti. Andersen
et al., sopra: +29% di tempo di gioco nel gioco più complesso, nulla nei due
semplici; e **+40% di livelli completati** quando l'informazione arriva nel
momento in cui serve invece che in un manuale all'inizio. Il transfer ai giochi
a pagamento lo escludono loro (§0-bis), quindi qui tengo solo la parte che non
dipende dal prezzo: **l'informazione va data attaccata al momento in cui si usa**.

*(Qui c'era uno studio del MIT sull'istruzione esplicita che riduce
l'esplorazione in bambini che giocano con un giocattolo. L'ho tolto: fra la
psicologia dello sviluppo e una barra di dominio non c'è nessun transfer, e
tenerlo era solo un modo di sembrare più documentata di quanto fossi.)*

**Il vincolo che regge davvero** è il carico cognitivo: spezzare invece di
stipare, rivelazione progressiva, e il lettore **scorre e non processa più idee
insieme**. Questo vale in ogni dominio, e non dipende da quale studio si cita.

**Sui JRPG**, che è il parente vero: l'insofferenza dei giocatori è verso *«15-20
minuti di conversazioni statiche una dietro l'altra»*, non verso battute brevi. E
il rimedio che i giocatori citano come buono — Persona — è **poter avanzare a
mano**, cioè esattamente il click che il tutorial di Carnivalz adesso ha.

**Misurare quanto basta.** Avevo scritto «3-7 persone trovano l'80% dei
problemi». È la regola di Nielsen, ed è **contestata**: Faulkner (60 utenti) ha
mostrato che cinque persone ne trovano **in media l'85,5%** — quindi la regola
non è sbagliata *in media* — ma che la stessa procedura può dare il **99%
oppure il 55%**, e non si può sapere quale delle due è capitata. Il rimedio non
è diffidare della media, è **alzare il pavimento**: con dieci persone il caso
peggiore sale a 82%, con venti a 95% (tabella in §0-ter).

## 2. Il verdetto sul tutorial di Carnivalz, corretto

La struttura è giusta: sette passi, ognuno chiede un'azione e la commenta.

| passo | azione | battute prima | battute dopo |
|---|---|---|---|
| **0** | **attacca** | **21** | 1 |
| 1 | abilita | 3 | 3 |
| 2 | difendi | 2 | 1 |
| 3 | oggetto | 2 | 1 |
| 4 | minigioco | 2 | 1 |
| 5 | abilita | 3 | 3 |
| 6 | oggetto | 3 | 4 |

Ieri avevo scritto che le 21 battute del passo 0 erano «l'anti-pattern da
manuale». **Non regge lo stesso**, ma non per le ragioni che avevo dato: 328
parole sono circa **due minuti** di lettura, lontanissime dai 15-20 minuti che
fanno arrabbiare i giocatori di JRPG, e si avanzano col click.

**Tutti e due i puntelli sono caduti.** Andersen non si può generalizzare a un
gioco che si compra (§0-bis); «Show or Tell?» dice che la comprensione è uguale
comunque e che i livelli iniziali *«si possono fare in qualunque maniera si
desideri»* (§0-ter). Resta in piedi una cosa sola, ed è di peso: **il carico
cognitivo**, che non dipende da quale studio si cita.

E resta una conclusione pratica che vale più di quelle che ho perso: **se la
scelta è quasi gratis in termini di apprendimento e coinvolgimento, allora va
decisa sul FEEL del gioco** — cioè è una scelta tua, non una domanda di
ricerca. La ricerca dice solo che non stai pagando niente a farla a modo tuo.

**Ma il punto 2 qui sotto adesso pesa il doppio.** Andersen misura +40% di
livelli quando l'informazione arriva in contesto invece che in un blocco
iniziale, e quella è l'unica parte del suo risultato che non dipende dal fatto
che i suoi giochi siano gratuiti. Le battute del passo 0 che parlano di cose che
in quel momento non succedono sono proprio il caso che quello studio punisce.

**Quello che resta in piedi della critica**, più stretto e meglio fondato:

1. **Undici concetti in un blocco solo** sono tanti per la memoria di lavoro, e
   questo il carico cognitivo lo dice a prescindere dal dominio. Non «troppe
   battute»: **troppe idee diverse senza niente in mezzo**.
2. **Le battute più deboli sono quelle non applicabili lì**: il colore dell'ECG e
   lo stress non si possono guardare mentre non succede niente. Quelle tre o
   quattro stanno meglio agganciate al momento in cui accadono.
3. **Va saltabile**, per chi rigioca. Su questo la ricerca è concorde e non
   dipende dal genere.
4. **Il blocco del menu è da verificare, non da dare per buono** (§0-bis). È la
   prima cosa da guardare quando qualcuno che non è Bru proverà il tutorial: se
   la gente lo subisce invece di seguirlo, si toglie.

Quindi: **non spostare tutto**. Spostare le tre o quattro battute che parlano di
cose che in quel momento non si vedono, lasciare il resto, e aggiungere un modo
di saltare. È un intervento molto più piccolo di quello che avevo proposto ieri.

## 3. Come è programmato, e cosa lo rende fragile

Lo stato del tutorial oggi è **un mucchio di variabili**: `tutorial_passo`,
`tutorial_passi_introdotti`, `tutorial_finito`, `lezione_in_corso`, più
`menu_acceso` e `tempo_fermo` che lo toccano da fuori.

La ricerca su Godot dice esattamente cosa costa: *«il pattern comincia a
ripagarsi intorno al quarto o quinto stato, o la prima volta che due booleani
sono entrambi veri quando non dovrebbero.»*

**Ed è già successo.** Il difetto di ieri — l'introduzione di un passo scritta
dentro il giro delle battute, mentre il giocatore riceve il turno da un'altra
parte — è esattamente un passaggio di stato avvenuto per una strada che non lo
sapeva. Con gli stati espliciti (*spiegando → in attesa dell'azione → commento →
passo seguente*) quella porta non esisterebbe.

## 4. Le trappole di GDScript che ci riguardano

- **Non si può sapere se una funzione è una coroutine** senza leggerla, e *«non
  aspettare coroutine perché non si sapeva che lo fossero ha causato molti
  bug»*. **Misurato qui: 16 funzioni contengono `await`, e 10 nomi vengono
  chiamati senza `await` da 23 punti.** Quasi tutte di proposito (`esegui_scontro`,
  `pompa_messaggi`), ma non c'è modo di distinguere le volute dalle dimenticate
  se non leggendo.
- **Mai `await` dentro `_process`**: fa saltare fotogrammi e sdoppiare azioni.
- **`await` su un segnale di un nodo liberato non torna mai**, in silenzio. E
  GDScript **non verifica il nome del segnale**: un refuso è un blocco muto.

## 5. Quello che manca al mio metodo

Le prove guardano lo stato. Ieri lo scatto ha visto in un colpo quello che
34.000 verifiche non vedevano, perché **nessuna guardava il pannello**.

E manca la cosa che conta di più: **guardare qualcuno giocare**. Non «3-7
persone», che era la cifra ottimista di ieri: **dieci** perché anche il caso
peggiore trovi l'82% dei problemi, venti per il 95%. Finora l'unico che gioca è Bru — che è anche
l'autore, cioè la persona al mondo che ha meno bisogno del tutorial, e quindi
l'unica che non può misurarlo.

E una cosa su come ho lavorato, che vale più delle altre. La prima versione di
questo documento era sicura di sé e sbagliata in tre punti, e non se n'è accorta
nessuna prova: se n'è accorto **il fatto di andare a rileggere le fonti invece
che le sintesi**. Lo studio da 45.000 giocatori diceva il contrario di come
l'avevo citato, e per saperlo bastava aprirlo.
