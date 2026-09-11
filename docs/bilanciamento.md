# Bilanciamento (generato, non scrivere qui a mano)

Prodotto da `prove/Simulatore.gd`: **234000 partite** giocate dal motore vero in 2941 secondi.

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
- **giri** — durata media in BATTUTE del protagonista (una battuta = un suo ciclo di ricarica)
- **danno** — punti vita persi in media dal protagonista (ne ha 1220)
- **risp.** — percentuale di partite in cui la creatura e' stata risparmiata

## A che livello ogni scontro diventa giusto

Livello minimo a cui si vince almeno l'80% delle volte andandoci dritto.

| creatura | id | hp | att | livello |
|---|---|--:|--:|--:|
| Abominio Marcio | `abominio_marcio` | 737 | 34 | 12 |
| Oppresso | `comparsa_di_ruggine` | 277 | 10 | 5 |
| Diabolo | `diabolo` | 405 | 26 | 8 |
| Il Divoratore | `divoratore` | 468 | 21 | 8 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | 486 | 32 | 8 |
| Donna Spinosa | `donna_spinosa` | 568 | 38 | 12 |
| Rottami Erranti | `ferraglia_urlante` | 381 | 14 | 8 |
| Ghoul | `ghoul` | 366 | 23 | 5 |
| El Muy Bonito | `giocoliere` | 340 | 15 | 5 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | 1125 | 25 | **mai** |
| Goblin Tipico | `goblin_tipico` | 86 | 6 | 1 |
| Golem errante di rottami | `golem_errante` | 539 | 25 | 8 |
| Infetto Rapido | `infetto_rapido` | 94 | 7 | 2 |
| L'ultimo spettacolo di Jerah | `jerah` | 2710 | 74 | **mai** |
| Jongo Dongo | `jongo_dongo` | 1857 | 48 | **mai** |
| Jongo Dongo | `jongo_dongo_risorto` | 2147 | 56 | **mai** |
| ??? | `l_immortale` | 120 | 5 | **mai** |
| Madre in Lacrime | `madre_in_lacrime` | 366 | 23 | 5 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | 439 | 14 | **mai** |
| Marionetta | `marionetta` | 568 | 38 | 12 |
| Fomentado | `maschera_vuota` | 164 | 10 | 2 |
| Nuvola di Marciume | `nuvola_di_marciume` | 94 | 7 | 2 |
| Ombra del passato | `ombra_del_passato` | 607 | 41 | 12 |
| Emblema dell'oppressione | `operaio_posseduto` | 290 | 16 | 5 |
| Operaio Sfruttato | `operaio_sfruttato` | 404 | 18 | 5 |
| Orrore di Meridia | `orrore_di_meridia` | 404 | 18 | 8 |
| Robo Pattuglia | `robo_pattuglia` | 277 | 10 | 5 |
| Sacerdote Folle | `sacerdote_folle` | 486 | 32 | 12 |
| Sadico | `sadico` | 405 | 26 | 8 |
| Slime Infimo | `slime_infimo` | 86 | 6 | 1 |
| Stigma | `stigma` | 405 | 26 | 8 |
| Tartaruga Innocente | `tartaruga_innocente` | 555 | 0 | 12 |
| Un tenero ricordo | `tenero_ricordo` | 6660 | 27 | **mai** |
| Teschio Errante | `teschio_errante` | 366 | 23 | 5 |
| Titano Zombie | `titano_zombie` | 737 | 34 | 12 |
| Capocantiere | `voce_registrata` | 207 | 13 | 3 |
| Volto sulla parete | `volto_sulla_parete` | 1733 | 57 | **mai** |
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
| Emblema dell'oppressione | 5 | comune | hp 290, attacco 16, difesa 5 | Bru ha chiesto 290/16/5; la curva del ruolo comune a livello 5 da' 245/15/6. Alzarlo di livello lo terrebbe sulla curva ma sposterebbe anche l'xp e il posto nella progressione, e il ruolo particolare a livello 5 darebbe 404/18/8: troppo. Scritte a mano e' l'unica delle tre strade che da' i suoi numeri senza cambiarne nessun altro. |
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
| Abominio Marcio | `abominio_marcio` | si_cura | 0% | 100% | 0% | 1.1 | 100.0 | 0% | 0 |
| Oppresso | `comparsa_di_ruggine` | attacca | 12% | 88% | 0% | 12.6 | 94.3 | 0% | 2 |
| Oppresso | `comparsa_di_ruggine` | difendi | 0% | 27% | 73% | 58.4 | 88.6 | 0% | 0 |
| Oppresso | `comparsa_di_ruggine` | studia | 7% | 93% | 0% | 12.8 | 97.1 | 0% | 1 |
| Oppresso | `comparsa_di_ruggine` | casuale | 13% | 79% | 7% | 36.5 | 95.5 | 0% | 2 |
| Oppresso | `comparsa_di_ruggine` | si_cura | 25% | 75% | 0% | 36.8 | 82.7 | 0% | 4 |
| Diabolo | `diabolo` | attacca | 1% | 99% | 0% | 1.5 | 99.1 | 0% | 0 |
| Diabolo | `diabolo` | difendi | 0% | 100% | 0% | 1.6 | 100.0 | 0% | 0 |
| Diabolo | `diabolo` | studia | 0% | 100% | 0% | 1.4 | 100.0 | 0% | 0 |
| Diabolo | `diabolo` | casuale | 0% | 100% | 0% | 1.5 | 100.0 | 0% | 0 |
| Diabolo | `diabolo` | si_cura | 2% | 98% | 0% | 1.8 | 98.7 | 0% | 1 |
| Il Divoratore | `divoratore` | attacca | 0% | 100% | 0% | 2.0 | 100.0 | 0% | 0 |
| Il Divoratore | `divoratore` | difendi | 0% | 100% | 0% | 2.2 | 100.0 | 0% | 0 |
| Il Divoratore | `divoratore` | studia | 0% | 100% | 0% | 2.0 | 100.0 | 0% | 0 |
| Il Divoratore | `divoratore` | casuale | 0% | 100% | 0% | 2.1 | 100.0 | 0% | 0 |
| Il Divoratore | `divoratore` | si_cura | 0% | 100% | 0% | 6.5 | 100.0 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | attacca | 2% | 98% | 0% | 1.0 | 99.3 | 0% | 1 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | difendi | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | studia | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | casuale | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | si_cura | 0% | 100% | 0% | 3.3 | 100.0 | 0% | 0 |
| Donna Spinosa | `donna_spinosa` | attacca | 1% | 99% | 0% | 1.0 | 99.9 | 0% | 0 |
| Donna Spinosa | `donna_spinosa` | difendi | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Donna Spinosa | `donna_spinosa` | studia | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Donna Spinosa | `donna_spinosa` | casuale | 1% | 99% | 0% | 1.0 | 99.9 | 0% | 0 |
| Donna Spinosa | `donna_spinosa` | si_cura | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Rottami Erranti | `ferraglia_urlante` | attacca | 0% | 100% | 0% | 7.3 | 100.0 | 0% | 0 |
| Rottami Erranti | `ferraglia_urlante` | difendi | 0% | 100% | 0% | 17.5 | 100.0 | 0% | 0 |
| Rottami Erranti | `ferraglia_urlante` | studia | 0% | 100% | 0% | 7.2 | 100.0 | 0% | 0 |
| Rottami Erranti | `ferraglia_urlante` | casuale | 0% | 100% | 0% | 8.6 | 100.0 | 0% | 0 |
| Rottami Erranti | `ferraglia_urlante` | si_cura | 0% | 100% | 0% | 22.8 | 100.0 | 0% | 0 |
| Ghoul | `ghoul` | attacca | 3% | 97% | 0% | 2.0 | 98.5 | 0% | 1 |
| Ghoul | `ghoul` | difendi | 0% | 100% | 0% | 2.0 | 100.0 | 0% | 0 |
| Ghoul | `ghoul` | studia | 0% | 100% | 0% | 2.0 | 100.0 | 0% | 0 |
| Ghoul | `ghoul` | casuale | 0% | 100% | 0% | 2.0 | 100.0 | 0% | 0 |
| Ghoul | `ghoul` | si_cura | 3% | 97% | 0% | 4.8 | 98.0 | 0% | 1 |
| El Muy Bonito | `giocoliere` | attacca | 0% | 100% | 0% | 2.6 | 100.0 | 0% | 0 |
| El Muy Bonito | `giocoliere` | difendi | 0% | 100% | 0% | 3.3 | 100.0 | 0% | 0 |
| El Muy Bonito | `giocoliere` | studia | 0% | 100% | 0% | 2.4 | 100.0 | 0% | 0 |
| El Muy Bonito | `giocoliere` | casuale | 0% | 100% | 0% | 2.8 | 100.0 | 0% | 0 |
| El Muy Bonito | `giocoliere` | si_cura | 0% | 100% | 0% | 4.8 | 100.0 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | attacca | 0% | 100% | 0% | 2.0 | 100.0 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | difendi | 0% | 100% | 0% | 2.2 | 100.0 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | studia | 0% | 100% | 0% | 2.0 | 100.0 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | casuale | 0% | 100% | 0% | 2.1 | 100.0 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | si_cura | 0% | 100% | 0% | 4.3 | 100.0 | 0% | 0 |
| Goblin Tipico | `goblin_tipico` | attacca | 100% | 0% | 0% | 7.0 | 23.3 | 0% | 2 |
| Goblin Tipico | `goblin_tipico` | difendi | 0% | 0% | 100% | 60.0 | 51.8 | 0% | 0 |
| Goblin Tipico | `goblin_tipico` | studia | 100% | 0% | 0% | 10.1 | 36.9 | 0% | 2 |
| Goblin Tipico | `goblin_tipico` | casuale | 72% | 21% | 7% | 33.6 | 64.0 | 0% | 1 |
| Goblin Tipico | `goblin_tipico` | si_cura | 100% | 0% | 0% | 7.0 | 23.3 | 0% | 2 |
| Golem errante di rottami | `golem_errante` | attacca | 0% | 100% | 0% | 2.0 | 100.0 | 0% | 0 |
| Golem errante di rottami | `golem_errante` | difendi | 0% | 100% | 0% | 2.1 | 100.0 | 0% | 0 |
| Golem errante di rottami | `golem_errante` | studia | 0% | 100% | 0% | 2.0 | 100.0 | 0% | 0 |
| Golem errante di rottami | `golem_errante` | casuale | 0% | 100% | 0% | 2.1 | 100.0 | 0% | 0 |
| Golem errante di rottami | `golem_errante` | si_cura | 0% | 100% | 0% | 5.4 | 100.0 | 0% | 0 |
| Infetto Rapido | `infetto_rapido` | attacca | 28% | 72% | 0% | 5.9 | 95.6 | 0% | 2 |
| Infetto Rapido | `infetto_rapido` | difendi | 0% | 100% | 0% | 27.1 | 100.0 | 0% | 0 |
| Infetto Rapido | `infetto_rapido` | studia | 3% | 97% | 0% | 6.6 | 99.2 | 0% | 0 |
| Infetto Rapido | `infetto_rapido` | casuale | 29% | 71% | 0% | 13.9 | 94.4 | 0% | 2 |
| Infetto Rapido | `infetto_rapido` | si_cura | 100% | 0% | 0% | 7.9 | 36.4 | 0% | 6 |
| L'ultimo spettacolo di Jerah | `jerah` | attacca | 0% | 100% | 0% | 0.7 | 100.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | difendi | 0% | 100% | 0% | 0.7 | 100.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | studia | 0% | 100% | 0% | 0.7 | 100.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | casuale | 0% | 100% | 0% | 0.7 | 100.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | si_cura | 0% | 100% | 0% | 0.8 | 100.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | attacca | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | difendi | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | studia | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | casuale | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | si_cura | 0% | 100% | 0% | 1.1 | 100.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | attacca | 0% | 100% | 0% | 0.1 | 100.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | difendi | 0% | 100% | 0% | 0.1 | 100.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | studia | 0% | 100% | 0% | 0.1 | 100.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | casuale | 0% | 100% | 0% | 0.1 | 100.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | si_cura | 0% | 100% | 0% | 0.1 | 100.0 | 0% | 0 |
| ??? | `l_immortale` | attacca | 0% | 100% | 0% | 7.0 | 100.0 | 0% | 0 |
| ??? | `l_immortale` | difendi | 0% | 100% | 0% | 35.8 | 100.0 | 0% | 0 |
| ??? | `l_immortale` | studia | 0% | 100% | 0% | 8.0 | 100.0 | 0% | 0 |
| ??? | `l_immortale` | casuale | 0% | 100% | 0% | 22.3 | 100.0 | 0% | 0 |
| ??? | `l_immortale` | si_cura | 0% | 100% | 0% | 26.8 | 100.0 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | attacca | 3% | 97% | 0% | 2.0 | 98.5 | 0% | 1 |
| Madre in Lacrime | `madre_in_lacrime` | difendi | 0% | 100% | 0% | 2.2 | 100.0 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | studia | 0% | 100% | 0% | 2.0 | 100.0 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | casuale | 0% | 100% | 0% | 2.1 | 100.0 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | si_cura | 4% | 96% | 0% | 5.6 | 97.5 | 0% | 1 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | attacca | 0% | 100% | 0% | 4.0 | 100.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | difendi | 0% | 100% | 0% | 4.0 | 100.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | studia | 0% | 100% | 0% | 4.0 | 100.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | casuale | 0% | 100% | 0% | 4.0 | 100.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | si_cura | 0% | 100% | 0% | 4.0 | 100.0 | 0% | 0 |
| Marionetta | `marionetta` | attacca | 0% | 100% | 0% | 0.9 | 100.0 | 0% | 0 |
| Marionetta | `marionetta` | difendi | 0% | 100% | 0% | 0.9 | 100.0 | 0% | 0 |
| Marionetta | `marionetta` | studia | 0% | 100% | 0% | 0.9 | 100.0 | 0% | 0 |
| Marionetta | `marionetta` | casuale | 0% | 100% | 0% | 0.9 | 100.0 | 0% | 0 |
| Marionetta | `marionetta` | si_cura | 0% | 100% | 0% | 1.2 | 100.0 | 0% | 0 |
| Fomentado | `maschera_vuota` | attacca | 43% | 57% | 0% | 6.9 | 94.2 | 0% | 4 |
| Fomentado | `maschera_vuota` | difendi | 79% | 21% | 0% | 20.9 | 88.7 | 0% | 7 |
| Fomentado | `maschera_vuota` | studia | 5% | 95% | 0% | 8.0 | 98.3 | 0% | 0 |
| Fomentado | `maschera_vuota` | casuale | 23% | 77% | 0% | 11.1 | 95.5 | 0% | 2 |
| Fomentado | `maschera_vuota` | si_cura | 100% | 0% | 0% | 8.0 | 37.0 | 0% | 9 |
| Nuvola di Marciume | `nuvola_di_marciume` | attacca | 75% | 25% | 0% | 6.8 | 89.3 | 0% | 4 |
| Nuvola di Marciume | `nuvola_di_marciume` | difendi | 0% | 100% | 0% | 21.7 | 100.0 | 0% | 0 |
| Nuvola di Marciume | `nuvola_di_marciume` | studia | 3% | 97% | 0% | 7.6 | 99.5 | 0% | 0 |
| Nuvola di Marciume | `nuvola_di_marciume` | casuale | 9% | 91% | 0% | 13.7 | 97.4 | 0% | 1 |
| Nuvola di Marciume | `nuvola_di_marciume` | si_cura | 100% | 0% | 0% | 10.5 | 33.7 | 0% | 6 |
| Ombra del passato | `ombra_del_passato` | attacca | 1% | 99% | 0% | 0.9 | 100.0 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | difendi | 0% | 100% | 0% | 0.9 | 100.0 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | studia | 0% | 100% | 0% | 0.9 | 100.0 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | casuale | 1% | 99% | 0% | 0.9 | 100.0 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | si_cura | 0% | 100% | 0% | 0.9 | 100.0 | 0% | 0 |
| Emblema dell'oppressione | `operaio_posseduto` | attacca | 1% | 99% | 0% | 3.2 | 99.2 | 0% | 0 |
| Emblema dell'oppressione | `operaio_posseduto` | difendi | 0% | 100% | 0% | 6.2 | 100.0 | 0% | 0 |
| Emblema dell'oppressione | `operaio_posseduto` | studia | 0% | 100% | 0% | 3.3 | 100.0 | 0% | 0 |
| Emblema dell'oppressione | `operaio_posseduto` | casuale | 1% | 99% | 0% | 4.0 | 99.9 | 0% | 0 |
| Emblema dell'oppressione | `operaio_posseduto` | si_cura | 5% | 95% | 0% | 13.0 | 97.0 | 0% | 1 |
| Operaio Sfruttato | `operaio_sfruttato` | attacca | 0% | 100% | 0% | 4.1 | 100.0 | 0% | 0 |
| Operaio Sfruttato | `operaio_sfruttato` | difendi | 0% | 100% | 0% | 6.1 | 100.0 | 0% | 0 |
| Operaio Sfruttato | `operaio_sfruttato` | studia | 0% | 100% | 0% | 4.0 | 100.0 | 0% | 0 |
| Operaio Sfruttato | `operaio_sfruttato` | casuale | 0% | 100% | 0% | 4.5 | 100.0 | 0% | 0 |
| Operaio Sfruttato | `operaio_sfruttato` | si_cura | 0% | 100% | 0% | 16.4 | 100.0 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | attacca | 0% | 100% | 0% | 3.6 | 100.0 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | difendi | 0% | 100% | 0% | 5.1 | 100.0 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | studia | 0% | 100% | 0% | 3.7 | 100.0 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | casuale | 0% | 100% | 0% | 4.1 | 100.0 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | si_cura | 0% | 100% | 0% | 13.8 | 100.0 | 0% | 0 |
| Robo Pattuglia | `robo_pattuglia` | attacca | 7% | 93% | 0% | 10.3 | 96.8 | 0% | 1 |
| Robo Pattuglia | `robo_pattuglia` | difendi | 0% | 80% | 20% | 52.4 | 98.6 | 0% | 0 |
| Robo Pattuglia | `robo_pattuglia` | studia | 5% | 95% | 0% | 10.6 | 98.6 | 0% | 1 |
| Robo Pattuglia | `robo_pattuglia` | casuale | 9% | 89% | 1% | 27.1 | 97.2 | 0% | 1 |
| Robo Pattuglia | `robo_pattuglia` | si_cura | 24% | 76% | 0% | 31.5 | 85.3 | 0% | 4 |
| Sacerdote Folle | `sacerdote_folle` | attacca | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Sacerdote Folle | `sacerdote_folle` | difendi | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Sacerdote Folle | `sacerdote_folle` | studia | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Sacerdote Folle | `sacerdote_folle` | casuale | 1% | 99% | 0% | 1.0 | 99.8 | 0% | 0 |
| Sacerdote Folle | `sacerdote_folle` | si_cura | 0% | 100% | 0% | 1.3 | 100.0 | 0% | 0 |
| Sadico | `sadico` | attacca | 2% | 98% | 0% | 1.0 | 98.6 | 0% | 1 |
| Sadico | `sadico` | difendi | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Sadico | `sadico` | studia | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Sadico | `sadico` | casuale | 0% | 100% | 0% | 1.0 | 100.0 | 0% | 0 |
| Sadico | `sadico` | si_cura | 1% | 99% | 0% | 1.0 | 99.5 | 0% | 0 |
| Slime Infimo | `slime_infimo` | attacca | 100% | 0% | 0% | 7.7 | 35.5 | 0% | 2 |
| Slime Infimo | `slime_infimo` | difendi | 0% | 94% | 6% | 48.7 | 99.4 | 0% | 0 |
| Slime Infimo | `slime_infimo` | studia | 79% | 21% | 0% | 10.8 | 60.6 | 0% | 2 |
| Slime Infimo | `slime_infimo` | casuale | 76% | 23% | 1% | 31.9 | 73.3 | 0% | 2 |
| Slime Infimo | `slime_infimo` | si_cura | 100% | 0% | 0% | 8.1 | 28.4 | 0% | 2 |
| Stigma | `stigma` | attacca | 1% | 99% | 0% | 1.4 | 99.1 | 0% | 0 |
| Stigma | `stigma` | difendi | 0% | 100% | 0% | 1.6 | 100.0 | 0% | 0 |
| Stigma | `stigma` | studia | 0% | 100% | 0% | 1.3 | 100.0 | 0% | 0 |
| Stigma | `stigma` | casuale | 1% | 99% | 0% | 1.4 | 99.9 | 0% | 0 |
| Stigma | `stigma` | si_cura | 1% | 99% | 0% | 1.7 | 99.1 | 0% | 0 |
| Tartaruga Innocente | `tartaruga_innocente` | attacca | 0% | 0% | 100% | 60.0 | 0.0 | 0% | 0 |
| Tartaruga Innocente | `tartaruga_innocente` | difendi | 0% | 0% | 100% | 60.0 | 0.0 | 0% | 0 |
| Tartaruga Innocente | `tartaruga_innocente` | studia | 100% | 0% | 0% | 2.0 | 0.0 | 100% | 3 |
| Tartaruga Innocente | `tartaruga_innocente` | casuale | 0% | 0% | 100% | 60.0 | 0.0 | 0% | 0 |
| Tartaruga Innocente | `tartaruga_innocente` | si_cura | 0% | 0% | 100% | 60.0 | 0.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | attacca | 0% | 100% | 0% | 1.1 | 100.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | difendi | 0% | 100% | 0% | 1.1 | 100.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | studia | 0% | 100% | 0% | 1.1 | 100.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | casuale | 0% | 100% | 0% | 1.1 | 100.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | si_cura | 0% | 100% | 0% | 1.2 | 100.0 | 0% | 0 |
| Teschio Errante | `teschio_errante` | attacca | 2% | 98% | 0% | 2.2 | 98.6 | 0% | 1 |
| Teschio Errante | `teschio_errante` | difendi | 0% | 100% | 0% | 2.6 | 100.0 | 0% | 0 |
| Teschio Errante | `teschio_errante` | studia | 0% | 100% | 0% | 2.2 | 100.0 | 0% | 0 |
| Teschio Errante | `teschio_errante` | casuale | 0% | 100% | 0% | 2.3 | 100.0 | 0% | 0 |
| Teschio Errante | `teschio_errante` | si_cura | 5% | 95% | 0% | 5.8 | 97.2 | 0% | 1 |
| Titano Zombie | `titano_zombie` | attacca | 0% | 100% | 0% | 1.1 | 100.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | difendi | 0% | 100% | 0% | 1.1 | 100.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | studia | 0% | 100% | 0% | 1.1 | 100.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | casuale | 0% | 100% | 0% | 1.1 | 100.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | si_cura | 0% | 100% | 0% | 2.7 | 100.0 | 0% | 0 |
| Capocantiere | `voce_registrata` | attacca | 5% | 95% | 0% | 5.6 | 97.9 | 0% | 1 |
| Capocantiere | `voce_registrata` | difendi | 0% | 100% | 0% | 11.3 | 100.0 | 0% | 0 |
| Capocantiere | `voce_registrata` | studia | 1% | 99% | 0% | 5.6 | 99.8 | 0% | 0 |
| Capocantiere | `voce_registrata` | casuale | 1% | 99% | 0% | 6.4 | 99.5 | 0% | 0 |
| Capocantiere | `voce_registrata` | si_cura | 10% | 90% | 0% | 18.1 | 94.1 | 0% | 1 |
| Volto sulla parete | `volto_sulla_parete` | attacca | 0% | 100% | 0% | 0.2 | 100.0 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | difendi | 0% | 100% | 0% | 0.2 | 100.0 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | studia | 0% | 100% | 0% | 0.2 | 100.0 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | casuale | 0% | 100% | 0% | 0.2 | 100.0 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | si_cura | 0% | 100% | 0% | 0.2 | 100.0 | 0% | 0 |
| Zombie Cittadino | `zombie_cittadino` | attacca | 100% | 0% | 0% | 9.2 | 50.7 | 0% | 5 |
| Zombie Cittadino | `zombie_cittadino` | difendi | 0% | 0% | 100% | 60.0 | 53.5 | 0% | 0 |
| Zombie Cittadino | `zombie_cittadino` | studia | 100% | 0% | 0% | 12.1 | 64.3 | 0% | 5 |
| Zombie Cittadino | `zombie_cittadino` | casuale | 99% | 1% | 0% | 28.3 | 51.3 | 0% | 5 |
| Zombie Cittadino | `zombie_cittadino` | si_cura | 100% | 0% | 0% | 9.6 | 29.2 | 0% | 5 |
| Zombie Mostruoso | `zombie_mostruoso` | attacca | 7% | 93% | 0% | 9.4 | 97.2 | 0% | 1 |
| Zombie Mostruoso | `zombie_mostruoso` | difendi | 0% | 100% | 0% | 35.8 | 100.0 | 0% | 0 |
| Zombie Mostruoso | `zombie_mostruoso` | studia | 3% | 97% | 0% | 10.1 | 99.0 | 0% | 0 |
| Zombie Mostruoso | `zombie_mostruoso` | casuale | 3% | 97% | 0% | 18.0 | 99.3 | 0% | 0 |
| Zombie Mostruoso | `zombie_mostruoso` | si_cura | 100% | 0% | 0% | 15.2 | 27.5 | 0% | 9 |

## Protagonista di livello 2

| creatura | id | come si gioca | vinte | perse | ∞ | giri | danno | risp. | xp |
|---|---|---|--:|--:|--:|--:|--:|--:|--:|
| Abominio Marcio | `abominio_marcio` | attacca | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | difendi | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | studia | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | casuale | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | si_cura | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| Oppresso | `comparsa_di_ruggine` | attacca | 24% | 76% | 0% | 19.9 | 128.7 | 0% | 4 |
| Oppresso | `comparsa_di_ruggine` | difendi | 0% | 0% | 100% | 60.0 | 70.6 | 0% | 0 |
| Oppresso | `comparsa_di_ruggine` | studia | 19% | 81% | 0% | 20.9 | 134.5 | 0% | 3 |
| Oppresso | `comparsa_di_ruggine` | casuale | 23% | 2% | 75% | 54.0 | 90.0 | 0% | 4 |
| Oppresso | `comparsa_di_ruggine` | si_cura | 44% | 1% | 55% | 46.1 | 77.3 | 0% | 7 |
| Diabolo | `diabolo` | attacca | 3% | 97% | 0% | 2.5 | 143.3 | 0% | 1 |
| Diabolo | `diabolo` | difendi | 1% | 99% | 0% | 3.0 | 144.8 | 0% | 0 |
| Diabolo | `diabolo` | studia | 0% | 100% | 0% | 2.6 | 145.0 | 0% | 0 |
| Diabolo | `diabolo` | casuale | 0% | 100% | 0% | 2.7 | 145.0 | 0% | 0 |
| Diabolo | `diabolo` | si_cura | 4% | 96% | 0% | 6.1 | 142.8 | 0% | 1 |
| Il Divoratore | `divoratore` | attacca | 0% | 100% | 0% | 3.1 | 145.0 | 0% | 0 |
| Il Divoratore | `divoratore` | difendi | 0% | 100% | 0% | 4.4 | 145.0 | 0% | 0 |
| Il Divoratore | `divoratore` | studia | 0% | 100% | 0% | 3.1 | 145.0 | 0% | 0 |
| Il Divoratore | `divoratore` | casuale | 0% | 100% | 0% | 3.5 | 145.0 | 0% | 0 |
| Il Divoratore | `divoratore` | si_cura | 0% | 100% | 0% | 11.5 | 145.0 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | attacca | 2% | 98% | 0% | 1.0 | 143.4 | 0% | 1 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | difendi | 0% | 100% | 0% | 1.7 | 145.0 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | studia | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | casuale | 0% | 100% | 0% | 1.3 | 145.0 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | si_cura | 2% | 98% | 0% | 1.0 | 143.4 | 0% | 1 |
| Donna Spinosa | `donna_spinosa` | attacca | 1% | 99% | 0% | 1.0 | 144.6 | 0% | 0 |
| Donna Spinosa | `donna_spinosa` | difendi | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| Donna Spinosa | `donna_spinosa` | studia | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| Donna Spinosa | `donna_spinosa` | casuale | 1% | 99% | 0% | 1.0 | 144.6 | 0% | 0 |
| Donna Spinosa | `donna_spinosa` | si_cura | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| Rottami Erranti | `ferraglia_urlante` | attacca | 0% | 100% | 0% | 11.5 | 145.0 | 0% | 0 |
| Rottami Erranti | `ferraglia_urlante` | difendi | 0% | 98% | 2% | 40.2 | 144.9 | 0% | 0 |
| Rottami Erranti | `ferraglia_urlante` | studia | 0% | 100% | 0% | 11.4 | 145.0 | 0% | 0 |
| Rottami Erranti | `ferraglia_urlante` | casuale | 0% | 100% | 0% | 20.5 | 145.0 | 0% | 0 |
| Rottami Erranti | `ferraglia_urlante` | si_cura | 0% | 100% | 0% | 36.1 | 145.0 | 0% | 0 |
| Ghoul | `ghoul` | attacca | 3% | 97% | 0% | 2.9 | 142.2 | 0% | 1 |
| Ghoul | `ghoul` | difendi | 0% | 100% | 0% | 3.6 | 145.0 | 0% | 0 |
| Ghoul | `ghoul` | studia | 0% | 100% | 0% | 2.9 | 145.0 | 0% | 0 |
| Ghoul | `ghoul` | casuale | 1% | 99% | 0% | 3.1 | 144.9 | 0% | 0 |
| Ghoul | `ghoul` | si_cura | 7% | 93% | 0% | 10.3 | 139.7 | 0% | 2 |
| El Muy Bonito | `giocoliere` | attacca | 0% | 100% | 0% | 3.7 | 145.0 | 0% | 0 |
| El Muy Bonito | `giocoliere` | difendi | 0% | 100% | 0% | 8.7 | 145.0 | 0% | 0 |
| El Muy Bonito | `giocoliere` | studia | 0% | 100% | 0% | 3.1 | 145.0 | 0% | 0 |
| El Muy Bonito | `giocoliere` | casuale | 0% | 100% | 0% | 4.2 | 145.0 | 0% | 0 |
| El Muy Bonito | `giocoliere` | si_cura | 0% | 100% | 0% | 10.3 | 145.0 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | attacca | 0% | 100% | 0% | 3.0 | 145.0 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | difendi | 0% | 100% | 0% | 3.8 | 145.0 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | studia | 0% | 100% | 0% | 3.0 | 145.0 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | casuale | 0% | 100% | 0% | 3.2 | 145.0 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | si_cura | 0% | 100% | 0% | 9.4 | 145.0 | 0% | 0 |
| Goblin Tipico | `goblin_tipico` | attacca | 100% | 0% | 0% | 4.7 | 11.3 | 0% | 2 |
| Goblin Tipico | `goblin_tipico` | difendi | 0% | 0% | 100% | 60.0 | 44.5 | 0% | 0 |
| Goblin Tipico | `goblin_tipico` | studia | 100% | 0% | 0% | 7.7 | 22.9 | 0% | 2 |
| Goblin Tipico | `goblin_tipico` | casuale | 99% | 0% | 1% | 15.7 | 22.3 | 0% | 2 |
| Goblin Tipico | `goblin_tipico` | si_cura | 100% | 0% | 0% | 4.7 | 11.3 | 0% | 2 |
| Golem errante di rottami | `golem_errante` | attacca | 0% | 100% | 0% | 2.9 | 145.0 | 0% | 0 |
| Golem errante di rottami | `golem_errante` | difendi | 0% | 100% | 0% | 3.5 | 145.0 | 0% | 0 |
| Golem errante di rottami | `golem_errante` | studia | 0% | 100% | 0% | 2.9 | 145.0 | 0% | 0 |
| Golem errante di rottami | `golem_errante` | casuale | 0% | 100% | 0% | 3.2 | 145.0 | 0% | 0 |
| Golem errante di rottami | `golem_errante` | si_cura | 0% | 100% | 0% | 10.0 | 145.0 | 0% | 0 |
| Infetto Rapido | `infetto_rapido` | attacca | 100% | 0% | 0% | 4.7 | 60.2 | 0% | 6 |
| Infetto Rapido | `infetto_rapido` | difendi | 0% | 100% | 0% | 45.8 | 145.0 | 0% | 0 |
| Infetto Rapido | `infetto_rapido` | studia | 100% | 0% | 0% | 7.7 | 96.8 | 0% | 6 |
| Infetto Rapido | `infetto_rapido` | casuale | 95% | 5% | 0% | 13.7 | 74.2 | 0% | 6 |
| Infetto Rapido | `infetto_rapido` | si_cura | 100% | 0% | 0% | 4.7 | 60.2 | 0% | 6 |
| L'ultimo spettacolo di Jerah | `jerah` | attacca | 0% | 100% | 0% | 1.1 | 145.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | difendi | 0% | 100% | 0% | 1.1 | 145.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | studia | 0% | 100% | 0% | 1.1 | 145.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | casuale | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | si_cura | 0% | 100% | 0% | 1.3 | 145.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | attacca | 0% | 100% | 0% | 1.2 | 145.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | difendi | 0% | 100% | 0% | 1.3 | 145.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | studia | 0% | 100% | 0% | 1.2 | 145.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | casuale | 0% | 100% | 0% | 1.2 | 145.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | si_cura | 0% | 100% | 0% | 1.5 | 145.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | attacca | 0% | 100% | 0% | 0.8 | 145.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | difendi | 0% | 100% | 0% | 0.8 | 145.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | studia | 0% | 100% | 0% | 0.8 | 145.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | casuale | 0% | 100% | 0% | 0.8 | 145.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | si_cura | 0% | 100% | 0% | 0.8 | 145.0 | 0% | 0 |
| ??? | `l_immortale` | attacca | 0% | 100% | 0% | 12.9 | 145.0 | 0% | 0 |
| ??? | `l_immortale` | difendi | 0% | 32% | 68% | 59.4 | 143.1 | 0% | 0 |
| ??? | `l_immortale` | studia | 0% | 100% | 0% | 13.2 | 145.0 | 0% | 0 |
| ??? | `l_immortale` | casuale | 0% | 97% | 3% | 47.8 | 145.0 | 0% | 0 |
| ??? | `l_immortale` | si_cura | 0% | 100% | 0% | 43.4 | 145.0 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | attacca | 3% | 97% | 0% | 3.0 | 142.3 | 0% | 1 |
| Madre in Lacrime | `madre_in_lacrime` | difendi | 0% | 100% | 0% | 3.9 | 145.0 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | studia | 0% | 100% | 0% | 3.1 | 145.0 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | casuale | 0% | 100% | 0% | 3.3 | 145.0 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | si_cura | 7% | 93% | 0% | 10.4 | 139.8 | 0% | 2 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | attacca | 0% | 100% | 0% | 4.0 | 145.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | difendi | 0% | 100% | 0% | 4.0 | 145.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | studia | 0% | 100% | 0% | 4.0 | 145.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | casuale | 0% | 100% | 0% | 4.0 | 145.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | si_cura | 0% | 100% | 0% | 4.0 | 145.0 | 0% | 0 |
| Marionetta | `marionetta` | attacca | 1% | 99% | 0% | 1.1 | 144.7 | 0% | 0 |
| Marionetta | `marionetta` | difendi | 0% | 100% | 0% | 1.1 | 145.0 | 0% | 0 |
| Marionetta | `marionetta` | studia | 0% | 100% | 0% | 1.1 | 145.0 | 0% | 0 |
| Marionetta | `marionetta` | casuale | 1% | 99% | 0% | 1.1 | 144.7 | 0% | 0 |
| Marionetta | `marionetta` | si_cura | 0% | 100% | 0% | 1.6 | 145.0 | 0% | 0 |
| Fomentado | `maschera_vuota` | attacca | 100% | 0% | 0% | 5.7 | 69.9 | 0% | 9 |
| Fomentado | `maschera_vuota` | difendi | 100% | 0% | 0% | 21.3 | 61.4 | 0% | 9 |
| Fomentado | `maschera_vuota` | studia | 100% | 0% | 0% | 8.0 | 97.3 | 0% | 9 |
| Fomentado | `maschera_vuota` | casuale | 99% | 1% | 0% | 11.0 | 82.1 | 0% | 9 |
| Fomentado | `maschera_vuota` | si_cura | 100% | 0% | 0% | 5.7 | 56.1 | 0% | 9 |
| Nuvola di Marciume | `nuvola_di_marciume` | attacca | 100% | 0% | 0% | 4.9 | 51.4 | 0% | 6 |
| Nuvola di Marciume | `nuvola_di_marciume` | difendi | 0% | 100% | 0% | 34.7 | 145.0 | 0% | 0 |
| Nuvola di Marciume | `nuvola_di_marciume` | studia | 100% | 0% | 0% | 7.9 | 89.0 | 0% | 6 |
| Nuvola di Marciume | `nuvola_di_marciume` | casuale | 96% | 4% | 0% | 15.0 | 85.1 | 0% | 6 |
| Nuvola di Marciume | `nuvola_di_marciume` | si_cura | 100% | 0% | 0% | 6.6 | 58.0 | 0% | 6 |
| Ombra del passato | `ombra_del_passato` | attacca | 1% | 99% | 0% | 1.0 | 144.7 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | difendi | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | studia | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | casuale | 1% | 99% | 0% | 1.0 | 144.7 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | si_cura | 0% | 100% | 0% | 1.3 | 145.0 | 0% | 0 |
| Emblema dell'oppressione | `operaio_posseduto` | attacca | 4% | 96% | 0% | 5.9 | 142.8 | 0% | 1 |
| Emblema dell'oppressione | `operaio_posseduto` | difendi | 0% | 100% | 0% | 17.4 | 145.0 | 0% | 0 |
| Emblema dell'oppressione | `operaio_posseduto` | studia | 4% | 96% | 0% | 6.0 | 144.0 | 0% | 1 |
| Emblema dell'oppressione | `operaio_posseduto` | casuale | 4% | 96% | 0% | 8.5 | 142.9 | 0% | 1 |
| Emblema dell'oppressione | `operaio_posseduto` | si_cura | 19% | 81% | 0% | 21.4 | 128.2 | 0% | 3 |
| Operaio Sfruttato | `operaio_sfruttato` | attacca | 0% | 100% | 0% | 6.6 | 145.0 | 0% | 0 |
| Operaio Sfruttato | `operaio_sfruttato` | difendi | 0% | 100% | 0% | 23.8 | 145.0 | 0% | 0 |
| Operaio Sfruttato | `operaio_sfruttato` | studia | 0% | 100% | 0% | 6.6 | 145.0 | 0% | 0 |
| Operaio Sfruttato | `operaio_sfruttato` | casuale | 0% | 100% | 0% | 8.9 | 145.0 | 0% | 0 |
| Operaio Sfruttato | `operaio_sfruttato` | si_cura | 0% | 100% | 0% | 22.3 | 145.0 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | attacca | 0% | 100% | 0% | 5.8 | 145.0 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | difendi | 0% | 100% | 0% | 15.8 | 145.0 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | studia | 0% | 100% | 0% | 5.9 | 145.0 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | casuale | 0% | 100% | 0% | 7.7 | 145.0 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | si_cura | 0% | 100% | 0% | 20.6 | 145.0 | 0% | 0 |
| Robo Pattuglia | `robo_pattuglia` | attacca | 19% | 81% | 0% | 16.6 | 133.1 | 0% | 3 |
| Robo Pattuglia | `robo_pattuglia` | difendi | 0% | 0% | 100% | 60.0 | 82.6 | 0% | 0 |
| Robo Pattuglia | `robo_pattuglia` | studia | 17% | 83% | 0% | 17.2 | 137.1 | 0% | 3 |
| Robo Pattuglia | `robo_pattuglia` | casuale | 19% | 12% | 69% | 53.6 | 105.7 | 0% | 3 |
| Robo Pattuglia | `robo_pattuglia` | si_cura | 39% | 45% | 16% | 46.5 | 107.2 | 0% | 6 |
| Sacerdote Folle | `sacerdote_folle` | attacca | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| Sacerdote Folle | `sacerdote_folle` | difendi | 0% | 100% | 0% | 1.1 | 145.0 | 0% | 0 |
| Sacerdote Folle | `sacerdote_folle` | studia | 0% | 100% | 0% | 1.1 | 145.0 | 0% | 0 |
| Sacerdote Folle | `sacerdote_folle` | casuale | 1% | 99% | 0% | 1.1 | 144.5 | 0% | 0 |
| Sacerdote Folle | `sacerdote_folle` | si_cura | 0% | 100% | 0% | 1.1 | 145.0 | 0% | 0 |
| Sadico | `sadico` | attacca | 3% | 97% | 0% | 2.0 | 142.1 | 0% | 1 |
| Sadico | `sadico` | difendi | 0% | 100% | 0% | 2.0 | 145.0 | 0% | 0 |
| Sadico | `sadico` | studia | 0% | 100% | 0% | 2.0 | 145.0 | 0% | 0 |
| Sadico | `sadico` | casuale | 1% | 99% | 0% | 2.0 | 144.7 | 0% | 0 |
| Sadico | `sadico` | si_cura | 1% | 99% | 0% | 2.6 | 143.6 | 0% | 0 |
| Slime Infimo | `slime_infimo` | attacca | 100% | 0% | 0% | 4.7 | 12.7 | 0% | 2 |
| Slime Infimo | `slime_infimo` | difendi | 0% | 0% | 100% | 60.0 | 110.9 | 0% | 0 |
| Slime Infimo | `slime_infimo` | studia | 100% | 0% | 0% | 7.9 | 31.3 | 0% | 2 |
| Slime Infimo | `slime_infimo` | casuale | 100% | 0% | 0% | 20.7 | 38.5 | 0% | 2 |
| Slime Infimo | `slime_infimo` | si_cura | 100% | 0% | 0% | 4.7 | 12.7 | 0% | 2 |
| Stigma | `stigma` | attacca | 3% | 97% | 0% | 2.4 | 143.3 | 0% | 1 |
| Stigma | `stigma` | difendi | 0% | 100% | 0% | 2.7 | 145.0 | 0% | 0 |
| Stigma | `stigma` | studia | 0% | 100% | 0% | 2.4 | 145.0 | 0% | 0 |
| Stigma | `stigma` | casuale | 1% | 99% | 0% | 2.5 | 144.4 | 0% | 0 |
| Stigma | `stigma` | si_cura | 3% | 97% | 0% | 6.1 | 142.5 | 0% | 1 |
| Tartaruga Innocente | `tartaruga_innocente` | attacca | 0% | 0% | 100% | 60.0 | 0.0 | 0% | 0 |
| Tartaruga Innocente | `tartaruga_innocente` | difendi | 0% | 0% | 100% | 60.0 | 0.0 | 0% | 0 |
| Tartaruga Innocente | `tartaruga_innocente` | studia | 100% | 0% | 0% | 2.0 | 0.0 | 100% | 3 |
| Tartaruga Innocente | `tartaruga_innocente` | casuale | 0% | 0% | 100% | 60.0 | 0.0 | 0% | 0 |
| Tartaruga Innocente | `tartaruga_innocente` | si_cura | 0% | 0% | 100% | 60.0 | 0.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | attacca | 0% | 100% | 0% | 1.5 | 145.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | difendi | 0% | 100% | 0% | 1.6 | 145.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | studia | 0% | 100% | 0% | 1.5 | 145.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | casuale | 0% | 100% | 0% | 1.5 | 145.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | si_cura | 0% | 100% | 0% | 1.8 | 145.0 | 0% | 0 |
| Teschio Errante | `teschio_errante` | attacca | 2% | 98% | 0% | 3.4 | 142.7 | 0% | 1 |
| Teschio Errante | `teschio_errante` | difendi | 0% | 100% | 0% | 5.3 | 145.0 | 0% | 0 |
| Teschio Errante | `teschio_errante` | studia | 1% | 99% | 0% | 3.4 | 145.0 | 0% | 0 |
| Teschio Errante | `teschio_errante` | casuale | 0% | 100% | 0% | 3.8 | 145.0 | 0% | 0 |
| Teschio Errante | `teschio_errante` | si_cura | 9% | 91% | 0% | 11.4 | 137.0 | 0% | 3 |
| Titano Zombie | `titano_zombie` | attacca | 0% | 100% | 0% | 1.7 | 145.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | difendi | 0% | 100% | 0% | 1.8 | 145.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | studia | 0% | 100% | 0% | 1.7 | 145.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | casuale | 0% | 100% | 0% | 1.8 | 145.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | si_cura | 0% | 100% | 0% | 4.4 | 145.0 | 0% | 0 |
| Capocantiere | `voce_registrata` | attacca | 5% | 95% | 0% | 8.4 | 140.1 | 0% | 1 |
| Capocantiere | `voce_registrata` | difendi | 0% | 100% | 0% | 37.7 | 145.0 | 0% | 0 |
| Capocantiere | `voce_registrata` | studia | 6% | 94% | 0% | 8.6 | 142.7 | 0% | 1 |
| Capocantiere | `voce_registrata` | casuale | 3% | 97% | 0% | 16.0 | 143.3 | 0% | 0 |
| Capocantiere | `voce_registrata` | si_cura | 100% | 0% | 0% | 13.9 | 43.3 | 0% | 13 |
| Volto sulla parete | `volto_sulla_parete` | attacca | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | difendi | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | studia | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | casuale | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | si_cura | 0% | 100% | 0% | 1.0 | 145.0 | 0% | 0 |
| Zombie Cittadino | `zombie_cittadino` | attacca | 100% | 0% | 0% | 6.5 | 28.3 | 0% | 5 |
| Zombie Cittadino | `zombie_cittadino` | difendi | 0% | 0% | 100% | 60.0 | 46.7 | 0% | 0 |
| Zombie Cittadino | `zombie_cittadino` | studia | 100% | 0% | 0% | 9.5 | 41.0 | 0% | 5 |
| Zombie Cittadino | `zombie_cittadino` | casuale | 100% | 0% | 0% | 20.2 | 31.8 | 0% | 5 |
| Zombie Cittadino | `zombie_cittadino` | si_cura | 100% | 0% | 0% | 6.5 | 28.3 | 0% | 5 |
| Zombie Mostruoso | `zombie_mostruoso` | attacca | 100% | 0% | 0% | 8.5 | 80.1 | 0% | 9 |
| Zombie Mostruoso | `zombie_mostruoso` | difendi | 0% | 1% | 99% | 60.0 | 100.6 | 0% | 0 |
| Zombie Mostruoso | `zombie_mostruoso` | studia | 99% | 1% | 0% | 11.5 | 106.1 | 0% | 9 |
| Zombie Mostruoso | `zombie_mostruoso` | casuale | 87% | 13% | 0% | 25.4 | 106.1 | 0% | 8 |
| Zombie Mostruoso | `zombie_mostruoso` | si_cura | 100% | 0% | 0% | 9.1 | 37.0 | 0% | 9 |

## Protagonista di livello 3

| creatura | id | come si gioca | vinte | perse | ∞ | giri | danno | risp. | xp |
|---|---|---|--:|--:|--:|--:|--:|--:|--:|
| Abominio Marcio | `abominio_marcio` | attacca | 0% | 100% | 0% | 2.1 | 190.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | difendi | 0% | 100% | 0% | 2.5 | 190.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | studia | 0% | 100% | 0% | 2.1 | 190.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | casuale | 0% | 100% | 0% | 2.2 | 190.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | si_cura | 0% | 100% | 0% | 2.5 | 190.0 | 0% | 0 |
| Oppresso | `comparsa_di_ruggine` | attacca | 40% | 60% | 0% | 32.0 | 153.8 | 0% | 6 |
| Oppresso | `comparsa_di_ruggine` | difendi | 0% | 0% | 100% | 60.0 | 47.1 | 0% | 0 |
| Oppresso | `comparsa_di_ruggine` | studia | 35% | 65% | 0% | 33.4 | 156.2 | 0% | 6 |
| Oppresso | `comparsa_di_ruggine` | casuale | 17% | 0% | 83% | 55.3 | 58.8 | 0% | 3 |
| Oppresso | `comparsa_di_ruggine` | si_cura | 61% | 0% | 39% | 42.2 | 60.9 | 0% | 10 |
| Diabolo | `diabolo` | attacca | 5% | 95% | 0% | 4.6 | 185.7 | 0% | 2 |
| Diabolo | `diabolo` | difendi | 4% | 96% | 0% | 8.8 | 187.2 | 0% | 1 |
| Diabolo | `diabolo` | studia | 2% | 98% | 0% | 4.7 | 189.0 | 0% | 1 |
| Diabolo | `diabolo` | casuale | 1% | 99% | 0% | 5.3 | 188.9 | 0% | 0 |
| Diabolo | `diabolo` | si_cura | 8% | 92% | 0% | 11.8 | 181.3 | 0% | 3 |
| Il Divoratore | `divoratore` | attacca | 0% | 100% | 0% | 5.9 | 190.0 | 0% | 0 |
| Il Divoratore | `divoratore` | difendi | 0% | 100% | 0% | 15.1 | 190.0 | 0% | 0 |
| Il Divoratore | `divoratore` | studia | 0% | 100% | 0% | 5.9 | 190.0 | 0% | 0 |
| Il Divoratore | `divoratore` | casuale | 0% | 100% | 0% | 7.6 | 190.0 | 0% | 0 |
| Il Divoratore | `divoratore` | si_cura | 0% | 100% | 0% | 18.5 | 190.0 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | attacca | 3% | 97% | 0% | 2.9 | 187.0 | 0% | 1 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | difendi | 0% | 100% | 0% | 3.9 | 190.0 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | studia | 0% | 100% | 0% | 3.0 | 190.0 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | casuale | 0% | 100% | 0% | 3.0 | 190.0 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | si_cura | 5% | 95% | 0% | 8.5 | 184.8 | 0% | 2 |
| Donna Spinosa | `donna_spinosa` | attacca | 3% | 97% | 0% | 2.0 | 186.4 | 0% | 2 |
| Donna Spinosa | `donna_spinosa` | difendi | 0% | 100% | 0% | 2.4 | 190.0 | 0% | 0 |
| Donna Spinosa | `donna_spinosa` | studia | 0% | 100% | 0% | 2.0 | 190.0 | 0% | 0 |
| Donna Spinosa | `donna_spinosa` | casuale | 1% | 99% | 0% | 2.2 | 189.6 | 0% | 0 |
| Donna Spinosa | `donna_spinosa` | si_cura | 1% | 99% | 0% | 2.5 | 189.0 | 0% | 0 |
| Rottami Erranti | `ferraglia_urlante` | attacca | 0% | 100% | 0% | 21.4 | 190.0 | 0% | 0 |
| Rottami Erranti | `ferraglia_urlante` | difendi | 0% | 5% | 95% | 59.7 | 132.9 | 0% | 0 |
| Rottami Erranti | `ferraglia_urlante` | studia | 0% | 100% | 0% | 21.1 | 190.0 | 0% | 0 |
| Rottami Erranti | `ferraglia_urlante` | casuale | 0% | 97% | 3% | 43.7 | 188.6 | 0% | 0 |
| Rottami Erranti | `ferraglia_urlante` | si_cura | 0% | 100% | 0% | 33.7 | 190.0 | 0% | 0 |
| Ghoul | `ghoul` | attacca | 7% | 93% | 0% | 5.4 | 183.1 | 0% | 2 |
| Ghoul | `ghoul` | difendi | 0% | 100% | 0% | 11.0 | 190.0 | 0% | 0 |
| Ghoul | `ghoul` | studia | 3% | 97% | 0% | 5.6 | 188.5 | 0% | 1 |
| Ghoul | `ghoul` | casuale | 3% | 97% | 0% | 6.3 | 187.5 | 0% | 1 |
| Ghoul | `ghoul` | si_cura | 10% | 90% | 0% | 15.7 | 177.6 | 0% | 3 |
| El Muy Bonito | `giocoliere` | attacca | 0% | 100% | 0% | 6.8 | 190.0 | 0% | 0 |
| El Muy Bonito | `giocoliere` | difendi | 0% | 100% | 0% | 32.9 | 190.0 | 0% | 0 |
| El Muy Bonito | `giocoliere` | studia | 0% | 100% | 0% | 4.4 | 190.0 | 0% | 0 |
| El Muy Bonito | `giocoliere` | casuale | 0% | 100% | 0% | 6.9 | 190.0 | 0% | 0 |
| El Muy Bonito | `giocoliere` | si_cura | 2% | 98% | 0% | 16.3 | 189.8 | 0% | 1 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | attacca | 0% | 100% | 0% | 5.6 | 190.0 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | difendi | 0% | 100% | 0% | 10.3 | 190.0 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | studia | 0% | 100% | 0% | 5.6 | 190.0 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | casuale | 0% | 100% | 0% | 6.3 | 190.0 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | si_cura | 0% | 100% | 0% | 15.6 | 190.0 | 0% | 0 |
| Goblin Tipico | `goblin_tipico` | attacca | 100% | 0% | 0% | 3.8 | 4.8 | 0% | 1 |
| Goblin Tipico | `goblin_tipico` | difendi | 0% | 0% | 100% | 60.0 | 31.5 | 0% | 0 |
| Goblin Tipico | `goblin_tipico` | studia | 100% | 0% | 0% | 6.8 | 9.8 | 0% | 1 |
| Goblin Tipico | `goblin_tipico` | casuale | 100% | 0% | 0% | 12.2 | 9.5 | 0% | 1 |
| Goblin Tipico | `goblin_tipico` | si_cura | 100% | 0% | 0% | 3.8 | 4.8 | 0% | 1 |
| Golem errante di rottami | `golem_errante` | attacca | 0% | 100% | 0% | 5.2 | 190.0 | 0% | 0 |
| Golem errante di rottami | `golem_errante` | difendi | 0% | 100% | 0% | 8.8 | 190.0 | 0% | 0 |
| Golem errante di rottami | `golem_errante` | studia | 0% | 100% | 0% | 5.4 | 190.0 | 0% | 0 |
| Golem errante di rottami | `golem_errante` | casuale | 0% | 100% | 0% | 6.2 | 190.0 | 0% | 0 |
| Golem errante di rottami | `golem_errante` | si_cura | 0% | 100% | 0% | 16.8 | 190.0 | 0% | 0 |
| Infetto Rapido | `infetto_rapido` | attacca | 100% | 0% | 0% | 3.8 | 24.6 | 0% | 5 |
| Infetto Rapido | `infetto_rapido` | difendi | 0% | 0% | 100% | 60.0 | 134.5 | 0% | 0 |
| Infetto Rapido | `infetto_rapido` | studia | 100% | 0% | 0% | 6.8 | 48.7 | 0% | 5 |
| Infetto Rapido | `infetto_rapido` | casuale | 100% | 0% | 0% | 12.0 | 41.0 | 0% | 5 |
| Infetto Rapido | `infetto_rapido` | si_cura | 100% | 0% | 0% | 3.8 | 24.6 | 0% | 5 |
| L'ultimo spettacolo di Jerah | `jerah` | attacca | 0% | 100% | 0% | 1.3 | 190.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | difendi | 0% | 100% | 0% | 1.3 | 190.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | studia | 0% | 100% | 0% | 1.2 | 190.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | casuale | 0% | 100% | 0% | 1.3 | 190.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | si_cura | 0% | 100% | 0% | 1.5 | 190.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | attacca | 0% | 100% | 0% | 2.4 | 190.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | difendi | 0% | 100% | 0% | 2.6 | 190.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | studia | 0% | 100% | 0% | 2.4 | 190.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | casuale | 0% | 100% | 0% | 2.4 | 190.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | si_cura | 0% | 100% | 0% | 3.8 | 190.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | attacca | 0% | 100% | 0% | 1.0 | 190.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | difendi | 0% | 100% | 0% | 1.0 | 190.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | studia | 0% | 100% | 0% | 1.0 | 190.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | casuale | 0% | 100% | 0% | 1.0 | 190.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | si_cura | 0% | 100% | 0% | 1.1 | 190.0 | 0% | 0 |
| ??? | `l_immortale` | attacca | 0% | 100% | 0% | 27.8 | 190.0 | 0% | 0 |
| ??? | `l_immortale` | difendi | 0% | 0% | 100% | 60.0 | 106.9 | 0% | 0 |
| ??? | `l_immortale` | studia | 0% | 100% | 0% | 28.4 | 190.0 | 0% | 0 |
| ??? | `l_immortale` | casuale | 0% | 0% | 100% | 60.0 | 120.3 | 0% | 0 |
| ??? | `l_immortale` | si_cura | 0% | 0% | 100% | 60.0 | 43.4 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | attacca | 7% | 93% | 0% | 5.6 | 182.9 | 0% | 2 |
| Madre in Lacrime | `madre_in_lacrime` | difendi | 0% | 100% | 0% | 11.9 | 190.0 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | studia | 4% | 96% | 0% | 5.8 | 188.3 | 0% | 1 |
| Madre in Lacrime | `madre_in_lacrime` | casuale | 3% | 97% | 0% | 6.6 | 187.5 | 0% | 1 |
| Madre in Lacrime | `madre_in_lacrime` | si_cura | 13% | 87% | 0% | 16.2 | 175.2 | 0% | 4 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | attacca | 0% | 100% | 0% | 6.0 | 190.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | difendi | 0% | 100% | 0% | 6.0 | 190.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | studia | 0% | 100% | 0% | 6.0 | 190.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | casuale | 0% | 100% | 0% | 6.0 | 190.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | si_cura | 0% | 100% | 0% | 6.0 | 190.0 | 0% | 0 |
| Marionetta | `marionetta` | attacca | 1% | 99% | 0% | 2.0 | 188.0 | 0% | 1 |
| Marionetta | `marionetta` | difendi | 0% | 100% | 0% | 2.1 | 190.0 | 0% | 0 |
| Marionetta | `marionetta` | studia | 0% | 100% | 0% | 2.0 | 190.0 | 0% | 0 |
| Marionetta | `marionetta` | casuale | 1% | 99% | 0% | 2.0 | 189.7 | 0% | 0 |
| Marionetta | `marionetta` | si_cura | 1% | 99% | 0% | 3.6 | 188.0 | 0% | 1 |
| Fomentado | `maschera_vuota` | attacca | 100% | 0% | 0% | 5.3 | 47.3 | 0% | 9 |
| Fomentado | `maschera_vuota` | difendi | 100% | 0% | 0% | 28.3 | 46.9 | 0% | 9 |
| Fomentado | `maschera_vuota` | studia | 100% | 0% | 0% | 7.8 | 70.7 | 0% | 9 |
| Fomentado | `maschera_vuota` | casuale | 100% | 0% | 0% | 10.7 | 54.5 | 0% | 9 |
| Fomentado | `maschera_vuota` | si_cura | 100% | 0% | 0% | 5.3 | 47.3 | 0% | 9 |
| Nuvola di Marciume | `nuvola_di_marciume` | attacca | 100% | 0% | 0% | 3.9 | 24.1 | 0% | 5 |
| Nuvola di Marciume | `nuvola_di_marciume` | difendi | 0% | 100% | 0% | 42.8 | 190.0 | 0% | 0 |
| Nuvola di Marciume | `nuvola_di_marciume` | studia | 100% | 0% | 0% | 6.9 | 54.1 | 0% | 5 |
| Nuvola di Marciume | `nuvola_di_marciume` | casuale | 100% | 0% | 0% | 12.1 | 63.2 | 0% | 5 |
| Nuvola di Marciume | `nuvola_di_marciume` | si_cura | 100% | 0% | 0% | 5.0 | 28.1 | 0% | 5 |
| Ombra del passato | `ombra_del_passato` | attacca | 3% | 97% | 0% | 1.8 | 186.8 | 0% | 2 |
| Ombra del passato | `ombra_del_passato` | difendi | 0% | 100% | 0% | 1.8 | 190.0 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | studia | 0% | 100% | 0% | 1.8 | 190.0 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | casuale | 1% | 99% | 0% | 1.8 | 189.7 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | si_cura | 2% | 98% | 0% | 3.9 | 187.2 | 0% | 1 |
| Emblema dell'oppressione | `operaio_posseduto` | attacca | 15% | 85% | 0% | 14.0 | 176.5 | 0% | 3 |
| Emblema dell'oppressione | `operaio_posseduto` | difendi | 0% | 100% | 0% | 39.9 | 190.0 | 0% | 0 |
| Emblema dell'oppressione | `operaio_posseduto` | studia | 12% | 88% | 0% | 14.0 | 183.4 | 0% | 2 |
| Emblema dell'oppressione | `operaio_posseduto` | casuale | 7% | 93% | 0% | 28.1 | 183.4 | 0% | 1 |
| Emblema dell'oppressione | `operaio_posseduto` | si_cura | 100% | 0% | 0% | 23.3 | 69.4 | 0% | 18 |
| Operaio Sfruttato | `operaio_sfruttato` | attacca | 0% | 100% | 0% | 12.4 | 190.0 | 0% | 0 |
| Operaio Sfruttato | `operaio_sfruttato` | difendi | 0% | 8% | 92% | 59.5 | 149.3 | 0% | 0 |
| Operaio Sfruttato | `operaio_sfruttato` | studia | 0% | 100% | 0% | 12.1 | 190.0 | 0% | 0 |
| Operaio Sfruttato | `operaio_sfruttato` | casuale | 0% | 75% | 25% | 40.0 | 184.9 | 0% | 0 |
| Operaio Sfruttato | `operaio_sfruttato` | si_cura | 0% | 100% | 0% | 34.9 | 190.0 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | attacca | 0% | 100% | 0% | 11.1 | 190.0 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | difendi | 0% | 79% | 21% | 50.4 | 186.6 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | studia | 0% | 100% | 0% | 11.1 | 190.0 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | casuale | 0% | 98% | 2% | 28.8 | 189.8 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | si_cura | 15% | 85% | 0% | 38.6 | 189.8 | 0% | 6 |
| Robo Pattuglia | `robo_pattuglia` | attacca | 43% | 57% | 0% | 28.7 | 149.7 | 0% | 7 |
| Robo Pattuglia | `robo_pattuglia` | difendi | 0% | 0% | 100% | 60.0 | 56.6 | 0% | 0 |
| Robo Pattuglia | `robo_pattuglia` | studia | 39% | 61% | 0% | 29.4 | 157.0 | 0% | 6 |
| Robo Pattuglia | `robo_pattuglia` | casuale | 12% | 0% | 88% | 56.2 | 70.7 | 0% | 2 |
| Robo Pattuglia | `robo_pattuglia` | si_cura | 53% | 0% | 47% | 41.9 | 50.3 | 0% | 8 |
| Sacerdote Folle | `sacerdote_folle` | attacca | 3% | 97% | 0% | 2.3 | 186.3 | 0% | 1 |
| Sacerdote Folle | `sacerdote_folle` | difendi | 0% | 100% | 0% | 2.8 | 190.0 | 0% | 0 |
| Sacerdote Folle | `sacerdote_folle` | studia | 0% | 100% | 0% | 2.4 | 190.0 | 0% | 0 |
| Sacerdote Folle | `sacerdote_folle` | casuale | 0% | 100% | 0% | 2.5 | 190.0 | 0% | 0 |
| Sacerdote Folle | `sacerdote_folle` | si_cura | 3% | 97% | 0% | 3.8 | 186.3 | 0% | 1 |
| Sadico | `sadico` | attacca | 5% | 95% | 0% | 3.9 | 185.4 | 0% | 2 |
| Sadico | `sadico` | difendi | 0% | 100% | 0% | 4.6 | 190.0 | 0% | 0 |
| Sadico | `sadico` | studia | 1% | 99% | 0% | 3.9 | 189.8 | 0% | 0 |
| Sadico | `sadico` | casuale | 0% | 100% | 0% | 4.1 | 190.0 | 0% | 0 |
| Sadico | `sadico` | si_cura | 3% | 97% | 0% | 8.3 | 187.4 | 0% | 1 |
| Slime Infimo | `slime_infimo` | attacca | 100% | 0% | 0% | 3.8 | 4.3 | 0% | 1 |
| Slime Infimo | `slime_infimo` | difendi | 0% | 0% | 100% | 60.0 | 53.5 | 0% | 0 |
| Slime Infimo | `slime_infimo` | studia | 100% | 0% | 0% | 7.0 | 10.3 | 0% | 1 |
| Slime Infimo | `slime_infimo` | casuale | 100% | 0% | 0% | 13.9 | 11.4 | 0% | 1 |
| Slime Infimo | `slime_infimo` | si_cura | 100% | 0% | 0% | 3.8 | 4.3 | 0% | 1 |
| Stigma | `stigma` | attacca | 5% | 95% | 0% | 4.3 | 184.5 | 0% | 2 |
| Stigma | `stigma` | difendi | 0% | 100% | 0% | 6.4 | 190.0 | 0% | 0 |
| Stigma | `stigma` | studia | 1% | 99% | 0% | 4.4 | 189.9 | 0% | 0 |
| Stigma | `stigma` | casuale | 1% | 99% | 0% | 4.7 | 189.3 | 0% | 0 |
| Stigma | `stigma` | si_cura | 7% | 93% | 0% | 13.5 | 182.7 | 0% | 2 |
| Tartaruga Innocente | `tartaruga_innocente` | attacca | 0% | 0% | 100% | 60.0 | 0.0 | 0% | 0 |
| Tartaruga Innocente | `tartaruga_innocente` | difendi | 0% | 0% | 100% | 60.0 | 0.0 | 0% | 0 |
| Tartaruga Innocente | `tartaruga_innocente` | studia | 100% | 0% | 0% | 2.0 | 0.0 | 100% | 1 |
| Tartaruga Innocente | `tartaruga_innocente` | casuale | 0% | 0% | 100% | 60.0 | 0.0 | 0% | 0 |
| Tartaruga Innocente | `tartaruga_innocente` | si_cura | 0% | 0% | 100% | 60.0 | 0.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | attacca | 0% | 100% | 0% | 2.0 | 190.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | difendi | 0% | 100% | 0% | 2.2 | 190.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | studia | 0% | 100% | 0% | 2.0 | 190.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | casuale | 0% | 100% | 0% | 2.1 | 190.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | si_cura | 0% | 100% | 0% | 2.4 | 190.0 | 0% | 0 |
| Teschio Errante | `teschio_errante` | attacca | 9% | 91% | 0% | 6.2 | 181.8 | 0% | 3 |
| Teschio Errante | `teschio_errante` | difendi | 0% | 100% | 0% | 18.5 | 190.0 | 0% | 0 |
| Teschio Errante | `teschio_errante` | studia | 2% | 98% | 0% | 6.4 | 189.4 | 0% | 1 |
| Teschio Errante | `teschio_errante` | casuale | 2% | 98% | 0% | 8.6 | 188.7 | 0% | 1 |
| Teschio Errante | `teschio_errante` | si_cura | 16% | 84% | 0% | 17.5 | 171.9 | 0% | 5 |
| Titano Zombie | `titano_zombie` | attacca | 0% | 100% | 0% | 2.9 | 190.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | difendi | 0% | 100% | 0% | 3.5 | 190.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | studia | 0% | 100% | 0% | 3.0 | 190.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | casuale | 0% | 100% | 0% | 3.1 | 190.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | si_cura | 0% | 100% | 0% | 8.9 | 190.0 | 0% | 0 |
| Capocantiere | `voce_registrata` | attacca | 100% | 0% | 0% | 8.5 | 95.4 | 0% | 13 |
| Capocantiere | `voce_registrata` | difendi | 0% | 0% | 100% | 60.0 | 109.1 | 0% | 0 |
| Capocantiere | `voce_registrata` | studia | 100% | 0% | 0% | 11.2 | 125.5 | 0% | 13 |
| Capocantiere | `voce_registrata` | casuale | 95% | 5% | 0% | 26.6 | 112.5 | 0% | 12 |
| Capocantiere | `voce_registrata` | si_cura | 100% | 0% | 0% | 8.8 | 68.4 | 0% | 13 |
| Volto sulla parete | `volto_sulla_parete` | attacca | 0% | 100% | 0% | 1.0 | 190.0 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | difendi | 0% | 100% | 0% | 1.0 | 190.0 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | studia | 0% | 100% | 0% | 1.0 | 190.0 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | casuale | 0% | 100% | 0% | 1.0 | 190.0 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | si_cura | 0% | 100% | 0% | 1.0 | 190.0 | 0% | 0 |
| Zombie Cittadino | `zombie_cittadino` | attacca | 100% | 0% | 0% | 4.9 | 11.4 | 0% | 4 |
| Zombie Cittadino | `zombie_cittadino` | difendi | 0% | 0% | 100% | 60.0 | 31.3 | 0% | 0 |
| Zombie Cittadino | `zombie_cittadino` | studia | 100% | 0% | 0% | 7.9 | 23.3 | 0% | 4 |
| Zombie Cittadino | `zombie_cittadino` | casuale | 100% | 0% | 0% | 15.3 | 17.5 | 0% | 4 |
| Zombie Cittadino | `zombie_cittadino` | si_cura | 100% | 0% | 0% | 4.9 | 11.4 | 0% | 4 |
| Zombie Mostruoso | `zombie_mostruoso` | attacca | 100% | 0% | 0% | 6.6 | 43.3 | 0% | 9 |
| Zombie Mostruoso | `zombie_mostruoso` | difendi | 0% | 0% | 100% | 60.0 | 62.3 | 0% | 0 |
| Zombie Mostruoso | `zombie_mostruoso` | studia | 100% | 0% | 0% | 9.5 | 58.7 | 0% | 9 |
| Zombie Mostruoso | `zombie_mostruoso` | casuale | 100% | 0% | 0% | 19.8 | 61.5 | 0% | 9 |
| Zombie Mostruoso | `zombie_mostruoso` | si_cura | 100% | 0% | 0% | 6.6 | 43.3 | 0% | 9 |

## Protagonista di livello 5

| creatura | id | come si gioca | vinte | perse | ∞ | giri | danno | risp. | xp |
|---|---|---|--:|--:|--:|--:|--:|--:|--:|
| Abominio Marcio | `abominio_marcio` | attacca | 0% | 100% | 0% | 5.9 | 285.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | difendi | 0% | 100% | 0% | 12.0 | 285.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | studia | 0% | 100% | 0% | 5.9 | 285.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | casuale | 0% | 100% | 0% | 6.9 | 285.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | si_cura | 0% | 100% | 0% | 13.3 | 285.0 | 0% | 0 |
| Oppresso | `comparsa_di_ruggine` | attacca | 100% | 0% | 0% | 10.3 | 22.3 | 0% | 14 |
| Oppresso | `comparsa_di_ruggine` | difendi | 0% | 0% | 100% | 60.0 | 23.2 | 0% | 0 |
| Oppresso | `comparsa_di_ruggine` | studia | 100% | 0% | 0% | 14.9 | 31.0 | 0% | 14 |
| Oppresso | `comparsa_di_ruggine` | casuale | 51% | 0% | 49% | 46.5 | 24.2 | 0% | 7 |
| Oppresso | `comparsa_di_ruggine` | si_cura | 100% | 0% | 0% | 10.3 | 22.3 | 0% | 14 |
| Diabolo | `diabolo` | attacca | 54% | 46% | 0% | 11.2 | 256.9 | 0% | 19 |
| Diabolo | `diabolo` | difendi | 25% | 4% | 71% | 54.8 | 194.1 | 0% | 9 |
| Diabolo | `diabolo` | studia | 10% | 90% | 0% | 12.1 | 277.2 | 0% | 4 |
| Diabolo | `diabolo` | casuale | 69% | 31% | 0% | 24.7 | 225.0 | 0% | 24 |
| Diabolo | `diabolo` | si_cura | 100% | 0% | 0% | 13.7 | 127.4 | 0% | 35 |
| Il Divoratore | `divoratore` | attacca | 0% | 100% | 0% | 17.8 | 285.0 | 0% | 0 |
| Il Divoratore | `divoratore` | difendi | 0% | 0% | 100% | 60.0 | 156.4 | 0% | 0 |
| Il Divoratore | `divoratore` | studia | 0% | 100% | 0% | 17.6 | 285.0 | 0% | 0 |
| Il Divoratore | `divoratore` | casuale | 0% | 16% | 84% | 57.1 | 224.0 | 0% | 0 |
| Il Divoratore | `divoratore` | si_cura | 100% | 0% | 0% | 34.0 | 164.5 | 0% | 48 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | attacca | 7% | 93% | 0% | 7.6 | 273.6 | 0% | 3 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | difendi | 0% | 63% | 37% | 52.9 | 272.6 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | studia | 4% | 96% | 0% | 7.8 | 281.1 | 0% | 2 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | casuale | 6% | 92% | 2% | 19.0 | 279.3 | 0% | 3 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | si_cura | 13% | 87% | 0% | 18.7 | 262.9 | 0% | 6 |
| Donna Spinosa | `donna_spinosa` | attacca | 3% | 97% | 0% | 5.0 | 278.0 | 0% | 2 |
| Donna Spinosa | `donna_spinosa` | difendi | 0% | 100% | 0% | 10.2 | 285.0 | 0% | 0 |
| Donna Spinosa | `donna_spinosa` | studia | 3% | 97% | 0% | 5.2 | 283.6 | 0% | 1 |
| Donna Spinosa | `donna_spinosa` | casuale | 3% | 97% | 0% | 5.9 | 282.6 | 0% | 1 |
| Donna Spinosa | `donna_spinosa` | si_cura | 5% | 95% | 0% | 10.7 | 279.4 | 0% | 2 |
| Rottami Erranti | `ferraglia_urlante` | attacca | 0% | 100% | 0% | 26.1 | 285.0 | 0% | 0 |
| Rottami Erranti | `ferraglia_urlante` | difendi | 0% | 0% | 100% | 60.0 | 80.6 | 0% | 0 |
| Rottami Erranti | `ferraglia_urlante` | studia | 0% | 100% | 0% | 28.3 | 285.0 | 0% | 0 |
| Rottami Erranti | `ferraglia_urlante` | casuale | 0% | 15% | 85% | 59.0 | 203.0 | 0% | 0 |
| Rottami Erranti | `ferraglia_urlante` | si_cura | 2% | 98% | 0% | 48.3 | 284.6 | 0% | 1 |
| Ghoul | `ghoul` | attacca | 89% | 11% | 0% | 11.3 | 232.6 | 0% | 27 |
| Ghoul | `ghoul` | difendi | 0% | 1% | 99% | 60.0 | 198.5 | 0% | 0 |
| Ghoul | `ghoul` | studia | 34% | 66% | 0% | 13.3 | 271.1 | 0% | 10 |
| Ghoul | `ghoul` | casuale | 73% | 27% | 0% | 33.3 | 226.7 | 0% | 22 |
| Ghoul | `ghoul` | si_cura | 100% | 0% | 0% | 13.0 | 115.5 | 0% | 30 |
| El Muy Bonito | `giocoliere` | attacca | 100% | 0% | 0% | 9.7 | 123.0 | 0% | 25 |
| El Muy Bonito | `giocoliere` | difendi | 0% | 0% | 100% | 60.0 | 116.9 | 0% | 0 |
| El Muy Bonito | `giocoliere` | studia | 1% | 99% | 0% | 8.7 | 284.9 | 0% | 0 |
| El Muy Bonito | `giocoliere` | casuale | 4% | 96% | 0% | 13.6 | 279.1 | 0% | 1 |
| El Muy Bonito | `giocoliere` | si_cura | 100% | 0% | 0% | 9.8 | 115.9 | 0% | 25 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | attacca | 0% | 100% | 0% | 14.2 | 285.0 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | difendi | 0% | 19% | 81% | 59.1 | 245.4 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | studia | 0% | 100% | 0% | 14.2 | 285.0 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | casuale | 0% | 91% | 9% | 42.8 | 283.1 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | si_cura | 0% | 100% | 0% | 31.3 | 285.0 | 0% | 0 |
| Goblin Tipico | `goblin_tipico` | attacca | 100% | 0% | 0% | 3.8 | 3.7 | 0% | 3 |
| Goblin Tipico | `goblin_tipico` | difendi | 0% | 0% | 100% | 60.0 | 24.3 | 0% | 0 |
| Goblin Tipico | `goblin_tipico` | studia | 100% | 0% | 0% | 6.8 | 7.5 | 0% | 3 |
| Goblin Tipico | `goblin_tipico` | casuale | 100% | 0% | 0% | 11.7 | 5.1 | 0% | 3 |
| Goblin Tipico | `goblin_tipico` | si_cura | 100% | 0% | 0% | 3.8 | 3.7 | 0% | 3 |
| Golem errante di rottami | `golem_errante` | attacca | 0% | 100% | 0% | 15.2 | 285.0 | 0% | 0 |
| Golem errante di rottami | `golem_errante` | difendi | 0% | 21% | 79% | 58.4 | 244.1 | 0% | 0 |
| Golem errante di rottami | `golem_errante` | studia | 0% | 100% | 0% | 14.5 | 285.0 | 0% | 0 |
| Golem errante di rottami | `golem_errante` | casuale | 0% | 75% | 25% | 43.2 | 276.0 | 0% | 0 |
| Golem errante di rottami | `golem_errante` | si_cura | 30% | 70% | 0% | 37.2 | 275.3 | 0% | 17 |
| Infetto Rapido | `infetto_rapido` | attacca | 100% | 0% | 0% | 2.9 | 5.5 | 0% | 3 |
| Infetto Rapido | `infetto_rapido` | difendi | 0% | 0% | 100% | 60.0 | 86.5 | 0% | 0 |
| Infetto Rapido | `infetto_rapido` | studia | 100% | 0% | 0% | 5.9 | 12.2 | 0% | 3 |
| Infetto Rapido | `infetto_rapido` | casuale | 100% | 0% | 0% | 9.3 | 14.3 | 0% | 3 |
| Infetto Rapido | `infetto_rapido` | si_cura | 100% | 0% | 0% | 2.9 | 5.5 | 0% | 3 |
| L'ultimo spettacolo di Jerah | `jerah` | attacca | 0% | 100% | 0% | 2.8 | 285.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | difendi | 0% | 100% | 0% | 3.1 | 285.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | studia | 0% | 100% | 0% | 2.8 | 285.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | casuale | 0% | 100% | 0% | 2.8 | 285.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | si_cura | 0% | 100% | 0% | 5.0 | 285.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | attacca | 0% | 100% | 0% | 5.5 | 285.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | difendi | 0% | 100% | 0% | 8.8 | 285.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | studia | 0% | 100% | 0% | 5.4 | 285.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | casuale | 0% | 100% | 0% | 6.0 | 285.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | si_cura | 0% | 100% | 0% | 11.2 | 285.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | attacca | 0% | 100% | 0% | 2.4 | 285.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | difendi | 0% | 100% | 0% | 2.8 | 285.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | studia | 0% | 100% | 0% | 2.5 | 285.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | casuale | 0% | 100% | 0% | 2.5 | 285.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | si_cura | 0% | 100% | 0% | 5.0 | 285.0 | 0% | 0 |
| ??? | `l_immortale` | attacca | 0% | 0% | 100% | 60.0 | 105.7 | 0% | 0 |
| ??? | `l_immortale` | difendi | 0% | 0% | 100% | 60.0 | 69.2 | 0% | 0 |
| ??? | `l_immortale` | studia | 0% | 0% | 100% | 60.0 | 103.1 | 0% | 0 |
| ??? | `l_immortale` | casuale | 0% | 0% | 100% | 60.0 | 70.5 | 0% | 0 |
| ??? | `l_immortale` | si_cura | 0% | 0% | 100% | 60.0 | 105.7 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | attacca | 99% | 1% | 0% | 10.9 | 212.5 | 0% | 30 |
| Madre in Lacrime | `madre_in_lacrime` | difendi | 0% | 21% | 79% | 58.4 | 242.7 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | studia | 64% | 36% | 0% | 13.4 | 259.5 | 0% | 19 |
| Madre in Lacrime | `madre_in_lacrime` | casuale | 75% | 25% | 0% | 31.9 | 229.1 | 0% | 22 |
| Madre in Lacrime | `madre_in_lacrime` | si_cura | 100% | 0% | 0% | 12.0 | 119.0 | 0% | 30 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | attacca | 0% | 100% | 0% | 8.0 | 285.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | difendi | 0% | 100% | 0% | 8.0 | 285.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | studia | 0% | 100% | 0% | 8.0 | 285.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | casuale | 0% | 100% | 0% | 8.0 | 285.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | si_cura | 0% | 100% | 0% | 8.0 | 285.0 | 0% | 0 |
| Marionetta | `marionetta` | attacca | 5% | 95% | 0% | 4.4 | 275.9 | 0% | 2 |
| Marionetta | `marionetta` | difendi | 0% | 100% | 0% | 7.2 | 285.0 | 0% | 0 |
| Marionetta | `marionetta` | studia | 0% | 100% | 0% | 4.5 | 285.0 | 0% | 0 |
| Marionetta | `marionetta` | casuale | 1% | 99% | 0% | 5.1 | 284.0 | 0% | 1 |
| Marionetta | `marionetta` | si_cura | 4% | 96% | 0% | 9.0 | 276.5 | 0% | 2 |
| Fomentado | `maschera_vuota` | attacca | 100% | 0% | 0% | 3.9 | 27.7 | 0% | 6 |
| Fomentado | `maschera_vuota` | difendi | 100% | 0% | 0% | 42.6 | 26.6 | 0% | 6 |
| Fomentado | `maschera_vuota` | studia | 100% | 0% | 0% | 6.9 | 21.5 | 0% | 6 |
| Fomentado | `maschera_vuota` | casuale | 100% | 0% | 0% | 10.4 | 20.9 | 0% | 6 |
| Fomentado | `maschera_vuota` | si_cura | 100% | 0% | 0% | 3.9 | 27.7 | 0% | 6 |
| Nuvola di Marciume | `nuvola_di_marciume` | attacca | 100% | 0% | 0% | 2.9 | 6.5 | 0% | 3 |
| Nuvola di Marciume | `nuvola_di_marciume` | difendi | 0% | 49% | 51% | 59.3 | 280.1 | 0% | 0 |
| Nuvola di Marciume | `nuvola_di_marciume` | studia | 100% | 0% | 0% | 5.9 | 20.9 | 0% | 3 |
| Nuvola di Marciume | `nuvola_di_marciume` | casuale | 100% | 0% | 0% | 9.4 | 33.0 | 0% | 3 |
| Nuvola di Marciume | `nuvola_di_marciume` | si_cura | 100% | 0% | 0% | 3.3 | 6.1 | 0% | 3 |
| Ombra del passato | `ombra_del_passato` | attacca | 3% | 97% | 0% | 4.0 | 278.5 | 0% | 2 |
| Ombra del passato | `ombra_del_passato` | difendi | 0% | 100% | 0% | 6.5 | 285.0 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | studia | 1% | 99% | 0% | 4.1 | 284.0 | 0% | 1 |
| Ombra del passato | `ombra_del_passato` | casuale | 2% | 98% | 0% | 4.6 | 283.5 | 0% | 1 |
| Ombra del passato | `ombra_del_passato` | si_cura | 6% | 94% | 0% | 10.0 | 275.1 | 0% | 3 |
| Emblema dell'oppressione | `operaio_posseduto` | attacca | 100% | 0% | 0% | 9.3 | 66.9 | 0% | 18 |
| Emblema dell'oppressione | `operaio_posseduto` | difendi | 0% | 0% | 100% | 60.0 | 163.7 | 0% | 0 |
| Emblema dell'oppressione | `operaio_posseduto` | studia | 100% | 0% | 0% | 12.3 | 87.0 | 0% | 18 |
| Emblema dell'oppressione | `operaio_posseduto` | casuale | 88% | 6% | 6% | 40.2 | 151.3 | 0% | 16 |
| Emblema dell'oppressione | `operaio_posseduto` | si_cura | 100% | 0% | 0% | 9.3 | 66.9 | 0% | 18 |
| Operaio Sfruttato | `operaio_sfruttato` | attacca | 100% | 0% | 0% | 14.4 | 167.7 | 0% | 39 |
| Operaio Sfruttato | `operaio_sfruttato` | difendi | 0% | 0% | 100% | 60.0 | 68.7 | 0% | 0 |
| Operaio Sfruttato | `operaio_sfruttato` | studia | 87% | 13% | 0% | 18.9 | 212.5 | 0% | 34 |
| Operaio Sfruttato | `operaio_sfruttato` | casuale | 12% | 4% | 84% | 57.6 | 149.7 | 0% | 5 |
| Operaio Sfruttato | `operaio_sfruttato` | si_cura | 100% | 0% | 0% | 15.2 | 103.8 | 0% | 39 |
| Orrore di Meridia | `orrore_di_meridia` | attacca | 7% | 93% | 0% | 20.6 | 280.0 | 0% | 3 |
| Orrore di Meridia | `orrore_di_meridia` | difendi | 0% | 0% | 100% | 60.0 | 75.4 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | studia | 1% | 99% | 0% | 20.9 | 285.0 | 0% | 1 |
| Orrore di Meridia | `orrore_di_meridia` | casuale | 5% | 21% | 75% | 57.4 | 198.6 | 0% | 2 |
| Orrore di Meridia | `orrore_di_meridia` | si_cura | 100% | 0% | 0% | 27.3 | 125.4 | 0% | 39 |
| Robo Pattuglia | `robo_pattuglia` | attacca | 100% | 0% | 0% | 12.2 | 28.0 | 0% | 14 |
| Robo Pattuglia | `robo_pattuglia` | difendi | 0% | 0% | 100% | 60.0 | 28.5 | 0% | 0 |
| Robo Pattuglia | `robo_pattuglia` | studia | 99% | 0% | 1% | 17.0 | 37.8 | 0% | 14 |
| Robo Pattuglia | `robo_pattuglia` | casuale | 40% | 0% | 60% | 51.2 | 28.4 | 0% | 6 |
| Robo Pattuglia | `robo_pattuglia` | si_cura | 100% | 0% | 0% | 12.2 | 28.0 | 0% | 14 |
| Sacerdote Folle | `sacerdote_folle` | attacca | 6% | 94% | 0% | 6.0 | 274.2 | 0% | 3 |
| Sacerdote Folle | `sacerdote_folle` | difendi | 0% | 100% | 0% | 16.7 | 285.0 | 0% | 0 |
| Sacerdote Folle | `sacerdote_folle` | studia | 1% | 99% | 0% | 6.1 | 284.4 | 0% | 1 |
| Sacerdote Folle | `sacerdote_folle` | casuale | 1% | 99% | 0% | 8.3 | 282.1 | 0% | 1 |
| Sacerdote Folle | `sacerdote_folle` | si_cura | 9% | 91% | 0% | 11.8 | 267.9 | 0% | 5 |
| Sadico | `sadico` | attacca | 7% | 93% | 0% | 8.8 | 270.6 | 0% | 2 |
| Sadico | `sadico` | difendi | 0% | 100% | 0% | 27.4 | 285.0 | 0% | 0 |
| Sadico | `sadico` | studia | 6% | 94% | 0% | 9.1 | 278.8 | 0% | 2 |
| Sadico | `sadico` | casuale | 6% | 94% | 0% | 14.6 | 277.6 | 0% | 2 |
| Sadico | `sadico` | si_cura | 85% | 15% | 0% | 19.7 | 219.7 | 0% | 30 |
| Slime Infimo | `slime_infimo` | attacca | 100% | 0% | 0% | 3.8 | 3.4 | 0% | 3 |
| Slime Infimo | `slime_infimo` | difendi | 0% | 0% | 100% | 60.0 | 27.4 | 0% | 0 |
| Slime Infimo | `slime_infimo` | studia | 100% | 0% | 0% | 6.8 | 6.4 | 0% | 3 |
| Slime Infimo | `slime_infimo` | casuale | 100% | 0% | 0% | 12.1 | 5.4 | 0% | 3 |
| Slime Infimo | `slime_infimo` | si_cura | 100% | 0% | 0% | 3.8 | 3.4 | 0% | 3 |
| Stigma | `stigma` | attacca | 12% | 88% | 0% | 10.1 | 267.6 | 0% | 4 |
| Stigma | `stigma` | difendi | 0% | 100% | 0% | 32.1 | 285.0 | 0% | 0 |
| Stigma | `stigma` | studia | 5% | 95% | 0% | 10.7 | 278.8 | 0% | 2 |
| Stigma | `stigma` | casuale | 5% | 95% | 0% | 18.7 | 280.3 | 0% | 2 |
| Stigma | `stigma` | si_cura | 100% | 0% | 0% | 17.1 | 127.5 | 0% | 35 |
| Tartaruga Innocente | `tartaruga_innocente` | attacca | 0% | 0% | 100% | 60.0 | 0.0 | 0% | 0 |
| Tartaruga Innocente | `tartaruga_innocente` | difendi | 0% | 0% | 100% | 60.0 | 0.0 | 0% | 0 |
| Tartaruga Innocente | `tartaruga_innocente` | studia | 100% | 0% | 0% | 2.0 | 0.0 | 100% | 1 |
| Tartaruga Innocente | `tartaruga_innocente` | casuale | 0% | 0% | 100% | 60.0 | 0.0 | 0% | 0 |
| Tartaruga Innocente | `tartaruga_innocente` | si_cura | 0% | 0% | 100% | 60.0 | 0.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | attacca | 0% | 100% | 0% | 4.0 | 285.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | difendi | 0% | 100% | 0% | 5.6 | 285.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | studia | 0% | 100% | 0% | 4.3 | 285.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | casuale | 0% | 100% | 0% | 4.4 | 285.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | si_cura | 0% | 100% | 0% | 5.1 | 285.0 | 0% | 0 |
| Teschio Errante | `teschio_errante` | attacca | 100% | 0% | 0% | 11.3 | 187.1 | 0% | 30 |
| Teschio Errante | `teschio_errante` | difendi | 0% | 3% | 97% | 59.9 | 212.8 | 0% | 0 |
| Teschio Errante | `teschio_errante` | studia | 94% | 6% | 0% | 14.3 | 238.4 | 0% | 28 |
| Teschio Errante | `teschio_errante` | casuale | 93% | 5% | 1% | 33.7 | 175.8 | 0% | 28 |
| Teschio Errante | `teschio_errante` | si_cura | 100% | 0% | 0% | 12.2 | 112.1 | 0% | 30 |
| Titano Zombie | `titano_zombie` | attacca | 0% | 100% | 0% | 8.1 | 285.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | difendi | 0% | 100% | 0% | 9.4 | 285.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | studia | 0% | 100% | 0% | 6.5 | 285.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | casuale | 0% | 100% | 0% | 7.3 | 285.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | si_cura | 0% | 100% | 0% | 16.5 | 285.0 | 0% | 0 |
| Capocantiere | `voce_registrata` | attacca | 100% | 0% | 0% | 5.7 | 38.3 | 0% | 11 |
| Capocantiere | `voce_registrata` | difendi | 0% | 0% | 100% | 60.0 | 51.1 | 0% | 0 |
| Capocantiere | `voce_registrata` | studia | 100% | 0% | 0% | 8.7 | 56.1 | 0% | 11 |
| Capocantiere | `voce_registrata` | casuale | 100% | 0% | 0% | 17.6 | 35.8 | 0% | 11 |
| Capocantiere | `voce_registrata` | si_cura | 100% | 0% | 0% | 5.7 | 38.3 | 0% | 11 |
| Volto sulla parete | `volto_sulla_parete` | attacca | 0% | 100% | 0% | 2.8 | 285.0 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | difendi | 0% | 100% | 0% | 3.0 | 285.0 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | studia | 0% | 100% | 0% | 2.9 | 285.0 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | casuale | 0% | 100% | 0% | 2.9 | 285.0 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | si_cura | 0% | 100% | 0% | 3.1 | 285.0 | 0% | 0 |
| Zombie Cittadino | `zombie_cittadino` | attacca | 100% | 0% | 0% | 3.8 | 3.0 | 0% | 3 |
| Zombie Cittadino | `zombie_cittadino` | difendi | 0% | 0% | 100% | 60.0 | 21.3 | 0% | 0 |
| Zombie Cittadino | `zombie_cittadino` | studia | 100% | 0% | 0% | 6.7 | 9.7 | 0% | 3 |
| Zombie Cittadino | `zombie_cittadino` | casuale | 100% | 0% | 0% | 11.6 | 6.8 | 0% | 3 |
| Zombie Cittadino | `zombie_cittadino` | si_cura | 100% | 0% | 0% | 3.8 | 3.0 | 0% | 3 |
| Zombie Mostruoso | `zombie_mostruoso` | attacca | 100% | 0% | 0% | 4.8 | 14.5 | 0% | 6 |
| Zombie Mostruoso | `zombie_mostruoso` | difendi | 0% | 0% | 100% | 60.0 | 30.0 | 0% | 0 |
| Zombie Mostruoso | `zombie_mostruoso` | studia | 100% | 0% | 0% | 7.8 | 26.5 | 0% | 6 |
| Zombie Mostruoso | `zombie_mostruoso` | casuale | 100% | 0% | 0% | 14.5 | 22.4 | 0% | 6 |
| Zombie Mostruoso | `zombie_mostruoso` | si_cura | 100% | 0% | 0% | 4.8 | 14.5 | 0% | 6 |

## Protagonista di livello 8

| creatura | id | come si gioca | vinte | perse | ∞ | giri | danno | risp. | xp |
|---|---|---|--:|--:|--:|--:|--:|--:|--:|
| Abominio Marcio | `abominio_marcio` | attacca | 0% | 100% | 0% | 13.4 | 425.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | difendi | 0% | 98% | 2% | 43.8 | 424.8 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | studia | 0% | 100% | 0% | 13.1 | 425.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | casuale | 0% | 100% | 0% | 28.9 | 425.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | si_cura | 0% | 100% | 0% | 27.1 | 425.0 | 0% | 0 |
| Oppresso | `comparsa_di_ruggine` | attacca | 100% | 0% | 0% | 7.3 | 9.5 | 0% | 12 |
| Oppresso | `comparsa_di_ruggine` | difendi | 0% | 0% | 100% | 60.0 | 18.1 | 0% | 0 |
| Oppresso | `comparsa_di_ruggine` | studia | 100% | 0% | 0% | 10.5 | 11.8 | 0% | 12 |
| Oppresso | `comparsa_di_ruggine` | casuale | 98% | 0% | 2% | 25.1 | 9.5 | 0% | 12 |
| Oppresso | `comparsa_di_ruggine` | si_cura | 100% | 0% | 0% | 7.3 | 9.5 | 0% | 12 |
| Diabolo | `diabolo` | attacca | 100% | 0% | 0% | 7.4 | 98.4 | 0% | 35 |
| Diabolo | `diabolo` | difendi | 38% | 0% | 62% | 52.8 | 85.6 | 0% | 14 |
| Diabolo | `diabolo` | studia | 100% | 0% | 0% | 10.5 | 125.2 | 0% | 35 |
| Diabolo | `diabolo` | casuale | 100% | 0% | 0% | 18.6 | 75.4 | 0% | 35 |
| Diabolo | `diabolo` | si_cura | 100% | 0% | 0% | 7.4 | 98.4 | 0% | 35 |
| Il Divoratore | `divoratore` | attacca | 100% | 0% | 0% | 18.6 | 150.5 | 0% | 34 |
| Il Divoratore | `divoratore` | difendi | 0% | 0% | 100% | 60.0 | 81.9 | 0% | 0 |
| Il Divoratore | `divoratore` | studia | 100% | 0% | 0% | 22.5 | 186.2 | 0% | 34 |
| Il Divoratore | `divoratore` | casuale | 71% | 0% | 29% | 51.7 | 95.0 | 0% | 24 |
| Il Divoratore | `divoratore` | si_cura | 100% | 0% | 0% | 18.6 | 150.5 | 0% | 34 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | attacca | 100% | 0% | 0% | 12.5 | 244.8 | 0% | 43 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | difendi | 0% | 0% | 100% | 60.0 | 165.7 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | studia | 100% | 0% | 0% | 14.2 | 279.7 | 0% | 43 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | casuale | 67% | 0% | 33% | 47.3 | 198.3 | 0% | 30 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | si_cura | 100% | 0% | 0% | 13.4 | 191.0 | 0% | 43 |
| Donna Spinosa | `donna_spinosa` | attacca | 17% | 83% | 0% | 10.5 | 390.7 | 0% | 8 |
| Donna Spinosa | `donna_spinosa` | difendi | 0% | 100% | 0% | 40.6 | 425.0 | 0% | 0 |
| Donna Spinosa | `donna_spinosa` | studia | 9% | 91% | 0% | 11.2 | 409.4 | 0% | 4 |
| Donna Spinosa | `donna_spinosa` | casuale | 9% | 91% | 0% | 23.7 | 411.7 | 0% | 4 |
| Donna Spinosa | `donna_spinosa` | si_cura | 71% | 29% | 0% | 19.2 | 353.3 | 0% | 36 |
| Rottami Erranti | `ferraglia_urlante` | attacca | 100% | 0% | 0% | 14.7 | 26.7 | 0% | 20 |
| Rottami Erranti | `ferraglia_urlante` | difendi | 0% | 0% | 100% | 60.0 | 39.4 | 0% | 0 |
| Rottami Erranti | `ferraglia_urlante` | studia | 100% | 0% | 0% | 17.7 | 33.7 | 0% | 20 |
| Rottami Erranti | `ferraglia_urlante` | casuale | 9% | 0% | 91% | 57.7 | 71.0 | 0% | 3 |
| Rottami Erranti | `ferraglia_urlante` | si_cura | 100% | 0% | 0% | 14.7 | 26.7 | 0% | 20 |
| Ghoul | `ghoul` | attacca | 100% | 0% | 0% | 7.0 | 89.5 | 0% | 30 |
| Ghoul | `ghoul` | difendi | 0% | 0% | 100% | 60.0 | 89.4 | 0% | 0 |
| Ghoul | `ghoul` | studia | 100% | 0% | 0% | 10.0 | 114.8 | 0% | 30 |
| Ghoul | `ghoul` | casuale | 100% | 0% | 0% | 21.2 | 81.7 | 0% | 30 |
| Ghoul | `ghoul` | si_cura | 100% | 0% | 0% | 7.0 | 89.5 | 0% | 30 |
| El Muy Bonito | `giocoliere` | attacca | 100% | 0% | 0% | 7.7 | 55.3 | 0% | 21 |
| El Muy Bonito | `giocoliere` | difendi | 0% | 0% | 100% | 60.0 | 68.6 | 0% | 0 |
| El Muy Bonito | `giocoliere` | studia | 100% | 0% | 0% | 9.9 | 168.1 | 0% | 21 |
| El Muy Bonito | `giocoliere` | casuale | 76% | 24% | 0% | 18.8 | 267.2 | 0% | 16 |
| El Muy Bonito | `giocoliere` | si_cura | 100% | 0% | 0% | 7.7 | 55.3 | 0% | 21 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | attacca | 0% | 100% | 0% | 19.9 | 425.0 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | difendi | 0% | 0% | 100% | 60.0 | 183.2 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | studia | 0% | 100% | 0% | 19.9 | 425.0 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | casuale | 0% | 3% | 97% | 59.7 | 256.3 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | si_cura | 17% | 83% | 0% | 34.5 | 420.5 | 0% | 37 |
| Goblin Tipico | `goblin_tipico` | attacca | 100% | 0% | 0% | 4.7 | 13.4 | 0% | 10 |
| Goblin Tipico | `goblin_tipico` | difendi | 0% | 0% | 100% | 60.0 | 41.1 | 0% | 0 |
| Goblin Tipico | `goblin_tipico` | studia | 100% | 0% | 0% | 7.7 | 20.3 | 0% | 10 |
| Goblin Tipico | `goblin_tipico` | casuale | 100% | 0% | 0% | 15.0 | 17.7 | 0% | 10 |
| Goblin Tipico | `goblin_tipico` | si_cura | 100% | 0% | 0% | 4.7 | 13.4 | 0% | 10 |
| Golem errante di rottami | `golem_errante` | attacca | 100% | 0% | 0% | 13.4 | 155.3 | 0% | 49 |
| Golem errante di rottami | `golem_errante` | difendi | 0% | 0% | 100% | 60.0 | 87.6 | 0% | 0 |
| Golem errante di rottami | `golem_errante` | studia | 100% | 0% | 0% | 16.5 | 196.4 | 0% | 49 |
| Golem errante di rottami | `golem_errante` | casuale | 40% | 0% | 60% | 55.8 | 127.9 | 0% | 21 |
| Golem errante di rottami | `golem_errante` | si_cura | 100% | 0% | 0% | 13.4 | 154.7 | 0% | 49 |
| Infetto Rapido | `infetto_rapido` | attacca | 100% | 0% | 0% | 3.0 | 11.2 | 0% | 10 |
| Infetto Rapido | `infetto_rapido` | difendi | 0% | 0% | 100% | 60.0 | 120.5 | 0% | 0 |
| Infetto Rapido | `infetto_rapido` | studia | 100% | 0% | 0% | 6.0 | 29.0 | 0% | 10 |
| Infetto Rapido | `infetto_rapido` | casuale | 100% | 0% | 0% | 9.6 | 26.4 | 0% | 10 |
| Infetto Rapido | `infetto_rapido` | si_cura | 100% | 0% | 0% | 3.0 | 11.2 | 0% | 10 |
| L'ultimo spettacolo di Jerah | `jerah` | attacca | 0% | 100% | 0% | 5.3 | 425.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | difendi | 0% | 100% | 0% | 7.4 | 425.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | studia | 0% | 100% | 0% | 5.5 | 425.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | casuale | 0% | 100% | 0% | 5.8 | 425.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | si_cura | 0% | 100% | 0% | 9.5 | 425.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | attacca | 0% | 100% | 0% | 11.9 | 425.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | difendi | 0% | 100% | 0% | 28.4 | 425.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | studia | 0% | 100% | 0% | 11.5 | 425.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | casuale | 0% | 100% | 0% | 20.2 | 425.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | si_cura | 0% | 100% | 0% | 23.0 | 425.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | attacca | 0% | 100% | 0% | 5.8 | 425.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | difendi | 0% | 100% | 0% | 9.9 | 425.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | studia | 0% | 100% | 0% | 5.8 | 425.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | casuale | 0% | 100% | 0% | 6.5 | 425.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | si_cura | 0% | 100% | 0% | 10.8 | 425.0 | 0% | 0 |
| ??? | `l_immortale` | attacca | 0% | 0% | 100% | 60.0 | 57.6 | 0% | 0 |
| ??? | `l_immortale` | difendi | 0% | 0% | 100% | 60.0 | 52.0 | 0% | 0 |
| ??? | `l_immortale` | studia | 0% | 0% | 100% | 60.0 | 57.5 | 0% | 0 |
| ??? | `l_immortale` | casuale | 0% | 0% | 100% | 60.0 | 52.3 | 0% | 0 |
| ??? | `l_immortale` | si_cura | 0% | 0% | 100% | 60.0 | 57.6 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | attacca | 100% | 0% | 0% | 6.8 | 77.1 | 0% | 30 |
| Madre in Lacrime | `madre_in_lacrime` | difendi | 0% | 0% | 100% | 60.0 | 104.1 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | studia | 100% | 0% | 0% | 9.8 | 101.8 | 0% | 30 |
| Madre in Lacrime | `madre_in_lacrime` | casuale | 100% | 0% | 0% | 20.7 | 76.4 | 0% | 30 |
| Madre in Lacrime | `madre_in_lacrime` | si_cura | 100% | 0% | 0% | 6.8 | 77.1 | 0% | 30 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | attacca | 0% | 100% | 0% | 11.0 | 425.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | difendi | 0% | 100% | 0% | 11.0 | 425.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | studia | 0% | 100% | 0% | 11.0 | 425.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | casuale | 0% | 100% | 0% | 11.0 | 425.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | si_cura | 0% | 100% | 0% | 11.0 | 425.0 | 0% | 0 |
| Marionetta | `marionetta` | attacca | 11% | 89% | 0% | 10.5 | 406.7 | 0% | 6 |
| Marionetta | `marionetta` | difendi | 0% | 71% | 29% | 52.0 | 412.0 | 0% | 0 |
| Marionetta | `marionetta` | studia | 7% | 93% | 0% | 10.1 | 411.7 | 0% | 4 |
| Marionetta | `marionetta` | casuale | 8% | 91% | 1% | 26.6 | 411.7 | 0% | 4 |
| Marionetta | `marionetta` | si_cura | 17% | 83% | 0% | 18.4 | 393.9 | 0% | 9 |
| Fomentado | `maschera_vuota` | attacca | 100% | 0% | 0% | 3.9 | 12.6 | 0% | 10 |
| Fomentado | `maschera_vuota` | difendi | 100% | 0% | 0% | 53.0 | 39.9 | 0% | 10 |
| Fomentado | `maschera_vuota` | studia | 100% | 0% | 0% | 6.9 | 51.9 | 0% | 10 |
| Fomentado | `maschera_vuota` | casuale | 100% | 0% | 0% | 10.9 | 28.3 | 0% | 10 |
| Fomentado | `maschera_vuota` | si_cura | 100% | 0% | 0% | 3.9 | 12.6 | 0% | 10 |
| Nuvola di Marciume | `nuvola_di_marciume` | attacca | 100% | 0% | 0% | 3.4 | 23.4 | 0% | 10 |
| Nuvola di Marciume | `nuvola_di_marciume` | difendi | 0% | 59% | 41% | 59.1 | 421.7 | 0% | 0 |
| Nuvola di Marciume | `nuvola_di_marciume` | studia | 100% | 0% | 0% | 6.7 | 55.5 | 0% | 10 |
| Nuvola di Marciume | `nuvola_di_marciume` | casuale | 100% | 0% | 0% | 12.1 | 81.7 | 0% | 10 |
| Nuvola di Marciume | `nuvola_di_marciume` | si_cura | 100% | 0% | 0% | 3.7 | 16.5 | 0% | 10 |
| Ombra del passato | `ombra_del_passato` | attacca | 17% | 83% | 0% | 9.6 | 395.6 | 0% | 10 |
| Ombra del passato | `ombra_del_passato` | difendi | 0% | 96% | 4% | 44.0 | 423.9 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | studia | 9% | 91% | 0% | 10.1 | 411.5 | 0% | 5 |
| Ombra del passato | `ombra_del_passato` | casuale | 11% | 89% | 0% | 20.3 | 412.0 | 0% | 6 |
| Ombra del passato | `ombra_del_passato` | si_cura | 37% | 63% | 0% | 16.5 | 374.5 | 0% | 21 |
| Emblema dell'oppressione | `operaio_posseduto` | attacca | 100% | 0% | 0% | 5.0 | 18.8 | 0% | 10 |
| Emblema dell'oppressione | `operaio_posseduto` | difendi | 0% | 0% | 100% | 60.0 | 111.9 | 0% | 0 |
| Emblema dell'oppressione | `operaio_posseduto` | studia | 100% | 0% | 0% | 8.9 | 26.8 | 0% | 10 |
| Emblema dell'oppressione | `operaio_posseduto` | casuale | 100% | 0% | 0% | 18.9 | 54.9 | 0% | 10 |
| Emblema dell'oppressione | `operaio_posseduto` | si_cura | 100% | 0% | 0% | 5.0 | 18.8 | 0% | 10 |
| Operaio Sfruttato | `operaio_sfruttato` | attacca | 100% | 0% | 0% | 7.9 | 62.4 | 0% | 21 |
| Operaio Sfruttato | `operaio_sfruttato` | difendi | 0% | 0% | 100% | 60.0 | 34.4 | 0% | 0 |
| Operaio Sfruttato | `operaio_sfruttato` | studia | 100% | 0% | 0% | 11.2 | 76.0 | 0% | 21 |
| Operaio Sfruttato | `operaio_sfruttato` | casuale | 99% | 0% | 1% | 27.3 | 43.0 | 0% | 21 |
| Operaio Sfruttato | `operaio_sfruttato` | si_cura | 100% | 0% | 0% | 7.9 | 62.4 | 0% | 21 |
| Orrore di Meridia | `orrore_di_meridia` | attacca | 100% | 0% | 0% | 12.9 | 142.2 | 0% | 21 |
| Orrore di Meridia | `orrore_di_meridia` | difendi | 0% | 0% | 100% | 60.0 | 40.8 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | studia | 100% | 0% | 0% | 16.6 | 123.9 | 0% | 21 |
| Orrore di Meridia | `orrore_di_meridia` | casuale | 77% | 5% | 17% | 46.3 | 375.2 | 0% | 17 |
| Orrore di Meridia | `orrore_di_meridia` | si_cura | 100% | 0% | 0% | 14.8 | 84.8 | 0% | 21 |
| Robo Pattuglia | `robo_pattuglia` | attacca | 100% | 0% | 0% | 8.8 | 7.7 | 0% | 12 |
| Robo Pattuglia | `robo_pattuglia` | difendi | 0% | 0% | 100% | 60.0 | 21.4 | 0% | 0 |
| Robo Pattuglia | `robo_pattuglia` | studia | 100% | 0% | 0% | 11.9 | 14.0 | 0% | 12 |
| Robo Pattuglia | `robo_pattuglia` | casuale | 87% | 0% | 13% | 32.6 | 13.7 | 0% | 10 |
| Robo Pattuglia | `robo_pattuglia` | si_cura | 100% | 0% | 0% | 8.8 | 7.7 | 0% | 12 |
| Sacerdote Folle | `sacerdote_folle` | attacca | 33% | 67% | 0% | 14.2 | 377.0 | 0% | 20 |
| Sacerdote Folle | `sacerdote_folle` | difendi | 0% | 78% | 22% | 51.4 | 413.8 | 0% | 0 |
| Sacerdote Folle | `sacerdote_folle` | studia | 15% | 85% | 0% | 14.3 | 406.5 | 0% | 8 |
| Sacerdote Folle | `sacerdote_folle` | casuale | 9% | 87% | 4% | 38.2 | 402.7 | 0% | 6 |
| Sacerdote Folle | `sacerdote_folle` | si_cura | 42% | 58% | 0% | 22.8 | 330.6 | 0% | 30 |
| Sadico | `sadico` | attacca | 100% | 0% | 0% | 8.6 | 157.0 | 0% | 35 |
| Sadico | `sadico` | difendi | 0% | 95% | 5% | 53.4 | 424.6 | 0% | 0 |
| Sadico | `sadico` | studia | 100% | 0% | 0% | 12.1 | 238.3 | 0% | 35 |
| Sadico | `sadico` | casuale | 91% | 9% | 0% | 27.4 | 271.6 | 0% | 32 |
| Sadico | `sadico` | si_cura | 100% | 0% | 0% | 10.0 | 154.2 | 0% | 35 |
| Slime Infimo | `slime_infimo` | attacca | 100% | 0% | 0% | 5.6 | 14.2 | 0% | 10 |
| Slime Infimo | `slime_infimo` | difendi | 0% | 0% | 100% | 60.0 | 50.2 | 0% | 0 |
| Slime Infimo | `slime_infimo` | studia | 100% | 0% | 0% | 8.6 | 30.4 | 0% | 10 |
| Slime Infimo | `slime_infimo` | casuale | 100% | 0% | 0% | 18.1 | 21.6 | 0% | 10 |
| Slime Infimo | `slime_infimo` | si_cura | 100% | 0% | 0% | 5.6 | 14.2 | 0% | 10 |
| Stigma | `stigma` | attacca | 100% | 0% | 0% | 8.2 | 145.0 | 0% | 35 |
| Stigma | `stigma` | difendi | 0% | 48% | 52% | 58.0 | 413.0 | 0% | 0 |
| Stigma | `stigma` | studia | 100% | 0% | 0% | 11.5 | 212.5 | 0% | 35 |
| Stigma | `stigma` | casuale | 99% | 1% | 0% | 25.7 | 230.7 | 0% | 35 |
| Stigma | `stigma` | si_cura | 100% | 0% | 0% | 8.2 | 123.3 | 0% | 35 |
| Tartaruga Innocente | `tartaruga_innocente` | attacca | 0% | 0% | 100% | 60.0 | 0.0 | 0% | 0 |
| Tartaruga Innocente | `tartaruga_innocente` | difendi | 0% | 0% | 100% | 60.0 | 0.0 | 0% | 0 |
| Tartaruga Innocente | `tartaruga_innocente` | studia | 100% | 0% | 0% | 2.0 | 0.0 | 100% | 1 |
| Tartaruga Innocente | `tartaruga_innocente` | casuale | 0% | 0% | 100% | 60.0 | 0.0 | 0% | 0 |
| Tartaruga Innocente | `tartaruga_innocente` | si_cura | 0% | 0% | 100% | 60.0 | 0.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | attacca | 0% | 100% | 0% | 7.5 | 425.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | difendi | 0% | 100% | 0% | 12.8 | 425.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | studia | 0% | 100% | 0% | 8.3 | 425.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | casuale | 0% | 100% | 0% | 9.6 | 425.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | si_cura | 0% | 100% | 0% | 10.0 | 425.0 | 0% | 0 |
| Teschio Errante | `teschio_errante` | attacca | 100% | 0% | 0% | 7.2 | 68.5 | 0% | 30 |
| Teschio Errante | `teschio_errante` | difendi | 0% | 0% | 100% | 60.0 | 92.8 | 0% | 0 |
| Teschio Errante | `teschio_errante` | studia | 100% | 0% | 0% | 10.1 | 85.2 | 0% | 30 |
| Teschio Errante | `teschio_errante` | casuale | 100% | 0% | 0% | 21.9 | 58.6 | 0% | 30 |
| Teschio Errante | `teschio_errante` | si_cura | 100% | 0% | 0% | 7.2 | 68.5 | 0% | 30 |
| Titano Zombie | `titano_zombie` | attacca | 0% | 100% | 0% | 14.4 | 425.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | difendi | 0% | 100% | 0% | 16.0 | 425.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | studia | 0% | 100% | 0% | 14.4 | 425.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | casuale | 0% | 100% | 0% | 15.8 | 425.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | si_cura | 0% | 100% | 0% | 24.0 | 425.0 | 0% | 0 |
| Capocantiere | `voce_registrata` | attacca | 100% | 0% | 0% | 4.7 | 21.3 | 0% | 10 |
| Capocantiere | `voce_registrata` | difendi | 0% | 0% | 100% | 60.0 | 38.0 | 0% | 0 |
| Capocantiere | `voce_registrata` | studia | 100% | 0% | 0% | 7.8 | 40.9 | 0% | 10 |
| Capocantiere | `voce_registrata` | casuale | 100% | 0% | 0% | 15.1 | 22.2 | 0% | 10 |
| Capocantiere | `voce_registrata` | si_cura | 100% | 0% | 0% | 4.7 | 21.3 | 0% | 10 |
| Volto sulla parete | `volto_sulla_parete` | attacca | 0% | 100% | 0% | 5.7 | 425.0 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | difendi | 0% | 100% | 0% | 11.1 | 425.0 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | studia | 0% | 100% | 0% | 5.7 | 425.0 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | casuale | 0% | 100% | 0% | 6.6 | 425.0 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | si_cura | 0% | 100% | 0% | 10.2 | 425.0 | 0% | 0 |
| Zombie Cittadino | `zombie_cittadino` | attacca | 100% | 0% | 0% | 4.7 | 18.8 | 0% | 10 |
| Zombie Cittadino | `zombie_cittadino` | difendi | 0% | 0% | 100% | 60.0 | 34.4 | 0% | 0 |
| Zombie Cittadino | `zombie_cittadino` | studia | 100% | 0% | 0% | 7.7 | 33.8 | 0% | 10 |
| Zombie Cittadino | `zombie_cittadino` | casuale | 100% | 0% | 0% | 15.1 | 19.2 | 0% | 10 |
| Zombie Cittadino | `zombie_cittadino` | si_cura | 100% | 0% | 0% | 4.7 | 18.8 | 0% | 10 |
| Zombie Mostruoso | `zombie_mostruoso` | attacca | 100% | 0% | 0% | 4.8 | 25.9 | 0% | 10 |
| Zombie Mostruoso | `zombie_mostruoso` | difendi | 0% | 0% | 100% | 60.0 | 39.1 | 0% | 0 |
| Zombie Mostruoso | `zombie_mostruoso` | studia | 100% | 0% | 0% | 7.8 | 40.9 | 0% | 10 |
| Zombie Mostruoso | `zombie_mostruoso` | casuale | 100% | 0% | 0% | 14.9 | 31.9 | 0% | 10 |
| Zombie Mostruoso | `zombie_mostruoso` | si_cura | 100% | 0% | 0% | 4.8 | 25.9 | 0% | 10 |

## Protagonista di livello 12

| creatura | id | come si gioca | vinte | perse | ∞ | giri | danno | risp. | xp |
|---|---|---|--:|--:|--:|--:|--:|--:|--:|
| Abominio Marcio | `abominio_marcio` | attacca | 100% | 0% | 0% | 17.1 | 369.9 | 0% | 60 |
| Abominio Marcio | `abominio_marcio` | difendi | 0% | 49% | 51% | 58.3 | 590.3 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | studia | 99% | 1% | 0% | 19.8 | 449.2 | 0% | 59 |
| Abominio Marcio | `abominio_marcio` | casuale | 7% | 69% | 23% | 54.8 | 597.3 | 0% | 4 |
| Abominio Marcio | `abominio_marcio` | si_cura | 100% | 0% | 0% | 18.2 | 272.4 | 0% | 60 |
| Oppresso | `comparsa_di_ruggine` | attacca | 100% | 0% | 0% | 9.3 | 19.7 | 0% | 23 |
| Oppresso | `comparsa_di_ruggine` | difendi | 0% | 0% | 100% | 60.0 | 20.9 | 0% | 0 |
| Oppresso | `comparsa_di_ruggine` | studia | 100% | 0% | 0% | 13.2 | 27.1 | 0% | 23 |
| Oppresso | `comparsa_di_ruggine` | casuale | 66% | 0% | 34% | 41.6 | 19.4 | 0% | 15 |
| Oppresso | `comparsa_di_ruggine` | si_cura | 100% | 0% | 0% | 9.3 | 19.7 | 0% | 23 |
| Diabolo | `diabolo` | attacca | 100% | 0% | 0% | 4.9 | 29.8 | 0% | 19 |
| Diabolo | `diabolo` | difendi | 55% | 0% | 45% | 46.6 | 42.4 | 0% | 11 |
| Diabolo | `diabolo` | studia | 100% | 0% | 0% | 7.9 | 45.5 | 0% | 19 |
| Diabolo | `diabolo` | casuale | 100% | 0% | 0% | 13.1 | 24.5 | 0% | 19 |
| Diabolo | `diabolo` | si_cura | 100% | 0% | 0% | 4.9 | 29.8 | 0% | 19 |
| Il Divoratore | `divoratore` | attacca | 100% | 0% | 0% | 18.2 | 181.2 | 0% | 42 |
| Il Divoratore | `divoratore` | difendi | 0% | 0% | 100% | 60.0 | 89.8 | 0% | 0 |
| Il Divoratore | `divoratore` | studia | 100% | 0% | 0% | 21.2 | 207.8 | 0% | 42 |
| Il Divoratore | `divoratore` | casuale | 67% | 0% | 33% | 50.9 | 109.6 | 0% | 29 |
| Il Divoratore | `divoratore` | si_cura | 100% | 0% | 0% | 18.2 | 181.2 | 0% | 42 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | attacca | 100% | 0% | 0% | 7.4 | 60.1 | 0% | 37 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | difendi | 0% | 0% | 100% | 60.0 | 86.3 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | studia | 100% | 0% | 0% | 10.5 | 101.4 | 0% | 37 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | casuale | 100% | 0% | 0% | 27.8 | 63.7 | 0% | 37 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | si_cura | 100% | 0% | 0% | 7.4 | 60.1 | 0% | 37 |
| Donna Spinosa | `donna_spinosa` | attacca | 100% | 0% | 0% | 8.6 | 219.6 | 0% | 51 |
| Donna Spinosa | `donna_spinosa` | difendi | 0% | 71% | 29% | 57.4 | 606.5 | 0% | 0 |
| Donna Spinosa | `donna_spinosa` | studia | 100% | 0% | 0% | 12.1 | 298.0 | 0% | 51 |
| Donna Spinosa | `donna_spinosa` | casuale | 98% | 2% | 0% | 26.5 | 346.0 | 0% | 50 |
| Donna Spinosa | `donna_spinosa` | si_cura | 100% | 0% | 0% | 10.2 | 228.8 | 0% | 51 |
| Rottami Erranti | `ferraglia_urlante` | attacca | 100% | 0% | 0% | 14.3 | 19.1 | 0% | 24 |
| Rottami Erranti | `ferraglia_urlante` | difendi | 1% | 0% | 99% | 60.0 | 33.8 | 0% | 0 |
| Rottami Erranti | `ferraglia_urlante` | studia | 100% | 0% | 0% | 17.5 | 28.1 | 0% | 24 |
| Rottami Erranti | `ferraglia_urlante` | casuale | 24% | 0% | 76% | 56.0 | 59.3 | 0% | 10 |
| Rottami Erranti | `ferraglia_urlante` | si_cura | 100% | 0% | 0% | 14.3 | 19.1 | 0% | 24 |
| Ghoul | `ghoul` | attacca | 100% | 0% | 0% | 5.3 | 52.8 | 0% | 19 |
| Ghoul | `ghoul` | difendi | 0% | 0% | 100% | 60.0 | 60.0 | 0% | 0 |
| Ghoul | `ghoul` | studia | 100% | 0% | 0% | 8.3 | 69.3 | 0% | 19 |
| Ghoul | `ghoul` | casuale | 100% | 0% | 0% | 18.2 | 48.3 | 0% | 19 |
| Ghoul | `ghoul` | si_cura | 100% | 0% | 0% | 5.3 | 52.8 | 0% | 19 |
| El Muy Bonito | `giocoliere` | attacca | 100% | 0% | 0% | 8.7 | 110.9 | 0% | 42 |
| El Muy Bonito | `giocoliere` | difendi | 0% | 0% | 100% | 60.0 | 98.2 | 0% | 0 |
| El Muy Bonito | `giocoliere` | studia | 100% | 0% | 0% | 11.6 | 333.9 | 0% | 42 |
| El Muy Bonito | `giocoliere` | casuale | 67% | 33% | 0% | 21.7 | 422.6 | 0% | 28 |
| El Muy Bonito | `giocoliere` | si_cura | 100% | 0% | 0% | 8.7 | 110.9 | 0% | 42 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | attacca | 0% | 100% | 0% | 20.2 | 610.0 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | difendi | 0% | 0% | 100% | 60.0 | 227.0 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | studia | 0% | 100% | 0% | 20.2 | 610.0 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | casuale | 0% | 1% | 99% | 59.8 | 349.3 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | si_cura | 2% | 98% | 0% | 30.5 | 609.5 | 0% | 7 |
| Goblin Tipico | `goblin_tipico` | attacca | 100% | 0% | 0% | 5.4 | 22.8 | 0% | 19 |
| Goblin Tipico | `goblin_tipico` | difendi | 0% | 0% | 100% | 60.0 | 54.0 | 0% | 0 |
| Goblin Tipico | `goblin_tipico` | studia | 100% | 0% | 0% | 8.5 | 46.0 | 0% | 19 |
| Goblin Tipico | `goblin_tipico` | casuale | 100% | 0% | 0% | 17.5 | 35.4 | 0% | 19 |
| Goblin Tipico | `goblin_tipico` | si_cura | 100% | 0% | 0% | 5.4 | 22.8 | 0% | 19 |
| Golem errante di rottami | `golem_errante` | attacca | 100% | 0% | 0% | 10.9 | 117.0 | 0% | 42 |
| Golem errante di rottami | `golem_errante` | difendi | 0% | 0% | 100% | 60.0 | 82.0 | 0% | 0 |
| Golem errante di rottami | `golem_errante` | studia | 100% | 0% | 0% | 14.0 | 154.3 | 0% | 42 |
| Golem errante di rottami | `golem_errante` | casuale | 83% | 0% | 17% | 47.3 | 104.3 | 0% | 35 |
| Golem errante di rottami | `golem_errante` | si_cura | 100% | 0% | 0% | 10.9 | 117.0 | 0% | 42 |
| Infetto Rapido | `infetto_rapido` | attacca | 100% | 0% | 0% | 3.8 | 33.0 | 0% | 21 |
| Infetto Rapido | `infetto_rapido` | difendi | 0% | 0% | 100% | 60.0 | 143.3 | 0% | 0 |
| Infetto Rapido | `infetto_rapido` | studia | 100% | 0% | 0% | 6.8 | 64.1 | 0% | 21 |
| Infetto Rapido | `infetto_rapido` | casuale | 100% | 0% | 0% | 12.0 | 50.6 | 0% | 21 |
| Infetto Rapido | `infetto_rapido` | si_cura | 100% | 0% | 0% | 3.8 | 33.0 | 0% | 21 |
| L'ultimo spettacolo di Jerah | `jerah` | attacca | 0% | 100% | 0% | 9.5 | 610.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | difendi | 0% | 99% | 1% | 20.2 | 609.2 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | studia | 0% | 100% | 0% | 11.1 | 610.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | casuale | 0% | 97% | 3% | 16.4 | 606.4 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | si_cura | 0% | 100% | 0% | 15.5 | 610.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | attacca | 0% | 100% | 0% | 22.2 | 610.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | difendi | 0% | 77% | 23% | 53.7 | 593.7 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | studia | 0% | 100% | 0% | 22.8 | 610.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | casuale | 0% | 91% | 9% | 48.0 | 606.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | si_cura | 5% | 95% | 0% | 38.2 | 607.2 | 0% | 18 |
| Jongo Dongo | `jongo_dongo_risorto` | attacca | 0% | 100% | 0% | 13.4 | 610.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | difendi | 0% | 77% | 23% | 52.2 | 597.4 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | studia | 0% | 100% | 0% | 13.5 | 610.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | casuale | 0% | 99% | 1% | 31.3 | 609.9 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | si_cura | 0% | 100% | 0% | 22.4 | 610.0 | 0% | 0 |
| ??? | `l_immortale` | attacca | 0% | 0% | 100% | 60.0 | 39.9 | 0% | 0 |
| ??? | `l_immortale` | difendi | 0% | 0% | 100% | 60.0 | 38.0 | 0% | 0 |
| ??? | `l_immortale` | studia | 0% | 0% | 100% | 60.0 | 40.2 | 0% | 0 |
| ??? | `l_immortale` | casuale | 0% | 0% | 100% | 60.0 | 38.1 | 0% | 0 |
| ??? | `l_immortale` | si_cura | 0% | 0% | 100% | 60.0 | 39.9 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | attacca | 100% | 0% | 0% | 4.9 | 39.1 | 0% | 19 |
| Madre in Lacrime | `madre_in_lacrime` | difendi | 0% | 0% | 100% | 60.0 | 65.4 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | studia | 100% | 0% | 0% | 7.9 | 61.7 | 0% | 19 |
| Madre in Lacrime | `madre_in_lacrime` | casuale | 100% | 0% | 0% | 16.1 | 42.9 | 0% | 19 |
| Madre in Lacrime | `madre_in_lacrime` | si_cura | 100% | 0% | 0% | 4.9 | 39.1 | 0% | 19 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | attacca | 0% | 100% | 0% | 14.0 | 610.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | difendi | 0% | 100% | 0% | 14.0 | 610.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | studia | 0% | 100% | 0% | 14.0 | 610.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | casuale | 0% | 100% | 0% | 14.0 | 610.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | si_cura | 0% | 100% | 0% | 14.0 | 610.0 | 0% | 0 |
| Marionetta | `marionetta` | attacca | 100% | 0% | 0% | 9.2 | 185.1 | 0% | 51 |
| Marionetta | `marionetta` | difendi | 0% | 0% | 100% | 60.0 | 155.9 | 0% | 0 |
| Marionetta | `marionetta` | studia | 100% | 0% | 0% | 12.2 | 253.1 | 0% | 51 |
| Marionetta | `marionetta` | casuale | 97% | 0% | 3% | 35.3 | 194.8 | 0% | 49 |
| Marionetta | `marionetta` | si_cura | 100% | 0% | 0% | 9.2 | 185.1 | 0% | 51 |
| Fomentado | `maschera_vuota` | attacca | 100% | 0% | 0% | 4.9 | 68.1 | 0% | 19 |
| Fomentado | `maschera_vuota` | difendi | 0% | 0% | 100% | 60.0 | 53.8 | 0% | 0 |
| Fomentado | `maschera_vuota` | studia | 100% | 0% | 0% | 7.8 | 81.2 | 0% | 19 |
| Fomentado | `maschera_vuota` | casuale | 100% | 0% | 0% | 13.0 | 53.5 | 0% | 19 |
| Fomentado | `maschera_vuota` | si_cura | 100% | 0% | 0% | 4.9 | 68.1 | 0% | 19 |
| Nuvola di Marciume | `nuvola_di_marciume` | attacca | 100% | 0% | 0% | 4.0 | 48.8 | 0% | 21 |
| Nuvola di Marciume | `nuvola_di_marciume` | difendi | 0% | 71% | 29% | 58.7 | 607.4 | 0% | 0 |
| Nuvola di Marciume | `nuvola_di_marciume` | studia | 100% | 0% | 0% | 7.4 | 113.9 | 0% | 21 |
| Nuvola di Marciume | `nuvola_di_marciume` | casuale | 100% | 0% | 0% | 12.8 | 146.6 | 0% | 21 |
| Nuvola di Marciume | `nuvola_di_marciume` | si_cura | 100% | 0% | 0% | 5.0 | 46.9 | 0% | 21 |
| Ombra del passato | `ombra_del_passato` | attacca | 100% | 0% | 0% | 8.4 | 223.8 | 0% | 55 |
| Ombra del passato | `ombra_del_passato` | difendi | 0% | 0% | 100% | 60.0 | 171.3 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | studia | 100% | 0% | 0% | 11.4 | 277.0 | 0% | 55 |
| Ombra del passato | `ombra_del_passato` | casuale | 99% | 1% | 0% | 24.8 | 217.3 | 0% | 55 |
| Ombra del passato | `ombra_del_passato` | si_cura | 100% | 0% | 0% | 8.4 | 223.8 | 0% | 55 |
| Emblema dell'oppressione | `operaio_posseduto` | attacca | 100% | 0% | 0% | 6.5 | 25.4 | 0% | 19 |
| Emblema dell'oppressione | `operaio_posseduto` | difendi | 0% | 0% | 100% | 60.0 | 118.4 | 0% | 0 |
| Emblema dell'oppressione | `operaio_posseduto` | studia | 100% | 0% | 0% | 9.5 | 37.5 | 0% | 19 |
| Emblema dell'oppressione | `operaio_posseduto` | casuale | 100% | 0% | 0% | 22.9 | 79.5 | 0% | 19 |
| Emblema dell'oppressione | `operaio_posseduto` | si_cura | 100% | 0% | 0% | 6.5 | 25.4 | 0% | 19 |
| Operaio Sfruttato | `operaio_sfruttato` | attacca | 100% | 0% | 0% | 9.5 | 103.5 | 0% | 42 |
| Operaio Sfruttato | `operaio_sfruttato` | difendi | 0% | 0% | 100% | 60.0 | 56.7 | 0% | 0 |
| Operaio Sfruttato | `operaio_sfruttato` | studia | 100% | 0% | 0% | 13.0 | 133.4 | 0% | 42 |
| Operaio Sfruttato | `operaio_sfruttato` | casuale | 87% | 0% | 13% | 38.9 | 126.6 | 0% | 37 |
| Operaio Sfruttato | `operaio_sfruttato` | si_cura | 100% | 0% | 0% | 9.5 | 103.5 | 0% | 42 |
| Orrore di Meridia | `orrore_di_meridia` | attacca | 100% | 0% | 0% | 17.7 | 521.3 | 0% | 42 |
| Orrore di Meridia | `orrore_di_meridia` | difendi | 0% | 0% | 100% | 60.0 | 65.3 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | studia | 100% | 0% | 0% | 21.7 | 535.9 | 0% | 42 |
| Orrore di Meridia | `orrore_di_meridia` | casuale | 38% | 18% | 44% | 53.6 | 531.7 | 0% | 17 |
| Orrore di Meridia | `orrore_di_meridia` | si_cura | 100% | 0% | 0% | 20.6 | 366.5 | 0% | 42 |
| Robo Pattuglia | `robo_pattuglia` | attacca | 100% | 0% | 0% | 11.1 | 27.2 | 0% | 23 |
| Robo Pattuglia | `robo_pattuglia` | difendi | 0% | 0% | 100% | 60.0 | 25.4 | 0% | 0 |
| Robo Pattuglia | `robo_pattuglia` | studia | 100% | 0% | 0% | 14.9 | 36.5 | 0% | 23 |
| Robo Pattuglia | `robo_pattuglia` | casuale | 54% | 0% | 46% | 45.5 | 23.8 | 0% | 12 |
| Robo Pattuglia | `robo_pattuglia` | si_cura | 100% | 0% | 0% | 11.1 | 27.2 | 0% | 23 |
| Sacerdote Folle | `sacerdote_folle` | attacca | 100% | 0% | 0% | 10.2 | 110.4 | 0% | 47 |
| Sacerdote Folle | `sacerdote_folle` | difendi | 0% | 0% | 100% | 60.0 | 242.7 | 0% | 0 |
| Sacerdote Folle | `sacerdote_folle` | studia | 100% | 0% | 0% | 19.6 | 235.8 | 0% | 58 |
| Sacerdote Folle | `sacerdote_folle` | casuale | 21% | 0% | 79% | 53.8 | 244.7 | 0% | 12 |
| Sacerdote Folle | `sacerdote_folle` | si_cura | 100% | 0% | 0% | 10.2 | 110.4 | 0% | 47 |
| Sadico | `sadico` | attacca | 100% | 0% | 0% | 5.4 | 68.8 | 0% | 19 |
| Sadico | `sadico` | difendi | 0% | 4% | 96% | 59.9 | 568.0 | 0% | 0 |
| Sadico | `sadico` | studia | 100% | 0% | 0% | 9.0 | 111.0 | 0% | 19 |
| Sadico | `sadico` | casuale | 100% | 0% | 0% | 20.0 | 187.7 | 0% | 19 |
| Sadico | `sadico` | si_cura | 100% | 0% | 0% | 6.0 | 56.1 | 0% | 19 |
| Slime Infimo | `slime_infimo` | attacca | 100% | 0% | 0% | 5.8 | 34.2 | 0% | 19 |
| Slime Infimo | `slime_infimo` | difendi | 0% | 0% | 100% | 60.0 | 59.3 | 0% | 0 |
| Slime Infimo | `slime_infimo` | studia | 100% | 0% | 0% | 8.9 | 48.6 | 0% | 19 |
| Slime Infimo | `slime_infimo` | casuale | 99% | 0% | 1% | 22.8 | 38.3 | 0% | 19 |
| Slime Infimo | `slime_infimo` | si_cura | 100% | 0% | 0% | 5.8 | 34.2 | 0% | 19 |
| Stigma | `stigma` | attacca | 100% | 0% | 0% | 5.2 | 54.7 | 0% | 19 |
| Stigma | `stigma` | difendi | 0% | 0% | 100% | 60.0 | 524.3 | 0% | 0 |
| Stigma | `stigma` | studia | 100% | 0% | 0% | 8.6 | 94.0 | 0% | 19 |
| Stigma | `stigma` | casuale | 100% | 0% | 0% | 17.6 | 132.8 | 0% | 19 |
| Stigma | `stigma` | si_cura | 100% | 0% | 0% | 5.3 | 46.7 | 0% | 19 |
| Tartaruga Innocente | `tartaruga_innocente` | attacca | 100% | 0% | 0% | 9.7 | 0.0 | 0% | 1 |
| Tartaruga Innocente | `tartaruga_innocente` | difendi | 0% | 0% | 100% | 60.0 | 0.0 | 0% | 0 |
| Tartaruga Innocente | `tartaruga_innocente` | studia | 100% | 0% | 0% | 2.0 | 0.0 | 100% | 1 |
| Tartaruga Innocente | `tartaruga_innocente` | casuale | 0% | 0% | 100% | 60.0 | 0.0 | 0% | 0 |
| Tartaruga Innocente | `tartaruga_innocente` | si_cura | 100% | 0% | 0% | 9.7 | 0.0 | 0% | 1 |
| Un tenero ricordo | `tenero_ricordo` | attacca | 0% | 100% | 0% | 14.4 | 610.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | difendi | 0% | 100% | 0% | 18.6 | 610.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | studia | 0% | 100% | 0% | 16.1 | 610.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | casuale | 0% | 100% | 0% | 18.4 | 610.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | si_cura | 0% | 100% | 0% | 17.0 | 610.0 | 0% | 0 |
| Teschio Errante | `teschio_errante` | attacca | 100% | 0% | 0% | 5.2 | 33.5 | 0% | 19 |
| Teschio Errante | `teschio_errante` | difendi | 0% | 0% | 100% | 60.0 | 57.2 | 0% | 0 |
| Teschio Errante | `teschio_errante` | studia | 100% | 0% | 0% | 8.3 | 44.6 | 0% | 19 |
| Teschio Errante | `teschio_errante` | casuale | 100% | 0% | 0% | 16.9 | 29.9 | 0% | 19 |
| Teschio Errante | `teschio_errante` | si_cura | 100% | 0% | 0% | 5.2 | 33.5 | 0% | 19 |
| Titano Zombie | `titano_zombie` | attacca | 99% | 1% | 0% | 16.6 | 477.8 | 0% | 59 |
| Titano Zombie | `titano_zombie` | difendi | 0% | 100% | 0% | 27.2 | 610.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | studia | 90% | 10% | 0% | 18.5 | 510.8 | 0% | 54 |
| Titano Zombie | `titano_zombie` | casuale | 1% | 99% | 0% | 30.3 | 609.8 | 0% | 0 |
| Titano Zombie | `titano_zombie` | si_cura | 100% | 0% | 0% | 21.4 | 375.3 | 0% | 60 |
| Capocantiere | `voce_registrata` | attacca | 100% | 0% | 0% | 4.9 | 36.8 | 0% | 19 |
| Capocantiere | `voce_registrata` | difendi | 0% | 0% | 100% | 60.0 | 50.5 | 0% | 0 |
| Capocantiere | `voce_registrata` | studia | 100% | 0% | 0% | 7.9 | 61.7 | 0% | 19 |
| Capocantiere | `voce_registrata` | casuale | 100% | 0% | 0% | 15.5 | 36.0 | 0% | 19 |
| Capocantiere | `voce_registrata` | si_cura | 100% | 0% | 0% | 4.9 | 36.8 | 0% | 19 |
| Volto sulla parete | `volto_sulla_parete` | attacca | 0% | 100% | 0% | 12.5 | 610.0 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | difendi | 0% | 100% | 0% | 37.9 | 610.0 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | studia | 0% | 100% | 0% | 12.5 | 610.0 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | casuale | 0% | 100% | 0% | 24.1 | 610.0 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | si_cura | 0% | 100% | 0% | 21.5 | 610.0 | 0% | 0 |
| Zombie Cittadino | `zombie_cittadino` | attacca | 100% | 0% | 0% | 4.9 | 34.6 | 0% | 19 |
| Zombie Cittadino | `zombie_cittadino` | difendi | 0% | 0% | 100% | 60.0 | 44.6 | 0% | 0 |
| Zombie Cittadino | `zombie_cittadino` | studia | 100% | 0% | 0% | 7.9 | 52.4 | 0% | 19 |
| Zombie Cittadino | `zombie_cittadino` | casuale | 100% | 0% | 0% | 15.3 | 29.4 | 0% | 19 |
| Zombie Cittadino | `zombie_cittadino` | si_cura | 100% | 0% | 0% | 4.9 | 34.6 | 0% | 19 |
| Zombie Mostruoso | `zombie_mostruoso` | attacca | 100% | 0% | 0% | 4.9 | 42.0 | 0% | 19 |
| Zombie Mostruoso | `zombie_mostruoso` | difendi | 0% | 0% | 100% | 60.0 | 52.1 | 0% | 0 |
| Zombie Mostruoso | `zombie_mostruoso` | studia | 100% | 0% | 0% | 7.9 | 59.1 | 0% | 19 |
| Zombie Mostruoso | `zombie_mostruoso` | casuale | 100% | 0% | 0% | 15.6 | 49.0 | 0% | 19 |
| Zombie Mostruoso | `zombie_mostruoso` | si_cura | 100% | 0% | 0% | 4.9 | 42.0 | 0% | 19 |

## Protagonista di livello 18

| creatura | id | come si gioca | vinte | perse | ∞ | giri | danno | risp. | xp |
|---|---|---|--:|--:|--:|--:|--:|--:|--:|
| Abominio Marcio | `abominio_marcio` | attacca | 100% | 0% | 0% | 16.9 | 478.8 | 0% | 71 |
| Abominio Marcio | `abominio_marcio` | difendi | 0% | 29% | 71% | 59.3 | 842.2 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | studia | 100% | 0% | 0% | 19.3 | 564.0 | 0% | 71 |
| Abominio Marcio | `abominio_marcio` | casuale | 9% | 52% | 39% | 56.4 | 855.3 | 0% | 7 |
| Abominio Marcio | `abominio_marcio` | si_cura | 100% | 0% | 0% | 17.4 | 370.3 | 0% | 71 |
| Oppresso | `comparsa_di_ruggine` | attacca | 100% | 0% | 0% | 11.8 | 42.9 | 0% | 39 |
| Oppresso | `comparsa_di_ruggine` | difendi | 0% | 0% | 100% | 60.0 | 25.9 | 0% | 0 |
| Oppresso | `comparsa_di_ruggine` | studia | 99% | 0% | 1% | 17.2 | 62.7 | 0% | 38 |
| Oppresso | `comparsa_di_ruggine` | casuale | 41% | 0% | 59% | 50.0 | 32.4 | 0% | 16 |
| Oppresso | `comparsa_di_ruggine` | si_cura | 100% | 0% | 0% | 11.8 | 42.9 | 0% | 39 |
| Diabolo | `diabolo` | attacca | 100% | 0% | 0% | 5.7 | 60.5 | 0% | 32 |
| Diabolo | `diabolo` | difendi | 49% | 0% | 51% | 49.2 | 59.5 | 0% | 16 |
| Diabolo | `diabolo` | studia | 100% | 0% | 0% | 8.6 | 82.1 | 0% | 32 |
| Diabolo | `diabolo` | casuale | 100% | 0% | 0% | 15.1 | 41.8 | 0% | 32 |
| Diabolo | `diabolo` | si_cura | 100% | 0% | 0% | 5.7 | 60.5 | 0% | 32 |
| Il Divoratore | `divoratore` | attacca | 100% | 0% | 0% | 22.8 | 390.7 | 0% | 71 |
| Il Divoratore | `divoratore` | difendi | 0% | 0% | 100% | 60.0 | 131.7 | 0% | 0 |
| Il Divoratore | `divoratore` | studia | 100% | 0% | 0% | 21.6 | 358.8 | 0% | 71 |
| Il Divoratore | `divoratore` | casuale | 45% | 0% | 55% | 56.0 | 196.2 | 0% | 35 |
| Il Divoratore | `divoratore` | si_cura | 100% | 0% | 0% | 22.8 | 389.5 | 0% | 71 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | attacca | 100% | 0% | 0% | 6.8 | 34.0 | 0% | 32 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | difendi | 0% | 0% | 100% | 60.0 | 71.7 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | studia | 100% | 0% | 0% | 9.8 | 72.9 | 0% | 32 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | casuale | 99% | 0% | 1% | 23.6 | 44.7 | 0% | 32 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | si_cura | 100% | 0% | 0% | 6.8 | 34.0 | 0% | 32 |
| Donna Spinosa | `donna_spinosa` | attacca | 100% | 0% | 0% | 6.1 | 108.4 | 0% | 32 |
| Donna Spinosa | `donna_spinosa` | difendi | 0% | 0% | 100% | 60.0 | 807.5 | 0% | 0 |
| Donna Spinosa | `donna_spinosa` | studia | 100% | 0% | 0% | 9.6 | 197.9 | 0% | 32 |
| Donna Spinosa | `donna_spinosa` | casuale | 100% | 0% | 0% | 20.7 | 285.4 | 0% | 32 |
| Donna Spinosa | `donna_spinosa` | si_cura | 100% | 0% | 0% | 7.0 | 96.4 | 0% | 32 |
| Rottami Erranti | `ferraglia_urlante` | attacca | 100% | 0% | 0% | 21.3 | 138.9 | 0% | 53 |
| Rottami Erranti | `ferraglia_urlante` | difendi | 0% | 0% | 100% | 60.0 | 43.9 | 0% | 0 |
| Rottami Erranti | `ferraglia_urlante` | studia | 100% | 0% | 0% | 28.0 | 227.1 | 0% | 58 |
| Rottami Erranti | `ferraglia_urlante` | casuale | 4% | 0% | 96% | 59.5 | 104.7 | 0% | 5 |
| Rottami Erranti | `ferraglia_urlante` | si_cura | 100% | 0% | 0% | 21.3 | 138.9 | 0% | 53 |
| Ghoul | `ghoul` | attacca | 100% | 0% | 0% | 5.7 | 83.5 | 0% | 32 |
| Ghoul | `ghoul` | difendi | 0% | 0% | 100% | 60.0 | 88.6 | 0% | 0 |
| Ghoul | `ghoul` | studia | 100% | 0% | 0% | 8.8 | 122.2 | 0% | 32 |
| Ghoul | `ghoul` | casuale | 100% | 0% | 0% | 18.0 | 80.0 | 0% | 32 |
| Ghoul | `ghoul` | si_cura | 100% | 0% | 0% | 5.7 | 83.5 | 0% | 32 |
| El Muy Bonito | `giocoliere` | attacca | 100% | 0% | 0% | 9.9 | 207.1 | 0% | 71 |
| El Muy Bonito | `giocoliere` | difendi | 0% | 0% | 100% | 60.0 | 131.7 | 0% | 0 |
| El Muy Bonito | `giocoliere` | studia | 100% | 0% | 0% | 12.6 | 453.3 | 0% | 71 |
| El Muy Bonito | `giocoliere` | casuale | 67% | 33% | 0% | 26.3 | 654.7 | 0% | 47 |
| El Muy Bonito | `giocoliere` | si_cura | 100% | 0% | 0% | 9.9 | 207.1 | 0% | 71 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | attacca | 0% | 100% | 0% | 22.5 | 890.0 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | difendi | 0% | 0% | 100% | 60.0 | 275.4 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | studia | 0% | 100% | 0% | 22.8 | 890.0 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | casuale | 0% | 1% | 99% | 60.0 | 429.2 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | si_cura | 3% | 97% | 0% | 30.7 | 886.6 | 0% | 17 |
| Goblin Tipico | `goblin_tipico` | attacca | 100% | 0% | 0% | 5.6 | 32.5 | 0% | 32 |
| Goblin Tipico | `goblin_tipico` | difendi | 0% | 0% | 100% | 60.0 | 78.3 | 0% | 0 |
| Goblin Tipico | `goblin_tipico` | studia | 100% | 0% | 0% | 8.7 | 65.5 | 0% | 32 |
| Goblin Tipico | `goblin_tipico` | casuale | 100% | 0% | 0% | 18.7 | 53.1 | 0% | 32 |
| Goblin Tipico | `goblin_tipico` | si_cura | 100% | 0% | 0% | 5.6 | 32.5 | 0% | 32 |
| Golem errante di rottami | `golem_errante` | attacca | 100% | 0% | 0% | 12.4 | 220.6 | 0% | 71 |
| Golem errante di rottami | `golem_errante` | difendi | 0% | 0% | 100% | 60.0 | 124.5 | 0% | 0 |
| Golem errante di rottami | `golem_errante` | studia | 100% | 0% | 0% | 15.5 | 282.5 | 0% | 71 |
| Golem errante di rottami | `golem_errante` | casuale | 49% | 0% | 51% | 54.9 | 192.1 | 0% | 38 |
| Golem errante di rottami | `golem_errante` | si_cura | 100% | 0% | 0% | 12.4 | 220.6 | 0% | 71 |
| Infetto Rapido | `infetto_rapido` | attacca | 100% | 0% | 0% | 3.9 | 66.3 | 0% | 36 |
| Infetto Rapido | `infetto_rapido` | difendi | 0% | 0% | 100% | 60.0 | 170.2 | 0% | 0 |
| Infetto Rapido | `infetto_rapido` | studia | 100% | 0% | 0% | 6.9 | 110.9 | 0% | 36 |
| Infetto Rapido | `infetto_rapido` | casuale | 100% | 0% | 0% | 12.5 | 88.1 | 0% | 36 |
| Infetto Rapido | `infetto_rapido` | si_cura | 100% | 0% | 0% | 3.9 | 66.3 | 0% | 36 |
| L'ultimo spettacolo di Jerah | `jerah` | attacca | 0% | 100% | 0% | 17.0 | 890.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | difendi | 0% | 86% | 14% | 35.6 | 866.8 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | studia | 5% | 95% | 0% | 20.3 | 886.2 | 0% | 23 |
| L'ultimo spettacolo di Jerah | `jerah` | casuale | 0% | 69% | 31% | 39.7 | 812.7 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | si_cura | 2% | 98% | 0% | 24.6 | 888.4 | 0% | 10 |
| Jongo Dongo | `jongo_dongo` | attacca | 1% | 99% | 0% | 23.6 | 889.7 | 0% | 4 |
| Jongo Dongo | `jongo_dongo` | difendi | 0% | 77% | 23% | 54.1 | 870.9 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | studia | 0% | 100% | 0% | 24.2 | 890.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | casuale | 0% | 87% | 13% | 49.2 | 874.2 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | si_cura | 9% | 91% | 0% | 36.5 | 881.1 | 0% | 56 |
| Jongo Dongo | `jongo_dongo_risorto` | attacca | 0% | 100% | 0% | 24.7 | 890.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | difendi | 0% | 0% | 100% | 60.0 | 411.1 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | studia | 0% | 100% | 0% | 23.9 | 890.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | casuale | 0% | 2% | 98% | 59.7 | 593.2 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | si_cura | 0% | 100% | 0% | 35.6 | 890.0 | 0% | 0 |
| ??? | `l_immortale` | attacca | 0% | 0% | 100% | 60.0 | 26.0 | 0% | 0 |
| ??? | `l_immortale` | difendi | 0% | 0% | 100% | 60.0 | 26.0 | 0% | 0 |
| ??? | `l_immortale` | studia | 0% | 0% | 100% | 60.0 | 26.0 | 0% | 0 |
| ??? | `l_immortale` | casuale | 0% | 0% | 100% | 60.0 | 26.0 | 0% | 0 |
| ??? | `l_immortale` | si_cura | 0% | 0% | 100% | 60.0 | 26.0 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | attacca | 100% | 0% | 0% | 5.7 | 76.9 | 0% | 32 |
| Madre in Lacrime | `madre_in_lacrime` | difendi | 0% | 0% | 100% | 60.0 | 98.6 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | studia | 100% | 0% | 0% | 8.6 | 109.1 | 0% | 32 |
| Madre in Lacrime | `madre_in_lacrime` | casuale | 100% | 0% | 0% | 17.9 | 76.8 | 0% | 32 |
| Madre in Lacrime | `madre_in_lacrime` | si_cura | 100% | 0% | 0% | 5.7 | 76.9 | 0% | 32 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | attacca | 0% | 100% | 0% | 14.0 | 890.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | difendi | 0% | 100% | 0% | 14.0 | 890.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | studia | 0% | 100% | 0% | 14.0 | 890.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | casuale | 0% | 100% | 0% | 14.0 | 890.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | si_cura | 0% | 100% | 0% | 14.0 | 890.0 | 0% | 0 |
| Marionetta | `marionetta` | attacca | 100% | 0% | 0% | 6.8 | 53.4 | 0% | 32 |
| Marionetta | `marionetta` | difendi | 0% | 0% | 100% | 60.0 | 87.9 | 0% | 0 |
| Marionetta | `marionetta` | studia | 100% | 0% | 0% | 9.8 | 103.9 | 0% | 32 |
| Marionetta | `marionetta` | casuale | 100% | 0% | 0% | 22.4 | 67.2 | 0% | 32 |
| Marionetta | `marionetta` | si_cura | 100% | 0% | 0% | 6.8 | 53.4 | 0% | 32 |
| Fomentado | `maschera_vuota` | attacca | 100% | 0% | 0% | 5.0 | 98.5 | 0% | 32 |
| Fomentado | `maschera_vuota` | difendi | 0% | 0% | 100% | 60.0 | 75.0 | 0% | 0 |
| Fomentado | `maschera_vuota` | studia | 100% | 0% | 0% | 8.0 | 133.4 | 0% | 32 |
| Fomentado | `maschera_vuota` | casuale | 100% | 0% | 0% | 14.1 | 85.3 | 0% | 32 |
| Fomentado | `maschera_vuota` | si_cura | 100% | 0% | 0% | 5.0 | 98.5 | 0% | 32 |
| Nuvola di Marciume | `nuvola_di_marciume` | attacca | 100% | 0% | 0% | 4.4 | 101.5 | 0% | 36 |
| Nuvola di Marciume | `nuvola_di_marciume` | difendi | 0% | 21% | 79% | 59.8 | 877.5 | 0% | 0 |
| Nuvola di Marciume | `nuvola_di_marciume` | studia | 100% | 0% | 0% | 7.7 | 186.4 | 0% | 36 |
| Nuvola di Marciume | `nuvola_di_marciume` | casuale | 100% | 0% | 0% | 15.2 | 246.2 | 0% | 36 |
| Nuvola di Marciume | `nuvola_di_marciume` | si_cura | 100% | 0% | 0% | 5.2 | 87.3 | 0% | 36 |
| Ombra del passato | `ombra_del_passato` | attacca | 100% | 0% | 0% | 5.8 | 90.6 | 0% | 32 |
| Ombra del passato | `ombra_del_passato` | difendi | 0% | 0% | 100% | 60.0 | 87.5 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | studia | 100% | 0% | 0% | 8.9 | 129.1 | 0% | 32 |
| Ombra del passato | `ombra_del_passato` | casuale | 100% | 0% | 0% | 17.7 | 79.5 | 0% | 32 |
| Ombra del passato | `ombra_del_passato` | si_cura | 100% | 0% | 0% | 5.8 | 90.6 | 0% | 32 |
| Emblema dell'oppressione | `operaio_posseduto` | attacca | 100% | 0% | 0% | 6.5 | 31.6 | 0% | 32 |
| Emblema dell'oppressione | `operaio_posseduto` | difendi | 0% | 0% | 100% | 60.0 | 129.3 | 0% | 0 |
| Emblema dell'oppressione | `operaio_posseduto` | studia | 100% | 0% | 0% | 9.5 | 59.8 | 0% | 32 |
| Emblema dell'oppressione | `operaio_posseduto` | casuale | 100% | 0% | 0% | 23.4 | 109.8 | 0% | 32 |
| Emblema dell'oppressione | `operaio_posseduto` | si_cura | 100% | 0% | 0% | 6.5 | 31.6 | 0% | 32 |
| Operaio Sfruttato | `operaio_sfruttato` | attacca | 100% | 0% | 0% | 11.5 | 223.8 | 0% | 71 |
| Operaio Sfruttato | `operaio_sfruttato` | difendi | 0% | 0% | 100% | 60.0 | 82.4 | 0% | 0 |
| Operaio Sfruttato | `operaio_sfruttato` | studia | 100% | 0% | 0% | 15.3 | 266.6 | 0% | 71 |
| Operaio Sfruttato | `operaio_sfruttato` | casuale | 45% | 0% | 55% | 50.7 | 268.5 | 0% | 33 |
| Operaio Sfruttato | `operaio_sfruttato` | si_cura | 100% | 0% | 0% | 11.5 | 223.8 | 0% | 71 |
| Orrore di Meridia | `orrore_di_meridia` | attacca | 99% | 1% | 0% | 21.2 | 495.7 | 0% | 71 |
| Orrore di Meridia | `orrore_di_meridia` | difendi | 0% | 0% | 100% | 60.0 | 92.1 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | studia | 99% | 1% | 0% | 24.1 | 852.4 | 0% | 70 |
| Orrore di Meridia | `orrore_di_meridia` | casuale | 19% | 13% | 68% | 56.7 | 658.8 | 0% | 15 |
| Orrore di Meridia | `orrore_di_meridia` | si_cura | 100% | 0% | 0% | 22.6 | 444.3 | 0% | 71 |
| Robo Pattuglia | `robo_pattuglia` | attacca | 100% | 0% | 0% | 14.0 | 59.1 | 0% | 39 |
| Robo Pattuglia | `robo_pattuglia` | difendi | 0% | 0% | 100% | 60.0 | 34.0 | 0% | 0 |
| Robo Pattuglia | `robo_pattuglia` | studia | 97% | 0% | 3% | 20.5 | 88.1 | 0% | 38 |
| Robo Pattuglia | `robo_pattuglia` | casuale | 28% | 0% | 72% | 53.0 | 39.9 | 0% | 11 |
| Robo Pattuglia | `robo_pattuglia` | si_cura | 100% | 0% | 0% | 14.0 | 59.1 | 0% | 39 |
| Sacerdote Folle | `sacerdote_folle` | attacca | 100% | 0% | 0% | 9.1 | 90.0 | 0% | 44 |
| Sacerdote Folle | `sacerdote_folle` | difendi | 0% | 0% | 100% | 60.0 | 254.2 | 0% | 0 |
| Sacerdote Folle | `sacerdote_folle` | studia | 100% | 0% | 0% | 16.6 | 219.7 | 0% | 55 |
| Sacerdote Folle | `sacerdote_folle` | casuale | 33% | 0% | 67% | 51.7 | 257.2 | 0% | 21 |
| Sacerdote Folle | `sacerdote_folle` | si_cura | 100% | 0% | 0% | 9.1 | 90.0 | 0% | 44 |
| Sadico | `sadico` | attacca | 100% | 0% | 0% | 6.1 | 112.3 | 0% | 32 |
| Sadico | `sadico` | difendi | 0% | 3% | 97% | 59.9 | 820.5 | 0% | 0 |
| Sadico | `sadico` | studia | 100% | 0% | 0% | 9.5 | 196.6 | 0% | 32 |
| Sadico | `sadico` | casuale | 100% | 0% | 0% | 20.6 | 289.5 | 0% | 32 |
| Sadico | `sadico` | si_cura | 100% | 0% | 0% | 7.0 | 100.7 | 0% | 32 |
| Slime Infimo | `slime_infimo` | attacca | 100% | 0% | 0% | 6.7 | 48.2 | 0% | 32 |
| Slime Infimo | `slime_infimo` | difendi | 0% | 0% | 100% | 60.0 | 79.9 | 0% | 0 |
| Slime Infimo | `slime_infimo` | studia | 100% | 0% | 0% | 9.8 | 96.0 | 0% | 32 |
| Slime Infimo | `slime_infimo` | casuale | 98% | 0% | 2% | 27.7 | 62.2 | 0% | 32 |
| Slime Infimo | `slime_infimo` | si_cura | 100% | 0% | 0% | 6.7 | 48.2 | 0% | 32 |
| Stigma | `stigma` | attacca | 100% | 0% | 0% | 5.9 | 95.4 | 0% | 32 |
| Stigma | `stigma` | difendi | 0% | 1% | 99% | 60.0 | 763.0 | 0% | 0 |
| Stigma | `stigma` | studia | 100% | 0% | 0% | 9.2 | 165.9 | 0% | 32 |
| Stigma | `stigma` | casuale | 100% | 0% | 0% | 19.4 | 225.6 | 0% | 32 |
| Stigma | `stigma` | si_cura | 100% | 0% | 0% | 6.1 | 80.0 | 0% | 32 |
| Tartaruga Innocente | `tartaruga_innocente` | attacca | 100% | 0% | 0% | 5.7 | 0.0 | 0% | 1 |
| Tartaruga Innocente | `tartaruga_innocente` | difendi | 0% | 0% | 100% | 60.0 | 0.0 | 0% | 0 |
| Tartaruga Innocente | `tartaruga_innocente` | studia | 100% | 0% | 0% | 2.0 | 0.0 | 100% | 1 |
| Tartaruga Innocente | `tartaruga_innocente` | casuale | 23% | 0% | 77% | 49.3 | 0.0 | 0% | 0 |
| Tartaruga Innocente | `tartaruga_innocente` | si_cura | 100% | 0% | 0% | 5.7 | 0.0 | 0% | 1 |
| Un tenero ricordo | `tenero_ricordo` | attacca | 0% | 100% | 0% | 24.4 | 890.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | difendi | 0% | 100% | 0% | 25.4 | 890.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | studia | 0% | 100% | 0% | 25.0 | 890.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | casuale | 0% | 100% | 0% | 26.6 | 890.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | si_cura | 0% | 100% | 0% | 25.8 | 890.0 | 0% | 0 |
| Teschio Errante | `teschio_errante` | attacca | 100% | 0% | 0% | 6.0 | 58.4 | 0% | 32 |
| Teschio Errante | `teschio_errante` | difendi | 0% | 0% | 100% | 60.0 | 85.4 | 0% | 0 |
| Teschio Errante | `teschio_errante` | studia | 100% | 0% | 0% | 8.9 | 84.6 | 0% | 32 |
| Teschio Errante | `teschio_errante` | casuale | 100% | 0% | 0% | 18.6 | 47.3 | 0% | 32 |
| Teschio Errante | `teschio_errante` | si_cura | 100% | 0% | 0% | 6.0 | 58.4 | 0% | 32 |
| Titano Zombie | `titano_zombie` | attacca | 100% | 0% | 0% | 16.4 | 684.3 | 0% | 71 |
| Titano Zombie | `titano_zombie` | difendi | 0% | 99% | 1% | 30.6 | 889.9 | 0% | 0 |
| Titano Zombie | `titano_zombie` | studia | 97% | 3% | 0% | 18.4 | 727.3 | 0% | 69 |
| Titano Zombie | `titano_zombie` | casuale | 1% | 99% | 0% | 32.7 | 889.7 | 0% | 1 |
| Titano Zombie | `titano_zombie` | si_cura | 100% | 0% | 0% | 21.2 | 598.6 | 0% | 71 |
| Capocantiere | `voce_registrata` | attacca | 100% | 0% | 0% | 5.7 | 72.3 | 0% | 32 |
| Capocantiere | `voce_registrata` | difendi | 0% | 0% | 100% | 60.0 | 71.7 | 0% | 0 |
| Capocantiere | `voce_registrata` | studia | 100% | 0% | 0% | 8.7 | 105.1 | 0% | 32 |
| Capocantiere | `voce_registrata` | casuale | 100% | 0% | 0% | 17.6 | 62.6 | 0% | 32 |
| Capocantiere | `voce_registrata` | si_cura | 100% | 0% | 0% | 5.7 | 72.3 | 0% | 32 |
| Volto sulla parete | `volto_sulla_parete` | attacca | 21% | 79% | 0% | 27.9 | 875.4 | 0% | 30 |
| Volto sulla parete | `volto_sulla_parete` | difendi | 0% | 33% | 67% | 59.3 | 851.0 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | studia | 12% | 88% | 0% | 28.6 | 875.3 | 0% | 17 |
| Volto sulla parete | `volto_sulla_parete` | casuale | 0% | 70% | 30% | 56.2 | 874.3 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | si_cura | 57% | 43% | 0% | 39.1 | 771.4 | 0% | 82 |
| Zombie Cittadino | `zombie_cittadino` | attacca | 100% | 0% | 0% | 5.7 | 69.2 | 0% | 32 |
| Zombie Cittadino | `zombie_cittadino` | difendi | 0% | 0% | 100% | 60.0 | 63.5 | 0% | 0 |
| Zombie Cittadino | `zombie_cittadino` | studia | 100% | 0% | 0% | 8.7 | 96.6 | 0% | 32 |
| Zombie Cittadino | `zombie_cittadino` | casuale | 100% | 0% | 0% | 17.7 | 52.5 | 0% | 32 |
| Zombie Cittadino | `zombie_cittadino` | si_cura | 100% | 0% | 0% | 5.7 | 69.2 | 0% | 32 |
| Zombie Mostruoso | `zombie_mostruoso` | attacca | 100% | 0% | 0% | 5.7 | 79.2 | 0% | 32 |
| Zombie Mostruoso | `zombie_mostruoso` | difendi | 0% | 0% | 100% | 60.0 | 76.3 | 0% | 0 |
| Zombie Mostruoso | `zombie_mostruoso` | studia | 100% | 0% | 0% | 8.7 | 109.2 | 0% | 32 |
| Zombie Mostruoso | `zombie_mostruoso` | casuale | 100% | 0% | 0% | 18.0 | 81.6 | 0% | 32 |
| Zombie Mostruoso | `zombie_mostruoso` | si_cura | 100% | 0% | 0% | 5.7 | 79.2 | 0% | 32 |

## Protagonista di livello 25

| creatura | id | come si gioca | vinte | perse | ∞ | giri | danno | risp. | xp |
|---|---|---|--:|--:|--:|--:|--:|--:|--:|
| Abominio Marcio | `abominio_marcio` | attacca | 100% | 0% | 0% | 17.7 | 730.5 | 0% | 101 |
| Abominio Marcio | `abominio_marcio` | difendi | 0% | 31% | 69% | 59.1 | 1154.9 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | studia | 100% | 0% | 0% | 22.0 | 920.3 | 0% | 101 |
| Abominio Marcio | `abominio_marcio` | casuale | 6% | 57% | 37% | 56.3 | 1178.0 | 0% | 6 |
| Abominio Marcio | `abominio_marcio` | si_cura | 100% | 0% | 0% | 20.7 | 611.3 | 0% | 101 |
| Oppresso | `comparsa_di_ruggine` | attacca | 98% | 0% | 2% | 14.8 | 78.6 | 0% | 54 |
| Oppresso | `comparsa_di_ruggine` | difendi | 0% | 0% | 100% | 60.0 | 27.2 | 0% | 0 |
| Oppresso | `comparsa_di_ruggine` | studia | 91% | 0% | 9% | 23.0 | 122.4 | 0% | 51 |
| Oppresso | `comparsa_di_ruggine` | casuale | 24% | 0% | 76% | 54.2 | 37.7 | 0% | 13 |
| Oppresso | `comparsa_di_ruggine` | si_cura | 98% | 0% | 2% | 14.8 | 78.6 | 0% | 54 |
| Diabolo | `diabolo` | attacca | 100% | 0% | 0% | 6.5 | 90.6 | 0% | 46 |
| Diabolo | `diabolo` | difendi | 34% | 0% | 66% | 53.4 | 81.9 | 0% | 17 |
| Diabolo | `diabolo` | studia | 100% | 0% | 0% | 9.6 | 127.4 | 0% | 46 |
| Diabolo | `diabolo` | casuale | 100% | 0% | 0% | 16.4 | 69.9 | 0% | 46 |
| Diabolo | `diabolo` | si_cura | 100% | 0% | 0% | 6.5 | 90.6 | 0% | 46 |
| Il Divoratore | `divoratore` | attacca | 100% | 0% | 0% | 24.3 | 626.4 | 0% | 101 |
| Il Divoratore | `divoratore` | difendi | 0% | 0% | 100% | 60.0 | 176.0 | 0% | 0 |
| Il Divoratore | `divoratore` | studia | 100% | 0% | 0% | 25.3 | 615.6 | 0% | 101 |
| Il Divoratore | `divoratore` | casuale | 34% | 0% | 66% | 57.6 | 271.6 | 0% | 38 |
| Il Divoratore | `divoratore` | si_cura | 100% | 0% | 0% | 24.8 | 589.2 | 0% | 101 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | attacca | 100% | 0% | 0% | 7.5 | 74.9 | 0% | 46 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | difendi | 0% | 0% | 100% | 60.0 | 86.9 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | studia | 100% | 0% | 0% | 10.4 | 109.0 | 0% | 46 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | casuale | 100% | 0% | 0% | 25.4 | 72.9 | 0% | 46 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | si_cura | 100% | 0% | 0% | 7.5 | 74.9 | 0% | 46 |
| Donna Spinosa | `donna_spinosa` | attacca | 100% | 0% | 0% | 6.9 | 173.4 | 0% | 46 |
| Donna Spinosa | `donna_spinosa` | difendi | 0% | 0% | 100% | 60.0 | 1115.1 | 0% | 0 |
| Donna Spinosa | `donna_spinosa` | studia | 100% | 0% | 0% | 10.4 | 289.7 | 0% | 46 |
| Donna Spinosa | `donna_spinosa` | casuale | 100% | 0% | 0% | 22.4 | 437.3 | 0% | 46 |
| Donna Spinosa | `donna_spinosa` | si_cura | 100% | 0% | 0% | 8.0 | 160.4 | 0% | 46 |
| Rottami Erranti | `ferraglia_urlante` | attacca | 100% | 0% | 0% | 28.1 | 356.4 | 0% | 93 |
| Rottami Erranti | `ferraglia_urlante` | difendi | 0% | 0% | 100% | 60.0 | 41.2 | 0% | 0 |
| Rottami Erranti | `ferraglia_urlante` | studia | 100% | 0% | 0% | 32.5 | 392.8 | 0% | 89 |
| Rottami Erranti | `ferraglia_urlante` | casuale | 2% | 0% | 98% | 59.9 | 134.0 | 0% | 2 |
| Rottami Erranti | `ferraglia_urlante` | si_cura | 100% | 0% | 0% | 28.1 | 356.4 | 0% | 93 |
| Ghoul | `ghoul` | attacca | 100% | 0% | 0% | 6.5 | 124.5 | 0% | 46 |
| Ghoul | `ghoul` | difendi | 0% | 0% | 100% | 60.0 | 123.0 | 0% | 0 |
| Ghoul | `ghoul` | studia | 100% | 0% | 0% | 9.5 | 183.0 | 0% | 46 |
| Ghoul | `ghoul` | casuale | 100% | 0% | 0% | 20.3 | 129.8 | 0% | 46 |
| Ghoul | `ghoul` | si_cura | 100% | 0% | 0% | 6.5 | 124.5 | 0% | 46 |
| El Muy Bonito | `giocoliere` | attacca | 100% | 0% | 0% | 10.6 | 316.0 | 0% | 101 |
| El Muy Bonito | `giocoliere` | difendi | 0% | 0% | 100% | 60.0 | 166.4 | 0% | 0 |
| El Muy Bonito | `giocoliere` | studia | 100% | 0% | 0% | 13.6 | 571.1 | 0% | 101 |
| El Muy Bonito | `giocoliere` | casuale | 84% | 16% | 0% | 29.8 | 750.9 | 0% | 85 |
| El Muy Bonito | `giocoliere` | si_cura | 100% | 0% | 0% | 10.6 | 316.0 | 0% | 101 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | attacca | 0% | 100% | 0% | 21.8 | 1220.0 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | difendi | 0% | 0% | 100% | 60.0 | 366.1 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | studia | 0% | 100% | 0% | 21.7 | 1220.0 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | casuale | 0% | 1% | 99% | 59.9 | 606.1 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | si_cura | 0% | 100% | 0% | 27.7 | 1220.0 | 0% | 0 |
| Goblin Tipico | `goblin_tipico` | attacca | 100% | 0% | 0% | 6.5 | 80.8 | 0% | 46 |
| Goblin Tipico | `goblin_tipico` | difendi | 0% | 0% | 100% | 60.0 | 108.4 | 0% | 0 |
| Goblin Tipico | `goblin_tipico` | studia | 100% | 0% | 0% | 9.6 | 133.2 | 0% | 46 |
| Goblin Tipico | `goblin_tipico` | casuale | 100% | 0% | 0% | 20.6 | 92.2 | 0% | 46 |
| Goblin Tipico | `goblin_tipico` | si_cura | 100% | 0% | 0% | 6.5 | 80.8 | 0% | 46 |
| Golem errante di rottami | `golem_errante` | attacca | 100% | 0% | 0% | 13.4 | 342.1 | 0% | 101 |
| Golem errante di rottami | `golem_errante` | difendi | 0% | 0% | 100% | 60.0 | 167.4 | 0% | 0 |
| Golem errante di rottami | `golem_errante` | studia | 100% | 0% | 0% | 16.8 | 447.1 | 0% | 101 |
| Golem errante di rottami | `golem_errante` | casuale | 35% | 0% | 65% | 57.0 | 280.5 | 0% | 40 |
| Golem errante di rottami | `golem_errante` | si_cura | 100% | 0% | 0% | 13.4 | 342.1 | 0% | 101 |
| Infetto Rapido | `infetto_rapido` | attacca | 100% | 0% | 0% | 3.9 | 104.3 | 0% | 51 |
| Infetto Rapido | `infetto_rapido` | difendi | 0% | 0% | 100% | 60.0 | 190.5 | 0% | 0 |
| Infetto Rapido | `infetto_rapido` | studia | 100% | 0% | 0% | 6.9 | 173.4 | 0% | 51 |
| Infetto Rapido | `infetto_rapido` | casuale | 100% | 0% | 0% | 12.6 | 115.3 | 0% | 51 |
| Infetto Rapido | `infetto_rapido` | si_cura | 100% | 0% | 0% | 3.9 | 104.3 | 0% | 51 |
| L'ultimo spettacolo di Jerah | `jerah` | attacca | 0% | 100% | 0% | 16.3 | 1220.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | difendi | 0% | 88% | 12% | 33.9 | 1201.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | studia | 1% | 99% | 0% | 18.2 | 1218.8 | 0% | 9 |
| L'ultimo spettacolo di Jerah | `jerah` | casuale | 0% | 83% | 17% | 35.4 | 1187.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | si_cura | 1% | 99% | 0% | 21.6 | 1216.8 | 0% | 4 |
| Jongo Dongo | `jongo_dongo` | attacca | 0% | 100% | 0% | 23.0 | 1220.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | difendi | 0% | 77% | 23% | 54.0 | 1184.1 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | studia | 0% | 100% | 0% | 23.4 | 1220.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | casuale | 0% | 90% | 10% | 48.0 | 1206.7 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | si_cura | 3% | 97% | 0% | 32.8 | 1217.5 | 0% | 22 |
| Jongo Dongo | `jongo_dongo_risorto` | attacca | 0% | 100% | 0% | 22.7 | 1220.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | difendi | 0% | 0% | 100% | 60.0 | 649.8 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | studia | 0% | 100% | 0% | 22.3 | 1220.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | casuale | 0% | 7% | 93% | 58.5 | 894.3 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | si_cura | 0% | 100% | 0% | 30.2 | 1220.0 | 0% | 0 |
| ??? | `l_immortale` | attacca | 0% | 0% | 100% | 60.0 | 24.0 | 0% | 0 |
| ??? | `l_immortale` | difendi | 0% | 0% | 100% | 60.0 | 24.0 | 0% | 0 |
| ??? | `l_immortale` | studia | 0% | 0% | 100% | 60.0 | 24.0 | 0% | 0 |
| ??? | `l_immortale` | casuale | 0% | 0% | 100% | 60.0 | 24.0 | 0% | 0 |
| ??? | `l_immortale` | si_cura | 0% | 0% | 100% | 60.0 | 24.0 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | attacca | 100% | 0% | 0% | 6.5 | 114.4 | 0% | 46 |
| Madre in Lacrime | `madre_in_lacrime` | difendi | 0% | 0% | 100% | 60.0 | 138.3 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | studia | 100% | 0% | 0% | 9.5 | 167.1 | 0% | 46 |
| Madre in Lacrime | `madre_in_lacrime` | casuale | 100% | 0% | 0% | 20.3 | 124.7 | 0% | 46 |
| Madre in Lacrime | `madre_in_lacrime` | si_cura | 100% | 0% | 0% | 6.5 | 114.4 | 0% | 46 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | attacca | 0% | 100% | 0% | 14.0 | 1220.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | difendi | 0% | 100% | 0% | 14.0 | 1220.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | studia | 0% | 100% | 0% | 14.0 | 1220.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | casuale | 0% | 100% | 0% | 14.0 | 1220.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | si_cura | 0% | 100% | 0% | 14.0 | 1220.0 | 0% | 0 |
| Marionetta | `marionetta` | attacca | 100% | 0% | 0% | 7.4 | 100.2 | 0% | 46 |
| Marionetta | `marionetta` | difendi | 0% | 0% | 100% | 60.0 | 115.2 | 0% | 0 |
| Marionetta | `marionetta` | studia | 100% | 0% | 0% | 10.4 | 166.8 | 0% | 46 |
| Marionetta | `marionetta` | casuale | 99% | 0% | 1% | 24.2 | 116.6 | 0% | 46 |
| Marionetta | `marionetta` | si_cura | 100% | 0% | 0% | 7.4 | 100.2 | 0% | 46 |
| Fomentado | `maschera_vuota` | attacca | 100% | 0% | 0% | 5.7 | 166.0 | 0% | 46 |
| Fomentado | `maschera_vuota` | difendi | 0% | 0% | 100% | 60.0 | 100.3 | 0% | 0 |
| Fomentado | `maschera_vuota` | studia | 100% | 0% | 0% | 8.8 | 210.6 | 0% | 46 |
| Fomentado | `maschera_vuota` | casuale | 100% | 0% | 0% | 15.4 | 141.0 | 0% | 46 |
| Fomentado | `maschera_vuota` | si_cura | 100% | 0% | 0% | 5.7 | 166.0 | 0% | 46 |
| Nuvola di Marciume | `nuvola_di_marciume` | attacca | 100% | 0% | 0% | 4.6 | 140.8 | 0% | 51 |
| Nuvola di Marciume | `nuvola_di_marciume` | difendi | 0% | 9% | 91% | 59.9 | 1189.9 | 0% | 0 |
| Nuvola di Marciume | `nuvola_di_marciume` | studia | 100% | 0% | 0% | 7.9 | 262.6 | 0% | 51 |
| Nuvola di Marciume | `nuvola_di_marciume` | casuale | 100% | 0% | 0% | 13.9 | 322.0 | 0% | 51 |
| Nuvola di Marciume | `nuvola_di_marciume` | si_cura | 100% | 0% | 0% | 5.2 | 122.0 | 0% | 51 |
| Ombra del passato | `ombra_del_passato` | attacca | 100% | 0% | 0% | 6.6 | 126.8 | 0% | 46 |
| Ombra del passato | `ombra_del_passato` | difendi | 0% | 0% | 100% | 60.0 | 121.6 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | studia | 100% | 0% | 0% | 9.6 | 186.1 | 0% | 46 |
| Ombra del passato | `ombra_del_passato` | casuale | 100% | 0% | 0% | 20.6 | 134.3 | 0% | 46 |
| Ombra del passato | `ombra_del_passato` | si_cura | 100% | 0% | 0% | 6.6 | 126.8 | 0% | 46 |
| Emblema dell'oppressione | `operaio_posseduto` | attacca | 100% | 0% | 0% | 6.5 | 39.0 | 0% | 46 |
| Emblema dell'oppressione | `operaio_posseduto` | difendi | 0% | 0% | 100% | 60.0 | 132.2 | 0% | 0 |
| Emblema dell'oppressione | `operaio_posseduto` | studia | 100% | 0% | 0% | 9.6 | 60.5 | 0% | 46 |
| Emblema dell'oppressione | `operaio_posseduto` | casuale | 100% | 0% | 0% | 23.9 | 145.0 | 0% | 46 |
| Emblema dell'oppressione | `operaio_posseduto` | si_cura | 100% | 0% | 0% | 6.5 | 39.0 | 0% | 46 |
| Operaio Sfruttato | `operaio_sfruttato` | attacca | 100% | 0% | 0% | 12.7 | 332.0 | 0% | 101 |
| Operaio Sfruttato | `operaio_sfruttato` | difendi | 0% | 0% | 100% | 60.0 | 108.3 | 0% | 0 |
| Operaio Sfruttato | `operaio_sfruttato` | studia | 100% | 0% | 0% | 16.6 | 450.9 | 0% | 101 |
| Operaio Sfruttato | `operaio_sfruttato` | casuale | 29% | 0% | 71% | 54.7 | 382.3 | 0% | 29 |
| Operaio Sfruttato | `operaio_sfruttato` | si_cura | 100% | 0% | 0% | 12.7 | 332.0 | 0% | 101 |
| Orrore di Meridia | `orrore_di_meridia` | attacca | 93% | 7% | 0% | 22.4 | 1163.2 | 0% | 94 |
| Orrore di Meridia | `orrore_di_meridia` | difendi | 0% | 0% | 100% | 60.0 | 122.8 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | studia | 93% | 7% | 0% | 26.1 | 1175.8 | 0% | 94 |
| Orrore di Meridia | `orrore_di_meridia` | casuale | 11% | 17% | 72% | 58.0 | 904.8 | 0% | 14 |
| Orrore di Meridia | `orrore_di_meridia` | si_cura | 78% | 22% | 0% | 26.4 | 1031.9 | 0% | 79 |
| Robo Pattuglia | `robo_pattuglia` | attacca | 97% | 0% | 3% | 18.2 | 106.8 | 0% | 54 |
| Robo Pattuglia | `robo_pattuglia` | difendi | 0% | 0% | 100% | 60.0 | 36.5 | 0% | 0 |
| Robo Pattuglia | `robo_pattuglia` | studia | 89% | 0% | 11% | 24.2 | 144.1 | 0% | 50 |
| Robo Pattuglia | `robo_pattuglia` | casuale | 22% | 0% | 78% | 54.8 | 48.2 | 0% | 13 |
| Robo Pattuglia | `robo_pattuglia` | si_cura | 97% | 0% | 3% | 18.2 | 106.8 | 0% | 54 |
| Sacerdote Folle | `sacerdote_folle` | attacca | 100% | 0% | 0% | 10.6 | 177.6 | 0% | 68 |
| Sacerdote Folle | `sacerdote_folle` | difendi | 0% | 0% | 100% | 60.0 | 350.8 | 0% | 0 |
| Sacerdote Folle | `sacerdote_folle` | studia | 100% | 0% | 0% | 17.4 | 337.3 | 0% | 80 |
| Sacerdote Folle | `sacerdote_folle` | casuale | 25% | 0% | 75% | 53.1 | 378.2 | 0% | 23 |
| Sacerdote Folle | `sacerdote_folle` | si_cura | 100% | 0% | 0% | 10.6 | 177.6 | 0% | 68 |
| Sadico | `sadico` | attacca | 100% | 0% | 0% | 6.9 | 180.1 | 0% | 46 |
| Sadico | `sadico` | difendi | 0% | 5% | 95% | 59.9 | 1133.3 | 0% | 0 |
| Sadico | `sadico` | studia | 100% | 0% | 0% | 10.1 | 285.5 | 0% | 46 |
| Sadico | `sadico` | casuale | 100% | 0% | 0% | 22.4 | 448.8 | 0% | 46 |
| Sadico | `sadico` | si_cura | 100% | 0% | 0% | 8.0 | 168.4 | 0% | 46 |
| Slime Infimo | `slime_infimo` | attacca | 100% | 0% | 0% | 7.4 | 92.2 | 0% | 46 |
| Slime Infimo | `slime_infimo` | difendi | 0% | 0% | 100% | 60.0 | 105.0 | 0% | 0 |
| Slime Infimo | `slime_infimo` | studia | 100% | 0% | 0% | 10.5 | 152.2 | 0% | 46 |
| Slime Infimo | `slime_infimo` | casuale | 99% | 0% | 1% | 29.0 | 106.5 | 0% | 46 |
| Slime Infimo | `slime_infimo` | si_cura | 100% | 0% | 0% | 7.4 | 92.2 | 0% | 46 |
| Stigma | `stigma` | attacca | 100% | 0% | 0% | 6.7 | 149.7 | 0% | 46 |
| Stigma | `stigma` | difendi | 0% | 1% | 99% | 60.0 | 1053.0 | 0% | 0 |
| Stigma | `stigma` | studia | 100% | 0% | 0% | 10.0 | 245.5 | 0% | 46 |
| Stigma | `stigma` | casuale | 100% | 0% | 0% | 22.4 | 378.1 | 0% | 46 |
| Stigma | `stigma` | si_cura | 100% | 0% | 0% | 7.0 | 128.5 | 0% | 46 |
| Tartaruga Innocente | `tartaruga_innocente` | attacca | 100% | 0% | 0% | 3.9 | 0.0 | 0% | 1 |
| Tartaruga Innocente | `tartaruga_innocente` | difendi | 0% | 0% | 100% | 60.0 | 0.0 | 0% | 0 |
| Tartaruga Innocente | `tartaruga_innocente` | studia | 100% | 0% | 0% | 2.0 | 0.0 | 100% | 1 |
| Tartaruga Innocente | `tartaruga_innocente` | casuale | 82% | 0% | 18% | 21.4 | 0.0 | 0% | 1 |
| Tartaruga Innocente | `tartaruga_innocente` | si_cura | 100% | 0% | 0% | 3.9 | 0.0 | 0% | 1 |
| Un tenero ricordo | `tenero_ricordo` | attacca | 0% | 100% | 0% | 23.0 | 1220.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | difendi | 0% | 100% | 0% | 25.4 | 1220.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | studia | 0% | 100% | 0% | 23.4 | 1220.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | casuale | 0% | 100% | 0% | 26.6 | 1220.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | si_cura | 0% | 100% | 0% | 24.3 | 1220.0 | 0% | 0 |
| Teschio Errante | `teschio_errante` | attacca | 100% | 0% | 0% | 6.6 | 87.7 | 0% | 46 |
| Teschio Errante | `teschio_errante` | difendi | 0% | 0% | 100% | 60.0 | 110.7 | 0% | 0 |
| Teschio Errante | `teschio_errante` | studia | 100% | 0% | 0% | 9.6 | 125.3 | 0% | 46 |
| Teschio Errante | `teschio_errante` | casuale | 100% | 0% | 0% | 20.4 | 76.7 | 0% | 46 |
| Teschio Errante | `teschio_errante` | si_cura | 100% | 0% | 0% | 6.6 | 87.7 | 0% | 46 |
| Titano Zombie | `titano_zombie` | attacca | 98% | 2% | 0% | 17.0 | 979.1 | 0% | 99 |
| Titano Zombie | `titano_zombie` | difendi | 0% | 99% | 1% | 33.4 | 1219.8 | 0% | 0 |
| Titano Zombie | `titano_zombie` | studia | 98% | 2% | 0% | 19.4 | 1026.5 | 0% | 99 |
| Titano Zombie | `titano_zombie` | casuale | 4% | 95% | 1% | 38.1 | 1217.5 | 0% | 4 |
| Titano Zombie | `titano_zombie` | si_cura | 100% | 0% | 0% | 22.6 | 924.0 | 0% | 101 |
| Capocantiere | `voce_registrata` | attacca | 100% | 0% | 0% | 6.5 | 107.4 | 0% | 46 |
| Capocantiere | `voce_registrata` | difendi | 0% | 0% | 100% | 60.0 | 98.0 | 0% | 0 |
| Capocantiere | `voce_registrata` | studia | 100% | 0% | 0% | 9.6 | 157.8 | 0% | 46 |
| Capocantiere | `voce_registrata` | casuale | 100% | 0% | 0% | 20.7 | 104.3 | 0% | 46 |
| Capocantiere | `voce_registrata` | si_cura | 100% | 0% | 0% | 6.5 | 107.4 | 0% | 46 |
| Volto sulla parete | `volto_sulla_parete` | attacca | 1% | 99% | 0% | 27.1 | 1219.9 | 0% | 1 |
| Volto sulla parete | `volto_sulla_parete` | difendi | 0% | 40% | 60% | 58.8 | 1176.6 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | studia | 2% | 98% | 0% | 27.7 | 1214.6 | 0% | 4 |
| Volto sulla parete | `volto_sulla_parete` | casuale | 0% | 78% | 22% | 54.4 | 1204.3 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | si_cura | 4% | 96% | 0% | 38.8 | 1206.6 | 0% | 8 |
| Zombie Cittadino | `zombie_cittadino` | attacca | 100% | 0% | 0% | 6.5 | 101.2 | 0% | 46 |
| Zombie Cittadino | `zombie_cittadino` | difendi | 0% | 0% | 100% | 60.0 | 85.5 | 0% | 0 |
| Zombie Cittadino | `zombie_cittadino` | studia | 100% | 0% | 0% | 9.5 | 141.6 | 0% | 46 |
| Zombie Cittadino | `zombie_cittadino` | casuale | 100% | 0% | 0% | 20.1 | 84.6 | 0% | 46 |
| Zombie Cittadino | `zombie_cittadino` | si_cura | 100% | 0% | 0% | 6.5 | 101.2 | 0% | 46 |
| Zombie Mostruoso | `zombie_mostruoso` | attacca | 100% | 0% | 0% | 6.6 | 113.5 | 0% | 46 |
| Zombie Mostruoso | `zombie_mostruoso` | difendi | 0% | 0% | 100% | 60.0 | 105.3 | 0% | 0 |
| Zombie Mostruoso | `zombie_mostruoso` | studia | 100% | 0% | 0% | 9.6 | 164.4 | 0% | 46 |
| Zombie Mostruoso | `zombie_mostruoso` | casuale | 100% | 0% | 0% | 20.4 | 127.5 | 0% | 46 |
| Zombie Mostruoso | `zombie_mostruoso` | si_cura | 100% | 0% | 0% | 6.6 | 113.5 | 0% | 46 |

