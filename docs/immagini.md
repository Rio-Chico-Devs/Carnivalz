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

### 1. Il ritratto singolo — 58 da fare

Basta questo perche' nessuno sia piu' un segnaposto. Le creature da
combattimento si fermano qui: non parlano, non gli serve altro.

```
art/personaggi/abominio_marcio.png
art/personaggi/anonimo.png
art/personaggi/bero.png
art/personaggi/comparsa_di_ruggine.png
art/personaggi/diabolo.png
art/personaggi/divoratore.png
art/personaggi/divoratore_di_carcasse.png
art/personaggi/donna_spinosa.png
art/personaggi/ferraglia_urlante.png
art/personaggi/fio.png
art/personaggi/ghoul.png
art/personaggi/giocoliere.png
art/personaggi/goblin_arrabbiato.png
art/personaggi/goblin_possessivo.png
art/personaggi/goblin_tipico.png
art/personaggi/guida.png
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
art/personaggi/nimbo_boy.png
art/personaggi/niru.png
art/personaggi/nuvola_di_marciume.png
art/personaggi/ombra_del_passato.png
art/personaggi/operaio_posseduto.png
art/personaggi/operaio_sfruttato.png
art/personaggi/orrore_di_meridia.png
art/personaggi/rana_folle.png
art/personaggi/reika.png
art/personaggi/rio.png
art/personaggi/robo_pattuglia.png
art/personaggi/sacerdote_folle.png
art/personaggi/sadico.png
art/personaggi/sally.png
art/personaggi/slime_infimo.png
art/personaggi/sogno_perduto.png
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

### 2. Le espressioni dei dialoghi — 59 da fare

Solo per chi ha delle battute, e solo le facce che le battute nominano.
Se una manca si ripiega sulla neutra, e se manca anche quella sul ritratto
singolo: si puo' fare in qualunque ordine.

```
art/personaggi/altoparlante/neutra.png
art/personaggi/anonimo/annoiata.png
art/personaggi/anonimo/decisa.png
art/personaggi/anonimo/delusa.png
art/personaggi/anonimo/infastidita.png
art/personaggi/anonimo/neutra.png
art/personaggi/anonimo/pensiero.png
art/personaggi/anonimo/petrificata.png
art/personaggi/anonimo/sforzo.png
art/personaggi/anonimo/sorpresa.png
art/personaggi/computer/neutra.png
art/personaggi/data_pad/neutra.png
art/personaggi/figura_misteriosa/neutra.png
art/personaggi/giocoliere/arrabbiata.png
art/personaggi/giocoliere/cool.png
art/personaggi/giocoliere/neutra.png
art/personaggi/goblin_arrabbiato/decisa.png
art/personaggi/goblin_arrabbiato/neutra.png
art/personaggi/goblin_possessivo/neutra.png
art/personaggi/goblin_tipico/neutra.png
art/personaggi/guida/neutra.png
art/personaggi/ignoto/neutra.png
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
art/personaggi/manifestazione_di_un_sogno/neutra.png
art/personaggi/nuvola_di_marciume/neutra.png
art/personaggi/reika/carina.png
art/personaggi/reika/neutra.png
art/personaggi/robo_pattuglia/neutra.png
art/personaggi/slime_infimo/neutra.png
art/personaggi/soldato_due/neutra.png
art/personaggi/soldato_uno/neutra.png
art/personaggi/sopravvissuta/neutra.png
art/personaggi/spirito_dei_giardini/neutra.png
art/personaggi/tartaruga_innocente/neutra.png
art/personaggi/tenero_ricordo/neutra.png
art/personaggi/vecchio_clown/neutra.png
art/personaggi/vecchio_clown/pensiero.png
art/personaggi/veronica/annoiata.png
art/personaggi/veronica/carina.png
art/personaggi/veronica/decisa.png
art/personaggi/veronica/felice.png
art/personaggi/veronica/infastidita.png
art/personaggi/veronica/neutra.png
art/personaggi/veronica/pensiero.png
art/personaggi/volto_sulla_parete/neutra.png
```

| chi | quante | quali |
|---|--:|---|
| Anonimo (`anonimo`) | 9 | `annoiata` · `decisa` · `delusa` · `infastidita` · `neutra` · `pensiero` · `petrificata` · `sforzo` · `sorpresa` |
| Veronica (`veronica`) | 7 | `annoiata` · `carina` · `decisa` · `felice` · `infastidita` · `neutra` · `pensiero` |
| Yhvina (`insonne`) | 6 | `annoiata` · `carina` · `decisa` · `delusa` · `infastidita` · `neutra` |
| L'ultimo spettacolo di Jerah (`jerah`) | 4 | `decisa` · `delusa` · `neutra` · `speciale` |
| El Muy Bonito (`giocoliere`) | 3 | `arrabbiata` · `cool` · `neutra` |
| Jongo Dongo (`jongo_dongo`) | 3 | `decisa` · `neutra` · `petrificata` |
| Un goblin terribilmente arrabbiato (`goblin_arrabbiato`) | 2 | `decisa` · `neutra` |
| Dr. Reika (`reika`) | 2 | `carina` · `neutra` |
| Il Vecchio Proprietario del teatro (`vecchio_clown`) | 2 | `neutra` · `pensiero` |
| altoparlante (`altoparlante`) | 1 | `neutra` |
| computer (`computer`) | 1 | `neutra` |
| data_pad (`data_pad`) | 1 | `neutra` |
| figura_misteriosa (`figura_misteriosa`) | 1 | `neutra` |
| Goblin Possessivo (`goblin_possessivo`) | 1 | `neutra` |
| Goblin Tipico (`goblin_tipico`) | 1 | `neutra` |
| Guida (`guida`) | 1 | `neutra` |
| ignoto (`ignoto`) | 1 | `neutra` |
| Infetto Rapido (`infetto_rapido`) | 1 | `neutra` |
| ??? (`l_immortale`) | 1 | `neutra` |
| Manifestazione di un sogno (`manifestazione_di_un_sogno`) | 1 | `neutra` |
| Nuvola di Marciume (`nuvola_di_marciume`) | 1 | `neutra` |
| Robo Pattuglia (`robo_pattuglia`) | 1 | `neutra` |
| Slime Infimo (`slime_infimo`) | 1 | `neutra` |
| soldato_due (`soldato_due`) | 1 | `neutra` |
| soldato_uno (`soldato_uno`) | 1 | `neutra` |
| Yara (`sopravvissuta`) | 1 | `neutra` |
| Spirito dei giardini (`spirito_dei_giardini`) | 1 | `neutra` |
| Tartaruga Gigante (`tartaruga_innocente`) | 1 | `neutra` |
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
| Nimbo Boy | 1 | `art/personaggi/nimbo_boy.png` | — |  |
| Rana Folle | 1 | `art/personaggi/rana_folle.png` | — |  |
| Sogno perduto | 1 | `art/personaggi/sogno_perduto.png` | — |  |
| Tartaruga Gigante | 1 | `art/personaggi/tartaruga_innocente.png` | — |  |
| Fomentado | 3 | `art/personaggi/maschera_vuota.png` | — |  |
| Emblema dell'oppressione | 5 | `art/personaggi/operaio_posseduto.png` | — |  |
| Veronica | 5 | `art/personaggi/veronica.png` | — |  |
| Un goblin terribilmente arrabbiato | 6 | `art/personaggi/goblin_arrabbiato.png` | — |  |
| ??? | 8 | `art/personaggi/l_immortale.png` | — |  |
| Diabolo | 9 | `art/personaggi/diabolo.png` | — |  |
| Un tenero ricordo | 15 | `art/personaggi/tenero_ricordo.png` | — |  |

## Personaggi

| chi | file | espressioni | c'è |
|---|---|---|:-:|
| Dr. Reika | `art/personaggi/reika.png` | `art/personaggi/reika/` |  |
| Guida | `art/personaggi/guida.png` | `art/personaggi/guida/` |  |
| Le lettere sull'altare | `art/personaggi/lettere_altare.png` | `art/personaggi/lettere_altare/` |  |
| Spirito dei giardini | `art/personaggi/spirito_dei_giardini.png` | `art/personaggi/spirito_dei_giardini/` |  |
| Goblin Possessivo | `art/personaggi/goblin_possessivo.png` | `art/personaggi/goblin_possessivo/` |  |
| Goblin Tipico | `art/personaggi/goblin_tipico.png` | `art/personaggi/goblin_tipico/` |  |
| Slime Infimo | `art/personaggi/slime_infimo.png` | `art/personaggi/slime_infimo/` |  |
| Infetto Rapido | `art/personaggi/infetto_rapido.png` | `art/personaggi/infetto_rapido/` |  |
| Nuvola di Marciume | `art/personaggi/nuvola_di_marciume.png` | `art/personaggi/nuvola_di_marciume/` |  |
| Zombie Cittadino | `art/personaggi/zombie_cittadino.png` | `art/personaggi/zombie_cittadino/` |  |
| Manifestazione di un sogno | `art/personaggi/manifestazione_di_un_sogno.png` | `art/personaggi/manifestazione_di_un_sogno/` |  |
| Zombie Mostruoso | `art/personaggi/zombie_mostruoso.png` | `art/personaggi/zombie_mostruoso/` |  |
| Capocantiere | `art/personaggi/voce_registrata.png` | `art/personaggi/voce_registrata/` |  |
| El Muy Bonito | `art/personaggi/giocoliere.png` | `art/personaggi/giocoliere/` |  |
| Oppresso | `art/personaggi/comparsa_di_ruggine.png` | `art/personaggi/comparsa_di_ruggine/` |  |
| Robo Pattuglia | `art/personaggi/robo_pattuglia.png` | `art/personaggi/robo_pattuglia/` |  |
| Operaio Sfruttato | `art/personaggi/operaio_sfruttato.png` | `art/personaggi/operaio_sfruttato/` |  |
| Orrore di Meridia | `art/personaggi/orrore_di_meridia.png` | `art/personaggi/orrore_di_meridia/` |  |
| Il Divoratore | `art/personaggi/divoratore.png` | `art/personaggi/divoratore/` |  |
| Rottami Erranti | `art/personaggi/ferraglia_urlante.png` | `art/personaggi/ferraglia_urlante/` |  |
| Golem errante di rottami | `art/personaggi/ferraglia_urlante.png` | `art/personaggi/golem_errante/` |  |
| Ghoul | `art/personaggi/ghoul.png` | `art/personaggi/ghoul/` |  |
| Madre in Lacrime | `art/personaggi/madre_in_lacrime.png` | `art/personaggi/madre_in_lacrime/` |  |
| Teschio Errante | `art/personaggi/teschio_errante.png` | `art/personaggi/teschio_errante/` |  |
| Sadico | `art/personaggi/sadico.png` | `art/personaggi/sadico/` |  |
| Stigma | `art/personaggi/stigma.png` | `art/personaggi/stigma/` |  |
| Abominio Marcio | `art/personaggi/abominio_marcio.png` | `art/personaggi/abominio_marcio/` |  |
| Titano Zombie | `art/personaggi/titano_zombie.png` | `art/personaggi/titano_zombie/` |  |
| Divoratore di Carcasse | `art/personaggi/divoratore_di_carcasse.png` | `art/personaggi/divoratore_di_carcasse/` |  |
| Sacerdote Folle | `art/personaggi/sacerdote_folle.png` | `art/personaggi/sacerdote_folle/` |  |
| Jongo Dongo | `art/personaggi/jongo_dongo.png` | `art/personaggi/jongo_dongo/` |  |
| Donna Spinosa | `art/personaggi/donna_spinosa.png` | `art/personaggi/donna_spinosa/` |  |
| Marionetta | `art/personaggi/marionetta.png` | `art/personaggi/marionetta/` |  |
| Jongo Dongo | `art/personaggi/jongo_dongo.png` | `art/personaggi/jongo_dongo_risorto/` |  |
| Ombra del passato | `art/personaggi/ombra_del_passato.png` | `art/personaggi/ombra_del_passato/` |  |
| Volto sulla parete | `art/personaggi/volto_sulla_parete.png` | `art/personaggi/volto_sulla_parete/` |  |
| L'ultimo spettacolo di Jerah | `art/personaggi/jerah.png` | `art/personaggi/jerah/` |  |

## Le illustrazioni delle scene

Disegni singoli a schermo intero: la scena si ferma, li mostra con la
didascalia sotto, e poi riprende. Se il file non c'e' resta la didascalia,
quindi si possono fare con calma. Vanno in `art/illustrazioni/`.

| file | dove | cosa si vede | c'è |
|---|---|---|:-:|
| `art/illustrazioni/casa_figlia_addio.png` | casa_gigante.json › spirito_storia | «Sono venuta a salutarti... ma non perché nutra un qualunque sentimento nei tuoi confronti: per avvisarti che ti supererò, a qualunque costo. Non voglio mai più vederti. Questo è un addio: grazie di niente.» |  |
| `art/illustrazioni/meridia_morto_vivente.png` | meridia.json › fuori_struttura | In mezzo alla strada, fermo, c'è qualcosa che ti sta guardando da parecchio. |  |
| `art/illustrazioni/file_reparto_montaggio.png` | squarcio_industriale.json › file_computer | In fila davanti alla catena ci sono più uomini di quanti quel reparto potesse contenerne. Nessuno guarda l'obiettivo. |  |

## Il negozio e la scheda della squadra

Le misure, e come ogni disegno viene messo nel suo riquadro, stanno in
`docs/interfaccia.md`. Finché un file manca si vede un disegno a forme, quindi
anche qui si può fare con calma e in qualunque ordine.

### I compagni: nella loro cartella, quella delle espressioni

La cartella ha il nome dell'**id**, non del ritratto: i disegni di Yhvina
stanno in `art/personaggi/insonne/`.

| chi | `intero.png` | `carta.png` | `emblema.png` |
|---|:-:|:-:|:-:|
| Anonimo (`art/personaggi/anonimo/`) |  |  |  |
| Yhvina (`art/personaggi/insonne/`) |  |  |  |
| Sally (`art/personaggi/sally/`) |  |  |  |
| Vega (`art/personaggi/vega/`) |  |  |  |
| Niru (`art/personaggi/niru/`) |  |  |  |
| Fio (`art/personaggi/fio/`) |  |  |  |
| Rio (`art/personaggi/rio/`) |  |  |  |
| Bero (`art/personaggi/bero/`) |  |  |  |
| Mockingbear (`art/personaggi/mockingbear/`) |  |  |  |
| Mr. Eto (`art/personaggi/mr_eto/`) |  |  |  |
| Yara (`art/personaggi/sopravvissuta/`) |  |  |  |
| Il Vecchio Proprietario del teatro (`art/personaggi/vecchio_clown/`) |  |  |  |
| Veronica (`art/personaggi/brawler/`) |  |  |  |

- `intero.png`: la figura intera, al centro della scheda
- `carta.png`: il ritratto nella carta della squadra, a destra
- `emblema.png`: l'emblema accanto al nome, in alto a sinistra

### Gli oggetti: `art/oggetti/<id>.png`

Lo stesso file serve alla carta dello scaffale, alla vetrina, alla miniatura
e al carosello della scheda.

| oggetto | file | c'è |
|---|---|:-:|
| Amuleto di cenere | `art/oggetti/amuleto_di_cenere.png` |  |
| Amuleto di ferro | `art/oggetti/amuleto_di_ferro.png` |  |
| Amuleto di pietra | `art/oggetti/amuleto_di_pietra.png` |  |
| Amuleto di vento | `art/oggetti/amuleto_di_vento.png` |  |
| Bastone | `art/oggetti/bastone.png` |  |
| Benda stretta | `art/oggetti/benda_stretta.png` |  |
| Bomba al nitro | `art/oggetti/bomba_al_nitro.png` |  |
| Bomba artigianale | `art/oggetti/bomba_artigianale.png` |  |
| Bottiglia di liquore | `art/oggetti/bottiglia_di_liquore.png` |  |
| Caramella di Nyu | `art/oggetti/caramella_di_nyu.png` |  |
| Carbone attivo | `art/oggetti/carbone_attivo.png` |  |
| Coltello di servizio | `art/oggetti/coltello_di_servizio.png` |  |
| Cuore di latta | `art/oggetti/cuore_di_latta.png` |  |
| Essenza d'aura | `art/oggetti/essenza_di_aura.png` |  |
| Fiala d'aura | `art/oggetti/fiala_aura.png` |  |
| Fiala HP | `art/oggetti/fiala_hp.png` |  |
| Fiore di luna | `art/oggetti/fiore_di_luna.png` |  |
| Frammento di vita | `art/oggetti/frammento_di_vita.png` |  |
| Frammento — vassoio | `art/oggetti/frammento_per_gli_accessori.png` |  |
| Frammento — rastrelliera | `art/oggetti/frammento_per_le_armi.png` |  |
| Il mondo è il mio Tesoro | `art/oggetti/il_mondo_e_il_mio_tesoro.png` |  |
| Infuso antico | `art/oggetti/infuso_antico.png` |  |
| Lente di Nyu | `art/oggetti/lente_di_nyu.png` |  |
| Mannaia scheggiata | `art/oggetti/mannaia_scheggiata.png` |  |
| Mazzafrusto | `art/oggetti/mazzafrusto.png` |  |
| Pacco di merendine scadute | `art/oggetti/merendine_scadute.png` |  |
| Molotov | `art/oggetti/molotov.png` |  |
| Motosega | `art/oggetti/motosega.png` |  |
| Gel Omega | `art/oggetti/omega_gel.png` |  |
| Petardo | `art/oggetti/petardo.png` |  |
| Pietra Quieta | `art/oggetti/pietra_quieta.png` |  |
| Premio di pezza | `art/oggetti/premio_di_pezza.png` |  |
| Razione da viaggio | `art/oggetti/razione_del_circo.png` |  |
| Ricordo del Passato | `art/oggetti/ricordo_del_passato.png` |  |
| Sale amaro | `art/oggetti/sale_amaro.png` |  |
| Sparachiodi arrugginito | `art/oggetti/sparachiodi_arrugginito.png` |  |
| Spazio nella realtà | `art/oggetti/spazio_nella_realta.png` |  |
| Specchio tascabile | `art/oggetti/specchio_tascabile.png` |  |
| Spranga di ferro | `art/oggetti/spranga_di_ferro.png` |  |
| Stigma del muto | `art/oggetti/stigma_del_muto.png` |  |
| Stigma del veglio | `art/oggetti/stigma_del_veglio.png` |  |
| Tonico calmante | `art/oggetti/tonico_calmante.png` |  |
| Vino di ottima qualità | `art/oggetti/vino_di_ottima_qualita.png` |  |

### Le icone delle statistiche: `art/interfaccia/statistiche/<chiave>.png`

| statistica | file | c'è |
|---|---|:-:|
| Punti vita | `art/interfaccia/statistiche/hp.png` |  |
| Attacco | `art/interfaccia/statistiche/attacco.png` |  |
| Difesa | `art/interfaccia/statistiche/difesa.png` |  |
| Velocità | `art/interfaccia/statistiche/velocita.png` |  |
| Aura | `art/interfaccia/statistiche/aura.png` |  |

## Il resto

| file | cos'è | c'è |
|---|---|:-:|
| `art/mappa.png` | Sfondo della mappa stellare (la proiezione del settore) |  |
| `art/sede.png` | Sfondo della Sede |  |
| `art/branding/logo_studio.png` | Logo Rio Chico Devs, primo dei loghi d'apertura |  |
| `art/branding/logo_personale.png` | Logo personale, secondo logo d'apertura |  |
| `art/fx/slaughter.png` | Illustrazione a schermo intero dello Slaughter |  |

---

Ritratti presenti: **0 su 60**.
