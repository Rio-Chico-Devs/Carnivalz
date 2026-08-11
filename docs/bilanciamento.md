# Bilanciamento (generato, non scrivere qui a mano)

Prodotto da `prove/Simulatore.gd`: **182400 partite** giocate dal motore vero in 1146 secondi.

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
| Abominio Marcio | `abominio_marcio` | 737 | 34 | 12 |
| Oppresso | `comparsa_di_ruggine` | 277 | 10 | 3 |
| Diabolo | `diabolo` | 405 | 26 | 8 |
| Il Divoratore | `divoratore` | 468 | 21 | 8 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | 486 | 32 | 8 |
| Donna Spinosa | `donna_spinosa` | 568 | 38 | 12 |
| Ferraglia Urlante | `ferraglia_urlante` | 381 | 14 | 5 |
| Ghoul | `ghoul` | 366 | 23 | 5 |
| El Muy Bonito | `giocoliere` | 340 | 15 | 5 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | 1125 | 25 | **mai** |
| Goblin Tipico | `goblin_tipico` | 86 | 6 | 1 |
| Infetto Rapido | `infetto_rapido` | 94 | 7 | 2 |
| L'ultimo spettacolo di Jerah | `jerah` | 2710 | 74 | **mai** |
| Jongo Dongo | `jongo_dongo` | 1857 | 48 | **mai** |
| Jongo Dongo | `jongo_dongo_risorto` | 2147 | 56 | **mai** |
| ??? | `l_immortale` | 120 | 5 | **mai** |
| Madre in Lacrime | `madre_in_lacrime` | 366 | 23 | 5 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | 439 | 14 | **mai** |
| Marionetta | `marionetta` | 568 | 38 | 12 |
| Fomentado | `maschera_vuota` | 164 | 10 | 2 |
| Nuvola di Marciume | `nuvola_di_marciume` | 94 | 7 | 1 |
| Ombra del passato | `ombra_del_passato` | 607 | 41 | 12 |
| Emblema dell'oppressione | `operaio_posseduto` | 245 | 15 | 3 |
| Operaio Sfruttato | `operaio_sfruttato` | 404 | 18 | 5 |
| Orrore di Meridia | `orrore_di_meridia` | 404 | 18 | 5 |
| Robo Pattuglia | `robo_pattuglia` | 277 | 10 | 3 |
| Sacerdote Folle | `sacerdote_folle` | 486 | 32 | 12 |
| Sadico | `sadico` | 405 | 26 | 8 |
| Slime Infimo | `slime_infimo` | 86 | 6 | 2 |
| Stigma | `stigma` | 405 | 26 | 8 |
| Tartaruga Innocente | `tartaruga_innocente` | 555 | 0 | 12 |
| Un tenero ricordo | `tenero_ricordo` | 6660 | 27 | **mai** |
| Teschio Errante | `teschio_errante` | 366 | 23 | 5 |
| Titano Zombie | `titano_zombie` | 737 | 34 | 12 |
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
| Abominio Marcio | `abominio_marcio` | attacca | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | difendi | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | studia | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | casuale | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Oppresso | `comparsa_di_ruggine` | attacca | 8% | 92% | 0% | 1.0 | 96.9 | 0% | 1 |
| Oppresso | `comparsa_di_ruggine` | difendi | 0% | 100% | 0% | 1.0 | 81.1 | 0% | 0 |
| Oppresso | `comparsa_di_ruggine` | studia | 7% | 93% | 0% | 1.0 | 97.5 | 0% | 1 |
| Oppresso | `comparsa_di_ruggine` | casuale | 17% | 83% | 0% | 1.0 | 92.5 | 0% | 3 |
| Diabolo | `diabolo` | attacca | 2% | 98% | 0% | 1.0 | 98.4 | 0% | 1 |
| Diabolo | `diabolo` | difendi | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Diabolo | `diabolo` | studia | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Diabolo | `diabolo` | casuale | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Il Divoratore | `divoratore` | attacca | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Il Divoratore | `divoratore` | difendi | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Il Divoratore | `divoratore` | studia | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Il Divoratore | `divoratore` | casuale | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | attacca | 2% | 98% | 0% | 1.0 | 99.3 | 0% | 1 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | difendi | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | studia | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | casuale | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Donna Spinosa | `donna_spinosa` | attacca | 1% | 99% | 0% | 1.0 | 99.9 | 0% | 0 |
| Donna Spinosa | `donna_spinosa` | difendi | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Donna Spinosa | `donna_spinosa` | studia | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Donna Spinosa | `donna_spinosa` | casuale | 1% | 99% | 0% | 1.0 | 99.9 | 0% | 0 |
| Ferraglia Urlante | `ferraglia_urlante` | attacca | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Ferraglia Urlante | `ferraglia_urlante` | difendi | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Ferraglia Urlante | `ferraglia_urlante` | studia | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Ferraglia Urlante | `ferraglia_urlante` | casuale | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Ghoul | `ghoul` | attacca | 3% | 97% | 0% | 1.0 | 98.5 | 0% | 1 |
| Ghoul | `ghoul` | difendi | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Ghoul | `ghoul` | studia | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Ghoul | `ghoul` | casuale | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| El Muy Bonito | `giocoliere` | attacca | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| El Muy Bonito | `giocoliere` | difendi | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| El Muy Bonito | `giocoliere` | studia | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| El Muy Bonito | `giocoliere` | casuale | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | attacca | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | difendi | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | studia | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | casuale | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Goblin Tipico | `goblin_tipico` | attacca | 100% | 0% | 0% | 1.0 | 21.4 | 0% | 2 |
| Goblin Tipico | `goblin_tipico` | difendi | 0% | 100% | 0% | 1.0 | 51.8 | 0% | 0 |
| Goblin Tipico | `goblin_tipico` | studia | 100% | 0% | 0% | 1.0 | 35.5 | 0% | 2 |
| Goblin Tipico | `goblin_tipico` | casuale | 97% | 3% | 0% | 1.0 | 33.4 | 0% | 2 |
| Infetto Rapido | `infetto_rapido` | attacca | 28% | 72% | 0% | 1.0 | 95.6 | 0% | 2 |
| Infetto Rapido | `infetto_rapido` | difendi | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Infetto Rapido | `infetto_rapido` | studia | 3% | 97% | 0% | 1.0 | 99.2 | 0% | 0 |
| Infetto Rapido | `infetto_rapido` | casuale | 29% | 71% | 0% | 1.0 | 94.4 | 0% | 2 |
| L'ultimo spettacolo di Jerah | `jerah` | attacca | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | difendi | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | studia | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | casuale | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | attacca | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | difendi | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | studia | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | casuale | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | attacca | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | difendi | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | studia | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | casuale | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| ??? | `l_immortale` | attacca | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| ??? | `l_immortale` | difendi | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| ??? | `l_immortale` | studia | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| ??? | `l_immortale` | casuale | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | attacca | 3% | 97% | 0% | 1.0 | 98.5 | 0% | 1 |
| Madre in Lacrime | `madre_in_lacrime` | difendi | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | studia | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | casuale | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | attacca | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | difendi | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | studia | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | casuale | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Marionetta | `marionetta` | attacca | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Marionetta | `marionetta` | difendi | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Marionetta | `marionetta` | studia | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Marionetta | `marionetta` | casuale | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Fomentado | `maschera_vuota` | attacca | 5% | 95% | 0% | 1.0 | 96.5 | 0% | 0 |
| Fomentado | `maschera_vuota` | difendi | 19% | 81% | 0% | 1.0 | 99.0 | 0% | 2 |
| Fomentado | `maschera_vuota` | studia | 3% | 97% | 0% | 1.0 | 98.6 | 0% | 0 |
| Fomentado | `maschera_vuota` | casuale | 23% | 77% | 0% | 1.0 | 95.4 | 0% | 2 |
| Nuvola di Marciume | `nuvola_di_marciume` | attacca | 80% | 20% | 0% | 1.0 | 86.5 | 0% | 5 |
| Nuvola di Marciume | `nuvola_di_marciume` | difendi | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Nuvola di Marciume | `nuvola_di_marciume` | studia | 3% | 97% | 0% | 1.0 | 99.2 | 0% | 0 |
| Nuvola di Marciume | `nuvola_di_marciume` | casuale | 4% | 96% | 0% | 1.0 | 98.6 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | attacca | 1% | 99% | 0% | 1.0 | 100.0 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | difendi | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | studia | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | casuale | 1% | 99% | 0% | 1.0 | 100.0 | 0% | 0 |
| Emblema dell'oppressione | `operaio_posseduto` | attacca | 3% | 97% | 0% | 1.0 | 97.9 | 0% | 1 |
| Emblema dell'oppressione | `operaio_posseduto` | difendi | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Emblema dell'oppressione | `operaio_posseduto` | studia | 1% | 99% | 0% | 1.0 | 99.9 | 0% | 0 |
| Emblema dell'oppressione | `operaio_posseduto` | casuale | 1% | 99% | 0% | 1.0 | 99.7 | 0% | 0 |
| Operaio Sfruttato | `operaio_sfruttato` | attacca | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Operaio Sfruttato | `operaio_sfruttato` | difendi | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Operaio Sfruttato | `operaio_sfruttato` | studia | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Operaio Sfruttato | `operaio_sfruttato` | casuale | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | attacca | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | difendi | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | studia | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | casuale | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Robo Pattuglia | `robo_pattuglia` | attacca | 7% | 93% | 0% | 1.0 | 96.8 | 0% | 1 |
| Robo Pattuglia | `robo_pattuglia` | difendi | 0% | 100% | 0% | 1.0 | 97.8 | 0% | 0 |
| Robo Pattuglia | `robo_pattuglia` | studia | 5% | 95% | 0% | 1.0 | 98.6 | 0% | 1 |
| Robo Pattuglia | `robo_pattuglia` | casuale | 9% | 91% | 0% | 1.0 | 97.2 | 0% | 1 |
| Sacerdote Folle | `sacerdote_folle` | attacca | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Sacerdote Folle | `sacerdote_folle` | difendi | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Sacerdote Folle | `sacerdote_folle` | studia | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Sacerdote Folle | `sacerdote_folle` | casuale | 1% | 99% | 0% | 1.0 | 99.8 | 0% | 0 |
| Sadico | `sadico` | attacca | 2% | 98% | 0% | 1.0 | 98.6 | 0% | 1 |
| Sadico | `sadico` | difendi | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Sadico | `sadico` | studia | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Sadico | `sadico` | casuale | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Slime Infimo | `slime_infimo` | attacca | 76% | 24% | 0% | 1.0 | 46.1 | 0% | 2 |
| Slime Infimo | `slime_infimo` | difendi | 0% | 100% | 0% | 1.0 | 98.7 | 0% | 0 |
| Slime Infimo | `slime_infimo` | studia | 55% | 45% | 0% | 1.0 | 66.8 | 0% | 1 |
| Slime Infimo | `slime_infimo` | casuale | 21% | 79% | 0% | 1.0 | 88.3 | 0% | 0 |
| Stigma | `stigma` | attacca | 1% | 99% | 0% | 1.0 | 99.1 | 0% | 0 |
| Stigma | `stigma` | difendi | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Stigma | `stigma` | studia | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Stigma | `stigma` | casuale | 1% | 99% | 0% | 1.0 | 99.9 | 0% | 0 |
| Tartaruga Innocente | `tartaruga_innocente` | attacca | 0% | 100% | 0% | 1.0 | 0.0 | 0% | 0 |
| Tartaruga Innocente | `tartaruga_innocente` | difendi | 0% | 100% | 0% | 1.0 | 0.0 | 0% | 0 |
| Tartaruga Innocente | `tartaruga_innocente` | studia | 100% | 0% | 0% | 1.0 | 0.0 | 100% | 3 |
| Tartaruga Innocente | `tartaruga_innocente` | casuale | 100% | 0% | 0% | 1.0 | 0.0 | 100% | 3 |
| Un tenero ricordo | `tenero_ricordo` | attacca | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | difendi | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | studia | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | casuale | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Teschio Errante | `teschio_errante` | attacca | 2% | 98% | 0% | 1.0 | 98.6 | 0% | 1 |
| Teschio Errante | `teschio_errante` | difendi | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Teschio Errante | `teschio_errante` | studia | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Teschio Errante | `teschio_errante` | casuale | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | attacca | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | difendi | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | studia | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | casuale | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Capocantiere | `voce_registrata` | attacca | 5% | 95% | 0% | 1.0 | 97.4 | 0% | 1 |
| Capocantiere | `voce_registrata` | difendi | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Capocantiere | `voce_registrata` | studia | 1% | 99% | 0% | 1.0 | 99.7 | 0% | 0 |
| Capocantiere | `voce_registrata` | casuale | 1% | 99% | 0% | 1.0 | 99.5 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | attacca | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | difendi | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | studia | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | casuale | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Zombie Cittadino | `zombie_cittadino` | attacca | 100% | 0% | 0% | 1.0 | 54.8 | 0% | 5 |
| Zombie Cittadino | `zombie_cittadino` | difendi | 0% | 100% | 0% | 1.0 | 62.4 | 0% | 0 |
| Zombie Cittadino | `zombie_cittadino` | studia | 100% | 0% | 0% | 1.0 | 73.0 | 0% | 5 |
| Zombie Cittadino | `zombie_cittadino` | casuale | 97% | 3% | 0% | 1.0 | 56.6 | 0% | 5 |
| Zombie Mostruoso | `zombie_mostruoso` | attacca | 7% | 93% | 0% | 1.0 | 96.3 | 0% | 1 |
| Zombie Mostruoso | `zombie_mostruoso` | difendi | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Zombie Mostruoso | `zombie_mostruoso` | studia | 4% | 96% | 0% | 1.0 | 98.1 | 0% | 0 |
| Zombie Mostruoso | `zombie_mostruoso` | casuale | 4% | 96% | 0% | 1.0 | 99.0 | 0% | 0 |

## Protagonista di livello 2

| creatura | id | come si gioca | vinte | perse | ∞ | giri | danno | risp. | xp |
|---|---|---|--:|--:|--:|--:|--:|--:|--:|
| Abominio Marcio | `abominio_marcio` | attacca | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | difendi | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | studia | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | casuale | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| Oppresso | `comparsa_di_ruggine` | attacca | 18% | 82% | 0% | 1.0 | 134.3 | 0% | 3 |
| Oppresso | `comparsa_di_ruggine` | difendi | 0% | 100% | 0% | 1.0 | 70.6 | 0% | 0 |
| Oppresso | `comparsa_di_ruggine` | studia | 19% | 81% | 0% | 1.0 | 134.3 | 0% | 3 |
| Oppresso | `comparsa_di_ruggine` | casuale | 23% | 77% | 0% | 1.0 | 87.5 | 0% | 4 |
| Diabolo | `diabolo` | attacca | 2% | 98% | 0% | 1.0 | 142.5 | 0% | 1 |
| Diabolo | `diabolo` | difendi | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| Diabolo | `diabolo` | studia | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| Diabolo | `diabolo` | casuale | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| Il Divoratore | `divoratore` | attacca | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| Il Divoratore | `divoratore` | difendi | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| Il Divoratore | `divoratore` | studia | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| Il Divoratore | `divoratore` | casuale | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | attacca | 2% | 98% | 0% | 1.0 | 143.4 | 0% | 1 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | difendi | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | studia | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | casuale | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| Donna Spinosa | `donna_spinosa` | attacca | 1% | 99% | 0% | 1.0 | 144.6 | 0% | 0 |
| Donna Spinosa | `donna_spinosa` | difendi | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| Donna Spinosa | `donna_spinosa` | studia | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| Donna Spinosa | `donna_spinosa` | casuale | 1% | 99% | 0% | 1.0 | 144.6 | 0% | 0 |
| Ferraglia Urlante | `ferraglia_urlante` | attacca | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| Ferraglia Urlante | `ferraglia_urlante` | difendi | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| Ferraglia Urlante | `ferraglia_urlante` | studia | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| Ferraglia Urlante | `ferraglia_urlante` | casuale | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| Ghoul | `ghoul` | attacca | 3% | 97% | 0% | 1.0 | 142.2 | 0% | 1 |
| Ghoul | `ghoul` | difendi | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| Ghoul | `ghoul` | studia | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| Ghoul | `ghoul` | casuale | 1% | 99% | 0% | 1.0 | 144.9 | 0% | 0 |
| El Muy Bonito | `giocoliere` | attacca | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| El Muy Bonito | `giocoliere` | difendi | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| El Muy Bonito | `giocoliere` | studia | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| El Muy Bonito | `giocoliere` | casuale | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | attacca | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | difendi | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | studia | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | casuale | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| Goblin Tipico | `goblin_tipico` | attacca | 100% | 0% | 0% | 1.0 | 11.3 | 0% | 2 |
| Goblin Tipico | `goblin_tipico` | difendi | 0% | 100% | 0% | 1.0 | 44.5 | 0% | 0 |
| Goblin Tipico | `goblin_tipico` | studia | 100% | 0% | 0% | 1.0 | 22.9 | 0% | 2 |
| Goblin Tipico | `goblin_tipico` | casuale | 100% | 0% | 0% | 1.0 | 19.6 | 0% | 2 |
| Infetto Rapido | `infetto_rapido` | attacca | 100% | 0% | 0% | 1.0 | 60.2 | 0% | 6 |
| Infetto Rapido | `infetto_rapido` | difendi | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| Infetto Rapido | `infetto_rapido` | studia | 100% | 0% | 0% | 1.0 | 96.8 | 0% | 6 |
| Infetto Rapido | `infetto_rapido` | casuale | 95% | 5% | 0% | 1.0 | 74.2 | 0% | 6 |
| L'ultimo spettacolo di Jerah | `jerah` | attacca | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | difendi | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | studia | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | casuale | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | attacca | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | difendi | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | studia | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | casuale | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | attacca | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | difendi | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | studia | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | casuale | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| ??? | `l_immortale` | attacca | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| ??? | `l_immortale` | difendi | 0% | 100% | 0% | 1.0 | 143.1 | 0% | 0 |
| ??? | `l_immortale` | studia | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| ??? | `l_immortale` | casuale | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | attacca | 3% | 97% | 0% | 1.0 | 142.3 | 0% | 1 |
| Madre in Lacrime | `madre_in_lacrime` | difendi | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | studia | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | casuale | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | attacca | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | difendi | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | studia | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | casuale | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| Marionetta | `marionetta` | attacca | 1% | 99% | 0% | 1.0 | 144.7 | 0% | 0 |
| Marionetta | `marionetta` | difendi | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| Marionetta | `marionetta` | studia | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| Marionetta | `marionetta` | casuale | 1% | 99% | 0% | 1.0 | 144.7 | 0% | 0 |
| Fomentado | `maschera_vuota` | attacca | 100% | 0% | 0% | 1.0 | 76.5 | 0% | 9 |
| Fomentado | `maschera_vuota` | difendi | 100% | 0% | 0% | 1.0 | 73.4 | 0% | 9 |
| Fomentado | `maschera_vuota` | studia | 100% | 0% | 0% | 1.0 | 103.5 | 0% | 9 |
| Fomentado | `maschera_vuota` | casuale | 97% | 3% | 0% | 1.0 | 85.3 | 0% | 9 |
| Nuvola di Marciume | `nuvola_di_marciume` | attacca | 100% | 0% | 0% | 1.0 | 50.8 | 0% | 6 |
| Nuvola di Marciume | `nuvola_di_marciume` | difendi | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| Nuvola di Marciume | `nuvola_di_marciume` | studia | 100% | 0% | 0% | 1.0 | 95.2 | 0% | 6 |
| Nuvola di Marciume | `nuvola_di_marciume` | casuale | 48% | 52% | 0% | 1.0 | 122.5 | 0% | 3 |
| Ombra del passato | `ombra_del_passato` | attacca | 1% | 99% | 0% | 1.0 | 144.7 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | difendi | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | studia | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | casuale | 1% | 99% | 0% | 1.0 | 144.7 | 0% | 0 |
| Emblema dell'oppressione | `operaio_posseduto` | attacca | 3% | 97% | 0% | 1.0 | 141.4 | 0% | 1 |
| Emblema dell'oppressione | `operaio_posseduto` | difendi | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| Emblema dell'oppressione | `operaio_posseduto` | studia | 3% | 97% | 0% | 1.0 | 144.1 | 0% | 0 |
| Emblema dell'oppressione | `operaio_posseduto` | casuale | 3% | 97% | 0% | 1.0 | 143.6 | 0% | 0 |
| Operaio Sfruttato | `operaio_sfruttato` | attacca | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| Operaio Sfruttato | `operaio_sfruttato` | difendi | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| Operaio Sfruttato | `operaio_sfruttato` | studia | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| Operaio Sfruttato | `operaio_sfruttato` | casuale | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | attacca | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | difendi | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | studia | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | casuale | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| Robo Pattuglia | `robo_pattuglia` | attacca | 19% | 81% | 0% | 1.0 | 133.1 | 0% | 3 |
| Robo Pattuglia | `robo_pattuglia` | difendi | 0% | 100% | 0% | 1.0 | 80.8 | 0% | 0 |
| Robo Pattuglia | `robo_pattuglia` | studia | 17% | 83% | 0% | 1.0 | 137.1 | 0% | 3 |
| Robo Pattuglia | `robo_pattuglia` | casuale | 18% | 82% | 0% | 1.0 | 104.9 | 0% | 3 |
| Sacerdote Folle | `sacerdote_folle` | attacca | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| Sacerdote Folle | `sacerdote_folle` | difendi | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| Sacerdote Folle | `sacerdote_folle` | studia | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| Sacerdote Folle | `sacerdote_folle` | casuale | 1% | 99% | 0% | 1.0 | 144.5 | 0% | 0 |
| Sadico | `sadico` | attacca | 3% | 97% | 0% | 1.0 | 142.1 | 0% | 1 |
| Sadico | `sadico` | difendi | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| Sadico | `sadico` | studia | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| Sadico | `sadico` | casuale | 1% | 99% | 0% | 1.0 | 144.7 | 0% | 0 |
| Slime Infimo | `slime_infimo` | attacca | 100% | 0% | 0% | 1.0 | 18.1 | 0% | 2 |
| Slime Infimo | `slime_infimo` | difendi | 0% | 100% | 0% | 1.0 | 96.0 | 0% | 0 |
| Slime Infimo | `slime_infimo` | studia | 100% | 0% | 0% | 1.0 | 37.8 | 0% | 2 |
| Slime Infimo | `slime_infimo` | casuale | 57% | 43% | 0% | 1.0 | 64.9 | 0% | 1 |
| Stigma | `stigma` | attacca | 2% | 98% | 0% | 1.0 | 143.3 | 0% | 1 |
| Stigma | `stigma` | difendi | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| Stigma | `stigma` | studia | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| Stigma | `stigma` | casuale | 1% | 99% | 0% | 1.0 | 144.4 | 0% | 0 |
| Tartaruga Innocente | `tartaruga_innocente` | attacca | 0% | 100% | 0% | 1.0 | 0.0 | 0% | 0 |
| Tartaruga Innocente | `tartaruga_innocente` | difendi | 0% | 100% | 0% | 1.0 | 0.0 | 0% | 0 |
| Tartaruga Innocente | `tartaruga_innocente` | studia | 100% | 0% | 0% | 1.0 | 0.0 | 100% | 3 |
| Tartaruga Innocente | `tartaruga_innocente` | casuale | 100% | 0% | 0% | 1.0 | 0.0 | 100% | 3 |
| Un tenero ricordo | `tenero_ricordo` | attacca | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | difendi | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | studia | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | casuale | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| Teschio Errante | `teschio_errante` | attacca | 3% | 97% | 0% | 1.0 | 142.6 | 0% | 1 |
| Teschio Errante | `teschio_errante` | difendi | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| Teschio Errante | `teschio_errante` | studia | 1% | 99% | 0% | 1.0 | 145.0 | 0% | 0 |
| Teschio Errante | `teschio_errante` | casuale | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | attacca | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | difendi | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | studia | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | casuale | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| Capocantiere | `voce_registrata` | attacca | 5% | 95% | 0% | 1.0 | 139.8 | 0% | 1 |
| Capocantiere | `voce_registrata` | difendi | 0% | 100% | 0% | 1.0 | 144.7 | 0% | 0 |
| Capocantiere | `voce_registrata` | studia | 3% | 97% | 0% | 1.0 | 143.4 | 0% | 0 |
| Capocantiere | `voce_registrata` | casuale | 1% | 99% | 0% | 1.0 | 144.0 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | attacca | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | difendi | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | studia | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | casuale | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| Zombie Cittadino | `zombie_cittadino` | attacca | 100% | 0% | 0% | 1.0 | 30.8 | 0% | 5 |
| Zombie Cittadino | `zombie_cittadino` | difendi | 0% | 100% | 0% | 1.0 | 54.0 | 0% | 0 |
| Zombie Cittadino | `zombie_cittadino` | studia | 100% | 0% | 0% | 1.0 | 46.2 | 0% | 5 |
| Zombie Cittadino | `zombie_cittadino` | casuale | 100% | 0% | 0% | 1.0 | 36.6 | 0% | 5 |
| Zombie Mostruoso | `zombie_mostruoso` | attacca | 100% | 0% | 0% | 1.0 | 82.1 | 0% | 9 |
| Zombie Mostruoso | `zombie_mostruoso` | difendi | 0% | 100% | 0% | 1.0 | 100.2 | 0% | 0 |
| Zombie Mostruoso | `zombie_mostruoso` | studia | 99% | 1% | 0% | 1.0 | 114.1 | 0% | 9 |
| Zombie Mostruoso | `zombie_mostruoso` | casuale | 90% | 10% | 0% | 1.0 | 97.1 | 0% | 8 |

## Protagonista di livello 3

| creatura | id | come si gioca | vinte | perse | ∞ | giri | danno | risp. | xp |
|---|---|---|--:|--:|--:|--:|--:|--:|--:|
| Abominio Marcio | `abominio_marcio` | attacca | 0% | 100% | 0% | 1.0 | 190.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | difendi | 0% | 100% | 0% | 1.0 | 190.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | studia | 0% | 100% | 0% | 1.0 | 190.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | casuale | 0% | 100% | 0% | 1.0 | 190.0 | 0% | 0 |
| Oppresso | `comparsa_di_ruggine` | attacca | 100% | 0% | 0% | 1.0 | 82.4 | 0% | 16 |
| Oppresso | `comparsa_di_ruggine` | difendi | 0% | 100% | 0% | 1.0 | 48.9 | 0% | 0 |
| Oppresso | `comparsa_di_ruggine` | studia | 100% | 0% | 0% | 1.0 | 95.2 | 0% | 16 |
| Oppresso | `comparsa_di_ruggine` | casuale | 74% | 26% | 0% | 1.0 | 55.3 | 0% | 12 |
| Diabolo | `diabolo` | attacca | 4% | 96% | 0% | 1.0 | 184.9 | 0% | 1 |
| Diabolo | `diabolo` | difendi | 0% | 100% | 0% | 1.0 | 190.0 | 0% | 0 |
| Diabolo | `diabolo` | studia | 2% | 98% | 0% | 1.0 | 189.4 | 0% | 1 |
| Diabolo | `diabolo` | casuale | 0% | 100% | 0% | 1.0 | 190.0 | 0% | 0 |
| Il Divoratore | `divoratore` | attacca | 0% | 100% | 0% | 1.0 | 190.0 | 0% | 0 |
| Il Divoratore | `divoratore` | difendi | 0% | 100% | 0% | 1.0 | 190.0 | 0% | 0 |
| Il Divoratore | `divoratore` | studia | 0% | 100% | 0% | 1.0 | 190.0 | 0% | 0 |
| Il Divoratore | `divoratore` | casuale | 0% | 100% | 0% | 1.0 | 190.0 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | attacca | 3% | 97% | 0% | 1.0 | 187.0 | 0% | 1 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | difendi | 0% | 100% | 0% | 1.0 | 190.0 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | studia | 0% | 100% | 0% | 1.0 | 190.0 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | casuale | 0% | 100% | 0% | 1.0 | 190.0 | 0% | 0 |
| Donna Spinosa | `donna_spinosa` | attacca | 3% | 97% | 0% | 1.0 | 186.3 | 0% | 2 |
| Donna Spinosa | `donna_spinosa` | difendi | 0% | 100% | 0% | 1.0 | 190.0 | 0% | 0 |
| Donna Spinosa | `donna_spinosa` | studia | 0% | 100% | 0% | 1.0 | 190.0 | 0% | 0 |
| Donna Spinosa | `donna_spinosa` | casuale | 1% | 99% | 0% | 1.0 | 189.6 | 0% | 0 |
| Ferraglia Urlante | `ferraglia_urlante` | attacca | 0% | 100% | 0% | 1.0 | 190.0 | 0% | 0 |
| Ferraglia Urlante | `ferraglia_urlante` | difendi | 0% | 100% | 0% | 1.0 | 146.4 | 0% | 0 |
| Ferraglia Urlante | `ferraglia_urlante` | studia | 0% | 100% | 0% | 1.0 | 190.0 | 0% | 0 |
| Ferraglia Urlante | `ferraglia_urlante` | casuale | 0% | 100% | 0% | 1.0 | 174.5 | 0% | 0 |
| Ghoul | `ghoul` | attacca | 7% | 93% | 0% | 1.0 | 183.1 | 0% | 2 |
| Ghoul | `ghoul` | difendi | 0% | 100% | 0% | 1.0 | 190.0 | 0% | 0 |
| Ghoul | `ghoul` | studia | 3% | 97% | 0% | 1.0 | 188.5 | 0% | 1 |
| Ghoul | `ghoul` | casuale | 3% | 97% | 0% | 1.0 | 187.5 | 0% | 1 |
| El Muy Bonito | `giocoliere` | attacca | 0% | 100% | 0% | 1.0 | 190.0 | 0% | 0 |
| El Muy Bonito | `giocoliere` | difendi | 0% | 100% | 0% | 1.0 | 189.6 | 0% | 0 |
| El Muy Bonito | `giocoliere` | studia | 0% | 100% | 0% | 1.0 | 190.0 | 0% | 0 |
| El Muy Bonito | `giocoliere` | casuale | 0% | 100% | 0% | 1.0 | 190.0 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | attacca | 0% | 100% | 0% | 1.0 | 190.0 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | difendi | 0% | 100% | 0% | 1.0 | 190.0 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | studia | 0% | 100% | 0% | 1.0 | 190.0 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | casuale | 0% | 100% | 0% | 1.0 | 190.0 | 0% | 0 |
| Goblin Tipico | `goblin_tipico` | attacca | 100% | 0% | 0% | 1.0 | 4.8 | 0% | 1 |
| Goblin Tipico | `goblin_tipico` | difendi | 0% | 100% | 0% | 1.0 | 31.5 | 0% | 0 |
| Goblin Tipico | `goblin_tipico` | studia | 100% | 0% | 0% | 1.0 | 9.8 | 0% | 1 |
| Goblin Tipico | `goblin_tipico` | casuale | 100% | 0% | 0% | 1.0 | 9.0 | 0% | 1 |
| Infetto Rapido | `infetto_rapido` | attacca | 100% | 0% | 0% | 1.0 | 24.6 | 0% | 5 |
| Infetto Rapido | `infetto_rapido` | difendi | 0% | 100% | 0% | 1.0 | 134.5 | 0% | 0 |
| Infetto Rapido | `infetto_rapido` | studia | 100% | 0% | 0% | 1.0 | 48.7 | 0% | 5 |
| Infetto Rapido | `infetto_rapido` | casuale | 100% | 0% | 0% | 1.0 | 41.0 | 0% | 5 |
| L'ultimo spettacolo di Jerah | `jerah` | attacca | 0% | 100% | 0% | 1.0 | 190.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | difendi | 0% | 100% | 0% | 1.0 | 190.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | studia | 0% | 100% | 0% | 1.0 | 190.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | casuale | 0% | 100% | 0% | 1.0 | 190.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | attacca | 0% | 100% | 0% | 1.0 | 190.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | difendi | 0% | 100% | 0% | 1.0 | 190.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | studia | 0% | 100% | 0% | 1.0 | 190.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | casuale | 0% | 100% | 0% | 1.0 | 190.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | attacca | 0% | 100% | 0% | 1.0 | 190.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | difendi | 0% | 100% | 0% | 1.0 | 190.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | studia | 0% | 100% | 0% | 1.0 | 190.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | casuale | 0% | 100% | 0% | 1.0 | 190.0 | 0% | 0 |
| ??? | `l_immortale` | attacca | 0% | 100% | 0% | 1.0 | 190.0 | 0% | 0 |
| ??? | `l_immortale` | difendi | 0% | 100% | 0% | 1.0 | 106.9 | 0% | 0 |
| ??? | `l_immortale` | studia | 0% | 100% | 0% | 1.0 | 190.0 | 0% | 0 |
| ??? | `l_immortale` | casuale | 0% | 100% | 0% | 1.0 | 120.3 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | attacca | 7% | 93% | 0% | 1.0 | 182.9 | 0% | 2 |
| Madre in Lacrime | `madre_in_lacrime` | difendi | 0% | 100% | 0% | 1.0 | 190.0 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | studia | 4% | 96% | 0% | 1.0 | 188.3 | 0% | 1 |
| Madre in Lacrime | `madre_in_lacrime` | casuale | 3% | 97% | 0% | 1.0 | 187.5 | 0% | 1 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | attacca | 0% | 100% | 0% | 1.0 | 190.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | difendi | 0% | 100% | 0% | 1.0 | 190.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | studia | 0% | 100% | 0% | 1.0 | 190.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | casuale | 0% | 100% | 0% | 1.0 | 190.0 | 0% | 0 |
| Marionetta | `marionetta` | attacca | 1% | 99% | 0% | 1.0 | 188.0 | 0% | 1 |
| Marionetta | `marionetta` | difendi | 0% | 100% | 0% | 1.0 | 190.0 | 0% | 0 |
| Marionetta | `marionetta` | studia | 0% | 100% | 0% | 1.0 | 190.0 | 0% | 0 |
| Marionetta | `marionetta` | casuale | 1% | 99% | 0% | 1.0 | 189.7 | 0% | 0 |
| Fomentado | `maschera_vuota` | attacca | 100% | 0% | 0% | 1.0 | 44.3 | 0% | 9 |
| Fomentado | `maschera_vuota` | difendi | 100% | 0% | 0% | 1.0 | 59.5 | 0% | 9 |
| Fomentado | `maschera_vuota` | studia | 100% | 0% | 0% | 1.0 | 68.9 | 0% | 9 |
| Fomentado | `maschera_vuota` | casuale | 100% | 0% | 0% | 1.0 | 55.1 | 0% | 9 |
| Nuvola di Marciume | `nuvola_di_marciume` | attacca | 100% | 0% | 0% | 1.0 | 21.5 | 0% | 5 |
| Nuvola di Marciume | `nuvola_di_marciume` | difendi | 0% | 100% | 0% | 1.0 | 190.0 | 0% | 0 |
| Nuvola di Marciume | `nuvola_di_marciume` | studia | 100% | 0% | 0% | 1.0 | 52.6 | 0% | 5 |
| Nuvola di Marciume | `nuvola_di_marciume` | casuale | 88% | 12% | 0% | 1.0 | 91.2 | 0% | 4 |
| Ombra del passato | `ombra_del_passato` | attacca | 3% | 97% | 0% | 1.0 | 186.8 | 0% | 2 |
| Ombra del passato | `ombra_del_passato` | difendi | 0% | 100% | 0% | 1.0 | 190.0 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | studia | 0% | 100% | 0% | 1.0 | 190.0 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | casuale | 1% | 99% | 0% | 1.0 | 189.7 | 0% | 0 |
| Emblema dell'oppressione | `operaio_posseduto` | attacca | 81% | 19% | 0% | 1.0 | 166.9 | 0% | 15 |
| Emblema dell'oppressione | `operaio_posseduto` | difendi | 0% | 100% | 0% | 1.0 | 187.0 | 0% | 0 |
| Emblema dell'oppressione | `operaio_posseduto` | studia | 9% | 91% | 0% | 1.0 | 183.4 | 0% | 2 |
| Emblema dell'oppressione | `operaio_posseduto` | casuale | 29% | 71% | 0% | 1.0 | 178.3 | 0% | 5 |
| Operaio Sfruttato | `operaio_sfruttato` | attacca | 0% | 100% | 0% | 1.0 | 190.0 | 0% | 0 |
| Operaio Sfruttato | `operaio_sfruttato` | difendi | 0% | 100% | 0% | 1.0 | 135.8 | 0% | 0 |
| Operaio Sfruttato | `operaio_sfruttato` | studia | 0% | 100% | 0% | 1.0 | 190.0 | 0% | 0 |
| Operaio Sfruttato | `operaio_sfruttato` | casuale | 1% | 99% | 0% | 1.0 | 189.9 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | attacca | 0% | 100% | 0% | 1.0 | 190.0 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | difendi | 0% | 100% | 0% | 1.0 | 190.0 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | studia | 0% | 100% | 0% | 1.0 | 190.0 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | casuale | 0% | 100% | 0% | 1.0 | 190.0 | 0% | 0 |
| Robo Pattuglia | `robo_pattuglia` | attacca | 100% | 0% | 0% | 1.0 | 120.3 | 0% | 16 |
| Robo Pattuglia | `robo_pattuglia` | difendi | 0% | 100% | 0% | 1.0 | 56.0 | 0% | 0 |
| Robo Pattuglia | `robo_pattuglia` | studia | 99% | 1% | 0% | 1.0 | 134.2 | 0% | 16 |
| Robo Pattuglia | `robo_pattuglia` | casuale | 18% | 82% | 0% | 1.0 | 68.0 | 0% | 3 |
| Sacerdote Folle | `sacerdote_folle` | attacca | 3% | 97% | 0% | 1.0 | 186.3 | 0% | 1 |
| Sacerdote Folle | `sacerdote_folle` | difendi | 0% | 100% | 0% | 1.0 | 190.0 | 0% | 0 |
| Sacerdote Folle | `sacerdote_folle` | studia | 0% | 100% | 0% | 1.0 | 190.0 | 0% | 0 |
| Sacerdote Folle | `sacerdote_folle` | casuale | 0% | 100% | 0% | 1.0 | 190.0 | 0% | 0 |
| Sadico | `sadico` | attacca | 5% | 95% | 0% | 1.0 | 185.3 | 0% | 2 |
| Sadico | `sadico` | difendi | 0% | 100% | 0% | 1.0 | 190.0 | 0% | 0 |
| Sadico | `sadico` | studia | 1% | 99% | 0% | 1.0 | 189.8 | 0% | 0 |
| Sadico | `sadico` | casuale | 0% | 100% | 0% | 1.0 | 190.0 | 0% | 0 |
| Slime Infimo | `slime_infimo` | attacca | 100% | 0% | 0% | 1.0 | 3.3 | 0% | 1 |
| Slime Infimo | `slime_infimo` | difendi | 0% | 100% | 0% | 1.0 | 47.6 | 0% | 0 |
| Slime Infimo | `slime_infimo` | studia | 100% | 0% | 0% | 1.0 | 9.2 | 0% | 1 |
| Slime Infimo | `slime_infimo` | casuale | 100% | 0% | 0% | 1.0 | 10.1 | 0% | 1 |
| Stigma | `stigma` | attacca | 5% | 95% | 0% | 1.0 | 184.4 | 0% | 2 |
| Stigma | `stigma` | difendi | 0% | 100% | 0% | 1.0 | 190.0 | 0% | 0 |
| Stigma | `stigma` | studia | 1% | 99% | 0% | 1.0 | 189.9 | 0% | 0 |
| Stigma | `stigma` | casuale | 1% | 99% | 0% | 1.0 | 189.2 | 0% | 0 |
| Tartaruga Innocente | `tartaruga_innocente` | attacca | 0% | 100% | 0% | 1.0 | 0.0 | 0% | 0 |
| Tartaruga Innocente | `tartaruga_innocente` | difendi | 0% | 100% | 0% | 1.0 | 0.0 | 0% | 0 |
| Tartaruga Innocente | `tartaruga_innocente` | studia | 100% | 0% | 0% | 1.0 | 0.0 | 100% | 1 |
| Tartaruga Innocente | `tartaruga_innocente` | casuale | 100% | 0% | 0% | 1.0 | 0.0 | 100% | 1 |
| Un tenero ricordo | `tenero_ricordo` | attacca | 0% | 100% | 0% | 1.0 | 190.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | difendi | 0% | 100% | 0% | 1.0 | 190.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | studia | 0% | 100% | 0% | 1.0 | 190.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | casuale | 0% | 100% | 0% | 1.0 | 190.0 | 0% | 0 |
| Teschio Errante | `teschio_errante` | attacca | 9% | 91% | 0% | 1.0 | 181.8 | 0% | 3 |
| Teschio Errante | `teschio_errante` | difendi | 0% | 100% | 0% | 1.0 | 190.0 | 0% | 0 |
| Teschio Errante | `teschio_errante` | studia | 2% | 98% | 0% | 1.0 | 189.4 | 0% | 1 |
| Teschio Errante | `teschio_errante` | casuale | 2% | 98% | 0% | 1.0 | 188.7 | 0% | 1 |
| Titano Zombie | `titano_zombie` | attacca | 0% | 100% | 0% | 1.0 | 190.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | difendi | 0% | 100% | 0% | 1.0 | 190.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | studia | 0% | 100% | 0% | 1.0 | 190.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | casuale | 0% | 100% | 0% | 1.0 | 190.0 | 0% | 0 |
| Capocantiere | `voce_registrata` | attacca | 99% | 1% | 0% | 1.0 | 113.1 | 0% | 13 |
| Capocantiere | `voce_registrata` | difendi | 0% | 100% | 0% | 1.0 | 102.5 | 0% | 0 |
| Capocantiere | `voce_registrata` | studia | 95% | 5% | 0% | 1.0 | 151.8 | 0% | 12 |
| Capocantiere | `voce_registrata` | casuale | 89% | 11% | 0% | 1.0 | 123.9 | 0% | 12 |
| Volto sulla parete | `volto_sulla_parete` | attacca | 0% | 100% | 0% | 1.0 | 190.0 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | difendi | 0% | 100% | 0% | 1.0 | 190.0 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | studia | 0% | 100% | 0% | 1.0 | 190.0 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | casuale | 0% | 100% | 0% | 1.0 | 190.0 | 0% | 0 |
| Zombie Cittadino | `zombie_cittadino` | attacca | 100% | 0% | 0% | 1.0 | 13.1 | 0% | 4 |
| Zombie Cittadino | `zombie_cittadino` | difendi | 0% | 100% | 0% | 1.0 | 36.0 | 0% | 0 |
| Zombie Cittadino | `zombie_cittadino` | studia | 100% | 0% | 0% | 1.0 | 26.4 | 0% | 4 |
| Zombie Cittadino | `zombie_cittadino` | casuale | 100% | 0% | 0% | 1.0 | 19.3 | 0% | 4 |
| Zombie Mostruoso | `zombie_mostruoso` | attacca | 100% | 0% | 0% | 1.0 | 46.4 | 0% | 9 |
| Zombie Mostruoso | `zombie_mostruoso` | difendi | 0% | 100% | 0% | 1.0 | 69.7 | 0% | 0 |
| Zombie Mostruoso | `zombie_mostruoso` | studia | 100% | 0% | 0% | 1.0 | 63.2 | 0% | 9 |
| Zombie Mostruoso | `zombie_mostruoso` | casuale | 100% | 0% | 0% | 1.0 | 55.1 | 0% | 9 |

## Protagonista di livello 5

| creatura | id | come si gioca | vinte | perse | ∞ | giri | danno | risp. | xp |
|---|---|---|--:|--:|--:|--:|--:|--:|--:|
| Abominio Marcio | `abominio_marcio` | attacca | 0% | 100% | 0% | 1.0 | 285.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | difendi | 0% | 100% | 0% | 1.0 | 285.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | studia | 0% | 100% | 0% | 1.0 | 285.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | casuale | 0% | 100% | 0% | 1.0 | 285.0 | 0% | 0 |
| Oppresso | `comparsa_di_ruggine` | attacca | 100% | 0% | 0% | 1.0 | 21.0 | 0% | 14 |
| Oppresso | `comparsa_di_ruggine` | difendi | 0% | 100% | 0% | 1.0 | 25.2 | 0% | 0 |
| Oppresso | `comparsa_di_ruggine` | studia | 100% | 0% | 0% | 1.0 | 23.6 | 0% | 14 |
| Oppresso | `comparsa_di_ruggine` | casuale | 100% | 0% | 0% | 1.0 | 15.8 | 0% | 14 |
| Diabolo | `diabolo` | attacca | 53% | 47% | 0% | 1.0 | 253.0 | 0% | 19 |
| Diabolo | `diabolo` | difendi | 0% | 100% | 0% | 1.0 | 180.1 | 0% | 0 |
| Diabolo | `diabolo` | studia | 9% | 91% | 0% | 1.0 | 275.3 | 0% | 3 |
| Diabolo | `diabolo` | casuale | 73% | 27% | 0% | 1.0 | 233.2 | 0% | 25 |
| Il Divoratore | `divoratore` | attacca | 67% | 33% | 0% | 1.0 | 263.3 | 0% | 32 |
| Il Divoratore | `divoratore` | difendi | 0% | 100% | 0% | 1.0 | 129.7 | 0% | 0 |
| Il Divoratore | `divoratore` | studia | 21% | 79% | 0% | 1.0 | 282.3 | 0% | 10 |
| Il Divoratore | `divoratore` | casuale | 83% | 17% | 0% | 1.0 | 185.1 | 0% | 40 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | attacca | 7% | 93% | 0% | 1.0 | 273.6 | 0% | 3 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | difendi | 0% | 100% | 0% | 1.0 | 272.6 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | studia | 4% | 96% | 0% | 1.0 | 281.1 | 0% | 2 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | casuale | 6% | 94% | 0% | 1.0 | 279.3 | 0% | 3 |
| Donna Spinosa | `donna_spinosa` | attacca | 3% | 97% | 0% | 1.0 | 277.9 | 0% | 2 |
| Donna Spinosa | `donna_spinosa` | difendi | 0% | 100% | 0% | 1.0 | 285.0 | 0% | 0 |
| Donna Spinosa | `donna_spinosa` | studia | 2% | 98% | 0% | 1.0 | 283.5 | 0% | 1 |
| Donna Spinosa | `donna_spinosa` | casuale | 3% | 97% | 0% | 1.0 | 282.5 | 0% | 1 |
| Ferraglia Urlante | `ferraglia_urlante` | attacca | 100% | 0% | 0% | 1.0 | 84.1 | 0% | 26 |
| Ferraglia Urlante | `ferraglia_urlante` | difendi | 0% | 100% | 0% | 1.0 | 55.7 | 0% | 0 |
| Ferraglia Urlante | `ferraglia_urlante` | studia | 100% | 0% | 0% | 1.0 | 97.1 | 0% | 26 |
| Ferraglia Urlante | `ferraglia_urlante` | casuale | 10% | 90% | 0% | 1.0 | 68.2 | 0% | 3 |
| Ghoul | `ghoul` | attacca | 89% | 11% | 0% | 1.0 | 232.6 | 0% | 27 |
| Ghoul | `ghoul` | difendi | 0% | 100% | 0% | 1.0 | 198.5 | 0% | 0 |
| Ghoul | `ghoul` | studia | 34% | 66% | 0% | 1.0 | 271.1 | 0% | 10 |
| Ghoul | `ghoul` | casuale | 73% | 27% | 0% | 1.0 | 226.7 | 0% | 22 |
| El Muy Bonito | `giocoliere` | attacca | 100% | 0% | 0% | 1.0 | 106.9 | 0% | 25 |
| El Muy Bonito | `giocoliere` | difendi | 0% | 100% | 0% | 1.0 | 88.6 | 0% | 0 |
| El Muy Bonito | `giocoliere` | studia | 1% | 99% | 0% | 1.0 | 284.8 | 0% | 0 |
| El Muy Bonito | `giocoliere` | casuale | 11% | 89% | 0% | 1.0 | 272.1 | 0% | 3 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | attacca | 0% | 100% | 0% | 1.0 | 285.0 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | difendi | 0% | 100% | 0% | 1.0 | 243.6 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | studia | 0% | 100% | 0% | 1.0 | 285.0 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | casuale | 0% | 100% | 0% | 1.0 | 283.5 | 0% | 0 |
| Goblin Tipico | `goblin_tipico` | attacca | 100% | 0% | 0% | 1.0 | 3.7 | 0% | 3 |
| Goblin Tipico | `goblin_tipico` | difendi | 0% | 100% | 0% | 1.0 | 24.3 | 0% | 0 |
| Goblin Tipico | `goblin_tipico` | studia | 100% | 0% | 0% | 1.0 | 7.5 | 0% | 3 |
| Goblin Tipico | `goblin_tipico` | casuale | 100% | 0% | 0% | 1.0 | 5.4 | 0% | 3 |
| Infetto Rapido | `infetto_rapido` | attacca | 100% | 0% | 0% | 1.0 | 5.5 | 0% | 3 |
| Infetto Rapido | `infetto_rapido` | difendi | 0% | 100% | 0% | 1.0 | 86.5 | 0% | 0 |
| Infetto Rapido | `infetto_rapido` | studia | 100% | 0% | 0% | 1.0 | 12.2 | 0% | 3 |
| Infetto Rapido | `infetto_rapido` | casuale | 100% | 0% | 0% | 1.0 | 14.3 | 0% | 3 |
| L'ultimo spettacolo di Jerah | `jerah` | attacca | 0% | 100% | 0% | 1.0 | 285.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | difendi | 0% | 100% | 0% | 1.0 | 285.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | studia | 0% | 100% | 0% | 1.0 | 285.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | casuale | 0% | 100% | 0% | 1.0 | 285.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | attacca | 0% | 100% | 0% | 1.0 | 285.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | difendi | 0% | 100% | 0% | 1.0 | 285.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | studia | 0% | 100% | 0% | 1.0 | 285.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | casuale | 0% | 100% | 0% | 1.0 | 285.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | attacca | 0% | 100% | 0% | 1.0 | 285.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | difendi | 0% | 100% | 0% | 1.0 | 285.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | studia | 0% | 100% | 0% | 1.0 | 285.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | casuale | 0% | 100% | 0% | 1.0 | 285.0 | 0% | 0 |
| ??? | `l_immortale` | attacca | 0% | 100% | 0% | 1.0 | 105.7 | 0% | 0 |
| ??? | `l_immortale` | difendi | 0% | 100% | 0% | 1.0 | 69.2 | 0% | 0 |
| ??? | `l_immortale` | studia | 0% | 100% | 0% | 1.0 | 103.1 | 0% | 0 |
| ??? | `l_immortale` | casuale | 0% | 100% | 0% | 1.0 | 70.5 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | attacca | 99% | 1% | 0% | 1.0 | 212.5 | 0% | 30 |
| Madre in Lacrime | `madre_in_lacrime` | difendi | 0% | 100% | 0% | 1.0 | 242.7 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | studia | 64% | 36% | 0% | 1.0 | 259.5 | 0% | 19 |
| Madre in Lacrime | `madre_in_lacrime` | casuale | 75% | 25% | 0% | 1.0 | 229.1 | 0% | 22 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | attacca | 0% | 100% | 0% | 1.0 | 285.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | difendi | 0% | 100% | 0% | 1.0 | 285.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | studia | 0% | 100% | 0% | 1.0 | 285.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | casuale | 0% | 100% | 0% | 1.0 | 285.0 | 0% | 0 |
| Marionetta | `marionetta` | attacca | 5% | 95% | 0% | 1.0 | 275.9 | 0% | 3 |
| Marionetta | `marionetta` | difendi | 0% | 100% | 0% | 1.0 | 285.0 | 0% | 0 |
| Marionetta | `marionetta` | studia | 0% | 100% | 0% | 1.0 | 285.0 | 0% | 0 |
| Marionetta | `marionetta` | casuale | 1% | 99% | 0% | 1.0 | 284.0 | 0% | 1 |
| Fomentado | `maschera_vuota` | attacca | 100% | 0% | 0% | 1.0 | 27.7 | 0% | 6 |
| Fomentado | `maschera_vuota` | difendi | 0% | 100% | 0% | 1.0 | 35.2 | 0% | 0 |
| Fomentado | `maschera_vuota` | studia | 100% | 0% | 0% | 1.0 | 17.9 | 0% | 6 |
| Fomentado | `maschera_vuota` | casuale | 100% | 0% | 0% | 1.0 | 20.5 | 0% | 6 |
| Nuvola di Marciume | `nuvola_di_marciume` | attacca | 100% | 0% | 0% | 1.0 | 4.8 | 0% | 3 |
| Nuvola di Marciume | `nuvola_di_marciume` | difendi | 0% | 100% | 0% | 1.0 | 285.0 | 0% | 0 |
| Nuvola di Marciume | `nuvola_di_marciume` | studia | 100% | 0% | 0% | 1.0 | 16.3 | 0% | 3 |
| Nuvola di Marciume | `nuvola_di_marciume` | casuale | 99% | 1% | 0% | 1.0 | 41.4 | 0% | 3 |
| Ombra del passato | `ombra_del_passato` | attacca | 3% | 97% | 0% | 1.0 | 278.5 | 0% | 2 |
| Ombra del passato | `ombra_del_passato` | difendi | 0% | 100% | 0% | 1.0 | 285.0 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | studia | 1% | 99% | 0% | 1.0 | 284.0 | 0% | 1 |
| Ombra del passato | `ombra_del_passato` | casuale | 2% | 98% | 0% | 1.0 | 283.5 | 0% | 1 |
| Emblema dell'oppressione | `operaio_posseduto` | attacca | 100% | 0% | 0% | 1.0 | 53.1 | 0% | 18 |
| Emblema dell'oppressione | `operaio_posseduto` | difendi | 0% | 100% | 0% | 1.0 | 81.4 | 0% | 0 |
| Emblema dell'oppressione | `operaio_posseduto` | studia | 100% | 0% | 0% | 1.0 | 89.7 | 0% | 18 |
| Emblema dell'oppressione | `operaio_posseduto` | casuale | 100% | 0% | 0% | 1.0 | 67.4 | 0% | 18 |
| Operaio Sfruttato | `operaio_sfruttato` | attacca | 100% | 0% | 0% | 1.0 | 124.6 | 0% | 39 |
| Operaio Sfruttato | `operaio_sfruttato` | difendi | 0% | 100% | 0% | 1.0 | 64.6 | 0% | 0 |
| Operaio Sfruttato | `operaio_sfruttato` | studia | 100% | 0% | 0% | 1.0 | 137.6 | 0% | 39 |
| Operaio Sfruttato | `operaio_sfruttato` | casuale | 99% | 1% | 0% | 1.0 | 100.6 | 0% | 39 |
| Orrore di Meridia | `orrore_di_meridia` | attacca | 100% | 0% | 0% | 1.0 | 139.5 | 0% | 39 |
| Orrore di Meridia | `orrore_di_meridia` | difendi | 0% | 100% | 0% | 1.0 | 96.7 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | studia | 100% | 0% | 0% | 1.0 | 186.8 | 0% | 39 |
| Orrore di Meridia | `orrore_di_meridia` | casuale | 20% | 80% | 0% | 1.0 | 124.3 | 0% | 8 |
| Robo Pattuglia | `robo_pattuglia` | attacca | 100% | 0% | 0% | 1.0 | 24.1 | 0% | 14 |
| Robo Pattuglia | `robo_pattuglia` | difendi | 0% | 100% | 0% | 1.0 | 28.4 | 0% | 0 |
| Robo Pattuglia | `robo_pattuglia` | studia | 100% | 0% | 0% | 1.0 | 28.9 | 0% | 14 |
| Robo Pattuglia | `robo_pattuglia` | casuale | 91% | 9% | 0% | 1.0 | 23.5 | 0% | 13 |
| Sacerdote Folle | `sacerdote_folle` | attacca | 6% | 94% | 0% | 1.0 | 274.2 | 0% | 3 |
| Sacerdote Folle | `sacerdote_folle` | difendi | 0% | 100% | 0% | 1.0 | 285.0 | 0% | 0 |
| Sacerdote Folle | `sacerdote_folle` | studia | 1% | 99% | 0% | 1.0 | 284.4 | 0% | 1 |
| Sacerdote Folle | `sacerdote_folle` | casuale | 1% | 99% | 0% | 1.0 | 282.1 | 0% | 1 |
| Sadico | `sadico` | attacca | 8% | 92% | 0% | 1.0 | 269.7 | 0% | 3 |
| Sadico | `sadico` | difendi | 0% | 100% | 0% | 1.0 | 285.0 | 0% | 0 |
| Sadico | `sadico` | studia | 6% | 94% | 0% | 1.0 | 279.0 | 0% | 2 |
| Sadico | `sadico` | casuale | 4% | 96% | 0% | 1.0 | 278.7 | 0% | 1 |
| Slime Infimo | `slime_infimo` | attacca | 100% | 0% | 0% | 1.0 | 2.7 | 0% | 3 |
| Slime Infimo | `slime_infimo` | difendi | 0% | 100% | 0% | 1.0 | 24.9 | 0% | 0 |
| Slime Infimo | `slime_infimo` | studia | 100% | 0% | 0% | 1.0 | 5.2 | 0% | 3 |
| Slime Infimo | `slime_infimo` | casuale | 100% | 0% | 0% | 1.0 | 4.9 | 0% | 3 |
| Stigma | `stigma` | attacca | 15% | 85% | 0% | 1.0 | 266.8 | 0% | 5 |
| Stigma | `stigma` | difendi | 0% | 100% | 0% | 1.0 | 285.0 | 0% | 0 |
| Stigma | `stigma` | studia | 6% | 94% | 0% | 1.0 | 277.6 | 0% | 2 |
| Stigma | `stigma` | casuale | 5% | 95% | 0% | 1.0 | 279.4 | 0% | 2 |
| Tartaruga Innocente | `tartaruga_innocente` | attacca | 0% | 100% | 0% | 1.0 | 0.0 | 0% | 0 |
| Tartaruga Innocente | `tartaruga_innocente` | difendi | 0% | 100% | 0% | 1.0 | 0.0 | 0% | 0 |
| Tartaruga Innocente | `tartaruga_innocente` | studia | 100% | 0% | 0% | 1.0 | 0.0 | 100% | 1 |
| Tartaruga Innocente | `tartaruga_innocente` | casuale | 100% | 0% | 0% | 1.0 | 0.0 | 100% | 1 |
| Un tenero ricordo | `tenero_ricordo` | attacca | 0% | 100% | 0% | 1.0 | 285.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | difendi | 0% | 100% | 0% | 1.0 | 285.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | studia | 0% | 100% | 0% | 1.0 | 285.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | casuale | 0% | 100% | 0% | 1.0 | 285.0 | 0% | 0 |
| Teschio Errante | `teschio_errante` | attacca | 100% | 0% | 0% | 1.0 | 183.0 | 0% | 30 |
| Teschio Errante | `teschio_errante` | difendi | 0% | 100% | 0% | 1.0 | 212.8 | 0% | 0 |
| Teschio Errante | `teschio_errante` | studia | 93% | 7% | 0% | 1.0 | 233.1 | 0% | 28 |
| Teschio Errante | `teschio_errante` | casuale | 93% | 7% | 0% | 1.0 | 172.0 | 0% | 28 |
| Titano Zombie | `titano_zombie` | attacca | 0% | 100% | 0% | 1.0 | 285.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | difendi | 0% | 100% | 0% | 1.0 | 285.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | studia | 0% | 100% | 0% | 1.0 | 285.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | casuale | 0% | 100% | 0% | 1.0 | 285.0 | 0% | 0 |
| Capocantiere | `voce_registrata` | attacca | 100% | 0% | 0% | 1.0 | 38.5 | 0% | 11 |
| Capocantiere | `voce_registrata` | difendi | 0% | 100% | 0% | 1.0 | 50.1 | 0% | 0 |
| Capocantiere | `voce_registrata` | studia | 100% | 0% | 0% | 1.0 | 56.0 | 0% | 11 |
| Capocantiere | `voce_registrata` | casuale | 100% | 0% | 0% | 1.0 | 37.0 | 0% | 11 |
| Volto sulla parete | `volto_sulla_parete` | attacca | 0% | 100% | 0% | 1.0 | 285.0 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | difendi | 0% | 100% | 0% | 1.0 | 285.0 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | studia | 0% | 100% | 0% | 1.0 | 285.0 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | casuale | 0% | 100% | 0% | 1.0 | 285.0 | 0% | 0 |
| Zombie Cittadino | `zombie_cittadino` | attacca | 100% | 0% | 0% | 1.0 | 3.7 | 0% | 3 |
| Zombie Cittadino | `zombie_cittadino` | difendi | 0% | 100% | 0% | 1.0 | 24.3 | 0% | 0 |
| Zombie Cittadino | `zombie_cittadino` | studia | 100% | 0% | 0% | 1.0 | 10.8 | 0% | 3 |
| Zombie Cittadino | `zombie_cittadino` | casuale | 100% | 0% | 0% | 1.0 | 7.3 | 0% | 3 |
| Zombie Mostruoso | `zombie_mostruoso` | attacca | 100% | 0% | 0% | 1.0 | 15.4 | 0% | 6 |
| Zombie Mostruoso | `zombie_mostruoso` | difendi | 0% | 100% | 0% | 1.0 | 33.9 | 0% | 0 |
| Zombie Mostruoso | `zombie_mostruoso` | studia | 100% | 0% | 0% | 1.0 | 25.8 | 0% | 6 |
| Zombie Mostruoso | `zombie_mostruoso` | casuale | 100% | 0% | 0% | 1.0 | 16.9 | 0% | 6 |

## Protagonista di livello 8

| creatura | id | come si gioca | vinte | perse | ∞ | giri | danno | risp. | xp |
|---|---|---|--:|--:|--:|--:|--:|--:|--:|
| Abominio Marcio | `abominio_marcio` | attacca | 0% | 100% | 0% | 1.0 | 425.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | difendi | 0% | 100% | 0% | 1.0 | 425.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | studia | 0% | 100% | 0% | 1.0 | 425.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | casuale | 0% | 100% | 0% | 1.0 | 425.0 | 0% | 0 |
| Oppresso | `comparsa_di_ruggine` | attacca | 100% | 0% | 0% | 1.0 | 8.8 | 0% | 12 |
| Oppresso | `comparsa_di_ruggine` | difendi | 0% | 100% | 0% | 1.0 | 20.1 | 0% | 0 |
| Oppresso | `comparsa_di_ruggine` | studia | 100% | 0% | 0% | 1.0 | 10.1 | 0% | 12 |
| Oppresso | `comparsa_di_ruggine` | casuale | 100% | 0% | 0% | 1.0 | 8.8 | 0% | 12 |
| Diabolo | `diabolo` | attacca | 100% | 0% | 0% | 1.0 | 98.1 | 0% | 35 |
| Diabolo | `diabolo` | difendi | 0% | 100% | 0% | 1.0 | 90.0 | 0% | 0 |
| Diabolo | `diabolo` | studia | 100% | 0% | 0% | 1.0 | 125.0 | 0% | 35 |
| Diabolo | `diabolo` | casuale | 100% | 0% | 0% | 1.0 | 77.7 | 0% | 35 |
| Il Divoratore | `divoratore` | attacca | 100% | 0% | 0% | 1.0 | 86.1 | 0% | 34 |
| Il Divoratore | `divoratore` | difendi | 0% | 100% | 0% | 1.0 | 72.2 | 0% | 0 |
| Il Divoratore | `divoratore` | studia | 100% | 0% | 0% | 1.0 | 118.0 | 0% | 34 |
| Il Divoratore | `divoratore` | casuale | 99% | 1% | 0% | 1.0 | 62.2 | 0% | 34 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | attacca | 100% | 0% | 0% | 1.0 | 244.8 | 0% | 43 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | difendi | 0% | 100% | 0% | 1.0 | 165.7 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | studia | 100% | 0% | 0% | 1.0 | 279.7 | 0% | 43 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | casuale | 41% | 59% | 0% | 1.0 | 202.4 | 0% | 17 |
| Donna Spinosa | `donna_spinosa` | attacca | 25% | 75% | 0% | 1.0 | 388.2 | 0% | 13 |
| Donna Spinosa | `donna_spinosa` | difendi | 0% | 100% | 0% | 1.0 | 425.0 | 0% | 0 |
| Donna Spinosa | `donna_spinosa` | studia | 9% | 91% | 0% | 1.0 | 408.7 | 0% | 4 |
| Donna Spinosa | `donna_spinosa` | casuale | 6% | 94% | 0% | 1.0 | 414.4 | 0% | 3 |
| Ferraglia Urlante | `ferraglia_urlante` | attacca | 100% | 0% | 0% | 1.0 | 17.0 | 0% | 18 |
| Ferraglia Urlante | `ferraglia_urlante` | difendi | 0% | 100% | 0% | 1.0 | 27.4 | 0% | 0 |
| Ferraglia Urlante | `ferraglia_urlante` | studia | 100% | 0% | 0% | 1.0 | 21.3 | 0% | 18 |
| Ferraglia Urlante | `ferraglia_urlante` | casuale | 99% | 1% | 0% | 1.0 | 17.5 | 0% | 18 |
| Ghoul | `ghoul` | attacca | 100% | 0% | 0% | 1.0 | 89.5 | 0% | 30 |
| Ghoul | `ghoul` | difendi | 0% | 100% | 0% | 1.0 | 89.4 | 0% | 0 |
| Ghoul | `ghoul` | studia | 100% | 0% | 0% | 1.0 | 114.8 | 0% | 30 |
| Ghoul | `ghoul` | casuale | 100% | 0% | 0% | 1.0 | 81.7 | 0% | 30 |
| El Muy Bonito | `giocoliere` | attacca | 100% | 0% | 0% | 1.0 | 56.2 | 0% | 21 |
| El Muy Bonito | `giocoliere` | difendi | 0% | 100% | 0% | 1.0 | 58.2 | 0% | 0 |
| El Muy Bonito | `giocoliere` | studia | 100% | 0% | 0% | 1.0 | 147.9 | 0% | 21 |
| El Muy Bonito | `giocoliere` | casuale | 87% | 13% | 0% | 1.0 | 219.0 | 0% | 18 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | attacca | 0% | 100% | 0% | 1.0 | 425.0 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | difendi | 0% | 100% | 0% | 1.0 | 181.5 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | studia | 0% | 100% | 0% | 1.0 | 425.0 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | casuale | 0% | 100% | 0% | 1.0 | 255.1 | 0% | 0 |
| Goblin Tipico | `goblin_tipico` | attacca | 100% | 0% | 0% | 1.0 | 13.4 | 0% | 10 |
| Goblin Tipico | `goblin_tipico` | difendi | 0% | 100% | 0% | 1.0 | 41.1 | 0% | 0 |
| Goblin Tipico | `goblin_tipico` | studia | 100% | 0% | 0% | 1.0 | 28.6 | 0% | 10 |
| Goblin Tipico | `goblin_tipico` | casuale | 100% | 0% | 0% | 1.0 | 19.9 | 0% | 10 |
| Infetto Rapido | `infetto_rapido` | attacca | 100% | 0% | 0% | 1.0 | 11.2 | 0% | 10 |
| Infetto Rapido | `infetto_rapido` | difendi | 0% | 100% | 0% | 1.0 | 120.5 | 0% | 0 |
| Infetto Rapido | `infetto_rapido` | studia | 100% | 0% | 0% | 1.0 | 29.0 | 0% | 10 |
| Infetto Rapido | `infetto_rapido` | casuale | 100% | 0% | 0% | 1.0 | 26.4 | 0% | 10 |
| L'ultimo spettacolo di Jerah | `jerah` | attacca | 0% | 100% | 0% | 1.0 | 425.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | difendi | 0% | 100% | 0% | 1.0 | 425.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | studia | 0% | 100% | 0% | 1.0 | 425.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | casuale | 0% | 100% | 0% | 1.0 | 425.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | attacca | 0% | 100% | 0% | 1.0 | 425.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | difendi | 0% | 100% | 0% | 1.0 | 424.1 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | studia | 0% | 100% | 0% | 1.0 | 425.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | casuale | 0% | 100% | 0% | 1.0 | 424.9 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | attacca | 0% | 100% | 0% | 1.0 | 425.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | difendi | 0% | 100% | 0% | 1.0 | 425.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | studia | 0% | 100% | 0% | 1.0 | 425.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | casuale | 0% | 100% | 0% | 1.0 | 425.0 | 0% | 0 |
| ??? | `l_immortale` | attacca | 0% | 100% | 0% | 1.0 | 57.6 | 0% | 0 |
| ??? | `l_immortale` | difendi | 0% | 100% | 0% | 1.0 | 52.0 | 0% | 0 |
| ??? | `l_immortale` | studia | 0% | 100% | 0% | 1.0 | 57.5 | 0% | 0 |
| ??? | `l_immortale` | casuale | 0% | 100% | 0% | 1.0 | 52.3 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | attacca | 100% | 0% | 0% | 1.0 | 77.1 | 0% | 30 |
| Madre in Lacrime | `madre_in_lacrime` | difendi | 0% | 100% | 0% | 1.0 | 104.1 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | studia | 100% | 0% | 0% | 1.0 | 101.8 | 0% | 30 |
| Madre in Lacrime | `madre_in_lacrime` | casuale | 100% | 0% | 0% | 1.0 | 76.4 | 0% | 30 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | attacca | 0% | 100% | 0% | 1.0 | 425.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | difendi | 0% | 100% | 0% | 1.0 | 425.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | studia | 0% | 100% | 0% | 1.0 | 425.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | casuale | 0% | 100% | 0% | 1.0 | 425.0 | 0% | 0 |
| Marionetta | `marionetta` | attacca | 14% | 86% | 0% | 1.0 | 404.5 | 0% | 7 |
| Marionetta | `marionetta` | difendi | 0% | 100% | 0% | 1.0 | 404.8 | 0% | 0 |
| Marionetta | `marionetta` | studia | 10% | 90% | 0% | 1.0 | 406.9 | 0% | 5 |
| Marionetta | `marionetta` | casuale | 8% | 92% | 0% | 1.0 | 409.1 | 0% | 4 |
| Fomentado | `maschera_vuota` | attacca | 100% | 0% | 0% | 1.0 | 14.0 | 0% | 10 |
| Fomentado | `maschera_vuota` | difendi | 0% | 100% | 0% | 1.0 | 44.1 | 0% | 0 |
| Fomentado | `maschera_vuota` | studia | 100% | 0% | 0% | 1.0 | 51.8 | 0% | 10 |
| Fomentado | `maschera_vuota` | casuale | 100% | 0% | 0% | 1.0 | 30.7 | 0% | 10 |
| Nuvola di Marciume | `nuvola_di_marciume` | attacca | 100% | 0% | 0% | 1.0 | 10.3 | 0% | 10 |
| Nuvola di Marciume | `nuvola_di_marciume` | difendi | 0% | 100% | 0% | 1.0 | 425.0 | 0% | 0 |
| Nuvola di Marciume | `nuvola_di_marciume` | studia | 100% | 0% | 0% | 1.0 | 34.9 | 0% | 10 |
| Nuvola di Marciume | `nuvola_di_marciume` | casuale | 100% | 0% | 0% | 1.0 | 66.6 | 0% | 10 |
| Ombra del passato | `ombra_del_passato` | attacca | 17% | 83% | 0% | 1.0 | 395.6 | 0% | 10 |
| Ombra del passato | `ombra_del_passato` | difendi | 0% | 100% | 0% | 1.0 | 423.9 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | studia | 9% | 91% | 0% | 1.0 | 411.5 | 0% | 5 |
| Ombra del passato | `ombra_del_passato` | casuale | 11% | 89% | 0% | 1.0 | 412.0 | 0% | 6 |
| Emblema dell'oppressione | `operaio_posseduto` | attacca | 100% | 0% | 0% | 1.0 | 14.0 | 0% | 10 |
| Emblema dell'oppressione | `operaio_posseduto` | difendi | 0% | 100% | 0% | 1.0 | 42.9 | 0% | 0 |
| Emblema dell'oppressione | `operaio_posseduto` | studia | 100% | 0% | 0% | 1.0 | 35.4 | 0% | 10 |
| Emblema dell'oppressione | `operaio_posseduto` | casuale | 100% | 0% | 0% | 1.0 | 23.4 | 0% | 10 |
| Operaio Sfruttato | `operaio_sfruttato` | attacca | 100% | 0% | 0% | 1.0 | 55.1 | 0% | 21 |
| Operaio Sfruttato | `operaio_sfruttato` | difendi | 0% | 100% | 0% | 1.0 | 33.1 | 0% | 0 |
| Operaio Sfruttato | `operaio_sfruttato` | studia | 100% | 0% | 0% | 1.0 | 65.3 | 0% | 21 |
| Operaio Sfruttato | `operaio_sfruttato` | casuale | 100% | 0% | 0% | 1.0 | 30.3 | 0% | 21 |
| Orrore di Meridia | `orrore_di_meridia` | attacca | 100% | 0% | 0% | 1.0 | 37.6 | 0% | 21 |
| Orrore di Meridia | `orrore_di_meridia` | difendi | 0% | 100% | 0% | 1.0 | 55.0 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | studia | 100% | 0% | 0% | 1.0 | 56.0 | 0% | 21 |
| Orrore di Meridia | `orrore_di_meridia` | casuale | 99% | 1% | 0% | 1.0 | 38.8 | 0% | 21 |
| Robo Pattuglia | `robo_pattuglia` | attacca | 100% | 0% | 0% | 1.0 | 6.2 | 0% | 12 |
| Robo Pattuglia | `robo_pattuglia` | difendi | 0% | 100% | 0% | 1.0 | 21.4 | 0% | 0 |
| Robo Pattuglia | `robo_pattuglia` | studia | 100% | 0% | 0% | 1.0 | 13.0 | 0% | 12 |
| Robo Pattuglia | `robo_pattuglia` | casuale | 99% | 1% | 0% | 1.0 | 11.8 | 0% | 12 |
| Sacerdote Folle | `sacerdote_folle` | attacca | 38% | 62% | 0% | 1.0 | 373.7 | 0% | 23 |
| Sacerdote Folle | `sacerdote_folle` | difendi | 0% | 100% | 0% | 1.0 | 408.5 | 0% | 0 |
| Sacerdote Folle | `sacerdote_folle` | studia | 17% | 83% | 0% | 1.0 | 406.0 | 0% | 10 |
| Sacerdote Folle | `sacerdote_folle` | casuale | 9% | 91% | 0% | 1.0 | 398.9 | 0% | 7 |
| Sadico | `sadico` | attacca | 100% | 0% | 0% | 1.0 | 134.3 | 0% | 35 |
| Sadico | `sadico` | difendi | 0% | 100% | 0% | 1.0 | 425.0 | 0% | 0 |
| Sadico | `sadico` | studia | 100% | 0% | 0% | 1.0 | 192.4 | 0% | 35 |
| Sadico | `sadico` | casuale | 60% | 40% | 0% | 1.0 | 330.5 | 0% | 21 |
| Slime Infimo | `slime_infimo` | attacca | 100% | 0% | 0% | 1.0 | 12.2 | 0% | 10 |
| Slime Infimo | `slime_infimo` | difendi | 0% | 100% | 0% | 1.0 | 42.5 | 0% | 0 |
| Slime Infimo | `slime_infimo` | studia | 100% | 0% | 0% | 1.0 | 22.6 | 0% | 10 |
| Slime Infimo | `slime_infimo` | casuale | 97% | 3% | 0% | 1.0 | 20.9 | 0% | 10 |
| Stigma | `stigma` | attacca | 100% | 0% | 0% | 1.0 | 126.8 | 0% | 35 |
| Stigma | `stigma` | difendi | 0% | 100% | 0% | 1.0 | 425.0 | 0% | 0 |
| Stigma | `stigma` | studia | 100% | 0% | 0% | 1.0 | 168.8 | 0% | 35 |
| Stigma | `stigma` | casuale | 84% | 16% | 0% | 1.0 | 255.0 | 0% | 29 |
| Tartaruga Innocente | `tartaruga_innocente` | attacca | 0% | 100% | 0% | 1.0 | 0.0 | 0% | 0 |
| Tartaruga Innocente | `tartaruga_innocente` | difendi | 0% | 100% | 0% | 1.0 | 0.0 | 0% | 0 |
| Tartaruga Innocente | `tartaruga_innocente` | studia | 100% | 0% | 0% | 1.0 | 0.0 | 100% | 1 |
| Tartaruga Innocente | `tartaruga_innocente` | casuale | 100% | 0% | 0% | 1.0 | 0.0 | 100% | 1 |
| Un tenero ricordo | `tenero_ricordo` | attacca | 0% | 100% | 0% | 1.0 | 425.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | difendi | 0% | 100% | 0% | 1.0 | 425.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | studia | 0% | 100% | 0% | 1.0 | 425.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | casuale | 0% | 100% | 0% | 1.0 | 425.0 | 0% | 0 |
| Teschio Errante | `teschio_errante` | attacca | 100% | 0% | 0% | 1.0 | 63.9 | 0% | 30 |
| Teschio Errante | `teschio_errante` | difendi | 0% | 100% | 0% | 1.0 | 92.8 | 0% | 0 |
| Teschio Errante | `teschio_errante` | studia | 100% | 0% | 0% | 1.0 | 78.9 | 0% | 30 |
| Teschio Errante | `teschio_errante` | casuale | 100% | 0% | 0% | 1.0 | 57.6 | 0% | 30 |
| Titano Zombie | `titano_zombie` | attacca | 0% | 100% | 0% | 1.0 | 425.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | difendi | 0% | 100% | 0% | 1.0 | 425.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | studia | 0% | 100% | 0% | 1.0 | 425.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | casuale | 0% | 100% | 0% | 1.0 | 425.0 | 0% | 0 |
| Capocantiere | `voce_registrata` | attacca | 100% | 0% | 0% | 1.0 | 22.7 | 0% | 10 |
| Capocantiere | `voce_registrata` | difendi | 0% | 100% | 0% | 1.0 | 37.1 | 0% | 0 |
| Capocantiere | `voce_registrata` | studia | 100% | 0% | 0% | 1.0 | 40.8 | 0% | 10 |
| Capocantiere | `voce_registrata` | casuale | 100% | 0% | 0% | 1.0 | 23.9 | 0% | 10 |
| Volto sulla parete | `volto_sulla_parete` | attacca | 0% | 100% | 0% | 1.0 | 425.0 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | difendi | 0% | 100% | 0% | 1.0 | 425.0 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | studia | 0% | 100% | 0% | 1.0 | 425.0 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | casuale | 0% | 100% | 0% | 1.0 | 425.0 | 0% | 0 |
| Zombie Cittadino | `zombie_cittadino` | attacca | 100% | 0% | 0% | 1.0 | 20.8 | 0% | 10 |
| Zombie Cittadino | `zombie_cittadino` | difendi | 0% | 100% | 0% | 1.0 | 39.0 | 0% | 0 |
| Zombie Cittadino | `zombie_cittadino` | studia | 100% | 0% | 0% | 1.0 | 36.9 | 0% | 10 |
| Zombie Cittadino | `zombie_cittadino` | casuale | 100% | 0% | 0% | 1.0 | 21.3 | 0% | 10 |
| Zombie Mostruoso | `zombie_mostruoso` | attacca | 100% | 0% | 0% | 1.0 | 24.6 | 0% | 10 |
| Zombie Mostruoso | `zombie_mostruoso` | difendi | 0% | 100% | 0% | 1.0 | 44.8 | 0% | 0 |
| Zombie Mostruoso | `zombie_mostruoso` | studia | 100% | 0% | 0% | 1.0 | 44.2 | 0% | 10 |
| Zombie Mostruoso | `zombie_mostruoso` | casuale | 100% | 0% | 0% | 1.0 | 27.1 | 0% | 10 |

## Protagonista di livello 12

| creatura | id | come si gioca | vinte | perse | ∞ | giri | danno | risp. | xp |
|---|---|---|--:|--:|--:|--:|--:|--:|--:|
| Abominio Marcio | `abominio_marcio` | attacca | 100% | 0% | 0% | 1.0 | 240.5 | 0% | 60 |
| Abominio Marcio | `abominio_marcio` | difendi | 0% | 100% | 0% | 1.0 | 610.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | studia | 100% | 0% | 0% | 1.0 | 342.4 | 0% | 60 |
| Abominio Marcio | `abominio_marcio` | casuale | 4% | 96% | 0% | 1.0 | 605.0 | 0% | 2 |
| Oppresso | `comparsa_di_ruggine` | attacca | 100% | 0% | 0% | 1.0 | 18.2 | 0% | 23 |
| Oppresso | `comparsa_di_ruggine` | difendi | 0% | 100% | 0% | 1.0 | 22.9 | 0% | 0 |
| Oppresso | `comparsa_di_ruggine` | studia | 100% | 0% | 0% | 1.0 | 22.9 | 0% | 23 |
| Oppresso | `comparsa_di_ruggine` | casuale | 100% | 0% | 0% | 1.0 | 13.2 | 0% | 23 |
| Diabolo | `diabolo` | attacca | 100% | 0% | 0% | 1.0 | 30.0 | 0% | 19 |
| Diabolo | `diabolo` | difendi | 0% | 100% | 0% | 1.0 | 51.5 | 0% | 0 |
| Diabolo | `diabolo` | studia | 100% | 0% | 0% | 1.0 | 45.5 | 0% | 19 |
| Diabolo | `diabolo` | casuale | 100% | 0% | 0% | 1.0 | 26.2 | 0% | 19 |
| Il Divoratore | `divoratore` | attacca | 100% | 0% | 0% | 1.0 | 104.1 | 0% | 42 |
| Il Divoratore | `divoratore` | difendi | 0% | 100% | 0% | 1.0 | 79.9 | 0% | 0 |
| Il Divoratore | `divoratore` | studia | 100% | 0% | 0% | 1.0 | 131.8 | 0% | 42 |
| Il Divoratore | `divoratore` | casuale | 100% | 0% | 0% | 1.0 | 74.3 | 0% | 42 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | attacca | 100% | 0% | 0% | 1.0 | 60.1 | 0% | 37 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | difendi | 0% | 100% | 0% | 1.0 | 86.3 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | studia | 100% | 0% | 0% | 1.0 | 101.4 | 0% | 37 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | casuale | 98% | 2% | 0% | 1.0 | 64.1 | 0% | 36 |
| Donna Spinosa | `donna_spinosa` | attacca | 100% | 0% | 0% | 1.0 | 159.9 | 0% | 51 |
| Donna Spinosa | `donna_spinosa` | difendi | 0% | 100% | 0% | 1.0 | 610.0 | 0% | 0 |
| Donna Spinosa | `donna_spinosa` | studia | 100% | 0% | 0% | 1.0 | 246.6 | 0% | 51 |
| Donna Spinosa | `donna_spinosa` | casuale | 84% | 16% | 0% | 1.0 | 382.3 | 0% | 43 |
| Ferraglia Urlante | `ferraglia_urlante` | attacca | 100% | 0% | 0% | 1.0 | 18.5 | 0% | 23 |
| Ferraglia Urlante | `ferraglia_urlante` | difendi | 0% | 100% | 0% | 1.0 | 24.9 | 0% | 0 |
| Ferraglia Urlante | `ferraglia_urlante` | studia | 100% | 0% | 0% | 1.0 | 23.2 | 0% | 23 |
| Ferraglia Urlante | `ferraglia_urlante` | casuale | 99% | 1% | 0% | 1.0 | 18.9 | 0% | 23 |
| Ghoul | `ghoul` | attacca | 100% | 0% | 0% | 1.0 | 52.8 | 0% | 19 |
| Ghoul | `ghoul` | difendi | 0% | 100% | 0% | 1.0 | 60.0 | 0% | 0 |
| Ghoul | `ghoul` | studia | 100% | 0% | 0% | 1.0 | 69.3 | 0% | 19 |
| Ghoul | `ghoul` | casuale | 100% | 0% | 0% | 1.0 | 48.3 | 0% | 19 |
| El Muy Bonito | `giocoliere` | attacca | 100% | 0% | 0% | 1.0 | 103.4 | 0% | 42 |
| El Muy Bonito | `giocoliere` | difendi | 0% | 100% | 0% | 1.0 | 91.7 | 0% | 0 |
| El Muy Bonito | `giocoliere` | studia | 100% | 0% | 0% | 1.0 | 299.7 | 0% | 42 |
| El Muy Bonito | `giocoliere` | casuale | 78% | 22% | 0% | 1.0 | 390.6 | 0% | 33 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | attacca | 0% | 100% | 0% | 1.0 | 610.0 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | difendi | 0% | 100% | 0% | 1.0 | 218.4 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | studia | 0% | 100% | 0% | 1.0 | 610.0 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | casuale | 0% | 100% | 0% | 1.0 | 352.7 | 0% | 0 |
| Goblin Tipico | `goblin_tipico` | attacca | 100% | 0% | 0% | 1.0 | 35.7 | 0% | 19 |
| Goblin Tipico | `goblin_tipico` | difendi | 0% | 100% | 0% | 1.0 | 54.0 | 0% | 0 |
| Goblin Tipico | `goblin_tipico` | studia | 100% | 0% | 0% | 1.0 | 46.0 | 0% | 19 |
| Goblin Tipico | `goblin_tipico` | casuale | 100% | 0% | 0% | 1.0 | 36.9 | 0% | 19 |
| Infetto Rapido | `infetto_rapido` | attacca | 100% | 0% | 0% | 1.0 | 33.0 | 0% | 21 |
| Infetto Rapido | `infetto_rapido` | difendi | 0% | 100% | 0% | 1.0 | 143.3 | 0% | 0 |
| Infetto Rapido | `infetto_rapido` | studia | 100% | 0% | 0% | 1.0 | 64.1 | 0% | 21 |
| Infetto Rapido | `infetto_rapido` | casuale | 100% | 0% | 0% | 1.0 | 50.6 | 0% | 21 |
| L'ultimo spettacolo di Jerah | `jerah` | attacca | 0% | 100% | 0% | 1.0 | 610.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | difendi | 0% | 100% | 0% | 1.0 | 606.6 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | studia | 0% | 100% | 0% | 1.0 | 610.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | casuale | 0% | 100% | 0% | 1.0 | 606.6 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | attacca | 0% | 100% | 0% | 1.0 | 610.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | difendi | 0% | 100% | 0% | 1.0 | 207.1 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | studia | 0% | 100% | 0% | 1.0 | 610.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | casuale | 0% | 100% | 0% | 1.0 | 305.3 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | attacca | 0% | 100% | 0% | 1.0 | 610.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | difendi | 0% | 100% | 0% | 1.0 | 597.4 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | studia | 0% | 100% | 0% | 1.0 | 610.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | casuale | 0% | 100% | 0% | 1.0 | 609.9 | 0% | 0 |
| ??? | `l_immortale` | attacca | 0% | 100% | 0% | 1.0 | 39.9 | 0% | 0 |
| ??? | `l_immortale` | difendi | 0% | 100% | 0% | 1.0 | 38.0 | 0% | 0 |
| ??? | `l_immortale` | studia | 0% | 100% | 0% | 1.0 | 40.2 | 0% | 0 |
| ??? | `l_immortale` | casuale | 0% | 100% | 0% | 1.0 | 38.1 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | attacca | 100% | 0% | 0% | 1.0 | 39.1 | 0% | 19 |
| Madre in Lacrime | `madre_in_lacrime` | difendi | 0% | 100% | 0% | 1.0 | 65.4 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | studia | 100% | 0% | 0% | 1.0 | 61.7 | 0% | 19 |
| Madre in Lacrime | `madre_in_lacrime` | casuale | 100% | 0% | 0% | 1.0 | 42.9 | 0% | 19 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | attacca | 0% | 100% | 0% | 1.0 | 610.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | difendi | 0% | 100% | 0% | 1.0 | 610.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | studia | 0% | 100% | 0% | 1.0 | 610.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | casuale | 0% | 100% | 0% | 1.0 | 610.0 | 0% | 0 |
| Marionetta | `marionetta` | attacca | 100% | 0% | 0% | 1.0 | 180.6 | 0% | 51 |
| Marionetta | `marionetta` | difendi | 0% | 100% | 0% | 1.0 | 142.7 | 0% | 0 |
| Marionetta | `marionetta` | studia | 100% | 0% | 0% | 1.0 | 242.3 | 0% | 51 |
| Marionetta | `marionetta` | casuale | 83% | 17% | 0% | 1.0 | 194.1 | 0% | 42 |
| Fomentado | `maschera_vuota` | attacca | 100% | 0% | 0% | 1.0 | 69.5 | 0% | 19 |
| Fomentado | `maschera_vuota` | difendi | 0% | 100% | 0% | 1.0 | 56.4 | 0% | 0 |
| Fomentado | `maschera_vuota` | studia | 100% | 0% | 0% | 1.0 | 95.2 | 0% | 19 |
| Fomentado | `maschera_vuota` | casuale | 100% | 0% | 0% | 1.0 | 59.0 | 0% | 19 |
| Nuvola di Marciume | `nuvola_di_marciume` | attacca | 100% | 0% | 0% | 1.0 | 29.4 | 0% | 21 |
| Nuvola di Marciume | `nuvola_di_marciume` | difendi | 0% | 100% | 0% | 1.0 | 610.0 | 0% | 0 |
| Nuvola di Marciume | `nuvola_di_marciume` | studia | 100% | 0% | 0% | 1.0 | 67.9 | 0% | 21 |
| Nuvola di Marciume | `nuvola_di_marciume` | casuale | 99% | 1% | 0% | 1.0 | 116.9 | 0% | 21 |
| Ombra del passato | `ombra_del_passato` | attacca | 100% | 0% | 0% | 1.0 | 223.8 | 0% | 55 |
| Ombra del passato | `ombra_del_passato` | difendi | 0% | 100% | 0% | 1.0 | 171.3 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | studia | 100% | 0% | 0% | 1.0 | 277.0 | 0% | 55 |
| Ombra del passato | `ombra_del_passato` | casuale | 99% | 1% | 0% | 1.0 | 217.3 | 0% | 55 |
| Emblema dell'oppressione | `operaio_posseduto` | attacca | 100% | 0% | 0% | 1.0 | 25.6 | 0% | 19 |
| Emblema dell'oppressione | `operaio_posseduto` | difendi | 0% | 100% | 0% | 1.0 | 58.2 | 0% | 0 |
| Emblema dell'oppressione | `operaio_posseduto` | studia | 100% | 0% | 0% | 1.0 | 52.0 | 0% | 19 |
| Emblema dell'oppressione | `operaio_posseduto` | casuale | 100% | 0% | 0% | 1.0 | 42.4 | 0% | 19 |
| Operaio Sfruttato | `operaio_sfruttato` | attacca | 100% | 0% | 0% | 1.0 | 89.7 | 0% | 42 |
| Operaio Sfruttato | `operaio_sfruttato` | difendi | 0% | 100% | 0% | 1.0 | 53.9 | 0% | 0 |
| Operaio Sfruttato | `operaio_sfruttato` | studia | 100% | 0% | 0% | 1.0 | 113.3 | 0% | 42 |
| Operaio Sfruttato | `operaio_sfruttato` | casuale | 100% | 0% | 0% | 1.0 | 75.0 | 0% | 42 |
| Orrore di Meridia | `orrore_di_meridia` | attacca | 100% | 0% | 0% | 1.0 | 101.2 | 0% | 42 |
| Orrore di Meridia | `orrore_di_meridia` | difendi | 0% | 100% | 0% | 1.0 | 84.9 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | studia | 100% | 0% | 0% | 1.0 | 130.8 | 0% | 42 |
| Orrore di Meridia | `orrore_di_meridia` | casuale | 84% | 16% | 0% | 1.0 | 91.4 | 0% | 35 |
| Robo Pattuglia | `robo_pattuglia` | attacca | 100% | 0% | 0% | 1.0 | 24.7 | 0% | 23 |
| Robo Pattuglia | `robo_pattuglia` | difendi | 0% | 100% | 0% | 1.0 | 25.4 | 0% | 0 |
| Robo Pattuglia | `robo_pattuglia` | studia | 100% | 0% | 0% | 1.0 | 30.3 | 0% | 23 |
| Robo Pattuglia | `robo_pattuglia` | casuale | 93% | 7% | 0% | 1.0 | 20.7 | 0% | 21 |
| Sacerdote Folle | `sacerdote_folle` | attacca | 100% | 0% | 0% | 1.0 | 107.1 | 0% | 47 |
| Sacerdote Folle | `sacerdote_folle` | difendi | 0% | 100% | 0% | 1.0 | 224.8 | 0% | 0 |
| Sacerdote Folle | `sacerdote_folle` | studia | 100% | 0% | 0% | 1.0 | 226.1 | 0% | 57 |
| Sacerdote Folle | `sacerdote_folle` | casuale | 23% | 77% | 0% | 1.0 | 231.5 | 0% | 13 |
| Sadico | `sadico` | attacca | 100% | 0% | 0% | 1.0 | 42.8 | 0% | 19 |
| Sadico | `sadico` | difendi | 0% | 100% | 0% | 1.0 | 610.0 | 0% | 0 |
| Sadico | `sadico` | studia | 100% | 0% | 0% | 1.0 | 76.7 | 0% | 19 |
| Sadico | `sadico` | casuale | 99% | 1% | 0% | 1.0 | 160.4 | 0% | 19 |
| Slime Infimo | `slime_infimo` | attacca | 100% | 0% | 0% | 1.0 | 29.5 | 0% | 19 |
| Slime Infimo | `slime_infimo` | difendi | 0% | 100% | 0% | 1.0 | 47.3 | 0% | 0 |
| Slime Infimo | `slime_infimo` | studia | 100% | 0% | 0% | 1.0 | 48.5 | 0% | 19 |
| Slime Infimo | `slime_infimo` | casuale | 93% | 7% | 0% | 1.0 | 34.5 | 0% | 18 |
| Stigma | `stigma` | attacca | 100% | 0% | 0% | 1.0 | 39.8 | 0% | 19 |
| Stigma | `stigma` | difendi | 0% | 100% | 0% | 1.0 | 609.5 | 0% | 0 |
| Stigma | `stigma` | studia | 100% | 0% | 0% | 1.0 | 71.6 | 0% | 19 |
| Stigma | `stigma` | casuale | 100% | 0% | 0% | 1.0 | 100.4 | 0% | 19 |
| Tartaruga Innocente | `tartaruga_innocente` | attacca | 100% | 0% | 0% | 1.0 | 0.0 | 0% | 1 |
| Tartaruga Innocente | `tartaruga_innocente` | difendi | 0% | 100% | 0% | 1.0 | 0.0 | 0% | 0 |
| Tartaruga Innocente | `tartaruga_innocente` | studia | 100% | 0% | 0% | 1.0 | 0.0 | 100% | 1 |
| Tartaruga Innocente | `tartaruga_innocente` | casuale | 100% | 0% | 0% | 1.0 | 0.0 | 100% | 1 |
| Un tenero ricordo | `tenero_ricordo` | attacca | 0% | 100% | 0% | 1.0 | 610.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | difendi | 0% | 100% | 0% | 1.0 | 610.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | studia | 0% | 100% | 0% | 1.0 | 610.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | casuale | 0% | 100% | 0% | 1.0 | 610.0 | 0% | 0 |
| Teschio Errante | `teschio_errante` | attacca | 100% | 0% | 0% | 1.0 | 28.8 | 0% | 19 |
| Teschio Errante | `teschio_errante` | difendi | 0% | 100% | 0% | 1.0 | 57.2 | 0% | 0 |
| Teschio Errante | `teschio_errante` | studia | 100% | 0% | 0% | 1.0 | 44.6 | 0% | 19 |
| Teschio Errante | `teschio_errante` | casuale | 100% | 0% | 0% | 1.0 | 28.2 | 0% | 19 |
| Titano Zombie | `titano_zombie` | attacca | 99% | 1% | 0% | 1.0 | 477.8 | 0% | 59 |
| Titano Zombie | `titano_zombie` | difendi | 0% | 100% | 0% | 1.0 | 610.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | studia | 90% | 10% | 0% | 1.0 | 510.8 | 0% | 54 |
| Titano Zombie | `titano_zombie` | casuale | 0% | 100% | 0% | 1.0 | 610.0 | 0% | 0 |
| Capocantiere | `voce_registrata` | attacca | 100% | 0% | 0% | 1.0 | 41.2 | 0% | 19 |
| Capocantiere | `voce_registrata` | difendi | 0% | 100% | 0% | 1.0 | 50.7 | 0% | 0 |
| Capocantiere | `voce_registrata` | studia | 100% | 0% | 0% | 1.0 | 64.4 | 0% | 19 |
| Capocantiere | `voce_registrata` | casuale | 100% | 0% | 0% | 1.0 | 38.6 | 0% | 19 |
| Volto sulla parete | `volto_sulla_parete` | attacca | 0% | 100% | 0% | 1.0 | 610.0 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | difendi | 0% | 100% | 0% | 1.0 | 610.0 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | studia | 0% | 100% | 0% | 1.0 | 610.0 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | casuale | 0% | 100% | 0% | 1.0 | 610.0 | 0% | 0 |
| Zombie Cittadino | `zombie_cittadino` | attacca | 100% | 0% | 0% | 1.0 | 37.9 | 0% | 19 |
| Zombie Cittadino | `zombie_cittadino` | difendi | 0% | 100% | 0% | 1.0 | 51.4 | 0% | 0 |
| Zombie Cittadino | `zombie_cittadino` | studia | 100% | 0% | 0% | 1.0 | 59.2 | 0% | 19 |
| Zombie Cittadino | `zombie_cittadino` | casuale | 100% | 0% | 0% | 1.0 | 34.6 | 0% | 19 |
| Zombie Mostruoso | `zombie_mostruoso` | attacca | 100% | 0% | 0% | 1.0 | 43.8 | 0% | 19 |
| Zombie Mostruoso | `zombie_mostruoso` | difendi | 0% | 100% | 0% | 1.0 | 59.5 | 0% | 0 |
| Zombie Mostruoso | `zombie_mostruoso` | studia | 100% | 0% | 0% | 1.0 | 68.8 | 0% | 19 |
| Zombie Mostruoso | `zombie_mostruoso` | casuale | 100% | 0% | 0% | 1.0 | 45.2 | 0% | 19 |

## Protagonista di livello 18

| creatura | id | come si gioca | vinte | perse | ∞ | giri | danno | risp. | xp |
|---|---|---|--:|--:|--:|--:|--:|--:|--:|
| Abominio Marcio | `abominio_marcio` | attacca | 100% | 0% | 0% | 1.0 | 283.7 | 0% | 71 |
| Abominio Marcio | `abominio_marcio` | difendi | 0% | 100% | 0% | 1.0 | 889.7 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | studia | 100% | 0% | 0% | 1.0 | 402.7 | 0% | 71 |
| Abominio Marcio | `abominio_marcio` | casuale | 7% | 93% | 0% | 1.0 | 868.3 | 0% | 5 |
| Oppresso | `comparsa_di_ruggine` | attacca | 100% | 0% | 0% | 1.0 | 38.4 | 0% | 39 |
| Oppresso | `comparsa_di_ruggine` | difendi | 0% | 100% | 0% | 1.0 | 29.1 | 0% | 0 |
| Oppresso | `comparsa_di_ruggine` | studia | 100% | 0% | 0% | 1.0 | 48.5 | 0% | 39 |
| Oppresso | `comparsa_di_ruggine` | casuale | 100% | 0% | 0% | 1.0 | 23.3 | 0% | 39 |
| Diabolo | `diabolo` | attacca | 100% | 0% | 0% | 1.0 | 61.3 | 0% | 32 |
| Diabolo | `diabolo` | difendi | 0% | 100% | 0% | 1.0 | 65.7 | 0% | 0 |
| Diabolo | `diabolo` | studia | 100% | 0% | 0% | 1.0 | 81.3 | 0% | 32 |
| Diabolo | `diabolo` | casuale | 100% | 0% | 0% | 1.0 | 44.3 | 0% | 32 |
| Il Divoratore | `divoratore` | attacca | 100% | 0% | 0% | 1.0 | 219.7 | 0% | 71 |
| Il Divoratore | `divoratore` | difendi | 0% | 100% | 0% | 1.0 | 121.8 | 0% | 0 |
| Il Divoratore | `divoratore` | studia | 100% | 0% | 0% | 1.0 | 252.2 | 0% | 71 |
| Il Divoratore | `divoratore` | casuale | 99% | 1% | 0% | 1.0 | 145.2 | 0% | 71 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | attacca | 100% | 0% | 0% | 1.0 | 34.0 | 0% | 32 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | difendi | 0% | 100% | 0% | 1.0 | 71.7 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | studia | 100% | 0% | 0% | 1.0 | 72.9 | 0% | 32 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | casuale | 99% | 1% | 0% | 1.0 | 44.8 | 0% | 32 |
| Donna Spinosa | `donna_spinosa` | attacca | 100% | 0% | 0% | 1.0 | 77.4 | 0% | 32 |
| Donna Spinosa | `donna_spinosa` | difendi | 0% | 100% | 0% | 1.0 | 890.0 | 0% | 0 |
| Donna Spinosa | `donna_spinosa` | studia | 100% | 0% | 0% | 1.0 | 125.5 | 0% | 32 |
| Donna Spinosa | `donna_spinosa` | casuale | 100% | 0% | 0% | 1.0 | 218.9 | 0% | 32 |
| Ferraglia Urlante | `ferraglia_urlante` | attacca | 100% | 0% | 0% | 1.0 | 38.4 | 0% | 39 |
| Ferraglia Urlante | `ferraglia_urlante` | difendi | 0% | 100% | 0% | 1.0 | 35.9 | 0% | 0 |
| Ferraglia Urlante | `ferraglia_urlante` | studia | 100% | 0% | 0% | 1.0 | 52.0 | 0% | 39 |
| Ferraglia Urlante | `ferraglia_urlante` | casuale | 91% | 9% | 0% | 1.0 | 32.1 | 0% | 35 |
| Ghoul | `ghoul` | attacca | 100% | 0% | 0% | 1.0 | 83.5 | 0% | 32 |
| Ghoul | `ghoul` | difendi | 0% | 100% | 0% | 1.0 | 88.6 | 0% | 0 |
| Ghoul | `ghoul` | studia | 100% | 0% | 0% | 1.0 | 122.2 | 0% | 32 |
| Ghoul | `ghoul` | casuale | 100% | 0% | 0% | 1.0 | 80.0 | 0% | 32 |
| El Muy Bonito | `giocoliere` | attacca | 100% | 0% | 0% | 1.0 | 230.8 | 0% | 71 |
| El Muy Bonito | `giocoliere` | difendi | 0% | 100% | 0% | 1.0 | 130.7 | 0% | 0 |
| El Muy Bonito | `giocoliere` | studia | 100% | 0% | 0% | 1.0 | 438.4 | 0% | 71 |
| El Muy Bonito | `giocoliere` | casuale | 78% | 22% | 0% | 1.0 | 635.4 | 0% | 55 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | attacca | 0% | 100% | 0% | 1.0 | 890.0 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | difendi | 0% | 100% | 0% | 1.0 | 269.8 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | studia | 0% | 100% | 0% | 1.0 | 890.0 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | casuale | 0% | 100% | 0% | 1.0 | 430.1 | 0% | 0 |
| Goblin Tipico | `goblin_tipico` | attacca | 100% | 0% | 0% | 1.0 | 54.5 | 0% | 32 |
| Goblin Tipico | `goblin_tipico` | difendi | 0% | 100% | 0% | 1.0 | 78.3 | 0% | 0 |
| Goblin Tipico | `goblin_tipico` | studia | 100% | 0% | 0% | 1.0 | 89.6 | 0% | 32 |
| Goblin Tipico | `goblin_tipico` | casuale | 100% | 0% | 0% | 1.0 | 58.3 | 0% | 32 |
| Infetto Rapido | `infetto_rapido` | attacca | 100% | 0% | 0% | 1.0 | 66.3 | 0% | 36 |
| Infetto Rapido | `infetto_rapido` | difendi | 0% | 100% | 0% | 1.0 | 170.2 | 0% | 0 |
| Infetto Rapido | `infetto_rapido` | studia | 100% | 0% | 0% | 1.0 | 110.9 | 0% | 36 |
| Infetto Rapido | `infetto_rapido` | casuale | 100% | 0% | 0% | 1.0 | 88.1 | 0% | 36 |
| L'ultimo spettacolo di Jerah | `jerah` | attacca | 3% | 97% | 0% | 1.0 | 886.9 | 0% | 16 |
| L'ultimo spettacolo di Jerah | `jerah` | difendi | 0% | 100% | 0% | 1.0 | 646.4 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | studia | 16% | 84% | 0% | 1.0 | 864.5 | 0% | 79 |
| L'ultimo spettacolo di Jerah | `jerah` | casuale | 1% | 99% | 0% | 1.0 | 702.3 | 0% | 3 |
| Jongo Dongo | `jongo_dongo` | attacca | 2% | 98% | 0% | 1.0 | 889.0 | 0% | 12 |
| Jongo Dongo | `jongo_dongo` | difendi | 0% | 100% | 0% | 1.0 | 305.7 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | studia | 0% | 100% | 0% | 1.0 | 890.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | casuale | 0% | 100% | 0% | 1.0 | 444.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | attacca | 0% | 100% | 0% | 1.0 | 890.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | difendi | 0% | 100% | 0% | 1.0 | 411.1 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | studia | 0% | 100% | 0% | 1.0 | 890.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | casuale | 0% | 100% | 0% | 1.0 | 593.2 | 0% | 0 |
| ??? | `l_immortale` | attacca | 0% | 100% | 0% | 1.0 | 26.0 | 0% | 0 |
| ??? | `l_immortale` | difendi | 0% | 100% | 0% | 1.0 | 26.0 | 0% | 0 |
| ??? | `l_immortale` | studia | 0% | 100% | 0% | 1.0 | 26.0 | 0% | 0 |
| ??? | `l_immortale` | casuale | 0% | 100% | 0% | 1.0 | 26.0 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | attacca | 100% | 0% | 0% | 1.0 | 76.9 | 0% | 32 |
| Madre in Lacrime | `madre_in_lacrime` | difendi | 0% | 100% | 0% | 1.0 | 98.6 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | studia | 100% | 0% | 0% | 1.0 | 109.1 | 0% | 32 |
| Madre in Lacrime | `madre_in_lacrime` | casuale | 100% | 0% | 0% | 1.0 | 76.8 | 0% | 32 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | attacca | 0% | 100% | 0% | 1.0 | 890.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | difendi | 0% | 100% | 0% | 1.0 | 890.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | studia | 0% | 100% | 0% | 1.0 | 890.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | casuale | 0% | 100% | 0% | 1.0 | 890.0 | 0% | 0 |
| Marionetta | `marionetta` | attacca | 100% | 0% | 0% | 1.0 | 53.0 | 0% | 32 |
| Marionetta | `marionetta` | difendi | 0% | 100% | 0% | 1.0 | 81.2 | 0% | 0 |
| Marionetta | `marionetta` | studia | 100% | 0% | 0% | 1.0 | 103.3 | 0% | 32 |
| Marionetta | `marionetta` | casuale | 100% | 0% | 0% | 1.0 | 65.1 | 0% | 32 |
| Fomentado | `maschera_vuota` | attacca | 100% | 0% | 0% | 1.0 | 120.4 | 0% | 32 |
| Fomentado | `maschera_vuota` | difendi | 0% | 100% | 0% | 1.0 | 83.2 | 0% | 0 |
| Fomentado | `maschera_vuota` | studia | 100% | 0% | 0% | 1.0 | 157.0 | 0% | 32 |
| Fomentado | `maschera_vuota` | casuale | 100% | 0% | 0% | 1.0 | 102.3 | 0% | 32 |
| Nuvola di Marciume | `nuvola_di_marciume` | attacca | 100% | 0% | 0% | 1.0 | 55.5 | 0% | 36 |
| Nuvola di Marciume | `nuvola_di_marciume` | difendi | 0% | 100% | 0% | 1.0 | 890.0 | 0% | 0 |
| Nuvola di Marciume | `nuvola_di_marciume` | studia | 100% | 0% | 0% | 1.0 | 104.7 | 0% | 36 |
| Nuvola di Marciume | `nuvola_di_marciume` | casuale | 100% | 0% | 0% | 1.0 | 139.0 | 0% | 36 |
| Ombra del passato | `ombra_del_passato` | attacca | 100% | 0% | 0% | 1.0 | 90.6 | 0% | 32 |
| Ombra del passato | `ombra_del_passato` | difendi | 0% | 100% | 0% | 1.0 | 87.5 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | studia | 100% | 0% | 0% | 1.0 | 129.1 | 0% | 32 |
| Ombra del passato | `ombra_del_passato` | casuale | 100% | 0% | 0% | 1.0 | 79.5 | 0% | 32 |
| Emblema dell'oppressione | `operaio_posseduto` | attacca | 100% | 0% | 0% | 1.0 | 56.9 | 0% | 32 |
| Emblema dell'oppressione | `operaio_posseduto` | difendi | 0% | 100% | 0% | 1.0 | 85.6 | 0% | 0 |
| Emblema dell'oppressione | `operaio_posseduto` | studia | 100% | 0% | 0% | 1.0 | 98.1 | 0% | 32 |
| Emblema dell'oppressione | `operaio_posseduto` | casuale | 100% | 0% | 0% | 1.0 | 74.0 | 0% | 32 |
| Operaio Sfruttato | `operaio_sfruttato` | attacca | 100% | 0% | 0% | 1.0 | 186.9 | 0% | 71 |
| Operaio Sfruttato | `operaio_sfruttato` | difendi | 0% | 100% | 0% | 1.0 | 77.9 | 0% | 0 |
| Operaio Sfruttato | `operaio_sfruttato` | studia | 100% | 0% | 0% | 1.0 | 209.4 | 0% | 71 |
| Operaio Sfruttato | `operaio_sfruttato` | casuale | 100% | 0% | 0% | 1.0 | 147.0 | 0% | 71 |
| Orrore di Meridia | `orrore_di_meridia` | attacca | 100% | 0% | 0% | 1.0 | 189.0 | 0% | 71 |
| Orrore di Meridia | `orrore_di_meridia` | difendi | 0% | 100% | 0% | 1.0 | 116.3 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | studia | 100% | 0% | 0% | 1.0 | 258.8 | 0% | 71 |
| Orrore di Meridia | `orrore_di_meridia` | casuale | 43% | 57% | 0% | 1.0 | 154.1 | 0% | 30 |
| Robo Pattuglia | `robo_pattuglia` | attacca | 100% | 0% | 0% | 1.0 | 46.3 | 0% | 39 |
| Robo Pattuglia | `robo_pattuglia` | difendi | 0% | 100% | 0% | 1.0 | 34.0 | 0% | 0 |
| Robo Pattuglia | `robo_pattuglia` | studia | 100% | 0% | 0% | 1.0 | 61.0 | 0% | 39 |
| Robo Pattuglia | `robo_pattuglia` | casuale | 78% | 22% | 0% | 1.0 | 35.5 | 0% | 30 |
| Sacerdote Folle | `sacerdote_folle` | attacca | 100% | 0% | 0% | 1.0 | 88.4 | 0% | 44 |
| Sacerdote Folle | `sacerdote_folle` | difendi | 0% | 100% | 0% | 1.0 | 245.3 | 0% | 0 |
| Sacerdote Folle | `sacerdote_folle` | studia | 100% | 0% | 0% | 1.0 | 216.1 | 0% | 56 |
| Sacerdote Folle | `sacerdote_folle` | casuale | 37% | 63% | 0% | 1.0 | 243.8 | 0% | 25 |
| Sadico | `sadico` | attacca | 100% | 0% | 0% | 1.0 | 81.4 | 0% | 32 |
| Sadico | `sadico` | difendi | 0% | 100% | 0% | 1.0 | 890.0 | 0% | 0 |
| Sadico | `sadico` | studia | 100% | 0% | 0% | 1.0 | 126.7 | 0% | 32 |
| Sadico | `sadico` | casuale | 99% | 1% | 0% | 1.0 | 225.0 | 0% | 32 |
| Slime Infimo | `slime_infimo` | attacca | 100% | 0% | 0% | 1.0 | 54.3 | 0% | 32 |
| Slime Infimo | `slime_infimo` | difendi | 0% | 100% | 0% | 1.0 | 62.2 | 0% | 0 |
| Slime Infimo | `slime_infimo` | studia | 100% | 0% | 0% | 1.0 | 84.0 | 0% | 32 |
| Slime Infimo | `slime_infimo` | casuale | 76% | 24% | 0% | 1.0 | 57.1 | 0% | 24 |
| Stigma | `stigma` | attacca | 100% | 0% | 0% | 1.0 | 77.9 | 0% | 32 |
| Stigma | `stigma` | difendi | 0% | 100% | 0% | 1.0 | 884.4 | 0% | 0 |
| Stigma | `stigma` | studia | 100% | 0% | 0% | 1.0 | 119.8 | 0% | 32 |
| Stigma | `stigma` | casuale | 100% | 0% | 0% | 1.0 | 155.6 | 0% | 32 |
| Tartaruga Innocente | `tartaruga_innocente` | attacca | 100% | 0% | 0% | 1.0 | 0.0 | 0% | 1 |
| Tartaruga Innocente | `tartaruga_innocente` | difendi | 0% | 100% | 0% | 1.0 | 0.0 | 0% | 0 |
| Tartaruga Innocente | `tartaruga_innocente` | studia | 100% | 0% | 0% | 1.0 | 0.0 | 100% | 1 |
| Tartaruga Innocente | `tartaruga_innocente` | casuale | 100% | 0% | 0% | 1.0 | 0.0 | 99% | 1 |
| Un tenero ricordo | `tenero_ricordo` | attacca | 0% | 100% | 0% | 1.0 | 890.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | difendi | 0% | 100% | 0% | 1.0 | 890.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | studia | 0% | 100% | 0% | 1.0 | 890.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | casuale | 0% | 100% | 0% | 1.0 | 890.0 | 0% | 0 |
| Teschio Errante | `teschio_errante` | attacca | 100% | 0% | 0% | 1.0 | 59.4 | 0% | 32 |
| Teschio Errante | `teschio_errante` | difendi | 0% | 100% | 0% | 1.0 | 85.4 | 0% | 0 |
| Teschio Errante | `teschio_errante` | studia | 100% | 0% | 0% | 1.0 | 80.2 | 0% | 32 |
| Teschio Errante | `teschio_errante` | casuale | 100% | 0% | 0% | 1.0 | 47.1 | 0% | 32 |
| Titano Zombie | `titano_zombie` | attacca | 100% | 0% | 0% | 1.0 | 684.3 | 0% | 71 |
| Titano Zombie | `titano_zombie` | difendi | 0% | 100% | 0% | 1.0 | 889.9 | 0% | 0 |
| Titano Zombie | `titano_zombie` | studia | 97% | 3% | 0% | 1.0 | 727.3 | 0% | 69 |
| Titano Zombie | `titano_zombie` | casuale | 0% | 100% | 0% | 1.0 | 890.0 | 0% | 0 |
| Capocantiere | `voce_registrata` | attacca | 100% | 0% | 0% | 1.0 | 76.2 | 0% | 32 |
| Capocantiere | `voce_registrata` | difendi | 0% | 100% | 0% | 1.0 | 73.7 | 0% | 0 |
| Capocantiere | `voce_registrata` | studia | 100% | 0% | 0% | 1.0 | 113.3 | 0% | 32 |
| Capocantiere | `voce_registrata` | casuale | 100% | 0% | 0% | 1.0 | 69.4 | 0% | 32 |
| Volto sulla parete | `volto_sulla_parete` | attacca | 99% | 1% | 0% | 1.0 | 695.3 | 0% | 144 |
| Volto sulla parete | `volto_sulla_parete` | difendi | 0% | 100% | 0% | 1.0 | 890.0 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | studia | 59% | 41% | 0% | 1.0 | 790.0 | 0% | 86 |
| Volto sulla parete | `volto_sulla_parete` | casuale | 0% | 100% | 0% | 1.0 | 890.0 | 0% | 0 |
| Zombie Cittadino | `zombie_cittadino` | attacca | 100% | 0% | 0% | 1.0 | 74.0 | 0% | 32 |
| Zombie Cittadino | `zombie_cittadino` | difendi | 0% | 100% | 0% | 1.0 | 74.7 | 0% | 0 |
| Zombie Cittadino | `zombie_cittadino` | studia | 100% | 0% | 0% | 1.0 | 107.8 | 0% | 32 |
| Zombie Cittadino | `zombie_cittadino` | casuale | 100% | 0% | 0% | 1.0 | 61.6 | 0% | 32 |
| Zombie Mostruoso | `zombie_mostruoso` | attacca | 100% | 0% | 0% | 1.0 | 85.3 | 0% | 32 |
| Zombie Mostruoso | `zombie_mostruoso` | difendi | 0% | 100% | 0% | 1.0 | 87.5 | 0% | 0 |
| Zombie Mostruoso | `zombie_mostruoso` | studia | 100% | 0% | 0% | 1.0 | 120.6 | 0% | 32 |
| Zombie Mostruoso | `zombie_mostruoso` | casuale | 100% | 0% | 0% | 1.0 | 83.4 | 0% | 32 |

## Protagonista di livello 25

| creatura | id | come si gioca | vinte | perse | ∞ | giri | danno | risp. | xp |
|---|---|---|--:|--:|--:|--:|--:|--:|--:|
| Abominio Marcio | `abominio_marcio` | attacca | 100% | 0% | 0% | 1.0 | 439.2 | 0% | 101 |
| Abominio Marcio | `abominio_marcio` | difendi | 0% | 100% | 0% | 1.0 | 1212.6 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | studia | 100% | 0% | 0% | 1.0 | 580.9 | 0% | 101 |
| Abominio Marcio | `abominio_marcio` | casuale | 5% | 95% | 0% | 1.0 | 1193.5 | 0% | 5 |
| Oppresso | `comparsa_di_ruggine` | attacca | 100% | 0% | 0% | 1.0 | 56.2 | 0% | 55 |
| Oppresso | `comparsa_di_ruggine` | difendi | 0% | 100% | 0% | 1.0 | 29.8 | 0% | 0 |
| Oppresso | `comparsa_di_ruggine` | studia | 100% | 0% | 0% | 1.0 | 74.9 | 0% | 55 |
| Oppresso | `comparsa_di_ruggine` | casuale | 100% | 0% | 0% | 1.0 | 29.7 | 0% | 55 |
| Diabolo | `diabolo` | attacca | 100% | 0% | 0% | 1.0 | 91.1 | 0% | 46 |
| Diabolo | `diabolo` | difendi | 0% | 100% | 0% | 1.0 | 84.8 | 0% | 0 |
| Diabolo | `diabolo` | studia | 100% | 0% | 0% | 1.0 | 128.3 | 0% | 46 |
| Diabolo | `diabolo` | casuale | 100% | 0% | 0% | 1.0 | 68.5 | 0% | 46 |
| Il Divoratore | `divoratore` | attacca | 100% | 0% | 0% | 1.0 | 317.6 | 0% | 101 |
| Il Divoratore | `divoratore` | difendi | 0% | 100% | 0% | 1.0 | 167.2 | 0% | 0 |
| Il Divoratore | `divoratore` | studia | 100% | 0% | 0% | 1.0 | 388.9 | 0% | 101 |
| Il Divoratore | `divoratore` | casuale | 99% | 1% | 0% | 1.0 | 207.8 | 0% | 100 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | attacca | 100% | 0% | 0% | 1.0 | 74.9 | 0% | 46 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | difendi | 0% | 100% | 0% | 1.0 | 86.9 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | studia | 100% | 0% | 0% | 1.0 | 109.0 | 0% | 46 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | casuale | 99% | 1% | 0% | 1.0 | 72.9 | 0% | 46 |
| Donna Spinosa | `donna_spinosa` | attacca | 100% | 0% | 0% | 1.0 | 113.7 | 0% | 46 |
| Donna Spinosa | `donna_spinosa` | difendi | 0% | 100% | 0% | 1.0 | 1219.5 | 0% | 0 |
| Donna Spinosa | `donna_spinosa` | studia | 100% | 0% | 0% | 1.0 | 179.5 | 0% | 46 |
| Donna Spinosa | `donna_spinosa` | casuale | 100% | 0% | 0% | 1.0 | 301.5 | 0% | 46 |
| Ferraglia Urlante | `ferraglia_urlante` | attacca | 100% | 0% | 0% | 1.0 | 58.5 | 0% | 55 |
| Ferraglia Urlante | `ferraglia_urlante` | difendi | 0% | 100% | 0% | 1.0 | 35.8 | 0% | 0 |
| Ferraglia Urlante | `ferraglia_urlante` | studia | 100% | 0% | 0% | 1.0 | 68.8 | 0% | 55 |
| Ferraglia Urlante | `ferraglia_urlante` | casuale | 84% | 16% | 0% | 1.0 | 42.1 | 0% | 46 |
| Ghoul | `ghoul` | attacca | 100% | 0% | 0% | 1.0 | 124.5 | 0% | 46 |
| Ghoul | `ghoul` | difendi | 0% | 100% | 0% | 1.0 | 123.0 | 0% | 0 |
| Ghoul | `ghoul` | studia | 100% | 0% | 0% | 1.0 | 183.0 | 0% | 46 |
| Ghoul | `ghoul` | casuale | 100% | 0% | 0% | 1.0 | 129.8 | 0% | 46 |
| El Muy Bonito | `giocoliere` | attacca | 100% | 0% | 0% | 1.0 | 322.2 | 0% | 101 |
| El Muy Bonito | `giocoliere` | difendi | 0% | 100% | 0% | 1.0 | 174.1 | 0% | 0 |
| El Muy Bonito | `giocoliere` | studia | 100% | 0% | 0% | 1.0 | 601.7 | 0% | 101 |
| El Muy Bonito | `giocoliere` | casuale | 81% | 19% | 0% | 1.0 | 797.7 | 0% | 81 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | attacca | 0% | 100% | 0% | 1.0 | 1220.0 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | difendi | 0% | 100% | 0% | 1.0 | 369.0 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | studia | 0% | 100% | 0% | 1.0 | 1220.0 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | casuale | 0% | 100% | 0% | 1.0 | 595.1 | 0% | 0 |
| Goblin Tipico | `goblin_tipico` | attacca | 100% | 0% | 0% | 1.0 | 85.7 | 0% | 46 |
| Goblin Tipico | `goblin_tipico` | difendi | 0% | 100% | 0% | 1.0 | 108.4 | 0% | 0 |
| Goblin Tipico | `goblin_tipico` | studia | 100% | 0% | 0% | 1.0 | 140.7 | 0% | 46 |
| Goblin Tipico | `goblin_tipico` | casuale | 100% | 0% | 0% | 1.0 | 103.0 | 0% | 46 |
| Infetto Rapido | `infetto_rapido` | attacca | 100% | 0% | 0% | 1.0 | 104.3 | 0% | 51 |
| Infetto Rapido | `infetto_rapido` | difendi | 0% | 100% | 0% | 1.0 | 190.5 | 0% | 0 |
| Infetto Rapido | `infetto_rapido` | studia | 100% | 0% | 0% | 1.0 | 173.4 | 0% | 51 |
| Infetto Rapido | `infetto_rapido` | casuale | 100% | 0% | 0% | 1.0 | 115.3 | 0% | 51 |
| L'ultimo spettacolo di Jerah | `jerah` | attacca | 2% | 98% | 0% | 1.0 | 1218.5 | 0% | 13 |
| L'ultimo spettacolo di Jerah | `jerah` | difendi | 0% | 100% | 0% | 1.0 | 704.1 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | studia | 21% | 79% | 0% | 1.0 | 1168.5 | 0% | 136 |
| L'ultimo spettacolo di Jerah | `jerah` | casuale | 0% | 100% | 0% | 1.0 | 827.1 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | attacca | 2% | 98% | 0% | 1.0 | 1219.2 | 0% | 16 |
| Jongo Dongo | `jongo_dongo` | difendi | 0% | 100% | 0% | 1.0 | 416.7 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | studia | 1% | 99% | 0% | 1.0 | 1219.6 | 0% | 11 |
| Jongo Dongo | `jongo_dongo` | casuale | 0% | 100% | 0% | 1.0 | 591.7 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | attacca | 0% | 100% | 0% | 1.0 | 1220.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | difendi | 0% | 100% | 0% | 1.0 | 649.8 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | studia | 0% | 100% | 0% | 1.0 | 1220.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | casuale | 0% | 100% | 0% | 1.0 | 894.3 | 0% | 0 |
| ??? | `l_immortale` | attacca | 0% | 100% | 0% | 1.0 | 24.0 | 0% | 0 |
| ??? | `l_immortale` | difendi | 0% | 100% | 0% | 1.0 | 24.0 | 0% | 0 |
| ??? | `l_immortale` | studia | 0% | 100% | 0% | 1.0 | 24.0 | 0% | 0 |
| ??? | `l_immortale` | casuale | 0% | 100% | 0% | 1.0 | 24.0 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | attacca | 100% | 0% | 0% | 1.0 | 114.4 | 0% | 46 |
| Madre in Lacrime | `madre_in_lacrime` | difendi | 0% | 100% | 0% | 1.0 | 138.3 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | studia | 100% | 0% | 0% | 1.0 | 167.1 | 0% | 46 |
| Madre in Lacrime | `madre_in_lacrime` | casuale | 100% | 0% | 0% | 1.0 | 124.7 | 0% | 46 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | attacca | 0% | 100% | 0% | 1.0 | 1220.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | difendi | 0% | 100% | 0% | 1.0 | 1220.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | studia | 0% | 100% | 0% | 1.0 | 1220.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | casuale | 0% | 100% | 0% | 1.0 | 1220.0 | 0% | 0 |
| Marionetta | `marionetta` | attacca | 100% | 0% | 0% | 1.0 | 99.7 | 0% | 46 |
| Marionetta | `marionetta` | difendi | 0% | 100% | 0% | 1.0 | 106.3 | 0% | 0 |
| Marionetta | `marionetta` | studia | 100% | 0% | 0% | 1.0 | 163.8 | 0% | 46 |
| Marionetta | `marionetta` | casuale | 100% | 0% | 0% | 1.0 | 111.8 | 0% | 46 |
| Fomentado | `maschera_vuota` | attacca | 100% | 0% | 0% | 1.0 | 178.9 | 0% | 46 |
| Fomentado | `maschera_vuota` | difendi | 0% | 100% | 0% | 1.0 | 115.0 | 0% | 0 |
| Fomentado | `maschera_vuota` | studia | 100% | 0% | 0% | 1.0 | 234.9 | 0% | 46 |
| Fomentado | `maschera_vuota` | casuale | 100% | 0% | 0% | 1.0 | 165.6 | 0% | 46 |
| Nuvola di Marciume | `nuvola_di_marciume` | attacca | 100% | 0% | 0% | 1.0 | 81.2 | 0% | 51 |
| Nuvola di Marciume | `nuvola_di_marciume` | difendi | 0% | 100% | 0% | 1.0 | 1220.0 | 0% | 0 |
| Nuvola di Marciume | `nuvola_di_marciume` | studia | 100% | 0% | 0% | 1.0 | 150.0 | 0% | 51 |
| Nuvola di Marciume | `nuvola_di_marciume` | casuale | 100% | 0% | 0% | 1.0 | 167.0 | 0% | 51 |
| Ombra del passato | `ombra_del_passato` | attacca | 100% | 0% | 0% | 1.0 | 126.8 | 0% | 46 |
| Ombra del passato | `ombra_del_passato` | difendi | 0% | 100% | 0% | 1.0 | 121.6 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | studia | 100% | 0% | 0% | 1.0 | 186.1 | 0% | 46 |
| Ombra del passato | `ombra_del_passato` | casuale | 100% | 0% | 0% | 1.0 | 134.3 | 0% | 46 |
| Emblema dell'oppressione | `operaio_posseduto` | attacca | 100% | 0% | 0% | 1.0 | 94.1 | 0% | 46 |
| Emblema dell'oppressione | `operaio_posseduto` | difendi | 0% | 100% | 0% | 1.0 | 118.3 | 0% | 0 |
| Emblema dell'oppressione | `operaio_posseduto` | studia | 100% | 0% | 0% | 1.0 | 156.1 | 0% | 46 |
| Emblema dell'oppressione | `operaio_posseduto` | casuale | 100% | 0% | 0% | 1.0 | 121.1 | 0% | 46 |
| Operaio Sfruttato | `operaio_sfruttato` | attacca | 100% | 0% | 0% | 1.0 | 253.0 | 0% | 101 |
| Operaio Sfruttato | `operaio_sfruttato` | difendi | 0% | 100% | 0% | 1.0 | 103.0 | 0% | 0 |
| Operaio Sfruttato | `operaio_sfruttato` | studia | 100% | 0% | 0% | 1.0 | 312.6 | 0% | 101 |
| Operaio Sfruttato | `operaio_sfruttato` | casuale | 100% | 0% | 0% | 1.0 | 246.9 | 0% | 101 |
| Orrore di Meridia | `orrore_di_meridia` | attacca | 100% | 0% | 0% | 1.0 | 329.2 | 0% | 101 |
| Orrore di Meridia | `orrore_di_meridia` | difendi | 0% | 100% | 0% | 1.0 | 152.8 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | studia | 100% | 0% | 0% | 1.0 | 379.9 | 0% | 101 |
| Orrore di Meridia | `orrore_di_meridia` | casuale | 43% | 57% | 0% | 1.0 | 240.7 | 0% | 44 |
| Robo Pattuglia | `robo_pattuglia` | attacca | 100% | 0% | 0% | 1.0 | 81.4 | 0% | 55 |
| Robo Pattuglia | `robo_pattuglia` | difendi | 0% | 100% | 0% | 1.0 | 36.5 | 0% | 0 |
| Robo Pattuglia | `robo_pattuglia` | studia | 100% | 0% | 0% | 1.0 | 96.5 | 0% | 55 |
| Robo Pattuglia | `robo_pattuglia` | casuale | 70% | 30% | 0% | 1.0 | 45.0 | 0% | 38 |
| Sacerdote Folle | `sacerdote_folle` | attacca | 100% | 0% | 0% | 1.0 | 178.0 | 0% | 69 |
| Sacerdote Folle | `sacerdote_folle` | difendi | 0% | 100% | 0% | 1.0 | 340.0 | 0% | 0 |
| Sacerdote Folle | `sacerdote_folle` | studia | 100% | 0% | 0% | 1.0 | 328.0 | 0% | 79 |
| Sacerdote Folle | `sacerdote_folle` | casuale | 21% | 79% | 0% | 1.0 | 388.6 | 0% | 17 |
| Sadico | `sadico` | attacca | 100% | 0% | 0% | 1.0 | 120.0 | 0% | 46 |
| Sadico | `sadico` | difendi | 0% | 100% | 0% | 1.0 | 1219.2 | 0% | 0 |
| Sadico | `sadico` | studia | 100% | 0% | 0% | 1.0 | 186.9 | 0% | 46 |
| Sadico | `sadico` | casuale | 99% | 1% | 0% | 1.0 | 314.1 | 0% | 46 |
| Slime Infimo | `slime_infimo` | attacca | 100% | 0% | 0% | 1.0 | 82.4 | 0% | 46 |
| Slime Infimo | `slime_infimo` | difendi | 0% | 100% | 0% | 1.0 | 78.7 | 0% | 0 |
| Slime Infimo | `slime_infimo` | studia | 100% | 0% | 0% | 1.0 | 129.0 | 0% | 46 |
| Slime Infimo | `slime_infimo` | casuale | 65% | 35% | 0% | 1.0 | 90.5 | 0% | 30 |
| Stigma | `stigma` | attacca | 100% | 0% | 0% | 1.0 | 115.5 | 0% | 46 |
| Stigma | `stigma` | difendi | 0% | 100% | 0% | 1.0 | 1184.7 | 0% | 0 |
| Stigma | `stigma` | studia | 100% | 0% | 0% | 1.0 | 177.3 | 0% | 46 |
| Stigma | `stigma` | casuale | 99% | 1% | 0% | 1.0 | 243.2 | 0% | 46 |
| Tartaruga Innocente | `tartaruga_innocente` | attacca | 100% | 0% | 0% | 1.0 | 0.0 | 0% | 1 |
| Tartaruga Innocente | `tartaruga_innocente` | difendi | 0% | 100% | 0% | 1.0 | 0.0 | 0% | 0 |
| Tartaruga Innocente | `tartaruga_innocente` | studia | 100% | 0% | 0% | 1.0 | 0.0 | 100% | 1 |
| Tartaruga Innocente | `tartaruga_innocente` | casuale | 100% | 0% | 0% | 1.0 | 0.0 | 97% | 1 |
| Un tenero ricordo | `tenero_ricordo` | attacca | 0% | 100% | 0% | 1.0 | 1220.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | difendi | 0% | 100% | 0% | 1.0 | 1220.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | studia | 0% | 100% | 0% | 1.0 | 1220.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | casuale | 0% | 100% | 0% | 1.0 | 1220.0 | 0% | 0 |
| Teschio Errante | `teschio_errante` | attacca | 100% | 0% | 0% | 1.0 | 87.9 | 0% | 46 |
| Teschio Errante | `teschio_errante` | difendi | 0% | 100% | 0% | 1.0 | 110.7 | 0% | 0 |
| Teschio Errante | `teschio_errante` | studia | 100% | 0% | 0% | 1.0 | 125.3 | 0% | 46 |
| Teschio Errante | `teschio_errante` | casuale | 100% | 0% | 0% | 1.0 | 75.6 | 0% | 46 |
| Titano Zombie | `titano_zombie` | attacca | 98% | 2% | 0% | 1.0 | 979.1 | 0% | 99 |
| Titano Zombie | `titano_zombie` | difendi | 0% | 100% | 0% | 1.0 | 1219.8 | 0% | 0 |
| Titano Zombie | `titano_zombie` | studia | 98% | 2% | 0% | 1.0 | 1026.5 | 0% | 99 |
| Titano Zombie | `titano_zombie` | casuale | 0% | 100% | 0% | 1.0 | 1219.5 | 0% | 0 |
| Capocantiere | `voce_registrata` | attacca | 100% | 0% | 0% | 1.0 | 121.6 | 0% | 46 |
| Capocantiere | `voce_registrata` | difendi | 0% | 100% | 0% | 1.0 | 101.7 | 0% | 0 |
| Capocantiere | `voce_registrata` | studia | 100% | 0% | 0% | 1.0 | 187.4 | 0% | 46 |
| Capocantiere | `voce_registrata` | casuale | 100% | 0% | 0% | 1.0 | 118.4 | 0% | 46 |
| Volto sulla parete | `volto_sulla_parete` | attacca | 58% | 42% | 0% | 1.0 | 1123.9 | 0% | 120 |
| Volto sulla parete | `volto_sulla_parete` | difendi | 0% | 100% | 0% | 1.0 | 1218.3 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | studia | 38% | 62% | 0% | 1.0 | 1160.2 | 0% | 79 |
| Volto sulla parete | `volto_sulla_parete` | casuale | 0% | 100% | 0% | 1.0 | 1220.0 | 0% | 0 |
| Zombie Cittadino | `zombie_cittadino` | attacca | 100% | 0% | 0% | 1.0 | 109.2 | 0% | 46 |
| Zombie Cittadino | `zombie_cittadino` | difendi | 0% | 100% | 0% | 1.0 | 101.8 | 0% | 0 |
| Zombie Cittadino | `zombie_cittadino` | studia | 100% | 0% | 0% | 1.0 | 159.3 | 0% | 46 |
| Zombie Cittadino | `zombie_cittadino` | casuale | 100% | 0% | 0% | 1.0 | 102.3 | 0% | 46 |
| Zombie Mostruoso | `zombie_mostruoso` | attacca | 100% | 0% | 0% | 1.0 | 126.8 | 0% | 46 |
| Zombie Mostruoso | `zombie_mostruoso` | difendi | 0% | 100% | 0% | 1.0 | 121.6 | 0% | 0 |
| Zombie Mostruoso | `zombie_mostruoso` | studia | 100% | 0% | 0% | 1.0 | 184.1 | 0% | 46 |
| Zombie Mostruoso | `zombie_mostruoso` | casuale | 100% | 0% | 0% | 1.0 | 135.7 | 0% | 46 |

