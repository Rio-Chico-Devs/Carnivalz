# Bilanciamento (generato, non scrivere qui a mano)

Prodotto da `prove/Simulatore.gd`: **99000 partite** giocate dal motore vero in 480 secondi.

Non e' una stima e non e' un modello: e' `Combattimento.tscn` istanziata e giocata,
con Voce/Campo/Menu muti. Se questi numeri sono sbagliati, sono sbagliati anche
quando ci giochi tu.

Ogni riga e' la media su 150 partite con semi fissi: due esecuzioni danno lo stesso
risultato, quindi una differenza qui e' sempre una differenza nel gioco.

**Il protagonista e' da solo e non ha guadagnato nessun punto statistica**: nel gioco
le stat non salgono col livello, salgono con quello che hai fatto. Qui sale solo il
livello, quindi questi numeri sono il pavimento - un giocatore vero sta sopra.

- **vinte / perse / ∞** — percentuale di partite. `∞` = non finisce entro 60 giri
- **giri** — durata media (un giro = tutti agiscono una volta)
- **danno** — punti vita persi in media dal protagonista (ne ha 20)
- **risp.** — percentuale di partite in cui la creatura e' stata risparmiata

## A che livello ogni scontro diventa giusto

Livello minimo a cui si vince almeno l'80% delle volte andandoci dritto.

| creatura | id | hp | att | livello |
|---|---|--:|--:|--:|
| Abominio Marcio | `abominio_marcio` | 40 | 3 | 5 |
| Oppresso | `comparsa_di_ruggine` | 27 | 2 | 3 |
| Diabolo | `diabolo` | 33 | 2 | 5 |
| Il Divoratore | `divoratore` | 45 | 3 | 8 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | 75 | 3 | 8 |
| Ferraglia Urlante | `ferraglia_urlante` | 35 | 2 | 5 |
| Ghoul | `ghoul` | 35 | 2 | 3 |
| El Muy Bonito | `giocoliere` | 18 | 2 | 1 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | 30 | 3 | 3 |
| Goblin Tipico | `goblin_tipico` | 6 | 1 | 1 |
| Infetto Rapido | `infetto_rapido` | 7 | 2 | 1 |
| L'ultimo spettacolo di Jerah | `jerah` | 35 | 2 | 5 |
| Jongo Dongo | `jongo_dongo` | 140 | 6 | **mai** |
| Jongo Dongo | `jongo_dongo_risorto` | 140 | 7 | **mai** |
| ??? | `l_immortale` | 12 | 1 | **mai** |
| Madre in Lacrime | `madre_in_lacrime` | 35 | 2 | 5 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | 32 | 5 | **mai** |
| Marionetta | `marionetta` | 38 | 6 | 8 |
| Fomentado | `maschera_vuota` | 10 | 1 | 1 |
| Ombra del passato | `ombra_del_passato` | 39 | 7 | **mai** |
| Emblema dell'oppressione | `operaio_posseduto` | 29 | 2 | 3 |
| Orrore di Meridia | `orrore_di_meridia` | 34 | 3 | 5 |
| Sacerdote Folle | `sacerdote_folle` | 56 | 3 | **mai** |
| Sadico | `sadico` | 36 | 3 | 5 |
| Slime Infimo | `slime_infimo` | 8 | 1 | 1 |
| Stigma | `stigma` | 34 | 3 | 5 |
| Tartaruga Innocente | `tartaruga_innocente` | 20 | 0 | 5 |
| Un tenero ricordo | `tenero_ricordo` | 666 | 6 | **mai** |
| Teschio Errante | `teschio_errante` | 29 | 2 | 3 |
| Titano Zombie | `titano_zombie` | 90 | 4 | **mai** |
| Capocantiere | `voce_registrata` | 25 | 2 | 2 |
| Zombie Cittadino | `zombie_cittadino` | 8 | 1 | 1 |
| Zombie Mostruoso | `zombie_mostruoso` | 22 | 2 | 1 |

## Protagonista di livello 1

| creatura | id | come si gioca | vinte | perse | ∞ | giri | danno | risp. | xp |
|---|---|---|--:|--:|--:|--:|--:|--:|--:|
| Abominio Marcio | `abominio_marcio` | attacca | 0% | 100% | 0% | 7.4 | 20.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | difendi | 0% | 0% | 100% | 61.0 | 5.8 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | studia | 0% | 100% | 0% | 7.4 | 20.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | casuale | 0% | 100% | 0% | 10.8 | 20.0 | 0% | 0 |
| Oppresso | `comparsa_di_ruggine` | attacca | 11% | 89% | 0% | 10.4 | 18.9 | 0% | 1 |
| Oppresso | `comparsa_di_ruggine` | difendi | 0% | 0% | 100% | 61.0 | 0.2 | 0% | 0 |
| Oppresso | `comparsa_di_ruggine` | studia | 5% | 95% | 0% | 10.7 | 19.5 | 0% | 1 |
| Oppresso | `comparsa_di_ruggine` | casuale | 3% | 97% | 0% | 15.6 | 19.8 | 0% | 0 |
| Diabolo | `diabolo` | attacca | 7% | 93% | 0% | 10.3 | 19.3 | 0% | 1 |
| Diabolo | `diabolo` | difendi | 0% | 0% | 100% | 61.0 | 2.0 | 0% | 0 |
| Diabolo | `diabolo` | studia | 4% | 96% | 0% | 10.5 | 19.7 | 0% | 0 |
| Diabolo | `diabolo` | casuale | 3% | 97% | 0% | 15.1 | 19.8 | 0% | 0 |
| Il Divoratore | `divoratore` | attacca | 0% | 100% | 0% | 7.4 | 20.0 | 0% | 0 |
| Il Divoratore | `divoratore` | difendi | 0% | 0% | 100% | 61.0 | 5.8 | 0% | 0 |
| Il Divoratore | `divoratore` | studia | 0% | 100% | 0% | 7.4 | 20.0 | 0% | 0 |
| Il Divoratore | `divoratore` | casuale | 0% | 100% | 0% | 10.8 | 20.0 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | attacca | 7% | 93% | 0% | 6.5 | 19.2 | 0% | 1 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | difendi | 0% | 0% | 100% | 61.0 | 4.0 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | studia | 4% | 96% | 0% | 6.7 | 19.8 | 0% | 1 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | casuale | 1% | 99% | 0% | 9.9 | 19.9 | 0% | 0 |
| Ferraglia Urlante | `ferraglia_urlante` | attacca | 0% | 100% | 0% | 10.7 | 20.0 | 0% | 0 |
| Ferraglia Urlante | `ferraglia_urlante` | difendi | 0% | 0% | 100% | 61.0 | 0.2 | 0% | 0 |
| Ferraglia Urlante | `ferraglia_urlante` | studia | 0% | 100% | 0% | 11.0 | 20.0 | 0% | 0 |
| Ferraglia Urlante | `ferraglia_urlante` | casuale | 0% | 100% | 0% | 15.8 | 20.0 | 0% | 0 |
| Ghoul | `ghoul` | attacca | 11% | 89% | 0% | 10.4 | 18.9 | 0% | 1 |
| Ghoul | `ghoul` | difendi | 0% | 0% | 100% | 61.0 | 0.2 | 0% | 0 |
| Ghoul | `ghoul` | studia | 7% | 93% | 0% | 10.5 | 19.5 | 0% | 1 |
| Ghoul | `ghoul` | casuale | 2% | 98% | 0% | 15.6 | 19.8 | 0% | 0 |
| El Muy Bonito | `giocoliere` | attacca | 100% | 0% | 0% | 5.9 | 12.0 | 0% | 18 |
| El Muy Bonito | `giocoliere` | difendi | 0% | 0% | 100% | 61.0 | 3.1 | 0% | 0 |
| El Muy Bonito | `giocoliere` | studia | 2% | 98% | 0% | 6.2 | 20.0 | 0% | 0 |
| El Muy Bonito | `giocoliere` | casuale | 21% | 79% | 0% | 9.5 | 19.1 | 0% | 4 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | attacca | 3% | 97% | 0% | 8.0 | 19.9 | 0% | 1 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | difendi | 0% | 0% | 100% | 61.0 | 2.9 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | studia | 0% | 100% | 0% | 8.6 | 20.0 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | casuale | 0% | 100% | 0% | 12.1 | 20.0 | 0% | 0 |
| Goblin Tipico | `goblin_tipico` | attacca | 100% | 0% | 0% | 2.0 | 1.0 | 0% | 2 |
| Goblin Tipico | `goblin_tipico` | difendi | 0% | 0% | 100% | 61.0 | 0.1 | 0% | 0 |
| Goblin Tipico | `goblin_tipico` | studia | 100% | 0% | 0% | 5.0 | 3.8 | 0% | 2 |
| Goblin Tipico | `goblin_tipico` | casuale | 100% | 0% | 0% | 6.4 | 3.0 | 0% | 2 |
| Infetto Rapido | `infetto_rapido` | attacca | 100% | 0% | 0% | 2.6 | 5.0 | 0% | 7 |
| Infetto Rapido | `infetto_rapido` | difendi | 0% | 0% | 100% | 61.0 | 2.0 | 0% | 0 |
| Infetto Rapido | `infetto_rapido` | studia | 100% | 0% | 0% | 5.7 | 10.6 | 0% | 7 |
| Infetto Rapido | `infetto_rapido` | casuale | 95% | 5% | 0% | 8.0 | 10.2 | 0% | 7 |
| L'ultimo spettacolo di Jerah | `jerah` | attacca | 1% | 99% | 0% | 8.5 | 20.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | difendi | 0% | 100% | 0% | 15.6 | 20.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | studia | 1% | 99% | 0% | 8.6 | 20.0 | 0% | 1 |
| L'ultimo spettacolo di Jerah | `jerah` | casuale | 2% | 98% | 0% | 11.2 | 19.9 | 0% | 1 |
| Jongo Dongo | `jongo_dongo` | attacca | 0% | 100% | 0% | 7.3 | 20.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | difendi | 0% | 49% | 51% | 52.5 | 16.3 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | studia | 0% | 100% | 0% | 7.4 | 20.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | casuale | 0% | 100% | 0% | 9.6 | 20.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | attacca | 0% | 100% | 0% | 3.2 | 20.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | difendi | 0% | 100% | 0% | 11.2 | 20.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | studia | 0% | 100% | 0% | 3.2 | 20.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | casuale | 0% | 100% | 0% | 3.9 | 20.0 | 0% | 0 |
| ??? | `l_immortale` | attacca | 0% | 100% | 0% | 20.7 | 20.0 | 0% | 0 |
| ??? | `l_immortale` | difendi | 0% | 0% | 100% | 61.0 | 0.1 | 0% | 0 |
| ??? | `l_immortale` | studia | 0% | 100% | 0% | 20.9 | 20.0 | 0% | 0 |
| ??? | `l_immortale` | casuale | 0% | 100% | 0% | 30.4 | 20.0 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | attacca | 11% | 89% | 0% | 10.4 | 18.9 | 0% | 1 |
| Madre in Lacrime | `madre_in_lacrime` | difendi | 0% | 0% | 100% | 61.0 | 0.2 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | studia | 7% | 93% | 0% | 10.5 | 19.5 | 0% | 1 |
| Madre in Lacrime | `madre_in_lacrime` | casuale | 2% | 98% | 0% | 15.6 | 19.8 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | attacca | 0% | 100% | 0% | 6.0 | 20.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | difendi | 0% | 100% | 0% | 6.0 | 20.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | studia | 0% | 100% | 0% | 6.0 | 20.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | casuale | 0% | 100% | 0% | 6.0 | 20.0 | 0% | 0 |
| Marionetta | `marionetta` | attacca | 5% | 95% | 0% | 4.1 | 19.5 | 0% | 0 |
| Marionetta | `marionetta` | difendi | 0% | 53% | 47% | 48.7 | 16.5 | 0% | 0 |
| Marionetta | `marionetta` | studia | 1% | 99% | 0% | 4.2 | 20.0 | 0% | 0 |
| Marionetta | `marionetta` | casuale | 1% | 99% | 0% | 4.9 | 19.9 | 0% | 0 |
| Fomentado | `maschera_vuota` | attacca | 100% | 0% | 0% | 2.8 | 1.8 | 0% | 8 |
| Fomentado | `maschera_vuota` | difendi | 100% | 0% | 0% | 10.0 | 0.1 | 0% | 8 |
| Fomentado | `maschera_vuota` | studia | 100% | 0% | 0% | 5.0 | 3.8 | 0% | 8 |
| Fomentado | `maschera_vuota` | casuale | 100% | 0% | 0% | 5.3 | 2.6 | 0% | 8 |
| Ombra del passato | `ombra_del_passato` | attacca | 3% | 97% | 0% | 3.1 | 19.5 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | difendi | 0% | 100% | 0% | 14.0 | 20.0 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | studia | 0% | 100% | 0% | 3.3 | 20.0 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | casuale | 1% | 99% | 0% | 4.1 | 19.9 | 0% | 0 |
| Emblema dell'oppressione | `operaio_posseduto` | attacca | 11% | 89% | 0% | 10.4 | 18.9 | 0% | 1 |
| Emblema dell'oppressione | `operaio_posseduto` | difendi | 0% | 0% | 100% | 61.0 | 0.2 | 0% | 0 |
| Emblema dell'oppressione | `operaio_posseduto` | studia | 5% | 95% | 0% | 10.7 | 19.5 | 0% | 1 |
| Emblema dell'oppressione | `operaio_posseduto` | casuale | 3% | 97% | 0% | 15.6 | 19.8 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | attacca | 0% | 100% | 0% | 6.5 | 20.0 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | difendi | 0% | 0% | 100% | 61.0 | 4.9 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | studia | 0% | 100% | 0% | 6.4 | 20.0 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | casuale | 0% | 100% | 0% | 9.5 | 20.0 | 0% | 0 |
| Sacerdote Folle | `sacerdote_folle` | attacca | 5% | 95% | 0% | 6.8 | 19.4 | 0% | 1 |
| Sacerdote Folle | `sacerdote_folle` | difendi | 0% | 0% | 100% | 61.0 | 4.8 | 0% | 0 |
| Sacerdote Folle | `sacerdote_folle` | studia | 1% | 99% | 0% | 6.7 | 19.9 | 0% | 0 |
| Sacerdote Folle | `sacerdote_folle` | casuale | 1% | 99% | 0% | 9.6 | 19.9 | 0% | 0 |
| Sadico | `sadico` | attacca | 7% | 93% | 0% | 7.1 | 19.2 | 0% | 1 |
| Sadico | `sadico` | difendi | 0% | 0% | 100% | 61.0 | 5.8 | 0% | 0 |
| Sadico | `sadico` | studia | 2% | 98% | 0% | 7.3 | 19.8 | 0% | 0 |
| Sadico | `sadico` | casuale | 2% | 98% | 0% | 10.9 | 19.9 | 0% | 0 |
| Slime Infimo | `slime_infimo` | attacca | 100% | 0% | 0% | 2.8 | 1.8 | 0% | 2 |
| Slime Infimo | `slime_infimo` | difendi | 0% | 0% | 100% | 61.0 | 0.1 | 0% | 0 |
| Slime Infimo | `slime_infimo` | studia | 100% | 0% | 0% | 5.9 | 4.7 | 0% | 2 |
| Slime Infimo | `slime_infimo` | casuale | 100% | 0% | 0% | 9.1 | 4.8 | 0% | 2 |
| Stigma | `stigma` | attacca | 5% | 95% | 0% | 7.1 | 19.6 | 0% | 0 |
| Stigma | `stigma` | difendi | 0% | 0% | 100% | 61.0 | 8.4 | 0% | 0 |
| Stigma | `stigma` | studia | 1% | 99% | 0% | 7.3 | 19.9 | 0% | 0 |
| Stigma | `stigma` | casuale | 1% | 99% | 0% | 10.4 | 19.9 | 0% | 0 |
| Tartaruga Innocente | `tartaruga_innocente` | attacca | 49% | 0% | 51% | 46.3 | 0.0 | 0% | 7 |
| Tartaruga Innocente | `tartaruga_innocente` | difendi | 0% | 0% | 100% | 61.0 | 0.0 | 0% | 0 |
| Tartaruga Innocente | `tartaruga_innocente` | studia | 100% | 0% | 0% | 1.0 | 0.0 | 100% | 19 |
| Tartaruga Innocente | `tartaruga_innocente` | casuale | 100% | 0% | 0% | 3.0 | 0.0 | 99% | 19 |
| Un tenero ricordo | `tenero_ricordo` | attacca | 0% | 100% | 0% | 5.5 | 20.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | difendi | 0% | 100% | 0% | 9.5 | 20.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | studia | 0% | 100% | 0% | 5.5 | 20.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | casuale | 0% | 100% | 0% | 6.2 | 20.0 | 0% | 0 |
| Teschio Errante | `teschio_errante` | attacca | 7% | 93% | 0% | 10.3 | 19.3 | 0% | 1 |
| Teschio Errante | `teschio_errante` | difendi | 0% | 0% | 100% | 61.0 | 2.0 | 0% | 0 |
| Teschio Errante | `teschio_errante` | studia | 4% | 96% | 0% | 10.5 | 19.7 | 0% | 0 |
| Teschio Errante | `teschio_errante` | casuale | 3% | 97% | 0% | 15.1 | 19.8 | 0% | 0 |
| Titano Zombie | `titano_zombie` | attacca | 0% | 100% | 0% | 9.7 | 20.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | difendi | 0% | 100% | 0% | 17.4 | 20.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | studia | 0% | 100% | 0% | 7.3 | 20.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | casuale | 0% | 100% | 0% | 9.0 | 20.0 | 0% | 0 |
| Capocantiere | `voce_registrata` | attacca | 29% | 71% | 0% | 10.0 | 18.8 | 0% | 3 |
| Capocantiere | `voce_registrata` | difendi | 0% | 0% | 100% | 61.0 | 2.0 | 0% | 0 |
| Capocantiere | `voce_registrata` | studia | 4% | 96% | 0% | 10.5 | 19.7 | 0% | 0 |
| Capocantiere | `voce_registrata` | casuale | 3% | 97% | 0% | 15.1 | 19.8 | 0% | 0 |
| Zombie Cittadino | `zombie_cittadino` | attacca | 100% | 0% | 0% | 2.8 | 1.8 | 0% | 6 |
| Zombie Cittadino | `zombie_cittadino` | difendi | 0% | 0% | 100% | 61.0 | 0.1 | 0% | 0 |
| Zombie Cittadino | `zombie_cittadino` | studia | 100% | 0% | 0% | 5.8 | 4.6 | 0% | 6 |
| Zombie Cittadino | `zombie_cittadino` | casuale | 100% | 0% | 0% | 8.8 | 4.8 | 0% | 6 |
| Zombie Mostruoso | `zombie_mostruoso` | attacca | 100% | 0% | 0% | 6.8 | 10.9 | 0% | 12 |
| Zombie Mostruoso | `zombie_mostruoso` | difendi | 0% | 0% | 100% | 61.0 | 0.2 | 0% | 0 |
| Zombie Mostruoso | `zombie_mostruoso` | studia | 85% | 15% | 0% | 9.9 | 17.1 | 0% | 10 |
| Zombie Mostruoso | `zombie_mostruoso` | casuale | 17% | 83% | 0% | 15.4 | 19.2 | 0% | 2 |

## Protagonista di livello 2

| creatura | id | come si gioca | vinte | perse | ∞ | giri | danno | risp. | xp |
|---|---|---|--:|--:|--:|--:|--:|--:|--:|
| Abominio Marcio | `abominio_marcio` | attacca | 0% | 100% | 0% | 8.2 | 20.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | difendi | 0% | 0% | 100% | 61.0 | 5.3 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | studia | 0% | 100% | 0% | 8.4 | 20.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | casuale | 0% | 100% | 0% | 12.0 | 20.0 | 0% | 0 |
| Oppresso | `comparsa_di_ruggine` | attacca | 62% | 38% | 0% | 10.7 | 16.8 | 0% | 6 |
| Oppresso | `comparsa_di_ruggine` | difendi | 0% | 0% | 100% | 61.0 | 0.2 | 0% | 0 |
| Oppresso | `comparsa_di_ruggine` | studia | 19% | 81% | 0% | 11.8 | 19.1 | 0% | 2 |
| Oppresso | `comparsa_di_ruggine` | casuale | 4% | 96% | 0% | 17.2 | 19.7 | 0% | 0 |
| Diabolo | `diabolo` | attacca | 9% | 91% | 0% | 11.6 | 19.2 | 0% | 1 |
| Diabolo | `diabolo` | difendi | 0% | 0% | 100% | 61.0 | 1.8 | 0% | 0 |
| Diabolo | `diabolo` | studia | 4% | 96% | 0% | 11.8 | 19.7 | 0% | 0 |
| Diabolo | `diabolo` | casuale | 5% | 95% | 0% | 16.9 | 19.7 | 0% | 0 |
| Il Divoratore | `divoratore` | attacca | 0% | 100% | 0% | 8.2 | 20.0 | 0% | 0 |
| Il Divoratore | `divoratore` | difendi | 0% | 0% | 100% | 61.0 | 5.3 | 0% | 0 |
| Il Divoratore | `divoratore` | studia | 0% | 100% | 0% | 8.4 | 20.0 | 0% | 0 |
| Il Divoratore | `divoratore` | casuale | 0% | 100% | 0% | 12.0 | 20.0 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | attacca | 8% | 92% | 0% | 7.1 | 19.1 | 0% | 1 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | difendi | 0% | 0% | 100% | 61.0 | 3.7 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | studia | 5% | 95% | 0% | 7.4 | 19.6 | 0% | 1 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | casuale | 1% | 99% | 0% | 11.1 | 19.9 | 0% | 0 |
| Ferraglia Urlante | `ferraglia_urlante` | attacca | 0% | 100% | 0% | 12.0 | 20.0 | 0% | 0 |
| Ferraglia Urlante | `ferraglia_urlante` | difendi | 0% | 0% | 100% | 61.0 | 0.2 | 0% | 0 |
| Ferraglia Urlante | `ferraglia_urlante` | studia | 0% | 100% | 0% | 12.3 | 20.0 | 0% | 0 |
| Ferraglia Urlante | `ferraglia_urlante` | casuale | 0% | 100% | 0% | 17.6 | 20.0 | 0% | 0 |
| Ghoul | `ghoul` | attacca | 19% | 81% | 0% | 11.4 | 18.5 | 0% | 2 |
| Ghoul | `ghoul` | difendi | 0% | 0% | 100% | 61.0 | 0.2 | 0% | 0 |
| Ghoul | `ghoul` | studia | 9% | 91% | 0% | 11.7 | 19.4 | 0% | 1 |
| Ghoul | `ghoul` | casuale | 3% | 97% | 0% | 17.2 | 19.8 | 0% | 0 |
| El Muy Bonito | `giocoliere` | attacca | 100% | 0% | 0% | 4.7 | 8.7 | 0% | 15 |
| El Muy Bonito | `giocoliere` | difendi | 0% | 0% | 100% | 61.0 | 2.8 | 0% | 0 |
| El Muy Bonito | `giocoliere` | studia | 37% | 63% | 0% | 6.4 | 18.7 | 0% | 6 |
| El Muy Bonito | `giocoliere` | casuale | 45% | 55% | 0% | 9.1 | 16.8 | 0% | 7 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | attacca | 59% | 41% | 0% | 7.8 | 17.5 | 0% | 21 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | difendi | 0% | 0% | 100% | 61.0 | 2.6 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | studia | 4% | 96% | 0% | 9.1 | 19.9 | 0% | 1 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | casuale | 0% | 100% | 0% | 13.3 | 20.0 | 0% | 0 |
| Goblin Tipico | `goblin_tipico` | attacca | 100% | 0% | 0% | 2.0 | 0.8 | 0% | 2 |
| Goblin Tipico | `goblin_tipico` | difendi | 0% | 0% | 100% | 61.0 | 0.1 | 0% | 0 |
| Goblin Tipico | `goblin_tipico` | studia | 100% | 0% | 0% | 5.0 | 3.3 | 0% | 2 |
| Goblin Tipico | `goblin_tipico` | casuale | 100% | 0% | 0% | 6.2 | 2.8 | 0% | 2 |
| Infetto Rapido | `infetto_rapido` | attacca | 100% | 0% | 0% | 2.0 | 3.3 | 0% | 6 |
| Infetto Rapido | `infetto_rapido` | difendi | 0% | 0% | 100% | 61.0 | 1.8 | 0% | 0 |
| Infetto Rapido | `infetto_rapido` | studia | 100% | 0% | 0% | 5.0 | 8.3 | 0% | 6 |
| Infetto Rapido | `infetto_rapido` | casuale | 99% | 1% | 0% | 5.7 | 6.5 | 0% | 6 |
| L'ultimo spettacolo di Jerah | `jerah` | attacca | 25% | 75% | 0% | 8.7 | 19.2 | 0% | 11 |
| L'ultimo spettacolo di Jerah | `jerah` | difendi | 0% | 100% | 0% | 15.6 | 20.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | studia | 5% | 95% | 0% | 8.9 | 19.8 | 0% | 2 |
| L'ultimo spettacolo di Jerah | `jerah` | casuale | 4% | 96% | 0% | 11.6 | 19.8 | 0% | 2 |
| Jongo Dongo | `jongo_dongo` | attacca | 0% | 100% | 0% | 7.9 | 20.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | difendi | 0% | 42% | 58% | 54.2 | 15.2 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | studia | 0% | 100% | 0% | 7.9 | 20.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | casuale | 0% | 100% | 0% | 10.7 | 20.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | attacca | 0% | 100% | 0% | 3.6 | 20.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | difendi | 0% | 100% | 0% | 12.9 | 20.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | studia | 0% | 100% | 0% | 3.6 | 20.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | casuale | 0% | 100% | 0% | 4.5 | 20.0 | 0% | 0 |
| ??? | `l_immortale` | attacca | 0% | 100% | 0% | 23.1 | 20.0 | 0% | 0 |
| ??? | `l_immortale` | difendi | 0% | 0% | 100% | 61.0 | 0.1 | 0% | 0 |
| ??? | `l_immortale` | studia | 0% | 100% | 0% | 23.3 | 20.0 | 0% | 0 |
| ??? | `l_immortale` | casuale | 0% | 100% | 0% | 34.2 | 20.0 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | attacca | 13% | 87% | 0% | 11.5 | 18.7 | 0% | 1 |
| Madre in Lacrime | `madre_in_lacrime` | difendi | 0% | 0% | 100% | 61.0 | 0.2 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | studia | 9% | 91% | 0% | 11.7 | 19.4 | 0% | 1 |
| Madre in Lacrime | `madre_in_lacrime` | casuale | 3% | 97% | 0% | 17.2 | 19.8 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | attacca | 0% | 100% | 0% | 6.0 | 20.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | difendi | 0% | 100% | 0% | 6.0 | 20.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | studia | 0% | 100% | 0% | 6.0 | 20.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | casuale | 0% | 100% | 0% | 6.0 | 20.0 | 0% | 0 |
| Marionetta | `marionetta` | attacca | 5% | 95% | 0% | 4.6 | 19.5 | 0% | 0 |
| Marionetta | `marionetta` | difendi | 0% | 43% | 57% | 51.2 | 15.5 | 0% | 0 |
| Marionetta | `marionetta` | studia | 1% | 99% | 0% | 4.7 | 19.9 | 0% | 0 |
| Marionetta | `marionetta` | casuale | 1% | 99% | 0% | 5.4 | 19.9 | 0% | 0 |
| Fomentado | `maschera_vuota` | attacca | 100% | 0% | 0% | 2.0 | 0.8 | 0% | 7 |
| Fomentado | `maschera_vuota` | difendi | 100% | 0% | 0% | 10.0 | 0.1 | 0% | 7 |
| Fomentado | `maschera_vuota` | studia | 100% | 0% | 0% | 5.0 | 3.4 | 0% | 7 |
| Fomentado | `maschera_vuota` | casuale | 100% | 0% | 0% | 4.8 | 2.0 | 0% | 7 |
| Ombra del passato | `ombra_del_passato` | attacca | 3% | 97% | 0% | 3.5 | 19.5 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | difendi | 0% | 100% | 0% | 16.0 | 20.0 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | studia | 1% | 99% | 0% | 3.7 | 20.0 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | casuale | 1% | 99% | 0% | 4.6 | 19.9 | 0% | 0 |
| Emblema dell'oppressione | `operaio_posseduto` | attacca | 50% | 50% | 0% | 11.0 | 17.5 | 0% | 5 |
| Emblema dell'oppressione | `operaio_posseduto` | difendi | 0% | 0% | 100% | 61.0 | 0.2 | 0% | 0 |
| Emblema dell'oppressione | `operaio_posseduto` | studia | 11% | 89% | 0% | 11.9 | 19.3 | 0% | 1 |
| Emblema dell'oppressione | `operaio_posseduto` | casuale | 4% | 96% | 0% | 17.2 | 19.7 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | attacca | 6% | 94% | 0% | 7.2 | 19.8 | 0% | 1 |
| Orrore di Meridia | `orrore_di_meridia` | difendi | 0% | 0% | 100% | 61.0 | 4.5 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | studia | 0% | 100% | 0% | 7.3 | 20.0 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | casuale | 0% | 100% | 0% | 10.8 | 20.0 | 0% | 0 |
| Sacerdote Folle | `sacerdote_folle` | attacca | 5% | 95% | 0% | 7.4 | 19.3 | 0% | 1 |
| Sacerdote Folle | `sacerdote_folle` | difendi | 0% | 0% | 100% | 61.0 | 4.4 | 0% | 0 |
| Sacerdote Folle | `sacerdote_folle` | studia | 1% | 99% | 0% | 7.4 | 19.9 | 0% | 0 |
| Sacerdote Folle | `sacerdote_folle` | casuale | 1% | 99% | 0% | 10.3 | 19.8 | 0% | 0 |
| Sadico | `sadico` | attacca | 9% | 91% | 0% | 8.0 | 19.1 | 0% | 1 |
| Sadico | `sadico` | difendi | 0% | 0% | 100% | 61.0 | 5.3 | 0% | 0 |
| Sadico | `sadico` | studia | 3% | 97% | 0% | 8.1 | 19.8 | 0% | 0 |
| Sadico | `sadico` | casuale | 2% | 98% | 0% | 12.0 | 19.9 | 0% | 0 |
| Slime Infimo | `slime_infimo` | attacca | 100% | 0% | 0% | 2.0 | 0.8 | 0% | 2 |
| Slime Infimo | `slime_infimo` | difendi | 0% | 0% | 100% | 61.0 | 0.1 | 0% | 0 |
| Slime Infimo | `slime_infimo` | studia | 100% | 0% | 0% | 5.0 | 3.3 | 0% | 2 |
| Slime Infimo | `slime_infimo` | casuale | 100% | 0% | 0% | 6.4 | 2.8 | 0% | 2 |
| Stigma | `stigma` | attacca | 7% | 93% | 0% | 8.0 | 19.5 | 0% | 1 |
| Stigma | `stigma` | difendi | 0% | 0% | 100% | 61.0 | 7.6 | 0% | 0 |
| Stigma | `stigma` | studia | 2% | 98% | 0% | 8.2 | 19.9 | 0% | 0 |
| Stigma | `stigma` | casuale | 2% | 98% | 0% | 11.5 | 19.9 | 0% | 0 |
| Tartaruga Innocente | `tartaruga_innocente` | attacca | 51% | 0% | 49% | 46.0 | 0.0 | 0% | 7 |
| Tartaruga Innocente | `tartaruga_innocente` | difendi | 0% | 0% | 100% | 61.0 | 0.0 | 0% | 0 |
| Tartaruga Innocente | `tartaruga_innocente` | studia | 100% | 0% | 0% | 1.0 | 0.0 | 100% | 16 |
| Tartaruga Innocente | `tartaruga_innocente` | casuale | 100% | 0% | 0% | 3.0 | 0.0 | 99% | 16 |
| Un tenero ricordo | `tenero_ricordo` | attacca | 0% | 100% | 0% | 5.9 | 20.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | difendi | 0% | 100% | 0% | 9.5 | 20.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | studia | 0% | 100% | 0% | 5.8 | 20.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | casuale | 0% | 100% | 0% | 6.5 | 20.0 | 0% | 0 |
| Teschio Errante | `teschio_errante` | attacca | 29% | 71% | 0% | 11.3 | 18.7 | 0% | 2 |
| Teschio Errante | `teschio_errante` | difendi | 0% | 0% | 100% | 61.0 | 1.8 | 0% | 0 |
| Teschio Errante | `teschio_errante` | studia | 5% | 95% | 0% | 11.8 | 19.6 | 0% | 0 |
| Teschio Errante | `teschio_errante` | casuale | 5% | 95% | 0% | 16.9 | 19.7 | 0% | 0 |
| Titano Zombie | `titano_zombie` | attacca | 0% | 100% | 0% | 10.3 | 20.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | difendi | 0% | 100% | 0% | 17.6 | 20.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | studia | 0% | 100% | 0% | 8.1 | 20.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | casuale | 0% | 100% | 0% | 9.7 | 20.0 | 0% | 0 |
| Capocantiere | `voce_registrata` | attacca | 100% | 0% | 0% | 7.7 | 12.7 | 0% | 8 |
| Capocantiere | `voce_registrata` | difendi | 0% | 0% | 100% | 61.0 | 1.8 | 0% | 0 |
| Capocantiere | `voce_registrata` | studia | 60% | 40% | 0% | 10.6 | 17.8 | 0% | 5 |
| Capocantiere | `voce_registrata` | casuale | 25% | 75% | 0% | 16.3 | 19.0 | 0% | 2 |
| Zombie Cittadino | `zombie_cittadino` | attacca | 100% | 0% | 0% | 2.0 | 0.8 | 0% | 5 |
| Zombie Cittadino | `zombie_cittadino` | difendi | 0% | 0% | 100% | 61.0 | 0.1 | 0% | 0 |
| Zombie Cittadino | `zombie_cittadino` | studia | 100% | 0% | 0% | 5.0 | 3.4 | 0% | 5 |
| Zombie Cittadino | `zombie_cittadino` | casuale | 100% | 0% | 0% | 5.9 | 2.6 | 0% | 5 |
| Zombie Mostruoso | `zombie_mostruoso` | attacca | 100% | 0% | 0% | 5.4 | 7.5 | 0% | 12 |
| Zombie Mostruoso | `zombie_mostruoso` | difendi | 0% | 0% | 100% | 61.0 | 0.2 | 0% | 0 |
| Zombie Mostruoso | `zombie_mostruoso` | studia | 100% | 0% | 0% | 8.6 | 12.9 | 0% | 12 |
| Zombie Mostruoso | `zombie_mostruoso` | casuale | 65% | 35% | 0% | 14.8 | 16.0 | 0% | 8 |

## Protagonista di livello 3

| creatura | id | come si gioca | vinte | perse | ∞ | giri | danno | risp. | xp |
|---|---|---|--:|--:|--:|--:|--:|--:|--:|
| Abominio Marcio | `abominio_marcio` | attacca | 17% | 83% | 0% | 9.2 | 19.5 | 0% | 2 |
| Abominio Marcio | `abominio_marcio` | difendi | 0% | 0% | 100% | 61.0 | 4.5 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | studia | 1% | 99% | 0% | 9.7 | 20.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | casuale | 0% | 100% | 0% | 13.6 | 20.0 | 0% | 0 |
| Oppresso | `comparsa_di_ruggine` | attacca | 100% | 0% | 0% | 8.0 | 10.3 | 0% | 7 |
| Oppresso | `comparsa_di_ruggine` | difendi | 0% | 0% | 100% | 61.0 | 0.2 | 0% | 0 |
| Oppresso | `comparsa_di_ruggine` | studia | 87% | 13% | 0% | 11.1 | 15.1 | 0% | 6 |
| Oppresso | `comparsa_di_ruggine` | casuale | 30% | 70% | 0% | 19.0 | 18.8 | 0% | 2 |
| Diabolo | `diabolo` | attacca | 45% | 55% | 0% | 12.4 | 17.8 | 0% | 3 |
| Diabolo | `diabolo` | difendi | 0% | 0% | 100% | 61.0 | 1.5 | 0% | 0 |
| Diabolo | `diabolo` | studia | 10% | 90% | 0% | 13.2 | 19.4 | 0% | 1 |
| Diabolo | `diabolo` | casuale | 7% | 93% | 0% | 19.4 | 19.6 | 0% | 0 |
| Il Divoratore | `divoratore` | attacca | 0% | 100% | 0% | 9.3 | 20.0 | 0% | 0 |
| Il Divoratore | `divoratore` | difendi | 0% | 0% | 100% | 61.0 | 4.5 | 0% | 0 |
| Il Divoratore | `divoratore` | studia | 0% | 100% | 0% | 9.7 | 20.0 | 0% | 0 |
| Il Divoratore | `divoratore` | casuale | 0% | 100% | 0% | 13.6 | 20.0 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | attacca | 9% | 91% | 0% | 8.2 | 19.1 | 0% | 1 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | difendi | 0% | 0% | 100% | 61.0 | 3.2 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | studia | 7% | 93% | 0% | 8.4 | 19.5 | 0% | 1 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | casuale | 3% | 97% | 0% | 12.6 | 19.8 | 0% | 0 |
| Ferraglia Urlante | `ferraglia_urlante` | attacca | 42% | 58% | 0% | 12.8 | 18.3 | 0% | 5 |
| Ferraglia Urlante | `ferraglia_urlante` | difendi | 0% | 0% | 100% | 61.0 | 0.2 | 0% | 0 |
| Ferraglia Urlante | `ferraglia_urlante` | studia | 11% | 89% | 0% | 13.9 | 19.6 | 0% | 1 |
| Ferraglia Urlante | `ferraglia_urlante` | casuale | 1% | 99% | 0% | 20.2 | 20.0 | 0% | 0 |
| Ghoul | `ghoul` | attacca | 95% | 5% | 0% | 10.1 | 13.3 | 0% | 6 |
| Ghoul | `ghoul` | difendi | 0% | 0% | 100% | 61.0 | 0.2 | 0% | 0 |
| Ghoul | `ghoul` | studia | 53% | 47% | 0% | 12.5 | 17.6 | 0% | 3 |
| Ghoul | `ghoul` | casuale | 9% | 91% | 0% | 19.5 | 19.5 | 0% | 1 |
| El Muy Bonito | `giocoliere` | attacca | 100% | 0% | 0% | 3.9 | 6.4 | 0% | 13 |
| El Muy Bonito | `giocoliere` | difendi | 0% | 0% | 100% | 61.0 | 2.5 | 0% | 0 |
| El Muy Bonito | `giocoliere` | studia | 72% | 28% | 0% | 6.0 | 15.7 | 0% | 9 |
| El Muy Bonito | `giocoliere` | casuale | 62% | 38% | 0% | 8.6 | 14.0 | 0% | 8 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | attacca | 95% | 5% | 0% | 7.0 | 12.6 | 0% | 27 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | difendi | 0% | 0% | 100% | 61.0 | 2.3 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | studia | 38% | 62% | 0% | 9.9 | 18.8 | 0% | 11 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | casuale | 5% | 95% | 0% | 14.0 | 19.9 | 0% | 1 |
| Goblin Tipico | `goblin_tipico` | attacca | 100% | 0% | 0% | 1.8 | 0.6 | 0% | 1 |
| Goblin Tipico | `goblin_tipico` | difendi | 0% | 0% | 100% | 61.0 | 0.0 | 0% | 0 |
| Goblin Tipico | `goblin_tipico` | studia | 100% | 0% | 0% | 4.8 | 2.8 | 0% | 1 |
| Goblin Tipico | `goblin_tipico` | casuale | 100% | 0% | 0% | 5.8 | 2.2 | 0% | 1 |
| Infetto Rapido | `infetto_rapido` | attacca | 100% | 0% | 0% | 2.0 | 2.8 | 0% | 5 |
| Infetto Rapido | `infetto_rapido` | difendi | 0% | 0% | 100% | 61.0 | 1.5 | 0% | 0 |
| Infetto Rapido | `infetto_rapido` | studia | 100% | 0% | 0% | 5.0 | 7.3 | 0% | 5 |
| Infetto Rapido | `infetto_rapido` | casuale | 100% | 0% | 0% | 5.5 | 5.5 | 0% | 5 |
| L'ultimo spettacolo di Jerah | `jerah` | attacca | 71% | 29% | 0% | 8.0 | 15.4 | 0% | 24 |
| L'ultimo spettacolo di Jerah | `jerah` | difendi | 0% | 100% | 0% | 15.7 | 20.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | studia | 15% | 85% | 0% | 9.3 | 19.4 | 0% | 5 |
| L'ultimo spettacolo di Jerah | `jerah` | casuale | 9% | 91% | 0% | 11.7 | 19.5 | 0% | 3 |
| Jongo Dongo | `jongo_dongo` | attacca | 0% | 100% | 0% | 8.6 | 20.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | difendi | 0% | 35% | 65% | 55.3 | 14.1 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | studia | 0% | 100% | 0% | 8.7 | 20.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | casuale | 0% | 100% | 0% | 12.1 | 20.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | attacca | 0% | 100% | 0% | 4.1 | 20.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | difendi | 0% | 100% | 0% | 15.3 | 20.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | studia | 0% | 100% | 0% | 4.1 | 20.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | casuale | 0% | 100% | 0% | 5.1 | 20.0 | 0% | 0 |
| ??? | `l_immortale` | attacca | 0% | 100% | 0% | 26.1 | 20.0 | 0% | 0 |
| ??? | `l_immortale` | difendi | 0% | 0% | 100% | 61.0 | 0.0 | 0% | 0 |
| ??? | `l_immortale` | studia | 0% | 100% | 0% | 26.5 | 20.0 | 0% | 0 |
| ??? | `l_immortale` | casuale | 0% | 100% | 0% | 38.9 | 20.0 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | attacca | 51% | 49% | 0% | 12.3 | 17.1 | 0% | 3 |
| Madre in Lacrime | `madre_in_lacrime` | difendi | 0% | 0% | 100% | 61.0 | 0.2 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | studia | 20% | 80% | 0% | 13.2 | 18.9 | 0% | 1 |
| Madre in Lacrime | `madre_in_lacrime` | casuale | 5% | 95% | 0% | 19.6 | 19.7 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | attacca | 0% | 100% | 0% | 6.0 | 20.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | difendi | 0% | 100% | 0% | 6.0 | 20.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | studia | 0% | 100% | 0% | 6.0 | 20.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | casuale | 0% | 100% | 0% | 6.0 | 20.0 | 0% | 0 |
| Marionetta | `marionetta` | attacca | 5% | 95% | 0% | 5.2 | 19.4 | 0% | 0 |
| Marionetta | `marionetta` | difendi | 0% | 34% | 66% | 53.2 | 14.0 | 0% | 0 |
| Marionetta | `marionetta` | studia | 2% | 98% | 0% | 5.4 | 19.9 | 0% | 0 |
| Marionetta | `marionetta` | casuale | 1% | 99% | 0% | 6.2 | 19.9 | 0% | 0 |
| Fomentado | `maschera_vuota` | attacca | 100% | 0% | 0% | 2.0 | 0.7 | 0% | 6 |
| Fomentado | `maschera_vuota` | difendi | 100% | 0% | 0% | 10.0 | 0.0 | 0% | 6 |
| Fomentado | `maschera_vuota` | studia | 100% | 0% | 0% | 4.8 | 2.8 | 0% | 6 |
| Fomentado | `maschera_vuota` | casuale | 100% | 0% | 0% | 4.4 | 1.7 | 0% | 6 |
| Ombra del passato | `ombra_del_passato` | attacca | 4% | 96% | 0% | 4.0 | 19.5 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | difendi | 0% | 100% | 0% | 18.7 | 20.0 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | studia | 1% | 99% | 0% | 4.1 | 20.0 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | casuale | 1% | 99% | 0% | 5.1 | 19.9 | 0% | 0 |
| Emblema dell'oppressione | `operaio_posseduto` | attacca | 100% | 0% | 0% | 8.6 | 11.1 | 0% | 8 |
| Emblema dell'oppressione | `operaio_posseduto` | difendi | 0% | 0% | 100% | 61.0 | 0.2 | 0% | 0 |
| Emblema dell'oppressione | `operaio_posseduto` | studia | 80% | 20% | 0% | 11.6 | 15.8 | 0% | 6 |
| Emblema dell'oppressione | `operaio_posseduto` | casuale | 22% | 78% | 0% | 19.1 | 19.0 | 0% | 2 |
| Orrore di Meridia | `orrore_di_meridia` | attacca | 57% | 43% | 0% | 7.4 | 17.3 | 0% | 11 |
| Orrore di Meridia | `orrore_di_meridia` | difendi | 0% | 0% | 100% | 61.0 | 4.0 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | studia | 9% | 91% | 0% | 8.2 | 19.7 | 0% | 2 |
| Orrore di Meridia | `orrore_di_meridia` | casuale | 1% | 99% | 0% | 12.1 | 20.0 | 0% | 0 |
| Sacerdote Folle | `sacerdote_folle` | attacca | 5% | 95% | 0% | 8.2 | 19.3 | 0% | 1 |
| Sacerdote Folle | `sacerdote_folle` | difendi | 0% | 0% | 100% | 61.0 | 3.8 | 0% | 0 |
| Sacerdote Folle | `sacerdote_folle` | studia | 1% | 99% | 0% | 8.2 | 19.8 | 0% | 0 |
| Sacerdote Folle | `sacerdote_folle` | casuale | 1% | 99% | 0% | 11.4 | 19.8 | 0% | 0 |
| Sadico | `sadico` | attacca | 37% | 63% | 0% | 8.8 | 17.9 | 0% | 3 |
| Sadico | `sadico` | difendi | 0% | 0% | 100% | 61.0 | 4.5 | 0% | 0 |
| Sadico | `sadico` | studia | 9% | 91% | 0% | 9.3 | 19.6 | 0% | 1 |
| Sadico | `sadico` | casuale | 3% | 97% | 0% | 13.4 | 19.8 | 0% | 0 |
| Slime Infimo | `slime_infimo` | attacca | 100% | 0% | 0% | 2.0 | 0.7 | 0% | 1 |
| Slime Infimo | `slime_infimo` | difendi | 0% | 0% | 100% | 61.0 | 0.0 | 0% | 0 |
| Slime Infimo | `slime_infimo` | studia | 100% | 0% | 0% | 5.0 | 2.9 | 0% | 1 |
| Slime Infimo | `slime_infimo` | casuale | 100% | 0% | 0% | 6.2 | 2.5 | 0% | 1 |
| Stigma | `stigma` | attacca | 27% | 73% | 0% | 8.8 | 18.8 | 0% | 2 |
| Stigma | `stigma` | difendi | 0% | 0% | 100% | 61.0 | 6.4 | 0% | 0 |
| Stigma | `stigma` | studia | 4% | 96% | 0% | 9.3 | 19.8 | 0% | 0 |
| Stigma | `stigma` | casuale | 3% | 97% | 0% | 13.1 | 19.8 | 0% | 0 |
| Tartaruga Innocente | `tartaruga_innocente` | attacca | 63% | 0% | 37% | 43.5 | 0.0 | 0% | 7 |
| Tartaruga Innocente | `tartaruga_innocente` | difendi | 0% | 0% | 100% | 61.0 | 0.0 | 0% | 0 |
| Tartaruga Innocente | `tartaruga_innocente` | studia | 100% | 0% | 0% | 1.0 | 0.0 | 100% | 14 |
| Tartaruga Innocente | `tartaruga_innocente` | casuale | 100% | 0% | 0% | 3.0 | 0.0 | 99% | 14 |
| Un tenero ricordo | `tenero_ricordo` | attacca | 0% | 100% | 0% | 6.3 | 20.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | difendi | 0% | 100% | 0% | 9.5 | 20.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | studia | 0% | 100% | 0% | 6.2 | 20.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | casuale | 0% | 100% | 0% | 6.8 | 20.0 | 0% | 0 |
| Teschio Errante | `teschio_errante` | attacca | 100% | 0% | 0% | 8.7 | 12.5 | 0% | 6 |
| Teschio Errante | `teschio_errante` | difendi | 0% | 0% | 100% | 61.0 | 1.5 | 0% | 0 |
| Teschio Errante | `teschio_errante` | studia | 67% | 33% | 0% | 11.5 | 17.1 | 0% | 4 |
| Teschio Errante | `teschio_errante` | casuale | 23% | 77% | 0% | 18.8 | 19.0 | 0% | 1 |
| Titano Zombie | `titano_zombie` | attacca | 0% | 100% | 0% | 10.8 | 20.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | difendi | 0% | 100% | 0% | 17.7 | 20.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | studia | 0% | 100% | 0% | 9.2 | 20.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | casuale | 0% | 100% | 0% | 10.3 | 20.0 | 0% | 0 |
| Capocantiere | `voce_registrata` | attacca | 100% | 0% | 0% | 6.1 | 8.6 | 0% | 6 |
| Capocantiere | `voce_registrata` | difendi | 0% | 0% | 100% | 61.0 | 1.5 | 0% | 0 |
| Capocantiere | `voce_registrata` | studia | 97% | 3% | 0% | 9.1 | 13.3 | 0% | 6 |
| Capocantiere | `voce_registrata` | casuale | 65% | 35% | 0% | 16.1 | 16.1 | 0% | 4 |
| Zombie Cittadino | `zombie_cittadino` | attacca | 100% | 0% | 0% | 2.0 | 0.7 | 0% | 4 |
| Zombie Cittadino | `zombie_cittadino` | difendi | 0% | 0% | 100% | 61.0 | 0.0 | 0% | 0 |
| Zombie Cittadino | `zombie_cittadino` | studia | 100% | 0% | 0% | 5.0 | 3.0 | 0% | 4 |
| Zombie Cittadino | `zombie_cittadino` | casuale | 100% | 0% | 0% | 5.8 | 2.2 | 0% | 4 |
| Zombie Mostruoso | `zombie_mostruoso` | attacca | 100% | 0% | 0% | 4.6 | 5.3 | 0% | 12 |
| Zombie Mostruoso | `zombie_mostruoso` | difendi | 0% | 0% | 100% | 61.0 | 0.2 | 0% | 0 |
| Zombie Mostruoso | `zombie_mostruoso` | studia | 100% | 0% | 0% | 7.7 | 9.8 | 0% | 12 |
| Zombie Mostruoso | `zombie_mostruoso` | casuale | 83% | 17% | 0% | 13.5 | 12.7 | 0% | 10 |

## Protagonista di livello 5

| creatura | id | come si gioca | vinte | perse | ∞ | giri | danno | risp. | xp |
|---|---|---|--:|--:|--:|--:|--:|--:|--:|
| Abominio Marcio | `abominio_marcio` | attacca | 97% | 3% | 0% | 7.6 | 10.7 | 0% | 6 |
| Abominio Marcio | `abominio_marcio` | difendi | 0% | 0% | 100% | 61.0 | 3.1 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | studia | 81% | 19% | 0% | 10.3 | 14.4 | 0% | 5 |
| Abominio Marcio | `abominio_marcio` | casuale | 35% | 65% | 0% | 17.7 | 18.3 | 0% | 2 |
| Oppresso | `comparsa_di_ruggine` | attacca | 100% | 0% | 0% | 5.4 | 4.5 | 0% | 4 |
| Oppresso | `comparsa_di_ruggine` | difendi | 0% | 0% | 100% | 61.0 | 0.1 | 0% | 0 |
| Oppresso | `comparsa_di_ruggine` | studia | 100% | 0% | 0% | 8.5 | 7.7 | 0% | 4 |
| Oppresso | `comparsa_di_ruggine` | casuale | 95% | 5% | 0% | 16.1 | 11.1 | 0% | 4 |
| Diabolo | `diabolo` | attacca | 100% | 0% | 0% | 7.6 | 8.0 | 0% | 3 |
| Diabolo | `diabolo` | difendi | 0% | 0% | 100% | 61.0 | 1.0 | 0% | 0 |
| Diabolo | `diabolo` | studia | 100% | 0% | 0% | 10.7 | 11.3 | 0% | 3 |
| Diabolo | `diabolo` | casuale | 69% | 31% | 0% | 21.0 | 15.2 | 0% | 2 |
| Il Divoratore | `divoratore` | attacca | 77% | 23% | 0% | 9.9 | 14.6 | 0% | 6 |
| Il Divoratore | `divoratore` | difendi | 0% | 0% | 100% | 61.0 | 3.1 | 0% | 0 |
| Il Divoratore | `divoratore` | studia | 51% | 49% | 0% | 12.0 | 17.4 | 0% | 4 |
| Il Divoratore | `divoratore` | casuale | 5% | 95% | 0% | 18.6 | 19.7 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | attacca | 17% | 83% | 0% | 10.9 | 18.5 | 0% | 1 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | difendi | 0% | 0% | 100% | 61.0 | 2.3 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | studia | 11% | 89% | 0% | 11.2 | 19.1 | 0% | 1 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | casuale | 4% | 96% | 0% | 17.3 | 19.7 | 0% | 0 |
| Ferraglia Urlante | `ferraglia_urlante` | attacca | 100% | 0% | 0% | 8.2 | 7.8 | 0% | 6 |
| Ferraglia Urlante | `ferraglia_urlante` | difendi | 0% | 0% | 100% | 61.0 | 0.1 | 0% | 0 |
| Ferraglia Urlante | `ferraglia_urlante` | studia | 99% | 1% | 0% | 11.3 | 10.5 | 0% | 6 |
| Ferraglia Urlante | `ferraglia_urlante` | casuale | 66% | 34% | 0% | 22.8 | 15.8 | 0% | 4 |
| Ghoul | `ghoul` | attacca | 100% | 0% | 0% | 6.5 | 5.5 | 0% | 4 |
| Ghoul | `ghoul` | difendi | 0% | 0% | 100% | 61.0 | 0.1 | 0% | 0 |
| Ghoul | `ghoul` | studia | 100% | 0% | 0% | 9.6 | 9.1 | 0% | 4 |
| Ghoul | `ghoul` | casuale | 84% | 16% | 0% | 19.5 | 13.3 | 0% | 3 |
| El Muy Bonito | `giocoliere` | attacca | 100% | 0% | 0% | 2.9 | 3.6 | 0% | 7 |
| El Muy Bonito | `giocoliere` | difendi | 0% | 0% | 100% | 61.0 | 1.8 | 0% | 0 |
| El Muy Bonito | `giocoliere` | studia | 99% | 1% | 0% | 5.6 | 8.7 | 0% | 7 |
| El Muy Bonito | `giocoliere` | casuale | 90% | 10% | 0% | 7.2 | 8.6 | 0% | 6 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | attacca | 100% | 0% | 0% | 5.2 | 7.9 | 0% | 16 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | difendi | 0% | 0% | 100% | 61.0 | 1.6 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | studia | 93% | 7% | 0% | 10.2 | 13.3 | 0% | 15 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | casuale | 35% | 65% | 0% | 14.2 | 17.6 | 0% | 6 |
| Goblin Tipico | `goblin_tipico` | attacca | 100% | 0% | 0% | 1.0 | 0.0 | 0% | 1 |
| Goblin Tipico | `goblin_tipico` | difendi | 0% | 0% | 100% | 61.0 | 0.0 | 0% | 0 |
| Goblin Tipico | `goblin_tipico` | studia | 100% | 0% | 0% | 4.0 | 1.6 | 0% | 1 |
| Goblin Tipico | `goblin_tipico` | casuale | 100% | 0% | 0% | 3.2 | 0.7 | 0% | 1 |
| Infetto Rapido | `infetto_rapido` | attacca | 100% | 0% | 0% | 1.0 | 0.9 | 0% | 3 |
| Infetto Rapido | `infetto_rapido` | difendi | 0% | 0% | 100% | 61.0 | 1.0 | 0% | 0 |
| Infetto Rapido | `infetto_rapido` | studia | 100% | 0% | 0% | 4.0 | 4.3 | 0% | 3 |
| Infetto Rapido | `infetto_rapido` | casuale | 100% | 0% | 0% | 3.1 | 2.1 | 0% | 3 |
| L'ultimo spettacolo di Jerah | `jerah` | attacca | 100% | 0% | 0% | 5.6 | 7.7 | 0% | 19 |
| L'ultimo spettacolo di Jerah | `jerah` | difendi | 0% | 100% | 0% | 15.7 | 20.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | studia | 42% | 58% | 0% | 9.5 | 17.1 | 0% | 8 |
| L'ultimo spettacolo di Jerah | `jerah` | casuale | 21% | 79% | 0% | 11.7 | 17.9 | 0% | 4 |
| Jongo Dongo | `jongo_dongo` | attacca | 0% | 100% | 0% | 10.4 | 20.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | difendi | 0% | 19% | 81% | 58.1 | 11.8 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | studia | 0% | 100% | 0% | 10.8 | 20.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | casuale | 0% | 100% | 0% | 15.1 | 20.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | attacca | 0% | 100% | 0% | 5.9 | 20.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | difendi | 0% | 100% | 0% | 22.9 | 20.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | studia | 0% | 100% | 0% | 5.5 | 20.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | casuale | 0% | 100% | 0% | 7.1 | 20.0 | 0% | 0 |
| ??? | `l_immortale` | attacca | 0% | 100% | 0% | 36.0 | 20.0 | 0% | 0 |
| ??? | `l_immortale` | difendi | 0% | 0% | 100% | 61.0 | 0.0 | 0% | 0 |
| ??? | `l_immortale` | studia | 0% | 100% | 0% | 37.2 | 20.0 | 0% | 0 |
| ??? | `l_immortale` | casuale | 0% | 79% | 21% | 52.1 | 19.4 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | attacca | 100% | 0% | 0% | 7.9 | 7.1 | 0% | 4 |
| Madre in Lacrime | `madre_in_lacrime` | difendi | 0% | 0% | 100% | 61.0 | 0.1 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | studia | 99% | 1% | 0% | 11.2 | 10.8 | 0% | 4 |
| Madre in Lacrime | `madre_in_lacrime` | casuale | 67% | 33% | 0% | 22.4 | 15.8 | 0% | 3 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | attacca | 0% | 100% | 0% | 6.0 | 20.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | difendi | 0% | 100% | 0% | 6.0 | 20.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | studia | 0% | 100% | 0% | 6.0 | 20.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | casuale | 0% | 100% | 0% | 6.0 | 20.0 | 0% | 0 |
| Marionetta | `marionetta` | attacca | 23% | 77% | 0% | 7.3 | 18.4 | 0% | 0 |
| Marionetta | `marionetta` | difendi | 0% | 17% | 83% | 58.5 | 10.8 | 0% | 0 |
| Marionetta | `marionetta` | studia | 5% | 95% | 0% | 7.5 | 19.6 | 0% | 0 |
| Marionetta | `marionetta` | casuale | 1% | 99% | 0% | 8.2 | 19.8 | 0% | 0 |
| Fomentado | `maschera_vuota` | attacca | 100% | 0% | 0% | 2.0 | 0.5 | 0% | 3 |
| Fomentado | `maschera_vuota` | difendi | 100% | 0% | 0% | 10.0 | 0.0 | 0% | 3 |
| Fomentado | `maschera_vuota` | studia | 100% | 0% | 0% | 4.0 | 1.6 | 0% | 3 |
| Fomentado | `maschera_vuota` | casuale | 100% | 0% | 0% | 3.6 | 0.9 | 0% | 3 |
| Ombra del passato | `ombra_del_passato` | attacca | 11% | 89% | 0% | 5.7 | 18.9 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | difendi | 0% | 100% | 0% | 26.6 | 20.0 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | studia | 3% | 97% | 0% | 5.7 | 19.7 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | casuale | 1% | 99% | 0% | 6.8 | 19.9 | 0% | 0 |
| Emblema dell'oppressione | `operaio_posseduto` | attacca | 100% | 0% | 0% | 5.6 | 4.7 | 0% | 5 |
| Emblema dell'oppressione | `operaio_posseduto` | difendi | 0% | 0% | 100% | 61.0 | 0.1 | 0% | 0 |
| Emblema dell'oppressione | `operaio_posseduto` | studia | 100% | 0% | 0% | 8.7 | 7.9 | 0% | 5 |
| Emblema dell'oppressione | `operaio_posseduto` | casuale | 94% | 6% | 0% | 16.5 | 11.3 | 0% | 5 |
| Orrore di Meridia | `orrore_di_meridia` | attacca | 99% | 1% | 0% | 5.7 | 8.5 | 0% | 20 |
| Orrore di Meridia | `orrore_di_meridia` | difendi | 0% | 0% | 100% | 61.0 | 2.8 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | studia | 83% | 17% | 0% | 8.6 | 14.4 | 0% | 17 |
| Orrore di Meridia | `orrore_di_meridia` | casuale | 47% | 53% | 0% | 15.1 | 17.7 | 0% | 9 |
| Sacerdote Folle | `sacerdote_folle` | attacca | 13% | 87% | 0% | 10.4 | 18.8 | 0% | 1 |
| Sacerdote Folle | `sacerdote_folle` | difendi | 0% | 0% | 100% | 61.0 | 2.9 | 0% | 0 |
| Sacerdote Folle | `sacerdote_folle` | studia | 4% | 96% | 0% | 10.6 | 19.7 | 0% | 0 |
| Sacerdote Folle | `sacerdote_folle` | casuale | 2% | 98% | 0% | 14.5 | 19.8 | 0% | 0 |
| Sadico | `sadico` | attacca | 99% | 1% | 0% | 6.7 | 8.8 | 0% | 4 |
| Sadico | `sadico` | difendi | 0% | 0% | 100% | 61.0 | 3.1 | 0% | 0 |
| Sadico | `sadico` | studia | 85% | 15% | 0% | 9.7 | 13.9 | 0% | 3 |
| Sadico | `sadico` | casuale | 40% | 60% | 0% | 16.9 | 17.6 | 0% | 2 |
| Slime Infimo | `slime_infimo` | attacca | 100% | 0% | 0% | 1.8 | 0.4 | 0% | 1 |
| Slime Infimo | `slime_infimo` | difendi | 0% | 0% | 100% | 61.0 | 0.0 | 0% | 0 |
| Slime Infimo | `slime_infimo` | studia | 100% | 0% | 0% | 4.8 | 2.0 | 0% | 1 |
| Slime Infimo | `slime_infimo` | casuale | 100% | 0% | 0% | 5.8 | 1.7 | 0% | 1 |
| Stigma | `stigma` | attacca | 99% | 1% | 0% | 6.6 | 10.5 | 0% | 4 |
| Stigma | `stigma` | difendi | 0% | 0% | 100% | 61.0 | 4.5 | 0% | 0 |
| Stigma | `stigma` | studia | 79% | 21% | 0% | 9.5 | 14.8 | 0% | 3 |
| Stigma | `stigma` | casuale | 45% | 55% | 0% | 15.7 | 17.3 | 0% | 2 |
| Tartaruga Innocente | `tartaruga_innocente` | attacca | 91% | 0% | 9% | 27.8 | 0.0 | 0% | 5 |
| Tartaruga Innocente | `tartaruga_innocente` | difendi | 0% | 0% | 100% | 61.0 | 0.0 | 0% | 0 |
| Tartaruga Innocente | `tartaruga_innocente` | studia | 100% | 0% | 0% | 1.0 | 0.0 | 100% | 8 |
| Tartaruga Innocente | `tartaruga_innocente` | casuale | 100% | 0% | 0% | 3.0 | 0.0 | 99% | 8 |
| Un tenero ricordo | `tenero_ricordo` | attacca | 0% | 100% | 0% | 7.2 | 20.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | difendi | 0% | 100% | 0% | 9.6 | 20.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | studia | 0% | 100% | 0% | 7.0 | 20.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | casuale | 0% | 100% | 0% | 7.6 | 20.0 | 0% | 0 |
| Teschio Errante | `teschio_errante` | attacca | 100% | 0% | 0% | 5.7 | 5.9 | 0% | 3 |
| Teschio Errante | `teschio_errante` | difendi | 0% | 0% | 100% | 61.0 | 1.0 | 0% | 0 |
| Teschio Errante | `teschio_errante` | studia | 100% | 0% | 0% | 8.7 | 9.1 | 0% | 3 |
| Teschio Errante | `teschio_errante` | casuale | 91% | 9% | 0% | 16.6 | 12.0 | 0% | 3 |
| Titano Zombie | `titano_zombie` | attacca | 0% | 100% | 0% | 12.2 | 20.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | difendi | 0% | 100% | 0% | 18.1 | 20.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | studia | 0% | 100% | 0% | 11.2 | 20.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | casuale | 0% | 100% | 0% | 12.0 | 20.0 | 0% | 0 |
| Capocantiere | `voce_registrata` | attacca | 100% | 0% | 0% | 4.3 | 4.3 | 0% | 4 |
| Capocantiere | `voce_registrata` | difendi | 0% | 0% | 100% | 61.0 | 1.0 | 0% | 0 |
| Capocantiere | `voce_registrata` | studia | 100% | 0% | 0% | 7.4 | 7.6 | 0% | 4 |
| Capocantiere | `voce_registrata` | casuale | 97% | 3% | 0% | 13.0 | 9.3 | 0% | 4 |
| Zombie Cittadino | `zombie_cittadino` | attacca | 100% | 0% | 0% | 1.8 | 0.4 | 0% | 2 |
| Zombie Cittadino | `zombie_cittadino` | difendi | 0% | 0% | 100% | 61.0 | 0.0 | 0% | 0 |
| Zombie Cittadino | `zombie_cittadino` | studia | 100% | 0% | 0% | 4.8 | 2.0 | 0% | 2 |
| Zombie Cittadino | `zombie_cittadino` | casuale | 100% | 0% | 0% | 5.5 | 1.5 | 0% | 2 |
| Zombie Mostruoso | `zombie_mostruoso` | attacca | 100% | 0% | 0% | 3.4 | 2.5 | 0% | 8 |
| Zombie Mostruoso | `zombie_mostruoso` | difendi | 0% | 0% | 100% | 61.0 | 0.1 | 0% | 0 |
| Zombie Mostruoso | `zombie_mostruoso` | studia | 100% | 0% | 0% | 6.6 | 5.7 | 0% | 8 |
| Zombie Mostruoso | `zombie_mostruoso` | casuale | 97% | 3% | 0% | 10.8 | 7.4 | 0% | 8 |

## Protagonista di livello 8

| creatura | id | come si gioca | vinte | perse | ∞ | giri | danno | risp. | xp |
|---|---|---|--:|--:|--:|--:|--:|--:|--:|
| Abominio Marcio | `abominio_marcio` | attacca | 100% | 0% | 0% | 4.9 | 5.2 | 0% | 2 |
| Abominio Marcio | `abominio_marcio` | difendi | 0% | 0% | 100% | 61.0 | 2.6 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | studia | 99% | 1% | 0% | 7.9 | 9.0 | 0% | 2 |
| Abominio Marcio | `abominio_marcio` | casuale | 86% | 14% | 0% | 14.4 | 11.5 | 0% | 2 |
| Oppresso | `comparsa_di_ruggine` | attacca | 100% | 0% | 0% | 3.8 | 2.4 | 0% | 1 |
| Oppresso | `comparsa_di_ruggine` | difendi | 0% | 0% | 100% | 61.0 | 0.1 | 0% | 0 |
| Oppresso | `comparsa_di_ruggine` | studia | 100% | 0% | 0% | 6.8 | 5.0 | 0% | 1 |
| Oppresso | `comparsa_di_ruggine` | casuale | 100% | 0% | 0% | 11.6 | 6.0 | 0% | 1 |
| Diabolo | `diabolo` | attacca | 100% | 0% | 0% | 4.8 | 3.9 | 0% | 1 |
| Diabolo | `diabolo` | difendi | 0% | 0% | 100% | 61.0 | 0.8 | 0% | 0 |
| Diabolo | `diabolo` | studia | 100% | 0% | 0% | 7.8 | 6.5 | 0% | 1 |
| Diabolo | `diabolo` | casuale | 98% | 2% | 0% | 14.3 | 8.1 | 0% | 1 |
| Il Divoratore | `divoratore` | attacca | 100% | 0% | 0% | 6.6 | 7.4 | 0% | 2 |
| Il Divoratore | `divoratore` | difendi | 0% | 0% | 100% | 61.0 | 2.6 | 0% | 0 |
| Il Divoratore | `divoratore` | studia | 96% | 4% | 0% | 9.5 | 10.7 | 0% | 2 |
| Il Divoratore | `divoratore` | casuale | 71% | 29% | 0% | 18.1 | 14.8 | 0% | 1 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | attacca | 87% | 13% | 0% | 9.8 | 13.2 | 0% | 2 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | difendi | 0% | 0% | 100% | 61.0 | 2.0 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | studia | 61% | 39% | 0% | 11.8 | 16.1 | 0% | 1 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | casuale | 21% | 79% | 0% | 21.0 | 18.9 | 0% | 0 |
| Ferraglia Urlante | `ferraglia_urlante` | attacca | 100% | 0% | 0% | 4.8 | 3.3 | 0% | 2 |
| Ferraglia Urlante | `ferraglia_urlante` | difendi | 0% | 0% | 100% | 61.0 | 0.1 | 0% | 0 |
| Ferraglia Urlante | `ferraglia_urlante` | studia | 100% | 0% | 0% | 7.8 | 5.8 | 0% | 2 |
| Ferraglia Urlante | `ferraglia_urlante` | casuale | 97% | 3% | 0% | 14.7 | 7.6 | 0% | 2 |
| Ghoul | `ghoul` | attacca | 100% | 0% | 0% | 4.7 | 3.2 | 0% | 1 |
| Ghoul | `ghoul` | difendi | 0% | 0% | 100% | 61.0 | 0.1 | 0% | 0 |
| Ghoul | `ghoul` | studia | 100% | 0% | 0% | 7.8 | 5.7 | 0% | 1 |
| Ghoul | `ghoul` | casuale | 97% | 3% | 0% | 14.5 | 7.8 | 0% | 1 |
| El Muy Bonito | `giocoliere` | attacca | 100% | 0% | 0% | 2.0 | 1.9 | 0% | 2 |
| El Muy Bonito | `giocoliere` | difendi | 0% | 0% | 100% | 61.0 | 1.4 | 0% | 0 |
| El Muy Bonito | `giocoliere` | studia | 99% | 1% | 0% | 5.0 | 7.1 | 0% | 2 |
| El Muy Bonito | `giocoliere` | casuale | 95% | 5% | 0% | 5.7 | 5.5 | 0% | 2 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | attacca | 100% | 0% | 0% | 3.3 | 2.1 | 0% | 4 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | difendi | 0% | 0% | 100% | 61.0 | 1.3 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | studia | 99% | 1% | 0% | 8.4 | 6.6 | 0% | 5 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | casuale | 95% | 5% | 0% | 11.6 | 8.4 | 0% | 4 |
| Goblin Tipico | `goblin_tipico` | attacca | 100% | 0% | 0% | 1.0 | 0.0 | 0% | 1 |
| Goblin Tipico | `goblin_tipico` | difendi | 0% | 0% | 100% | 61.0 | 0.0 | 0% | 0 |
| Goblin Tipico | `goblin_tipico` | studia | 100% | 0% | 0% | 4.0 | 1.3 | 0% | 1 |
| Goblin Tipico | `goblin_tipico` | casuale | 100% | 0% | 0% | 3.2 | 0.5 | 0% | 1 |
| Infetto Rapido | `infetto_rapido` | attacca | 100% | 0% | 0% | 1.0 | 0.7 | 0% | 1 |
| Infetto Rapido | `infetto_rapido` | difendi | 0% | 0% | 100% | 61.0 | 0.8 | 0% | 0 |
| Infetto Rapido | `infetto_rapido` | studia | 100% | 0% | 0% | 4.0 | 3.4 | 0% | 1 |
| Infetto Rapido | `infetto_rapido` | casuale | 100% | 0% | 0% | 3.1 | 1.6 | 0% | 1 |
| L'ultimo spettacolo di Jerah | `jerah` | attacca | 100% | 0% | 0% | 4.1 | 4.3 | 0% | 5 |
| L'ultimo spettacolo di Jerah | `jerah` | difendi | 0% | 100% | 0% | 15.7 | 20.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | studia | 67% | 33% | 0% | 9.0 | 13.9 | 0% | 4 |
| L'ultimo spettacolo di Jerah | `jerah` | casuale | 44% | 56% | 0% | 10.7 | 15.6 | 0% | 2 |
| Jongo Dongo | `jongo_dongo` | attacca | 1% | 99% | 0% | 11.9 | 20.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | difendi | 0% | 13% | 87% | 59.1 | 10.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | studia | 0% | 100% | 0% | 12.1 | 20.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | casuale | 0% | 100% | 0% | 17.2 | 20.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | attacca | 1% | 99% | 0% | 7.2 | 20.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | difendi | 0% | 100% | 0% | 28.9 | 20.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | studia | 0% | 100% | 0% | 7.0 | 20.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | casuale | 0% | 100% | 0% | 9.1 | 20.0 | 0% | 0 |
| ??? | `l_immortale` | attacca | 0% | 99% | 1% | 44.3 | 20.0 | 0% | 0 |
| ??? | `l_immortale` | difendi | 0% | 0% | 100% | 61.0 | 0.0 | 0% | 0 |
| ??? | `l_immortale` | studia | 0% | 95% | 5% | 45.3 | 19.9 | 0% | 0 |
| ??? | `l_immortale` | casuale | 0% | 36% | 64% | 58.2 | 17.6 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | attacca | 100% | 0% | 0% | 4.7 | 3.2 | 0% | 1 |
| Madre in Lacrime | `madre_in_lacrime` | difendi | 0% | 0% | 100% | 61.0 | 0.1 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | studia | 100% | 0% | 0% | 7.8 | 5.7 | 0% | 1 |
| Madre in Lacrime | `madre_in_lacrime` | casuale | 97% | 3% | 0% | 14.5 | 7.9 | 0% | 1 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | attacca | 0% | 100% | 0% | 6.0 | 20.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | difendi | 0% | 100% | 0% | 6.0 | 20.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | studia | 0% | 100% | 0% | 6.0 | 20.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | casuale | 0% | 100% | 0% | 6.0 | 20.0 | 0% | 0 |
| Marionetta | `marionetta` | attacca | 89% | 11% | 0% | 5.9 | 12.0 | 0% | 1 |
| Marionetta | `marionetta` | difendi | 0% | 9% | 91% | 59.8 | 9.2 | 0% | 0 |
| Marionetta | `marionetta` | studia | 51% | 49% | 0% | 7.8 | 16.8 | 0% | 1 |
| Marionetta | `marionetta` | casuale | 13% | 87% | 0% | 10.2 | 19.1 | 0% | 0 |
| Fomentado | `maschera_vuota` | attacca | 100% | 0% | 0% | 1.0 | 0.0 | 0% | 1 |
| Fomentado | `maschera_vuota` | difendi | 100% | 0% | 0% | 10.0 | 0.0 | 0% | 1 |
| Fomentado | `maschera_vuota` | studia | 100% | 0% | 0% | 4.0 | 1.3 | 0% | 1 |
| Fomentado | `maschera_vuota` | casuale | 100% | 0% | 0% | 3.0 | 0.4 | 0% | 1 |
| Ombra del passato | `ombra_del_passato` | attacca | 63% | 37% | 0% | 5.5 | 13.9 | 0% | 1 |
| Ombra del passato | `ombra_del_passato` | difendi | 0% | 98% | 2% | 33.0 | 20.0 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | studia | 25% | 75% | 0% | 6.6 | 17.8 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | casuale | 7% | 93% | 0% | 8.5 | 19.4 | 0% | 0 |
| Emblema dell'oppressione | `operaio_posseduto` | attacca | 100% | 0% | 0% | 3.8 | 2.4 | 0% | 1 |
| Emblema dell'oppressione | `operaio_posseduto` | difendi | 0% | 0% | 100% | 61.0 | 0.1 | 0% | 0 |
| Emblema dell'oppressione | `operaio_posseduto` | studia | 100% | 0% | 0% | 6.8 | 5.0 | 0% | 1 |
| Emblema dell'oppressione | `operaio_posseduto` | casuale | 100% | 0% | 0% | 11.6 | 6.1 | 0% | 1 |
| Orrore di Meridia | `orrore_di_meridia` | attacca | 100% | 0% | 0% | 3.9 | 4.4 | 0% | 11 |
| Orrore di Meridia | `orrore_di_meridia` | difendi | 0% | 0% | 100% | 61.0 | 2.4 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | studia | 99% | 1% | 0% | 6.9 | 9.1 | 0% | 11 |
| Orrore di Meridia | `orrore_di_meridia` | casuale | 90% | 10% | 0% | 12.1 | 11.2 | 0% | 10 |
| Sacerdote Folle | `sacerdote_folle` | attacca | 51% | 49% | 0% | 9.9 | 14.7 | 0% | 1 |
| Sacerdote Folle | `sacerdote_folle` | difendi | 0% | 0% | 100% | 61.0 | 2.4 | 0% | 0 |
| Sacerdote Folle | `sacerdote_folle` | studia | 27% | 73% | 0% | 11.5 | 17.7 | 0% | 1 |
| Sacerdote Folle | `sacerdote_folle` | casuale | 5% | 95% | 0% | 16.8 | 19.5 | 0% | 0 |
| Sadico | `sadico` | attacca | 100% | 0% | 0% | 4.7 | 4.8 | 0% | 1 |
| Sadico | `sadico` | difendi | 0% | 0% | 100% | 61.0 | 2.6 | 0% | 0 |
| Sadico | `sadico` | studia | 99% | 1% | 0% | 7.8 | 8.6 | 0% | 1 |
| Sadico | `sadico` | casuale | 87% | 13% | 0% | 13.8 | 11.4 | 0% | 1 |
| Slime Infimo | `slime_infimo` | attacca | 100% | 0% | 0% | 1.0 | 0.0 | 0% | 1 |
| Slime Infimo | `slime_infimo` | difendi | 0% | 0% | 100% | 61.0 | 0.0 | 0% | 0 |
| Slime Infimo | `slime_infimo` | studia | 100% | 0% | 0% | 4.0 | 1.3 | 0% | 1 |
| Slime Infimo | `slime_infimo` | casuale | 100% | 0% | 0% | 3.2 | 0.5 | 0% | 1 |
| Stigma | `stigma` | attacca | 100% | 0% | 0% | 4.7 | 5.8 | 0% | 1 |
| Stigma | `stigma` | difendi | 0% | 0% | 100% | 61.0 | 3.6 | 0% | 0 |
| Stigma | `stigma` | studia | 99% | 1% | 0% | 7.7 | 9.7 | 0% | 1 |
| Stigma | `stigma` | casuale | 87% | 13% | 0% | 13.4 | 11.7 | 0% | 1 |
| Tartaruga Innocente | `tartaruga_innocente` | attacca | 100% | 0% | 0% | 4.1 | 0.0 | 0% | 2 |
| Tartaruga Innocente | `tartaruga_innocente` | difendi | 0% | 0% | 100% | 61.0 | 0.0 | 0% | 0 |
| Tartaruga Innocente | `tartaruga_innocente` | studia | 100% | 0% | 0% | 1.0 | 0.0 | 100% | 3 |
| Tartaruga Innocente | `tartaruga_innocente` | casuale | 100% | 0% | 0% | 3.0 | 0.0 | 97% | 3 |
| Un tenero ricordo | `tenero_ricordo` | attacca | 0% | 100% | 0% | 7.7 | 20.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | difendi | 0% | 100% | 0% | 9.6 | 20.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | studia | 0% | 100% | 0% | 7.5 | 20.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | casuale | 0% | 100% | 0% | 8.2 | 20.0 | 0% | 0 |
| Teschio Errante | `teschio_errante` | attacca | 100% | 0% | 0% | 3.9 | 3.2 | 0% | 1 |
| Teschio Errante | `teschio_errante` | difendi | 0% | 0% | 100% | 61.0 | 0.8 | 0% | 0 |
| Teschio Errante | `teschio_errante` | studia | 100% | 0% | 0% | 6.8 | 5.6 | 0% | 1 |
| Teschio Errante | `teschio_errante` | casuale | 99% | 1% | 0% | 11.5 | 6.6 | 0% | 1 |
| Titano Zombie | `titano_zombie` | attacca | 12% | 88% | 0% | 13.2 | 19.5 | 0% | 7 |
| Titano Zombie | `titano_zombie` | difendi | 0% | 100% | 0% | 18.2 | 20.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | studia | 4% | 96% | 0% | 12.5 | 19.8 | 0% | 2 |
| Titano Zombie | `titano_zombie` | casuale | 0% | 100% | 0% | 12.7 | 20.0 | 0% | 0 |
| Capocantiere | `voce_registrata` | attacca | 100% | 0% | 0% | 3.0 | 2.4 | 0% | 1 |
| Capocantiere | `voce_registrata` | difendi | 0% | 0% | 100% | 61.0 | 0.8 | 0% | 0 |
| Capocantiere | `voce_registrata` | studia | 100% | 0% | 0% | 6.0 | 4.9 | 0% | 1 |
| Capocantiere | `voce_registrata` | casuale | 99% | 1% | 0% | 9.2 | 5.2 | 0% | 1 |
| Zombie Cittadino | `zombie_cittadino` | attacca | 100% | 0% | 0% | 1.0 | 0.0 | 0% | 1 |
| Zombie Cittadino | `zombie_cittadino` | difendi | 0% | 0% | 100% | 61.0 | 0.0 | 0% | 0 |
| Zombie Cittadino | `zombie_cittadino` | studia | 100% | 0% | 0% | 4.0 | 1.3 | 0% | 1 |
| Zombie Cittadino | `zombie_cittadino` | casuale | 100% | 0% | 0% | 3.0 | 0.4 | 0% | 1 |
| Zombie Mostruoso | `zombie_mostruoso` | attacca | 100% | 0% | 0% | 2.8 | 1.5 | 0% | 3 |
| Zombie Mostruoso | `zombie_mostruoso` | difendi | 0% | 0% | 100% | 61.0 | 0.1 | 0% | 0 |
| Zombie Mostruoso | `zombie_mostruoso` | studia | 100% | 0% | 0% | 5.9 | 4.1 | 0% | 3 |
| Zombie Mostruoso | `zombie_mostruoso` | casuale | 100% | 0% | 0% | 9.0 | 4.6 | 0% | 3 |

