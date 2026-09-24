# Bilanciamento (generato, non scrivere qui a mano)

Prodotto da `prove/Simulatore.gd`: **309600 partite** giocate dal motore vero in 3039 secondi.

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
- **giri** — durata media in BATTUTE del protagonista (una battuta = un suo turno)
- **danno** — punti vita persi in media dal protagonista (ne ha 1220)
- **risp.** — percentuale di partite in cui la creatura e' stata risparmiata

## A che livello ogni scontro diventa giusto

Livello minimo a cui si vince almeno l'80% delle volte andandoci dritto.

| creatura | id | hp | att | livello |
|---|---|--:|--:|--:|
| Abominio Marcio | `abominio_marcio` | 737 | 34 | 12 |
| Oppresso | `comparsa_di_ruggine` | 277 | 10 | 5 |
| Diabolo | `diabolo` | 445 | 26 | 8 |
| Il Divoratore | `divoratore` | 468 | 21 | 8 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | 486 | 32 | 8 |
| Donna Spinosa | `donna_spinosa` | 568 | 38 | 12 |
| Rottami Erranti | `ferraglia_urlante` | 381 | 14 | 8 |
| Ghoul | `ghoul` | 366 | 23 | 5 |
| El Muy Bonito | `giocoliere` | 340 | 15 | 5 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | 500 | 3 | 2 |
| Goblin Possessivo | `goblin_possessivo` | 86 | 6 | 1 |
| Goblin Tipico | `goblin_tipico` | 86 | 6 | 1 |
| Golem errante di rottami | `golem_errante` | 539 | 25 | 8 |
| Infetto Rapido | `infetto_rapido` | 94 | 7 | 1 |
| L'ultimo spettacolo di Jerah | `jerah` | 2710 | 74 | **mai** |
| Jongo Dongo | `jongo_dongo` | 1857 | 48 | **mai** |
| Jongo Dongo | `jongo_dongo_risorto` | 2147 | 56 | **mai** |
| ??? | `l_immortale` | 120 | 5 | **mai** |
| Madre in Lacrime | `madre_in_lacrime` | 366 | 23 | 5 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | 439 | 14 | **mai** |
| Marionetta | `marionetta` | 568 | 38 | 12 |
| Fomentado | `maschera_vuota` | 205 | 10 | 2 |
| Nimbo Boy | `nimbo_boy` | 3 | 0 | 1 |
| Nuvola di Marciume | `nuvola_di_marciume` | 94 | 7 | 1 |
| Ombra del passato | `ombra_del_passato` | 607 | 41 | 12 |
| Emblema dell'oppressione | `operaio_posseduto` | 290 | 16 | 5 |
| Operaio Sfruttato | `operaio_sfruttato` | 404 | 18 | 5 |
| Orrore di Meridia | `orrore_di_meridia` | 404 | 18 | 8 |
| Rana Folle | `rana_folle` | 34 | 7 | 1 |
| Robo Pattuglia | `robo_pattuglia` | 277 | 10 | 5 |
| Sacerdote Folle | `sacerdote_folle` | 486 | 32 | 12 |
| Sadico | `sadico` | 405 | 26 | 8 |
| Slime Infimo | `slime_infimo` | 86 | 6 | 1 |
| Sogno perduto | `sogno_perduto` | 33 | 6 | 1 |
| Stigma | `stigma` | 405 | 26 | 8 |
| Tartaruga Gigante | `tartaruga_innocente` | 555 | 0 | 12 |
| Un tenero ricordo | `tenero_ricordo` | 6660 | 27 | **mai** |
| Teschio Errante | `teschio_errante` | 366 | 23 | 5 |
| Titano Zombie | `titano_zombie` | 737 | 34 | 12 |
| Capocantiere | `voce_registrata` | 207 | 13 | 3 |
| Volto sulla parete | `volto_sulla_parete` | 1733 | 57 | **mai** |
| Zombie Cittadino | `zombie_cittadino` | 125 | 8 | 3 |
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
| Fomentado | 3 | comune | hp 205 | Bru: «va bene cosi', aumenta i loro hp piuttosto leggermente, ma la meccanica va bene, segue la logica di essere consumati. Gli umani sono felici quando capiscono che possono avere altre strade di vittoria: questo e' il caso.» Da 164 a 205 (+25%). Misurato: difendendosi e basta si vince ancora il 100% delle volte, ma in 35 battute invece di 28; andandoci dritto si vince in 6. La strada alternativa resta aperta e costa sei volte il tempo, che e' esattamente quello che deve costare. |
| Emblema dell'oppressione | 5 | comune | hp 290, attacco 16, difesa 5 | Bru ha chiesto 290/16/5; la curva del ruolo comune a livello 5 da' 245/15/6. Alzarlo di livello lo terrebbe sulla curva ma sposterebbe anche l'xp e il posto nella progressione, e il ruolo particolare a livello 5 darebbe 404/18/8: troppo. Scritte a mano e' l'unica delle tre strade che da' i suoi numeri senza cambiarne nessun altro. |
| Diabolo | 9 | comune | hp 445 | Stessa decisione di Bru, ma con la mano piu' leggera: da 405 a 445 (+10%). A +25% la strada dell'attesa non spariva, si INCEPPAVA - il 71% delle partite superava le sessanta battute senza finire, che non e' una sconfitta ma e' peggio di una. A +10% difendersi e basta vince il 45% invece del 55%, e chi attacca chiude in 6 battute. Numeri miei: ./prove/sonda.sh diabolo difendi 12. |
| ??? | 8 | particolare | hp 120, attacco 5, difesa 0 | Non deve essere battuto: si rialza sempre. I suoi numeri sono bassi apposta, perche' il giocatore ci provi abbastanza a lungo da capirlo. |
| Un tenero ricordo | 15 | fonte | hp 6660, attacco 27, difesa 12 | Non si vince a danno: si vince con le leve. La riserva e' una parete che dice «non da questa parte», non un conto da smaltire. |
| Rana Folle | 1 | comune | hp 34, attacco 7 | Orda della prima missione. Da comune al livello 1 una rana avrebbe la vita di un goblin intero, e cinque rane sarebbero cinque goblin: la vita di un'orda e' quella di una per quante sono. Numeri misurati sulla strategia di Bru (concentrarsi quando fanno fronte compatto, poi l'onda psichica). |
| Tartaruga Gigante | 1 | corazzato | hp 555, attacco 0, difesa 6 | Non e' uno scontro, e' un indovinello: non attacca mai e non si batte a colpi. La sua riserva enorme serve a far capire che la strada e' un'altra. |
| Un goblin terribilmente arrabbiato | 6 | fonte | hp 500, attacco 3, difesa 3, velocita 1 | Prima fonte del gioco, e primo boss vero. Le statistiche sono scritte a mano e non escono dal ruolo: Bru lo vuole «lungo e interessante, time consuming, non difficile e imbattibile». Tanta vita e poca difesa, cosi' ogni tuo colpo si vede e ne servono tanti; un attacco basso e lento, cosi' a fare paura sono la Mazzata e i goblin che chiama, non il colpo normale. |
| Veronica | 5 | miniboss | hp 600, attacco 18, difesa 6, xp 0, tazo 0 | Allenamento scriptato del tutorial: e' invincibile per copione, i numeri servono solo a far durare la lezione il giusto. |
| Nimbo Boy | 1 | comune | hp 3, attacco 0, difesa 0, velocita 6 | Scritte a mano apposta: la curva del ruolo comune a livello 1 darebbe una creatura normale, e questa normale non e'. Tre punti vita perche' tre sono i colpi che regge, e zero attacco perche' non attacca mai. |
| Sogno perduto | 1 | comune | hp 33, attacco 6, difesa 1, velocita 5 | I punti vita qui sono solo il valore di ripiego se qualcuno lo mette in campo senza un evocatore: normalmente li prende da chi lo sogna. 33 e' un quarto dei 130 di Yhvina oggi. Attacco e difesa sono miei, da correggere. |

## Protagonista di livello 1

| creatura | id | come si gioca | vinte | perse | ∞ | giri | danno | risp. | xp |
|---|---|---|--:|--:|--:|--:|--:|--:|--:|
| Abominio Marcio | `abominio_marcio` | attacca | 0% | 100% | 0% | 2.2 | 100.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | difendi | 0% | 100% | 0% | 2.2 | 100.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | studia | 0% | 100% | 0% | 2.2 | 100.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | casuale | 0% | 100% | 0% | 2.2 | 100.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | si_cura | 0% | 100% | 0% | 5.9 | 100.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | speciali | 0% | 100% | 0% | 2.2 | 100.0 | 0% | 0 |
| Oppresso | `comparsa_di_ruggine` | attacca | 12% | 88% | 0% | 12.6 | 94.3 | 0% | 2 |
| Oppresso | `comparsa_di_ruggine` | difendi | 0% | 27% | 73% | 58.4 | 87.5 | 0% | 0 |
| Oppresso | `comparsa_di_ruggine` | studia | 7% | 93% | 0% | 12.8 | 97.1 | 0% | 1 |
| Oppresso | `comparsa_di_ruggine` | casuale | 13% | 79% | 7% | 36.5 | 95.4 | 0% | 2 |
| Oppresso | `comparsa_di_ruggine` | si_cura | 25% | 75% | 0% | 36.8 | 82.7 | 0% | 4 |
| Oppresso | `comparsa_di_ruggine` | speciali | 11% | 89% | 0% | 12.5 | 95.0 | 0% | 2 |
| Diabolo | `diabolo` | attacca | 3% | 97% | 0% | 3.4 | 98.6 | 0% | 1 |
| Diabolo | `diabolo` | difendi | 1% | 99% | 0% | 4.1 | 99.7 | 0% | 0 |
| Diabolo | `diabolo` | studia | 0% | 100% | 0% | 3.4 | 100.0 | 0% | 0 |
| Diabolo | `diabolo` | casuale | 0% | 100% | 0% | 3.6 | 100.0 | 0% | 0 |
| Diabolo | `diabolo` | si_cura | 7% | 93% | 0% | 12.5 | 96.9 | 0% | 2 |
| Diabolo | `diabolo` | speciali | 1% | 99% | 0% | 3.4 | 99.6 | 0% | 0 |
| Il Divoratore | `divoratore` | attacca | 0% | 100% | 0% | 3.6 | 100.0 | 0% | 0 |
| Il Divoratore | `divoratore` | difendi | 0% | 100% | 0% | 4.5 | 100.0 | 0% | 0 |
| Il Divoratore | `divoratore` | studia | 0% | 100% | 0% | 3.5 | 100.0 | 0% | 0 |
| Il Divoratore | `divoratore` | casuale | 0% | 100% | 0% | 3.9 | 100.0 | 0% | 0 |
| Il Divoratore | `divoratore` | si_cura | 0% | 100% | 0% | 15.1 | 100.0 | 0% | 0 |
| Il Divoratore | `divoratore` | speciali | 0% | 100% | 0% | 3.5 | 100.0 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | attacca | 3% | 97% | 0% | 2.8 | 98.8 | 0% | 1 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | difendi | 0% | 100% | 0% | 2.9 | 100.0 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | studia | 0% | 100% | 0% | 2.8 | 100.0 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | casuale | 1% | 99% | 0% | 2.8 | 99.7 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | si_cura | 3% | 97% | 0% | 10.6 | 98.0 | 0% | 1 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | speciali | 0% | 100% | 0% | 2.8 | 100.0 | 0% | 0 |
| Donna Spinosa | `donna_spinosa` | attacca | 3% | 97% | 0% | 2.0 | 98.6 | 0% | 2 |
| Donna Spinosa | `donna_spinosa` | difendi | 0% | 100% | 0% | 2.1 | 100.0 | 0% | 0 |
| Donna Spinosa | `donna_spinosa` | studia | 0% | 100% | 0% | 2.0 | 100.0 | 0% | 0 |
| Donna Spinosa | `donna_spinosa` | casuale | 1% | 99% | 0% | 2.1 | 99.8 | 0% | 0 |
| Donna Spinosa | `donna_spinosa` | si_cura | 2% | 98% | 0% | 4.9 | 98.7 | 0% | 1 |
| Donna Spinosa | `donna_spinosa` | speciali | 0% | 100% | 0% | 2.0 | 100.0 | 0% | 0 |
| Rottami Erranti | `ferraglia_urlante` | attacca | 0% | 100% | 0% | 10.4 | 100.0 | 0% | 0 |
| Rottami Erranti | `ferraglia_urlante` | difendi | 0% | 100% | 0% | 30.5 | 100.0 | 0% | 0 |
| Rottami Erranti | `ferraglia_urlante` | studia | 0% | 100% | 0% | 10.3 | 100.0 | 0% | 0 |
| Rottami Erranti | `ferraglia_urlante` | casuale | 0% | 100% | 0% | 13.7 | 100.0 | 0% | 0 |
| Rottami Erranti | `ferraglia_urlante` | si_cura | 0% | 100% | 0% | 36.0 | 100.0 | 0% | 0 |
| Rottami Erranti | `ferraglia_urlante` | speciali | 0% | 100% | 0% | 10.0 | 100.0 | 0% | 0 |
| Ghoul | `ghoul` | attacca | 5% | 95% | 0% | 3.3 | 97.9 | 0% | 1 |
| Ghoul | `ghoul` | difendi | 0% | 100% | 0% | 3.8 | 100.0 | 0% | 0 |
| Ghoul | `ghoul` | studia | 0% | 100% | 0% | 3.3 | 100.0 | 0% | 0 |
| Ghoul | `ghoul` | casuale | 1% | 99% | 0% | 3.5 | 99.6 | 0% | 0 |
| Ghoul | `ghoul` | si_cura | 5% | 95% | 0% | 13.8 | 97.0 | 0% | 2 |
| Ghoul | `ghoul` | speciali | 1% | 99% | 0% | 3.3 | 99.9 | 0% | 0 |
| El Muy Bonito | `giocoliere` | attacca | 0% | 100% | 0% | 5.5 | 100.0 | 0% | 0 |
| El Muy Bonito | `giocoliere` | difendi | 0% | 100% | 0% | 12.3 | 100.0 | 0% | 0 |
| El Muy Bonito | `giocoliere` | studia | 0% | 100% | 0% | 4.0 | 100.0 | 0% | 0 |
| El Muy Bonito | `giocoliere` | casuale | 0% | 100% | 0% | 5.7 | 100.0 | 0% | 0 |
| El Muy Bonito | `giocoliere` | si_cura | 0% | 100% | 0% | 20.1 | 100.0 | 0% | 0 |
| El Muy Bonito | `giocoliere` | speciali | 0% | 100% | 0% | 5.5 | 100.0 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | attacca | 19% | 81% | 0% | 37.0 | 94.1 | 0% | 29 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | difendi | 0% | 0% | 100% | 60.0 | 32.6 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | studia | 19% | 81% | 0% | 39.0 | 93.4 | 0% | 28 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | casuale | 0% | 0% | 100% | 60.0 | 37.2 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | si_cura | 99% | 0% | 1% | 49.0 | 23.1 | 0% | 153 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | speciali | 51% | 49% | 0% | 31.8 | 80.3 | 0% | 78 |
| Goblin Possessivo | `goblin_possessivo` | attacca | 100% | 0% | 0% | 7.7 | 27.6 | 0% | 2 |
| Goblin Possessivo | `goblin_possessivo` | difendi | 0% | 0% | 100% | 60.0 | 49.2 | 0% | 0 |
| Goblin Possessivo | `goblin_possessivo` | studia | 100% | 0% | 0% | 10.6 | 41.6 | 0% | 2 |
| Goblin Possessivo | `goblin_possessivo` | casuale | 71% | 11% | 18% | 37.9 | 59.4 | 0% | 1 |
| Goblin Possessivo | `goblin_possessivo` | si_cura | 100% | 0% | 0% | 7.7 | 27.6 | 0% | 2 |
| Goblin Possessivo | `goblin_possessivo` | speciali | 100% | 0% | 0% | 6.4 | 18.8 | 0% | 2 |
| Goblin Tipico | `goblin_tipico` | attacca | 100% | 0% | 0% | 7.7 | 27.6 | 0% | 2 |
| Goblin Tipico | `goblin_tipico` | difendi | 0% | 0% | 100% | 60.0 | 49.2 | 0% | 0 |
| Goblin Tipico | `goblin_tipico` | studia | 100% | 0% | 0% | 10.6 | 41.6 | 0% | 2 |
| Goblin Tipico | `goblin_tipico` | casuale | 71% | 11% | 18% | 37.9 | 59.4 | 0% | 1 |
| Goblin Tipico | `goblin_tipico` | si_cura | 100% | 0% | 0% | 7.7 | 27.6 | 0% | 2 |
| Goblin Tipico | `goblin_tipico` | speciali | 100% | 0% | 0% | 6.4 | 18.8 | 0% | 2 |
| Golem errante di rottami | `golem_errante` | attacca | 0% | 100% | 0% | 3.3 | 100.0 | 0% | 0 |
| Golem errante di rottami | `golem_errante` | difendi | 0% | 100% | 0% | 3.8 | 100.0 | 0% | 0 |
| Golem errante di rottami | `golem_errante` | studia | 0% | 100% | 0% | 3.3 | 100.0 | 0% | 0 |
| Golem errante di rottami | `golem_errante` | casuale | 0% | 100% | 0% | 3.5 | 100.0 | 0% | 0 |
| Golem errante di rottami | `golem_errante` | si_cura | 0% | 100% | 0% | 13.1 | 100.0 | 0% | 0 |
| Golem errante di rottami | `golem_errante` | speciali | 0% | 100% | 0% | 3.3 | 100.0 | 0% | 0 |
| Infetto Rapido | `infetto_rapido` | attacca | 100% | 0% | 0% | 6.6 | 53.9 | 0% | 6 |
| Infetto Rapido | `infetto_rapido` | difendi | 0% | 77% | 23% | 56.2 | 99.0 | 0% | 0 |
| Infetto Rapido | `infetto_rapido` | studia | 100% | 0% | 0% | 9.7 | 77.3 | 0% | 6 |
| Infetto Rapido | `infetto_rapido` | casuale | 99% | 1% | 0% | 19.8 | 63.3 | 0% | 6 |
| Infetto Rapido | `infetto_rapido` | si_cura | 100% | 0% | 0% | 7.1 | 25.8 | 0% | 6 |
| Infetto Rapido | `infetto_rapido` | speciali | 100% | 0% | 0% | 5.5 | 44.9 | 0% | 6 |
| L'ultimo spettacolo di Jerah | `jerah` | attacca | 0% | 100% | 0% | 2.1 | 100.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | difendi | 0% | 100% | 0% | 2.2 | 100.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | studia | 0% | 100% | 0% | 2.1 | 100.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | casuale | 0% | 100% | 0% | 2.0 | 100.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | si_cura | 0% | 100% | 0% | 6.6 | 100.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | speciali | 0% | 100% | 0% | 2.1 | 100.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | attacca | 0% | 100% | 0% | 2.9 | 100.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | difendi | 0% | 100% | 0% | 2.7 | 100.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | studia | 0% | 100% | 0% | 2.5 | 100.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | casuale | 0% | 100% | 0% | 2.8 | 100.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | si_cura | 0% | 100% | 0% | 4.9 | 100.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | speciali | 0% | 100% | 0% | 2.5 | 100.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | attacca | 0% | 100% | 0% | 1.1 | 100.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | difendi | 0% | 100% | 0% | 1.1 | 100.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | studia | 0% | 100% | 0% | 1.1 | 100.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | casuale | 0% | 100% | 0% | 1.1 | 100.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | si_cura | 0% | 100% | 0% | 2.2 | 100.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | speciali | 0% | 100% | 0% | 1.1 | 100.0 | 0% | 0 |
| ??? | `l_immortale` | attacca | 0% | 100% | 0% | 17.2 | 100.0 | 0% | 0 |
| ??? | `l_immortale` | difendi | 0% | 0% | 100% | 60.0 | 69.9 | 0% | 0 |
| ??? | `l_immortale` | studia | 0% | 100% | 0% | 17.7 | 100.0 | 0% | 0 |
| ??? | `l_immortale` | casuale | 0% | 14% | 86% | 58.5 | 83.8 | 0% | 0 |
| ??? | `l_immortale` | si_cura | 0% | 97% | 3% | 58.2 | 99.9 | 0% | 0 |
| ??? | `l_immortale` | speciali | 0% | 100% | 0% | 17.4 | 100.0 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | attacca | 5% | 95% | 0% | 3.3 | 97.6 | 0% | 1 |
| Madre in Lacrime | `madre_in_lacrime` | difendi | 0% | 100% | 0% | 4.1 | 100.0 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | studia | 1% | 99% | 0% | 3.5 | 100.0 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | casuale | 1% | 99% | 0% | 3.6 | 99.4 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | si_cura | 8% | 92% | 0% | 13.0 | 95.3 | 0% | 2 |
| Madre in Lacrime | `madre_in_lacrime` | speciali | 1% | 99% | 0% | 3.4 | 99.8 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | attacca | 0% | 100% | 0% | 5.0 | 100.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | difendi | 0% | 100% | 0% | 5.0 | 100.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | studia | 0% | 100% | 0% | 5.0 | 100.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | casuale | 0% | 100% | 0% | 5.0 | 100.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | si_cura | 0% | 100% | 0% | 5.0 | 100.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | speciali | 0% | 100% | 0% | 5.0 | 100.0 | 0% | 0 |
| Marionetta | `marionetta` | attacca | 2% | 98% | 0% | 2.3 | 99.1 | 0% | 1 |
| Marionetta | `marionetta` | difendi | 0% | 100% | 0% | 2.4 | 100.0 | 0% | 0 |
| Marionetta | `marionetta` | studia | 0% | 100% | 0% | 2.3 | 100.0 | 0% | 0 |
| Marionetta | `marionetta` | casuale | 1% | 99% | 0% | 2.3 | 99.9 | 0% | 0 |
| Marionetta | `marionetta` | si_cura | 5% | 95% | 0% | 7.6 | 97.2 | 0% | 3 |
| Marionetta | `marionetta` | speciali | 0% | 100% | 0% | 2.3 | 100.0 | 0% | 0 |
| Fomentado | `maschera_vuota` | attacca | 11% | 89% | 0% | 8.4 | 96.3 | 0% | 1 |
| Fomentado | `maschera_vuota` | difendi | 49% | 51% | 0% | 29.6 | 94.9 | 0% | 4 |
| Fomentado | `maschera_vuota` | studia | 5% | 95% | 0% | 9.4 | 98.4 | 0% | 0 |
| Fomentado | `maschera_vuota` | casuale | 21% | 79% | 0% | 14.3 | 96.2 | 0% | 2 |
| Fomentado | `maschera_vuota` | si_cura | 100% | 0% | 0% | 10.3 | 15.2 | 0% | 9 |
| Fomentado | `maschera_vuota` | speciali | 71% | 29% | 0% | 7.6 | 93.4 | 0% | 6 |
| Nimbo Boy | `nimbo_boy` | attacca | 100% | 0% | 0% | 3.0 | 0.0 | 0% | 2 |
| Nimbo Boy | `nimbo_boy` | difendi | 0% | 0% | 100% | 60.0 | 0.0 | 0% | 0 |
| Nimbo Boy | `nimbo_boy` | studia | 100% | 0% | 0% | 6.0 | 0.0 | 0% | 2 |
| Nimbo Boy | `nimbo_boy` | casuale | 100% | 0% | 0% | 8.7 | 0.0 | 0% | 2 |
| Nimbo Boy | `nimbo_boy` | si_cura | 100% | 0% | 0% | 3.0 | 0.0 | 0% | 2 |
| Nimbo Boy | `nimbo_boy` | speciali | 100% | 0% | 0% | 5.0 | 0.0 | 0% | 2 |
| Nuvola di Marciume | `nuvola_di_marciume` | attacca | 100% | 0% | 0% | 6.9 | 49.3 | 0% | 6 |
| Nuvola di Marciume | `nuvola_di_marciume` | difendi | 0% | 100% | 0% | 31.5 | 100.0 | 0% | 0 |
| Nuvola di Marciume | `nuvola_di_marciume` | studia | 100% | 0% | 0% | 10.1 | 75.0 | 0% | 6 |
| Nuvola di Marciume | `nuvola_di_marciume` | casuale | 74% | 26% | 0% | 19.2 | 78.6 | 0% | 4 |
| Nuvola di Marciume | `nuvola_di_marciume` | si_cura | 100% | 0% | 0% | 8.1 | 42.7 | 0% | 6 |
| Nuvola di Marciume | `nuvola_di_marciume` | speciali | 100% | 0% | 0% | 6.4 | 45.6 | 0% | 6 |
| Ombra del passato | `ombra_del_passato` | attacca | 3% | 97% | 0% | 1.8 | 99.0 | 0% | 2 |
| Ombra del passato | `ombra_del_passato` | difendi | 0% | 100% | 0% | 1.9 | 100.0 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | studia | 0% | 100% | 0% | 1.9 | 100.0 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | casuale | 1% | 99% | 0% | 1.9 | 99.8 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | si_cura | 3% | 97% | 0% | 8.0 | 98.5 | 0% | 2 |
| Ombra del passato | `ombra_del_passato` | speciali | 0% | 100% | 0% | 1.9 | 100.0 | 0% | 0 |
| Emblema dell'oppressione | `operaio_posseduto` | attacca | 5% | 95% | 0% | 5.2 | 98.3 | 0% | 1 |
| Emblema dell'oppressione | `operaio_posseduto` | difendi | 0% | 100% | 0% | 12.2 | 100.0 | 0% | 0 |
| Emblema dell'oppressione | `operaio_posseduto` | studia | 2% | 98% | 0% | 5.2 | 99.7 | 0% | 0 |
| Emblema dell'oppressione | `operaio_posseduto` | casuale | 1% | 99% | 0% | 7.2 | 99.5 | 0% | 0 |
| Emblema dell'oppressione | `operaio_posseduto` | si_cura | 11% | 89% | 0% | 19.8 | 94.0 | 0% | 2 |
| Emblema dell'oppressione | `operaio_posseduto` | speciali | 1% | 99% | 0% | 5.2 | 99.7 | 0% | 0 |
| Operaio Sfruttato | `operaio_sfruttato` | attacca | 0% | 100% | 0% | 6.7 | 100.0 | 0% | 0 |
| Operaio Sfruttato | `operaio_sfruttato` | difendi | 0% | 100% | 0% | 12.8 | 100.0 | 0% | 0 |
| Operaio Sfruttato | `operaio_sfruttato` | studia | 0% | 100% | 0% | 6.5 | 100.0 | 0% | 0 |
| Operaio Sfruttato | `operaio_sfruttato` | casuale | 0% | 100% | 0% | 7.8 | 100.0 | 0% | 0 |
| Operaio Sfruttato | `operaio_sfruttato` | si_cura | 0% | 100% | 0% | 25.6 | 100.0 | 0% | 0 |
| Operaio Sfruttato | `operaio_sfruttato` | speciali | 0% | 100% | 0% | 6.6 | 100.0 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | attacca | 0% | 100% | 0% | 5.8 | 100.0 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | difendi | 0% | 100% | 0% | 10.3 | 100.0 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | studia | 0% | 100% | 0% | 5.9 | 100.0 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | casuale | 0% | 100% | 0% | 6.7 | 100.0 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | si_cura | 0% | 100% | 0% | 21.8 | 100.0 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | speciali | 0% | 100% | 0% | 5.8 | 100.0 | 0% | 0 |
| Rana Folle | `rana_folle` | attacca | 100% | 0% | 0% | 11.8 | 32.9 | 0% | 2 |
| Rana Folle | `rana_folle` | difendi | 0% | 57% | 43% | 55.2 | 95.6 | 0% | 0 |
| Rana Folle | `rana_folle` | studia | 95% | 5% | 0% | 14.6 | 62.5 | 0% | 2 |
| Rana Folle | `rana_folle` | casuale | 99% | 1% | 1% | 35.6 | 45.1 | 0% | 2 |
| Rana Folle | `rana_folle` | si_cura | 100% | 0% | 0% | 11.8 | 31.1 | 0% | 2 |
| Rana Folle | `rana_folle` | speciali | 100% | 0% | 0% | 10.1 | 28.5 | 0% | 2 |
| Robo Pattuglia | `robo_pattuglia` | attacca | 7% | 93% | 0% | 10.3 | 96.8 | 0% | 1 |
| Robo Pattuglia | `robo_pattuglia` | difendi | 0% | 80% | 20% | 52.4 | 98.4 | 0% | 0 |
| Robo Pattuglia | `robo_pattuglia` | studia | 5% | 95% | 0% | 10.6 | 98.6 | 0% | 1 |
| Robo Pattuglia | `robo_pattuglia` | casuale | 9% | 89% | 1% | 27.1 | 97.2 | 0% | 1 |
| Robo Pattuglia | `robo_pattuglia` | si_cura | 24% | 76% | 0% | 31.5 | 85.3 | 0% | 4 |
| Robo Pattuglia | `robo_pattuglia` | speciali | 7% | 93% | 0% | 10.4 | 96.7 | 0% | 1 |
| Sacerdote Folle | `sacerdote_folle` | attacca | 3% | 97% | 0% | 2.4 | 98.3 | 0% | 1 |
| Sacerdote Folle | `sacerdote_folle` | difendi | 0% | 100% | 0% | 2.8 | 100.0 | 0% | 0 |
| Sacerdote Folle | `sacerdote_folle` | studia | 0% | 100% | 0% | 2.4 | 100.0 | 0% | 0 |
| Sacerdote Folle | `sacerdote_folle` | casuale | 1% | 99% | 0% | 2.4 | 99.8 | 0% | 0 |
| Sacerdote Folle | `sacerdote_folle` | si_cura | 3% | 97% | 0% | 7.9 | 98.4 | 0% | 1 |
| Sacerdote Folle | `sacerdote_folle` | speciali | 0% | 100% | 0% | 2.5 | 100.0 | 0% | 0 |
| Sadico | `sadico` | attacca | 4% | 96% | 0% | 2.8 | 98.0 | 0% | 1 |
| Sadico | `sadico` | difendi | 0% | 100% | 0% | 2.8 | 100.0 | 0% | 0 |
| Sadico | `sadico` | studia | 0% | 100% | 0% | 2.8 | 100.0 | 0% | 0 |
| Sadico | `sadico` | casuale | 1% | 99% | 0% | 2.8 | 99.7 | 0% | 0 |
| Sadico | `sadico` | si_cura | 4% | 96% | 0% | 7.0 | 97.6 | 0% | 1 |
| Sadico | `sadico` | speciali | 1% | 99% | 0% | 2.8 | 99.9 | 0% | 0 |
| Slime Infimo | `slime_infimo` | attacca | 100% | 0% | 0% | 7.5 | 29.6 | 0% | 2 |
| Slime Infimo | `slime_infimo` | difendi | 0% | 0% | 100% | 60.0 | 68.1 | 0% | 0 |
| Slime Infimo | `slime_infimo` | studia | 100% | 0% | 0% | 10.6 | 48.0 | 0% | 2 |
| Slime Infimo | `slime_infimo` | casuale | 97% | 0% | 3% | 32.6 | 46.5 | 0% | 2 |
| Slime Infimo | `slime_infimo` | si_cura | 100% | 0% | 0% | 7.5 | 29.6 | 0% | 2 |
| Slime Infimo | `slime_infimo` | speciali | 100% | 0% | 0% | 6.6 | 22.0 | 0% | 2 |
| Sogno perduto | `sogno_perduto` | attacca | 100% | 0% | 0% | 2.9 | 19.7 | 0% | 2 |
| Sogno perduto | `sogno_perduto` | difendi | 0% | 0% | 100% | 60.0 | 75.9 | 0% | 0 |
| Sogno perduto | `sogno_perduto` | studia | 100% | 0% | 0% | 5.9 | 38.2 | 0% | 2 |
| Sogno perduto | `sogno_perduto` | casuale | 100% | 0% | 0% | 9.1 | 34.7 | 0% | 2 |
| Sogno perduto | `sogno_perduto` | si_cura | 100% | 0% | 0% | 2.9 | 19.7 | 0% | 2 |
| Sogno perduto | `sogno_perduto` | speciali | 100% | 0% | 0% | 3.0 | 18.4 | 0% | 2 |
| Stigma | `stigma` | attacca | 3% | 97% | 0% | 3.4 | 98.6 | 0% | 1 |
| Stigma | `stigma` | difendi | 0% | 100% | 0% | 3.7 | 100.0 | 0% | 0 |
| Stigma | `stigma` | studia | 0% | 100% | 0% | 3.2 | 100.0 | 0% | 0 |
| Stigma | `stigma` | casuale | 1% | 99% | 0% | 3.4 | 99.7 | 0% | 0 |
| Stigma | `stigma` | si_cura | 11% | 89% | 0% | 13.4 | 94.5 | 0% | 4 |
| Stigma | `stigma` | speciali | 1% | 99% | 0% | 3.3 | 99.8 | 0% | 0 |
| Tartaruga Gigante | `tartaruga_innocente` | attacca | 0% | 0% | 100% | 60.0 | 0.0 | 0% | 0 |
| Tartaruga Gigante | `tartaruga_innocente` | difendi | 0% | 0% | 100% | 60.0 | 0.0 | 0% | 0 |
| Tartaruga Gigante | `tartaruga_innocente` | studia | 100% | 0% | 0% | 2.0 | 0.0 | 100% | 3 |
| Tartaruga Gigante | `tartaruga_innocente` | casuale | 0% | 0% | 100% | 60.0 | 0.0 | 0% | 0 |
| Tartaruga Gigante | `tartaruga_innocente` | si_cura | 0% | 0% | 100% | 60.0 | 0.0 | 0% | 0 |
| Tartaruga Gigante | `tartaruga_innocente` | speciali | 0% | 0% | 100% | 60.0 | 0.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | attacca | 0% | 100% | 0% | 3.8 | 100.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | difendi | 0% | 100% | 0% | 4.4 | 100.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | studia | 0% | 100% | 0% | 3.8 | 100.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | casuale | 0% | 100% | 0% | 4.1 | 100.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | si_cura | 0% | 100% | 0% | 7.4 | 100.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | speciali | 0% | 100% | 0% | 3.8 | 100.0 | 0% | 0 |
| Teschio Errante | `teschio_errante` | attacca | 3% | 97% | 0% | 3.9 | 98.2 | 0% | 1 |
| Teschio Errante | `teschio_errante` | difendi | 0% | 100% | 0% | 5.6 | 100.0 | 0% | 0 |
| Teschio Errante | `teschio_errante` | studia | 1% | 99% | 0% | 4.0 | 99.8 | 0% | 0 |
| Teschio Errante | `teschio_errante` | casuale | 0% | 100% | 0% | 4.3 | 100.0 | 0% | 0 |
| Teschio Errante | `teschio_errante` | si_cura | 13% | 87% | 0% | 14.8 | 91.7 | 0% | 4 |
| Teschio Errante | `teschio_errante` | speciali | 1% | 99% | 0% | 4.0 | 99.6 | 0% | 0 |
| Titano Zombie | `titano_zombie` | attacca | 0% | 100% | 0% | 3.5 | 100.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | difendi | 0% | 100% | 0% | 3.7 | 100.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | studia | 0% | 100% | 0% | 3.5 | 100.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | casuale | 0% | 100% | 0% | 3.6 | 100.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | si_cura | 0% | 100% | 0% | 17.1 | 100.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | speciali | 0% | 100% | 0% | 3.6 | 100.0 | 0% | 0 |
| Capocantiere | `voce_registrata` | attacca | 11% | 89% | 0% | 6.6 | 96.1 | 0% | 1 |
| Capocantiere | `voce_registrata` | difendi | 0% | 100% | 0% | 15.7 | 100.0 | 0% | 0 |
| Capocantiere | `voce_registrata` | studia | 3% | 97% | 0% | 6.7 | 98.9 | 0% | 0 |
| Capocantiere | `voce_registrata` | casuale | 2% | 98% | 0% | 8.5 | 99.2 | 0% | 0 |
| Capocantiere | `voce_registrata` | si_cura | 52% | 48% | 0% | 20.8 | 81.0 | 0% | 7 |
| Capocantiere | `voce_registrata` | speciali | 2% | 98% | 0% | 6.7 | 99.2 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | attacca | 0% | 100% | 0% | 1.2 | 100.0 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | difendi | 0% | 100% | 0% | 1.2 | 100.0 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | studia | 0% | 100% | 0% | 1.2 | 100.0 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | casuale | 0% | 100% | 0% | 1.2 | 100.0 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | si_cura | 0% | 100% | 0% | 1.9 | 100.0 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | speciali | 0% | 100% | 0% | 1.2 | 100.0 | 0% | 0 |
| Zombie Cittadino | `zombie_cittadino` | attacca | 25% | 75% | 0% | 17.6 | 88.1 | 0% | 1 |
| Zombie Cittadino | `zombie_cittadino` | difendi | 0% | 9% | 91% | 58.7 | 74.4 | 0% | 0 |
| Zombie Cittadino | `zombie_cittadino` | studia | 15% | 85% | 0% | 18.4 | 94.3 | 0% | 1 |
| Zombie Cittadino | `zombie_cittadino` | casuale | 16% | 16% | 68% | 52.7 | 73.3 | 0% | 1 |
| Zombie Cittadino | `zombie_cittadino` | si_cura | 67% | 4% | 29% | 38.5 | 40.4 | 0% | 3 |
| Zombie Cittadino | `zombie_cittadino` | speciali | 23% | 77% | 0% | 18.0 | 90.9 | 0% | 1 |
| Zombie Mostruoso | `zombie_mostruoso` | attacca | 13% | 87% | 0% | 9.9 | 94.6 | 0% | 1 |
| Zombie Mostruoso | `zombie_mostruoso` | difendi | 0% | 100% | 0% | 37.2 | 100.0 | 0% | 0 |
| Zombie Mostruoso | `zombie_mostruoso` | studia | 2% | 98% | 0% | 10.7 | 99.2 | 0% | 0 |
| Zombie Mostruoso | `zombie_mostruoso` | casuale | 3% | 97% | 0% | 19.4 | 99.3 | 0% | 0 |
| Zombie Mostruoso | `zombie_mostruoso` | si_cura | 100% | 0% | 0% | 14.5 | 28.9 | 0% | 9 |
| Zombie Mostruoso | `zombie_mostruoso` | speciali | 49% | 51% | 0% | 9.1 | 91.2 | 0% | 4 |

## Protagonista di livello 2

| creatura | id | come si gioca | vinte | perse | ∞ | giri | danno | risp. | xp |
|---|---|---|--:|--:|--:|--:|--:|--:|--:|
| Abominio Marcio | `abominio_marcio` | attacca | 0% | 100% | 0% | 3.3 | 145.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | difendi | 0% | 100% | 0% | 3.9 | 145.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | studia | 0% | 100% | 0% | 3.4 | 145.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | casuale | 0% | 100% | 0% | 3.6 | 145.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | si_cura | 0% | 100% | 0% | 9.4 | 145.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | speciali | 0% | 100% | 0% | 3.4 | 145.0 | 0% | 0 |
| Oppresso | `comparsa_di_ruggine` | attacca | 24% | 76% | 0% | 19.9 | 128.7 | 0% | 4 |
| Oppresso | `comparsa_di_ruggine` | difendi | 0% | 0% | 100% | 60.0 | 69.3 | 0% | 0 |
| Oppresso | `comparsa_di_ruggine` | studia | 19% | 81% | 0% | 20.9 | 134.5 | 0% | 3 |
| Oppresso | `comparsa_di_ruggine` | casuale | 23% | 2% | 75% | 54.0 | 89.1 | 0% | 4 |
| Oppresso | `comparsa_di_ruggine` | si_cura | 44% | 1% | 55% | 46.1 | 73.0 | 0% | 7 |
| Oppresso | `comparsa_di_ruggine` | speciali | 21% | 79% | 0% | 19.8 | 131.2 | 0% | 3 |
| Diabolo | `diabolo` | attacca | 5% | 95% | 0% | 5.4 | 141.9 | 0% | 2 |
| Diabolo | `diabolo` | difendi | 2% | 98% | 0% | 9.6 | 143.6 | 0% | 1 |
| Diabolo | `diabolo` | studia | 1% | 99% | 0% | 5.7 | 144.9 | 0% | 0 |
| Diabolo | `diabolo` | casuale | 2% | 98% | 0% | 6.2 | 144.3 | 0% | 1 |
| Diabolo | `diabolo` | si_cura | 18% | 82% | 0% | 17.8 | 129.5 | 0% | 6 |
| Diabolo | `diabolo` | speciali | 4% | 96% | 0% | 5.5 | 143.3 | 0% | 1 |
| Il Divoratore | `divoratore` | attacca | 0% | 100% | 0% | 5.8 | 145.0 | 0% | 0 |
| Il Divoratore | `divoratore` | difendi | 0% | 100% | 0% | 11.6 | 145.0 | 0% | 0 |
| Il Divoratore | `divoratore` | studia | 0% | 100% | 0% | 5.8 | 145.0 | 0% | 0 |
| Il Divoratore | `divoratore` | casuale | 0% | 100% | 0% | 7.2 | 145.0 | 0% | 0 |
| Il Divoratore | `divoratore` | si_cura | 0% | 100% | 0% | 21.9 | 145.0 | 0% | 0 |
| Il Divoratore | `divoratore` | speciali | 0% | 100% | 0% | 5.7 | 145.0 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | attacca | 4% | 96% | 0% | 3.9 | 142.0 | 0% | 2 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | difendi | 0% | 100% | 0% | 6.3 | 145.0 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | studia | 0% | 100% | 0% | 4.0 | 145.0 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | casuale | 1% | 99% | 0% | 4.6 | 144.4 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | si_cura | 11% | 89% | 0% | 15.1 | 134.0 | 0% | 5 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | speciali | 0% | 100% | 0% | 4.0 | 145.0 | 0% | 0 |
| Donna Spinosa | `donna_spinosa` | attacca | 5% | 95% | 0% | 3.3 | 141.8 | 0% | 2 |
| Donna Spinosa | `donna_spinosa` | difendi | 0% | 100% | 0% | 3.7 | 145.0 | 0% | 0 |
| Donna Spinosa | `donna_spinosa` | studia | 0% | 100% | 0% | 3.4 | 145.0 | 0% | 0 |
| Donna Spinosa | `donna_spinosa` | casuale | 1% | 99% | 0% | 3.5 | 144.4 | 0% | 0 |
| Donna Spinosa | `donna_spinosa` | si_cura | 5% | 95% | 0% | 9.5 | 141.1 | 0% | 2 |
| Donna Spinosa | `donna_spinosa` | speciali | 1% | 99% | 0% | 3.3 | 144.8 | 0% | 0 |
| Rottami Erranti | `ferraglia_urlante` | attacca | 0% | 100% | 0% | 16.4 | 145.0 | 0% | 0 |
| Rottami Erranti | `ferraglia_urlante` | difendi | 0% | 45% | 55% | 55.8 | 130.6 | 0% | 0 |
| Rottami Erranti | `ferraglia_urlante` | studia | 0% | 100% | 0% | 16.5 | 145.0 | 0% | 0 |
| Rottami Erranti | `ferraglia_urlante` | casuale | 0% | 89% | 11% | 38.7 | 143.1 | 0% | 0 |
| Rottami Erranti | `ferraglia_urlante` | si_cura | 0% | 99% | 1% | 51.7 | 144.8 | 0% | 0 |
| Rottami Erranti | `ferraglia_urlante` | speciali | 0% | 100% | 0% | 16.6 | 145.0 | 0% | 0 |
| Ghoul | `ghoul` | attacca | 6% | 94% | 0% | 5.2 | 140.1 | 0% | 2 |
| Ghoul | `ghoul` | difendi | 0% | 100% | 0% | 8.4 | 145.0 | 0% | 0 |
| Ghoul | `ghoul` | studia | 1% | 99% | 0% | 5.4 | 144.7 | 0% | 0 |
| Ghoul | `ghoul` | casuale | 2% | 98% | 0% | 6.0 | 143.7 | 0% | 1 |
| Ghoul | `ghoul` | si_cura | 15% | 85% | 0% | 18.3 | 131.4 | 0% | 4 |
| Ghoul | `ghoul` | speciali | 2% | 98% | 0% | 5.4 | 144.0 | 0% | 1 |
| El Muy Bonito | `giocoliere` | attacca | 0% | 100% | 0% | 8.8 | 145.0 | 0% | 0 |
| El Muy Bonito | `giocoliere` | difendi | 0% | 99% | 1% | 41.0 | 145.0 | 0% | 0 |
| El Muy Bonito | `giocoliere` | studia | 0% | 100% | 0% | 5.4 | 145.0 | 0% | 0 |
| El Muy Bonito | `giocoliere` | casuale | 0% | 100% | 0% | 8.9 | 145.0 | 0% | 0 |
| El Muy Bonito | `giocoliere` | si_cura | 90% | 10% | 0% | 25.9 | 110.2 | 0% | 26 |
| El Muy Bonito | `giocoliere` | speciali | 0% | 100% | 0% | 8.7 | 145.0 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | attacca | 100% | 0% | 0% | 28.5 | 60.9 | 0% | 153 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | difendi | 0% | 0% | 100% | 60.0 | 32.3 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | studia | 100% | 0% | 0% | 34.6 | 79.6 | 0% | 154 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | casuale | 2% | 0% | 98% | 59.9 | 41.0 | 0% | 3 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | si_cura | 100% | 0% | 0% | 28.8 | 33.1 | 0% | 153 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | speciali | 100% | 0% | 0% | 22.9 | 45.3 | 0% | 153 |
| Goblin Possessivo | `goblin_possessivo` | attacca | 100% | 0% | 0% | 4.8 | 15.1 | 0% | 2 |
| Goblin Possessivo | `goblin_possessivo` | difendi | 0% | 0% | 100% | 60.0 | 43.0 | 0% | 0 |
| Goblin Possessivo | `goblin_possessivo` | studia | 100% | 0% | 0% | 7.7 | 26.2 | 0% | 2 |
| Goblin Possessivo | `goblin_possessivo` | casuale | 100% | 0% | 0% | 15.9 | 21.3 | 0% | 2 |
| Goblin Possessivo | `goblin_possessivo` | si_cura | 100% | 0% | 0% | 4.8 | 15.1 | 0% | 2 |
| Goblin Possessivo | `goblin_possessivo` | speciali | 100% | 0% | 0% | 3.0 | 5.8 | 0% | 2 |
| Goblin Tipico | `goblin_tipico` | attacca | 100% | 0% | 0% | 4.8 | 15.1 | 0% | 2 |
| Goblin Tipico | `goblin_tipico` | difendi | 0% | 0% | 100% | 60.0 | 43.0 | 0% | 0 |
| Goblin Tipico | `goblin_tipico` | studia | 100% | 0% | 0% | 7.7 | 26.2 | 0% | 2 |
| Goblin Tipico | `goblin_tipico` | casuale | 100% | 0% | 0% | 15.9 | 21.3 | 0% | 2 |
| Goblin Tipico | `goblin_tipico` | si_cura | 100% | 0% | 0% | 4.8 | 15.1 | 0% | 2 |
| Goblin Tipico | `goblin_tipico` | speciali | 100% | 0% | 0% | 3.0 | 5.8 | 0% | 2 |
| Golem errante di rottami | `golem_errante` | attacca | 0% | 100% | 0% | 5.1 | 145.0 | 0% | 0 |
| Golem errante di rottami | `golem_errante` | difendi | 0% | 100% | 0% | 7.3 | 145.0 | 0% | 0 |
| Golem errante di rottami | `golem_errante` | studia | 0% | 100% | 0% | 5.1 | 145.0 | 0% | 0 |
| Golem errante di rottami | `golem_errante` | casuale | 0% | 100% | 0% | 5.7 | 145.0 | 0% | 0 |
| Golem errante di rottami | `golem_errante` | si_cura | 0% | 100% | 0% | 18.9 | 145.0 | 0% | 0 |
| Golem errante di rottami | `golem_errante` | speciali | 0% | 100% | 0% | 5.1 | 145.0 | 0% | 0 |
| Infetto Rapido | `infetto_rapido` | attacca | 100% | 0% | 0% | 4.7 | 33.1 | 0% | 6 |
| Infetto Rapido | `infetto_rapido` | difendi | 0% | 0% | 100% | 60.0 | 96.1 | 0% | 0 |
| Infetto Rapido | `infetto_rapido` | studia | 100% | 0% | 0% | 7.8 | 51.8 | 0% | 6 |
| Infetto Rapido | `infetto_rapido` | casuale | 100% | 0% | 0% | 14.3 | 40.3 | 0% | 6 |
| Infetto Rapido | `infetto_rapido` | si_cura | 100% | 0% | 0% | 4.7 | 33.1 | 0% | 6 |
| Infetto Rapido | `infetto_rapido` | speciali | 100% | 0% | 0% | 3.9 | 26.3 | 0% | 6 |
| L'ultimo spettacolo di Jerah | `jerah` | attacca | 0% | 100% | 0% | 3.0 | 145.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | difendi | 0% | 100% | 0% | 3.1 | 145.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | studia | 0% | 100% | 0% | 3.0 | 145.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | casuale | 0% | 100% | 0% | 2.9 | 145.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | si_cura | 0% | 100% | 0% | 7.9 | 145.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | speciali | 0% | 100% | 0% | 3.0 | 145.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | attacca | 0% | 100% | 0% | 4.3 | 145.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | difendi | 0% | 100% | 0% | 4.5 | 145.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | studia | 0% | 100% | 0% | 4.0 | 145.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | casuale | 0% | 100% | 0% | 4.3 | 145.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | si_cura | 0% | 100% | 0% | 11.0 | 145.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | speciali | 0% | 100% | 0% | 3.9 | 145.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | attacca | 0% | 100% | 0% | 1.8 | 145.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | difendi | 0% | 100% | 0% | 1.9 | 145.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | studia | 0% | 100% | 0% | 1.8 | 145.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | casuale | 0% | 100% | 0% | 1.7 | 145.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | si_cura | 0% | 100% | 0% | 4.9 | 145.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | speciali | 0% | 100% | 0% | 1.8 | 145.0 | 0% | 0 |
| ??? | `l_immortale` | attacca | 0% | 100% | 0% | 29.9 | 145.0 | 0% | 0 |
| ??? | `l_immortale` | difendi | 0% | 0% | 100% | 60.0 | 63.9 | 0% | 0 |
| ??? | `l_immortale` | studia | 0% | 100% | 0% | 30.4 | 145.0 | 0% | 0 |
| ??? | `l_immortale` | casuale | 0% | 0% | 100% | 60.0 | 73.7 | 0% | 0 |
| ??? | `l_immortale` | si_cura | 0% | 0% | 100% | 60.0 | 43.4 | 0% | 0 |
| ??? | `l_immortale` | speciali | 0% | 100% | 0% | 29.4 | 145.0 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | attacca | 6% | 94% | 0% | 5.4 | 139.8 | 0% | 2 |
| Madre in Lacrime | `madre_in_lacrime` | difendi | 0% | 100% | 0% | 9.4 | 145.0 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | studia | 3% | 97% | 0% | 5.7 | 144.4 | 0% | 1 |
| Madre in Lacrime | `madre_in_lacrime` | casuale | 2% | 98% | 0% | 6.5 | 143.5 | 0% | 1 |
| Madre in Lacrime | `madre_in_lacrime` | si_cura | 21% | 79% | 0% | 18.5 | 127.0 | 0% | 6 |
| Madre in Lacrime | `madre_in_lacrime` | speciali | 2% | 98% | 0% | 5.6 | 144.0 | 0% | 1 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | attacca | 0% | 100% | 0% | 5.0 | 145.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | difendi | 0% | 100% | 0% | 5.0 | 145.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | studia | 0% | 100% | 0% | 5.0 | 145.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | casuale | 0% | 100% | 0% | 5.0 | 145.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | si_cura | 0% | 100% | 0% | 5.0 | 145.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | speciali | 0% | 100% | 0% | 5.0 | 145.0 | 0% | 0 |
| Marionetta | `marionetta` | attacca | 3% | 97% | 0% | 3.5 | 142.7 | 0% | 2 |
| Marionetta | `marionetta` | difendi | 0% | 100% | 0% | 4.1 | 145.0 | 0% | 0 |
| Marionetta | `marionetta` | studia | 1% | 99% | 0% | 3.7 | 145.0 | 0% | 0 |
| Marionetta | `marionetta` | casuale | 1% | 99% | 0% | 3.8 | 144.6 | 0% | 0 |
| Marionetta | `marionetta` | si_cura | 8% | 92% | 0% | 12.3 | 137.1 | 0% | 4 |
| Marionetta | `marionetta` | speciali | 1% | 99% | 0% | 3.6 | 144.7 | 0% | 0 |
| Fomentado | `maschera_vuota` | attacca | 100% | 0% | 0% | 6.9 | 76.4 | 0% | 9 |
| Fomentado | `maschera_vuota` | difendi | 100% | 0% | 0% | 30.8 | 67.6 | 0% | 9 |
| Fomentado | `maschera_vuota` | studia | 100% | 0% | 0% | 9.7 | 102.5 | 0% | 9 |
| Fomentado | `maschera_vuota` | casuale | 100% | 0% | 0% | 14.6 | 82.6 | 0% | 9 |
| Fomentado | `maschera_vuota` | si_cura | 100% | 0% | 0% | 7.0 | 49.0 | 0% | 9 |
| Fomentado | `maschera_vuota` | speciali | 100% | 0% | 0% | 6.0 | 66.7 | 0% | 9 |
| Nimbo Boy | `nimbo_boy` | attacca | 100% | 0% | 0% | 3.0 | 0.0 | 0% | 2 |
| Nimbo Boy | `nimbo_boy` | difendi | 0% | 0% | 100% | 60.0 | 0.0 | 0% | 0 |
| Nimbo Boy | `nimbo_boy` | studia | 100% | 0% | 0% | 6.0 | 0.0 | 0% | 2 |
| Nimbo Boy | `nimbo_boy` | casuale | 100% | 0% | 0% | 8.7 | 0.0 | 0% | 2 |
| Nimbo Boy | `nimbo_boy` | si_cura | 100% | 0% | 0% | 3.0 | 0.0 | 0% | 2 |
| Nimbo Boy | `nimbo_boy` | speciali | 100% | 0% | 0% | 5.0 | 0.0 | 0% | 2 |
| Nuvola di Marciume | `nuvola_di_marciume` | attacca | 100% | 0% | 0% | 4.9 | 29.0 | 0% | 6 |
| Nuvola di Marciume | `nuvola_di_marciume` | difendi | 0% | 100% | 0% | 47.9 | 145.0 | 0% | 0 |
| Nuvola di Marciume | `nuvola_di_marciume` | studia | 100% | 0% | 0% | 7.9 | 48.7 | 0% | 6 |
| Nuvola di Marciume | `nuvola_di_marciume` | casuale | 100% | 0% | 0% | 14.6 | 53.0 | 0% | 6 |
| Nuvola di Marciume | `nuvola_di_marciume` | si_cura | 100% | 0% | 0% | 5.7 | 29.8 | 0% | 6 |
| Nuvola di Marciume | `nuvola_di_marciume` | speciali | 100% | 0% | 0% | 3.9 | 22.5 | 0% | 6 |
| Ombra del passato | `ombra_del_passato` | attacca | 3% | 97% | 0% | 2.6 | 142.4 | 0% | 2 |
| Ombra del passato | `ombra_del_passato` | difendi | 0% | 100% | 0% | 2.8 | 145.0 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | studia | 0% | 100% | 0% | 2.6 | 145.0 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | casuale | 1% | 99% | 0% | 2.7 | 144.5 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | si_cura | 5% | 95% | 0% | 10.8 | 141.4 | 0% | 3 |
| Ombra del passato | `ombra_del_passato` | speciali | 1% | 99% | 0% | 2.6 | 144.9 | 0% | 0 |
| Emblema dell'oppressione | `operaio_posseduto` | attacca | 9% | 91% | 0% | 10.1 | 139.8 | 0% | 2 |
| Emblema dell'oppressione | `operaio_posseduto` | difendi | 0% | 100% | 0% | 32.6 | 145.0 | 0% | 0 |
| Emblema dell'oppressione | `operaio_posseduto` | studia | 4% | 96% | 0% | 9.3 | 142.5 | 0% | 1 |
| Emblema dell'oppressione | `operaio_posseduto` | casuale | 7% | 93% | 0% | 18.2 | 142.1 | 0% | 1 |
| Emblema dell'oppressione | `operaio_posseduto` | si_cura | 68% | 32% | 0% | 30.9 | 108.3 | 0% | 12 |
| Emblema dell'oppressione | `operaio_posseduto` | speciali | 5% | 95% | 0% | 10.3 | 142.9 | 0% | 1 |
| Operaio Sfruttato | `operaio_sfruttato` | attacca | 0% | 100% | 0% | 10.8 | 145.0 | 0% | 0 |
| Operaio Sfruttato | `operaio_sfruttato` | difendi | 0% | 95% | 5% | 45.8 | 144.7 | 0% | 0 |
| Operaio Sfruttato | `operaio_sfruttato` | studia | 0% | 100% | 0% | 10.5 | 145.0 | 0% | 0 |
| Operaio Sfruttato | `operaio_sfruttato` | casuale | 0% | 100% | 0% | 22.3 | 145.0 | 0% | 0 |
| Operaio Sfruttato | `operaio_sfruttato` | si_cura | 0% | 100% | 0% | 36.2 | 145.0 | 0% | 0 |
| Operaio Sfruttato | `operaio_sfruttato` | speciali | 0% | 100% | 0% | 10.6 | 145.0 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | attacca | 0% | 100% | 0% | 9.2 | 145.0 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | difendi | 0% | 100% | 0% | 31.0 | 145.0 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | studia | 0% | 100% | 0% | 9.3 | 145.0 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | casuale | 0% | 100% | 0% | 15.6 | 145.0 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | si_cura | 0% | 100% | 0% | 35.1 | 145.0 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | speciali | 0% | 100% | 0% | 9.3 | 145.0 | 0% | 0 |
| Rana Folle | `rana_folle` | attacca | 100% | 0% | 0% | 8.4 | 17.8 | 0% | 2 |
| Rana Folle | `rana_folle` | difendi | 0% | 0% | 100% | 60.0 | 91.5 | 0% | 0 |
| Rana Folle | `rana_folle` | studia | 100% | 0% | 0% | 11.4 | 41.7 | 0% | 2 |
| Rana Folle | `rana_folle` | casuale | 100% | 0% | 0% | 25.5 | 27.1 | 0% | 2 |
| Rana Folle | `rana_folle` | si_cura | 100% | 0% | 0% | 8.4 | 17.8 | 0% | 2 |
| Rana Folle | `rana_folle` | speciali | 100% | 0% | 0% | 7.1 | 15.4 | 0% | 2 |
| Robo Pattuglia | `robo_pattuglia` | attacca | 19% | 81% | 0% | 16.6 | 133.1 | 0% | 3 |
| Robo Pattuglia | `robo_pattuglia` | difendi | 0% | 0% | 100% | 60.0 | 81.4 | 0% | 0 |
| Robo Pattuglia | `robo_pattuglia` | studia | 17% | 83% | 0% | 17.2 | 137.1 | 0% | 3 |
| Robo Pattuglia | `robo_pattuglia` | casuale | 19% | 12% | 69% | 53.6 | 104.9 | 0% | 3 |
| Robo Pattuglia | `robo_pattuglia` | si_cura | 39% | 45% | 16% | 46.5 | 106.2 | 0% | 6 |
| Robo Pattuglia | `robo_pattuglia` | speciali | 12% | 88% | 0% | 18.0 | 136.9 | 0% | 2 |
| Sacerdote Folle | `sacerdote_folle` | attacca | 4% | 96% | 0% | 3.8 | 141.7 | 0% | 2 |
| Sacerdote Folle | `sacerdote_folle` | difendi | 0% | 100% | 0% | 4.7 | 145.0 | 0% | 0 |
| Sacerdote Folle | `sacerdote_folle` | studia | 1% | 99% | 0% | 3.9 | 145.0 | 0% | 0 |
| Sacerdote Folle | `sacerdote_folle` | casuale | 1% | 99% | 0% | 4.1 | 144.3 | 0% | 1 |
| Sacerdote Folle | `sacerdote_folle` | si_cura | 5% | 95% | 0% | 11.2 | 140.5 | 0% | 2 |
| Sacerdote Folle | `sacerdote_folle` | speciali | 1% | 99% | 0% | 3.8 | 144.7 | 0% | 0 |
| Sadico | `sadico` | attacca | 5% | 95% | 0% | 4.1 | 140.5 | 0% | 2 |
| Sadico | `sadico` | difendi | 0% | 100% | 0% | 5.4 | 145.0 | 0% | 0 |
| Sadico | `sadico` | studia | 1% | 99% | 0% | 4.1 | 144.9 | 0% | 0 |
| Sadico | `sadico` | casuale | 1% | 99% | 0% | 4.5 | 144.0 | 0% | 0 |
| Sadico | `sadico` | si_cura | 3% | 97% | 0% | 12.1 | 141.9 | 0% | 1 |
| Sadico | `sadico` | speciali | 2% | 98% | 0% | 4.1 | 144.0 | 0% | 1 |
| Slime Infimo | `slime_infimo` | attacca | 100% | 0% | 0% | 4.9 | 13.5 | 0% | 2 |
| Slime Infimo | `slime_infimo` | difendi | 0% | 0% | 100% | 60.0 | 60.4 | 0% | 0 |
| Slime Infimo | `slime_infimo` | studia | 100% | 0% | 0% | 7.9 | 26.9 | 0% | 2 |
| Slime Infimo | `slime_infimo` | casuale | 100% | 0% | 0% | 17.5 | 23.2 | 0% | 2 |
| Slime Infimo | `slime_infimo` | si_cura | 100% | 0% | 0% | 4.9 | 13.5 | 0% | 2 |
| Slime Infimo | `slime_infimo` | speciali | 100% | 0% | 0% | 3.0 | 6.4 | 0% | 2 |
| Sogno perduto | `sogno_perduto` | attacca | 100% | 0% | 0% | 2.0 | 10.0 | 0% | 2 |
| Sogno perduto | `sogno_perduto` | difendi | 0% | 0% | 100% | 60.0 | 66.0 | 0% | 0 |
| Sogno perduto | `sogno_perduto` | studia | 100% | 0% | 0% | 4.9 | 25.4 | 0% | 2 |
| Sogno perduto | `sogno_perduto` | casuale | 100% | 0% | 0% | 6.4 | 18.3 | 0% | 2 |
| Sogno perduto | `sogno_perduto` | si_cura | 100% | 0% | 0% | 2.0 | 10.0 | 0% | 2 |
| Sogno perduto | `sogno_perduto` | speciali | 100% | 0% | 0% | 3.0 | 15.4 | 0% | 2 |
| Stigma | `stigma` | attacca | 7% | 93% | 0% | 5.1 | 141.5 | 0% | 2 |
| Stigma | `stigma` | difendi | 0% | 100% | 0% | 7.2 | 145.0 | 0% | 0 |
| Stigma | `stigma` | studia | 2% | 98% | 0% | 5.1 | 144.2 | 0% | 1 |
| Stigma | `stigma` | casuale | 1% | 99% | 0% | 5.6 | 144.2 | 0% | 0 |
| Stigma | `stigma` | si_cura | 11% | 89% | 0% | 18.6 | 135.8 | 0% | 4 |
| Stigma | `stigma` | speciali | 2% | 98% | 0% | 5.2 | 144.3 | 0% | 1 |
| Tartaruga Gigante | `tartaruga_innocente` | attacca | 0% | 0% | 100% | 60.0 | 0.0 | 0% | 0 |
| Tartaruga Gigante | `tartaruga_innocente` | difendi | 0% | 0% | 100% | 60.0 | 0.0 | 0% | 0 |
| Tartaruga Gigante | `tartaruga_innocente` | studia | 100% | 0% | 0% | 2.0 | 0.0 | 100% | 3 |
| Tartaruga Gigante | `tartaruga_innocente` | casuale | 0% | 0% | 100% | 60.0 | 0.0 | 0% | 0 |
| Tartaruga Gigante | `tartaruga_innocente` | si_cura | 0% | 0% | 100% | 60.0 | 0.0 | 0% | 0 |
| Tartaruga Gigante | `tartaruga_innocente` | speciali | 0% | 0% | 100% | 60.0 | 0.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | attacca | 0% | 100% | 0% | 5.2 | 145.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | difendi | 0% | 100% | 0% | 6.5 | 145.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | studia | 0% | 100% | 0% | 5.3 | 145.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | casuale | 0% | 100% | 0% | 5.7 | 145.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | si_cura | 0% | 100% | 0% | 9.7 | 145.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | speciali | 0% | 100% | 0% | 5.2 | 145.0 | 0% | 0 |
| Teschio Errante | `teschio_errante` | attacca | 3% | 97% | 0% | 6.2 | 141.6 | 0% | 1 |
| Teschio Errante | `teschio_errante` | difendi | 0% | 100% | 0% | 14.9 | 145.0 | 0% | 0 |
| Teschio Errante | `teschio_errante` | studia | 5% | 95% | 0% | 6.3 | 143.4 | 0% | 1 |
| Teschio Errante | `teschio_errante` | casuale | 0% | 100% | 0% | 8.1 | 145.0 | 0% | 0 |
| Teschio Errante | `teschio_errante` | si_cura | 17% | 83% | 0% | 20.5 | 127.5 | 0% | 5 |
| Teschio Errante | `teschio_errante` | speciali | 3% | 97% | 0% | 6.4 | 143.4 | 0% | 1 |
| Titano Zombie | `titano_zombie` | attacca | 0% | 100% | 0% | 5.7 | 145.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | difendi | 0% | 100% | 0% | 6.1 | 145.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | studia | 0% | 100% | 0% | 5.0 | 145.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | casuale | 0% | 100% | 0% | 5.3 | 145.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | si_cura | 0% | 100% | 0% | 21.3 | 145.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | speciali | 0% | 100% | 0% | 5.0 | 145.0 | 0% | 0 |
| Capocantiere | `voce_registrata` | attacca | 16% | 84% | 0% | 9.7 | 135.1 | 0% | 2 |
| Capocantiere | `voce_registrata` | difendi | 0% | 81% | 19% | 50.4 | 142.9 | 0% | 0 |
| Capocantiere | `voce_registrata` | studia | 7% | 93% | 0% | 10.7 | 141.2 | 0% | 1 |
| Capocantiere | `voce_registrata` | casuale | 14% | 86% | 0% | 23.3 | 140.8 | 0% | 2 |
| Capocantiere | `voce_registrata` | si_cura | 100% | 0% | 0% | 13.1 | 39.2 | 0% | 13 |
| Capocantiere | `voce_registrata` | speciali | 82% | 18% | 0% | 9.0 | 125.0 | 0% | 11 |
| Volto sulla parete | `volto_sulla_parete` | attacca | 0% | 100% | 0% | 2.1 | 145.0 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | difendi | 0% | 100% | 0% | 2.2 | 145.0 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | studia | 0% | 100% | 0% | 2.1 | 145.0 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | casuale | 0% | 100% | 0% | 2.1 | 145.0 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | si_cura | 0% | 100% | 0% | 4.2 | 145.0 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | speciali | 0% | 100% | 0% | 2.1 | 145.0 | 0% | 0 |
| Zombie Cittadino | `zombie_cittadino` | attacca | 57% | 43% | 0% | 25.1 | 103.9 | 0% | 3 |
| Zombie Cittadino | `zombie_cittadino` | difendi | 0% | 3% | 97% | 59.4 | 70.7 | 0% | 0 |
| Zombie Cittadino | `zombie_cittadino` | studia | 43% | 57% | 0% | 28.0 | 117.8 | 0% | 2 |
| Zombie Cittadino | `zombie_cittadino` | casuale | 25% | 1% | 73% | 54.5 | 61.6 | 0% | 1 |
| Zombie Cittadino | `zombie_cittadino` | si_cura | 94% | 1% | 5% | 32.1 | 43.5 | 0% | 5 |
| Zombie Cittadino | `zombie_cittadino` | speciali | 69% | 31% | 0% | 23.8 | 99.5 | 0% | 3 |
| Zombie Mostruoso | `zombie_mostruoso` | attacca | 100% | 0% | 0% | 8.4 | 72.9 | 0% | 9 |
| Zombie Mostruoso | `zombie_mostruoso` | difendi | 0% | 0% | 100% | 60.0 | 98.0 | 0% | 0 |
| Zombie Mostruoso | `zombie_mostruoso` | studia | 100% | 0% | 0% | 11.6 | 101.9 | 0% | 9 |
| Zombie Mostruoso | `zombie_mostruoso` | casuale | 89% | 11% | 0% | 26.0 | 104.7 | 0% | 8 |
| Zombie Mostruoso | `zombie_mostruoso` | si_cura | 100% | 0% | 0% | 8.8 | 45.0 | 0% | 9 |
| Zombie Mostruoso | `zombie_mostruoso` | speciali | 100% | 0% | 0% | 6.9 | 59.5 | 0% | 9 |

## Protagonista di livello 3

| creatura | id | come si gioca | vinte | perse | ∞ | giri | danno | risp. | xp |
|---|---|---|--:|--:|--:|--:|--:|--:|--:|
| Abominio Marcio | `abominio_marcio` | attacca | 0% | 100% | 0% | 4.8 | 190.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | difendi | 0% | 100% | 0% | 6.2 | 190.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | studia | 0% | 100% | 0% | 4.7 | 190.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | casuale | 0% | 100% | 0% | 5.2 | 190.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | si_cura | 0% | 100% | 0% | 14.6 | 190.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | speciali | 0% | 100% | 0% | 4.8 | 190.0 | 0% | 0 |
| Oppresso | `comparsa_di_ruggine` | attacca | 47% | 53% | 0% | 30.6 | 146.2 | 0% | 7 |
| Oppresso | `comparsa_di_ruggine` | difendi | 0% | 0% | 100% | 60.0 | 44.8 | 0% | 0 |
| Oppresso | `comparsa_di_ruggine` | studia | 35% | 65% | 0% | 33.3 | 151.7 | 0% | 6 |
| Oppresso | `comparsa_di_ruggine` | casuale | 15% | 0% | 85% | 56.7 | 56.8 | 0% | 2 |
| Oppresso | `comparsa_di_ruggine` | si_cura | 69% | 0% | 31% | 38.6 | 55.4 | 0% | 11 |
| Oppresso | `comparsa_di_ruggine` | speciali | 95% | 5% | 0% | 17.8 | 89.8 | 0% | 15 |
| Diabolo | `diabolo` | attacca | 7% | 93% | 0% | 7.6 | 183.8 | 0% | 2 |
| Diabolo | `diabolo` | difendi | 4% | 96% | 0% | 22.1 | 187.1 | 0% | 1 |
| Diabolo | `diabolo` | studia | 3% | 97% | 0% | 7.9 | 188.5 | 0% | 1 |
| Diabolo | `diabolo` | casuale | 4% | 96% | 0% | 10.4 | 187.7 | 0% | 1 |
| Diabolo | `diabolo` | si_cura | 15% | 85% | 0% | 21.8 | 170.4 | 0% | 5 |
| Diabolo | `diabolo` | speciali | 7% | 93% | 0% | 7.7 | 185.4 | 0% | 2 |
| Il Divoratore | `divoratore` | attacca | 0% | 100% | 0% | 8.3 | 190.0 | 0% | 0 |
| Il Divoratore | `divoratore` | difendi | 0% | 100% | 0% | 24.6 | 190.0 | 0% | 0 |
| Il Divoratore | `divoratore` | studia | 0% | 100% | 0% | 8.4 | 190.0 | 0% | 0 |
| Il Divoratore | `divoratore` | casuale | 0% | 100% | 0% | 13.1 | 190.0 | 0% | 0 |
| Il Divoratore | `divoratore` | si_cura | 0% | 100% | 0% | 27.7 | 190.0 | 0% | 0 |
| Il Divoratore | `divoratore` | speciali | 0% | 100% | 0% | 8.3 | 190.0 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | attacca | 4% | 96% | 0% | 5.8 | 185.1 | 0% | 2 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | difendi | 0% | 100% | 0% | 13.3 | 190.0 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | studia | 2% | 98% | 0% | 6.0 | 189.2 | 0% | 1 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | casuale | 1% | 99% | 0% | 7.2 | 189.1 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | si_cura | 18% | 82% | 0% | 17.7 | 168.5 | 0% | 8 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | speciali | 1% | 99% | 0% | 5.9 | 189.7 | 0% | 0 |
| Donna Spinosa | `donna_spinosa` | attacca | 6% | 94% | 0% | 4.6 | 184.2 | 0% | 3 |
| Donna Spinosa | `donna_spinosa` | difendi | 0% | 100% | 0% | 5.9 | 190.0 | 0% | 0 |
| Donna Spinosa | `donna_spinosa` | studia | 2% | 98% | 0% | 4.6 | 189.4 | 0% | 1 |
| Donna Spinosa | `donna_spinosa` | casuale | 1% | 99% | 0% | 5.0 | 189.1 | 0% | 0 |
| Donna Spinosa | `donna_spinosa` | si_cura | 4% | 96% | 0% | 13.6 | 185.6 | 0% | 2 |
| Donna Spinosa | `donna_spinosa` | speciali | 2% | 98% | 0% | 4.6 | 188.9 | 0% | 1 |
| Rottami Erranti | `ferraglia_urlante` | attacca | 0% | 100% | 0% | 23.3 | 190.0 | 0% | 0 |
| Rottami Erranti | `ferraglia_urlante` | difendi | 0% | 1% | 99% | 59.9 | 115.0 | 0% | 0 |
| Rottami Erranti | `ferraglia_urlante` | studia | 0% | 100% | 0% | 24.3 | 190.0 | 0% | 0 |
| Rottami Erranti | `ferraglia_urlante` | casuale | 0% | 89% | 11% | 47.8 | 185.3 | 0% | 0 |
| Rottami Erranti | `ferraglia_urlante` | si_cura | 0% | 100% | 0% | 39.0 | 190.0 | 0% | 0 |
| Rottami Erranti | `ferraglia_urlante` | speciali | 0% | 100% | 0% | 17.8 | 190.0 | 0% | 0 |
| Ghoul | `ghoul` | attacca | 6% | 94% | 0% | 7.3 | 182.2 | 0% | 2 |
| Ghoul | `ghoul` | difendi | 0% | 100% | 0% | 18.2 | 190.0 | 0% | 0 |
| Ghoul | `ghoul` | studia | 5% | 95% | 0% | 7.6 | 187.7 | 0% | 2 |
| Ghoul | `ghoul` | casuale | 3% | 97% | 0% | 9.8 | 187.3 | 0% | 1 |
| Ghoul | `ghoul` | si_cura | 28% | 72% | 0% | 20.7 | 164.0 | 0% | 8 |
| Ghoul | `ghoul` | speciali | 3% | 97% | 0% | 7.6 | 187.8 | 0% | 1 |
| El Muy Bonito | `giocoliere` | attacca | 0% | 100% | 0% | 11.8 | 190.0 | 0% | 0 |
| El Muy Bonito | `giocoliere` | difendi | 0% | 1% | 99% | 59.8 | 145.5 | 0% | 0 |
| El Muy Bonito | `giocoliere` | studia | 0% | 100% | 0% | 6.7 | 190.0 | 0% | 0 |
| El Muy Bonito | `giocoliere` | casuale | 0% | 100% | 0% | 10.9 | 190.0 | 0% | 0 |
| El Muy Bonito | `giocoliere` | si_cura | 100% | 0% | 0% | 17.5 | 72.0 | 0% | 29 |
| El Muy Bonito | `giocoliere` | speciali | 76% | 24% | 0% | 10.4 | 170.7 | 0% | 22 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | attacca | 100% | 0% | 0% | 21.3 | 25.7 | 0% | 153 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | difendi | 0% | 0% | 100% | 60.0 | 32.3 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | studia | 100% | 0% | 0% | 26.2 | 36.4 | 0% | 153 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | casuale | 18% | 0% | 82% | 58.5 | 45.3 | 0% | 30 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | si_cura | 100% | 0% | 0% | 21.3 | 25.7 | 0% | 153 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | speciali | 100% | 0% | 0% | 16.8 | 20.9 | 0% | 152 |
| Goblin Possessivo | `goblin_possessivo` | attacca | 100% | 0% | 0% | 3.8 | 4.8 | 0% | 1 |
| Goblin Possessivo | `goblin_possessivo` | difendi | 0% | 0% | 100% | 60.0 | 31.5 | 0% | 0 |
| Goblin Possessivo | `goblin_possessivo` | studia | 100% | 0% | 0% | 6.8 | 9.8 | 0% | 1 |
| Goblin Possessivo | `goblin_possessivo` | casuale | 100% | 0% | 0% | 12.2 | 10.9 | 0% | 1 |
| Goblin Possessivo | `goblin_possessivo` | si_cura | 100% | 0% | 0% | 3.8 | 4.8 | 0% | 1 |
| Goblin Possessivo | `goblin_possessivo` | speciali | 100% | 0% | 0% | 3.0 | 4.8 | 0% | 1 |
| Goblin Tipico | `goblin_tipico` | attacca | 100% | 0% | 0% | 3.8 | 4.8 | 0% | 1 |
| Goblin Tipico | `goblin_tipico` | difendi | 0% | 0% | 100% | 60.0 | 31.5 | 0% | 0 |
| Goblin Tipico | `goblin_tipico` | studia | 100% | 0% | 0% | 6.8 | 9.8 | 0% | 1 |
| Goblin Tipico | `goblin_tipico` | casuale | 100% | 0% | 0% | 12.2 | 10.9 | 0% | 1 |
| Goblin Tipico | `goblin_tipico` | si_cura | 100% | 0% | 0% | 3.8 | 4.8 | 0% | 1 |
| Goblin Tipico | `goblin_tipico` | speciali | 100% | 0% | 0% | 3.0 | 4.8 | 0% | 1 |
| Golem errante di rottami | `golem_errante` | attacca | 0% | 100% | 0% | 7.3 | 190.0 | 0% | 0 |
| Golem errante di rottami | `golem_errante` | difendi | 0% | 100% | 0% | 13.6 | 190.0 | 0% | 0 |
| Golem errante di rottami | `golem_errante` | studia | 0% | 100% | 0% | 7.3 | 190.0 | 0% | 0 |
| Golem errante di rottami | `golem_errante` | casuale | 0% | 100% | 0% | 8.9 | 190.0 | 0% | 0 |
| Golem errante di rottami | `golem_errante` | si_cura | 0% | 100% | 0% | 23.6 | 190.0 | 0% | 0 |
| Golem errante di rottami | `golem_errante` | speciali | 0% | 100% | 0% | 7.2 | 190.0 | 0% | 0 |
| Infetto Rapido | `infetto_rapido` | attacca | 100% | 0% | 0% | 3.8 | 19.6 | 0% | 5 |
| Infetto Rapido | `infetto_rapido` | difendi | 0% | 0% | 100% | 60.0 | 92.5 | 0% | 0 |
| Infetto Rapido | `infetto_rapido` | studia | 100% | 0% | 0% | 6.8 | 34.0 | 0% | 5 |
| Infetto Rapido | `infetto_rapido` | casuale | 100% | 0% | 0% | 11.6 | 28.9 | 0% | 5 |
| Infetto Rapido | `infetto_rapido` | si_cura | 100% | 0% | 0% | 3.8 | 19.6 | 0% | 5 |
| Infetto Rapido | `infetto_rapido` | speciali | 100% | 0% | 0% | 3.0 | 14.3 | 0% | 5 |
| L'ultimo spettacolo di Jerah | `jerah` | attacca | 0% | 100% | 0% | 3.8 | 190.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | difendi | 0% | 100% | 0% | 4.2 | 190.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | studia | 0% | 100% | 0% | 3.9 | 190.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | casuale | 0% | 100% | 0% | 3.9 | 190.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | si_cura | 0% | 100% | 0% | 10.7 | 190.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | speciali | 0% | 100% | 0% | 3.9 | 190.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | attacca | 0% | 100% | 0% | 5.6 | 190.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | difendi | 0% | 100% | 0% | 6.6 | 190.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | studia | 0% | 100% | 0% | 5.4 | 190.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | casuale | 0% | 100% | 0% | 5.8 | 190.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | si_cura | 0% | 100% | 0% | 14.3 | 190.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | speciali | 0% | 100% | 0% | 5.3 | 190.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | attacca | 0% | 100% | 0% | 2.6 | 190.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | difendi | 0% | 100% | 0% | 2.7 | 190.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | studia | 0% | 100% | 0% | 2.5 | 190.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | casuale | 0% | 100% | 0% | 2.4 | 190.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | si_cura | 0% | 100% | 0% | 8.5 | 190.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | speciali | 0% | 100% | 0% | 2.5 | 190.0 | 0% | 0 |
| ??? | `l_immortale` | attacca | 0% | 100% | 0% | 48.3 | 190.0 | 0% | 0 |
| ??? | `l_immortale` | difendi | 0% | 0% | 100% | 60.0 | 62.6 | 0% | 0 |
| ??? | `l_immortale` | studia | 0% | 100% | 0% | 48.7 | 190.0 | 0% | 0 |
| ??? | `l_immortale` | casuale | 0% | 0% | 100% | 60.0 | 69.8 | 0% | 0 |
| ??? | `l_immortale` | si_cura | 0% | 0% | 100% | 60.0 | 34.3 | 0% | 0 |
| ??? | `l_immortale` | speciali | 0% | 100% | 0% | 50.9 | 190.0 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | attacca | 6% | 94% | 0% | 7.8 | 181.9 | 0% | 2 |
| Madre in Lacrime | `madre_in_lacrime` | difendi | 0% | 100% | 0% | 19.1 | 190.0 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | studia | 5% | 95% | 0% | 8.2 | 187.2 | 0% | 2 |
| Madre in Lacrime | `madre_in_lacrime` | casuale | 3% | 97% | 0% | 10.9 | 187.0 | 0% | 1 |
| Madre in Lacrime | `madre_in_lacrime` | si_cura | 80% | 20% | 0% | 20.0 | 135.0 | 0% | 24 |
| Madre in Lacrime | `madre_in_lacrime` | speciali | 5% | 95% | 0% | 8.2 | 187.3 | 0% | 1 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | attacca | 0% | 100% | 0% | 6.0 | 190.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | difendi | 0% | 100% | 0% | 6.0 | 190.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | studia | 0% | 100% | 0% | 6.0 | 190.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | casuale | 0% | 100% | 0% | 6.0 | 190.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | si_cura | 0% | 100% | 0% | 6.0 | 190.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | speciali | 0% | 100% | 0% | 6.0 | 190.0 | 0% | 0 |
| Marionetta | `marionetta` | attacca | 6% | 94% | 0% | 4.9 | 185.5 | 0% | 3 |
| Marionetta | `marionetta` | difendi | 0% | 100% | 0% | 6.4 | 190.0 | 0% | 0 |
| Marionetta | `marionetta` | studia | 1% | 99% | 0% | 5.0 | 189.6 | 0% | 1 |
| Marionetta | `marionetta` | casuale | 1% | 99% | 0% | 5.4 | 189.2 | 0% | 1 |
| Marionetta | `marionetta` | si_cura | 6% | 94% | 0% | 14.9 | 183.0 | 0% | 3 |
| Marionetta | `marionetta` | speciali | 2% | 98% | 0% | 5.0 | 189.2 | 0% | 1 |
| Fomentado | `maschera_vuota` | attacca | 100% | 0% | 0% | 6.0 | 53.8 | 0% | 9 |
| Fomentado | `maschera_vuota` | difendi | 100% | 0% | 0% | 37.5 | 52.2 | 0% | 9 |
| Fomentado | `maschera_vuota` | studia | 100% | 0% | 0% | 8.8 | 71.9 | 0% | 9 |
| Fomentado | `maschera_vuota` | casuale | 100% | 0% | 0% | 13.8 | 54.8 | 0% | 9 |
| Fomentado | `maschera_vuota` | si_cura | 100% | 0% | 0% | 6.0 | 53.8 | 0% | 9 |
| Fomentado | `maschera_vuota` | speciali | 100% | 0% | 0% | 5.0 | 43.0 | 0% | 9 |
| Nimbo Boy | `nimbo_boy` | attacca | 100% | 0% | 0% | 3.0 | 0.0 | 0% | 1 |
| Nimbo Boy | `nimbo_boy` | difendi | 0% | 0% | 100% | 60.0 | 0.0 | 0% | 0 |
| Nimbo Boy | `nimbo_boy` | studia | 100% | 0% | 0% | 6.0 | 0.0 | 0% | 1 |
| Nimbo Boy | `nimbo_boy` | casuale | 100% | 0% | 0% | 8.7 | 0.0 | 0% | 1 |
| Nimbo Boy | `nimbo_boy` | si_cura | 100% | 0% | 0% | 3.0 | 0.0 | 0% | 1 |
| Nimbo Boy | `nimbo_boy` | speciali | 100% | 0% | 0% | 5.0 | 0.0 | 0% | 1 |
| Nuvola di Marciume | `nuvola_di_marciume` | attacca | 100% | 0% | 0% | 3.9 | 19.7 | 0% | 5 |
| Nuvola di Marciume | `nuvola_di_marciume` | difendi | 0% | 100% | 0% | 48.7 | 190.0 | 0% | 0 |
| Nuvola di Marciume | `nuvola_di_marciume` | studia | 100% | 0% | 0% | 6.9 | 39.8 | 0% | 5 |
| Nuvola di Marciume | `nuvola_di_marciume` | casuale | 100% | 0% | 0% | 11.8 | 47.4 | 0% | 5 |
| Nuvola di Marciume | `nuvola_di_marciume` | si_cura | 100% | 0% | 0% | 4.7 | 19.7 | 0% | 5 |
| Nuvola di Marciume | `nuvola_di_marciume` | speciali | 100% | 0% | 0% | 3.0 | 14.4 | 0% | 5 |
| Ombra del passato | `ombra_del_passato` | attacca | 5% | 95% | 0% | 3.9 | 185.3 | 0% | 3 |
| Ombra del passato | `ombra_del_passato` | difendi | 0% | 100% | 0% | 4.3 | 190.0 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | studia | 1% | 99% | 0% | 3.9 | 189.8 | 0% | 1 |
| Ombra del passato | `ombra_del_passato` | casuale | 1% | 99% | 0% | 4.0 | 189.2 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | si_cura | 6% | 94% | 0% | 12.6 | 183.0 | 0% | 3 |
| Ombra del passato | `ombra_del_passato` | speciali | 2% | 98% | 0% | 3.9 | 189.2 | 0% | 1 |
| Emblema dell'oppressione | `operaio_posseduto` | attacca | 32% | 68% | 0% | 15.7 | 175.3 | 0% | 6 |
| Emblema dell'oppressione | `operaio_posseduto` | difendi | 0% | 96% | 4% | 49.4 | 189.4 | 0% | 0 |
| Emblema dell'oppressione | `operaio_posseduto` | studia | 11% | 89% | 0% | 16.9 | 182.2 | 0% | 2 |
| Emblema dell'oppressione | `operaio_posseduto` | casuale | 14% | 85% | 1% | 38.1 | 180.0 | 0% | 3 |
| Emblema dell'oppressione | `operaio_posseduto` | si_cura | 100% | 0% | 0% | 19.4 | 62.6 | 0% | 18 |
| Emblema dell'oppressione | `operaio_posseduto` | speciali | 100% | 0% | 0% | 10.6 | 118.7 | 0% | 18 |
| Operaio Sfruttato | `operaio_sfruttato` | attacca | 0% | 100% | 0% | 14.8 | 190.0 | 0% | 0 |
| Operaio Sfruttato | `operaio_sfruttato` | difendi | 0% | 1% | 99% | 59.9 | 123.3 | 0% | 0 |
| Operaio Sfruttato | `operaio_sfruttato` | studia | 0% | 100% | 0% | 14.7 | 190.0 | 0% | 0 |
| Operaio Sfruttato | `operaio_sfruttato` | casuale | 0% | 45% | 55% | 49.5 | 171.0 | 0% | 0 |
| Operaio Sfruttato | `operaio_sfruttato` | si_cura | 2% | 98% | 0% | 41.0 | 188.3 | 0% | 1 |
| Operaio Sfruttato | `operaio_sfruttato` | speciali | 0% | 100% | 0% | 13.2 | 190.0 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | attacca | 0% | 100% | 0% | 13.7 | 190.0 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | difendi | 0% | 33% | 67% | 57.4 | 171.8 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | studia | 0% | 100% | 0% | 13.5 | 190.0 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | casuale | 0% | 85% | 15% | 38.1 | 186.9 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | si_cura | 5% | 95% | 0% | 39.3 | 189.9 | 0% | 2 |
| Orrore di Meridia | `orrore_di_meridia` | speciali | 0% | 100% | 0% | 14.1 | 190.0 | 0% | 0 |
| Rana Folle | `rana_folle` | attacca | 100% | 0% | 0% | 6.5 | 7.7 | 0% | 1 |
| Rana Folle | `rana_folle` | difendi | 0% | 0% | 100% | 60.0 | 66.4 | 0% | 0 |
| Rana Folle | `rana_folle` | studia | 100% | 0% | 0% | 9.6 | 26.7 | 0% | 1 |
| Rana Folle | `rana_folle` | casuale | 100% | 0% | 0% | 18.8 | 14.8 | 0% | 1 |
| Rana Folle | `rana_folle` | si_cura | 100% | 0% | 0% | 6.5 | 7.7 | 0% | 1 |
| Rana Folle | `rana_folle` | speciali | 100% | 0% | 0% | 5.3 | 10.8 | 0% | 1 |
| Robo Pattuglia | `robo_pattuglia` | attacca | 44% | 56% | 0% | 29.3 | 150.2 | 0% | 7 |
| Robo Pattuglia | `robo_pattuglia` | difendi | 0% | 0% | 100% | 60.0 | 53.8 | 0% | 0 |
| Robo Pattuglia | `robo_pattuglia` | studia | 41% | 59% | 0% | 29.6 | 153.0 | 0% | 7 |
| Robo Pattuglia | `robo_pattuglia` | casuale | 19% | 0% | 81% | 54.5 | 65.1 | 0% | 3 |
| Robo Pattuglia | `robo_pattuglia` | si_cura | 51% | 0% | 49% | 41.7 | 53.2 | 0% | 8 |
| Robo Pattuglia | `robo_pattuglia` | speciali | 64% | 36% | 0% | 26.5 | 128.8 | 0% | 10 |
| Sacerdote Folle | `sacerdote_folle` | attacca | 4% | 96% | 0% | 5.1 | 184.8 | 0% | 2 |
| Sacerdote Folle | `sacerdote_folle` | difendi | 0% | 100% | 0% | 7.7 | 190.0 | 0% | 0 |
| Sacerdote Folle | `sacerdote_folle` | studia | 1% | 99% | 0% | 5.3 | 189.6 | 0% | 0 |
| Sacerdote Folle | `sacerdote_folle` | casuale | 1% | 99% | 0% | 5.9 | 188.6 | 0% | 1 |
| Sacerdote Folle | `sacerdote_folle` | si_cura | 6% | 94% | 0% | 12.9 | 182.5 | 0% | 3 |
| Sacerdote Folle | `sacerdote_folle` | speciali | 1% | 99% | 0% | 5.2 | 189.4 | 0% | 0 |
| Sadico | `sadico` | attacca | 7% | 93% | 0% | 5.9 | 182.5 | 0% | 2 |
| Sadico | `sadico` | difendi | 0% | 100% | 0% | 8.7 | 190.0 | 0% | 0 |
| Sadico | `sadico` | studia | 2% | 98% | 0% | 6.0 | 189.2 | 0% | 1 |
| Sadico | `sadico` | casuale | 2% | 98% | 0% | 6.8 | 187.8 | 0% | 1 |
| Sadico | `sadico` | si_cura | 12% | 88% | 0% | 19.6 | 175.8 | 0% | 4 |
| Sadico | `sadico` | speciali | 3% | 97% | 0% | 6.0 | 187.9 | 0% | 1 |
| Slime Infimo | `slime_infimo` | attacca | 100% | 0% | 0% | 3.8 | 4.9 | 0% | 1 |
| Slime Infimo | `slime_infimo` | difendi | 0% | 0% | 100% | 60.0 | 54.6 | 0% | 0 |
| Slime Infimo | `slime_infimo` | studia | 100% | 0% | 0% | 7.0 | 11.4 | 0% | 1 |
| Slime Infimo | `slime_infimo` | casuale | 100% | 0% | 0% | 13.7 | 12.0 | 0% | 1 |
| Slime Infimo | `slime_infimo` | si_cura | 100% | 0% | 0% | 3.8 | 4.9 | 0% | 1 |
| Slime Infimo | `slime_infimo` | speciali | 100% | 0% | 0% | 3.0 | 4.8 | 0% | 1 |
| Sogno perduto | `sogno_perduto` | attacca | 100% | 0% | 0% | 2.0 | 10.0 | 0% | 1 |
| Sogno perduto | `sogno_perduto` | difendi | 0% | 0% | 100% | 60.0 | 63.8 | 0% | 0 |
| Sogno perduto | `sogno_perduto` | studia | 100% | 0% | 0% | 4.9 | 22.4 | 0% | 1 |
| Sogno perduto | `sogno_perduto` | casuale | 100% | 0% | 0% | 6.4 | 17.9 | 0% | 1 |
| Sogno perduto | `sogno_perduto` | si_cura | 100% | 0% | 0% | 2.0 | 10.0 | 0% | 1 |
| Sogno perduto | `sogno_perduto` | speciali | 100% | 0% | 0% | 3.0 | 12.4 | 0% | 1 |
| Stigma | `stigma` | attacca | 10% | 90% | 0% | 6.9 | 182.1 | 0% | 4 |
| Stigma | `stigma` | difendi | 0% | 100% | 0% | 12.0 | 190.0 | 0% | 0 |
| Stigma | `stigma` | studia | 4% | 96% | 0% | 7.1 | 187.7 | 0% | 1 |
| Stigma | `stigma` | casuale | 1% | 99% | 0% | 8.3 | 188.5 | 0% | 0 |
| Stigma | `stigma` | si_cura | 12% | 88% | 0% | 21.8 | 174.9 | 0% | 4 |
| Stigma | `stigma` | speciali | 3% | 97% | 0% | 7.0 | 188.3 | 0% | 1 |
| Tartaruga Gigante | `tartaruga_innocente` | attacca | 0% | 0% | 100% | 60.0 | 0.0 | 0% | 0 |
| Tartaruga Gigante | `tartaruga_innocente` | difendi | 0% | 0% | 100% | 60.0 | 0.0 | 0% | 0 |
| Tartaruga Gigante | `tartaruga_innocente` | studia | 100% | 0% | 0% | 2.0 | 0.0 | 100% | 1 |
| Tartaruga Gigante | `tartaruga_innocente` | casuale | 0% | 0% | 100% | 60.0 | 0.0 | 0% | 0 |
| Tartaruga Gigante | `tartaruga_innocente` | si_cura | 0% | 0% | 100% | 60.0 | 0.0 | 0% | 0 |
| Tartaruga Gigante | `tartaruga_innocente` | speciali | 0% | 0% | 100% | 60.0 | 0.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | attacca | 0% | 100% | 0% | 6.5 | 190.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | difendi | 0% | 100% | 0% | 8.6 | 190.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | studia | 0% | 100% | 0% | 6.6 | 190.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | casuale | 0% | 100% | 0% | 7.0 | 190.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | si_cura | 0% | 100% | 0% | 11.1 | 190.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | speciali | 0% | 100% | 0% | 6.6 | 190.0 | 0% | 0 |
| Teschio Errante | `teschio_errante` | attacca | 6% | 94% | 0% | 9.0 | 184.2 | 0% | 2 |
| Teschio Errante | `teschio_errante` | difendi | 0% | 100% | 0% | 29.2 | 190.0 | 0% | 0 |
| Teschio Errante | `teschio_errante` | studia | 9% | 91% | 0% | 9.0 | 184.2 | 0% | 3 |
| Teschio Errante | `teschio_errante` | casuale | 4% | 96% | 0% | 15.5 | 189.0 | 0% | 1 |
| Teschio Errante | `teschio_errante` | si_cura | 94% | 6% | 0% | 22.2 | 128.1 | 0% | 28 |
| Teschio Errante | `teschio_errante` | speciali | 7% | 93% | 0% | 9.0 | 185.8 | 0% | 2 |
| Titano Zombie | `titano_zombie` | attacca | 0% | 100% | 0% | 8.5 | 190.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | difendi | 0% | 100% | 0% | 8.4 | 190.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | studia | 0% | 100% | 0% | 6.5 | 190.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | casuale | 0% | 100% | 0% | 6.9 | 190.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | si_cura | 0% | 100% | 0% | 22.6 | 190.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | speciali | 0% | 100% | 0% | 6.7 | 190.0 | 0% | 0 |
| Capocantiere | `voce_registrata` | attacca | 100% | 0% | 0% | 8.5 | 95.4 | 0% | 13 |
| Capocantiere | `voce_registrata` | difendi | 0% | 0% | 100% | 60.0 | 107.6 | 0% | 0 |
| Capocantiere | `voce_registrata` | studia | 100% | 0% | 0% | 11.2 | 125.5 | 0% | 13 |
| Capocantiere | `voce_registrata` | casuale | 95% | 5% | 0% | 26.6 | 112.5 | 0% | 12 |
| Capocantiere | `voce_registrata` | si_cura | 100% | 0% | 0% | 8.8 | 68.4 | 0% | 13 |
| Capocantiere | `voce_registrata` | speciali | 100% | 0% | 0% | 6.7 | 72.5 | 0% | 13 |
| Volto sulla parete | `volto_sulla_parete` | attacca | 0% | 100% | 0% | 2.9 | 190.0 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | difendi | 0% | 100% | 0% | 3.2 | 190.0 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | studia | 0% | 100% | 0% | 2.9 | 190.0 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | casuale | 0% | 100% | 0% | 3.0 | 190.0 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | si_cura | 0% | 100% | 0% | 6.3 | 190.0 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | speciali | 0% | 100% | 0% | 2.9 | 190.0 | 0% | 0 |
| Zombie Cittadino | `zombie_cittadino` | attacca | 99% | 1% | 0% | 24.3 | 63.0 | 0% | 4 |
| Zombie Cittadino | `zombie_cittadino` | difendi | 0% | 1% | 99% | 59.9 | 53.5 | 0% | 0 |
| Zombie Cittadino | `zombie_cittadino` | studia | 99% | 1% | 0% | 29.6 | 79.5 | 0% | 4 |
| Zombie Cittadino | `zombie_cittadino` | casuale | 39% | 0% | 61% | 52.1 | 41.6 | 0% | 2 |
| Zombie Cittadino | `zombie_cittadino` | si_cura | 98% | 0% | 2% | 24.8 | 49.7 | 0% | 4 |
| Zombie Cittadino | `zombie_cittadino` | speciali | 99% | 1% | 0% | 22.7 | 58.8 | 0% | 4 |
| Zombie Mostruoso | `zombie_mostruoso` | attacca | 100% | 0% | 0% | 6.6 | 36.9 | 0% | 9 |
| Zombie Mostruoso | `zombie_mostruoso` | difendi | 0% | 0% | 100% | 60.0 | 59.6 | 0% | 0 |
| Zombie Mostruoso | `zombie_mostruoso` | studia | 100% | 0% | 0% | 9.5 | 55.5 | 0% | 9 |
| Zombie Mostruoso | `zombie_mostruoso` | casuale | 100% | 0% | 0% | 20.0 | 58.1 | 0% | 9 |
| Zombie Mostruoso | `zombie_mostruoso` | si_cura | 100% | 0% | 0% | 6.6 | 36.9 | 0% | 9 |
| Zombie Mostruoso | `zombie_mostruoso` | speciali | 100% | 0% | 0% | 4.7 | 25.8 | 0% | 9 |

## Protagonista di livello 5

| creatura | id | come si gioca | vinte | perse | ∞ | giri | danno | risp. | xp |
|---|---|---|--:|--:|--:|--:|--:|--:|--:|
| Abominio Marcio | `abominio_marcio` | attacca | 0% | 100% | 0% | 8.1 | 285.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | difendi | 0% | 100% | 0% | 17.6 | 285.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | studia | 0% | 100% | 0% | 8.1 | 285.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | casuale | 0% | 100% | 0% | 10.6 | 285.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | si_cura | 0% | 100% | 0% | 20.6 | 285.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | speciali | 0% | 100% | 0% | 8.1 | 285.0 | 0% | 0 |
| Oppresso | `comparsa_di_ruggine` | attacca | 100% | 0% | 0% | 10.3 | 22.3 | 0% | 14 |
| Oppresso | `comparsa_di_ruggine` | difendi | 0% | 0% | 100% | 60.0 | 23.2 | 0% | 0 |
| Oppresso | `comparsa_di_ruggine` | studia | 100% | 0% | 0% | 14.9 | 31.0 | 0% | 14 |
| Oppresso | `comparsa_di_ruggine` | casuale | 51% | 0% | 49% | 46.5 | 24.2 | 0% | 7 |
| Oppresso | `comparsa_di_ruggine` | si_cura | 100% | 0% | 0% | 10.3 | 22.3 | 0% | 14 |
| Oppresso | `comparsa_di_ruggine` | speciali | 100% | 0% | 0% | 7.2 | 14.5 | 0% | 14 |
| Diabolo | `diabolo` | attacca | 63% | 37% | 0% | 12.4 | 257.3 | 0% | 22 |
| Diabolo | `diabolo` | difendi | 14% | 0% | 86% | 56.9 | 170.2 | 0% | 5 |
| Diabolo | `diabolo` | studia | 13% | 87% | 0% | 13.8 | 273.8 | 0% | 4 |
| Diabolo | `diabolo` | casuale | 83% | 17% | 0% | 28.9 | 211.5 | 0% | 29 |
| Diabolo | `diabolo` | si_cura | 100% | 0% | 0% | 14.7 | 117.6 | 0% | 35 |
| Diabolo | `diabolo` | speciali | 100% | 0% | 0% | 9.1 | 186.1 | 0% | 35 |
| Il Divoratore | `divoratore` | attacca | 0% | 100% | 0% | 18.8 | 285.0 | 0% | 0 |
| Il Divoratore | `divoratore` | difendi | 0% | 0% | 100% | 60.0 | 154.6 | 0% | 0 |
| Il Divoratore | `divoratore` | studia | 0% | 100% | 0% | 18.6 | 285.0 | 0% | 0 |
| Il Divoratore | `divoratore` | casuale | 1% | 18% | 81% | 57.0 | 218.8 | 0% | 1 |
| Il Divoratore | `divoratore` | si_cura | 100% | 0% | 0% | 35.0 | 164.5 | 0% | 48 |
| Il Divoratore | `divoratore` | speciali | 9% | 91% | 0% | 19.1 | 282.9 | 0% | 4 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | attacca | 10% | 90% | 0% | 11.7 | 273.8 | 0% | 4 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | difendi | 0% | 5% | 95% | 59.5 | 210.9 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | studia | 5% | 95% | 0% | 11.2 | 280.5 | 0% | 2 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | casuale | 15% | 60% | 25% | 39.2 | 263.4 | 0% | 6 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | si_cura | 27% | 73% | 0% | 26.2 | 241.5 | 0% | 12 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | speciali | 9% | 91% | 0% | 11.3 | 278.2 | 0% | 4 |
| Donna Spinosa | `donna_spinosa` | attacca | 6% | 94% | 0% | 7.7 | 273.0 | 0% | 3 |
| Donna Spinosa | `donna_spinosa` | difendi | 0% | 100% | 0% | 17.7 | 285.0 | 0% | 0 |
| Donna Spinosa | `donna_spinosa` | studia | 4% | 96% | 0% | 7.9 | 280.9 | 0% | 2 |
| Donna Spinosa | `donna_spinosa` | casuale | 2% | 98% | 0% | 10.3 | 283.1 | 0% | 1 |
| Donna Spinosa | `donna_spinosa` | si_cura | 11% | 89% | 0% | 19.1 | 270.6 | 0% | 5 |
| Donna Spinosa | `donna_spinosa` | speciali | 3% | 97% | 0% | 7.9 | 281.2 | 0% | 1 |
| Rottami Erranti | `ferraglia_urlante` | attacca | 0% | 100% | 0% | 27.9 | 285.0 | 0% | 0 |
| Rottami Erranti | `ferraglia_urlante` | difendi | 0% | 0% | 100% | 60.0 | 77.8 | 0% | 0 |
| Rottami Erranti | `ferraglia_urlante` | studia | 0% | 100% | 0% | 29.8 | 285.0 | 0% | 0 |
| Rottami Erranti | `ferraglia_urlante` | casuale | 0% | 11% | 89% | 59.1 | 197.8 | 0% | 0 |
| Rottami Erranti | `ferraglia_urlante` | si_cura | 5% | 95% | 0% | 50.2 | 283.6 | 0% | 3 |
| Rottami Erranti | `ferraglia_urlante` | speciali | 3% | 97% | 0% | 26.2 | 279.6 | 0% | 1 |
| Ghoul | `ghoul` | attacca | 89% | 11% | 0% | 11.3 | 232.6 | 0% | 27 |
| Ghoul | `ghoul` | difendi | 0% | 1% | 99% | 60.0 | 195.6 | 0% | 0 |
| Ghoul | `ghoul` | studia | 34% | 66% | 0% | 13.3 | 271.1 | 0% | 10 |
| Ghoul | `ghoul` | casuale | 73% | 27% | 0% | 33.3 | 226.7 | 0% | 22 |
| Ghoul | `ghoul` | si_cura | 100% | 0% | 0% | 13.0 | 115.5 | 0% | 30 |
| Ghoul | `ghoul` | speciali | 100% | 0% | 0% | 8.4 | 163.3 | 0% | 30 |
| El Muy Bonito | `giocoliere` | attacca | 100% | 0% | 0% | 9.6 | 105.0 | 0% | 25 |
| El Muy Bonito | `giocoliere` | difendi | 0% | 0% | 100% | 60.0 | 96.6 | 0% | 0 |
| El Muy Bonito | `giocoliere` | studia | 9% | 91% | 0% | 9.5 | 282.8 | 0% | 2 |
| El Muy Bonito | `giocoliere` | casuale | 11% | 89% | 0% | 15.1 | 274.3 | 0% | 3 |
| El Muy Bonito | `giocoliere` | si_cura | 100% | 0% | 0% | 9.6 | 104.4 | 0% | 25 |
| El Muy Bonito | `giocoliere` | speciali | 100% | 0% | 0% | 6.8 | 71.4 | 0% | 25 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | attacca | 100% | 0% | 0% | 14.1 | 13.8 | 0% | 153 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | difendi | 0% | 0% | 100% | 60.0 | 32.2 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | studia | 100% | 0% | 0% | 19.1 | 17.6 | 0% | 154 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | casuale | 77% | 0% | 23% | 46.6 | 40.5 | 0% | 120 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | si_cura | 100% | 0% | 0% | 14.1 | 13.8 | 0% | 153 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | speciali | 100% | 0% | 0% | 11.9 | 12.8 | 0% | 153 |
| Goblin Possessivo | `goblin_possessivo` | attacca | 100% | 0% | 0% | 3.8 | 3.7 | 0% | 3 |
| Goblin Possessivo | `goblin_possessivo` | difendi | 0% | 0% | 100% | 60.0 | 24.3 | 0% | 0 |
| Goblin Possessivo | `goblin_possessivo` | studia | 100% | 0% | 0% | 6.8 | 7.5 | 0% | 3 |
| Goblin Possessivo | `goblin_possessivo` | casuale | 100% | 0% | 0% | 11.4 | 5.7 | 0% | 3 |
| Goblin Possessivo | `goblin_possessivo` | si_cura | 100% | 0% | 0% | 3.8 | 3.7 | 0% | 3 |
| Goblin Possessivo | `goblin_possessivo` | speciali | 100% | 0% | 0% | 3.0 | 3.6 | 0% | 3 |
| Goblin Tipico | `goblin_tipico` | attacca | 100% | 0% | 0% | 3.8 | 3.7 | 0% | 3 |
| Goblin Tipico | `goblin_tipico` | difendi | 0% | 0% | 100% | 60.0 | 24.3 | 0% | 0 |
| Goblin Tipico | `goblin_tipico` | studia | 100% | 0% | 0% | 6.8 | 7.5 | 0% | 3 |
| Goblin Tipico | `goblin_tipico` | casuale | 100% | 0% | 0% | 11.4 | 5.7 | 0% | 3 |
| Goblin Tipico | `goblin_tipico` | si_cura | 100% | 0% | 0% | 3.8 | 3.7 | 0% | 3 |
| Goblin Tipico | `goblin_tipico` | speciali | 100% | 0% | 0% | 3.0 | 3.6 | 0% | 3 |
| Golem errante di rottami | `golem_errante` | attacca | 0% | 100% | 0% | 16.1 | 285.0 | 0% | 0 |
| Golem errante di rottami | `golem_errante` | difendi | 0% | 17% | 83% | 58.7 | 238.5 | 0% | 0 |
| Golem errante di rottami | `golem_errante` | studia | 0% | 100% | 0% | 15.4 | 285.0 | 0% | 0 |
| Golem errante di rottami | `golem_errante` | casuale | 0% | 70% | 30% | 44.8 | 272.1 | 0% | 0 |
| Golem errante di rottami | `golem_errante` | si_cura | 42% | 58% | 0% | 38.0 | 270.5 | 0% | 24 |
| Golem errante di rottami | `golem_errante` | speciali | 3% | 97% | 0% | 16.3 | 284.2 | 0% | 2 |
| Infetto Rapido | `infetto_rapido` | attacca | 100% | 0% | 0% | 2.9 | 5.5 | 0% | 3 |
| Infetto Rapido | `infetto_rapido` | difendi | 0% | 0% | 100% | 60.0 | 85.1 | 0% | 0 |
| Infetto Rapido | `infetto_rapido` | studia | 100% | 0% | 0% | 5.9 | 12.2 | 0% | 3 |
| Infetto Rapido | `infetto_rapido` | casuale | 100% | 0% | 0% | 9.3 | 14.3 | 0% | 3 |
| Infetto Rapido | `infetto_rapido` | si_cura | 100% | 0% | 0% | 2.9 | 5.5 | 0% | 3 |
| Infetto Rapido | `infetto_rapido` | speciali | 100% | 0% | 0% | 3.0 | 4.5 | 0% | 3 |
| L'ultimo spettacolo di Jerah | `jerah` | attacca | 0% | 100% | 0% | 5.7 | 285.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | difendi | 0% | 100% | 0% | 7.1 | 285.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | studia | 0% | 100% | 0% | 5.7 | 285.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | casuale | 0% | 100% | 0% | 5.9 | 285.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | si_cura | 0% | 100% | 0% | 12.9 | 285.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | speciali | 0% | 100% | 0% | 5.7 | 285.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | attacca | 0% | 100% | 0% | 8.9 | 285.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | difendi | 0% | 100% | 0% | 15.1 | 285.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | studia | 0% | 100% | 0% | 8.6 | 285.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | casuale | 0% | 100% | 0% | 11.3 | 285.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | si_cura | 0% | 100% | 0% | 19.1 | 285.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | speciali | 0% | 100% | 0% | 8.6 | 285.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | attacca | 0% | 100% | 0% | 4.5 | 285.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | difendi | 0% | 100% | 0% | 5.7 | 285.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | studia | 0% | 100% | 0% | 4.5 | 285.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | casuale | 0% | 100% | 0% | 4.7 | 285.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | si_cura | 0% | 100% | 0% | 11.3 | 285.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | speciali | 0% | 100% | 0% | 4.4 | 285.0 | 0% | 0 |
| ??? | `l_immortale` | attacca | 0% | 0% | 100% | 60.0 | 93.0 | 0% | 0 |
| ??? | `l_immortale` | difendi | 0% | 0% | 100% | 60.0 | 60.2 | 0% | 0 |
| ??? | `l_immortale` | studia | 0% | 0% | 100% | 60.0 | 91.9 | 0% | 0 |
| ??? | `l_immortale` | casuale | 0% | 0% | 100% | 60.0 | 61.3 | 0% | 0 |
| ??? | `l_immortale` | si_cura | 0% | 0% | 100% | 60.0 | 93.0 | 0% | 0 |
| ??? | `l_immortale` | speciali | 0% | 0% | 100% | 60.0 | 85.5 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | attacca | 99% | 1% | 0% | 10.9 | 212.5 | 0% | 30 |
| Madre in Lacrime | `madre_in_lacrime` | difendi | 0% | 21% | 79% | 58.4 | 238.9 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | studia | 64% | 36% | 0% | 13.4 | 259.5 | 0% | 19 |
| Madre in Lacrime | `madre_in_lacrime` | casuale | 75% | 25% | 0% | 31.9 | 229.1 | 0% | 22 |
| Madre in Lacrime | `madre_in_lacrime` | si_cura | 100% | 0% | 0% | 12.0 | 119.0 | 0% | 30 |
| Madre in Lacrime | `madre_in_lacrime` | speciali | 100% | 0% | 0% | 7.7 | 137.8 | 0% | 30 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | attacca | 0% | 100% | 0% | 9.0 | 285.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | difendi | 0% | 100% | 0% | 9.0 | 285.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | studia | 0% | 100% | 0% | 9.0 | 285.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | casuale | 0% | 100% | 0% | 9.0 | 285.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | si_cura | 0% | 100% | 0% | 9.0 | 285.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | speciali | 0% | 100% | 0% | 9.0 | 285.0 | 0% | 0 |
| Marionetta | `marionetta` | attacca | 11% | 89% | 0% | 8.1 | 269.6 | 0% | 6 |
| Marionetta | `marionetta` | difendi | 0% | 100% | 0% | 18.8 | 285.0 | 0% | 0 |
| Marionetta | `marionetta` | studia | 9% | 91% | 0% | 8.4 | 279.2 | 0% | 4 |
| Marionetta | `marionetta` | casuale | 3% | 97% | 0% | 11.2 | 282.2 | 0% | 2 |
| Marionetta | `marionetta` | si_cura | 18% | 82% | 0% | 19.4 | 261.0 | 0% | 9 |
| Marionetta | `marionetta` | speciali | 3% | 97% | 0% | 8.5 | 281.6 | 0% | 2 |
| Fomentado | `maschera_vuota` | attacca | 100% | 0% | 0% | 4.8 | 16.0 | 0% | 6 |
| Fomentado | `maschera_vuota` | difendi | 100% | 0% | 0% | 52.5 | 31.5 | 0% | 6 |
| Fomentado | `maschera_vuota` | studia | 100% | 0% | 0% | 7.8 | 39.5 | 0% | 6 |
| Fomentado | `maschera_vuota` | casuale | 100% | 0% | 0% | 12.1 | 22.8 | 0% | 6 |
| Fomentado | `maschera_vuota` | si_cura | 100% | 0% | 0% | 4.8 | 16.0 | 0% | 6 |
| Fomentado | `maschera_vuota` | speciali | 100% | 0% | 0% | 3.9 | 26.8 | 0% | 6 |
| Nimbo Boy | `nimbo_boy` | attacca | 100% | 0% | 0% | 3.0 | 0.0 | 0% | 3 |
| Nimbo Boy | `nimbo_boy` | difendi | 0% | 0% | 100% | 60.0 | 0.0 | 0% | 0 |
| Nimbo Boy | `nimbo_boy` | studia | 100% | 0% | 0% | 6.0 | 0.0 | 0% | 3 |
| Nimbo Boy | `nimbo_boy` | casuale | 100% | 0% | 0% | 9.3 | 0.0 | 0% | 3 |
| Nimbo Boy | `nimbo_boy` | si_cura | 100% | 0% | 0% | 3.0 | 0.0 | 0% | 3 |
| Nimbo Boy | `nimbo_boy` | speciali | 100% | 0% | 0% | 5.0 | 0.0 | 0% | 3 |
| Nuvola di Marciume | `nuvola_di_marciume` | attacca | 100% | 0% | 0% | 2.9 | 6.5 | 0% | 3 |
| Nuvola di Marciume | `nuvola_di_marciume` | difendi | 0% | 49% | 51% | 59.3 | 279.7 | 0% | 0 |
| Nuvola di Marciume | `nuvola_di_marciume` | studia | 100% | 0% | 0% | 5.9 | 20.9 | 0% | 3 |
| Nuvola di Marciume | `nuvola_di_marciume` | casuale | 100% | 0% | 0% | 9.4 | 33.0 | 0% | 3 |
| Nuvola di Marciume | `nuvola_di_marciume` | si_cura | 100% | 0% | 0% | 3.3 | 6.1 | 0% | 3 |
| Nuvola di Marciume | `nuvola_di_marciume` | speciali | 100% | 0% | 0% | 3.0 | 5.9 | 0% | 3 |
| Ombra del passato | `ombra_del_passato` | attacca | 6% | 94% | 0% | 6.6 | 274.0 | 0% | 3 |
| Ombra del passato | `ombra_del_passato` | difendi | 0% | 100% | 0% | 13.0 | 285.0 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | studia | 4% | 96% | 0% | 6.8 | 282.1 | 0% | 2 |
| Ombra del passato | `ombra_del_passato` | casuale | 1% | 99% | 0% | 8.1 | 283.5 | 0% | 1 |
| Ombra del passato | `ombra_del_passato` | si_cura | 12% | 88% | 0% | 15.9 | 268.2 | 0% | 7 |
| Ombra del passato | `ombra_del_passato` | speciali | 3% | 97% | 0% | 6.8 | 281.7 | 0% | 1 |
| Emblema dell'oppressione | `operaio_posseduto` | attacca | 100% | 0% | 0% | 9.4 | 52.7 | 0% | 18 |
| Emblema dell'oppressione | `operaio_posseduto` | difendi | 0% | 0% | 100% | 60.0 | 159.4 | 0% | 0 |
| Emblema dell'oppressione | `operaio_posseduto` | studia | 100% | 0% | 0% | 12.3 | 85.1 | 0% | 18 |
| Emblema dell'oppressione | `operaio_posseduto` | casuale | 89% | 3% | 8% | 38.8 | 143.2 | 0% | 16 |
| Emblema dell'oppressione | `operaio_posseduto` | si_cura | 100% | 0% | 0% | 9.4 | 52.7 | 0% | 18 |
| Emblema dell'oppressione | `operaio_posseduto` | speciali | 100% | 0% | 0% | 6.8 | 36.6 | 0% | 18 |
| Operaio Sfruttato | `operaio_sfruttato` | attacca | 100% | 0% | 0% | 13.8 | 155.0 | 0% | 39 |
| Operaio Sfruttato | `operaio_sfruttato` | difendi | 0% | 0% | 100% | 60.0 | 65.3 | 0% | 0 |
| Operaio Sfruttato | `operaio_sfruttato` | studia | 93% | 7% | 0% | 18.3 | 193.0 | 0% | 36 |
| Operaio Sfruttato | `operaio_sfruttato` | casuale | 11% | 6% | 83% | 57.4 | 137.9 | 0% | 4 |
| Operaio Sfruttato | `operaio_sfruttato` | si_cura | 100% | 0% | 0% | 14.4 | 109.5 | 0% | 39 |
| Operaio Sfruttato | `operaio_sfruttato` | speciali | 100% | 0% | 0% | 9.8 | 91.1 | 0% | 39 |
| Orrore di Meridia | `orrore_di_meridia` | attacca | 39% | 61% | 0% | 20.5 | 283.7 | 0% | 15 |
| Orrore di Meridia | `orrore_di_meridia` | difendi | 0% | 0% | 100% | 60.0 | 70.5 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | studia | 3% | 97% | 0% | 22.5 | 284.8 | 0% | 1 |
| Orrore di Meridia | `orrore_di_meridia` | casuale | 3% | 24% | 73% | 57.0 | 202.9 | 0% | 2 |
| Orrore di Meridia | `orrore_di_meridia` | si_cura | 100% | 0% | 0% | 27.0 | 120.0 | 0% | 39 |
| Orrore di Meridia | `orrore_di_meridia` | speciali | 55% | 45% | 0% | 17.9 | 280.2 | 0% | 22 |
| Rana Folle | `rana_folle` | attacca | 100% | 0% | 0% | 4.9 | 3.6 | 0% | 3 |
| Rana Folle | `rana_folle` | difendi | 0% | 0% | 100% | 60.0 | 49.1 | 0% | 0 |
| Rana Folle | `rana_folle` | studia | 100% | 0% | 0% | 7.9 | 10.6 | 0% | 3 |
| Rana Folle | `rana_folle` | casuale | 100% | 0% | 0% | 15.0 | 7.2 | 0% | 3 |
| Rana Folle | `rana_folle` | si_cura | 100% | 0% | 0% | 4.9 | 3.6 | 0% | 3 |
| Rana Folle | `rana_folle` | speciali | 100% | 0% | 0% | 3.9 | 5.8 | 0% | 3 |
| Robo Pattuglia | `robo_pattuglia` | attacca | 100% | 0% | 0% | 12.2 | 28.0 | 0% | 14 |
| Robo Pattuglia | `robo_pattuglia` | difendi | 0% | 0% | 100% | 60.0 | 28.5 | 0% | 0 |
| Robo Pattuglia | `robo_pattuglia` | studia | 99% | 0% | 1% | 17.0 | 37.8 | 0% | 14 |
| Robo Pattuglia | `robo_pattuglia` | casuale | 40% | 0% | 60% | 51.2 | 28.4 | 0% | 6 |
| Robo Pattuglia | `robo_pattuglia` | si_cura | 100% | 0% | 0% | 12.2 | 28.0 | 0% | 14 |
| Robo Pattuglia | `robo_pattuglia` | speciali | 100% | 0% | 0% | 8.4 | 16.9 | 0% | 14 |
| Sacerdote Folle | `sacerdote_folle` | attacca | 4% | 96% | 0% | 8.8 | 275.7 | 0% | 2 |
| Sacerdote Folle | `sacerdote_folle` | difendi | 0% | 100% | 0% | 23.8 | 285.0 | 0% | 0 |
| Sacerdote Folle | `sacerdote_folle` | studia | 3% | 97% | 0% | 8.8 | 282.0 | 0% | 1 |
| Sacerdote Folle | `sacerdote_folle` | casuale | 1% | 99% | 0% | 14.2 | 282.2 | 0% | 1 |
| Sacerdote Folle | `sacerdote_folle` | si_cura | 8% | 92% | 0% | 17.1 | 270.1 | 0% | 4 |
| Sacerdote Folle | `sacerdote_folle` | speciali | 2% | 98% | 0% | 9.3 | 283.2 | 0% | 1 |
| Sadico | `sadico` | attacca | 9% | 91% | 0% | 9.5 | 270.4 | 0% | 3 |
| Sadico | `sadico` | difendi | 0% | 100% | 0% | 29.0 | 285.0 | 0% | 0 |
| Sadico | `sadico` | studia | 7% | 93% | 0% | 9.9 | 277.6 | 0% | 2 |
| Sadico | `sadico` | casuale | 4% | 96% | 0% | 16.2 | 278.8 | 0% | 1 |
| Sadico | `sadico` | si_cura | 100% | 0% | 0% | 19.5 | 147.5 | 0% | 35 |
| Sadico | `sadico` | speciali | 25% | 75% | 0% | 9.4 | 274.0 | 0% | 9 |
| Slime Infimo | `slime_infimo` | attacca | 100% | 0% | 0% | 3.8 | 3.4 | 0% | 3 |
| Slime Infimo | `slime_infimo` | difendi | 0% | 0% | 100% | 60.0 | 27.7 | 0% | 0 |
| Slime Infimo | `slime_infimo` | studia | 100% | 0% | 0% | 6.8 | 6.3 | 0% | 3 |
| Slime Infimo | `slime_infimo` | casuale | 100% | 0% | 0% | 12.2 | 5.7 | 0% | 3 |
| Slime Infimo | `slime_infimo` | si_cura | 100% | 0% | 0% | 3.8 | 3.4 | 0% | 3 |
| Slime Infimo | `slime_infimo` | speciali | 100% | 0% | 0% | 3.0 | 3.2 | 0% | 3 |
| Sogno perduto | `sogno_perduto` | attacca | 100% | 0% | 0% | 1.0 | 0.0 | 0% | 3 |
| Sogno perduto | `sogno_perduto` | difendi | 0% | 0% | 100% | 60.0 | 49.2 | 0% | 0 |
| Sogno perduto | `sogno_perduto` | studia | 100% | 0% | 0% | 4.0 | 4.4 | 0% | 3 |
| Sogno perduto | `sogno_perduto` | casuale | 100% | 0% | 0% | 3.3 | 2.4 | 0% | 3 |
| Sogno perduto | `sogno_perduto` | si_cura | 100% | 0% | 0% | 1.0 | 0.0 | 0% | 3 |
| Sogno perduto | `sogno_perduto` | speciali | 100% | 0% | 0% | 3.0 | 2.2 | 0% | 3 |
| Stigma | `stigma` | attacca | 15% | 85% | 0% | 10.6 | 264.2 | 0% | 5 |
| Stigma | `stigma` | difendi | 0% | 100% | 0% | 34.5 | 285.0 | 0% | 0 |
| Stigma | `stigma` | studia | 7% | 93% | 0% | 11.5 | 275.9 | 0% | 2 |
| Stigma | `stigma` | casuale | 5% | 95% | 0% | 21.6 | 280.0 | 0% | 2 |
| Stigma | `stigma` | si_cura | 100% | 0% | 0% | 15.7 | 118.2 | 0% | 35 |
| Stigma | `stigma` | speciali | 69% | 31% | 0% | 9.8 | 254.3 | 0% | 24 |
| Tartaruga Gigante | `tartaruga_innocente` | attacca | 0% | 0% | 100% | 60.0 | 0.0 | 0% | 0 |
| Tartaruga Gigante | `tartaruga_innocente` | difendi | 0% | 0% | 100% | 60.0 | 0.0 | 0% | 0 |
| Tartaruga Gigante | `tartaruga_innocente` | studia | 100% | 0% | 0% | 2.0 | 0.0 | 100% | 1 |
| Tartaruga Gigante | `tartaruga_innocente` | casuale | 0% | 0% | 100% | 60.0 | 0.0 | 0% | 0 |
| Tartaruga Gigante | `tartaruga_innocente` | si_cura | 0% | 0% | 100% | 60.0 | 0.0 | 0% | 0 |
| Tartaruga Gigante | `tartaruga_innocente` | speciali | 0% | 0% | 100% | 60.0 | 0.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | attacca | 0% | 100% | 0% | 9.0 | 285.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | difendi | 0% | 100% | 0% | 14.9 | 285.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | studia | 0% | 100% | 0% | 9.1 | 285.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | casuale | 0% | 100% | 0% | 11.1 | 285.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | si_cura | 0% | 100% | 0% | 13.9 | 285.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | speciali | 0% | 100% | 0% | 9.2 | 285.0 | 0% | 0 |
| Teschio Errante | `teschio_errante` | attacca | 100% | 0% | 0% | 11.3 | 187.1 | 0% | 30 |
| Teschio Errante | `teschio_errante` | difendi | 0% | 3% | 97% | 59.9 | 209.5 | 0% | 0 |
| Teschio Errante | `teschio_errante` | studia | 94% | 6% | 0% | 14.3 | 238.4 | 0% | 28 |
| Teschio Errante | `teschio_errante` | casuale | 93% | 5% | 1% | 33.7 | 175.6 | 0% | 28 |
| Teschio Errante | `teschio_errante` | si_cura | 100% | 0% | 0% | 12.2 | 112.1 | 0% | 30 |
| Teschio Errante | `teschio_errante` | speciali | 100% | 0% | 0% | 8.5 | 133.3 | 0% | 30 |
| Titano Zombie | `titano_zombie` | attacca | 0% | 100% | 0% | 12.0 | 285.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | difendi | 0% | 100% | 0% | 14.3 | 285.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | studia | 0% | 100% | 0% | 10.9 | 285.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | casuale | 0% | 100% | 0% | 11.8 | 285.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | si_cura | 0% | 100% | 0% | 24.0 | 285.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | speciali | 0% | 100% | 0% | 11.6 | 285.0 | 0% | 0 |
| Capocantiere | `voce_registrata` | attacca | 100% | 0% | 0% | 5.7 | 28.2 | 0% | 11 |
| Capocantiere | `voce_registrata` | difendi | 0% | 0% | 100% | 60.0 | 48.7 | 0% | 0 |
| Capocantiere | `voce_registrata` | studia | 100% | 0% | 0% | 8.7 | 46.7 | 0% | 11 |
| Capocantiere | `voce_registrata` | casuale | 100% | 0% | 0% | 17.4 | 33.5 | 0% | 11 |
| Capocantiere | `voce_registrata` | si_cura | 100% | 0% | 0% | 5.7 | 28.2 | 0% | 11 |
| Capocantiere | `voce_registrata` | speciali | 100% | 0% | 0% | 4.8 | 28.9 | 0% | 11 |
| Volto sulla parete | `volto_sulla_parete` | attacca | 0% | 100% | 0% | 5.0 | 285.0 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | difendi | 0% | 100% | 0% | 6.8 | 285.0 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | studia | 0% | 100% | 0% | 5.0 | 285.0 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | casuale | 0% | 100% | 0% | 5.4 | 285.0 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | si_cura | 0% | 100% | 0% | 11.3 | 285.0 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | speciali | 0% | 100% | 0% | 5.0 | 285.0 | 0% | 0 |
| Zombie Cittadino | `zombie_cittadino` | attacca | 98% | 0% | 2% | 18.3 | 22.0 | 0% | 3 |
| Zombie Cittadino | `zombie_cittadino` | difendi | 0% | 0% | 100% | 60.0 | 39.5 | 0% | 0 |
| Zombie Cittadino | `zombie_cittadino` | studia | 99% | 0% | 1% | 22.2 | 26.3 | 0% | 3 |
| Zombie Cittadino | `zombie_cittadino` | casuale | 56% | 0% | 44% | 47.0 | 24.1 | 0% | 2 |
| Zombie Cittadino | `zombie_cittadino` | si_cura | 98% | 0% | 2% | 18.3 | 22.0 | 0% | 3 |
| Zombie Cittadino | `zombie_cittadino` | speciali | 99% | 0% | 1% | 16.3 | 20.3 | 0% | 3 |
| Zombie Mostruoso | `zombie_mostruoso` | attacca | 100% | 0% | 0% | 4.8 | 13.8 | 0% | 6 |
| Zombie Mostruoso | `zombie_mostruoso` | difendi | 0% | 0% | 100% | 60.0 | 29.6 | 0% | 0 |
| Zombie Mostruoso | `zombie_mostruoso` | studia | 100% | 0% | 0% | 7.8 | 23.9 | 0% | 6 |
| Zombie Mostruoso | `zombie_mostruoso` | casuale | 100% | 0% | 0% | 14.5 | 21.4 | 0% | 6 |
| Zombie Mostruoso | `zombie_mostruoso` | si_cura | 100% | 0% | 0% | 4.8 | 13.8 | 0% | 6 |
| Zombie Mostruoso | `zombie_mostruoso` | speciali | 100% | 0% | 0% | 3.0 | 5.1 | 0% | 6 |

## Protagonista di livello 8

| creatura | id | come si gioca | vinte | perse | ∞ | giri | danno | risp. | xp |
|---|---|---|--:|--:|--:|--:|--:|--:|--:|
| Abominio Marcio | `abominio_marcio` | attacca | 0% | 100% | 0% | 14.5 | 425.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | difendi | 0% | 97% | 3% | 45.1 | 424.4 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | studia | 0% | 100% | 0% | 13.9 | 425.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | casuale | 0% | 100% | 0% | 31.9 | 425.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | si_cura | 0% | 100% | 0% | 30.4 | 425.0 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | speciali | 1% | 99% | 0% | 15.0 | 424.6 | 0% | 1 |
| Oppresso | `comparsa_di_ruggine` | attacca | 100% | 0% | 0% | 7.3 | 9.5 | 0% | 12 |
| Oppresso | `comparsa_di_ruggine` | difendi | 0% | 0% | 100% | 60.0 | 18.1 | 0% | 0 |
| Oppresso | `comparsa_di_ruggine` | studia | 100% | 0% | 0% | 10.5 | 11.8 | 0% | 12 |
| Oppresso | `comparsa_di_ruggine` | casuale | 98% | 0% | 2% | 25.1 | 9.5 | 0% | 12 |
| Oppresso | `comparsa_di_ruggine` | si_cura | 100% | 0% | 0% | 7.3 | 9.5 | 0% | 12 |
| Oppresso | `comparsa_di_ruggine` | speciali | 100% | 0% | 0% | 5.2 | 6.0 | 0% | 12 |
| Diabolo | `diabolo` | attacca | 100% | 0% | 0% | 8.3 | 102.9 | 0% | 35 |
| Diabolo | `diabolo` | difendi | 31% | 0% | 69% | 54.5 | 83.6 | 0% | 11 |
| Diabolo | `diabolo` | studia | 100% | 0% | 0% | 11.2 | 122.0 | 0% | 35 |
| Diabolo | `diabolo` | casuale | 100% | 0% | 0% | 21.4 | 70.4 | 0% | 35 |
| Diabolo | `diabolo` | si_cura | 100% | 0% | 0% | 8.3 | 102.9 | 0% | 35 |
| Diabolo | `diabolo` | speciali | 100% | 0% | 0% | 6.3 | 67.3 | 0% | 35 |
| Il Divoratore | `divoratore` | attacca | 100% | 0% | 0% | 17.4 | 136.8 | 0% | 34 |
| Il Divoratore | `divoratore` | difendi | 0% | 0% | 100% | 60.0 | 78.3 | 0% | 0 |
| Il Divoratore | `divoratore` | studia | 100% | 0% | 0% | 20.8 | 169.9 | 0% | 34 |
| Il Divoratore | `divoratore` | casuale | 76% | 0% | 24% | 50.2 | 87.0 | 0% | 26 |
| Il Divoratore | `divoratore` | si_cura | 100% | 0% | 0% | 17.4 | 136.8 | 0% | 34 |
| Il Divoratore | `divoratore` | speciali | 100% | 0% | 0% | 15.5 | 111.3 | 0% | 34 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | attacca | 100% | 0% | 0% | 11.2 | 208.3 | 0% | 43 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | difendi | 0% | 0% | 100% | 60.0 | 151.8 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | studia | 100% | 0% | 0% | 14.1 | 260.9 | 0% | 43 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | casuale | 66% | 0% | 34% | 50.2 | 191.8 | 0% | 30 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | si_cura | 100% | 0% | 0% | 11.6 | 200.8 | 0% | 43 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | speciali | 100% | 0% | 0% | 8.6 | 158.9 | 0% | 43 |
| Donna Spinosa | `donna_spinosa` | attacca | 23% | 77% | 0% | 11.8 | 395.9 | 0% | 12 |
| Donna Spinosa | `donna_spinosa` | difendi | 0% | 100% | 0% | 43.8 | 425.0 | 0% | 0 |
| Donna Spinosa | `donna_spinosa` | studia | 8% | 92% | 0% | 12.9 | 412.3 | 0% | 4 |
| Donna Spinosa | `donna_spinosa` | casuale | 17% | 83% | 0% | 27.3 | 407.5 | 0% | 8 |
| Donna Spinosa | `donna_spinosa` | si_cura | 100% | 0% | 0% | 19.1 | 260.3 | 0% | 51 |
| Donna Spinosa | `donna_spinosa` | speciali | 98% | 2% | 0% | 10.2 | 346.7 | 0% | 50 |
| Rottami Erranti | `ferraglia_urlante` | attacca | 100% | 0% | 0% | 15.4 | 35.3 | 0% | 22 |
| Rottami Erranti | `ferraglia_urlante` | difendi | 0% | 0% | 100% | 60.0 | 38.2 | 0% | 0 |
| Rottami Erranti | `ferraglia_urlante` | studia | 100% | 0% | 0% | 18.4 | 39.1 | 0% | 21 |
| Rottami Erranti | `ferraglia_urlante` | casuale | 9% | 0% | 91% | 57.8 | 67.2 | 0% | 3 |
| Rottami Erranti | `ferraglia_urlante` | si_cura | 100% | 0% | 0% | 15.4 | 35.3 | 0% | 22 |
| Rottami Erranti | `ferraglia_urlante` | speciali | 100% | 0% | 0% | 10.1 | 12.6 | 0% | 19 |
| Ghoul | `ghoul` | attacca | 100% | 0% | 0% | 6.9 | 68.0 | 0% | 30 |
| Ghoul | `ghoul` | difendi | 0% | 0% | 100% | 60.0 | 84.2 | 0% | 0 |
| Ghoul | `ghoul` | studia | 100% | 0% | 0% | 10.0 | 116.5 | 0% | 30 |
| Ghoul | `ghoul` | casuale | 100% | 0% | 0% | 20.8 | 73.6 | 0% | 30 |
| Ghoul | `ghoul` | si_cura | 100% | 0% | 0% | 6.9 | 68.0 | 0% | 30 |
| Ghoul | `ghoul` | speciali | 100% | 0% | 0% | 5.6 | 67.0 | 0% | 30 |
| El Muy Bonito | `giocoliere` | attacca | 100% | 0% | 0% | 7.7 | 50.5 | 0% | 21 |
| El Muy Bonito | `giocoliere` | difendi | 0% | 0% | 100% | 60.0 | 67.8 | 0% | 0 |
| El Muy Bonito | `giocoliere` | studia | 100% | 0% | 0% | 9.9 | 160.9 | 0% | 21 |
| El Muy Bonito | `giocoliere` | casuale | 76% | 24% | 0% | 18.7 | 269.3 | 0% | 16 |
| El Muy Bonito | `giocoliere` | si_cura | 100% | 0% | 0% | 7.7 | 50.5 | 0% | 21 |
| El Muy Bonito | `giocoliere` | speciali | 100% | 0% | 0% | 5.8 | 36.4 | 0% | 21 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | attacca | 100% | 0% | 0% | 12.1 | 13.8 | 0% | 216 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | difendi | 0% | 0% | 100% | 60.0 | 32.2 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | studia | 100% | 0% | 0% | 16.2 | 18.7 | 0% | 216 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | casuale | 85% | 0% | 15% | 42.1 | 38.1 | 0% | 187 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | si_cura | 100% | 0% | 0% | 12.1 | 13.8 | 0% | 216 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | speciali | 100% | 0% | 0% | 10.0 | 10.4 | 0% | 216 |
| Goblin Possessivo | `goblin_possessivo` | attacca | 100% | 0% | 0% | 4.8 | 7.0 | 0% | 10 |
| Goblin Possessivo | `goblin_possessivo` | difendi | 0% | 0% | 100% | 60.0 | 40.8 | 0% | 0 |
| Goblin Possessivo | `goblin_possessivo` | studia | 100% | 0% | 0% | 7.8 | 21.2 | 0% | 10 |
| Goblin Possessivo | `goblin_possessivo` | casuale | 100% | 0% | 0% | 14.2 | 15.3 | 0% | 10 |
| Goblin Possessivo | `goblin_possessivo` | si_cura | 100% | 0% | 0% | 4.8 | 7.0 | 0% | 10 |
| Goblin Possessivo | `goblin_possessivo` | speciali | 100% | 0% | 0% | 3.0 | 6.9 | 0% | 10 |
| Goblin Tipico | `goblin_tipico` | attacca | 100% | 0% | 0% | 4.8 | 7.0 | 0% | 10 |
| Goblin Tipico | `goblin_tipico` | difendi | 0% | 0% | 100% | 60.0 | 40.8 | 0% | 0 |
| Goblin Tipico | `goblin_tipico` | studia | 100% | 0% | 0% | 7.8 | 21.2 | 0% | 10 |
| Goblin Tipico | `goblin_tipico` | casuale | 100% | 0% | 0% | 14.2 | 15.3 | 0% | 10 |
| Goblin Tipico | `goblin_tipico` | si_cura | 100% | 0% | 0% | 4.8 | 7.0 | 0% | 10 |
| Goblin Tipico | `goblin_tipico` | speciali | 100% | 0% | 0% | 3.0 | 6.9 | 0% | 10 |
| Golem errante di rottami | `golem_errante` | attacca | 100% | 0% | 0% | 13.7 | 144.6 | 0% | 49 |
| Golem errante di rottami | `golem_errante` | difendi | 0% | 0% | 100% | 60.0 | 82.3 | 0% | 0 |
| Golem errante di rottami | `golem_errante` | studia | 100% | 0% | 0% | 16.5 | 178.3 | 0% | 49 |
| Golem errante di rottami | `golem_errante` | casuale | 35% | 0% | 65% | 56.9 | 123.6 | 0% | 20 |
| Golem errante di rottami | `golem_errante` | si_cura | 100% | 0% | 0% | 13.7 | 144.6 | 0% | 49 |
| Golem errante di rottami | `golem_errante` | speciali | 100% | 0% | 0% | 10.5 | 106.2 | 0% | 49 |
| Infetto Rapido | `infetto_rapido` | attacca | 100% | 0% | 0% | 3.0 | 11.2 | 0% | 10 |
| Infetto Rapido | `infetto_rapido` | difendi | 0% | 0% | 100% | 60.0 | 89.2 | 0% | 0 |
| Infetto Rapido | `infetto_rapido` | studia | 100% | 0% | 0% | 6.0 | 21.7 | 0% | 10 |
| Infetto Rapido | `infetto_rapido` | casuale | 100% | 0% | 0% | 9.2 | 20.1 | 0% | 10 |
| Infetto Rapido | `infetto_rapido` | si_cura | 100% | 0% | 0% | 3.0 | 11.2 | 0% | 10 |
| Infetto Rapido | `infetto_rapido` | speciali | 100% | 0% | 0% | 3.0 | 10.8 | 0% | 10 |
| L'ultimo spettacolo di Jerah | `jerah` | attacca | 0% | 100% | 0% | 8.4 | 425.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | difendi | 0% | 100% | 0% | 12.9 | 425.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | studia | 0% | 100% | 0% | 8.5 | 425.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | casuale | 0% | 100% | 0% | 10.1 | 425.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | si_cura | 0% | 100% | 0% | 16.3 | 425.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | speciali | 0% | 100% | 0% | 8.4 | 425.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | attacca | 0% | 100% | 0% | 14.8 | 425.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | difendi | 0% | 100% | 0% | 33.6 | 425.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | studia | 0% | 100% | 0% | 14.8 | 425.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | casuale | 0% | 100% | 0% | 25.8 | 425.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | si_cura | 0% | 100% | 0% | 28.8 | 425.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | speciali | 0% | 100% | 0% | 14.5 | 425.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | attacca | 0% | 100% | 0% | 8.1 | 425.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | difendi | 0% | 100% | 0% | 15.9 | 425.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | studia | 0% | 100% | 0% | 8.1 | 425.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | casuale | 0% | 100% | 0% | 9.7 | 425.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | si_cura | 0% | 100% | 0% | 16.1 | 425.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | speciali | 0% | 100% | 0% | 8.0 | 425.0 | 0% | 0 |
| ??? | `l_immortale` | attacca | 0% | 0% | 100% | 60.0 | 55.9 | 0% | 0 |
| ??? | `l_immortale` | difendi | 0% | 0% | 100% | 60.0 | 51.0 | 0% | 0 |
| ??? | `l_immortale` | studia | 0% | 0% | 100% | 60.0 | 55.9 | 0% | 0 |
| ??? | `l_immortale` | casuale | 0% | 0% | 100% | 60.0 | 51.1 | 0% | 0 |
| ??? | `l_immortale` | si_cura | 0% | 0% | 100% | 60.0 | 55.9 | 0% | 0 |
| ??? | `l_immortale` | speciali | 0% | 0% | 100% | 60.0 | 56.2 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | attacca | 100% | 0% | 0% | 6.8 | 60.6 | 0% | 30 |
| Madre in Lacrime | `madre_in_lacrime` | difendi | 0% | 0% | 100% | 60.0 | 98.6 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | studia | 100% | 0% | 0% | 9.8 | 105.9 | 0% | 30 |
| Madre in Lacrime | `madre_in_lacrime` | casuale | 100% | 0% | 0% | 20.5 | 71.3 | 0% | 30 |
| Madre in Lacrime | `madre_in_lacrime` | si_cura | 100% | 0% | 0% | 6.8 | 60.6 | 0% | 30 |
| Madre in Lacrime | `madre_in_lacrime` | speciali | 100% | 0% | 0% | 5.6 | 61.9 | 0% | 30 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | attacca | 0% | 100% | 0% | 11.0 | 425.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | difendi | 0% | 100% | 0% | 11.0 | 425.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | studia | 0% | 100% | 0% | 11.0 | 425.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | casuale | 0% | 100% | 0% | 11.0 | 425.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | si_cura | 0% | 100% | 0% | 11.0 | 425.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | speciali | 0% | 100% | 0% | 11.0 | 425.0 | 0% | 0 |
| Marionetta | `marionetta` | attacca | 70% | 30% | 0% | 12.7 | 358.1 | 0% | 36 |
| Marionetta | `marionetta` | difendi | 0% | 3% | 97% | 59.7 | 307.5 | 0% | 0 |
| Marionetta | `marionetta` | studia | 24% | 76% | 0% | 14.2 | 392.7 | 0% | 12 |
| Marionetta | `marionetta` | casuale | 23% | 51% | 26% | 42.8 | 371.4 | 0% | 12 |
| Marionetta | `marionetta` | si_cura | 100% | 0% | 0% | 18.0 | 209.3 | 0% | 51 |
| Marionetta | `marionetta` | speciali | 100% | 0% | 0% | 10.4 | 284.4 | 0% | 51 |
| Fomentado | `maschera_vuota` | attacca | 100% | 0% | 0% | 3.9 | 36.7 | 0% | 10 |
| Fomentado | `maschera_vuota` | difendi | 97% | 0% | 3% | 56.1 | 41.0 | 0% | 10 |
| Fomentado | `maschera_vuota` | studia | 100% | 0% | 0% | 7.0 | 48.8 | 0% | 10 |
| Fomentado | `maschera_vuota` | casuale | 100% | 0% | 0% | 10.7 | 29.1 | 0% | 10 |
| Fomentado | `maschera_vuota` | si_cura | 100% | 0% | 0% | 3.9 | 36.7 | 0% | 10 |
| Fomentado | `maschera_vuota` | speciali | 100% | 0% | 0% | 3.0 | 5.8 | 0% | 10 |
| Nimbo Boy | `nimbo_boy` | attacca | 100% | 0% | 0% | 5.0 | 0.0 | 0% | 10 |
| Nimbo Boy | `nimbo_boy` | difendi | 0% | 0% | 100% | 60.0 | 0.0 | 0% | 0 |
| Nimbo Boy | `nimbo_boy` | studia | 100% | 0% | 0% | 8.0 | 0.0 | 0% | 10 |
| Nimbo Boy | `nimbo_boy` | casuale | 100% | 0% | 0% | 14.7 | 0.0 | 0% | 10 |
| Nimbo Boy | `nimbo_boy` | si_cura | 100% | 0% | 0% | 5.0 | 0.0 | 0% | 10 |
| Nimbo Boy | `nimbo_boy` | speciali | 100% | 0% | 0% | 7.0 | 0.0 | 0% | 10 |
| Nuvola di Marciume | `nuvola_di_marciume` | attacca | 100% | 0% | 0% | 3.4 | 21.2 | 0% | 10 |
| Nuvola di Marciume | `nuvola_di_marciume` | difendi | 0% | 0% | 100% | 60.0 | 405.2 | 0% | 0 |
| Nuvola di Marciume | `nuvola_di_marciume` | studia | 100% | 0% | 0% | 6.7 | 47.7 | 0% | 10 |
| Nuvola di Marciume | `nuvola_di_marciume` | casuale | 100% | 0% | 0% | 11.3 | 67.3 | 0% | 10 |
| Nuvola di Marciume | `nuvola_di_marciume` | si_cura | 100% | 0% | 0% | 3.6 | 14.1 | 0% | 10 |
| Nuvola di Marciume | `nuvola_di_marciume` | speciali | 100% | 0% | 0% | 3.0 | 16.9 | 0% | 10 |
| Ombra del passato | `ombra_del_passato` | attacca | 11% | 89% | 0% | 11.0 | 399.3 | 0% | 6 |
| Ombra del passato | `ombra_del_passato` | difendi | 0% | 63% | 37% | 52.9 | 409.4 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | studia | 7% | 93% | 0% | 11.9 | 413.7 | 0% | 4 |
| Ombra del passato | `ombra_del_passato` | casuale | 15% | 85% | 0% | 26.4 | 409.7 | 0% | 8 |
| Ombra del passato | `ombra_del_passato` | si_cura | 99% | 1% | 0% | 17.5 | 287.6 | 0% | 55 |
| Ombra del passato | `ombra_del_passato` | speciali | 79% | 21% | 0% | 10.0 | 375.1 | 0% | 44 |
| Emblema dell'oppressione | `operaio_posseduto` | attacca | 100% | 0% | 0% | 5.9 | 12.6 | 0% | 10 |
| Emblema dell'oppressione | `operaio_posseduto` | difendi | 0% | 0% | 100% | 60.0 | 111.8 | 0% | 0 |
| Emblema dell'oppressione | `operaio_posseduto` | studia | 100% | 0% | 0% | 8.9 | 25.2 | 0% | 10 |
| Emblema dell'oppressione | `operaio_posseduto` | casuale | 100% | 0% | 0% | 19.9 | 55.9 | 0% | 10 |
| Emblema dell'oppressione | `operaio_posseduto` | si_cura | 100% | 0% | 0% | 5.9 | 12.6 | 0% | 10 |
| Emblema dell'oppressione | `operaio_posseduto` | speciali | 100% | 0% | 0% | 3.9 | 12.3 | 0% | 10 |
| Operaio Sfruttato | `operaio_sfruttato` | attacca | 100% | 0% | 0% | 7.8 | 47.9 | 0% | 21 |
| Operaio Sfruttato | `operaio_sfruttato` | difendi | 0% | 0% | 100% | 60.0 | 34.1 | 0% | 0 |
| Operaio Sfruttato | `operaio_sfruttato` | studia | 100% | 0% | 0% | 11.2 | 63.3 | 0% | 21 |
| Operaio Sfruttato | `operaio_sfruttato` | casuale | 100% | 0% | 0% | 25.5 | 39.5 | 0% | 21 |
| Operaio Sfruttato | `operaio_sfruttato` | si_cura | 100% | 0% | 0% | 7.8 | 47.9 | 0% | 21 |
| Operaio Sfruttato | `operaio_sfruttato` | speciali | 100% | 0% | 0% | 6.1 | 42.7 | 0% | 21 |
| Orrore di Meridia | `orrore_di_meridia` | attacca | 100% | 0% | 0% | 11.4 | 281.1 | 0% | 21 |
| Orrore di Meridia | `orrore_di_meridia` | difendi | 0% | 0% | 100% | 60.0 | 40.4 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | studia | 100% | 0% | 0% | 14.4 | 289.7 | 0% | 21 |
| Orrore di Meridia | `orrore_di_meridia` | casuale | 83% | 7% | 10% | 45.4 | 364.8 | 0% | 18 |
| Orrore di Meridia | `orrore_di_meridia` | si_cura | 100% | 0% | 0% | 16.2 | 134.3 | 0% | 21 |
| Orrore di Meridia | `orrore_di_meridia` | speciali | 100% | 0% | 0% | 7.9 | 342.6 | 0% | 21 |
| Rana Folle | `rana_folle` | attacca | 100% | 0% | 0% | 4.8 | 3.6 | 0% | 10 |
| Rana Folle | `rana_folle` | difendi | 0% | 0% | 100% | 60.0 | 75.4 | 0% | 0 |
| Rana Folle | `rana_folle` | studia | 100% | 0% | 0% | 7.8 | 10.3 | 0% | 10 |
| Rana Folle | `rana_folle` | casuale | 100% | 0% | 0% | 13.6 | 8.4 | 0% | 10 |
| Rana Folle | `rana_folle` | si_cura | 100% | 0% | 0% | 4.8 | 3.6 | 0% | 10 |
| Rana Folle | `rana_folle` | speciali | 100% | 0% | 0% | 3.9 | 4.3 | 0% | 10 |
| Robo Pattuglia | `robo_pattuglia` | attacca | 100% | 0% | 0% | 8.8 | 7.7 | 0% | 12 |
| Robo Pattuglia | `robo_pattuglia` | difendi | 0% | 0% | 100% | 60.0 | 21.4 | 0% | 0 |
| Robo Pattuglia | `robo_pattuglia` | studia | 100% | 0% | 0% | 11.9 | 14.0 | 0% | 12 |
| Robo Pattuglia | `robo_pattuglia` | casuale | 87% | 0% | 13% | 32.6 | 13.7 | 0% | 10 |
| Robo Pattuglia | `robo_pattuglia` | si_cura | 100% | 0% | 0% | 8.8 | 7.7 | 0% | 12 |
| Robo Pattuglia | `robo_pattuglia` | speciali | 100% | 0% | 0% | 6.7 | 8.0 | 0% | 12 |
| Sacerdote Folle | `sacerdote_folle` | attacca | 50% | 50% | 0% | 15.9 | 353.3 | 0% | 31 |
| Sacerdote Folle | `sacerdote_folle` | difendi | 0% | 59% | 41% | 54.7 | 401.8 | 0% | 0 |
| Sacerdote Folle | `sacerdote_folle` | studia | 27% | 73% | 0% | 16.5 | 398.1 | 0% | 15 |
| Sacerdote Folle | `sacerdote_folle` | casuale | 7% | 78% | 15% | 45.9 | 406.4 | 0% | 6 |
| Sacerdote Folle | `sacerdote_folle` | si_cura | 72% | 28% | 0% | 23.8 | 268.6 | 0% | 56 |
| Sacerdote Folle | `sacerdote_folle` | speciali | 97% | 3% | 0% | 13.7 | 260.1 | 0% | 68 |
| Sadico | `sadico` | attacca | 100% | 0% | 0% | 8.5 | 153.6 | 0% | 35 |
| Sadico | `sadico` | difendi | 0% | 88% | 12% | 54.8 | 424.4 | 0% | 0 |
| Sadico | `sadico` | studia | 100% | 0% | 0% | 12.0 | 205.9 | 0% | 35 |
| Sadico | `sadico` | casuale | 94% | 6% | 0% | 27.1 | 245.5 | 0% | 33 |
| Sadico | `sadico` | si_cura | 100% | 0% | 0% | 9.9 | 151.6 | 0% | 35 |
| Sadico | `sadico` | speciali | 100% | 0% | 0% | 6.5 | 105.7 | 0% | 35 |
| Slime Infimo | `slime_infimo` | attacca | 100% | 0% | 0% | 5.6 | 14.6 | 0% | 10 |
| Slime Infimo | `slime_infimo` | difendi | 0% | 0% | 100% | 60.0 | 49.6 | 0% | 0 |
| Slime Infimo | `slime_infimo` | studia | 100% | 0% | 0% | 8.8 | 30.1 | 0% | 10 |
| Slime Infimo | `slime_infimo` | casuale | 100% | 0% | 0% | 18.9 | 19.4 | 0% | 10 |
| Slime Infimo | `slime_infimo` | si_cura | 100% | 0% | 0% | 5.6 | 14.6 | 0% | 10 |
| Slime Infimo | `slime_infimo` | speciali | 100% | 0% | 0% | 3.0 | 6.1 | 0% | 10 |
| Sogno perduto | `sogno_perduto` | attacca | 100% | 0% | 0% | 1.0 | 0.0 | 0% | 10 |
| Sogno perduto | `sogno_perduto` | difendi | 0% | 0% | 100% | 60.0 | 37.2 | 0% | 0 |
| Sogno perduto | `sogno_perduto` | studia | 100% | 0% | 0% | 4.0 | 2.5 | 0% | 10 |
| Sogno perduto | `sogno_perduto` | casuale | 100% | 0% | 0% | 3.2 | 1.7 | 0% | 10 |
| Sogno perduto | `sogno_perduto` | si_cura | 100% | 0% | 0% | 1.0 | 0.0 | 0% | 10 |
| Sogno perduto | `sogno_perduto` | speciali | 100% | 0% | 0% | 3.0 | 1.3 | 0% | 10 |
| Stigma | `stigma` | attacca | 100% | 0% | 0% | 8.1 | 131.1 | 0% | 35 |
| Stigma | `stigma` | difendi | 0% | 33% | 67% | 58.6 | 407.3 | 0% | 0 |
| Stigma | `stigma` | studia | 100% | 0% | 0% | 11.7 | 190.6 | 0% | 35 |
| Stigma | `stigma` | casuale | 99% | 1% | 0% | 26.8 | 216.6 | 0% | 35 |
| Stigma | `stigma` | si_cura | 100% | 0% | 0% | 8.2 | 118.9 | 0% | 35 |
| Stigma | `stigma` | speciali | 100% | 0% | 0% | 6.5 | 100.6 | 0% | 35 |
| Tartaruga Gigante | `tartaruga_innocente` | attacca | 0% | 0% | 100% | 60.0 | 0.0 | 0% | 0 |
| Tartaruga Gigante | `tartaruga_innocente` | difendi | 0% | 0% | 100% | 60.0 | 0.0 | 0% | 0 |
| Tartaruga Gigante | `tartaruga_innocente` | studia | 100% | 0% | 0% | 2.0 | 0.0 | 100% | 1 |
| Tartaruga Gigante | `tartaruga_innocente` | casuale | 0% | 0% | 100% | 60.0 | 0.0 | 0% | 0 |
| Tartaruga Gigante | `tartaruga_innocente` | si_cura | 0% | 0% | 100% | 60.0 | 0.0 | 0% | 0 |
| Tartaruga Gigante | `tartaruga_innocente` | speciali | 35% | 0% | 65% | 45.2 | 0.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | attacca | 0% | 100% | 0% | 12.1 | 425.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | difendi | 0% | 100% | 0% | 22.6 | 425.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | studia | 0% | 100% | 0% | 13.3 | 425.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | casuale | 0% | 100% | 0% | 19.6 | 425.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | si_cura | 0% | 100% | 0% | 17.0 | 425.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | speciali | 0% | 100% | 0% | 12.4 | 425.0 | 0% | 0 |
| Teschio Errante | `teschio_errante` | attacca | 100% | 0% | 0% | 7.2 | 53.6 | 0% | 30 |
| Teschio Errante | `teschio_errante` | difendi | 0% | 0% | 100% | 60.0 | 89.3 | 0% | 0 |
| Teschio Errante | `teschio_errante` | studia | 100% | 0% | 0% | 10.2 | 84.2 | 0% | 30 |
| Teschio Errante | `teschio_errante` | casuale | 100% | 0% | 0% | 22.1 | 54.2 | 0% | 30 |
| Teschio Errante | `teschio_errante` | si_cura | 100% | 0% | 0% | 7.2 | 53.6 | 0% | 30 |
| Teschio Errante | `teschio_errante` | speciali | 100% | 0% | 0% | 5.9 | 48.9 | 0% | 30 |
| Titano Zombie | `titano_zombie` | attacca | 0% | 100% | 0% | 15.7 | 425.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | difendi | 0% | 100% | 0% | 17.6 | 425.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | studia | 0% | 100% | 0% | 15.6 | 425.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | casuale | 0% | 100% | 0% | 17.9 | 425.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | si_cura | 1% | 99% | 0% | 26.3 | 424.5 | 0% | 1 |
| Titano Zombie | `titano_zombie` | speciali | 1% | 99% | 0% | 15.2 | 424.6 | 0% | 1 |
| Capocantiere | `voce_registrata` | attacca | 100% | 0% | 0% | 4.8 | 16.4 | 0% | 10 |
| Capocantiere | `voce_registrata` | difendi | 0% | 0% | 100% | 60.0 | 37.7 | 0% | 0 |
| Capocantiere | `voce_registrata` | studia | 100% | 0% | 0% | 7.8 | 31.0 | 0% | 10 |
| Capocantiere | `voce_registrata` | casuale | 100% | 0% | 0% | 14.9 | 21.3 | 0% | 10 |
| Capocantiere | `voce_registrata` | si_cura | 100% | 0% | 0% | 4.8 | 16.4 | 0% | 10 |
| Capocantiere | `voce_registrata` | speciali | 100% | 0% | 0% | 3.0 | 5.5 | 0% | 10 |
| Volto sulla parete | `volto_sulla_parete` | attacca | 0% | 100% | 0% | 8.5 | 425.0 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | difendi | 0% | 100% | 0% | 17.7 | 425.0 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | studia | 0% | 100% | 0% | 8.5 | 425.0 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | casuale | 0% | 100% | 0% | 10.9 | 425.0 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | si_cura | 0% | 100% | 0% | 17.3 | 425.0 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | speciali | 0% | 100% | 0% | 8.6 | 425.0 | 0% | 0 |
| Zombie Cittadino | `zombie_cittadino` | attacca | 99% | 0% | 1% | 23.2 | 73.3 | 0% | 10 |
| Zombie Cittadino | `zombie_cittadino` | difendi | 0% | 0% | 100% | 60.0 | 63.6 | 0% | 0 |
| Zombie Cittadino | `zombie_cittadino` | studia | 99% | 0% | 1% | 27.8 | 86.8 | 0% | 10 |
| Zombie Cittadino | `zombie_cittadino` | casuale | 41% | 0% | 59% | 49.9 | 43.7 | 0% | 4 |
| Zombie Cittadino | `zombie_cittadino` | si_cura | 99% | 0% | 1% | 23.2 | 71.8 | 0% | 10 |
| Zombie Cittadino | `zombie_cittadino` | speciali | 98% | 0% | 2% | 21.3 | 64.5 | 0% | 10 |
| Zombie Mostruoso | `zombie_mostruoso` | attacca | 100% | 0% | 0% | 4.8 | 18.0 | 0% | 10 |
| Zombie Mostruoso | `zombie_mostruoso` | difendi | 0% | 0% | 100% | 60.0 | 38.2 | 0% | 0 |
| Zombie Mostruoso | `zombie_mostruoso` | studia | 100% | 0% | 0% | 7.8 | 34.5 | 0% | 10 |
| Zombie Mostruoso | `zombie_mostruoso` | casuale | 100% | 0% | 0% | 14.8 | 29.9 | 0% | 10 |
| Zombie Mostruoso | `zombie_mostruoso` | si_cura | 100% | 0% | 0% | 4.8 | 18.0 | 0% | 10 |
| Zombie Mostruoso | `zombie_mostruoso` | speciali | 100% | 0% | 0% | 3.0 | 6.4 | 0% | 10 |

## Protagonista di livello 12

| creatura | id | come si gioca | vinte | perse | ∞ | giri | danno | risp. | xp |
|---|---|---|--:|--:|--:|--:|--:|--:|--:|
| Abominio Marcio | `abominio_marcio` | attacca | 100% | 0% | 0% | 16.6 | 355.3 | 0% | 60 |
| Abominio Marcio | `abominio_marcio` | difendi | 0% | 37% | 63% | 58.9 | 584.3 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | studia | 100% | 0% | 0% | 20.0 | 431.2 | 0% | 60 |
| Abominio Marcio | `abominio_marcio` | casuale | 8% | 61% | 31% | 55.9 | 594.9 | 0% | 5 |
| Abominio Marcio | `abominio_marcio` | si_cura | 100% | 0% | 0% | 18.3 | 262.8 | 0% | 60 |
| Abominio Marcio | `abominio_marcio` | speciali | 100% | 0% | 0% | 12.5 | 253.7 | 0% | 60 |
| Oppresso | `comparsa_di_ruggine` | attacca | 100% | 0% | 0% | 9.3 | 19.4 | 0% | 23 |
| Oppresso | `comparsa_di_ruggine` | difendi | 0% | 0% | 100% | 60.0 | 20.8 | 0% | 0 |
| Oppresso | `comparsa_di_ruggine` | studia | 100% | 0% | 0% | 12.7 | 25.6 | 0% | 23 |
| Oppresso | `comparsa_di_ruggine` | casuale | 71% | 0% | 29% | 39.7 | 17.9 | 0% | 16 |
| Oppresso | `comparsa_di_ruggine` | si_cura | 100% | 0% | 0% | 9.3 | 19.4 | 0% | 23 |
| Oppresso | `comparsa_di_ruggine` | speciali | 100% | 0% | 0% | 8.2 | 14.2 | 0% | 23 |
| Diabolo | `diabolo` | attacca | 100% | 0% | 0% | 5.7 | 26.8 | 0% | 19 |
| Diabolo | `diabolo` | difendi | 43% | 0% | 57% | 50.3 | 44.2 | 0% | 8 |
| Diabolo | `diabolo` | studia | 100% | 0% | 0% | 8.7 | 43.1 | 0% | 19 |
| Diabolo | `diabolo` | casuale | 100% | 0% | 0% | 14.7 | 25.1 | 0% | 19 |
| Diabolo | `diabolo` | si_cura | 100% | 0% | 0% | 5.7 | 26.8 | 0% | 19 |
| Diabolo | `diabolo` | speciali | 100% | 0% | 0% | 5.8 | 28.1 | 0% | 19 |
| Il Divoratore | `divoratore` | attacca | 100% | 0% | 0% | 18.7 | 174.2 | 0% | 42 |
| Il Divoratore | `divoratore` | difendi | 0% | 0% | 100% | 60.0 | 87.1 | 0% | 0 |
| Il Divoratore | `divoratore` | studia | 100% | 0% | 0% | 20.2 | 196.8 | 0% | 42 |
| Il Divoratore | `divoratore` | casuale | 67% | 0% | 33% | 49.8 | 98.1 | 0% | 29 |
| Il Divoratore | `divoratore` | si_cura | 100% | 0% | 0% | 18.7 | 174.2 | 0% | 42 |
| Il Divoratore | `divoratore` | speciali | 100% | 0% | 0% | 16.6 | 156.8 | 0% | 42 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | attacca | 100% | 0% | 0% | 7.7 | 56.1 | 0% | 37 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | difendi | 0% | 0% | 100% | 60.0 | 84.2 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | studia | 100% | 0% | 0% | 10.5 | 88.9 | 0% | 37 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | casuale | 99% | 0% | 1% | 27.6 | 59.4 | 0% | 37 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | si_cura | 100% | 0% | 0% | 7.7 | 56.1 | 0% | 37 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | speciali | 100% | 0% | 0% | 6.8 | 52.8 | 0% | 37 |
| Donna Spinosa | `donna_spinosa` | attacca | 100% | 0% | 0% | 8.5 | 195.2 | 0% | 51 |
| Donna Spinosa | `donna_spinosa` | difendi | 0% | 55% | 45% | 58.1 | 602.1 | 0% | 0 |
| Donna Spinosa | `donna_spinosa` | studia | 100% | 0% | 0% | 12.0 | 291.6 | 0% | 51 |
| Donna Spinosa | `donna_spinosa` | casuale | 98% | 2% | 0% | 26.8 | 328.1 | 0% | 50 |
| Donna Spinosa | `donna_spinosa` | si_cura | 100% | 0% | 0% | 9.8 | 202.8 | 0% | 51 |
| Donna Spinosa | `donna_spinosa` | speciali | 100% | 0% | 0% | 7.6 | 155.4 | 0% | 51 |
| Rottami Erranti | `ferraglia_urlante` | attacca | 100% | 0% | 0% | 14.1 | 19.5 | 0% | 24 |
| Rottami Erranti | `ferraglia_urlante` | difendi | 1% | 0% | 99% | 60.0 | 32.0 | 0% | 0 |
| Rottami Erranti | `ferraglia_urlante` | studia | 100% | 0% | 0% | 17.6 | 30.0 | 0% | 24 |
| Rottami Erranti | `ferraglia_urlante` | casuale | 25% | 0% | 75% | 55.7 | 55.7 | 0% | 10 |
| Rottami Erranti | `ferraglia_urlante` | si_cura | 100% | 0% | 0% | 14.1 | 19.5 | 0% | 24 |
| Rottami Erranti | `ferraglia_urlante` | speciali | 100% | 0% | 0% | 11.4 | 13.0 | 0% | 23 |
| Ghoul | `ghoul` | attacca | 100% | 0% | 0% | 5.2 | 32.5 | 0% | 19 |
| Ghoul | `ghoul` | difendi | 0% | 0% | 100% | 60.0 | 57.4 | 0% | 0 |
| Ghoul | `ghoul` | studia | 100% | 0% | 0% | 8.3 | 59.4 | 0% | 19 |
| Ghoul | `ghoul` | casuale | 100% | 0% | 0% | 16.8 | 41.4 | 0% | 19 |
| Ghoul | `ghoul` | si_cura | 100% | 0% | 0% | 5.2 | 32.5 | 0% | 19 |
| Ghoul | `ghoul` | speciali | 100% | 0% | 0% | 5.7 | 40.3 | 0% | 19 |
| El Muy Bonito | `giocoliere` | attacca | 100% | 0% | 0% | 8.7 | 103.3 | 0% | 42 |
| El Muy Bonito | `giocoliere` | difendi | 0% | 0% | 100% | 60.0 | 95.5 | 0% | 0 |
| El Muy Bonito | `giocoliere` | studia | 100% | 0% | 0% | 11.6 | 303.5 | 0% | 42 |
| El Muy Bonito | `giocoliere` | casuale | 66% | 34% | 0% | 21.9 | 421.8 | 0% | 28 |
| El Muy Bonito | `giocoliere` | si_cura | 100% | 0% | 0% | 8.7 | 103.3 | 0% | 42 |
| El Muy Bonito | `giocoliere` | speciali | 100% | 0% | 0% | 7.8 | 89.3 | 0% | 42 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | attacca | 100% | 0% | 0% | 12.3 | 21.5 | 0% | 335 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | difendi | 0% | 0% | 100% | 60.0 | 32.2 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | studia | 100% | 0% | 0% | 16.4 | 29.7 | 0% | 335 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | casuale | 80% | 0% | 20% | 43.7 | 42.8 | 0% | 284 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | si_cura | 100% | 0% | 0% | 12.3 | 21.5 | 0% | 335 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | speciali | 100% | 0% | 0% | 10.9 | 16.9 | 0% | 334 |
| Goblin Possessivo | `goblin_possessivo` | attacca | 100% | 0% | 0% | 4.9 | 22.4 | 0% | 19 |
| Goblin Possessivo | `goblin_possessivo` | difendi | 0% | 0% | 100% | 60.0 | 51.7 | 0% | 0 |
| Goblin Possessivo | `goblin_possessivo` | studia | 100% | 0% | 0% | 7.9 | 46.5 | 0% | 19 |
| Goblin Possessivo | `goblin_possessivo` | casuale | 100% | 0% | 0% | 17.2 | 28.6 | 0% | 19 |
| Goblin Possessivo | `goblin_possessivo` | si_cura | 100% | 0% | 0% | 4.9 | 22.4 | 0% | 19 |
| Goblin Possessivo | `goblin_possessivo` | speciali | 100% | 0% | 0% | 5.7 | 21.7 | 0% | 19 |
| Goblin Tipico | `goblin_tipico` | attacca | 100% | 0% | 0% | 4.9 | 22.4 | 0% | 19 |
| Goblin Tipico | `goblin_tipico` | difendi | 0% | 0% | 100% | 60.0 | 51.7 | 0% | 0 |
| Goblin Tipico | `goblin_tipico` | studia | 100% | 0% | 0% | 7.9 | 46.5 | 0% | 19 |
| Goblin Tipico | `goblin_tipico` | casuale | 100% | 0% | 0% | 17.2 | 28.6 | 0% | 19 |
| Goblin Tipico | `goblin_tipico` | si_cura | 100% | 0% | 0% | 4.9 | 22.4 | 0% | 19 |
| Goblin Tipico | `goblin_tipico` | speciali | 100% | 0% | 0% | 5.7 | 21.7 | 0% | 19 |
| Golem errante di rottami | `golem_errante` | attacca | 100% | 0% | 0% | 11.0 | 108.8 | 0% | 42 |
| Golem errante di rottami | `golem_errante` | difendi | 0% | 0% | 100% | 60.0 | 77.4 | 0% | 0 |
| Golem errante di rottami | `golem_errante` | studia | 100% | 0% | 0% | 14.0 | 143.6 | 0% | 42 |
| Golem errante di rottami | `golem_errante` | casuale | 73% | 0% | 27% | 48.1 | 98.9 | 0% | 32 |
| Golem errante di rottami | `golem_errante` | si_cura | 100% | 0% | 0% | 11.0 | 108.8 | 0% | 42 |
| Golem errante di rottami | `golem_errante` | speciali | 100% | 0% | 0% | 10.1 | 95.6 | 0% | 42 |
| Infetto Rapido | `infetto_rapido` | attacca | 100% | 0% | 0% | 3.8 | 26.3 | 0% | 21 |
| Infetto Rapido | `infetto_rapido` | difendi | 0% | 0% | 100% | 60.0 | 95.8 | 0% | 0 |
| Infetto Rapido | `infetto_rapido` | studia | 100% | 0% | 0% | 6.8 | 42.9 | 0% | 21 |
| Infetto Rapido | `infetto_rapido` | casuale | 100% | 0% | 0% | 11.6 | 34.4 | 0% | 21 |
| Infetto Rapido | `infetto_rapido` | si_cura | 100% | 0% | 0% | 3.8 | 26.3 | 0% | 21 |
| Infetto Rapido | `infetto_rapido` | speciali | 100% | 0% | 0% | 4.0 | 27.6 | 0% | 21 |
| L'ultimo spettacolo di Jerah | `jerah` | attacca | 0% | 100% | 0% | 11.6 | 610.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | difendi | 0% | 95% | 5% | 25.2 | 606.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | studia | 0% | 100% | 0% | 12.1 | 610.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | casuale | 0% | 93% | 7% | 22.8 | 604.8 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | si_cura | 0% | 100% | 0% | 19.1 | 610.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | speciali | 0% | 100% | 0% | 11.5 | 610.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | attacca | 0% | 100% | 0% | 25.4 | 610.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | difendi | 0% | 67% | 33% | 54.8 | 589.6 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | studia | 0% | 100% | 0% | 25.3 | 610.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | casuale | 0% | 87% | 13% | 49.7 | 601.7 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | si_cura | 15% | 85% | 0% | 42.1 | 597.4 | 0% | 64 |
| Jongo Dongo | `jongo_dongo` | speciali | 3% | 97% | 0% | 24.1 | 606.1 | 0% | 13 |
| Jongo Dongo | `jongo_dongo_risorto` | attacca | 0% | 100% | 0% | 14.5 | 610.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | difendi | 0% | 59% | 41% | 55.0 | 585.1 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | studia | 0% | 100% | 0% | 14.4 | 610.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | casuale | 0% | 98% | 2% | 34.4 | 608.7 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | si_cura | 0% | 100% | 0% | 24.2 | 610.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | speciali | 0% | 100% | 0% | 14.2 | 610.0 | 0% | 0 |
| ??? | `l_immortale` | attacca | 0% | 0% | 100% | 60.0 | 38.7 | 0% | 0 |
| ??? | `l_immortale` | difendi | 0% | 0% | 100% | 60.0 | 37.0 | 0% | 0 |
| ??? | `l_immortale` | studia | 0% | 0% | 100% | 60.0 | 38.8 | 0% | 0 |
| ??? | `l_immortale` | casuale | 0% | 0% | 100% | 60.0 | 37.0 | 0% | 0 |
| ??? | `l_immortale` | si_cura | 0% | 0% | 100% | 60.0 | 38.7 | 0% | 0 |
| ??? | `l_immortale` | speciali | 0% | 0% | 100% | 60.0 | 38.3 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | attacca | 100% | 0% | 0% | 4.9 | 24.2 | 0% | 19 |
| Madre in Lacrime | `madre_in_lacrime` | difendi | 0% | 0% | 100% | 60.0 | 62.5 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | studia | 100% | 0% | 0% | 7.9 | 47.2 | 0% | 19 |
| Madre in Lacrime | `madre_in_lacrime` | casuale | 100% | 0% | 0% | 15.3 | 36.8 | 0% | 19 |
| Madre in Lacrime | `madre_in_lacrime` | si_cura | 100% | 0% | 0% | 4.9 | 24.2 | 0% | 19 |
| Madre in Lacrime | `madre_in_lacrime` | speciali | 100% | 0% | 0% | 5.7 | 37.9 | 0% | 19 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | attacca | 0% | 100% | 0% | 14.0 | 610.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | difendi | 0% | 100% | 0% | 14.0 | 610.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | studia | 0% | 100% | 0% | 14.0 | 610.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | casuale | 0% | 100% | 0% | 14.0 | 610.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | si_cura | 0% | 100% | 0% | 14.0 | 610.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | speciali | 0% | 100% | 0% | 14.0 | 610.0 | 0% | 0 |
| Marionetta | `marionetta` | attacca | 100% | 0% | 0% | 9.3 | 174.4 | 0% | 51 |
| Marionetta | `marionetta` | difendi | 0% | 0% | 100% | 60.0 | 140.5 | 0% | 0 |
| Marionetta | `marionetta` | studia | 100% | 0% | 0% | 12.3 | 242.0 | 0% | 51 |
| Marionetta | `marionetta` | casuale | 93% | 0% | 7% | 34.7 | 172.1 | 0% | 48 |
| Marionetta | `marionetta` | si_cura | 100% | 0% | 0% | 9.3 | 174.4 | 0% | 51 |
| Marionetta | `marionetta` | speciali | 100% | 0% | 0% | 8.3 | 144.0 | 0% | 51 |
| Fomentado | `maschera_vuota` | attacca | 100% | 0% | 0% | 4.8 | 36.8 | 0% | 19 |
| Fomentado | `maschera_vuota` | difendi | 0% | 0% | 100% | 60.0 | 52.4 | 0% | 0 |
| Fomentado | `maschera_vuota` | studia | 100% | 0% | 0% | 7.0 | 80.2 | 0% | 19 |
| Fomentado | `maschera_vuota` | casuale | 100% | 0% | 0% | 10.8 | 53.0 | 0% | 19 |
| Fomentado | `maschera_vuota` | si_cura | 100% | 0% | 0% | 4.8 | 36.8 | 0% | 19 |
| Fomentado | `maschera_vuota` | speciali | 100% | 0% | 0% | 4.8 | 36.6 | 0% | 19 |
| Nimbo Boy | `nimbo_boy` | attacca | 100% | 0% | 0% | 6.0 | 0.0 | 0% | 19 |
| Nimbo Boy | `nimbo_boy` | difendi | 0% | 0% | 100% | 60.0 | 0.0 | 0% | 0 |
| Nimbo Boy | `nimbo_boy` | studia | 100% | 0% | 0% | 9.0 | 0.0 | 0% | 19 |
| Nimbo Boy | `nimbo_boy` | casuale | 100% | 0% | 0% | 18.5 | 0.0 | 0% | 19 |
| Nimbo Boy | `nimbo_boy` | si_cura | 100% | 0% | 0% | 6.0 | 0.0 | 0% | 19 |
| Nimbo Boy | `nimbo_boy` | speciali | 100% | 0% | 0% | 1.0 | 0.0 | 0% | 19 |
| Nuvola di Marciume | `nuvola_di_marciume` | attacca | 100% | 0% | 0% | 4.1 | 41.4 | 0% | 21 |
| Nuvola di Marciume | `nuvola_di_marciume` | difendi | 0% | 0% | 100% | 60.0 | 583.5 | 0% | 0 |
| Nuvola di Marciume | `nuvola_di_marciume` | studia | 100% | 0% | 0% | 7.4 | 86.5 | 0% | 21 |
| Nuvola di Marciume | `nuvola_di_marciume` | casuale | 100% | 0% | 0% | 13.0 | 117.8 | 0% | 21 |
| Nuvola di Marciume | `nuvola_di_marciume` | si_cura | 100% | 0% | 0% | 4.7 | 32.9 | 0% | 21 |
| Nuvola di Marciume | `nuvola_di_marciume` | speciali | 100% | 0% | 0% | 4.5 | 48.5 | 0% | 21 |
| Ombra del passato | `ombra_del_passato` | attacca | 100% | 0% | 0% | 8.5 | 199.3 | 0% | 55 |
| Ombra del passato | `ombra_del_passato` | difendi | 0% | 0% | 100% | 60.0 | 156.2 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | studia | 100% | 0% | 0% | 11.4 | 277.0 | 0% | 55 |
| Ombra del passato | `ombra_del_passato` | casuale | 100% | 0% | 0% | 25.4 | 194.7 | 0% | 55 |
| Ombra del passato | `ombra_del_passato` | si_cura | 100% | 0% | 0% | 8.5 | 199.3 | 0% | 55 |
| Ombra del passato | `ombra_del_passato` | speciali | 100% | 0% | 0% | 7.5 | 153.6 | 0% | 55 |
| Emblema dell'oppressione | `operaio_posseduto` | attacca | 100% | 0% | 0% | 6.6 | 24.2 | 0% | 19 |
| Emblema dell'oppressione | `operaio_posseduto` | difendi | 0% | 0% | 100% | 60.0 | 115.0 | 0% | 0 |
| Emblema dell'oppressione | `operaio_posseduto` | studia | 100% | 0% | 0% | 9.6 | 38.3 | 0% | 19 |
| Emblema dell'oppressione | `operaio_posseduto` | casuale | 100% | 0% | 0% | 23.0 | 72.0 | 0% | 19 |
| Emblema dell'oppressione | `operaio_posseduto` | si_cura | 100% | 0% | 0% | 6.6 | 24.2 | 0% | 19 |
| Emblema dell'oppressione | `operaio_posseduto` | speciali | 100% | 0% | 0% | 6.1 | 19.1 | 0% | 19 |
| Operaio Sfruttato | `operaio_sfruttato` | attacca | 100% | 0% | 0% | 9.3 | 103.2 | 0% | 42 |
| Operaio Sfruttato | `operaio_sfruttato` | difendi | 0% | 0% | 100% | 60.0 | 56.3 | 0% | 0 |
| Operaio Sfruttato | `operaio_sfruttato` | studia | 100% | 0% | 0% | 12.9 | 138.8 | 0% | 42 |
| Operaio Sfruttato | `operaio_sfruttato` | casuale | 85% | 0% | 15% | 37.4 | 121.5 | 0% | 36 |
| Operaio Sfruttato | `operaio_sfruttato` | si_cura | 100% | 0% | 0% | 9.3 | 103.2 | 0% | 42 |
| Operaio Sfruttato | `operaio_sfruttato` | speciali | 100% | 0% | 0% | 8.5 | 97.7 | 0% | 42 |
| Orrore di Meridia | `orrore_di_meridia` | attacca | 100% | 0% | 0% | 18.9 | 497.7 | 0% | 42 |
| Orrore di Meridia | `orrore_di_meridia` | difendi | 0% | 0% | 100% | 60.0 | 63.3 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | studia | 100% | 0% | 0% | 21.5 | 432.7 | 0% | 42 |
| Orrore di Meridia | `orrore_di_meridia` | casuale | 47% | 15% | 38% | 53.9 | 548.2 | 0% | 21 |
| Orrore di Meridia | `orrore_di_meridia` | si_cura | 100% | 0% | 0% | 21.9 | 318.7 | 0% | 42 |
| Orrore di Meridia | `orrore_di_meridia` | speciali | 100% | 0% | 0% | 15.1 | 536.7 | 0% | 42 |
| Rana Folle | `rana_folle` | attacca | 100% | 0% | 0% | 4.8 | 2.8 | 0% | 19 |
| Rana Folle | `rana_folle` | difendi | 0% | 0% | 100% | 60.0 | 75.4 | 0% | 0 |
| Rana Folle | `rana_folle` | studia | 100% | 0% | 0% | 7.8 | 6.3 | 0% | 19 |
| Rana Folle | `rana_folle` | casuale | 100% | 0% | 0% | 13.9 | 7.3 | 0% | 19 |
| Rana Folle | `rana_folle` | si_cura | 100% | 0% | 0% | 4.8 | 2.8 | 0% | 19 |
| Rana Folle | `rana_folle` | speciali | 100% | 0% | 0% | 4.9 | 2.3 | 0% | 19 |
| Robo Pattuglia | `robo_pattuglia` | attacca | 100% | 0% | 0% | 11.0 | 26.8 | 0% | 23 |
| Robo Pattuglia | `robo_pattuglia` | difendi | 0% | 0% | 100% | 60.0 | 25.3 | 0% | 0 |
| Robo Pattuglia | `robo_pattuglia` | studia | 99% | 0% | 1% | 14.8 | 34.6 | 0% | 23 |
| Robo Pattuglia | `robo_pattuglia` | casuale | 47% | 0% | 53% | 48.4 | 25.6 | 0% | 11 |
| Robo Pattuglia | `robo_pattuglia` | si_cura | 100% | 0% | 0% | 11.0 | 26.8 | 0% | 23 |
| Robo Pattuglia | `robo_pattuglia` | speciali | 100% | 0% | 0% | 9.7 | 20.3 | 0% | 23 |
| Sacerdote Folle | `sacerdote_folle` | attacca | 100% | 0% | 0% | 10.2 | 91.0 | 0% | 47 |
| Sacerdote Folle | `sacerdote_folle` | difendi | 0% | 0% | 100% | 60.0 | 222.6 | 0% | 0 |
| Sacerdote Folle | `sacerdote_folle` | studia | 100% | 0% | 0% | 17.1 | 179.3 | 0% | 52 |
| Sacerdote Folle | `sacerdote_folle` | casuale | 22% | 0% | 78% | 54.2 | 232.2 | 0% | 13 |
| Sacerdote Folle | `sacerdote_folle` | si_cura | 100% | 0% | 0% | 10.2 | 91.0 | 0% | 47 |
| Sacerdote Folle | `sacerdote_folle` | speciali | 100% | 0% | 0% | 8.7 | 79.3 | 0% | 46 |
| Sadico | `sadico` | attacca | 100% | 0% | 0% | 5.4 | 50.9 | 0% | 19 |
| Sadico | `sadico` | difendi | 0% | 2% | 98% | 60.0 | 561.1 | 0% | 0 |
| Sadico | `sadico` | studia | 100% | 0% | 0% | 9.0 | 110.3 | 0% | 19 |
| Sadico | `sadico` | casuale | 100% | 0% | 0% | 17.9 | 153.8 | 0% | 19 |
| Sadico | `sadico` | si_cura | 100% | 0% | 0% | 5.8 | 43.0 | 0% | 19 |
| Sadico | `sadico` | speciali | 100% | 0% | 0% | 5.9 | 58.4 | 0% | 19 |
| Slime Infimo | `slime_infimo` | attacca | 100% | 0% | 0% | 5.9 | 26.7 | 0% | 19 |
| Slime Infimo | `slime_infimo` | difendi | 0% | 0% | 100% | 60.0 | 57.8 | 0% | 0 |
| Slime Infimo | `slime_infimo` | studia | 100% | 0% | 0% | 8.9 | 48.3 | 0% | 19 |
| Slime Infimo | `slime_infimo` | casuale | 99% | 0% | 1% | 21.5 | 33.3 | 0% | 19 |
| Slime Infimo | `slime_infimo` | si_cura | 100% | 0% | 0% | 5.9 | 26.7 | 0% | 19 |
| Slime Infimo | `slime_infimo` | speciali | 100% | 0% | 0% | 6.5 | 32.5 | 0% | 19 |
| Sogno perduto | `sogno_perduto` | attacca | 100% | 0% | 0% | 1.0 | 0.0 | 0% | 19 |
| Sogno perduto | `sogno_perduto` | difendi | 0% | 0% | 100% | 60.0 | 27.2 | 0% | 0 |
| Sogno perduto | `sogno_perduto` | studia | 100% | 0% | 0% | 4.0 | 1.3 | 0% | 19 |
| Sogno perduto | `sogno_perduto` | casuale | 100% | 0% | 0% | 3.2 | 1.4 | 0% | 19 |
| Sogno perduto | `sogno_perduto` | si_cura | 100% | 0% | 0% | 1.0 | 0.0 | 0% | 19 |
| Sogno perduto | `sogno_perduto` | speciali | 100% | 0% | 0% | 1.2 | 0.2 | 0% | 19 |
| Stigma | `stigma` | attacca | 100% | 0% | 0% | 5.1 | 36.4 | 0% | 19 |
| Stigma | `stigma` | difendi | 0% | 0% | 100% | 60.0 | 515.8 | 0% | 0 |
| Stigma | `stigma` | studia | 100% | 0% | 0% | 8.5 | 79.8 | 0% | 19 |
| Stigma | `stigma` | casuale | 100% | 0% | 0% | 17.3 | 112.6 | 0% | 19 |
| Stigma | `stigma` | si_cura | 100% | 0% | 0% | 5.2 | 29.6 | 0% | 19 |
| Stigma | `stigma` | speciali | 100% | 0% | 0% | 5.8 | 48.8 | 0% | 19 |
| Tartaruga Gigante | `tartaruga_innocente` | attacca | 100% | 0% | 0% | 9.7 | 0.0 | 0% | 1 |
| Tartaruga Gigante | `tartaruga_innocente` | difendi | 0% | 0% | 100% | 60.0 | 0.0 | 0% | 0 |
| Tartaruga Gigante | `tartaruga_innocente` | studia | 100% | 0% | 0% | 2.0 | 0.0 | 100% | 1 |
| Tartaruga Gigante | `tartaruga_innocente` | casuale | 0% | 0% | 100% | 60.0 | 0.0 | 0% | 0 |
| Tartaruga Gigante | `tartaruga_innocente` | si_cura | 100% | 0% | 0% | 9.7 | 0.0 | 0% | 1 |
| Tartaruga Gigante | `tartaruga_innocente` | speciali | 100% | 0% | 0% | 9.3 | 0.0 | 0% | 1 |
| Un tenero ricordo | `tenero_ricordo` | attacca | 0% | 100% | 0% | 17.3 | 610.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | difendi | 0% | 100% | 0% | 24.1 | 610.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | studia | 0% | 100% | 0% | 19.3 | 610.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | casuale | 0% | 100% | 0% | 23.9 | 610.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | si_cura | 0% | 100% | 0% | 21.2 | 610.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | speciali | 0% | 100% | 0% | 17.3 | 610.0 | 0% | 0 |
| Teschio Errante | `teschio_errante` | attacca | 100% | 0% | 0% | 5.1 | 19.1 | 0% | 19 |
| Teschio Errante | `teschio_errante` | difendi | 0% | 0% | 100% | 60.0 | 55.2 | 0% | 0 |
| Teschio Errante | `teschio_errante` | studia | 100% | 0% | 0% | 8.2 | 35.6 | 0% | 19 |
| Teschio Errante | `teschio_errante` | casuale | 100% | 0% | 0% | 15.5 | 26.1 | 0% | 19 |
| Teschio Errante | `teschio_errante` | si_cura | 100% | 0% | 0% | 5.1 | 19.1 | 0% | 19 |
| Teschio Errante | `teschio_errante` | speciali | 100% | 0% | 0% | 5.7 | 24.6 | 0% | 19 |
| Titano Zombie | `titano_zombie` | attacca | 100% | 0% | 0% | 15.6 | 451.5 | 0% | 60 |
| Titano Zombie | `titano_zombie` | difendi | 0% | 100% | 0% | 27.9 | 610.0 | 0% | 0 |
| Titano Zombie | `titano_zombie` | studia | 96% | 4% | 0% | 18.8 | 508.8 | 0% | 58 |
| Titano Zombie | `titano_zombie` | casuale | 3% | 96% | 1% | 31.3 | 609.1 | 0% | 2 |
| Titano Zombie | `titano_zombie` | si_cura | 100% | 0% | 0% | 20.7 | 373.8 | 0% | 60 |
| Titano Zombie | `titano_zombie` | speciali | 100% | 0% | 0% | 13.4 | 357.3 | 0% | 60 |
| Capocantiere | `voce_registrata` | attacca | 100% | 0% | 0% | 4.9 | 20.8 | 0% | 19 |
| Capocantiere | `voce_registrata` | difendi | 0% | 0% | 100% | 60.0 | 48.2 | 0% | 0 |
| Capocantiere | `voce_registrata` | studia | 100% | 0% | 0% | 7.9 | 44.1 | 0% | 19 |
| Capocantiere | `voce_registrata` | casuale | 100% | 0% | 0% | 15.1 | 33.7 | 0% | 19 |
| Capocantiere | `voce_registrata` | si_cura | 100% | 0% | 0% | 4.9 | 20.8 | 0% | 19 |
| Capocantiere | `voce_registrata` | speciali | 100% | 0% | 0% | 5.7 | 33.2 | 0% | 19 |
| Volto sulla parete | `volto_sulla_parete` | attacca | 0% | 100% | 0% | 14.0 | 610.0 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | difendi | 0% | 100% | 0% | 40.2 | 610.0 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | studia | 0% | 100% | 0% | 14.1 | 610.0 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | casuale | 0% | 100% | 0% | 26.8 | 610.0 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | si_cura | 0% | 100% | 0% | 24.3 | 610.0 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | speciali | 0% | 100% | 0% | 13.9 | 610.0 | 0% | 0 |
| Zombie Cittadino | `zombie_cittadino` | attacca | 99% | 0% | 1% | 26.3 | 140.4 | 0% | 19 |
| Zombie Cittadino | `zombie_cittadino` | difendi | 0% | 0% | 100% | 60.0 | 69.9 | 0% | 0 |
| Zombie Cittadino | `zombie_cittadino` | studia | 97% | 0% | 3% | 32.1 | 173.6 | 0% | 18 |
| Zombie Cittadino | `zombie_cittadino` | casuale | 35% | 0% | 65% | 52.1 | 58.0 | 0% | 7 |
| Zombie Cittadino | `zombie_cittadino` | si_cura | 99% | 0% | 1% | 26.3 | 139.6 | 0% | 19 |
| Zombie Cittadino | `zombie_cittadino` | speciali | 98% | 0% | 2% | 24.2 | 124.6 | 0% | 19 |
| Zombie Mostruoso | `zombie_mostruoso` | attacca | 100% | 0% | 0% | 4.9 | 22.9 | 0% | 19 |
| Zombie Mostruoso | `zombie_mostruoso` | difendi | 0% | 0% | 100% | 60.0 | 50.2 | 0% | 0 |
| Zombie Mostruoso | `zombie_mostruoso` | studia | 100% | 0% | 0% | 7.9 | 49.7 | 0% | 19 |
| Zombie Mostruoso | `zombie_mostruoso` | casuale | 100% | 0% | 0% | 15.5 | 43.4 | 0% | 19 |
| Zombie Mostruoso | `zombie_mostruoso` | si_cura | 100% | 0% | 0% | 4.9 | 22.9 | 0% | 19 |
| Zombie Mostruoso | `zombie_mostruoso` | speciali | 100% | 0% | 0% | 5.5 | 34.3 | 0% | 19 |

## Protagonista di livello 18

| creatura | id | come si gioca | vinte | perse | ∞ | giri | danno | risp. | xp |
|---|---|---|--:|--:|--:|--:|--:|--:|--:|
| Abominio Marcio | `abominio_marcio` | attacca | 100% | 0% | 0% | 16.3 | 455.4 | 0% | 71 |
| Abominio Marcio | `abominio_marcio` | difendi | 0% | 15% | 85% | 59.6 | 830.5 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | studia | 100% | 0% | 0% | 19.7 | 555.3 | 0% | 71 |
| Abominio Marcio | `abominio_marcio` | casuale | 13% | 40% | 47% | 57.2 | 845.5 | 0% | 10 |
| Abominio Marcio | `abominio_marcio` | si_cura | 100% | 0% | 0% | 17.8 | 353.1 | 0% | 71 |
| Abominio Marcio | `abominio_marcio` | speciali | 100% | 0% | 0% | 12.3 | 309.9 | 0% | 71 |
| Oppresso | `comparsa_di_ruggine` | attacca | 100% | 0% | 0% | 11.8 | 42.9 | 0% | 39 |
| Oppresso | `comparsa_di_ruggine` | difendi | 0% | 0% | 100% | 60.0 | 25.9 | 0% | 0 |
| Oppresso | `comparsa_di_ruggine` | studia | 99% | 0% | 1% | 17.2 | 62.7 | 0% | 38 |
| Oppresso | `comparsa_di_ruggine` | casuale | 41% | 0% | 59% | 50.0 | 32.4 | 0% | 16 |
| Oppresso | `comparsa_di_ruggine` | si_cura | 100% | 0% | 0% | 11.8 | 42.9 | 0% | 39 |
| Oppresso | `comparsa_di_ruggine` | speciali | 100% | 0% | 0% | 10.0 | 34.6 | 0% | 39 |
| Diabolo | `diabolo` | attacca | 100% | 0% | 0% | 6.8 | 52.8 | 0% | 32 |
| Diabolo | `diabolo` | difendi | 33% | 0% | 67% | 54.4 | 62.4 | 0% | 11 |
| Diabolo | `diabolo` | studia | 100% | 0% | 0% | 9.7 | 78.5 | 0% | 32 |
| Diabolo | `diabolo` | casuale | 100% | 0% | 0% | 18.0 | 42.7 | 0% | 32 |
| Diabolo | `diabolo` | si_cura | 100% | 0% | 0% | 6.8 | 52.8 | 0% | 32 |
| Diabolo | `diabolo` | speciali | 100% | 0% | 0% | 6.6 | 50.6 | 0% | 32 |
| Il Divoratore | `divoratore` | attacca | 100% | 0% | 0% | 21.8 | 343.6 | 0% | 71 |
| Il Divoratore | `divoratore` | difendi | 0% | 0% | 100% | 60.0 | 124.7 | 0% | 0 |
| Il Divoratore | `divoratore` | studia | 100% | 0% | 0% | 24.7 | 411.7 | 0% | 71 |
| Il Divoratore | `divoratore` | casuale | 44% | 0% | 56% | 57.0 | 176.9 | 0% | 35 |
| Il Divoratore | `divoratore` | si_cura | 100% | 0% | 0% | 21.8 | 343.6 | 0% | 71 |
| Il Divoratore | `divoratore` | speciali | 100% | 0% | 0% | 17.5 | 270.2 | 0% | 71 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | attacca | 100% | 0% | 0% | 6.9 | 41.1 | 0% | 32 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | difendi | 0% | 0% | 100% | 60.0 | 69.8 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | studia | 100% | 0% | 0% | 9.7 | 59.3 | 0% | 32 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | casuale | 100% | 0% | 0% | 24.0 | 42.0 | 0% | 32 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | si_cura | 100% | 0% | 0% | 6.9 | 41.1 | 0% | 32 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | speciali | 100% | 0% | 0% | 6.7 | 39.3 | 0% | 32 |
| Donna Spinosa | `donna_spinosa` | attacca | 100% | 0% | 0% | 6.3 | 99.4 | 0% | 32 |
| Donna Spinosa | `donna_spinosa` | difendi | 0% | 0% | 100% | 60.0 | 799.4 | 0% | 0 |
| Donna Spinosa | `donna_spinosa` | studia | 100% | 0% | 0% | 9.6 | 169.4 | 0% | 32 |
| Donna Spinosa | `donna_spinosa` | casuale | 100% | 0% | 0% | 20.2 | 267.8 | 0% | 32 |
| Donna Spinosa | `donna_spinosa` | si_cura | 100% | 0% | 0% | 7.0 | 87.8 | 0% | 32 |
| Donna Spinosa | `donna_spinosa` | speciali | 100% | 0% | 0% | 6.4 | 91.9 | 0% | 32 |
| Rottami Erranti | `ferraglia_urlante` | attacca | 100% | 0% | 0% | 21.4 | 117.1 | 0% | 53 |
| Rottami Erranti | `ferraglia_urlante` | difendi | 0% | 0% | 100% | 60.0 | 41.4 | 0% | 0 |
| Rottami Erranti | `ferraglia_urlante` | studia | 100% | 0% | 0% | 28.0 | 205.3 | 0% | 58 |
| Rottami Erranti | `ferraglia_urlante` | casuale | 3% | 0% | 97% | 59.8 | 99.2 | 0% | 2 |
| Rottami Erranti | `ferraglia_urlante` | si_cura | 100% | 0% | 0% | 21.4 | 117.1 | 0% | 53 |
| Rottami Erranti | `ferraglia_urlante` | speciali | 100% | 0% | 0% | 12.6 | 26.3 | 0% | 39 |
| Ghoul | `ghoul` | attacca | 100% | 0% | 0% | 5.8 | 61.4 | 0% | 32 |
| Ghoul | `ghoul` | difendi | 0% | 0% | 100% | 60.0 | 84.1 | 0% | 0 |
| Ghoul | `ghoul` | studia | 100% | 0% | 0% | 8.8 | 97.6 | 0% | 32 |
| Ghoul | `ghoul` | casuale | 100% | 0% | 0% | 17.7 | 69.9 | 0% | 32 |
| Ghoul | `ghoul` | si_cura | 100% | 0% | 0% | 5.8 | 61.4 | 0% | 32 |
| Ghoul | `ghoul` | speciali | 100% | 0% | 0% | 6.0 | 61.1 | 0% | 32 |
| El Muy Bonito | `giocoliere` | attacca | 100% | 0% | 0% | 9.9 | 192.6 | 0% | 71 |
| El Muy Bonito | `giocoliere` | difendi | 0% | 0% | 100% | 60.0 | 125.3 | 0% | 0 |
| El Muy Bonito | `giocoliere` | studia | 100% | 0% | 0% | 12.6 | 428.3 | 0% | 71 |
| El Muy Bonito | `giocoliere` | casuale | 79% | 21% | 0% | 25.2 | 601.7 | 0% | 56 |
| El Muy Bonito | `giocoliere` | si_cura | 100% | 0% | 0% | 9.9 | 192.6 | 0% | 71 |
| El Muy Bonito | `giocoliere` | speciali | 100% | 0% | 0% | 9.0 | 164.4 | 0% | 71 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | attacca | 100% | 0% | 0% | 12.4 | 26.2 | 0% | 498 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | difendi | 0% | 0% | 100% | 60.0 | 32.2 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | studia | 100% | 0% | 0% | 16.6 | 41.7 | 0% | 499 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | casuale | 78% | 0% | 22% | 43.8 | 46.5 | 0% | 395 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | si_cura | 100% | 0% | 0% | 12.4 | 26.2 | 0% | 498 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | speciali | 100% | 0% | 0% | 10.9 | 21.4 | 0% | 497 |
| Goblin Possessivo | `goblin_possessivo` | attacca | 100% | 0% | 0% | 5.8 | 34.6 | 0% | 32 |
| Goblin Possessivo | `goblin_possessivo` | difendi | 0% | 0% | 100% | 60.0 | 75.0 | 0% | 0 |
| Goblin Possessivo | `goblin_possessivo` | studia | 100% | 0% | 0% | 8.8 | 67.8 | 0% | 32 |
| Goblin Possessivo | `goblin_possessivo` | casuale | 100% | 0% | 0% | 18.6 | 48.4 | 0% | 32 |
| Goblin Possessivo | `goblin_possessivo` | si_cura | 100% | 0% | 0% | 5.8 | 34.6 | 0% | 32 |
| Goblin Possessivo | `goblin_possessivo` | speciali | 100% | 0% | 0% | 5.9 | 33.4 | 0% | 32 |
| Goblin Tipico | `goblin_tipico` | attacca | 100% | 0% | 0% | 5.8 | 34.6 | 0% | 32 |
| Goblin Tipico | `goblin_tipico` | difendi | 0% | 0% | 100% | 60.0 | 75.0 | 0% | 0 |
| Goblin Tipico | `goblin_tipico` | studia | 100% | 0% | 0% | 8.8 | 67.8 | 0% | 32 |
| Goblin Tipico | `goblin_tipico` | casuale | 100% | 0% | 0% | 18.6 | 48.4 | 0% | 32 |
| Goblin Tipico | `goblin_tipico` | si_cura | 100% | 0% | 0% | 5.8 | 34.6 | 0% | 32 |
| Goblin Tipico | `goblin_tipico` | speciali | 100% | 0% | 0% | 5.9 | 33.4 | 0% | 32 |
| Golem errante di rottami | `golem_errante` | attacca | 100% | 0% | 0% | 12.4 | 201.1 | 0% | 71 |
| Golem errante di rottami | `golem_errante` | difendi | 0% | 0% | 100% | 60.0 | 116.0 | 0% | 0 |
| Golem errante di rottami | `golem_errante` | studia | 100% | 0% | 0% | 15.5 | 274.1 | 0% | 71 |
| Golem errante di rottami | `golem_errante` | casuale | 55% | 0% | 45% | 55.0 | 180.2 | 0% | 41 |
| Golem errante di rottami | `golem_errante` | si_cura | 100% | 0% | 0% | 12.4 | 201.1 | 0% | 71 |
| Golem errante di rottami | `golem_errante` | speciali | 100% | 0% | 0% | 11.5 | 192.0 | 0% | 71 |
| Infetto Rapido | `infetto_rapido` | attacca | 100% | 0% | 0% | 3.9 | 41.4 | 0% | 36 |
| Infetto Rapido | `infetto_rapido` | difendi | 0% | 0% | 100% | 60.0 | 105.5 | 0% | 0 |
| Infetto Rapido | `infetto_rapido` | studia | 100% | 0% | 0% | 7.0 | 68.7 | 0% | 36 |
| Infetto Rapido | `infetto_rapido` | casuale | 100% | 0% | 0% | 12.1 | 49.6 | 0% | 36 |
| Infetto Rapido | `infetto_rapido` | si_cura | 100% | 0% | 0% | 3.9 | 41.4 | 0% | 36 |
| Infetto Rapido | `infetto_rapido` | speciali | 100% | 0% | 0% | 4.7 | 52.6 | 0% | 36 |
| L'ultimo spettacolo di Jerah | `jerah` | attacca | 0% | 100% | 0% | 17.8 | 890.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | difendi | 0% | 77% | 23% | 38.4 | 844.3 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | studia | 5% | 95% | 0% | 21.1 | 884.3 | 0% | 27 |
| L'ultimo spettacolo di Jerah | `jerah` | casuale | 0% | 63% | 37% | 42.4 | 821.1 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | si_cura | 5% | 95% | 0% | 25.7 | 884.8 | 0% | 24 |
| L'ultimo spettacolo di Jerah | `jerah` | speciali | 5% | 95% | 0% | 18.2 | 885.7 | 0% | 24 |
| Jongo Dongo | `jongo_dongo` | attacca | 1% | 99% | 0% | 26.5 | 889.1 | 0% | 4 |
| Jongo Dongo | `jongo_dongo` | difendi | 0% | 65% | 35% | 55.7 | 852.2 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | studia | 0% | 100% | 0% | 27.1 | 890.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | casuale | 0% | 83% | 17% | 51.2 | 865.7 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | si_cura | 19% | 81% | 0% | 39.9 | 856.6 | 0% | 120 |
| Jongo Dongo | `jongo_dongo` | speciali | 9% | 91% | 0% | 24.9 | 877.5 | 0% | 55 |
| Jongo Dongo | `jongo_dongo_risorto` | attacca | 0% | 100% | 0% | 25.0 | 890.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | difendi | 0% | 0% | 100% | 60.0 | 380.3 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | studia | 0% | 100% | 0% | 25.1 | 890.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | casuale | 0% | 3% | 97% | 59.5 | 566.9 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | si_cura | 0% | 100% | 0% | 35.7 | 890.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | speciali | 1% | 99% | 0% | 24.5 | 890.0 | 0% | 3 |
| ??? | `l_immortale` | attacca | 0% | 0% | 100% | 60.0 | 26.0 | 0% | 0 |
| ??? | `l_immortale` | difendi | 0% | 0% | 100% | 60.0 | 26.0 | 0% | 0 |
| ??? | `l_immortale` | studia | 0% | 0% | 100% | 60.0 | 26.0 | 0% | 0 |
| ??? | `l_immortale` | casuale | 0% | 0% | 100% | 60.0 | 26.0 | 0% | 0 |
| ??? | `l_immortale` | si_cura | 0% | 0% | 100% | 60.0 | 26.0 | 0% | 0 |
| ??? | `l_immortale` | speciali | 0% | 0% | 100% | 60.0 | 26.0 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | attacca | 100% | 0% | 0% | 5.7 | 59.1 | 0% | 32 |
| Madre in Lacrime | `madre_in_lacrime` | difendi | 0% | 0% | 100% | 60.0 | 94.7 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | studia | 100% | 0% | 0% | 8.7 | 91.5 | 0% | 32 |
| Madre in Lacrime | `madre_in_lacrime` | casuale | 100% | 0% | 0% | 17.6 | 65.1 | 0% | 32 |
| Madre in Lacrime | `madre_in_lacrime` | si_cura | 100% | 0% | 0% | 5.7 | 59.1 | 0% | 32 |
| Madre in Lacrime | `madre_in_lacrime` | speciali | 100% | 0% | 0% | 5.9 | 53.7 | 0% | 32 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | attacca | 0% | 100% | 0% | 14.0 | 890.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | difendi | 0% | 100% | 0% | 14.0 | 890.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | studia | 0% | 100% | 0% | 14.0 | 890.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | casuale | 0% | 100% | 0% | 14.0 | 890.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | si_cura | 0% | 100% | 0% | 14.0 | 890.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | speciali | 0% | 100% | 0% | 14.0 | 890.0 | 0% | 0 |
| Marionetta | `marionetta` | attacca | 100% | 0% | 0% | 6.8 | 52.2 | 0% | 32 |
| Marionetta | `marionetta` | difendi | 0% | 0% | 100% | 60.0 | 85.2 | 0% | 0 |
| Marionetta | `marionetta` | studia | 100% | 0% | 0% | 9.8 | 91.4 | 0% | 32 |
| Marionetta | `marionetta` | casuale | 99% | 0% | 1% | 23.5 | 65.9 | 0% | 32 |
| Marionetta | `marionetta` | si_cura | 100% | 0% | 0% | 6.8 | 52.2 | 0% | 32 |
| Marionetta | `marionetta` | speciali | 100% | 0% | 0% | 6.1 | 47.7 | 0% | 32 |
| Fomentado | `maschera_vuota` | attacca | 100% | 0% | 0% | 4.8 | 93.5 | 0% | 32 |
| Fomentado | `maschera_vuota` | difendi | 0% | 0% | 100% | 60.0 | 72.3 | 0% | 0 |
| Fomentado | `maschera_vuota` | studia | 100% | 0% | 0% | 7.7 | 123.1 | 0% | 32 |
| Fomentado | `maschera_vuota` | casuale | 100% | 0% | 0% | 11.9 | 86.5 | 0% | 32 |
| Fomentado | `maschera_vuota` | si_cura | 100% | 0% | 0% | 4.8 | 93.5 | 0% | 32 |
| Fomentado | `maschera_vuota` | speciali | 100% | 0% | 0% | 4.8 | 93.3 | 0% | 32 |
| Nimbo Boy | `nimbo_boy` | attacca | 100% | 0% | 0% | 8.0 | 0.0 | 0% | 32 |
| Nimbo Boy | `nimbo_boy` | difendi | 0% | 0% | 100% | 60.0 | 0.0 | 0% | 0 |
| Nimbo Boy | `nimbo_boy` | studia | 100% | 0% | 0% | 11.0 | 0.0 | 0% | 32 |
| Nimbo Boy | `nimbo_boy` | casuale | 100% | 0% | 0% | 24.2 | 0.0 | 0% | 32 |
| Nimbo Boy | `nimbo_boy` | si_cura | 100% | 0% | 0% | 8.0 | 0.0 | 0% | 32 |
| Nimbo Boy | `nimbo_boy` | speciali | 100% | 0% | 0% | 1.0 | 0.0 | 0% | 32 |
| Nuvola di Marciume | `nuvola_di_marciume` | attacca | 100% | 0% | 0% | 4.4 | 70.2 | 0% | 36 |
| Nuvola di Marciume | `nuvola_di_marciume` | difendi | 0% | 0% | 100% | 60.0 | 821.9 | 0% | 0 |
| Nuvola di Marciume | `nuvola_di_marciume` | studia | 100% | 0% | 0% | 7.6 | 130.2 | 0% | 36 |
| Nuvola di Marciume | `nuvola_di_marciume` | casuale | 100% | 0% | 0% | 13.9 | 182.2 | 0% | 36 |
| Nuvola di Marciume | `nuvola_di_marciume` | si_cura | 100% | 0% | 0% | 4.8 | 50.8 | 0% | 36 |
| Nuvola di Marciume | `nuvola_di_marciume` | speciali | 100% | 0% | 0% | 4.8 | 76.4 | 0% | 36 |
| Ombra del passato | `ombra_del_passato` | attacca | 100% | 0% | 0% | 5.8 | 56.8 | 0% | 32 |
| Ombra del passato | `ombra_del_passato` | difendi | 0% | 0% | 100% | 60.0 | 83.1 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | studia | 100% | 0% | 0% | 8.9 | 94.5 | 0% | 32 |
| Ombra del passato | `ombra_del_passato` | casuale | 100% | 0% | 0% | 17.6 | 73.7 | 0% | 32 |
| Ombra del passato | `ombra_del_passato` | si_cura | 100% | 0% | 0% | 5.8 | 56.8 | 0% | 32 |
| Ombra del passato | `ombra_del_passato` | speciali | 100% | 0% | 0% | 6.1 | 61.6 | 0% | 32 |
| Emblema dell'oppressione | `operaio_posseduto` | attacca | 100% | 0% | 0% | 6.6 | 27.7 | 0% | 32 |
| Emblema dell'oppressione | `operaio_posseduto` | difendi | 0% | 0% | 100% | 60.0 | 126.0 | 0% | 0 |
| Emblema dell'oppressione | `operaio_posseduto` | studia | 100% | 0% | 0% | 9.6 | 45.2 | 0% | 32 |
| Emblema dell'oppressione | `operaio_posseduto` | casuale | 100% | 0% | 0% | 22.9 | 101.3 | 0% | 32 |
| Emblema dell'oppressione | `operaio_posseduto` | si_cura | 100% | 0% | 0% | 6.6 | 27.7 | 0% | 32 |
| Emblema dell'oppressione | `operaio_posseduto` | speciali | 100% | 0% | 0% | 6.1 | 27.4 | 0% | 32 |
| Operaio Sfruttato | `operaio_sfruttato` | attacca | 100% | 0% | 0% | 11.2 | 197.6 | 0% | 71 |
| Operaio Sfruttato | `operaio_sfruttato` | difendi | 0% | 0% | 100% | 60.0 | 80.1 | 0% | 0 |
| Operaio Sfruttato | `operaio_sfruttato` | studia | 100% | 0% | 0% | 15.0 | 245.9 | 0% | 71 |
| Operaio Sfruttato | `operaio_sfruttato` | casuale | 45% | 0% | 55% | 51.9 | 262.1 | 0% | 32 |
| Operaio Sfruttato | `operaio_sfruttato` | si_cura | 100% | 0% | 0% | 11.2 | 197.6 | 0% | 71 |
| Operaio Sfruttato | `operaio_sfruttato` | speciali | 100% | 0% | 0% | 10.1 | 187.6 | 0% | 71 |
| Orrore di Meridia | `orrore_di_meridia` | attacca | 100% | 0% | 0% | 20.7 | 838.8 | 0% | 71 |
| Orrore di Meridia | `orrore_di_meridia` | difendi | 0% | 0% | 100% | 60.0 | 87.4 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | studia | 99% | 1% | 0% | 24.4 | 835.1 | 0% | 70 |
| Orrore di Meridia | `orrore_di_meridia` | casuale | 16% | 10% | 74% | 58.0 | 690.7 | 0% | 14 |
| Orrore di Meridia | `orrore_di_meridia` | si_cura | 100% | 0% | 0% | 25.4 | 735.7 | 0% | 71 |
| Orrore di Meridia | `orrore_di_meridia` | speciali | 99% | 1% | 0% | 17.5 | 810.1 | 0% | 71 |
| Rana Folle | `rana_folle` | attacca | 100% | 0% | 0% | 4.8 | 2.8 | 0% | 32 |
| Rana Folle | `rana_folle` | difendi | 0% | 0% | 100% | 60.0 | 81.4 | 0% | 0 |
| Rana Folle | `rana_folle` | studia | 100% | 0% | 0% | 7.8 | 8.5 | 0% | 32 |
| Rana Folle | `rana_folle` | casuale | 100% | 0% | 0% | 14.6 | 8.1 | 0% | 32 |
| Rana Folle | `rana_folle` | si_cura | 100% | 0% | 0% | 4.8 | 2.8 | 0% | 32 |
| Rana Folle | `rana_folle` | speciali | 100% | 0% | 0% | 4.8 | 2.4 | 0% | 32 |
| Robo Pattuglia | `robo_pattuglia` | attacca | 100% | 0% | 0% | 14.0 | 59.1 | 0% | 39 |
| Robo Pattuglia | `robo_pattuglia` | difendi | 0% | 0% | 100% | 60.0 | 34.0 | 0% | 0 |
| Robo Pattuglia | `robo_pattuglia` | studia | 97% | 0% | 3% | 20.5 | 88.1 | 0% | 38 |
| Robo Pattuglia | `robo_pattuglia` | casuale | 28% | 0% | 72% | 53.0 | 39.9 | 0% | 11 |
| Robo Pattuglia | `robo_pattuglia` | si_cura | 100% | 0% | 0% | 14.0 | 59.1 | 0% | 39 |
| Robo Pattuglia | `robo_pattuglia` | speciali | 100% | 0% | 0% | 11.2 | 47.3 | 0% | 39 |
| Sacerdote Folle | `sacerdote_folle` | attacca | 100% | 0% | 0% | 9.2 | 86.2 | 0% | 45 |
| Sacerdote Folle | `sacerdote_folle` | difendi | 0% | 0% | 100% | 60.0 | 242.0 | 0% | 0 |
| Sacerdote Folle | `sacerdote_folle` | studia | 100% | 0% | 0% | 15.7 | 175.4 | 0% | 53 |
| Sacerdote Folle | `sacerdote_folle` | casuale | 35% | 0% | 65% | 50.6 | 216.9 | 0% | 21 |
| Sacerdote Folle | `sacerdote_folle` | si_cura | 100% | 0% | 0% | 9.2 | 86.2 | 0% | 45 |
| Sacerdote Folle | `sacerdote_folle` | speciali | 100% | 0% | 0% | 8.4 | 75.0 | 0% | 44 |
| Sadico | `sadico` | attacca | 100% | 0% | 0% | 6.3 | 102.7 | 0% | 32 |
| Sadico | `sadico` | difendi | 0% | 3% | 97% | 59.9 | 811.3 | 0% | 0 |
| Sadico | `sadico` | studia | 100% | 0% | 0% | 9.5 | 169.7 | 0% | 32 |
| Sadico | `sadico` | casuale | 100% | 0% | 0% | 20.6 | 272.0 | 0% | 32 |
| Sadico | `sadico` | si_cura | 100% | 0% | 0% | 7.0 | 91.5 | 0% | 32 |
| Sadico | `sadico` | speciali | 100% | 0% | 0% | 6.4 | 96.0 | 0% | 32 |
| Slime Infimo | `slime_infimo` | attacca | 100% | 0% | 0% | 6.8 | 50.9 | 0% | 32 |
| Slime Infimo | `slime_infimo` | difendi | 0% | 0% | 100% | 60.0 | 77.8 | 0% | 0 |
| Slime Infimo | `slime_infimo` | studia | 100% | 0% | 0% | 9.8 | 83.7 | 0% | 32 |
| Slime Infimo | `slime_infimo` | casuale | 100% | 0% | 0% | 27.1 | 54.9 | 0% | 32 |
| Slime Infimo | `slime_infimo` | si_cura | 100% | 0% | 0% | 6.8 | 50.9 | 0% | 32 |
| Slime Infimo | `slime_infimo` | speciali | 100% | 0% | 0% | 6.9 | 51.6 | 0% | 32 |
| Sogno perduto | `sogno_perduto` | attacca | 100% | 0% | 0% | 1.0 | 0.0 | 0% | 32 |
| Sogno perduto | `sogno_perduto` | difendi | 0% | 0% | 100% | 60.0 | 24.2 | 0% | 0 |
| Sogno perduto | `sogno_perduto` | studia | 100% | 0% | 0% | 4.0 | 1.3 | 0% | 32 |
| Sogno perduto | `sogno_perduto` | casuale | 100% | 0% | 0% | 3.2 | 1.4 | 0% | 32 |
| Sogno perduto | `sogno_perduto` | si_cura | 100% | 0% | 0% | 1.0 | 0.0 | 0% | 32 |
| Sogno perduto | `sogno_perduto` | speciali | 100% | 0% | 0% | 1.0 | 0.0 | 0% | 32 |
| Stigma | `stigma` | attacca | 100% | 0% | 0% | 6.0 | 77.2 | 0% | 32 |
| Stigma | `stigma` | difendi | 0% | 1% | 99% | 60.0 | 751.3 | 0% | 0 |
| Stigma | `stigma` | studia | 100% | 0% | 0% | 9.1 | 136.9 | 0% | 32 |
| Stigma | `stigma` | casuale | 100% | 0% | 0% | 19.3 | 208.7 | 0% | 32 |
| Stigma | `stigma` | si_cura | 100% | 0% | 0% | 6.1 | 66.3 | 0% | 32 |
| Stigma | `stigma` | speciali | 100% | 0% | 0% | 6.2 | 77.5 | 0% | 32 |
| Tartaruga Gigante | `tartaruga_innocente` | attacca | 100% | 0% | 0% | 5.7 | 0.0 | 0% | 1 |
| Tartaruga Gigante | `tartaruga_innocente` | difendi | 0% | 0% | 100% | 60.0 | 0.0 | 0% | 0 |
| Tartaruga Gigante | `tartaruga_innocente` | studia | 100% | 0% | 0% | 2.0 | 0.0 | 100% | 1 |
| Tartaruga Gigante | `tartaruga_innocente` | casuale | 23% | 0% | 77% | 49.3 | 0.0 | 0% | 0 |
| Tartaruga Gigante | `tartaruga_innocente` | si_cura | 100% | 0% | 0% | 5.7 | 0.0 | 0% | 1 |
| Tartaruga Gigante | `tartaruga_innocente` | speciali | 100% | 0% | 0% | 5.9 | 0.0 | 0% | 1 |
| Un tenero ricordo | `tenero_ricordo` | attacca | 0% | 100% | 0% | 25.5 | 890.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | difendi | 0% | 100% | 0% | 27.4 | 890.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | studia | 0% | 100% | 0% | 25.8 | 890.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | casuale | 0% | 100% | 0% | 27.8 | 890.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | si_cura | 0% | 100% | 0% | 26.4 | 890.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | speciali | 0% | 100% | 0% | 25.4 | 890.0 | 0% | 0 |
| Teschio Errante | `teschio_errante` | attacca | 100% | 0% | 0% | 6.1 | 46.6 | 0% | 32 |
| Teschio Errante | `teschio_errante` | difendi | 0% | 0% | 100% | 60.0 | 82.8 | 0% | 0 |
| Teschio Errante | `teschio_errante` | studia | 100% | 0% | 0% | 8.9 | 71.8 | 0% | 32 |
| Teschio Errante | `teschio_errante` | casuale | 100% | 0% | 0% | 18.5 | 46.6 | 0% | 32 |
| Teschio Errante | `teschio_errante` | si_cura | 100% | 0% | 0% | 6.1 | 46.6 | 0% | 32 |
| Teschio Errante | `teschio_errante` | speciali | 100% | 0% | 0% | 6.1 | 39.7 | 0% | 32 |
| Titano Zombie | `titano_zombie` | attacca | 100% | 0% | 0% | 15.4 | 643.1 | 0% | 71 |
| Titano Zombie | `titano_zombie` | difendi | 0% | 99% | 1% | 31.5 | 889.9 | 0% | 0 |
| Titano Zombie | `titano_zombie` | studia | 99% | 1% | 0% | 18.9 | 725.0 | 0% | 71 |
| Titano Zombie | `titano_zombie` | casuale | 4% | 95% | 1% | 33.7 | 887.4 | 0% | 3 |
| Titano Zombie | `titano_zombie` | si_cura | 100% | 0% | 0% | 20.7 | 601.0 | 0% | 71 |
| Titano Zombie | `titano_zombie` | speciali | 100% | 0% | 0% | 13.2 | 486.6 | 0% | 71 |
| Capocantiere | `voce_registrata` | attacca | 100% | 0% | 0% | 5.7 | 52.9 | 0% | 32 |
| Capocantiere | `voce_registrata` | difendi | 0% | 0% | 100% | 60.0 | 68.2 | 0% | 0 |
| Capocantiere | `voce_registrata` | studia | 100% | 0% | 0% | 8.7 | 87.0 | 0% | 32 |
| Capocantiere | `voce_registrata` | casuale | 100% | 0% | 0% | 17.3 | 57.4 | 0% | 32 |
| Capocantiere | `voce_registrata` | si_cura | 100% | 0% | 0% | 5.7 | 52.9 | 0% | 32 |
| Capocantiere | `voce_registrata` | speciali | 100% | 0% | 0% | 5.8 | 45.4 | 0% | 32 |
| Volto sulla parete | `volto_sulla_parete` | attacca | 18% | 82% | 0% | 29.1 | 872.5 | 0% | 26 |
| Volto sulla parete | `volto_sulla_parete` | difendi | 0% | 19% | 81% | 59.6 | 840.7 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | studia | 13% | 87% | 0% | 29.1 | 878.9 | 0% | 19 |
| Volto sulla parete | `volto_sulla_parete` | casuale | 0% | 61% | 39% | 56.6 | 869.2 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | si_cura | 70% | 30% | 0% | 39.8 | 772.6 | 0% | 102 |
| Volto sulla parete | `volto_sulla_parete` | speciali | 99% | 1% | 0% | 22.6 | 681.5 | 0% | 144 |
| Zombie Cittadino | `zombie_cittadino` | attacca | 99% | 0% | 1% | 29.5 | 242.7 | 0% | 32 |
| Zombie Cittadino | `zombie_cittadino` | difendi | 0% | 0% | 100% | 60.0 | 85.8 | 0% | 0 |
| Zombie Cittadino | `zombie_cittadino` | studia | 98% | 0% | 2% | 35.4 | 286.2 | 0% | 31 |
| Zombie Cittadino | `zombie_cittadino` | casuale | 28% | 0% | 72% | 53.6 | 79.0 | 0% | 9 |
| Zombie Cittadino | `zombie_cittadino` | si_cura | 99% | 0% | 1% | 29.5 | 237.1 | 0% | 32 |
| Zombie Cittadino | `zombie_cittadino` | speciali | 99% | 0% | 1% | 25.7 | 207.2 | 0% | 32 |
| Zombie Mostruoso | `zombie_mostruoso` | attacca | 100% | 0% | 0% | 5.7 | 56.8 | 0% | 32 |
| Zombie Mostruoso | `zombie_mostruoso` | difendi | 0% | 0% | 100% | 60.0 | 73.3 | 0% | 0 |
| Zombie Mostruoso | `zombie_mostruoso` | studia | 100% | 0% | 0% | 8.7 | 91.0 | 0% | 32 |
| Zombie Mostruoso | `zombie_mostruoso` | casuale | 100% | 0% | 0% | 17.3 | 73.9 | 0% | 32 |
| Zombie Mostruoso | `zombie_mostruoso` | si_cura | 100% | 0% | 0% | 5.7 | 56.8 | 0% | 32 |
| Zombie Mostruoso | `zombie_mostruoso` | speciali | 100% | 0% | 0% | 5.7 | 53.3 | 0% | 32 |

## Protagonista di livello 25

| creatura | id | come si gioca | vinte | perse | ∞ | giri | danno | risp. | xp |
|---|---|---|--:|--:|--:|--:|--:|--:|--:|
| Abominio Marcio | `abominio_marcio` | attacca | 100% | 0% | 0% | 18.4 | 735.3 | 0% | 101 |
| Abominio Marcio | `abominio_marcio` | difendi | 0% | 21% | 79% | 59.5 | 1138.6 | 0% | 0 |
| Abominio Marcio | `abominio_marcio` | studia | 99% | 1% | 0% | 22.1 | 895.2 | 0% | 100 |
| Abominio Marcio | `abominio_marcio` | casuale | 3% | 46% | 51% | 57.2 | 1178.6 | 0% | 3 |
| Abominio Marcio | `abominio_marcio` | si_cura | 100% | 0% | 0% | 19.7 | 558.3 | 0% | 101 |
| Abominio Marcio | `abominio_marcio` | speciali | 100% | 0% | 0% | 14.9 | 568.2 | 0% | 101 |
| Oppresso | `comparsa_di_ruggine` | attacca | 98% | 0% | 2% | 15.1 | 77.7 | 0% | 54 |
| Oppresso | `comparsa_di_ruggine` | difendi | 0% | 0% | 100% | 60.0 | 27.1 | 0% | 0 |
| Oppresso | `comparsa_di_ruggine` | studia | 95% | 0% | 5% | 20.6 | 106.9 | 0% | 52 |
| Oppresso | `comparsa_di_ruggine` | casuale | 33% | 0% | 67% | 52.2 | 36.4 | 0% | 18 |
| Oppresso | `comparsa_di_ruggine` | si_cura | 98% | 0% | 2% | 15.1 | 77.7 | 0% | 54 |
| Oppresso | `comparsa_di_ruggine` | speciali | 100% | 0% | 0% | 12.1 | 59.2 | 0% | 55 |
| Diabolo | `diabolo` | attacca | 100% | 0% | 0% | 7.7 | 114.3 | 0% | 46 |
| Diabolo | `diabolo` | difendi | 18% | 0% | 82% | 56.5 | 83.5 | 0% | 9 |
| Diabolo | `diabolo` | studia | 100% | 0% | 0% | 10.6 | 154.5 | 0% | 46 |
| Diabolo | `diabolo` | casuale | 100% | 0% | 0% | 20.0 | 70.6 | 0% | 46 |
| Diabolo | `diabolo` | si_cura | 100% | 0% | 0% | 7.7 | 114.3 | 0% | 46 |
| Diabolo | `diabolo` | speciali | 100% | 0% | 0% | 7.5 | 107.5 | 0% | 46 |
| Il Divoratore | `divoratore` | attacca | 100% | 0% | 0% | 22.2 | 518.8 | 0% | 101 |
| Il Divoratore | `divoratore` | difendi | 0% | 0% | 100% | 60.0 | 162.4 | 0% | 0 |
| Il Divoratore | `divoratore` | studia | 100% | 0% | 0% | 26.3 | 634.8 | 0% | 101 |
| Il Divoratore | `divoratore` | casuale | 31% | 0% | 69% | 57.5 | 256.4 | 0% | 34 |
| Il Divoratore | `divoratore` | si_cura | 100% | 0% | 0% | 22.4 | 509.0 | 0% | 101 |
| Il Divoratore | `divoratore` | speciali | 100% | 0% | 0% | 20.0 | 454.0 | 0% | 101 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | attacca | 100% | 0% | 0% | 7.6 | 83.5 | 0% | 46 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | difendi | 0% | 0% | 100% | 60.0 | 84.5 | 0% | 0 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | studia | 100% | 0% | 0% | 10.3 | 112.7 | 0% | 46 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | casuale | 99% | 0% | 1% | 26.2 | 68.1 | 0% | 46 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | si_cura | 100% | 0% | 0% | 7.6 | 83.5 | 0% | 46 |
| Divoratore di Carcasse | `divoratore_di_carcasse` | speciali | 100% | 0% | 0% | 6.3 | 58.0 | 0% | 46 |
| Donna Spinosa | `donna_spinosa` | attacca | 100% | 0% | 0% | 6.9 | 172.5 | 0% | 46 |
| Donna Spinosa | `donna_spinosa` | difendi | 0% | 0% | 100% | 60.0 | 1104.0 | 0% | 0 |
| Donna Spinosa | `donna_spinosa` | studia | 100% | 0% | 0% | 10.3 | 282.7 | 0% | 46 |
| Donna Spinosa | `donna_spinosa` | casuale | 100% | 0% | 0% | 22.9 | 431.9 | 0% | 46 |
| Donna Spinosa | `donna_spinosa` | si_cura | 100% | 0% | 0% | 8.1 | 158.8 | 0% | 46 |
| Donna Spinosa | `donna_spinosa` | speciali | 100% | 0% | 0% | 6.6 | 149.8 | 0% | 46 |
| Rottami Erranti | `ferraglia_urlante` | attacca | 100% | 0% | 0% | 28.2 | 315.8 | 0% | 91 |
| Rottami Erranti | `ferraglia_urlante` | difendi | 0% | 0% | 100% | 60.0 | 38.6 | 0% | 0 |
| Rottami Erranti | `ferraglia_urlante` | studia | 100% | 0% | 0% | 32.0 | 358.7 | 0% | 88 |
| Rottami Erranti | `ferraglia_urlante` | casuale | 3% | 0% | 97% | 59.7 | 114.7 | 0% | 3 |
| Rottami Erranti | `ferraglia_urlante` | si_cura | 100% | 0% | 0% | 28.2 | 315.8 | 0% | 91 |
| Rottami Erranti | `ferraglia_urlante` | speciali | 100% | 0% | 0% | 17.3 | 55.6 | 0% | 57 |
| Ghoul | `ghoul` | attacca | 100% | 0% | 0% | 6.6 | 120.0 | 0% | 46 |
| Ghoul | `ghoul` | difendi | 0% | 0% | 100% | 60.0 | 115.7 | 0% | 0 |
| Ghoul | `ghoul` | studia | 100% | 0% | 0% | 9.5 | 171.6 | 0% | 46 |
| Ghoul | `ghoul` | casuale | 100% | 0% | 0% | 20.2 | 116.1 | 0% | 46 |
| Ghoul | `ghoul` | si_cura | 100% | 0% | 0% | 6.6 | 120.0 | 0% | 46 |
| Ghoul | `ghoul` | speciali | 100% | 0% | 0% | 6.1 | 90.9 | 0% | 46 |
| El Muy Bonito | `giocoliere` | attacca | 100% | 0% | 0% | 10.6 | 286.9 | 0% | 101 |
| El Muy Bonito | `giocoliere` | difendi | 0% | 0% | 100% | 60.0 | 157.2 | 0% | 0 |
| El Muy Bonito | `giocoliere` | studia | 100% | 0% | 0% | 13.5 | 560.8 | 0% | 101 |
| El Muy Bonito | `giocoliere` | casuale | 83% | 17% | 0% | 29.6 | 732.3 | 0% | 83 |
| El Muy Bonito | `giocoliere` | si_cura | 100% | 0% | 0% | 10.6 | 286.9 | 0% | 101 |
| El Muy Bonito | `giocoliere` | speciali | 100% | 0% | 0% | 9.9 | 257.6 | 0% | 101 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | attacca | 100% | 0% | 0% | 12.7 | 53.3 | 0% | 672 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | difendi | 0% | 0% | 100% | 60.0 | 32.2 | 0% | 0 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | studia | 100% | 0% | 0% | 16.2 | 60.6 | 0% | 669 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | casuale | 75% | 0% | 25% | 44.3 | 48.0 | 0% | 528 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | si_cura | 100% | 0% | 0% | 12.7 | 53.3 | 0% | 672 |
| Un goblin terribilmente arrabbiato | `goblin_arrabbiato` | speciali | 100% | 0% | 0% | 11.4 | 31.1 | 0% | 666 |
| Goblin Possessivo | `goblin_possessivo` | attacca | 100% | 0% | 0% | 6.6 | 52.3 | 0% | 46 |
| Goblin Possessivo | `goblin_possessivo` | difendi | 0% | 0% | 100% | 60.0 | 103.9 | 0% | 0 |
| Goblin Possessivo | `goblin_possessivo` | studia | 100% | 0% | 0% | 9.6 | 104.4 | 0% | 46 |
| Goblin Possessivo | `goblin_possessivo` | casuale | 100% | 0% | 0% | 20.2 | 79.9 | 0% | 46 |
| Goblin Possessivo | `goblin_possessivo` | si_cura | 100% | 0% | 0% | 6.6 | 52.3 | 0% | 46 |
| Goblin Possessivo | `goblin_possessivo` | speciali | 100% | 0% | 0% | 6.0 | 75.1 | 0% | 46 |
| Goblin Tipico | `goblin_tipico` | attacca | 100% | 0% | 0% | 6.6 | 52.3 | 0% | 46 |
| Goblin Tipico | `goblin_tipico` | difendi | 0% | 0% | 100% | 60.0 | 103.9 | 0% | 0 |
| Goblin Tipico | `goblin_tipico` | studia | 100% | 0% | 0% | 9.6 | 104.4 | 0% | 46 |
| Goblin Tipico | `goblin_tipico` | casuale | 100% | 0% | 0% | 20.2 | 79.9 | 0% | 46 |
| Goblin Tipico | `goblin_tipico` | si_cura | 100% | 0% | 0% | 6.6 | 52.3 | 0% | 46 |
| Goblin Tipico | `goblin_tipico` | speciali | 100% | 0% | 0% | 6.0 | 75.1 | 0% | 46 |
| Golem errante di rottami | `golem_errante` | attacca | 100% | 0% | 0% | 13.7 | 330.6 | 0% | 101 |
| Golem errante di rottami | `golem_errante` | difendi | 0% | 0% | 100% | 60.0 | 156.3 | 0% | 0 |
| Golem errante di rottami | `golem_errante` | studia | 100% | 0% | 0% | 16.5 | 397.3 | 0% | 101 |
| Golem errante di rottami | `golem_errante` | casuale | 39% | 0% | 61% | 56.2 | 271.9 | 0% | 44 |
| Golem errante di rottami | `golem_errante` | si_cura | 100% | 0% | 0% | 13.7 | 330.6 | 0% | 101 |
| Golem errante di rottami | `golem_errante` | speciali | 100% | 0% | 0% | 12.2 | 279.0 | 0% | 101 |
| Infetto Rapido | `infetto_rapido` | attacca | 100% | 0% | 0% | 3.9 | 64.8 | 0% | 51 |
| Infetto Rapido | `infetto_rapido` | difendi | 0% | 0% | 100% | 60.0 | 124.6 | 0% | 0 |
| Infetto Rapido | `infetto_rapido` | studia | 100% | 0% | 0% | 7.0 | 106.7 | 0% | 51 |
| Infetto Rapido | `infetto_rapido` | casuale | 100% | 0% | 0% | 12.1 | 72.8 | 0% | 51 |
| Infetto Rapido | `infetto_rapido` | si_cura | 100% | 0% | 0% | 3.9 | 64.8 | 0% | 51 |
| Infetto Rapido | `infetto_rapido` | speciali | 100% | 0% | 0% | 4.4 | 64.1 | 0% | 51 |
| L'ultimo spettacolo di Jerah | `jerah` | attacca | 0% | 100% | 0% | 17.5 | 1220.0 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | difendi | 0% | 82% | 18% | 36.3 | 1171.7 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | studia | 5% | 95% | 0% | 19.6 | 1210.9 | 0% | 35 |
| L'ultimo spettacolo di Jerah | `jerah` | casuale | 0% | 77% | 23% | 39.0 | 1161.8 | 0% | 0 |
| L'ultimo spettacolo di Jerah | `jerah` | si_cura | 1% | 99% | 0% | 22.7 | 1219.8 | 0% | 4 |
| L'ultimo spettacolo di Jerah | `jerah` | speciali | 2% | 98% | 0% | 17.6 | 1217.6 | 0% | 14 |
| Jongo Dongo | `jongo_dongo` | attacca | 0% | 100% | 0% | 25.3 | 1220.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | difendi | 0% | 63% | 37% | 55.8 | 1170.3 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | studia | 1% | 99% | 0% | 26.2 | 1219.9 | 0% | 6 |
| Jongo Dongo | `jongo_dongo` | casuale | 0% | 89% | 11% | 49.0 | 1206.2 | 0% | 0 |
| Jongo Dongo | `jongo_dongo` | si_cura | 9% | 91% | 0% | 36.0 | 1203.8 | 0% | 74 |
| Jongo Dongo | `jongo_dongo` | speciali | 6% | 94% | 0% | 24.2 | 1206.5 | 0% | 49 |
| Jongo Dongo | `jongo_dongo_risorto` | attacca | 0% | 100% | 0% | 23.7 | 1220.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | difendi | 0% | 0% | 100% | 60.0 | 609.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | studia | 0% | 100% | 0% | 23.4 | 1220.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | casuale | 0% | 10% | 90% | 58.6 | 879.2 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | si_cura | 0% | 100% | 0% | 31.1 | 1220.0 | 0% | 0 |
| Jongo Dongo | `jongo_dongo_risorto` | speciali | 1% | 99% | 0% | 24.1 | 1219.7 | 0% | 9 |
| ??? | `l_immortale` | attacca | 0% | 0% | 100% | 60.0 | 24.0 | 0% | 0 |
| ??? | `l_immortale` | difendi | 0% | 0% | 100% | 60.0 | 24.0 | 0% | 0 |
| ??? | `l_immortale` | studia | 0% | 0% | 100% | 60.0 | 24.0 | 0% | 0 |
| ??? | `l_immortale` | casuale | 0% | 0% | 100% | 60.0 | 24.0 | 0% | 0 |
| ??? | `l_immortale` | si_cura | 0% | 0% | 100% | 60.0 | 24.0 | 0% | 0 |
| ??? | `l_immortale` | speciali | 0% | 0% | 100% | 60.0 | 24.0 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | attacca | 100% | 0% | 0% | 6.6 | 113.4 | 0% | 46 |
| Madre in Lacrime | `madre_in_lacrime` | difendi | 0% | 0% | 100% | 60.0 | 132.9 | 0% | 0 |
| Madre in Lacrime | `madre_in_lacrime` | studia | 100% | 0% | 0% | 9.5 | 158.6 | 0% | 46 |
| Madre in Lacrime | `madre_in_lacrime` | casuale | 100% | 0% | 0% | 20.2 | 107.7 | 0% | 46 |
| Madre in Lacrime | `madre_in_lacrime` | si_cura | 100% | 0% | 0% | 6.6 | 113.4 | 0% | 46 |
| Madre in Lacrime | `madre_in_lacrime` | speciali | 100% | 0% | 0% | 6.0 | 85.3 | 0% | 46 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | attacca | 0% | 100% | 0% | 14.0 | 1220.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | difendi | 0% | 100% | 0% | 14.0 | 1220.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | studia | 0% | 100% | 0% | 14.0 | 1220.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | casuale | 0% | 100% | 0% | 14.0 | 1220.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | si_cura | 0% | 100% | 0% | 14.0 | 1220.0 | 0% | 0 |
| Manifestazione di un sogno | `manifestazione_di_un_sogno` | speciali | 0% | 100% | 0% | 14.0 | 1220.0 | 0% | 0 |
| Marionetta | `marionetta` | attacca | 100% | 0% | 0% | 7.5 | 99.7 | 0% | 46 |
| Marionetta | `marionetta` | difendi | 0% | 0% | 100% | 60.0 | 110.8 | 0% | 0 |
| Marionetta | `marionetta` | studia | 100% | 0% | 0% | 10.4 | 150.2 | 0% | 46 |
| Marionetta | `marionetta` | casuale | 99% | 0% | 1% | 24.9 | 105.1 | 0% | 46 |
| Marionetta | `marionetta` | si_cura | 100% | 0% | 0% | 7.5 | 99.7 | 0% | 46 |
| Marionetta | `marionetta` | speciali | 100% | 0% | 0% | 6.5 | 76.2 | 0% | 46 |
| Fomentado | `maschera_vuota` | attacca | 100% | 0% | 0% | 4.8 | 141.1 | 0% | 46 |
| Fomentado | `maschera_vuota` | difendi | 0% | 0% | 100% | 60.0 | 96.2 | 0% | 0 |
| Fomentado | `maschera_vuota` | studia | 100% | 0% | 0% | 7.8 | 188.8 | 0% | 46 |
| Fomentado | `maschera_vuota` | casuale | 100% | 0% | 0% | 12.6 | 132.9 | 0% | 46 |
| Fomentado | `maschera_vuota` | si_cura | 100% | 0% | 0% | 4.8 | 141.1 | 0% | 46 |
| Fomentado | `maschera_vuota` | speciali | 100% | 0% | 0% | 5.1 | 133.5 | 0% | 46 |
| Nimbo Boy | `nimbo_boy` | attacca | 100% | 0% | 0% | 11.0 | 0.0 | 0% | 46 |
| Nimbo Boy | `nimbo_boy` | difendi | 0% | 0% | 100% | 60.0 | 0.0 | 0% | 0 |
| Nimbo Boy | `nimbo_boy` | studia | 100% | 0% | 0% | 14.0 | 0.0 | 0% | 46 |
| Nimbo Boy | `nimbo_boy` | casuale | 99% | 0% | 1% | 32.8 | 0.0 | 0% | 46 |
| Nimbo Boy | `nimbo_boy` | si_cura | 100% | 0% | 0% | 11.0 | 0.0 | 0% | 46 |
| Nimbo Boy | `nimbo_boy` | speciali | 100% | 0% | 0% | 11.3 | 0.0 | 0% | 46 |
| Nuvola di Marciume | `nuvola_di_marciume` | attacca | 100% | 0% | 0% | 4.6 | 109.2 | 0% | 51 |
| Nuvola di Marciume | `nuvola_di_marciume` | difendi | 0% | 0% | 100% | 60.0 | 1127.5 | 0% | 0 |
| Nuvola di Marciume | `nuvola_di_marciume` | studia | 100% | 0% | 0% | 7.7 | 196.2 | 0% | 51 |
| Nuvola di Marciume | `nuvola_di_marciume` | casuale | 100% | 0% | 0% | 14.3 | 264.7 | 0% | 51 |
| Nuvola di Marciume | `nuvola_di_marciume` | si_cura | 100% | 0% | 0% | 4.8 | 76.9 | 0% | 51 |
| Nuvola di Marciume | `nuvola_di_marciume` | speciali | 100% | 0% | 0% | 5.4 | 125.1 | 0% | 51 |
| Ombra del passato | `ombra_del_passato` | attacca | 100% | 0% | 0% | 6.6 | 119.3 | 0% | 46 |
| Ombra del passato | `ombra_del_passato` | difendi | 0% | 0% | 100% | 60.0 | 115.5 | 0% | 0 |
| Ombra del passato | `ombra_del_passato` | studia | 100% | 0% | 0% | 9.6 | 177.3 | 0% | 46 |
| Ombra del passato | `ombra_del_passato` | casuale | 100% | 0% | 0% | 21.0 | 126.5 | 0% | 46 |
| Ombra del passato | `ombra_del_passato` | si_cura | 100% | 0% | 0% | 6.6 | 119.3 | 0% | 46 |
| Ombra del passato | `ombra_del_passato` | speciali | 100% | 0% | 0% | 6.0 | 92.0 | 0% | 46 |
| Emblema dell'oppressione | `operaio_posseduto` | attacca | 100% | 0% | 0% | 6.8 | 40.0 | 0% | 46 |
| Emblema dell'oppressione | `operaio_posseduto` | difendi | 0% | 0% | 100% | 60.0 | 128.9 | 0% | 0 |
| Emblema dell'oppressione | `operaio_posseduto` | studia | 100% | 0% | 0% | 9.8 | 59.6 | 0% | 46 |
| Emblema dell'oppressione | `operaio_posseduto` | casuale | 98% | 0% | 2% | 24.3 | 155.3 | 0% | 45 |
| Emblema dell'oppressione | `operaio_posseduto` | si_cura | 100% | 0% | 0% | 6.8 | 40.0 | 0% | 46 |
| Emblema dell'oppressione | `operaio_posseduto` | speciali | 100% | 0% | 0% | 6.5 | 35.8 | 0% | 46 |
| Operaio Sfruttato | `operaio_sfruttato` | attacca | 100% | 0% | 0% | 12.3 | 325.4 | 0% | 101 |
| Operaio Sfruttato | `operaio_sfruttato` | difendi | 0% | 0% | 100% | 60.0 | 102.7 | 0% | 0 |
| Operaio Sfruttato | `operaio_sfruttato` | studia | 100% | 0% | 0% | 16.5 | 417.9 | 0% | 101 |
| Operaio Sfruttato | `operaio_sfruttato` | casuale | 33% | 0% | 67% | 53.1 | 372.6 | 0% | 34 |
| Operaio Sfruttato | `operaio_sfruttato` | si_cura | 100% | 0% | 0% | 12.3 | 325.4 | 0% | 101 |
| Operaio Sfruttato | `operaio_sfruttato` | speciali | 100% | 0% | 0% | 11.1 | 258.6 | 0% | 101 |
| Orrore di Meridia | `orrore_di_meridia` | attacca | 94% | 6% | 0% | 23.1 | 1188.4 | 0% | 95 |
| Orrore di Meridia | `orrore_di_meridia` | difendi | 0% | 0% | 100% | 60.0 | 113.6 | 0% | 0 |
| Orrore di Meridia | `orrore_di_meridia` | studia | 97% | 3% | 0% | 26.2 | 949.7 | 0% | 98 |
| Orrore di Meridia | `orrore_di_meridia` | casuale | 9% | 10% | 81% | 58.5 | 867.1 | 0% | 9 |
| Orrore di Meridia | `orrore_di_meridia` | si_cura | 81% | 19% | 0% | 26.6 | 1107.9 | 0% | 82 |
| Orrore di Meridia | `orrore_di_meridia` | speciali | 99% | 1% | 0% | 20.8 | 939.1 | 0% | 100 |
| Rana Folle | `rana_folle` | attacca | 100% | 0% | 0% | 4.8 | 3.0 | 0% | 46 |
| Rana Folle | `rana_folle` | difendi | 0% | 0% | 100% | 60.0 | 81.4 | 0% | 0 |
| Rana Folle | `rana_folle` | studia | 100% | 0% | 0% | 7.8 | 9.0 | 0% | 46 |
| Rana Folle | `rana_folle` | casuale | 100% | 0% | 0% | 14.8 | 7.9 | 0% | 46 |
| Rana Folle | `rana_folle` | si_cura | 100% | 0% | 0% | 4.8 | 3.0 | 0% | 46 |
| Rana Folle | `rana_folle` | speciali | 100% | 0% | 0% | 4.4 | 2.6 | 0% | 46 |
| Robo Pattuglia | `robo_pattuglia` | attacca | 97% | 0% | 3% | 16.8 | 94.8 | 0% | 53 |
| Robo Pattuglia | `robo_pattuglia` | difendi | 0% | 0% | 100% | 60.0 | 36.4 | 0% | 0 |
| Robo Pattuglia | `robo_pattuglia` | studia | 93% | 0% | 7% | 23.4 | 141.4 | 0% | 51 |
| Robo Pattuglia | `robo_pattuglia` | casuale | 23% | 0% | 77% | 54.7 | 49.8 | 0% | 13 |
| Robo Pattuglia | `robo_pattuglia` | si_cura | 97% | 0% | 3% | 16.8 | 94.8 | 0% | 53 |
| Robo Pattuglia | `robo_pattuglia` | speciali | 100% | 0% | 0% | 13.1 | 70.9 | 0% | 55 |
| Sacerdote Folle | `sacerdote_folle` | attacca | 100% | 0% | 0% | 10.8 | 172.8 | 0% | 69 |
| Sacerdote Folle | `sacerdote_folle` | difendi | 0% | 0% | 100% | 60.0 | 330.5 | 0% | 0 |
| Sacerdote Folle | `sacerdote_folle` | studia | 100% | 0% | 0% | 17.5 | 317.2 | 0% | 79 |
| Sacerdote Folle | `sacerdote_folle` | casuale | 30% | 0% | 70% | 52.6 | 336.4 | 0% | 27 |
| Sacerdote Folle | `sacerdote_folle` | si_cura | 100% | 0% | 0% | 10.8 | 172.8 | 0% | 69 |
| Sacerdote Folle | `sacerdote_folle` | speciali | 100% | 0% | 0% | 8.3 | 118.1 | 0% | 64 |
| Sadico | `sadico` | attacca | 100% | 0% | 0% | 6.9 | 179.3 | 0% | 46 |
| Sadico | `sadico` | difendi | 0% | 6% | 94% | 59.9 | 1121.2 | 0% | 0 |
| Sadico | `sadico` | studia | 100% | 0% | 0% | 10.2 | 282.8 | 0% | 46 |
| Sadico | `sadico` | casuale | 100% | 0% | 0% | 21.9 | 415.3 | 0% | 46 |
| Sadico | `sadico` | si_cura | 100% | 0% | 0% | 8.1 | 166.8 | 0% | 46 |
| Sadico | `sadico` | speciali | 100% | 0% | 0% | 6.6 | 157.6 | 0% | 46 |
| Slime Infimo | `slime_infimo` | attacca | 100% | 0% | 0% | 7.5 | 103.0 | 0% | 46 |
| Slime Infimo | `slime_infimo` | difendi | 0% | 0% | 100% | 60.0 | 102.7 | 0% | 0 |
| Slime Infimo | `slime_infimo` | studia | 100% | 0% | 0% | 10.5 | 145.3 | 0% | 46 |
| Slime Infimo | `slime_infimo` | casuale | 99% | 0% | 1% | 29.6 | 91.4 | 0% | 46 |
| Slime Infimo | `slime_infimo` | si_cura | 100% | 0% | 0% | 7.5 | 103.0 | 0% | 46 |
| Slime Infimo | `slime_infimo` | speciali | 100% | 0% | 0% | 6.5 | 74.4 | 0% | 46 |
| Sogno perduto | `sogno_perduto` | attacca | 100% | 0% | 0% | 1.0 | 0.0 | 0% | 46 |
| Sogno perduto | `sogno_perduto` | difendi | 0% | 0% | 100% | 60.0 | 24.2 | 0% | 0 |
| Sogno perduto | `sogno_perduto` | studia | 100% | 0% | 0% | 4.0 | 1.4 | 0% | 46 |
| Sogno perduto | `sogno_perduto` | casuale | 100% | 0% | 0% | 3.2 | 1.4 | 0% | 46 |
| Sogno perduto | `sogno_perduto` | si_cura | 100% | 0% | 0% | 1.0 | 0.0 | 0% | 46 |
| Sogno perduto | `sogno_perduto` | speciali | 100% | 0% | 0% | 1.0 | 0.0 | 0% | 46 |
| Stigma | `stigma` | attacca | 100% | 0% | 0% | 6.8 | 139.5 | 0% | 46 |
| Stigma | `stigma` | difendi | 0% | 1% | 99% | 60.0 | 1037.4 | 0% | 0 |
| Stigma | `stigma` | studia | 100% | 0% | 0% | 9.9 | 230.6 | 0% | 46 |
| Stigma | `stigma` | casuale | 100% | 0% | 0% | 20.7 | 324.3 | 0% | 46 |
| Stigma | `stigma` | si_cura | 100% | 0% | 0% | 7.1 | 131.9 | 0% | 46 |
| Stigma | `stigma` | speciali | 100% | 0% | 0% | 6.4 | 119.3 | 0% | 46 |
| Tartaruga Gigante | `tartaruga_innocente` | attacca | 100% | 0% | 0% | 3.9 | 0.0 | 0% | 1 |
| Tartaruga Gigante | `tartaruga_innocente` | difendi | 0% | 0% | 100% | 60.0 | 0.0 | 0% | 0 |
| Tartaruga Gigante | `tartaruga_innocente` | studia | 100% | 0% | 0% | 2.0 | 0.0 | 100% | 1 |
| Tartaruga Gigante | `tartaruga_innocente` | casuale | 82% | 0% | 18% | 21.4 | 0.0 | 0% | 1 |
| Tartaruga Gigante | `tartaruga_innocente` | si_cura | 100% | 0% | 0% | 3.9 | 0.0 | 0% | 1 |
| Tartaruga Gigante | `tartaruga_innocente` | speciali | 100% | 0% | 0% | 4.4 | 0.0 | 0% | 1 |
| Un tenero ricordo | `tenero_ricordo` | attacca | 0% | 100% | 0% | 24.4 | 1220.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | difendi | 0% | 100% | 0% | 26.3 | 1220.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | studia | 0% | 100% | 0% | 25.7 | 1220.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | casuale | 0% | 100% | 0% | 27.2 | 1220.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | si_cura | 0% | 100% | 0% | 25.5 | 1220.0 | 0% | 0 |
| Un tenero ricordo | `tenero_ricordo` | speciali | 0% | 100% | 0% | 24.6 | 1220.0 | 0% | 0 |
| Teschio Errante | `teschio_errante` | attacca | 100% | 0% | 0% | 6.7 | 78.6 | 0% | 46 |
| Teschio Errante | `teschio_errante` | difendi | 0% | 0% | 100% | 60.0 | 107.1 | 0% | 0 |
| Teschio Errante | `teschio_errante` | studia | 100% | 0% | 0% | 9.5 | 118.4 | 0% | 46 |
| Teschio Errante | `teschio_errante` | casuale | 100% | 0% | 0% | 21.0 | 76.3 | 0% | 46 |
| Teschio Errante | `teschio_errante` | si_cura | 100% | 0% | 0% | 6.7 | 78.6 | 0% | 46 |
| Teschio Errante | `teschio_errante` | speciali | 100% | 0% | 0% | 6.3 | 69.6 | 0% | 46 |
| Titano Zombie | `titano_zombie` | attacca | 100% | 0% | 0% | 16.4 | 872.6 | 0% | 101 |
| Titano Zombie | `titano_zombie` | difendi | 0% | 99% | 1% | 34.2 | 1219.7 | 0% | 0 |
| Titano Zombie | `titano_zombie` | studia | 100% | 0% | 0% | 19.7 | 993.1 | 0% | 101 |
| Titano Zombie | `titano_zombie` | casuale | 4% | 96% | 0% | 37.9 | 1217.1 | 0% | 4 |
| Titano Zombie | `titano_zombie` | si_cura | 100% | 0% | 0% | 21.8 | 891.9 | 0% | 101 |
| Titano Zombie | `titano_zombie` | speciali | 100% | 0% | 0% | 15.4 | 829.8 | 0% | 101 |
| Capocantiere | `voce_registrata` | attacca | 100% | 0% | 0% | 6.6 | 99.0 | 0% | 46 |
| Capocantiere | `voce_registrata` | difendi | 0% | 0% | 100% | 60.0 | 92.6 | 0% | 0 |
| Capocantiere | `voce_registrata` | studia | 100% | 0% | 0% | 9.5 | 148.9 | 0% | 46 |
| Capocantiere | `voce_registrata` | casuale | 100% | 0% | 0% | 19.8 | 91.7 | 0% | 46 |
| Capocantiere | `voce_registrata` | si_cura | 100% | 0% | 0% | 6.6 | 99.0 | 0% | 46 |
| Capocantiere | `voce_registrata` | speciali | 100% | 0% | 0% | 6.3 | 86.3 | 0% | 46 |
| Volto sulla parete | `volto_sulla_parete` | attacca | 1% | 99% | 0% | 28.0 | 1217.7 | 0% | 1 |
| Volto sulla parete | `volto_sulla_parete` | difendi | 0% | 29% | 71% | 59.2 | 1161.0 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | studia | 0% | 100% | 0% | 28.2 | 1220.0 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | casuale | 0% | 69% | 31% | 55.1 | 1199.7 | 0% | 0 |
| Volto sulla parete | `volto_sulla_parete` | si_cura | 5% | 95% | 0% | 39.5 | 1214.6 | 0% | 10 |
| Volto sulla parete | `volto_sulla_parete` | speciali | 86% | 14% | 0% | 24.3 | 1070.4 | 0% | 178 |
| Zombie Cittadino | `zombie_cittadino` | attacca | 99% | 0% | 1% | 30.9 | 401.4 | 0% | 45 |
| Zombie Cittadino | `zombie_cittadino` | difendi | 0% | 0% | 100% | 60.0 | 100.4 | 0% | 0 |
| Zombie Cittadino | `zombie_cittadino` | studia | 93% | 0% | 7% | 36.6 | 451.2 | 0% | 44 |
| Zombie Cittadino | `zombie_cittadino` | casuale | 25% | 0% | 75% | 55.0 | 110.1 | 0% | 11 |
| Zombie Cittadino | `zombie_cittadino` | si_cura | 96% | 0% | 4% | 31.0 | 375.8 | 0% | 44 |
| Zombie Cittadino | `zombie_cittadino` | speciali | 98% | 0% | 2% | 27.3 | 349.7 | 0% | 45 |
| Zombie Mostruoso | `zombie_mostruoso` | attacca | 100% | 0% | 0% | 6.6 | 106.0 | 0% | 46 |
| Zombie Mostruoso | `zombie_mostruoso` | difendi | 0% | 0% | 100% | 60.0 | 100.2 | 0% | 0 |
| Zombie Mostruoso | `zombie_mostruoso` | studia | 100% | 0% | 0% | 9.5 | 153.0 | 0% | 46 |
| Zombie Mostruoso | `zombie_mostruoso` | casuale | 100% | 0% | 0% | 20.0 | 114.1 | 0% | 46 |
| Zombie Mostruoso | `zombie_mostruoso` | si_cura | 100% | 0% | 0% | 6.6 | 106.0 | 0% | 46 |
| Zombie Mostruoso | `zombie_mostruoso` | speciali | 100% | 0% | 0% | 6.3 | 93.5 | 0% | 46 |

