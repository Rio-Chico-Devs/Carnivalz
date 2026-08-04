# Bilanciamento (generato, non scrivere qui a mano)

Prodotto da `prove/Simulatore.gd`: **99000 partite** giocate dal motore vero in 554 secondi.

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
- **danno** — punti vita persi in media dal protagonista (ne ha 425)
- **risp.** — percentuale di partite in cui la creatura e' stata risparmiata

## A che livello ogni scontro diventa giusto

Livello minimo a cui si vince almeno l'80% delle volte andandoci dritto.

| creatura | id | hp | att | livello |
|---|---|--:|--:|--:|
| Abominio Marcio | `abominio_marcio` | 400 | 14 | 5 |
| Oppresso | `comparsa_di_ruggine` | 270 | 9 | 2 |
| Diabolo | `diabolo` | 330 | 9 | 3 |
| Il Divoratore | `divoratore` | 450 | 14 | 5 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | 750 | 14 | 5 |
| Ferraglia Urlante | `ferraglia_urlante` | 350 | 9 | 3 |
| Ghoul | `ghoul` | 350 | 9 | 3 |
| El Muy Bonito | `giocoliere` | 180 | 9 | 2 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | 700 | 14 | 5 |
| Goblin Tipico | `goblin_tipico` | 60 | 5 | 1 |
| Infetto Rapido | `infetto_rapido` | 70 | 9 | 1 |
| L'ultimo spettacolo di Jerah | `jerah` | 2200 | 27 | **mai** |
| Jongo Dongo | `jongo_dongo` | 1400 | 27 | 8 |
| Jongo Dongo | `jongo_dongo_risorto` | 1400 | 32 | **mai** |
| ??? | `l_immortale` | 120 | 5 | **mai** |
| Madre in Lacrime | `madre_in_lacrime` | 350 | 9 | 3 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | 320 | 23 | **mai** |
| Marionetta | `marionetta` | 380 | 27 | 5 |
| Fomentado | `maschera_vuota` | 100 | 5 | 1 |
| Ombra del passato | `ombra_del_passato` | 390 | 32 | 8 |
| Emblema dell'oppressione | `operaio_posseduto` | 290 | 9 | 2 |
| Orrore di Meridia | `orrore_di_meridia` | 340 | 14 | 3 |
| Sacerdote Folle | `sacerdote_folle` | 560 | 14 | 8 |
| Sadico | `sadico` | 360 | 14 | 3 |
| Slime Infimo | `slime_infimo` | 80 | 5 | 1 |
| Stigma | `stigma` | 340 | 14 | 3 |
| Tartaruga Innocente | `tartaruga_innocente` | 299 | 0 | 2 |
| Un tenero ricordo | `tenero_ricordo` | 6660 | 27 | **mai** |
| Teschio Errante | `teschio_errante` | 290 | 9 | 3 |
| Titano Zombie | `titano_zombie` | 900 | 18 | **mai** |
| Capocantiere | `voce_registrata` | 250 | 9 | 2 |
| Zombie Cittadino | `zombie_cittadino` | 80 | 5 | 1 |
| Zombie Mostruoso | `zombie_mostruoso` | 220 | 9 | 2 |

## Protagonista di livello 1

| creatura | id | come si gioca | vinte | perse | ∞ | giri | danno | risp. | xp |
|---|---|---|--:|--:|--:|--:|--:|--:|--:|
| Abominio Marcio | `abominio_marcio` | attacca | 0% | 100% | 0% | 8.0 | 100.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | difendi | 0% | 100% | 0% | 22.9 | 100.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | studia | 0% | 100% | 0% | 8.0 | 100.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | casuale | 0% | 100% | 0% | 10.0 | 100.0 | 0% | 0 |
| Oppresso | `comparsa_di_ruggine` | attacca | 11% | 89% | 0% | 11.2 | 96.8 | 0% | 1 |
| Oppresso | `comparsa_di_ruggine` | difendi | 0% | 100% | 0% | 32.4 | 100.0 | 0% | 0 |
| Oppresso | `comparsa_di_ruggine` | studia | 7% | 93% | 0% | 11.2 | 96.9 | 0% | 1 |
| Oppresso | `comparsa_di_ruggine` | casuale | 3% | 97% | 0% | 14.4 | 99.0 | 0% | 0 |
| Diabolo | `diabolo` | attacca | 12% | 88% | 0% | 10.8 | 93.4 | 0% | 1 |
| Diabolo | `diabolo` | difendi | 0% | 100% | 0% | 30.5 | 100.0 | 0% | 0 |
| Diabolo | `diabolo` | studia | 3% | 97% | 0% | 11.5 | 99.3 | 0% | 0 |
| Diabolo | `diabolo` | casuale | 1% | 99% | 0% | 14.1 | 99.4 | 0% | 0 |
| Il Divoratore | `divoratore` | attacca | 0% | 100% | 0% | 8.0 | 100.0 | 0% | 0 |
| Il Divoratore | `divoratore` | difendi | 0% | 100% | 0% | 22.9 | 100.0 | 0% | 0 |
| Il Divoratore | `divoratore` | studia | 0% | 100% | 0% | 8.0 | 100.0 | 0% | 0 |
| Il Divoratore | `divoratore` | casuale | 0% | 100% | 0% | 10.0 | 100.0 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | attacca | 6% | 94% | 0% | 7.0 | 97.5 | 0% | 1 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | difendi | 0% | 100% | 0% | 20.2 | 100.0 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | studia | 1% | 99% | 0% | 7.1 | 99.8 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | casuale | 1% | 99% | 0% | 9.0 | 99.0 | 0% | 0 |
| Ferraglia Urlante | `ferraglia_urlante` | attacca | 0% | 100% | 0% | 11.6 | 100.0 | 0% | 0 |
| Ferraglia Urlante | `ferraglia_urlante` | difendi | 0% | 100% | 0% | 32.4 | 100.0 | 0% | 0 |
| Ferraglia Urlante | `ferraglia_urlante` | studia | 0% | 100% | 0% | 11.6 | 100.0 | 0% | 0 |
| Ferraglia Urlante | `ferraglia_urlante` | casuale | 0% | 100% | 0% | 14.4 | 100.0 | 0% | 0 |
| Ghoul | `ghoul` | attacca | 11% | 89% | 0% | 11.2 | 96.8 | 0% | 1 |
| Ghoul | `ghoul` | difendi | 0% | 100% | 0% | 32.4 | 100.0 | 0% | 0 |
| Ghoul | `ghoul` | studia | 7% | 93% | 0% | 11.3 | 97.8 | 0% | 1 |
| Ghoul | `ghoul` | casuale | 2% | 98% | 0% | 14.4 | 98.9 | 0% | 0 |
| El Muy Bonito | `giocoliere` | attacca | 1% | 99% | 0% | 11.0 | 100.0 | 0% | 0 |
| El Muy Bonito | `giocoliere` | difendi | 0% | 100% | 0% | 30.3 | 100.0 | 0% | 0 |
| El Muy Bonito | `giocoliere` | studia | 0% | 100% | 0% | 6.0 | 100.0 | 0% | 0 |
| El Muy Bonito | `giocoliere` | casuale | 0% | 100% | 0% | 9.7 | 100.0 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | attacca | 0% | 100% | 0% | 8.9 | 100.0 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | difendi | 0% | 100% | 0% | 20.3 | 100.0 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | studia | 0% | 100% | 0% | 8.8 | 100.0 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | casuale | 0% | 100% | 0% | 10.7 | 100.0 | 0% | 0 |
| Goblin Tipico | `goblin_tipico` | attacca | 100% | 0% | 0% | 3.9 | 15.2 | 0% | 2 |
| Goblin Tipico | `goblin_tipico` | difendi | 0% | 100% | 0% | 49.9 | 100.0 | 0% | 0 |
| Goblin Tipico | `goblin_tipico` | studia | 100% | 0% | 0% | 7.0 | 30.8 | 0% | 2 |
| Goblin Tipico | `goblin_tipico` | casuale | 100% | 0% | 0% | 12.7 | 46.4 | 0% | 2 |
| Infetto Rapido | `infetto_rapido` | attacca | 100% | 0% | 0% | 4.8 | 44.1 | 0% | 7 |
| Infetto Rapido | `infetto_rapido` | difendi | 0% | 100% | 0% | 30.5 | 100.0 | 0% | 0 |
| Infetto Rapido | `infetto_rapido` | studia | 100% | 0% | 0% | 7.9 | 73.3 | 0% | 7 |
| Infetto Rapido | `infetto_rapido` | casuale | 48% | 52% | 0% | 12.7 | 90.7 | 0% | 3 |
| L'ultimo spettacolo di Jerah | `jerah` | attacca | 0% | 100% | 0% | 6.5 | 100.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | difendi | 0% | 100% | 0% | 10.4 | 100.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | studia | 0% | 100% | 0% | 6.6 | 100.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | casuale | 0% | 100% | 0% | 7.1 | 100.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | attacca | 0% | 100% | 0% | 8.6 | 100.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | difendi | 0% | 100% | 0% | 19.4 | 100.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | studia | 0% | 100% | 0% | 8.4 | 100.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | casuale | 0% | 100% | 0% | 10.0 | 100.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | attacca | 0% | 100% | 0% | 3.8 | 100.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | difendi | 0% | 100% | 0% | 6.4 | 100.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | studia | 0% | 100% | 0% | 3.9 | 100.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | casuale | 0% | 100% | 0% | 4.1 | 100.0 | 0% | 0 |
| ??? | `l_immortale` | attacca | 0% | 100% | 0% | 19.7 | 100.0 | 0% | 0 |
| ??? | `l_immortale` | difendi | 0% | 100% | 0% | 49.9 | 100.0 | 0% | 0 |
| ??? | `l_immortale` | studia | 0% | 100% | 0% | 19.7 | 100.0 | 0% | 0 |
| ??? | `l_immortale` | casuale | 0% | 100% | 0% | 24.7 | 100.0 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | attacca | 11% | 89% | 0% | 11.2 | 96.8 | 0% | 1 |
| Madre in Lacrime | `madre_in_lacrime` | difendi | 0% | 100% | 0% | 32.4 | 100.0 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | studia | 7% | 93% | 0% | 11.3 | 97.8 | 0% | 1 |
| Madre in Lacrime | `madre_in_lacrime` | casuale | 2% | 98% | 0% | 14.4 | 98.9 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | attacca | 0% | 100% | 0% | 6.0 | 100.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | difendi | 0% | 100% | 0% | 6.0 | 100.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | studia | 0% | 100% | 0% | 6.0 | 100.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | casuale | 0% | 100% | 0% | 6.0 | 100.0 | 0% | 0 |
| Marionetta | `marionetta` | attacca | 3% | 97% | 0% | 3.9 | 98.1 | 0% | 0 |
| Marionetta | `marionetta` | difendi | 0% | 100% | 0% | 9.1 | 100.0 | 0% | 0 |
| Marionetta | `marionetta` | studia | 1% | 99% | 0% | 4.0 | 99.9 | 0% | 0 |
| Marionetta | `marionetta` | casuale | 0% | 100% | 0% | 4.9 | 100.0 | 0% | 0 |
| Fomentado | `maschera_vuota` | attacca | 100% | 0% | 0% | 4.9 | 20.2 | 0% | 8 |
| Fomentado | `maschera_vuota` | difendi | 100% | 0% | 0% | 20.0 | 38.1 | 0% | 8 |
| Fomentado | `maschera_vuota` | studia | 100% | 0% | 0% | 7.7 | 34.6 | 0% | 8 |
| Fomentado | `maschera_vuota` | casuale | 100% | 0% | 0% | 10.6 | 38.7 | 0% | 8 |
| Ombra del passato | `ombra_del_passato` | attacca | 2% | 98% | 0% | 3.8 | 98.2 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | difendi | 0% | 100% | 0% | 6.5 | 100.0 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | studia | 1% | 99% | 0% | 3.8 | 100.0 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | casuale | 0% | 100% | 0% | 4.1 | 100.0 | 0% | 0 |
| Emblema dell'oppressione | `operaio_posseduto` | attacca | 11% | 89% | 0% | 11.2 | 96.8 | 0% | 1 |
| Emblema dell'oppressione | `operaio_posseduto` | difendi | 0% | 100% | 0% | 32.4 | 100.0 | 0% | 0 |
| Emblema dell'oppressione | `operaio_posseduto` | studia | 7% | 93% | 0% | 11.2 | 96.9 | 0% | 1 |
| Emblema dell'oppressione | `operaio_posseduto` | casuale | 3% | 97% | 0% | 14.4 | 99.0 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | attacca | 0% | 100% | 0% | 6.9 | 100.0 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | difendi | 0% | 100% | 0% | 19.6 | 100.0 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | studia | 0% | 100% | 0% | 6.9 | 100.0 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | casuale | 0% | 100% | 0% | 8.5 | 100.0 | 0% | 0 |
| Sacerdote Folle | `sacerdote_folle` | attacca | 5% | 95% | 0% | 7.2 | 97.3 | 0% | 1 |
| Sacerdote Folle | `sacerdote_folle` | difendi | 0% | 100% | 0% | 16.4 | 100.0 | 0% | 0 |
| Sacerdote Folle | `sacerdote_folle` | studia | 1% | 99% | 0% | 7.2 | 99.4 | 0% | 0 |
| Sacerdote Folle | `sacerdote_folle` | casuale | 1% | 99% | 0% | 8.9 | 99.4 | 0% | 0 |
| Sadico | `sadico` | attacca | 3% | 97% | 0% | 7.8 | 97.7 | 0% | 0 |
| Sadico | `sadico` | difendi | 0% | 100% | 0% | 22.9 | 100.0 | 0% | 0 |
| Sadico | `sadico` | studia | 3% | 97% | 0% | 7.9 | 99.0 | 0% | 0 |
| Sadico | `sadico` | casuale | 2% | 98% | 0% | 10.0 | 99.3 | 0% | 0 |
| Slime Infimo | `slime_infimo` | attacca | 100% | 0% | 0% | 5.7 | 24.5 | 0% | 2 |
| Slime Infimo | `slime_infimo` | difendi | 0% | 100% | 0% | 49.9 | 100.0 | 0% | 0 |
| Slime Infimo | `slime_infimo` | studia | 100% | 0% | 0% | 8.8 | 40.1 | 0% | 2 |
| Slime Infimo | `slime_infimo` | casuale | 90% | 10% | 0% | 17.3 | 65.9 | 0% | 2 |
| Stigma | `stigma` | attacca | 9% | 91% | 0% | 7.6 | 95.2 | 0% | 1 |
| Stigma | `stigma` | difendi | 0% | 100% | 0% | 21.1 | 100.0 | 0% | 0 |
| Stigma | `stigma` | studia | 1% | 99% | 0% | 7.9 | 99.9 | 0% | 0 |
| Stigma | `stigma` | casuale | 1% | 99% | 0% | 9.6 | 99.5 | 0% | 0 |
| Tartaruga Innocente | `tartaruga_innocente` | attacca | 49% | 0% | 51% | 46.3 | 0.0 | 0% | 7 |
| Tartaruga Innocente | `tartaruga_innocente` | difendi | 0% | 0% | 100% | 61.0 | 0.0 | 0% | 0 |
| Tartaruga Innocente | `tartaruga_innocente` | studia | 100% | 0% | 0% | 1.0 | 0.0 | 100% | 19 |
| Tartaruga Innocente | `tartaruga_innocente` | casuale | 100% | 0% | 0% | 3.0 | 0.0 | 99% | 19 |
| Un tenero ricordo | `tenero_ricordo` | attacca | 0% | 100% | 0% | 5.6 | 100.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | difendi | 0% | 100% | 0% | 8.0 | 100.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | studia | 0% | 100% | 0% | 5.9 | 100.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | casuale | 0% | 100% | 0% | 6.0 | 100.0 | 0% | 0 |
| Teschio Errante | `teschio_errante` | attacca | 12% | 88% | 0% | 10.8 | 93.4 | 0% | 1 |
| Teschio Errante | `teschio_errante` | difendi | 0% | 100% | 0% | 30.5 | 100.0 | 0% | 0 |
| Teschio Errante | `teschio_errante` | studia | 3% | 97% | 0% | 11.5 | 99.3 | 0% | 0 |
| Teschio Errante | `teschio_errante` | casuale | 1% | 99% | 0% | 14.1 | 99.4 | 0% | 0 |
| Titano Zombie | `titano_zombie` | attacca | 0% | 100% | 0% | 9.1 | 100.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | difendi | 0% | 100% | 0% | 9.3 | 100.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | studia | 0% | 100% | 0% | 6.7 | 100.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | casuale | 0% | 100% | 0% | 7.2 | 100.0 | 0% | 0 |
| Capocantiere | `voce_registrata` | attacca | 12% | 88% | 0% | 10.8 | 93.4 | 0% | 1 |
| Capocantiere | `voce_registrata` | difendi | 0% | 100% | 0% | 30.5 | 100.0 | 0% | 0 |
| Capocantiere | `voce_registrata` | studia | 3% | 97% | 0% | 11.5 | 99.3 | 0% | 0 |
| Capocantiere | `voce_registrata` | casuale | 1% | 99% | 0% | 14.1 | 99.4 | 0% | 0 |
| Zombie Cittadino | `zombie_cittadino` | attacca | 100% | 0% | 0% | 5.7 | 24.5 | 0% | 6 |
| Zombie Cittadino | `zombie_cittadino` | difendi | 0% | 100% | 0% | 49.9 | 100.0 | 0% | 0 |
| Zombie Cittadino | `zombie_cittadino` | studia | 100% | 0% | 0% | 8.6 | 39.2 | 0% | 6 |
| Zombie Cittadino | `zombie_cittadino` | casuale | 91% | 9% | 0% | 17.6 | 67.4 | 0% | 5 |
| Zombie Mostruoso | `zombie_mostruoso` | attacca | 11% | 89% | 0% | 11.2 | 96.8 | 0% | 1 |
| Zombie Mostruoso | `zombie_mostruoso` | difendi | 0% | 100% | 0% | 32.4 | 100.0 | 0% | 0 |
| Zombie Mostruoso | `zombie_mostruoso` | studia | 7% | 93% | 0% | 11.3 | 97.8 | 0% | 1 |
| Zombie Mostruoso | `zombie_mostruoso` | casuale | 2% | 98% | 0% | 14.4 | 98.9 | 0% | 0 |

## Protagonista di livello 2

| creatura | id | come si gioca | vinte | perse | ∞ | giri | danno | risp. | xp |
|---|---|---|--:|--:|--:|--:|--:|--:|--:|
| Abominio Marcio | `abominio_marcio` | attacca | 0% | 100% | 0% | 12.5 | 145.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | difendi | 0% | 100% | 0% | 33.7 | 145.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | studia | 0% | 100% | 0% | 12.5 | 145.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | casuale | 0% | 100% | 0% | 15.6 | 145.0 | 0% | 0 |
| Oppresso | `comparsa_di_ruggine` | attacca | 100% | 0% | 0% | 15.4 | 118.6 | 0% | 10 |
| Oppresso | `comparsa_di_ruggine` | difendi | 0% | 100% | 0% | 46.9 | 145.0 | 0% | 0 |
| Oppresso | `comparsa_di_ruggine` | studia | 44% | 56% | 0% | 17.3 | 136.8 | 0% | 4 |
| Oppresso | `comparsa_di_ruggine` | casuale | 6% | 94% | 0% | 22.2 | 142.1 | 0% | 1 |
| Diabolo | `diabolo` | attacca | 24% | 76% | 0% | 16.3 | 131.0 | 0% | 2 |
| Diabolo | `diabolo` | difendi | 0% | 100% | 0% | 45.3 | 145.0 | 0% | 0 |
| Diabolo | `diabolo` | studia | 9% | 91% | 0% | 17.7 | 141.6 | 0% | 1 |
| Diabolo | `diabolo` | casuale | 7% | 93% | 0% | 22.1 | 142.7 | 0% | 1 |
| Il Divoratore | `divoratore` | attacca | 0% | 100% | 0% | 12.5 | 145.0 | 0% | 0 |
| Il Divoratore | `divoratore` | difendi | 0% | 100% | 0% | 33.7 | 145.0 | 0% | 0 |
| Il Divoratore | `divoratore` | studia | 0% | 100% | 0% | 12.5 | 145.0 | 0% | 0 |
| Il Divoratore | `divoratore` | casuale | 0% | 100% | 0% | 15.6 | 145.0 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | attacca | 9% | 91% | 0% | 10.8 | 139.1 | 0% | 2 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | difendi | 0% | 100% | 0% | 29.5 | 145.0 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | studia | 6% | 94% | 0% | 11.0 | 142.5 | 0% | 1 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | casuale | 3% | 97% | 0% | 13.9 | 143.0 | 0% | 0 |
| Ferraglia Urlante | `ferraglia_urlante` | attacca | 0% | 100% | 0% | 18.1 | 145.0 | 0% | 0 |
| Ferraglia Urlante | `ferraglia_urlante` | difendi | 0% | 100% | 0% | 46.9 | 145.0 | 0% | 0 |
| Ferraglia Urlante | `ferraglia_urlante` | studia | 0% | 100% | 0% | 18.1 | 145.0 | 0% | 0 |
| Ferraglia Urlante | `ferraglia_urlante` | casuale | 0% | 100% | 0% | 22.6 | 145.0 | 0% | 0 |
| Ghoul | `ghoul` | attacca | 19% | 81% | 0% | 16.9 | 133.8 | 0% | 2 |
| Ghoul | `ghoul` | difendi | 0% | 100% | 0% | 46.9 | 145.0 | 0% | 0 |
| Ghoul | `ghoul` | studia | 14% | 86% | 0% | 17.3 | 137.5 | 0% | 1 |
| Ghoul | `ghoul` | casuale | 8% | 92% | 0% | 22.3 | 141.6 | 0% | 1 |
| El Muy Bonito | `giocoliere` | attacca | 100% | 0% | 0% | 8.6 | 71.6 | 0% | 18 |
| El Muy Bonito | `giocoliere` | difendi | 0% | 100% | 0% | 45.1 | 145.0 | 0% | 0 |
| El Muy Bonito | `giocoliere` | studia | 0% | 100% | 0% | 8.0 | 145.0 | 0% | 0 |
| El Muy Bonito | `giocoliere` | casuale | 6% | 94% | 0% | 11.6 | 142.7 | 0% | 1 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | attacca | 0% | 100% | 0% | 13.1 | 145.0 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | difendi | 0% | 100% | 0% | 28.4 | 145.0 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | studia | 0% | 100% | 0% | 13.0 | 145.0 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | casuale | 0% | 100% | 0% | 15.9 | 145.0 | 0% | 0 |
| Goblin Tipico | `goblin_tipico` | attacca | 100% | 0% | 0% | 3.0 | 8.2 | 0% | 2 |
| Goblin Tipico | `goblin_tipico` | difendi | 0% | 0% | 100% | 61.0 | 120.1 | 0% | 0 |
| Goblin Tipico | `goblin_tipico` | studia | 100% | 0% | 0% | 6.0 | 20.9 | 0% | 2 |
| Goblin Tipico | `goblin_tipico` | casuale | 100% | 0% | 0% | 9.6 | 28.9 | 0% | 2 |
| Infetto Rapido | `infetto_rapido` | attacca | 100% | 0% | 0% | 3.8 | 31.0 | 0% | 7 |
| Infetto Rapido | `infetto_rapido` | difendi | 0% | 100% | 0% | 45.3 | 145.0 | 0% | 0 |
| Infetto Rapido | `infetto_rapido` | studia | 100% | 0% | 0% | 6.9 | 56.7 | 0% | 7 |
| Infetto Rapido | `infetto_rapido` | casuale | 99% | 1% | 0% | 11.1 | 72.8 | 0% | 7 |
| L'ultimo spettacolo di Jerah | `jerah` | attacca | 0% | 100% | 0% | 8.9 | 145.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | difendi | 0% | 100% | 0% | 14.3 | 145.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | studia | 0% | 100% | 0% | 9.7 | 145.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | casuale | 0% | 100% | 0% | 10.3 | 145.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | attacca | 0% | 100% | 0% | 12.4 | 145.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | difendi | 0% | 100% | 0% | 28.1 | 145.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | studia | 0% | 100% | 0% | 11.9 | 145.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | casuale | 0% | 100% | 0% | 14.2 | 145.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | attacca | 0% | 100% | 0% | 5.0 | 145.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | difendi | 0% | 100% | 0% | 10.1 | 145.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | studia | 0% | 100% | 0% | 5.0 | 145.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | casuale | 0% | 100% | 0% | 6.0 | 145.0 | 0% | 0 |
| ??? | `l_immortale` | attacca | 0% | 100% | 0% | 35.1 | 145.0 | 0% | 0 |
| ??? | `l_immortale` | difendi | 0% | 0% | 100% | 61.0 | 120.1 | 0% | 0 |
| ??? | `l_immortale` | studia | 0% | 100% | 0% | 35.1 | 145.0 | 0% | 0 |
| ??? | `l_immortale` | casuale | 0% | 100% | 0% | 42.4 | 145.0 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | attacca | 17% | 83% | 0% | 16.9 | 133.9 | 0% | 2 |
| Madre in Lacrime | `madre_in_lacrime` | difendi | 0% | 100% | 0% | 46.9 | 145.0 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | studia | 14% | 86% | 0% | 17.3 | 137.5 | 0% | 1 |
| Madre in Lacrime | `madre_in_lacrime` | casuale | 8% | 92% | 0% | 22.3 | 141.6 | 0% | 1 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | attacca | 0% | 100% | 0% | 6.0 | 145.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | difendi | 0% | 100% | 0% | 6.0 | 145.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | studia | 0% | 100% | 0% | 6.0 | 145.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | casuale | 0% | 100% | 0% | 6.0 | 145.0 | 0% | 0 |
| Marionetta | `marionetta` | attacca | 3% | 97% | 0% | 5.9 | 141.9 | 0% | 0 |
| Marionetta | `marionetta` | difendi | 0% | 100% | 0% | 15.2 | 145.0 | 0% | 0 |
| Marionetta | `marionetta` | studia | 3% | 97% | 0% | 6.0 | 143.9 | 0% | 0 |
| Marionetta | `marionetta` | casuale | 1% | 99% | 0% | 7.1 | 144.8 | 0% | 0 |
| Fomentado | `maschera_vuota` | attacca | 100% | 0% | 0% | 3.9 | 12.4 | 0% | 8 |
| Fomentado | `maschera_vuota` | difendi | 100% | 0% | 0% | 20.0 | 38.1 | 0% | 8 |
| Fomentado | `maschera_vuota` | studia | 100% | 0% | 0% | 6.8 | 24.3 | 0% | 8 |
| Fomentado | `maschera_vuota` | casuale | 100% | 0% | 0% | 9.2 | 27.9 | 0% | 8 |
| Ombra del passato | `ombra_del_passato` | attacca | 3% | 97% | 0% | 4.9 | 142.0 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | difendi | 0% | 100% | 0% | 10.1 | 145.0 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | studia | 1% | 99% | 0% | 5.0 | 144.4 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | casuale | 0% | 100% | 0% | 5.9 | 145.0 | 0% | 0 |
| Emblema dell'oppressione | `operaio_posseduto` | attacca | 85% | 15% | 0% | 16.3 | 126.8 | 0% | 10 |
| Emblema dell'oppressione | `operaio_posseduto` | difendi | 0% | 100% | 0% | 46.9 | 145.0 | 0% | 0 |
| Emblema dell'oppressione | `operaio_posseduto` | studia | 16% | 84% | 0% | 17.4 | 137.7 | 0% | 2 |
| Emblema dell'oppressione | `operaio_posseduto` | casuale | 6% | 94% | 0% | 22.2 | 142.1 | 0% | 1 |
| Orrore di Meridia | `orrore_di_meridia` | attacca | 0% | 100% | 0% | 10.6 | 145.0 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | difendi | 0% | 100% | 0% | 28.7 | 145.0 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | studia | 0% | 100% | 0% | 10.5 | 145.0 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | casuale | 0% | 100% | 0% | 13.1 | 145.0 | 0% | 0 |
| Sacerdote Folle | `sacerdote_folle` | attacca | 5% | 95% | 0% | 10.2 | 140.0 | 0% | 1 |
| Sacerdote Folle | `sacerdote_folle` | difendi | 0% | 100% | 0% | 21.6 | 145.0 | 0% | 0 |
| Sacerdote Folle | `sacerdote_folle` | studia | 1% | 99% | 0% | 10.3 | 143.7 | 0% | 0 |
| Sacerdote Folle | `sacerdote_folle` | casuale | 1% | 99% | 0% | 12.5 | 144.1 | 0% | 0 |
| Sadico | `sadico` | attacca | 13% | 87% | 0% | 12.0 | 139.4 | 0% | 1 |
| Sadico | `sadico` | difendi | 0% | 100% | 0% | 33.7 | 145.0 | 0% | 0 |
| Sadico | `sadico` | studia | 8% | 92% | 0% | 12.1 | 141.4 | 0% | 1 |
| Sadico | `sadico` | casuale | 3% | 97% | 0% | 15.6 | 143.3 | 0% | 0 |
| Slime Infimo | `slime_infimo` | attacca | 100% | 0% | 0% | 3.9 | 12.4 | 0% | 2 |
| Slime Infimo | `slime_infimo` | difendi | 0% | 0% | 100% | 61.0 | 120.1 | 0% | 0 |
| Slime Infimo | `slime_infimo` | studia | 100% | 0% | 0% | 7.0 | 25.1 | 0% | 2 |
| Slime Infimo | `slime_infimo` | casuale | 100% | 0% | 0% | 12.7 | 39.4 | 0% | 2 |
| Stigma | `stigma` | attacca | 13% | 87% | 0% | 11.5 | 134.8 | 0% | 1 |
| Stigma | `stigma` | difendi | 0% | 100% | 0% | 31.8 | 145.0 | 0% | 0 |
| Stigma | `stigma` | studia | 3% | 97% | 0% | 12.4 | 143.7 | 0% | 0 |
| Stigma | `stigma` | casuale | 2% | 98% | 0% | 15.2 | 144.1 | 0% | 0 |
| Tartaruga Innocente | `tartaruga_innocente` | attacca | 100% | 0% | 0% | 35.9 | 0.0 | 0% | 13 |
| Tartaruga Innocente | `tartaruga_innocente` | difendi | 0% | 0% | 100% | 61.0 | 0.0 | 0% | 0 |
| Tartaruga Innocente | `tartaruga_innocente` | studia | 100% | 0% | 0% | 1.0 | 0.0 | 100% | 16 |
| Tartaruga Innocente | `tartaruga_innocente` | casuale | 100% | 0% | 0% | 3.0 | 0.0 | 99% | 16 |
| Un tenero ricordo | `tenero_ricordo` | attacca | 0% | 100% | 0% | 6.9 | 145.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | difendi | 0% | 100% | 0% | 8.9 | 145.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | studia | 0% | 100% | 0% | 7.1 | 145.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | casuale | 0% | 100% | 0% | 7.2 | 145.0 | 0% | 0 |
| Teschio Errante | `teschio_errante` | attacca | 56% | 44% | 0% | 15.8 | 129.4 | 0% | 4 |
| Teschio Errante | `teschio_errante` | difendi | 0% | 100% | 0% | 45.3 | 145.0 | 0% | 0 |
| Teschio Errante | `teschio_errante` | studia | 9% | 91% | 0% | 17.7 | 141.6 | 0% | 1 |
| Teschio Errante | `teschio_errante` | casuale | 7% | 93% | 0% | 22.1 | 142.7 | 0% | 1 |
| Titano Zombie | `titano_zombie` | attacca | 0% | 100% | 0% | 11.4 | 145.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | difendi | 0% | 100% | 0% | 12.2 | 145.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | studia | 0% | 100% | 0% | 10.6 | 145.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | casuale | 0% | 100% | 0% | 9.8 | 145.0 | 0% | 0 |
| Capocantiere | `voce_registrata` | attacca | 100% | 0% | 0% | 12.2 | 101.1 | 0% | 9 |
| Capocantiere | `voce_registrata` | difendi | 0% | 100% | 0% | 45.3 | 145.0 | 0% | 0 |
| Capocantiere | `voce_registrata` | studia | 93% | 7% | 0% | 15.9 | 130.6 | 0% | 8 |
| Capocantiere | `voce_registrata` | casuale | 7% | 93% | 0% | 22.0 | 142.6 | 0% | 1 |
| Zombie Cittadino | `zombie_cittadino` | attacca | 100% | 0% | 0% | 3.9 | 12.4 | 0% | 6 |
| Zombie Cittadino | `zombie_cittadino` | difendi | 0% | 0% | 100% | 61.0 | 120.1 | 0% | 0 |
| Zombie Cittadino | `zombie_cittadino` | studia | 100% | 0% | 0% | 6.9 | 24.9 | 0% | 6 |
| Zombie Cittadino | `zombie_cittadino` | casuale | 100% | 0% | 0% | 12.5 | 38.9 | 0% | 6 |
| Zombie Mostruoso | `zombie_mostruoso` | attacca | 100% | 0% | 0% | 9.7 | 71.7 | 0% | 12 |
| Zombie Mostruoso | `zombie_mostruoso` | difendi | 0% | 100% | 0% | 46.9 | 145.0 | 0% | 0 |
| Zombie Mostruoso | `zombie_mostruoso` | studia | 100% | 0% | 0% | 12.7 | 96.2 | 0% | 12 |
| Zombie Mostruoso | `zombie_mostruoso` | casuale | 21% | 79% | 0% | 22.0 | 138.7 | 0% | 2 |

## Protagonista di livello 3

| creatura | id | come si gioca | vinte | perse | ∞ | giri | danno | risp. | xp |
|---|---|---|--:|--:|--:|--:|--:|--:|--:|
| Abominio Marcio | `abominio_marcio` | attacca | 67% | 33% | 0% | 16.8 | 182.3 | 0% | 11 |
| Abominio Marcio | `abominio_marcio` | difendi | 0% | 100% | 0% | 44.4 | 190.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | studia | 1% | 99% | 0% | 17.2 | 190.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | casuale | 0% | 100% | 0% | 21.6 | 190.0 | 0% | 0 |
| Oppresso | `comparsa_di_ruggine` | attacca | 100% | 0% | 0% | 11.3 | 65.0 | 0% | 10 |
| Oppresso | `comparsa_di_ruggine` | difendi | 0% | 1% | 99% | 61.0 | 183.6 | 0% | 0 |
| Oppresso | `comparsa_di_ruggine` | studia | 100% | 0% | 0% | 14.0 | 81.8 | 0% | 10 |
| Oppresso | `comparsa_di_ruggine` | casuale | 65% | 35% | 0% | 32.0 | 164.5 | 0% | 6 |
| Diabolo | `diabolo` | attacca | 100% | 0% | 0% | 15.3 | 90.0 | 0% | 8 |
| Diabolo | `diabolo` | difendi | 0% | 1% | 99% | 61.0 | 183.6 | 0% | 0 |
| Diabolo | `diabolo` | studia | 100% | 0% | 0% | 18.3 | 108.7 | 0% | 8 |
| Diabolo | `diabolo` | casuale | 22% | 78% | 0% | 34.8 | 177.6 | 0% | 2 |
| Il Divoratore | `divoratore` | attacca | 0% | 100% | 0% | 17.1 | 190.0 | 0% | 0 |
| Il Divoratore | `divoratore` | difendi | 0% | 100% | 0% | 44.4 | 190.0 | 0% | 0 |
| Il Divoratore | `divoratore` | studia | 0% | 100% | 0% | 17.2 | 190.0 | 0% | 0 |
| Il Divoratore | `divoratore` | casuale | 0% | 100% | 0% | 21.6 | 190.0 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | attacca | 15% | 85% | 0% | 15.7 | 177.6 | 0% | 3 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | difendi | 0% | 100% | 0% | 39.0 | 190.0 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | studia | 12% | 88% | 0% | 16.1 | 182.4 | 0% | 2 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | casuale | 7% | 93% | 0% | 20.3 | 184.9 | 0% | 1 |
| Ferraglia Urlante | `ferraglia_urlante` | attacca | 100% | 0% | 0% | 17.2 | 102.2 | 0% | 16 |
| Ferraglia Urlante | `ferraglia_urlante` | difendi | 0% | 1% | 99% | 61.0 | 183.6 | 0% | 0 |
| Ferraglia Urlante | `ferraglia_urlante` | studia | 100% | 0% | 0% | 20.2 | 121.8 | 0% | 16 |
| Ferraglia Urlante | `ferraglia_urlante` | casuale | 5% | 95% | 0% | 36.6 | 188.9 | 0% | 1 |
| Ghoul | `ghoul` | attacca | 100% | 0% | 0% | 14.4 | 84.6 | 0% | 9 |
| Ghoul | `ghoul` | difendi | 0% | 1% | 99% | 61.0 | 183.6 | 0% | 0 |
| Ghoul | `ghoul` | studia | 100% | 0% | 0% | 17.5 | 103.7 | 0% | 9 |
| Ghoul | `ghoul` | casuale | 29% | 71% | 0% | 34.5 | 175.6 | 0% | 3 |
| El Muy Bonito | `giocoliere` | attacca | 100% | 0% | 0% | 6.7 | 44.0 | 0% | 18 |
| El Muy Bonito | `giocoliere` | difendi | 0% | 19% | 81% | 60.8 | 187.1 | 0% | 0 |
| El Muy Bonito | `giocoliere` | studia | 99% | 1% | 0% | 8.7 | 154.4 | 0% | 18 |
| El Muy Bonito | `giocoliere` | casuale | 38% | 62% | 0% | 12.4 | 166.8 | 0% | 7 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | attacca | 0% | 100% | 0% | 19.1 | 190.0 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | difendi | 0% | 100% | 0% | 36.4 | 190.0 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | studia | 0% | 100% | 0% | 18.9 | 190.0 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | casuale | 0% | 100% | 0% | 22.8 | 190.0 | 0% | 0 |
| Goblin Tipico | `goblin_tipico` | attacca | 100% | 0% | 0% | 2.9 | 5.9 | 0% | 1 |
| Goblin Tipico | `goblin_tipico` | difendi | 0% | 0% | 100% | 61.0 | 120.1 | 0% | 0 |
| Goblin Tipico | `goblin_tipico` | studia | 100% | 0% | 0% | 5.9 | 15.4 | 0% | 1 |
| Goblin Tipico | `goblin_tipico` | casuale | 100% | 0% | 0% | 9.3 | 22.4 | 0% | 1 |
| Infetto Rapido | `infetto_rapido` | attacca | 100% | 0% | 0% | 2.9 | 17.9 | 0% | 6 |
| Infetto Rapido | `infetto_rapido` | difendi | 0% | 17% | 83% | 60.8 | 186.6 | 0% | 0 |
| Infetto Rapido | `infetto_rapido` | studia | 100% | 0% | 0% | 5.9 | 37.3 | 0% | 6 |
| Infetto Rapido | `infetto_rapido` | casuale | 100% | 0% | 0% | 8.4 | 44.0 | 0% | 6 |
| L'ultimo spettacolo di Jerah | `jerah` | attacca | 0% | 100% | 0% | 11.9 | 190.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | difendi | 0% | 100% | 0% | 18.2 | 190.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | studia | 0% | 100% | 0% | 13.9 | 190.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | casuale | 0% | 100% | 0% | 14.7 | 190.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | attacca | 0% | 100% | 0% | 17.0 | 190.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | difendi | 0% | 100% | 0% | 37.2 | 190.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | studia | 0% | 100% | 0% | 16.4 | 190.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | casuale | 0% | 100% | 0% | 19.5 | 190.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | attacca | 0% | 100% | 0% | 6.9 | 190.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | difendi | 0% | 100% | 0% | 14.5 | 190.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | studia | 0% | 100% | 0% | 7.0 | 190.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | casuale | 0% | 100% | 0% | 8.0 | 190.0 | 0% | 0 |
| ??? | `l_immortale` | attacca | 0% | 38% | 62% | 60.4 | 187.5 | 0% | 0 |
| ??? | `l_immortale` | difendi | 0% | 0% | 100% | 61.0 | 120.1 | 0% | 0 |
| ??? | `l_immortale` | studia | 0% | 37% | 63% | 60.4 | 187.6 | 0% | 0 |
| ??? | `l_immortale` | casuale | 0% | 0% | 100% | 61.0 | 165.9 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | attacca | 100% | 0% | 0% | 16.1 | 95.0 | 0% | 9 |
| Madre in Lacrime | `madre_in_lacrime` | difendi | 0% | 1% | 99% | 61.0 | 183.6 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | studia | 100% | 0% | 0% | 19.1 | 113.8 | 0% | 9 |
| Madre in Lacrime | `madre_in_lacrime` | casuale | 16% | 84% | 0% | 34.9 | 178.1 | 0% | 1 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | attacca | 0% | 100% | 0% | 6.0 | 190.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | difendi | 0% | 100% | 0% | 6.0 | 190.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | studia | 0% | 100% | 0% | 6.0 | 190.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | casuale | 0% | 100% | 0% | 6.0 | 190.0 | 0% | 0 |
| Marionetta | `marionetta` | attacca | 5% | 95% | 0% | 8.5 | 185.5 | 0% | 0 |
| Marionetta | `marionetta` | difendi | 0% | 100% | 0% | 24.8 | 190.0 | 0% | 0 |
| Marionetta | `marionetta` | studia | 6% | 94% | 0% | 8.6 | 186.5 | 0% | 0 |
| Marionetta | `marionetta` | casuale | 1% | 99% | 0% | 9.8 | 189.1 | 0% | 0 |
| Fomentado | `maschera_vuota` | attacca | 100% | 0% | 0% | 3.0 | 6.2 | 0% | 8 |
| Fomentado | `maschera_vuota` | difendi | 100% | 0% | 0% | 20.0 | 38.1 | 0% | 8 |
| Fomentado | `maschera_vuota` | studia | 100% | 0% | 0% | 6.0 | 15.7 | 0% | 8 |
| Fomentado | `maschera_vuota` | casuale | 100% | 0% | 0% | 8.0 | 19.1 | 0% | 8 |
| Ombra del passato | `ombra_del_passato` | attacca | 3% | 97% | 0% | 6.8 | 185.8 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | difendi | 0% | 100% | 0% | 14.7 | 190.0 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | studia | 5% | 95% | 0% | 6.9 | 187.7 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | casuale | 1% | 99% | 0% | 8.1 | 189.5 | 0% | 0 |
| Emblema dell'oppressione | `operaio_posseduto` | attacca | 100% | 0% | 0% | 12.1 | 69.9 | 0% | 12 |
| Emblema dell'oppressione | `operaio_posseduto` | difendi | 0% | 1% | 99% | 61.0 | 183.6 | 0% | 0 |
| Emblema dell'oppressione | `operaio_posseduto` | studia | 100% | 0% | 0% | 14.8 | 87.0 | 0% | 12 |
| Emblema dell'oppressione | `operaio_posseduto` | casuale | 53% | 47% | 0% | 33.0 | 169.8 | 0% | 6 |
| Orrore di Meridia | `orrore_di_meridia` | attacca | 99% | 1% | 0% | 13.1 | 153.3 | 0% | 20 |
| Orrore di Meridia | `orrore_di_meridia` | difendi | 0% | 100% | 0% | 37.9 | 190.0 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | studia | 43% | 57% | 0% | 15.4 | 186.8 | 0% | 9 |
| Orrore di Meridia | `orrore_di_meridia` | casuale | 0% | 100% | 0% | 19.1 | 190.0 | 0% | 0 |
| Sacerdote Folle | `sacerdote_folle` | attacca | 5% | 95% | 0% | 13.5 | 182.8 | 0% | 1 |
| Sacerdote Folle | `sacerdote_folle` | difendi | 0% | 100% | 0% | 26.5 | 190.0 | 0% | 0 |
| Sacerdote Folle | `sacerdote_folle` | studia | 1% | 99% | 0% | 13.8 | 188.1 | 0% | 0 |
| Sacerdote Folle | `sacerdote_folle` | casuale | 1% | 99% | 0% | 16.5 | 188.8 | 0% | 0 |
| Sadico | `sadico` | attacca | 100% | 0% | 0% | 14.6 | 153.8 | 0% | 10 |
| Sadico | `sadico` | difendi | 0% | 100% | 0% | 44.4 | 190.0 | 0% | 0 |
| Sadico | `sadico` | studia | 31% | 69% | 0% | 16.4 | 179.7 | 0% | 3 |
| Sadico | `sadico` | casuale | 7% | 93% | 0% | 21.4 | 186.0 | 0% | 1 |
| Slime Infimo | `slime_infimo` | attacca | 100% | 0% | 0% | 3.0 | 6.1 | 0% | 1 |
| Slime Infimo | `slime_infimo` | difendi | 0% | 0% | 100% | 61.0 | 120.1 | 0% | 0 |
| Slime Infimo | `slime_infimo` | studia | 100% | 0% | 0% | 6.0 | 15.7 | 0% | 1 |
| Slime Infimo | `slime_infimo` | casuale | 100% | 0% | 0% | 9.6 | 23.4 | 0% | 1 |
| Stigma | `stigma` | attacca | 100% | 0% | 0% | 13.8 | 145.0 | 0% | 9 |
| Stigma | `stigma` | difendi | 0% | 100% | 0% | 44.4 | 190.0 | 0% | 0 |
| Stigma | `stigma` | studia | 63% | 37% | 0% | 16.3 | 176.8 | 0% | 6 |
| Stigma | `stigma` | casuale | 7% | 93% | 0% | 21.4 | 186.0 | 0% | 1 |
| Tartaruga Innocente | `tartaruga_innocente` | attacca | 100% | 0% | 0% | 26.9 | 0.0 | 0% | 11 |
| Tartaruga Innocente | `tartaruga_innocente` | difendi | 0% | 0% | 100% | 61.0 | 0.0 | 0% | 0 |
| Tartaruga Innocente | `tartaruga_innocente` | studia | 100% | 0% | 0% | 1.0 | 0.0 | 100% | 14 |
| Tartaruga Innocente | `tartaruga_innocente` | casuale | 100% | 0% | 0% | 3.0 | 0.0 | 99% | 14 |
| Un tenero ricordo | `tenero_ricordo` | attacca | 0% | 100% | 0% | 7.8 | 190.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | difendi | 0% | 100% | 0% | 9.3 | 190.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | studia | 0% | 100% | 0% | 7.9 | 190.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | casuale | 0% | 100% | 0% | 8.1 | 190.0 | 0% | 0 |
| Teschio Errante | `teschio_errante` | attacca | 100% | 0% | 0% | 11.6 | 73.3 | 0% | 8 |
| Teschio Errante | `teschio_errante` | difendi | 0% | 17% | 83% | 60.8 | 186.6 | 0% | 0 |
| Teschio Errante | `teschio_errante` | studia | 100% | 0% | 0% | 15.2 | 95.3 | 0% | 8 |
| Teschio Errante | `teschio_errante` | casuale | 50% | 50% | 0% | 32.7 | 169.4 | 0% | 4 |
| Titano Zombie | `titano_zombie` | attacca | 0% | 100% | 0% | 13.3 | 190.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | difendi | 0% | 100% | 0% | 13.5 | 190.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | studia | 0% | 100% | 0% | 13.1 | 190.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | casuale | 0% | 100% | 0% | 11.5 | 190.0 | 0% | 0 |
| Capocantiere | `voce_registrata` | attacca | 100% | 0% | 0% | 9.4 | 53.2 | 0% | 9 |
| Capocantiere | `voce_registrata` | difendi | 0% | 1% | 99% | 61.0 | 183.6 | 0% | 0 |
| Capocantiere | `voce_registrata` | studia | 100% | 0% | 0% | 12.4 | 71.8 | 0% | 9 |
| Capocantiere | `voce_registrata` | casuale | 86% | 14% | 0% | 28.1 | 141.0 | 0% | 8 |
| Zombie Cittadino | `zombie_cittadino` | attacca | 100% | 0% | 0% | 3.0 | 6.1 | 0% | 5 |
| Zombie Cittadino | `zombie_cittadino` | difendi | 0% | 0% | 100% | 61.0 | 120.1 | 0% | 0 |
| Zombie Cittadino | `zombie_cittadino` | studia | 100% | 0% | 0% | 6.0 | 15.7 | 0% | 5 |
| Zombie Cittadino | `zombie_cittadino` | casuale | 100% | 0% | 0% | 9.5 | 23.2 | 0% | 5 |
| Zombie Mostruoso | `zombie_mostruoso` | attacca | 100% | 0% | 0% | 7.7 | 42.5 | 0% | 12 |
| Zombie Mostruoso | `zombie_mostruoso` | difendi | 0% | 1% | 99% | 61.0 | 183.6 | 0% | 0 |
| Zombie Mostruoso | `zombie_mostruoso` | studia | 100% | 0% | 0% | 10.7 | 61.6 | 0% | 12 |
| Zombie Mostruoso | `zombie_mostruoso` | casuale | 97% | 3% | 0% | 23.7 | 118.0 | 0% | 12 |

## Protagonista di livello 5

| creatura | id | come si gioca | vinte | perse | ∞ | giri | danno | risp. | xp |
|---|---|---|--:|--:|--:|--:|--:|--:|--:|
| Abominio Marcio | `abominio_marcio` | attacca | 100% | 0% | 0% | 10.9 | 82.7 | 0% | 16 |
| Abominio Marcio | `abominio_marcio` | difendi | 0% | 0% | 100% | 61.0 | 255.9 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | studia | 100% | 0% | 0% | 13.9 | 108.9 | 0% | 16 |
| Abominio Marcio | `abominio_marcio` | casuale | 86% | 14% | 0% | 32.6 | 222.5 | 0% | 14 |
| Oppresso | `comparsa_di_ruggine` | attacca | 100% | 0% | 0% | 7.5 | 28.8 | 0% | 9 |
| Oppresso | `comparsa_di_ruggine` | difendi | 0% | 0% | 100% | 61.0 | 183.2 | 0% | 0 |
| Oppresso | `comparsa_di_ruggine` | studia | 100% | 0% | 0% | 10.3 | 40.6 | 0% | 9 |
| Oppresso | `comparsa_di_ruggine` | casuale | 100% | 0% | 0% | 23.0 | 86.9 | 0% | 9 |
| Diabolo | `diabolo` | attacca | 100% | 0% | 0% | 9.4 | 36.8 | 0% | 8 |
| Diabolo | `diabolo` | difendi | 0% | 0% | 100% | 61.0 | 183.2 | 0% | 0 |
| Diabolo | `diabolo` | studia | 100% | 0% | 0% | 12.4 | 49.6 | 0% | 8 |
| Diabolo | `diabolo` | casuale | 100% | 0% | 0% | 28.7 | 107.9 | 0% | 8 |
| Il Divoratore | `divoratore` | attacca | 100% | 0% | 0% | 13.3 | 103.4 | 0% | 20 |
| Il Divoratore | `divoratore` | difendi | 0% | 0% | 100% | 61.0 | 255.9 | 0% | 0 |
| Il Divoratore | `divoratore` | studia | 100% | 0% | 0% | 16.3 | 129.3 | 0% | 20 |
| Il Divoratore | `divoratore` | casuale | 59% | 41% | 0% | 37.3 | 257.0 | 0% | 12 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | attacca | 100% | 0% | 0% | 19.9 | 159.9 | 0% | 18 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | difendi | 0% | 79% | 21% | 58.7 | 283.9 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | studia | 100% | 0% | 0% | 22.9 | 184.8 | 0% | 18 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | casuale | 13% | 87% | 0% | 37.3 | 268.2 | 0% | 2 |
| Ferraglia Urlante | `ferraglia_urlante` | attacca | 100% | 0% | 0% | 10.4 | 40.7 | 0% | 16 |
| Ferraglia Urlante | `ferraglia_urlante` | difendi | 0% | 0% | 100% | 61.0 | 183.2 | 0% | 0 |
| Ferraglia Urlante | `ferraglia_urlante` | studia | 100% | 0% | 0% | 13.5 | 54.1 | 0% | 16 |
| Ferraglia Urlante | `ferraglia_urlante` | casuale | 99% | 0% | 1% | 32.2 | 121.7 | 0% | 16 |
| Ghoul | `ghoul` | attacca | 100% | 0% | 0% | 9.4 | 36.8 | 0% | 9 |
| Ghoul | `ghoul` | difendi | 0% | 0% | 100% | 61.0 | 183.2 | 0% | 0 |
| Ghoul | `ghoul` | studia | 100% | 0% | 0% | 12.4 | 49.6 | 0% | 9 |
| Ghoul | `ghoul` | casuale | 100% | 0% | 0% | 28.7 | 107.9 | 0% | 9 |
| El Muy Bonito | `giocoliere` | attacca | 100% | 0% | 0% | 4.8 | 16.6 | 0% | 15 |
| El Muy Bonito | `giocoliere` | difendi | 0% | 0% | 100% | 61.0 | 183.2 | 0% | 0 |
| El Muy Bonito | `giocoliere` | studia | 100% | 0% | 0% | 7.0 | 91.8 | 0% | 15 |
| El Muy Bonito | `giocoliere` | casuale | 84% | 16% | 0% | 11.1 | 131.7 | 0% | 13 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | attacca | 100% | 0% | 0% | 18.3 | 133.7 | 0% | 41 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | difendi | 0% | 97% | 3% | 53.3 | 284.4 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | studia | 100% | 0% | 0% | 24.1 | 166.5 | 0% | 41 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | casuale | 5% | 95% | 0% | 42.0 | 284.2 | 0% | 2 |
| Goblin Tipico | `goblin_tipico` | attacca | 100% | 0% | 0% | 2.0 | 2.1 | 0% | 1 |
| Goblin Tipico | `goblin_tipico` | difendi | 0% | 0% | 100% | 61.0 | 123.1 | 0% | 0 |
| Goblin Tipico | `goblin_tipico` | studia | 100% | 0% | 0% | 5.0 | 8.7 | 0% | 1 |
| Goblin Tipico | `goblin_tipico` | casuale | 100% | 0% | 0% | 6.5 | 11.7 | 0% | 1 |
| Infetto Rapido | `infetto_rapido` | attacca | 100% | 0% | 0% | 2.0 | 4.2 | 0% | 4 |
| Infetto Rapido | `infetto_rapido` | difendi | 0% | 0% | 100% | 61.0 | 183.2 | 0% | 0 |
| Infetto Rapido | `infetto_rapido` | studia | 100% | 0% | 0% | 5.0 | 17.5 | 0% | 4 |
| Infetto Rapido | `infetto_rapido` | casuale | 100% | 0% | 0% | 6.6 | 21.4 | 0% | 4 |
| L'ultimo spettacolo di Jerah | `jerah` | attacca | 0% | 100% | 0% | 19.9 | 285.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | difendi | 0% | 100% | 0% | 26.6 | 285.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | studia | 0% | 100% | 0% | 24.5 | 285.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | casuale | 0% | 100% | 0% | 24.6 | 285.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | attacca | 0% | 100% | 0% | 28.7 | 285.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | difendi | 0% | 73% | 27% | 54.0 | 274.1 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | studia | 0% | 100% | 0% | 28.4 | 285.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | casuale | 0% | 100% | 0% | 34.0 | 285.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | attacca | 0% | 100% | 0% | 11.8 | 285.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | difendi | 0% | 100% | 0% | 29.1 | 285.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | studia | 0% | 100% | 0% | 11.8 | 285.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | casuale | 0% | 100% | 0% | 13.6 | 285.0 | 0% | 0 |
| ??? | `l_immortale` | attacca | 0% | 0% | 100% | 61.0 | 129.1 | 0% | 0 |
| ??? | `l_immortale` | difendi | 0% | 0% | 100% | 61.0 | 120.0 | 0% | 0 |
| ??? | `l_immortale` | studia | 0% | 0% | 100% | 61.0 | 129.2 | 0% | 0 |
| ??? | `l_immortale` | casuale | 0% | 0% | 100% | 61.0 | 125.3 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | attacca | 100% | 0% | 0% | 10.3 | 40.5 | 0% | 9 |
| Madre in Lacrime | `madre_in_lacrime` | difendi | 0% | 0% | 100% | 61.0 | 183.2 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | studia | 100% | 0% | 0% | 13.2 | 53.3 | 0% | 9 |
| Madre in Lacrime | `madre_in_lacrime` | casuale | 100% | 0% | 0% | 31.3 | 118.3 | 0% | 9 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | attacca | 0% | 100% | 0% | 6.0 | 285.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | difendi | 0% | 100% | 0% | 6.0 | 285.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | studia | 0% | 100% | 0% | 6.0 | 285.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | casuale | 0% | 100% | 0% | 6.0 | 285.0 | 0% | 0 |
| Marionetta | `marionetta` | attacca | 100% | 0% | 0% | 12.0 | 218.4 | 0% | 4 |
| Marionetta | `marionetta` | difendi | 0% | 100% | 0% | 40.4 | 285.0 | 0% | 0 |
| Marionetta | `marionetta` | studia | 49% | 51% | 0% | 14.1 | 265.1 | 0% | 2 |
| Marionetta | `marionetta` | casuale | 3% | 97% | 0% | 17.5 | 281.0 | 0% | 0 |
| Fomentado | `maschera_vuota` | attacca | 100% | 0% | 0% | 2.9 | 4.0 | 0% | 6 |
| Fomentado | `maschera_vuota` | difendi | 100% | 0% | 0% | 20.0 | 38.0 | 0% | 6 |
| Fomentado | `maschera_vuota` | studia | 100% | 0% | 0% | 5.0 | 8.6 | 0% | 6 |
| Fomentado | `maschera_vuota` | casuale | 100% | 0% | 0% | 6.4 | 11.3 | 0% | 6 |
| Ombra del passato | `ombra_del_passato` | attacca | 45% | 55% | 0% | 11.4 | 266.5 | 0% | 3 |
| Ombra del passato | `ombra_del_passato` | difendi | 0% | 100% | 0% | 29.8 | 285.0 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | studia | 7% | 93% | 0% | 11.5 | 275.7 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | casuale | 3% | 97% | 0% | 13.7 | 282.3 | 0% | 0 |
| Emblema dell'oppressione | `operaio_posseduto` | attacca | 100% | 0% | 0% | 7.8 | 29.7 | 0% | 12 |
| Emblema dell'oppressione | `operaio_posseduto` | difendi | 0% | 0% | 100% | 61.0 | 183.2 | 0% | 0 |
| Emblema dell'oppressione | `operaio_posseduto` | studia | 100% | 0% | 0% | 10.6 | 42.0 | 0% | 12 |
| Emblema dell'oppressione | `operaio_posseduto` | casuale | 100% | 0% | 0% | 24.0 | 90.9 | 0% | 12 |
| Orrore di Meridia | `orrore_di_meridia` | attacca | 100% | 0% | 0% | 8.7 | 70.8 | 0% | 20 |
| Orrore di Meridia | `orrore_di_meridia` | difendi | 0% | 47% | 53% | 59.8 | 280.2 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | studia | 100% | 0% | 0% | 11.7 | 99.6 | 0% | 20 |
| Orrore di Meridia | `orrore_di_meridia` | casuale | 94% | 6% | 0% | 26.1 | 193.0 | 0% | 19 |
| Sacerdote Folle | `sacerdote_folle` | attacca | 22% | 78% | 0% | 24.0 | 253.1 | 0% | 5 |
| Sacerdote Folle | `sacerdote_folle` | difendi | 0% | 100% | 0% | 36.5 | 285.0 | 0% | 0 |
| Sacerdote Folle | `sacerdote_folle` | studia | 12% | 88% | 0% | 24.8 | 272.1 | 0% | 3 |
| Sacerdote Folle | `sacerdote_folle` | casuale | 1% | 99% | 0% | 26.8 | 283.2 | 0% | 0 |
| Sadico | `sadico` | attacca | 100% | 0% | 0% | 9.5 | 72.2 | 0% | 10 |
| Sadico | `sadico` | difendi | 0% | 0% | 100% | 61.0 | 255.9 | 0% | 0 |
| Sadico | `sadico` | studia | 100% | 0% | 0% | 12.5 | 97.7 | 0% | 10 |
| Sadico | `sadico` | casuale | 94% | 6% | 0% | 29.1 | 196.4 | 0% | 9 |
| Slime Infimo | `slime_infimo` | attacca | 100% | 0% | 0% | 2.9 | 4.1 | 0% | 1 |
| Slime Infimo | `slime_infimo` | difendi | 0% | 0% | 100% | 61.0 | 123.1 | 0% | 0 |
| Slime Infimo | `slime_infimo` | studia | 100% | 0% | 0% | 5.9 | 10.8 | 0% | 1 |
| Slime Infimo | `slime_infimo` | casuale | 100% | 0% | 0% | 9.3 | 17.8 | 0% | 1 |
| Stigma | `stigma` | attacca | 100% | 0% | 0% | 9.4 | 71.0 | 0% | 9 |
| Stigma | `stigma` | difendi | 0% | 0% | 100% | 61.0 | 255.9 | 0% | 0 |
| Stigma | `stigma` | studia | 100% | 0% | 0% | 12.4 | 96.2 | 0% | 9 |
| Stigma | `stigma` | casuale | 94% | 6% | 0% | 28.4 | 191.9 | 0% | 8 |
| Tartaruga Innocente | `tartaruga_innocente` | attacca | 100% | 0% | 0% | 12.5 | 0.0 | 0% | 6 |
| Tartaruga Innocente | `tartaruga_innocente` | difendi | 0% | 0% | 100% | 61.0 | 0.0 | 0% | 0 |
| Tartaruga Innocente | `tartaruga_innocente` | studia | 100% | 0% | 0% | 1.0 | 0.0 | 100% | 8 |
| Tartaruga Innocente | `tartaruga_innocente` | casuale | 100% | 0% | 0% | 3.0 | 0.0 | 99% | 8 |
| Un tenero ricordo | `tenero_ricordo` | attacca | 0% | 100% | 0% | 9.2 | 285.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | difendi | 0% | 100% | 0% | 9.4 | 285.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | studia | 0% | 100% | 0% | 9.0 | 285.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | casuale | 0% | 100% | 0% | 9.5 | 285.0 | 0% | 0 |
| Teschio Errante | `teschio_errante` | attacca | 100% | 0% | 0% | 7.8 | 29.7 | 0% | 8 |
| Teschio Errante | `teschio_errante` | difendi | 0% | 0% | 100% | 61.0 | 183.2 | 0% | 0 |
| Teschio Errante | `teschio_errante` | studia | 100% | 0% | 0% | 10.8 | 42.8 | 0% | 8 |
| Teschio Errante | `teschio_errante` | casuale | 100% | 0% | 0% | 23.9 | 89.4 | 0% | 8 |
| Titano Zombie | `titano_zombie` | attacca | 0% | 100% | 0% | 16.6 | 285.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | difendi | 0% | 100% | 0% | 16.7 | 285.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | studia | 0% | 100% | 0% | 17.0 | 285.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | casuale | 0% | 100% | 0% | 15.7 | 285.0 | 0% | 0 |
| Capocantiere | `voce_registrata` | attacca | 100% | 0% | 0% | 6.7 | 24.9 | 0% | 8 |
| Capocantiere | `voce_registrata` | difendi | 0% | 0% | 100% | 61.0 | 183.2 | 0% | 0 |
| Capocantiere | `voce_registrata` | studia | 100% | 0% | 0% | 9.7 | 38.1 | 0% | 8 |
| Capocantiere | `voce_registrata` | casuale | 100% | 0% | 0% | 20.5 | 76.0 | 0% | 8 |
| Zombie Cittadino | `zombie_cittadino` | attacca | 100% | 0% | 0% | 2.0 | 2.1 | 0% | 3 |
| Zombie Cittadino | `zombie_cittadino` | difendi | 0% | 0% | 100% | 61.0 | 120.0 | 0% | 0 |
| Zombie Cittadino | `zombie_cittadino` | studia | 100% | 0% | 0% | 5.0 | 8.6 | 0% | 3 |
| Zombie Cittadino | `zombie_cittadino` | casuale | 100% | 0% | 0% | 6.6 | 11.7 | 0% | 3 |
| Zombie Mostruoso | `zombie_mostruoso` | attacca | 100% | 0% | 0% | 5.7 | 20.8 | 0% | 8 |
| Zombie Mostruoso | `zombie_mostruoso` | difendi | 0% | 0% | 100% | 61.0 | 183.2 | 0% | 0 |
| Zombie Mostruoso | `zombie_mostruoso` | studia | 100% | 0% | 0% | 8.8 | 34.0 | 0% | 8 |
| Zombie Mostruoso | `zombie_mostruoso` | casuale | 100% | 0% | 0% | 17.8 | 65.4 | 0% | 8 |

## Protagonista di livello 8

| creatura | id | come si gioca | vinte | perse | ∞ | giri | danno | risp. | xp |
|---|---|---|--:|--:|--:|--:|--:|--:|--:|
| Abominio Marcio | `abominio_marcio` | attacca | 100% | 0% | 0% | 7.0 | 26.2 | 0% | 16 |
| Abominio Marcio | `abominio_marcio` | difendi | 0% | 0% | 100% | 61.0 | 192.7 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | studia | 100% | 0% | 0% | 10.0 | 40.1 | 0% | 16 |
| Abominio Marcio | `abominio_marcio` | casuale | 100% | 0% | 0% | 21.8 | 84.0 | 0% | 16 |
| Oppresso | `comparsa_di_ruggine` | attacca | 100% | 0% | 0% | 6.6 | 14.2 | 0% | 6 |
| Oppresso | `comparsa_di_ruggine` | difendi | 0% | 0% | 100% | 61.0 | 126.5 | 0% | 0 |
| Oppresso | `comparsa_di_ruggine` | studia | 100% | 0% | 0% | 9.4 | 20.7 | 0% | 6 |
| Oppresso | `comparsa_di_ruggine` | casuale | 100% | 0% | 0% | 20.4 | 45.7 | 0% | 6 |
| Diabolo | `diabolo` | attacca | 100% | 0% | 0% | 5.9 | 11.4 | 0% | 8 |
| Diabolo | `diabolo` | difendi | 0% | 0% | 100% | 61.0 | 123.2 | 0% | 0 |
| Diabolo | `diabolo` | studia | 100% | 0% | 0% | 8.9 | 18.5 | 0% | 8 |
| Diabolo | `diabolo` | casuale | 100% | 0% | 0% | 18.3 | 38.3 | 0% | 8 |
| Il Divoratore | `divoratore` | attacca | 100% | 0% | 0% | 8.6 | 33.5 | 0% | 14 |
| Il Divoratore | `divoratore` | difendi | 0% | 0% | 100% | 61.0 | 192.7 | 0% | 0 |
| Il Divoratore | `divoratore` | studia | 100% | 0% | 0% | 11.6 | 47.3 | 0% | 14 |
| Il Divoratore | `divoratore` | casuale | 100% | 0% | 0% | 26.7 | 103.9 | 0% | 14 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | attacca | 100% | 0% | 0% | 12.9 | 53.0 | 0% | 18 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | difendi | 0% | 0% | 100% | 61.0 | 210.3 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | studia | 100% | 0% | 0% | 15.9 | 66.4 | 0% | 18 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | casuale | 95% | 0% | 5% | 38.5 | 156.9 | 0% | 17 |
| Ferraglia Urlante | `ferraglia_urlante` | attacca | 100% | 0% | 0% | 6.8 | 12.9 | 0% | 11 |
| Ferraglia Urlante | `ferraglia_urlante` | difendi | 0% | 0% | 100% | 61.0 | 123.2 | 0% | 0 |
| Ferraglia Urlante | `ferraglia_urlante` | studia | 100% | 0% | 0% | 9.7 | 19.9 | 0% | 11 |
| Ferraglia Urlante | `ferraglia_urlante` | casuale | 100% | 0% | 0% | 20.8 | 43.6 | 0% | 11 |
| Ghoul | `ghoul` | attacca | 100% | 0% | 0% | 6.4 | 12.7 | 0% | 9 |
| Ghoul | `ghoul` | difendi | 0% | 0% | 100% | 61.0 | 123.2 | 0% | 0 |
| Ghoul | `ghoul` | studia | 100% | 0% | 0% | 9.5 | 19.9 | 0% | 9 |
| Ghoul | `ghoul` | casuale | 100% | 0% | 0% | 19.9 | 41.8 | 0% | 9 |
| El Muy Bonito | `giocoliere` | attacca | 100% | 0% | 0% | 4.0 | 7.4 | 0% | 12 |
| El Muy Bonito | `giocoliere` | difendi | 0% | 0% | 100% | 61.0 | 126.4 | 0% | 0 |
| El Muy Bonito | `giocoliere` | studia | 100% | 0% | 0% | 6.8 | 72.8 | 0% | 12 |
| El Muy Bonito | `giocoliere` | casuale | 96% | 4% | 0% | 10.7 | 112.7 | 0% | 12 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | attacca | 100% | 0% | 0% | 13.2 | 54.2 | 0% | 30 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | difendi | 0% | 0% | 100% | 61.0 | 280.0 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | studia | 100% | 0% | 0% | 19.1 | 80.2 | 0% | 30 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | casuale | 97% | 0% | 3% | 41.5 | 215.5 | 0% | 29 |
| Goblin Tipico | `goblin_tipico` | attacca | 100% | 0% | 0% | 2.9 | 4.3 | 0% | 2 |
| Goblin Tipico | `goblin_tipico` | difendi | 0% | 0% | 100% | 61.0 | 123.2 | 0% | 0 |
| Goblin Tipico | `goblin_tipico` | studia | 100% | 0% | 0% | 5.9 | 11.3 | 0% | 2 |
| Goblin Tipico | `goblin_tipico` | casuale | 100% | 0% | 0% | 9.3 | 18.4 | 0% | 2 |
| Infetto Rapido | `infetto_rapido` | attacca | 100% | 0% | 0% | 2.9 | 10.4 | 0% | 6 |
| Infetto Rapido | `infetto_rapido` | difendi | 0% | 0% | 100% | 61.0 | 195.9 | 0% | 0 |
| Infetto Rapido | `infetto_rapido` | studia | 100% | 0% | 0% | 5.9 | 27.2 | 0% | 6 |
| Infetto Rapido | `infetto_rapido` | casuale | 100% | 0% | 0% | 9.2 | 38.7 | 0% | 6 |
| L'ultimo spettacolo di Jerah | `jerah` | attacca | 15% | 85% | 0% | 35.7 | 418.6 | 0% | 9 |
| L'ultimo spettacolo di Jerah | `jerah` | difendi | 0% | 99% | 1% | 38.6 | 422.4 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | studia | 14% | 85% | 1% | 40.1 | 416.1 | 0% | 7 |
| L'ultimo spettacolo di Jerah | `jerah` | casuale | 0% | 99% | 1% | 40.0 | 423.7 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | attacca | 98% | 2% | 0% | 41.8 | 289.4 | 0% | 71 |
| Jongo Dongo | `jongo_dongo` | difendi | 0% | 1% | 99% | 61.0 | 261.9 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | studia | 87% | 11% | 2% | 47.7 | 335.9 | 0% | 64 |
| Jongo Dongo | `jongo_dongo` | casuale | 0% | 29% | 71% | 59.2 | 382.6 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | attacca | 0% | 100% | 0% | 21.9 | 425.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | difendi | 0% | 99% | 1% | 52.0 | 425.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | studia | 0% | 100% | 0% | 21.7 | 425.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | casuale | 0% | 100% | 0% | 25.5 | 425.0 | 0% | 0 |
| ??? | `l_immortale` | attacca | 0% | 0% | 100% | 61.0 | 123.0 | 0% | 0 |
| ??? | `l_immortale` | difendi | 0% | 0% | 100% | 61.0 | 120.0 | 0% | 0 |
| ??? | `l_immortale` | studia | 0% | 0% | 100% | 61.0 | 123.1 | 0% | 0 |
| ??? | `l_immortale` | casuale | 0% | 0% | 100% | 61.0 | 121.8 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | attacca | 100% | 0% | 0% | 6.7 | 13.3 | 0% | 9 |
| Madre in Lacrime | `madre_in_lacrime` | difendi | 0% | 0% | 100% | 61.0 | 123.2 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | studia | 100% | 0% | 0% | 9.7 | 20.3 | 0% | 9 |
| Madre in Lacrime | `madre_in_lacrime` | casuale | 100% | 0% | 0% | 20.5 | 43.1 | 0% | 9 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | attacca | 0% | 100% | 0% | 6.0 | 425.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | difendi | 0% | 100% | 0% | 6.0 | 425.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | studia | 0% | 100% | 0% | 6.0 | 425.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | casuale | 0% | 100% | 0% | 6.0 | 425.0 | 0% | 0 |
| Marionetta | `marionetta` | attacca | 100% | 0% | 0% | 7.5 | 103.8 | 0% | 4 |
| Marionetta | `marionetta` | difendi | 0% | 39% | 61% | 59.8 | 406.9 | 0% | 0 |
| Marionetta | `marionetta` | studia | 100% | 0% | 0% | 10.3 | 147.0 | 0% | 4 |
| Marionetta | `marionetta` | casuale | 95% | 5% | 0% | 22.8 | 284.6 | 0% | 4 |
| Fomentado | `maschera_vuota` | attacca | 100% | 0% | 0% | 2.9 | 4.1 | 0% | 6 |
| Fomentado | `maschera_vuota` | difendi | 100% | 0% | 0% | 32.0 | 62.0 | 0% | 6 |
| Fomentado | `maschera_vuota` | studia | 100% | 0% | 0% | 5.9 | 10.8 | 0% | 6 |
| Fomentado | `maschera_vuota` | casuale | 100% | 0% | 0% | 7.5 | 13.8 | 0% | 6 |
| Ombra del passato | `ombra_del_passato` | attacca | 100% | 0% | 0% | 7.6 | 131.6 | 0% | 6 |
| Ombra del passato | `ombra_del_passato` | difendi | 0% | 97% | 3% | 52.2 | 425.0 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | studia | 100% | 0% | 0% | 10.3 | 185.7 | 0% | 6 |
| Ombra del passato | `ombra_del_passato` | casuale | 69% | 31% | 0% | 21.6 | 348.4 | 0% | 4 |
| Emblema dell'oppressione | `operaio_posseduto` | attacca | 100% | 0% | 0% | 4.9 | 9.0 | 0% | 7 |
| Emblema dell'oppressione | `operaio_posseduto` | difendi | 0% | 0% | 100% | 61.0 | 123.2 | 0% | 0 |
| Emblema dell'oppressione | `operaio_posseduto` | studia | 100% | 0% | 0% | 7.9 | 15.7 | 0% | 7 |
| Emblema dell'oppressione | `operaio_posseduto` | casuale | 100% | 0% | 0% | 15.6 | 32.4 | 0% | 7 |
| Orrore di Meridia | `orrore_di_meridia` | attacca | 100% | 0% | 0% | 5.8 | 24.8 | 0% | 11 |
| Orrore di Meridia | `orrore_di_meridia` | difendi | 0% | 0% | 100% | 61.0 | 221.8 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | studia | 100% | 0% | 0% | 8.9 | 42.0 | 0% | 11 |
| Orrore di Meridia | `orrore_di_meridia` | casuale | 100% | 0% | 0% | 17.5 | 78.4 | 0% | 11 |
| Sacerdote Folle | `sacerdote_folle` | attacca | 97% | 0% | 3% | 22.9 | 115.5 | 0% | 38 |
| Sacerdote Folle | `sacerdote_folle` | difendi | 0% | 0% | 100% | 61.0 | 365.7 | 0% | 0 |
| Sacerdote Folle | `sacerdote_folle` | studia | 61% | 1% | 37% | 41.0 | 242.6 | 0% | 22 |
| Sacerdote Folle | `sacerdote_folle` | casuale | 21% | 23% | 57% | 57.4 | 370.0 | 0% | 7 |
| Sadico | `sadico` | attacca | 100% | 0% | 0% | 6.6 | 25.8 | 0% | 10 |
| Sadico | `sadico` | difendi | 0% | 0% | 100% | 61.0 | 192.7 | 0% | 0 |
| Sadico | `sadico` | studia | 100% | 0% | 0% | 9.7 | 39.6 | 0% | 10 |
| Sadico | `sadico` | casuale | 100% | 0% | 0% | 20.5 | 78.8 | 0% | 10 |
| Slime Infimo | `slime_infimo` | attacca | 100% | 0% | 0% | 3.0 | 4.4 | 0% | 2 |
| Slime Infimo | `slime_infimo` | difendi | 0% | 0% | 100% | 61.0 | 123.2 | 0% | 0 |
| Slime Infimo | `slime_infimo` | studia | 100% | 0% | 0% | 6.0 | 11.4 | 0% | 2 |
| Slime Infimo | `slime_infimo` | casuale | 100% | 0% | 0% | 9.6 | 19.1 | 0% | 2 |
| Stigma | `stigma` | attacca | 100% | 0% | 0% | 5.9 | 22.2 | 0% | 9 |
| Stigma | `stigma` | difendi | 0% | 0% | 100% | 61.0 | 192.7 | 0% | 0 |
| Stigma | `stigma` | studia | 100% | 0% | 0% | 8.9 | 36.2 | 0% | 9 |
| Stigma | `stigma` | casuale | 100% | 0% | 0% | 18.3 | 70.0 | 0% | 9 |
| Tartaruga Innocente | `tartaruga_innocente` | attacca | 100% | 0% | 0% | 6.6 | 0.0 | 0% | 2 |
| Tartaruga Innocente | `tartaruga_innocente` | difendi | 0% | 0% | 100% | 61.0 | 0.0 | 0% | 0 |
| Tartaruga Innocente | `tartaruga_innocente` | studia | 100% | 0% | 0% | 1.0 | 0.0 | 100% | 3 |
| Tartaruga Innocente | `tartaruga_innocente` | casuale | 100% | 0% | 0% | 3.0 | 0.0 | 99% | 3 |
| Un tenero ricordo | `tenero_ricordo` | attacca | 0% | 100% | 0% | 10.0 | 425.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | difendi | 0% | 100% | 0% | 9.4 | 425.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | studia | 0% | 100% | 0% | 9.4 | 425.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | casuale | 0% | 100% | 0% | 10.2 | 425.0 | 0% | 0 |
| Teschio Errante | `teschio_errante` | attacca | 100% | 0% | 0% | 4.9 | 9.0 | 0% | 8 |
| Teschio Errante | `teschio_errante` | difendi | 0% | 0% | 100% | 61.0 | 123.2 | 0% | 0 |
| Teschio Errante | `teschio_errante` | studia | 100% | 0% | 0% | 7.9 | 16.0 | 0% | 8 |
| Teschio Errante | `teschio_errante` | casuale | 100% | 0% | 0% | 15.4 | 32.0 | 0% | 8 |
| Titano Zombie | `titano_zombie` | attacca | 5% | 95% | 0% | 20.1 | 423.6 | 0% | 3 |
| Titano Zombie | `titano_zombie` | difendi | 0% | 100% | 0% | 18.7 | 425.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | studia | 1% | 99% | 0% | 20.4 | 424.2 | 0% | 1 |
| Titano Zombie | `titano_zombie` | casuale | 0% | 100% | 0% | 19.5 | 425.0 | 0% | 0 |
| Capocantiere | `voce_registrata` | attacca | 100% | 0% | 0% | 5.7 | 11.8 | 0% | 6 |
| Capocantiere | `voce_registrata` | difendi | 0% | 0% | 100% | 61.0 | 126.5 | 0% | 0 |
| Capocantiere | `voce_registrata` | studia | 100% | 0% | 0% | 8.8 | 19.4 | 0% | 6 |
| Capocantiere | `voce_registrata` | casuale | 100% | 0% | 0% | 17.8 | 39.5 | 0% | 6 |
| Zombie Cittadino | `zombie_cittadino` | attacca | 100% | 0% | 0% | 2.9 | 4.2 | 0% | 5 |
| Zombie Cittadino | `zombie_cittadino` | difendi | 0% | 0% | 100% | 61.0 | 120.0 | 0% | 0 |
| Zombie Cittadino | `zombie_cittadino` | studia | 100% | 0% | 0% | 5.9 | 11.0 | 0% | 5 |
| Zombie Cittadino | `zombie_cittadino` | casuale | 100% | 0% | 0% | 9.2 | 17.7 | 0% | 5 |
| Zombie Mostruoso | `zombie_mostruoso` | attacca | 100% | 0% | 0% | 5.7 | 16.8 | 0% | 8 |
| Zombie Mostruoso | `zombie_mostruoso` | difendi | 0% | 0% | 100% | 61.0 | 189.6 | 0% | 0 |
| Zombie Mostruoso | `zombie_mostruoso` | studia | 100% | 0% | 0% | 8.8 | 27.6 | 0% | 8 |
| Zombie Mostruoso | `zombie_mostruoso` | casuale | 100% | 0% | 0% | 17.8 | 57.1 | 0% | 8 |

