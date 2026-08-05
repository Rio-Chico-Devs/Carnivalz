# Bilanciamento (generato, non scrivere qui a mano)

Prodotto da `prove/Simulatore.gd`: **99000 partite** giocate dal motore vero in 481 secondi.

Non e' una stima e non e' un modello: e' `Combattimento.tscn` istanziata e giocata,
con Voce/Campo/Menu muti. Se questi numeri sono sbagliati, sono sbagliati anche
quando ci giochi tu.

Ogni riga e' la media su 150 partite con semi fissi: due esecuzioni danno lo stesso
risultato, quindi una differenza qui e' sempre una differenza nel gioco.

**Il protagonista e' quello vero.** Nel gioco le stat non salgono col livello, salgono
con quello che hai fatto: per mesi qui saliva solo il livello, e la tabella misurava
uno arrivato al livello 8 senza aver mai combattuto. Adesso si applica il
`profilo_giocatore_tipo` di crescita.json prima di ogni scontro. Se quella stima e'
sbagliata, tutta questa tabella e' sbagliata: e' il numero piu' importante del file.

- **vinte / perse / ∞** — percentuale di partite. `∞` = non finisce entro 60 giri
- **giri** — durata media (un giro = tutti agiscono una volta)
- **danno** — punti vita persi in media dal protagonista (ne ha 425)
- **risp.** — percentuale di partite in cui la creatura e' stata risparmiata

## A che livello ogni scontro diventa giusto

Livello minimo a cui si vince almeno l'80% delle volte andandoci dritto.

| creatura | id | hp | att | livello |
|---|---|--:|--:|--:|
| Abominio Marcio | `abominio_marcio` | 699 | 43 | **mai** |
| Oppresso | `comparsa_di_ruggine` | 160 | 13 | 2 |
| Diabolo | `diabolo` | 347 | 25 | 5 |
| Il Divoratore | `divoratore` | 450 | 27 | 8 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | 540 | 47 | 8 |
| Ferraglia Urlante | `ferraglia_urlante` | 360 | 18 | 5 |
| Ghoul | `ghoul` | 352 | 23 | 5 |
| El Muy Bonito | `giocoliere` | 297 | 13 | 3 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | 1125 | 22 | 8 |
| Goblin Tipico | `goblin_tipico` | 90 | 5 | 1 |
| Infetto Rapido | `infetto_rapido` | 126 | 8 | 1 |
| L'ultimo spettacolo di Jerah | `jerah` | 2225 | 63 | **mai** |
| Jongo Dongo | `jongo_dongo` | 1225 | 43 | **mai** |
| Jongo Dongo | `jongo_dongo_risorto` | 1400 | 50 | **mai** |
| ??? | `l_immortale` | 120 | 5 | **mai** |
| Madre in Lacrime | `madre_in_lacrime` | 328 | 23 | 5 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | 320 | 23 | **mai** |
| Marionetta | `marionetta` | 547 | 56 | **mai** |
| Fomentado | `maschera_vuota` | 162 | 10 | 1 |
| Ombra del passato | `ombra_del_passato` | 597 | 60 | **mai** |
| Emblema dell'oppressione | `operaio_posseduto` | 199 | 15 | 3 |
| Orrore di Meridia | `orrore_di_meridia` | 361 | 24 | 5 |
| Sacerdote Folle | `sacerdote_folle` | 540 | 47 | **mai** |
| Sadico | `sadico` | 403 | 39 | 8 |
| Slime Infimo | `slime_infimo` | 90 | 5 | 1 |
| Stigma | `stigma` | 381 | 39 | 8 |
| Tartaruga Innocente | `tartaruga_innocente` | 555 | 0 | **mai** |
| Un tenero ricordo | `tenero_ricordo` | 6660 | 27 | **mai** |
| Teschio Errante | `teschio_errante` | 292 | 23 | 5 |
| Titano Zombie | `titano_zombie` | 840 | 44 | **mai** |
| Capocantiere | `voce_registrata` | 168 | 13 | 2 |
| Zombie Cittadino | `zombie_cittadino` | 126 | 7 | 1 |
| Zombie Mostruoso | `zombie_mostruoso` | 162 | 10 | 2 |
## Curva di riferimento (quanto dovrebbe essere forte una creatura)

Non e' una regola che il gioco applica: e' un metro per accorgersi di chi e' fuori
scala. Una creatura dovrebbe reggere una decina di colpi e portarsi via circa un
terzo della vita del protagonista.

| livello | il protagonista ha | hp consigliati | attacco consigliato |
|--:|---|--:|--:|
| 1 | 100 hp, 15 attacco | 120 | 4 |
| 2 | 145 hp, 21 attacco | 168 | 6 |
| 3 | 190 hp, 27 attacco | 216 | 8 |
| 5 | 285 hp, 39 attacco | 312 | 12 |
| 8 | 425 hp, 57 attacco | 456 | 18 |
| 12 | 610 hp, 81 attacco | 648 | 25 |
| 16 | 800 hp, 105 attacco | 840 | 33 |
| 20 | 985 hp, 129 attacco | 1032 | 41 |

### Creature molto lontane dal riferimento

| creatura | livello | hp | consigliati | attacco | consigliato |
|---|--:|--:|--:|--:|--:|
| Abominio Marcio | 10 | 699 | 552 | 43 | 21 |
| Divoratore di Carcasse | 11 | 540 | 600 | 47 | 23 |
| Un goblin terribilmente arrabbiato | 6 | 1125 | 360 | 22 | 14 |
| L'ultimo spettacolo di Jerah | 18 | 2225 | 936 | 63 | 37 |
| ??? | 8 | 120 | 456 | 5 | 18 |
| Manifestazione di un sogno | 3 | 320 | 216 | 23 | 8 |
| Marionetta | 13 | 547 | 696 | 56 | 27 |
| Ombra del passato | 14 | 597 | 744 | 60 | 29 |
| Sacerdote Folle | 11 | 540 | 600 | 47 | 23 |
| Sadico | 9 | 403 | 504 | 39 | 19 |
| Stigma | 9 | 381 | 504 | 39 | 19 |
| Tartaruga Innocente | 1 | 555 | 120 | 0 | 4 |
| Un tenero ricordo | 15 | 6660 | 792 | 27 | 31 |
| Titano Zombie | 10 | 840 | 552 | 44 | 21 |

## Protagonista di livello 1

| creatura | id | come si gioca | vinte | perse | ∞ | giri | danno | risp. | xp |
|---|---|---|--:|--:|--:|--:|--:|--:|--:|
| Abominio Marcio | `abominio_marcio` | attacca | 0% | 100% | 0% | 2.9 | 100.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | difendi | 0% | 100% | 0% | 3.8 | 100.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | studia | 0% | 100% | 0% | 2.9 | 100.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | casuale | 0% | 100% | 0% | 3.0 | 100.0 | 0% | 0 |
| Oppresso | `comparsa_di_ruggine` | attacca | 3% | 97% | 0% | 7.8 | 97.7 | 0% | 0 |
| Oppresso | `comparsa_di_ruggine` | difendi | 0% | 39% | 61% | 57.9 | 89.8 | 0% | 0 |
| Oppresso | `comparsa_di_ruggine` | studia | 5% | 95% | 0% | 7.8 | 98.4 | 0% | 0 |
| Oppresso | `comparsa_di_ruggine` | casuale | 2% | 98% | 0% | 10.6 | 99.5 | 0% | 0 |
| Diabolo | `diabolo` | attacca | 6% | 94% | 0% | 4.7 | 97.4 | 0% | 0 |
| Diabolo | `diabolo` | difendi | 0% | 100% | 0% | 9.1 | 100.0 | 0% | 0 |
| Diabolo | `diabolo` | studia | 0% | 100% | 0% | 4.8 | 100.0 | 0% | 0 |
| Diabolo | `diabolo` | casuale | 1% | 99% | 0% | 5.1 | 99.8 | 0% | 0 |
| Il Divoratore | `divoratore` | attacca | 0% | 100% | 0% | 4.0 | 100.0 | 0% | 0 |
| Il Divoratore | `divoratore` | difendi | 0% | 100% | 0% | 9.1 | 100.0 | 0% | 0 |
| Il Divoratore | `divoratore` | studia | 0% | 100% | 0% | 4.0 | 100.0 | 0% | 0 |
| Il Divoratore | `divoratore` | casuale | 0% | 100% | 0% | 5.0 | 100.0 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | attacca | 2% | 98% | 0% | 3.2 | 98.6 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | difendi | 0% | 100% | 0% | 5.5 | 100.0 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | studia | 0% | 100% | 0% | 3.4 | 100.0 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | casuale | 1% | 99% | 0% | 3.6 | 99.6 | 0% | 0 |
| Ferraglia Urlante | `ferraglia_urlante` | attacca | 0% | 100% | 0% | 6.0 | 100.0 | 0% | 0 |
| Ferraglia Urlante | `ferraglia_urlante` | difendi | 0% | 79% | 21% | 47.8 | 97.4 | 0% | 0 |
| Ferraglia Urlante | `ferraglia_urlante` | studia | 0% | 100% | 0% | 6.0 | 100.0 | 0% | 0 |
| Ferraglia Urlante | `ferraglia_urlante` | casuale | 0% | 100% | 0% | 7.7 | 100.0 | 0% | 0 |
| Ghoul | `ghoul` | attacca | 3% | 97% | 0% | 4.7 | 98.0 | 0% | 0 |
| Ghoul | `ghoul` | difendi | 0% | 100% | 0% | 14.6 | 100.0 | 0% | 0 |
| Ghoul | `ghoul` | studia | 1% | 99% | 0% | 4.8 | 99.7 | 0% | 0 |
| Ghoul | `ghoul` | casuale | 1% | 99% | 0% | 5.6 | 99.7 | 0% | 0 |
| El Muy Bonito | `giocoliere` | attacca | 0% | 100% | 0% | 7.9 | 100.0 | 0% | 0 |
| El Muy Bonito | `giocoliere` | difendi | 0% | 60% | 40% | 54.0 | 96.1 | 0% | 0 |
| El Muy Bonito | `giocoliere` | studia | 0% | 100% | 0% | 5.8 | 100.0 | 0% | 0 |
| El Muy Bonito | `giocoliere` | casuale | 0% | 100% | 0% | 8.4 | 100.0 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | attacca | 0% | 100% | 0% | 7.6 | 100.0 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | difendi | 0% | 100% | 0% | 24.7 | 100.0 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | studia | 0% | 100% | 0% | 7.5 | 100.0 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | casuale | 0% | 100% | 0% | 9.0 | 100.0 | 0% | 0 |
| Goblin Tipico | `goblin_tipico` | attacca | 100% | 0% | 0% | 5.9 | 25.2 | 0% | 2 |
| Goblin Tipico | `goblin_tipico` | difendi | 0% | 0% | 100% | 61.0 | 60.2 | 0% | 0 |
| Goblin Tipico | `goblin_tipico` | studia | 100% | 0% | 0% | 8.9 | 40.9 | 0% | 2 |
| Goblin Tipico | `goblin_tipico` | casuale | 93% | 7% | 0% | 18.0 | 62.4 | 0% | 2 |
| Infetto Rapido | `infetto_rapido` | attacca | 100% | 0% | 0% | 8.2 | 66.9 | 0% | 7 |
| Infetto Rapido | `infetto_rapido` | difendi | 0% | 0% | 100% | 61.0 | 73.9 | 0% | 0 |
| Infetto Rapido | `infetto_rapido` | studia | 67% | 33% | 0% | 11.6 | 94.5 | 0% | 5 |
| Infetto Rapido | `infetto_rapido` | casuale | 7% | 93% | 0% | 17.0 | 98.6 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | attacca | 0% | 100% | 0% | 3.9 | 100.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | difendi | 0% | 100% | 0% | 5.5 | 100.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | studia | 0% | 100% | 0% | 4.3 | 100.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | casuale | 0% | 100% | 0% | 4.3 | 100.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | attacca | 0% | 100% | 0% | 6.7 | 100.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | difendi | 0% | 100% | 0% | 12.5 | 100.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | studia | 0% | 100% | 0% | 6.4 | 100.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | casuale | 0% | 100% | 0% | 7.2 | 100.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | attacca | 0% | 100% | 0% | 2.9 | 100.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | difendi | 0% | 100% | 0% | 2.9 | 100.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | studia | 0% | 100% | 0% | 2.9 | 100.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | casuale | 0% | 100% | 0% | 2.9 | 100.0 | 0% | 0 |
| ??? | `l_immortale` | attacca | 0% | 100% | 0% | 19.7 | 100.0 | 0% | 0 |
| ??? | `l_immortale` | difendi | 0% | 0% | 100% | 61.0 | 60.2 | 0% | 0 |
| ??? | `l_immortale` | studia | 0% | 100% | 0% | 19.7 | 100.0 | 0% | 0 |
| ??? | `l_immortale` | casuale | 0% | 100% | 0% | 26.8 | 100.0 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | attacca | 3% | 97% | 0% | 4.7 | 98.0 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | difendi | 0% | 100% | 0% | 14.6 | 100.0 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | studia | 1% | 99% | 0% | 4.8 | 99.7 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | casuale | 1% | 99% | 0% | 5.6 | 99.7 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | attacca | 0% | 100% | 0% | 6.0 | 100.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | difendi | 0% | 100% | 0% | 6.0 | 100.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | studia | 0% | 100% | 0% | 6.0 | 100.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | casuale | 0% | 100% | 0% | 6.0 | 100.0 | 0% | 0 |
| Marionetta | `marionetta` | attacca | 2% | 98% | 0% | 2.0 | 98.4 | 0% | 0 |
| Marionetta | `marionetta` | difendi | 0% | 100% | 0% | 2.9 | 100.0 | 0% | 0 |
| Marionetta | `marionetta` | studia | 0% | 100% | 0% | 2.0 | 100.0 | 0% | 0 |
| Marionetta | `marionetta` | casuale | 0% | 100% | 0% | 2.6 | 100.0 | 0% | 0 |
| Fomentado | `maschera_vuota` | attacca | 100% | 0% | 0% | 8.3 | 74.2 | 0% | 8 |
| Fomentado | `maschera_vuota` | difendi | 100% | 0% | 0% | 33.0 | 40.7 | 0% | 8 |
| Fomentado | `maschera_vuota` | studia | 41% | 59% | 0% | 9.8 | 94.2 | 0% | 3 |
| Fomentado | `maschera_vuota` | casuale | 27% | 73% | 0% | 14.1 | 96.1 | 0% | 2 |
| Ombra del passato | `ombra_del_passato` | attacca | 2% | 98% | 0% | 2.0 | 98.4 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | difendi | 0% | 100% | 0% | 2.9 | 100.0 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | studia | 0% | 100% | 0% | 2.0 | 100.0 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | casuale | 0% | 100% | 0% | 2.1 | 100.0 | 0% | 0 |
| Emblema dell'oppressione | `operaio_posseduto` | attacca | 3% | 97% | 0% | 7.5 | 97.8 | 0% | 0 |
| Emblema dell'oppressione | `operaio_posseduto` | difendi | 0% | 63% | 37% | 55.0 | 93.5 | 0% | 0 |
| Emblema dell'oppressione | `operaio_posseduto` | studia | 5% | 95% | 0% | 7.6 | 98.6 | 0% | 1 |
| Emblema dell'oppressione | `operaio_posseduto` | casuale | 1% | 99% | 0% | 9.5 | 99.6 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | attacca | 0% | 100% | 0% | 5.3 | 100.0 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | difendi | 0% | 100% | 0% | 20.3 | 100.0 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | studia | 0% | 100% | 0% | 5.3 | 100.0 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | casuale | 0% | 100% | 0% | 6.5 | 100.0 | 0% | 0 |
| Sacerdote Folle | `sacerdote_folle` | attacca | 3% | 97% | 0% | 4.5 | 98.0 | 0% | 1 |
| Sacerdote Folle | `sacerdote_folle` | difendi | 0% | 100% | 0% | 8.4 | 100.0 | 0% | 0 |
| Sacerdote Folle | `sacerdote_folle` | studia | 1% | 99% | 0% | 4.8 | 99.8 | 0% | 0 |
| Sacerdote Folle | `sacerdote_folle` | casuale | 1% | 99% | 0% | 5.4 | 99.8 | 0% | 0 |
| Sadico | `sadico` | attacca | 2% | 98% | 0% | 3.0 | 98.3 | 0% | 0 |
| Sadico | `sadico` | difendi | 0% | 100% | 0% | 4.7 | 100.0 | 0% | 0 |
| Sadico | `sadico` | studia | 0% | 100% | 0% | 3.0 | 100.0 | 0% | 0 |
| Sadico | `sadico` | casuale | 0% | 100% | 0% | 3.2 | 100.0 | 0% | 0 |
| Slime Infimo | `slime_infimo` | attacca | 100% | 0% | 0% | 5.9 | 25.2 | 0% | 2 |
| Slime Infimo | `slime_infimo` | difendi | 0% | 0% | 100% | 61.0 | 60.2 | 0% | 0 |
| Slime Infimo | `slime_infimo` | studia | 100% | 0% | 0% | 8.9 | 40.9 | 0% | 2 |
| Slime Infimo | `slime_infimo` | casuale | 93% | 7% | 0% | 18.0 | 62.4 | 0% | 2 |
| Stigma | `stigma` | attacca | 3% | 97% | 0% | 2.9 | 98.4 | 0% | 0 |
| Stigma | `stigma` | difendi | 0% | 100% | 0% | 3.8 | 100.0 | 0% | 0 |
| Stigma | `stigma` | studia | 0% | 100% | 0% | 3.0 | 100.0 | 0% | 0 |
| Stigma | `stigma` | casuale | 0% | 100% | 0% | 3.1 | 100.0 | 0% | 0 |
| Tartaruga Innocente | `tartaruga_innocente` | attacca | 49% | 0% | 51% | 46.3 | 0.0 | 0% | 7 |
| Tartaruga Innocente | `tartaruga_innocente` | difendi | 0% | 0% | 100% | 61.0 | 0.0 | 0% | 0 |
| Tartaruga Innocente | `tartaruga_innocente` | studia | 100% | 0% | 0% | 1.0 | 0.0 | 100% | 19 |
| Tartaruga Innocente | `tartaruga_innocente` | casuale | 100% | 0% | 0% | 3.0 | 0.0 | 99% | 19 |
| Un tenero ricordo | `tenero_ricordo` | attacca | 0% | 100% | 0% | 5.1 | 100.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | difendi | 0% | 100% | 0% | 6.5 | 100.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | studia | 0% | 100% | 0% | 5.4 | 100.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | casuale | 0% | 100% | 0% | 5.5 | 100.0 | 0% | 0 |
| Teschio Errante | `teschio_errante` | attacca | 6% | 94% | 0% | 4.7 | 97.1 | 0% | 0 |
| Teschio Errante | `teschio_errante` | difendi | 0% | 100% | 0% | 12.1 | 100.0 | 0% | 0 |
| Teschio Errante | `teschio_errante` | studia | 0% | 100% | 0% | 4.8 | 100.0 | 0% | 0 |
| Teschio Errante | `teschio_errante` | casuale | 1% | 99% | 0% | 5.4 | 99.7 | 0% | 0 |
| Titano Zombie | `titano_zombie` | attacca | 0% | 100% | 0% | 5.3 | 100.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | difendi | 0% | 100% | 0% | 5.9 | 100.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | studia | 0% | 100% | 0% | 4.6 | 100.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | casuale | 0% | 100% | 0% | 5.0 | 100.0 | 0% | 0 |
| Capocantiere | `voce_registrata` | attacca | 9% | 91% | 0% | 7.6 | 95.2 | 0% | 1 |
| Capocantiere | `voce_registrata` | difendi | 0% | 63% | 37% | 54.3 | 95.8 | 0% | 0 |
| Capocantiere | `voce_registrata` | studia | 1% | 99% | 0% | 7.9 | 99.9 | 0% | 0 |
| Capocantiere | `voce_registrata` | casuale | 1% | 99% | 0% | 10.2 | 99.5 | 0% | 0 |
| Zombie Cittadino | `zombie_cittadino` | attacca | 100% | 0% | 0% | 8.5 | 54.3 | 0% | 6 |
| Zombie Cittadino | `zombie_cittadino` | difendi | 0% | 0% | 100% | 61.0 | 63.7 | 0% | 0 |
| Zombie Cittadino | `zombie_cittadino` | studia | 100% | 0% | 0% | 11.3 | 74.0 | 0% | 6 |
| Zombie Cittadino | `zombie_cittadino` | casuale | 15% | 85% | 0% | 19.4 | 97.1 | 0% | 1 |
| Zombie Mostruoso | `zombie_mostruoso` | attacca | 15% | 85% | 0% | 9.7 | 96.2 | 0% | 2 |
| Zombie Mostruoso | `zombie_mostruoso` | difendi | 0% | 1% | 99% | 61.0 | 76.1 | 0% | 0 |
| Zombie Mostruoso | `zombie_mostruoso` | studia | 5% | 95% | 0% | 9.8 | 98.3 | 0% | 1 |
| Zombie Mostruoso | `zombie_mostruoso` | casuale | 2% | 98% | 0% | 14.6 | 98.9 | 0% | 0 |

## Protagonista di livello 2

| creatura | id | come si gioca | vinte | perse | ∞ | giri | danno | risp. | xp |
|---|---|---|--:|--:|--:|--:|--:|--:|--:|
| Abominio Marcio | `abominio_marcio` | attacca | 0% | 100% | 0% | 4.0 | 145.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | difendi | 0% | 100% | 0% | 5.8 | 145.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | studia | 0% | 100% | 0% | 4.0 | 145.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | casuale | 0% | 100% | 0% | 4.4 | 145.0 | 0% | 0 |
| Oppresso | `comparsa_di_ruggine` | attacca | 100% | 0% | 0% | 10.3 | 105.9 | 0% | 10 |
| Oppresso | `comparsa_di_ruggine` | difendi | 0% | 0% | 100% | 61.0 | 90.2 | 0% | 0 |
| Oppresso | `comparsa_di_ruggine` | studia | 71% | 29% | 0% | 12.6 | 134.0 | 0% | 7 |
| Oppresso | `comparsa_di_ruggine` | casuale | 3% | 97% | 0% | 17.5 | 143.0 | 0% | 0 |
| Diabolo | `diabolo` | attacca | 7% | 93% | 0% | 6.5 | 139.3 | 0% | 1 |
| Diabolo | `diabolo` | difendi | 0% | 100% | 0% | 16.9 | 145.0 | 0% | 0 |
| Diabolo | `diabolo` | studia | 0% | 100% | 0% | 6.8 | 145.0 | 0% | 0 |
| Diabolo | `diabolo` | casuale | 1% | 99% | 0% | 7.7 | 144.4 | 0% | 0 |
| Il Divoratore | `divoratore` | attacca | 0% | 100% | 0% | 6.0 | 145.0 | 0% | 0 |
| Il Divoratore | `divoratore` | difendi | 0% | 100% | 0% | 15.2 | 145.0 | 0% | 0 |
| Il Divoratore | `divoratore` | studia | 0% | 100% | 0% | 6.0 | 145.0 | 0% | 0 |
| Il Divoratore | `divoratore` | casuale | 0% | 100% | 0% | 7.2 | 145.0 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | attacca | 3% | 97% | 0% | 4.5 | 142.6 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | difendi | 0% | 100% | 0% | 7.9 | 145.0 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | studia | 0% | 100% | 0% | 4.7 | 145.0 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | casuale | 1% | 99% | 0% | 5.3 | 143.9 | 0% | 0 |
| Ferraglia Urlante | `ferraglia_urlante` | attacca | 0% | 100% | 0% | 9.6 | 145.0 | 0% | 0 |
| Ferraglia Urlante | `ferraglia_urlante` | difendi | 0% | 19% | 81% | 59.4 | 116.5 | 0% | 0 |
| Ferraglia Urlante | `ferraglia_urlante` | studia | 0% | 100% | 0% | 9.6 | 145.0 | 0% | 0 |
| Ferraglia Urlante | `ferraglia_urlante` | casuale | 0% | 100% | 0% | 11.6 | 145.0 | 0% | 0 |
| Ghoul | `ghoul` | attacca | 3% | 97% | 0% | 6.8 | 141.8 | 0% | 0 |
| Ghoul | `ghoul` | difendi | 0% | 100% | 0% | 26.4 | 145.0 | 0% | 0 |
| Ghoul | `ghoul` | studia | 3% | 97% | 0% | 6.9 | 143.9 | 0% | 0 |
| Ghoul | `ghoul` | casuale | 1% | 99% | 0% | 8.6 | 144.3 | 0% | 0 |
| El Muy Bonito | `giocoliere` | attacca | 12% | 88% | 0% | 12.9 | 144.7 | 0% | 2 |
| El Muy Bonito | `giocoliere` | difendi | 0% | 0% | 100% | 61.0 | 100.6 | 0% | 0 |
| El Muy Bonito | `giocoliere` | studia | 0% | 100% | 0% | 7.0 | 145.0 | 0% | 0 |
| El Muy Bonito | `giocoliere` | casuale | 0% | 100% | 0% | 10.7 | 145.0 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | attacca | 0% | 100% | 0% | 10.9 | 145.0 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | difendi | 0% | 100% | 0% | 38.4 | 145.0 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | studia | 0% | 100% | 0% | 10.9 | 145.0 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | casuale | 0% | 100% | 0% | 13.2 | 145.0 | 0% | 0 |
| Goblin Tipico | `goblin_tipico` | attacca | 100% | 0% | 0% | 4.7 | 15.5 | 0% | 2 |
| Goblin Tipico | `goblin_tipico` | difendi | 0% | 0% | 100% | 61.0 | 60.1 | 0% | 0 |
| Goblin Tipico | `goblin_tipico` | studia | 100% | 0% | 0% | 7.7 | 28.3 | 0% | 2 |
| Goblin Tipico | `goblin_tipico` | casuale | 100% | 0% | 0% | 14.6 | 41.4 | 0% | 2 |
| Infetto Rapido | `infetto_rapido` | attacca | 100% | 0% | 0% | 5.7 | 41.2 | 0% | 7 |
| Infetto Rapido | `infetto_rapido` | difendi | 0% | 0% | 100% | 61.0 | 72.7 | 0% | 0 |
| Infetto Rapido | `infetto_rapido` | studia | 100% | 0% | 0% | 8.9 | 64.3 | 0% | 7 |
| Infetto Rapido | `infetto_rapido` | casuale | 97% | 3% | 0% | 17.4 | 90.9 | 0% | 7 |
| L'ultimo spettacolo di Jerah | `jerah` | attacca | 0% | 100% | 0% | 5.5 | 145.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | difendi | 0% | 100% | 0% | 7.6 | 145.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | studia | 0% | 100% | 0% | 5.8 | 145.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | casuale | 0% | 100% | 0% | 6.0 | 145.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | attacca | 0% | 100% | 0% | 9.2 | 145.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | difendi | 0% | 100% | 0% | 18.7 | 145.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | studia | 0% | 100% | 0% | 8.8 | 145.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | casuale | 0% | 100% | 0% | 10.0 | 145.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | attacca | 0% | 100% | 0% | 3.8 | 145.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | difendi | 0% | 100% | 0% | 4.8 | 145.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | studia | 0% | 100% | 0% | 3.9 | 145.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | casuale | 0% | 100% | 0% | 3.9 | 145.0 | 0% | 0 |
| ??? | `l_immortale` | attacca | 0% | 100% | 0% | 35.1 | 145.0 | 0% | 0 |
| ??? | `l_immortale` | difendi | 0% | 0% | 100% | 61.0 | 60.1 | 0% | 0 |
| ??? | `l_immortale` | studia | 0% | 100% | 0% | 35.1 | 145.0 | 0% | 0 |
| ??? | `l_immortale` | casuale | 0% | 100% | 0% | 46.7 | 145.0 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | attacca | 3% | 97% | 0% | 6.8 | 141.8 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | difendi | 0% | 100% | 0% | 26.4 | 145.0 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | studia | 3% | 97% | 0% | 6.9 | 143.9 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | casuale | 1% | 99% | 0% | 8.6 | 144.3 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | attacca | 0% | 100% | 0% | 6.0 | 145.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | difendi | 0% | 100% | 0% | 6.0 | 145.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | studia | 0% | 100% | 0% | 6.0 | 145.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | casuale | 0% | 100% | 0% | 6.0 | 145.0 | 0% | 0 |
| Marionetta | `marionetta` | attacca | 2% | 98% | 0% | 3.0 | 142.4 | 0% | 0 |
| Marionetta | `marionetta` | difendi | 0% | 100% | 0% | 3.8 | 145.0 | 0% | 0 |
| Marionetta | `marionetta` | studia | 0% | 100% | 0% | 3.0 | 145.0 | 0% | 0 |
| Marionetta | `marionetta` | casuale | 0% | 100% | 0% | 3.3 | 145.0 | 0% | 0 |
| Fomentado | `maschera_vuota` | attacca | 100% | 0% | 0% | 5.9 | 40.7 | 0% | 8 |
| Fomentado | `maschera_vuota` | difendi | 100% | 0% | 0% | 33.0 | 40.5 | 0% | 8 |
| Fomentado | `maschera_vuota` | studia | 100% | 0% | 0% | 8.7 | 64.1 | 0% | 8 |
| Fomentado | `maschera_vuota` | casuale | 100% | 0% | 0% | 14.1 | 76.7 | 0% | 8 |
| Ombra del passato | `ombra_del_passato` | attacca | 2% | 98% | 0% | 3.0 | 142.5 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | difendi | 0% | 100% | 0% | 3.8 | 145.0 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | studia | 0% | 100% | 0% | 3.0 | 145.0 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | casuale | 0% | 100% | 0% | 3.1 | 145.0 | 0% | 0 |
| Emblema dell'oppressione | `operaio_posseduto` | attacca | 14% | 86% | 0% | 11.2 | 140.3 | 0% | 2 |
| Emblema dell'oppressione | `operaio_posseduto` | difendi | 0% | 4% | 96% | 60.9 | 101.2 | 0% | 0 |
| Emblema dell'oppressione | `operaio_posseduto` | studia | 7% | 93% | 0% | 11.2 | 140.6 | 0% | 1 |
| Emblema dell'oppressione | `operaio_posseduto` | casuale | 3% | 97% | 0% | 14.5 | 143.5 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | attacca | 0% | 100% | 0% | 7.9 | 145.0 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | difendi | 0% | 100% | 0% | 34.5 | 145.0 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | studia | 0% | 100% | 0% | 7.9 | 145.0 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | casuale | 0% | 100% | 0% | 9.7 | 145.0 | 0% | 0 |
| Sacerdote Folle | `sacerdote_folle` | attacca | 3% | 97% | 0% | 6.2 | 141.6 | 0% | 1 |
| Sacerdote Folle | `sacerdote_folle` | difendi | 0% | 100% | 0% | 12.2 | 145.0 | 0% | 0 |
| Sacerdote Folle | `sacerdote_folle` | studia | 1% | 99% | 0% | 6.5 | 144.1 | 0% | 0 |
| Sacerdote Folle | `sacerdote_folle` | casuale | 1% | 99% | 0% | 7.4 | 144.4 | 0% | 0 |
| Sadico | `sadico` | attacca | 3% | 97% | 0% | 4.7 | 142.2 | 0% | 0 |
| Sadico | `sadico` | difendi | 0% | 100% | 0% | 6.7 | 145.0 | 0% | 0 |
| Sadico | `sadico` | studia | 1% | 99% | 0% | 4.8 | 144.7 | 0% | 0 |
| Sadico | `sadico` | casuale | 1% | 99% | 0% | 4.9 | 144.7 | 0% | 0 |
| Slime Infimo | `slime_infimo` | attacca | 100% | 0% | 0% | 4.7 | 15.5 | 0% | 2 |
| Slime Infimo | `slime_infimo` | difendi | 0% | 0% | 100% | 61.0 | 60.1 | 0% | 0 |
| Slime Infimo | `slime_infimo` | studia | 100% | 0% | 0% | 7.7 | 28.3 | 0% | 2 |
| Slime Infimo | `slime_infimo` | casuale | 100% | 0% | 0% | 14.6 | 41.4 | 0% | 2 |
| Stigma | `stigma` | attacca | 6% | 94% | 0% | 4.7 | 141.3 | 0% | 1 |
| Stigma | `stigma` | difendi | 0% | 100% | 0% | 5.8 | 145.0 | 0% | 0 |
| Stigma | `stigma` | studia | 0% | 100% | 0% | 4.8 | 145.0 | 0% | 0 |
| Stigma | `stigma` | casuale | 1% | 99% | 0% | 4.9 | 144.7 | 0% | 0 |
| Tartaruga Innocente | `tartaruga_innocente` | attacca | 49% | 0% | 51% | 46.3 | 0.0 | 0% | 6 |
| Tartaruga Innocente | `tartaruga_innocente` | difendi | 0% | 0% | 100% | 61.0 | 0.0 | 0% | 0 |
| Tartaruga Innocente | `tartaruga_innocente` | studia | 100% | 0% | 0% | 1.0 | 0.0 | 100% | 16 |
| Tartaruga Innocente | `tartaruga_innocente` | casuale | 100% | 0% | 0% | 3.0 | 0.0 | 99% | 16 |
| Un tenero ricordo | `tenero_ricordo` | attacca | 0% | 100% | 0% | 6.0 | 145.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | difendi | 0% | 100% | 0% | 7.1 | 145.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | studia | 0% | 100% | 0% | 6.3 | 145.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | casuale | 0% | 100% | 0% | 6.2 | 145.0 | 0% | 0 |
| Teschio Errante | `teschio_errante` | attacca | 8% | 92% | 0% | 6.7 | 138.8 | 0% | 1 |
| Teschio Errante | `teschio_errante` | difendi | 0% | 100% | 0% | 23.2 | 145.0 | 0% | 0 |
| Teschio Errante | `teschio_errante` | studia | 0% | 100% | 0% | 7.0 | 145.0 | 0% | 0 |
| Teschio Errante | `teschio_errante` | casuale | 1% | 99% | 0% | 8.3 | 144.4 | 0% | 0 |
| Titano Zombie | `titano_zombie` | attacca | 0% | 100% | 0% | 8.0 | 145.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | difendi | 0% | 100% | 0% | 8.1 | 145.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | studia | 0% | 100% | 0% | 6.2 | 145.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | casuale | 0% | 100% | 0% | 6.6 | 145.0 | 0% | 0 |
| Capocantiere | `voce_registrata` | attacca | 100% | 0% | 0% | 9.1 | 103.4 | 0% | 9 |
| Capocantiere | `voce_registrata` | difendi | 0% | 0% | 100% | 61.0 | 100.1 | 0% | 0 |
| Capocantiere | `voce_registrata` | studia | 63% | 37% | 0% | 12.4 | 139.7 | 0% | 6 |
| Capocantiere | `voce_registrata` | casuale | 5% | 95% | 0% | 17.1 | 143.5 | 0% | 0 |
| Zombie Cittadino | `zombie_cittadino` | attacca | 100% | 0% | 0% | 5.9 | 30.3 | 0% | 6 |
| Zombie Cittadino | `zombie_cittadino` | difendi | 0% | 0% | 100% | 61.0 | 63.5 | 0% | 0 |
| Zombie Cittadino | `zombie_cittadino` | studia | 100% | 0% | 0% | 8.8 | 48.5 | 0% | 6 |
| Zombie Cittadino | `zombie_cittadino` | casuale | 99% | 1% | 0% | 18.3 | 76.8 | 0% | 6 |
| Zombie Mostruoso | `zombie_mostruoso` | attacca | 100% | 0% | 0% | 7.6 | 55.0 | 0% | 12 |
| Zombie Mostruoso | `zombie_mostruoso` | difendi | 0% | 0% | 100% | 61.0 | 75.9 | 0% | 0 |
| Zombie Mostruoso | `zombie_mostruoso` | studia | 100% | 0% | 0% | 10.6 | 79.8 | 0% | 12 |
| Zombie Mostruoso | `zombie_mostruoso` | casuale | 63% | 37% | 0% | 21.3 | 119.5 | 0% | 8 |

## Protagonista di livello 3

| creatura | id | come si gioca | vinte | perse | ∞ | giri | danno | risp. | xp |
|---|---|---|--:|--:|--:|--:|--:|--:|--:|
| Abominio Marcio | `abominio_marcio` | attacca | 0% | 100% | 0% | 5.0 | 190.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | difendi | 0% | 100% | 0% | 8.4 | 190.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | studia | 0% | 100% | 0% | 5.0 | 190.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | casuale | 0% | 100% | 0% | 5.9 | 190.0 | 0% | 0 |
| Oppresso | `comparsa_di_ruggine` | attacca | 100% | 0% | 0% | 7.5 | 68.4 | 0% | 10 |
| Oppresso | `comparsa_di_ruggine` | difendi | 0% | 0% | 100% | 61.0 | 86.3 | 0% | 0 |
| Oppresso | `comparsa_di_ruggine` | studia | 100% | 0% | 0% | 10.3 | 97.0 | 0% | 10 |
| Oppresso | `comparsa_di_ruggine` | casuale | 68% | 32% | 0% | 21.5 | 157.1 | 0% | 7 |
| Diabolo | `diabolo` | attacca | 5% | 95% | 0% | 9.3 | 185.1 | 0% | 0 |
| Diabolo | `diabolo` | difendi | 0% | 100% | 0% | 29.6 | 190.0 | 0% | 0 |
| Diabolo | `diabolo` | studia | 5% | 95% | 0% | 9.4 | 187.4 | 0% | 0 |
| Diabolo | `diabolo` | casuale | 2% | 98% | 0% | 11.0 | 188.4 | 0% | 0 |
| Il Divoratore | `divoratore` | attacca | 0% | 100% | 0% | 8.7 | 190.0 | 0% | 0 |
| Il Divoratore | `divoratore` | difendi | 0% | 100% | 0% | 24.8 | 190.0 | 0% | 0 |
| Il Divoratore | `divoratore` | studia | 0% | 100% | 0% | 8.7 | 190.0 | 0% | 0 |
| Il Divoratore | `divoratore` | casuale | 0% | 100% | 0% | 9.9 | 190.0 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | attacca | 4% | 96% | 0% | 6.2 | 185.8 | 0% | 1 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | difendi | 0% | 100% | 0% | 10.7 | 190.0 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | studia | 3% | 97% | 0% | 6.4 | 189.5 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | casuale | 1% | 99% | 0% | 7.2 | 188.3 | 0% | 0 |
| Ferraglia Urlante | `ferraglia_urlante` | attacca | 0% | 100% | 0% | 12.9 | 190.0 | 0% | 0 |
| Ferraglia Urlante | `ferraglia_urlante` | difendi | 0% | 0% | 100% | 61.0 | 112.6 | 0% | 0 |
| Ferraglia Urlante | `ferraglia_urlante` | studia | 0% | 100% | 0% | 12.9 | 190.0 | 0% | 0 |
| Ferraglia Urlante | `ferraglia_urlante` | casuale | 0% | 100% | 0% | 16.4 | 190.0 | 0% | 0 |
| Ghoul | `ghoul` | attacca | 5% | 95% | 0% | 9.7 | 184.7 | 0% | 0 |
| Ghoul | `ghoul` | difendi | 0% | 100% | 0% | 44.5 | 190.0 | 0% | 0 |
| Ghoul | `ghoul` | studia | 5% | 95% | 0% | 9.8 | 186.8 | 0% | 0 |
| Ghoul | `ghoul` | casuale | 2% | 98% | 0% | 12.2 | 188.2 | 0% | 0 |
| El Muy Bonito | `giocoliere` | attacca | 100% | 0% | 0% | 10.6 | 112.6 | 0% | 18 |
| El Muy Bonito | `giocoliere` | difendi | 0% | 0% | 100% | 61.0 | 95.7 | 0% | 0 |
| El Muy Bonito | `giocoliere` | studia | 0% | 100% | 0% | 8.7 | 190.0 | 0% | 0 |
| El Muy Bonito | `giocoliere` | casuale | 3% | 97% | 0% | 12.4 | 189.3 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | attacca | 0% | 100% | 0% | 15.6 | 190.0 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | difendi | 0% | 89% | 11% | 51.3 | 189.0 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | studia | 0% | 100% | 0% | 15.6 | 190.0 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | casuale | 0% | 100% | 0% | 19.0 | 190.0 | 0% | 0 |
| Goblin Tipico | `goblin_tipico` | attacca | 100% | 0% | 0% | 3.8 | 9.0 | 0% | 1 |
| Goblin Tipico | `goblin_tipico` | difendi | 0% | 0% | 100% | 61.0 | 60.1 | 0% | 0 |
| Goblin Tipico | `goblin_tipico` | studia | 100% | 0% | 0% | 6.8 | 18.4 | 0% | 1 |
| Goblin Tipico | `goblin_tipico` | casuale | 100% | 0% | 0% | 12.3 | 26.7 | 0% | 1 |
| Infetto Rapido | `infetto_rapido` | attacca | 100% | 0% | 0% | 4.7 | 28.9 | 0% | 6 |
| Infetto Rapido | `infetto_rapido` | difendi | 0% | 0% | 100% | 61.0 | 68.8 | 0% | 0 |
| Infetto Rapido | `infetto_rapido` | studia | 100% | 0% | 0% | 7.8 | 48.7 | 0% | 6 |
| Infetto Rapido | `infetto_rapido` | casuale | 100% | 0% | 0% | 14.0 | 63.2 | 0% | 6 |
| L'ultimo spettacolo di Jerah | `jerah` | attacca | 0% | 100% | 0% | 7.0 | 190.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | difendi | 0% | 100% | 0% | 9.7 | 190.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | studia | 0% | 100% | 0% | 7.6 | 190.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | casuale | 0% | 100% | 0% | 7.7 | 190.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | attacca | 0% | 100% | 0% | 11.9 | 190.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | difendi | 0% | 100% | 0% | 25.5 | 190.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | studia | 0% | 100% | 0% | 11.3 | 190.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | casuale | 0% | 100% | 0% | 12.8 | 190.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | attacca | 0% | 100% | 0% | 4.8 | 190.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | difendi | 0% | 100% | 0% | 6.7 | 190.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | studia | 0% | 100% | 0% | 4.8 | 190.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | casuale | 0% | 100% | 0% | 5.0 | 190.0 | 0% | 0 |
| ??? | `l_immortale` | attacca | 0% | 38% | 62% | 60.4 | 187.5 | 0% | 0 |
| ??? | `l_immortale` | difendi | 0% | 0% | 100% | 61.0 | 60.1 | 0% | 0 |
| ??? | `l_immortale` | studia | 0% | 37% | 63% | 60.4 | 187.6 | 0% | 0 |
| ??? | `l_immortale` | casuale | 0% | 0% | 100% | 61.0 | 146.6 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | attacca | 5% | 95% | 0% | 9.7 | 184.7 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | difendi | 0% | 100% | 0% | 44.5 | 190.0 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | studia | 5% | 95% | 0% | 9.8 | 186.8 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | casuale | 2% | 98% | 0% | 12.2 | 188.2 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | attacca | 0% | 100% | 0% | 6.0 | 190.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | difendi | 0% | 100% | 0% | 6.0 | 190.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | studia | 0% | 100% | 0% | 6.0 | 190.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | casuale | 0% | 100% | 0% | 6.0 | 190.0 | 0% | 0 |
| Marionetta | `marionetta` | attacca | 3% | 97% | 0% | 3.9 | 186.4 | 0% | 0 |
| Marionetta | `marionetta` | difendi | 0% | 100% | 0% | 5.8 | 190.0 | 0% | 0 |
| Marionetta | `marionetta` | studia | 1% | 99% | 0% | 4.0 | 189.7 | 0% | 0 |
| Marionetta | `marionetta` | casuale | 0% | 100% | 0% | 4.4 | 190.0 | 0% | 0 |
| Fomentado | `maschera_vuota` | attacca | 100% | 0% | 0% | 4.9 | 28.5 | 0% | 8 |
| Fomentado | `maschera_vuota` | difendi | 100% | 0% | 0% | 33.0 | 38.9 | 0% | 8 |
| Fomentado | `maschera_vuota` | studia | 100% | 0% | 0% | 7.7 | 48.9 | 0% | 8 |
| Fomentado | `maschera_vuota` | casuale | 100% | 0% | 0% | 12.1 | 57.6 | 0% | 8 |
| Ombra del passato | `ombra_del_passato` | attacca | 2% | 98% | 0% | 3.8 | 186.6 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | difendi | 0% | 100% | 0% | 4.8 | 190.0 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | studia | 1% | 99% | 0% | 3.8 | 189.8 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | casuale | 0% | 100% | 0% | 4.1 | 190.0 | 0% | 0 |
| Emblema dell'oppressione | `operaio_posseduto` | attacca | 100% | 0% | 0% | 9.4 | 104.0 | 0% | 12 |
| Emblema dell'oppressione | `operaio_posseduto` | difendi | 0% | 0% | 100% | 61.0 | 97.5 | 0% | 0 |
| Emblema dell'oppressione | `operaio_posseduto` | studia | 100% | 0% | 0% | 12.1 | 137.8 | 0% | 12 |
| Emblema dell'oppressione | `operaio_posseduto` | casuale | 11% | 89% | 0% | 20.3 | 185.4 | 0% | 1 |
| Orrore di Meridia | `orrore_di_meridia` | attacca | 0% | 100% | 0% | 11.6 | 190.0 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | difendi | 0% | 81% | 19% | 52.1 | 187.5 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | studia | 0% | 100% | 0% | 11.5 | 190.0 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | casuale | 0% | 100% | 0% | 14.1 | 190.0 | 0% | 0 |
| Sacerdote Folle | `sacerdote_folle` | attacca | 5% | 95% | 0% | 7.8 | 184.7 | 0% | 1 |
| Sacerdote Folle | `sacerdote_folle` | difendi | 0% | 100% | 0% | 16.3 | 190.0 | 0% | 0 |
| Sacerdote Folle | `sacerdote_folle` | studia | 1% | 99% | 0% | 8.2 | 188.5 | 0% | 0 |
| Sacerdote Folle | `sacerdote_folle` | casuale | 1% | 99% | 0% | 9.2 | 189.1 | 0% | 0 |
| Sadico | `sadico` | attacca | 3% | 97% | 0% | 5.7 | 186.0 | 0% | 0 |
| Sadico | `sadico` | difendi | 0% | 100% | 0% | 9.5 | 190.0 | 0% | 0 |
| Sadico | `sadico` | studia | 1% | 99% | 0% | 5.8 | 189.1 | 0% | 0 |
| Sadico | `sadico` | casuale | 1% | 99% | 0% | 6.5 | 189.4 | 0% | 0 |
| Slime Infimo | `slime_infimo` | attacca | 100% | 0% | 0% | 3.8 | 9.0 | 0% | 1 |
| Slime Infimo | `slime_infimo` | difendi | 0% | 0% | 100% | 61.0 | 60.1 | 0% | 0 |
| Slime Infimo | `slime_infimo` | studia | 100% | 0% | 0% | 6.8 | 18.4 | 0% | 1 |
| Slime Infimo | `slime_infimo` | casuale | 100% | 0% | 0% | 12.3 | 26.7 | 0% | 1 |
| Stigma | `stigma` | attacca | 3% | 97% | 0% | 5.7 | 186.0 | 0% | 0 |
| Stigma | `stigma` | difendi | 0% | 100% | 0% | 9.5 | 190.0 | 0% | 0 |
| Stigma | `stigma` | studia | 1% | 99% | 0% | 5.8 | 189.1 | 0% | 0 |
| Stigma | `stigma` | casuale | 1% | 99% | 0% | 6.5 | 189.4 | 0% | 0 |
| Tartaruga Innocente | `tartaruga_innocente` | attacca | 49% | 0% | 51% | 46.3 | 0.0 | 0% | 5 |
| Tartaruga Innocente | `tartaruga_innocente` | difendi | 0% | 0% | 100% | 61.0 | 0.0 | 0% | 0 |
| Tartaruga Innocente | `tartaruga_innocente` | studia | 100% | 0% | 0% | 1.0 | 0.0 | 100% | 14 |
| Tartaruga Innocente | `tartaruga_innocente` | casuale | 100% | 0% | 0% | 3.0 | 0.0 | 99% | 14 |
| Un tenero ricordo | `tenero_ricordo` | attacca | 0% | 100% | 0% | 6.7 | 190.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | difendi | 0% | 100% | 0% | 7.7 | 190.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | studia | 0% | 100% | 0% | 6.9 | 190.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | casuale | 0% | 100% | 0% | 6.8 | 190.0 | 0% | 0 |
| Teschio Errante | `teschio_errante` | attacca | 11% | 89% | 0% | 9.3 | 178.6 | 0% | 1 |
| Teschio Errante | `teschio_errante` | difendi | 0% | 100% | 0% | 40.5 | 190.0 | 0% | 0 |
| Teschio Errante | `teschio_errante` | studia | 2% | 98% | 0% | 9.9 | 189.1 | 0% | 0 |
| Teschio Errante | `teschio_errante` | casuale | 1% | 99% | 0% | 11.9 | 189.1 | 0% | 0 |
| Titano Zombie | `titano_zombie` | attacca | 0% | 100% | 0% | 10.4 | 190.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | difendi | 0% | 100% | 0% | 9.7 | 190.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | studia | 0% | 100% | 0% | 8.3 | 190.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | casuale | 0% | 100% | 0% | 8.0 | 190.0 | 0% | 0 |
| Capocantiere | `voce_registrata` | attacca | 100% | 0% | 0% | 6.8 | 60.7 | 0% | 9 |
| Capocantiere | `voce_registrata` | difendi | 0% | 0% | 100% | 61.0 | 86.3 | 0% | 0 |
| Capocantiere | `voce_registrata` | studia | 100% | 0% | 0% | 9.8 | 92.5 | 0% | 9 |
| Capocantiere | `voce_registrata` | casuale | 79% | 21% | 0% | 20.2 | 143.4 | 0% | 7 |
| Zombie Cittadino | `zombie_cittadino` | attacca | 100% | 0% | 0% | 4.8 | 19.7 | 0% | 5 |
| Zombie Cittadino | `zombie_cittadino` | difendi | 0% | 0% | 100% | 61.0 | 63.4 | 0% | 0 |
| Zombie Cittadino | `zombie_cittadino` | studia | 100% | 0% | 0% | 7.7 | 34.9 | 0% | 5 |
| Zombie Cittadino | `zombie_cittadino` | casuale | 100% | 0% | 0% | 15.1 | 53.0 | 0% | 5 |
| Zombie Mostruoso | `zombie_mostruoso` | attacca | 100% | 0% | 0% | 5.9 | 35.6 | 0% | 12 |
| Zombie Mostruoso | `zombie_mostruoso` | difendi | 0% | 0% | 100% | 61.0 | 72.8 | 0% | 0 |
| Zombie Mostruoso | `zombie_mostruoso` | studia | 100% | 0% | 0% | 8.9 | 58.0 | 0% | 12 |
| Zombie Mostruoso | `zombie_mostruoso` | casuale | 99% | 1% | 0% | 18.3 | 88.2 | 0% | 12 |

## Protagonista di livello 5

| creatura | id | come si gioca | vinte | perse | ∞ | giri | danno | risp. | xp |
|---|---|---|--:|--:|--:|--:|--:|--:|--:|
| Abominio Marcio | `abominio_marcio` | attacca | 0% | 100% | 0% | 8.7 | 285.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | difendi | 0% | 100% | 0% | 14.7 | 285.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | studia | 0% | 100% | 0% | 8.7 | 285.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | casuale | 0% | 100% | 0% | 9.8 | 285.0 | 0% | 0 |
| Oppresso | `comparsa_di_ruggine` | attacca | 100% | 0% | 0% | 4.8 | 28.1 | 0% | 9 |
| Oppresso | `comparsa_di_ruggine` | difendi | 0% | 0% | 100% | 61.0 | 82.1 | 0% | 0 |
| Oppresso | `comparsa_di_ruggine` | studia | 100% | 0% | 0% | 7.7 | 49.8 | 0% | 9 |
| Oppresso | `comparsa_di_ruggine` | casuale | 100% | 0% | 0% | 15.1 | 74.8 | 0% | 9 |
| Diabolo | `diabolo` | attacca | 100% | 0% | 0% | 12.7 | 219.1 | 0% | 8 |
| Diabolo | `diabolo` | difendi | 0% | 19% | 81% | 59.8 | 250.3 | 0% | 0 |
| Diabolo | `diabolo` | studia | 43% | 57% | 0% | 15.1 | 268.1 | 0% | 3 |
| Diabolo | `diabolo` | casuale | 4% | 96% | 0% | 18.9 | 280.4 | 0% | 0 |
| Il Divoratore | `divoratore` | attacca | 53% | 47% | 0% | 14.7 | 275.5 | 0% | 11 |
| Il Divoratore | `divoratore` | difendi | 0% | 79% | 21% | 53.7 | 281.8 | 0% | 0 |
| Il Divoratore | `divoratore` | studia | 0% | 100% | 0% | 14.8 | 285.0 | 0% | 0 |
| Il Divoratore | `divoratore` | casuale | 0% | 100% | 0% | 17.8 | 285.0 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | attacca | 7% | 93% | 0% | 10.3 | 274.7 | 0% | 1 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | difendi | 0% | 100% | 0% | 18.6 | 285.0 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | studia | 5% | 95% | 0% | 10.6 | 279.6 | 0% | 1 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | casuale | 3% | 97% | 0% | 11.8 | 281.7 | 0% | 0 |
| Ferraglia Urlante | `ferraglia_urlante` | attacca | 100% | 0% | 0% | 12.3 | 130.6 | 0% | 16 |
| Ferraglia Urlante | `ferraglia_urlante` | difendi | 0% | 0% | 100% | 61.0 | 103.5 | 0% | 0 |
| Ferraglia Urlante | `ferraglia_urlante` | studia | 100% | 0% | 0% | 15.4 | 165.7 | 0% | 16 |
| Ferraglia Urlante | `ferraglia_urlante` | casuale | 29% | 71% | 0% | 31.4 | 273.2 | 0% | 5 |
| Ghoul | `ghoul` | attacca | 100% | 0% | 0% | 11.2 | 170.1 | 0% | 9 |
| Ghoul | `ghoul` | difendi | 0% | 0% | 100% | 61.0 | 137.6 | 0% | 0 |
| Ghoul | `ghoul` | studia | 100% | 0% | 0% | 14.1 | 218.3 | 0% | 9 |
| Ghoul | `ghoul` | casuale | 10% | 90% | 0% | 21.4 | 278.0 | 0% | 1 |
| El Muy Bonito | `giocoliere` | attacca | 100% | 0% | 0% | 7.0 | 45.5 | 0% | 15 |
| El Muy Bonito | `giocoliere` | difendi | 0% | 0% | 100% | 61.0 | 82.3 | 0% | 0 |
| El Muy Bonito | `giocoliere` | studia | 100% | 0% | 0% | 9.0 | 188.6 | 0% | 15 |
| El Muy Bonito | `giocoliere` | casuale | 40% | 60% | 0% | 14.1 | 240.6 | 0% | 6 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | attacca | 73% | 27% | 0% | 27.9 | 257.2 | 0% | 30 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | difendi | 0% | 0% | 100% | 61.0 | 172.3 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | studia | 30% | 70% | 0% | 29.6 | 277.7 | 0% | 12 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | casuale | 0% | 100% | 0% | 35.1 | 285.0 | 0% | 0 |
| Goblin Tipico | `goblin_tipico` | attacca | 100% | 0% | 0% | 2.9 | 2.3 | 0% | 1 |
| Goblin Tipico | `goblin_tipico` | difendi | 0% | 0% | 100% | 61.0 | 60.1 | 0% | 0 |
| Goblin Tipico | `goblin_tipico` | studia | 100% | 0% | 0% | 5.9 | 6.1 | 0% | 1 |
| Goblin Tipico | `goblin_tipico` | casuale | 100% | 0% | 0% | 9.3 | 9.7 | 0% | 1 |
| Infetto Rapido | `infetto_rapido` | attacca | 100% | 0% | 0% | 3.0 | 6.4 | 0% | 4 |
| Infetto Rapido | `infetto_rapido` | difendi | 0% | 0% | 100% | 61.0 | 63.3 | 0% | 0 |
| Infetto Rapido | `infetto_rapido` | studia | 100% | 0% | 0% | 6.0 | 16.5 | 0% | 4 |
| Infetto Rapido | `infetto_rapido` | casuale | 100% | 0% | 0% | 9.5 | 21.0 | 0% | 4 |
| L'ultimo spettacolo di Jerah | `jerah` | attacca | 0% | 100% | 0% | 10.9 | 285.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | difendi | 0% | 100% | 0% | 15.3 | 285.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | studia | 0% | 100% | 0% | 12.7 | 285.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | casuale | 0% | 100% | 0% | 12.7 | 285.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | attacca | 0% | 100% | 0% | 18.6 | 285.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | difendi | 0% | 93% | 7% | 43.7 | 283.4 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | studia | 0% | 100% | 0% | 17.5 | 285.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | casuale | 0% | 100% | 0% | 20.0 | 285.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | attacca | 0% | 100% | 0% | 7.6 | 285.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | difendi | 0% | 100% | 0% | 11.1 | 285.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | studia | 0% | 100% | 0% | 7.7 | 285.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | casuale | 0% | 100% | 0% | 8.0 | 285.0 | 0% | 0 |
| ??? | `l_immortale` | attacca | 0% | 0% | 100% | 61.0 | 72.1 | 0% | 0 |
| ??? | `l_immortale` | difendi | 0% | 0% | 100% | 61.0 | 60.0 | 0% | 0 |
| ??? | `l_immortale` | studia | 0% | 0% | 100% | 61.0 | 72.3 | 0% | 0 |
| ??? | `l_immortale` | casuale | 0% | 0% | 100% | 61.0 | 67.1 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | attacca | 100% | 0% | 0% | 11.6 | 177.5 | 0% | 9 |
| Madre in Lacrime | `madre_in_lacrime` | difendi | 0% | 0% | 100% | 61.0 | 137.6 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | studia | 100% | 0% | 0% | 14.7 | 227.5 | 0% | 9 |
| Madre in Lacrime | `madre_in_lacrime` | casuale | 10% | 90% | 0% | 21.4 | 278.0 | 0% | 1 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | attacca | 0% | 100% | 0% | 6.0 | 285.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | difendi | 0% | 100% | 0% | 6.0 | 285.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | studia | 0% | 100% | 0% | 6.0 | 285.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | casuale | 0% | 100% | 0% | 6.0 | 285.0 | 0% | 0 |
| Marionetta | `marionetta` | attacca | 3% | 97% | 0% | 6.6 | 278.8 | 0% | 0 |
| Marionetta | `marionetta` | difendi | 0% | 100% | 0% | 9.5 | 285.0 | 0% | 0 |
| Marionetta | `marionetta` | studia | 4% | 96% | 0% | 6.7 | 282.2 | 0% | 0 |
| Marionetta | `marionetta` | casuale | 1% | 99% | 0% | 7.1 | 284.6 | 0% | 0 |
| Fomentado | `maschera_vuota` | attacca | 100% | 0% | 0% | 3.8 | 12.4 | 0% | 6 |
| Fomentado | `maschera_vuota` | difendi | 100% | 0% | 0% | 33.0 | 37.1 | 0% | 6 |
| Fomentado | `maschera_vuota` | studia | 100% | 0% | 0% | 6.8 | 25.1 | 0% | 6 |
| Fomentado | `maschera_vuota` | casuale | 100% | 0% | 0% | 9.6 | 27.6 | 0% | 6 |
| Ombra del passato | `ombra_del_passato` | attacca | 3% | 97% | 0% | 5.9 | 278.9 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | difendi | 0% | 100% | 0% | 8.6 | 285.0 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | studia | 3% | 97% | 0% | 6.0 | 282.8 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | casuale | 1% | 99% | 0% | 6.7 | 284.8 | 0% | 0 |
| Emblema dell'oppressione | `operaio_posseduto` | attacca | 100% | 0% | 0% | 5.9 | 46.1 | 0% | 12 |
| Emblema dell'oppressione | `operaio_posseduto` | difendi | 0% | 0% | 100% | 61.0 | 92.2 | 0% | 0 |
| Emblema dell'oppressione | `operaio_posseduto` | studia | 100% | 0% | 0% | 8.8 | 73.7 | 0% | 12 |
| Emblema dell'oppressione | `operaio_posseduto` | casuale | 100% | 0% | 0% | 18.2 | 119.2 | 0% | 12 |
| Orrore di Meridia | `orrore_di_meridia` | attacca | 100% | 0% | 0% | 10.6 | 130.7 | 0% | 20 |
| Orrore di Meridia | `orrore_di_meridia` | difendi | 0% | 0% | 100% | 61.0 | 178.5 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | studia | 100% | 0% | 0% | 13.7 | 173.8 | 0% | 20 |
| Orrore di Meridia | `orrore_di_meridia` | casuale | 25% | 75% | 0% | 25.8 | 275.0 | 0% | 5 |
| Sacerdote Folle | `sacerdote_folle` | attacca | 5% | 95% | 0% | 11.7 | 274.1 | 0% | 1 |
| Sacerdote Folle | `sacerdote_folle` | difendi | 0% | 100% | 0% | 29.4 | 285.0 | 0% | 0 |
| Sacerdote Folle | `sacerdote_folle` | studia | 1% | 99% | 0% | 12.1 | 282.0 | 0% | 0 |
| Sacerdote Folle | `sacerdote_folle` | casuale | 1% | 99% | 0% | 13.6 | 283.4 | 0% | 0 |
| Sadico | `sadico` | attacca | 5% | 95% | 0% | 9.4 | 277.4 | 0% | 0 |
| Sadico | `sadico` | difendi | 0% | 100% | 0% | 18.4 | 285.0 | 0% | 0 |
| Sadico | `sadico` | studia | 5% | 95% | 0% | 9.5 | 280.7 | 0% | 0 |
| Sadico | `sadico` | casuale | 2% | 98% | 0% | 10.9 | 282.6 | 0% | 0 |
| Slime Infimo | `slime_infimo` | attacca | 100% | 0% | 0% | 2.9 | 2.3 | 0% | 1 |
| Slime Infimo | `slime_infimo` | difendi | 0% | 0% | 100% | 61.0 | 60.1 | 0% | 0 |
| Slime Infimo | `slime_infimo` | studia | 100% | 0% | 0% | 5.9 | 6.1 | 0% | 1 |
| Slime Infimo | `slime_infimo` | casuale | 100% | 0% | 0% | 9.3 | 9.7 | 0% | 1 |
| Stigma | `stigma` | attacca | 5% | 95% | 0% | 9.4 | 277.4 | 0% | 0 |
| Stigma | `stigma` | difendi | 0% | 100% | 0% | 18.4 | 285.0 | 0% | 0 |
| Stigma | `stigma` | studia | 5% | 95% | 0% | 9.5 | 280.7 | 0% | 0 |
| Stigma | `stigma` | casuale | 2% | 98% | 0% | 10.9 | 282.6 | 0% | 0 |
| Tartaruga Innocente | `tartaruga_innocente` | attacca | 49% | 0% | 51% | 46.3 | 0.0 | 0% | 3 |
| Tartaruga Innocente | `tartaruga_innocente` | difendi | 0% | 0% | 100% | 61.0 | 0.0 | 0% | 0 |
| Tartaruga Innocente | `tartaruga_innocente` | studia | 100% | 0% | 0% | 1.0 | 0.0 | 100% | 8 |
| Tartaruga Innocente | `tartaruga_innocente` | casuale | 100% | 0% | 0% | 3.0 | 0.0 | 99% | 8 |
| Un tenero ricordo | `tenero_ricordo` | attacca | 0% | 100% | 0% | 7.8 | 285.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | difendi | 0% | 100% | 0% | 8.6 | 285.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | studia | 0% | 100% | 0% | 7.9 | 285.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | casuale | 0% | 100% | 0% | 7.9 | 285.0 | 0% | 0 |
| Teschio Errante | `teschio_errante` | attacca | 100% | 0% | 0% | 9.4 | 139.7 | 0% | 8 |
| Teschio Errante | `teschio_errante` | difendi | 0% | 0% | 100% | 61.0 | 137.6 | 0% | 0 |
| Teschio Errante | `teschio_errante` | studia | 100% | 0% | 0% | 12.4 | 189.3 | 0% | 8 |
| Teschio Errante | `teschio_errante` | casuale | 22% | 78% | 0% | 21.0 | 272.1 | 0% | 2 |
| Titano Zombie | `titano_zombie` | attacca | 0% | 100% | 0% | 13.1 | 285.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | difendi | 0% | 100% | 0% | 12.9 | 285.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | studia | 0% | 100% | 0% | 12.8 | 285.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | casuale | 0% | 100% | 0% | 10.9 | 285.0 | 0% | 0 |
| Capocantiere | `voce_registrata` | attacca | 100% | 0% | 0% | 4.8 | 28.2 | 0% | 8 |
| Capocantiere | `voce_registrata` | difendi | 0% | 0% | 100% | 61.0 | 82.1 | 0% | 0 |
| Capocantiere | `voce_registrata` | studia | 100% | 0% | 0% | 7.8 | 50.6 | 0% | 8 |
| Capocantiere | `voce_registrata` | casuale | 100% | 0% | 0% | 14.9 | 72.6 | 0% | 8 |
| Zombie Cittadino | `zombie_cittadino` | attacca | 100% | 0% | 0% | 3.0 | 4.4 | 0% | 3 |
| Zombie Cittadino | `zombie_cittadino` | difendi | 0% | 0% | 100% | 61.0 | 60.3 | 0% | 0 |
| Zombie Cittadino | `zombie_cittadino` | studia | 100% | 0% | 0% | 6.0 | 11.5 | 0% | 3 |
| Zombie Cittadino | `zombie_cittadino` | casuale | 100% | 0% | 0% | 9.5 | 15.6 | 0% | 3 |
| Zombie Mostruoso | `zombie_mostruoso` | attacca | 100% | 0% | 0% | 3.9 | 12.9 | 0% | 8 |
| Zombie Mostruoso | `zombie_mostruoso` | difendi | 0% | 0% | 100% | 61.0 | 69.6 | 0% | 0 |
| Zombie Mostruoso | `zombie_mostruoso` | studia | 100% | 0% | 0% | 7.0 | 26.1 | 0% | 8 |
| Zombie Mostruoso | `zombie_mostruoso` | casuale | 100% | 0% | 0% | 12.7 | 36.9 | 0% | 8 |

## Protagonista di livello 8

| creatura | id | come si gioca | vinte | perse | ∞ | giri | danno | risp. | xp |
|---|---|---|--:|--:|--:|--:|--:|--:|--:|
| Abominio Marcio | `abominio_marcio` | attacca | 72% | 28% | 0% | 14.9 | 407.4 | 0% | 12 |
| Abominio Marcio | `abominio_marcio` | difendi | 0% | 100% | 0% | 28.8 | 425.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | studia | 1% | 99% | 0% | 15.3 | 425.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | casuale | 0% | 100% | 0% | 17.0 | 425.0 | 0% | 0 |
| Oppresso | `comparsa_di_ruggine` | attacca | 100% | 0% | 0% | 3.8 | 15.8 | 0% | 6 |
| Oppresso | `comparsa_di_ruggine` | difendi | 0% | 0% | 100% | 61.0 | 82.1 | 0% | 0 |
| Oppresso | `comparsa_di_ruggine` | studia | 100% | 0% | 0% | 6.8 | 32.1 | 0% | 6 |
| Oppresso | `comparsa_di_ruggine` | casuale | 100% | 0% | 0% | 12.2 | 45.3 | 0% | 6 |
| Diabolo | `diabolo` | attacca | 100% | 0% | 0% | 7.5 | 90.6 | 0% | 8 |
| Diabolo | `diabolo` | difendi | 0% | 0% | 100% | 61.0 | 124.9 | 0% | 0 |
| Diabolo | `diabolo` | studia | 100% | 0% | 0% | 10.6 | 132.3 | 0% | 8 |
| Diabolo | `diabolo` | casuale | 99% | 1% | 0% | 23.2 | 238.5 | 0% | 8 |
| Il Divoratore | `divoratore` | attacca | 100% | 0% | 0% | 9.5 | 133.0 | 0% | 14 |
| Il Divoratore | `divoratore` | difendi | 0% | 0% | 100% | 61.0 | 138.9 | 0% | 0 |
| Il Divoratore | `divoratore` | studia | 100% | 0% | 0% | 12.5 | 180.9 | 0% | 14 |
| Il Divoratore | `divoratore` | casuale | 83% | 17% | 0% | 28.0 | 340.5 | 0% | 12 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | attacca | 100% | 0% | 0% | 11.9 | 246.8 | 0% | 18 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | difendi | 0% | 100% | 0% | 34.2 | 425.0 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | studia | 96% | 4% | 0% | 14.9 | 306.8 | 0% | 17 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | casuale | 10% | 90% | 0% | 21.3 | 410.5 | 0% | 2 |
| Ferraglia Urlante | `ferraglia_urlante` | attacca | 100% | 0% | 0% | 7.7 | 49.9 | 0% | 11 |
| Ferraglia Urlante | `ferraglia_urlante` | difendi | 0% | 0% | 100% | 61.0 | 91.4 | 0% | 0 |
| Ferraglia Urlante | `ferraglia_urlante` | studia | 100% | 0% | 0% | 10.7 | 72.9 | 0% | 11 |
| Ferraglia Urlante | `ferraglia_urlante` | casuale | 100% | 0% | 0% | 23.9 | 125.5 | 0% | 11 |
| Ghoul | `ghoul` | attacca | 100% | 0% | 0% | 6.8 | 68.4 | 0% | 9 |
| Ghoul | `ghoul` | difendi | 0% | 0% | 100% | 61.0 | 115.9 | 0% | 0 |
| Ghoul | `ghoul` | studia | 100% | 0% | 0% | 9.8 | 104.3 | 0% | 9 |
| Ghoul | `ghoul` | casuale | 100% | 0% | 0% | 21.2 | 178.3 | 0% | 9 |
| El Muy Bonito | `giocoliere` | attacca | 100% | 0% | 0% | 5.8 | 27.5 | 0% | 11 |
| El Muy Bonito | `giocoliere` | difendi | 0% | 0% | 100% | 61.0 | 82.3 | 0% | 0 |
| El Muy Bonito | `giocoliere` | studia | 100% | 0% | 0% | 8.0 | 125.8 | 0% | 11 |
| El Muy Bonito | `giocoliere` | casuale | 73% | 27% | 0% | 13.9 | 226.2 | 0% | 8 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | attacca | 100% | 0% | 0% | 25.0 | 201.4 | 0% | 52 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | difendi | 0% | 0% | 100% | 61.0 | 198.4 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | studia | 100% | 0% | 0% | 31.0 | 238.4 | 0% | 52 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | casuale | 1% | 85% | 15% | 52.2 | 420.6 | 0% | 0 |
| Goblin Tipico | `goblin_tipico` | attacca | 100% | 0% | 0% | 2.9 | 2.4 | 0% | 2 |
| Goblin Tipico | `goblin_tipico` | difendi | 0% | 0% | 100% | 61.0 | 60.1 | 0% | 0 |
| Goblin Tipico | `goblin_tipico` | studia | 100% | 0% | 0% | 5.9 | 6.4 | 0% | 2 |
| Goblin Tipico | `goblin_tipico` | casuale | 100% | 0% | 0% | 9.3 | 10.0 | 0% | 2 |
| Infetto Rapido | `infetto_rapido` | attacca | 100% | 0% | 0% | 3.0 | 4.7 | 0% | 6 |
| Infetto Rapido | `infetto_rapido` | difendi | 0% | 0% | 100% | 61.0 | 66.6 | 0% | 0 |
| Infetto Rapido | `infetto_rapido` | studia | 100% | 0% | 0% | 6.0 | 12.3 | 0% | 6 |
| Infetto Rapido | `infetto_rapido` | casuale | 100% | 0% | 0% | 9.5 | 16.8 | 0% | 6 |
| L'ultimo spettacolo di Jerah | `jerah` | attacca | 0% | 100% | 0% | 18.8 | 425.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | difendi | 0% | 99% | 1% | 26.4 | 424.6 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | studia | 0% | 100% | 0% | 22.9 | 425.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | casuale | 0% | 100% | 0% | 23.3 | 425.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | attacca | 0% | 100% | 0% | 28.3 | 425.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | difendi | 0% | 21% | 79% | 59.7 | 346.5 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | studia | 0% | 100% | 0% | 28.4 | 425.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | casuale | 0% | 99% | 1% | 35.3 | 424.8 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | attacca | 0% | 100% | 0% | 12.5 | 425.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | difendi | 0% | 100% | 0% | 20.2 | 425.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | studia | 0% | 100% | 0% | 12.5 | 425.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | casuale | 0% | 100% | 0% | 13.8 | 425.0 | 0% | 0 |
| ??? | `l_immortale` | attacca | 0% | 0% | 100% | 61.0 | 66.1 | 0% | 0 |
| ??? | `l_immortale` | difendi | 0% | 0% | 100% | 61.0 | 60.0 | 0% | 0 |
| ??? | `l_immortale` | studia | 0% | 0% | 100% | 61.0 | 66.1 | 0% | 0 |
| ??? | `l_immortale` | casuale | 0% | 0% | 100% | 61.0 | 63.5 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | attacca | 100% | 0% | 0% | 6.7 | 66.8 | 0% | 9 |
| Madre in Lacrime | `madre_in_lacrime` | difendi | 0% | 0% | 100% | 61.0 | 115.9 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | studia | 100% | 0% | 0% | 9.7 | 102.2 | 0% | 9 |
| Madre in Lacrime | `madre_in_lacrime` | casuale | 100% | 0% | 0% | 20.5 | 172.6 | 0% | 9 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | attacca | 0% | 100% | 0% | 6.0 | 425.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | difendi | 0% | 100% | 0% | 6.0 | 425.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | studia | 0% | 100% | 0% | 6.0 | 425.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | casuale | 0% | 100% | 0% | 6.0 | 425.0 | 0% | 0 |
| Marionetta | `marionetta` | attacca | 19% | 81% | 0% | 11.1 | 410.1 | 0% | 1 |
| Marionetta | `marionetta` | difendi | 0% | 100% | 0% | 16.7 | 425.0 | 0% | 0 |
| Marionetta | `marionetta` | studia | 7% | 93% | 0% | 11.2 | 412.0 | 0% | 0 |
| Marionetta | `marionetta` | casuale | 2% | 98% | 0% | 12.1 | 421.6 | 0% | 0 |
| Fomentado | `maschera_vuota` | attacca | 100% | 0% | 0% | 3.0 | 6.8 | 0% | 6 |
| Fomentado | `maschera_vuota` | difendi | 100% | 0% | 0% | 41.0 | 50.4 | 0% | 6 |
| Fomentado | `maschera_vuota` | studia | 100% | 0% | 0% | 6.0 | 17.5 | 0% | 6 |
| Fomentado | `maschera_vuota` | casuale | 100% | 0% | 0% | 9.2 | 21.8 | 0% | 6 |
| Ombra del passato | `ombra_del_passato` | attacca | 6% | 94% | 0% | 10.3 | 413.0 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | difendi | 0% | 100% | 0% | 14.9 | 425.0 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | studia | 7% | 93% | 0% | 10.3 | 413.6 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | casuale | 2% | 98% | 0% | 11.0 | 422.1 | 0% | 0 |
| Emblema dell'oppressione | `operaio_posseduto` | attacca | 100% | 0% | 0% | 3.8 | 15.9 | 0% | 7 |
| Emblema dell'oppressione | `operaio_posseduto` | difendi | 0% | 0% | 100% | 61.0 | 82.1 | 0% | 0 |
| Emblema dell'oppressione | `operaio_posseduto` | studia | 100% | 0% | 0% | 6.8 | 32.1 | 0% | 7 |
| Emblema dell'oppressione | `operaio_posseduto` | casuale | 100% | 0% | 0% | 12.2 | 45.3 | 0% | 7 |
| Orrore di Meridia | `orrore_di_meridia` | attacca | 100% | 0% | 0% | 6.8 | 51.2 | 0% | 11 |
| Orrore di Meridia | `orrore_di_meridia` | difendi | 0% | 0% | 100% | 61.0 | 111.5 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | studia | 100% | 0% | 0% | 9.8 | 77.7 | 0% | 11 |
| Orrore di Meridia | `orrore_di_meridia` | casuale | 100% | 0% | 0% | 20.4 | 133.4 | 0% | 11 |
| Sacerdote Folle | `sacerdote_folle` | attacca | 45% | 55% | 0% | 17.9 | 329.0 | 0% | 11 |
| Sacerdote Folle | `sacerdote_folle` | difendi | 0% | 91% | 9% | 49.5 | 422.0 | 0% | 0 |
| Sacerdote Folle | `sacerdote_folle` | studia | 21% | 79% | 0% | 19.9 | 388.6 | 0% | 5 |
| Sacerdote Folle | `sacerdote_folle` | casuale | 1% | 99% | 0% | 22.1 | 422.3 | 0% | 0 |
| Sadico | `sadico` | attacca | 100% | 0% | 0% | 8.3 | 191.3 | 0% | 10 |
| Sadico | `sadico` | difendi | 0% | 100% | 0% | 36.6 | 425.0 | 0% | 0 |
| Sadico | `sadico` | studia | 100% | 0% | 0% | 11.4 | 270.6 | 0% | 10 |
| Sadico | `sadico` | casuale | 24% | 76% | 0% | 18.5 | 404.7 | 0% | 2 |
| Slime Infimo | `slime_infimo` | attacca | 100% | 0% | 0% | 2.9 | 2.4 | 0% | 2 |
| Slime Infimo | `slime_infimo` | difendi | 0% | 0% | 100% | 61.0 | 60.1 | 0% | 0 |
| Slime Infimo | `slime_infimo` | studia | 100% | 0% | 0% | 5.9 | 6.4 | 0% | 2 |
| Slime Infimo | `slime_infimo` | casuale | 100% | 0% | 0% | 9.3 | 10.0 | 0% | 2 |
| Stigma | `stigma` | attacca | 100% | 0% | 0% | 7.6 | 172.3 | 0% | 9 |
| Stigma | `stigma` | difendi | 0% | 100% | 0% | 36.6 | 425.0 | 0% | 0 |
| Stigma | `stigma` | studia | 100% | 0% | 0% | 10.6 | 250.0 | 0% | 9 |
| Stigma | `stigma` | casuale | 35% | 65% | 0% | 18.1 | 392.9 | 0% | 3 |
| Tartaruga Innocente | `tartaruga_innocente` | attacca | 57% | 0% | 43% | 44.3 | 0.0 | 0% | 1 |
| Tartaruga Innocente | `tartaruga_innocente` | difendi | 0% | 0% | 100% | 61.0 | 0.0 | 0% | 0 |
| Tartaruga Innocente | `tartaruga_innocente` | studia | 100% | 0% | 0% | 1.0 | 0.0 | 100% | 3 |
| Tartaruga Innocente | `tartaruga_innocente` | casuale | 100% | 0% | 0% | 3.0 | 0.0 | 99% | 3 |
| Un tenero ricordo | `tenero_ricordo` | attacca | 0% | 100% | 0% | 8.9 | 425.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | difendi | 0% | 100% | 0% | 9.2 | 425.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | studia | 0% | 100% | 0% | 8.8 | 425.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | casuale | 0% | 100% | 0% | 9.2 | 425.0 | 0% | 0 |
| Teschio Errante | `teschio_errante` | attacca | 100% | 0% | 0% | 5.7 | 55.9 | 0% | 8 |
| Teschio Errante | `teschio_errante` | difendi | 0% | 0% | 100% | 61.0 | 115.9 | 0% | 0 |
| Teschio Errante | `teschio_errante` | studia | 100% | 0% | 0% | 8.8 | 91.4 | 0% | 8 |
| Teschio Errante | `teschio_errante` | casuale | 100% | 0% | 0% | 17.8 | 147.6 | 0% | 8 |
| Titano Zombie | `titano_zombie` | attacca | 0% | 100% | 0% | 15.9 | 425.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | difendi | 0% | 100% | 0% | 16.0 | 425.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | studia | 0% | 100% | 0% | 16.3 | 425.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | casuale | 0% | 100% | 0% | 14.4 | 425.0 | 0% | 0 |
| Capocantiere | `voce_registrata` | attacca | 100% | 0% | 0% | 3.8 | 15.9 | 0% | 6 |
| Capocantiere | `voce_registrata` | difendi | 0% | 0% | 100% | 61.0 | 82.1 | 0% | 0 |
| Capocantiere | `voce_registrata` | studia | 100% | 0% | 0% | 6.8 | 32.5 | 0% | 6 |
| Capocantiere | `voce_registrata` | casuale | 100% | 0% | 0% | 12.3 | 45.1 | 0% | 6 |
| Zombie Cittadino | `zombie_cittadino` | attacca | 100% | 0% | 0% | 3.0 | 2.7 | 0% | 4 |
| Zombie Cittadino | `zombie_cittadino` | difendi | 0% | 0% | 100% | 61.0 | 63.4 | 0% | 0 |
| Zombie Cittadino | `zombie_cittadino` | studia | 100% | 0% | 0% | 6.0 | 7.1 | 0% | 4 |
| Zombie Cittadino | `zombie_cittadino` | casuale | 100% | 0% | 0% | 9.5 | 11.0 | 0% | 4 |
| Zombie Mostruoso | `zombie_mostruoso` | attacca | 100% | 0% | 0% | 3.8 | 10.1 | 0% | 8 |
| Zombie Mostruoso | `zombie_mostruoso` | difendi | 0% | 0% | 100% | 61.0 | 75.8 | 0% | 0 |
| Zombie Mostruoso | `zombie_mostruoso` | studia | 100% | 0% | 0% | 6.8 | 20.5 | 0% | 8 |
| Zombie Mostruoso | `zombie_mostruoso` | casuale | 100% | 0% | 0% | 12.3 | 30.2 | 0% | 8 |

