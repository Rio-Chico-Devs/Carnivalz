# Bilanciamento (generato, non scrivere qui a mano)

Prodotto da `prove/Simulatore.gd`: **182400 partite** giocate dal motore vero in 979 secondi.

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
- **danno** — punti vita persi in media dal protagonista (ne ha 1220)
- **risp.** — percentuale di partite in cui la creatura e' stata risparmiata

## A che livello ogni scontro diventa giusto

Livello minimo a cui si vince almeno l'80% delle volte andandoci dritto.

| creatura | id | hp | att | livello |
|---|---|--:|--:|--:|
| Abominio Marcio | `abominio_marcio` | 737 | 34 | 8 |
| Oppresso | `comparsa_di_ruggine` | 277 | 10 | 3 |
| Diabolo | `diabolo` | 405 | 26 | 5 |
| Il Divoratore | `divoratore` | 468 | 21 | 5 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | 486 | 32 | 8 |
| Donna Spinosa | `donna_spinosa` | 568 | 38 | 8 |
| Ferraglia Urlante | `ferraglia_urlante` | 381 | 14 | 5 |
| Ghoul | `ghoul` | 366 | 23 | 5 |
| El Muy Bonito | `giocoliere` | 340 | 15 | 5 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | 1125 | 25 | **mai** |
| Goblin Tipico | `goblin_tipico` | 86 | 6 | 1 |
| Infetto Rapido | `infetto_rapido` | 94 | 7 | 1 |
| L'ultimo spettacolo di Jerah | `jerah` | 2710 | 74 | **mai** |
| Jongo Dongo | `jongo_dongo` | 1857 | 48 | **mai** |
| Jongo Dongo | `jongo_dongo_risorto` | 2147 | 56 | **mai** |
| ??? | `l_immortale` | 120 | 5 | **mai** |
| Madre in Lacrime | `madre_in_lacrime` | 366 | 23 | 5 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | 439 | 14 | **mai** |
| Marionetta | `marionetta` | 568 | 38 | 8 |
| Fomentado | `maschera_vuota` | 164 | 10 | 1 |
| Nuvola di Marciume | `nuvola_di_marciume` | 94 | 7 | 1 |
| Ombra del passato | `ombra_del_passato` | 607 | 41 | 8 |
| Emblema dell'oppressione | `operaio_posseduto` | 245 | 15 | 3 |
| Operaio Sfruttato | `operaio_sfruttato` | 404 | 18 | 5 |
| Orrore di Meridia | `orrore_di_meridia` | 404 | 18 | 5 |
| Robo Pattuglia | `robo_pattuglia` | 277 | 10 | 3 |
| Sacerdote Folle | `sacerdote_folle` | 486 | 32 | 8 |
| Sadico | `sadico` | 405 | 26 | 5 |
| Slime Infimo | `slime_infimo` | 86 | 6 | 1 |
| Stigma | `stigma` | 405 | 26 | 5 |
| Tartaruga Innocente | `tartaruga_innocente` | 555 | 0 | 12 |
| Un tenero ricordo | `tenero_ricordo` | 6660 | 27 | **mai** |
| Teschio Errante | `teschio_errante` | 366 | 23 | 5 |
| Titano Zombie | `titano_zombie` | 737 | 34 | 18 |
| Capocantiere | `voce_registrata` | 207 | 13 | 3 |
| Volto sulla parete | `volto_sulla_parete` | 1733 | 57 | 18 |
| Zombie Cittadino | `zombie_cittadino` | 125 | 8 | 1 |
| Zombie Mostruoso | `zombie_mostruoso` | 164 | 10 | 2 |
## Da dove escono i numeri delle creature

Nessuna creatura ha piu' hp, attacco, difesa, xp e tazo scritti a mano: dichiara a
che **livello** sta e che **ruolo** ha, e i numeri escono da `data/ruoli.json`. E
ruoli.json a sua volta non ha numeri suoi: ha **quote del protagonista**. La riga
"protagonista" qui sotto e' calcolata da `crescita.json` esattamente come la calcola
il gioco, quindi le due curve non possono divergere: e' una sola curva.

### Il metro: un nemico comune al tuo livello

| livello | il protagonista ha | un comune ha | scontri per salire | xp a scontro |
|--:|---|---|--:|--:|
| 1 | 100 hp, 15 att, 0 dif, 3 vel | 86 hp, 6 att, 1 dif, 2 vel | 5.0 | 2 |
| 2 | 145 hp, 21 att, 1 dif, 3 vel | 125 hp, 8 att, 2 dif, 2 vel | 5.3 | 5 |
| 3 | 190 hp, 27 att, 2 dif, 4 vel | 164 hp, 10 att, 3 dif, 3 vel | 5.7 | 9 |
| 5 | 285 hp, 39 att, 5 dif, 6 vel | 245 hp, 15 att, 6 dif, 5 vel | 6.4 | 18 |
| 8 | 425 hp, 57 att, 9 dif, 8 vel | 366 hp, 23 att, 10 dif, 6 vel | 7.4 | 30 |
| 12 | 610 hp, 81 att, 14 dif, 11 vel | 525 hp, 35 att, 15 dif, 9 vel | 8.8 | 47 |
| 16 | 800 hp, 105 att, 20 dif, 15 vel | 689 hp, 47 att, 21 dif, 12 vel | 10.2 | 62 |
| 20 | 985 hp, 129 att, 25 dif, 18 vel | 848 hp, 60 att, 26 dif, 14 vel | 11.6 | 77 |
| 25 | 1220 hp, 159 att, 32 dif, 22 vel | 1050 hp, 77 att, 33 dif, 18 vel | 13.4 | 93 |
| 30 | 1450 hp, 189 att, 38 dif, 26 vel | 1248 hp, 96 att, 39 dif, 21 vel | 15.1 | 109 |

**"Scontri per salire"** e' la manopola del ritmo del gioco intero: l'esperienza di
una creatura non e' scelta, e' il fabbisogno del livello diviso per quel numero.
Prima l'esperienza era una retta e il fabbisogno una potenza, quindi al livello 1
bastavano 4 scontri e al livello 20 ne servivano 26 - e nessuno l'aveva mai misurato,
perche' nessuna prova guardava sopra il livello 8.

### Cosa cambia il ruolo (a livello 10)

| ruolo | hp | attacco | difesa | velocita | xp | tazo | cos'e' |
|---|--:|--:|--:|--:|--:|--:|---|
| **comune** | 448 | 29 | 13 | 8 | 39 | 12 | il nemico di riserva: muore in cinque o sei turni e si porta via un quarto della vita. E' il metro di tutto il resto - il suo xp e' 1.0, cioe' e' lui la creatura che conta in 'scontri_per_livello' |
| **veloce** | 339 | 27 | 3 | 19 | 43 | 13 | colpisce prima e piu' spesso, ma regge poco e non para niente |
| **corazzato** | 601 | 22 | 34 | 6 | 47 | 15 | il muro: lento, poco offensivo, ma i colpi normali ci rimbalzano |
| **particolare** | 737 | 34 | 18 | 9 | 86 | 24 | l'incontro che ti fa alzare la testa: non un boss, ma nemmeno uno qualunque |
| **miniboss** | 1201 | 38 | 22 | 10 | 175 | 49 | il guardiano di un ramo: si prepara, e se non ti prepari perdi |
| **fonte** | 1583 | 40 | 26 | 9 | 272 | 73 | quello che tiene in piedi una frattura. Sempre al livello del protagonista |
| **oggetto_scena** | 66 | 0 | 0 | 0 | 0 | 0 | non combatte: sta li' per essere colpito (le lettere sull'altare) |

### Le eccezioni dichiarate

Una creatura puo' ancora scrivere un numero a mano, e quel numero vince. Ma deve
dire perche' (campo `fuori_curva`), e `prova_curva_creature` fallisce se non lo fa:
cosi' un'eccezione resta un'eccezione invece di tornare a essere la regola.

| creatura | livello | ruolo | scritto a mano | perche' |
|---|--:|---|---|---|
| ??? | 8 | particolare | hp 120, attacco 5, difesa 0 | Non deve essere battuto: si rialza sempre. I suoi numeri sono bassi apposta, perche' il giocatore ci provi abbastanza a lungo da capirlo. |
| Un tenero ricordo | 15 | fonte | hp 6660, attacco 27, difesa 12 | Non si vince a danno: si vince con le leve. La riserva e' una parete che dice «non da questa parte», non un conto da smaltire. |
| Tartaruga Innocente | 1 | corazzato | hp 555, attacco 0, difesa 6 | Non e' uno scontro, e' un indovinello: non attacca mai e non si batte a colpi. La sua riserva enorme serve a far capire che la strada e' un'altra. |
| Un goblin terribilmente arrabbiato | 6 | fonte | hp 1125 | Prima fonte del gioco, e primo boss vero: sta sopra la curva apposta, perche' il tutorial deve finire con uno scontro che si ricorda. |
| Veronica | 5 | miniboss | hp 600, attacco 18, difesa 6, xp 0, tazo 0 | Allenamento scriptato del tutorial: e' invincibile per copione, i numeri servono solo a far durare la lezione il giusto. |

## Protagonista di livello 1

| creatura | id | come si gioca | vinte | perse | ∞ | giri | danno | risp. | xp |
|---|---|---|--:|--:|--:|--:|--:|--:|--:|
| Abominio Marcio | `abominio_marcio` | attacca | 0% | 100% | 0% | 3.9 | 100.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | difendi | 0% | 100% | 0% | 4.8 | 100.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | studia | 0% | 100% | 0% | 3.8 | 100.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | casuale | 0% | 100% | 0% | 3.9 | 100.0 | 0% | 0 |
| Oppresso | `comparsa_di_ruggine` | attacca | 5% | 95% | 0% | 9.7 | 97.2 | 0% | 1 |
| Oppresso | `comparsa_di_ruggine` | difendi | 0% | 1% | 99% | 61.0 | 76.1 | 0% | 0 |
| Oppresso | `comparsa_di_ruggine` | studia | 7% | 93% | 0% | 9.8 | 97.3 | 0% | 1 |
| Oppresso | `comparsa_di_ruggine` | casuale | 3% | 97% | 0% | 14.4 | 99.0 | 0% | 0 |
| Diabolo | `diabolo` | attacca | 5% | 95% | 0% | 3.9 | 97.5 | 0% | 2 |
| Diabolo | `diabolo` | difendi | 0% | 100% | 0% | 8.2 | 100.0 | 0% | 0 |
| Diabolo | `diabolo` | studia | 0% | 100% | 0% | 4.0 | 100.0 | 0% | 0 |
| Diabolo | `diabolo` | casuale | 1% | 99% | 0% | 4.8 | 99.8 | 0% | 0 |
| Il Divoratore | `divoratore` | attacca | 0% | 100% | 0% | 5.0 | 100.0 | 0% | 0 |
| Il Divoratore | `divoratore` | difendi | 0% | 100% | 0% | 18.0 | 100.0 | 0% | 0 |
| Il Divoratore | `divoratore` | studia | 0% | 100% | 0% | 5.0 | 100.0 | 0% | 0 |
| Il Divoratore | `divoratore` | casuale | 0% | 100% | 0% | 6.1 | 100.0 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | attacca | 4% | 96% | 0% | 4.2 | 98.4 | 0% | 2 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | difendi | 0% | 100% | 0% | 8.1 | 100.0 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | studia | 0% | 100% | 0% | 4.4 | 100.0 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | casuale | 1% | 99% | 0% | 4.6 | 99.7 | 0% | 0 |
| Donna Spinosa | `donna_spinosa` | attacca | 5% | 95% | 0% | 4.1 | 97.4 | 0% | 2 |
| Donna Spinosa | `donna_spinosa` | difendi | 0% | 100% | 0% | 5.9 | 100.0 | 0% | 0 |
| Donna Spinosa | `donna_spinosa` | studia | 1% | 99% | 0% | 4.4 | 99.9 | 0% | 0 |
| Donna Spinosa | `donna_spinosa` | casuale | 1% | 99% | 0% | 4.5 | 99.8 | 0% | 0 |
| Ferraglia Urlante | `ferraglia_urlante` | attacca | 0% | 100% | 0% | 7.9 | 100.0 | 0% | 0 |
| Ferraglia Urlante | `ferraglia_urlante` | difendi | 0% | 63% | 37% | 53.0 | 96.7 | 0% | 0 |
| Ferraglia Urlante | `ferraglia_urlante` | studia | 0% | 100% | 0% | 8.0 | 100.0 | 0% | 0 |
| Ferraglia Urlante | `ferraglia_urlante` | casuale | 0% | 100% | 0% | 10.1 | 100.0 | 0% | 0 |
| Ghoul | `ghoul` | attacca | 6% | 94% | 0% | 4.7 | 97.1 | 0% | 2 |
| Ghoul | `ghoul` | difendi | 0% | 100% | 0% | 12.1 | 100.0 | 0% | 0 |
| Ghoul | `ghoul` | studia | 0% | 100% | 0% | 4.8 | 100.0 | 0% | 0 |
| Ghoul | `ghoul` | casuale | 1% | 99% | 0% | 5.4 | 99.7 | 0% | 0 |
| El Muy Bonito | `giocoliere` | attacca | 0% | 100% | 0% | 7.4 | 100.0 | 0% | 0 |
| El Muy Bonito | `giocoliere` | difendi | 0% | 81% | 19% | 49.0 | 98.1 | 0% | 0 |
| El Muy Bonito | `giocoliere` | studia | 0% | 100% | 0% | 5.0 | 100.0 | 0% | 0 |
| El Muy Bonito | `giocoliere` | casuale | 0% | 100% | 0% | 7.8 | 100.0 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | attacca | 0% | 100% | 0% | 6.9 | 100.0 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | difendi | 0% | 100% | 0% | 17.9 | 100.0 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | studia | 0% | 100% | 0% | 7.1 | 100.0 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | casuale | 0% | 100% | 0% | 7.9 | 100.0 | 0% | 0 |
| Goblin Tipico | `goblin_tipico` | attacca | 100% | 0% | 0% | 6.4 | 33.6 | 0% | 2 |
| Goblin Tipico | `goblin_tipico` | difendi | 0% | 0% | 100% | 61.0 | 60.3 | 0% | 0 |
| Goblin Tipico | `goblin_tipico` | studia | 100% | 0% | 0% | 9.5 | 52.6 | 0% | 2 |
| Goblin Tipico | `goblin_tipico` | casuale | 70% | 30% | 0% | 18.7 | 77.4 | 0% | 1 |
| Infetto Rapido | `infetto_rapido` | attacca | 100% | 0% | 0% | 6.4 | 46.1 | 0% | 6 |
| Infetto Rapido | `infetto_rapido` | difendi | 0% | 0% | 100% | 61.0 | 69.8 | 0% | 0 |
| Infetto Rapido | `infetto_rapido` | studia | 100% | 0% | 0% | 9.7 | 70.1 | 0% | 6 |
| Infetto Rapido | `infetto_rapido` | casuale | 53% | 47% | 0% | 17.5 | 90.1 | 0% | 3 |
| L'ultimo spettacolo di Jerah | `jerah` | attacca | 0% | 100% | 0% | 3.8 | 100.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | difendi | 0% | 100% | 0% | 4.5 | 100.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | studia | 0% | 100% | 0% | 3.8 | 100.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | casuale | 0% | 100% | 0% | 4.0 | 100.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | attacca | 0% | 100% | 0% | 6.5 | 100.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | difendi | 0% | 100% | 0% | 10.6 | 100.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | studia | 0% | 100% | 0% | 6.1 | 100.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | casuale | 0% | 100% | 0% | 6.9 | 100.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | attacca | 0% | 100% | 0% | 2.0 | 100.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | difendi | 0% | 100% | 0% | 2.6 | 100.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | studia | 0% | 100% | 0% | 2.0 | 100.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | casuale | 0% | 100% | 0% | 2.2 | 100.0 | 0% | 0 |
| ??? | `l_immortale` | attacca | 0% | 100% | 0% | 19.8 | 100.0 | 0% | 0 |
| ??? | `l_immortale` | difendi | 0% | 0% | 100% | 61.0 | 64.4 | 0% | 0 |
| ??? | `l_immortale` | studia | 0% | 100% | 0% | 19.7 | 100.0 | 0% | 0 |
| ??? | `l_immortale` | casuale | 0% | 100% | 0% | 26.1 | 100.0 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | attacca | 6% | 94% | 0% | 4.7 | 97.1 | 0% | 2 |
| Madre in Lacrime | `madre_in_lacrime` | difendi | 0% | 100% | 0% | 12.1 | 100.0 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | studia | 0% | 100% | 0% | 4.8 | 100.0 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | casuale | 1% | 99% | 0% | 5.4 | 99.7 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | attacca | 0% | 100% | 0% | 6.0 | 100.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | difendi | 0% | 100% | 0% | 6.0 | 100.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | studia | 0% | 100% | 0% | 6.0 | 100.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | casuale | 0% | 100% | 0% | 6.0 | 100.0 | 0% | 0 |
| Marionetta | `marionetta` | attacca | 3% | 97% | 0% | 2.9 | 98.4 | 0% | 2 |
| Marionetta | `marionetta` | difendi | 0% | 100% | 0% | 3.8 | 100.0 | 0% | 0 |
| Marionetta | `marionetta` | studia | 0% | 100% | 0% | 3.0 | 100.0 | 0% | 0 |
| Marionetta | `marionetta` | casuale | 0% | 100% | 0% | 3.1 | 100.0 | 0% | 0 |
| Fomentado | `maschera_vuota` | attacca | 99% | 1% | 0% | 9.5 | 86.4 | 0% | 9 |
| Fomentado | `maschera_vuota` | difendi | 100% | 0% | 0% | 33.0 | 40.7 | 0% | 9 |
| Fomentado | `maschera_vuota` | studia | 7% | 93% | 0% | 9.8 | 97.2 | 0% | 1 |
| Fomentado | `maschera_vuota` | casuale | 9% | 91% | 0% | 14.3 | 98.4 | 0% | 1 |
| Nuvola di Marciume | `nuvola_di_marciume` | attacca | 100% | 0% | 0% | 6.4 | 46.1 | 0% | 6 |
| Nuvola di Marciume | `nuvola_di_marciume` | difendi | 0% | 0% | 100% | 61.0 | 69.8 | 0% | 0 |
| Nuvola di Marciume | `nuvola_di_marciume` | studia | 100% | 0% | 0% | 9.7 | 70.1 | 0% | 6 |
| Nuvola di Marciume | `nuvola_di_marciume` | casuale | 53% | 47% | 0% | 17.5 | 90.1 | 0% | 3 |
| Ombra del passato | `ombra_del_passato` | attacca | 3% | 97% | 0% | 2.9 | 98.5 | 0% | 2 |
| Ombra del passato | `ombra_del_passato` | difendi | 0% | 100% | 0% | 3.8 | 100.0 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | studia | 0% | 100% | 0% | 3.0 | 100.0 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | casuale | 0% | 100% | 0% | 3.1 | 100.0 | 0% | 0 |
| Emblema dell'oppressione | `operaio_posseduto` | attacca | 9% | 91% | 0% | 7.3 | 95.6 | 0% | 2 |
| Emblema dell'oppressione | `operaio_posseduto` | difendi | 0% | 79% | 21% | 50.5 | 97.8 | 0% | 0 |
| Emblema dell'oppressione | `operaio_posseduto` | studia | 1% | 99% | 0% | 7.6 | 99.7 | 0% | 0 |
| Emblema dell'oppressione | `operaio_posseduto` | casuale | 1% | 99% | 0% | 9.3 | 99.6 | 0% | 0 |
| Operaio Sfruttato | `operaio_sfruttato` | attacca | 0% | 100% | 0% | 6.0 | 100.0 | 0% | 0 |
| Operaio Sfruttato | `operaio_sfruttato` | difendi | 0% | 99% | 1% | 36.9 | 100.0 | 0% | 0 |
| Operaio Sfruttato | `operaio_sfruttato` | studia | 0% | 100% | 0% | 6.0 | 100.0 | 0% | 0 |
| Operaio Sfruttato | `operaio_sfruttato` | casuale | 0% | 100% | 0% | 7.3 | 100.0 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | attacca | 0% | 100% | 0% | 6.0 | 100.0 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | difendi | 0% | 98% | 2% | 40.2 | 99.9 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | studia | 0% | 100% | 0% | 6.0 | 100.0 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | casuale | 0% | 100% | 0% | 7.5 | 100.0 | 0% | 0 |
| Robo Pattuglia | `robo_pattuglia` | attacca | 5% | 95% | 0% | 9.7 | 97.2 | 0% | 1 |
| Robo Pattuglia | `robo_pattuglia` | difendi | 0% | 1% | 99% | 61.0 | 76.1 | 0% | 0 |
| Robo Pattuglia | `robo_pattuglia` | studia | 7% | 93% | 0% | 9.8 | 97.3 | 0% | 1 |
| Robo Pattuglia | `robo_pattuglia` | casuale | 3% | 97% | 0% | 14.4 | 99.0 | 0% | 0 |
| Sacerdote Folle | `sacerdote_folle` | attacca | 4% | 96% | 0% | 5.2 | 97.2 | 0% | 2 |
| Sacerdote Folle | `sacerdote_folle` | difendi | 0% | 100% | 0% | 10.8 | 100.0 | 0% | 0 |
| Sacerdote Folle | `sacerdote_folle` | studia | 0% | 100% | 0% | 5.2 | 100.0 | 0% | 0 |
| Sacerdote Folle | `sacerdote_folle` | casuale | 1% | 99% | 0% | 6.0 | 99.2 | 0% | 1 |
| Sadico | `sadico` | attacca | 5% | 95% | 0% | 3.9 | 97.5 | 0% | 2 |
| Sadico | `sadico` | difendi | 0% | 100% | 0% | 8.2 | 100.0 | 0% | 0 |
| Sadico | `sadico` | studia | 0% | 100% | 0% | 4.0 | 100.0 | 0% | 0 |
| Sadico | `sadico` | casuale | 1% | 99% | 0% | 4.8 | 99.8 | 0% | 0 |
| Slime Infimo | `slime_infimo` | attacca | 100% | 0% | 0% | 6.4 | 33.6 | 0% | 2 |
| Slime Infimo | `slime_infimo` | difendi | 0% | 0% | 100% | 61.0 | 60.3 | 0% | 0 |
| Slime Infimo | `slime_infimo` | studia | 100% | 0% | 0% | 9.5 | 52.6 | 0% | 2 |
| Slime Infimo | `slime_infimo` | casuale | 70% | 30% | 0% | 18.7 | 77.4 | 0% | 1 |
| Stigma | `stigma` | attacca | 5% | 95% | 0% | 3.9 | 97.5 | 0% | 2 |
| Stigma | `stigma` | difendi | 0% | 100% | 0% | 8.2 | 100.0 | 0% | 0 |
| Stigma | `stigma` | studia | 0% | 100% | 0% | 4.0 | 100.0 | 0% | 0 |
| Stigma | `stigma` | casuale | 1% | 99% | 0% | 4.8 | 99.8 | 0% | 0 |
| Tartaruga Innocente | `tartaruga_innocente` | attacca | 0% | 0% | 100% | 61.0 | 0.0 | 0% | 0 |
| Tartaruga Innocente | `tartaruga_innocente` | difendi | 0% | 0% | 100% | 61.0 | 0.0 | 0% | 0 |
| Tartaruga Innocente | `tartaruga_innocente` | studia | 100% | 0% | 0% | 1.0 | 0.0 | 100% | 3 |
| Tartaruga Innocente | `tartaruga_innocente` | casuale | 100% | 0% | 0% | 2.8 | 0.0 | 100% | 3 |
| Un tenero ricordo | `tenero_ricordo` | attacca | 0% | 100% | 0% | 5.3 | 100.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | difendi | 0% | 100% | 0% | 6.5 | 100.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | studia | 0% | 100% | 0% | 5.4 | 100.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | casuale | 0% | 100% | 0% | 5.6 | 100.0 | 0% | 0 |
| Teschio Errante | `teschio_errante` | attacca | 6% | 94% | 0% | 4.7 | 97.1 | 0% | 2 |
| Teschio Errante | `teschio_errante` | difendi | 0% | 100% | 0% | 12.1 | 100.0 | 0% | 0 |
| Teschio Errante | `teschio_errante` | studia | 0% | 100% | 0% | 4.8 | 100.0 | 0% | 0 |
| Teschio Errante | `teschio_errante` | casuale | 1% | 99% | 0% | 5.4 | 99.7 | 0% | 0 |
| Titano Zombie | `titano_zombie` | attacca | 0% | 100% | 0% | 5.3 | 100.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | difendi | 0% | 100% | 0% | 6.6 | 100.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | studia | 0% | 100% | 0% | 5.1 | 100.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | casuale | 0% | 100% | 0% | 5.5 | 100.0 | 0% | 0 |
| Capocantiere | `voce_registrata` | attacca | 9% | 91% | 0% | 7.6 | 95.2 | 0% | 1 |
| Capocantiere | `voce_registrata` | difendi | 0% | 63% | 37% | 54.3 | 95.8 | 0% | 0 |
| Capocantiere | `voce_registrata` | studia | 1% | 99% | 0% | 7.9 | 99.9 | 0% | 0 |
| Capocantiere | `voce_registrata` | casuale | 1% | 99% | 0% | 10.2 | 99.5 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | attacca | 0% | 100% | 0% | 3.5 | 100.0 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | difendi | 0% | 100% | 0% | 3.9 | 100.0 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | studia | 0% | 100% | 0% | 3.4 | 100.0 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | casuale | 0% | 100% | 0% | 3.6 | 100.0 | 0% | 0 |
| Zombie Cittadino | `zombie_cittadino` | attacca | 100% | 0% | 0% | 9.4 | 69.2 | 0% | 5 |
| Zombie Cittadino | `zombie_cittadino` | difendi | 0% | 0% | 100% | 61.0 | 66.8 | 0% | 0 |
| Zombie Cittadino | `zombie_cittadino` | studia | 75% | 25% | 0% | 11.9 | 91.2 | 0% | 4 |
| Zombie Cittadino | `zombie_cittadino` | casuale | 3% | 97% | 0% | 17.5 | 98.6 | 0% | 0 |
| Zombie Mostruoso | `zombie_mostruoso` | attacca | 5% | 95% | 0% | 9.7 | 97.2 | 0% | 0 |
| Zombie Mostruoso | `zombie_mostruoso` | difendi | 0% | 1% | 99% | 61.0 | 76.1 | 0% | 0 |
| Zombie Mostruoso | `zombie_mostruoso` | studia | 5% | 95% | 0% | 9.8 | 98.3 | 0% | 0 |
| Zombie Mostruoso | `zombie_mostruoso` | casuale | 2% | 98% | 0% | 14.6 | 98.9 | 0% | 0 |

## Protagonista di livello 2

| creatura | id | come si gioca | vinte | perse | ∞ | giri | danno | risp. | xp |
|---|---|---|--:|--:|--:|--:|--:|--:|--:|
| Abominio Marcio | `abominio_marcio` | attacca | 0% | 100% | 0% | 5.0 | 145.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | difendi | 0% | 100% | 0% | 7.7 | 145.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | studia | 0% | 100% | 0% | 5.0 | 145.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | casuale | 0% | 100% | 0% | 5.4 | 145.0 | 0% | 0 |
| Oppresso | `comparsa_di_ruggine` | attacca | 17% | 83% | 0% | 16.9 | 133.9 | 0% | 3 |
| Oppresso | `comparsa_di_ruggine` | difendi | 0% | 0% | 100% | 61.0 | 75.9 | 0% | 0 |
| Oppresso | `comparsa_di_ruggine` | studia | 12% | 88% | 0% | 17.3 | 137.8 | 0% | 2 |
| Oppresso | `comparsa_di_ruggine` | casuale | 7% | 93% | 0% | 24.2 | 141.6 | 0% | 1 |
| Diabolo | `diabolo` | attacca | 7% | 93% | 0% | 6.5 | 139.5 | 0% | 3 |
| Diabolo | `diabolo` | difendi | 0% | 100% | 0% | 15.1 | 145.0 | 0% | 0 |
| Diabolo | `diabolo` | studia | 0% | 100% | 0% | 6.8 | 145.0 | 0% | 0 |
| Diabolo | `diabolo` | casuale | 1% | 99% | 0% | 7.2 | 144.5 | 0% | 0 |
| Il Divoratore | `divoratore` | attacca | 0% | 100% | 0% | 7.9 | 145.0 | 0% | 0 |
| Il Divoratore | `divoratore` | difendi | 0% | 100% | 0% | 30.8 | 145.0 | 0% | 0 |
| Il Divoratore | `divoratore` | studia | 0% | 100% | 0% | 8.0 | 145.0 | 0% | 0 |
| Il Divoratore | `divoratore` | casuale | 0% | 100% | 0% | 9.4 | 145.0 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | attacca | 4% | 96% | 0% | 6.0 | 141.4 | 0% | 2 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | difendi | 0% | 100% | 0% | 13.6 | 145.0 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | studia | 1% | 99% | 0% | 6.2 | 144.8 | 0% | 1 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | casuale | 1% | 99% | 0% | 7.0 | 144.4 | 0% | 0 |
| Donna Spinosa | `donna_spinosa` | attacca | 6% | 94% | 0% | 5.8 | 139.7 | 0% | 3 |
| Donna Spinosa | `donna_spinosa` | difendi | 0% | 100% | 0% | 8.3 | 145.0 | 0% | 0 |
| Donna Spinosa | `donna_spinosa` | studia | 3% | 97% | 0% | 6.0 | 143.9 | 0% | 1 |
| Donna Spinosa | `donna_spinosa` | casuale | 1% | 99% | 0% | 6.4 | 144.4 | 0% | 0 |
| Ferraglia Urlante | `ferraglia_urlante` | attacca | 0% | 100% | 0% | 12.4 | 145.0 | 0% | 0 |
| Ferraglia Urlante | `ferraglia_urlante` | difendi | 0% | 1% | 99% | 60.9 | 105.0 | 0% | 0 |
| Ferraglia Urlante | `ferraglia_urlante` | studia | 0% | 100% | 0% | 12.4 | 145.0 | 0% | 0 |
| Ferraglia Urlante | `ferraglia_urlante` | casuale | 0% | 100% | 0% | 15.5 | 145.0 | 0% | 0 |
| Ghoul | `ghoul` | attacca | 8% | 92% | 0% | 6.7 | 138.8 | 0% | 2 |
| Ghoul | `ghoul` | difendi | 0% | 100% | 0% | 23.2 | 145.0 | 0% | 0 |
| Ghoul | `ghoul` | studia | 0% | 100% | 0% | 7.0 | 145.0 | 0% | 0 |
| Ghoul | `ghoul` | casuale | 1% | 99% | 0% | 8.3 | 144.4 | 0% | 0 |
| El Muy Bonito | `giocoliere` | attacca | 0% | 100% | 0% | 11.1 | 145.0 | 0% | 0 |
| El Muy Bonito | `giocoliere` | difendi | 0% | 8% | 92% | 60.6 | 113.2 | 0% | 0 |
| El Muy Bonito | `giocoliere` | studia | 0% | 100% | 0% | 6.9 | 145.0 | 0% | 0 |
| El Muy Bonito | `giocoliere` | casuale | 0% | 100% | 0% | 10.0 | 145.0 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | attacca | 0% | 100% | 0% | 9.9 | 145.0 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | difendi | 0% | 100% | 0% | 28.3 | 145.0 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | studia | 0% | 100% | 0% | 10.0 | 145.0 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | casuale | 0% | 100% | 0% | 11.5 | 145.0 | 0% | 0 |
| Goblin Tipico | `goblin_tipico` | attacca | 100% | 0% | 0% | 4.7 | 19.0 | 0% | 2 |
| Goblin Tipico | `goblin_tipico` | difendi | 0% | 0% | 100% | 61.0 | 60.3 | 0% | 0 |
| Goblin Tipico | `goblin_tipico` | studia | 100% | 0% | 0% | 7.7 | 34.6 | 0% | 2 |
| Goblin Tipico | `goblin_tipico` | casuale | 100% | 0% | 0% | 14.6 | 49.7 | 0% | 2 |
| Infetto Rapido | `infetto_rapido` | attacca | 100% | 0% | 0% | 4.7 | 28.9 | 0% | 6 |
| Infetto Rapido | `infetto_rapido` | difendi | 0% | 0% | 100% | 61.0 | 68.7 | 0% | 0 |
| Infetto Rapido | `infetto_rapido` | studia | 100% | 0% | 0% | 7.8 | 48.7 | 0% | 6 |
| Infetto Rapido | `infetto_rapido` | casuale | 100% | 0% | 0% | 14.0 | 63.2 | 0% | 6 |
| L'ultimo spettacolo di Jerah | `jerah` | attacca | 0% | 100% | 0% | 4.9 | 145.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | difendi | 0% | 100% | 0% | 6.2 | 145.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | studia | 0% | 100% | 0% | 4.9 | 145.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | casuale | 0% | 100% | 0% | 5.1 | 145.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | attacca | 0% | 100% | 0% | 8.7 | 145.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | difendi | 0% | 100% | 0% | 16.0 | 145.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | studia | 0% | 100% | 0% | 8.4 | 145.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | casuale | 0% | 100% | 0% | 9.8 | 145.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | attacca | 0% | 100% | 0% | 3.0 | 145.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | difendi | 0% | 100% | 0% | 3.9 | 145.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | studia | 0% | 100% | 0% | 3.0 | 145.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | casuale | 0% | 100% | 0% | 3.1 | 145.0 | 0% | 0 |
| ??? | `l_immortale` | attacca | 0% | 100% | 0% | 35.4 | 145.0 | 0% | 0 |
| ??? | `l_immortale` | difendi | 0% | 0% | 100% | 61.0 | 63.4 | 0% | 0 |
| ??? | `l_immortale` | studia | 0% | 100% | 0% | 35.4 | 145.0 | 0% | 0 |
| ??? | `l_immortale` | casuale | 0% | 100% | 0% | 46.0 | 145.0 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | attacca | 8% | 92% | 0% | 6.7 | 138.8 | 0% | 2 |
| Madre in Lacrime | `madre_in_lacrime` | difendi | 0% | 100% | 0% | 23.2 | 145.0 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | studia | 0% | 100% | 0% | 7.0 | 145.0 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | casuale | 1% | 99% | 0% | 8.3 | 144.4 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | attacca | 0% | 100% | 0% | 6.0 | 145.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | difendi | 0% | 100% | 0% | 6.0 | 145.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | studia | 0% | 100% | 0% | 6.0 | 145.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | casuale | 0% | 100% | 0% | 6.0 | 145.0 | 0% | 0 |
| Marionetta | `marionetta` | attacca | 6% | 94% | 0% | 4.7 | 141.2 | 0% | 3 |
| Marionetta | `marionetta` | difendi | 0% | 100% | 0% | 6.6 | 145.0 | 0% | 0 |
| Marionetta | `marionetta` | studia | 1% | 99% | 0% | 4.8 | 145.0 | 0% | 0 |
| Marionetta | `marionetta` | casuale | 1% | 99% | 0% | 5.0 | 144.7 | 0% | 0 |
| Fomentado | `maschera_vuota` | attacca | 100% | 0% | 0% | 6.8 | 48.5 | 0% | 9 |
| Fomentado | `maschera_vuota` | difendi | 100% | 0% | 0% | 33.0 | 40.5 | 0% | 9 |
| Fomentado | `maschera_vuota` | studia | 100% | 0% | 0% | 9.5 | 70.3 | 0% | 9 |
| Fomentado | `maschera_vuota` | casuale | 100% | 0% | 0% | 15.3 | 83.5 | 0% | 9 |
| Nuvola di Marciume | `nuvola_di_marciume` | attacca | 100% | 0% | 0% | 4.7 | 28.9 | 0% | 6 |
| Nuvola di Marciume | `nuvola_di_marciume` | difendi | 0% | 0% | 100% | 61.0 | 68.7 | 0% | 0 |
| Nuvola di Marciume | `nuvola_di_marciume` | studia | 100% | 0% | 0% | 7.8 | 48.7 | 0% | 6 |
| Nuvola di Marciume | `nuvola_di_marciume` | casuale | 100% | 0% | 0% | 14.0 | 63.2 | 0% | 6 |
| Ombra del passato | `ombra_del_passato` | attacca | 5% | 95% | 0% | 3.9 | 141.5 | 0% | 3 |
| Ombra del passato | `ombra_del_passato` | difendi | 0% | 100% | 0% | 5.8 | 145.0 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | studia | 0% | 100% | 0% | 4.0 | 145.0 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | casuale | 1% | 99% | 0% | 4.6 | 144.7 | 0% | 0 |
| Emblema dell'oppressione | `operaio_posseduto` | attacca | 12% | 88% | 0% | 10.7 | 135.4 | 0% | 2 |
| Emblema dell'oppressione | `operaio_posseduto` | difendi | 0% | 8% | 92% | 60.5 | 112.3 | 0% | 0 |
| Emblema dell'oppressione | `operaio_posseduto` | studia | 3% | 97% | 0% | 11.4 | 144.0 | 0% | 1 |
| Emblema dell'oppressione | `operaio_posseduto` | casuale | 1% | 99% | 0% | 14.2 | 144.2 | 0% | 0 |
| Operaio Sfruttato | `operaio_sfruttato` | attacca | 0% | 100% | 0% | 9.0 | 145.0 | 0% | 0 |
| Operaio Sfruttato | `operaio_sfruttato` | difendi | 0% | 39% | 61% | 57.2 | 128.5 | 0% | 0 |
| Operaio Sfruttato | `operaio_sfruttato` | studia | 0% | 100% | 0% | 9.0 | 145.0 | 0% | 0 |
| Operaio Sfruttato | `operaio_sfruttato` | casuale | 0% | 100% | 0% | 11.1 | 145.0 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | attacca | 0% | 100% | 0% | 9.5 | 145.0 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | difendi | 0% | 37% | 63% | 57.9 | 129.8 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | studia | 0% | 100% | 0% | 9.6 | 145.0 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | casuale | 0% | 100% | 0% | 11.6 | 145.0 | 0% | 0 |
| Robo Pattuglia | `robo_pattuglia` | attacca | 17% | 83% | 0% | 16.9 | 133.9 | 0% | 3 |
| Robo Pattuglia | `robo_pattuglia` | difendi | 0% | 0% | 100% | 61.0 | 75.9 | 0% | 0 |
| Robo Pattuglia | `robo_pattuglia` | studia | 12% | 88% | 0% | 17.3 | 137.8 | 0% | 2 |
| Robo Pattuglia | `robo_pattuglia` | casuale | 7% | 93% | 0% | 24.2 | 141.6 | 0% | 1 |
| Sacerdote Folle | `sacerdote_folle` | attacca | 4% | 96% | 0% | 7.0 | 140.3 | 0% | 2 |
| Sacerdote Folle | `sacerdote_folle` | difendi | 0% | 100% | 0% | 15.5 | 145.0 | 0% | 0 |
| Sacerdote Folle | `sacerdote_folle` | studia | 3% | 97% | 0% | 7.1 | 144.2 | 0% | 1 |
| Sacerdote Folle | `sacerdote_folle` | casuale | 1% | 99% | 0% | 8.1 | 143.6 | 0% | 1 |
| Sadico | `sadico` | attacca | 7% | 93% | 0% | 6.5 | 139.5 | 0% | 3 |
| Sadico | `sadico` | difendi | 0% | 100% | 0% | 15.1 | 145.0 | 0% | 0 |
| Sadico | `sadico` | studia | 0% | 100% | 0% | 6.8 | 145.0 | 0% | 0 |
| Sadico | `sadico` | casuale | 1% | 99% | 0% | 7.2 | 144.5 | 0% | 0 |
| Slime Infimo | `slime_infimo` | attacca | 100% | 0% | 0% | 4.7 | 19.0 | 0% | 2 |
| Slime Infimo | `slime_infimo` | difendi | 0% | 0% | 100% | 61.0 | 60.3 | 0% | 0 |
| Slime Infimo | `slime_infimo` | studia | 100% | 0% | 0% | 7.7 | 34.6 | 0% | 2 |
| Slime Infimo | `slime_infimo` | casuale | 100% | 0% | 0% | 14.6 | 49.7 | 0% | 2 |
| Stigma | `stigma` | attacca | 7% | 93% | 0% | 6.5 | 139.5 | 0% | 3 |
| Stigma | `stigma` | difendi | 0% | 100% | 0% | 15.1 | 145.0 | 0% | 0 |
| Stigma | `stigma` | studia | 0% | 100% | 0% | 6.8 | 145.0 | 0% | 0 |
| Stigma | `stigma` | casuale | 1% | 99% | 0% | 7.2 | 144.5 | 0% | 0 |
| Tartaruga Innocente | `tartaruga_innocente` | attacca | 0% | 0% | 100% | 61.0 | 0.0 | 0% | 0 |
| Tartaruga Innocente | `tartaruga_innocente` | difendi | 0% | 0% | 100% | 61.0 | 0.0 | 0% | 0 |
| Tartaruga Innocente | `tartaruga_innocente` | studia | 100% | 0% | 0% | 1.0 | 0.0 | 100% | 3 |
| Tartaruga Innocente | `tartaruga_innocente` | casuale | 100% | 0% | 0% | 2.8 | 0.0 | 100% | 3 |
| Un tenero ricordo | `tenero_ricordo` | attacca | 0% | 100% | 0% | 6.3 | 145.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | difendi | 0% | 100% | 0% | 7.3 | 145.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | studia | 0% | 100% | 0% | 6.3 | 145.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | casuale | 0% | 100% | 0% | 6.5 | 145.0 | 0% | 0 |
| Teschio Errante | `teschio_errante` | attacca | 8% | 92% | 0% | 6.7 | 138.8 | 0% | 2 |
| Teschio Errante | `teschio_errante` | difendi | 0% | 100% | 0% | 23.2 | 145.0 | 0% | 0 |
| Teschio Errante | `teschio_errante` | studia | 0% | 100% | 0% | 7.0 | 145.0 | 0% | 0 |
| Teschio Errante | `teschio_errante` | casuale | 1% | 99% | 0% | 8.3 | 144.4 | 0% | 0 |
| Titano Zombie | `titano_zombie` | attacca | 0% | 100% | 0% | 8.0 | 145.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | difendi | 0% | 100% | 0% | 9.2 | 145.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | studia | 0% | 100% | 0% | 6.9 | 145.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | casuale | 0% | 100% | 0% | 7.4 | 145.0 | 0% | 0 |
| Capocantiere | `voce_registrata` | attacca | 75% | 25% | 0% | 11.3 | 127.7 | 0% | 10 |
| Capocantiere | `voce_registrata` | difendi | 0% | 0% | 100% | 61.0 | 100.1 | 0% | 0 |
| Capocantiere | `voce_registrata` | studia | 5% | 95% | 0% | 13.2 | 143.4 | 0% | 1 |
| Capocantiere | `voce_registrata` | casuale | 3% | 97% | 0% | 17.2 | 143.8 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | attacca | 0% | 100% | 0% | 4.9 | 145.0 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | difendi | 0% | 100% | 0% | 6.1 | 145.0 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | studia | 0% | 100% | 0% | 4.8 | 145.0 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | casuale | 0% | 100% | 0% | 5.0 | 145.0 | 0% | 0 |
| Zombie Cittadino | `zombie_cittadino` | attacca | 100% | 0% | 0% | 6.7 | 40.9 | 0% | 5 |
| Zombie Cittadino | `zombie_cittadino` | difendi | 0% | 0% | 100% | 61.0 | 66.6 | 0% | 0 |
| Zombie Cittadino | `zombie_cittadino` | studia | 100% | 0% | 0% | 9.5 | 60.9 | 0% | 5 |
| Zombie Cittadino | `zombie_cittadino` | casuale | 93% | 7% | 0% | 20.2 | 98.2 | 0% | 5 |
| Zombie Mostruoso | `zombie_mostruoso` | attacca | 100% | 0% | 0% | 8.5 | 62.6 | 0% | 9 |
| Zombie Mostruoso | `zombie_mostruoso` | difendi | 0% | 0% | 100% | 61.0 | 75.9 | 0% | 0 |
| Zombie Mostruoso | `zombie_mostruoso` | studia | 100% | 0% | 0% | 11.5 | 87.1 | 0% | 9 |
| Zombie Mostruoso | `zombie_mostruoso` | casuale | 51% | 49% | 0% | 22.7 | 128.3 | 0% | 5 |

## Protagonista di livello 3

| creatura | id | come si gioca | vinte | perse | ∞ | giri | danno | risp. | xp |
|---|---|---|--:|--:|--:|--:|--:|--:|--:|
| Abominio Marcio | `abominio_marcio` | attacca | 0% | 100% | 0% | 6.7 | 190.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | difendi | 0% | 100% | 0% | 11.9 | 190.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | studia | 0% | 100% | 0% | 6.7 | 190.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | casuale | 0% | 100% | 0% | 7.4 | 190.0 | 0% | 0 |
| Oppresso | `comparsa_di_ruggine` | attacca | 100% | 0% | 0% | 15.6 | 106.7 | 0% | 16 |
| Oppresso | `comparsa_di_ruggine` | difendi | 0% | 0% | 100% | 61.0 | 72.8 | 0% | 0 |
| Oppresso | `comparsa_di_ruggine` | studia | 100% | 0% | 0% | 18.5 | 127.5 | 0% | 16 |
| Oppresso | `comparsa_di_ruggine` | casuale | 15% | 85% | 0% | 34.3 | 179.9 | 0% | 2 |
| Diabolo | `diabolo` | attacca | 10% | 90% | 0% | 8.5 | 179.9 | 0% | 4 |
| Diabolo | `diabolo` | difendi | 0% | 100% | 0% | 23.7 | 190.0 | 0% | 0 |
| Diabolo | `diabolo` | studia | 1% | 99% | 0% | 8.9 | 189.5 | 0% | 0 |
| Diabolo | `diabolo` | casuale | 1% | 99% | 0% | 10.1 | 189.1 | 0% | 0 |
| Il Divoratore | `divoratore` | attacca | 0% | 100% | 0% | 10.6 | 190.0 | 0% | 0 |
| Il Divoratore | `divoratore` | difendi | 0% | 100% | 0% | 44.0 | 190.0 | 0% | 0 |
| Il Divoratore | `divoratore` | studia | 0% | 100% | 0% | 10.6 | 190.0 | 0% | 0 |
| Il Divoratore | `divoratore` | casuale | 0% | 100% | 0% | 12.8 | 190.0 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | attacca | 5% | 95% | 0% | 8.4 | 184.3 | 0% | 2 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | difendi | 0% | 100% | 0% | 19.8 | 190.0 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | studia | 3% | 97% | 0% | 8.7 | 188.7 | 0% | 1 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | casuale | 1% | 99% | 0% | 9.9 | 189.0 | 0% | 0 |
| Donna Spinosa | `donna_spinosa` | attacca | 6% | 94% | 0% | 7.5 | 181.8 | 0% | 3 |
| Donna Spinosa | `donna_spinosa` | difendi | 0% | 100% | 0% | 10.7 | 190.0 | 0% | 0 |
| Donna Spinosa | `donna_spinosa` | studia | 3% | 97% | 0% | 7.8 | 187.4 | 0% | 2 |
| Donna Spinosa | `donna_spinosa` | casuale | 1% | 99% | 0% | 8.2 | 189.1 | 0% | 0 |
| Ferraglia Urlante | `ferraglia_urlante` | attacca | 0% | 100% | 0% | 17.1 | 190.0 | 0% | 0 |
| Ferraglia Urlante | `ferraglia_urlante` | difendi | 0% | 0% | 100% | 61.0 | 90.3 | 0% | 0 |
| Ferraglia Urlante | `ferraglia_urlante` | studia | 0% | 100% | 0% | 17.2 | 190.0 | 0% | 0 |
| Ferraglia Urlante | `ferraglia_urlante` | casuale | 0% | 100% | 0% | 23.0 | 190.0 | 0% | 0 |
| Ghoul | `ghoul` | attacca | 11% | 89% | 0% | 9.3 | 178.6 | 0% | 3 |
| Ghoul | `ghoul` | difendi | 0% | 100% | 0% | 40.5 | 190.0 | 0% | 0 |
| Ghoul | `ghoul` | studia | 2% | 98% | 0% | 9.9 | 189.1 | 0% | 1 |
| Ghoul | `ghoul` | casuale | 1% | 99% | 0% | 11.9 | 189.1 | 0% | 0 |
| El Muy Bonito | `giocoliere` | attacca | 31% | 69% | 0% | 15.0 | 186.3 | 0% | 9 |
| El Muy Bonito | `giocoliere` | difendi | 0% | 0% | 100% | 61.0 | 108.7 | 0% | 0 |
| El Muy Bonito | `giocoliere` | studia | 0% | 100% | 0% | 8.0 | 190.0 | 0% | 0 |
| El Muy Bonito | `giocoliere` | casuale | 0% | 100% | 0% | 11.8 | 190.0 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | attacca | 0% | 100% | 0% | 13.9 | 190.0 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | difendi | 0% | 100% | 0% | 40.1 | 190.0 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | studia | 0% | 100% | 0% | 14.1 | 190.0 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | casuale | 0% | 100% | 0% | 16.8 | 190.0 | 0% | 0 |
| Goblin Tipico | `goblin_tipico` | attacca | 100% | 0% | 0% | 3.8 | 11.5 | 0% | 1 |
| Goblin Tipico | `goblin_tipico` | difendi | 0% | 0% | 100% | 61.0 | 60.2 | 0% | 0 |
| Goblin Tipico | `goblin_tipico` | studia | 100% | 0% | 0% | 6.8 | 24.0 | 0% | 1 |
| Goblin Tipico | `goblin_tipico` | casuale | 100% | 0% | 0% | 12.2 | 33.6 | 0% | 1 |
| Infetto Rapido | `infetto_rapido` | attacca | 100% | 0% | 0% | 3.8 | 19.5 | 0% | 5 |
| Infetto Rapido | `infetto_rapido` | difendi | 0% | 0% | 100% | 61.0 | 67.6 | 0% | 0 |
| Infetto Rapido | `infetto_rapido` | studia | 100% | 0% | 0% | 6.9 | 35.7 | 0% | 5 |
| Infetto Rapido | `infetto_rapido` | casuale | 100% | 0% | 0% | 11.1 | 42.9 | 0% | 5 |
| L'ultimo spettacolo di Jerah | `jerah` | attacca | 0% | 100% | 0% | 6.2 | 190.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | difendi | 0% | 100% | 0% | 8.0 | 190.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | studia | 0% | 100% | 0% | 6.5 | 190.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | casuale | 0% | 100% | 0% | 6.7 | 190.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | attacca | 0% | 100% | 0% | 11.3 | 190.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | difendi | 0% | 100% | 0% | 22.4 | 190.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | studia | 0% | 100% | 0% | 10.8 | 190.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | casuale | 0% | 100% | 0% | 12.6 | 190.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | attacca | 0% | 100% | 0% | 4.0 | 190.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | difendi | 0% | 100% | 0% | 4.8 | 190.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | studia | 0% | 100% | 0% | 4.0 | 190.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | casuale | 0% | 100% | 0% | 4.2 | 190.0 | 0% | 0 |
| ??? | `l_immortale` | attacca | 0% | 33% | 67% | 60.5 | 187.4 | 0% | 0 |
| ??? | `l_immortale` | difendi | 0% | 0% | 100% | 61.0 | 62.3 | 0% | 0 |
| ??? | `l_immortale` | studia | 0% | 35% | 65% | 60.4 | 187.3 | 0% | 0 |
| ??? | `l_immortale` | casuale | 0% | 0% | 100% | 61.0 | 148.3 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | attacca | 11% | 89% | 0% | 9.3 | 178.6 | 0% | 3 |
| Madre in Lacrime | `madre_in_lacrime` | difendi | 0% | 100% | 0% | 40.5 | 190.0 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | studia | 2% | 98% | 0% | 9.9 | 189.1 | 0% | 1 |
| Madre in Lacrime | `madre_in_lacrime` | casuale | 1% | 99% | 0% | 11.9 | 189.1 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | attacca | 0% | 100% | 0% | 6.0 | 190.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | difendi | 0% | 100% | 0% | 6.0 | 190.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | studia | 0% | 100% | 0% | 6.0 | 190.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | casuale | 0% | 100% | 0% | 6.0 | 190.0 | 0% | 0 |
| Marionetta | `marionetta` | attacca | 7% | 93% | 0% | 5.8 | 183.1 | 0% | 3 |
| Marionetta | `marionetta` | difendi | 0% | 100% | 0% | 9.4 | 190.0 | 0% | 0 |
| Marionetta | `marionetta` | studia | 1% | 99% | 0% | 6.0 | 189.6 | 0% | 0 |
| Marionetta | `marionetta` | casuale | 1% | 99% | 0% | 6.5 | 189.3 | 0% | 0 |
| Fomentado | `maschera_vuota` | attacca | 100% | 0% | 0% | 5.7 | 34.8 | 0% | 9 |
| Fomentado | `maschera_vuota` | difendi | 100% | 0% | 0% | 33.0 | 38.9 | 0% | 9 |
| Fomentado | `maschera_vuota` | studia | 100% | 0% | 0% | 7.9 | 50.1 | 0% | 9 |
| Fomentado | `maschera_vuota` | casuale | 100% | 0% | 0% | 13.0 | 62.0 | 0% | 9 |
| Nuvola di Marciume | `nuvola_di_marciume` | attacca | 100% | 0% | 0% | 3.8 | 19.5 | 0% | 5 |
| Nuvola di Marciume | `nuvola_di_marciume` | difendi | 0% | 0% | 100% | 61.0 | 67.6 | 0% | 0 |
| Nuvola di Marciume | `nuvola_di_marciume` | studia | 100% | 0% | 0% | 6.9 | 35.7 | 0% | 5 |
| Nuvola di Marciume | `nuvola_di_marciume` | casuale | 100% | 0% | 0% | 11.1 | 42.9 | 0% | 5 |
| Ombra del passato | `ombra_del_passato` | attacca | 7% | 93% | 0% | 5.6 | 183.6 | 0% | 4 |
| Ombra del passato | `ombra_del_passato` | difendi | 0% | 100% | 0% | 8.4 | 190.0 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | studia | 1% | 99% | 0% | 5.7 | 189.7 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | casuale | 1% | 99% | 0% | 6.0 | 189.4 | 0% | 0 |
| Emblema dell'oppressione | `operaio_posseduto` | attacca | 100% | 0% | 0% | 9.9 | 122.2 | 0% | 18 |
| Emblema dell'oppressione | `operaio_posseduto` | difendi | 0% | 0% | 100% | 61.0 | 108.2 | 0% | 0 |
| Emblema dell'oppressione | `operaio_posseduto` | studia | 95% | 5% | 0% | 13.4 | 166.7 | 0% | 17 |
| Emblema dell'oppressione | `operaio_posseduto` | casuale | 7% | 93% | 0% | 20.1 | 187.5 | 0% | 1 |
| Operaio Sfruttato | `operaio_sfruttato` | attacca | 0% | 100% | 0% | 12.5 | 190.0 | 0% | 0 |
| Operaio Sfruttato | `operaio_sfruttato` | difendi | 0% | 0% | 100% | 61.0 | 127.4 | 0% | 0 |
| Operaio Sfruttato | `operaio_sfruttato` | studia | 0% | 100% | 0% | 12.6 | 190.0 | 0% | 0 |
| Operaio Sfruttato | `operaio_sfruttato` | casuale | 0% | 100% | 0% | 15.7 | 190.0 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | attacca | 0% | 100% | 0% | 13.4 | 190.0 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | difendi | 0% | 1% | 99% | 61.0 | 127.9 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | studia | 0% | 100% | 0% | 13.5 | 190.0 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | casuale | 0% | 100% | 0% | 17.1 | 190.0 | 0% | 0 |
| Robo Pattuglia | `robo_pattuglia` | attacca | 100% | 0% | 0% | 15.6 | 106.7 | 0% | 16 |
| Robo Pattuglia | `robo_pattuglia` | difendi | 0% | 0% | 100% | 61.0 | 72.8 | 0% | 0 |
| Robo Pattuglia | `robo_pattuglia` | studia | 100% | 0% | 0% | 18.5 | 127.5 | 0% | 16 |
| Robo Pattuglia | `robo_pattuglia` | casuale | 15% | 85% | 0% | 34.3 | 179.9 | 0% | 2 |
| Sacerdote Folle | `sacerdote_folle` | attacca | 4% | 96% | 0% | 8.8 | 183.4 | 0% | 2 |
| Sacerdote Folle | `sacerdote_folle` | difendi | 0% | 100% | 0% | 21.1 | 190.0 | 0% | 0 |
| Sacerdote Folle | `sacerdote_folle` | studia | 3% | 97% | 0% | 8.9 | 187.8 | 0% | 1 |
| Sacerdote Folle | `sacerdote_folle` | casuale | 1% | 99% | 0% | 10.1 | 187.9 | 0% | 1 |
| Sadico | `sadico` | attacca | 10% | 90% | 0% | 8.5 | 179.9 | 0% | 4 |
| Sadico | `sadico` | difendi | 0% | 100% | 0% | 23.7 | 190.0 | 0% | 0 |
| Sadico | `sadico` | studia | 1% | 99% | 0% | 8.9 | 189.5 | 0% | 0 |
| Sadico | `sadico` | casuale | 1% | 99% | 0% | 10.1 | 189.1 | 0% | 0 |
| Slime Infimo | `slime_infimo` | attacca | 100% | 0% | 0% | 3.8 | 11.5 | 0% | 1 |
| Slime Infimo | `slime_infimo` | difendi | 0% | 0% | 100% | 61.0 | 60.2 | 0% | 0 |
| Slime Infimo | `slime_infimo` | studia | 100% | 0% | 0% | 6.8 | 24.0 | 0% | 1 |
| Slime Infimo | `slime_infimo` | casuale | 100% | 0% | 0% | 12.2 | 33.6 | 0% | 1 |
| Stigma | `stigma` | attacca | 10% | 90% | 0% | 8.5 | 179.9 | 0% | 4 |
| Stigma | `stigma` | difendi | 0% | 100% | 0% | 23.7 | 190.0 | 0% | 0 |
| Stigma | `stigma` | studia | 1% | 99% | 0% | 8.9 | 189.5 | 0% | 0 |
| Stigma | `stigma` | casuale | 1% | 99% | 0% | 10.1 | 189.1 | 0% | 0 |
| Tartaruga Innocente | `tartaruga_innocente` | attacca | 0% | 0% | 100% | 61.0 | 0.0 | 0% | 0 |
| Tartaruga Innocente | `tartaruga_innocente` | difendi | 0% | 0% | 100% | 61.0 | 0.0 | 0% | 0 |
| Tartaruga Innocente | `tartaruga_innocente` | studia | 100% | 0% | 0% | 1.0 | 0.0 | 100% | 1 |
| Tartaruga Innocente | `tartaruga_innocente` | casuale | 100% | 0% | 0% | 2.8 | 0.0 | 100% | 1 |
| Un tenero ricordo | `tenero_ricordo` | attacca | 0% | 100% | 0% | 7.0 | 190.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | difendi | 0% | 100% | 0% | 7.9 | 190.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | studia | 0% | 100% | 0% | 7.0 | 190.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | casuale | 0% | 100% | 0% | 7.1 | 190.0 | 0% | 0 |
| Teschio Errante | `teschio_errante` | attacca | 11% | 89% | 0% | 9.3 | 178.6 | 0% | 3 |
| Teschio Errante | `teschio_errante` | difendi | 0% | 100% | 0% | 40.5 | 190.0 | 0% | 0 |
| Teschio Errante | `teschio_errante` | studia | 2% | 98% | 0% | 9.9 | 189.1 | 0% | 1 |
| Teschio Errante | `teschio_errante` | casuale | 1% | 99% | 0% | 11.9 | 189.1 | 0% | 0 |
| Titano Zombie | `titano_zombie` | attacca | 0% | 100% | 0% | 10.8 | 190.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | difendi | 0% | 100% | 0% | 11.1 | 190.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | studia | 0% | 100% | 0% | 9.0 | 190.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | casuale | 0% | 100% | 0% | 9.0 | 190.0 | 0% | 0 |
| Capocantiere | `voce_registrata` | attacca | 100% | 0% | 0% | 8.5 | 78.5 | 0% | 13 |
| Capocantiere | `voce_registrata` | difendi | 0% | 0% | 100% | 61.0 | 86.3 | 0% | 0 |
| Capocantiere | `voce_registrata` | studia | 100% | 0% | 0% | 11.5 | 109.2 | 0% | 13 |
| Capocantiere | `voce_registrata` | casuale | 53% | 47% | 0% | 22.9 | 166.4 | 0% | 7 |
| Volto sulla parete | `volto_sulla_parete` | attacca | 0% | 100% | 0% | 6.2 | 190.0 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | difendi | 0% | 100% | 0% | 7.9 | 190.0 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | studia | 0% | 100% | 0% | 6.1 | 190.0 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | casuale | 0% | 100% | 0% | 6.6 | 190.0 | 0% | 0 |
| Zombie Cittadino | `zombie_cittadino` | attacca | 100% | 0% | 0% | 4.9 | 23.9 | 0% | 4 |
| Zombie Cittadino | `zombie_cittadino` | difendi | 0% | 0% | 100% | 61.0 | 63.6 | 0% | 0 |
| Zombie Cittadino | `zombie_cittadino` | studia | 100% | 0% | 0% | 7.8 | 42.2 | 0% | 4 |
| Zombie Cittadino | `zombie_cittadino` | casuale | 100% | 0% | 0% | 15.4 | 63.2 | 0% | 4 |
| Zombie Mostruoso | `zombie_mostruoso` | attacca | 100% | 0% | 0% | 6.6 | 41.4 | 0% | 9 |
| Zombie Mostruoso | `zombie_mostruoso` | difendi | 0% | 0% | 100% | 61.0 | 72.8 | 0% | 0 |
| Zombie Mostruoso | `zombie_mostruoso` | studia | 100% | 0% | 0% | 9.7 | 63.6 | 0% | 9 |
| Zombie Mostruoso | `zombie_mostruoso` | casuale | 99% | 1% | 0% | 20.4 | 100.0 | 0% | 9 |

## Protagonista di livello 5

| creatura | id | come si gioca | vinte | perse | ∞ | giri | danno | risp. | xp |
|---|---|---|--:|--:|--:|--:|--:|--:|--:|
| Abominio Marcio | `abominio_marcio` | attacca | 0% | 100% | 0% | 10.9 | 285.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | difendi | 0% | 100% | 0% | 23.4 | 285.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | studia | 0% | 100% | 0% | 10.9 | 285.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | casuale | 0% | 100% | 0% | 12.4 | 285.0 | 0% | 0 |
| Oppresso | `comparsa_di_ruggine` | attacca | 100% | 0% | 0% | 9.4 | 36.6 | 0% | 14 |
| Oppresso | `comparsa_di_ruggine` | difendi | 0% | 0% | 100% | 61.0 | 69.6 | 0% | 0 |
| Oppresso | `comparsa_di_ruggine` | studia | 100% | 0% | 0% | 12.1 | 48.5 | 0% | 14 |
| Oppresso | `comparsa_di_ruggine` | casuale | 100% | 0% | 0% | 28.9 | 93.0 | 0% | 14 |
| Diabolo | `diabolo` | attacca | 99% | 1% | 0% | 11.5 | 216.7 | 0% | 35 |
| Diabolo | `diabolo` | difendi | 0% | 39% | 61% | 58.1 | 265.1 | 0% | 0 |
| Diabolo | `diabolo` | studia | 33% | 67% | 0% | 14.9 | 274.9 | 0% | 12 |
| Diabolo | `diabolo` | casuale | 3% | 97% | 0% | 18.3 | 282.3 | 0% | 1 |
| Il Divoratore | `divoratore` | attacca | 100% | 0% | 0% | 14.2 | 192.8 | 0% | 48 |
| Il Divoratore | `divoratore` | difendi | 0% | 0% | 100% | 61.0 | 119.7 | 0% | 0 |
| Il Divoratore | `divoratore` | studia | 100% | 0% | 0% | 17.3 | 237.7 | 0% | 48 |
| Il Divoratore | `divoratore` | casuale | 1% | 99% | 0% | 25.2 | 285.0 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | attacca | 31% | 69% | 0% | 14.2 | 265.2 | 0% | 13 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | difendi | 0% | 100% | 0% | 38.9 | 285.0 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | studia | 12% | 88% | 0% | 15.0 | 277.3 | 0% | 5 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | casuale | 7% | 93% | 0% | 17.1 | 279.2 | 0% | 3 |
| Donna Spinosa | `donna_spinosa` | attacca | 9% | 91% | 0% | 11.0 | 269.1 | 0% | 4 |
| Donna Spinosa | `donna_spinosa` | difendi | 0% | 100% | 0% | 15.3 | 285.0 | 0% | 0 |
| Donna Spinosa | `donna_spinosa` | studia | 5% | 95% | 0% | 11.5 | 277.5 | 0% | 3 |
| Donna Spinosa | `donna_spinosa` | casuale | 3% | 97% | 0% | 12.3 | 282.8 | 0% | 1 |
| Ferraglia Urlante | `ferraglia_urlante` | attacca | 100% | 0% | 0% | 14.7 | 115.2 | 0% | 26 |
| Ferraglia Urlante | `ferraglia_urlante` | difendi | 0% | 0% | 100% | 61.0 | 85.2 | 0% | 0 |
| Ferraglia Urlante | `ferraglia_urlante` | studia | 100% | 0% | 0% | 17.7 | 141.0 | 0% | 26 |
| Ferraglia Urlante | `ferraglia_urlante` | casuale | 67% | 33% | 0% | 42.2 | 250.3 | 0% | 17 |
| Ghoul | `ghoul` | attacca | 100% | 0% | 0% | 11.0 | 167.0 | 0% | 30 |
| Ghoul | `ghoul` | difendi | 0% | 0% | 100% | 61.0 | 137.6 | 0% | 0 |
| Ghoul | `ghoul` | studia | 100% | 0% | 0% | 14.0 | 216.3 | 0% | 30 |
| Ghoul | `ghoul` | casuale | 10% | 90% | 0% | 21.3 | 277.6 | 0% | 3 |
| El Muy Bonito | `giocoliere` | attacca | 100% | 0% | 0% | 9.5 | 81.8 | 0% | 25 |
| El Muy Bonito | `giocoliere` | difendi | 0% | 0% | 100% | 61.0 | 91.9 | 0% | 0 |
| El Muy Bonito | `giocoliere` | studia | 6% | 94% | 0% | 10.0 | 282.3 | 0% | 2 |
| El Muy Bonito | `giocoliere` | casuale | 7% | 93% | 0% | 14.5 | 279.9 | 0% | 2 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | attacca | 0% | 100% | 0% | 24.0 | 285.0 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | difendi | 0% | 7% | 93% | 60.8 | 229.0 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | studia | 0% | 100% | 0% | 23.6 | 285.0 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | casuale | 0% | 100% | 0% | 29.5 | 285.0 | 0% | 0 |
| Goblin Tipico | `goblin_tipico` | attacca | 100% | 0% | 0% | 3.8 | 9.1 | 0% | 3 |
| Goblin Tipico | `goblin_tipico` | difendi | 0% | 0% | 100% | 61.0 | 63.3 | 0% | 0 |
| Goblin Tipico | `goblin_tipico` | studia | 100% | 0% | 0% | 6.8 | 19.2 | 0% | 3 |
| Goblin Tipico | `goblin_tipico` | casuale | 100% | 0% | 0% | 12.2 | 27.7 | 0% | 3 |
| Infetto Rapido | `infetto_rapido` | attacca | 100% | 0% | 0% | 2.9 | 4.3 | 0% | 3 |
| Infetto Rapido | `infetto_rapido` | difendi | 0% | 0% | 100% | 61.0 | 60.3 | 0% | 0 |
| Infetto Rapido | `infetto_rapido` | studia | 100% | 0% | 0% | 5.9 | 11.3 | 0% | 3 |
| Infetto Rapido | `infetto_rapido` | casuale | 100% | 0% | 0% | 9.2 | 15.1 | 0% | 3 |
| L'ultimo spettacolo di Jerah | `jerah` | attacca | 0% | 100% | 0% | 9.6 | 285.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | difendi | 0% | 100% | 0% | 12.5 | 285.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | studia | 0% | 100% | 0% | 10.8 | 285.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | casuale | 0% | 100% | 0% | 11.2 | 285.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | attacca | 0% | 100% | 0% | 17.1 | 285.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | difendi | 0% | 99% | 1% | 38.2 | 284.9 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | studia | 0% | 100% | 0% | 16.2 | 285.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | casuale | 0% | 100% | 0% | 20.2 | 285.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | attacca | 0% | 100% | 0% | 6.7 | 285.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | difendi | 0% | 100% | 0% | 8.6 | 285.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | studia | 0% | 100% | 0% | 6.7 | 285.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | casuale | 0% | 100% | 0% | 7.0 | 285.0 | 0% | 0 |
| ??? | `l_immortale` | attacca | 0% | 0% | 100% | 61.0 | 71.5 | 0% | 0 |
| ??? | `l_immortale` | difendi | 0% | 0% | 100% | 61.0 | 60.3 | 0% | 0 |
| ??? | `l_immortale` | studia | 0% | 0% | 100% | 61.0 | 71.6 | 0% | 0 |
| ??? | `l_immortale` | casuale | 0% | 0% | 100% | 61.0 | 67.9 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | attacca | 100% | 0% | 0% | 11.0 | 167.0 | 0% | 30 |
| Madre in Lacrime | `madre_in_lacrime` | difendi | 0% | 0% | 100% | 61.0 | 137.6 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | studia | 100% | 0% | 0% | 14.0 | 216.3 | 0% | 30 |
| Madre in Lacrime | `madre_in_lacrime` | casuale | 10% | 90% | 0% | 21.3 | 277.6 | 0% | 3 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | attacca | 0% | 100% | 0% | 6.0 | 285.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | difendi | 0% | 100% | 0% | 6.0 | 285.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | studia | 0% | 100% | 0% | 6.0 | 285.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | casuale | 0% | 100% | 0% | 6.0 | 285.0 | 0% | 0 |
| Marionetta | `marionetta` | attacca | 11% | 89% | 0% | 9.3 | 268.1 | 0% | 5 |
| Marionetta | `marionetta` | difendi | 0% | 100% | 0% | 18.4 | 285.0 | 0% | 0 |
| Marionetta | `marionetta` | studia | 1% | 99% | 0% | 9.8 | 283.3 | 0% | 1 |
| Marionetta | `marionetta` | casuale | 1% | 99% | 0% | 11.1 | 283.6 | 0% | 0 |
| Fomentado | `maschera_vuota` | attacca | 100% | 0% | 0% | 3.9 | 12.9 | 0% | 6 |
| Fomentado | `maschera_vuota` | difendi | 100% | 0% | 0% | 33.0 | 37.1 | 0% | 6 |
| Fomentado | `maschera_vuota` | studia | 100% | 0% | 0% | 6.8 | 25.2 | 0% | 6 |
| Fomentado | `maschera_vuota` | casuale | 100% | 0% | 0% | 10.1 | 29.1 | 0% | 6 |
| Nuvola di Marciume | `nuvola_di_marciume` | attacca | 100% | 0% | 0% | 2.9 | 4.3 | 0% | 3 |
| Nuvola di Marciume | `nuvola_di_marciume` | difendi | 0% | 0% | 100% | 61.0 | 60.3 | 0% | 0 |
| Nuvola di Marciume | `nuvola_di_marciume` | studia | 100% | 0% | 0% | 5.9 | 11.3 | 0% | 3 |
| Nuvola di Marciume | `nuvola_di_marciume` | casuale | 100% | 0% | 0% | 9.2 | 15.1 | 0% | 3 |
| Ombra del passato | `ombra_del_passato` | attacca | 10% | 90% | 0% | 8.5 | 269.4 | 0% | 6 |
| Ombra del passato | `ombra_del_passato` | difendi | 0% | 100% | 0% | 15.2 | 285.0 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | studia | 1% | 99% | 0% | 8.9 | 283.5 | 0% | 1 |
| Ombra del passato | `ombra_del_passato` | casuale | 1% | 99% | 0% | 10.0 | 283.7 | 0% | 0 |
| Emblema dell'oppressione | `operaio_posseduto` | attacca | 100% | 0% | 0% | 6.7 | 53.9 | 0% | 18 |
| Emblema dell'oppressione | `operaio_posseduto` | difendi | 0% | 0% | 100% | 61.0 | 92.2 | 0% | 0 |
| Emblema dell'oppressione | `operaio_posseduto` | studia | 100% | 0% | 0% | 9.5 | 80.0 | 0% | 18 |
| Emblema dell'oppressione | `operaio_posseduto` | casuale | 100% | 0% | 0% | 20.4 | 134.7 | 0% | 18 |
| Operaio Sfruttato | `operaio_sfruttato` | attacca | 100% | 0% | 0% | 11.5 | 122.4 | 0% | 39 |
| Operaio Sfruttato | `operaio_sfruttato` | difendi | 0% | 0% | 100% | 61.0 | 104.0 | 0% | 0 |
| Operaio Sfruttato | `operaio_sfruttato` | studia | 100% | 0% | 0% | 14.5 | 159.3 | 0% | 39 |
| Operaio Sfruttato | `operaio_sfruttato` | casuale | 41% | 59% | 0% | 30.5 | 266.8 | 0% | 16 |
| Orrore di Meridia | `orrore_di_meridia` | attacca | 100% | 0% | 0% | 11.6 | 113.2 | 0% | 39 |
| Orrore di Meridia | `orrore_di_meridia` | difendi | 0% | 0% | 100% | 61.0 | 107.4 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | studia | 100% | 0% | 0% | 14.6 | 147.2 | 0% | 39 |
| Orrore di Meridia | `orrore_di_meridia` | casuale | 54% | 46% | 0% | 32.5 | 259.9 | 0% | 21 |
| Robo Pattuglia | `robo_pattuglia` | attacca | 100% | 0% | 0% | 9.4 | 36.6 | 0% | 14 |
| Robo Pattuglia | `robo_pattuglia` | difendi | 0% | 0% | 100% | 61.0 | 69.6 | 0% | 0 |
| Robo Pattuglia | `robo_pattuglia` | studia | 100% | 0% | 0% | 12.1 | 48.5 | 0% | 14 |
| Robo Pattuglia | `robo_pattuglia` | casuale | 100% | 0% | 0% | 28.9 | 93.0 | 0% | 14 |
| Sacerdote Folle | `sacerdote_folle` | attacca | 11% | 89% | 0% | 12.6 | 269.3 | 0% | 5 |
| Sacerdote Folle | `sacerdote_folle` | difendi | 0% | 99% | 1% | 43.7 | 284.7 | 0% | 0 |
| Sacerdote Folle | `sacerdote_folle` | studia | 8% | 92% | 0% | 13.0 | 278.1 | 0% | 4 |
| Sacerdote Folle | `sacerdote_folle` | casuale | 1% | 99% | 0% | 15.3 | 281.6 | 0% | 1 |
| Sadico | `sadico` | attacca | 99% | 1% | 0% | 11.5 | 216.7 | 0% | 35 |
| Sadico | `sadico` | difendi | 0% | 39% | 61% | 58.1 | 265.1 | 0% | 0 |
| Sadico | `sadico` | studia | 33% | 67% | 0% | 14.9 | 274.9 | 0% | 12 |
| Sadico | `sadico` | casuale | 3% | 97% | 0% | 18.3 | 282.3 | 0% | 1 |
| Slime Infimo | `slime_infimo` | attacca | 100% | 0% | 0% | 3.8 | 9.1 | 0% | 3 |
| Slime Infimo | `slime_infimo` | difendi | 0% | 0% | 100% | 61.0 | 63.3 | 0% | 0 |
| Slime Infimo | `slime_infimo` | studia | 100% | 0% | 0% | 6.8 | 19.2 | 0% | 3 |
| Slime Infimo | `slime_infimo` | casuale | 100% | 0% | 0% | 12.2 | 27.7 | 0% | 3 |
| Stigma | `stigma` | attacca | 99% | 1% | 0% | 11.5 | 216.7 | 0% | 35 |
| Stigma | `stigma` | difendi | 0% | 39% | 61% | 58.1 | 265.1 | 0% | 0 |
| Stigma | `stigma` | studia | 33% | 67% | 0% | 14.9 | 274.9 | 0% | 12 |
| Stigma | `stigma` | casuale | 3% | 97% | 0% | 18.3 | 282.3 | 0% | 1 |
| Tartaruga Innocente | `tartaruga_innocente` | attacca | 0% | 0% | 100% | 61.0 | 0.0 | 0% | 0 |
| Tartaruga Innocente | `tartaruga_innocente` | difendi | 0% | 0% | 100% | 61.0 | 0.0 | 0% | 0 |
| Tartaruga Innocente | `tartaruga_innocente` | studia | 100% | 0% | 0% | 1.0 | 0.0 | 100% | 1 |
| Tartaruga Innocente | `tartaruga_innocente` | casuale | 100% | 0% | 0% | 2.8 | 0.0 | 100% | 1 |
| Un tenero ricordo | `tenero_ricordo` | attacca | 0% | 100% | 0% | 7.8 | 285.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | difendi | 0% | 100% | 0% | 8.4 | 285.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | studia | 0% | 100% | 0% | 8.0 | 285.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | casuale | 0% | 100% | 0% | 8.1 | 285.0 | 0% | 0 |
| Teschio Errante | `teschio_errante` | attacca | 100% | 0% | 0% | 11.0 | 167.0 | 0% | 30 |
| Teschio Errante | `teschio_errante` | difendi | 0% | 0% | 100% | 61.0 | 137.6 | 0% | 0 |
| Teschio Errante | `teschio_errante` | studia | 100% | 0% | 0% | 14.0 | 216.3 | 0% | 30 |
| Teschio Errante | `teschio_errante` | casuale | 10% | 90% | 0% | 21.3 | 277.6 | 0% | 3 |
| Titano Zombie | `titano_zombie` | attacca | 0% | 100% | 0% | 14.1 | 285.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | difendi | 0% | 100% | 0% | 14.6 | 285.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | studia | 0% | 100% | 0% | 13.8 | 285.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | casuale | 0% | 100% | 0% | 12.3 | 285.0 | 0% | 0 |
| Capocantiere | `voce_registrata` | attacca | 100% | 0% | 0% | 5.7 | 35.6 | 0% | 11 |
| Capocantiere | `voce_registrata` | difendi | 0% | 0% | 100% | 61.0 | 82.1 | 0% | 0 |
| Capocantiere | `voce_registrata` | studia | 100% | 0% | 0% | 8.8 | 58.2 | 0% | 11 |
| Capocantiere | `voce_registrata` | casuale | 100% | 0% | 0% | 17.8 | 88.0 | 0% | 11 |
| Volto sulla parete | `volto_sulla_parete` | attacca | 0% | 100% | 0% | 9.6 | 285.0 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | difendi | 0% | 100% | 0% | 12.0 | 285.0 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | studia | 0% | 100% | 0% | 9.3 | 285.0 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | casuale | 0% | 100% | 0% | 10.0 | 285.0 | 0% | 0 |
| Zombie Cittadino | `zombie_cittadino` | attacca | 100% | 0% | 0% | 3.8 | 9.1 | 0% | 3 |
| Zombie Cittadino | `zombie_cittadino` | difendi | 0% | 0% | 100% | 61.0 | 63.3 | 0% | 0 |
| Zombie Cittadino | `zombie_cittadino` | studia | 100% | 0% | 0% | 6.8 | 18.9 | 0% | 3 |
| Zombie Cittadino | `zombie_cittadino` | casuale | 100% | 0% | 0% | 12.0 | 27.4 | 0% | 3 |
| Zombie Mostruoso | `zombie_mostruoso` | attacca | 100% | 0% | 0% | 4.8 | 16.4 | 0% | 6 |
| Zombie Mostruoso | `zombie_mostruoso` | difendi | 0% | 0% | 100% | 61.0 | 69.6 | 0% | 0 |
| Zombie Mostruoso | `zombie_mostruoso` | studia | 100% | 0% | 0% | 7.8 | 29.6 | 0% | 6 |
| Zombie Mostruoso | `zombie_mostruoso` | casuale | 100% | 0% | 0% | 14.9 | 44.5 | 0% | 6 |

## Protagonista di livello 8

| creatura | id | come si gioca | vinte | perse | ∞ | giri | danno | risp. | xp |
|---|---|---|--:|--:|--:|--:|--:|--:|--:|
| Abominio Marcio | `abominio_marcio` | attacca | 100% | 0% | 0% | 15.8 | 329.1 | 0% | 86 |
| Abominio Marcio | `abominio_marcio` | difendi | 0% | 79% | 21% | 54.9 | 421.5 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | studia | 91% | 9% | 0% | 18.7 | 390.0 | 0% | 79 |
| Abominio Marcio | `abominio_marcio` | casuale | 0% | 100% | 0% | 23.6 | 425.0 | 0% | 0 |
| Oppresso | `comparsa_di_ruggine` | attacca | 100% | 0% | 0% | 6.7 | 14.4 | 0% | 12 |
| Oppresso | `comparsa_di_ruggine` | difendi | 0% | 0% | 100% | 61.0 | 69.7 | 0% | 0 |
| Oppresso | `comparsa_di_ruggine` | studia | 100% | 0% | 0% | 9.6 | 21.0 | 0% | 12 |
| Oppresso | `comparsa_di_ruggine` | casuale | 100% | 0% | 0% | 20.7 | 40.2 | 0% | 12 |
| Diabolo | `diabolo` | attacca | 100% | 0% | 0% | 7.6 | 97.9 | 0% | 35 |
| Diabolo | `diabolo` | difendi | 0% | 0% | 100% | 61.0 | 129.9 | 0% | 0 |
| Diabolo | `diabolo` | studia | 100% | 0% | 0% | 10.6 | 142.0 | 0% | 35 |
| Diabolo | `diabolo` | casuale | 97% | 3% | 0% | 23.2 | 259.0 | 0% | 34 |
| Il Divoratore | `divoratore` | attacca | 100% | 0% | 0% | 8.6 | 80.4 | 0% | 34 |
| Il Divoratore | `divoratore` | difendi | 0% | 0% | 100% | 61.0 | 107.7 | 0% | 0 |
| Il Divoratore | `divoratore` | studia | 100% | 0% | 0% | 11.6 | 112.4 | 0% | 34 |
| Il Divoratore | `divoratore` | casuale | 100% | 0% | 0% | 26.8 | 200.4 | 0% | 34 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | attacca | 100% | 0% | 0% | 9.4 | 131.3 | 0% | 43 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | difendi | 0% | 0% | 100% | 61.0 | 269.4 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | studia | 100% | 0% | 0% | 12.4 | 170.0 | 0% | 43 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | casuale | 82% | 18% | 0% | 27.1 | 326.9 | 0% | 35 |
| Donna Spinosa | `donna_spinosa` | attacca | 100% | 0% | 0% | 11.6 | 262.4 | 0% | 51 |
| Donna Spinosa | `donna_spinosa` | difendi | 0% | 100% | 0% | 21.1 | 425.0 | 0% | 0 |
| Donna Spinosa | `donna_spinosa` | studia | 89% | 11% | 0% | 14.7 | 357.8 | 0% | 45 |
| Donna Spinosa | `donna_spinosa` | casuale | 5% | 95% | 0% | 17.6 | 416.0 | 0% | 2 |
| Ferraglia Urlante | `ferraglia_urlante` | attacca | 100% | 0% | 0% | 8.6 | 33.5 | 0% | 18 |
| Ferraglia Urlante | `ferraglia_urlante` | difendi | 0% | 0% | 100% | 61.0 | 78.9 | 0% | 0 |
| Ferraglia Urlante | `ferraglia_urlante` | studia | 100% | 0% | 0% | 11.6 | 47.2 | 0% | 18 |
| Ferraglia Urlante | `ferraglia_urlante` | casuale | 100% | 0% | 0% | 26.7 | 86.9 | 0% | 18 |
| Ghoul | `ghoul` | attacca | 100% | 0% | 0% | 6.8 | 68.4 | 0% | 30 |
| Ghoul | `ghoul` | difendi | 0% | 0% | 100% | 61.0 | 115.9 | 0% | 0 |
| Ghoul | `ghoul` | studia | 100% | 0% | 0% | 9.8 | 104.3 | 0% | 30 |
| Ghoul | `ghoul` | casuale | 100% | 0% | 0% | 21.2 | 178.3 | 0% | 30 |
| El Muy Bonito | `giocoliere` | attacca | 100% | 0% | 0% | 7.6 | 51.6 | 0% | 21 |
| El Muy Bonito | `giocoliere` | difendi | 0% | 0% | 100% | 61.0 | 92.2 | 0% | 0 |
| El Muy Bonito | `giocoliere` | studia | 100% | 0% | 0% | 9.7 | 213.2 | 0% | 21 |
| El Muy Bonito | `giocoliere` | casuale | 45% | 55% | 0% | 16.2 | 338.1 | 0% | 9 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | attacca | 31% | 69% | 0% | 31.7 | 412.1 | 0% | 68 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | difendi | 0% | 0% | 100% | 61.0 | 274.8 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | studia | 8% | 92% | 0% | 31.8 | 422.8 | 0% | 18 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | casuale | 0% | 100% | 0% | 40.0 | 425.0 | 0% | 0 |
| Goblin Tipico | `goblin_tipico` | attacca | 100% | 0% | 0% | 4.8 | 20.9 | 0% | 10 |
| Goblin Tipico | `goblin_tipico` | difendi | 0% | 0% | 100% | 61.0 | 82.1 | 0% | 0 |
| Goblin Tipico | `goblin_tipico` | studia | 100% | 0% | 0% | 7.8 | 37.7 | 0% | 10 |
| Goblin Tipico | `goblin_tipico` | casuale | 100% | 0% | 0% | 14.9 | 56.0 | 0% | 10 |
| Infetto Rapido | `infetto_rapido` | attacca | 100% | 0% | 0% | 2.9 | 13.1 | 0% | 10 |
| Infetto Rapido | `infetto_rapido` | difendi | 0% | 0% | 100% | 61.0 | 82.1 | 0% | 0 |
| Infetto Rapido | `infetto_rapido` | studia | 100% | 0% | 0% | 6.0 | 27.2 | 0% | 10 |
| Infetto Rapido | `infetto_rapido` | casuale | 100% | 0% | 0% | 8.7 | 29.9 | 0% | 10 |
| L'ultimo spettacolo di Jerah | `jerah` | attacca | 0% | 100% | 0% | 15.3 | 425.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | difendi | 0% | 100% | 0% | 21.5 | 425.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | studia | 0% | 100% | 0% | 18.1 | 425.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | casuale | 0% | 100% | 0% | 18.7 | 425.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | attacca | 0% | 100% | 0% | 28.9 | 425.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | difendi | 0% | 43% | 57% | 57.4 | 379.8 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | studia | 0% | 100% | 0% | 26.7 | 425.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | casuale | 0% | 98% | 2% | 34.6 | 424.1 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | attacca | 0% | 100% | 0% | 11.4 | 425.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | difendi | 0% | 100% | 0% | 15.8 | 425.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | studia | 0% | 100% | 0% | 11.4 | 425.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | casuale | 0% | 100% | 0% | 12.0 | 425.0 | 0% | 0 |
| ??? | `l_immortale` | attacca | 0% | 0% | 100% | 61.0 | 66.1 | 0% | 0 |
| ??? | `l_immortale` | difendi | 0% | 0% | 100% | 61.0 | 60.0 | 0% | 0 |
| ??? | `l_immortale` | studia | 0% | 0% | 100% | 61.0 | 66.1 | 0% | 0 |
| ??? | `l_immortale` | casuale | 0% | 0% | 100% | 61.0 | 63.5 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | attacca | 100% | 0% | 0% | 6.8 | 68.4 | 0% | 30 |
| Madre in Lacrime | `madre_in_lacrime` | difendi | 0% | 0% | 100% | 61.0 | 115.9 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | studia | 100% | 0% | 0% | 9.8 | 104.3 | 0% | 30 |
| Madre in Lacrime | `madre_in_lacrime` | casuale | 100% | 0% | 0% | 21.2 | 178.3 | 0% | 30 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | attacca | 0% | 100% | 0% | 6.0 | 425.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | difendi | 0% | 100% | 0% | 6.0 | 425.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | studia | 0% | 100% | 0% | 6.0 | 425.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | casuale | 0% | 100% | 0% | 6.0 | 425.0 | 0% | 0 |
| Marionetta | `marionetta` | attacca | 100% | 0% | 0% | 11.4 | 285.7 | 0% | 51 |
| Marionetta | `marionetta` | difendi | 0% | 100% | 0% | 38.6 | 425.0 | 0% | 0 |
| Marionetta | `marionetta` | studia | 97% | 3% | 0% | 15.0 | 372.8 | 0% | 50 |
| Marionetta | `marionetta` | casuale | 2% | 98% | 0% | 19.8 | 421.8 | 0% | 1 |
| Fomentado | `maschera_vuota` | attacca | 100% | 0% | 0% | 3.9 | 16.5 | 0% | 10 |
| Fomentado | `maschera_vuota` | difendi | 100% | 0% | 0% | 49.0 | 65.9 | 0% | 10 |
| Fomentado | `maschera_vuota` | studia | 100% | 0% | 0% | 6.9 | 32.7 | 0% | 10 |
| Fomentado | `maschera_vuota` | casuale | 100% | 0% | 0% | 11.5 | 42.7 | 0% | 10 |
| Nuvola di Marciume | `nuvola_di_marciume` | attacca | 100% | 0% | 0% | 2.9 | 13.1 | 0% | 10 |
| Nuvola di Marciume | `nuvola_di_marciume` | difendi | 0% | 0% | 100% | 61.0 | 82.1 | 0% | 0 |
| Nuvola di Marciume | `nuvola_di_marciume` | studia | 100% | 0% | 0% | 6.0 | 27.2 | 0% | 10 |
| Nuvola di Marciume | `nuvola_di_marciume` | casuale | 100% | 0% | 0% | 8.7 | 29.9 | 0% | 10 |
| Ombra del passato | `ombra_del_passato` | attacca | 97% | 3% | 0% | 12.3 | 335.7 | 0% | 54 |
| Ombra del passato | `ombra_del_passato` | difendi | 0% | 100% | 0% | 32.2 | 425.0 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | studia | 33% | 67% | 0% | 15.4 | 408.4 | 0% | 18 |
| Ombra del passato | `ombra_del_passato` | casuale | 2% | 98% | 0% | 17.9 | 422.3 | 0% | 1 |
| Emblema dell'oppressione | `operaio_posseduto` | attacca | 100% | 0% | 0% | 4.8 | 20.9 | 0% | 10 |
| Emblema dell'oppressione | `operaio_posseduto` | difendi | 0% | 0% | 100% | 61.0 | 82.1 | 0% | 0 |
| Emblema dell'oppressione | `operaio_posseduto` | studia | 100% | 0% | 0% | 7.7 | 37.0 | 0% | 10 |
| Emblema dell'oppressione | `operaio_posseduto` | casuale | 100% | 0% | 0% | 15.1 | 57.7 | 0% | 10 |
| Operaio Sfruttato | `operaio_sfruttato` | attacca | 100% | 0% | 0% | 7.6 | 51.6 | 0% | 21 |
| Operaio Sfruttato | `operaio_sfruttato` | difendi | 0% | 0% | 100% | 61.0 | 92.2 | 0% | 0 |
| Operaio Sfruttato | `operaio_sfruttato` | studia | 100% | 0% | 0% | 10.6 | 75.7 | 0% | 21 |
| Operaio Sfruttato | `operaio_sfruttato` | casuale | 100% | 0% | 0% | 23.1 | 124.6 | 0% | 21 |
| Orrore di Meridia | `orrore_di_meridia` | attacca | 100% | 0% | 0% | 7.7 | 42.0 | 0% | 21 |
| Orrore di Meridia | `orrore_di_meridia` | difendi | 0% | 0% | 100% | 61.0 | 97.5 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | studia | 100% | 0% | 0% | 10.8 | 61.6 | 0% | 21 |
| Orrore di Meridia | `orrore_di_meridia` | casuale | 100% | 0% | 0% | 23.4 | 104.5 | 0% | 21 |
| Robo Pattuglia | `robo_pattuglia` | attacca | 100% | 0% | 0% | 6.7 | 14.4 | 0% | 12 |
| Robo Pattuglia | `robo_pattuglia` | difendi | 0% | 0% | 100% | 61.0 | 69.7 | 0% | 0 |
| Robo Pattuglia | `robo_pattuglia` | studia | 100% | 0% | 0% | 9.6 | 21.0 | 0% | 12 |
| Robo Pattuglia | `robo_pattuglia` | casuale | 100% | 0% | 0% | 20.7 | 40.2 | 0% | 12 |
| Sacerdote Folle | `sacerdote_folle` | attacca | 88% | 12% | 0% | 16.4 | 236.2 | 0% | 65 |
| Sacerdote Folle | `sacerdote_folle` | difendi | 0% | 3% | 97% | 60.9 | 318.7 | 0% | 0 |
| Sacerdote Folle | `sacerdote_folle` | studia | 50% | 50% | 0% | 20.4 | 334.9 | 0% | 34 |
| Sacerdote Folle | `sacerdote_folle` | casuale | 6% | 94% | 0% | 25.4 | 410.5 | 0% | 3 |
| Sadico | `sadico` | attacca | 100% | 0% | 0% | 7.6 | 97.9 | 0% | 35 |
| Sadico | `sadico` | difendi | 0% | 0% | 100% | 61.0 | 129.9 | 0% | 0 |
| Sadico | `sadico` | studia | 100% | 0% | 0% | 10.6 | 142.0 | 0% | 35 |
| Sadico | `sadico` | casuale | 97% | 3% | 0% | 23.2 | 259.0 | 0% | 34 |
| Slime Infimo | `slime_infimo` | attacca | 100% | 0% | 0% | 4.8 | 20.9 | 0% | 10 |
| Slime Infimo | `slime_infimo` | difendi | 0% | 0% | 100% | 61.0 | 82.1 | 0% | 0 |
| Slime Infimo | `slime_infimo` | studia | 100% | 0% | 0% | 7.8 | 37.7 | 0% | 10 |
| Slime Infimo | `slime_infimo` | casuale | 100% | 0% | 0% | 14.9 | 56.0 | 0% | 10 |
| Stigma | `stigma` | attacca | 100% | 0% | 0% | 7.6 | 97.9 | 0% | 35 |
| Stigma | `stigma` | difendi | 0% | 0% | 100% | 61.0 | 129.9 | 0% | 0 |
| Stigma | `stigma` | studia | 100% | 0% | 0% | 10.6 | 142.0 | 0% | 35 |
| Stigma | `stigma` | casuale | 97% | 3% | 0% | 23.2 | 259.0 | 0% | 34 |
| Tartaruga Innocente | `tartaruga_innocente` | attacca | 19% | 0% | 81% | 56.7 | 0.0 | 0% | 0 |
| Tartaruga Innocente | `tartaruga_innocente` | difendi | 0% | 0% | 100% | 61.0 | 0.0 | 0% | 0 |
| Tartaruga Innocente | `tartaruga_innocente` | studia | 100% | 0% | 0% | 1.0 | 0.0 | 100% | 1 |
| Tartaruga Innocente | `tartaruga_innocente` | casuale | 100% | 0% | 0% | 2.8 | 0.0 | 100% | 1 |
| Un tenero ricordo | `tenero_ricordo` | attacca | 0% | 100% | 0% | 8.5 | 425.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | difendi | 0% | 100% | 0% | 8.5 | 425.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | studia | 0% | 100% | 0% | 8.4 | 425.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | casuale | 0% | 100% | 0% | 8.8 | 425.0 | 0% | 0 |
| Teschio Errante | `teschio_errante` | attacca | 100% | 0% | 0% | 6.8 | 68.4 | 0% | 30 |
| Teschio Errante | `teschio_errante` | difendi | 0% | 0% | 100% | 61.0 | 115.9 | 0% | 0 |
| Teschio Errante | `teschio_errante` | studia | 100% | 0% | 0% | 9.8 | 104.3 | 0% | 30 |
| Teschio Errante | `teschio_errante` | casuale | 100% | 0% | 0% | 21.2 | 178.3 | 0% | 30 |
| Titano Zombie | `titano_zombie` | attacca | 0% | 100% | 0% | 18.0 | 425.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | difendi | 0% | 100% | 0% | 17.8 | 425.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | studia | 0% | 100% | 0% | 17.9 | 425.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | casuale | 0% | 100% | 0% | 16.4 | 425.0 | 0% | 0 |
| Capocantiere | `voce_registrata` | attacca | 100% | 0% | 0% | 4.8 | 20.9 | 0% | 10 |
| Capocantiere | `voce_registrata` | difendi | 0% | 0% | 100% | 61.0 | 82.1 | 0% | 0 |
| Capocantiere | `voce_registrata` | studia | 100% | 0% | 0% | 7.8 | 37.7 | 0% | 10 |
| Capocantiere | `voce_registrata` | casuale | 100% | 0% | 0% | 14.9 | 56.0 | 0% | 10 |
| Volto sulla parete | `volto_sulla_parete` | attacca | 0% | 100% | 0% | 15.0 | 425.0 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | difendi | 0% | 100% | 0% | 17.8 | 425.0 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | studia | 0% | 100% | 0% | 14.6 | 425.0 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | casuale | 0% | 100% | 0% | 15.5 | 425.0 | 0% | 0 |
| Zombie Cittadino | `zombie_cittadino` | attacca | 100% | 0% | 0% | 4.8 | 20.9 | 0% | 10 |
| Zombie Cittadino | `zombie_cittadino` | difendi | 0% | 0% | 100% | 61.0 | 82.1 | 0% | 0 |
| Zombie Cittadino | `zombie_cittadino` | studia | 100% | 0% | 0% | 7.7 | 37.0 | 0% | 10 |
| Zombie Cittadino | `zombie_cittadino` | casuale | 100% | 0% | 0% | 15.1 | 57.7 | 0% | 10 |
| Zombie Mostruoso | `zombie_mostruoso` | attacca | 100% | 0% | 0% | 4.8 | 20.9 | 0% | 10 |
| Zombie Mostruoso | `zombie_mostruoso` | difendi | 0% | 0% | 100% | 61.0 | 82.1 | 0% | 0 |
| Zombie Mostruoso | `zombie_mostruoso` | studia | 100% | 0% | 0% | 7.8 | 37.7 | 0% | 10 |
| Zombie Mostruoso | `zombie_mostruoso` | casuale | 100% | 0% | 0% | 14.9 | 56.0 | 0% | 10 |

## Protagonista di livello 12

| creatura | id | come si gioca | vinte | perse | ∞ | giri | danno | risp. | xp |
|---|---|---|--:|--:|--:|--:|--:|--:|--:|
| Abominio Marcio | `abominio_marcio` | attacca | 100% | 0% | 0% | 9.9 | 139.8 | 0% | 60 |
| Abominio Marcio | `abominio_marcio` | difendi | 0% | 0% | 100% | 61.0 | 257.2 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | studia | 100% | 0% | 0% | 12.9 | 188.1 | 0% | 60 |
| Abominio Marcio | `abominio_marcio` | casuale | 98% | 2% | 0% | 30.4 | 382.8 | 0% | 59 |
| Oppresso | `comparsa_di_ruggine` | attacca | 100% | 0% | 0% | 8.5 | 35.2 | 0% | 23 |
| Oppresso | `comparsa_di_ruggine` | difendi | 0% | 0% | 100% | 61.0 | 88.4 | 0% | 0 |
| Oppresso | `comparsa_di_ruggine` | studia | 100% | 0% | 0% | 11.2 | 47.7 | 0% | 23 |
| Oppresso | `comparsa_di_ruggine` | casuale | 100% | 0% | 0% | 26.0 | 92.3 | 0% | 23 |
| Diabolo | `diabolo` | attacca | 100% | 0% | 0% | 4.9 | 37.8 | 0% | 19 |
| Diabolo | `diabolo` | difendi | 0% | 0% | 100% | 61.0 | 111.0 | 0% | 0 |
| Diabolo | `diabolo` | studia | 100% | 0% | 0% | 7.9 | 67.3 | 0% | 19 |
| Diabolo | `diabolo` | casuale | 100% | 0% | 0% | 15.4 | 101.5 | 0% | 19 |
| Il Divoratore | `divoratore` | attacca | 100% | 0% | 0% | 8.6 | 96.9 | 0% | 42 |
| Il Divoratore | `divoratore` | difendi | 0% | 0% | 100% | 61.0 | 136.9 | 0% | 0 |
| Il Divoratore | `divoratore` | studia | 100% | 0% | 0% | 11.6 | 135.6 | 0% | 42 |
| Il Divoratore | `divoratore` | casuale | 100% | 0% | 0% | 26.8 | 267.7 | 0% | 42 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | attacca | 100% | 0% | 0% | 6.6 | 56.5 | 0% | 37 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | difendi | 0% | 0% | 100% | 61.0 | 133.0 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | studia | 100% | 0% | 0% | 9.6 | 84.5 | 0% | 37 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | casuale | 100% | 0% | 0% | 20.5 | 156.7 | 0% | 37 |
| Donna Spinosa | `donna_spinosa` | attacca | 100% | 0% | 0% | 7.5 | 100.1 | 0% | 51 |
| Donna Spinosa | `donna_spinosa` | difendi | 0% | 100% | 0% | 29.1 | 610.0 | 0% | 0 |
| Donna Spinosa | `donna_spinosa` | studia | 100% | 0% | 0% | 10.5 | 166.3 | 0% | 51 |
| Donna Spinosa | `donna_spinosa` | casuale | 60% | 40% | 0% | 20.9 | 462.0 | 0% | 31 |
| Ferraglia Urlante | `ferraglia_urlante` | attacca | 100% | 0% | 0% | 8.6 | 34.4 | 0% | 23 |
| Ferraglia Urlante | `ferraglia_urlante` | difendi | 0% | 0% | 100% | 61.0 | 88.4 | 0% | 0 |
| Ferraglia Urlante | `ferraglia_urlante` | studia | 100% | 0% | 0% | 11.6 | 48.7 | 0% | 23 |
| Ferraglia Urlante | `ferraglia_urlante` | casuale | 100% | 0% | 0% | 26.7 | 90.8 | 0% | 23 |
| Ghoul | `ghoul` | attacca | 100% | 0% | 0% | 4.9 | 37.8 | 0% | 19 |
| Ghoul | `ghoul` | difendi | 0% | 0% | 100% | 61.0 | 111.0 | 0% | 0 |
| Ghoul | `ghoul` | studia | 100% | 0% | 0% | 7.9 | 67.3 | 0% | 19 |
| Ghoul | `ghoul` | casuale | 100% | 0% | 0% | 15.4 | 101.5 | 0% | 19 |
| El Muy Bonito | `giocoliere` | attacca | 100% | 0% | 0% | 8.6 | 99.4 | 0% | 42 |
| El Muy Bonito | `giocoliere` | difendi | 0% | 0% | 100% | 61.0 | 137.3 | 0% | 0 |
| El Muy Bonito | `giocoliere` | studia | 100% | 0% | 0% | 10.9 | 300.6 | 0% | 42 |
| El Muy Bonito | `giocoliere` | casuale | 35% | 65% | 0% | 18.9 | 541.8 | 0% | 15 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | attacca | 34% | 66% | 0% | 32.6 | 586.1 | 0% | 118 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | difendi | 0% | 3% | 97% | 60.9 | 488.0 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | studia | 7% | 93% | 0% | 32.4 | 607.1 | 0% | 26 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | casuale | 0% | 100% | 0% | 41.0 | 610.0 | 0% | 0 |
| Goblin Tipico | `goblin_tipico` | attacca | 100% | 0% | 0% | 4.9 | 37.8 | 0% | 19 |
| Goblin Tipico | `goblin_tipico` | difendi | 0% | 0% | 100% | 61.0 | 111.0 | 0% | 0 |
| Goblin Tipico | `goblin_tipico` | studia | 100% | 0% | 0% | 7.9 | 67.3 | 0% | 19 |
| Goblin Tipico | `goblin_tipico` | casuale | 100% | 0% | 0% | 15.4 | 101.5 | 0% | 19 |
| Infetto Rapido | `infetto_rapido` | attacca | 100% | 0% | 0% | 3.8 | 28.8 | 0% | 21 |
| Infetto Rapido | `infetto_rapido` | difendi | 0% | 0% | 100% | 61.0 | 110.6 | 0% | 0 |
| Infetto Rapido | `infetto_rapido` | studia | 100% | 0% | 0% | 6.9 | 52.9 | 0% | 21 |
| Infetto Rapido | `infetto_rapido` | casuale | 100% | 0% | 0% | 11.1 | 65.0 | 0% | 21 |
| L'ultimo spettacolo di Jerah | `jerah` | attacca | 1% | 99% | 0% | 22.1 | 609.8 | 0% | 3 |
| L'ultimo spettacolo di Jerah | `jerah` | difendi | 0% | 99% | 1% | 36.5 | 609.9 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | studia | 0% | 100% | 0% | 26.5 | 610.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | casuale | 0% | 99% | 1% | 28.3 | 609.8 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | attacca | 53% | 47% | 0% | 38.8 | 539.5 | 0% | 216 |
| Jongo Dongo | `jongo_dongo` | difendi | 0% | 1% | 99% | 61.0 | 325.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | studia | 21% | 79% | 0% | 39.3 | 582.5 | 0% | 89 |
| Jongo Dongo | `jongo_dongo` | casuale | 0% | 67% | 33% | 53.5 | 573.4 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | attacca | 0% | 100% | 0% | 19.2 | 610.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | difendi | 0% | 100% | 0% | 30.3 | 610.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | studia | 0% | 100% | 0% | 19.3 | 610.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | casuale | 0% | 100% | 0% | 20.9 | 610.0 | 0% | 0 |
| ??? | `l_immortale` | attacca | 0% | 0% | 100% | 61.0 | 60.0 | 0% | 0 |
| ??? | `l_immortale` | difendi | 0% | 0% | 100% | 61.0 | 60.0 | 0% | 0 |
| ??? | `l_immortale` | studia | 0% | 0% | 100% | 61.0 | 60.0 | 0% | 0 |
| ??? | `l_immortale` | casuale | 0% | 0% | 100% | 61.0 | 60.0 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | attacca | 100% | 0% | 0% | 4.9 | 37.8 | 0% | 19 |
| Madre in Lacrime | `madre_in_lacrime` | difendi | 0% | 0% | 100% | 61.0 | 111.0 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | studia | 100% | 0% | 0% | 7.9 | 67.3 | 0% | 19 |
| Madre in Lacrime | `madre_in_lacrime` | casuale | 100% | 0% | 0% | 15.4 | 101.5 | 0% | 19 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | attacca | 0% | 100% | 0% | 6.0 | 610.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | difendi | 0% | 100% | 0% | 6.0 | 610.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | studia | 0% | 100% | 0% | 6.0 | 610.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | casuale | 0% | 100% | 0% | 6.0 | 610.0 | 0% | 0 |
| Marionetta | `marionetta` | attacca | 100% | 0% | 0% | 7.6 | 125.8 | 0% | 51 |
| Marionetta | `marionetta` | difendi | 0% | 0% | 100% | 61.0 | 334.2 | 0% | 0 |
| Marionetta | `marionetta` | studia | 100% | 0% | 0% | 10.4 | 177.6 | 0% | 51 |
| Marionetta | `marionetta` | casuale | 99% | 1% | 0% | 23.1 | 358.4 | 0% | 50 |
| Fomentado | `maschera_vuota` | attacca | 100% | 0% | 0% | 4.9 | 37.8 | 0% | 19 |
| Fomentado | `maschera_vuota` | difendi | 0% | 0% | 100% | 61.0 | 111.0 | 0% | 0 |
| Fomentado | `maschera_vuota` | studia | 100% | 0% | 0% | 7.7 | 64.8 | 0% | 19 |
| Fomentado | `maschera_vuota` | casuale | 100% | 0% | 0% | 14.1 | 93.6 | 0% | 19 |
| Nuvola di Marciume | `nuvola_di_marciume` | attacca | 100% | 0% | 0% | 3.8 | 28.8 | 0% | 21 |
| Nuvola di Marciume | `nuvola_di_marciume` | difendi | 0% | 0% | 100% | 61.0 | 110.6 | 0% | 0 |
| Nuvola di Marciume | `nuvola_di_marciume` | studia | 100% | 0% | 0% | 6.9 | 52.9 | 0% | 21 |
| Nuvola di Marciume | `nuvola_di_marciume` | casuale | 100% | 0% | 0% | 11.1 | 65.0 | 0% | 21 |
| Ombra del passato | `ombra_del_passato` | attacca | 100% | 0% | 0% | 8.5 | 157.3 | 0% | 55 |
| Ombra del passato | `ombra_del_passato` | difendi | 0% | 4% | 96% | 60.9 | 512.8 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | studia | 100% | 0% | 0% | 11.2 | 214.7 | 0% | 55 |
| Ombra del passato | `ombra_del_passato` | casuale | 87% | 13% | 0% | 25.6 | 452.5 | 0% | 48 |
| Emblema dell'oppressione | `operaio_posseduto` | attacca | 100% | 0% | 0% | 4.9 | 37.8 | 0% | 19 |
| Emblema dell'oppressione | `operaio_posseduto` | difendi | 0% | 0% | 100% | 61.0 | 111.0 | 0% | 0 |
| Emblema dell'oppressione | `operaio_posseduto` | studia | 100% | 0% | 0% | 7.9 | 66.4 | 0% | 19 |
| Emblema dell'oppressione | `operaio_posseduto` | casuale | 100% | 0% | 0% | 15.6 | 105.1 | 0% | 19 |
| Operaio Sfruttato | `operaio_sfruttato` | attacca | 100% | 0% | 0% | 8.6 | 99.4 | 0% | 42 |
| Operaio Sfruttato | `operaio_sfruttato` | difendi | 0% | 0% | 100% | 61.0 | 137.3 | 0% | 0 |
| Operaio Sfruttato | `operaio_sfruttato` | studia | 100% | 0% | 0% | 11.6 | 139.8 | 0% | 42 |
| Operaio Sfruttato | `operaio_sfruttato` | casuale | 100% | 0% | 0% | 26.0 | 265.5 | 0% | 42 |
| Orrore di Meridia | `orrore_di_meridia` | attacca | 100% | 0% | 0% | 8.7 | 60.8 | 0% | 42 |
| Orrore di Meridia | `orrore_di_meridia` | difendi | 0% | 0% | 100% | 61.0 | 115.9 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | studia | 100% | 0% | 0% | 11.7 | 82.8 | 0% | 42 |
| Orrore di Meridia | `orrore_di_meridia` | casuale | 100% | 0% | 0% | 26.4 | 160.8 | 0% | 42 |
| Robo Pattuglia | `robo_pattuglia` | attacca | 100% | 0% | 0% | 8.5 | 35.2 | 0% | 23 |
| Robo Pattuglia | `robo_pattuglia` | difendi | 0% | 0% | 100% | 61.0 | 88.4 | 0% | 0 |
| Robo Pattuglia | `robo_pattuglia` | studia | 100% | 0% | 0% | 11.2 | 47.7 | 0% | 23 |
| Robo Pattuglia | `robo_pattuglia` | casuale | 100% | 0% | 0% | 26.0 | 92.3 | 0% | 23 |
| Sacerdote Folle | `sacerdote_folle` | attacca | 100% | 0% | 0% | 9.9 | 85.6 | 0% | 50 |
| Sacerdote Folle | `sacerdote_folle` | difendi | 0% | 0% | 100% | 61.0 | 250.1 | 0% | 0 |
| Sacerdote Folle | `sacerdote_folle` | studia | 100% | 0% | 0% | 17.8 | 192.7 | 0% | 57 |
| Sacerdote Folle | `sacerdote_folle` | casuale | 46% | 54% | 0% | 38.7 | 495.6 | 0% | 30 |
| Sadico | `sadico` | attacca | 100% | 0% | 0% | 4.9 | 37.8 | 0% | 19 |
| Sadico | `sadico` | difendi | 0% | 0% | 100% | 61.0 | 111.0 | 0% | 0 |
| Sadico | `sadico` | studia | 100% | 0% | 0% | 7.9 | 67.3 | 0% | 19 |
| Sadico | `sadico` | casuale | 100% | 0% | 0% | 15.4 | 101.5 | 0% | 19 |
| Slime Infimo | `slime_infimo` | attacca | 100% | 0% | 0% | 4.9 | 37.8 | 0% | 19 |
| Slime Infimo | `slime_infimo` | difendi | 0% | 0% | 100% | 61.0 | 111.0 | 0% | 0 |
| Slime Infimo | `slime_infimo` | studia | 100% | 0% | 0% | 7.9 | 67.3 | 0% | 19 |
| Slime Infimo | `slime_infimo` | casuale | 100% | 0% | 0% | 15.4 | 101.5 | 0% | 19 |
| Stigma | `stigma` | attacca | 100% | 0% | 0% | 4.9 | 37.8 | 0% | 19 |
| Stigma | `stigma` | difendi | 0% | 0% | 100% | 61.0 | 111.0 | 0% | 0 |
| Stigma | `stigma` | studia | 100% | 0% | 0% | 7.9 | 67.3 | 0% | 19 |
| Stigma | `stigma` | casuale | 100% | 0% | 0% | 15.4 | 101.5 | 0% | 19 |
| Tartaruga Innocente | `tartaruga_innocente` | attacca | 100% | 0% | 0% | 9.3 | 0.0 | 0% | 1 |
| Tartaruga Innocente | `tartaruga_innocente` | difendi | 0% | 0% | 100% | 61.0 | 0.0 | 0% | 0 |
| Tartaruga Innocente | `tartaruga_innocente` | studia | 100% | 0% | 0% | 1.0 | 0.0 | 100% | 1 |
| Tartaruga Innocente | `tartaruga_innocente` | casuale | 100% | 0% | 0% | 2.8 | 0.0 | 100% | 1 |
| Un tenero ricordo | `tenero_ricordo` | attacca | 0% | 100% | 0% | 8.9 | 610.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | difendi | 0% | 100% | 0% | 8.5 | 610.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | studia | 0% | 100% | 0% | 8.6 | 610.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | casuale | 0% | 100% | 0% | 8.9 | 610.0 | 0% | 0 |
| Teschio Errante | `teschio_errante` | attacca | 100% | 0% | 0% | 4.9 | 37.8 | 0% | 19 |
| Teschio Errante | `teschio_errante` | difendi | 0% | 0% | 100% | 61.0 | 111.0 | 0% | 0 |
| Teschio Errante | `teschio_errante` | studia | 100% | 0% | 0% | 7.9 | 67.3 | 0% | 19 |
| Teschio Errante | `teschio_errante` | casuale | 100% | 0% | 0% | 15.4 | 101.5 | 0% | 19 |
| Titano Zombie | `titano_zombie` | attacca | 70% | 30% | 0% | 18.1 | 558.6 | 0% | 42 |
| Titano Zombie | `titano_zombie` | difendi | 0% | 100% | 0% | 21.5 | 610.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | studia | 46% | 54% | 0% | 19.8 | 585.1 | 0% | 28 |
| Titano Zombie | `titano_zombie` | casuale | 0% | 100% | 0% | 20.6 | 610.0 | 0% | 0 |
| Capocantiere | `voce_registrata` | attacca | 100% | 0% | 0% | 4.9 | 37.8 | 0% | 19 |
| Capocantiere | `voce_registrata` | difendi | 0% | 0% | 100% | 61.0 | 111.0 | 0% | 0 |
| Capocantiere | `voce_registrata` | studia | 100% | 0% | 0% | 7.9 | 67.3 | 0% | 19 |
| Capocantiere | `voce_registrata` | casuale | 100% | 0% | 0% | 15.4 | 101.5 | 0% | 19 |
| Volto sulla parete | `volto_sulla_parete` | attacca | 1% | 99% | 0% | 21.7 | 609.2 | 0% | 4 |
| Volto sulla parete | `volto_sulla_parete` | difendi | 0% | 100% | 0% | 24.9 | 610.0 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | studia | 0% | 100% | 0% | 21.5 | 610.0 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | casuale | 0% | 100% | 0% | 22.1 | 610.0 | 0% | 0 |
| Zombie Cittadino | `zombie_cittadino` | attacca | 100% | 0% | 0% | 4.9 | 37.8 | 0% | 19 |
| Zombie Cittadino | `zombie_cittadino` | difendi | 0% | 0% | 100% | 61.0 | 111.0 | 0% | 0 |
| Zombie Cittadino | `zombie_cittadino` | studia | 100% | 0% | 0% | 7.9 | 66.4 | 0% | 19 |
| Zombie Cittadino | `zombie_cittadino` | casuale | 100% | 0% | 0% | 15.6 | 105.1 | 0% | 19 |
| Zombie Mostruoso | `zombie_mostruoso` | attacca | 100% | 0% | 0% | 4.9 | 37.8 | 0% | 19 |
| Zombie Mostruoso | `zombie_mostruoso` | difendi | 0% | 0% | 100% | 61.0 | 111.0 | 0% | 0 |
| Zombie Mostruoso | `zombie_mostruoso` | studia | 100% | 0% | 0% | 7.9 | 67.3 | 0% | 19 |
| Zombie Mostruoso | `zombie_mostruoso` | casuale | 100% | 0% | 0% | 15.4 | 101.5 | 0% | 19 |

## Protagonista di livello 18

| creatura | id | come si gioca | vinte | perse | ∞ | giri | danno | risp. | xp |
|---|---|---|--:|--:|--:|--:|--:|--:|--:|
| Abominio Marcio | `abominio_marcio` | attacca | 100% | 0% | 0% | 9.9 | 168.7 | 0% | 71 |
| Abominio Marcio | `abominio_marcio` | difendi | 0% | 0% | 100% | 61.0 | 519.4 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | studia | 100% | 0% | 0% | 12.9 | 227.2 | 0% | 71 |
| Abominio Marcio | `abominio_marcio` | casuale | 99% | 1% | 0% | 30.5 | 501.9 | 0% | 70 |
| Oppresso | `comparsa_di_ruggine` | attacca | 100% | 0% | 0% | 10.3 | 72.9 | 0% | 39 |
| Oppresso | `comparsa_di_ruggine` | difendi | 0% | 0% | 100% | 61.0 | 117.0 | 0% | 0 |
| Oppresso | `comparsa_di_ruggine` | studia | 100% | 0% | 0% | 13.0 | 94.1 | 0% | 39 |
| Oppresso | `comparsa_di_ruggine` | casuale | 100% | 0% | 0% | 31.6 | 187.8 | 0% | 39 |
| Diabolo | `diabolo` | attacca | 100% | 0% | 0% | 5.7 | 66.9 | 0% | 32 |
| Diabolo | `diabolo` | difendi | 0% | 0% | 100% | 61.0 | 265.4 | 0% | 0 |
| Diabolo | `diabolo` | studia | 100% | 0% | 0% | 8.8 | 109.5 | 0% | 32 |
| Diabolo | `diabolo` | casuale | 100% | 0% | 0% | 17.8 | 197.3 | 0% | 32 |
| Il Divoratore | `divoratore` | attacca | 100% | 0% | 0% | 9.9 | 168.7 | 0% | 71 |
| Il Divoratore | `divoratore` | difendi | 0% | 0% | 100% | 61.0 | 519.4 | 0% | 0 |
| Il Divoratore | `divoratore` | studia | 100% | 0% | 0% | 12.9 | 227.2 | 0% | 71 |
| Il Divoratore | `divoratore` | casuale | 99% | 1% | 0% | 30.5 | 501.9 | 0% | 70 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | attacca | 100% | 0% | 0% | 5.7 | 48.4 | 0% | 32 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | difendi | 0% | 0% | 100% | 61.0 | 214.9 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | studia | 100% | 0% | 0% | 8.8 | 76.0 | 0% | 32 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | casuale | 100% | 0% | 0% | 17.3 | 137.1 | 0% | 32 |
| Donna Spinosa | `donna_spinosa` | attacca | 100% | 0% | 0% | 5.6 | 52.4 | 0% | 32 |
| Donna Spinosa | `donna_spinosa` | difendi | 0% | 100% | 0% | 35.7 | 890.0 | 0% | 0 |
| Donna Spinosa | `donna_spinosa` | studia | 100% | 0% | 0% | 8.7 | 100.3 | 0% | 32 |
| Donna Spinosa | `donna_spinosa` | casuale | 96% | 4% | 0% | 17.5 | 318.6 | 0% | 31 |
| Ferraglia Urlante | `ferraglia_urlante` | attacca | 100% | 0% | 0% | 10.4 | 73.1 | 0% | 39 |
| Ferraglia Urlante | `ferraglia_urlante` | difendi | 0% | 0% | 100% | 61.0 | 117.0 | 0% | 0 |
| Ferraglia Urlante | `ferraglia_urlante` | studia | 100% | 0% | 0% | 13.4 | 97.4 | 0% | 39 |
| Ferraglia Urlante | `ferraglia_urlante` | casuale | 99% | 0% | 1% | 32.1 | 186.5 | 0% | 39 |
| Ghoul | `ghoul` | attacca | 100% | 0% | 0% | 5.7 | 66.9 | 0% | 32 |
| Ghoul | `ghoul` | difendi | 0% | 0% | 100% | 61.0 | 265.4 | 0% | 0 |
| Ghoul | `ghoul` | studia | 100% | 0% | 0% | 8.8 | 109.5 | 0% | 32 |
| Ghoul | `ghoul` | casuale | 100% | 0% | 0% | 17.8 | 197.3 | 0% | 32 |
| El Muy Bonito | `giocoliere` | attacca | 100% | 0% | 0% | 9.9 | 172.0 | 0% | 71 |
| El Muy Bonito | `giocoliere` | difendi | 0% | 0% | 100% | 61.0 | 527.4 | 0% | 0 |
| El Muy Bonito | `giocoliere` | studia | 100% | 0% | 0% | 12.6 | 416.5 | 0% | 71 |
| El Muy Bonito | `giocoliere` | casuale | 29% | 71% | 0% | 22.2 | 817.6 | 0% | 20 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | attacca | 64% | 36% | 0% | 35.2 | 815.5 | 0% | 333 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | difendi | 0% | 35% | 65% | 59.2 | 812.7 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | studia | 22% | 78% | 0% | 36.1 | 875.1 | 0% | 114 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | casuale | 0% | 98% | 2% | 42.8 | 888.6 | 0% | 0 |
| Goblin Tipico | `goblin_tipico` | attacca | 100% | 0% | 0% | 5.7 | 66.9 | 0% | 32 |
| Goblin Tipico | `goblin_tipico` | difendi | 0% | 0% | 100% | 61.0 | 265.4 | 0% | 0 |
| Goblin Tipico | `goblin_tipico` | studia | 100% | 0% | 0% | 8.8 | 109.5 | 0% | 32 |
| Goblin Tipico | `goblin_tipico` | casuale | 100% | 0% | 0% | 17.8 | 197.3 | 0% | 32 |
| Infetto Rapido | `infetto_rapido` | attacca | 100% | 0% | 0% | 3.9 | 46.4 | 0% | 36 |
| Infetto Rapido | `infetto_rapido` | difendi | 0% | 0% | 100% | 61.0 | 149.0 | 0% | 0 |
| Infetto Rapido | `infetto_rapido` | studia | 100% | 0% | 0% | 7.0 | 83.6 | 0% | 36 |
| Infetto Rapido | `infetto_rapido` | casuale | 100% | 0% | 0% | 11.7 | 111.4 | 0% | 36 |
| L'ultimo spettacolo di Jerah | `jerah` | attacca | 37% | 63% | 0% | 30.5 | 808.0 | 0% | 191 |
| L'ultimo spettacolo di Jerah | `jerah` | difendi | 0% | 83% | 17% | 52.7 | 875.2 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | studia | 38% | 62% | 0% | 36.8 | 797.7 | 0% | 195 |
| L'ultimo spettacolo di Jerah | `jerah` | casuale | 0% | 91% | 9% | 40.6 | 876.8 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | attacca | 71% | 29% | 0% | 38.9 | 706.8 | 0% | 446 |
| Jongo Dongo | `jongo_dongo` | difendi | 0% | 2% | 98% | 60.9 | 541.6 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | studia | 49% | 51% | 0% | 40.9 | 780.5 | 0% | 309 |
| Jongo Dongo | `jongo_dongo` | casuale | 0% | 56% | 44% | 54.8 | 811.7 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | attacca | 5% | 95% | 0% | 26.9 | 888.3 | 0% | 26 |
| Jongo Dongo | `jongo_dongo_risorto` | difendi | 0% | 100% | 0% | 39.1 | 890.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | studia | 0% | 100% | 0% | 26.7 | 890.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | casuale | 0% | 100% | 0% | 29.0 | 890.0 | 0% | 0 |
| ??? | `l_immortale` | attacca | 0% | 0% | 100% | 61.0 | 60.0 | 0% | 0 |
| ??? | `l_immortale` | difendi | 0% | 0% | 100% | 61.0 | 60.0 | 0% | 0 |
| ??? | `l_immortale` | studia | 0% | 0% | 100% | 61.0 | 60.0 | 0% | 0 |
| ??? | `l_immortale` | casuale | 0% | 0% | 100% | 61.0 | 60.0 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | attacca | 100% | 0% | 0% | 5.7 | 66.9 | 0% | 32 |
| Madre in Lacrime | `madre_in_lacrime` | difendi | 0% | 0% | 100% | 61.0 | 265.4 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | studia | 100% | 0% | 0% | 8.8 | 109.5 | 0% | 32 |
| Madre in Lacrime | `madre_in_lacrime` | casuale | 100% | 0% | 0% | 17.8 | 197.3 | 0% | 32 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | attacca | 0% | 100% | 0% | 6.0 | 890.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | difendi | 0% | 100% | 0% | 6.0 | 890.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | studia | 0% | 100% | 0% | 6.0 | 890.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | casuale | 0% | 100% | 0% | 6.0 | 890.0 | 0% | 0 |
| Marionetta | `marionetta` | attacca | 100% | 0% | 0% | 5.7 | 66.9 | 0% | 32 |
| Marionetta | `marionetta` | difendi | 0% | 0% | 100% | 61.0 | 265.4 | 0% | 0 |
| Marionetta | `marionetta` | studia | 100% | 0% | 0% | 8.6 | 106.5 | 0% | 32 |
| Marionetta | `marionetta` | casuale | 100% | 0% | 0% | 17.8 | 200.9 | 0% | 32 |
| Fomentado | `maschera_vuota` | attacca | 100% | 0% | 0% | 5.7 | 66.9 | 0% | 32 |
| Fomentado | `maschera_vuota` | difendi | 0% | 0% | 100% | 61.0 | 265.4 | 0% | 0 |
| Fomentado | `maschera_vuota` | studia | 100% | 0% | 0% | 8.6 | 106.4 | 0% | 32 |
| Fomentado | `maschera_vuota` | casuale | 100% | 0% | 0% | 16.2 | 181.6 | 0% | 32 |
| Nuvola di Marciume | `nuvola_di_marciume` | attacca | 100% | 0% | 0% | 3.9 | 46.4 | 0% | 36 |
| Nuvola di Marciume | `nuvola_di_marciume` | difendi | 0% | 0% | 100% | 61.0 | 149.0 | 0% | 0 |
| Nuvola di Marciume | `nuvola_di_marciume` | studia | 100% | 0% | 0% | 7.0 | 83.6 | 0% | 36 |
| Nuvola di Marciume | `nuvola_di_marciume` | casuale | 100% | 0% | 0% | 11.7 | 111.4 | 0% | 36 |
| Ombra del passato | `ombra_del_passato` | attacca | 100% | 0% | 0% | 5.7 | 66.9 | 0% | 32 |
| Ombra del passato | `ombra_del_passato` | difendi | 0% | 0% | 100% | 61.0 | 265.4 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | studia | 100% | 0% | 0% | 8.6 | 106.5 | 0% | 32 |
| Ombra del passato | `ombra_del_passato` | casuale | 100% | 0% | 0% | 17.8 | 200.9 | 0% | 32 |
| Emblema dell'oppressione | `operaio_posseduto` | attacca | 100% | 0% | 0% | 5.7 | 66.9 | 0% | 32 |
| Emblema dell'oppressione | `operaio_posseduto` | difendi | 0% | 0% | 100% | 61.0 | 265.4 | 0% | 0 |
| Emblema dell'oppressione | `operaio_posseduto` | studia | 100% | 0% | 0% | 8.6 | 106.5 | 0% | 32 |
| Emblema dell'oppressione | `operaio_posseduto` | casuale | 100% | 0% | 0% | 17.8 | 200.9 | 0% | 32 |
| Operaio Sfruttato | `operaio_sfruttato` | attacca | 100% | 0% | 0% | 9.9 | 172.0 | 0% | 71 |
| Operaio Sfruttato | `operaio_sfruttato` | difendi | 0% | 0% | 100% | 61.0 | 527.4 | 0% | 0 |
| Operaio Sfruttato | `operaio_sfruttato` | studia | 100% | 0% | 0% | 12.9 | 231.7 | 0% | 71 |
| Operaio Sfruttato | `operaio_sfruttato` | casuale | 100% | 0% | 0% | 30.1 | 498.3 | 0% | 71 |
| Orrore di Meridia | `orrore_di_meridia` | attacca | 100% | 0% | 0% | 9.9 | 91.0 | 0% | 71 |
| Orrore di Meridia | `orrore_di_meridia` | difendi | 0% | 0% | 100% | 61.0 | 305.3 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | studia | 100% | 0% | 0% | 13.0 | 120.8 | 0% | 71 |
| Orrore di Meridia | `orrore_di_meridia` | casuale | 100% | 0% | 0% | 29.8 | 264.6 | 0% | 71 |
| Robo Pattuglia | `robo_pattuglia` | attacca | 100% | 0% | 0% | 10.3 | 72.9 | 0% | 39 |
| Robo Pattuglia | `robo_pattuglia` | difendi | 0% | 0% | 100% | 61.0 | 117.0 | 0% | 0 |
| Robo Pattuglia | `robo_pattuglia` | studia | 100% | 0% | 0% | 13.0 | 94.1 | 0% | 39 |
| Robo Pattuglia | `robo_pattuglia` | casuale | 100% | 0% | 0% | 31.6 | 187.8 | 0% | 39 |
| Sacerdote Folle | `sacerdote_folle` | attacca | 100% | 0% | 0% | 9.0 | 95.2 | 0% | 51 |
| Sacerdote Folle | `sacerdote_folle` | difendi | 0% | 0% | 100% | 61.0 | 519.9 | 0% | 0 |
| Sacerdote Folle | `sacerdote_folle` | studia | 100% | 0% | 0% | 17.2 | 246.5 | 0% | 64 |
| Sacerdote Folle | `sacerdote_folle` | casuale | 41% | 59% | 1% | 36.7 | 700.8 | 0% | 28 |
| Sadico | `sadico` | attacca | 100% | 0% | 0% | 5.7 | 66.9 | 0% | 32 |
| Sadico | `sadico` | difendi | 0% | 0% | 100% | 61.0 | 265.4 | 0% | 0 |
| Sadico | `sadico` | studia | 100% | 0% | 0% | 8.8 | 109.5 | 0% | 32 |
| Sadico | `sadico` | casuale | 100% | 0% | 0% | 17.8 | 197.3 | 0% | 32 |
| Slime Infimo | `slime_infimo` | attacca | 100% | 0% | 0% | 5.7 | 66.9 | 0% | 32 |
| Slime Infimo | `slime_infimo` | difendi | 0% | 0% | 100% | 61.0 | 265.4 | 0% | 0 |
| Slime Infimo | `slime_infimo` | studia | 100% | 0% | 0% | 8.8 | 109.5 | 0% | 32 |
| Slime Infimo | `slime_infimo` | casuale | 100% | 0% | 0% | 17.8 | 197.3 | 0% | 32 |
| Stigma | `stigma` | attacca | 100% | 0% | 0% | 5.7 | 66.9 | 0% | 32 |
| Stigma | `stigma` | difendi | 0% | 0% | 100% | 61.0 | 265.4 | 0% | 0 |
| Stigma | `stigma` | studia | 100% | 0% | 0% | 8.8 | 109.5 | 0% | 32 |
| Stigma | `stigma` | casuale | 100% | 0% | 0% | 17.8 | 197.3 | 0% | 32 |
| Tartaruga Innocente | `tartaruga_innocente` | attacca | 100% | 0% | 0% | 5.2 | 0.0 | 0% | 1 |
| Tartaruga Innocente | `tartaruga_innocente` | difendi | 0% | 0% | 100% | 61.0 | 0.0 | 0% | 0 |
| Tartaruga Innocente | `tartaruga_innocente` | studia | 100% | 0% | 0% | 1.0 | 0.0 | 100% | 1 |
| Tartaruga Innocente | `tartaruga_innocente` | casuale | 100% | 0% | 0% | 2.8 | 0.0 | 99% | 1 |
| Un tenero ricordo | `tenero_ricordo` | attacca | 0% | 100% | 0% | 10.0 | 890.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | difendi | 0% | 100% | 0% | 9.5 | 890.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | studia | 0% | 100% | 0% | 9.6 | 890.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | casuale | 0% | 100% | 0% | 10.3 | 890.0 | 0% | 0 |
| Teschio Errante | `teschio_errante` | attacca | 100% | 0% | 0% | 5.7 | 66.9 | 0% | 32 |
| Teschio Errante | `teschio_errante` | difendi | 0% | 0% | 100% | 61.0 | 265.4 | 0% | 0 |
| Teschio Errante | `teschio_errante` | studia | 100% | 0% | 0% | 8.8 | 109.5 | 0% | 32 |
| Teschio Errante | `teschio_errante` | casuale | 100% | 0% | 0% | 17.8 | 197.3 | 0% | 32 |
| Titano Zombie | `titano_zombie` | attacca | 87% | 13% | 0% | 18.1 | 792.4 | 0% | 62 |
| Titano Zombie | `titano_zombie` | difendi | 0% | 100% | 0% | 22.0 | 890.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | studia | 63% | 37% | 0% | 20.4 | 842.2 | 0% | 44 |
| Titano Zombie | `titano_zombie` | casuale | 0% | 100% | 0% | 21.9 | 890.0 | 0% | 0 |
| Capocantiere | `voce_registrata` | attacca | 100% | 0% | 0% | 5.7 | 66.9 | 0% | 32 |
| Capocantiere | `voce_registrata` | difendi | 0% | 0% | 100% | 61.0 | 265.4 | 0% | 0 |
| Capocantiere | `voce_registrata` | studia | 100% | 0% | 0% | 8.8 | 109.5 | 0% | 32 |
| Capocantiere | `voce_registrata` | casuale | 100% | 0% | 0% | 17.8 | 197.3 | 0% | 32 |
| Volto sulla parete | `volto_sulla_parete` | attacca | 100% | 0% | 0% | 16.7 | 318.4 | 0% | 145 |
| Volto sulla parete | `volto_sulla_parete` | difendi | 0% | 100% | 0% | 35.1 | 890.0 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | studia | 100% | 0% | 0% | 19.7 | 418.5 | 0% | 145 |
| Volto sulla parete | `volto_sulla_parete` | casuale | 1% | 99% | 0% | 31.8 | 889.6 | 0% | 1 |
| Zombie Cittadino | `zombie_cittadino` | attacca | 100% | 0% | 0% | 5.7 | 66.9 | 0% | 32 |
| Zombie Cittadino | `zombie_cittadino` | difendi | 0% | 0% | 100% | 61.0 | 265.4 | 0% | 0 |
| Zombie Cittadino | `zombie_cittadino` | studia | 100% | 0% | 0% | 8.6 | 106.5 | 0% | 32 |
| Zombie Cittadino | `zombie_cittadino` | casuale | 100% | 0% | 0% | 17.8 | 200.9 | 0% | 32 |
| Zombie Mostruoso | `zombie_mostruoso` | attacca | 100% | 0% | 0% | 5.7 | 66.9 | 0% | 32 |
| Zombie Mostruoso | `zombie_mostruoso` | difendi | 0% | 0% | 100% | 61.0 | 265.4 | 0% | 0 |
| Zombie Mostruoso | `zombie_mostruoso` | studia | 100% | 0% | 0% | 8.8 | 109.5 | 0% | 32 |
| Zombie Mostruoso | `zombie_mostruoso` | casuale | 100% | 0% | 0% | 17.8 | 197.3 | 0% | 32 |

## Protagonista di livello 25

| creatura | id | come si gioca | vinte | perse | ∞ | giri | danno | risp. | xp |
|---|---|---|--:|--:|--:|--:|--:|--:|--:|
| Abominio Marcio | `abominio_marcio` | attacca | 100% | 0% | 0% | 10.5 | 281.0 | 0% | 101 |
| Abominio Marcio | `abominio_marcio` | difendi | 0% | 19% | 81% | 60.6 | 1142.9 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | studia | 100% | 0% | 0% | 13.5 | 371.6 | 0% | 101 |
| Abominio Marcio | `abominio_marcio` | casuale | 93% | 7% | 0% | 31.9 | 840.8 | 0% | 94 |
| Oppresso | `comparsa_di_ruggine` | attacca | 100% | 0% | 0% | 11.2 | 125.5 | 0% | 55 |
| Oppresso | `comparsa_di_ruggine` | difendi | 0% | 0% | 100% | 61.0 | 325.8 | 0% | 0 |
| Oppresso | `comparsa_di_ruggine` | studia | 100% | 0% | 0% | 13.9 | 157.5 | 0% | 55 |
| Oppresso | `comparsa_di_ruggine` | casuale | 100% | 0% | 0% | 34.2 | 346.8 | 0% | 55 |
| Diabolo | `diabolo` | attacca | 100% | 0% | 0% | 6.6 | 127.9 | 0% | 46 |
| Diabolo | `diabolo` | difendi | 0% | 0% | 100% | 61.0 | 718.2 | 0% | 0 |
| Diabolo | `diabolo` | studia | 100% | 0% | 0% | 9.7 | 196.2 | 0% | 46 |
| Diabolo | `diabolo` | casuale | 100% | 0% | 0% | 20.5 | 386.8 | 0% | 46 |
| Il Divoratore | `divoratore` | attacca | 100% | 0% | 0% | 10.5 | 281.0 | 0% | 101 |
| Il Divoratore | `divoratore` | difendi | 0% | 19% | 81% | 60.6 | 1142.9 | 0% | 0 |
| Il Divoratore | `divoratore` | studia | 100% | 0% | 0% | 13.5 | 371.6 | 0% | 101 |
| Il Divoratore | `divoratore` | casuale | 93% | 7% | 0% | 31.9 | 840.8 | 0% | 94 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | attacca | 100% | 0% | 0% | 6.6 | 88.3 | 0% | 46 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | difendi | 0% | 0% | 100% | 61.0 | 514.1 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | studia | 100% | 0% | 0% | 9.6 | 131.6 | 0% | 46 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | casuale | 100% | 0% | 0% | 20.5 | 265.1 | 0% | 46 |
| Donna Spinosa | `donna_spinosa` | attacca | 100% | 0% | 0% | 6.5 | 94.4 | 0% | 46 |
| Donna Spinosa | `donna_spinosa` | difendi | 0% | 100% | 0% | 38.8 | 1220.0 | 0% | 0 |
| Donna Spinosa | `donna_spinosa` | studia | 100% | 0% | 0% | 9.6 | 159.1 | 0% | 46 |
| Donna Spinosa | `donna_spinosa` | casuale | 97% | 3% | 0% | 20.2 | 503.5 | 0% | 44 |
| Ferraglia Urlante | `ferraglia_urlante` | attacca | 100% | 0% | 0% | 11.4 | 126.1 | 0% | 55 |
| Ferraglia Urlante | `ferraglia_urlante` | difendi | 0% | 0% | 100% | 61.0 | 325.8 | 0% | 0 |
| Ferraglia Urlante | `ferraglia_urlante` | studia | 100% | 0% | 0% | 14.4 | 164.0 | 0% | 55 |
| Ferraglia Urlante | `ferraglia_urlante` | casuale | 99% | 0% | 1% | 35.2 | 350.6 | 0% | 54 |
| Ghoul | `ghoul` | attacca | 100% | 0% | 0% | 6.6 | 127.9 | 0% | 46 |
| Ghoul | `ghoul` | difendi | 0% | 0% | 100% | 61.0 | 718.2 | 0% | 0 |
| Ghoul | `ghoul` | studia | 100% | 0% | 0% | 9.7 | 196.2 | 0% | 46 |
| Ghoul | `ghoul` | casuale | 100% | 0% | 0% | 20.5 | 386.8 | 0% | 46 |
| El Muy Bonito | `giocoliere` | attacca | 100% | 0% | 0% | 10.5 | 283.2 | 0% | 101 |
| El Muy Bonito | `giocoliere` | difendi | 0% | 19% | 81% | 60.7 | 1150.4 | 0% | 0 |
| El Muy Bonito | `giocoliere` | studia | 100% | 0% | 0% | 13.5 | 589.6 | 0% | 101 |
| El Muy Bonito | `giocoliere` | casuale | 25% | 75% | 0% | 23.8 | 1152.1 | 0% | 25 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | attacca | 27% | 73% | 0% | 33.8 | 1180.4 | 0% | 191 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | difendi | 0% | 96% | 4% | 48.0 | 1217.7 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | studia | 6% | 94% | 0% | 33.5 | 1216.9 | 0% | 42 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | casuale | 0% | 99% | 1% | 37.7 | 1219.3 | 0% | 0 |
| Goblin Tipico | `goblin_tipico` | attacca | 100% | 0% | 0% | 6.6 | 127.9 | 0% | 46 |
| Goblin Tipico | `goblin_tipico` | difendi | 0% | 0% | 100% | 61.0 | 718.2 | 0% | 0 |
| Goblin Tipico | `goblin_tipico` | studia | 100% | 0% | 0% | 9.7 | 196.2 | 0% | 46 |
| Goblin Tipico | `goblin_tipico` | casuale | 100% | 0% | 0% | 20.5 | 386.8 | 0% | 46 |
| Infetto Rapido | `infetto_rapido` | attacca | 100% | 0% | 0% | 3.9 | 71.4 | 0% | 51 |
| Infetto Rapido | `infetto_rapido` | difendi | 0% | 0% | 100% | 61.0 | 488.5 | 0% | 0 |
| Infetto Rapido | `infetto_rapido` | studia | 100% | 0% | 0% | 7.0 | 128.7 | 0% | 51 |
| Infetto Rapido | `infetto_rapido` | casuale | 100% | 0% | 0% | 11.7 | 189.0 | 0% | 51 |
| L'ultimo spettacolo di Jerah | `jerah` | attacca | 29% | 71% | 0% | 29.2 | 1120.1 | 0% | 195 |
| L'ultimo spettacolo di Jerah | `jerah` | difendi | 0% | 92% | 8% | 44.1 | 1202.6 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | studia | 34% | 66% | 0% | 34.3 | 1095.9 | 0% | 234 |
| L'ultimo spettacolo di Jerah | `jerah` | casuale | 0% | 90% | 10% | 39.3 | 1195.5 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | attacca | 62% | 38% | 0% | 37.1 | 992.7 | 0% | 525 |
| Jongo Dongo | `jongo_dongo` | difendi | 0% | 20% | 80% | 59.7 | 974.1 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | studia | 39% | 61% | 0% | 38.8 | 1086.2 | 0% | 348 |
| Jongo Dongo | `jongo_dongo` | casuale | 0% | 69% | 31% | 51.5 | 1140.9 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | attacca | 1% | 99% | 0% | 26.8 | 1219.6 | 0% | 9 |
| Jongo Dongo | `jongo_dongo_risorto` | difendi | 0% | 100% | 0% | 33.8 | 1220.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | studia | 0% | 100% | 0% | 26.6 | 1220.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | casuale | 0% | 100% | 0% | 28.1 | 1220.0 | 0% | 0 |
| ??? | `l_immortale` | attacca | 0% | 0% | 100% | 61.0 | 60.0 | 0% | 0 |
| ??? | `l_immortale` | difendi | 0% | 0% | 100% | 61.0 | 60.0 | 0% | 0 |
| ??? | `l_immortale` | studia | 0% | 0% | 100% | 61.0 | 60.0 | 0% | 0 |
| ??? | `l_immortale` | casuale | 0% | 0% | 100% | 61.0 | 60.0 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | attacca | 100% | 0% | 0% | 6.6 | 127.9 | 0% | 46 |
| Madre in Lacrime | `madre_in_lacrime` | difendi | 0% | 0% | 100% | 61.0 | 718.2 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | studia | 100% | 0% | 0% | 9.7 | 196.2 | 0% | 46 |
| Madre in Lacrime | `madre_in_lacrime` | casuale | 100% | 0% | 0% | 20.5 | 386.8 | 0% | 46 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | attacca | 0% | 100% | 0% | 6.0 | 1220.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | difendi | 0% | 100% | 0% | 6.0 | 1220.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | studia | 0% | 100% | 0% | 6.0 | 1220.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | casuale | 0% | 100% | 0% | 6.0 | 1220.0 | 0% | 0 |
| Marionetta | `marionetta` | attacca | 100% | 0% | 0% | 6.6 | 127.9 | 0% | 46 |
| Marionetta | `marionetta` | difendi | 0% | 0% | 100% | 61.0 | 718.2 | 0% | 0 |
| Marionetta | `marionetta` | studia | 100% | 0% | 0% | 9.4 | 189.8 | 0% | 46 |
| Marionetta | `marionetta` | casuale | 100% | 0% | 0% | 20.4 | 388.3 | 0% | 46 |
| Fomentado | `maschera_vuota` | attacca | 100% | 0% | 0% | 5.9 | 110.1 | 0% | 46 |
| Fomentado | `maschera_vuota` | difendi | 0% | 0% | 100% | 61.0 | 718.2 | 0% | 0 |
| Fomentado | `maschera_vuota` | studia | 100% | 0% | 0% | 8.8 | 175.8 | 0% | 46 |
| Fomentado | `maschera_vuota` | casuale | 100% | 0% | 0% | 17.9 | 339.7 | 0% | 46 |
| Nuvola di Marciume | `nuvola_di_marciume` | attacca | 100% | 0% | 0% | 3.9 | 71.4 | 0% | 51 |
| Nuvola di Marciume | `nuvola_di_marciume` | difendi | 0% | 0% | 100% | 61.0 | 488.5 | 0% | 0 |
| Nuvola di Marciume | `nuvola_di_marciume` | studia | 100% | 0% | 0% | 7.0 | 128.7 | 0% | 51 |
| Nuvola di Marciume | `nuvola_di_marciume` | casuale | 100% | 0% | 0% | 11.7 | 189.0 | 0% | 51 |
| Ombra del passato | `ombra_del_passato` | attacca | 100% | 0% | 0% | 6.6 | 127.9 | 0% | 46 |
| Ombra del passato | `ombra_del_passato` | difendi | 0% | 0% | 100% | 61.0 | 718.2 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | studia | 100% | 0% | 0% | 9.4 | 189.8 | 0% | 46 |
| Ombra del passato | `ombra_del_passato` | casuale | 100% | 0% | 0% | 20.4 | 388.3 | 0% | 46 |
| Emblema dell'oppressione | `operaio_posseduto` | attacca | 100% | 0% | 0% | 6.6 | 127.9 | 0% | 46 |
| Emblema dell'oppressione | `operaio_posseduto` | difendi | 0% | 0% | 100% | 61.0 | 718.2 | 0% | 0 |
| Emblema dell'oppressione | `operaio_posseduto` | studia | 100% | 0% | 0% | 9.4 | 189.8 | 0% | 46 |
| Emblema dell'oppressione | `operaio_posseduto` | casuale | 100% | 0% | 0% | 20.4 | 388.3 | 0% | 46 |
| Operaio Sfruttato | `operaio_sfruttato` | attacca | 100% | 0% | 0% | 10.5 | 283.2 | 0% | 101 |
| Operaio Sfruttato | `operaio_sfruttato` | difendi | 0% | 19% | 81% | 60.7 | 1150.4 | 0% | 0 |
| Operaio Sfruttato | `operaio_sfruttato` | studia | 100% | 0% | 0% | 13.6 | 375.3 | 0% | 101 |
| Operaio Sfruttato | `operaio_sfruttato` | casuale | 96% | 4% | 0% | 31.7 | 834.9 | 0% | 97 |
| Orrore di Meridia | `orrore_di_meridia` | attacca | 100% | 0% | 0% | 10.6 | 146.3 | 0% | 101 |
| Orrore di Meridia | `orrore_di_meridia` | difendi | 0% | 0% | 100% | 61.0 | 619.2 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | studia | 100% | 0% | 0% | 13.7 | 192.6 | 0% | 101 |
| Orrore di Meridia | `orrore_di_meridia` | casuale | 100% | 0% | 0% | 32.3 | 445.0 | 0% | 101 |
| Robo Pattuglia | `robo_pattuglia` | attacca | 100% | 0% | 0% | 11.2 | 125.5 | 0% | 55 |
| Robo Pattuglia | `robo_pattuglia` | difendi | 0% | 0% | 100% | 61.0 | 325.8 | 0% | 0 |
| Robo Pattuglia | `robo_pattuglia` | studia | 100% | 0% | 0% | 13.9 | 157.5 | 0% | 55 |
| Robo Pattuglia | `robo_pattuglia` | casuale | 100% | 0% | 0% | 34.2 | 346.8 | 0% | 55 |
| Sacerdote Folle | `sacerdote_folle` | attacca | 100% | 0% | 0% | 11.0 | 202.7 | 0% | 78 |
| Sacerdote Folle | `sacerdote_folle` | difendi | 0% | 82% | 18% | 53.8 | 1191.4 | 0% | 0 |
| Sacerdote Folle | `sacerdote_folle` | studia | 100% | 0% | 0% | 19.4 | 462.9 | 0% | 94 |
| Sacerdote Folle | `sacerdote_folle` | casuale | 21% | 79% | 0% | 33.2 | 1062.1 | 0% | 16 |
| Sadico | `sadico` | attacca | 100% | 0% | 0% | 6.6 | 127.9 | 0% | 46 |
| Sadico | `sadico` | difendi | 0% | 0% | 100% | 61.0 | 718.2 | 0% | 0 |
| Sadico | `sadico` | studia | 100% | 0% | 0% | 9.7 | 196.2 | 0% | 46 |
| Sadico | `sadico` | casuale | 100% | 0% | 0% | 20.5 | 386.8 | 0% | 46 |
| Slime Infimo | `slime_infimo` | attacca | 100% | 0% | 0% | 6.6 | 127.9 | 0% | 46 |
| Slime Infimo | `slime_infimo` | difendi | 0% | 0% | 100% | 61.0 | 718.2 | 0% | 0 |
| Slime Infimo | `slime_infimo` | studia | 100% | 0% | 0% | 9.7 | 196.2 | 0% | 46 |
| Slime Infimo | `slime_infimo` | casuale | 100% | 0% | 0% | 20.5 | 386.8 | 0% | 46 |
| Stigma | `stigma` | attacca | 100% | 0% | 0% | 6.6 | 127.9 | 0% | 46 |
| Stigma | `stigma` | difendi | 0% | 0% | 100% | 61.0 | 718.2 | 0% | 0 |
| Stigma | `stigma` | studia | 100% | 0% | 0% | 9.7 | 196.2 | 0% | 46 |
| Stigma | `stigma` | casuale | 100% | 0% | 0% | 20.5 | 386.8 | 0% | 46 |
| Tartaruga Innocente | `tartaruga_innocente` | attacca | 100% | 0% | 0% | 3.9 | 0.0 | 0% | 1 |
| Tartaruga Innocente | `tartaruga_innocente` | difendi | 0% | 0% | 100% | 61.0 | 0.0 | 0% | 0 |
| Tartaruga Innocente | `tartaruga_innocente` | studia | 100% | 0% | 0% | 1.0 | 0.0 | 100% | 1 |
| Tartaruga Innocente | `tartaruga_innocente` | casuale | 100% | 0% | 0% | 2.7 | 0.0 | 96% | 1 |
| Un tenero ricordo | `tenero_ricordo` | attacca | 0% | 100% | 0% | 10.0 | 1220.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | difendi | 0% | 100% | 0% | 9.5 | 1220.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | studia | 0% | 100% | 0% | 9.6 | 1220.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | casuale | 0% | 100% | 0% | 10.3 | 1220.0 | 0% | 0 |
| Teschio Errante | `teschio_errante` | attacca | 100% | 0% | 0% | 6.6 | 127.9 | 0% | 46 |
| Teschio Errante | `teschio_errante` | difendi | 0% | 0% | 100% | 61.0 | 718.2 | 0% | 0 |
| Teschio Errante | `teschio_errante` | studia | 100% | 0% | 0% | 9.7 | 196.2 | 0% | 46 |
| Teschio Errante | `teschio_errante` | casuale | 100% | 0% | 0% | 20.5 | 386.8 | 0% | 46 |
| Titano Zombie | `titano_zombie` | attacca | 73% | 27% | 0% | 19.4 | 1138.2 | 0% | 73 |
| Titano Zombie | `titano_zombie` | difendi | 0% | 100% | 0% | 21.7 | 1220.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | studia | 46% | 54% | 0% | 21.3 | 1179.6 | 0% | 46 |
| Titano Zombie | `titano_zombie` | casuale | 0% | 100% | 0% | 22.0 | 1220.0 | 0% | 0 |
| Capocantiere | `voce_registrata` | attacca | 100% | 0% | 0% | 6.6 | 127.9 | 0% | 46 |
| Capocantiere | `voce_registrata` | difendi | 0% | 0% | 100% | 61.0 | 718.2 | 0% | 0 |
| Capocantiere | `voce_registrata` | studia | 100% | 0% | 0% | 9.7 | 196.2 | 0% | 46 |
| Capocantiere | `voce_registrata` | casuale | 100% | 0% | 0% | 20.5 | 386.8 | 0% | 46 |
| Volto sulla parete | `volto_sulla_parete` | attacca | 100% | 0% | 0% | 18.0 | 448.8 | 0% | 207 |
| Volto sulla parete | `volto_sulla_parete` | difendi | 0% | 100% | 0% | 37.2 | 1220.0 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | studia | 100% | 0% | 0% | 21.0 | 579.0 | 0% | 207 |
| Volto sulla parete | `volto_sulla_parete` | casuale | 1% | 99% | 0% | 34.4 | 1218.4 | 0% | 1 |
| Zombie Cittadino | `zombie_cittadino` | attacca | 100% | 0% | 0% | 6.6 | 127.9 | 0% | 46 |
| Zombie Cittadino | `zombie_cittadino` | difendi | 0% | 0% | 100% | 61.0 | 718.2 | 0% | 0 |
| Zombie Cittadino | `zombie_cittadino` | studia | 100% | 0% | 0% | 9.4 | 189.8 | 0% | 46 |
| Zombie Cittadino | `zombie_cittadino` | casuale | 100% | 0% | 0% | 20.4 | 388.3 | 0% | 46 |
| Zombie Mostruoso | `zombie_mostruoso` | attacca | 100% | 0% | 0% | 6.6 | 127.9 | 0% | 46 |
| Zombie Mostruoso | `zombie_mostruoso` | difendi | 0% | 0% | 100% | 61.0 | 718.2 | 0% | 0 |
| Zombie Mostruoso | `zombie_mostruoso` | studia | 100% | 0% | 0% | 9.7 | 196.2 | 0% | 46 |
| Zombie Mostruoso | `zombie_mostruoso` | casuale | 100% | 0% | 0% | 20.5 | 386.8 | 0% | 46 |

