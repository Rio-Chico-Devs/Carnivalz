# Topologia delle mappe (generato, non scrivere qui a mano)

Prodotto da `strumenti/topologia.py`. Guarda **come sono attaccate** le stanze, non
cosa c'e' scritto dentro. Le domande che risponde, e da dove vengono, stanno in
`docs/dedalo.md`.

- **anelli** — giri chiusi indipendenti. Zero = un albero, cioe' un corridoio con
  vicoli ciechi: si va avanti e si torna dalla stessa strada
- **scorciatoie** — archi che saltano almeno tre stanze. Sono gli anelli che si
  *sentono*. Escluse quelle prodotte da una sconfitta: quelle non le trovi, ti capitano
- **bivi** — stanze che offrono almeno due strade che non siano «torna indietro»
- **sostanza** — stanze con qualcosa dentro. Le altre si attraversano e basta

## Il quadro

| zona | stanze | porte | anelli | scorciatoie | bivi | con sostanza | agguati | cancelli | profondita' |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|
| casa_gigante | 79 | 114 | 36 | 10 | 21 | 30 | 10 | 11 | 11 |
| fontana | 3 | 2 | 0 | 0 | 1 | 1 | 0 | 0 | 1 |
| kizako_ala | 8 | 10 | 3 | 0 | 4 | 4 | 3 | 0 | 4 |
| meridia | 28 | 50 | 23 | 8 | 8 | 14 | 5 | 0 | 12 |
| qualcosa_preme | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| rocca_ossidiana | 37 | 58 | 22 | 3 | 13 | 21 | 3 | 8 | 16 |
| squarcio_industriale | 27 | 49 | 23 | 3 | 9 | 12 | 6 | 0 | 11 |
| teatro_del_passato | 6 | 5 | 0 | 0 | 4 | 6 | 0 | 0 | 3 |
| **tutte** | **189** | **288** | **107** | **24** | **60** | **88** | **27** | **19** | |

## Quante scelte offre una stanza

Senza contare «torna indietro»: quelle non sono una strada nuova.

| scelte vere | stanze | |
|--:|--:|---|
| 0 | 52 | ████████████████████████████████████████████████████ |
| 1 | 77 | █████████████████████████████████████████████████████████████████████████████ |
| 2 | 24 | ████████████████████████ |
| 3 | 16 | ████████████████ |
| 4 | 13 | █████████████ |
| 5 | 3 | ███ |
| 6 | 2 | ██ |
| 7 | 2 | ██ |

**129 stanze su 189 (68%) non offrono nessuna scelta**: una strada sola, o nessuna.  
**154 scelte su 420 (37%) sono «torna indietro».**  
Altre **41** sono cappi: ti lasciano dove sei (frugare, osservare, raccogliere).

## Le scorciatoie vere

Archi che saltano almeno tre stanze e che **non** sono l'espulsione dopo una sconfitta.

| zona | da | a | salta |
|---|---|---|--:|
| casa_gigante | `albero_addio_buono` | `giardino_est` | 5 |
| casa_gigante | `albero_addio` | `giardino_est` | 4 |
| casa_gigante | `spirito_hub` | `spirito_storia_lasciata` | 4 |
| casa_gigante | `spirito_hub` | `spirito_storia_buona` | 4 |
| casa_gigante | `dopo_volto` | `vivaio_3` | 3 |
| casa_gigante | `altare` | `congedo_yhvina` | 3 |
| casa_gigante | `giardino_est` | `spirito_hub` | 3 |
| casa_gigante | `attico` | `yhvina_si_dopo` | 3 |
| casa_gigante | `id_card_trovata` | `vivaio_3` | 3 |
| casa_gigante | `giardino_nord` | `vivaio_apertura` | 3 |
| meridia | `complessi` | `dopo_ondate` | 9 |
| meridia | `dopo_ondate` | `struttura` | 8 |
| meridia | `complessi` | `seconda_ondata` | 8 |
| meridia | `complessi` | `dopo_infetto` | 7 |
| meridia | `complessi` | `fuori_struttura_dopo` | 7 |
| meridia | `complessi` | `fuori_struttura` | 6 |
| meridia | `fuori_struttura_dopo` | `struttura` | 6 |
| meridia | `complessi` | `dopo_nuvola` | 3 |
| rocca_ossidiana | `ponte_approccio` | `ponte_attacco_compagna` | 5 |
| rocca_ossidiana | `ponte_approccio` | `ponte_attacco` | 4 |
| rocca_ossidiana | `cunicolo_2` | `piazza_con_yara` | 3 |
| squarcio_industriale | `corridoio_tubi_aperto` | `varco` | 5 |
| squarcio_industriale | `corridoio_tubi` | `dopo_operaio` | 4 |
| squarcio_industriale | `corridoio_tubi` | `varco` | 4 |

In piu' ci sono **14** archi lunghi prodotti da una sconfitta, che portano fuori.
Non contano come scorciatoie: non sono una cosa che trovi, sono una cosa che ti succede.

## I cancelli: quanto dista la chiave dalla serratura

Una serratura accanto alla sua chiave e' un dosso, non una porta chiusa.
«chiave fuori zona» vuol dire che la bandierina si accende altrove — in un dialogo,
in un incarico, in un evento — e non e' un errore.

| zona | condizione | chiave | serratura | distanza |
|---|---|--:|--:|--:|
| casa_gigante | `casa_ricordo_sconfitto` | 9 | 0 | 9 |
| casa_gigante | `casa_botola` | — | 4 | chiave fuori zona |
| casa_gigante | `casa_botola` | — | 4 | chiave fuori zona |
| casa_gigante | `casa_botola` | — | 4 | chiave fuori zona |
| casa_gigante | `casa_ricordo_sconfitto` | 9 | 7 | 2 |
| casa_gigante | `casa_ricordo_sconfitto` | 9 | 7 | 2 |
| casa_gigante | `casa_botola` | — | 6 | chiave fuori zona |
| casa_gigante | `casa_spirito_lab` | 6 | 6 | 0 |
| casa_gigante | `casa_matrice` | 5 | 6 | 1 |
| casa_gigante | `casa_spirito_vivaio` | 6 | 6 | 0 |
| casa_gigante | `casa_spirito_vivaio` | 6 | 6 | 0 |
| rocca_ossidiana | `oss_lamento_superato` | 4 | 3 | 1 |
| rocca_ossidiana | `oss_lamento_superato` | 4 | 3 | 1 |
| rocca_ossidiana | `oss_compagna_reclutata` | 7 | 5 | 2 |
| rocca_ossidiana | `oss_compagna_reclutata` | 7 | 9 | 2 |
| rocca_ossidiana | `oss_compagna_reclutata` | 7 | 10 | 3 |
| rocca_ossidiana | `oss_cripta_superata` | 12 | 11 | 1 |
| rocca_ossidiana | `oss_cripta_superata` | 12 | 12 | 0 |
| rocca_ossidiana | `oss_compagna_reclutata` | 7 | 12 | 5 |

## Stanze che non si raggiungono

Nessuna: da ogni ingresso si arriva a ogni stanza della sua zona.

