# Dove vanno i disegni (generato, non scrivere qui a mano)

Rigenera con `python3 strumenti/genera_immagini.py`.

**Il nome del file non e' sempre l'id.** Lo decide il campo `ritratto` nei dati:
Yhvina ha id `insonne` ma il suo file si chiama `yhvina.png`. Usa la colonna
*file* e non pensarci piu'.

Formati: PNG con trasparenza. Non serve una misura precisa — il gioco scala
mantenendo le proporzioni. Un file che manca non rompe niente: si vede un
segnaposto con l'iniziale del nome, quindi si puo' disegnare a poco a poco.

## Le espressioni, per chi parla nei dialoghi

Chi ha delle battute puo' avere una cartella sua con le espressioni:

```
art/personaggi/<id>/<espressione>.png
```

Le 16: `neutra` · `arrabbiata` · `felice` · `carina` · `infastidita` · `disgusto` · `speciale` · `dialogo` · `delusa` · `petrificata` · `annoiata` · `pensiero` · `sorpresa` · `sforzo` · `cool` · `decisa`

`neutra` e' quella di ripiego, conviene farla per prima. Se manca anche quella
si usa il file singolo `art/personaggi/<id>.png`, che va benissimo da solo.

Le 16 non sono una gabbia: `espr` e' il nome del file, quindi una scena puo'
chiedere `"espr": "sotto_la_pioggia"` e basta disegnare quel file.

## Cosa serve, adesso

Non 16 espressioni per 48 personaggi (768 disegni, che non li fa nessuno).
Questo e' quello che i dialoghi scritti finora chiedono davvero.

### 1. Il ritratto singolo — 53 da fare

Basta questo perche' nessuno sia piu' un segnaposto. Le creature da
combattimento si fermano qui: non parlano, non gli serve altro.

```
art/personaggi/abominio_marcio.png
art/personaggi/anonimo.png
art/personaggi/bero.png
art/personaggi/comparsa_di_ruggine.png
art/personaggi/curie.png
art/personaggi/diabolo.png
art/personaggi/divoratore.png
art/personaggi/divoratore_di_carcasse.png
art/personaggi/donna_spinosa.png
art/personaggi/ferraglia_urlante.png
art/personaggi/fio.png
art/personaggi/ghoul.png
art/personaggi/giocoliere.png
art/personaggi/goblin_arrabbiato.png
art/personaggi/goblin_tipico.png
art/personaggi/infetto_rapido.png
art/personaggi/jerah.png
art/personaggi/jongo_dongo.png
art/personaggi/l_immortale.png
art/personaggi/lettere_altare.png
art/personaggi/madre_in_lacrime.png
art/personaggi/manifestazione_di_un_sogno.png
art/personaggi/marionetta.png
art/personaggi/maschera_vuota.png
art/personaggi/mockingbear.png
art/personaggi/mr_eto.png
art/personaggi/niru.png
art/personaggi/nuvola_di_marciume.png
art/personaggi/ombra_del_passato.png
art/personaggi/operaio_posseduto.png
art/personaggi/operaio_sfruttato.png
art/personaggi/orrore_di_meridia.png
art/personaggi/rio.png
art/personaggi/robo_pattuglia.png
art/personaggi/sacerdote_folle.png
art/personaggi/sadico.png
art/personaggi/sally.png
art/personaggi/slime_infimo.png
art/personaggi/spirito_dei_giardini.png
art/personaggi/stigma.png
art/personaggi/tartaruga_innocente.png
art/personaggi/tenero_ricordo.png
art/personaggi/teschio_errante.png
art/personaggi/titano_zombie.png
art/personaggi/vecchio_clown.png
art/personaggi/vega.png
art/personaggi/veronica.png
art/personaggi/voce_registrata.png
art/personaggi/volto_sulla_parete.png
art/personaggi/yara.png
art/personaggi/yhvina.png
art/personaggi/zombie_cittadino.png
art/personaggi/zombie_mostruoso.png
```

### 2. Le espressioni dei dialoghi — 40 da fare

Solo per chi ha delle battute, e solo le facce che le battute nominano.
Se una manca si ripiega sulla neutra, e se manca anche quella sul ritratto
singolo: si puo' fare in qualunque ordine.

```
art/personaggi/anonimo/decisa.png
art/personaggi/anonimo/neutra.png
art/personaggi/anonimo/pensiero.png
art/personaggi/anonimo/sforzo.png
art/personaggi/anonimo/sorpresa.png
art/personaggi/computer/neutra.png
art/personaggi/curie/carina.png
art/personaggi/curie/neutra.png
art/personaggi/figura_misteriosa/neutra.png
art/personaggi/giocoliere/arrabbiata.png
art/personaggi/giocoliere/cool.png
art/personaggi/giocoliere/neutra.png
art/personaggi/goblin_arrabbiato/decisa.png
art/personaggi/goblin_arrabbiato/neutra.png
art/personaggi/infetto_rapido/neutra.png
art/personaggi/insonne/annoiata.png
art/personaggi/insonne/carina.png
art/personaggi/insonne/decisa.png
art/personaggi/insonne/delusa.png
art/personaggi/insonne/infastidita.png
art/personaggi/insonne/neutra.png
art/personaggi/jerah/decisa.png
art/personaggi/jerah/delusa.png
art/personaggi/jerah/neutra.png
art/personaggi/jerah/speciale.png
art/personaggi/jongo_dongo/decisa.png
art/personaggi/jongo_dongo/neutra.png
art/personaggi/jongo_dongo/petrificata.png
art/personaggi/l_immortale/neutra.png
art/personaggi/nuvola_di_marciume/neutra.png
art/personaggi/robo_pattuglia/neutra.png
art/personaggi/sopravvissuta/neutra.png
art/personaggi/spirito_dei_giardini/neutra.png
art/personaggi/tenero_ricordo/neutra.png
art/personaggi/vecchio_clown/neutra.png
art/personaggi/vecchio_clown/pensiero.png
art/personaggi/veronica/decisa.png
art/personaggi/veronica/felice.png
art/personaggi/veronica/neutra.png
art/personaggi/volto_sulla_parete/neutra.png
```

| chi | quante | quali |
|---|--:|---|
| Yhvina (`insonne`) | 6 | `annoiata` · `carina` · `decisa` · `delusa` · `infastidita` · `neutra` |
| Anonimo (`anonimo`) | 5 | `decisa` · `neutra` · `pensiero` · `sforzo` · `sorpresa` |
| L'ultimo spettacolo di Jerah (`jerah`) | 4 | `decisa` · `delusa` · `neutra` · `speciale` |
| El Muy Bonito (`giocoliere`) | 3 | `arrabbiata` · `cool` · `neutra` |
| Jongo Dongo (`jongo_dongo`) | 3 | `decisa` · `neutra` · `petrificata` |
| Veronica (`veronica`) | 3 | `decisa` · `felice` · `neutra` |
| Dott.ssa Curie Heartlife (`curie`) | 2 | `carina` · `neutra` |
| Un goblin terribilmente arrabbiato (`goblin_arrabbiato`) | 2 | `decisa` · `neutra` |
| Il Vecchio Proprietario del teatro (`vecchio_clown`) | 2 | `neutra` · `pensiero` |
| computer (`computer`) | 1 | `neutra` |
| figura_misteriosa (`figura_misteriosa`) | 1 | `neutra` |
| Infetto Rapido (`infetto_rapido`) | 1 | `neutra` |
| ??? (`l_immortale`) | 1 | `neutra` |
| Nuvola di Marciume (`nuvola_di_marciume`) | 1 | `neutra` |
| Robo Pattuglia (`robo_pattuglia`) | 1 | `neutra` |
| Yara (`sopravvissuta`) | 1 | `neutra` |
| Spirito dei giardini (`spirito_dei_giardini`) | 1 | `neutra` |
| Un tenero ricordo (`tenero_ricordo`) | 1 | `neutra` |
| Volto sulla parete (`volto_sulla_parete`) | 1 | `neutra` |

## Squadra

| chi | file | espressioni | c'è |
|---|---|---|:-:|
| Anonimo | `art/personaggi/anonimo.png` | `art/personaggi/anonimo/` |  |
| Bero | `art/personaggi/bero.png` | `art/personaggi/bero/` |  |
| Fio | `art/personaggi/fio.png` | `art/personaggi/fio/` |  |
| Il Vecchio Proprietario del teatro | `art/personaggi/vecchio_clown.png` | `art/personaggi/vecchio_clown/` |  |
| Mockingbear | `art/personaggi/mockingbear.png` | `art/personaggi/mockingbear/` |  |
| Mr. Eto | `art/personaggi/mr_eto.png` | `art/personaggi/mr_eto/` |  |
| Niru | `art/personaggi/niru.png` | `art/personaggi/niru/` |  |
| Rio | `art/personaggi/rio.png` | `art/personaggi/rio/` |  |
| Sally | `art/personaggi/sally.png` | `art/personaggi/sally/` |  |
| Vega | `art/personaggi/vega.png` | `art/personaggi/vega/` |  |
| Yara | `art/personaggi/yara.png` | `art/personaggi/sopravvissuta/` |  |
| Yhvina | `art/personaggi/yhvina.png` | `art/personaggi/insonne/` |  |

## Creature

| creatura | lv | file | espressioni | c'è |
|---|--:|---|---|:-:|
| Goblin Tipico | 1 | `art/personaggi/goblin_tipico.png` | — |  |
| Slime Infimo | 1 | `art/personaggi/slime_infimo.png` | — |  |
| Tartaruga Innocente | 1 | `art/personaggi/tartaruga_innocente.png` | — |  |
| Infetto Rapido | 2 | `art/personaggi/infetto_rapido.png` | — |  |
| Nuvola di Marciume | 2 | `art/personaggi/nuvola_di_marciume.png` | — |  |
| Zombie Cittadino | 2 | `art/personaggi/zombie_cittadino.png` | — |  |
| Fomentado | 3 | `art/personaggi/maschera_vuota.png` | — |  |
| Manifestazione di un sogno | 3 | `art/personaggi/manifestazione_di_un_sogno.png` | — |  |
| Zombie Mostruoso | 3 | `art/personaggi/zombie_mostruoso.png` | — |  |
| Capocantiere | 4 | `art/personaggi/voce_registrata.png` | — |  |
| El Muy Bonito | 4 | `art/personaggi/giocoliere.png` | — |  |
| Oppresso | 4 | `art/personaggi/comparsa_di_ruggine.png` | — |  |
| Robo Pattuglia | 4 | `art/personaggi/robo_pattuglia.png` | — |  |
| Emblema dell'oppressione | 5 | `art/personaggi/operaio_posseduto.png` | — |  |
| Operaio Sfruttato | 5 | `art/personaggi/operaio_sfruttato.png` | — |  |
| Orrore di Meridia | 5 | `art/personaggi/orrore_di_meridia.png` | — |  |
| Veronica | 5 | `art/personaggi/veronica.png` | — |  |
| Ferraglia Urlante | 6 | `art/personaggi/ferraglia_urlante.png` | — |  |
| Il Divoratore | 6 | `art/personaggi/divoratore.png` | — |  |
| Un goblin terribilmente arrabbiato | 6 | `art/personaggi/goblin_arrabbiato.png` | — |  |
| ??? | 8 | `art/personaggi/l_immortale.png` | — |  |
| Ghoul | 8 | `art/personaggi/ghoul.png` | — |  |
| Madre in Lacrime | 8 | `art/personaggi/madre_in_lacrime.png` | — |  |
| Teschio Errante | 8 | `art/personaggi/teschio_errante.png` | — |  |
| Diabolo | 9 | `art/personaggi/diabolo.png` | — |  |
| Sadico | 9 | `art/personaggi/sadico.png` | — |  |
| Stigma | 9 | `art/personaggi/stigma.png` | — |  |
| Abominio Marcio | 10 | `art/personaggi/abominio_marcio.png` | — |  |
| Titano Zombie | 10 | `art/personaggi/titano_zombie.png` | — |  |
| Divoratore di Carcasse | 11 | `art/personaggi/divoratore_di_carcasse.png` | — |  |
| Sacerdote Folle | 11 | `art/personaggi/sacerdote_folle.png` | — |  |
| Jongo Dongo | 12 | `art/personaggi/jongo_dongo.png` | — |  |
| Donna Spinosa | 13 | `art/personaggi/donna_spinosa.png` | — |  |
| Marionetta | 13 | `art/personaggi/marionetta.png` | — |  |
| Jongo Dongo | 14 | `art/personaggi/jongo_dongo.png` | — |  |
| Ombra del passato | 14 | `art/personaggi/ombra_del_passato.png` | — |  |
| Un tenero ricordo | 15 | `art/personaggi/tenero_ricordo.png` | — |  |
| Volto sulla parete | 15 | `art/personaggi/volto_sulla_parete.png` | — |  |
| L'ultimo spettacolo di Jerah | 18 | `art/personaggi/jerah.png` | — |  |

## Personaggi

| chi | file | espressioni | c'è |
|---|---|---|:-:|
| Dott.ssa Curie Heartlife | `art/personaggi/curie.png` | `art/personaggi/curie/` |  |
| Le lettere sull'altare | `art/personaggi/lettere_altare.png` | `art/personaggi/lettere_altare/` |  |
| Spirito dei giardini | `art/personaggi/spirito_dei_giardini.png` | `art/personaggi/spirito_dei_giardini/` |  |

## Le illustrazioni delle scene

Disegni singoli a schermo intero: la scena si ferma, li mostra con la
didascalia sotto, e poi riprende. Se il file non c'e' resta la didascalia,
quindi si possono fare con calma. Vanno in `art/illustrazioni/`.

| file | dove | cosa si vede | c'è |
|---|---|---|:-:|
| `art/illustrazioni/casa_figlia_addio.png` | casa_gigante.json › spirito_storia | «Sono venuta a salutarti... ma non perché nutra un qualunque sentimento nei tuoi confronti: per avvisarti che ti supererò, a qualunque costo. Non voglio mai più vederti. Questo è un addio: grazie di niente.» |  |
| `art/illustrazioni/meridia_morto_vivente.png` | meridia.json › fuori_struttura | In mezzo alla strada, fermo, c'è qualcosa che ti sta guardando da parecchio. |  |
| `art/illustrazioni/file_reparto_montaggio.png` | squarcio_industriale.json › file_computer | In fila davanti alla catena ci sono più uomini di quanti quel reparto potesse contenerne. Nessuno guarda l'obiettivo. |  |

## Il resto

| file | cos'è | c'è |
|---|---|:-:|
| `art/mappa.png` | Sfondo della mappa stellare (la proiezione del settore) |  |
| `art/sede.png` | Sfondo della Sede |  |
| `art/branding/logo_studio.png` | Logo Rio Chico Devs, primo dei loghi d'apertura |  |
| `art/branding/logo_personale.png` | Logo personale, secondo logo d'apertura |  |
| `art/fx/slaughter.png` | Illustrazione a schermo intero dello Slaughter |  |

---

Ritratti presenti: **0 su 54**.
