# Bilanciamento (generato, non scrivere qui a mano)

Prodotto da `prove/Simulatore.gd`: **99000 partite** giocate dal motore vero in 537 secondi.

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
- **danno** — punti vita persi in media dal protagonista (ne ha 100)
- **risp.** — percentuale di partite in cui la creatura e' stata risparmiata

## A che livello ogni scontro diventa giusto

Livello minimo a cui si vince almeno l'80% delle volte andandoci dritto.

| creatura | id | hp | att | livello |
|---|---|--:|--:|--:|
| Abominio Marcio | `abominio_marcio` | 200 | 9 | 5 |
| Oppresso | `comparsa_di_ruggine` | 135 | 6 | 3 |
| Diabolo | `diabolo` | 165 | 6 | 5 |
| Il Divoratore | `divoratore` | 225 | 9 | 8 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | 375 | 9 | 8 |
| Ferraglia Urlante | `ferraglia_urlante` | 175 | 6 | 5 |
| Ghoul | `ghoul` | 175 | 6 | 3 |
| El Muy Bonito | `giocoliere` | 90 | 6 | 1 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | 150 | 9 | 3 |
| Goblin Tipico | `goblin_tipico` | 30 | 3 | 1 |
| Infetto Rapido | `infetto_rapido` | 35 | 6 | 1 |
| L'ultimo spettacolo di Jerah | `jerah` | 175 | 6 | 5 |
| Jongo Dongo | `jongo_dongo` | 700 | 18 | **mai** |
| Jongo Dongo | `jongo_dongo_risorto` | 700 | 21 | **mai** |
| ??? | `l_immortale` | 60 | 3 | **mai** |
| Madre in Lacrime | `madre_in_lacrime` | 175 | 6 | 5 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | 160 | 15 | **mai** |
| Marionetta | `marionetta` | 190 | 18 | 8 |
| Fomentado | `maschera_vuota` | 50 | 3 | 1 |
| Ombra del passato | `ombra_del_passato` | 195 | 21 | **mai** |
| Emblema dell'oppressione | `operaio_posseduto` | 145 | 6 | 3 |
| Orrore di Meridia | `orrore_di_meridia` | 170 | 9 | 5 |
| Sacerdote Folle | `sacerdote_folle` | 280 | 9 | **mai** |
| Sadico | `sadico` | 180 | 9 | 5 |
| Slime Infimo | `slime_infimo` | 40 | 3 | 1 |
| Stigma | `stigma` | 170 | 9 | 5 |
| Tartaruga Innocente | `tartaruga_innocente` | 100 | 0 | 8 |
| Un tenero ricordo | `tenero_ricordo` | 666 | 18 | **mai** |
| Teschio Errante | `teschio_errante` | 145 | 6 | 3 |
| Titano Zombie | `titano_zombie` | 450 | 12 | **mai** |
| Capocantiere | `voce_registrata` | 125 | 6 | 2 |
| Zombie Cittadino | `zombie_cittadino` | 40 | 3 | 1 |
| Zombie Mostruoso | `zombie_mostruoso` | 110 | 6 | 1 |

## Protagonista di livello 1

| creatura | id | come si gioca | vinte | perse | ∞ | giri | danno | risp. | xp |
|---|---|---|--:|--:|--:|--:|--:|--:|--:|
| Abominio Marcio | `abominio_marcio` | attacca | 0% | 100% | 0% | 12.4 | 100.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | difendi | 0% | 0% | 100% | 61.0 | 14.5 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | studia | 0% | 100% | 0% | 12.6 | 100.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | casuale | 0% | 100% | 0% | 18.0 | 100.0 | 0% | 0 |
| Oppresso | `comparsa_di_ruggine` | attacca | 27% | 73% | 0% | 16.4 | 88.7 | 0% | 3 |
| Oppresso | `comparsa_di_ruggine` | difendi | 0% | 0% | 100% | 61.0 | 0.5 | 0% | 0 |
| Oppresso | `comparsa_di_ruggine` | studia | 11% | 89% | 0% | 17.5 | 95.0 | 0% | 1 |
| Oppresso | `comparsa_di_ruggine` | casuale | 7% | 93% | 0% | 26.0 | 97.2 | 0% | 1 |
| Diabolo | `diabolo` | attacca | 12% | 88% | 0% | 16.9 | 93.8 | 0% | 1 |
| Diabolo | `diabolo` | difendi | 0% | 0% | 100% | 61.0 | 6.0 | 0% | 0 |
| Diabolo | `diabolo` | studia | 11% | 89% | 0% | 17.4 | 96.6 | 0% | 1 |
| Diabolo | `diabolo` | casuale | 7% | 93% | 0% | 25.3 | 97.1 | 0% | 1 |
| Il Divoratore | `divoratore` | attacca | 0% | 100% | 0% | 12.4 | 100.0 | 0% | 0 |
| Il Divoratore | `divoratore` | difendi | 0% | 0% | 100% | 61.0 | 14.5 | 0% | 0 |
| Il Divoratore | `divoratore` | studia | 0% | 100% | 0% | 12.6 | 100.0 | 0% | 0 |
| Il Divoratore | `divoratore` | casuale | 0% | 100% | 0% | 18.0 | 100.0 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | attacca | 12% | 88% | 0% | 10.5 | 94.3 | 0% | 2 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | difendi | 0% | 0% | 100% | 61.0 | 10.1 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | studia | 9% | 91% | 0% | 10.8 | 96.8 | 0% | 2 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | casuale | 3% | 97% | 0% | 16.6 | 98.8 | 0% | 1 |
| Ferraglia Urlante | `ferraglia_urlante` | attacca | 0% | 100% | 0% | 18.1 | 100.0 | 0% | 0 |
| Ferraglia Urlante | `ferraglia_urlante` | difendi | 0% | 0% | 100% | 61.0 | 0.5 | 0% | 0 |
| Ferraglia Urlante | `ferraglia_urlante` | studia | 0% | 100% | 0% | 18.5 | 100.0 | 0% | 0 |
| Ferraglia Urlante | `ferraglia_urlante` | casuale | 0% | 100% | 0% | 26.5 | 100.0 | 0% | 0 |
| Ghoul | `ghoul` | attacca | 27% | 73% | 0% | 16.4 | 88.7 | 0% | 2 |
| Ghoul | `ghoul` | difendi | 0% | 0% | 100% | 61.0 | 0.5 | 0% | 0 |
| Ghoul | `ghoul` | studia | 15% | 85% | 0% | 17.0 | 93.9 | 0% | 1 |
| Ghoul | `ghoul` | casuale | 8% | 92% | 0% | 26.2 | 97.0 | 0% | 1 |
| El Muy Bonito | `giocoliere` | attacca | 100% | 0% | 0% | 9.9 | 57.7 | 0% | 18 |
| El Muy Bonito | `giocoliere` | difendi | 0% | 0% | 100% | 61.0 | 7.1 | 0% | 0 |
| El Muy Bonito | `giocoliere` | studia | 0% | 100% | 0% | 8.3 | 100.0 | 0% | 0 |
| El Muy Bonito | `giocoliere` | casuale | 5% | 95% | 0% | 12.5 | 98.9 | 0% | 1 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | attacca | 1% | 99% | 0% | 12.8 | 100.0 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | difendi | 0% | 0% | 100% | 61.0 | 7.6 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | studia | 0% | 100% | 0% | 13.2 | 100.0 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | casuale | 0% | 100% | 0% | 18.3 | 100.0 | 0% | 0 |
| Goblin Tipico | `goblin_tipico` | attacca | 100% | 0% | 0% | 3.8 | 8.1 | 0% | 2 |
| Goblin Tipico | `goblin_tipico` | difendi | 0% | 0% | 100% | 61.0 | 0.1 | 0% | 0 |
| Goblin Tipico | `goblin_tipico` | studia | 100% | 0% | 0% | 6.9 | 16.8 | 0% | 2 |
| Goblin Tipico | `goblin_tipico` | casuale | 100% | 0% | 0% | 12.2 | 20.2 | 0% | 2 |
| Infetto Rapido | `infetto_rapido` | attacca | 100% | 0% | 0% | 4.0 | 22.4 | 0% | 7 |
| Infetto Rapido | `infetto_rapido` | difendi | 0% | 0% | 100% | 61.0 | 6.0 | 0% | 0 |
| Infetto Rapido | `infetto_rapido` | studia | 100% | 0% | 0% | 7.0 | 39.0 | 0% | 7 |
| Infetto Rapido | `infetto_rapido` | casuale | 99% | 1% | 0% | 12.1 | 46.6 | 0% | 7 |
| L'ultimo spettacolo di Jerah | `jerah` | attacca | 5% | 95% | 0% | 13.0 | 99.0 | 0% | 2 |
| L'ultimo spettacolo di Jerah | `jerah` | difendi | 0% | 100% | 0% | 22.2 | 100.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | studia | 1% | 99% | 0% | 13.9 | 99.5 | 0% | 1 |
| L'ultimo spettacolo di Jerah | `jerah` | casuale | 1% | 99% | 0% | 17.1 | 99.7 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | attacca | 0% | 100% | 0% | 12.0 | 100.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | difendi | 0% | 1% | 99% | 60.9 | 47.2 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | studia | 0% | 100% | 0% | 12.1 | 100.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | casuale | 0% | 100% | 0% | 15.7 | 100.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | attacca | 0% | 100% | 0% | 5.4 | 100.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | difendi | 0% | 100% | 0% | 23.3 | 100.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | studia | 0% | 100% | 0% | 5.3 | 100.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | casuale | 0% | 100% | 0% | 6.5 | 100.0 | 0% | 0 |
| ??? | `l_immortale` | attacca | 0% | 100% | 0% | 35.2 | 100.0 | 0% | 0 |
| ??? | `l_immortale` | difendi | 0% | 0% | 100% | 61.0 | 0.1 | 0% | 0 |
| ??? | `l_immortale` | studia | 0% | 100% | 0% | 35.5 | 100.0 | 0% | 0 |
| ??? | `l_immortale` | casuale | 0% | 89% | 11% | 52.3 | 99.5 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | attacca | 27% | 73% | 0% | 16.4 | 88.7 | 0% | 2 |
| Madre in Lacrime | `madre_in_lacrime` | difendi | 0% | 0% | 100% | 61.0 | 0.5 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | studia | 15% | 85% | 0% | 17.0 | 93.9 | 0% | 1 |
| Madre in Lacrime | `madre_in_lacrime` | casuale | 8% | 92% | 0% | 26.2 | 97.0 | 0% | 1 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | attacca | 0% | 100% | 0% | 6.0 | 100.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | difendi | 0% | 100% | 0% | 6.0 | 100.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | studia | 0% | 100% | 0% | 6.0 | 100.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | casuale | 0% | 100% | 0% | 6.0 | 100.0 | 0% | 0 |
| Marionetta | `marionetta` | attacca | 6% | 94% | 0% | 6.3 | 96.5 | 0% | 0 |
| Marionetta | `marionetta` | difendi | 0% | 18% | 82% | 58.8 | 63.6 | 0% | 0 |
| Marionetta | `marionetta` | studia | 3% | 97% | 0% | 6.5 | 98.9 | 0% | 0 |
| Marionetta | `marionetta` | casuale | 1% | 99% | 0% | 7.9 | 99.5 | 0% | 0 |
| Fomentado | `maschera_vuota` | attacca | 100% | 0% | 0% | 4.6 | 10.2 | 0% | 8 |
| Fomentado | `maschera_vuota` | difendi | 100% | 0% | 0% | 17.0 | 0.1 | 0% | 8 |
| Fomentado | `maschera_vuota` | studia | 100% | 0% | 0% | 6.8 | 16.6 | 0% | 8 |
| Fomentado | `maschera_vuota` | casuale | 100% | 0% | 0% | 8.9 | 14.7 | 0% | 8 |
| Ombra del passato | `ombra_del_passato` | attacca | 5% | 95% | 0% | 5.3 | 96.7 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | difendi | 0% | 100% | 0% | 24.4 | 100.0 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | studia | 3% | 97% | 0% | 5.4 | 99.3 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | casuale | 1% | 99% | 0% | 6.6 | 99.6 | 0% | 0 |
| Emblema dell'oppressione | `operaio_posseduto` | attacca | 27% | 73% | 0% | 16.4 | 88.7 | 0% | 3 |
| Emblema dell'oppressione | `operaio_posseduto` | difendi | 0% | 0% | 100% | 61.0 | 0.5 | 0% | 0 |
| Emblema dell'oppressione | `operaio_posseduto` | studia | 11% | 89% | 0% | 17.5 | 95.0 | 0% | 1 |
| Emblema dell'oppressione | `operaio_posseduto` | casuale | 7% | 93% | 0% | 26.0 | 97.2 | 0% | 1 |
| Orrore di Meridia | `orrore_di_meridia` | attacca | 0% | 100% | 0% | 10.8 | 100.0 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | difendi | 0% | 0% | 100% | 61.0 | 13.5 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | studia | 0% | 100% | 0% | 10.6 | 100.0 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | casuale | 0% | 100% | 0% | 15.7 | 100.0 | 0% | 0 |
| Sacerdote Folle | `sacerdote_folle` | attacca | 6% | 94% | 0% | 10.1 | 96.0 | 0% | 1 |
| Sacerdote Folle | `sacerdote_folle` | difendi | 0% | 0% | 100% | 61.0 | 12.0 | 0% | 0 |
| Sacerdote Folle | `sacerdote_folle` | studia | 2% | 98% | 0% | 10.2 | 99.0 | 0% | 0 |
| Sacerdote Folle | `sacerdote_folle` | casuale | 1% | 99% | 0% | 14.0 | 99.1 | 0% | 0 |
| Sadico | `sadico` | attacca | 14% | 86% | 0% | 11.9 | 93.8 | 0% | 1 |
| Sadico | `sadico` | difendi | 0% | 0% | 100% | 61.0 | 14.5 | 0% | 0 |
| Sadico | `sadico` | studia | 9% | 91% | 0% | 12.1 | 96.9 | 0% | 1 |
| Sadico | `sadico` | casuale | 5% | 95% | 0% | 17.9 | 98.8 | 0% | 0 |
| Slime Infimo | `slime_infimo` | attacca | 100% | 0% | 0% | 4.7 | 10.6 | 0% | 2 |
| Slime Infimo | `slime_infimo` | difendi | 0% | 0% | 100% | 61.0 | 0.1 | 0% | 0 |
| Slime Infimo | `slime_infimo` | studia | 100% | 0% | 0% | 7.8 | 19.4 | 0% | 2 |
| Slime Infimo | `slime_infimo` | casuale | 100% | 0% | 0% | 14.6 | 25.2 | 0% | 2 |
| Stigma | `stigma` | attacca | 9% | 91% | 0% | 11.8 | 95.8 | 0% | 1 |
| Stigma | `stigma` | difendi | 0% | 0% | 100% | 61.0 | 22.5 | 0% | 0 |
| Stigma | `stigma` | studia | 5% | 95% | 0% | 12.1 | 98.3 | 0% | 0 |
| Stigma | `stigma` | casuale | 4% | 96% | 0% | 17.1 | 98.7 | 0% | 0 |
| Tartaruga Innocente | `tartaruga_innocente` | attacca | 49% | 0% | 51% | 46.3 | 0.0 | 0% | 7 |
| Tartaruga Innocente | `tartaruga_innocente` | difendi | 0% | 0% | 100% | 61.0 | 0.0 | 0% | 0 |
| Tartaruga Innocente | `tartaruga_innocente` | studia | 100% | 0% | 0% | 1.0 | 0.0 | 100% | 19 |
| Tartaruga Innocente | `tartaruga_innocente` | casuale | 100% | 0% | 0% | 3.0 | 0.0 | 99% | 19 |
| Un tenero ricordo | `tenero_ricordo` | attacca | 0% | 100% | 0% | 7.2 | 100.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | difendi | 0% | 100% | 0% | 9.7 | 100.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | studia | 0% | 100% | 0% | 7.1 | 100.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | casuale | 0% | 100% | 0% | 7.6 | 100.0 | 0% | 0 |
| Teschio Errante | `teschio_errante` | attacca | 12% | 88% | 0% | 16.9 | 93.8 | 0% | 1 |
| Teschio Errante | `teschio_errante` | difendi | 0% | 0% | 100% | 61.0 | 6.0 | 0% | 0 |
| Teschio Errante | `teschio_errante` | studia | 11% | 89% | 0% | 17.4 | 96.6 | 0% | 1 |
| Teschio Errante | `teschio_errante` | casuale | 7% | 93% | 0% | 25.3 | 97.1 | 0% | 1 |
| Titano Zombie | `titano_zombie` | attacca | 0% | 100% | 0% | 12.1 | 100.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | difendi | 0% | 100% | 0% | 17.9 | 100.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | studia | 0% | 100% | 0% | 10.9 | 100.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | casuale | 0% | 100% | 0% | 11.0 | 100.0 | 0% | 0 |
| Capocantiere | `voce_registrata` | attacca | 21% | 79% | 0% | 16.8 | 93.4 | 0% | 2 |
| Capocantiere | `voce_registrata` | difendi | 0% | 0% | 100% | 61.0 | 6.0 | 0% | 0 |
| Capocantiere | `voce_registrata` | studia | 11% | 89% | 0% | 17.4 | 96.6 | 0% | 1 |
| Capocantiere | `voce_registrata` | casuale | 7% | 93% | 0% | 25.3 | 97.1 | 0% | 1 |
| Zombie Cittadino | `zombie_cittadino` | attacca | 100% | 0% | 0% | 4.7 | 10.6 | 0% | 6 |
| Zombie Cittadino | `zombie_cittadino` | difendi | 0% | 0% | 100% | 61.0 | 0.1 | 0% | 0 |
| Zombie Cittadino | `zombie_cittadino` | studia | 100% | 0% | 0% | 7.7 | 19.0 | 0% | 6 |
| Zombie Cittadino | `zombie_cittadino` | casuale | 100% | 0% | 0% | 14.3 | 24.8 | 0% | 6 |
| Zombie Mostruoso | `zombie_mostruoso` | attacca | 100% | 0% | 0% | 11.4 | 58.5 | 0% | 12 |
| Zombie Mostruoso | `zombie_mostruoso` | difendi | 0% | 0% | 100% | 61.0 | 0.5 | 0% | 0 |
| Zombie Mostruoso | `zombie_mostruoso` | studia | 100% | 0% | 0% | 14.6 | 77.5 | 0% | 12 |
| Zombie Mostruoso | `zombie_mostruoso` | casuale | 14% | 86% | 0% | 26.2 | 96.5 | 0% | 2 |

## Protagonista di livello 2

| creatura | id | come si gioca | vinte | perse | ∞ | giri | danno | risp. | xp |
|---|---|---|--:|--:|--:|--:|--:|--:|--:|
| Abominio Marcio | `abominio_marcio` | attacca | 0% | 100% | 0% | 13.9 | 100.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | difendi | 0% | 0% | 100% | 61.0 | 13.2 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | studia | 0% | 100% | 0% | 14.0 | 100.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | casuale | 0% | 100% | 0% | 20.1 | 100.0 | 0% | 0 |
| Oppresso | `comparsa_di_ruggine` | attacca | 63% | 37% | 0% | 17.5 | 83.6 | 0% | 6 |
| Oppresso | `comparsa_di_ruggine` | difendi | 0% | 0% | 100% | 61.0 | 0.5 | 0% | 0 |
| Oppresso | `comparsa_di_ruggine` | studia | 25% | 75% | 0% | 19.6 | 93.3 | 0% | 3 |
| Oppresso | `comparsa_di_ruggine` | casuale | 8% | 92% | 0% | 28.7 | 96.4 | 0% | 1 |
| Diabolo | `diabolo` | attacca | 14% | 86% | 0% | 19.0 | 92.9 | 0% | 1 |
| Diabolo | `diabolo` | difendi | 0% | 0% | 100% | 61.0 | 5.2 | 0% | 0 |
| Diabolo | `diabolo` | studia | 13% | 87% | 0% | 19.3 | 95.8 | 0% | 1 |
| Diabolo | `diabolo` | casuale | 7% | 93% | 0% | 28.3 | 96.6 | 0% | 1 |
| Il Divoratore | `divoratore` | attacca | 0% | 100% | 0% | 13.9 | 100.0 | 0% | 0 |
| Il Divoratore | `divoratore` | difendi | 0% | 0% | 100% | 61.0 | 13.2 | 0% | 0 |
| Il Divoratore | `divoratore` | studia | 0% | 100% | 0% | 14.0 | 100.0 | 0% | 0 |
| Il Divoratore | `divoratore` | casuale | 0% | 100% | 0% | 20.1 | 100.0 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | attacca | 13% | 87% | 0% | 11.6 | 93.4 | 0% | 2 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | difendi | 0% | 0% | 100% | 61.0 | 9.3 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | studia | 13% | 87% | 0% | 11.9 | 95.5 | 0% | 2 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | casuale | 5% | 95% | 0% | 18.7 | 98.3 | 0% | 1 |
| Ferraglia Urlante | `ferraglia_urlante` | attacca | 0% | 100% | 0% | 20.4 | 100.0 | 0% | 0 |
| Ferraglia Urlante | `ferraglia_urlante` | difendi | 0% | 0% | 100% | 61.0 | 0.5 | 0% | 0 |
| Ferraglia Urlante | `ferraglia_urlante` | studia | 0% | 100% | 0% | 20.7 | 100.0 | 0% | 0 |
| Ferraglia Urlante | `ferraglia_urlante` | casuale | 0% | 100% | 0% | 30.0 | 100.0 | 0% | 0 |
| Ghoul | `ghoul` | attacca | 29% | 71% | 0% | 18.1 | 87.3 | 0% | 3 |
| Ghoul | `ghoul` | difendi | 0% | 0% | 100% | 61.0 | 0.5 | 0% | 0 |
| Ghoul | `ghoul` | studia | 16% | 84% | 0% | 18.8 | 93.0 | 0% | 1 |
| Ghoul | `ghoul` | casuale | 8% | 92% | 0% | 29.2 | 96.5 | 0% | 1 |
| El Muy Bonito | `giocoliere` | attacca | 100% | 0% | 0% | 7.7 | 40.2 | 0% | 18 |
| El Muy Bonito | `giocoliere` | difendi | 0% | 0% | 100% | 61.0 | 6.5 | 0% | 0 |
| El Muy Bonito | `giocoliere` | studia | 15% | 85% | 0% | 8.6 | 98.0 | 0% | 3 |
| El Muy Bonito | `giocoliere` | casuale | 23% | 77% | 0% | 12.6 | 92.7 | 0% | 4 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | attacca | 35% | 65% | 0% | 12.8 | 95.2 | 0% | 15 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | difendi | 0% | 0% | 100% | 61.0 | 6.9 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | studia | 7% | 93% | 0% | 13.9 | 99.7 | 0% | 3 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | casuale | 0% | 100% | 0% | 20.5 | 100.0 | 0% | 0 |
| Goblin Tipico | `goblin_tipico` | attacca | 100% | 0% | 0% | 2.9 | 4.7 | 0% | 2 |
| Goblin Tipico | `goblin_tipico` | difendi | 0% | 0% | 100% | 61.0 | 0.1 | 0% | 0 |
| Goblin Tipico | `goblin_tipico` | studia | 100% | 0% | 0% | 5.9 | 12.4 | 0% | 2 |
| Goblin Tipico | `goblin_tipico` | casuale | 100% | 0% | 0% | 9.1 | 12.9 | 0% | 2 |
| Infetto Rapido | `infetto_rapido` | attacca | 100% | 0% | 0% | 3.0 | 14.5 | 0% | 7 |
| Infetto Rapido | `infetto_rapido` | difendi | 0% | 0% | 100% | 61.0 | 5.2 | 0% | 0 |
| Infetto Rapido | `infetto_rapido` | studia | 100% | 0% | 0% | 6.0 | 29.8 | 0% | 7 |
| Infetto Rapido | `infetto_rapido` | casuale | 100% | 0% | 0% | 9.3 | 31.6 | 0% | 7 |
| L'ultimo spettacolo di Jerah | `jerah` | attacca | 10% | 90% | 0% | 13.3 | 98.0 | 0% | 5 |
| L'ultimo spettacolo di Jerah | `jerah` | difendi | 0% | 100% | 0% | 22.2 | 100.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | studia | 5% | 95% | 0% | 14.1 | 98.7 | 0% | 2 |
| L'ultimo spettacolo di Jerah | `jerah` | casuale | 2% | 98% | 0% | 17.6 | 99.1 | 0% | 1 |
| Jongo Dongo | `jongo_dongo` | attacca | 0% | 100% | 0% | 13.2 | 100.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | difendi | 0% | 1% | 99% | 61.0 | 41.4 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | studia | 0% | 100% | 0% | 13.3 | 100.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | casuale | 0% | 100% | 0% | 17.4 | 100.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | attacca | 0% | 100% | 0% | 6.1 | 100.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | difendi | 0% | 100% | 0% | 26.3 | 100.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | studia | 0% | 100% | 0% | 6.0 | 100.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | casuale | 0% | 100% | 0% | 7.3 | 100.0 | 0% | 0 |
| ??? | `l_immortale` | attacca | 0% | 100% | 0% | 39.3 | 100.0 | 0% | 0 |
| ??? | `l_immortale` | difendi | 0% | 0% | 100% | 61.0 | 0.1 | 0% | 0 |
| ??? | `l_immortale` | studia | 0% | 100% | 0% | 39.9 | 100.0 | 0% | 0 |
| ??? | `l_immortale` | casuale | 0% | 63% | 37% | 56.6 | 97.0 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | attacca | 28% | 72% | 0% | 18.1 | 87.4 | 0% | 3 |
| Madre in Lacrime | `madre_in_lacrime` | difendi | 0% | 0% | 100% | 61.0 | 0.5 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | studia | 16% | 84% | 0% | 18.8 | 93.0 | 0% | 1 |
| Madre in Lacrime | `madre_in_lacrime` | casuale | 8% | 92% | 0% | 29.2 | 96.5 | 0% | 1 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | attacca | 0% | 100% | 0% | 6.0 | 100.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | difendi | 0% | 100% | 0% | 6.0 | 100.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | studia | 0% | 100% | 0% | 6.0 | 100.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | casuale | 0% | 100% | 0% | 6.0 | 100.0 | 0% | 0 |
| Marionetta | `marionetta` | attacca | 7% | 93% | 0% | 7.0 | 96.4 | 0% | 0 |
| Marionetta | `marionetta` | difendi | 0% | 13% | 87% | 59.4 | 58.2 | 0% | 0 |
| Marionetta | `marionetta` | studia | 3% | 97% | 0% | 7.4 | 98.8 | 0% | 0 |
| Marionetta | `marionetta` | casuale | 1% | 99% | 0% | 8.7 | 99.5 | 0% | 0 |
| Fomentado | `maschera_vuota` | attacca | 100% | 0% | 0% | 3.8 | 7.1 | 0% | 8 |
| Fomentado | `maschera_vuota` | difendi | 100% | 0% | 0% | 17.0 | 0.1 | 0% | 8 |
| Fomentado | `maschera_vuota` | studia | 100% | 0% | 0% | 6.0 | 12.4 | 0% | 8 |
| Fomentado | `maschera_vuota` | casuale | 100% | 0% | 0% | 7.7 | 11.0 | 0% | 8 |
| Ombra del passato | `ombra_del_passato` | attacca | 5% | 95% | 0% | 5.9 | 96.7 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | difendi | 0% | 100% | 0% | 27.5 | 100.0 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | studia | 3% | 97% | 0% | 6.1 | 99.1 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | casuale | 1% | 99% | 0% | 7.2 | 99.6 | 0% | 0 |
| Emblema dell'oppressione | `operaio_posseduto` | attacca | 48% | 52% | 0% | 17.8 | 85.8 | 0% | 6 |
| Emblema dell'oppressione | `operaio_posseduto` | difendi | 0% | 0% | 100% | 61.0 | 0.5 | 0% | 0 |
| Emblema dell'oppressione | `operaio_posseduto` | studia | 19% | 81% | 0% | 19.7 | 93.8 | 0% | 2 |
| Emblema dell'oppressione | `operaio_posseduto` | casuale | 8% | 92% | 0% | 28.7 | 96.4 | 0% | 1 |
| Orrore di Meridia | `orrore_di_meridia` | attacca | 0% | 100% | 0% | 12.0 | 100.0 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | difendi | 0% | 0% | 100% | 61.0 | 12.2 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | studia | 0% | 100% | 0% | 11.9 | 100.0 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | casuale | 0% | 100% | 0% | 17.8 | 100.0 | 0% | 0 |
| Sacerdote Folle | `sacerdote_folle` | attacca | 6% | 94% | 0% | 10.9 | 95.7 | 0% | 1 |
| Sacerdote Folle | `sacerdote_folle` | difendi | 0% | 0% | 100% | 61.0 | 10.8 | 0% | 0 |
| Sacerdote Folle | `sacerdote_folle` | studia | 2% | 98% | 0% | 11.2 | 98.9 | 0% | 0 |
| Sacerdote Folle | `sacerdote_folle` | casuale | 1% | 99% | 0% | 15.2 | 99.0 | 0% | 0 |
| Sadico | `sadico` | attacca | 16% | 84% | 0% | 13.1 | 92.8 | 0% | 2 |
| Sadico | `sadico` | difendi | 0% | 0% | 100% | 61.0 | 13.2 | 0% | 0 |
| Sadico | `sadico` | studia | 10% | 90% | 0% | 13.4 | 96.5 | 0% | 1 |
| Sadico | `sadico` | casuale | 7% | 93% | 0% | 20.1 | 98.6 | 0% | 1 |
| Slime Infimo | `slime_infimo` | attacca | 100% | 0% | 0% | 3.8 | 7.1 | 0% | 2 |
| Slime Infimo | `slime_infimo` | difendi | 0% | 0% | 100% | 61.0 | 0.1 | 0% | 0 |
| Slime Infimo | `slime_infimo` | studia | 100% | 0% | 0% | 6.9 | 14.9 | 0% | 2 |
| Slime Infimo | `slime_infimo` | casuale | 100% | 0% | 0% | 12.2 | 18.3 | 0% | 2 |
| Stigma | `stigma` | attacca | 11% | 89% | 0% | 13.2 | 95.2 | 0% | 1 |
| Stigma | `stigma` | difendi | 0% | 0% | 100% | 61.0 | 20.1 | 0% | 0 |
| Stigma | `stigma` | studia | 5% | 95% | 0% | 13.6 | 97.9 | 0% | 0 |
| Stigma | `stigma` | casuale | 6% | 94% | 0% | 19.2 | 98.1 | 0% | 1 |
| Tartaruga Innocente | `tartaruga_innocente` | attacca | 49% | 0% | 51% | 46.3 | 0.0 | 0% | 6 |
| Tartaruga Innocente | `tartaruga_innocente` | difendi | 0% | 0% | 100% | 61.0 | 0.0 | 0% | 0 |
| Tartaruga Innocente | `tartaruga_innocente` | studia | 100% | 0% | 0% | 1.0 | 0.0 | 100% | 16 |
| Tartaruga Innocente | `tartaruga_innocente` | casuale | 100% | 0% | 0% | 3.0 | 0.0 | 99% | 16 |
| Un tenero ricordo | `tenero_ricordo` | attacca | 0% | 100% | 0% | 7.5 | 100.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | difendi | 0% | 100% | 0% | 9.7 | 100.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | studia | 0% | 100% | 0% | 7.3 | 100.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | casuale | 0% | 100% | 0% | 7.8 | 100.0 | 0% | 0 |
| Teschio Errante | `teschio_errante` | attacca | 27% | 73% | 0% | 18.7 | 92.0 | 0% | 2 |
| Teschio Errante | `teschio_errante` | difendi | 0% | 0% | 100% | 61.0 | 5.2 | 0% | 0 |
| Teschio Errante | `teschio_errante` | studia | 14% | 86% | 0% | 19.3 | 95.7 | 0% | 1 |
| Teschio Errante | `teschio_errante` | casuale | 7% | 93% | 0% | 28.3 | 96.6 | 0% | 1 |
| Titano Zombie | `titano_zombie` | attacca | 0% | 100% | 0% | 12.7 | 100.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | difendi | 0% | 100% | 0% | 18.1 | 100.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | studia | 0% | 100% | 0% | 11.7 | 100.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | casuale | 0% | 100% | 0% | 11.5 | 100.0 | 0% | 0 |
| Capocantiere | `voce_registrata` | attacca | 100% | 0% | 0% | 12.7 | 64.4 | 0% | 9 |
| Capocantiere | `voce_registrata` | difendi | 0% | 0% | 100% | 61.0 | 5.2 | 0% | 0 |
| Capocantiere | `voce_registrata` | studia | 95% | 5% | 0% | 15.9 | 80.7 | 0% | 9 |
| Capocantiere | `voce_registrata` | casuale | 15% | 85% | 0% | 28.0 | 95.6 | 0% | 1 |
| Zombie Cittadino | `zombie_cittadino` | attacca | 100% | 0% | 0% | 3.8 | 7.1 | 0% | 6 |
| Zombie Cittadino | `zombie_cittadino` | difendi | 0% | 0% | 100% | 61.0 | 0.1 | 0% | 0 |
| Zombie Cittadino | `zombie_cittadino` | studia | 100% | 0% | 0% | 6.8 | 14.7 | 0% | 6 |
| Zombie Cittadino | `zombie_cittadino` | casuale | 100% | 0% | 0% | 11.6 | 17.5 | 0% | 6 |
| Zombie Mostruoso | `zombie_mostruoso` | attacca | 100% | 0% | 0% | 8.9 | 40.1 | 0% | 12 |
| Zombie Mostruoso | `zombie_mostruoso` | difendi | 0% | 0% | 100% | 61.0 | 0.5 | 0% | 0 |
| Zombie Mostruoso | `zombie_mostruoso` | studia | 100% | 0% | 0% | 12.0 | 56.7 | 0% | 12 |
| Zombie Mostruoso | `zombie_mostruoso` | casuale | 65% | 35% | 0% | 25.9 | 84.0 | 0% | 8 |

## Protagonista di livello 3

| creatura | id | come si gioca | vinte | perse | ∞ | giri | danno | risp. | xp |
|---|---|---|--:|--:|--:|--:|--:|--:|--:|
| Abominio Marcio | `abominio_marcio` | attacca | 6% | 94% | 0% | 15.7 | 99.8 | 0% | 1 |
| Abominio Marcio | `abominio_marcio` | difendi | 0% | 0% | 100% | 61.0 | 11.1 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | studia | 1% | 99% | 0% | 16.2 | 100.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | casuale | 0% | 100% | 0% | 23.0 | 100.0 | 0% | 0 |
| Oppresso | `comparsa_di_ruggine` | attacca | 100% | 0% | 0% | 13.3 | 54.1 | 0% | 10 |
| Oppresso | `comparsa_di_ruggine` | difendi | 0% | 0% | 100% | 61.0 | 0.4 | 0% | 0 |
| Oppresso | `comparsa_di_ruggine` | studia | 99% | 1% | 0% | 16.7 | 68.6 | 0% | 10 |
| Oppresso | `comparsa_di_ruggine` | casuale | 21% | 79% | 0% | 31.9 | 94.2 | 0% | 2 |
| Diabolo | `diabolo` | attacca | 43% | 57% | 0% | 20.7 | 90.0 | 0% | 3 |
| Diabolo | `diabolo` | difendi | 0% | 0% | 100% | 61.0 | 4.4 | 0% | 0 |
| Diabolo | `diabolo` | studia | 21% | 79% | 0% | 21.6 | 94.6 | 0% | 2 |
| Diabolo | `diabolo` | casuale | 9% | 91% | 0% | 32.2 | 95.9 | 0% | 1 |
| Il Divoratore | `divoratore` | attacca | 0% | 100% | 0% | 15.7 | 100.0 | 0% | 0 |
| Il Divoratore | `divoratore` | difendi | 0% | 0% | 100% | 61.0 | 11.1 | 0% | 0 |
| Il Divoratore | `divoratore` | studia | 0% | 100% | 0% | 16.2 | 100.0 | 0% | 0 |
| Il Divoratore | `divoratore` | casuale | 0% | 100% | 0% | 23.0 | 100.0 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | attacca | 15% | 85% | 0% | 13.1 | 92.8 | 0% | 3 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | difendi | 0% | 0% | 100% | 61.0 | 8.0 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | studia | 16% | 84% | 0% | 13.3 | 94.3 | 0% | 3 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | casuale | 7% | 93% | 0% | 20.8 | 97.8 | 0% | 1 |
| Ferraglia Urlante | `ferraglia_urlante` | attacca | 25% | 75% | 0% | 22.6 | 97.1 | 0% | 4 |
| Ferraglia Urlante | `ferraglia_urlante` | difendi | 0% | 0% | 100% | 61.0 | 0.4 | 0% | 0 |
| Ferraglia Urlante | `ferraglia_urlante` | studia | 7% | 93% | 0% | 23.4 | 99.5 | 0% | 1 |
| Ferraglia Urlante | `ferraglia_urlante` | casuale | 0% | 100% | 0% | 34.3 | 100.0 | 0% | 0 |
| Ghoul | `ghoul` | attacca | 99% | 1% | 0% | 16.6 | 67.7 | 0% | 9 |
| Ghoul | `ghoul` | difendi | 0% | 0% | 100% | 61.0 | 0.4 | 0% | 0 |
| Ghoul | `ghoul` | studia | 68% | 32% | 0% | 19.4 | 83.7 | 0% | 6 |
| Ghoul | `ghoul` | casuale | 11% | 89% | 0% | 32.7 | 95.9 | 0% | 1 |
| El Muy Bonito | `giocoliere` | attacca | 100% | 0% | 0% | 6.0 | 28.0 | 0% | 18 |
| El Muy Bonito | `giocoliere` | difendi | 0% | 0% | 100% | 61.0 | 5.8 | 0% | 0 |
| El Muy Bonito | `giocoliere` | studia | 79% | 21% | 0% | 8.0 | 80.4 | 0% | 14 |
| El Muy Bonito | `giocoliere` | casuale | 43% | 57% | 0% | 12.3 | 83.2 | 0% | 8 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | attacca | 99% | 1% | 0% | 11.5 | 69.5 | 0% | 41 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | difendi | 0% | 0% | 100% | 61.0 | 6.0 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | studia | 57% | 43% | 0% | 15.1 | 91.4 | 0% | 23 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | casuale | 2% | 98% | 0% | 22.9 | 99.9 | 0% | 1 |
| Goblin Tipico | `goblin_tipico` | attacca | 100% | 0% | 0% | 2.0 | 2.1 | 0% | 1 |
| Goblin Tipico | `goblin_tipico` | difendi | 0% | 0% | 100% | 61.0 | 0.0 | 0% | 0 |
| Goblin Tipico | `goblin_tipico` | studia | 100% | 0% | 0% | 5.0 | 8.5 | 0% | 1 |
| Goblin Tipico | `goblin_tipico` | casuale | 100% | 0% | 0% | 6.4 | 7.4 | 0% | 1 |
| Infetto Rapido | `infetto_rapido` | attacca | 100% | 0% | 0% | 2.9 | 12.0 | 0% | 6 |
| Infetto Rapido | `infetto_rapido` | difendi | 0% | 0% | 100% | 61.0 | 4.4 | 0% | 0 |
| Infetto Rapido | `infetto_rapido` | studia | 100% | 0% | 0% | 5.9 | 26.0 | 0% | 6 |
| Infetto Rapido | `infetto_rapido` | casuale | 100% | 0% | 0% | 8.9 | 26.6 | 0% | 6 |
| L'ultimo spettacolo di Jerah | `jerah` | attacca | 43% | 57% | 0% | 13.1 | 91.5 | 0% | 21 |
| L'ultimo spettacolo di Jerah | `jerah` | difendi | 0% | 100% | 0% | 22.2 | 100.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | studia | 17% | 83% | 0% | 14.5 | 96.4 | 0% | 8 |
| L'ultimo spettacolo di Jerah | `jerah` | casuale | 4% | 96% | 0% | 18.0 | 98.4 | 0% | 2 |
| Jongo Dongo | `jongo_dongo` | attacca | 0% | 100% | 0% | 14.4 | 100.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | difendi | 0% | 1% | 99% | 61.0 | 36.3 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | studia | 0% | 100% | 0% | 14.9 | 100.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | casuale | 0% | 100% | 0% | 19.6 | 100.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | attacca | 0% | 100% | 0% | 6.9 | 100.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | difendi | 0% | 100% | 0% | 30.9 | 100.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | studia | 0% | 100% | 0% | 6.8 | 100.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | casuale | 0% | 100% | 0% | 8.2 | 100.0 | 0% | 0 |
| ??? | `l_immortale` | attacca | 0% | 100% | 0% | 44.6 | 100.0 | 0% | 0 |
| ??? | `l_immortale` | difendi | 0% | 0% | 100% | 61.0 | 0.0 | 0% | 0 |
| ??? | `l_immortale` | studia | 0% | 100% | 0% | 45.3 | 100.0 | 0% | 0 |
| ??? | `l_immortale` | casuale | 0% | 22% | 78% | 59.8 | 89.5 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | attacca | 51% | 49% | 0% | 20.0 | 83.1 | 0% | 5 |
| Madre in Lacrime | `madre_in_lacrime` | difendi | 0% | 0% | 100% | 61.0 | 0.4 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | studia | 20% | 80% | 0% | 21.0 | 91.3 | 0% | 2 |
| Madre in Lacrime | `madre_in_lacrime` | casuale | 10% | 90% | 0% | 32.7 | 95.9 | 0% | 1 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | attacca | 0% | 100% | 0% | 6.0 | 100.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | difendi | 0% | 100% | 0% | 6.0 | 100.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | studia | 0% | 100% | 0% | 6.0 | 100.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | casuale | 0% | 100% | 0% | 6.0 | 100.0 | 0% | 0 |
| Marionetta | `marionetta` | attacca | 8% | 92% | 0% | 8.1 | 96.1 | 0% | 0 |
| Marionetta | `marionetta` | difendi | 0% | 8% | 92% | 59.8 | 50.2 | 0% | 0 |
| Marionetta | `marionetta` | studia | 4% | 96% | 0% | 8.3 | 98.3 | 0% | 0 |
| Marionetta | `marionetta` | casuale | 1% | 99% | 0% | 9.9 | 99.3 | 0% | 0 |
| Fomentado | `maschera_vuota` | attacca | 100% | 0% | 0% | 3.0 | 4.3 | 0% | 8 |
| Fomentado | `maschera_vuota` | difendi | 100% | 0% | 0% | 17.0 | 0.0 | 0% | 8 |
| Fomentado | `maschera_vuota` | studia | 100% | 0% | 0% | 5.9 | 10.8 | 0% | 8 |
| Fomentado | `maschera_vuota` | casuale | 100% | 0% | 0% | 7.0 | 8.7 | 0% | 8 |
| Ombra del passato | `ombra_del_passato` | attacca | 5% | 95% | 0% | 6.7 | 96.6 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | difendi | 0% | 100% | 0% | 32.1 | 100.0 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | studia | 4% | 96% | 0% | 7.0 | 98.7 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | casuale | 1% | 99% | 0% | 8.3 | 99.4 | 0% | 0 |
| Emblema dell'oppressione | `operaio_posseduto` | attacca | 100% | 0% | 0% | 14.1 | 57.6 | 0% | 12 |
| Emblema dell'oppressione | `operaio_posseduto` | difendi | 0% | 0% | 100% | 61.0 | 0.4 | 0% | 0 |
| Emblema dell'oppressione | `operaio_posseduto` | studia | 99% | 1% | 0% | 17.6 | 72.2 | 0% | 12 |
| Emblema dell'oppressione | `operaio_posseduto` | casuale | 17% | 83% | 0% | 32.0 | 94.8 | 0% | 2 |
| Orrore di Meridia | `orrore_di_meridia` | attacca | 47% | 53% | 0% | 12.8 | 92.7 | 0% | 9 |
| Orrore di Meridia | `orrore_di_meridia` | difendi | 0% | 0% | 100% | 61.0 | 10.8 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | studia | 13% | 87% | 0% | 13.5 | 98.6 | 0% | 3 |
| Orrore di Meridia | `orrore_di_meridia` | casuale | 0% | 100% | 0% | 20.1 | 100.0 | 0% | 0 |
| Sacerdote Folle | `sacerdote_folle` | attacca | 6% | 94% | 0% | 12.1 | 95.5 | 0% | 1 |
| Sacerdote Folle | `sacerdote_folle` | difendi | 0% | 0% | 100% | 61.0 | 9.4 | 0% | 0 |
| Sacerdote Folle | `sacerdote_folle` | studia | 3% | 97% | 0% | 12.4 | 98.7 | 0% | 1 |
| Sacerdote Folle | `sacerdote_folle` | casuale | 1% | 99% | 0% | 16.7 | 99.0 | 0% | 0 |
| Sadico | `sadico` | attacca | 38% | 62% | 0% | 14.6 | 90.2 | 0% | 4 |
| Sadico | `sadico` | difendi | 0% | 0% | 100% | 61.0 | 11.1 | 0% | 0 |
| Sadico | `sadico` | studia | 16% | 84% | 0% | 15.1 | 95.3 | 0% | 2 |
| Sadico | `sadico` | casuale | 7% | 93% | 0% | 22.6 | 98.0 | 0% | 1 |
| Slime Infimo | `slime_infimo` | attacca | 100% | 0% | 0% | 3.0 | 4.3 | 0% | 1 |
| Slime Infimo | `slime_infimo` | difendi | 0% | 0% | 100% | 61.0 | 0.0 | 0% | 0 |
| Slime Infimo | `slime_infimo` | studia | 100% | 0% | 0% | 6.0 | 10.8 | 0% | 1 |
| Slime Infimo | `slime_infimo` | casuale | 100% | 0% | 0% | 9.3 | 11.9 | 0% | 1 |
| Stigma | `stigma` | attacca | 29% | 71% | 0% | 14.9 | 93.8 | 0% | 3 |
| Stigma | `stigma` | difendi | 0% | 0% | 100% | 61.0 | 17.0 | 0% | 0 |
| Stigma | `stigma` | studia | 6% | 94% | 0% | 15.4 | 97.6 | 0% | 1 |
| Stigma | `stigma` | casuale | 7% | 93% | 0% | 22.1 | 97.6 | 0% | 1 |
| Tartaruga Innocente | `tartaruga_innocente` | attacca | 49% | 0% | 51% | 46.3 | 0.0 | 0% | 5 |
| Tartaruga Innocente | `tartaruga_innocente` | difendi | 0% | 0% | 100% | 61.0 | 0.0 | 0% | 0 |
| Tartaruga Innocente | `tartaruga_innocente` | studia | 100% | 0% | 0% | 1.0 | 0.0 | 100% | 14 |
| Tartaruga Innocente | `tartaruga_innocente` | casuale | 100% | 0% | 0% | 3.0 | 0.0 | 99% | 14 |
| Un tenero ricordo | `tenero_ricordo` | attacca | 0% | 100% | 0% | 7.7 | 100.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | difendi | 0% | 100% | 0% | 9.7 | 100.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | studia | 0% | 100% | 0% | 7.6 | 100.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | casuale | 0% | 100% | 0% | 8.2 | 100.0 | 0% | 0 |
| Teschio Errante | `teschio_errante` | attacca | 100% | 0% | 0% | 14.4 | 63.5 | 0% | 8 |
| Teschio Errante | `teschio_errante` | difendi | 0% | 0% | 100% | 61.0 | 4.4 | 0% | 0 |
| Teschio Errante | `teschio_errante` | studia | 93% | 7% | 0% | 17.6 | 78.7 | 0% | 7 |
| Teschio Errante | `teschio_errante` | casuale | 16% | 84% | 0% | 31.9 | 95.2 | 0% | 1 |
| Titano Zombie | `titano_zombie` | attacca | 0% | 100% | 0% | 13.1 | 100.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | difendi | 0% | 100% | 0% | 18.1 | 100.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | studia | 0% | 100% | 0% | 12.4 | 100.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | casuale | 0% | 100% | 0% | 12.2 | 100.0 | 0% | 0 |
| Capocantiere | `voce_registrata` | attacca | 100% | 0% | 0% | 10.0 | 43.6 | 0% | 9 |
| Capocantiere | `voce_registrata` | difendi | 0% | 0% | 100% | 61.0 | 4.4 | 0% | 0 |
| Capocantiere | `voce_registrata` | studia | 100% | 0% | 0% | 13.2 | 59.0 | 0% | 9 |
| Capocantiere | `voce_registrata` | casuale | 60% | 40% | 0% | 28.5 | 85.2 | 0% | 5 |
| Zombie Cittadino | `zombie_cittadino` | attacca | 100% | 0% | 0% | 3.0 | 4.3 | 0% | 5 |
| Zombie Cittadino | `zombie_cittadino` | difendi | 0% | 0% | 100% | 61.0 | 0.0 | 0% | 0 |
| Zombie Cittadino | `zombie_cittadino` | studia | 100% | 0% | 0% | 6.0 | 11.0 | 0% | 5 |
| Zombie Cittadino | `zombie_cittadino` | casuale | 100% | 0% | 0% | 8.9 | 11.3 | 0% | 5 |
| Zombie Mostruoso | `zombie_mostruoso` | attacca | 100% | 0% | 0% | 7.4 | 28.1 | 0% | 12 |
| Zombie Mostruoso | `zombie_mostruoso` | difendi | 0% | 0% | 100% | 61.0 | 0.4 | 0% | 0 |
| Zombie Mostruoso | `zombie_mostruoso` | studia | 100% | 0% | 0% | 10.5 | 42.2 | 0% | 12 |
| Zombie Mostruoso | `zombie_mostruoso` | casuale | 91% | 9% | 0% | 23.2 | 65.9 | 0% | 11 |

## Protagonista di livello 5

| creatura | id | come si gioca | vinte | perse | ∞ | giri | danno | risp. | xp |
|---|---|---|--:|--:|--:|--:|--:|--:|--:|
| Abominio Marcio | `abominio_marcio` | attacca | 99% | 1% | 0% | 13.3 | 59.4 | 0% | 16 |
| Abominio Marcio | `abominio_marcio` | difendi | 0% | 0% | 100% | 61.0 | 7.8 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | studia | 94% | 6% | 0% | 16.2 | 71.2 | 0% | 15 |
| Abominio Marcio | `abominio_marcio` | casuale | 25% | 75% | 0% | 30.9 | 96.4 | 0% | 4 |
| Oppresso | `comparsa_di_ruggine` | attacca | 100% | 0% | 0% | 8.3 | 22.6 | 0% | 9 |
| Oppresso | `comparsa_di_ruggine` | difendi | 0% | 0% | 100% | 61.0 | 0.2 | 0% | 0 |
| Oppresso | `comparsa_di_ruggine` | studia | 100% | 0% | 0% | 11.5 | 32.8 | 0% | 9 |
| Oppresso | `comparsa_di_ruggine` | casuale | 99% | 1% | 0% | 25.5 | 53.7 | 0% | 9 |
| Diabolo | `diabolo` | attacca | 100% | 0% | 0% | 12.6 | 40.3 | 0% | 8 |
| Diabolo | `diabolo` | difendi | 0% | 0% | 100% | 61.0 | 3.1 | 0% | 0 |
| Diabolo | `diabolo` | studia | 100% | 0% | 0% | 15.8 | 50.6 | 0% | 8 |
| Diabolo | `diabolo` | casuale | 77% | 23% | 0% | 36.2 | 78.4 | 0% | 6 |
| Il Divoratore | `divoratore` | attacca | 79% | 21% | 0% | 17.3 | 79.3 | 0% | 16 |
| Il Divoratore | `divoratore` | difendi | 0% | 0% | 100% | 61.0 | 7.8 | 0% | 0 |
| Il Divoratore | `divoratore` | studia | 65% | 35% | 0% | 19.8 | 87.8 | 0% | 13 |
| Il Divoratore | `divoratore` | casuale | 3% | 97% | 0% | 31.9 | 99.6 | 0% | 1 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | attacca | 20% | 80% | 0% | 17.7 | 89.5 | 0% | 4 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | difendi | 0% | 0% | 100% | 61.0 | 5.9 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | studia | 20% | 80% | 0% | 17.7 | 91.2 | 0% | 4 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | casuale | 9% | 91% | 0% | 28.4 | 96.2 | 0% | 2 |
| Ferraglia Urlante | `ferraglia_urlante` | attacca | 100% | 0% | 0% | 14.0 | 41.4 | 0% | 16 |
| Ferraglia Urlante | `ferraglia_urlante` | difendi | 0% | 0% | 100% | 61.0 | 0.2 | 0% | 0 |
| Ferraglia Urlante | `ferraglia_urlante` | studia | 100% | 0% | 0% | 17.1 | 49.9 | 0% | 16 |
| Ferraglia Urlante | `ferraglia_urlante` | casuale | 69% | 29% | 2% | 40.1 | 83.0 | 0% | 11 |
| Ghoul | `ghoul` | attacca | 100% | 0% | 0% | 10.9 | 30.1 | 0% | 9 |
| Ghoul | `ghoul` | difendi | 0% | 0% | 100% | 61.0 | 0.2 | 0% | 0 |
| Ghoul | `ghoul` | studia | 100% | 0% | 0% | 14.0 | 42.1 | 0% | 9 |
| Ghoul | `ghoul` | casuale | 89% | 11% | 0% | 33.5 | 69.4 | 0% | 8 |
| El Muy Bonito | `giocoliere` | attacca | 100% | 0% | 0% | 4.8 | 16.3 | 0% | 18 |
| El Muy Bonito | `giocoliere` | difendi | 0% | 0% | 100% | 61.0 | 4.2 | 0% | 0 |
| El Muy Bonito | `giocoliere` | studia | 100% | 0% | 0% | 7.0 | 46.8 | 0% | 18 |
| El Muy Bonito | `giocoliere` | casuale | 81% | 19% | 0% | 11.0 | 53.1 | 0% | 15 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | attacca | 100% | 0% | 0% | 9.1 | 47.4 | 0% | 41 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | difendi | 0% | 0% | 100% | 61.0 | 4.4 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | studia | 97% | 3% | 0% | 14.5 | 66.0 | 0% | 39 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | casuale | 16% | 84% | 0% | 24.1 | 97.1 | 0% | 7 |
| Goblin Tipico | `goblin_tipico` | attacca | 100% | 0% | 0% | 2.0 | 1.4 | 0% | 1 |
| Goblin Tipico | `goblin_tipico` | difendi | 0% | 0% | 100% | 61.0 | 0.0 | 0% | 0 |
| Goblin Tipico | `goblin_tipico` | studia | 100% | 0% | 0% | 5.0 | 6.2 | 0% | 1 |
| Goblin Tipico | `goblin_tipico` | casuale | 100% | 0% | 0% | 6.4 | 5.5 | 0% | 1 |
| Infetto Rapido | `infetto_rapido` | attacca | 100% | 0% | 0% | 2.0 | 6.0 | 0% | 4 |
| Infetto Rapido | `infetto_rapido` | difendi | 0% | 0% | 100% | 61.0 | 3.1 | 0% | 0 |
| Infetto Rapido | `infetto_rapido` | studia | 100% | 0% | 0% | 5.0 | 16.3 | 0% | 4 |
| Infetto Rapido | `infetto_rapido` | casuale | 100% | 0% | 0% | 5.8 | 12.1 | 0% | 4 |
| L'ultimo spettacolo di Jerah | `jerah` | attacca | 95% | 5% | 0% | 10.5 | 57.8 | 0% | 48 |
| L'ultimo spettacolo di Jerah | `jerah` | difendi | 0% | 100% | 0% | 22.2 | 100.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | studia | 49% | 51% | 0% | 14.1 | 85.3 | 0% | 24 |
| L'ultimo spettacolo di Jerah | `jerah` | casuale | 15% | 85% | 0% | 18.4 | 93.6 | 0% | 8 |
| Jongo Dongo | `jongo_dongo` | attacca | 0% | 100% | 0% | 18.1 | 100.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | difendi | 0% | 0% | 100% | 61.0 | 26.5 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | studia | 0% | 100% | 0% | 18.8 | 100.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | casuale | 0% | 100% | 0% | 25.0 | 100.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | attacca | 0% | 100% | 0% | 9.8 | 100.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | difendi | 0% | 96% | 4% | 43.2 | 99.6 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | studia | 0% | 100% | 0% | 9.4 | 100.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | casuale | 0% | 100% | 0% | 11.3 | 100.0 | 0% | 0 |
| ??? | `l_immortale` | attacca | 0% | 49% | 51% | 58.3 | 94.9 | 0% | 0 |
| ??? | `l_immortale` | difendi | 0% | 0% | 100% | 61.0 | 0.0 | 0% | 0 |
| ??? | `l_immortale` | studia | 0% | 37% | 63% | 58.9 | 93.8 | 0% | 0 |
| ??? | `l_immortale` | casuale | 0% | 0% | 100% | 61.0 | 65.8 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | attacca | 100% | 0% | 0% | 13.1 | 37.4 | 0% | 9 |
| Madre in Lacrime | `madre_in_lacrime` | difendi | 0% | 0% | 100% | 61.0 | 0.2 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | studia | 100% | 0% | 0% | 16.4 | 50.4 | 0% | 9 |
| Madre in Lacrime | `madre_in_lacrime` | casuale | 69% | 30% | 1% | 38.2 | 80.1 | 0% | 6 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | attacca | 0% | 100% | 0% | 6.0 | 100.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | difendi | 0% | 100% | 0% | 6.0 | 100.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | studia | 0% | 100% | 0% | 6.0 | 100.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | casuale | 0% | 100% | 0% | 6.0 | 100.0 | 0% | 0 |
| Marionetta | `marionetta` | attacca | 15% | 85% | 0% | 11.1 | 93.5 | 0% | 1 |
| Marionetta | `marionetta` | difendi | 0% | 1% | 99% | 60.8 | 36.3 | 0% | 0 |
| Marionetta | `marionetta` | studia | 7% | 93% | 0% | 11.6 | 97.0 | 0% | 0 |
| Marionetta | `marionetta` | casuale | 3% | 97% | 0% | 13.5 | 98.9 | 0% | 0 |
| Fomentado | `maschera_vuota` | attacca | 100% | 0% | 0% | 2.8 | 2.8 | 0% | 8 |
| Fomentado | `maschera_vuota` | difendi | 100% | 0% | 0% | 17.0 | 0.0 | 0% | 8 |
| Fomentado | `maschera_vuota` | studia | 100% | 0% | 0% | 5.0 | 6.3 | 0% | 8 |
| Fomentado | `maschera_vuota` | casuale | 100% | 0% | 0% | 5.8 | 4.8 | 0% | 8 |
| Ombra del passato | `ombra_del_passato` | attacca | 9% | 91% | 0% | 9.4 | 94.7 | 0% | 1 |
| Ombra del passato | `ombra_del_passato` | difendi | 0% | 89% | 11% | 45.2 | 98.8 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | studia | 6% | 94% | 0% | 9.7 | 97.6 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | casuale | 1% | 99% | 0% | 11.3 | 99.1 | 0% | 0 |
| Emblema dell'oppressione | `operaio_posseduto` | attacca | 100% | 0% | 0% | 9.1 | 24.8 | 0% | 12 |
| Emblema dell'oppressione | `operaio_posseduto` | difendi | 0% | 0% | 100% | 61.0 | 0.2 | 0% | 0 |
| Emblema dell'oppressione | `operaio_posseduto` | studia | 100% | 0% | 0% | 12.3 | 35.0 | 0% | 12 |
| Emblema dell'oppressione | `operaio_posseduto` | casuale | 97% | 3% | 0% | 27.7 | 58.3 | 0% | 12 |
| Orrore di Meridia | `orrore_di_meridia` | attacca | 100% | 0% | 0% | 9.5 | 47.7 | 0% | 20 |
| Orrore di Meridia | `orrore_di_meridia` | difendi | 0% | 0% | 100% | 61.0 | 7.6 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | studia | 99% | 1% | 0% | 12.6 | 65.5 | 0% | 20 |
| Orrore di Meridia | `orrore_di_meridia` | casuale | 43% | 57% | 0% | 26.2 | 91.7 | 0% | 9 |
| Sacerdote Folle | `sacerdote_folle` | attacca | 9% | 91% | 0% | 15.2 | 94.9 | 0% | 2 |
| Sacerdote Folle | `sacerdote_folle` | difendi | 0% | 0% | 100% | 61.0 | 7.2 | 0% | 0 |
| Sacerdote Folle | `sacerdote_folle` | studia | 4% | 96% | 0% | 15.8 | 98.1 | 0% | 1 |
| Sacerdote Folle | `sacerdote_folle` | casuale | 3% | 97% | 0% | 21.3 | 98.6 | 0% | 1 |
| Sadico | `sadico` | attacca | 100% | 0% | 0% | 10.9 | 45.7 | 0% | 10 |
| Sadico | `sadico` | difendi | 0% | 0% | 100% | 61.0 | 7.8 | 0% | 0 |
| Sadico | `sadico` | studia | 95% | 5% | 0% | 14.0 | 63.6 | 0% | 9 |
| Sadico | `sadico` | casuale | 45% | 55% | 0% | 28.6 | 89.1 | 0% | 4 |
| Slime Infimo | `slime_infimo` | attacca | 100% | 0% | 0% | 2.9 | 2.8 | 0% | 1 |
| Slime Infimo | `slime_infimo` | difendi | 0% | 0% | 100% | 61.0 | 0.0 | 0% | 0 |
| Slime Infimo | `slime_infimo` | studia | 100% | 0% | 0% | 5.9 | 7.8 | 0% | 1 |
| Slime Infimo | `slime_infimo` | casuale | 100% | 0% | 0% | 9.1 | 8.6 | 0% | 1 |
| Stigma | `stigma` | attacca | 100% | 0% | 0% | 10.9 | 52.1 | 0% | 9 |
| Stigma | `stigma` | difendi | 0% | 0% | 100% | 61.0 | 11.9 | 0% | 0 |
| Stigma | `stigma` | studia | 97% | 3% | 0% | 14.1 | 67.5 | 0% | 9 |
| Stigma | `stigma` | casuale | 42% | 58% | 0% | 27.8 | 89.8 | 0% | 4 |
| Tartaruga Innocente | `tartaruga_innocente` | attacca | 66% | 0% | 34% | 42.9 | 0.0 | 0% | 4 |
| Tartaruga Innocente | `tartaruga_innocente` | difendi | 0% | 0% | 100% | 61.0 | 0.0 | 0% | 0 |
| Tartaruga Innocente | `tartaruga_innocente` | studia | 100% | 0% | 0% | 1.0 | 0.0 | 100% | 8 |
| Tartaruga Innocente | `tartaruga_innocente` | casuale | 100% | 0% | 0% | 3.0 | 0.0 | 99% | 8 |
| Un tenero ricordo | `tenero_ricordo` | attacca | 0% | 100% | 0% | 8.5 | 100.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | difendi | 0% | 100% | 0% | 9.7 | 100.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | studia | 0% | 100% | 0% | 8.3 | 100.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | casuale | 0% | 100% | 0% | 8.8 | 100.0 | 0% | 0 |
| Teschio Errante | `teschio_errante` | attacca | 100% | 0% | 0% | 9.2 | 29.2 | 0% | 8 |
| Teschio Errante | `teschio_errante` | difendi | 0% | 0% | 100% | 61.0 | 3.1 | 0% | 0 |
| Teschio Errante | `teschio_errante` | studia | 100% | 0% | 0% | 12.3 | 39.3 | 0% | 8 |
| Teschio Errante | `teschio_errante` | casuale | 97% | 3% | 0% | 27.9 | 60.2 | 0% | 8 |
| Titano Zombie | `titano_zombie` | attacca | 0% | 100% | 0% | 14.4 | 100.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | difendi | 0% | 100% | 0% | 18.5 | 100.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | studia | 0% | 100% | 0% | 14.0 | 100.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | casuale | 0% | 100% | 0% | 13.9 | 100.0 | 0% | 0 |
| Capocantiere | `voce_registrata` | attacca | 100% | 0% | 0% | 6.8 | 21.7 | 0% | 8 |
| Capocantiere | `voce_registrata` | difendi | 0% | 0% | 100% | 61.0 | 3.1 | 0% | 0 |
| Capocantiere | `voce_registrata` | studia | 100% | 0% | 0% | 9.8 | 31.1 | 0% | 8 |
| Capocantiere | `voce_registrata` | casuale | 100% | 0% | 0% | 20.3 | 44.3 | 0% | 8 |
| Zombie Cittadino | `zombie_cittadino` | attacca | 100% | 0% | 0% | 2.0 | 1.4 | 0% | 3 |
| Zombie Cittadino | `zombie_cittadino` | difendi | 0% | 0% | 100% | 61.0 | 0.0 | 0% | 0 |
| Zombie Cittadino | `zombie_cittadino` | studia | 100% | 0% | 0% | 5.0 | 6.3 | 0% | 3 |
| Zombie Cittadino | `zombie_cittadino` | casuale | 100% | 0% | 0% | 6.0 | 5.0 | 0% | 3 |
| Zombie Mostruoso | `zombie_mostruoso` | attacca | 100% | 0% | 0% | 5.6 | 14.1 | 0% | 8 |
| Zombie Mostruoso | `zombie_mostruoso` | difendi | 0% | 0% | 100% | 61.0 | 0.2 | 0% | 0 |
| Zombie Mostruoso | `zombie_mostruoso` | studia | 100% | 0% | 0% | 8.7 | 24.2 | 0% | 8 |
| Zombie Mostruoso | `zombie_mostruoso` | casuale | 100% | 0% | 0% | 17.5 | 36.2 | 0% | 8 |

## Protagonista di livello 8

| creatura | id | come si gioca | vinte | perse | ∞ | giri | danno | risp. | xp |
|---|---|---|--:|--:|--:|--:|--:|--:|--:|
| Abominio Marcio | `abominio_marcio` | attacca | 100% | 0% | 0% | 8.5 | 29.6 | 0% | 16 |
| Abominio Marcio | `abominio_marcio` | difendi | 0% | 0% | 100% | 61.0 | 6.4 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | studia | 100% | 0% | 0% | 11.6 | 39.8 | 0% | 16 |
| Abominio Marcio | `abominio_marcio` | casuale | 89% | 11% | 0% | 25.4 | 63.4 | 0% | 14 |
| Oppresso | `comparsa_di_ruggine` | attacca | 100% | 0% | 0% | 6.5 | 16.0 | 0% | 6 |
| Oppresso | `comparsa_di_ruggine` | difendi | 0% | 0% | 100% | 61.0 | 2.7 | 0% | 0 |
| Oppresso | `comparsa_di_ruggine` | studia | 100% | 0% | 0% | 9.6 | 25.2 | 0% | 6 |
| Oppresso | `comparsa_di_ruggine` | casuale | 99% | 1% | 0% | 19.8 | 39.0 | 0% | 6 |
| Diabolo | `diabolo` | attacca | 100% | 0% | 0% | 7.5 | 19.4 | 0% | 8 |
| Diabolo | `diabolo` | difendi | 0% | 0% | 100% | 61.0 | 2.4 | 0% | 0 |
| Diabolo | `diabolo` | studia | 100% | 0% | 0% | 10.5 | 26.4 | 0% | 8 |
| Diabolo | `diabolo` | casuale | 100% | 0% | 0% | 22.4 | 38.4 | 0% | 8 |
| Il Divoratore | `divoratore` | attacca | 100% | 0% | 0% | 10.4 | 36.6 | 0% | 14 |
| Il Divoratore | `divoratore` | difendi | 0% | 0% | 100% | 61.0 | 6.4 | 0% | 0 |
| Il Divoratore | `divoratore` | studia | 100% | 0% | 0% | 13.5 | 47.0 | 0% | 14 |
| Il Divoratore | `divoratore` | casuale | 78% | 22% | 0% | 30.0 | 75.0 | 0% | 11 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | attacca | 92% | 8% | 0% | 15.7 | 64.8 | 0% | 17 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | difendi | 0% | 0% | 100% | 61.0 | 5.0 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | studia | 79% | 21% | 0% | 17.8 | 73.9 | 0% | 14 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | casuale | 17% | 83% | 0% | 33.9 | 93.4 | 0% | 3 |
| Ferraglia Urlante | `ferraglia_urlante` | attacca | 100% | 0% | 0% | 8.5 | 19.7 | 0% | 16 |
| Ferraglia Urlante | `ferraglia_urlante` | difendi | 0% | 0% | 100% | 61.0 | 0.2 | 0% | 0 |
| Ferraglia Urlante | `ferraglia_urlante` | studia | 100% | 0% | 0% | 11.6 | 26.4 | 0% | 16 |
| Ferraglia Urlante | `ferraglia_urlante` | casuale | 100% | 0% | 0% | 26.1 | 43.0 | 0% | 16 |
| Ghoul | `ghoul` | attacca | 100% | 0% | 0% | 7.3 | 16.3 | 0% | 9 |
| Ghoul | `ghoul` | difendi | 0% | 0% | 100% | 61.0 | 0.2 | 0% | 0 |
| Ghoul | `ghoul` | studia | 100% | 0% | 0% | 10.5 | 24.5 | 0% | 9 |
| Ghoul | `ghoul` | casuale | 100% | 0% | 0% | 23.6 | 38.8 | 0% | 9 |
| El Muy Bonito | `giocoliere` | attacca | 100% | 0% | 0% | 3.0 | 8.3 | 0% | 18 |
| El Muy Bonito | `giocoliere` | difendi | 0% | 0% | 100% | 61.0 | 3.1 | 0% | 0 |
| El Muy Bonito | `giocoliere` | studia | 100% | 0% | 0% | 6.0 | 28.6 | 0% | 18 |
| El Muy Bonito | `giocoliere` | casuale | 95% | 5% | 0% | 8.4 | 30.3 | 0% | 17 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | attacca | 100% | 0% | 0% | 6.2 | 16.1 | 0% | 29 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | difendi | 0% | 0% | 100% | 61.0 | 3.6 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | studia | 100% | 0% | 0% | 11.6 | 33.0 | 0% | 29 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | casuale | 89% | 11% | 0% | 20.4 | 56.5 | 0% | 26 |
| Goblin Tipico | `goblin_tipico` | attacca | 100% | 0% | 0% | 2.0 | 1.5 | 0% | 2 |
| Goblin Tipico | `goblin_tipico` | difendi | 0% | 0% | 100% | 61.0 | 0.0 | 0% | 0 |
| Goblin Tipico | `goblin_tipico` | studia | 100% | 0% | 0% | 5.0 | 6.6 | 0% | 2 |
| Goblin Tipico | `goblin_tipico` | casuale | 100% | 0% | 0% | 6.4 | 5.9 | 0% | 2 |
| Infetto Rapido | `infetto_rapido` | attacca | 100% | 0% | 0% | 2.0 | 6.1 | 0% | 5 |
| Infetto Rapido | `infetto_rapido` | difendi | 0% | 0% | 100% | 61.0 | 6.8 | 0% | 0 |
| Infetto Rapido | `infetto_rapido` | studia | 100% | 0% | 0% | 5.0 | 17.5 | 0% | 5 |
| Infetto Rapido | `infetto_rapido` | casuale | 100% | 0% | 0% | 5.8 | 12.8 | 0% | 5 |
| L'ultimo spettacolo di Jerah | `jerah` | attacca | 100% | 0% | 0% | 7.0 | 27.7 | 0% | 48 |
| L'ultimo spettacolo di Jerah | `jerah` | difendi | 0% | 100% | 0% | 22.2 | 100.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | studia | 79% | 21% | 0% | 12.5 | 68.0 | 0% | 40 |
| L'ultimo spettacolo di Jerah | `jerah` | casuale | 33% | 67% | 0% | 17.5 | 86.9 | 0% | 16 |
| Jongo Dongo | `jongo_dongo` | attacca | 0% | 100% | 0% | 20.8 | 100.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | difendi | 0% | 0% | 100% | 61.0 | 22.3 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | studia | 0% | 100% | 0% | 21.4 | 100.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | casuale | 0% | 100% | 0% | 29.3 | 100.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | attacca | 0% | 100% | 0% | 12.0 | 100.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | difendi | 0% | 68% | 32% | 51.5 | 95.1 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | studia | 0% | 100% | 0% | 11.7 | 100.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | casuale | 0% | 100% | 0% | 14.2 | 100.0 | 0% | 0 |
| ??? | `l_immortale` | attacca | 0% | 4% | 96% | 60.7 | 80.2 | 0% | 0 |
| ??? | `l_immortale` | difendi | 0% | 0% | 100% | 61.0 | 0.0 | 0% | 0 |
| ??? | `l_immortale` | studia | 0% | 2% | 98% | 60.9 | 78.8 | 0% | 0 |
| ??? | `l_immortale` | casuale | 0% | 0% | 100% | 61.0 | 53.6 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | attacca | 100% | 0% | 0% | 8.2 | 18.5 | 0% | 9 |
| Madre in Lacrime | `madre_in_lacrime` | difendi | 0% | 0% | 100% | 61.0 | 0.2 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | studia | 100% | 0% | 0% | 11.4 | 27.0 | 0% | 9 |
| Madre in Lacrime | `madre_in_lacrime` | casuale | 99% | 1% | 0% | 26.2 | 42.8 | 0% | 9 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | attacca | 0% | 100% | 0% | 6.0 | 100.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | difendi | 0% | 100% | 0% | 6.0 | 100.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | studia | 0% | 100% | 0% | 6.0 | 100.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | casuale | 0% | 100% | 0% | 6.0 | 100.0 | 0% | 0 |
| Marionetta | `marionetta` | attacca | 83% | 17% | 0% | 9.6 | 65.5 | 0% | 3 |
| Marionetta | `marionetta` | difendi | 0% | 1% | 99% | 60.9 | 29.6 | 0% | 0 |
| Marionetta | `marionetta` | studia | 60% | 40% | 0% | 12.0 | 81.5 | 0% | 2 |
| Marionetta | `marionetta` | casuale | 9% | 91% | 0% | 16.8 | 96.7 | 0% | 0 |
| Fomentado | `maschera_vuota` | attacca | 100% | 0% | 0% | 2.0 | 1.1 | 0% | 8 |
| Fomentado | `maschera_vuota` | difendi | 100% | 0% | 0% | 17.0 | 0.0 | 0% | 8 |
| Fomentado | `maschera_vuota` | studia | 100% | 0% | 0% | 5.0 | 5.2 | 0% | 8 |
| Fomentado | `maschera_vuota` | casuale | 100% | 0% | 0% | 5.1 | 3.4 | 0% | 8 |
| Ombra del passato | `ombra_del_passato` | attacca | 66% | 34% | 0% | 9.1 | 72.9 | 0% | 4 |
| Ombra del passato | `ombra_del_passato` | difendi | 0% | 61% | 39% | 52.9 | 93.6 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | studia | 43% | 57% | 0% | 10.8 | 87.5 | 0% | 3 |
| Ombra del passato | `ombra_del_passato` | casuale | 5% | 95% | 0% | 14.2 | 97.6 | 0% | 0 |
| Emblema dell'oppressione | `operaio_posseduto` | attacca | 100% | 0% | 0% | 6.0 | 12.6 | 0% | 7 |
| Emblema dell'oppressione | `operaio_posseduto` | difendi | 0% | 0% | 100% | 61.0 | 0.2 | 0% | 0 |
| Emblema dell'oppressione | `operaio_posseduto` | studia | 100% | 0% | 0% | 9.1 | 20.2 | 0% | 7 |
| Emblema dell'oppressione | `operaio_posseduto` | casuale | 99% | 1% | 0% | 18.2 | 30.3 | 0% | 7 |
| Orrore di Meridia | `orrore_di_meridia` | attacca | 100% | 0% | 0% | 6.7 | 24.9 | 0% | 11 |
| Orrore di Meridia | `orrore_di_meridia` | difendi | 0% | 0% | 100% | 61.0 | 6.6 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | studia | 100% | 0% | 0% | 9.8 | 39.6 | 0% | 11 |
| Orrore di Meridia | `orrore_di_meridia` | casuale | 94% | 6% | 0% | 21.5 | 60.5 | 0% | 10 |
| Sacerdote Folle | `sacerdote_folle` | attacca | 31% | 69% | 0% | 16.9 | 86.4 | 0% | 8 |
| Sacerdote Folle | `sacerdote_folle` | difendi | 0% | 0% | 100% | 61.0 | 6.2 | 0% | 0 |
| Sacerdote Folle | `sacerdote_folle` | studia | 16% | 84% | 0% | 18.3 | 93.6 | 0% | 3 |
| Sacerdote Folle | `sacerdote_folle` | casuale | 3% | 97% | 0% | 24.8 | 98.0 | 0% | 1 |
| Sadico | `sadico` | attacca | 100% | 0% | 0% | 7.3 | 24.5 | 0% | 10 |
| Sadico | `sadico` | difendi | 0% | 0% | 100% | 61.0 | 6.4 | 0% | 0 |
| Sadico | `sadico` | studia | 100% | 0% | 0% | 10.5 | 36.9 | 0% | 10 |
| Sadico | `sadico` | casuale | 92% | 8% | 0% | 23.1 | 57.3 | 0% | 9 |
| Slime Infimo | `slime_infimo` | attacca | 100% | 0% | 0% | 2.8 | 3.1 | 0% | 2 |
| Slime Infimo | `slime_infimo` | difendi | 0% | 0% | 100% | 61.0 | 0.0 | 0% | 0 |
| Slime Infimo | `slime_infimo` | studia | 100% | 0% | 0% | 5.9 | 8.2 | 0% | 2 |
| Slime Infimo | `slime_infimo` | casuale | 100% | 0% | 0% | 9.1 | 9.0 | 0% | 2 |
| Stigma | `stigma` | attacca | 100% | 0% | 0% | 7.3 | 28.5 | 0% | 9 |
| Stigma | `stigma` | difendi | 0% | 0% | 100% | 61.0 | 9.7 | 0% | 0 |
| Stigma | `stigma` | studia | 100% | 0% | 0% | 10.3 | 39.0 | 0% | 9 |
| Stigma | `stigma` | casuale | 95% | 5% | 0% | 21.4 | 56.1 | 0% | 9 |
| Tartaruga Innocente | `tartaruga_innocente` | attacca | 100% | 0% | 0% | 9.3 | 0.0 | 0% | 2 |
| Tartaruga Innocente | `tartaruga_innocente` | difendi | 0% | 0% | 100% | 61.0 | 0.0 | 0% | 0 |
| Tartaruga Innocente | `tartaruga_innocente` | studia | 100% | 0% | 0% | 1.0 | 0.0 | 100% | 3 |
| Tartaruga Innocente | `tartaruga_innocente` | casuale | 100% | 0% | 0% | 3.0 | 0.0 | 99% | 3 |
| Un tenero ricordo | `tenero_ricordo` | attacca | 0% | 100% | 0% | 8.9 | 100.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | difendi | 0% | 100% | 0% | 9.7 | 100.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | studia | 0% | 100% | 0% | 8.7 | 100.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | casuale | 0% | 100% | 0% | 9.1 | 100.0 | 0% | 0 |
| Teschio Errante | `teschio_errante` | attacca | 100% | 0% | 0% | 6.2 | 15.7 | 0% | 8 |
| Teschio Errante | `teschio_errante` | difendi | 0% | 0% | 100% | 61.0 | 2.4 | 0% | 0 |
| Teschio Errante | `teschio_errante` | studia | 100% | 0% | 0% | 9.2 | 23.0 | 0% | 8 |
| Teschio Errante | `teschio_errante` | casuale | 100% | 0% | 0% | 18.2 | 31.9 | 0% | 8 |
| Titano Zombie | `titano_zombie` | attacca | 0% | 100% | 0% | 15.3 | 100.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | difendi | 0% | 100% | 0% | 18.6 | 100.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | studia | 0% | 100% | 0% | 15.0 | 100.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | casuale | 0% | 100% | 0% | 14.5 | 100.0 | 0% | 0 |
| Capocantiere | `voce_registrata` | attacca | 100% | 0% | 0% | 5.7 | 17.0 | 0% | 6 |
| Capocantiere | `voce_registrata` | difendi | 0% | 0% | 100% | 61.0 | 5.3 | 0% | 0 |
| Capocantiere | `voce_registrata` | studia | 100% | 0% | 0% | 8.7 | 25.5 | 0% | 6 |
| Capocantiere | `voce_registrata` | casuale | 100% | 0% | 0% | 16.8 | 35.0 | 0% | 6 |
| Zombie Cittadino | `zombie_cittadino` | attacca | 100% | 0% | 0% | 2.0 | 1.5 | 0% | 4 |
| Zombie Cittadino | `zombie_cittadino` | difendi | 0% | 0% | 100% | 61.0 | 0.0 | 0% | 0 |
| Zombie Cittadino | `zombie_cittadino` | studia | 100% | 0% | 0% | 5.0 | 6.8 | 0% | 4 |
| Zombie Cittadino | `zombie_cittadino` | casuale | 100% | 0% | 0% | 6.0 | 5.3 | 0% | 4 |
| Zombie Mostruoso | `zombie_mostruoso` | attacca | 100% | 0% | 0% | 4.9 | 11.8 | 0% | 8 |
| Zombie Mostruoso | `zombie_mostruoso` | difendi | 0% | 0% | 100% | 61.0 | 2.7 | 0% | 0 |
| Zombie Mostruoso | `zombie_mostruoso` | studia | 100% | 0% | 0% | 7.9 | 20.4 | 0% | 8 |
| Zombie Mostruoso | `zombie_mostruoso` | casuale | 100% | 0% | 0% | 15.1 | 29.0 | 0% | 8 |

