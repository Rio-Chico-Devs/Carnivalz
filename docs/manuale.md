# Manuale dei personaggi — da correggere

> **Questo file è tuo: scrivici sopra.** È l'unico documento del progetto fatto per essere
> modificato a mano e rimandato indietro. Non lo rigenera nessuno strumento, quindi quello che
> scrivi resta.
>
> **Come segnare le correzioni** — vanno bene tutte e tre, usa quella che ti viene comoda:
> - riscrivere direttamente sopra il testo che non va;
> - aggiungere una riga che comincia con `>>` per un commento a margine;
> - lasciare `???` dove non hai deciso.
>
> Quando me lo rimandi lo leggo riga per riga e applico. Dove la tua correzione contraddice il
> codice te lo dico invece di scegliere da solo.

---

## 1. I cinque tipi

L'asse che decide efficacia e resistenze. Uno solo, non due.

| Tipo | Cosa ci sta dentro | Specie che ci ricadono |
| --- | --- | --- |
| **Natura** | Quello che è nato così ed è rimasto vivo | Goblin, Ferino, Flora, Tartaruga, Slime |
| **Artificio** | Costruito da qualcuno, e ancora acceso quando non serve più | Robot, Automa, Golem |
| **Spirituale** | Un corpo che regge qualcosa che non è più suo | Zombie, Feticcio |
| **Speciale** | Non ha categoria e non ne vuole una | Onirico, Nimbo, Indeterminato |
| **Tetro** | Nasce dal rancore e dal buio. È il tipo delle fonti | Ombra, Incarnazione |

**Come funziona in campo:** tre valori soli, come già funzionano le resistenze —
`normale` · `ipersensibile` (pesa di più) · `immune` (non arriva).

### Decisione che aspetta te

Oggi il gioco ha **due** assi che fanno un lavoro simile: `elemento` (fuoco, veleno, oscuro,
elettrico, psico — su 16 creature) e `filogenesi` nel tecno log (naturale, meccanica, umana…).

La mia proposta: **i cinque tipi sostituiscono l'elemento**; la filogenesi resta dov'è perché è
narrativa — dice da che corpo viene, non contro cosa è forte.

`>>` scrivi qui se la vedi diversa:

---

## 2. Gli otto status

Per ognuno: **la tua definizione**, e sotto **cosa fa oggi il motore**.

### Terrore
- **Tu:** indebolimento temporaneo del personaggio e impossibilità di fare critico.
- **Oggi:** esiste ma fa un'altra cosa — alza lo stress di 40 e abbassa il legame di 15. Non blocca
  i critici e non indebolisce.
- **Da decidere:** di quanto indebolisce? `???`

### Fiamme
- **Tu:** danno continuo ogni turno. È il danno nel tempo più forte.
- **Oggi:** il meccanismo esiste (`combustione`, lo usano tre creature) ma **non è uno status**: sta
  fuori da `stati.json`, quindi non si cura, non si resiste, non compare nella scheda.
- **Da decidere:** quanto danno a turno? Quanti turni dura, o finché non ti curi? `???`

### Tossina
- **Tu:** indebolimento temporaneo e leggeri danni ogni turno, meno di Fiamme.
- **Oggi:** si chiama `veleno` ed è **crescente** — il danno aumenta ogni turno, quindi col tempo
  supera le Fiamme invece di restare sotto.
- **Da decidere:** quanto danno a turno, e cosa indebolisce? `???`

### Sonno
- **Tu:** immobile per massimo 3 turni, con possibilità casuale di svegliarsi dal secondo in poi.
- **Oggi:** esiste come «salta turno», senza tetto e senza risveglio.
- **Da decidere:** che probabilità di svegliarsi? Un colpo subìto sveglia? `???`

### Maledizione
- **Tu:** conto alla rovescia basato sulla resistenza alle maledizioni. Parte da **10**; un attacco
  che dà 3 punti ti porta a 7. A **zero vai KO** e non puoi essere rianimato con oggetti fino alla
  fine del combattimento.
- **Oggi:** è un contatore di **turni** (parte da 9 e scala da solo), non una riserva consumata
  dagli attacchi. Il KO che ne segue è normale: gli oggetti funzionano.
- **Da decidere:** la riserva si ricarica a fine scontro o resta bassa? La resistenza alza il 10 di
  partenza o riduce i punti che ricevi? `???`

### Rabbia
- **Tu:** attacchi soltanto, non puoi usare mosse.
- **Oggi:** è esattamente `berserk`, già implementato. **Basta rinominarlo.**
- **Da decidere:** quanti turni dura? `???`

### Provocato
- **Tu:** puoi attaccare solo il nemico che ti ha provocato.
- **Oggi:** la Provocazione esiste come **abilità tua** (costa 3 aura). Come status **subìto** non
  esiste: nessuna creatura può provocarti.
- **Da decidere:** dura a turni, o finché quel nemico è vivo? `???`

### Frastornato
- **Tu:** puoi solo attaccare, e i bersagli sono casuali.
- **Oggi:** `confusione` fa già i bersagli casuali, ma non impedisce di usare le mosse.
- **Da decidere:** quanti turni? `???`

### Gli altri due che restano

**Lentezza** e **Rapidità** (velocità ∓2). Servono anche alle armi. Congelamento e Decomposizione
sono stati tolti.

---

## 3. Anatomia di un personaggio

Tutti i campi scrivibili. Quelli con `·` sono facoltativi.

### Identità

| Campo | Tipo | Cosa fa |
| --- | --- | --- |
| `id` | testo | Nome interno. **Deve dire chi è**: cercare «Oppresso» e non trovarlo è il punto in cui si sbaglia creatura |
| `nome` | testo | Come si legge a schermo |
| `nome_breve` · | testo | Per la scheda in combattimento, se il nome è lungo |
| `descrizione` | testo | La riga in corsivo sotto il nome nel bestiario |
| `ritratto` | percorso | `res://art/personaggi/….png` |
| `livello` | intero | Il suo livello base |
| `ruolo` | enum | `comune` `veloce` `corazzato` `particolare` `miniboss` `fonte` — decide tutte le statistiche |
| `tipo` | enum | Uno dei cinque |

### Statistiche

> Normalmente **non si scrivono**: escono dalla curva del ruolo (`data/ruoli.json`), così
> ricalibrare tutto il gioco è una riga sola. Scriverle a mano è un'eccezione che **deve dichiarare
> il perché** in un campo `fuori_curva` — e una prova lo pretende.

| Campo | Cosa fa |
| --- | --- |
| `hp` `attacco` `difesa` `velocita` | Se presenti vincono sulla curva |
| `fattore_base` | Quanto arde in lei: alimenta critici e Slaughter |
| `resistenze` | Per tipo o per status: `normale` `ipersensibile` `immune` |
| `scala_col_giocatore` | `false` = resta esattamente com'è (la Tartaruga) |
| `invincibile` | Non muore mai: si rialza sempre |
| `rinascita` | Torna in piedi **una volta sola**, a una quota di vita |

### Comportamento e contenuti

| Campo | Cosa fa |
| --- | --- |
| `mosse` | **Sempre sei caselle**, anche vuote |
| `studio` | Domande e risposte dello Studia: è la sua voce |
| `risparmio` | Se c'è, si può risparmiare invece di abbatterla |
| `bottino_comune` | Oggetti con probabilità |
| `drop_raro` · `carta` | Il pezzo raro, e la carta da collezione |
| `combustione` | Brucia a ogni sua battuta, da subito o dopo N studi |
| `frenesia` · `mossa_disperazione` | Comportamenti speciali dei boss |

---

## 4. Anatomia di una mossa

124 mosse scritte finora. Ogni creatura ne ha sei caselle.

```json
{
  "id": "falciata",                  // identificativo, unico nella creatura
  "nome": "Falciata",                // come compare nelle tabelle
  "testo": "Il braccio lungo…",      // LA FRASE CHE SI LEGGE IN CAMPO
  "tipo": "attacco_forte",           // uno dei 20 tipi del motore
  "quota": 1.5,                      // ×1,5 il suo attacco ATTUALE
  "quota_a_terra": 2.6,              // · sale mentre lei cala di vita
  "valore": 23,                      // · numero fisso: eccezione dichiarata
  "colpi": 20,                       // · per attacco_multiplo
  "stati": ["frastornato", "rabbia"],// · cosa lascia addosso
  "quando": { "vita_sotto": 0.3 },   // · a quale condizione ESISTE
  "priorita": 7,                     // · >0 = la SCEGLIE invece di sorteggiarla
  "peso": 2,                         // · peso nel sorteggio
  "ricarica": 3,                     // · sue battute di attesa
  "massimo_usi": 2,                  // · tetto per scontro
  "telegrafata": true,               // · si annuncia una battuta prima
  "costo_vita": 0.25                 // · quanto costa a chi la tira
}
```

### I venti tipi di mossa

| Tipo | Cosa fa | Tipo | Cosa fa |
| --- | --- | --- | --- |
| `attacco_forte` | colpo singolo | `potenziamento` | più statistiche insieme, anche agli alleati |
| `attacco_tutti` | tutta la squadra | `modalita` | forma che lavora N battute |
| `attacco_multiplo` | N colpi a caso | `trasformazione` | dopo N battute diventa un'altra creatura |
| `spezza_guardia` | azzera gli scatti | `tormento` | danno a tutti ogni loro battuta finché non cade |
| `rubavita` | colpisce e si cura | `evoca` | chiama alleati, tetto 3 |
| `meta_vita` | metà della vita attuale | `stato` | applica uno o più stati |
| `cura` | quota della vita massima | `sacrificio` | uccide un evocato per potenziarsi |
| `difendi` | alza la guardia | `scena` | non fa niente, ed è dichiarato |
| `incendia` | dà fuoco a uno | `autolesione` | si ferisce, e la squadra ne risente |
| `buff_attacco` | alza il suo attacco | `buff_difesa` | alza la sua difesa |

### Le condizioni disponibili

Dentro `quando`. Una mossa fuori condizione **non entra nemmeno nel sorteggio**.

| Chiave | Vera quando |
| --- | --- |
| `vita_sotto` · `vita_sopra` | La sua vita è sotto/sopra una quota |
| `bersaglio_vita_sotto` | Qualcuno di là è ridotto male |
| `alleati_almeno` · `alleati_al_massimo` | Quanti dei suoi sono in piedi |
| `battuta_almeno` | Non prima della sua N-esima battuta |
| `senza_stato` | Solo se non ha già quello stato |
| `dopo_mossa` | Solo dopo che ha usato quell'altra mossa |
| `dopo_rinascita` | Solo dopo essere tornata in piedi |

---

## 5. L'albero di abilità

Una **linea** è un'abilità che cresce di grado. Chi conosce un grado non conosce gli altri: nel menu
ne compare uno solo, il più alto sbloccato.

| Linea | Gradi | Da lv | Cosa fa |
| --- | --: | --: | --- |
| **Annichilazione** | 6 | 19 | Meno danno di un colpo normale, ma se il nemico è già a terra metà delle volte non si rialza |
| **Flagello** | 6 | 11 | Il danno di un colpo spezzato in venti aghi su tutti. Ognuno può fare critico o andare a vuoto |
| **Mantra** | 6 | 14 | Svuota la barra di dominio su di te: difesa e attacco salgono, lo stress cala. Quanto era piena, tanto rende |
| Sciolte | 9 | 0-25 | Provoca, Astio, Vendetta, Pietà, Mattanza, Studio, Anonimato, Sovraccarico, Spezza spazio |

```json
"annichilazione_ii": {
  "nome": "Annichilazione II",
  "linea": "annichilazione",     // a quale linea appartiene
  "grado": 2,                    // sostituisce il grado 1 nel menu
  "livello": 29,                 // livello minimo per aprirlo
  "costo": 1,                    // punti abilità
  "richiede": "annichilazione",  // · nodo da prendere prima
  "aura": 7,                     // quanto costa usarla in campo
  "frazione_danno": 0.75,        // parametri specifici del tipo
  "testo_uso": "…",              // la frase quando parte
  "descrizione": "…"             // quello che legge il giocatore
}
```

> **Difetto bloccante:** i punti arrivano dal livello **25**, uno ogni 4. La demo finisce a Jerah,
> livello **18**. Così com'è nella demo l'albero non si vede mai. E i punti sono **solo del
> protagonista**.

### Il percorso di crescita — da progettare insieme

Deciso: le statistiche salgono spendendo, come nella Sferografia — **ma non facciamo una
sferografia**. Serve un percorso nostro. Le domande da sciogliere, per quando ci ragioniamo:

- **Che forma ha?** Linea, albero a rami, griglia, anelli concentrici?
- **Si torna indietro?** Un ramo sbagliato si può ripensare, o la scelta pesa per sempre?
- **Le otto classi sono otto rami** dello stesso percorso, o otto percorsi separati?
- **I compagni hanno lo stesso percorso** con nodi diversi, o forme diverse?
- **Quanti punti in tutto** fino a Jerah, e quanti nodi devono restare chiusi a fine demo?

`>>` scrivi qui quello che hai in mente:

---

## 6. Le armi

Un'arma non è un numero più grande: **porta i suoi attacchi**. Cambiare arma non cambia quanto
picchi, cambia cosa puoi fare.

```json
{
  "id": "mannaia_scheggiata",
  "nome": "Mannaia scheggiata",
  "tipo": "arma",
  "descrizione": "Pesante e mal bilanciata: colpisce più forte, ma ti rallenta.",
  "classe_arma": "catalizzatore",     // chi la può impugnare
  "effetto_equipaggiato": {           // quello che dà solo a portarla
    "attacco": 9,
    "velocita": -1,                   // i valori negativi si possono
    "difesa": 0,
    "hp_max": 0
  },
  "attacchi": [                       // LE MOSSE CHE L'ARMA PORTA
    {
      "id": "fendente", "nome": "Fendente",
      "bonus": 4,                     // si SOMMA al tuo attacco
      "aura": 0,                      // costo: 0 = gratis, sempre disponibile
      "testo": "%s cala la mannaia con tutto il peso che ha.",
      "descrizione": "Pesante, lento, e non gli importa della tua guardia."
    },
    {
      "id": "spaccata", "nome": "Spaccata",
      "bonus": 11, "aura": 3,
      "tipo": "tetro",                // · il tipo del colpo
      "stati": ["tossina"],           // · cosa lascia addosso
      "testo": "%s apre un varco dove non ce n'era uno."
    }
  ],
  "prezzo_vendita": 120
}
```

### Le tre classi d'arma

| Classe | Chi | Perché |
| --- | --- | --- |
| `catalizzatore` | Il protagonista | Non combatte *con* l'arma: combatte *attraverso* l'arma. **Le può usare tutte** |
| `pesante` | Veronica | Martelli e cose a due mani. Lente, e non gliene importa della tua guardia |
| `artigli` | Yhvina | Artigli e glifi: veloci |

### Stato attuale

**Due armi sole**, tutte e due nel Vuoto Ardente:

| Arma | Bonus | Attacchi che porta |
| --- | --- | --- |
| Coltello di servizio | attacco +3 | Affondo (+2, gratis) · Scarica breve (+5, 2 aura) |
| Mannaia scheggiata | attacco +9, velocità −1 | Fendente (+4, gratis) · Spaccata (+11, 3 aura) |

> **Nota per quando le scriveremo:** i bonus sono numeri **fissi**, quindi a livello 20 un +9 non si
> sente più. Se un'arma deve restare una decisione anche a fine gioco, i bonus vanno per fasce
> oppure diventano quote dell'attacco.

### Armi da scrivere

Riempi le righe che vuoi, cancella quelle che non servono.

| Nome | Dove si trova | Classe | Bonus | Attacco 1 | Attacco 2 |
| --- | --- | --- | --- | --- | --- |
| `???` | Squarcio Industriale | | | | |
| `???` | Kizako — Ala Dimenticata | | | | |
| `???` | Rocca Ossidiana | | | | |
| `???` | Casa Gigante | | | | |
| `???` | Teatro del Passato | | | | |
| `???` | Meridia | | | | |

---

## 7. I 39 nemici

Aggiornati a oggi. **La colonna Tipo è una mia proposta: correggila.**
«Mosse» dice quante caselle sono piene, «Libere» quante restano.

#### Livelli 1-5

| Creatura | id | Lv | Ruolo | **Tipo →** | Specie | Mosse | Libere |
| --- | --- | --: | --- | --- | --- | --: | --: |
| Goblin Tipico | `goblin_tipico` | 1 | comune | **Natura** | Goblin | 3 | 3 |
| Slime Infimo | `slime_infimo` | 1 | comune | **Natura** | Slime | 3 | 3 |
| Tartaruga Innocente | `tartaruga_innocente` | 1 | corazzato | **Natura** | Tartaruga | 2 | 4 |
| Infetto Rapido | `infetto_rapido` | 2 | veloce | **Spirituale** | Zombie | 1 | 5 |
| Nuvola di Marciume | `nuvola_di_marciume` | 2 | veloce | **Speciale** | Nimbo | 2 | 4 |
| Zombie Cittadino | `zombie_cittadino` | 2 | comune | **Spirituale** | Zombie | 3 | 3 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | 3 | miniboss | **Speciale** | Onirico | 0 | 6 |
| Fomentado | `maschera_vuota` | 3 | comune | **Spirituale** | Feticcio | 3 | 3 |
| Zombie Mostruoso | `zombie_mostruoso` | 3 | comune | **Spirituale** | Zombie | 5 | 1 |
| Oppresso | `comparsa_di_ruggine` | 4 | corazzato | **Tetro** | Incarnazione | 3 | 3 |
| El Muy Bonito | `giocoliere` | 4 | particolare | **Spirituale** | Feticcio | 6 | 0 |
| Robo Pattuglia | `robo_pattuglia` | 4 | corazzato | **Artificio** | Robot | 3 | 3 |
| Capocantiere | `voce_registrata` | 4 | comune | **Spirituale** | Feticcio | 2 | 4 |
| Emblema dell'oppressione | `operaio_posseduto` | 5 | comune | **Spirituale** | Feticcio | 3 | 3 |
| Operaio Sfruttato | `operaio_sfruttato` | 5 | particolare | **Spirituale** | Feticcio | 3 | 3 |
| Orrore di Meridia | `orrore_di_meridia` | 5 | particolare | **Spirituale** | Zombie | 6 | 0 |

#### Livelli 6-10

| Creatura | id | Lv | Ruolo | **Tipo →** | Specie | Mosse | Libere |
| --- | --- | --: | --- | --- | --- | --: | --: |
| Il Divoratore | `divoratore` | 6 | particolare | **Artificio** | Robot | 6 | 0 |
| Rottami Erranti | `ferraglia_urlante` | 6 | corazzato | **Artificio** | Robot | 6 | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | 6 | fonte | **Natura** | Goblin | 5 | 1 |
| Golem errante di rottami | `golem_errante` | 7 | particolare | **Artificio** | Golem | 4 | 2 |
| Ghoul | `ghoul` | 8 | comune | **Spirituale** | Zombie | 2 | 4 |
| ??? | `l_immortale` | 8 | particolare | **Tetro** | Indeterminato | 1 | 5 |
| Madre in Lacrime | `madre_in_lacrime` | 8 | comune | **Spirituale** | Zombie | 2 | 4 |
| Teschio Errante | `teschio_errante` | 8 | comune | **Spirituale** | Zombie | 2 | 4 |
| Diabolo | `diabolo` | 9 | comune | **Natura** | Ferino | 2 | 4 |
| Sadico | `sadico` | 9 | comune | **Natura** | Umano | 2 | 4 |
| Stigma | `stigma` | 9 | comune | **Spirituale** | Zombie | 2 | 4 |
| Abominio Marcio | `abominio_marcio` | 10 | particolare | **Spirituale** | Zombie | 3 | 3 |
| Titano Zombie | `titano_zombie` | 10 | particolare | **Spirituale** | Zombie | 2 | 4 |

#### Livelli 11-15

| Creatura | id | Lv | Ruolo | **Tipo →** | Specie | Mosse | Libere |
| --- | --- | --: | --- | --- | --- | --: | --: |
| Divoratore di Carcasse | `divoratore_di_carcasse` | 11 | comune | **Natura** | Ferino | 2 | 4 |
| Sacerdote Folle | `sacerdote_folle` | 11 | comune | **Tetro** | Umano | 6 | 0 |
| Jongo Dongo | `jongo_dongo` | 12 | fonte | **Natura** | Umano | 6 | 0 |
| Donna Spinosa | `donna_spinosa` | 13 | comune | **Natura** | Flora | 2 | 4 |
| Marionetta | `marionetta` | 13 | comune | **Tetro** | Automa | 3 | 3 |
| Jongo Dongo | `jongo_dongo_risorto` | 14 | fonte | **Spirituale** | Zombie | 3 | 3 |
| Ombra del passato | `ombra_del_passato` | 14 | comune | **Tetro** | Ombra | 2 | 4 |
| Un tenero ricordo | `tenero_ricordo` | 15 | fonte | **Tetro** | Automa | 5 | 1 |
| Volto sulla parete | `volto_sulla_parete` | 15 | miniboss | **Tetro** | Incarnazione | 3 | 3 |

#### Livelli 16+

| Creatura | id | Lv | Ruolo | **Tipo →** | Specie | Mosse | Libere |
| --- | --- | --: | --- | --- | --- | --: | --: |
| L'ultimo spettacolo di Jerah | `jerah` | 18 | fonte | **Natura** | Umano | 5 | 1 |

---

## 8. Cosa comporta tutto questo nel codice

| Lavoro | Peso | Cosa comporta |
| --- | --- | --- |
| Berserk → **Rabbia** | minimo | Solo il nome: la meccanica è già la tua |
| Confusione → **Frastornato** | piccolo | Rinomina + aggiungere «solo attacchi» |
| **Sonno**: tetto 3 e risveglio | piccolo | Tiro di risveglio dal secondo turno |
| Veleno → **Tossina** | medio | Rinomina + da crescente a costante e leggero + indebolimento |
| **Fiamme** come status | medio | Portare la combustione dentro `stati.json` |
| **Terrore**: niente critici | medio | Blocco dei critici + indebolimento |
| **Provocato** come status | medio | Oggi è solo un'abilità tua: va reso subibile |
| **I cinque tipi** | grosso | Sostituire l'elemento su 39 creature, le armi e le abilità |
| **Maledizione** a riserva | grosso | Da contatore di turni a riserva da 10, col KO non rianimabile |
| **Crescita di tutti dai punti** | grosso | Il percorso nuovo, e i compagni che smettono di essere congelati |

**Ordine consigliato:** i primi tre sono mezz'ora e si vedono subito. Maledizione e tipi vanno
**dopo** il percorso di crescita, perché toccano gli stessi file.

---

*Manuale dei personaggi · scritto per essere corretto a mano · ramo `claude/inizio-progetto-dya2lr`*
