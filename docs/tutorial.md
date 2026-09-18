# Insegnare a giocare

Ricerca fatta su richiesta di Bru («educati su come fare tutorial efficaci, sul
linguaggio che usi, su stratagemmi per godot, come conviene programmarlo e come
si evitano errori»), e poi applicata al tutorial che c'è.

La prima cosa che ha bocciato è il lavoro di ieri.

## 1. Quello che dice la ricerca

**Si impara facendo, non leggendo.** *«Se il tutorial non è molto corto e
semplice, i giocatori faticano a capire e ricordare concetti che non hanno
applicato.»* La lezione conta quando il giocatore la mette in pratica subito.

**Una cosa per volta, in un posto senza rischio.** Il manuale dell'onboarding:
insegnare *il minimo insieme di controlli, un meccanismo alla volta*, e lasciare
che il giocatore lo provi a bassa posta prima di alzare la pressione.

**Presto, e poco.** *«Gameplay entro 60 secondi, il momento "ah ecco" entro 90,
un giro introduttivo di due passi o meno.»* E: *«se insegni troppo troppo
presto, la ritenzione cala, perché il giocatore si sente esaminato prima di
sentirsi ricompensato.»*

**I modali sono un anti-pattern.** Una finestra che impedisce di interagire
finché non la chiudi interrompe e costringe. *«Un onboarding obbligatorio è
l'affermazione che tu sai meglio del giocatore come deve imparare.»*

**Mario 1-1 insegna senza una parola.** Niente testo: spazio negativo, segnali
visivi, cicli di tentativi corti. La regola non è «scrivi meglio le istruzioni»,
è **«fai in modo che non servano»**.

**E misurare non è «quanti hanno finito».** *«"Il tutorial lo completa il 70%"
dice meno di "il 12% se ne va al passo tre" — il secondo ti dice cosa
aggiustare.»* Bastano **3-7 giocatori** per vedere l'80% dei problemi.

### Il linguaggio

- **Spezzare invece di stipare**: non schiacciare tutti i vincoli in un
  suggerimento solo.
- **Rivelazione progressiva**: il contesto essenziale subito, il resto a
  richiesta.
- **Verbo + oggetto**: «Colpisci la creatura», non «È possibile colpire».
- Il lettore **scorre**, non legge, e **non processa più idee insieme**.

## 2. Il verdetto sul tutorial di Carnivalz

La struttura è **già quella giusta**: sette passi, ognuno chiede un'azione e la
commenta dopo. È esattamente «una cosa per volta, provandola».

Poi ieri ci ho messo la lezione sulla schermata, e l'ho messa tutta nel primo
passo:

| passo | azione | battute prima | battute dopo |
|---|---|---|---|
| **0** | **attacca** | **21** | 1 |
| 1 | abilita | 3 | 3 |
| 2 | difendi | 2 | 1 |
| 3 | oggetto | 2 | 1 |
| 4 | minigioco | 2 | 1 |
| 5 | abilita | 3 | 3 |
| 6 | oggetto | 3 | 4 |

**328 parole e undici concetti prima che il giocatore possa premere qualunque
cosa** — HP, aura, dominio, ECG, morale, stress, cinque voci di menu, la difesa
cumulativa, la Mattanza, il tempo reale. Nessuno di quegli undici è applicabile
mentre lo si sente. E il mondo è fermo: è un modale, cioè l'anti-pattern.

Gli altri sei passi sono **ben tarati**: 2-3 battute, un'azione, un commento.
Il difetto è tutto e solo nel passo 0, e l'ho introdotto io.

### La proposta

Non buttare niente — Bru ha chiesto che **ogni componente venga spiegato**, e
resta giusto. Cambiare **quando**:

1. **Prima del primo pugno restano 3-4 battute**: chi hai davanti, che la sua
   scheda è coperta, e che si colpisce cliccandola. Il resto no.
2. **Ogni pezzo si spiega nel passo in cui serve.** L'aura nel passo
   dell'abilità (c'è già). La difesa cumulativa nel passo della difesa (c'è
   già). La Mattanza quando la barra è piena (c'è già). **I passi esistono
   già: le battute vanno spostate lì dentro.**
3. **Quello che non ha un passo** — ECG, morale, stress, ricarica — si dice
   **quando succede**: la prima volta che la linea diventa gialla, la prima
   volta che la ricarica ti ferma. Sono agganci nuovi, ma piccoli.
4. **Saltabile.** Un tutorial che non si può saltare è una mancanza di rispetto
   verso chi rigioca.

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

E manca la cosa che la ricerca mette per prima: **guardare qualcuno giocare**.
Bastano 3-7 persone per l'80% dei problemi di prima esperienza — e finora
l'unico che gioca è Bru, che è anche l'autore, cioè la persona al mondo che ha
meno bisogno del tutorial.
