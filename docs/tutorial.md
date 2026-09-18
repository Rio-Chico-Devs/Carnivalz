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

## 1. Quello che dice la ricerca, con le sue misure

**A favore dell'istruzione esplicita.** «Show or Tell?» (FDG 2024, **75
giocatori**, su *Baba Is You*): i giocatori della versione con tutorial diretto
*«hanno fatto meno errori, hanno percepito una difficoltà minore, hanno dovuto
ricominciare meno spesso e avevano più probabilità di finire tutti i livelli in
venti minuti»*. Conclusione degli autori: **l'istruzione diretta all'inizio porta
a una comprensione pari al learn-by-doing più in fretta, con meno errori, e senza
sacrificare il coinvolgimento.**

**A favore, se il gioco è complesso.** Andersen et al., sopra: +29% di tempo di
gioco nel gioco più complesso, nulla nei due semplici.

**Contro, ma in un altro dominio.** Il MIT ha trovato che l'istruzione esplicita
riduce l'esplorazione spontanea — **in bambini che giocano con un giocattolo**.
È scoperta aperta, non un'interfaccia con una barra di dominio: il transfer non è
scontato.

**Il vincolo che regge davvero** è il carico cognitivo: spezzare invece di
stipare, rivelazione progressiva, e il lettore **scorre e non processa più idee
insieme**. Questo vale in ogni dominio, e non dipende da quale studio si cita.

**Sui JRPG**, che è il parente vero: l'insofferenza dei giocatori è verso *«15-20
minuti di conversazioni statiche una dietro l'altra»*, non verso battute brevi. E
il rimedio che i giocatori citano come buono — Persona — è **poter avanzare a
mano**, cioè esattamente il click che il tutorial di Carnivalz adesso ha.

**Misurare quanto basta.** Avevo scritto «3-7 persone trovano l'80% dei
problemi». È la regola di Nielsen, ed è **contestata**: Faulkner ha mostrato che
cinque persone possono trovarne il 95% *oppure il 55%*, e la varianza è troppo
alta per deciderci qualcosa. Con **10** il minimo sale a 80%, con **20** a 95%.

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
manuale». **Non regge.** Lo studio più recente e più pertinente dice che
l'istruzione diretta all'inizio funziona, e quello più grande dice che serve
proprio nei giochi complessi come questo. 328 parole sono circa **due minuti** di
lettura: lontanissime dai 15-20 minuti che fanno arrabbiare i giocatori di JRPG,
e si avanzano col click.

**Quello che resta in piedi della critica**, più stretto e meglio fondato:

1. **Undici concetti in un blocco solo** sono tanti per la memoria di lavoro, e
   questo il carico cognitivo lo dice a prescindere dal dominio. Non «troppe
   battute»: **troppe idee diverse senza niente in mezzo**.
2. **Le battute più deboli sono quelle non applicabili lì**: il colore dell'ECG e
   lo stress non si possono guardare mentre non succede niente. Quelle tre o
   quattro stanno meglio agganciate al momento in cui accadono.
3. **Va saltabile**, per chi rigioca. Su questo la ricerca è concorde e non
   dipende dal genere.

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
persone», che era la cifra ottimista di ieri: **dieci** per avere almeno l'80%
dei problemi, venti per il 95%. Finora l'unico che gioca è Bru — che è anche
l'autore, cioè la persona al mondo che ha meno bisogno del tutorial, e quindi
l'unica che non può misurarlo.

E una cosa su come ho lavorato, che vale più delle altre. La prima versione di
questo documento era sicura di sé e sbagliata in tre punti, e non se n'è accorta
nessuna prova: se n'è accorto **il fatto di andare a rileggere le fonti invece
che le sintesi**. Lo studio da 45.000 giocatori diceva il contrario di come
l'avevo citato, e per saperlo bastava aprirlo.
