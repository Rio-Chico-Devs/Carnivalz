# La mediazione — chi ascolta, e a quali condizioni

> **Questo file è tuo: scrivici sopra.** La colonna che conta è **Condizioni**. Scrivi lì
> a che condizioni quella creatura accetta di ascoltarti, o **NO** se per natura non lo farà
> mai. Quando me lo rimandi lo applico ai dati.

---

## Come funziona, in gioco

Il menu di combattimento ha **cinque voci fisse**: Attacca · Difendi · Abilità · Oggetti · Fuggi.
**Mediazione è la sesta, e di solito non c'è.** Per farla comparire devono passare tre cose,
in quest'ordine:

| | Cancello | Chi decide |
| --: | --- | --- |
| 1 | **La natura.** Questa creatura media, in generale? | Tu, in questo documento |
| 2 | **La voglia.** Stasera vuole ascoltare? | Il caso, una volta sola all'ingresso |
| 3 | **Lo studio.** Te ne sei accorto? | Il giocatore, studiandola |

Se ne salta uno, il bottone non compare. E quando compare, **funziona**: non esiste il caso
in cui lo premi e ti risponde di no.

> **Una scelta che ho fatto io, e che puoi ribaltare.** Il tiro sulla voglia si fa
> **all'ingresso dello scontro**, non quando premi il bottone. Se lo tirassimo alla pressione,
> chi sa come funziona ricaricherebbe finché non passa, e il caso diventerebbe una formalità.
> Deciso all'ingresso, invece, la stessa specie è mediabile stasera e non domani — e lo scopri
> studiando. Se preferisci il tiro al momento del bottone, è una riga.

Il contatore degli studi si vede **anche quando quella creatura stasera non ha voglia**:
`capita 1/3` compare comunque. Sapere che era possibile, e non è successo, è il motivo per
riprovarci al prossimo incontro; nasconderlo farebbe sembrare rotta una cosa che è casuale.

**Cosa rende mediare.** Niente Tazo e niente drop — non si fruga addosso a chi hai lasciato
vivo — ma **+25% di esperienza** rispetto ad ammazzarlo, più quello che scrivi tu (legame,
stress, un oggetto che ti lascia).

---

## Le colonne

- **Condizioni** — *tu*. A che condizioni ascolta. `NO` se per natura non media mai.
- **Studi** — quante volte va studiata prima che il bottone compaia. Default **1**.
- **Quanto spesso** — su dieci incontri, in quanti ha voglia. `10/10` = sempre, `3/10` = raro.
- **Cosa succede** — la frase che si legge quando media, e cosa ti lascia.

---

## I comuni — 18 creature

Quelli che incontri a ripetizione. Bru: «non sempre se sono nemici comuni medieranno».

| Creatura | Lv | Tipo | Dove | Condizioni | Studi | Quanto spesso | Cosa succede |
| --- | --: | --- | --- | --- | --: | --: | --- |
| **Goblin Tipico**<br>`goblin_tipico` | 1 | Natura | Tutorial | `???` | `???` | `???` | `???` |
| **Slime Infimo**<br>`slime_infimo` | 1 | Natura | Tutorial | `???` | `???` | `???` | `???` |
| **Zombie Cittadino**<br>`zombie_cittadino` | 2 | Tetro | Meridia | `???` | `???` | `???` | `???` |
| **Fomentado**<br>`maschera_vuota` | 3 | Tetro | *non piazzato* | `???` | `???` | `???` | `???` |
| **Zombie Mostruoso**<br>`zombie_mostruoso` | 3 | Tetro | Meridia | `???` | `???` | `???` | `???` |
| **Capocantiere**<br>`voce_registrata` | 4 | Spirituale | Squarcio Industriale | `???` | `???` | `???` | `???` |
| **Emblema dell'oppressione**<br>`operaio_posseduto` | 5 | Spirituale | Kizako Ala · Squarcio Industriale | `???` | `???` | `???` | `???` |
| **Ghoul**<br>`ghoul` | 8 | Tetro | Rocca Ossidiana | `???` | `???` | `???` | `???` |
| **Madre in Lacrime**<br>`madre_in_lacrime` | 8 | Spirituale | Rocca Ossidiana | `???` | `???` | `???` | `???` |
| **Teschio Errante**<br>`teschio_errante` | 8 | Spirituale | Rocca Ossidiana | `???` | `???` | `???` | `???` |
| **Diabolo**<br>`diabolo` | 9 | Tetro | Rocca Ossidiana | `???` | `???` | `???` | `???` |
| **Sadico**<br>`sadico` | 9 | Tetro | Rocca Ossidiana | `???` | `???` | `???` | `???` |
| **Stigma**<br>`stigma` | 9 | Tetro | Rocca Ossidiana | `???` | `???` | `???` | `???` |
| **Divoratore di Carcasse**<br>`divoratore_di_carcasse` | 11 | Natura | Rocca Ossidiana | `???` | `???` | `???` | `???` |
| **Sacerdote Folle**<br>`sacerdote_folle` | 11 | Tetro | Rocca Ossidiana | `???` | `???` | `???` | `???` |
| **Donna Spinosa**<br>`donna_spinosa` | 13 | Natura | Casa Gigante | `???` | `???` | `???` | `???` |
| **Marionetta**<br>`marionetta` | 13 | Tetro | Casa Gigante | `???` | `???` | `???` | `???` |
| **Ombra del passato**<br>`ombra_del_passato` | 14 | Tetro | Casa Gigante | `???` | `???` | `???` | `???` |

## Particolari, corazzati, veloci, fonti — 21 creature

Miniboss, fonti e creature con un ruolo speciale. Chi è **invincibile per copione** o è un
**incontro scriptato** non media mai, anche se gli scrivi le condizioni: il motore lo blocca a monte.

| Creatura | Lv | Tipo | Dove | Condizioni | Studi | Quanto spesso | Cosa succede |
| --- | --: | --- | --- | --- | --: | --: | --- |
| **Tartaruga Innocente**<br>`tartaruga_innocente` | 1 | Natura | Tutorial | Non ha mai attaccato nessuno. Basta guardarla una volta per accorgersene. | 1 | 10/10 | Decidi di lasciarla andare. Non c'era nessuna ragione di … *(lascia: pietra_quieta)* |
| **Infetto Rapido**<br>`infetto_rapido` | 2 | Tetro | Meridia | `???` | `???` | `???` | `???` |
| **Nuvola di Marciume**<br>`nuvola_di_marciume` | 2 | Tetro | Meridia | `???` | `???` | `???` | `???` |
| **Manifestazione di un sogno**<br>`manifestazione_di_un_sogno` | 3 | Spirituale | Tutorial | `???` | `???` | `???` | `???` |
| **Oppresso**<br>`comparsa_di_ruggine` | 4 | Spirituale | Kizako Ala · Squarcio Industriale | `???` | `???` | `???` | `???` |
| **El Muy Bonito**<br>`giocoliere` | 4 | Speciale | *non piazzato* | `???` | `???` | `???` | `???` |
| **Robo Pattuglia**<br>`robo_pattuglia` | 4 | Artificio | Squarcio Industriale | `???` | `???` | `???` | `???` |
| **Operaio Sfruttato**<br>`operaio_sfruttato` | 5 | Spirituale | Squarcio Industriale | `???` | `???` | `???` | `???` |
| **Orrore di Meridia**<br>`orrore_di_meridia` | 5 | Tetro | Meridia | `???` | `???` | `???` | `???` |
| **Il Divoratore**<br>`divoratore` | 6 | Artificio | Squarcio Industriale | `???` | `???` | `???` | `???` |
| **Rottami Erranti**<br>`ferraglia_urlante` | 6 | Artificio | Kizako Ala | `???` | `???` | `???` | `???` |
| **Un goblin terribilmente arrabbiato**<br>`goblin_arrabbiato` | 6 | Natura | Tutorial | `???` | `???` | `???` | `???` |
| **Golem errante di rottami**<br>`golem_errante` | 7 | Artificio | *non piazzato* | `???` | `???` | `???` | `???` |
| **???**<br>`l_immortale` | 8 | Tetro | Rocca Ossidiana | `???` | `???` | `???` | `???` |
| **Abominio Marcio**<br>`abominio_marcio` | 10 | Tetro | *non piazzato* | `???` | `???` | `???` | `???` |
| **Titano Zombie**<br>`titano_zombie` | 10 | Tetro | Meridia | `???` | `???` | `???` | `???` |
| **Jongo Dongo**<br>`jongo_dongo` | 12 | Tetro | Rocca Ossidiana | `???` | `???` | `???` | `???` |
| **Jongo Dongo**<br>`jongo_dongo_risorto` | 14 | Speciale | Rocca Ossidiana | `???` | `???` | `???` | `???` |
| **Un tenero ricordo**<br>`tenero_ricordo` | 15 | Tetro | Casa Gigante | `???` | `???` | `???` | `???` |
| **Volto sulla parete**<br>`volto_sulla_parete` | 15 | Tetro | Casa Gigante | `???` | `???` | `???` | `???` |
| **L'ultimo spettacolo di Jerah**<br>`jerah` | 18 | Spirituale | *non piazzato* | `???` | `???` | `???` | `???` |

---

## Note

- **L'unica già scritta è la Tartaruga Innocente**, che era la vecchia meccanica «Risparmia»:
  la migro a mediazione senza cambiarle niente. Tutte le altre righe sono `???` e aspettano te.
- **Il Golem errante, l'Abominio Marcio, Fomentado, El Muy Bonito e Jerah non sono ancora
  piazzati** in nessuna zona: esistono nei dati ma non li incontri. Segnalo qui perché una
  condizione di mediazione scritta per loro oggi non la vedrebbe nessuno.
- **Jongo Dongo e Jongo Dongo risorto** sono la stessa creatura in due momenti. Se media, con
  ogni probabilità media solo uno dei due.
- **???** (`l_immortale`) è invincibile per copione: il motore gli nega la mediazione a monte,
  quindi non serve scriverci niente a meno che tu non voglia cambiare quel copione.

---

*La mediazione · scritto per essere compilato a mano · ramo `claude/inizio-progetto-dya2lr`*
