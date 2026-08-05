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
| Zombie Cittadino | 2 | `art/personaggi/zombie_cittadino.png` | — |  |
| Fomentado | 3 | `art/personaggi/maschera_vuota.png` | — |  |
| Manifestazione di un sogno | 3 | `art/personaggi/manifestazione_di_un_sogno.png` | — |  |
| Zombie Mostruoso | 3 | `art/personaggi/zombie_mostruoso.png` | — |  |
| Capocantiere | 4 | `art/personaggi/voce_registrata.png` | — |  |
| El Muy Bonito | 4 | `art/personaggi/giocoliere.png` | — |  |
| Oppresso | 4 | `art/personaggi/comparsa_di_ruggine.png` | — |  |
| Emblema dell'oppressione | 5 | `art/personaggi/operaio_posseduto.png` | — |  |
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
| Marionetta | 13 | `art/personaggi/marionetta.png` | — |  |
| Jongo Dongo | 14 | `art/personaggi/jongo_dongo.png` | — |  |
| Ombra del passato | 14 | `art/personaggi/ombra_del_passato.png` | — |  |
| Un tenero ricordo | 15 | `art/personaggi/tenero_ricordo.png` | — |  |
| L'ultimo spettacolo di Jerah | 18 | `art/personaggi/jerah.png` | — |  |

## Personaggi

| chi | file | espressioni | c'è |
|---|---|---|:-:|
| Dott.ssa Curie Heartlife | `art/personaggi/curie.png` | `art/personaggi/curie/` |  |
| Le lettere sull'altare | `art/personaggi/lettere_altare.png` | `art/personaggi/lettere_altare/` |  |

## Il resto

| file | cos'è | c'è |
|---|---|:-:|
| `art/mappa.png` | Sfondo della mappa stellare (la proiezione del settore) |  |
| `art/sede.png` | Sfondo della Sede |  |
| `art/branding/logo_studio.png` | Logo Rio Chico Devs, primo dei loghi d'apertura |  |
| `art/branding/logo_personale.png` | Logo personale, secondo logo d'apertura |  |
| `art/fx/slaughter.png` | Illustrazione a schermo intero dello Slaughter |  |

---

Ritratti presenti: **0 su 48**.
