# Le mappe (generato, non scrivere qui a mano)

Rigenera con `python3 strumenti/genera_mappe.py`.

## Come e' fatta una mappa

Ogni **quadratino e' una scena**: un nodo del file di eventi, cioe' una
schermata con la sua descrizione, le sue scelte e i suoi agguati. Una zona e'
una figura composta da tanti quadratini, e la figura e' la mappa.

I quadratini si **illuminano man mano che esplori**: finche' non ci sei mai
arrivato, un quadratino non c'e'. Se e' il vicino ancora ignoto di un posto in
cui sei stato, si vede che c'e' qualcosa ma non cosa: e' il quadratino spento
al bordo della luce. Il gioco lo sa gia' fare — `nodi_visitati` tiene il conto
di dove sei stato, `stanza_sbloccata()` di cosa e' raggiungibile.

### La legenda

| segno | cosa vuol dire |
|---|---|
| quadrato **rosso pieno** | ci sei stato: percorso normale |
| quadrato **verde pieno** | ci sei stato: zona segreta (`tipo: "segreta"`) |
| quadrato con **`?`** acceso | lo sai raggiungibile e non ci sei mai andato. Cliccandolo ci vai |
| quadrato con **`?`** spento | sai solo che li' c'e' qualcosa, perche' confina con un posto in cui sei stato. Cliccandolo il gioco dice perche' non si passa ancora |
| **niente** | non ne sai nemmeno l'esistenza: la mappa si costruisce camminando |
| **freccia** | dove sei adesso |
| **cerchio** | il boss della zona |
| **punto pieno** | uno scontro duro: li' negli agguati puo' capitare qualcosa di molto piu' grosso |
| **✕** | il punto da cui si esce dalla zona |
| **cornice** | la porzione di mappa che stai guardando |

Le icone sono disegnate a mano dal codice finche' non arrivano i disegni veri.
Aggiungerne una vuol dire **aggiungere un file**, non toccare il codice: se
esiste `art/icone_mappa/<icona>.png` quello vince sul disegno provvisorio.

### Le stanze grandi

Una stanza grande **occupa piu' di un quadratino**: nei dati e' il campo
`dimensione` (larghezza x altezza in quadratini). Serve a far vedere che la
piazza sotterranea non e' larga come un ripostiglio: la mappa deve mentire il
meno possibile.

Due stanze non possono finire sullo stesso quadratino. Non e' una convenzione:
`prova_mappe` tiene il conto di ogni casella occupata, e allargare una stanza
sopra la vicina fa fallire le prove invece di produrre un quadrato che ne copre
un altro (con quello sotto diventato incliccabile, e nessun errore da nessuna
parte).

### I piani

Se una frattura (o un Carnivalz) ha piu' piani, **ogni piano ha la sua mappa**,
col suo titolo — «1° piano», «-2», «sotterranei». Si passa da una all'altra
dove il percorso sale o scende. Il primo caso vero e' il garage di Meridia:
quattro piani sotto la citta', ognuno una discesa in linea retta.

### La mappa totale

Piu' avanti uno dei personaggi sapra' **disegnare la mappa intera** di una
zona. Non la riempie: ne mostra i *contorni*. Vedi la forma completa della
figura e capisci che li', in un punto che non hai ancora battuto, c'e'
qualcosa — un'area segreta, una stanza che non hai aperto — senza sapere cosa
sia. E' il contrario dell'esplorazione automatica: ti dice **dove guardare**,
non cosa troverai.

## Cosa c'e' gia' e cosa manca

| pezzo | stato |
|---|---|
| una mappa per zona, coi collegamenti | ✅ `mappa_dungeon` nel file di eventi |
| i posti si illuminano esplorando | ✅ `nodi_visitati` / `stanza_sbloccata()` |
| **quadrati su griglia** invece di pallini e linee | ✅ campo `cella` |
| **stanze grandi** su piu' quadratini | ✅ campo `dimensione` |
| il **«?»** su quello che si intravede | ✅ e cliccandolo ci si va, se la storia l'ha aperto |
| zone segrete in verde | ✅ campo `tipo: "segreta"` — nessuna ancora marcata nei dati |
| icone (boss, scontro duro, uscita...) | ✅ campo `icona`, disegnate a mano finche' non arrivano i disegni: basta mettere `art/icone_mappa/<icona>.png` |
| cornice della vista | ✅ |
| zoom e trascinamento | ⬜ oggi la griglia si adatta da sola al riquadro |
| piu' piani per zona | ⬜ oggi la mappa e' una sola per file di eventi |
| eventi che compaiono sulla mappa dopo uno scontro | ⬜ |
| mappa totale a contorni | ⬜ (abilita' di un personaggio, piu' avanti) |

## Come si legge quello che segue

Per ogni zona ci sono due disegni della stessa cosa.

**La griglia** e' la mappa come la vede il giocatore: dove stanno le stanze una
rispetto all'altra. `▶` e' il punto di ingresso, `✕` l'uscita dalla zona, `◇` una
zona segreta. Una stanza grande occupa piu' caselle: le caselle in piu' portano
una freccia (`↑`, `←`) verso quella che ha il nome.

**Il percorso** e' la stessa zona ripercorsa dall'ingresso, per far vedere in
che ordine si apre. Ogni riga e' una scelta; l'indentazione e' la profondita'.
A destra, fra parentesi, cosa comporta:

- `oggetto` — quella scelta fa raccogliere qualcosa (una volta sola)
- `agguato NN%` — entrando li' si rischia uno scontro casuale
- `scontro!` — uno scontro scritto, che parte da solo
- `flag` — quella stanza alza un flag (di solito e' cosi' che si apre altro)
- `serve ...` — la scelta non compare finche' non hai quello che chiede
- `→ gia' visto` — porta a una stanza gia' incontrata piu' in alto (non si
  ripete il ramo)


---

# Introduzione

<sub>`data/events_intro.json` — 1 scene</sub>

*Questa zona non ha ancora una `mappa_dungeon`: si gioca solo a scelte.*

## Il percorso

```
monologo
```

---

# Pianure di Redenna (tutorial)

<sub>`data/events_tutorial.json` — 28 scene</sub>

## La griglia

| | | |
|:--:|:--:|:--:|
|   | **Verso le urla** |   |
| **Le pozze d'acqua** |   | **La collina** |
|   | **Il bivio** |   |
|   | **Il masso e il ruscello** |   |
|   | ▶ **Punto d'atterraggio** |   |

6 stanze sulla mappa, 6 collegamenti.

Non sulla mappa (scene di passaggio, scontri scritti, varianti «dopo»): `boss`, `collina_ritorno`, `collina_vuota`, `dopo_collina`, `dopo_pozze`, `dopo_primo_goblin`, `due_nemici`, `hq_congedo`, `hq_domanda_dominatori`, `hq_domanda_perche`, `hq_domanda_quando`, `hq_infermeria`, `hq_sala_riunioni_1`, `hq_sala_riunioni_2`, `hq_scontro_veronica`, `hq_training_grounds`, `hq_veronica_saluto`, `pozze_ripulite`, `primo_incontro`, `sconfitta`, `sconfitta_manifestazione`, `vittoria`.

## Il percorso

```
inizio
  · Fatti largo tra le pianure → primo_incontro   (scontro! goblin_tipico)
    ⟳ con tut_primo_goblin diventa dopo_primo_goblin
    dopo_primo_goblin   (flag tut_primo_goblin)
      · Continua per la tua strada → masso
        · Ispeziona l'acqua che luccica → due_nemici   (+fiala_hp, fiala_hp; scontro! goblin_tipico, slime_infimo)
          ⟳ con tut_radura_superata diventa bivio
          bivio   (flag tut_radura_superata)
            · Procedi verso le pozze d'acqua → pozze   (scontro! goblin_tipico, tartaruga_innocente)
              ⟳ con tut_pozze_fatte diventa pozze_ripulite
              pozze_ripulite
                · Attraversa gli arbusti → convergenza   (flag tut_strada_aperta)
                  · Scatta verso i rumori → boss   (scontro! goblin_arrabbiato)
                    vinci → vittoria
                      · Torna al quartier generale → hq_veronica_saluto
                        · Vai in sala riunioni → hq_sala_riunioni_1
                          · Vai ai campi di addestramento → hq_training_grounds
                            · Affronta l'allenamento → hq_scontro_veronica   (scontro! veronica)
                              vinci → hq_infermeria
                                · Vai in sala riunioni → hq_sala_riunioni_2
                                  · Come mai mi trovo qui? → hq_domanda_perche
                                    · Come mai mi trovo qui?
                                    · Cosa sono i dominatori in realtà? → hq_domanda_dominatori
                                      · Come mai mi trovo qui? → hq_domanda_perche [gia' visto]
                                      · Cosa sono i dominatori in realtà?
                                      · Da quanto tempo sta succedendo tutto questo? → hq_domanda_quando
                                        · Come mai mi trovo qui? → hq_domanda_perche [gia' visto]
                                        · Cosa sono i dominatori in realtà? → hq_domanda_dominatori [gia' visto]
                                        · Da quanto tempo sta succedendo tutto questo?
                                        · Nessuna domanda. Parto immediatamente. → hq_congedo   (flag tutorial_completato)
                                          · Torna alla mappa stellare
                                      · Nessuna domanda. Parto immediatamente. → hq_congedo [gia' visto]
                                    · Da quanto tempo sta succedendo tutto questo? → hq_domanda_quando [gia' visto]
                                    · Nessuna domanda. Parto immediatamente. → hq_congedo [gia' visto]
                                  · Cosa sono i dominatori in realtà? → hq_domanda_dominatori [gia' visto]
                                  · Da quanto tempo sta succedendo tutto questo? → hq_domanda_quando [gia' visto]
                                  · Nessuna domanda. Parto immediatamente. → hq_congedo [gia' visto]
                              perdi → hq_infermeria [gia' visto]
                    perdi → sconfitta
                      · Rialzati e ricomincia
                  · Torna alla collina → collina   (flag tut_collina_vista; scontro! manifestazione_di_un_sogno)
                    ⟳ con tut_collina_vista diventa collina_ritorno
                    collina_ritorno
                      ⟳ con tut_collina_fatta diventa collina_vuota
                      collina_vuota
                        · Attraversa gli arbusti → convergenza [gia' visto]
                        · Torna al bivio → bivio [gia' visto]
                      · Combatti   (solo se non tut_collina_fatta)
                      · Torna al bivio → bivio [gia' visto]
                    vinci → dopo_collina   (flag tut_collina_fatta)
                      · Attraversa gli arbusti → convergenza [gia' visto]
                      · Apri la mappa
                    perdi → sconfitta_manifestazione
                      · Rialzati e ricomincia
                    fuggi → bivio [gia' visto]
                  · Torna alle pozze → pozze [gia' visto]
                · Torna al bivio → bivio [gia' visto]
              vinci → dopo_pozze   (flag tut_pozze_fatte)
                · Oltrepassa gli arbusti → convergenza [gia' visto]
                · Apri la mappa
              perdi → sconfitta [gia' visto]
              fuggi → bivio [gia' visto]
            · Sali sulla collina → collina [gia' visto]
          vinci → bivio [gia' visto]
          perdi → sconfitta [gia' visto]
        · Prosegui senza fermarti → due_nemici [gia' visto]
    vinci → dopo_primo_goblin [gia' visto]
    perdi → sconfitta [gia' visto]
```

---

# Il Vuoto Ardente — campagna di Jerah

<sub>`data/events.json` — 26 scene</sub>

*Questa zona non ha ancora una `mappa_dungeon`: si gioca solo a scelte.*

## Il percorso

```
inizio
  · Taglia per le dune → bosco
    · Fruga tra i resti → sentiero_lanterne   (+razione_del_circo; +10 Tazo)
      · Seguile: che contino pure → radura
        · Affrontala
        · Aggirala nell'ombra, seguendo l'istinto → campo_giostre   (serve l'abilita' sesto_senso)
          · Scendi nel toril → tunnel
            · Prendi quello che serve → giostra_cavalli   (+petardo; +10 Tazo)
              · Ferma il meccanismo e recupera i Tazo incastrati → baraccone_premi   (+20 Tazo)
                · Gioca una partita (10 Tazo) → premio   (+-10 Tazo)
                  · Prendi il premio e va' verso il ruedo → proscenio   (+premio_di_pezza)
                    · Accendi un falò → falo
                      · Mangia qualcosa e lascia che il fuoco parli → falo_notte
                        · Il Vecchio Proprietario del teatro apre la mano: un bottone dorato, del primo abito di luci di Jerah → palco   (+bottone_dorato; serve vecchio_clown)
                          · Passa da lui
                          · Scardina la botola e passa sotto il tablao → backstage   (serve l'abilita' scasso)
                            · Vola fin lassù, tra le travi → segreto   (serve l'abilita' volo)
                              · Prendila e scendi nel ruedo → boss   (+medaglia_del_vecchio_circo)
                                · Estingui la fonte
                            · Arrampicati a mani nude, presa dopo presa → segreto [gia' visto]
                            · Scosta l'ultimo drappo → boss [gia' visto]
                        · Verso il ruedo → palco [gia' visto]
                      · Meglio non perdere tempo → palco [gia' visto]
                    · Avanti, senza fermarsi → palco [gia' visto]
                · I giochi truccati non ti fregano → proscenio [gia' visto]
              · Passa oltre, senza guardarli negli occhi → baraccone_premi [gia' visto]
            · Attraversa e basta → giostra_cavalli [gia' visto]
          · Entra nella sala degli specchi → specchi
            · Reggi lo sguardo e afferra la scheggia → giostra_cavalli [gia' visto]
            · Distogli lo sguardo e attraversa in fretta → giostra_cavalli [gia' visto]
          · Bussa al carro illuminato → carovana
            · Accetta la bevanda → carovana_si
              · Ascolta il suo racconto → carovana_racconto
                · Portalo con te fino al ruedo → giostra_cavalli [gia' visto]
                · È troppo pericoloso: lascialo alla sua veglia → giostra_cavalli [gia' visto]
            · Rifiuta, preferisci ascoltare → carovana_no
              · Ascolta il suo racconto → carovana_racconto [gia' visto]
      · Spegnile a una a una, e respira → radura [gia' visto]
    · Non toccare niente → sentiero_lanterne [gia' visto]
  · Segui l'arroyo secco → fiume
    · Raccogli la lanterna → riva   (+lanterna_che_pulsa)
      · Ispeziona il carico → sentiero_lanterne [gia' visto]
      · Prosegui lungo l'arroyo → sentiero_lanterne [gia' visto]
    · Lasciala dov'è → riva [gia' visto]
```

---

# Casa Gigante

<sub>`data/vuoti/casa_gigante.json` — 79 scene</sub>

## La griglia

| | | | | | | |
|:--:|:--:|:--:|:--:|:--:|:--:|:--:|
|   |   | **Camera da letto** |   |   |   |   |
| **L'altare** |   | **Attico** |   | **Deposito chimico** |   |   |
| **Il tunnel** |   | **Soffitta** |   | **Sala delle matrici** |   |   |
| **Stanza degli studi** | **Stanza dei giochi** | **La scala** | **Grande bagno** | **Il grande laboratorio** |   |   |
|   |   | **Sala principale** | **Cucina** | **Giardino ovest** |   |   |
|   | **Ala sinistra** | **Il salone** | **Ala destra** | **Il giardino** | **Giardino est** | **L'albero grande** |
|   |   | ↑ |   | ↑ |   |   |
|   |   | ▶ ✕ **La soglia** |   | **Verso i giardini** | **Giardino nord** | **Vivaio, primo piano** |
|   |   |   |   |   |   | **Vivaio, secondo piano** |
|   |   |   |   |   |   | **Fondo del vivaio** |

27 stanze sulla mappa, 26 collegamenti.

Non sulla mappa (scene di passaggio, scontri scritti, varianti «dopo»): `albero_addio`, `albero_addio_buono`, `albero_voce_spilla`, `botola_chiusa`, `cacciata`, `cartella_clinica`, `congedo_yhvina`, `dopo_volto`, `fiori_di_luna`, `foto_1`, `foto_2`, `foto_3`, `id_card_trovata`, `lettere_bruciate`, `lettere_lettura`, `lettore_vuoto`, `mensola`, `porta_bloccata`, `porta_enorme`, `presentazione_ricordo`, `quadro_donna`, `quadro_famiglia`, `quadro_uomo`, `ricordo_concluso`, `ricordo_concluso_buono`, `spirito_chiacchiere`, `spirito_diari`, `spirito_esperimento`, `spirito_foto`, `spirito_hub`, `spirito_indizio_yhvina`, `spirito_laboratori`, `spirito_laboratori_ancora`, `spirito_matrice`, `spirito_ricordi`, `spirito_rivelato`, `spirito_storia`, `spirito_storia_buona`, `spirito_storia_lasciata`, `spirito_vivaio_ancora`, `vivaio_1_perlustra`, `vivaio_2_perlustra`, `vivaio_apertura`, `vivaio_fondo`, `vivaio_fondo_dopo`, `vivaio_ingresso`, `vivaio_rovi`, `vivaio_varco`, `voce_avvicinati`, `voce_ignorata`, `volto_appare`, `yhvina_si`.

## Il percorso

```
soglia
  · Entra nella casa → salone   (agguato 30%)
    · Vai nella sala principale → sala_principale
      · Osserva il quadro dell'uomo → quadro_uomo
        · Torna nella sala principale → sala_principale [gia' visto]
      · Osserva il quadro della donna → quadro_donna
        · Torna nella sala principale → sala_principale [gia' visto]
      · Osserva il quadro di famiglia → quadro_famiglia
        · Torna nella sala principale → sala_principale [gia' visto]
      · Fruga sotto i cuscini del divano   (+18 Tazo)
      · Vai in cucina → cucina   (agguato 30%)
        · Fruga nella mensola → mensola
          · Torna in cucina → cucina [gia' visto]
        · Stappa una bottiglia di vino di ottima qualità   (+vino_di_ottima_qualita)
        · Fruga nella credenza dei dolci   (+merendine_scadute)
        · Torna nella sala principale → sala_principale [gia' visto]
      · Sali le scale → scala
        · Entra nella stanza dei giochi → stanza_giochi   (agguato 30%)
          · Osserva la prima fotografia → foto_1
            · Torna alla stanza dei giochi → stanza_giochi [gia' visto]
          · Osserva la seconda fotografia → foto_2
            · Torna alla stanza dei giochi → stanza_giochi [gia' visto]
          · Osserva la terza fotografia → foto_3
            · Torna alla stanza dei giochi → stanza_giochi [gia' visto]
          · Apri il baule dei giocattoli   (+fiala_hp)
          · Scendi nella botola → stanza_studi   (serve casa_botola; serve id_card, matrice)
            · Leggi la cartella clinica → cartella_clinica
              · Richiudi il fascicolo → stanza_studi [gia' visto]
            · Prosegui nel tunnel → tunnel
              · Avanza verso la luce in fondo → altare
                · Leggi le lettere → lettere_lettura   (solo se non casa_lettere_bruciate)
                  · Richiudi le lettere → altare [gia' visto]
                · Brucia le lettere → lettere_bruciate
                  · Torna all'altare → altare [gia' visto]
                · Stappa l'ultima bottiglia di vino di ottima qualità   (+vino_di_ottima_qualita)
                · Osserva da vicino la foto sull'altare → presentazione_ricordo   (solo se non casa_ricordo_sconfitto; scontro! tenero_ricordo)
                  vinci → ricordo_concluso   (flag casa_ricordo_sconfitto)
                    · Raccogli ciò che resta → congedo_yhvina   (+prova_di_un_forte_amore; +80 Tazo)
                      · Torna verso l'altare → altare [gia' visto]
                  perdi → cacciata
                    · Riprendi dall'ultimo salvataggio
                · Guarda oltre l'altare, nel buio → porta_bloccata   (solo se non casa_ricordo_sconfitto)
                  · Torna all'altare → altare [gia' visto]
                · L'altare è silenzioso, ora. → tunnel [gia' visto]
                · Guarda oltre l'altare, nel buio → porta_enorme   (serve casa_ricordo_sconfitto)
                  · Prova ad aprirla → tunnel [gia' visto]
                  · Non si muove di un millimetro. Non è ancora il momento. → altare [gia' visto]
                · Torna al tunnel → tunnel [gia' visto]
              · Torna alla stanza degli studi → stanza_studi [gia' visto]
            · Risali dalla botola → stanza_giochi [gia' visto]
          · Prova la matrice sul lettore → lettore_vuoto   (serve casa_botola; serve matrice; solo se non casa_id_card)
            · Torna alla stanza dei giochi → stanza_giochi [gia' visto]
          · Esamina il lettore della botola → botola_chiusa   (serve casa_botola; solo se non casa_matrice)
            · Torna alla stanza dei giochi → stanza_giochi [gia' visto]
          · Torna alla scala → scala [gia' visto]
        · Sali fino alla soffitta → soffitta   (agguato 30%)
          · Rovista tra gli scatoloni   (+collana_particolare)
          · Controlla dentro un vecchio baule chiuso a chiave   (+22 Tazo)
          · Un altro sottoscala porta più su, verso l'attico → attico
            · Apri la porta della camera da letto → camera_da_letto
              · Chiedile di combattere al tuo fianco → yhvina_si   (solo se non casa_ricordo_sconfitto)
                · Esci dalla camera → attico [gia' visto]
              · "Ce la faccio da solo." → attico [gia' visto]
            · Torna alla soffitta → soffitta [gia' visto]
          · Torna alla scala → scala [gia' visto]
        · Entra nel grande bagno → grande_bagno
          · Torna alla scala → scala [gia' visto]
        · Scendi nella sala principale → sala_principale [gia' visto]
      · Torna al salone → salone [gia' visto]
    · Vai nell'ala destra → ala_destra
      · Alza la piastrella   (+spilla_margherita)
      · Torna al salone → salone [gia' visto]
    · Vai nell'ala sinistra → ala_sinistra
      · Torna al salone → salone [gia' visto]
    · Torna alla soglia → soglia [gia' visto]
  · Va' verso i giardini → giardino_ingresso
    · Entra nel giardino → giardino   (agguato 35%)
      · Prendi il sentiero verso il giardino est → giardino_est   (agguato 35%)
        · Esplora il giardino est → fiori_di_luna   (+fiore_di_luna, fiore_di_luna)
          · Torna a guardarti intorno → giardino_est [gia' visto]
        · Addentrati nel giardino est → albero_voce
          ⟳ con casa_spilla diventa albero_voce_spilla
          albero_voce_spilla
            ⟳ con casa_spirito diventa spirito_hub
            spirito_hub
              ⟳ con casa_volto_battuto diventa albero_addio
              albero_addio
                ⟳ con casa_yhvina_legame diventa albero_addio_buono
                albero_addio_buono
                  · Raccogli il regalo della custode   (+fiore_di_luna, fiore_di_luna, fiore_di_luna; +120 Tazo)
                  · Torna al giardino est → giardino_est [gia' visto]
                · Torna al giardino est → giardino_est [gia' visto]
              · Chiedi consiglio su dove cercare → spirito_indizio_yhvina   (solo se non casa_yhvina)
                · Ringraziala → spirito_hub [gia' visto]
              · Chiedile come si apre la botola → spirito_laboratori   (serve casa_botola; solo se non casa_matrice)
                · Torna a parlarle → spirito_hub [gia' visto]
              · Chiedile ancora dei laboratori → spirito_laboratori_ancora   (serve casa_spirito_lab; solo se non casa_matrice)
                · Torna a parlarle → spirito_hub [gia' visto]
              · Mostrale la matrice → spirito_matrice   (serve casa_matrice)
                · Chiedi di più sull'esperimento → spirito_esperimento
                  · Chiedi delle persone nelle foto → spirito_foto
                    · Resta ad ascoltarla → spirito_esperimento [gia' visto]
                  · Chiedi dei suoi ultimi ricordi → spirito_ricordi
                    · Resta ad ascoltarla → spirito_esperimento [gia' visto]
                  · Chiedi dei diari di ricerca → spirito_diari   (serve diari_di_ricerca)
                    · Approfondisci la questione → spirito_storia
                      · Concludi in modo positivo → spirito_storia_buona
                        · Torna a parlare d'altro → spirito_hub [gia' visto]
                      · Lascia perdere → spirito_storia_lasciata
                        · Torna a parlare d'altro → spirito_hub [gia' visto]
                    · Vai via → spirito_esperimento [gia' visto]
                  · Torna a parlare d'altro → spirito_hub [gia' visto]
                · Concludi il discorso → spirito_hub [gia' visto]
              · Chiedile ancora del vivaio → spirito_vivaio_ancora   (serve casa_spirito_vivaio; solo se non casa_id_card)
                · Torna a parlarle → spirito_hub [gia' visto]
              · Chiedile del passato di questa casa → spirito_esperimento [gia' visto]
              · Falle compagnia un momento → spirito_chiacchiere
                · Resta ancora un po' → spirito_hub [gia' visto]
              · Torna al giardino est → giardino_est [gia' visto]
            · Mostra la spilla a margherita → spirito_rivelato   (serve spilla_margherita; flag casa_spirito)
              · Resta a parlare con lei → spirito_hub [gia' visto]
            · Torna al giardino est → giardino_est [gia' visto]
          · Avvicinati → voce_avvicinati
            · Torna al giardino est → giardino_est [gia' visto]
          · Vai via → voce_ignorata
            · Torna indietro e avvicinati → voce_avvicinati [gia' visto]
            · Torna al giardino est → giardino_est [gia' visto]
        · Torna al giardino → giardino [gia' visto]
      · Prendi il sentiero verso il giardino ovest → giardino_ovest   (agguato 35%)
        · Entra nel grande laboratorio → laboratorio
          · Perlustra i banconi   (+diari_di_ricerca)
          · Fruga in un armadietto del personale   (+45 Tazo)
          · Entra nella sala delle matrici → sala_matrici
            · Prendi una matrice dal ripiano   (+matrice)
            · Prosegui oltre la sala → deposito_chimico
              · Prendi una tanica di diserbante   (+diserbante)
              · Torna alla sala delle matrici → sala_matrici [gia' visto]
            · Torna nel laboratorio → laboratorio [gia' visto]
          · Torna al giardino ovest → giardino_ovest [gia' visto]
        · Torna al giardino → giardino [gia' visto]
      · Prendi il sentiero verso il giardino nord → giardino_nord   (flag casa_vivaio_bloccato; agguato 35%)
        · Avvicinati ai rovi → vivaio_ingresso
          ⟳ con casa_vivaio_aperto diventa vivaio_1
          vivaio_1   (agguato 40%)
            · Perlustra il piano → vivaio_1_perlustra
              · Torna a guardarti intorno → vivaio_1 [gia' visto]
            · Prosegui al piano inferiore → vivaio_2   (agguato 40%)
              · Perlustra il piano → vivaio_2_perlustra
                · Vai giù per il buco → vivaio_3
                  · Perlustra la stanza → vivaio_fondo
                    ⟳ con casa_volto_battuto diventa vivaio_fondo_dopo
                    vivaio_fondo_dopo
                      · Perlustra la stanza → id_card_trovata   (+id_card, fiala_hp, fiala_hp; +190 Tazo)
                        · Risali → vivaio_3 [gia' visto]
                      · Risali → vivaio_3 [gia' visto]
                    · Usa il diserbante sul terreno → volto_appare   (serve diserbante; scontro! volto_sulla_parete)
                      vinci → dopo_volto   (flag casa_volto_battuto)
                        · Perlustra la stanza → id_card_trovata [gia' visto]
                        · Risali → vivaio_3 [gia' visto]
                      perdi → cacciata [gia' visto]
                      fuggi → vivaio_3 [gia' visto]
                    · Risali → vivaio_3 [gia' visto]
                  · Risali al secondo piano → vivaio_2 [gia' visto]
                · Torna a guardarti intorno → vivaio_2 [gia' visto]
              · Risali al primo piano → vivaio_1 [gia' visto]
            · Esci dal vivaio → giardino_nord [gia' visto]
          · Prova a diradare le piante con un colpo → vivaio_rovi
            · Torna a guardare i rovi → vivaio_ingresso [gia' visto]
          · Versa il diserbante sui rovi → vivaio_varco   (serve diserbante)
            · Colpisci le piante → vivaio_apertura   (flag casa_vivaio_aperto)
              · Entra nel vivaio → vivaio_1 [gia' visto]
              · Torna al giardino nord → giardino_nord [gia' visto]
          · Torna al giardino nord → giardino_nord [gia' visto]
        · Torna al giardino → giardino [gia' visto]
      · Torna verso la soglia → giardino_ingresso [gia' visto]
    · Torna alla soglia → soglia [gia' visto]
  · Torna nel Vuoto   (solo se non casa_yhvina; esce dalla zona)
  · Torna nel Vuoto   (serve casa_ricordo_sconfitto; esce dalla zona)
```

---

# Fontana

<sub>`data/vuoti/fontana.json` — 3 scene</sub>

*Questa zona non ha ancora una `mappa_dungeon`: si gioca solo a scelte.*

## Il percorso

```
fontana
  · Deponi ciò che hai raccolto e completa la Fontana → fontana_completa   (serve anima_inquieta, ricordi_felici, volonta_di_un_fabbro, cuore_di_carnivalz)
    · Torna nel Vuoto   (esce dalla zona)
  · Osserva gli incavi vuoti → incavi
    · Torna alla fontana → fontana [gia' visto]
  · Torna nel Vuoto   (esce dalla zona)
```

---

# Kizako Ala

<sub>`data/vuoti/kizako_ala.json` — 8 scene</sub>

*Questa zona non ha ancora una `mappa_dungeon`: si gioca solo a scelte.*

## Il percorso

```
portone
  · Entra nel reparto montaggio → reparto   (agguato 40%)
    · Raggiungi la sala mensa → mensa   (agguato 40%)
      · Fruga tra i cartellini   (+30 Tazo)
      · Recupera il tesserino di un caposquadra   (+componente_elettronico)
      · Scendi negli archivi → archivi   (flag quest_kizako_ala)
        · Leggi un fascicolo a caso → fascicolo
          · Richiudi il fascicolo → archivi [gia' visto]
        · Entra nello studio di Kizako → studio_kizako
          · Preleva la volontà lasciata sull'incudine dell'officina   (+volonta_di_un_fabbro)
          · Esci dagli archivi → archivi [gia' visto]
        · Torna alla mensa → mensa [gia' visto]
      · Torna al reparto → reparto [gia' visto]
    · Sali alla passerella dei capisquadra → passerella   (agguato 50%)
      · Forza la cassaforte del capannone   (+45 Tazo)
      · Recupera la tanica lasciata sul ballatoio   (+benzina)
      · Scendi negli archivi per la scala di servizio → archivi [gia' visto]
      · Torna al reparto → reparto [gia' visto]
    · Torna al portone → portone [gia' visto]
  · Torna nel Vuoto   (esce dalla zona)
```

---

# Meridia

<sub>`data/vuoti/meridia.json` — 28 scene</sub>

## La griglia

| | | | |
|:--:|:--:|:--:|:--:|
|   |   | **Quartieri profondi** | ← |
|   |   | **Vicolo sul retro** |   |
| **Supermercato** | **Officina** | **Edicola** |   |
|   | **Strada principale** |   |   |
| **Struttura abbandonata** | **Primi complessi** | **Il parco** |   |
|   | **Ingresso della città** | ↑ |   |
|   | **Strade di periferia** |   |   |
|   | ▶ ✕ **Il varco** |   |   |

12 stanze sulla mappa, 11 collegamenti.

Non sulla mappa (scene di passaggio, scontri scritti, varianti «dopo»): `complessi_dopo`, `dopo_infetto`, `dopo_nuvola`, `dopo_ondate`, `espulso`, `fuori_struttura`, `fuori_struttura_dopo`, `garage_1`, `garage_2`, `garage_3`, `garage_3_perlustra`, `garage_4`, `garage_4_perlustra`, `parco_dopo`, `parco_lago`, `seconda_ondata`.

## Il percorso

```
varco
  · Scendi verso le strade di periferia → periferia
    · Prosegui verso l'ingresso della città → ingresso_citta
      · Prosegui verso i primi complessi di edifici → complessi   (flag mer_indagine)
        ⟳ con mer_indagine diventa complessi_dopo
        complessi_dopo
          · Avanza per la strada principale → strada_principale   (agguato 50%, ripetibile)
            · Entra nel supermercato saccheggiato → supermercato   (agguato 50%, ripetibile)
              · Fruga tra gli scaffali caduti   (+bastone; +6 Tazo)
              · Svuota una cassa ancora chiusa   (+8 Tazo)
              · Torna alla strada → strada_principale [gia' visto]
            · Entra nell'officina abbandonata → officina   (agguato 50%, ripetibile)
              · Recupera la spranga di ferro sul banco   (+spranga_di_ferro; +5 Tazo)
              · Forza l'armadietto degli attrezzi   (+motosega; serve l'abilita' scasso)
              · Torna alla strada → strada_principale [gia' visto]
            · Vai verso l'edicola → edicola
              · Leggi la prima pagina di giornale   (+pagina_di_giornale_1)
              · Leggi la seconda pagina di giornale   (+pagina_di_giornale_2)
              · Leggi la terza pagina di giornale   (+pagina_di_giornale_3)
              · Vai verso il vicolo sul retro → vicolo   (agguato 50%, ripetibile)
                · Raccogli il mazzafrusto improvvisato   (+mazzafrusto; +6 Tazo)
                · Recupera lo sparachiodi caduto tra i cassonetti   (+sparachiodi_arrugginito; +5 Tazo)
                · Scendi verso i quartieri profondi → quartieri_profondi   (flag meridia_esplorata; agguato 65%, ripetibile)
                  · Continua a battere i quartieri profondi
                  · Torna al vicolo → vicolo [gia' visto]
                · Torna all'edicola → edicola [gia' visto]
              · Torna alla strada → strada_principale [gia' visto]
            · Torna ai complessi di edifici → complessi [gia' visto]
          · Investiga il parco → parco
            ⟳ con mer_nuvola_battuta diventa parco_dopo
            parco_dopo
              · Torna ai complessi di edifici → complessi [gia' visto]
            · Esamina il parco → parco_lago   (+fiala_misteriosa; scontro! nuvola_di_marciume)
              vinci → dopo_nuvola   (flag mer_nuvola_battuta)
                · Torna ai complessi di edifici → complessi [gia' visto]
              perdi → espulso
                · Riprendi fiato nel Vuoto   (esce dalla zona)
              fuggi → parco [gia' visto]
            · Torna ai complessi di edifici → complessi [gia' visto]
          · Investiga dentro la struttura abbandonata → struttura
            · Esplora i piani inferiori → garage_1
              · Scendi al piano inferiore → garage_2
                · Scendi al piano inferiore → garage_3
                  · Perlustra il piano → garage_3_perlustra
                    · Scendi al piano inferiore → garage_4
                      · Perlustra il piano → garage_4_perlustra   (flag mer_macerie)
                        · Torna in superficie → fuori_struttura   (scontro! infetto_rapido)
                          ⟳ con mer_agguato_battuto diventa fuori_struttura_dopo
                          fuori_struttura_dopo
                            · Torna ai complessi di edifici → complessi [gia' visto]
                            · Rientra nella struttura → struttura [gia' visto]
                          vinci → dopo_infetto   (scontro! zombie_cittadino, zombie_cittadino, zombie_cittadino)
                            vinci → seconda_ondata   (scontro! zombie_cittadino, zombie_cittadino, zombie_cittadino)
                              vinci → dopo_ondate   (flag mer_agguato_battuto)
                                · Torna ai complessi di edifici → complessi [gia' visto]
                                · Rientra nella struttura → struttura [gia' visto]
                              perdi → espulso [gia' visto]
                              fuggi → complessi [gia' visto]
                            perdi → espulso [gia' visto]
                            fuggi → complessi [gia' visto]
                          perdi → espulso [gia' visto]
                          fuggi → complessi [gia' visto]
                        · Guarda ancora il cumulo → garage_4 [gia' visto]
                      · Torna in superficie → fuori_struttura [gia' visto]
                    · Torna a guardarti intorno → garage_3 [gia' visto]
                  · Scendi al piano inferiore → garage_4 [gia' visto]
                  · Risali al piano superiore → garage_2 [gia' visto]
                · Risali al piano superiore → garage_1 [gia' visto]
              · Risali in superficie → struttura [gia' visto]
            · Torna ai complessi di edifici → complessi [gia' visto]
          · Torna all'ingresso della città → ingresso_citta [gia' visto]
        · Avanza per la strada principale → strada_principale [gia' visto]
        · Investiga il parco → parco [gia' visto]
        · Investiga dentro la struttura abbandonata → struttura [gia' visto]
        · Torna all'ingresso della città → ingresso_citta [gia' visto]
      · Torna alle strade di periferia → periferia [gia' visto]
    · Torna al varco → varco [gia' visto]
  · Torna nel Vuoto   (esce dalla zona)
```

---

# Qualcosa Preme

<sub>`data/vuoti/qualcosa_preme.json` — 1 scene</sub>

*Questa zona non ha ancora una `mappa_dungeon`: si gioca solo a scelte.*

## Il percorso

```
soglia   (flag qualcosa_preme_toccato)
  · ...   (esce dalla zona)
```

---

# Rocca Ossidiana

<sub>`data/vuoti/rocca_ossidiana.json` — 37 scene</sub>

## La griglia

| | | | | | | |
|:--:|:--:|:--:|:--:|:--:|:--:|:--:|
| ✕ **Piazza sotterranea** | ← |   |   |   |   | ✕ **Cargo abbandonato** |
| ↑ | ↑ | ✕ **Cunicolo di sinistra** |   | ✕ **Cunicolo di destra** |   |   |
|   |   |   | ✕ **Bivio dei cunicoli** |   |   |   |
|   |   |   | ✕ **Il grande ponte marcio** |   |   |   |
|   |   |   |   |   | **Sala del lamento** |   |
|   | **La fossa oscura** |   | **Corridoio di ossidiana** |   | **Sala del raccolto** |   |
|   |   |   | ▶ ✕ **Il varco** |   |   |   |

11 stanze sulla mappa, 11 collegamenti.

Non sulla mappa (scene di passaggio, scontri scritti, varianti «dopo»): `altare_con_yara`, `altare_da_solo`, `altare_dei_sacrifici`, `cripta_con_compagna`, `cripta_senza_compagna`, `dopo_lamento`, `espulso`, `fondo_del_fosso`, `jongo_prima_caduta`, `lamento_imboscata`, `oltre_ponte`, `oltre_ponte_gratitudine`, `piazza_con_yara`, `piazza_ritorno`, `ponte_attacco`, `ponte_attacco_compagna`, `ponte_centro`, `ponte_meta_compagna`, `ponte_meta_solo`, `ponte_quasi_fine`, `sconfitta_boss`, `sconfitta_immortale`, `trono_marcio_con_compagna`, `trono_marcio_senza_compagna`, `vittoria`, `yara_si_unisce`.

## Il percorso

```
varco
  · Scendi nel corridoio di ossidiana → corridoio_ossidiana   (agguato 35%)
    · Scendi nella fossa oscura → fossa_oscura   (agguato 30%)
      · Fruga nel buio   (+20 Tazo)
      · Procedi verso il fondo → fondo_del_fosso
        · Recupera ciò che trovi → fossa_oscura [gia' visto]
        · Torna alla fossa → fossa_oscura [gia' visto]
      · Torna al corridoio → corridoio_ossidiana [gia' visto]
    · Entra nella sala del raccolto → sala_del_raccolto   (agguato 35%)
      · Fruga tra i sacchi marci   (+25 Tazo)
      · Recupera una fiala intatta tra le macerie   (+fiala_hp)
      · Scendi verso la sala del lamento → sala_del_lamento
        · Raccogli le pergamene → lamento_imboscata   (+pergamene_incomprensibili; solo se non oss_lamento_superato; scontro! ghoul, sacerdote_folle)
          vinci → dopo_lamento   (flag oss_lamento_superato; checkpoint)
            · Prendi il ciondolo strappato al sacerdote   (+ciondolo_del_grande_viaggio)
            · Prosegui più a fondo nei cunicoli → cunicolo_1
              · Vai a sinistra → cunicolo_2
                · Prosegui verso il bagliore → piazza_sotterranea   (flag oss_yara_conosciuta)
                  ⟳ con oss_yara_conosciuta diventa piazza_ritorno
                  piazza_ritorno
                    ⟳ con oss_compagna_reclutata diventa piazza_con_yara
                    piazza_con_yara
                      · Raccogli l'oggetto brillante   (+bomba_artigianale)
                      · Torna al cunicolo → cunicolo_2 [gia' visto]
                      · Torna alla mappa
                    · Chiedile di unirsi a te → yara_si_unisce
                      · Torna al cunicolo → cunicolo_2 [gia' visto]
                      · Apri la mappa
                    · Torna al cunicolo → cunicolo_2 [gia' visto]
                    · Torna alla mappa
                  · Chiedile di unirsi a te → yara_si_unisce [gia' visto]
                  · Torna al cunicolo → cunicolo_2 [gia' visto]
                  · Torna alla mappa
                · Torna al bivio → cunicolo_1 [gia' visto]
                · Torna alla mappa
              · Vai a destra → cunicolo_3
                · Sali verso la superficie → cargo_abbandonato
                  · Fruga tra le casse   (+30 Tazo)
                  · Recupera una fiala   (+fiala_hp)
                  · Recupera un'altra fiala   (+fiala_hp)
                  · Recupera l'infuso antico   (+infuso_antico)
                  · Recupera il gel omega   (+omega_gel)
                  · Torna al cunicolo → cunicolo_3 [gia' visto]
                  · Torna alla mappa
                · Torna al bivio → cunicolo_1 [gia' visto]
                · Torna alla mappa
              · Torna alla mappa
            · Prendi i cunicoli di destra, verso il ponte → ponte_approccio
              · Attraversa il grande ponte marcio → ponte_meta_compagna   (serve oss_compagna_reclutata)
                · Prosegui → ponte_centro
                  · Prosegui? → ponte_quasi_fine
                    · Prosegui? → ponte_attacco
                      · Reagisci → ponte_attacco_compagna   (serve oss_compagna_reclutata; scontro! divoratore_di_carcasse)
                        vinci → oltre_ponte
                          · Continua → oltre_ponte_gratitudine   (serve oss_compagna_reclutata)
                            · Entra nella cripta → cripta_con_compagna
                              · Affronta l'abominio   (solo se non oss_cripta_superata)
                              · Intuisci il momento giusto e scivola oltre, nell'ombra → altare_dei_sacrifici   (serve l'abilita' sesto_senso; flag oss_cripta_superata)
                                · Continua → altare_con_yara   (serve oss_compagna_reclutata)
                                  · Scendi verso il trono → trono_marcio_con_compagna   (flag oss_yara_esplosa)
                                    · Affrontalo
                                  · Torna alla cripta → cripta_con_compagna [gia' visto]
                                · Continua → altare_da_solo   (solo se non oss_compagna_reclutata)
                                  · Scendi verso il trono → trono_marcio_senza_compagna
                                    · Affrontalo
                                  · Torna alla cripta → cripta_senza_compagna
                                    · Affronta l'abominio   (solo se non oss_cripta_superata)
                                    · Intuisci il momento giusto e scivola oltre, nell'ombra → altare_dei_sacrifici [gia' visto]
                                    · Scendi verso l'altare → altare_dei_sacrifici [gia' visto]
                              · Scendi verso l'altare → altare_dei_sacrifici [gia' visto]
                          · Entra nella cripta → cripta_senza_compagna [gia' visto]
                        perdi → espulso
                          · Riprendi fiato nel Vuoto   (esce dalla zona)
                        fuggi → ponte_approccio [gia' visto]
                      · Reagisci   (solo se non oss_compagna_reclutata)
                  · Torna indietro → ponte_approccio [gia' visto]
              · Attraversa il grande ponte marcio → ponte_meta_solo   (solo se non oss_compagna_reclutata)
                · Prosegui → ponte_centro [gia' visto]
              · Torna alla mappa
          perdi → espulso [gia' visto]
        · Raccogli le pergamene   (+pergamene_incomprensibili; serve oss_lamento_superato)
        · Affronta ciò che urla nel buio → lamento_imboscata [gia' visto]
        · Prosegui → dopo_lamento [gia' visto]
        · Torna alla sala del raccolto → sala_del_raccolto [gia' visto]
      · Torna al corridoio → corridoio_ossidiana [gia' visto]
    · Torna al varco → varco [gia' visto]
  · Torna nel Vuoto   (esce dalla zona)
```

---

# Squarcio Industriale

<sub>`data/vuoti/squarcio_industriale.json` — 27 scene</sub>

## La griglia

| | | | | | | |
|:--:|:--:|:--:|:--:|:--:|:--:|:--:|
|   | **Il Padiglione** | ← | **La grande discarica** | ← |   |   |
|   | ↑ | ↑ | **Cuore del complesso** | ← |   |   |
|   |   |   |   |   |   | **Vecchio centro di controllo** |
|   |   |   | **Il nastro trasportatore** |   |   |   |
|   |   |   |   |   | **Sala informatica** |   |
|   |   |   |   | **Sala delle valvole** |   |   |
| **Stanza degli schermi** |   |   |   |   |   |   |
|   |   | **Corridoi infiniti** |   | **Corridoio dei tubi** | **Deposito** |   |
|   |   |   |   | **Sala vetrata** |   |   |
|   |   |   |   | **Corridoi stretti** |   |   |
|   |   |   |   | ▶ ✕ **Il varco** |   |   |

14 stanze sulla mappa, 14 collegamenti.

Non sulla mappa (scene di passaggio, scontri scritti, varianti «dopo»): `corridoi_infiniti_dopo`, `corridoi_stretti_dopo`, `corridoio_tubi_aperto`, `diario_1`, `diario_2`, `diario_3`, `dopo_operaio`, `dopo_robo`, `espulso`, `file_computer`, `padiglione_e_chiuso`, `sala_sorveglianza_dopo`, `sala_vetrata_dopo`.

## Il percorso

```
varco
  · Addentrati nel complesso → corridoi_stretti
    ⟳ con ind_robo_battuto diventa corridoi_stretti_dopo
    corridoi_stretti_dopo
      · Prosegui verso la sala vetrata → sala_vetrata   (scontro! robo_pattuglia)
        ⟳ con ind_robo_battuto diventa sala_vetrata_dopo
        sala_vetrata_dopo
          · Avanza nel corridoio dei tubi → corridoio_tubi   (agguato 35%)
            ⟳ con ind_sorveglianza diventa corridoio_tubi_aperto
            corridoio_tubi_aperto   (agguato 35%)
              · Fruga in un armadietto arrugginito → corridoio_tubi [gia' visto]
              · Verso la sala delle valvole → sala_valvole   (agguato 35%)
                · Recupera i bulloni caduti da una valvola   (+viti_e_bulloni; +8 Tazo)
                · Sali verso la sala informatica → sala_schede   (agguato 30%)
                  · Stacca il componente che lampeggia verso l'alto   (+componente_elettronico)
                  · Recupera la fiala incastrata tra i condensatori   (+fiala_hp)
                  · Scendi al vecchio centro di controllo → centro_controllo
                    · Leggi il primo diario → diario_1
                      · Richiudi il diario → centro_controllo [gia' visto]
                    · Leggi il secondo diario → diario_2
                      · Richiudi il diario → centro_controllo [gia' visto]
                    · Leggi il terzo diario → diario_3
                      · Richiudi il diario → centro_controllo [gia' visto]
                    · Apri il cassetto della scrivania   (+25 Tazo)
                    · Torna alla sala informatica → sala_schede [gia' visto]
                  · Torna alle valvole → sala_valvole [gia' visto]
                  · Torna nel corridoio → corridoio_tubi [gia' visto]
                · Segui il nastro trasportatore → nastro   (agguato 30%)
                  · Prendi la tanica di benzina sotto il rullo   (+benzina)
                  · Raccogli la bottiglia artigianale   (+molotov)
                  · Segui il nastro fino al cuore del complesso → cuore   (flag industriale_esplorato)
                    · Apri la cassetta   (+40 Tazo)
                    · Cerca tra i macchinari distrutti   (+fiala_hp)
                    · Esci nel piazzale della grande discarica → discarica   (agguato 35%)
                      · Rovista tra i rottami più vicini   (+rottame_di_metallo)
                      · Scava sotto una montagna di lamiere   (+rottame_di_metallo; +15 Tazo)
                      · Controlla un container ribaltato   (+35 Tazo)
                      · Va' verso la struttura tonda più in fondo → padiglione_e
                        · Prova a forzare il portello → padiglione_e_chiuso
                          · Torna al padiglione → padiglione_e [gia' visto]
                        · Torna alla discarica → discarica [gia' visto]
                      · Torna al cuore del complesso → cuore [gia' visto]
                    · Torna al nastro → nastro [gia' visto]
                  · Torna alle valvole → sala_valvole [gia' visto]
                · Torna nel corridoio → corridoio_tubi [gia' visto]
              · Entra nel deposito → deposito
                · Fruga nella cassa marchiata con una croce   (+fiala_hp, fiala_hp)
                · Svuota il barattolo di minuteria   (+viti_e_bulloni)
                · Solleva la mattonella smossa   (+30 Tazo)
                · Svita una piastra di rivestimento   (+viti_e_bulloni)
                · Torna nel corridoio → corridoio_tubi [gia' visto]
              · Sali alla sala informatica → sala_schede [gia' visto]
              · Torna nei corridoi infiniti → corridoi_infiniti
                ⟳ con ind_sorveglianza diventa corridoi_infiniti_dopo
                corridoi_infiniti_dopo
                  · Entra nella stanza degli schermi → sala_sorveglianza
                    ⟳ con ind_sorveglianza diventa sala_sorveglianza_dopo
                    sala_sorveglianza_dopo
                      · Torna indietro fra i corridoi → corridoi_infiniti [gia' visto]
                    · Leggi i file → file_computer   (scontro! operaio_sfruttato)
                      vinci → dopo_operaio   (flag ind_sorveglianza)
                        · Torna indietro fra i tubi → corridoio_tubi [gia' visto]
                      perdi → espulso
                        · Riprendi fiato nel Vuoto   (esce dalla zona)
                      fuggi → sala_sorveglianza [gia' visto]
                    · Torna indietro fra i corridoi → corridoi_infiniti [gia' visto]
                  · Torna indietro fra i tubi → corridoio_tubi [gia' visto]
                · Abbatti la porta → sala_sorveglianza [gia' visto]
                · Torna indietro fra i tubi → corridoio_tubi [gia' visto]
              · Torna al varco → varco [gia' visto]
            · Fruga in un armadietto arrugginito   (+viti_e_bulloni; +12 Tazo)
            · Addentrati ancora di più nel complesso → corridoi_infiniti [gia' visto]
            · Torna al varco → varco [gia' visto]
          · Torna ai corridoi → corridoi_stretti [gia' visto]
        vinci → dopo_robo   (flag ind_robo_battuto)
          · Avanza nel corridoio dei tubi → corridoio_tubi [gia' visto]
          · Torna ai corridoi → corridoi_stretti [gia' visto]
        perdi → espulso [gia' visto]
        fuggi → corridoi_stretti [gia' visto]
      · Torna al varco → varco [gia' visto]
    · Prosegui verso la luce rossa → sala_vetrata [gia' visto]
    · Torna al varco → varco [gia' visto]
  · Torna nel Vuoto   (esce dalla zona)
```

---

# Teatro Del Passato

<sub>`data/vuoti/teatro_del_passato.json` — 6 scene</sub>

*Questa zona non ha ancora una `mappa_dungeon`: si gioca solo a scelte.*

## Il percorso

```
foyer
  · Pesca nella fontanella dei desideri   (+12 Tazo)
  · Entra in platea → platea
    · Resta a guardare le acrobazie
    · Controlla sotto la poltrona numero 7   (+25 Tazo)
    · Sali sul palcoscenico → palcoscenico
      · Apri il baule di scena   (+31 Tazo)
      · Vai dietro le quinte → quinte   (flag quest_teatro)
        · Prendi la copia del biglietto   (+biglietto_strano)
        · Torna sul palcoscenico → palcoscenico [gia' visto]
      · Scendi in platea → platea [gia' visto]
    · Sali in galleria → galleria
      · Allunga la mano nella balaustra scollata   (+45 Tazo)
      · Scendi in platea → platea [gia' visto]
    · Torna nel foyer → foyer [gia' visto]
  · Passa dal botteghino → botteghino
    · Apri il doppio fondo del cassetto   (+25 Tazo)
    · Torna nel foyer → foyer [gia' visto]
  · Torna nel Vuoto   (esce dalla zona)
```
