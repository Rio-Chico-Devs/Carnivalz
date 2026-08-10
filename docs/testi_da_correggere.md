# Carnivalz — tutti i testi del gioco

Ogni cosa che il giocatore può leggere, una volta sola, con un posto dove scrivere la
versione giusta. **Non è un documento da leggere**: è un documento da riempire e ridarmi
indietro. Ogni frase compare una volta sola, nell'ordine in cui sta nei file del gioco.

## Come si usa

Ogni voce è fatta così:

```
**`ESEMPIO.1`** · Tutorial › inizio › battuta di Anonimo
> Dunque sarebbe questa la mia prima missione autonoma?
>
> →
```

1. La riga con **`ID`** dice dove sta la frase. **Non toccarla**: è quella che uso per
   ritrovare il testo esatto da cambiare.
2. La riga `>` è il testo com'è adesso. Lascialo com'è.
3. Dopo la freccia `→` scrivi la versione corretta. Se una frase va bene, lascia la
   freccia vuota e passa oltre — riscrivere solo quello che cambia rende il lavoro più
   veloce per tutti e due.

Cose utili da sapere mentre correggi:

- `%s` e `%d` sono buchi che il gioco riempie da solo (`%s` un nome o una parola, `%d` un
  numero). Se li sposti va bene, ma devono restare **tutti**, nello stesso ordine.
- `<br>` segna un a capo dentro la stessa frase.
- `[b]grassetto[/b]`, `[i]corsivo[/i]`, `[center]centrato[/center]` sono formattazione:
  puoi tenerla, toglierla o metterla dove serve.
- Per cancellare una frase, scrivi `ELIMINARE` dopo la freccia. Per spezzarla in due
  pagine, scrivi le due parti separate da una riga con `---`.
- Se una frase non ti convince ma non sai come riscriverla, scrivi `?` e una nota: la
  riguardiamo insieme.

Legenda dei prefissi degli ID:

| Prefisso | Cosa |
|---|---|
| `UI.` | scritte dell'interfaccia (bottoni, menu, diario di combattimento) |
| `INT.` | l'introduzione |
| `TUT.` | il tutorial |
| `IND.` `MER.` `OSS.` `TEA.` `CASA.` `KIZ.` `FON.` `PRE.` | gli squarci del Vuoto Ardente |
| `JER.` | la campagna di Jerah |
| `COMP.` | chiacchiere coi compagni |
| `CRE.` | creature: descrizioni, studio, carte |
| `CLA.` | personaggi giocabili |
| `OGG.` | oggetti |
| `STA.` | stati (avvelenato, terrore...) |
| `CRES.` | crescita: nomi delle statistiche e abilità passive |
| `APP.` | appunti del Diario |
| `LUO.` | nomi dei luoghi sulle mappe |
| `NEG.` | negozi |
| `PSI.` | psichi |


# 1. Scritte dell'interfaccia

Tutto quello che il gioco scrive di suo: bottoni, menu, notifiche, righe del diario di
combattimento. Non è mai passato sotto i tuoi occhi finora.


## 1.1 Loghi d'apertura

<sub>`scripts/Splash.gd`</sub>

**`UI.Splash.001`**
> RIO CHICO DEVS
>
> →

**`UI.Splash.002`**
> un gioco di Bru
>
> →


## 1.2 Menu principale

<sub>`scripts/Menu.gd`</sub>

**`UI.Menu.001`**
> CARNIVALZ
>
> →

**`UI.Menu.002`**
> una festa per chi ha subìto ingiustizie
>
> →

**`UI.Menu.003`**
> — demo —
>
> →

**`UI.Menu.004`**
> Opzioni
>
> →

**`UI.Menu.005`**
> Extra
>
> →

**`UI.Menu.006`**
> Esci dal gioco
>
> →

**`UI.Menu.007`**
> In gioco: ESC per pausa, storico, Diario e scheda del personaggio.<br>La partita si salva da sola ogni volta che rientri alla Sede.
>
> →

**`UI.Menu.008`** · riempi_partite
> %d.  %s<br>%s
>
> →

**`UI.Menu.009`** · riempi_partite
> %d.  Nuova partita
>
> →

**`UI.Menu.010`** · _su_nuova_partita
> Come ti chiami?
>
> →

**`UI.Menu.011`** · _su_nuova_partita
> Lascia vuoto per restare l'Anonimo.
>
> →

**`UI.Menu.012`** · _su_nuova_partita
> Comincia
>
> →

**`UI.Menu.013`** · _su_nuova_partita
> Indietro
>
> →

**`UI.Menu.014`** · _su_cancella
> Cancellare la partita %d?
>
> →

**`UI.Menu.015`** · _su_cancella
> %s<br>%s<br>Non si torna indietro.
>
> →

**`UI.Menu.016`** · _su_cancella
> No, lasciala stare
>
> →

**`UI.Menu.017`** · _su_cancella
> Sì, cancella
>
> →


## 1.3 Opzioni

<sub>`scripts/Opzioni.gd`</sub>

**`UI.Opzioni.001`**
> Opzioni
>
> →

**`UI.Opzioni.002`**
> Indietro
>
> →


## 1.4 Extra

<sub>`scripts/Extra.gd`</sub>

**`UI.Extra.001`**
> Extra
>
> →

**`UI.Extra.002`**
> Carica codice
>
> →

**`UI.Extra.003`**
> Ringraziamenti
>
> →

**`UI.Extra.004`**
> Instagram: %s
>
> →

**`UI.Extra.005`**
> Sito: %s
>
> →

**`UI.Extra.006`**
> Indietro
>
> →

**`UI.Extra.007`** · _su_carica_codice
> Conferma
>
> →

**`UI.Extra.008`** · _su_carica_codice
> Codice non riconosciuto.
>
> →

**`UI.Extra.009`** · _su_carica_codice
> Codice già riscattato in precedenza.
>
> →

**`UI.Extra.010`** · _su_carica_codice
> Codice riscattato!
>
> →

**`UI.Extra.011`** · _su_carica_codice
> Chiudi
>
> →


## 1.5 Collezioni (album, bestiario, compendio)

<sub>`scripts/Collezione.gd`</sub>

**`UI.Collezione.001`**
> Torna al menu
>
> →

**`UI.Collezione.002`** · titolo_schermata
> Collezione
>
> →


## 1.6 Album delle carte

<sub>`scripts/Album.gd`</sub>

**`UI.Album.001`** · titolo_schermata
> Album delle carte  (%d / %d)
>
> →


## 1.7 Bestiario

<sub>`scripts/Bestiario.gd`</sub>

**`UI.Bestiario.001`** · titolo_schermata
> Bestiario  (%d / %d)
>
> →

**`UI.Bestiario.002`** · testo_extra
> » [voce nascosta — c'è ancora qualcosa da scoprire su di lui]
>
> →


## 1.8 Compendio degli oggetti

<sub>`scripts/Compendio.gd`</sub>

**`UI.Compendio.001`** · titolo_schermata
> Oggetti  (%d / %d)
>
> →

**`UI.Compendio.002`** · _etichetta_portatore
> Nell'armadio — si mette addosso dal Diario (ESC)
>
> →

**`UI.Compendio.003`** · _etichetta_portatore
> Addosso a %s
>
> →


## 1.9 Introduzione

<sub>`scripts/Intro.gd`</sub>

**`UI.Intro.001`**
> premi per continuare
>
> →


## 1.10 Mappa stellare

<sub>`scripts/Mappa.gd`</sub>

**`UI.Mappa.001`**
> Tazo: %d
>
> →


## 1.11 Il Vuoto (mappa di una regione)

<sub>`scripts/Vuoto.gd`</sub>

**`UI.Vuoto.001`**
> IL VUOTO — %s
>
> →

**`UI.Vuoto.002`**
> Tazo: %d
>
> →

**`UI.Vuoto.003`** · crea_pianeta
> ☉  Scendi verso l'anomalia
>
> →


## 1.12 Mappa di una zona

<sub>`scripts/MappaZona.gd`</sub>

**`UI.MappaZona.001`** · costruisci_intelaiatura
> Torna alla stanza corrente
>
> →

**`UI.MappaZona.002`** · _su_stanza
> Da questa parte non si passa, per ora.
>
> →

**`UI.MappaZona.003`** · _su_stanza
> Troppo lontano. Da qui si va solo dove si arriva a piedi.
>
> →


## 1.13 Schermata degli eventi

<sub>`scripts/Main.gd`</sub>

**`UI.Main.001`** · scelte a schermo
> Osserva la scena
>
> →

**`UI.Main.002`** · quando il Diario si aggiorna
> Il resto me lo sono segnato. Ci ripenso quando decido da dove cominciare.
>
> →

**`UI.Main.003`** · quando sblocchi una passiva
> Nuova abilità passiva: %s
>
> →

**`UI.Main.004`** · quando raccogli un oggetto
> %s: la sacca è piena, non c'è posto per lui.
>
> →

**`UI.Main.005`** · quando raccogli un oggetto
> Hai raccolto: %s (%s).
>
> →

**`UI.Main.006`** · _su_scelta
> Hai ottenuto %d Tazo.
>
> →

**`UI.Main.007`** · menu «Parla con la squadra»
> %s e %s stanno parlando...
>
> →

**`UI.Main.008`** · quando intervieni in una discussione
> Puoi intervenire.
>
> →

**`UI.Main.009`** · quando parli con un compagno
> %s non ha altro da dirti, qui.
>
> →

**`UI.Main.010`** · barra di stato in alto
> solo tu
>
> →

**`UI.Main.011`** · barra di stato in alto
> Lv %d   ·   Tazo %d   ·   Sacca %d/%d   ·   Legame %d
>
> →

**`UI.Main.012`** · barra di stato in alto
> HP %d   ATT %d   DIF %d   VEL %d   INT %d   MEN %d   FAT %d
>
> →


## 1.14 Combattimento

<sub>`scripts/Combattimento.gd`</sub>

**`UI.Combattimento.001`**
> Ora di combattere.
>
> →

**`UI.Combattimento.002`** · quando si mostra un oggetto al nemico
> %s mostra %s.
>
> →

**`UI.Combattimento.003`** · barra della speranza
> Speranza %d / %d
>
> →

**`UI.Combattimento.004`** · esegui_scontro
> %s è in preda alla rabbia e attacca di nuovo!
>
> →

**`UI.Combattimento.005`** · mostra_continua_fine
> ▸ Continua
>
> →

**`UI.Combattimento.006`** · esegui_turno
> [i]%s ha perso il controllo: può solo attaccare.[/i]
>
> →

**`UI.Combattimento.007`** · esegui_turno
> [i]%s è confuso e colpisce %s per sbaglio![/i]
>
> →

**`UI.Combattimento.008`** · quando ci si difende
> %s si mette in guardia (difesa +%d).
>
> →

**`UI.Combattimento.009`** · quando si usa un oggetto
> %s usa: %s.
>
> →

**`UI.Combattimento.010`** · applica_effetto
> [i]%s si libera di %s.[/i]
>
> →

**`UI.Combattimento.011`** · applica_effetto
> [i]%s non ne aveva bisogno: niente %s addosso.[/i]
>
> →

**`UI.Combattimento.012`** · risparmia
> Decidi di risparmiarlo.
>
> →

**`UI.Combattimento.013`** · provocazione
> [i]%s si mette in mostra: i nemici non vedono altro che lui.[/i]
>
> →

**`UI.Combattimento.014`** · colpo d'area
> [i]%s scatena un colpo che si abbatte su tutti i nemici![/i]
>
> →

**`UI.Combattimento.015`** · consuma_carica
> [b]%s scarica tutto quello che ha accumulato.[/b]
>
> →

**`UI.Combattimento.016`** · quando si prova a fuggire
> [i]%s prova a fuggire, ma non trova il varco giusto.[/i]
>
> →

**`UI.Combattimento.017`** · verifica_rabbia_su_morte
> La rabbia cresce.
>
> →

**`UI.Combattimento.018`** · verifica_cura_su_morte
> Si rimette in sesto.
>
> →

**`UI.Combattimento.019`** · risolvi_rigenerazione
> La carne si richiude su se stessa.
>
> →

**`UI.Combattimento.020`** · risolvi_rigenerazione
> Resta a terra, e continua a ricucirsi.
>
> →

**`UI.Combattimento.021`** · esegui_mossa
> [i]...ma nessuno risponde al richiamo.[/i]
>
> →

**`UI.Combattimento.022`** · esegui_mossa
> [i]%s lo colpisce lui stesso, senza esitare.[/i]
>
> →

**`UI.Combattimento.023`** · cedimento
> [i]Lo spettacolo di %s si spegne un po' di più.[/i]
>
> →

**`UI.Combattimento.024`** · applica_stato
> [i]%s %s[/i]
>
> →

**`UI.Combattimento.025`** · applica_stato
> subisce uno stato.
>
> →

**`UI.Combattimento.026`** · applica_stato
> [i]%s ne è contagiato.[/i]
>
> →

**`UI.Combattimento.027`** · risolvi_stati_a_inizio_turno
> [i]%s non riesce ad agire: %s.[/i]
>
> →

**`UI.Combattimento.028`** · quando si attacca
> Il fattore di disallineamento arde in %s!
>
> →

**`UI.Combattimento.029`** · quando si attacca
> %s para il colpo di %s.
>
> →

**`UI.Combattimento.030`** · quando si attacca
> [b]Colpo critico![/b] %s coglie %s in pieno.
>
> →

**`UI.Combattimento.031`** · _su_ko
> Vittoria.
>
> →

**`UI.Combattimento.032`** · _su_ko
> %d esperienza · %d Tazo
>
> →

**`UI.Combattimento.033`** · _su_ko
> Il party è a terra. Il disallineamento ha vinto.
>
> →

**`UI.Combattimento.034`** · reagisci
> %s ribolle di rabbia!
>
> →

**`UI.Combattimento.035`** · reagisci
> %s si chiude in sé: la sua difesa cala.
>
> →

**`UI.Combattimento.036`** · reagisci
> %s si concentra: il fattore di disallineamento sale.
>
> →


## 1.15 Negozio

<sub>`scripts/Negozio.gd`</sub>

**`UI.Negozio.001`** · costruisci
> Tazo: %d   •   Sacca %d/%d
>
> →

**`UI.Negozio.002`** · aggiungi_voce_vendita
> Compra — %d Tazo
>
> →

**`UI.Negozio.003`** · aggiungi_voce_vendita
> la sacca è piena
>
> →

**`UI.Negozio.004`** · aggiungi_voce_vendita
> ti mancano %d Tazo
>
> →

**`UI.Negozio.005`** · aggiungi_voce_vendita
> te ne restano %d
>
> →

**`UI.Negozio.006`** · quanti_ne_hai
> ne hai già %d in sacca
>
> →

**`UI.Negozio.007`** · quanti_ne_hai
> ne hai già uno, nell'armadio
>
> →

**`UI.Negozio.008`** · quanti_ne_hai
> ne hai già uno, addosso a %s
>
> →

**`UI.Negozio.009`** · aggiungi_voce_baratto
> in cambio di:
>
> →

**`UI.Negozio.010`** · aggiungi_voce_baratto
> Baratta
>
> →

**`UI.Negozio.011`** · aggiungi_voce_baratto
> ti manca:
>
> →


## 1.16 Pausa, storico e Diario

<sub>`scripts/Pausa.gd`</sub>

**`UI.Pausa.001`** · intestazione
> Tazo %d     Lv %d
>
> →

**`UI.Pausa.002`** · menu di pausa
> Pausa
>
> →

**`UI.Pausa.003`** · menu di pausa
> Riprendi
>
> →

**`UI.Pausa.004`** · menu di pausa
> Storico dei dialoghi
>
> →

**`UI.Pausa.005`** · menu di pausa
> Diario
>
> →

**`UI.Pausa.006`** · menu di pausa
> Personaggio e squadra
>
> →

**`UI.Pausa.007`** · menu di pausa
> Zaino
>
> →

**`UI.Pausa.008`** · menu di pausa
> Opzioni
>
> →

**`UI.Pausa.009`** · menu di pausa
> Torna al menu principale
>
> →

**`UI.Pausa.010`** · mostra_opzioni
> Indietro
>
> →

**`UI.Pausa.011`** · conferma di uscita
> Tornare al menu?
>
> →

**`UI.Pausa.012`** · conferma di uscita
> Il gioco si salva da solo quando rientri alla Sede: tutto quello che hai<br>fatto dentro questa zona (stanze, oggetti raccolti, Tazo) andrà perso.
>
> →

**`UI.Pausa.013`** · conferma di uscita
> No, resto qui
>
> →

**`UI.Pausa.014`** · conferma di uscita
> Sì, torna al menu principale
>
> →

**`UI.Pausa.015`** · storico dei dialoghi
> Non hai ancora letto niente.
>
> →

**`UI.Pausa.016`** · mostra_inventario
> %s  (%s)
>
> →

**`UI.Pausa.017`** · capienza_testo
> %d / %d
>
> →

**`UI.Pausa.018`** · disegna_scomparto
> Questo scomparto è vuoto.
>
> →

**`UI.Pausa.019`** · riga_oggetto
> ×%d
>
> →

**`UI.Pausa.020`** · riga_oggetto
> in uso — %s
>
> →

**`UI.Pausa.021`** · riga_oggetto
> %s  —  %s
>
> →

**`UI.Pausa.022`** · Diario › Appunti
> Appunti
>
> →

**`UI.Pausa.023`** · Diario › Appunti
> Niente da segnare, per ora.
>
> →

**`UI.Pausa.024`** · Diario › Appunti
> Già risolti
>
> →

**`UI.Pausa.025`** · Diario › riga di un appunto
> chiesto da
>
> →

**`UI.Pausa.026`** · etichetta_bonus
> velocità
>
> →

**`UI.Pausa.027`** · etichetta_bonus
> vita massima
>
> →

**`UI.Pausa.028`** · etichetta_bonus
> aura massima
>
> →

**`UI.Pausa.029`** · etichetta_bonus
> aura per turno
>
> →

**`UI.Pausa.030`** · etichetta_bonus
> rintocchi di maledizione
>
> →

**`UI.Pausa.031`** · riassunto_effetto
> nessun effetto
>
> →

**`UI.Pausa.032`** · Diario › Stato
> Stato
>
> →

**`UI.Pausa.033`** · Diario › Stato
> Livello
>
> →

**`UI.Pausa.034`** · Diario › Stato
> %d  (%d / %d esperienza)
>
> →

**`UI.Pausa.035`** · Diario › Cosa ti sta cambiando
> Cosa ti sta cambiando
>
> →

**`UI.Pausa.036`** · Diario › nomi delle azioni tracciate
> Colpi che hai sferrato
>
> →

**`UI.Pausa.037`** · Diario › nomi delle azioni tracciate
> Danni che hai incassato
>
> →

**`UI.Pausa.038`** · Diario › nomi delle azioni tracciate
> Volte che hai tenuto la guardia
>
> →

**`UI.Pausa.039`** · Diario › nomi delle azioni tracciate
> Creature che hai studiato
>
> →

**`UI.Pausa.040`** · Diario › nomi delle azioni tracciate
> Volte che sei scappato
>
> →

**`UI.Pausa.041`** · Diario › nomi delle azioni tracciate
> Oggetti che hai usato
>
> →

**`UI.Pausa.042`** · Diario › nomi delle azioni tracciate
> Stanze che hai esplorato
>
> →

**`UI.Pausa.043`** · Diario › nomi delle azioni tracciate
> Stress che hai retto
>
> →

**`UI.Pausa.044`** · Diario › nomi delle azioni tracciate
> Colpi critici che hai messo a segno
>
> →

**`UI.Pausa.045`** · Diario › Abilità passive
> Abilità passive
>
> →

**`UI.Pausa.046`** · Diario › Abilità passive
> Nessuna, per ora.
>
> →

**`UI.Pausa.047`** · Diario › Squadra
> Squadra
>
> →

**`UI.Pausa.048`** · Diario › Squadra
> Legame
>
> →

**`UI.Pausa.049`** · Diario › Squadra
> %d / 100
>
> →

**`UI.Pausa.050`** · Diario › Squadra
> Lv %d   ·   stress %d
>
> →

**`UI.Pausa.051`** · Diario › Osservazioni
> Osservazioni
>
> →

**`UI.Pausa.052`** · Diario › Osservazioni
> Creature studiate
>
> →

**`UI.Pausa.053`** · Diario › Osservazioni
> Creature incontrate
>
> →

**`UI.Pausa.054`** · Diario › Osservazioni
> Oggetti catalogati
>
> →

**`UI.Pausa.055`** · Diario › Osservazioni
> Resistenza —
>
> →

**`UI.Pausa.056`** · Diario › Organizzazione
> Organizzazione
>
> →

**`UI.Pausa.057`** · Diario › Organizzazione
> Fonti estinte
>
> →

**`UI.Pausa.058`** · Diario › Organizzazione
> Valutazione
>
> →

**`UI.Pausa.059`** · Diario › giudizio dell'Organizzazione
> In osservazione.
>
> →

**`UI.Pausa.060`** · Diario › giudizio dell'Organizzazione
> Prestazione conforme alle attese.
>
> →

**`UI.Pausa.061`** · Diario › giudizio dell'Organizzazione
> Rendimento soddisfacente.
>
> →

**`UI.Pausa.062`** · Diario › giudizio dell'Organizzazione
> Elemento affidabile.
>
> →

**`UI.Pausa.063`** · Diario › giudizio dell'Organizzazione
> Elemento di valore. Aspettative in aumento.
>
> →


## 1.17 Ritratti

<sub>`scripts/Ritratto.gd`</sub>

**`UI.Ritratto.001`** · mostra
> %s · Lv %d
>
> →


## 1.18 Varie

<sub>`scripts/GameState.gd`</sub>

**`UI.GameState.001`** · anteprima_slot
> Vuoto
>
> →

**`UI.GameState.002`** · anteprima_slot
> Tazo %d · Fonti estinte %d · Legame %d
>
> →

**`UI.GameState.003`** · nome_slot
> %s · livello %d
>
> →


# 2. La storia


## Introduzione

<sub>`data/events_intro.json`</sub>


### Introduzione › `monologo`

**`INT.monologo.1`** · battuta di Anonimo
> ...
>
> →

**`INT.monologo.2`** · battuta di Anonimo
> ... ...
>
> →

**`INT.monologo.3`** · battuta di Anonimo
> ... ... ...
>
> →

**`INT.monologo.4`** · battuta di Anonimo
> Coordinate confermate, obiettivo localizzato, perimetro di azione calcolato...
>
> →

**`INT.monologo.5`** · battuta di Anonimo
> ...
>
> →

**`INT.monologo.6`** · battuta di Anonimo
> Computer... proiettami il più possibile vicino alla fonte.
>
> →

**`INT.monologo.7`** · battuta di Computer
> Autorizzazione confermata. Buona fortuna unità UJ-111
>
> →

**`INT.monologo.8`** · battuta di Computer
> lancio in...
>
> →

**`INT.monologo.9`** · battuta di Computer
> 3...
>
> →

**`INT.monologo.10`** · battuta di Computer
> 2...
>
> →

**`INT.monologo.11`** · battuta di Computer
> 1...
>
> →

**`INT.monologo.12`** · battuta di Computer
> Per aspera, ad astra.
>
> →

**`INT.monologo.13`** · battuta di Anonimo
> ...
>
> →


## Tutorial

<sub>`data/events_tutorial.json`</sub>


### Tutorial › `inizio`

**`TUT.inizio.1`** · narrazione
> In queste pianure il vento soffia gentile.<br>Piccole pozze d'acqua salutano il cielo con i loro riflessi mentre le foglie cambiano colore nel tempo...<br>Piccole creature primitive vivono spensierate in queste radure lontane, aspettando che quello stesso vento che soffia incessante li porti via...
>
> →

**`TUT.inizio.2`** · carta del titolo
> Pianure di Redenna
>
> →

**`TUT.inizio.3`** · battuta di Anonimo
> Dunque sarebbe questa la mia prima missione autonoma? Sembra un posto molto tranquillo, forse siamo in tempo per salvare queste pianure...
>
> →

**`TUT.inizio.scena`** · quando ci torni («Osserva la scena»)
> Le pianure di Redenna si aprono davanti a te, tranquille come sembravano da lassù.
>
> →

**`TUT.inizio.scelta1`** · bottone di scelta
> Fatti largo tra le pianure
>
> →


### Tutorial › `primo_incontro`

**`TUT.primo_incontro.1`** · narrazione
> Tra le felci, qualcosa ti nota e si fa avanti, saltando fuori dal suo nascondiglio, ti aggredisce.
>
> →

**`TUT.primo_incontro.2`** · battuta di Anonimo
> Vediamo di finire presto: non ho tempo da perdere.
>
> →


### Tutorial › `dopo_primo_goblin`

**`TUT.dopo_primo_goblin.1`** · narrazione
> Alcune creature sono malvage di natura, è tuo compito decidere il loro destino.
>
> →

**`TUT.dopo_primo_goblin.2`** · battuta di Anonimo
> Le creature qui sembrano molto deboli... Qualunque cosa stia causando questa anomalia non deve essere molto forte...
>
> →

**`TUT.dopo_primo_goblin.scelta1`** · bottone di scelta
> Continua per la tua strada
>
> →


### Tutorial › `masso`

**`TUT.masso.1`** · narrazione
> Il sentiero costeggia un masso coperto di muschio, accanto si trova un ruscello poco profondo. Sembra esserci qualcosa, nell'acqua bassa.
>
> →

**`TUT.masso.scelta1`** · bottone di scelta (fa raccogliere Fiala HP, Fiala HP)
> Ispeziona l'acqua che luccica
>
> →

**`TUT.masso.scelta2`** · bottone di scelta
> Prosegui senza fermarti
>
> →


### Tutorial › `due_nemici`

**`TUT.due_nemici.1`** · narrazione
> Ti ritrovi in mezzo a una piccola radura fangosa. Le acque cristalline che emergono dai cumuli di fango umido creano un luccichio meraviglioso...
>
> →


### Tutorial › `bivio`

**`TUT.bivio.1`** · battuta di Anonimo
> Hm... sembra che io possa proseguire sia dalla parte bassa che alta di questo bivio...
>
> →

**`TUT.bivio.2`** · battuta di Anonimo
> Forse sarebbe meglio proseguire dalla parte bassa, posso sempre tornare indietro...
>
> →

**`TUT.bivio.3`** · battuta di Anonimo
> Anche se... Ho un brutto presentimento... qualcosa mi turba... e proviene dalla collina. Forse sarebbe meglio investigare cosa c'è sopra la collina...
>
> →

**`TUT.bivio.4`** · narrazione
> Il sentiero si dirama: da qui in poi conviene tenere d'occhio la mappa (bottone "Mappa"). Da qui puoi controllare la tua posizione, e ti riporta nei posti che hai già visto senza doverli riattraversare a piedi.
>
> →

**`TUT.bivio.scena`** · quando ci torni («Osserva la scena»)
> Il terreno sembra innalzarsi creando una piccola collina... tutto intorno ci sono varie pozze d'acqua che riflettono i raggi del sole. In lontananza senti dei rumori indistinti.
>
> →

**`TUT.bivio.scelta1`** · bottone di scelta
> Procedi verso le pozze d'acqua
>
> →

**`TUT.bivio.scelta2`** · bottone di scelta
> Sali sulla collina
>
> →


### Tutorial › `pozze`

**`TUT.pozze.1`** · battuta di Anonimo
> Un altro Goblin... e quella... cos'è? È enorme...
>
> →


### Tutorial › `pozze_ripulite`

**`TUT.pozze_ripulite.1`** · narrazione
> Le pozze riflettono il cielo, immobili. C'è una particolare calma in questo posto.
>
> →

**`TUT.pozze_ripulite.scelta1`** · bottone di scelta
> Attraversa gli arbusti
>
> →

**`TUT.pozze_ripulite.scelta2`** · bottone di scelta
> Torna al bivio
>
> →


### Tutorial › `dopo_pozze`

**`TUT.dopo_pozze.1`** · battuta di Anonimo
> Qualcuno sembra urlare oltre questi arbusti... sento che la fonte è vicina... devo essere sicuro di aver fatto tutto quello che era necessario fare prima di proseguire.
>
> →

**`TUT.dopo_pozze.scena`** · quando ci torni («Osserva la scena»)
> Le pozze riflettono il cielo, immobili. Da qui il sentiero è interrotto da un mucchio di arbusti.
>
> →

**`TUT.dopo_pozze.scelta1`** · bottone di scelta
> Oltrepassa gli arbusti
>
> →

**`TUT.dopo_pozze.scelta2`** · bottone di scelta
> Apri la mappa
>
> →


### Tutorial › `collina`

**`TUT.collina.1`** · battuta di Anonimo
> Ho davvero un brutto presentimento...
>
> →

**`TUT.collina.2`** · battuta di Anonimo
> Cos'è questo odore dolce... è molto piacevole...
>
> →

**`TUT.collina.3`** · battuta di Anonimo
> Non sembrerebbe esserci niente qui sopra...
>
> →

**`TUT.collina.4`** · battuta di Anonimo
> ...
>
> →

**`TUT.collina.5`** · battuta di Anonimo
> *sniff* L'odore sembra essersi fatto più forte... cos'è questa stanchezza improvvisa...
>
> →

**`TUT.collina.6`** · narrazione
> Piccole particelle di luce cominciano a concentrarsi davanti a te, roteando e creando un gioco di movimenti ipnotici...
>
> →

**`TUT.collina.7`** · battuta di Anonimo
> Cosa sta succedendo? ...
>
> →

**`TUT.collina.8`** · narrazione
> Una creatura appare dal nulla, cammina intorno a te osservandoti da vicino, senti una stanchezza travolgente che ti impedisce di reagire...
>
> →

**`TUT.collina.9`** · battuta di Anonimo
> Devo... riprendermi...
>
> →

**`TUT.collina.10`** · battuta di Anonimo
> !!! È ora di porre fine a tutto questo!
>
> →

**`TUT.collina.11`** · narrazione
> La creatura si allontana leggermente avvolgendoti in un velo iridescente.
>
> →

**`TUT.collina.12`** · narrazione
> La manifestazione ti osserva e prova ad avvicinarsi di nuovo. Hai un terribile presentimento...
>
> →


### Tutorial › `collina_ritorno`

**`TUT.collina_ritorno.1`** · battuta di Anonimo
> Devo scoprire di più su quella creatura.
>
> →

**`TUT.collina_ritorno.2`** · narrazione
> Proprio al centro della collina la strana creatura volteggia, ignorando tutto il resto...
>
> →

**`TUT.collina_ritorno.scena`** · quando ci torni («Osserva la scena»)
> La collina è silenziosa, sembra essere tutto tornato alla normalità, ma la fonte è ancora da qualche parte...
>
> →

**`TUT.collina_ritorno.scelta1`** · bottone di scelta (porta a un combattimento)
> Combatti
>
> →

**`TUT.collina_ritorno.scelta2`** · bottone di scelta
> Torna al bivio
>
> →


### Tutorial › `collina_vuota`

**`TUT.collina_vuota.1`** · narrazione
> La cima della collina è vuota. Nell'erba resta solo il cerchio schiacciato dove qualcosa volteggiava, e l'odore dolce che si sta dissolvendo.
>
> →

**`TUT.collina_vuota.2`** · battuta di Anonimo
> Qui ho già finito.
>
> →

**`TUT.collina_vuota.scena`** · quando ci torni («Osserva la scena»)
> La cima della collina è vuota. Resta il cerchio schiacciato nell'erba.
>
> →

**`TUT.collina_vuota.scelta1`** · bottone di scelta
> Attraversa gli arbusti
>
> →

**`TUT.collina_vuota.scelta2`** · bottone di scelta
> Torna al bivio
>
> →


### Tutorial › `dopo_collina`

**`TUT.dopo_collina.1`** · battuta di Anonimo
> Non so cosa fosse... ma la collina è silenziosa, adesso.
>
> →

**`TUT.dopo_collina.scena`** · quando ci torni («Osserva la scena»)
> La collina è silenziosa, sembra essere tutto tornato alla normalità, ma la fonte è ancora da qualche parte...
>
> →

**`TUT.dopo_collina.scelta1`** · bottone di scelta
> Attraversa gli arbusti
>
> →

**`TUT.dopo_collina.scelta2`** · bottone di scelta
> Apri la mappa
>
> →


### Tutorial › `convergenza`

**`TUT.convergenza.1`** · battuta di Anonimo
> Le urla si fanno sempre più forti, devo essere vicino...
>
> →

**`TUT.convergenza.scena`** · quando ci torni («Osserva la scena»)
> Sono vicino. Lo sento.
>
> →

**`TUT.convergenza.scelta1`** · bottone di scelta
> Scatta verso i rumori
>
> →

**`TUT.convergenza.scelta2`** · bottone di scelta
> Torna alla collina
>
> →

**`TUT.convergenza.scelta3`** · bottone di scelta
> Torna alle pozze
>
> →


### Tutorial › `boss`

**`TUT.boss.1`** · narrazione
> Al centro di una piccola arena di pietra e fango, un goblin terribilmente arrabbiato ti aspetta, i pugni già stretti.
>
> →

**`TUT.boss.2`** · battuta di Un goblin terribilmente arrabbiato
> ?! ^?%&$!!
>
> →

**`TUT.boss.3`** · battuta di Anonimo
> Eccoti, facciamola finita.
>
> →

**`TUT.boss.4`** · battuta di Un goblin terribilmente arrabbiato
> Ah?! Ti carica a testa bassa!
>
> →


### Tutorial › `vittoria`

**`TUT.vittoria.1`** · narrazione
> Dopo lo scontro, il vento si placa e l'atmosfera sembra essere meno tesa: i livelli di disallineamento sono normali.
>
> →

**`TUT.vittoria.2`** · battuta di Anonimo
> Sembra essere tutto finito...
>
> →

**`TUT.vittoria.3`** · narrazione
> È ora di lasciare questo posto, altri compiti ti attendono.
>
> →

**`TUT.vittoria.scelta1`** · bottone di scelta
> Torna al quartier generale
>
> →


### Tutorial › `sconfitta`

**`TUT.sconfitta.1`** · narrazione
> Sconfitta totale, sei stato spazzato via.
>
> →

**`TUT.sconfitta.scelta1`** · bottone di scelta
> Rialzati e ricomincia
>
> →


### Tutorial › `sconfitta_manifestazione`

**`TUT.sconfitta_manifestazione.1`** · narrazione
> È ora di dormire, nei sogni ogni tuo desiderio diventa realtà...
>
> →

**`TUT.sconfitta_manifestazione.scelta1`** · bottone di scelta
> Rialzati e ricomincia
>
> →


### Tutorial › `hq_veronica_saluto`

**`TUT.hq_veronica_saluto.1`** · battuta di Veronica
> Heilà, sei tornato! Com'è andata la tua prima missione da solo? Scommetto che l'hai completata al massimo della potenza!
>
> →

**`TUT.hq_veronica_saluto.2`** · battuta di Anonimo
> Tutto come previsto.
>
> →

**`TUT.hq_veronica_saluto.3`** · battuta di Veronica
> BAHAHA! Certamente! Non c'era da aspettarsi di meno da te avendo un'allenatrice esplosiva come me, giusto?
>
> →

**`TUT.hq_veronica_saluto.4`** · battuta di Anonimo
> A proposito, oggi abbiamo un altro incontro vero?
>
> →

**`TUT.hq_veronica_saluto.5`** · battuta di Veronica
> Yes Baby! Non vedo l'ora di dare il massimo!
>
> →

**`TUT.hq_veronica_saluto.6`** · battuta di Veronica
> ...
>
> →

**`TUT.hq_veronica_saluto.7`** · battuta di Veronica
> Ma prima dovresti passare in sala riunioni, vogliono vederti per il rapporto...
>
> →

**`TUT.hq_veronica_saluto.8`** · battuta di Anonimo
> Immaginavo. Allora non perdo altro tempo.
>
> →

**`TUT.hq_veronica_saluto.9`** · battuta di Veronica
> "NON PERDO ALTRO TEMPO"!? Che cattivo.
>
> →

**`TUT.hq_veronica_saluto.10`** · battuta di Veronica
> Come puoi trattarmi in questo modo?
>
> →

**`TUT.hq_veronica_saluto.11`** · battuta di Veronica
> ...
>
> →

**`TUT.hq_veronica_saluto.12`** · battuta di Veronica
> Hey, mi stai ascoltando?
>
> →

**`TUT.hq_veronica_saluto.13`** · battuta di Anonimo
> Ci vediamo dopo per l'allenamento Veronica.
>
> →

**`TUT.hq_veronica_saluto.14`** · battuta di Veronica
> Che antipatico...
>
> →

**`TUT.hq_veronica_saluto.scelta1`** · bottone di scelta
> Vai in sala riunioni
>
> →


### Tutorial › `hq_sala_riunioni_1`

**`TUT.hq_sala_riunioni_1.1`** · battuta di Anonimo
> Eccomi. Unità UJ-111 a rapporto. Ho inoltrato la mia analisi sulla frattura e le osservazioni fatte sul campo come sempre.
>
> →

**`TUT.hq_sala_riunioni_1.2`** · narrazione
> Uno schermo oscurato si accende con un ronzio elettrico.
>
> →

**`TUT.hq_sala_riunioni_1.3`** · battuta di ??? (Organizzazione)
> Buongiorno unità UJ-111, ci rallegriamo di ritrovarti operativo e in ottima salute. Proseguiamo a renderti grazie per i tuoi sforzi e ti confermiamo il successo dell'operazione.
>
> →

**`TUT.hq_sala_riunioni_1.4`** · battuta di ??? (Organizzazione)
> Vanno corretti alcuni errori grammaticali nelle pratiche, errore trascurabile, ma ci teniamo a fartelo presente. Per il resto hai già disponibile nel tuo diario gli eventi che vanno completati nell'arco della giornata.
>
> →

**`TUT.hq_sala_riunioni_1.5`** · battuta di ??? (Organizzazione)
> Le ricordiamo che il suo Diario è sempre consultabile: in cima vi troverà gli appunti sui luoghi dove deve recarsi e su ciò che le viene chiesto strada facendo, e sotto le sue statistiche, quali sue abitudini la stanno facendo crescere, le creature che ha studiato, i legami con la squadra e la nostra valutazione sul suo operato.
>
> →

**`TUT.hq_sala_riunioni_1.6`** · narrazione
> Puoi aprire il Diario in qualunque momento premendo ESC: da lì passi anche allo storico di tutto quello che hai letto finora.
>
> →

**`TUT.hq_sala_riunioni_1.7`** · battuta di ??? (Organizzazione)
> Bene unità UJ-111, la nostra attuale istanza si ritira per deliberare. Complimenti per il suo recente successo, ci aspettiamo grandi cose da lei. Per aspera ad astra!
>
> →

**`TUT.hq_sala_riunioni_1.8`** · narrazione
> Lo schermo si spegne con un ronzio elettrico.
>
> →

**`TUT.hq_sala_riunioni_1.9`** · battuta di Anonimo
> Burocrazia...
>
> →

**`TUT.hq_sala_riunioni_1.10`** · battuta di Anonimo
> Adesso dovrei vedermi con Veronica per il mio ultimo allenamento... meglio non farla aspettare...
>
> →

**`TUT.hq_sala_riunioni_1.scelta1`** · bottone di scelta
> Vai ai campi di addestramento
>
> →


### Tutorial › `hq_training_grounds`

**`TUT.hq_training_grounds.1`** · battuta di Veronica
> Eccoti qui, al massimo della tua potenza spero. Sei pronto per un ultimo allenamento oltre ogni limite!?
>
> →

**`TUT.hq_training_grounds.2`** · battuta di Anonimo
> ...
>
> →

**`TUT.hq_training_grounds.3`** · battuta di Veronica
> Cos'è quella faccia, non mi sembri trasudare potenza...
>
> →

**`TUT.hq_training_grounds.4`** · battuta di Anonimo
> Hai troppo entusiasmo, la cosa mi imbarazza.
>
> →

**`TUT.hq_training_grounds.5`** · battuta di Veronica
> SEMPRE! Che senso ha vivere se non lo si fa superando ogni limite conosciuto ogni singolo giorno?
>
> →

**`TUT.hq_training_grounds.6`** · battuta di Anonimo
> Sigh...
>
> →

**`TUT.hq_training_grounds.7`** · battuta di Veronica
> Basta con le chiacchiere fai parlare i pugni adesso! Le cose si fanno serie. Preparati.
>
> →

**`TUT.hq_training_grounds.scelta1`** · bottone di scelta
> Affronta l'allenamento
>
> →


### Tutorial › `hq_scontro_veronica`

**`TUT.hq_scontro_veronica.1`** · narrazione
> Veronica si mette in posizione. Questo non è un discorso: è un allenamento, e tocca a te muoverti.
>
> →


### Tutorial › `hq_infermeria`

**`TUT.hq_infermeria.1`** · narrazione
> Ti risvegli in infermeria.
>
> →

**`TUT.hq_infermeria.2`** · battuta di Dott.ssa Curie Heartlife
> Ben svegliato, a pezzi come sempre vedo...
>
> →

**`TUT.hq_infermeria.3`** · battuta di Anonimo
> Solito allenamento con Veronica...
>
> →

**`TUT.hq_infermeria.4`** · battuta di Dott.ssa Curie Heartlife
> Se non fossi un dominatore di limiti saresti già morto, lo sai?
>
> →

**`TUT.hq_infermeria.5`** · battuta di Anonimo
> ...
>
> →

**`TUT.hq_infermeria.6`** · battuta di Anonimo
> Non ho mai capito perché io e Veronica abbiamo questa... fortuna?
>
> →

**`TUT.hq_infermeria.7`** · battuta di Dott.ssa Curie Heartlife
> Beh dovresti saperlo... solo individui con una forte forza di volontà e una fortunata costituzione diventano dominatori... Non è una fortuna, è un destino.
>
> →

**`TUT.hq_infermeria.8`** · battuta di Anonimo
> Anche lei è una dominatrice se ricordo bene...
>
> →

**`TUT.hq_infermeria.9`** · battuta di Dott.ssa Curie Heartlife
> Sì, ma non tutti i dominatori sono fatti per il combattimento: io sono specializzata nelle cure e nella conoscenza. Non mi sognerei mai di andarmene a zonzo per l'universo a... beh... lo sai... io non sono molto a favore della violenza...
>
> →

**`TUT.hq_infermeria.10`** · battuta di Anonimo
> Qualcuno purtroppo deve farlo...
>
> →

**`TUT.hq_infermeria.11`** · battuta di Dott.ssa Curie Heartlife
> Apprezzo quel che fate...
>
> →

**`TUT.hq_infermeria.12`** · battuta di Dott.ssa Curie Heartlife
> Ah! Dimenticavo, devi recarti nella sala riunioni: ti hanno affidato un bell'incarico...
>
> →

**`TUT.hq_infermeria.13`** · battuta di Dott.ssa Curie Heartlife
> Spero di non rivederti presto da queste parti <3
>
> →

**`TUT.hq_infermeria.14`** · battuta di Anonimo
> Un bell'incarico... Penso che siamo destinati a rivederci.
>
> →

**`TUT.hq_infermeria.15`** · battuta di Dott.ssa Curie Heartlife
> È inevitabile...
>
> →

**`TUT.hq_infermeria.scelta1`** · bottone di scelta
> Vai in sala riunioni
>
> →


### Tutorial › `hq_sala_riunioni_2`

**`TUT.hq_sala_riunioni_2.1`** · battuta di ??? (Organizzazione)
> Salve candidato, abbiamo analizzato i suoi dati, e siamo sicuri, oltre una certa soglia, che lei sia un candidato affidabile e adatto a farsi carico di alcune questioni abbastanza importanti...
>
> →

**`TUT.hq_sala_riunioni_2.2`** · battuta di ??? (Organizzazione)
> Come ben sa, il numero di dominatori è calato drasticamente di questi tempi e sempre più mondi e realtà vengono compromessi a causa delle anomalie che stiamo studiando...
>
> →

**`TUT.hq_sala_riunioni_2.3`** · battuta di ??? (Organizzazione)
> Non vogliamo compromettere la sua salute e la sua integrità, ma allo stesso tempo abbiamo bisogno che lei affini le sue abilità con alcuni casi di minore entità.
>
> →

**`TUT.hq_sala_riunioni_2.4`** · battuta di ??? (Organizzazione)
> Abbiamo aggiornato nelle sue planimetrie i luoghi d'interesse dove ci sarebbe bisogno di effettuare dei rilevamenti importanti, così come un punto anomalo dove i livelli di allineamento sono fuori controllo ma non in modo preoccupante: siamo sicuri che saprà gestire la situazione. Ha qualcosa da riferire?
>
> →

**`TUT.hq_sala_riunioni_2.scena`** · quando ci torni («Osserva la scena»)
> Lo schermo oscurato aspetta. Non ha fretta.
>
> →

**`TUT.hq_sala_riunioni_2.scelta1`** · bottone di scelta
> Come mai mi trovo qui?
>
> →

**`TUT.hq_sala_riunioni_2.scelta2`** · bottone di scelta
> Cosa sono i dominatori in realtà?
>
> →

**`TUT.hq_sala_riunioni_2.scelta3`** · bottone di scelta
> Da quanto tempo sta succedendo tutto questo?
>
> →

**`TUT.hq_sala_riunioni_2.scelta4`** · bottone di scelta
> Nessuna domanda. Parto immediatamente.
>
> →


### Tutorial › `hq_domanda_perche`

**`TUT.hq_domanda_perche.1`** · battuta di ??? (Organizzazione)
> Lei è qui per essere studiato e per compiere il suo dovere in quanto dominatore, ovviamente. Senza di lei sarebbe impossibile tornare a quella che un tempo veniva chiamata "normalità". Insieme a lei altre unità sono attualmente accolte dalle nostre strutture sparse lungo tutto il cosmo. Non deve sentirsi solo.
>
> →

**`TUT.hq_domanda_perche.2`** · battuta di ??? (Organizzazione)
> Ha altro che le preme chiedere?
>
> →

**`TUT.hq_domanda_perche.scelta1`** · bottone di scelta
> Come mai mi trovo qui?
>
> →

**`TUT.hq_domanda_perche.scelta2`** · bottone di scelta
> Cosa sono i dominatori in realtà?
>
> →

**`TUT.hq_domanda_perche.scelta3`** · bottone di scelta
> Da quanto tempo sta succedendo tutto questo?
>
> →

**`TUT.hq_domanda_perche.scelta4`** · bottone di scelta
> Nessuna domanda. Parto immediatamente.
>
> →


### Tutorial › `hq_domanda_dominatori`

**`TUT.hq_domanda_dominatori.1`** · battuta di ??? (Organizzazione)
> Quello che noi definiamo come "Dominatore" è un soggetto con particolari capacità di resilienza, capace di adattarsi a diverse situazioni grazie a quello che noi pensiamo essere stato "un vissuto particolarmente travagliato".
>
> →

**`TUT.hq_domanda_dominatori.2`** · battuta di ??? (Organizzazione)
> Vi contraddistinguono ottime doti di resistenza allo stress e una strana energia che nasce dai vostri sentimenti negativi, che solo voi siete capaci di dominare e trasformare in forza. Per questo vi chiamiamo "Dominatori".
>
> →

**`TUT.hq_domanda_dominatori.3`** · battuta di ??? (Organizzazione)
> Ha altro che le preme chiedere?
>
> →

**`TUT.hq_domanda_dominatori.scelta1`** · bottone di scelta
> Come mai mi trovo qui?
>
> →

**`TUT.hq_domanda_dominatori.scelta2`** · bottone di scelta
> Cosa sono i dominatori in realtà?
>
> →

**`TUT.hq_domanda_dominatori.scelta3`** · bottone di scelta
> Da quanto tempo sta succedendo tutto questo?
>
> →

**`TUT.hq_domanda_dominatori.scelta4`** · bottone di scelta
> Nessuna domanda. Parto immediatamente.
>
> →


### Tutorial › `hq_domanda_quando`

**`TUT.hq_domanda_quando.1`** · battuta di ??? (Organizzazione)
> Secondo i nostri registri, basandoci su un primitivo calendario di un pianeta chiamato "Terra" che fu il primo caso di disallineamento nella storia... si parla di ormai più di qualche migliaio di anni...
>
> →

**`TUT.hq_domanda_quando.2`** · battuta di ??? (Organizzazione)
> Calcolando stima...
>
> →

**`TUT.hq_domanda_quando.3`** · battuta di ??? (Organizzazione)
> ...
>
> →

**`TUT.hq_domanda_quando.4`** · battuta di ??? (Organizzazione)
> ... ... ...
>
> →

**`TUT.hq_domanda_quando.5`** · battuta di ??? (Organizzazione)
> Esattamente 3696 anni su base terrestre, 245 giorni, 22 ore, 31 minuti e 59 secondi.
>
> →

**`TUT.hq_domanda_quando.6`** · battuta di ??? (Organizzazione)
> Ha altro che le preme chiedere?
>
> →

**`TUT.hq_domanda_quando.scelta1`** · bottone di scelta
> Come mai mi trovo qui?
>
> →

**`TUT.hq_domanda_quando.scelta2`** · bottone di scelta
> Cosa sono i dominatori in realtà?
>
> →

**`TUT.hq_domanda_quando.scelta3`** · bottone di scelta
> Da quanto tempo sta succedendo tutto questo?
>
> →

**`TUT.hq_domanda_quando.scelta4`** · bottone di scelta
> Nessuna domanda. Parto immediatamente.
>
> →


### Tutorial › `hq_congedo`

**`TUT.hq_congedo.1`** · battuta di Anonimo
> No, non ho altre domande... Parto immediatamente.
>
> →

**`TUT.hq_congedo.2`** · battuta di ??? (Organizzazione)
> Ottimo, sapevamo di poter contare su di lei, candidato. Per aspera ad astra!
>
> →

**`TUT.hq_congedo.scelta1`** · bottone di scelta
> Torna alla mappa stellare
>
> →


## Lo Squarcio Industriale

<sub>`data/vuoti/squarcio_industriale.json`</sub>


### Lo Squarcio Industriale › `varco`

**`IND.varco.1`** · narrazione
> Lo squarcio si richiude alle tue spalle con un sospiro di vapore. Un tetro colore rosso pervade la stanza, vagamente illuminata da qualche sprazzo di luce proveniente da chissà dove. Corridoi stretti, e un odore di olio consumato misto a ferro.
>
> →

**`IND.varco.2`** · battuta di Anonimo
> Strano... non riesco a percepire in modo distinto se ci sia una fonte o meno...
>
> →

**`IND.varco.3`** · battuta di Anonimo
> Questo posto mette una pressione particolare... qualcosa di terribile è successo qui...
>
> →

**`IND.varco.scena`** · quando ci torni («Osserva la scena»)
> La luce rossa, i corridoi stretti, l'olio consumato. Lo squarcio è alle tue spalle.
>
> →

**`IND.varco.scelta1`** · bottone di scelta
> Addentrati nel complesso
>
> →

**`IND.varco.scelta2`** · bottone di scelta (esce dallo squarcio)
> Torna nel Vuoto
>
> →


### Lo Squarcio Industriale › `corridoi_stretti`

**`IND.corridoi_stretti.1`** · battuta di Anonimo
> Questa zona sembrerebbe essere abbandonata... eppure nell'aria riesco a percepire un lieve sentore di pericolo...
>
> →

**`IND.corridoi_stretti.2`** · narrazione
> Attraversi lunghi corridoi illuminati da luci che si accendono e si spengono... Il silenzio fa spazio a nuovi rumori meccanici, come se ci fossero dei macchinari in moto. In fondo all'ultimo corridoio, una luce rossa illumina il percorso.
>
> →

**`IND.corridoi_stretti.scena`** · quando ci torni («Osserva la scena»)
> Corridoi stretti, luci a intermittenza. In fondo, una luce rossa.
>
> →

**`IND.corridoi_stretti.scelta1`** · bottone di scelta
> Prosegui verso la luce rossa
>
> →

**`IND.corridoi_stretti.scelta2`** · bottone di scelta
> Torna al varco
>
> →


### Lo Squarcio Industriale › `corridoi_stretti_dopo`

**`IND.corridoi_stretti_dopo.1`** · narrazione
> I corridoi sono gli stessi. Le luci continuano ad accendersi e spegnersi, senza nessuno che le guardi.
>
> →

**`IND.corridoi_stretti_dopo.scena`** · quando ci torni («Osserva la scena»)
> Corridoi stretti, luci a intermittenza. In fondo, una luce rossa.
>
> →

**`IND.corridoi_stretti_dopo.scelta1`** · bottone di scelta
> Prosegui verso la sala vetrata
>
> →

**`IND.corridoi_stretti_dopo.scelta2`** · bottone di scelta
> Torna al varco
>
> →


### Lo Squarcio Industriale › `sala_vetrata`

**`IND.sala_vetrata.1`** · narrazione
> Nella stanza tutto è illuminato da una fioca luce rossa. Lungo i lati, vari schermi con messaggi di errore muoiono e si riattivano in continuazione...
>
> →

**`IND.sala_vetrata.2`** · narrazione
> Sul lato noti una gigantesca finestra su una stanza dove un macchinario continua a produrre piccoli pezzi meccanici...
>
> →

**`IND.sala_vetrata.3`** · battuta di Anonimo
> Sembrerebbe che la produzione non sia mai stata dismessa... Non riesco a distinguere bene cosa viene prodotto, da quassù...
>
> →

**`IND.sala_vetrata.4`** · battuta di Anonimo
> ... Cos'era quel rumore?
>
> →

**`IND.sala_vetrata.5`** · narrazione
> Dalla botola in alto qualcosa ti osserva. Non ti eri neanche accorto della sua presenza...
>
> →

**`IND.sala_vetrata.6`** · battuta di Robo Pattuglia
> 01001111 01010011 01010011 01000101 01010010 01010110 01000001 01011010 01001001 01001111 01001110 01000101 00100000 01000100 01000101 01001100 00100000 01010011 01001111 01000111 01000111 01000101 01010100 01010100 01001111 00100000 01000011 01001111 01001110 01000011 01001100 01010101 01010011 01000001
>
> →

**`IND.sala_vetrata.7`** · battuta di Robo Pattuglia
> 01001001 01101101 01110000 01101111 01110011 01110100 01100001 01111010 01101001 01101111 01101110 01100101 00100000 01100100 01100101 01101100 00100000 01101100 01101001 01101110 01100111 01110101 01100001 01100111 01100111 01101001 01101111 00100000 01100011 01101111 01101101 01110000 01101100 01100101 01110100 01100001 01110100 01100001
>
> →

**`IND.sala_vetrata.8`** · battuta di Robo Pattuglia
> BUONGIORNO VISITATORE, PURTROPPO IL COMPLESSO E' ATTUALMENTE CHIUSO.
>
> →

**`IND.sala_vetrata.9`** · battuta di Robo Pattuglia
> DOVRO' TERMINARLA.
>
> →


### Lo Squarcio Industriale › `sala_vetrata_dopo`

**`IND.sala_vetrata_dopo.1`** · narrazione
> Il macchinario continua a produrre, oltre la vetrata. La botola in alto è aperta e non ne scende più niente.
>
> →

**`IND.sala_vetrata_dopo.scena`** · quando ci torni («Osserva la scena»)
> La luce rossa, gli schermi che muoiono e si riaccendono, la vetrata sulla catena di montaggio.
>
> →

**`IND.sala_vetrata_dopo.scelta1`** · bottone di scelta
> Avanza nel corridoio dei tubi
>
> →

**`IND.sala_vetrata_dopo.scelta2`** · bottone di scelta
> Torna ai corridoi
>
> →


### Lo Squarcio Industriale › `dopo_robo`

**`IND.dopo_robo.1`** · battuta di Anonimo
> Non mi ero neanche accorto di essere osservato... D'altronde era una macchina: non ha una natura malvagia, esegue solo i comandi che le vengono dati...
>
> →

**`IND.dopo_robo.2`** · battuta di Anonimo
> Sembra esserci un percorso da questa parte, tra i tubi...
>
> →

**`IND.dopo_robo.scena`** · quando ci torni («Osserva la scena»)
> La luce rossa, gli schermi che muoiono e si riaccendono, la vetrata sulla catena di montaggio.
>
> →

**`IND.dopo_robo.scelta1`** · bottone di scelta
> Avanza nel corridoio dei tubi
>
> →

**`IND.dopo_robo.scelta2`** · bottone di scelta
> Torna ai corridoi
>
> →


### Lo Squarcio Industriale › `corridoio_tubi`

**`IND.corridoio_tubi.1`** · narrazione
> Il corridoio termina in un'altra piccola stanza dismessa... Tubi e valvole in ogni direzione, alcuni ancora caldi. Da qualche parte un programma si accende, borbotta qualcosa, si rispegne.
>
> →

**`IND.corridoio_tubi.scena`** · quando ci torni («Osserva la scena»)
> La piccola stanza dismessa in fondo al corridoio dei tubi.
>
> →

**`IND.corridoio_tubi.scelta1`** · bottone di scelta (fa raccogliere Viti e bulloni)
> Fruga in un armadietto arrugginito
>
> →

**`IND.corridoio_tubi.scelta2`** · bottone di scelta
> Addentrati ancora di più nel complesso
>
> →

**`IND.corridoio_tubi.scelta3`** · bottone di scelta
> Torna al varco
>
> →


### Lo Squarcio Industriale › `corridoio_tubi_aperto`

**`IND.corridoio_tubi_aperto.1`** · narrazione
> La piccola stanza dismessa in fondo al corridoio dei tubi. Adesso che sai dove guardare, sopra le tre entrate c'è scritto qualcosa: «sala delle valvole», «Deposito», «Sala informatica».
>
> →

**`IND.corridoio_tubi_aperto.scena`** · quando ci torni («Osserva la scena»)
> La piccola stanza dismessa: tre entrate, e sopra ognuna una targa.
>
> →

**`IND.corridoio_tubi_aperto.scelta1`** · bottone di scelta (fa raccogliere Viti e bulloni)
> Fruga in un armadietto arrugginito
>
> →

**`IND.corridoio_tubi_aperto.scelta2`** · bottone di scelta
> Verso la sala delle valvole
>
> →

**`IND.corridoio_tubi_aperto.scelta3`** · bottone di scelta
> Entra nel deposito
>
> →

**`IND.corridoio_tubi_aperto.scelta4`** · bottone di scelta
> Sali alla sala informatica
>
> →

**`IND.corridoio_tubi_aperto.scelta5`** · bottone di scelta
> Torna nei corridoi infiniti
>
> →

**`IND.corridoio_tubi_aperto.scelta6`** · bottone di scelta
> Pianta un proiettore nella stanza dei tubi
>
> →

**`IND.corridoio_tubi_aperto.scelta7`** · bottone di scelta
> Torna al varco
>
> →


### Lo Squarcio Industriale › `corridoi_infiniti`

**`IND.corridoi_infiniti.1`** · battuta di Anonimo
> Questo posto sembra non finire mai, e continuo a non percepire nulla... eppure qualcosa di strano si cela in questa frattura... meglio continuare a raccogliere dati...
>
> →

**`IND.corridoi_infiniti.2`** · narrazione
> I corridoi si intrecciano e sembrano essere infiniti, ma a un certo punto davanti a te compare una porta che sembra cedere facilmente...
>
> →

**`IND.corridoi_infiniti.3`** · battuta di Anonimo
> Sembra facile da abbattere...
>
> →

**`IND.corridoi_infiniti.scena`** · quando ci torni («Osserva la scena»)
> Corridoi che si intrecciano senza fine. Davanti a te, una porta che non oppone molta resistenza.
>
> →

**`IND.corridoi_infiniti.scelta1`** · bottone di scelta
> Abbatti la porta
>
> →

**`IND.corridoi_infiniti.scelta2`** · bottone di scelta
> Torna indietro fra i tubi
>
> →


### Lo Squarcio Industriale › `corridoi_infiniti_dopo`

**`IND.corridoi_infiniti_dopo.1`** · narrazione
> I corridoi si intrecciano sempre allo stesso modo. In fondo, il vano vuoto della porta che hai buttato giù.
>
> →

**`IND.corridoi_infiniti_dopo.scena`** · quando ci torni («Osserva la scena»)
> Corridoi che si intrecciano senza fine. In fondo, il vano vuoto della porta abbattuta.
>
> →

**`IND.corridoi_infiniti_dopo.scelta1`** · bottone di scelta
> Entra nella stanza degli schermi
>
> →

**`IND.corridoi_infiniti_dopo.scelta2`** · bottone di scelta
> Torna indietro fra i tubi
>
> →


### Lo Squarcio Industriale › `sala_sorveglianza`

**`IND.sala_sorveglianza.1`** · narrazione
> Qualcosa nell'aria sembra aver reagito al suono della porta che cadeva per terra...
>
> →

**`IND.sala_sorveglianza.2`** · battuta di Anonimo
> ...
>
> →

**`IND.sala_sorveglianza.3`** · battuta di Anonimo
> Sembra che qualcosa sia cambiato in questo posto... C'è davvero qualcosa in questo posto...
>
> →

**`IND.sala_sorveglianza.4`** · narrazione
> Al centro della stanza ci sono vari schermi dai quali riesci a vedere diverse angolazioni di te stesso... Nel computer sul lato destro sembrano esserci aperti dei file...
>
> →

**`IND.sala_sorveglianza.scena`** · quando ci torni («Osserva la scena»)
> Gli schermi che ti riprendono da ogni angolazione. Sulla destra, il computer con i file aperti.
>
> →

**`IND.sala_sorveglianza.scelta1`** · bottone di scelta
> Leggi i file
>
> →

**`IND.sala_sorveglianza.scelta2`** · bottone di scelta
> Torna indietro fra i corridoi
>
> →


### Lo Squarcio Industriale › `file_computer`

**`IND.file_computer.1`** · narrazione
> Pagina 1 di 6. «Rapporto interno, riservato alla direzione. Reparto montaggio: media di sedici ore per turno. Richieste di sostituzione presentate nel trimestre: quarantuno. Richieste accolte: nessuna.»
>
> →

**`IND.file_computer.2`** · narrazione
> Pagina 2 di 6. «Il personale del turno di notte riferisce di sentire la catena muoversi a impianto spento. Il fenomeno non risulta da nessuna rilevazione strumentale. Provvedimento adottato: sospensione delle pause non necessarie.»
>
> →

**`IND.file_computer.3`** · narrazione
> Pagina 3 di 6. «Allegato fotografico. Reparto montaggio, ultimo giorno documentato.»
>
> →

**`IND.file_computer.4`** · didascalia dell'illustrazione `art/illustrazioni/file_reparto_montaggio.png`
> In fila davanti alla catena ci sono più uomini di quanti quel reparto potesse contenerne. Nessuno guarda l'obiettivo.
>
> →

**`IND.file_computer.5`** · narrazione
> Alle tue spalle una sedia raschia il pavimento. C'era qualcuno seduto a quel computer, e non se n'era mai andato.
>
> →


### Lo Squarcio Industriale › `dopo_operaio`

**`IND.dopo_operaio.1`** · battuta di Anonimo
> Sembrerebbe che questo posto fosse un inferno per i lavoratori... Nello scontro il computer è rimasto danneggiato... è impossibile continuare la lettura, se solo avessi uno strumento per recuperare i file...
>
> →

**`IND.dopo_operaio.2`** · battuta di Anonimo
> Non c'è altro da fare qui... posso proseguire oltre in tre direzioni... sulle varie entrate c'è scritto qualcosa...
>
> →

**`IND.dopo_operaio.scena`** · quando ci torni («Osserva la scena»)
> Gli schermi che ti riprendono da ogni angolazione. Il computer sulla destra, adesso spento e annerito.
>
> →

**`IND.dopo_operaio.scelta1`** · bottone di scelta
> Torna indietro fra i tubi
>
> →


### Lo Squarcio Industriale › `sala_sorveglianza_dopo`

**`IND.sala_sorveglianza_dopo.1`** · narrazione
> Gli schermi continuano a riprenderti da ogni angolazione. Il computer sulla destra è spento e annerito: quello che c'era dentro è ancora lì, ma non da questa parte dello schermo.
>
> →

**`IND.sala_sorveglianza_dopo.2`** · battuta di Anonimo
> Senza uno strumento adatto, quei file restano dove sono.
>
> →

**`IND.sala_sorveglianza_dopo.scena`** · quando ci torni («Osserva la scena»)
> Gli schermi che ti riprendono da ogni angolazione. Il computer sulla destra, adesso spento e annerito.
>
> →

**`IND.sala_sorveglianza_dopo.scelta1`** · bottone di scelta
> Torna indietro fra i corridoi
>
> →


### Lo Squarcio Industriale › `deposito`

**`IND.deposito.1`** · narrazione
> Un vecchio deposito abbandonato: sembra che qualcuno ci sia vissuto per un breve periodo...
>
> →

**`IND.deposito.scena`** · quando ci torni («Osserva la scena»)
> Il vecchio deposito. Scaffali piegati dal caldo, casse sventrate.
>
> →

**`IND.deposito.scelta1`** · bottone di scelta (fa raccogliere Fiala HP, Fiala HP)
> Fruga nella cassa marchiata con una croce
>
> →

**`IND.deposito.scelta2`** · bottone di scelta (fa raccogliere Viti e bulloni)
> Svuota il barattolo di minuteria
>
> →

**`IND.deposito.scelta3`** · bottone di scelta
> Solleva la mattonella smossa
>
> →

**`IND.deposito.scelta4`** · bottone di scelta (fa raccogliere Viti e bulloni)
> Svita una piastra di rivestimento
>
> →

**`IND.deposito.scelta5`** · bottone di scelta
> Torna nel corridoio
>
> →


### Lo Squarcio Industriale › `sala_valvole`

**`IND.sala_valvole.1`** · narrazione
> Ti ritrovi in una sala piena di valvole e tubi che perdono in continuazione...
>
> →

**`IND.sala_valvole.scena`** · quando ci torni («Osserva la scena»)
> La sala delle valvole: ruote di metallo grandi come carri, e perdite dappertutto.
>
> →

**`IND.sala_valvole.scelta1`** · bottone di scelta (fa raccogliere Viti e bulloni)
> Recupera i bulloni caduti da una valvola
>
> →

**`IND.sala_valvole.scelta2`** · bottone di scelta
> Sali verso la sala informatica
>
> →

**`IND.sala_valvole.scelta3`** · bottone di scelta
> Segui il nastro trasportatore
>
> →

**`IND.sala_valvole.scelta4`** · bottone di scelta
> Pianta un proiettore nella sala delle valvole
>
> →

**`IND.sala_valvole.scelta5`** · bottone di scelta
> Torna nel corridoio
>
> →


### Lo Squarcio Industriale › `sala_schede`

**`IND.sala_schede.1`** · narrazione
> Le pareti di questa stanza sono adornate con circuiti e fili che si perdono sull'alto soffitto, un assordante rumore elettrico pervade ogni angolo di questa stanza. In fondo sembra esserci una porta con scritto «centro di controllo».
>
> →

**`IND.sala_schede.scena`** · quando ci torni («Osserva la scena»)
> La sala informatica: circuiti alle pareti, e in fondo la porta del centro di controllo.
>
> →

**`IND.sala_schede.scelta1`** · bottone di scelta (fa raccogliere Misterioso componente elettronico)
> Stacca il componente che lampeggia verso l'alto
>
> →

**`IND.sala_schede.scelta2`** · bottone di scelta (fa raccogliere Fiala HP)
> Recupera la fiala incastrata tra i condensatori
>
> →

**`IND.sala_schede.scelta3`** · bottone di scelta
> Scendi al vecchio centro di controllo
>
> →

**`IND.sala_schede.scelta4`** · bottone di scelta
> Torna alle valvole
>
> →

**`IND.sala_schede.scelta5`** · bottone di scelta
> Torna nel corridoio
>
> →


### Lo Squarcio Industriale › `centro_controllo`

**`IND.centro_controllo.1`** · battuta di Anonimo
> Sembrerebbe un vecchio centro di controllo... sopra quella scrivania ci sono vari documenti...
>
> →

**`IND.centro_controllo.scena`** · quando ci torni («Osserva la scena»)
> Il vecchio centro di controllo: monitor spenti, un'unica poltrona, e i diari sulla scrivania.
>
> →

**`IND.centro_controllo.scelta1`** · bottone di scelta
> Leggi il primo diario
>
> →

**`IND.centro_controllo.scelta2`** · bottone di scelta
> Leggi il secondo diario
>
> →

**`IND.centro_controllo.scelta3`** · bottone di scelta
> Leggi il terzo diario
>
> →

**`IND.centro_controllo.scelta4`** · bottone di scelta
> Apri il cassetto della scrivania
>
> →

**`IND.centro_controllo.scelta5`** · bottone di scelta
> Torna alla sala informatica
>
> →


### Lo Squarcio Industriale › `diario_1`

**`IND.diario_1.1`** · narrazione
> «Giorno 1. Il complesso è operativo. Ho detto ai capisquadra che voglio efficienza, non lamentele. Sfortunatamente nessuno sembra capire l'importanza di questo progetto... perché sono tutti così restii a lavorare? Eppure sono io quello che ha investito i migliori anni della sua vita per creare questo posto... ingrati. Sono tutti ingrati.»
>
> →

**`IND.diario_1.scelta1`** · bottone di scelta
> Richiudi il diario
>
> →


### Lo Squarcio Industriale › `diario_2`

**`IND.diario_2.1`** · narrazione
> «Tre operai non si sono presentati oggi. Il caporeparto dice che ne ha abbastanza di come viene gestito questo posto. Ho ordinato di aumentare i turni ai restanti, per compensare. Non possiamo permetterci ritardi sulle consegne. Come mai non capiscono che è ora il momento di impegnarsi di più? Sono tutti dannatamente pigri...»
>
> →

**`IND.diario_2.scelta1`** · bottone di scelta
> Richiudi il diario
>
> →


### Lo Squarcio Industriale › `diario_3`

**`IND.diario_3.1`** · narrazione
> «Questo posto sembra essere destinato alla rovina, quei maledetti del sindacato sono riusciti a rovinarmi. Ma non gliela darò vinta... Sono io che ho creato tutto questo! Mi rifiuto di perdere tutti questi progressi... Non chiuderò l'impianto. Sposterò la produzione altrove. Questo posto, ormai, può anche andare in malora: recupererò i dati e troverò un nuovo posto da dove ricominciare...»
>
> →

**`IND.diario_3.scelta1`** · bottone di scelta
> Richiudi il diario
>
> →


### Lo Squarcio Industriale › `nastro`

**`IND.nastro.1`** · narrazione
> Il nastro trasportatore corre ancora, a vuoto.
>
> →

**`IND.nastro.scena`** · quando ci torni («Osserva la scena»)
> Il nastro trasportatore che corre a vuoto. Il caldo, qui, toglie il respiro.
>
> →

**`IND.nastro.scelta1`** · bottone di scelta (fa raccogliere Benzina)
> Prendi la tanica di benzina sotto il rullo
>
> →

**`IND.nastro.scelta2`** · bottone di scelta (fa raccogliere Molotov)
> Raccogli la bottiglia artigianale
>
> →

**`IND.nastro.scelta3`** · bottone di scelta
> Segui il nastro fino al cuore del complesso
>
> →

**`IND.nastro.scelta4`** · bottone di scelta
> Torna alle valvole
>
> →


### Lo Squarcio Industriale › `cuore`

**`IND.cuore.1`** · battuta di Anonimo
> Sembra che questo sia il cuore del complesso... ci sono vari nomi incisi sui macchinari distrutti.
>
> →

**`IND.cuore.2`** · battuta di Anonimo
> E qui... Un'insegna sbiadita, illeggibile: KI...O IND..TR.ES. Sembra essere tutto andato in malora... Qualcuno deve aver tentato di distruggere questo posto.
>
> →

**`IND.cuore.3`** · battuta di Anonimo
> Più avanti sento dei rumori... sembra una discarica gigantesca...
>
> →

**`IND.cuore.scena`** · quando ci torni («Osserva la scena»)
> Il cuore del complesso: la turbina ferma, i nomi incisi sulle pale, l'insegna sbiadita.
>
> →

**`IND.cuore.scelta1`** · bottone di scelta
> Apri la cassetta
>
> →

**`IND.cuore.scelta2`** · bottone di scelta (fa raccogliere Fiala HP)
> Cerca tra i macchinari distrutti
>
> →

**`IND.cuore.scelta3`** · bottone di scelta
> Esci nel piazzale della grande discarica
>
> →

**`IND.cuore.scelta4`** · bottone di scelta
> Pianta un proiettore nel cuore del complesso
>
> →

**`IND.cuore.scelta5`** · bottone di scelta
> Torna al nastro
>
> →


### Lo Squarcio Industriale › `discarica`

**`IND.discarica.1`** · battuta di Anonimo
> Incredibile, i rottami si estendono a perdita d'occhio. Sento dei lievi tremori provenire da sottoterra... questo posto non è sicuro...
>
> →

**`IND.discarica.scena`** · quando ci torni («Osserva la scena»)
> Il piazzale a cielo aperto: montagne di rottami, e il sole rosso che ci batte sopra.
>
> →

**`IND.discarica.scelta1`** · bottone di scelta (fa raccogliere Rottame di metallo)
> Rovista tra i rottami più vicini
>
> →

**`IND.discarica.scelta2`** · bottone di scelta (fa raccogliere Rottame di metallo)
> Scava sotto una montagna di lamiere
>
> →

**`IND.discarica.scelta3`** · bottone di scelta
> Controlla un container ribaltato
>
> →

**`IND.discarica.scelta4`** · bottone di scelta
> Va' verso la struttura tonda più in fondo
>
> →

**`IND.discarica.scelta5`** · bottone di scelta
> Torna al cuore del complesso
>
> →


### Lo Squarcio Industriale › `padiglione_e`

**`IND.padiglione_e.1`** · battuta di Anonimo
> Cosa ci fa questo padiglione in mezzo alla discarica? Sembra esserci un'entrata sotterranea gigantesca... impossibile da aprire...
>
> →

**`IND.padiglione_e.scena`** · quando ci torni («Osserva la scena»)
> Il Padiglione: una struttura tonda enorme, e un unico portello sigillato sul fondo.
>
> →

**`IND.padiglione_e.scelta1`** · bottone di scelta
> Prova a forzare il portello
>
> →

**`IND.padiglione_e.scelta2`** · bottone di scelta
> Torna alla discarica
>
> →


### Lo Squarcio Industriale › `padiglione_e_chiuso`

**`IND.padiglione_e_chiuso.1`** · battuta di Anonimo
> Non si muove di un millimetro: qualunque cosa lo tenga chiuso, non è fatta per cedere a mani nude. Qualunque cosa ci sia sotto, doveva essere tenuta nascosta. Sarà meglio fare rapporto all'organizzazione...
>
> →

**`IND.padiglione_e_chiuso.scelta1`** · bottone di scelta
> Torna al padiglione
>
> →


### Lo Squarcio Industriale › `espulso`

**`IND.espulso.1`** · narrazione
> Le macerie ti schiacciano... il tuo destino è deciso, diventi un tutt'uno con i rottami... dimenticato per sempre sotto quel sole rosso, per l'eternità...
>
> →

**`IND.espulso.scelta1`** · bottone di scelta (esce dallo squarcio)
> Riprendi fiato nel Vuoto
>
> →


## Meridia

<sub>`data/vuoti/meridia.json`</sub>


### Meridia › `varco`

**`MER.varco.1`** · narrazione
> Lo squarcio si apre sulla cima di una collina che affaccia su un'enorme città. Varie ombre si muovono in lontananza, lente... la terra trema... l'aria è umida, e una leggera brezza porta il tipico odore di morte che contraddistingue le terre marcite. Il sole è nascosto da una nube densa e minacciosa, che rende tutta la zona fredda e buia.
>
> →

**`MER.varco.2`** · battuta di Anonimo
> Questo posto trasmette una desolazione tremenda...
>
> →

**`MER.varco.scena`** · quando ci torni («Osserva la scena»)
> La collina sopra Meridia. Sotto di te la città, e le ombre che si muovono piano.
>
> →

**`MER.varco.scelta1`** · bottone di scelta
> Scendi verso le strade di periferia
>
> →

**`MER.varco.scelta2`** · bottone di scelta (esce dallo squarcio)
> Torna nel Vuoto
>
> →


### Meridia › `periferia`

**`MER.periferia.1`** · narrazione
> Lungo queste strade non ci sono segni di vita... tutto è marcio, tutto dimenticato da tempo. Anche all'aperto una sottile polvere permea l'aria, rendendola difficile da respirare... tuttavia non sembra ancora essere nociva.
>
> →

**`MER.periferia.scena`** · quando ci torni («Osserva la scena»)
> Le strade di periferia. La polvere sospesa, e niente che si muova.
>
> →

**`MER.periferia.scelta1`** · bottone di scelta
> Prosegui verso l'ingresso della città
>
> →

**`MER.periferia.scelta2`** · bottone di scelta
> Torna al varco
>
> →


### Meridia › `ingresso_citta`

**`MER.ingresso_citta.1`** · battuta di Anonimo
> Da qui è possibile entrare in questa città... i livelli di disallineamento sono alle stelle. Per ora il mio compito consiste solo nello studiare il quartiere est...
>
> →

**`MER.ingresso_citta.2`** · battuta di Anonimo
> Sembrerebbe che l'Organizzazione stia studiando questo posto già da tempo. Nonostante la fonte sia stata estinta da un pezzo, questo mondo non dà cenni di ripresa... come se fosse fermo nel tempo...
>
> →

**`MER.ingresso_citta.scena`** · quando ci torni («Osserva la scena»)
> L'ingresso della città. I primi palazzi, e i cartelli che nessuno legge più.
>
> →

**`MER.ingresso_citta.scelta1`** · bottone di scelta
> Prosegui verso i primi complessi di edifici
>
> →

**`MER.ingresso_citta.scelta2`** · bottone di scelta
> Torna alle strade di periferia
>
> →


### Meridia › `complessi`

**`MER.complessi.1`** · battuta di Anonimo
> Sarà già da un po' di minuti che cammino... qualcuno mi tiene d'occhio da quando sono entrato... no... anche più di un soggetto...
>
> →

**`MER.complessi.2`** · battuta di Anonimo
> ... Bene, da qui posso cominciare a raccogliere dati sulla zona. Ci sono varie strutture che sembrano essere interessanti...
>
> →

**`MER.complessi.scena`** · quando ci torni («Osserva la scena»)
> I primi complessi di edifici. La strada principale davanti, il parco da un lato, la struttura dall'altro.
>
> →

**`MER.complessi.scelta1`** · bottone di scelta
> Avanza per la strada principale
>
> →

**`MER.complessi.scelta2`** · bottone di scelta
> Investiga il parco
>
> →

**`MER.complessi.scelta3`** · bottone di scelta
> Investiga dentro la struttura abbandonata
>
> →

**`MER.complessi.scelta4`** · bottone di scelta
> Torna all'ingresso della città
>
> →


### Meridia › `complessi_dopo`

**`MER.complessi_dopo.1`** · narrazione
> I primi complessi di edifici. Da qui si vede tutto quello che c'è da vedere di questo quartiere: la strada principale, il parco, la struttura.
>
> →

**`MER.complessi_dopo.scena`** · quando ci torni («Osserva la scena»)
> I primi complessi di edifici. La strada principale davanti, il parco da un lato, la struttura dall'altro.
>
> →

**`MER.complessi_dopo.scelta1`** · bottone di scelta
> Avanza per la strada principale
>
> →

**`MER.complessi_dopo.scelta2`** · bottone di scelta
> Investiga il parco
>
> →

**`MER.complessi_dopo.scelta3`** · bottone di scelta
> Investiga dentro la struttura abbandonata
>
> →

**`MER.complessi_dopo.scelta4`** · bottone di scelta
> Pianta un proiettore fra i complessi
>
> →

**`MER.complessi_dopo.scelta5`** · bottone di scelta
> Torna all'ingresso della città
>
> →


### Meridia › `struttura`

**`MER.struttura.1`** · battuta di Anonimo
> Sembra che sia un garage sotterraneo? Le luci sono ancora accese... Incredibile che funzioni ancora la corrente dopo così tanti anni...
>
> →

**`MER.struttura.scena`** · quando ci torni («Osserva la scena»)
> La struttura abbandonata. La rampa che scende, e le luci che nessuno ha mai spento.
>
> →

**`MER.struttura.scelta1`** · bottone di scelta
> Esplora i piani inferiori
>
> →

**`MER.struttura.scelta2`** · bottone di scelta
> Torna ai complessi di edifici
>
> →


### Meridia › `garage_1`

**`MER.garage_1.1`** · battuta di Anonimo
> Sembra una stanza enorme... ci saranno posti per almeno un migliaio di auto. Quanta gente viveva in questa città?
>
> →

**`MER.garage_1.scena`** · quando ci torni («Osserva la scena»)
> Piano -1. Le file di posti auto vuoti, a perdita d'occhio.
>
> →

**`MER.garage_1.scelta1`** · bottone di scelta
> Scendi al piano inferiore
>
> →

**`MER.garage_1.scelta2`** · bottone di scelta
> Risali in superficie
>
> →


### Meridia › `garage_2`

**`MER.garage_2.1`** · narrazione
> Vari rottami sembrano sparsi ovunque: difficile vedere cosa si cela negli angoli di questo enorme piano...
>
> →

**`MER.garage_2.scena`** · quando ci torni («Osserva la scena»)
> Piano -2. I rottami sparsi, e gli angoli che restano bui.
>
> →

**`MER.garage_2.scelta1`** · bottone di scelta
> Scendi al piano inferiore
>
> →

**`MER.garage_2.scelta2`** · bottone di scelta
> Risali al piano superiore
>
> →


### Meridia › `garage_3`

**`MER.garage_3.1`** · battuta di Anonimo
> ... Cos'è stato? ...
>
> →

**`MER.garage_3.scena`** · quando ci torni («Osserva la scena»)
> Piano -3. Il rumore che hai sentito non si ripete.
>
> →

**`MER.garage_3.scelta1`** · bottone di scelta
> Perlustra il piano
>
> →

**`MER.garage_3.scelta2`** · bottone di scelta
> Scendi al piano inferiore
>
> →

**`MER.garage_3.scelta3`** · bottone di scelta
> Risali al piano superiore
>
> →


### Meridia › `garage_3_perlustra`

**`MER.garage_3_perlustra.1`** · narrazione
> Non hai trovato nulla d'interessante... vari fori sono distribuiti nelle pareti... sembrano scavati a mano.
>
> →

**`MER.garage_3_perlustra.scelta1`** · bottone di scelta
> Scendi al piano inferiore
>
> →

**`MER.garage_3_perlustra.scelta2`** · bottone di scelta
> Torna a guardarti intorno
>
> →


### Meridia › `garage_4`

**`MER.garage_4.1`** · battuta di Anonimo
> C'è solo un gigantesco cumulo di macerie che si sviluppa verso il basso... sento provenire dell'aria da qui sotto... che si possa accedere in qualche modo?
>
> →

**`MER.garage_4.scena`** · quando ci torni («Osserva la scena»)
> Piano -4. Il cumulo di macerie che scende ancora, e l'aria che ne sale.
>
> →

**`MER.garage_4.scelta1`** · bottone di scelta
> Perlustra il piano
>
> →

**`MER.garage_4.scelta2`** · bottone di scelta
> Torna in superficie
>
> →


### Meridia › `garage_4_perlustra`

**`MER.garage_4_perlustra.1`** · narrazione
> Nonostante i tuoi sforzi il cumulo di macerie ti impedisce di proseguire oltre... Non sembra esserci più niente qui.
>
> →

**`MER.garage_4_perlustra.scelta1`** · bottone di scelta
> Torna in superficie
>
> →

**`MER.garage_4_perlustra.scelta2`** · bottone di scelta
> Guarda ancora il cumulo
>
> →


### Meridia › `fuori_struttura`

**`MER.fuori_struttura.1`** · battuta di Anonimo
> Alla fine è stato inutile entrare in questo posto... sarà meglio dare un'occhiata nelle altre zone...
>
> →

**`MER.fuori_struttura.2`** · didascalia dell'illustrazione `art/illustrazioni/meridia_morto_vivente.png`
> In mezzo alla strada, fermo, c'è qualcosa che ti sta guardando da parecchio.
>
> →

**`MER.fuori_struttura.3`** · battuta di Anonimo
> E quello cos'è?
>
> →

**`MER.fuori_struttura.4`** · battuta di Infetto Rapido
> Mooooaaahhh...
>
> →

**`MER.fuori_struttura.5`** · narrazione
> La creatura ti osserva... sembra in qualche modo... invidiosa? In un battito d'occhio, ti ritrovi faccia a faccia con qualcosa di terribile.
>
> →


### Meridia › `dopo_infetto`

**`MER.dopo_infetto.1`** · battuta di Anonimo
> ... Credo di aver attirato l'attenzione...
>
> →


### Meridia › `seconda_ondata`

**`MER.seconda_ondata.1`** · narrazione
> Non fai in tempo a riprendere fiato: dal fondo della strada ne arrivano altri, con lo stesso passo di prima.
>
> →


### Meridia › `dopo_ondate`

**`MER.dopo_ondate.1`** · battuta di Anonimo
> Sembra essere finita... ecco cosa mi stava seguendo. La fonte dovrebbe essere stata estinta: allora perché queste creature continuano a comparire?
>
> →

**`MER.dopo_ondate.2`** · battuta di Anonimo
> Sarà meglio proseguire con le indagini.
>
> →

**`MER.dopo_ondate.scena`** · quando ci torni («Osserva la scena»)
> Fuori dalla struttura. La strada, adesso, è di nuovo vuota.
>
> →

**`MER.dopo_ondate.scelta1`** · bottone di scelta
> Torna ai complessi di edifici
>
> →

**`MER.dopo_ondate.scelta2`** · bottone di scelta
> Rientra nella struttura
>
> →


### Meridia › `fuori_struttura_dopo`

**`MER.fuori_struttura_dopo.1`** · narrazione
> Fuori dalla struttura. Dove si erano ammassati non è rimasto niente.
>
> →

**`MER.fuori_struttura_dopo.scena`** · quando ci torni («Osserva la scena»)
> Fuori dalla struttura. La strada, adesso, è di nuovo vuota.
>
> →

**`MER.fuori_struttura_dopo.scelta1`** · bottone di scelta
> Torna ai complessi di edifici
>
> →

**`MER.fuori_struttura_dopo.scelta2`** · bottone di scelta
> Rientra nella struttura
>
> →


### Meridia › `parco`

**`MER.parco.1`** · battuta di Anonimo
> Questo parco è immenso... doveva essere meraviglioso, un tempo...
>
> →

**`MER.parco.scena`** · quando ci torni («Osserva la scena»)
> Il parco. Gli alberi secchi, e il lago quasi prosciugato.
>
> →

**`MER.parco.scelta1`** · bottone di scelta (fa raccogliere Fiala misteriosa)
> Esamina il parco
>
> →

**`MER.parco.scelta2`** · bottone di scelta
> Torna ai complessi di edifici
>
> →


### Meridia › `parco_lago`

**`MER.parco_lago.1`** · narrazione
> Al centro del lago qualcosa luccica. L'acqua è bassa, così ti fai strada verso l'oggetto...
>
> →

**`MER.parco_lago.2`** · battuta di Anonimo
> Qualcosa sembra venire verso di me dal cielo...
>
> →

**`MER.parco_lago.3`** · battuta di Nuvola di Marciume
> Baflooon!
>
> →


### Meridia › `dopo_nuvola`

**`MER.dopo_nuvola.1`** · battuta di Anonimo
> Non era una grande minaccia, alla fine... ma mi chiedo se ci sia una correlazione tra le nuvole che ricoprono il pianeta e l'anomalo comportamento di questa frattura.
>
> →

**`MER.dopo_nuvola.2`** · battuta di Anonimo
> Meglio continuare con le indagini.
>
> →

**`MER.dopo_nuvola.scena`** · quando ci torni («Osserva la scena»)
> Il parco. Gli alberi secchi, e il lago quasi prosciugato.
>
> →

**`MER.dopo_nuvola.scelta1`** · bottone di scelta
> Torna ai complessi di edifici
>
> →


### Meridia › `parco_dopo`

**`MER.parco_dopo.1`** · narrazione
> Il parco è tornato immobile. Sopra gli alberi secchi le nuvole continuano a passare, basse.
>
> →

**`MER.parco_dopo.scena`** · quando ci torni («Osserva la scena»)
> Il parco. Gli alberi secchi, e il lago quasi prosciugato.
>
> →

**`MER.parco_dopo.scelta1`** · bottone di scelta
> Torna ai complessi di edifici
>
> →


### Meridia › `strada_principale`

**`MER.strada_principale.1`** · narrazione
> Lungo le strade principali della città leggi diversi cartelli che portano il nome della città nella quale ti trovi: «Meridia».
>
> →

**`MER.strada_principale.scena`** · quando ci torni («Osserva la scena»)
> La strada principale. Le vetrine rotte, e i cartelli col nome della città.
>
> →

**`MER.strada_principale.scelta1`** · bottone di scelta
> Entra nel supermercato saccheggiato
>
> →

**`MER.strada_principale.scelta2`** · bottone di scelta
> Entra nell'officina abbandonata
>
> →

**`MER.strada_principale.scelta3`** · bottone di scelta
> Vai verso l'edicola
>
> →

**`MER.strada_principale.scelta4`** · bottone di scelta
> Pianta un proiettore sulla strada principale
>
> →

**`MER.strada_principale.scelta5`** · bottone di scelta
> Torna ai complessi di edifici
>
> →


### Meridia › `supermercato`

**`MER.supermercato.1`** · battuta di Anonimo
> Questo posto è stato vandalizzato innumerevoli volte. Devo cercare di fare piano: i nemici si nascondono dietro ogni angolo...
>
> →

**`MER.supermercato.scena`** · quando ci torni («Osserva la scena»)
> Il supermercato saccheggiato. Scaffali rovesciati, carrelli fermi a metà corsia.
>
> →

**`MER.supermercato.scelta1`** · bottone di scelta (fa raccogliere Bastone)
> Fruga tra gli scaffali caduti
>
> →

**`MER.supermercato.scelta2`** · bottone di scelta
> Svuota una cassa ancora chiusa
>
> →

**`MER.supermercato.scelta3`** · bottone di scelta
> Torna alla strada
>
> →


### Meridia › `officina`

**`MER.officina.1`** · battuta di Anonimo
> Una normalissima officina... è buio pesto, potrei essere attaccato da un momento all'altro.
>
> →

**`MER.officina.scena`** · quando ci torni («Osserva la scena»)
> L'officina abbandonata. Il furgone ancora sollevato sul ponte.
>
> →

**`MER.officina.scelta1`** · bottone di scelta (fa raccogliere Spranga di ferro)
> Recupera la spranga di ferro sul banco
>
> →

**`MER.officina.scelta2`** · bottone di scelta (fa raccogliere Motosega)
> Forza l'armadietto degli attrezzi
>
> →

**`MER.officina.scelta3`** · bottone di scelta
> Torna alla strada
>
> →


### Meridia › `edicola`

**`MER.edicola.1`** · battuta di Anonimo
> Le edicole sono sempre un ottimo posto per raccogliere informazioni.
>
> →

**`MER.edicola.scena`** · quando ci torni («Osserva la scena»)
> L'edicola con la saracinesca a metà, e le pile di giornali mai ritirati.
>
> →

**`MER.edicola.scelta1`** · bottone di scelta (fa raccogliere Pagina di giornale (prima))
> Leggi la prima pagina di giornale
>
> →

**`MER.edicola.scelta2`** · bottone di scelta (fa raccogliere Pagina di giornale (seconda))
> Leggi la seconda pagina di giornale
>
> →

**`MER.edicola.scelta3`** · bottone di scelta (fa raccogliere Pagina di giornale (ultima))
> Leggi la terza pagina di giornale
>
> →

**`MER.edicola.scelta4`** · bottone di scelta
> Vai verso il vicolo sul retro
>
> →

**`MER.edicola.scelta5`** · bottone di scelta
> Torna alla strada
>
> →


### Meridia › `vicolo`

**`MER.vicolo.1`** · battuta di Anonimo
> Procedendo verso il centro della città l'aria si fa sempre più pesante...
>
> →

**`MER.vicolo.scena`** · quando ci torni («Osserva la scena»)
> Il vicolo dietro l'edicola. I cassonetti rovesciati, la scala antincendio verso il nulla.
>
> →

**`MER.vicolo.scelta1`** · bottone di scelta (fa raccogliere Mazzafrusto)
> Raccogli il mazzafrusto improvvisato
>
> →

**`MER.vicolo.scelta2`** · bottone di scelta (fa raccogliere Sparachiodi arrugginito)
> Recupera lo sparachiodi caduto tra i cassonetti
>
> →

**`MER.vicolo.scelta3`** · bottone di scelta
> Scendi verso i quartieri profondi
>
> →

**`MER.vicolo.scelta4`** · bottone di scelta
> Pianta un proiettore nel vicolo
>
> →

**`MER.vicolo.scelta5`** · bottone di scelta
> Torna all'edicola
>
> →


### Meridia › `quartieri_profondi`

**`MER.quartieri_profondi.1`** · battuta di Anonimo
> *Cough*
>
> →

**`MER.quartieri_profondi.2`** · battuta di Anonimo
> *Spit*
>
> →

**`MER.quartieri_profondi.3`** · battuta di Anonimo
> Non posso reggere ancora molto... Meglio non spingersi oltre senza avere un'attrezzatura adeguata. Mi limiterò a esplorare fino a questa zona, per ora...
>
> →

**`MER.quartieri_profondi.scena`** · quando ci torni («Osserva la scena»)
> I quartieri profondi. I palazzi si stringono, e l'aria non si respira più.
>
> →

**`MER.quartieri_profondi.scelta1`** · bottone di scelta
> Continua a battere i quartieri profondi
>
> →

**`MER.quartieri_profondi.scelta2`** · bottone di scelta
> Torna al vicolo
>
> →


### Meridia › `espulso`

**`MER.espulso.1`** · narrazione
> Il tuo destino è segnato. Tra le mille bocche affamate scompari in silenzio... un ultimo respiro si perde tra le nuvole che ricoprono questo pianeta.
>
> →

**`MER.espulso.scelta1`** · bottone di scelta (esce dallo squarcio)
> Riprendi fiato nel Vuoto
>
> →


## Cunicoli sotterranei di Jondoh

<sub>`data/vuoti/rocca_ossidiana.json`</sub>


### Cunicoli sotterranei di Jondoh › `varco`

**`OSS.varco.1`** · narrazione
> In un angolo remoto, lontano dalle luci più calde e raggiunto solo da freddi e gelidi venti, lunghi cunicoli sono stati scavati nella fredda e dura ossidiana che ricopre questo sfortunato luogo.<br>"Stai lontano dai cunicoli", si diceva agli sfortunati esploratori che recuperavano il prezioso minerale da questo mondo primitivo. Quello che si cela sottoterra è un mondo che è meglio resti dimenticato...<br>Jondoh è il nome di questo pianeta, abbandonato da ogni luce, che ora ribolle e cerca disperatamente una nuova vita... Cosa si cela in fondo ai cunicoli di questo inferno nero?
>
> →

**`OSS.varco.2`** · carta del titolo
> Cunicoli sotterranei di Jondoh
>
> →

**`OSS.varco.3`** · battuta di Anonimo
> Questo posto... il solo respirare quest'aria mi rende profondamente triste... cosa sta succedendo in questo posto?
>
> →

**`OSS.varco.scena`** · quando ci torni («Osserva la scena»)
> Il varco resta aperto alle tue spalle, un taglio di luce fredda sulla parete nera. Davanti, il corridoio scende.
>
> →

**`OSS.varco.scelta1`** · bottone di scelta
> Scendi nel corridoio di ossidiana
>
> →

**`OSS.varco.scelta2`** · bottone di scelta (esce dallo squarcio)
> Torna nel Vuoto
>
> →


### Cunicoli sotterranei di Jondoh › `corridoio_ossidiana`

**`OSS.corridoio_ossidiana.1`** · narrazione
> Il corridoio scende, tagliato nella roccia nera. Ai lati, nicchie scavate a mano, segni di graffi e un odore ferroso misto a qualcosa di dolce contraddistinguono questi cunicoli: una leggera polvere grigia, come un fondo sabbioso, ricopre il terreno su cui cammini. Il raschiare si fa più vicino: intorno a te, vari buchi dai quali provengono suoni di graffi e grugniti indistinguibili grondano una sostanza nera che si solidifica a contatto con l'aria.
>
> →

**`OSS.corridoio_ossidiana.scelta1`** · bottone di scelta
> Scendi nella fossa oscura
>
> →

**`OSS.corridoio_ossidiana.scelta2`** · bottone di scelta
> Entra nella sala del raccolto
>
> →

**`OSS.corridoio_ossidiana.scelta3`** · bottone di scelta
> Torna al varco
>
> →


### Cunicoli sotterranei di Jondoh › `fossa_oscura`

**`OSS.fossa_oscura.1`** · narrazione
> Una fossa oscura dove piccole pietre illuminano quel poco che è visibile. Qualcosa si muove nel buio: non sai se sia ostile o meno, e lo stress sale preoccupantemente. In alto, incastrato tra due sporgenze di ossidiana, qualcosa luccica ancora.
>
> →

**`OSS.fossa_oscura.scelta1`** · bottone di scelta
> Fruga nel buio
>
> →

**`OSS.fossa_oscura.scelta2`** · bottone di scelta
> Procedi verso il fondo
>
> →

**`OSS.fossa_oscura.scelta3`** · bottone di scelta
> Torna al corridoio
>
> →


### Cunicoli sotterranei di Jondoh › `fondo_del_fosso`

**`OSS.fondo_del_fosso.1`** · narrazione
> Non sembra esserci altro. Senti qualcosa sballottato fra i tuoi piedi: uno zaino, di qualcuno più sfortunato di te...
>
> →

**`OSS.fondo_del_fosso.scelta1`** · bottone di scelta (fa raccogliere Fiala HP)
> Recupera ciò che trovi
>
> →

**`OSS.fondo_del_fosso.scelta2`** · bottone di scelta
> Torna alla fossa
>
> →


### Cunicoli sotterranei di Jondoh › `sala_del_raccolto`

**`OSS.sala_del_raccolto.1`** · narrazione
> Cos'è questo posto... c'è una puzza tremenda... quelli... sono cadaveri. Il modo in cui sono stati disposti e ridotti ti fa riflettere: ci sono dei sacchi cuciti in modo primitivo, sparsi in giro.
>
> →

**`OSS.sala_del_raccolto.scelta1`** · bottone di scelta
> Fruga tra i sacchi marci
>
> →

**`OSS.sala_del_raccolto.scelta2`** · bottone di scelta (fa raccogliere Fiala HP)
> Recupera una fiala intatta tra le macerie
>
> →

**`OSS.sala_del_raccolto.scelta3`** · bottone di scelta
> Scendi verso la sala del lamento
>
> →

**`OSS.sala_del_raccolto.scelta4`** · bottone di scelta
> Torna al corridoio
>
> →


### Cunicoli sotterranei di Jondoh › `sala_del_lamento`

**`OSS.sala_del_lamento.1`** · battuta di Anonimo
> ...ma cosa è successo in questo posto?!
>
> →

**`OSS.sala_del_lamento.2`** · battuta di Anonimo
> Dall'alto, un essere scappa verso uno dei cunicoli: era enorme, e mi stava osservando... Sarà meglio sbrigarmi a estinguere la fonte di questa follia...
>
> →

**`OSS.sala_del_lamento.3`** · narrazione
> Per terra trovi delle pergamene incomprensibili...
>
> →

**`OSS.sala_del_lamento.scena`** · quando ci torni («Osserva la scena»)
> La sala del lamento: pareti coperte di graffi fino a dove arriva il braccio di un uomo, e un'eco che non si decide a spegnersi.
>
> →

**`OSS.sala_del_lamento.scelta1`** · bottone di scelta (fa raccogliere Pergamene incomprensibili)
> Raccogli le pergamene
>
> →

**`OSS.sala_del_lamento.scelta2`** · bottone di scelta (fa raccogliere Pergamene incomprensibili)
> Raccogli le pergamene
>
> →

**`OSS.sala_del_lamento.scelta3`** · bottone di scelta
> Affronta ciò che urla nel buio
>
> →

**`OSS.sala_del_lamento.scelta4`** · bottone di scelta
> Prosegui
>
> →

**`OSS.sala_del_lamento.scelta5`** · bottone di scelta
> Torna alla sala del raccolto
>
> →


### Cunicoli sotterranei di Jondoh › `lamento_imboscata`

**`OSS.lamento_imboscata.1`** · narrazione
> Una figura oscura ti travolge dal buio!
>
> →

**`OSS.lamento_imboscata.2`** · battuta di Anonimo
> !!!
>
> →


### Cunicoli sotterranei di Jondoh › `dopo_lamento`

**`OSS.dopo_lamento.1`** · narrazione
> Qualcosa, dentro di te, si fissa in questo punto. Non tornerai indietro da qui.
>
> →

**`OSS.dopo_lamento.scelta1`** · bottone di scelta (fa raccogliere Ciondolo del grande viaggio)
> Prendi il ciondolo strappato al sacerdote
>
> →

**`OSS.dopo_lamento.scelta2`** · bottone di scelta
> Prosegui più a fondo nei cunicoli
>
> →

**`OSS.dopo_lamento.scelta3`** · bottone di scelta
> Prendi i cunicoli di destra, verso il ponte
>
> →


### Cunicoli sotterranei di Jondoh › `cunicolo_1`

**`OSS.cunicolo_1.1`** · narrazione
> Questi cunicoli sembrano non avere fine. Da qui la roccia si biforca in due direzioni diverse.
>
> →

**`OSS.cunicolo_1.scelta1`** · bottone di scelta
> Vai a sinistra
>
> →

**`OSS.cunicolo_1.scelta2`** · bottone di scelta
> Vai a destra
>
> →

**`OSS.cunicolo_1.scelta3`** · bottone di scelta
> Pianta un proiettore al bivio dei cunicoli
>
> →

**`OSS.cunicolo_1.scelta4`** · bottone di scelta
> Torna alla mappa
>
> →


### Cunicoli sotterranei di Jondoh › `cunicolo_2`

**`OSS.cunicolo_2.1`** · narrazione
> Il cunicolo di sinistra scende ancora, ma in fondo si intravede un bagliore instabile, come di torce accese da qualcun altro.
>
> →

**`OSS.cunicolo_2.scelta1`** · bottone di scelta
> Prosegui verso il bagliore
>
> →

**`OSS.cunicolo_2.scelta2`** · bottone di scelta
> Torna al bivio
>
> →

**`OSS.cunicolo_2.scelta3`** · bottone di scelta
> Torna alla mappa
>
> →


### Cunicoli sotterranei di Jondoh › `cunicolo_3`

**`OSS.cunicolo_3.1`** · narrazione
> Il cunicolo di destra sale, e un filo di vento gelido comincia a farsi sentire: da qualche parte, più avanti, c'è una via verso la superficie.
>
> →

**`OSS.cunicolo_3.scelta1`** · bottone di scelta
> Sali verso la superficie
>
> →

**`OSS.cunicolo_3.scelta2`** · bottone di scelta
> Torna al bivio
>
> →

**`OSS.cunicolo_3.scelta3`** · bottone di scelta
> Torna alla mappa
>
> →


### Cunicoli sotterranei di Jondoh › `piazza_sotterranea`

**`OSS.piazza_sotterranea.1`** · narrazione
> Nella piazza sotterranea trovi qualcuno di vivo, finalmente. Ti osserva a lungo, immobile, prima di abbassare la guardia.
>
> →

**`OSS.piazza_sotterranea.2`** · battuta di Yara
> Non ne arrivano molti fin qui. Ancora meno ne escono.
>
> →

**`OSS.piazza_sotterranea.3`** · battuta di Yara
> Jondoh è un pianeta minerario. Chi ci lavora non è nativo: sono schiavi, portati qui da altri mondi.
>
> →

**`OSS.piazza_sotterranea.4`** · battuta di Yara
> Respirare le polveri, toccare la sostanza nera... li fa mutare. Regrediscono, e sviluppano una malvagità che prima non avevano.
>
> →

**`OSS.piazza_sotterranea.5`** · battuta di Yara
> Per anni il problema è stato ignorato. Gli schiavi continuavano ad arrivare, i cunicoli continuavano a scavarsi.
>
> →

**`OSS.piazza_sotterranea.6`** · battuta di Yara
> Poi sono cominciate le sparizioni. La prima fu mia sorella minore. La più piccola di tutti noi.
>
> →

**`OSS.piazza_sotterranea.7`** · battuta di Yara
> Da quel giorno sono passati anni, e molti altri sono scomparsi in questi cunicoli.
>
> →

**`OSS.piazza_sotterranea.8`** · battuta di Yara
> Il lavoro si è spostato tutto in superficie: i cunicoli erano considerati troppo pericolosi.
>
> →

**`OSS.piazza_sotterranea.9`** · battuta di Yara
> Finché uno schiavo fu attaccato da un ghoul, in superficie. Il ghoul morì poco dopo: riescono a vivere solo qui sotto.
>
> →

**`OSS.piazza_sotterranea.10`** · battuta di Yara
> Da allora qualcosa è cambiato. Sempre più persone sparite, attacchi sempre più frequenti.
>
> →

**`OSS.piazza_sotterranea.11`** · battuta di Yara
> Ho passato anni a combattere queste cose. Non avrò pace finché non saprò la verità fino in fondo.
>
> →

**`OSS.piazza_sotterranea.scelta1`** · bottone di scelta
> Chiedile di unirsi a te
>
> →

**`OSS.piazza_sotterranea.scelta2`** · bottone di scelta
> Torna al cunicolo
>
> →

**`OSS.piazza_sotterranea.scelta3`** · bottone di scelta
> Torna alla mappa
>
> →


### Cunicoli sotterranei di Jondoh › `piazza_ritorno`

**`OSS.piazza_ritorno.1`** · battuta di Yara
> Hey... ciao di nuovo...
>
> →

**`OSS.piazza_ritorno.scena`** · quando ci torni («Osserva la scena»)
> Yara è dove l'hai lasciata: la schiena contro la roccia, gli occhi puntati sulla galleria da cui sei arrivato.
>
> →

**`OSS.piazza_ritorno.scelta1`** · bottone di scelta
> Chiedile di unirsi a te
>
> →

**`OSS.piazza_ritorno.scelta2`** · bottone di scelta
> Torna al cunicolo
>
> →

**`OSS.piazza_ritorno.scelta3`** · bottone di scelta
> Torna alla mappa
>
> →


### Cunicoli sotterranei di Jondoh › `piazza_con_yara`

**`OSS.piazza_con_yara.1`** · narrazione
> C'è qualcosa di brillante per terra.
>
> →

**`OSS.piazza_con_yara.scena`** · quando ci torni («Osserva la scena»)
> La piazza è vuota, adesso: le torce consumate fino alla base, e il silenzio che si richiude ogni volta che smetti di parlare.
>
> →

**`OSS.piazza_con_yara.scelta1`** · bottone di scelta (fa raccogliere Bomba artigianale)
> Raccogli l'oggetto brillante
>
> →

**`OSS.piazza_con_yara.scelta2`** · bottone di scelta
> Torna al cunicolo
>
> →

**`OSS.piazza_con_yara.scelta3`** · bottone di scelta
> Torna alla mappa
>
> →


### Cunicoli sotterranei di Jondoh › `yara_si_unisce`

**`OSS.yara_si_unisce.1`** · battuta di Yara
> Va bene. Non perché mi fidi di te: perché da sola non ci sono mai arrivata.
>
> →

**`OSS.yara_si_unisce.2`** · battuta di Yara
> Vado avanti io quando serve. Tu bada a non morire.
>
> →

**`OSS.yara_si_unisce.scena`** · quando ci torni («Osserva la scena»)
> Yara ti aspetta, già rivolta verso l'uscita della piazza.
>
> →

**`OSS.yara_si_unisce.scelta1`** · bottone di scelta
> Torna al cunicolo
>
> →

**`OSS.yara_si_unisce.scelta2`** · bottone di scelta
> Apri la mappa
>
> →


### Cunicoli sotterranei di Jondoh › `cargo_abbandonato`

**`OSS.cargo_abbandonato.1`** · narrazione
> All'aperto trovi un cargo abbandonato, arrugginito, mezzo sepolto nella sabbia nera. All'interno, casse sfondate e provviste dimenticate da chissà quanto tempo.
>
> →

**`OSS.cargo_abbandonato.scelta1`** · bottone di scelta
> Fruga tra le casse
>
> →

**`OSS.cargo_abbandonato.scelta2`** · bottone di scelta (fa raccogliere Fiala HP)
> Recupera una fiala
>
> →

**`OSS.cargo_abbandonato.scelta3`** · bottone di scelta (fa raccogliere Fiala HP)
> Recupera un'altra fiala
>
> →

**`OSS.cargo_abbandonato.scelta4`** · bottone di scelta (fa raccogliere Infuso antico)
> Recupera l'infuso antico
>
> →

**`OSS.cargo_abbandonato.scelta5`** · bottone di scelta (fa raccogliere Gel Omega)
> Recupera il gel omega
>
> →

**`OSS.cargo_abbandonato.scelta6`** · bottone di scelta
> Torna al cunicolo
>
> →

**`OSS.cargo_abbandonato.scelta7`** · bottone di scelta
> Torna alla mappa
>
> →


### Cunicoli sotterranei di Jondoh › `ponte_approccio`

**`OSS.ponte_approccio.1`** · narrazione
> Il cunicolo si apre su un grande ponte marcio, teso su un baratro che la luce non riesce a raggiungere. Oltre il ponte, il passaggio prosegue verso il basso.
>
> →

**`OSS.ponte_approccio.scelta1`** · bottone di scelta
> Attraversa il grande ponte marcio
>
> →

**`OSS.ponte_approccio.scelta2`** · bottone di scelta
> Attraversa il grande ponte marcio
>
> →

**`OSS.ponte_approccio.scelta3`** · bottone di scelta
> Torna alla mappa
>
> →


### Cunicoli sotterranei di Jondoh › `ponte_meta_compagna`

**`OSS.ponte_meta_compagna.1`** · battuta di Yara
> Stai attento: non sono mai riuscita ad attraversare questo ponte. Una creatura orribile vive nella parte inferiore. L'ho vista una sola volta, e mi è bastato...
>
> →

**`OSS.ponte_meta_compagna.scena`** · quando ci torni («Osserva la scena»)
> Le assi del ponte scricchiolano già sotto il primo passo. Sotto, solo buio.
>
> →

**`OSS.ponte_meta_compagna.scelta1`** · bottone di scelta
> Prosegui
>
> →


### Cunicoli sotterranei di Jondoh › `ponte_meta_solo`

**`OSS.ponte_meta_solo.1`** · battuta di Anonimo
> ...i ponti non mi sono mai piaciuti...
>
> →

**`OSS.ponte_meta_solo.scena`** · quando ci torni («Osserva la scena»)
> Le assi del ponte scricchiolano già sotto il primo passo. Sotto, solo buio.
>
> →

**`OSS.ponte_meta_solo.scelta1`** · bottone di scelta
> Prosegui
>
> →


### Cunicoli sotterranei di Jondoh › `ponte_centro`

**`OSS.ponte_centro.1`** · narrazione
> Senti qualcosa muoversi sotto di te...
>
> →

**`OSS.ponte_centro.scelta1`** · bottone di scelta
> Prosegui?
>
> →

**`OSS.ponte_centro.scelta2`** · bottone di scelta
> Torna indietro
>
> →


### Cunicoli sotterranei di Jondoh › `ponte_quasi_fine`

**`OSS.ponte_quasi_fine.1`** · narrazione
> Sembra tutto ok: ormai sei a metà del ponte...
>
> →

**`OSS.ponte_quasi_fine.scelta1`** · bottone di scelta
> Prosegui?
>
> →


### Cunicoli sotterranei di Jondoh › `ponte_attacco`

**`OSS.ponte_attacco.1`** · narrazione
> Qualcosa sta salendo da sotto il ponte...
>
> →

**`OSS.ponte_attacco.2`** · battuta di Anonimo
> Ecco cos'era questa puzza.
>
> →

**`OSS.ponte_attacco.scelta1`** · bottone di scelta
> Reagisci
>
> →

**`OSS.ponte_attacco.scelta2`** · bottone di scelta (porta a un combattimento)
> Reagisci
>
> →


### Cunicoli sotterranei di Jondoh › `ponte_attacco_compagna`

**`OSS.ponte_attacco_compagna.1`** · battuta di Yara
> Eccolo. È proprio quella creatura schifosa!
>
> →


### Cunicoli sotterranei di Jondoh › `oltre_ponte`

**`OSS.oltre_ponte.1`** · narrazione
> Attraversato il ponte, volgi lo sguardo all'indietro: altri vermi risalgono e divorano la carcassa di quello che hai appena ucciso... Ce n'era più di uno.
>
> →

**`OSS.oltre_ponte.scelta1`** · bottone di scelta
> Continua
>
> →

**`OSS.oltre_ponte.scelta2`** · bottone di scelta
> Entra nella cripta
>
> →


### Cunicoli sotterranei di Jondoh › `oltre_ponte_gratitudine`

**`OSS.oltre_ponte_gratitudine.1`** · battuta di Yara
> Non ce l'avrei mai fatta da sola... Grazie per avermi fatto venire con te.
>
> →

**`OSS.oltre_ponte_gratitudine.scena`** · quando ci torni («Osserva la scena»)
> Dall'altra parte del ponte l'aria è ancora più densa. Yara non guarda più indietro.
>
> →

**`OSS.oltre_ponte_gratitudine.scelta1`** · bottone di scelta
> Entra nella cripta
>
> →


### Cunicoli sotterranei di Jondoh › `cripta_senza_compagna`

**`OSS.cripta_senza_compagna.1`** · narrazione
> Si narra di esseri nati dal bitume più nero, che vivono negli incubi delle persone.<br>Esseri abietti che non hanno mai conosciuto la grazia di un tocco gentile.<br>Non conoscono pietà o rimorso, schiavi perfetti di un oscuro potere che tutto fa marcire.<br>In fondo, chi avrebbe mai fatto qualcosa per loro?<br>Benvenuto, nelle profondità marcite di Jondoh, possa la terra perdonare chi l'ha calpestata senza rispetto.
>
> →

**`OSS.cripta_senza_compagna.2`** · battuta di Anonimo
> C'è qualcuno che cammina...
>
> →

**`OSS.cripta_senza_compagna.3`** · battuta di ???
> Nnnnghhh.... Yaaaargh...
>
> →

**`OSS.cripta_senza_compagna.4`** · battuta di Anonimo
> La situazione è chiara...
>
> →

**`OSS.cripta_senza_compagna.scena`** · quando ci torni («Osserva la scena»)
> La cripta è una galleria bassa di ossidiana lucida. Qualcosa continua a camminarci dentro, senza arrivare da nessuna parte.
>
> →

**`OSS.cripta_senza_compagna.scelta1`** · bottone di scelta (porta a un combattimento)
> Affronta l'abominio
>
> →

**`OSS.cripta_senza_compagna.scelta2`** · bottone di scelta
> Intuisci il momento giusto e scivola oltre, nell'ombra
>
> →

**`OSS.cripta_senza_compagna.scelta3`** · bottone di scelta
> Scendi verso l'altare
>
> →


### Cunicoli sotterranei di Jondoh › `cripta_con_compagna`

**`OSS.cripta_con_compagna.1`** · narrazione
> Si narra di esseri nati dal bitume più nero, che vivono negli incubi delle persone.<br>Esseri abietti che non hanno mai conosciuto la grazia di un tocco gentile.<br>Non conoscono pietà o rimorso, schiavi perfetti di un oscuro potere che tutto fa marcire.<br>In fondo, chi avrebbe mai fatto qualcosa per loro?<br>Benvenuto, nelle profondità marcite di Jondoh, possa la terra perdonare chi l'ha calpestata senza rispetto.
>
> →

**`OSS.cripta_con_compagna.2`** · battuta di Anonimo
> C'è qualcuno che cammina...
>
> →

**`OSS.cripta_con_compagna.3`** · battuta di Yara
> Non sembra essere qualcuno, ma qualcosa...
>
> →

**`OSS.cripta_con_compagna.4`** · battuta di ???
> Nnnnghhh.... Yaaaargh...
>
> →

**`OSS.cripta_con_compagna.5`** · battuta di Anonimo
> La situazione è chiara...
>
> →

**`OSS.cripta_con_compagna.scena`** · quando ci torni («Osserva la scena»)
> La cripta è una galleria bassa di ossidiana lucida. Qualcosa continua a camminarci dentro, senza arrivare da nessuna parte.
>
> →

**`OSS.cripta_con_compagna.scelta1`** · bottone di scelta (porta a un combattimento)
> Affronta l'abominio
>
> →

**`OSS.cripta_con_compagna.scelta2`** · bottone di scelta
> Intuisci il momento giusto e scivola oltre, nell'ombra
>
> →

**`OSS.cripta_con_compagna.scelta3`** · bottone di scelta
> Scendi verso l'altare
>
> →


### Cunicoli sotterranei di Jondoh › `sconfitta_immortale`

**`OSS.sconfitta_immortale.1`** · narrazione
> Non riesci a scrollartelo di dosso in tempo. Il buio, alla fine, non ha nemmeno bisogno di uccidere: basta che resti lì, finché non resta più nulla da opporgli.
>
> →

**`OSS.sconfitta_immortale.scelta1`** · bottone di scelta
> Riprendi dall'ultimo salvataggio
>
> →


### Cunicoli sotterranei di Jondoh › `altare_dei_sacrifici`

**`OSS.altare_dei_sacrifici.1`** · narrazione
> Un altare scavato nella pietra nera: candele consumate fino alla base, cera colata sopra cera, e una scalinata che scende ancora, verso una luce rossastra.
>
> →

**`OSS.altare_dei_sacrifici.scelta1`** · bottone di scelta
> Continua
>
> →

**`OSS.altare_dei_sacrifici.scelta2`** · bottone di scelta
> Continua
>
> →


### Cunicoli sotterranei di Jondoh › `altare_da_solo`

**`OSS.altare_da_solo.1`** · battuta di Anonimo
> Quella creatura non era pericolosa... eppure sembrava impossibile infliggergli del danno vero... anche se... sembrava comunque soffrire...
>
> →

**`OSS.altare_da_solo.scena`** · quando ci torni («Osserva la scena»)
> L'altare è come l'hai lasciato: le candele consumate, la scalinata che scende verso la luce rossastra.
>
> →

**`OSS.altare_da_solo.scelta1`** · bottone di scelta
> Scendi verso il trono
>
> →

**`OSS.altare_da_solo.scelta2`** · bottone di scelta
> Torna alla cripta
>
> →


### Cunicoli sotterranei di Jondoh › `altare_con_yara`

**`OSS.altare_con_yara.1`** · battuta di Yara
> Povera creatura... Cosa pensi sia successo a quella cosa?
>
> →

**`OSS.altare_con_yara.2`** · battuta di Anonimo
> Questo posto... è qualcosa che non dovrebbe esistere... Non ho risposte alla tua domanda...
>
> →

**`OSS.altare_con_yara.3`** · battuta di Yara
> Non perdonerò mai chi ha causato tutto questo.
>
> →

**`OSS.altare_con_yara.4`** · battuta di Anonimo
> ...
>
> →

**`OSS.altare_con_yara.scena`** · quando ci torni («Osserva la scena»)
> L'altare è come l'avete lasciato: le candele consumate, la scalinata che scende verso la luce rossastra.
>
> →

**`OSS.altare_con_yara.scelta1`** · bottone di scelta
> Scendi verso il trono
>
> →

**`OSS.altare_con_yara.scelta2`** · bottone di scelta
> Torna alla cripta
>
> →


### Cunicoli sotterranei di Jondoh › `trono_marcio_senza_compagna`

**`OSS.trono_marcio_senza_compagna.1`** · narrazione
> Qualcuno recita in una lingua a te sconosciuta dei canti mentre scendi gli ultimi gradini: le parole non vogliono dire niente, ma il ritmo è quello di una preghiera che non si è mai interrotta.
>
> →

**`OSS.trono_marcio_senza_compagna.2`** · battuta di Anonimo
> Sei tu il responsabile di tutto questo?
>
> →

**`OSS.trono_marcio_senza_compagna.3`** · battuta di Jongo Dongo
> Hmmm? Un piccolo sacrificio, per un grande risultato...
>
> →

**`OSS.trono_marcio_senza_compagna.scelta1`** · bottone di scelta (porta a un combattimento)
> Affrontalo
>
> →


### Cunicoli sotterranei di Jondoh › `trono_marcio_con_compagna`

**`OSS.trono_marcio_con_compagna.1`** · narrazione
> Qualcuno recita in una lingua a te sconosciuta dei canti mentre scendete gli ultimi gradini: le parole non vogliono dire niente, ma il ritmo è quello di una preghiera che non si è mai interrotta.
>
> →

**`OSS.trono_marcio_con_compagna.2`** · battuta di Anonimo
> Sei tu il responsabile di tutto questo?
>
> →

**`OSS.trono_marcio_con_compagna.3`** · battuta di Jongo Dongo
> Hmmm? Un piccolo sacrificio, per un grande risultato...
>
> →

**`OSS.trono_marcio_con_compagna.4`** · battuta di Yara
> Riconosco quella voce... È la stessa che ho sentito quel giorno. Non posso dimenticarla... Maledetto! Sei stato tu!
>
> →

**`OSS.trono_marcio_con_compagna.5`** · narrazione
> Prima che tu possa fermarla, si lancia avventatamente contro Jongo Dongo, che non esita a trafiggerla.
>
> →

**`OSS.trono_marcio_con_compagna.6`** · battuta di Yara
> Ma... le... detto... muori...
>
> →

**`OSS.trono_marcio_con_compagna.7`** · narrazione
> *click* La ragazza salta in aria: Jongo Dongo viene avvolto dalle fiamme.
>
> →

**`OSS.trono_marcio_con_compagna.8`** · battuta di Jongo Dongo
> ... Il dolore... non è altro che un mero ostacolo... sciocca ragazzina...
>
> →

**`OSS.trono_marcio_con_compagna.9`** · battuta di Anonimo
> ... Avrei dovuto fermarla... La pagherai...
>
> →

**`OSS.trono_marcio_con_compagna.scelta1`** · bottone di scelta (porta a un combattimento)
> Affrontalo
>
> →


### Cunicoli sotterranei di Jondoh › `jongo_prima_caduta`

**`OSS.jongo_prima_caduta.1`** · battuta di Anonimo
> Finalmente questa storia ha una fine.
>
> →

**`OSS.jongo_prima_caduta.2`** · battuta di Anonimo
> ... Come mai non percepisco alcun cambiamento?
>
> →

**`OSS.jongo_prima_caduta.3`** · narrazione
> Jongo Dongo si rialza.
>
> →

**`OSS.jongo_prima_caduta.4`** · battuta di Jongo Dongo
> ...
>
> →

**`OSS.jongo_prima_caduta.5`** · battuta di Anonimo
> ... Come fa ad essere ancora in piedi?!
>
> →


### Cunicoli sotterranei di Jondoh › `vittoria`

**`OSS.vittoria.1`** · narrazione
> Jongo Dongo cade in ginocchio, poi si sfalda: la maledizione che lo teneva in piedi si scioglie insieme a lui. Non chiede perdono. Dai rimasugli sparsi nel vento si alza una voce sinistra... "Eravamo così... vicini... il viaggio...". L'ossidiana intorno smette di sudare, l'aria si alleggerisce e in lontananza puoi percepire qualcosa che si addormenta dolcemente.
>
> →

**`OSS.vittoria.scelta1`** · bottone di scelta (esce dallo squarcio)
> Torna nel Vuoto
>
> →


### Cunicoli sotterranei di Jondoh › `sconfitta_boss`

**`OSS.sconfitta_boss.1`** · battuta di Jongo Dongo
> Un nuovo sacrificio... Una nuova possibilità...
>
> →

**`OSS.sconfitta_boss.scelta1`** · bottone di scelta
> Riprendi dall'ultimo salvataggio
>
> →


### Cunicoli sotterranei di Jondoh › `espulso`

**`OSS.espulso.1`** · narrazione
> Il buio ti si richiude sopra come una fossa che si rinchiude. Quando riprendi fiato, sei di nuovo nel Vuoto. La Rocca di Ossidiana resta lì, marcia e paziente.
>
> →

**`OSS.espulso.scelta1`** · bottone di scelta (esce dallo squarcio)
> Riprendi fiato nel Vuoto
>
> →


## Il Teatro del Passato

<sub>`data/vuoti/teatro_del_passato.json`</sub>


### Il Teatro del Passato › `foyer`

**`TEA.foyer.1`** · narrazione
> Questo squarcio dà sul passato: un teatro nel suo giorno migliore. Il foyer profuma di velluto e cera. Da dentro arriva un applauso — no: il rumore di un solo paio di mani.
>
> →

**`TEA.foyer.scelta1`** · bottone di scelta
> Pesca nella fontanella dei desideri
>
> →

**`TEA.foyer.scelta2`** · bottone di scelta
> Entra in platea
>
> →

**`TEA.foyer.scelta3`** · bottone di scelta
> Passa dal botteghino
>
> →

**`TEA.foyer.scelta4`** · bottone di scelta (esce dallo squarcio)
> Torna nel Vuoto
>
> →


### Il Teatro del Passato › `platea`

**`TEA.platea.1`** · narrazione
> In platea non c'è nessuno. Sul palco, un ragazzo si esibisce in acrobazie folli: salti che nessun corpo dovrebbe reggere, eppure atterra sempre. Si allena come se il mondo intero lo stesse guardando. Non lo guarda nessuno.
>
> →

**`TEA.platea.scelta1`** · bottone di scelta
> Resta a guardare le acrobazie
>
> →

**`TEA.platea.scelta2`** · bottone di scelta
> Controlla sotto la poltrona numero 7
>
> →

**`TEA.platea.scelta3`** · bottone di scelta
> Sali sul palcoscenico
>
> →

**`TEA.platea.scelta4`** · bottone di scelta
> Sali in galleria
>
> →

**`TEA.platea.scelta5`** · bottone di scelta
> Torna nel foyer
>
> →


### Il Teatro del Passato › `palcoscenico`

**`TEA.palcoscenico.1`** · narrazione
> Da vicino il ragazzo è solo un ragazzo: fiato corto, mani fasciate, occhi che bruciano. Ti attraversa con lo sguardo — sei nel passato, per lui non esisti. Riparte da capo. Ancora. Ancora.
>
> →

**`TEA.palcoscenico.scelta1`** · bottone di scelta
> Apri il baule di scena
>
> →

**`TEA.palcoscenico.scelta2`** · bottone di scelta
> Vai dietro le quinte
>
> →

**`TEA.palcoscenico.scelta3`** · bottone di scelta
> Scendi in platea
>
> →


### Il Teatro del Passato › `quinte`

**`TEA.quinte.1`** · narrazione
> Dietro le quinte: corde, sacchi di sabbia, uno specchio con le lampadine. Infilata nella cornice dello specchio c'è una copia di uno strano biglietto.
>
> →

**`TEA.quinte.scelta1`** · bottone di scelta (fa raccogliere Copia di uno strano biglietto)
> Prendi la copia del biglietto
>
> →

**`TEA.quinte.scelta2`** · bottone di scelta
> Torna sul palcoscenico
>
> →


### Il Teatro del Passato › `galleria`

**`TEA.galleria.1`** · narrazione
> Dalla galleria il palco sembra piccolo e il ragazzo un punto che vola. Il lampadario di cristallo trattiene la luce come fosse fiato.
>
> →

**`TEA.galleria.scelta1`** · bottone di scelta
> Allunga la mano nella balaustra scollata
>
> →

**`TEA.galleria.scelta2`** · bottone di scelta
> Scendi in platea
>
> →


### Il Teatro del Passato › `botteghino`

**`TEA.botteghino.1`** · narrazione
> Il botteghino è ordinato, pronto per una fila che deve ancora arrivare. Il registro segna un solo biglietto venduto, prima fila.
>
> →

**`TEA.botteghino.scelta1`** · bottone di scelta
> Apri il doppio fondo del cassetto
>
> →

**`TEA.botteghino.scelta2`** · bottone di scelta
> Torna nel foyer
>
> →


## La Casa Gigante

<sub>`data/vuoti/casa_gigante.json`</sub>


### La Casa Gigante › `soglia`

**`CASA.soglia.1`** · narrazione
> Mi diceva mia madre: i bravi bambini restano lontani dalla grande casa in mezzo al bosco, non si avvicinano neanche per cogliere un fiore coperto di rugiada.<br>I bambini che disobbediscono vengono trasformati in bellissime bambole di ottima fattura... con vestiti eleganti e accessori sgargianti.<br>Diventano i giocattoli dei demoni che hanno occupato la casa... ci giocano e ci giocano e ci giocano ancora...<br>Finché ogni cucitura non è recisa... finché ogni porcellana non è insudiciata... finché ogni filo non viene tirato.<br>Un tempo questa casa donava amore e riparo... o forse... solo l'illusione di una vita perfetta...
>
> →

**`CASA.soglia.2`** · carta del titolo
> La Grande Magione Abbandonata
>
> →

**`CASA.soglia.scena`** · quando ci torni («Osserva la scena»)
> La facciata della grande casa ti sovrasta, storta, con tutte le finestre buie tranne una.
>
> →

**`CASA.soglia.scelta1`** · bottone di scelta
> Entra nella casa
>
> →

**`CASA.soglia.scelta2`** · bottone di scelta
> Va' verso i giardini
>
> →

**`CASA.soglia.scelta3`** · bottone di scelta (esce dallo squarcio)
> Torna nel Vuoto
>
> →

**`CASA.soglia.scelta4`** · bottone di scelta (esce dallo squarcio)
> Torna nel Vuoto
>
> →


### La Casa Gigante › `salone`

**`CASA.salone.1`** · narrazione
> Sembra tutto abbandonato da tantissimo tempo... la polvere è così fitta da sembrare una leggera nebbia...
>
> →

**`CASA.salone.scelta1`** · bottone di scelta
> Vai nella sala principale
>
> →

**`CASA.salone.scelta2`** · bottone di scelta
> Vai nell'ala destra
>
> →

**`CASA.salone.scelta3`** · bottone di scelta
> Vai nell'ala sinistra
>
> →

**`CASA.salone.scelta4`** · bottone di scelta
> Pianta un proiettore nel salone
>
> →

**`CASA.salone.scelta5`** · bottone di scelta
> Torna alla soglia
>
> →


### La Casa Gigante › `sala_principale`

**`CASA.sala_principale.1`** · narrazione
> Sembra che le pareti siano addobbate con i quadri di gente che probabilmente viveva in questo posto...
>
> →

**`CASA.sala_principale.scelta1`** · bottone di scelta
> Osserva il quadro dell'uomo
>
> →

**`CASA.sala_principale.scelta2`** · bottone di scelta
> Osserva il quadro della donna
>
> →

**`CASA.sala_principale.scelta3`** · bottone di scelta
> Osserva il quadro di famiglia
>
> →

**`CASA.sala_principale.scelta4`** · bottone di scelta
> Fruga sotto i cuscini del divano
>
> →

**`CASA.sala_principale.scelta5`** · bottone di scelta
> Vai in cucina
>
> →

**`CASA.sala_principale.scelta6`** · bottone di scelta
> Sali le scale
>
> →

**`CASA.sala_principale.scelta7`** · bottone di scelta
> Torna al salone
>
> →


### La Casa Gigante › `ala_destra`

**`CASA.ala_destra.1`** · narrazione
> Alte colonne si ergono lungo un corridoio a scacchi: la polvere ha reso ormai le mattonelle bianche di un giallo ocra molto oscuro...
>
> →

**`CASA.ala_destra.2`** · battuta di Anonimo
> ... C'è qualcosa sotto questa piastrella.
>
> →

**`CASA.ala_destra.3`** · battuta di Anonimo
> Sembra che non ci sia altro se non stanze completamente piene di macerie, oltre questo punto...
>
> →

**`CASA.ala_destra.scena`** · quando ci torni («Osserva la scena»)
> Il corridoio a scacchi dell'ala destra, e in fondo le stanze sfondate dalle macerie. Non porta da nessuna parte.
>
> →

**`CASA.ala_destra.scelta1`** · bottone di scelta (fa raccogliere Spilla a margherita)
> Alza la piastrella
>
> →

**`CASA.ala_destra.scelta2`** · bottone di scelta
> Torna al salone
>
> →


### La Casa Gigante › `ala_sinistra`

**`CASA.ala_sinistra.1`** · battuta di Anonimo
> Mh... sembrerebbe non esserci nulla qui dentro. Certo che questa famiglia doveva possedere un'ingente quantità di soldi, per permettersi un posto del genere...
>
> →

**`CASA.ala_sinistra.scena`** · quando ci torni («Osserva la scena»)
> L'ala sinistra: stanze grandi, vuote, e niente dentro a parte la polvere.
>
> →

**`CASA.ala_sinistra.scelta1`** · bottone di scelta
> Torna al salone
>
> →


### La Casa Gigante › `quadro_uomo`

**`CASA.quadro_uomo.1`** · narrazione
> Sembra un uomo molto severo... le rughe sul suo volto fanno trasparire un'estrema tristezza e una rabbia sempre tenuta a bada.
>
> →

**`CASA.quadro_uomo.scelta1`** · bottone di scelta
> Torna nella sala principale
>
> →


### La Casa Gigante › `quadro_donna`

**`CASA.quadro_donna.1`** · narrazione
> Una donna di una certa età... cos'ha in mano? Il suo sguardo non ti fa sentire al sicuro.
>
> →

**`CASA.quadro_donna.scelta1`** · bottone di scelta
> Torna nella sala principale
>
> →


### La Casa Gigante › `quadro_famiglia`

**`CASA.quadro_famiglia.1`** · narrazione
> Ci sono un uomo, una donna, una bambina con una bambola in braccio e una donna anziana in posa... la donna più anziana ha uno sguardo che farebbe gelare il sangue a molti... Non sembrano molto felici...
>
> →

**`CASA.quadro_famiglia.scelta1`** · bottone di scelta
> Torna nella sala principale
>
> →


### La Casa Gigante › `mensola`

**`CASA.mensola.1`** · narrazione
> Tutti gli strumenti in questa cucina sembrano di ottima fattura, c'è un forte odore di ammoniaca e detersivi sopravvissuto anche al tempo...
>
> →

**`CASA.mensola.2`** · battuta di Anonimo
> Queste sostanze sono molto pericolose se ingerite... cosa ci fanno in una cucina?
>
> →

**`CASA.mensola.scena`** · quando ci torni («Osserva la scena»)
> La mensola dei detersivi, allineati come in una vetrina. L'odore di ammoniaca non se ne va.
>
> →

**`CASA.mensola.scelta1`** · bottone di scelta
> Torna in cucina
>
> →


### La Casa Gigante › `cucina`

**`CASA.cucina.1`** · narrazione
> Pentole in fila, un tavolo apparecchiato per tre da molto tempo, senza che nessuno l'abbia mai sparecchiato. In una credenza, bottiglie impolverate; in un'altra, qualcosa di dolce.
>
> →

**`CASA.cucina.scelta1`** · bottone di scelta
> Fruga nella mensola
>
> →

**`CASA.cucina.scelta2`** · bottone di scelta (fa raccogliere Vino di ottima qualità)
> Stappa una bottiglia di vino di ottima qualità
>
> →

**`CASA.cucina.scelta3`** · bottone di scelta (fa raccogliere Pacco di merendine scadute)
> Fruga nella credenza dei dolci
>
> →

**`CASA.cucina.scelta4`** · bottone di scelta
> Torna nella sala principale
>
> →


### La Casa Gigante › `scala`

**`CASA.scala.1`** · narrazione
> La scala sale attraverso piani che sembrano più numerosi di quanti dovrebbero essere.
>
> →

**`CASA.scala.2`** · battuta di Anonimo
> Questa casa è immensa... la maggior parte delle stanze sono vuote... come se qualcuno avesse portato via tutto...
>
> →

**`CASA.scala.scena`** · quando ci torni («Osserva la scena»)
> La scala, e i suoi piani che non finiscono mai. Da qui si arriva ovunque, in questa casa.
>
> →

**`CASA.scala.scelta1`** · bottone di scelta
> Entra nella stanza dei giochi
>
> →

**`CASA.scala.scelta2`** · bottone di scelta
> Sali fino alla soffitta
>
> →

**`CASA.scala.scelta3`** · bottone di scelta
> Entra nel grande bagno
>
> →

**`CASA.scala.scelta4`** · bottone di scelta
> Pianta un proiettore in cima alla scala
>
> →

**`CASA.scala.scelta5`** · bottone di scelta
> Scendi nella sala principale
>
> →


### La Casa Gigante › `grande_bagno`

**`CASA.grande_bagno.1`** · battuta di Anonimo
> Questo bagno è enorme... l'acqua non funziona più... un tempo deve essere stato bellissimo rilassarsi qui...
>
> →

**`CASA.grande_bagno.scena`** · quando ci torni («Osserva la scena»)
> Il grande bagno, le rubinetterie secche e la vasca piena di calcinacci.
>
> →

**`CASA.grande_bagno.scelta1`** · bottone di scelta
> Torna alla scala
>
> →


### La Casa Gigante › `stanza_giochi`

**`CASA.stanza_giochi.1`** · narrazione
> La stanza dei giochi: scaffali di giocattoli allineati come spettatori, un baule, e un mucchio di cuscini contro il muro. Tre fotografie, in cornici diverse, osservano la stanza da un comò.
>
> →

**`CASA.stanza_giochi.scelta1`** · bottone di scelta
> Osserva la prima fotografia
>
> →

**`CASA.stanza_giochi.scelta2`** · bottone di scelta
> Osserva la seconda fotografia
>
> →

**`CASA.stanza_giochi.scelta3`** · bottone di scelta
> Osserva la terza fotografia
>
> →

**`CASA.stanza_giochi.scelta4`** · bottone di scelta (fa raccogliere Fiala HP)
> Apri il baule dei giocattoli
>
> →

**`CASA.stanza_giochi.scelta5`** · bottone di scelta
> Scendi nella botola
>
> →

**`CASA.stanza_giochi.scelta6`** · bottone di scelta
> Prova la matrice sul lettore
>
> →

**`CASA.stanza_giochi.scelta7`** · bottone di scelta
> Esamina il lettore della botola
>
> →

**`CASA.stanza_giochi.scelta8`** · bottone di scelta
> Torna alla scala
>
> →


### La Casa Gigante › `foto_1`

**`CASA.foto_1.1`** · narrazione
> Una fotografia ingiallita: una ragazzina, forse sei o sette anni, gioca seduta per terra con una bambola fatta a mano. Sta ridendo.
>
> →

**`CASA.foto_1.scelta1`** · bottone di scelta
> Torna alla stanza dei giochi
>
> →


### La Casa Gigante › `foto_2`

**`CASA.foto_2.1`** · narrazione
> La stessa ragazzina, cresciuta: un vestito più elegante, una posa più composta. Tiene ancora la bambola, stretta contro il fianco, come se qualcuno potesse portargliela via da un momento all'altro.
>
> →

**`CASA.foto_2.scelta1`** · bottone di scelta
> Torna alla stanza dei giochi
>
> →


### La Casa Gigante › `foto_3`

**`CASA.foto_3.1`** · narrazione
> Una festa di compleanno: candeline, un tavolo pieno di regali che sembrano tutti uguali e tutti sbagliati. La ragazzina è al centro, la bambola in grembo. Non sorride, in questa.
>
> →

**`CASA.foto_3.scelta1`** · bottone di scelta
> Torna alla stanza dei giochi
>
> →


### La Casa Gigante › `soffitta`

**`CASA.soffitta.1`** · battuta di Anonimo
> Questa vecchia soffitta sembra cadere a pezzi, se non fosse per la luce della luna che passa attraverso le fessure, non vedresti nulla...
>
> →

**`CASA.soffitta.scena`** · quando ci torni («Osserva la scena»)
> La soffitta: scatoloni ovunque, tutti con la stessa scritta a mano. Nessuno è mai stato buttato.
>
> →

**`CASA.soffitta.scelta1`** · bottone di scelta (fa raccogliere Collana particolare)
> Rovista tra gli scatoloni
>
> →

**`CASA.soffitta.scelta2`** · bottone di scelta
> Controlla dentro un vecchio baule chiuso a chiave
>
> →

**`CASA.soffitta.scelta3`** · bottone di scelta
> Un altro sottoscala porta più su, verso l'attico
>
> →

**`CASA.soffitta.scelta4`** · bottone di scelta
> Torna alla scala
>
> →


### La Casa Gigante › `attico`

**`CASA.attico.1`** · narrazione
> Salendo ancora più in alto la polvere sembra diminuire, in questo piccolo attico puoi respirare più liberamente...
>
> →

**`CASA.attico.2`** · battuta di Anonimo
> Sento uno strano potere... mi ricorda... Veronica? Non può essere...
>
> →

**`CASA.attico.scena`** · quando ci torni («Osserva la scena»)
> L'attico, basso e lungo. In fondo, sotto uno spiovente, una porta chiusa da cui filtra una luce fioca e costante.
>
> →

**`CASA.attico.scelta1`** · bottone di scelta
> Apri la porta della camera da letto
>
> →

**`CASA.attico.scelta2`** · bottone di scelta
> Torna alla soffitta
>
> →


### La Casa Gigante › `camera_da_letto`

**`CASA.camera_da_letto.1`** · narrazione
> Sembra esserci qualcuno...
>
> →

**`CASA.camera_da_letto.2`** · battuta di Yhvina
> Eh? E tu chi sei? Non mi aspettavo di trovare qualcun altro...
>
> →

**`CASA.camera_da_letto.3`** · battuta di Yhvina
> Hm... sembra che anche tu sia come me... Lo percepisci anche tu vero? Altrimenti non saresti qui... C'è qualcosa di estremamente sbagliato in questo posto...
>
> →

**`CASA.camera_da_letto.4`** · battuta di Anonimo
> In realtà io sono qui per conto dell'organizzazione... questo squarcio dovrebbe essere di mia competenza... Tu come ci sei finita qui?
>
> →

**`CASA.camera_da_letto.5`** · battuta di Yhvina
> Organizzazione? Io sono qui per puro caso... mi capita di addormentarmi e ritrovarmi in posti come questo... Da qualche parte deve esserci qualcuno... o meglio qualcosa... che genera tutto questo... Io voglio solo andare a casa e farmi una dormita.
>
> →

**`CASA.camera_da_letto.6`** · battuta di Anonimo
> Pensandoci bene, abbiamo un obiettivo in comune... sarebbe una buona mossa proporle di andare a fondo in questa questione insieme...
>
> →

**`CASA.camera_da_letto.scena`** · quando ci torni («Osserva la scena»)
> La camera da letto sotto lo spiovente: un materasso per terra, una lampada che nessuno spegne mai.
>
> →

**`CASA.camera_da_letto.scelta1`** · bottone di scelta
> Chiedile di combattere al tuo fianco
>
> →

**`CASA.camera_da_letto.scelta2`** · bottone di scelta
> "Ce la faccio da solo."
>
> →


### La Casa Gigante › `yhvina_si`

**`CASA.yhvina_si.1`** · narrazione
> Proponi a Yhvina di unirsi a te.
>
> →

**`CASA.yhvina_si.2`** · battuta di Anonimo
> Ehm... perché mi guarda così? Cos'è quell'espressione disgustata...?
>
> →

**`CASA.yhvina_si.3`** · battuta di Yhvina
> Hmpf... beh, una cosa è certa, prima finisce questa storia, meglio è... Ma non montarti la testa, una volta finita questa storia, ognuno per la sua strada.
>
> →

**`CASA.yhvina_si.4`** · narrazione
> Le mani di Yhvina cambiano e il suo sguardo non ti rassicura per niente...
>
> →

**`CASA.yhvina_si.5`** · battuta di Yhvina
> Su, andiamo, abbiamo già perso fin troppo tempo.
>
> →

**`CASA.yhvina_si.scena`** · quando ci torni («Osserva la scena»)
> Yhvina è in piedi accanto alla porta, e aspetta che sia tu a muoverti.
>
> →

**`CASA.yhvina_si.scelta1`** · bottone di scelta
> Esci dalla camera
>
> →


### La Casa Gigante › `stanza_studi`

**`CASA.stanza_studi.1`** · narrazione
> Sotto i cuscini, la botola dà su una stanza degli studi: scrivania, diplomi alle pareti, e un fascicolo lasciato aperto come se qualcuno l'avesse richiuso in fretta, tanti anni fa.
>
> →

**`CASA.stanza_studi.scelta1`** · bottone di scelta
> Leggi la cartella clinica
>
> →

**`CASA.stanza_studi.scelta2`** · bottone di scelta
> Prosegui nel tunnel
>
> →

**`CASA.stanza_studi.scelta3`** · bottone di scelta
> Risali dalla botola
>
> →


### La Casa Gigante › `cartella_clinica`

**`CASA.cartella_clinica.1`** · narrazione
> "...sbalzi di umore frequenti, episodi depressivi persistenti. Livelli di disallineamento anomali per l'età. Salute generale carente." La firma in fondo è illeggibile quanto il resto.
>
> →

**`CASA.cartella_clinica.scelta1`** · bottone di scelta
> Richiudi il fascicolo
>
> →


### La Casa Gigante › `tunnel`

**`CASA.tunnel.1`** · narrazione
> Un tunnel scavato a mano, stretto, che scende oltre le fondamenta della casa. L'aria si fa più fredda a ogni passo.
>
> →

**`CASA.tunnel.2`** · battuta di Anonimo
> L'aria è fredda... presumo che ci siamo...
>
> →

**`CASA.tunnel.3`** · battuta di Yhvina
> Lo senti anche tu, vero? Quello che vogliamo trovare si trova in fondo a questo tunnel...
>
> →

**`CASA.tunnel.scena`** · quando ci torni («Osserva la scena»)
> Il tunnel scavato a mano scende oltre le fondamenta. Più avanti, il freddo.
>
> →

**`CASA.tunnel.scelta1`** · bottone di scelta
> Avanza verso la luce in fondo
>
> →

**`CASA.tunnel.scelta2`** · bottone di scelta
> Torna alla stanza degli studi
>
> →


### La Casa Gigante › `altare`

**`CASA.altare.1`** · narrazione
> Un altare tributario, costruito con le mani: candele consumate, una foto incorniciata, e un mucchio di lettere ingiallite. Ai piedi dell'altare, buttata su un fianco, una bambola sporca di terra. Oltre le candele, nel buio, si intuisce qualcosa di enorme incassato nella parete di fondo.
>
> →

**`CASA.altare.scelta1`** · bottone di scelta
> Leggi le lettere
>
> →

**`CASA.altare.scelta2`** · bottone di scelta
> Brucia le lettere
>
> →

**`CASA.altare.scelta3`** · bottone di scelta (fa raccogliere Vino di ottima qualità)
> Stappa l'ultima bottiglia di vino di ottima qualità
>
> →

**`CASA.altare.scelta4`** · bottone di scelta
> Osserva da vicino la foto sull'altare
>
> →

**`CASA.altare.scelta5`** · bottone di scelta
> Guarda oltre l'altare, nel buio
>
> →

**`CASA.altare.scelta6`** · bottone di scelta
> L'altare è silenzioso, ora.
>
> →

**`CASA.altare.scelta7`** · bottone di scelta
> Guarda oltre l'altare, nel buio
>
> →

**`CASA.altare.scelta8`** · bottone di scelta
> Torna al tunnel
>
> →


### La Casa Gigante › `presentazione_ricordo`

**`CASA.presentazione_ricordo.1`** · narrazione
> Quando si vuole bene a qualcuno, un legame viene creato... come migliaia di fili intrecciati diventa sempre più solido.<br>Che nessuno osi dividere quello che è stato unito dall'amore... Sono questioni superiori agli uomini...<br>Così... filo su filo si tesse una piccola bambola di pezza, non troppo bella non troppo brutta... ma colma di amore...<br>E con lo spezzarsi di quel legame... così come si sfalda una bambola, cominciò a sfaldarsi la fortuna di chi osò calpestare la tenerezza di un legame nato dal sentimento più puro...
>
> →

**`CASA.presentazione_ricordo.2`** · carta del titolo
> Un tenero ricordo
>
> →


### La Casa Gigante › `porta_bloccata`

**`CASA.porta_bloccata.1`** · narrazione
> Fai un passo oltre le candele, e la bambola si volta di scatto verso di te — non ti aveva mai guardato prima. Non si muove, non parla: si limita a restare tra te e il buio, e in qualche modo è più che sufficiente. Meglio non insistere. Non ancora.
>
> →

**`CASA.porta_bloccata.scelta1`** · bottone di scelta
> Torna all'altare
>
> →


### La Casa Gigante › `porta_enorme`

**`CASA.porta_enorme.1`** · narrazione
> Con la bambola non più a guardia, il passo oltre l'altare è libero: una porta enorme, sproporzionata perfino per questa casa, incassata nella roccia oltre le candele consumate. Nessuna maniglia, solo un meccanismo circolare al centro, coperto di polvere e fermo da chissà quanto.
>
> →

**`CASA.porta_enorme.scelta1`** · bottone di scelta
> Prova ad aprirla
>
> →

**`CASA.porta_enorme.scelta2`** · bottone di scelta
> Non si muove di un millimetro. Non è ancora il momento.
>
> →


### La Casa Gigante › `lettere_lettura`

**`CASA.lettere_lettura.1`** · narrazione
> Sono lettere mai spedite, scritte dai genitori: parlano di rimorso, di quanto avrebbero voluto tornare indietro. "Se solo non avessimo preteso così tanto da te," dice una. Un'altra si interrompe a metà frase.
>
> →

**`CASA.lettere_lettura.scelta1`** · bottone di scelta
> Richiudi le lettere
>
> →


### La Casa Gigante › `lettere_bruciate`

**`CASA.lettere_bruciate.1`** · narrazione
> Le accendi una a una, sull'ultima candela ancora viva. Il rimorso di chi le ha scritte non serve più a nessuno: bruciano in fretta, come se anche loro non aspettassero altro.
>
> →

**`CASA.lettere_bruciate.scelta1`** · bottone di scelta
> Torna all'altare
>
> →


### La Casa Gigante › `ricordo_concluso`

**`CASA.ricordo_concluso.1`** · narrazione
> Le cuciture non cedono: si strappano. La bambola si apre da sola lungo le giunture, un filo dopo l'altro, e ogni strappo suona come qualcosa che si rompe dentro un corpo vero.
>
> →

**`CASA.ricordo_concluso.2`** · narrazione
> Le ombre nere escono da lei tutte insieme, si spargono sulle pareti e scappano in ogni direzione, disperdendosi con lamenti assordanti che ti restano nelle orecchie molto dopo che il buio le ha inghiottite.
>
> →

**`CASA.ricordo_concluso.3`** · battuta di Un tenero ricordo
> ...volevo, giocare... ancora... un po'...
>
> →

**`CASA.ricordo_concluso.4`** · narrazione
> Quello che resta a terra non somiglia più a niente. L'atmosfera trasuda una tristezza profonda e umida... sembra quasi di aver fatto la cosa sbagliata...
>
> →

**`CASA.ricordo_concluso.scelta1`** · bottone di scelta (fa raccogliere Prova di un forte amore)
> Raccogli ciò che resta
>
> →


### La Casa Gigante › `ricordo_concluso_buono`

**`CASA.ricordo_concluso_buono.1`** · narrazione
> La bambola comincia a sfilacciarsi lo stesso, ma questa volta senza opporre resistenza: le ombre nere si ritirano piano dalle pareti, senza violenza.
>
> →

**`CASA.ricordo_concluso_buono.2`** · battuta di Un tenero ricordo
> ...Lylloh... sei tornata a giocare con me?
>
> →

**`CASA.ricordo_concluso_buono.3`** · narrazione
> Quello che resta, nell'aria, non è più dolore: solo quiete.
>
> →

**`CASA.ricordo_concluso_buono.4`** · battuta di Un tenero ricordo
> Grazie... per non avermi dimenticata.
>
> →

**`CASA.ricordo_concluso_buono.scelta1`** · bottone di scelta (fa raccogliere Prova di un forte amore)
> Raccogli ciò che resta
>
> →


### La Casa Gigante › `congedo_yhvina`

**`CASA.congedo_yhvina.1`** · battuta di Yhvina
> Bene, sembrerebbe che il nostro lavoro qui sia terminato, sembra che potrò tornare finalmente a casa.
>
> →

**`CASA.congedo_yhvina.2`** · battuta di Yhvina
> Ecco che arriva... Bene. Se il destino vorrà, ci rivedremo ancora.
>
> →

**`CASA.congedo_yhvina.3`** · narrazione
> Uno squarcio deforma Yhvina che scompare senza lasciare alcuna traccia... quando uno squarcio si chiude, tutto quello che ha portato viene riportato indietro.
>
> →

**`CASA.congedo_yhvina.4`** · narrazione
> Il tuo compito sembra essere terminato.
>
> →

**`CASA.congedo_yhvina.scena`** · quando ci torni («Osserva la scena»)
> Dove c'era Yhvina non è rimasto niente. Il tuo compito, qui, è terminato.
>
> →

**`CASA.congedo_yhvina.scelta1`** · bottone di scelta
> Torna verso l'altare
>
> →


### La Casa Gigante › `cacciata`

**`CASA.cacciata.1`** · narrazione
> Qualcosa ti solleva di peso e la casa ti scaraventa fuori, oltre lo squarcio. La ninna nanna riprende, stonata come prima.
>
> →

**`CASA.cacciata.scelta1`** · bottone di scelta
> Riprendi dall'ultimo salvataggio
>
> →


### La Casa Gigante › `giardino_ingresso`

**`CASA.giardino_ingresso.1`** · battuta di Anonimo
> Andando da questa parte sembra esserci l'entrata verso un giardino...
>
> →

**`CASA.giardino_ingresso.scena`** · quando ci torni («Osserva la scena»)
> Il vialetto che porta al giardino, sul fianco della casa.
>
> →

**`CASA.giardino_ingresso.scelta1`** · bottone di scelta
> Entra nel giardino
>
> →

**`CASA.giardino_ingresso.scelta2`** · bottone di scelta
> Torna alla soglia
>
> →


### La Casa Gigante › `giardino`

**`CASA.giardino.1`** · narrazione
> Una luna bellissima illumina il giardino. Puoi scorgere poco e niente fra i rami... ogni tanto, tra le foglie, un movimento rapido e sfuggevole ti fa rimanere all'erta.
>
> →

**`CASA.giardino.scena`** · quando ci torni («Osserva la scena»)
> Il giardino sotto la luna. Tre sentieri: est, ovest, nord.
>
> →

**`CASA.giardino.scelta1`** · bottone di scelta
> Prendi il sentiero verso il giardino est
>
> →

**`CASA.giardino.scelta2`** · bottone di scelta
> Prendi il sentiero verso il giardino ovest
>
> →

**`CASA.giardino.scelta3`** · bottone di scelta
> Prendi il sentiero verso il giardino nord
>
> →

**`CASA.giardino.scelta4`** · bottone di scelta
> Pianta un proiettore nel giardino
>
> →

**`CASA.giardino.scelta5`** · bottone di scelta
> Torna verso la soglia
>
> →


### La Casa Gigante › `giardino_est`

**`CASA.giardino_est.1`** · battuta di Anonimo
> ... C'è un profondo silenzio in questo posto...
>
> →

**`CASA.giardino_est.scena`** · quando ci torni («Osserva la scena»)
> Il giardino est. Il silenzio, qui, è più fitto che altrove.
>
> →

**`CASA.giardino_est.scelta1`** · bottone di scelta (fa raccogliere Fiore di luna, Fiore di luna)
> Esplora il giardino est
>
> →

**`CASA.giardino_est.scelta2`** · bottone di scelta
> Addentrati nel giardino est
>
> →

**`CASA.giardino_est.scelta3`** · bottone di scelta
> Torna al giardino
>
> →


### La Casa Gigante › `fiori_di_luna`

**`CASA.fiori_di_luna.1`** · narrazione
> Tra l'erba alta, due fiori pallidi si aprono solo di notte.
>
> →

**`CASA.fiori_di_luna.2`** · battuta di Anonimo
> Questi campioni possono essere utili... posso portarli nella serra dell'Organizzazione, o consumarli nel caso venga colpito da un essere velenoso.
>
> →

**`CASA.fiori_di_luna.3`** · narrazione
> I fiori di luna sono fiori comuni, utilizzati per trattare lievi infezioni o avvelenamenti. Oltre a essere belli, possono anche essere molto utili.
>
> →

**`CASA.fiori_di_luna.scelta1`** · bottone di scelta
> Torna a guardarti intorno
>
> →


### La Casa Gigante › `albero_voce`

**`CASA.albero_voce.1`** · battuta di Anonimo
> Non sembra essere possibile procedere oltre...
>
> →

**`CASA.albero_voce.2`** · battuta di Spirito dei giardini
> Hey... tu...
>
> →

**`CASA.albero_voce.3`** · battuta di Anonimo
> ?
>
> →

**`CASA.albero_voce.4`** · battuta di Spirito dei giardini
> ... Qui, vicino all'albero...
>
> →

**`CASA.albero_voce.scena`** · quando ci torni («Osserva la scena»)
> La profondità del giardino est. L'albero grande in fondo, e niente altro.
>
> →

**`CASA.albero_voce.scelta1`** · bottone di scelta
> Avvicinati
>
> →

**`CASA.albero_voce.scelta2`** · bottone di scelta
> Vai via
>
> →


### La Casa Gigante › `voce_ignorata`

**`CASA.voce_ignorata.1`** · battuta di Spirito dei giardini
> Hey... dove... vai? Aspetta...
>
> →

**`CASA.voce_ignorata.scelta1`** · bottone di scelta
> Torna indietro e avvicinati
>
> →

**`CASA.voce_ignorata.scelta2`** · bottone di scelta
> Torna al giardino est
>
> →


### La Casa Gigante › `voce_avvicinati`

**`CASA.voce_avvicinati.1`** · battuta di Anonimo
> Sembra provenire da qui...
>
> →

**`CASA.voce_avvicinati.2`** · battuta di Spirito dei giardini
> Lei è qui per aiutare la signorina Lylloh?
>
> →

**`CASA.voce_avvicinati.3`** · battuta di Anonimo
> ? Chi parla?
>
> →

**`CASA.voce_avvicinati.4`** · battuta di Spirito dei giardini
> ... Devo aver sbagliato persona...
>
> →

**`CASA.voce_avvicinati.5`** · narrazione
> Cerchi ovunque... ma sembra che la voce non ci sia più. Qualunque cosa fosse, ormai è andata via.
>
> →

**`CASA.voce_avvicinati.scelta1`** · bottone di scelta
> Torna al giardino est
>
> →


### La Casa Gigante › `albero_voce_spilla`

**`CASA.albero_voce_spilla.1`** · battuta di Spirito dei giardini
> ... Signorina Lylloh? È lei?
>
> →

**`CASA.albero_voce_spilla.scena`** · quando ci torni («Osserva la scena»)
> La profondità del giardino est. L'albero grande in fondo, e niente altro.
>
> →

**`CASA.albero_voce_spilla.scelta1`** · bottone di scelta
> Mostra la spilla a margherita
>
> →

**`CASA.albero_voce_spilla.scelta2`** · bottone di scelta
> Torna al giardino est
>
> →


### La Casa Gigante › `spirito_rivelato`

**`CASA.spirito_rivelato.1`** · battuta di Spirito dei giardini
> ...
>
> →

**`CASA.spirito_rivelato.2`** · battuta di Spirito dei giardini
> Come fa ad avere la spilla della signorina? Le ha per caso fatto del male?!
>
> →

**`CASA.spirito_rivelato.3`** · battuta di Anonimo
> Non so di cosa parli. Ho raccolto questo oggetto nei pressi dell'ala sinistra della casa, che si trova poco lontano da qui.
>
> →

**`CASA.spirito_rivelato.4`** · battuta di Spirito dei giardini
> ...
>
> →

**`CASA.spirito_rivelato.5`** · narrazione
> Le foglie cominciano a muoversi freneticamente e il vento si alza lievemente... Dall'albero centrale un volto appare sulla sua superficie.
>
> →

**`CASA.spirito_rivelato.6`** · battuta di Spirito dei giardini
> Cosa... è successo alla signorina Lylloh?
>
> →

**`CASA.spirito_rivelato.7`** · battuta di Anonimo
> Non saprei rispondere a questa domanda. Io sono qui con un compito ben preciso... Ma penso che la persona che lei chiama signorina Lylloh, purtroppo, non ci sia più.
>
> →

**`CASA.spirito_rivelato.8`** · battuta di Spirito dei giardini
> ... Dovevo immaginarlo. Ho perso il conto dei giorni che ho passato innaffiando queste piante... da quando non mi è stato più permesso avvicinarmi alla magione...
>
> →

**`CASA.spirito_rivelato.9`** · battuta di Spirito dei giardini
> Cosa... ci fa lei esattamente qui?
>
> →

**`CASA.spirito_rivelato.10`** · battuta di Anonimo
> Sarebbe crudele dirle la verità... ancora non ho capito se è ostile o meno... sarà meglio limitarmi a investigare su cosa è accaduto qui.
>
> →

**`CASA.spirito_rivelato.11`** · battuta di Anonimo
> Sono qui solo di passaggio, siccome è stato richiesto il mio... aiuto. Qualunque cosa sia successa qui, io sono venuto per risolverla.
>
> →

**`CASA.spirito_rivelato.12`** · battuta di Anonimo
> Vorrei sapere di più su questo posto, e su cosa devo aspettarmi da te.
>
> →

**`CASA.spirito_rivelato.13`** · battuta di Spirito dei giardini
> Hohoho... Che giovinotto energico... Io sono solo una vecchia custode, con un grande amore verso questo giardino e verso la signorina...
>
> →

**`CASA.spirito_rivelato.14`** · battuta di Spirito dei giardini
> Se lei è qui per aiutare... non la intralcerò. Anzi... se ha bisogno di farsi due chiacchiere con una povera vecchia, sarò felice di aiutarla... hohoho...
>
> →

**`CASA.spirito_rivelato.scelta1`** · bottone di scelta
> Resta a parlare con lei
>
> →


### La Casa Gigante › `spirito_hub`

**`CASA.spirito_hub.1`** · battuta di Spirito dei giardini
> Hohoho... Mi dica pure, giovinotto.
>
> →

**`CASA.spirito_hub.scena`** · quando ci torni («Osserva la scena»)
> Il volto della vecchia custode, sulla corteccia dell'albero grande.
>
> →

**`CASA.spirito_hub.scelta1`** · bottone di scelta
> Chiedi consiglio su dove cercare
>
> →

**`CASA.spirito_hub.scelta2`** · bottone di scelta
> Chiedile come si apre la botola
>
> →

**`CASA.spirito_hub.scelta3`** · bottone di scelta
> Chiedile ancora dei laboratori
>
> →

**`CASA.spirito_hub.scelta4`** · bottone di scelta
> Mostrale la matrice
>
> →

**`CASA.spirito_hub.scelta5`** · bottone di scelta
> Chiedile ancora del vivaio
>
> →

**`CASA.spirito_hub.scelta6`** · bottone di scelta
> Chiedile del passato di questa casa
>
> →

**`CASA.spirito_hub.scelta7`** · bottone di scelta
> Falle compagnia un momento
>
> →

**`CASA.spirito_hub.scelta8`** · bottone di scelta
> Torna al giardino est
>
> →


### La Casa Gigante › `spirito_indizio_yhvina`

**`CASA.spirito_indizio_yhvina.1`** · battuta di Spirito dei giardini
> Nei piani superiori della casa ho visto da qui aggirarsi qualcuno... forse dovresti dare un'occhiata... hohoho...
>
> →

**`CASA.spirito_indizio_yhvina.scelta1`** · bottone di scelta
> Ringraziala
>
> →


### La Casa Gigante › `spirito_laboratori`

**`CASA.spirito_laboratori.1`** · battuta di Yhvina
> ... Cos'è quello?
>
> →

**`CASA.spirito_laboratori.2`** · battuta di Spirito dei giardini
> Hohoho... Vedo che hai trovato una compagna molto elegante. Che bella fanciulla!
>
> →

**`CASA.spirito_laboratori.3`** · battuta di Yhvina
> ...
>
> →

**`CASA.spirito_laboratori.4`** · battuta di Spirito dei giardini
> Hohoho, che fanciulla tenera!
>
> →

**`CASA.spirito_laboratori.5`** · battuta di Yhvina
> Hmpf, ecco un'altra persona sfacciata! Vedo che questo posto è pieno di maleducati! Yawn...
>
> →

**`CASA.spirito_laboratori.6`** · battuta di Anonimo
> Abbiamo trovato una botola in una stanza del primo piano... sapresti dirmi come aprirla?
>
> →

**`CASA.spirito_laboratori.7`** · battuta di Spirito dei giardini
> Hmmm... Sì. Le stanze inferiori erano una prerogativa dei signori: a me non era consentito accedervi.
>
> →

**`CASA.spirito_laboratori.8`** · battuta di Spirito dei giardini
> Forse dovreste provare a cercare nei laboratori sull'altro lato del giardino... potreste trovare una copia delle chiavi di accesso dei signori da quelle parti. Era in quel centro di ricerca che fabbricavano le varie chiavi di accesso della magione.
>
> →

**`CASA.spirito_laboratori.9`** · battuta di Yhvina
> Ottimo, allora è deciso: andremo verso i giardini a ovest.
>
> →

**`CASA.spirito_laboratori.10`** · battuta di Spirito dei giardini
> Che ragazza decisa... Mi ricordi la mia piccola bambina. Non la vedo da quando ha cominciato a lavorare per quel gruppo di ricercatori su Terna 9... Sai, hai gli stessi occhi stanchi... dovresti riposarti un pochino, tesoro.
>
> →

**`CASA.spirito_laboratori.11`** · battuta di Yhvina
> Non si preoccupi, io purtroppo non dormo mai. Non è che non voglia... Non dipende da me.
>
> →

**`CASA.spirito_laboratori.12`** · battuta di Spirito dei giardini
> Sento che non sei come gli altri, hohoho... Non dirò altro. Ma prenditi cura di te, tesoro.
>
> →

**`CASA.spirito_laboratori.13`** · battuta di Yhvina
> ...
>
> →

**`CASA.spirito_laboratori.scelta1`** · bottone di scelta
> Torna a parlarle
>
> →


### La Casa Gigante › `spirito_laboratori_ancora`

**`CASA.spirito_laboratori_ancora.1`** · battuta di Spirito dei giardini
> Hai provato a cercare nei laboratori?
>
> →

**`CASA.spirito_laboratori_ancora.scelta1`** · bottone di scelta
> Torna a parlarle
>
> →


### La Casa Gigante › `spirito_matrice`

**`CASA.spirito_matrice.1`** · battuta di Spirito dei giardini
> Hohoho... Come prosegue il suo lavoro? Ha trovato quel che cercava? Si sta prendendo cura della sua amica?
>
> →

**`CASA.spirito_matrice.2`** · battuta di Yhvina
> Sono io che mi prendo cura di lui. Se non ci fossi io, probabilmente sarebbe rimasto a contare le macerie di quel rudere laggiù.
>
> →

**`CASA.spirito_matrice.3`** · battuta di Spirito dei giardini
> Hohoho, non ne dubito, signorina! Come sempre la trovo stanca ma in forma!
>
> →

**`CASA.spirito_matrice.4`** · battuta di Yhvina
> Bisogna fare quel che bisogna fare... yaaawn...
>
> →

**`CASA.spirito_matrice.5`** · battuta di Spirito dei giardini
> Ma passiamo a noi: hai l'espressione di chi deve chiedermi qualcosa.
>
> →

**`CASA.spirito_matrice.6`** · battuta di Anonimo
> La matrice da sola non serve... sembrerebbe aver bisogno di un chip di identificazione da inserire. Ha idea se i padroni della casa avessero qualcosa di simile?
>
> →

**`CASA.spirito_matrice.7`** · battuta di Spirito dei giardini
> I signori, dopo la disgrazia, non sono più tornati in questa casa... solo la capofamiglia abitava la magione. Soleva aggirarsi sempre nel vivaio da quando è rimasta sola: adorava i suoi fiori, non ha mai dato importanza ad altro. Ricordo ancora i bei tempi passati con il signorino, prima che diventasse adulto... era un giovanotto molto solo. Forse dovreste perlustrare il vivaio.
>
> →

**`CASA.spirito_matrice.8`** · battuta di Anonimo
> Dobbiamo trovare un modo per distruggere quei rovi...
>
> →

**`CASA.spirito_matrice.9`** · battuta di Spirito dei giardini
> Rovi?
>
> →

**`CASA.spirito_matrice.10`** · battuta di Anonimo
> Sì, dei rovi ci impediscono di proseguire: l'intero vivaio sembra inglobato in essi.
>
> →

**`CASA.spirito_matrice.11`** · battuta di Spirito dei giardini
> ... Nei laboratori dovrebbe esserci qualcosa che vi possa aiutare. Sapete, ero una dei capi ricerca prima di venire demansionata, siccome mi ero rifiutata di far parte dei progetti che la signora aveva per i nostri vivai. Ricordo di aver sviluppato un potente diserbante insieme ai miei colleghi, per prevenire e controllare eventuali scenari dovuti alla cattiva gestione dell'esperimento.
>
> →

**`CASA.spirito_matrice.scelta1`** · bottone di scelta
> Chiedi di più sull'esperimento
>
> →

**`CASA.spirito_matrice.scelta2`** · bottone di scelta
> Concludi il discorso
>
> →


### La Casa Gigante › `spirito_vivaio_ancora`

**`CASA.spirito_vivaio_ancora.1`** · battuta di Spirito dei giardini
> Forse dovreste provare a perlustrare il vivaio.
>
> →

**`CASA.spirito_vivaio_ancora.scelta1`** · bottone di scelta
> Torna a parlarle
>
> →


### La Casa Gigante › `spirito_esperimento`

**`CASA.spirito_esperimento.1`** · battuta di Spirito dei giardini
> Una volta, in questo posto, coltivavamo piante per sviluppare medicinali e antibiotici per delle grandi case farmaceutiche.
>
> →

**`CASA.spirito_esperimento.2`** · battuta di Spirito dei giardini
> Questo finché la signora, dopo aver ricevuto una grossa somma di denaro, non ha cominciato a considerare l'utilizzo delle nostre piante anche in campo bellico. Veleni. Piante capaci di distruggere interi complessi, di divorare persone.
>
> →

**`CASA.spirito_esperimento.3`** · battuta di Spirito dei giardini
> ... Quello che era un progetto nato per migliorare le condizioni delle persone è diventato qualcosa che creava nuovi problemi. Io e la signora eravamo delle ricercatrici di successo: insieme abbiamo sviluppato decine di medicinali biologici a basso costo, in grado di risolvere la maggior parte dei problemi dei pianeti più poveri. Ma qualcosa è cambiato. Non so spiegare quando né come... ma quel cambiamento ha avuto un impatto anche sulla sua famiglia.
>
> →

**`CASA.spirito_esperimento.scena`** · quando ci torni («Osserva la scena»)
> Il volto della vecchia custode, sulla corteccia dell'albero grande.
>
> →

**`CASA.spirito_esperimento.scelta1`** · bottone di scelta
> Chiedi delle persone nelle foto
>
> →

**`CASA.spirito_esperimento.scelta2`** · bottone di scelta
> Chiedi dei suoi ultimi ricordi
>
> →

**`CASA.spirito_esperimento.scelta3`** · bottone di scelta
> Chiedi dei diari di ricerca
>
> →

**`CASA.spirito_esperimento.scelta4`** · bottone di scelta
> Torna a parlare d'altro
>
> →


### La Casa Gigante › `spirito_foto`

**`CASA.spirito_foto.1`** · battuta di Spirito dei giardini
> La famiglia era composta dal signore, dalla signora e dalla piccola signorina Lylloh. La capofamiglia era la mia compagna di ricerche. Il signore e la signora sono sempre state persone molto sole... La signorina Lylloh ha ereditato questa solitudine.
>
> →

**`CASA.spirito_foto.2`** · battuta di Spirito dei giardini
> A causa della rigida educazione imposta dalla capofamiglia, la signorina Lylloh non ha mai conosciuto l'amicizia vera. È vero che non le mancava nulla, ma solo dal punto di vista materiale. Nel corso degli anni questa sua tristezza la consumò, fino al giorno della tragedia. Così perdemmo l'unica cosa di puro e innocente che restava in quella casa.
>
> →

**`CASA.spirito_foto.scelta1`** · bottone di scelta
> Resta ad ascoltarla
>
> →


### La Casa Gigante › `spirito_ricordi`

**`CASA.spirito_ricordi.1`** · battuta di Spirito dei giardini
> Mentirei se ti dicessi che i miei ricordi sono nitidi: è passato troppo tempo. Ormai, quando provo a ricordare, riesco a mettere insieme solo piccoli ponti che si collegano tra di loro senza portare da nessuna parte. Giusto il necessario per esserti utile... hohoho...
>
> →

**`CASA.spirito_ricordi.scelta1`** · bottone di scelta
> Resta ad ascoltarla
>
> →


### La Casa Gigante › `spirito_diari`

**`CASA.spirito_diari.1`** · battuta di Spirito dei giardini
> ... Hai trovato i miei diari? Hohoho... pensavo fossero stati buttati via. D'altronde non c'era più bisogno di me. Ormai puoi immaginare quanto male abbia causato con le mie ricerche.
>
> →

**`CASA.spirito_diari.2`** · battuta di Yhvina
> Non è colpa sua... lei voleva solo far del bene. Conosco fin troppo bene questa sensazione. Non ci si può far nulla, se non schiacciare con la forza le fonti che ti causano quel male.
>
> →

**`CASA.spirito_diari.3`** · battuta di Spirito dei giardini
> Non importa se all'inizio le intenzioni erano buone. Non passo giorno a pentirmi di non aver mai provato a fermare la vecchia signora... In parte mi sento responsabile. Sento che dentro hai una grande rabbia: ma non fare gli sbagli che ha fatto questa povera vecchia. Ricorda sempre che ci sono molte strade da percorrere.
>
> →

**`CASA.spirito_diari.4`** · battuta di Yhvina
> ...
>
> →

**`CASA.spirito_diari.scelta1`** · bottone di scelta
> Approfondisci la questione
>
> →

**`CASA.spirito_diari.scelta2`** · bottone di scelta
> Vai via
>
> →


### La Casa Gigante › `spirito_storia`

**`CASA.spirito_storia.1`** · battuta di Anonimo
> Posso chiederti... come mai hai deciso di visitare questo posto?
>
> →

**`CASA.spirito_storia.2`** · battuta di Yhvina
> ... Non sono affari tuoi. Diciamo che è una questione personale: non mi interessa in quale posto finirò. Ma sradicherò qualunque follia causi la disfatta di questi mondi. A qualunque costo.
>
> →

**`CASA.spirito_storia.3`** · battuta di Spirito dei giardini
> ... Conosco quello sguardo... hohoho... Permettimi di raccontarti un'ultima storia.
>
> →

**`CASA.spirito_storia.4`** · battuta di Spirito dei giardini
> Sai, non sono sempre stata così aperta al dialogo. Per me esisteva soltanto il mio lavoro, le mie piante, le mie ricerche. Come un albero, radicata nei miei ideali, non mi sono mai accorta che ero consumata dai miei obiettivi. Mio marito morì in un tragico incidente, nel posto dove mia figlia venne assunta per lavorare a dei progetti di particolare importanza per quell'azienda... la Meteo Inc., una delle aziende più discusse tra le galassie per i loro metodi e le loro ricerche senza scrupoli.
>
> →

**`CASA.spirito_storia.5`** · battuta di Spirito dei giardini
> Mia figlia ti somigliava molto. Non aveva mai avuto un padre, e sua madre era totalmente assente: crebbe in un mondo freddo, dove ogni richiesta era un fastidio per gli altri. Ho perso il conto dei momenti importanti della sua vita che mi sono persa. Ricordo ancora le sue ultime parole:
>
> →

**`CASA.spirito_storia.6`** · didascalia dell'illustrazione `art/illustrazioni/casa_figlia_addio.png`
> «Sono venuta a salutarti... ma non perché nutra un qualunque sentimento nei tuoi confronti: per avvisarti che ti supererò, a qualunque costo. Non voglio mai più vederti. Questo è un addio: grazie di niente.»
>
> →

**`CASA.spirito_storia.7`** · battuta di Spirito dei giardini
> Da quel giorno non la vidi più. Pensai che fosse una cosa buona: era decisa, intelligente, determinata. Ma passati vari anni mi resi conto di cosa avevo fatto. Avevo trascorso la mia vita in un laboratorio, perdendo le persone che avevo più care senza rendermene conto, senza dargli importanza. E ora che le mie ricerche erano state gettate alle fiamme e trasformate in armi, cominciavo ad aprire gli occhi sulle cose veramente importanti.
>
> →

**`CASA.spirito_storia.8`** · battuta di Yhvina
> ...
>
> →

**`CASA.spirito_storia.9`** · battuta di Spirito dei giardini
> Ti chiedo scusa se mi sono permessa di raccontarti questa piccola storia, hohoho... Solo che mi ricordi davvero tanto mia figlia, e volevo forse illudermi di poter giustificarmi con te, come se fosse stata lei... hohoho...
>
> →

**`CASA.spirito_storia.10`** · battuta di Yhvina
> Non preoccuparti... va bene così. Ma non fraintendiamoci: io... non sono così buona da meritare la pietà di qualcuno.
>
> →

**`CASA.spirito_storia.11`** · battuta di Spirito dei giardini
> ...
>
> →

**`CASA.spirito_storia.scelta1`** · bottone di scelta
> Concludi in modo positivo
>
> →

**`CASA.spirito_storia.scelta2`** · bottone di scelta
> Lascia perdere
>
> →


### La Casa Gigante › `spirito_storia_buona`

**`CASA.spirito_storia_buona.1`** · battuta di Anonimo
> Penso di poter dire la stessa cosa. Ma nonostante sia vero... solo il fatto di essere consapevoli di quel che si è, o di quel che si è fatto... forse ci dà un'ultima possibilità di aggiustare le cose.
>
> →

**`CASA.spirito_storia_buona.2`** · battuta di Yhvina
> ...
>
> →

**`CASA.spirito_storia_buona.scelta1`** · bottone di scelta
> Torna a parlare d'altro
>
> →


### La Casa Gigante › `spirito_storia_lasciata`

**`CASA.spirito_storia_lasciata.1`** · battuta di Anonimo
> ...
>
> →

**`CASA.spirito_storia_lasciata.scelta1`** · bottone di scelta
> Torna a parlare d'altro
>
> →


### La Casa Gigante › `albero_addio`

**`CASA.albero_addio.1`** · narrazione
> L'albero dove prima era presente il volto della signora ora è avvizzito, e al suo posto è rimasto solo un accenno di quel volto. Sembra... felice?
>
> →

**`CASA.albero_addio.2`** · battuta di Anonimo
> Il diserbante deve aver colpito anche lei...
>
> →

**`CASA.albero_addio.scena`** · quando ci torni («Osserva la scena»)
> L'albero avvizzito. Sulla corteccia, l'accenno di un volto che sorride.
>
> →

**`CASA.albero_addio.scelta1`** · bottone di scelta
> Torna al giardino est
>
> →


### La Casa Gigante › `albero_addio_buono`

**`CASA.albero_addio_buono.1`** · battuta di Yhvina
> ... Signora?
>
> →

**`CASA.albero_addio_buono.2`** · battuta di Spirito dei giardini
> ... Sento che in questi giardini è tornata la pace. Grazie a voi le mie piccole piante possono finalmente riposare.
>
> →

**`CASA.albero_addio_buono.3`** · battuta di Spirito dei giardini
> Sarà l'età, mio caro... ma ho tanto sonno. Forse è arrivato il momento anche per questa vecchia signora di prendersi una piccola pausa, dopo tutti questi anni di lavoro... hohoho... Ma prima, eccoti un piccolo regalo, per ringraziarti della tua gentilezza. Grazie per aver tenuto compagnia a questa povera vecchia.
>
> →

**`CASA.albero_addio_buono.4`** · battuta di Spirito dei giardini
> Guarda che belli, i miei fiori! Era passato così tanto tempo dall'ultima volta che li ho visti felici. Grazie, giovanotti... hohoho...
>
> →

**`CASA.albero_addio_buono.5`** · narrazione
> L'albero dove prima era presente il volto della signora ora è avvizzito, e al suo posto è rimasto solo un accenno di quel volto. Sembra... felice?
>
> →

**`CASA.albero_addio_buono.6`** · battuta di Anonimo
> Il diserbante deve aver colpito anche lei...
>
> →

**`CASA.albero_addio_buono.7`** · battuta di Yhvina
> ...
>
> →

**`CASA.albero_addio_buono.8`** · battuta di Anonimo
> ... ?
>
> →

**`CASA.albero_addio_buono.9`** · battuta di Yhvina
> Perché mi fissi, stupido!? Tutto questo polline mi ha stancato...
>
> →

**`CASA.albero_addio_buono.10`** · battuta di Yhvina
> Diamoci una mossa prima che mi arrabbi sul serio. Ne ho abbastanza di questo posto.
>
> →

**`CASA.albero_addio_buono.11`** · battuta di Yhvina
> ...
>
> →

**`CASA.albero_addio_buono.scena`** · quando ci torni («Osserva la scena»)
> L'albero avvizzito. Sulla corteccia, l'accenno di un volto che sorride.
>
> →

**`CASA.albero_addio_buono.scelta1`** · bottone di scelta (fa raccogliere Fiore di luna, Fiore di luna, Fiore di luna)
> Raccogli il regalo della custode
>
> →

**`CASA.albero_addio_buono.scelta2`** · bottone di scelta
> Torna al giardino est
>
> →


### La Casa Gigante › `giardino_ovest`

**`CASA.giardino_ovest.1`** · narrazione
> Il sentiero a ovest esce dal folto e si allarga su una radura lastricata. In fondo, basso e lungo, un edificio con le finestre a nastro: non è parte della casa, e non prova nemmeno a sembrarlo.
>
> →

**`CASA.giardino_ovest.scena`** · quando ci torni («Osserva la scena»)
> La radura lastricata a ovest, e in fondo il grande laboratorio.
>
> →

**`CASA.giardino_ovest.scelta1`** · bottone di scelta
> Entra nel grande laboratorio
>
> →

**`CASA.giardino_ovest.scelta2`** · bottone di scelta
> Torna al giardino
>
> →


### La Casa Gigante › `laboratorio`

**`CASA.laboratorio.1`** · narrazione
> Banconi in fila, vetreria ancora al suo posto, cartelle appese a ogni postazione. Qui dentro non è passato nessuno a portare via niente: semplicemente, un giorno, non è più tornato nessuno.
>
> →

**`CASA.laboratorio.2`** · battuta di Anonimo
> Un centro di ricerca vero e proprio... e in ottimo stato. Chi lavorava qui non se n'è andato di fretta: se n'è andato e basta.
>
> →

**`CASA.laboratorio.scena`** · quando ci torni («Osserva la scena»)
> Il grande laboratorio: banconi in fila, e le cartelle ancora appese.
>
> →

**`CASA.laboratorio.scelta1`** · bottone di scelta (fa raccogliere Diari di ricerca)
> Perlustra i banconi
>
> →

**`CASA.laboratorio.scelta2`** · bottone di scelta
> Fruga in un armadietto del personale
>
> →

**`CASA.laboratorio.scelta3`** · bottone di scelta
> Entra nella sala delle matrici
>
> →

**`CASA.laboratorio.scelta4`** · bottone di scelta
> Pianta un proiettore nel laboratorio
>
> →

**`CASA.laboratorio.scelta5`** · bottone di scelta
> Torna al giardino ovest
>
> →


### La Casa Gigante › `sala_matrici`

**`CASA.sala_matrici.1`** · narrazione
> Una stanza piccola e schermata, piena di macchine da incisione. Su un ripiano, una fila di piastrine identiche: le chiavi di accesso della magione, tutte vergini, tutte mai assegnate a nessuno.
>
> →

**`CASA.sala_matrici.scena`** · quando ci torni («Osserva la scena»)
> La sala delle matrici: le macchine da incisione e le piastrine mai assegnate.
>
> →

**`CASA.sala_matrici.scelta1`** · bottone di scelta (fa raccogliere Matrice di accesso)
> Prendi una matrice dal ripiano
>
> →

**`CASA.sala_matrici.scelta2`** · bottone di scelta
> Prosegui oltre la sala
>
> →

**`CASA.sala_matrici.scelta3`** · bottone di scelta
> Torna nel laboratorio
>
> →


### La Casa Gigante › `deposito_chimico`

**`CASA.deposito_chimico.1`** · narrazione
> Un deposito chimico dietro la sala delle matrici. Taniche allineate contro la parete, tutte con la stessa etichetta scritta a mano e la stessa dicitura sotto: «uso interno — contenimento vivai».
>
> →

**`CASA.deposito_chimico.scena`** · quando ci torni («Osserva la scena»)
> Il deposito chimico. Le taniche contro la parete, allineate.
>
> →

**`CASA.deposito_chimico.scelta1`** · bottone di scelta (fa raccogliere Diserbante dei vivai)
> Prendi una tanica di diserbante
>
> →

**`CASA.deposito_chimico.scelta2`** · bottone di scelta
> Torna alla sala delle matrici
>
> →


### La Casa Gigante › `giardino_nord`

**`CASA.giardino_nord.1`** · narrazione
> Il sentiero a nord finisce contro una parete viva: rovi fitti come una muraglia, che salgono per tre piani e coprono per intero la struttura di vetro dietro di essi.
>
> →

**`CASA.giardino_nord.scena`** · quando ci torni («Osserva la scena»)
> La muraglia di rovi a nord, e il vetro del vivaio appena visibile dietro.
>
> →

**`CASA.giardino_nord.scelta1`** · bottone di scelta
> Avvicinati ai rovi
>
> →

**`CASA.giardino_nord.scelta2`** · bottone di scelta
> Torna al giardino
>
> →


### La Casa Gigante › `vivaio_ingresso`

**`CASA.vivaio_ingresso.1`** · battuta di Anonimo
> Cosa sono queste piante? Sembrano crescere continuamente...
>
> →

**`CASA.vivaio_ingresso.scena`** · quando ci torni («Osserva la scena»)
> Le piante impediscono il passaggio: colpirle è inutile.
>
> →

**`CASA.vivaio_ingresso.scelta1`** · bottone di scelta
> Prova a diradare le piante con un colpo
>
> →

**`CASA.vivaio_ingresso.scelta2`** · bottone di scelta
> Versa il diserbante sui rovi
>
> →

**`CASA.vivaio_ingresso.scelta3`** · bottone di scelta
> Torna al giardino nord
>
> →


### La Casa Gigante › `vivaio_rovi`

**`CASA.vivaio_rovi.1`** · battuta di Anonimo
> !!!
>
> →

**`CASA.vivaio_rovi.2`** · battuta di Anonimo
> Tutto inutile: sembra che reagiscano, e se distrutte riescono a rigenerarsi immediatamente.
>
> →

**`CASA.vivaio_rovi.scelta1`** · bottone di scelta
> Torna a guardare i rovi
>
> →


### La Casa Gigante › `vivaio_varco`

**`CASA.vivaio_varco.1`** · narrazione
> Il diserbante affonda nel terreno ai piedi della muraglia. Per un momento non succede niente. Poi i rovi si fermano: non appassiscono, si fermano soltanto.
>
> →

**`CASA.vivaio_varco.2`** · battuta di Anonimo
> Le piante hanno smesso di crescere momentaneamente. È il mio momento per colpirle.
>
> →

**`CASA.vivaio_varco.scelta1`** · bottone di scelta
> Colpisci le piante
>
> →


### La Casa Gigante › `vivaio_apertura`

**`CASA.vivaio_apertura.1`** · narrazione
> Le piante si seccano e lasciano una piccola apertura, che ti permette di entrare nel vivaio.
>
> →

**`CASA.vivaio_apertura.scelta1`** · bottone di scelta
> Entra nel vivaio
>
> →

**`CASA.vivaio_apertura.scelta2`** · bottone di scelta
> Torna al giardino nord
>
> →


### La Casa Gigante › `vivaio_1`

**`CASA.vivaio_1.1`** · narrazione
> Il primo piano del vivaio: vasche lunghe quanto la sala, e sopra ognuna un cartellino di specie che non hai mai sentito nominare. Quello che ci cresce dentro adesso non è quello che c'era scritto.
>
> →

**`CASA.vivaio_1.scena`** · quando ci torni («Osserva la scena»)
> Il primo piano del vivaio, le vasche lunghe e i cartellini illeggibili.
>
> →

**`CASA.vivaio_1.scelta1`** · bottone di scelta
> Perlustra il piano
>
> →

**`CASA.vivaio_1.scelta2`** · bottone di scelta
> Prosegui al piano inferiore
>
> →

**`CASA.vivaio_1.scelta3`** · bottone di scelta
> Esci dal vivaio
>
> →


### La Casa Gigante › `vivaio_1_perlustra`

**`CASA.vivaio_1_perlustra.1`** · battuta di Anonimo
> Non sembra esserci nulla di interessante, qui...
>
> →

**`CASA.vivaio_1_perlustra.scelta1`** · bottone di scelta
> Torna a guardarti intorno
>
> →


### La Casa Gigante › `vivaio_2`

**`CASA.vivaio_2.1`** · narrazione
> Il secondo piano è più buio: le vetrate sono coperte dai rovi anche da dentro.
>
> →

**`CASA.vivaio_2.scena`** · quando ci torni («Osserva la scena»)
> Il secondo piano del vivaio, con le vetrate coperte dai rovi.
>
> →

**`CASA.vivaio_2.scelta1`** · bottone di scelta
> Perlustra il piano
>
> →

**`CASA.vivaio_2.scelta2`** · bottone di scelta
> Risali al primo piano
>
> →


### La Casa Gigante › `vivaio_2_perlustra`

**`CASA.vivaio_2_perlustra.1`** · narrazione
> C'è un buco, dove prima deve esserci stato un ascensore. Vuoi proseguire?
>
> →

**`CASA.vivaio_2_perlustra.scelta1`** · bottone di scelta
> Vai giù per il buco
>
> →

**`CASA.vivaio_2_perlustra.scelta2`** · bottone di scelta
> Torna a guardarti intorno
>
> →


### La Casa Gigante › `vivaio_3`

**`CASA.vivaio_3.1`** · battuta di Anonimo
> Più giù vedi l'ascensore a pezzi: questo deve essere il piano più basso... Cosa ha cercato di uscire da qui?
>
> →

**`CASA.vivaio_3.2`** · battuta di Yhvina
> Sta' attento... yaaawn. Percepisco che qualcosa di forte si trova più avanti.
>
> →

**`CASA.vivaio_3.3`** · narrazione
> Ti ritrovi in una stanza piena di piante come quelle che avvolgono l'intero vivaio.
>
> →

**`CASA.vivaio_3.scena`** · quando ci torni («Osserva la scena»)
> Il fondo del vivaio: l'ascensore a pezzi, e la stanza invasa dalle piante.
>
> →

**`CASA.vivaio_3.scelta1`** · bottone di scelta
> Perlustra la stanza
>
> →

**`CASA.vivaio_3.scelta2`** · bottone di scelta
> Risali al secondo piano
>
> →


### La Casa Gigante › `vivaio_fondo`

**`CASA.vivaio_fondo.1`** · battuta di Anonimo
> Questa stanza sembra ricoperta da queste fastidiose piante... Forse sarebbe il caso di estinguerle una volta per tutte.
>
> →

**`CASA.vivaio_fondo.scelta1`** · bottone di scelta
> Usa il diserbante sul terreno
>
> →

**`CASA.vivaio_fondo.scelta2`** · bottone di scelta
> Risali
>
> →


### La Casa Gigante › `volto_appare`

**`CASA.volto_appare.1`** · battuta di Yhvina
> ... Sembra che qualunque cosa controlli queste piante non abbia gradito le tue doti da giardiniere.
>
> →

**`CASA.volto_appare.2`** · battuta di Anonimo
> ...
>
> →

**`CASA.volto_appare.3`** · narrazione
> Qualcosa prende forma sulla parete...
>
> →

**`CASA.volto_appare.4`** · battuta di Volto sulla parete
> Chi siete... Siete venuti a rubare i risultati delle mie ricerche, vero? Schifosi...
>
> →

**`CASA.volto_appare.5`** · battuta di Anonimo
> ... Fatti avanti e fai silenzio.
>
> →

**`CASA.volto_appare.6`** · battuta di Volto sulla parete
> Come osi, piccolo stupido impudente... Tu non sai chi hai davanti!
>
> →


### La Casa Gigante › `dopo_volto`

**`CASA.dopo_volto.1`** · battuta di Yhvina
> ... Che faticaccia. Le erbacce non muoiono mai.
>
> →

**`CASA.dopo_volto.scena`** · quando ci torni («Osserva la scena»)
> La stanza in fondo al vivaio. Sulla parete non è rimasto niente.
>
> →

**`CASA.dopo_volto.scelta1`** · bottone di scelta (fa raccogliere ID della capofamiglia, Fiala HP, Fiala HP)
> Perlustra la stanza
>
> →

**`CASA.dopo_volto.scelta2`** · bottone di scelta
> Risali
>
> →


### La Casa Gigante › `id_card_trovata`

**`CASA.id_card_trovata.1`** · narrazione
> Nel cassetto di una delle scrivanie trovi l'ID della capofamiglia, coperto di piccole piante.
>
> →

**`CASA.id_card_trovata.scelta1`** · bottone di scelta
> Risali
>
> →


### La Casa Gigante › `vivaio_fondo_dopo`

**`CASA.vivaio_fondo_dopo.1`** · narrazione
> La stanza in fondo al vivaio. Il terreno è secco, e sulla parete non prende più forma niente.
>
> →

**`CASA.vivaio_fondo_dopo.scena`** · quando ci torni («Osserva la scena»)
> La stanza in fondo al vivaio. Sulla parete non è rimasto niente.
>
> →

**`CASA.vivaio_fondo_dopo.scelta1`** · bottone di scelta (fa raccogliere ID della capofamiglia, Fiala HP, Fiala HP)
> Perlustra la stanza
>
> →

**`CASA.vivaio_fondo_dopo.scelta2`** · bottone di scelta
> Risali
>
> →


### La Casa Gigante › `botola_chiusa`

**`CASA.botola_chiusa.1`** · narrazione
> La botola non ha maniglia: solo una fessura sottile sul bordo, e sopra la fessura una spia che continua a lampeggiare piano, da anni.
>
> →

**`CASA.botola_chiusa.2`** · battuta di Anonimo
> Una chiave di accesso. Certo che ci voleva una chiave di accesso...
>
> →

**`CASA.botola_chiusa.scelta1`** · bottone di scelta
> Torna alla stanza dei giochi
>
> →


### La Casa Gigante › `lettore_vuoto`

**`CASA.lettore_vuoto.1`** · narrazione
> Infili la matrice nella fessura. La spia smette di lampeggiare e resta accesa, fissa, per qualche secondo.
>
> →

**`CASA.lettore_vuoto.2`** · narrazione
> «UTENTE NON IDENTIFICATO. ID VUOTO.»
>
> →

**`CASA.lettore_vuoto.3`** · battuta di Anonimo
> Manca il chip di identificazione. La piastrina da sola non dice a nessuno chi sono.
>
> →

**`CASA.lettore_vuoto.scelta1`** · bottone di scelta
> Torna alla stanza dei giochi
>
> →


### La Casa Gigante › `spirito_chiacchiere`

**`CASA.spirito_chiacchiere.1`** · battuta di Spirito dei giardini
> Hohoho... Non serve sempre chiedere qualcosa, sa? Una vecchia si accontenta anche solo di sentire dei passi che si fermano.
>
> →

**`CASA.spirito_chiacchiere.scelta1`** · bottone di scelta
> Resta ancora un po'
>
> →


## Kizako Industries — Ala Dimenticata

<sub>`data/vuoti/kizako_ala.json`</sub>


### Kizako Industries — Ala Dimenticata › `portone`

**`KIZ.portone.1`** · narrazione
> Lo squarcio si apre su un'altra ala dello stesso complesso: più grande, più antica, sigillata da un portone che qualcuno ha divelto dall'interno. Sopra l'architrave, in lettere di metallo mezze cadute: KIZAKO INDUSTRIES. Sirene lontane suonano a intervalli, senza motivo. Le luci di cantiere si accendono e si spengono da sole.
>
> →

**`KIZ.portone.scelta1`** · bottone di scelta
> Entra nel reparto montaggio
>
> →

**`KIZ.portone.scelta2`** · bottone di scelta (esce dallo squarcio)
> Torna nel Vuoto
>
> →


### Kizako Industries — Ala Dimenticata › `reparto`

**`KIZ.reparto.1`** · narrazione
> Il reparto montaggio si perde nel buio. Nastri fermi, bracci meccanici piegati come schiene stanche. Ogni tanto qualcosa si muove tra i rottami: non macchine, non del tutto. Fa' Studia in combattimento, e sentirai chi erano.
>
> →

**`KIZ.reparto.scelta1`** · bottone di scelta
> Raggiungi la sala mensa
>
> →

**`KIZ.reparto.scelta2`** · bottone di scelta
> Sali alla passerella dei capisquadra
>
> →

**`KIZ.reparto.scelta3`** · bottone di scelta
> Torna al portone
>
> →


### Kizako Industries — Ala Dimenticata › `mensa`

**`KIZ.mensa.1`** · narrazione
> Una mensa aziendale immensa, tavoli in fila fino a perdersi. Su un muro, un orologio marcatempo fermo alle 19:47. Sotto, migliaia di cartellini timbrati e mai ritirati. Su una parete, un manifesto: 'IL RIPOSO È UN LUSSO CHE LA STORIA NON SI CONCEDE. — K.'
>
> →

**`KIZ.mensa.scelta1`** · bottone di scelta
> Fruga tra i cartellini
>
> →

**`KIZ.mensa.scelta2`** · bottone di scelta (fa raccogliere Misterioso componente elettronico)
> Recupera il tesserino di un caposquadra
>
> →

**`KIZ.mensa.scelta3`** · bottone di scelta
> Scendi negli archivi
>
> →

**`KIZ.mensa.scelta4`** · bottone di scelta
> Torna al reparto
>
> →


### Kizako Industries — Ala Dimenticata › `passerella`

**`KIZ.passerella.1`** · narrazione
> Dalla passerella si domina tutto il reparto. Da qui i capisquadra guardavano gli operai come si guarda un formicaio. Una di quelle sagome di ferro è ancora qui, incastrata nella ringhiera, e urla con la voce di troppa gente.
>
> →

**`KIZ.passerella.scelta1`** · bottone di scelta
> Forza la cassaforte del capannone
>
> →

**`KIZ.passerella.scelta2`** · bottone di scelta (fa raccogliere Benzina)
> Recupera la tanica lasciata sul ballatoio
>
> →

**`KIZ.passerella.scelta3`** · bottone di scelta
> Scendi negli archivi per la scala di servizio
>
> →

**`KIZ.passerella.scelta4`** · bottone di scelta
> Torna al reparto
>
> →


### Kizako Industries — Ala Dimenticata › `archivi`

**`KIZ.archivi.1`** · narrazione
> Gli archivi della Kizako Industries. Faldoni di brevetti d'arma, bilanci gonfi, e una parete intera di fototessere di dipendenti, ognuna con una data di assunzione e nessuna data di uscita. In fondo, uno studio privato con una targa: DIR. KIZAKO.
>
> →

**`KIZ.archivi.scelta1`** · bottone di scelta
> Leggi un fascicolo a caso
>
> →

**`KIZ.archivi.scelta2`** · bottone di scelta
> Entra nello studio di Kizako
>
> →

**`KIZ.archivi.scelta3`** · bottone di scelta
> Torna alla mensa
>
> →


### Kizako Industries — Ala Dimenticata › `fascicolo`

**`KIZ.fascicolo.1`** · narrazione
> "Progetto di ottimizzazione del rendimento umano. Turni prolungati oltre soglia di crollo. Perdite accettabili. Nota a margine, altra grafia: 'Signore, alcuni non tornano a casa da settimane. Rispondono solo alle sirene.' Risposta, inchiostro rosso: 'Ottimo. Meno distrazioni.'"
>
> →

**`KIZ.fascicolo.scelta1`** · bottone di scelta
> Richiudi il fascicolo
>
> →


### Kizako Industries — Ala Dimenticata › `studio_kizako`

**`KIZ.studio_kizako.1`** · narrazione
> Lo studio è vuoto, pulito, gelido: l'unica stanza intatta di tutto il complesso. Nessun ritratto del padrone, da nessuna parte. Solo una lavagna piena di formule e, in un angolo, la sagoma di dove doveva esserci qualcosa di prezioso, ora sparito. Kizako non c'è. Kizako non c'è mai, nelle sue fabbriche. Ma le sue fabbriche sono ovunque.
>
> →

**`KIZ.studio_kizako.scelta1`** · bottone di scelta (fa raccogliere La volontà di un fabbro)
> Preleva la volontà lasciata sull'incudine dell'officina
>
> →

**`KIZ.studio_kizako.scelta2`** · bottone di scelta
> Esci dagli archivi
>
> →


### Kizako Industries — Ala Dimenticata › `espulso`

**`KIZ.espulso.1`** · narrazione
> Le sirene esplodono tutte insieme e le luci di cantiere ti accecano. Quando torni a vedere, sei fuori dallo squarcio. La fabbrica continua a produrre niente, per nessuno.
>
> →

**`KIZ.espulso.scelta1`** · bottone di scelta (esce dallo squarcio)
> Riprendi fiato nel Vuoto
>
> →


## La Fontana

<sub>`data/vuoti/fontana.json`</sub>


### La Fontana › `fontana`

**`FON.fontana.1`** · narrazione
> Nessun deserto, nessuna fabbrica: qui c'è solo una luce chiara e sospesa, e al centro una fontana di pietra bianca, asciutta da sempre. Sul bordo, quattro incavi vuoti, ognuno della forma di qualcosa che non hai ancora. Chi la riempie, dice l'incisione, riporta indietro qualcuno.
>
> →

**`FON.fontana.scelta1`** · bottone di scelta
> Deponi ciò che hai raccolto e completa la Fontana
>
> →

**`FON.fontana.scelta2`** · bottone di scelta
> Osserva gli incavi vuoti
>
> →

**`FON.fontana.scelta3`** · bottone di scelta (esce dallo squarcio)
> Torna nel Vuoto
>
> →


### La Fontana › `incavi`

**`FON.incavi.1`** · narrazione
> Quattro incavi, quattro forme: un'anima inquieta, dei ricordi felici, la volontà di un fabbro, un cuore di disallineamento. Sono cose che non si trovano in un posto solo: si raccolgono lungo tutta la strada. Finché mancano, la fontana resta asciutta.
>
> →

**`FON.incavi.scelta1`** · bottone di scelta
> Torna alla fontana
>
> →


### La Fontana › `fontana_completa`

**`FON.fontana_completa.1`** · narrazione
> I quattro pezzi trovano il loro posto. L'acqua sgorga dal nulla, limpida, e sale oltre il bordo senza traboccare. Dentro il riflesso prende forma qualcuno che il disallineamento aveva rubato al mondo. Si volta verso di te. [Un nuovo personaggio si unirà: lo gestiremo più avanti.]
>
> →

**`FON.fontana_completa.scelta1`** · bottone di scelta (esce dallo squarcio)
> Torna nel Vuoto
>
> →


## Qualcosa preme

<sub>`data/vuoti/qualcosa_preme.json`</sub>


### Qualcosa preme › `soglia`

**`PRE.soglia.1`** · narrazione
> Lo squarcio non si apre su un luogo. Si apre su una pressione — enorme, senza forma, che ti schiaccia il petto prima ancora che tu abbia fatto un passo. Non c'è niente da vedere. C'è solo qualcosa, dall'altra parte, che si accorge di te. Il Vuoto stesso sembra volerti indietro.
>
> →

**`PRE.soglia.scelta1`** · bottone di scelta (esce dallo squarcio)
> ...
>
> →


## La campagna di Jerah

<sub>`data/events.json`</sub>


### La campagna di Jerah › `inizio`

**`JER.inizio.1`** · narrazione
> L'incarico dell'Organizzazione è chiaro: trovare la fonte ed estinguerla, prima che questo mondo venga divorato. Davanti a te un deserto che brucia di una luce rossa che non viene dal sole. All'orizzonte, una plaza de toros in fiamme, e da lì un battito di tacchi e chitarre che sa di sfida. Due vie tagliano la sabbia rovente.
>
> →

**`JER.inizio.scelta1`** · bottone di scelta
> Taglia per le dune
>
> →

**`JER.inizio.scelta2`** · bottone di scelta
> Segui l'arroyo secco
>
> →


### La campagna di Jerah › `bosco`

**`JER.bosco.1`** · narrazione
> Tra le dune, una vecchia biglietteria da corrida rovesciata, mezza sepolta. Dentro, monete sparse e una razione ancora sigillata.
>
> →

**`JER.bosco.scelta1`** · bottone di scelta (fa raccogliere Razione da viaggio)
> Fruga tra i resti
>
> →

**`JER.bosco.scelta2`** · bottone di scelta
> Non toccare niente
>
> →


### La campagna di Jerah › `fiume`

**`JER.fiume.1`** · narrazione
> L'arroyo è secco da secoli. Nella sabbia, mezza sepolta, una lanterna spenta che pulsa come un cuore.
>
> →

**`JER.fiume.scelta1`** · bottone di scelta (fa raccogliere Lanterna che pulsa)
> Raccogli la lanterna
>
> →

**`JER.fiume.scelta2`** · bottone di scelta
> Lasciala dov'è
>
> →


### La campagna di Jerah › `riva`

**`JER.riva.1`** · narrazione
> Più avanti, un carro da mercante ribaltato, il carico sparso nella sabbia. Qualcuno è fuggito in fretta, o non è fuggito affatto.
>
> →

**`JER.riva.scelta1`** · bottone di scelta (fa raccogliere Tonico calmante)
> Ispeziona il carico
>
> →

**`JER.riva.scelta2`** · bottone di scelta
> Prosegui lungo l'arroyo
>
> →


### La campagna di Jerah › `sentiero_lanterne`

**`JER.sentiero_lanterne.1`** · narrazione
> Una fila di torce di ferro nero si accende al tuo passaggio, una alla volta, come se qualcuno contasse i tuoi passi verso l'arena.
>
> →

**`JER.sentiero_lanterne.scelta1`** · bottone di scelta
> Seguile: che contino pure
>
> →

**`JER.sentiero_lanterne.scelta2`** · bottone di scelta
> Spegnile a una a una, e respira
>
> →


### La campagna di Jerah › `radura`

**`JER.radura.1`** · narrazione
> Il piazzale davanti alla plaza. Cactus alti come uomini, sombreros bruciati appesi ai pali. Sulla sabbia, immobile e spavaldo, un Fomentado in maschera di toro ti aspetta a braccia aperte.
>
> →

**`JER.radura.scelta1`** · bottone di scelta (porta a un combattimento)
> Affrontala
>
> →

**`JER.radura.scelta2`** · bottone di scelta
> Aggirala nell'ombra, seguendo l'istinto
>
> →


### La campagna di Jerah › `campo_giostre`

**`JER.campo_giostre.1`** · narrazione
> Il patio delle cuadrillas, sotto le gradinate. Il toril con le sbarre divelte, una sala di specchi ancora accesa, e in fondo un carro con una lampada alla finestra.
>
> →

**`JER.campo_giostre.scelta1`** · bottone di scelta
> Scendi nel toril
>
> →

**`JER.campo_giostre.scelta2`** · bottone di scelta
> Entra nella sala degli specchi
>
> →

**`JER.campo_giostre.scelta3`** · bottone di scelta
> Bussa al carro illuminato
>
> →


### La campagna di Jerah › `tunnel`

**`JER.tunnel.1`** · narrazione
> Nel toril qualcuno ha smontato le sbarre pezzo per pezzo, e ha lasciato la cassa degli attrezzi. In un angolo, un petardo del vecchio spettacolo pirotecnico.
>
> →

**`JER.tunnel.scelta1`** · bottone di scelta (fa raccogliere Petardo)
> Prendi quello che serve
>
> →

**`JER.tunnel.scelta2`** · bottone di scelta
> Attraversa e basta
>
> →


### La campagna di Jerah › `specchi`

**`JER.specchi.1`** · narrazione
> Gli specchi non riflettono te: riflettono i mondi che non ci sono più. In uno di essi, una scheggia luccica a portata di mano. Guardare fa male.
>
> →

**`JER.specchi.scelta1`** · bottone di scelta (fa raccogliere Scheggia di specchio)
> Reggi lo sguardo e afferra la scheggia
>
> →

**`JER.specchi.scelta2`** · bottone di scelta
> Distogli lo sguardo e attraversa in fretta
>
> →


### La campagna di Jerah › `carovana`

**`JER.carovana.1`** · narrazione
> In una terra molto, ma molto lontana, dove la luce del sole risplende ogni giorno...<br>Dove maghi, attori, acrobati e artisti di tutti i tipi si esibiscono in cerca di fama e di un'opportunità di rimanere nella storia...<br>Si annida una forza scottata dalla sua stessa passione.<br>Chi è stato consumato dal suo stesso talento si esibisce senza riposo, trascinato non da un obbligo, ma dalle proprie stesse emozioni e da un vento che soffia sempre più forte...<br>Benvenuti nelle terre consumate dalle fiamme della passione... Benvenuti ai deserti di Jondoh, il pianeta dello spettacolo.
>
> →

**`JER.carovana.2`** · battuta di Il Vecchio Proprietario del teatro
> Ciao straniero, è raro trovare qualcuno ancora sano in questi luoghi. Raccontami: cosa ti porta in questo mondo ormai divorato dalle fiamme?
>
> →

**`JER.carovana.3`** · battuta di Anonimo
> Sono qui per conto dell'Organizzazione, sembrerebbe che questo mondo sia ormai perduto. Dimmi, vecchio: cosa dannazione è successo in queste terre?
>
> →

**`JER.carovana.4`** · battuta di Il Vecchio Proprietario del teatro
> Ho ho ho, che giovane focoso che abbiamo qui! Vale, ti racconterò quel che so... Vuoi un sorso?
>
> →

**`JER.carovana.scelta1`** · bottone di scelta
> Accetta la bevanda
>
> →

**`JER.carovana.scelta2`** · bottone di scelta
> Rifiuta, preferisci ascoltare
>
> →


### La campagna di Jerah › `carovana_si`

**`JER.carovana_si.1`** · battuta di Anonimo
> Grazie mille, ne avevo proprio bisogno.
>
> →

**`JER.carovana_si.scelta1`** · bottone di scelta
> Ascolta il suo racconto
>
> →


### La campagna di Jerah › `carovana_no`

**`JER.carovana_no.1`** · battuta di Anonimo
> No, grazie: preferisco ascoltare la tua storia.
>
> →

**`JER.carovana_no.scelta1`** · bottone di scelta
> Ascolta il suo racconto
>
> →


### La campagna di Jerah › `carovana_racconto`

**`JER.carovana_racconto.1`** · narrazione
> [Qui andranno le cinque tavole disegnate da Bru sulla storia di Jerah — arte non ancora pronta.]
>
> →

**`JER.carovana_racconto.2`** · battuta di Il Vecchio Proprietario del teatro
> E questo è quel che posso dirti dal punto di vista di un vecchio che non si è mai pentito delle sue azioni...
>
> →

**`JER.carovana_racconto.3`** · battuta di Il Vecchio Proprietario del teatro
> Senti, so perché sei qui: permettimi di accompagnarti da lui, ti prego... Voglio solo parlarci un'ultima volta. Non m'importa quale sarà il mio destino, non sarò un peso...
>
> →

**`JER.carovana_racconto.scelta1`** · bottone di scelta
> Portalo con te fino al ruedo
>
> →

**`JER.carovana_racconto.scelta2`** · bottone di scelta
> È troppo pericoloso: lascialo alla sua veglia
>
> →


### La campagna di Jerah › `giostra_cavalli`

**`JER.giostra_cavalli.1`** · narrazione
> Una giostra di cavalli da picador gira da sola, a luci spente. I cavalli di legno hanno tutti la testa voltata verso di te.
>
> →

**`JER.giostra_cavalli.scelta1`** · bottone di scelta
> Ferma il meccanismo e recupera i Tazo incastrati
>
> →

**`JER.giostra_cavalli.scelta2`** · bottone di scelta
> Passa oltre, senza guardarli negli occhi
>
> →


### La campagna di Jerah › `baraccone_premi`

**`JER.baraccone_premi.1`** · narrazione
> Un banco di gioco all'ombra delle gradinate: tre bersagli di latta, una pistola a spuntoni incatenata al banco, e premi che nessuno ha mai vinto.
>
> →

**`JER.baraccone_premi.scelta1`** · bottone di scelta
> Gioca una partita (10 Tazo)
>
> →

**`JER.baraccone_premi.scelta2`** · bottone di scelta
> I giochi truccati non ti fregano
>
> →


### La campagna di Jerah › `premio`

**`JER.premio.1`** · narrazione
> Tre colpi, tre bersagli. Nel silenzio, il banco ti porge un toro di pezza con un occhio solo. Sembra sinceramente stupito che qualcuno abbia vinto.
>
> →

**`JER.premio.scelta1`** · bottone di scelta (fa raccogliere Premio di pezza)
> Prendi il premio e va' verso il ruedo
>
> →


### La campagna di Jerah › `proscenio`

**`JER.proscenio.1`** · narrazione
> Sotto l'arco d'ingresso al ruedo c'è uno spiazzo riparato dal vento di sabbia. La fonte è vicina: si sente il calore. C'è tempo per un ultimo respiro.
>
> →

**`JER.proscenio.scelta1`** · bottone di scelta
> Accendi un falò
>
> →

**`JER.proscenio.scelta2`** · bottone di scelta
> Avanti, senza fermarsi
>
> →


### La campagna di Jerah › `falo`

**`JER.falo.1`** · narrazione
> Il fuoco prende in fretta, piccolo e amico in mezzo a tutto quel fuoco nemico. Qui il fragore dell'arena sembra più lontano. C'è tempo per respirare.
>
> →

**`JER.falo.scelta1`** · bottone di scelta
> Mangia qualcosa e lascia che il fuoco parli
>
> →

**`JER.falo.scelta2`** · bottone di scelta
> Meglio non perdere tempo
>
> →


### La campagna di Jerah › `falo_notte`

**`JER.falo_notte.1`** · narrazione
> Le braci calano. Qualcuno dovrebbe dire qualcosa, ma il silenzio va bene lo stesso.
>
> →

**`JER.falo_notte.scelta1`** · bottone di scelta (fa raccogliere Bottone dorato)
> Il Vecchio Proprietario del teatro apre la mano: un bottone dorato, del primo abito di luci di Jerah
>
> →

**`JER.falo_notte.scelta2`** · bottone di scelta
> Verso il ruedo
>
> →


### La campagna di Jerah › `palco`

**`JER.palco.1`** · narrazione
> Una strana musica latina comincia a inondare la sala, dalle fiamme e dal cumulo di rose si innalza una figura di rara bellezza, che ti squadra con un'espressione malvagia...
>
> →

**`JER.palco.2`** · battuta di El Muy Bonito
> Vamos! Cosa ci fanno degli individui senza talento come voi qui? Perché non lasciate mai noi artisti in pace? Stavo cercando l'ispirazione! E ora tutto è perduto! Siate dannati...
>
> →

**`JER.palco.3`** · battuta di Anonimo
> Fatti da parte.
>
> →

**`JER.palco.4`** · battuta di El Muy Bonito
> Cosa?! Como te atreves... Es la ora...
>
> →

**`JER.palco.5`** · battuta di El Muy Bonito
> DE MORIR!
>
> →

**`JER.palco.scelta1`** · bottone di scelta (porta a un combattimento)
> Passa da lui
>
> →

**`JER.palco.scelta2`** · bottone di scelta
> Scardina la botola e passa sotto il tablao
>
> →


### La campagna di Jerah › `backstage`

**`JER.backstage.1`** · narrazione
> Il callejón dietro la barriera è un intrico di corde e drappi bruciacchiati. In alto, tra le travi di ferro nero, luccica qualcosa che nessuno dovrebbe aver lasciato lì.
>
> →

**`JER.backstage.scelta1`** · bottone di scelta
> Vola fin lassù, tra le travi
>
> →

**`JER.backstage.scelta2`** · bottone di scelta
> Arrampicati a mani nude, presa dopo presa
>
> →

**`JER.backstage.scelta3`** · bottone di scelta
> Scosta l'ultimo drappo
>
> →


### La campagna di Jerah › `segreto`

**`JER.segreto.1`** · narrazione
> Tra le travi trovi la medaglia della vecchia plaza, incisa con un nome che non riesci a leggere. Nessuno la vedeva da anni.
>
> →

**`JER.segreto.scelta1`** · bottone di scelta (fa raccogliere Medaglia della vecchia plaza)
> Prendila e scendi nel ruedo
>
> →


### La campagna di Jerah › `boss`

**`JER.boss.1`** · narrazione
> Cosa spinge l'uomo a dare di più? Perché cerchiamo sempre l'approvazione di chi ci circonda? Forse tutta la vita è uno spettacolo... ma cosa succede se il protagonista viene privato del suo lieto fine? Le risate dei bambini si trasformano in delusione, gli sguardi vengono rivolti altrove... E tutto si perde sotto il sipario... Ma a volte... C'è tempo per un ultimo spettacolo, uno spettacolo... mai visto prima.
>
> →

**`JER.boss.2`** · battuta di L'ultimo spettacolo di Jerah
> Sento... che non sei come gli altri... sei venuto... ad ammirare la mia Jerah?!
>
> →

**`JER.boss.3`** · battuta di L'ultimo spettacolo di Jerah
> Benvenuto, {nome}. Ammira Jerah! AMAMI!
>
> →

**`JER.boss.4`** · narrazione
> Il deserto trattiene il fiato.
>
> →

**`JER.boss.scelta1`** · bottone di scelta (porta a un combattimento)
> Estingui la fonte
>
> →


### La campagna di Jerah › `sconfitta`

**`JER.sconfitta.1`** · narrazione
> Ti risvegli fuori dalla plaza, la testa che rimbomba come un tamburo. Il disallineamento ti ha risputato nella sabbia. Per stavolta.
>
> →

**`JER.sconfitta.scelta1`** · bottone di scelta
> Torna alla mappa stellare
>
> →


### La campagna di Jerah › `vittoria`

**`JER.vittoria.1`** · narrazione
> Jerah si spegne senza una parola, gli occhi ancora sulle gradinate vuote. Non c'era più niente da salvare: il nucleo cede, e l'Organizzazione segna il pianeta come perduto. Nessuna rinascita, stavolta. Solo cenere dove c'era il fuoco.
>
> →

**`JER.vittoria.scelta1`** · bottone di scelta
> Torna alla mappa stellare
>
> →


### La campagna di Jerah › `vittoria_eroe`

**`JER.vittoria_eroe.1`** · narrazione
> L'ultimo spettacolo di Jerah finisce così: un inchino vero, il primo da anni, la muleta abbassata nella sabbia. Il nucleo si imbeve di fattore di disallineamento e si riassorbe: una pangea nuova, vita nuova, tutte le anime in fila per rinascere — anche la sua. L'Organizzazione lo chiamerà esito eroe. Tu lo chiami com'era: uno spettacolo, finito bene.
>
> →

**`JER.vittoria_eroe.scelta1`** · bottone di scelta
> Torna alla mappa stellare
>
> →


# 3. Chiacchiere coi compagni

<sub>`data/dialoghi.json`</sub>

Quello che i compagni dicono premendo «Parla con la squadra». Esiste solo dove qualcuno
l'ha scritto, stanza per stanza: l'elenco delle stanze ancora mute è in appendice, in
fondo a questo documento.


### Nella stanza `stanza_giochi`

**`COMP.stanza_giochi.1`** · narrazione
> %s si ferma davanti ai cuscini ammucchiati contro il muro, fissandoli con curiosità.
>
> →

**`COMP.stanza_giochi.2`** · battuta di Yhvina
> Hey, guarda qui, sembra esserci qualcosa sotto questo mucchio di cuscini... proviamo a spostarli?
>
> →

**`COMP.stanza_giochi.3`** · narrazione
> Tira un calcio violento contro i cuscini.
>
> →

**`COMP.stanza_giochi.4`** · battuta del compagno con cui stai parlando
> Ecco fatto... vedi? C'è un passaggio...
>
> →

**`COMP.stanza_giochi.5`** · narrazione
> Non ha perso molto tempo... Ma il risultato c'è.
>
> →


### Nella stanza `spirito_hub`

**`COMP.spirito_hub.1`** · battuta di Yhvina
> Sai, quella dolce signora mi sta proprio simpatica... yaaawn...
>
> →

**`COMP.spirito_hub.2`** · battuta di Yhvina
> Dovresti prendere esempio. Lei sì che sa riconoscere i talenti delle persone.
>
> →

**`COMP.spirito_hub.3`** · battuta di Anonimo
> ...
>
> →


### Nella stanza `albero_addio`

**`COMP.albero_addio.1`** · battuta di Yhvina
> Un vero peccato. Mi stava cominciando a essere molto simpatica... yaaawn...
>
> →


### Nella stanza `albero_addio_buono`

**`COMP.albero_addio_buono.1`** · battuta di Anonimo
> ... Forse è meglio non parlarle, ora.
>
> →


### Discussione in `salone` — tra Sally e Vega

**`COMP.conv.salone.1`** · battuta di Sally
> Ti giuro che in questa casa non c'è NIENTE di normale. Nemmeno un poster storto.
>
> →

**`COMP.conv.salone.2`** · battuta di Vega
> O forse è normale, per chi ci ha vissuto. Non tutti i ricordi buttano giù i muri.
>
> →

**`COMP.conv.salone.3`** · battuta di Sally
> Ai ricordi buoni non serve una casa gigante per starci dentro.
>
> →

**`COMP.conv.salone.med`** · invito a intervenire
> Le due si voltano verso di te, aspettando che tu dica la tua.
>
> →

**`COMP.conv.salone.med1.scelta`** · bottone di scelta
> Mostra la collana trovata in soffitta
>
> →

**`COMP.conv.salone.med1.battuta`** · cosa dice Anonimo
> Guardate: l'ho trovata in soffitta. Qualcuno di voi due la riconosce?
>
> →

**`COMP.conv.salone.med1.risposta`** · risposta di Vega
> Vedi? Anche le cose piccole restano. Grazie per averla notata.
>
> →

**`COMP.conv.salone.med2.scelta`** · bottone di scelta
> Prova a mediare tra le due
>
> →

**`COMP.conv.salone.med2.battuta`** · cosa dice Anonimo
> Magari ha ragione lei: a volte i ricordi fanno più rumore della verità.
>
> →

**`COMP.conv.salone.med2.risposta`** · risposta di Sally
> ...touché.
>
> →

**`COMP.conv.salone.med3.scelta`** · bottone di scelta
> Resta in silenzio e lascia che continuino da sole
>
> →


# 4. Le creature

<sub>`data/personaggi.json`</sub>

Voci del bestiario, risposte quando le studi, battute delle fasi dei boss, retro delle
carte collezionabili.


### Fomentado  <sub>`maschera_vuota`</sub>

**`CRE.maschera_vuota.nome`** · nome a schermo
> Fomentado
>
> →

**`CRE.maschera_vuota.descrizione`** · voce del bestiario
> Un'anima irrequieta spinta al suo limite dalla sua stessa passione, brucia forte, sempre! Finché non rimarrà che cenere.
>
> →

**`CRE.maschera_vuota.studio1.domanda`** · Studia › domanda (vuota = ne pesca una a caso dalle generiche)
> Rispondi.
>
> →

**`CRE.maschera_vuota.studio1.risposta`** · Studia › cosa risponde
> ¡Ándale! ...ándale... Non c'è tempo per fermarsi, lo spettacolo continua!
>
> →

**`CRE.maschera_vuota.studio2.domanda`** · Studia › domanda (vuota = ne pesca una a caso dalle generiche)
> Fammi capire cosa succede...
>
> →

**`CRE.maschera_vuota.studio2.risposta`** · Studia › cosa risponde
> ¡Soy para todos! ...o para nadie. Pero nunca pararé!
>
> →

**`CRE.maschera_vuota.combustione.testo_turno`** · ogni turno che brucia
> Il fuoco che porta dentro non si spegne mai: un altro pezzo di lui si consuma.
>
> →

**`CRE.maschera_vuota.carta.nome`** · nome sulla carta collezionabile
> Fomentado
>
> →

**`CRE.maschera_vuota.carta.testo`** · retro della carta collezionabile
> Un folle talentuoso che non ha mai rinunciato ai suoi sogni, un esempio di vita... forse.
>
> →


### El Muy Bonito  <sub>`giocoliere`</sub>

**`CRE.giocoliere.nome`** · nome a schermo
> El Muy Bonito
>
> →

**`CRE.giocoliere.descrizione`** · voce del bestiario
> Una rara bellezza, un campione nella recita, ma il talento a volte può farti uscire fuori di testa.
>
> →

**`CRE.giocoliere.studio1.domanda`** · Studia › domanda (vuota = ne pesca una a caso dalle generiche)
> Rivelami i tuoi desideri
>
> →

**`CRE.giocoliere.studio1.risposta`** · Studia › cosa risponde
> ¡No me digas lo que tengo que hacer, hombre! Soccombi dinnanzi a me, e brucia come io brucio nel cielo!
>
> →

**`CRE.giocoliere.studio2.domanda`** · Studia › domanda (vuota = ne pesca una a caso dalle generiche)
> Ti ascolto.
>
> →

**`CRE.giocoliere.studio2.risposta`** · Studia › cosa risponde
> Guardatemi! GUARDATEMI!!!
>
> →

**`CRE.giocoliere.combustione.testo_turno`** · ogni turno che brucia
> Le fiamme lo consumano un altro po'. Lui ne trae ancora più forza.
>
> →

**`CRE.giocoliere.carta.nome`** · nome sulla carta collezionabile
> El Muy Bonito
>
> →

**`CRE.giocoliere.carta.testo`** · retro della carta collezionabile
> Ho sempre voluto un suo autografo! - Fan.
>
> →


### Oppresso  <sub>`comparsa_di_ruggine`</sub>

**`CRE.comparsa_di_ruggine.nome`** · nome a schermo
> Oppresso
>
> →

**`CRE.comparsa_di_ruggine.descrizione`** · voce del bestiario
> La ruggine ha preso il posto della pelle, sta ancora aspettando che il suo turno finisca...
>
> →

**`CRE.comparsa_di_ruggine.studio1.domanda`** · Studia › domanda (vuota = ne pesca una a caso dalle generiche)
> (ascolti il suo ultimo ricordo)
>
> →

**`CRE.comparsa_di_ruggine.studio1.risposta`** · Studia › cosa risponde
> Taglia, separa, ricomincia... taglia, separa, ricomincia...
>
> →

**`CRE.comparsa_di_ruggine.studio2.domanda`** · Studia › domanda (vuota = ne pesca una a caso dalle generiche)
> (ascolti ancora)
>
> →

**`CRE.comparsa_di_ruggine.studio2.risposta`** · Studia › cosa risponde
> Acqua, ho bisogno di acqua...
>
> →

**`CRE.comparsa_di_ruggine.carta.nome`** · nome sulla carta collezionabile
> Oppresso
>
> →

**`CRE.comparsa_di_ruggine.carta.testo`** · retro della carta collezionabile
> Timbrava il cartellino anche il giorno in cui il mondo è finito.
>
> →


### Capocantiere  <sub>`voce_registrata`</sub>

**`CRE.voce_registrata.nome`** · nome a schermo
> Capocantiere
>
> →

**`CRE.voce_registrata.descrizione`** · voce del bestiario
> Gestire dieci... cento... no... mille operai insoddisfatti, non dà gratificazione alcuna.
>
> →

**`CRE.voce_registrata.studio1.risposta`** · Studia › cosa risponde
> Hey, tu! Torna subito al lavoro!
>
> →

**`CRE.voce_registrata.studio2.risposta`** · Studia › cosa risponde
> Lavorate! Lavorate!
>
> →

**`CRE.voce_registrata.carta.nome`** · nome sulla carta collezionabile
> Capocantiere
>
> →

**`CRE.voce_registrata.carta.testo`** · retro della carta collezionabile
> Urlava ordini anche quando non restava più nessuno ad ascoltarli.
>
> →


### Emblema dell'oppressione  <sub>`operaio_posseduto`</sub>

**`CRE.operaio_posseduto.nome`** · nome a schermo
> Emblema dell'oppressione
>
> →

**`CRE.operaio_posseduto.descrizione`** · voce del bestiario
> Ferraglia tenuta insieme dallo spirito di un lavoratore che non è mai tornato a casa.
>
> →

**`CRE.operaio_posseduto.studio1.domanda`** · Studia › domanda (vuota = ne pesca una a caso dalle generiche)
> (ascolti il suo ultimo ricordo)
>
> →

**`CRE.operaio_posseduto.studio1.risposta`** · Studia › cosa risponde
> signor... Kiz..a.. urgh... basta...
>
> →

**`CRE.operaio_posseduto.studio2.domanda`** · Studia › domanda (vuota = ne pesca una a caso dalle generiche)
> (ascolti ancora)
>
> →

**`CRE.operaio_posseduto.studio2.risposta`** · Studia › cosa risponde
> I miei bambini... devo tornare a casa...
>
> →

**`CRE.operaio_posseduto.carta.nome`** · nome sulla carta collezionabile
> Emblema dell'oppressione
>
> →

**`CRE.operaio_posseduto.carta.testo`** · retro della carta collezionabile
> Kizako Industries — dipendente n° illeggibile. Anzianità: eterna.
>
> →


### Robo Pattuglia  <sub>`robo_pattuglia`</sub>

**`CRE.robo_pattuglia.nome`** · nome a schermo
> Robo Pattuglia
>
> →

**`CRE.robo_pattuglia.nome_breve`** · nome corto (schede in combattimento)
> Robo Pattuglia
>
> →

**`CRE.robo_pattuglia.descrizione`** · voce del bestiario
> Una macchina di sorveglianza che non ha mai ricevuto l'ordine di smettere. Esegue un regolamento che nessuno applica più.
>
> →

**`CRE.robo_pattuglia.studio1.domanda`** · Studia › domanda (vuota = ne pesca una a caso dalle generiche)
> Cos'è questo posto.
>
> →

**`CRE.robo_pattuglia.studio1.risposta`** · Studia › cosa risponde
> NON HO I PERMESSI NECESSARI PER RISPONDERE ALLE SUE DOMANDE.
>
> →

**`CRE.robo_pattuglia.studio2.domanda`** · Studia › domanda (vuota = ne pesca una a caso dalle generiche)
> (provi ancora)
>
> →

**`CRE.robo_pattuglia.studio2.risposta`** · Studia › cosa risponde
> Non sembra essere possibile comunicare con questa macchina...
>
> →

**`CRE.robo_pattuglia.carta.nome`** · nome sulla carta collezionabile
> Robo Pattuglia
>
> →

**`CRE.robo_pattuglia.carta.testo`** · retro della carta collezionabile
> Turno di guardia iniziato il 14/03. Turno di guardia mai terminato.
>
> →


### Operaio Sfruttato  <sub>`operaio_sfruttato`</sub>

**`CRE.operaio_sfruttato.nome`** · nome a schermo
> Operaio Sfruttato
>
> →

**`CRE.operaio_sfruttato.nome_breve`** · nome corto (schede in combattimento)
> Operaio Sfruttato
>
> →

**`CRE.operaio_sfruttato.descrizione`** · voce del bestiario
> Non difende i file: difende le ore che ci ha lasciato dentro. Toccarli è toccare l'unica cosa che gli è rimasta.
>
> →

**`CRE.operaio_sfruttato.studio1.domanda`** · Studia › domanda (vuota = ne pesca una a caso dalle generiche)
> Cosa è successo in questo posto?
>
> →

**`CRE.operaio_sfruttato.studio1.risposta`** · Studia › cosa risponde
> Fai silenzio! Non toccare i miei file!
>
> →

**`CRE.operaio_sfruttato.studio2.domanda`** · Studia › domanda (vuota = ne pesca una a caso dalle generiche)
> (provi a calmarlo)
>
> →

**`CRE.operaio_sfruttato.studio2.risposta`** · Studia › cosa risponde
> Impossibile ragionarci: è furioso.
>
> →

**`CRE.operaio_sfruttato.carta.nome`** · nome sulla carta collezionabile
> Operaio Sfruttato
>
> →

**`CRE.operaio_sfruttato.carta.testo`** · retro della carta collezionabile
> Straordinari non retribuiti: illeggibile. Ferie maturate: nessuna.
>
> →


### Ferraglia Urlante  <sub>`ferraglia_urlante`</sub>

**`CRE.ferraglia_urlante.nome`** · nome a schermo
> Ferraglia Urlante
>
> →

**`CRE.ferraglia_urlante.descrizione`** · voce del bestiario
> Una montagna di rottami saldati dal dolore. Sembra di sentire le urla di una protesta.
>
> →

**`CRE.ferraglia_urlante.studio1.domanda`** · Studia › domanda (vuota = ne pesca una a caso dalle generiche)
> (ascolti il suo ultimo ricordo)
>
> →

**`CRE.ferraglia_urlante.studio1.risposta`** · Studia › cosa risponde
> Non ce la faccio più! Voglio guardare la tivù!
>
> →

**`CRE.ferraglia_urlante.studio2.domanda`** · Studia › domanda (vuota = ne pesca una a caso dalle generiche)
> (ascolti ancora)
>
> →

**`CRE.ferraglia_urlante.studio2.risposta`** · Studia › cosa risponde
> Qualcuno spenga le macchine! Non le sopporto più!
>
> →

**`CRE.ferraglia_urlante.carta.nome`** · nome sulla carta collezionabile
> Ferraglia Urlante
>
> →

**`CRE.ferraglia_urlante.carta.testo`** · retro della carta collezionabile
> Non un operaio: un intero reparto, compresso in una cosa sola.
>
> →


### Il Divoratore  <sub>`divoratore`</sub>

**`CRE.divoratore.nome`** · nome a schermo
> Il Divoratore
>
> →

**`CRE.divoratore.descrizione`** · voce del bestiario
> Una macchina che sembra uscita dai sogni di un pazzo, sembra divorare ogni cosa nel suo raggio d'azione, che sia viva o morta...
>
> →

**`CRE.divoratore.studio1.domanda`** · Studia › domanda (vuota = ne pesca una a caso dalle generiche)
> Fa veramente paura...
>
> →

**`CRE.divoratore.studio1.risposta`** · Studia › cosa risponde
> RRRR RRRR
>
> →

**`CRE.divoratore.studio2.domanda`** · Studia › domanda (vuota = ne pesca una a caso dalle generiche)
> Non c'è nulla da osservare
>
> →

**`CRE.divoratore.studio2.risposta`** · Studia › cosa risponde
> *Rattle*
>
> →

**`CRE.divoratore.carta.nome`** · nome sulla carta collezionabile
> Il Divoratore
>
> →

**`CRE.divoratore.carta.testo`** · retro della carta collezionabile
> Questa macchina ci fornirà nuova energia dai rifiuti! Sono un genio! - Dr. Kizako, Genio Indiscusso
>
> →


### Ghoul  <sub>`ghoul`</sub>

**`CRE.ghoul.nome`** · nome a schermo
> Ghoul
>
> →

**`CRE.ghoul.descrizione`** · voce del bestiario
> Carne marcia tenuta insieme dalla fame e da poco altro. Uno dei tanti che la Rocca di Ossidiana non ha mai lasciato andare.
>
> →

**`CRE.ghoul.studio1.risposta`** · Studia › cosa risponde
> Non sembra comprendere ragioni o avere una volontà.
>
> →

**`CRE.ghoul.carta.nome`** · nome sulla carta collezionabile
> Ghoul
>
> →

**`CRE.ghoul.carta.testo`** · retro della carta collezionabile
> Non ricorda il proprio nome. Ricorda solo la fame.
>
> →


### Teschio Errante  <sub>`teschio_errante`</sub>

**`CRE.teschio_errante.nome`** · nome a schermo
> Teschio Errante
>
> →

**`CRE.teschio_errante.descrizione`** · voce del bestiario
> Un teschio che galleggia basso sull'ossidiana, a scatti, come se cercasse ancora il corpo perduto.
>
> →

**`CRE.teschio_errante.studio1.risposta`** · Studia › cosa risponde
> una cosa molto Metal.
>
> →

**`CRE.teschio_errante.carta.nome`** · nome sulla carta collezionabile
> Teschio Errante
>
> →

**`CRE.teschio_errante.carta.testo`** · retro della carta collezionabile
> Vaga da anni. Non ha mai smesso di cercare.
>
> →


### Abominio Marcio  <sub>`abominio_marcio`</sub>

**`CRE.abominio_marcio.nome`** · nome a schermo
> Abominio Marcio
>
> →

**`CRE.abominio_marcio.descrizione`** · voce del bestiario
> Più corpi fusi insieme dal marciume, tenuti in piedi da qualcosa che non è più vita. Una delle tante forme che prende la maledizione della Rocca.
>
> →

**`CRE.abominio_marcio.carta.nome`** · nome sulla carta collezionabile
> Abominio Marcio
>
> →

**`CRE.abominio_marcio.carta.testo`** · retro della carta collezionabile
> Non è un solo mostro: sono tutti quelli che nessuno è venuto a seppellire.
>
> →


### Madre in Lacrime  <sub>`madre_in_lacrime`</sub>

**`CRE.madre_in_lacrime.nome`** · nome a schermo
> Madre in Lacrime
>
> →

**`CRE.madre_in_lacrime.descrizione`** · voce del bestiario
> Piange lacrime di ossidiana per figli che non tornano, e non lascia avvicinare nessuno a quel dolore.
>
> →

**`CRE.madre_in_lacrime.studio1.risposta`** · Studia › cosa risponde
> Lasciate stare i miei figli!
>
> →

**`CRE.madre_in_lacrime.carta.nome`** · nome sulla carta collezionabile
> Madre in Lacrime
>
> →

**`CRE.madre_in_lacrime.carta.testo`** · retro della carta collezionabile
> Nessuno ricorda più i nomi dei suoi figli. Lei sì.
>
> →


### Stigma  <sub>`stigma`</sub>

**`CRE.stigma.nome`** · nome a schermo
> Stigma
>
> →

**`CRE.stigma.descrizione`** · voce del bestiario
> Porta incisi sulla pelle i peccati di qualcun altro, marchiato da una colpa che non è la sua.
>
> →

**`CRE.stigma.studio1.risposta`** · Studia › cosa risponde
> Quel che non sai, quel che credi!
>
> →

**`CRE.stigma.carta.nome`** · nome sulla carta collezionabile
> Stigma
>
> →

**`CRE.stigma.carta.testo`** · retro della carta collezionabile
> Il marchio non si cancella. Nemmeno con la morte.
>
> →


### Diabolo  <sub>`diabolo`</sub>

**`CRE.diabolo.nome`** · nome a schermo
> Diabolo
>
> →

**`CRE.diabolo.descrizione`** · voce del bestiario
> Un piccolo demone da baraccone, cresciuto storto tra le fiamme della Rocca.
>
> →

**`CRE.diabolo.studio1.risposta`** · Studia › cosa risponde
> E' l'ora del male!
>
> →

**`CRE.diabolo.carta.nome`** · nome sulla carta collezionabile
> Diabolo
>
> →

**`CRE.diabolo.carta.testo`** · retro della carta collezionabile
> Rideva anche mentre bruciava. Forse rideva soprattutto per quello.
>
> →


### Sadico  <sub>`sadico`</sub>

**`CRE.sadico.nome`** · nome a schermo
> Sadico
>
> →

**`CRE.sadico.descrizione`** · voce del bestiario
> Trova piacere nel dolore altrui, l'unico linguaggio che la Rocca gli ha insegnato.
>
> →

**`CRE.sadico.studio1.risposta`** · Studia › cosa risponde
> Viooolenza!
>
> →

**`CRE.sadico.carta.nome`** · nome sulla carta collezionabile
> Sadico
>
> →

**`CRE.sadico.carta.testo`** · retro della carta collezionabile
> Alla Rocca ha imparato una sola cosa: far male fa stare meglio.
>
> →


### Jongo Dongo  <sub>`jongo_dongo`</sub>

**`CRE.jongo_dongo.nome`** · nome a schermo
> Jongo Dongo
>
> →

**`CRE.jongo_dongo.descrizione`** · voce del bestiario
> Un tempo signore di queste terre. Sacrificò raccolti e famiglie intere per la propria fortuna, e non si è mai pentito: la maledizione delle famiglie in lutto lo ha fatto marcire vivo, ma non lo ha fermato.
>
> →

**`CRE.jongo_dongo.studio1.domanda`** · Studia › domanda (vuota = ne pesca una a caso dalle generiche)
> Che cosa hai fatto...
>
> →

**`CRE.jongo_dongo.studio1.risposta`** · Studia › cosa risponde
> Chi siete... voi... siete venuti a rubare nella nostra terra?!
>
> →

**`CRE.jongo_dongo.studio2.domanda`** · Studia › domanda (vuota = ne pesca una a caso dalle generiche)
> Cosa è successo alla gente di queste terre?
>
> →

**`CRE.jongo_dongo.studio2.risposta`** · Studia › cosa risponde
> Non devo dare spiegazioni e chi vuole farci del male!
>
> →

**`CRE.jongo_dongo.studio3.domanda`** · Studia › domanda (vuota = ne pesca una a caso dalle generiche)
> Non hai idea delle forze con cui stai giocando...
>
> →

**`CRE.jongo_dongo.studio3.risposta`** · Studia › cosa risponde
> Sono stato benedetto dalla verità del lungo viaggio!
>
> →

**`CRE.jongo_dongo.studio4.domanda`** · Studia › domanda (vuota = ne pesca una a caso dalle generiche)
> Del lungo viaggio?
>
> →

**`CRE.jongo_dongo.studio4.risposta`** · Studia › cosa risponde
> Un piccolo sacrificio per un grande risultato. Voi... non potete capire...
>
> →

**`CRE.jongo_dongo.mossa_soglia_hp.testo`** · mossa sotto soglia
> Jongo Dongo batte tre volte il palmo marcio sull'ossidiana: la terra gli restituisce tre ghoul insieme.
>
> →

**`CRE.jongo_dongo.cura_su_morte_alleato.testo`** · quando muore un suo alleato
> Jongo Dongo respira a fondo mentre il ghoul si affloscia: quello che resta del suo servo gli rientra dentro. Recupera %d punti vita.
>
> →

**`CRE.jongo_dongo.mossa1.testo`** · cosa si legge quando la usa
> Jongo Dongo affonda l'artiglio marcio con tutto il suo peso.
>
> →

**`CRE.jongo_dongo.mossa2.testo`** · cosa si legge quando la usa
> Jongo Dongo cala il bastone dalla pietra marcia: dove tocca, la carne comincia a cedere.
>
> →

**`CRE.jongo_dongo.mossa3.testo`** · cosa si legge quando la usa
> "IL VIAGGIO RICHIEDE SEMPRE IL SUO PREZZO!" Il grido vi si conficca dentro più delle unghie.
>
> →

**`CRE.jongo_dongo.mossa4.testo`** · cosa si legge quando la usa
> Jongo Dongo si volta verso uno dei suoi ghoul, con la stessa calma di sempre: "Un piccolo sacrificio... per un grande risultato."
>
> →

**`CRE.jongo_dongo.mossa5.testo`** · cosa si legge quando la usa
> Jongo Dongo batte il palmo marcio sull'ossidiana: la terra stessa gli restituisce un altro ghoul.
>
> →

**`CRE.jongo_dongo.carta.nome`** · nome sulla carta collezionabile
> Jongo Dongo
>
> →

**`CRE.jongo_dongo.carta.testo`** · retro della carta collezionabile
> "Un piccolo sacrificio per un grande risultato." Lo pensava anche l'ultima volta.
>
> →


### Jongo Dongo  <sub>`jongo_dongo_risorto`</sub>

**`CRE.jongo_dongo_risorto.nome`** · nome a schermo
> Jongo Dongo
>
> →

**`CRE.jongo_dongo_risorto.descrizione`** · voce del bestiario
> Ormai non rimane altro di lui che un corpo marcito che si muove solo grazie a una volontà misteriosa.
>
> →

**`CRE.jongo_dongo_risorto.studio_esaurito`** · Studia › quando non ha più niente da dire
> Qualcosa sembra risiedere dentro di lui...
>
> →

**`CRE.jongo_dongo_risorto.carta.nome`** · nome sulla carta collezionabile
> Jongo Dongo
>
> →

**`CRE.jongo_dongo_risorto.carta.testo`** · retro della carta collezionabile
> "Un piccolo sacrificio per un grande risultato." Lo pensava anche l'ultima volta.
>
> →


### ???  <sub>`l_immortale`</sub>

**`CRE.l_immortale.nome`** · nome a schermo
> ???
>
> →

**`CRE.l_immortale.descrizione`** · voce del bestiario
> Qualcosa che cammina nella cripta, e non si ferma per quanto lo si colpisca. Il suo vero nome è ancora un mistero.
>
> →

**`CRE.l_immortale.avviso_fuga`** · se provi a scappare
> {'turno': 5, 'richiede_compagno': 'sopravvissuta', 'testo': 'Dobbiamo scappare, adesso! Non si può vincere contro di lui!'}
>
> →


### Sacerdote Folle  <sub>`sacerdote_folle`</sub>

**`CRE.sacerdote_folle.nome`** · nome a schermo
> Sacerdote Folle
>
> →

**`CRE.sacerdote_folle.descrizione`** · voce del bestiario
> Officiava i sacrifici della Rocca molto prima che Jongo Dongo ne facesse un culto. Recita ancora le sue litanie, anche se non è rimasto nessuno a rispondergli.
>
> →

**`CRE.sacerdote_folle.studio1.risposta`** · Studia › cosa risponde
> Continua a recitare, senza guardarti.
>
> →

**`CRE.sacerdote_folle.mossa1.testo`** · cosa si legge quando la usa
> "Per il viaggio!" Il sacerdote colpisce recitando.
>
> →

**`CRE.sacerdote_folle.mossa2.testo`** · cosa si legge quando la usa
> "Unisciti al raccolto!" Il sacerdote colpisce recitando.
>
> →

**`CRE.sacerdote_folle.mossa3.testo`** · cosa si legge quando la usa
> "Portatelo da me!" Il sacerdote colpisce recitando.
>
> →

**`CRE.sacerdote_folle.mossa4.testo`** · cosa si legge quando la usa
> "Non c'è altra strada!" Il sacerdote colpisce recitando.
>
> →

**`CRE.sacerdote_folle.mossa5.testo`** · cosa si legge quando la usa
> Il sacerdote alza le braccia: un teschio errante risponde al richiamo.
>
> →

**`CRE.sacerdote_folle.carta.nome`** · nome sulla carta collezionabile
> Sacerdote Folle
>
> →

**`CRE.sacerdote_folle.carta.testo`** · retro della carta collezionabile
> Ha smesso di distinguere la preghiera dalla minaccia. Forse non c'era mai stata differenza.
>
> →


### Divoratore di Carcasse  <sub>`divoratore_di_carcasse`</sub>

**`CRE.divoratore_di_carcasse.nome`** · nome a schermo
> Divoratore di Carcasse
>
> →

**`CRE.divoratore_di_carcasse.descrizione`** · voce del bestiario
> Vive sotto il grande ponte marcio, nutrendosi di ciò che il ponte stesso lascia cadere. La puzza lo tradisce molto prima che si mostri.
>
> →

**`CRE.divoratore_di_carcasse.mossa1.testo`** · cosa si legge quando la usa
> Il divoratore azzanna più volte, veloce.
>
> →

**`CRE.divoratore_di_carcasse.carta.nome`** · nome sulla carta collezionabile
> Divoratore di Carcasse
>
> →

**`CRE.divoratore_di_carcasse.carta.testo`** · retro della carta collezionabile
> Non ha mai dovuto cacciare: gli basta aspettare sotto il ponte.
>
> →


### Yara  <sub>`sopravvissuta`</sub>

**`CRE.sopravvissuta.nome`** · nome a schermo
> Yara
>
> →

**`CRE.sopravvissuta.descrizione`** · voce del bestiario
> L'unica sopravvissuta dei cunicoli di Jondoh. Anni a combattere ciò che si muove nel buio, in cerca di una sorella che nessuno le ha mai lasciata cercare davvero.
>
> →


### Zombie Mostruoso  <sub>`zombie_mostruoso`</sub>

**`CRE.zombie_mostruoso.nome`** · nome a schermo
> Zombie Mostruoso
>
> →

**`CRE.zombie_mostruoso.descrizione`** · voce del bestiario
> Qualcosa, in questo, ha continuato a crescere anche dopo la morte. Le braccia non sono più della stessa lunghezza.
>
> →

**`CRE.zombie_mostruoso.studio1.risposta`** · Studia › cosa risponde
> Un rantolo profondo, che sembra venire da più bocche insieme.
>
> →

**`CRE.zombie_mostruoso.carta.nome`** · nome sulla carta collezionabile
> Zombie Mostruoso
>
> →

**`CRE.zombie_mostruoso.carta.testo`** · retro della carta collezionabile
> Non tutti marciscono allo stesso modo. Alcuni si gonfiano.
>
> →


### Orrore di Meridia  <sub>`orrore_di_meridia`</sub>

**`CRE.orrore_di_meridia.nome`** · nome a schermo
> Orrore di Meridia
>
> →

**`CRE.orrore_di_meridia.descrizione`** · voce del bestiario
> Più corpi che si sono trovati nello stesso posto al momento sbagliato, e non si sono più separati.
>
> →

**`CRE.orrore_di_meridia.mossa1.testo`** · cosa si legge quando la usa
> L'orrore sferza con tutte le braccia insieme.
>
> →

**`CRE.orrore_di_meridia.mossa2.testo`** · cosa si legge quando la usa
> Più bocche affondano contemporaneamente.
>
> →

**`CRE.orrore_di_meridia.carta.nome`** · nome sulla carta collezionabile
> Orrore di Meridia
>
> →

**`CRE.orrore_di_meridia.carta.testo`** · retro della carta collezionabile
> A Meridia nessuno è morto da solo. Alcuni non se ne sono accorti.
>
> →


### Titano Zombie  <sub>`titano_zombie`</sub>

**`CRE.titano_zombie.nome`** · nome a schermo
> Titano Zombie
>
> →

**`CRE.titano_zombie.descrizione`** · voce del bestiario
> La cosa più grande che Meridia abbia partorito dopo la fine. Si ricuce da solo, e non ha mai imparato a fermarsi.
>
> →

**`CRE.titano_zombie.mossa1.testo`** · cosa si legge quando la usa
> Pugno devastante: il colpo si abbatte con tutto il peso della città morta.
>
> →

**`CRE.titano_zombie.mossa2.testo`** · cosa si legge quando la usa
> Il titano spazza l'aria davanti a sé: nessuno resta in piedi comodo.
>
> →

**`CRE.titano_zombie.carta.nome`** · nome sulla carta collezionabile
> Titano Zombie
>
> →

**`CRE.titano_zombie.carta.testo`** · retro della carta collezionabile
> Nelle parti profonde della città c'è qualcosa che non smette di rialzarsi. Chi l'ha visto non è tornato a raccontarlo due volte.
>
> →


### Zombie Cittadino  <sub>`zombie_cittadino`</sub>

**`CRE.zombie_cittadino.nome`** · nome a schermo
> Zombie Cittadino
>
> →

**`CRE.zombie_cittadino.descrizione`** · voce del bestiario
> Era qualcuno, a Meridia, prima del coprifuoco. Ora cammina piano, verso niente in particolare, con tutti gli altri.
>
> →

**`CRE.zombie_cittadino.carta.nome`** · nome sulla carta collezionabile
> Zombie Cittadino
>
> →

**`CRE.zombie_cittadino.carta.testo`** · retro della carta collezionabile
> Meridia ne ha fatti a migliaia, tutti uguali.
>
> →


### Infetto Rapido  <sub>`infetto_rapido`</sub>

**`CRE.infetto_rapido.nome`** · nome a schermo
> Infetto Rapido
>
> →

**`CRE.infetto_rapido.descrizione`** · voce del bestiario
> Non tutti a Meridia sono diventati lenti. Questi corrono ancora, come se stessero ancora scappando da qualcosa.
>
> →

**`CRE.infetto_rapido.studio1.domanda`** · Studia › domanda (vuota = ne pesca una a caso dalle generiche)
> Cosa vuoi da me?
>
> →

**`CRE.infetto_rapido.studio1.risposta`** · Studia › cosa risponde
> Non sembra voler altro se non la tua fine.
>
> →

**`CRE.infetto_rapido.studio2.domanda`** · Studia › domanda (vuota = ne pesca una a caso dalle generiche)
> (provi a rallentarlo con la voce)
>
> →

**`CRE.infetto_rapido.studio2.risposta`** · Studia › cosa risponde
> Corre lo stesso. Non ha mai smesso.
>
> →

**`CRE.infetto_rapido.carta.nome`** · nome sulla carta collezionabile
> Infetto Rapido
>
> →

**`CRE.infetto_rapido.carta.testo`** · retro della carta collezionabile
> Corre da anni. Non si è mai fermato a chiedersi perché.
>
> →


### Nuvola di Marciume  <sub>`nuvola_di_marciume`</sub>

**`CRE.nuvola_di_marciume.nome`** · nome a schermo
> Nuvola di Marciume
>
> →

**`CRE.nuvola_di_marciume.nome_breve`** · nome corto (schede in combattimento)
> Nuvola
>
> →

**`CRE.nuvola_di_marciume.descrizione`** · voce del bestiario
> Un pezzo della coltre che copre Meridia, sceso più in basso degli altri. Non insegue nessuno: capita addosso.
>
> →

**`CRE.nuvola_di_marciume.studio1.domanda`** · Studia › domanda (vuota = ne pesca una a caso dalle generiche)
> (la osservi mentre si addensa)
>
> →

**`CRE.nuvola_di_marciume.studio1.risposta`** · Studia › cosa risponde
> Sembra che le nubi che ricoprono il cielo possano prendere vita propria...
>
> →

**`CRE.nuvola_di_marciume.studio2.domanda`** · Studia › domanda (vuota = ne pesca una a caso dalle generiche)
> (provi a richiamare la sua attenzione)
>
> →

**`CRE.nuvola_di_marciume.studio2.risposta`** · Studia › cosa risponde
> Non sembra reagire ad alcuno stimolo.
>
> →

**`CRE.nuvola_di_marciume.carta.nome`** · nome sulla carta collezionabile
> Nuvola di Marciume
>
> →

**`CRE.nuvola_di_marciume.carta.testo`** · retro della carta collezionabile
> Il cielo di Meridia, in una porzione abbastanza piccola da poterla colpire.
>
> →


### Marionetta  <sub>`marionetta`</sub>

**`CRE.marionetta.nome`** · nome a schermo
> Marionetta
>
> →

**`CRE.marionetta.descrizione`** · voce del bestiario
> Legno, fili e un po' di rancore. Qualcuno la muoveva con affetto, una volta.
>
> →

**`CRE.marionetta.carta.nome`** · nome sulla carta collezionabile
> Marionetta
>
> →

**`CRE.marionetta.carta.testo`** · retro della carta collezionabile
> I fili non li tiene più nessuno. Eppure si muove.
>
> →


### Ombra del passato  <sub>`ombra_del_passato`</sub>

**`CRE.ombra_del_passato.nome`** · nome a schermo
> Ombra del passato
>
> →

**`CRE.ombra_del_passato.descrizione`** · voce del bestiario
> Un'ombra del passato, vive grazie ai sentimenti repressi di qualcuno che ricorda la persona da cui prende forma con sentimenti negativi.
>
> →

**`CRE.ombra_del_passato.carta.nome`** · nome sulla carta collezionabile
> Ombra del passato
>
> →

**`CRE.ombra_del_passato.carta.testo`** · retro della carta collezionabile
> Le ombre del passato assumono la forma di persone ricordate con odio, parlano di fatti che hanno lasciato dei segni irremovibili nell'anima di qualcuno e sono forti quanto l'odio provato nei confronti di quelle persone.
>
> →


### Donna Spinosa  <sub>`donna_spinosa`</sub>

**`CRE.donna_spinosa.nome`** · nome a schermo
> Donna Spinosa
>
> →

**`CRE.donna_spinosa.nome_breve`** · nome corto (schede in combattimento)
> Donna Spinosa
>
> →

**`CRE.donna_spinosa.descrizione`** · voce del bestiario
> Cresciuta in una vasca con un cartellino che diceva un'altra cosa. Sta ferma finché non le passi accanto, e allora si ricorda di essere stata progettata.
>
> →

**`CRE.donna_spinosa.studio1.domanda`** · Studia › domanda (vuota = ne pesca una a caso dalle generiche)
> Chi eri?
>
> →

**`CRE.donna_spinosa.studio1.risposta`** · Studia › cosa risponde
> Muove le labbra, ma quello che ne esce è solo un fruscio di foglie.
>
> →

**`CRE.donna_spinosa.studio2.domanda`** · Studia › domanda (vuota = ne pesca una a caso dalle generiche)
> (cerchi il cartellino della sua vasca)
>
> →

**`CRE.donna_spinosa.studio2.risposta`** · Studia › cosa risponde
> La specie dichiarata sul cartellino non ha niente a che vedere con quello che ti sta davanti.
>
> →

**`CRE.donna_spinosa.mossa1.testo`** · cosa si legge quando la usa
> Le spine entrano piano, quasi con gentilezza. Il bruciore arriva dopo.
>
> →

**`CRE.donna_spinosa.carta.nome`** · nome sulla carta collezionabile
> Donna Spinosa
>
> →

**`CRE.donna_spinosa.carta.testo`** · retro della carta collezionabile
> Vivaio 3, vasca 11. Specie dichiarata: ornamentale.
>
> →


### Volto sulla parete  <sub>`volto_sulla_parete`</sub>

**`CRE.volto_sulla_parete.nome`** · nome a schermo
> Volto sulla parete
>
> →

**`CRE.volto_sulla_parete.nome_breve`** · nome corto (schede in combattimento)
> Il volto
>
> →

**`CRE.volto_sulla_parete.descrizione`** · voce del bestiario
> Quello che è rimasto della capofamiglia, cresciuto dentro la parete insieme a tutto il resto. Difende ancora i risultati di ricerche che non servono più a nessuno.
>
> →

**`CRE.volto_sulla_parete.studio1.domanda`** · Studia › domanda (vuota = ne pesca una a caso dalle generiche)
> (la osservi)
>
> →

**`CRE.volto_sulla_parete.studio1.risposta`** · Studia › cosa risponde
> Sembra il volto di una persona anziana: trasuda odio e rabbia da ogni parte.
>
> →

**`CRE.volto_sulla_parete.studio2.domanda`** · Studia › domanda (vuota = ne pesca una a caso dalle generiche)
> Cosa è successo in questo posto?
>
> →

**`CRE.volto_sulla_parete.studio2.risposta`** · Studia › cosa risponde
> Fastidiosi parassiti... sparite!
>
> →

**`CRE.volto_sulla_parete.studio3.domanda`** · Studia › domanda (vuota = ne pesca una a caso dalle generiche)
> Ho capito: sei quella folle che ha rovinato questo posto.
>
> →

**`CRE.volto_sulla_parete.studio3.risposta`** · Studia › cosa risponde
> Eh?! Chi ti credi di essere. Sudicio insetto!
>
> →

**`CRE.volto_sulla_parete.studio4.domanda`** · Studia › domanda (vuota = ne pesca una a caso dalle generiche)
> Non ti è bastato rovinare la tua famiglia?
>
> →

**`CRE.volto_sulla_parete.studio4.risposta`** · Studia › cosa risponde
> Piccolo stupido: delle parole di voi scarafaggi non me ne faccio niente!
>
> →

**`CRE.volto_sulla_parete.studio5.domanda`** · Studia › domanda (vuota = ne pesca una a caso dalle generiche)
> (cerchi un appiglio, un rimorso, qualcosa)
>
> →

**`CRE.volto_sulla_parete.studio5.risposta`** · Studia › cosa risponde
> C'è solo malvagità in questo essere. Non hai alternative.
>
> →

**`CRE.volto_sulla_parete.mossa1.testo`** · cosa si legge quando la usa
> Le radici escono dal pavimento e stringono: dove toccano, la pelle cambia colore.
>
> →

**`CRE.volto_sulla_parete.mossa2.testo`** · cosa si legge quando la usa
> La parete si apre e sputa una nube di spore su tutta la stanza.
>
> →

**`CRE.volto_sulla_parete.carta.nome`** · nome sulla carta collezionabile
> Volto sulla parete
>
> →

**`CRE.volto_sulla_parete.carta.testo`** · retro della carta collezionabile
> Capo ricerca. Ha firmato ogni autorizzazione, compresa l'ultima.
>
> →


### Spirito dei giardini  <sub>`spirito_dei_giardini`</sub>

**`CRE.spirito_dei_giardini.nome`** · nome a schermo
> Spirito dei giardini
>
> →

**`CRE.spirito_dei_giardini.nome_breve`** · nome corto (schede in combattimento)
> la custode
>
> →

**`CRE.spirito_dei_giardini.descrizione`** · voce del bestiario
> La vecchia custode dei giardini della magione, e un tempo capo ricerca al fianco della capofamiglia. Innaffia le stesse piante da più anni di quanti ne sappia contare.
>
> →


### Le lettere sull'altare  <sub>`lettere_altare`</sub>

**`CRE.lettere_altare.nome`** · nome a schermo
> Le lettere sull'altare
>
> →

**`CRE.lettere_altare.nome_breve`** · nome corto (schede in combattimento)
> le lettere
>
> →


### Un tenero ricordo  <sub>`tenero_ricordo`</sub>

**`CRE.tenero_ricordo.nome`** · nome a schermo
> Un tenero ricordo
>
> →

**`CRE.tenero_ricordo.nome_breve`** · nome corto (schede in combattimento)
> la bambola
>
> →

**`CRE.tenero_ricordo.descrizione`** · voce del bestiario
> Una bambola cucita a mano, Non ha un bel aspetto ma sembra essere stata amata. Qualcosa di oscuro si annida tra le cuciture.
>
> →

**`CRE.tenero_ricordo.descrizione_extra`** · voce del bestiario, dopo averla studiata
> {'richiede_oggetto': 'prova_di_un_forte_amore', 'testo': 'A volte un oggetto può amarti più di quanto chi dovrebbe farlo abbia mai fatto...'}
>
> →

**`CRE.tenero_ricordo.testo_cedimento`** · quando cede
> Qualcosa, nella bambola, si ammorbidisce. Non è più solo dolore, quello che trema tra le sue cuciture.
>
> →

**`CRE.tenero_ricordo.frenesia.testo_sblocco_bersaglio`** · frenesia
> Non è vero... bugiardi... a voi non è dispiaciuto davvero...
>
> →

**`CRE.tenero_ricordo.mossa1.testo`** · cosa si legge quando la usa
> La bambola spalanca le cuciture e lancia una manciata di spilli.
>
> →

**`CRE.tenero_ricordo.mossa2.testo`** · cosa si legge quando la usa
> Un lamento terribile riempie la stanza. I cuori di tutti sobbalzano.
>
> →

**`CRE.tenero_ricordo.mossa3.testo`** · cosa si legge quando la usa
> La bambola si strappa una cucitura da sola, piano. Fa più male a voi che a lei.
>
> →

**`CRE.tenero_ricordo.mossa4.testo`** · cosa si legge quando la usa
> Dei fili scendono dal soffitto: una marionetta si alza da terra.
>
> →

**`CRE.tenero_ricordo.leva1.testo`** · quando le mostri l'oggetto giusto
> "..."<br>"Lil..."<br>"...Loh?"
>
> →

**`CRE.tenero_ricordo.leva1.testo_fermo`** · se la mostri di nuovo
> La... mia... migliore... amica...
>
> →

**`CRE.tenero_ricordo.leva2.testo`** · quando le mostri l'oggetto giusto
> Un lamento sottile, quasi un sollievo: qualcosa che pesava da anni si è appena alleggerito.
>
> →

**`CRE.tenero_ricordo.carta.nome`** · nome sulla carta collezionabile
> Un tenero ricordo
>
> →

**`CRE.tenero_ricordo.carta.testo`** · retro della carta collezionabile
> Una Bambola che ha preso vita dai sentimenti puri di un bambino, a volte l'amore può trasformarsi in qualcosa di pauroso.
>
> →


### L'ultimo spettacolo di Jerah  <sub>`jerah`</sub>

**`CRE.jerah.nome`** · nome a schermo
> L'ultimo spettacolo di Jerah
>
> →

**`CRE.jerah.nome_breve`** · nome corto (schede in combattimento)
> Jerah
>
> →

**`CRE.jerah.descrizione`** · voce del bestiario
> Un talento unico, forse 1 su 10milioni: il più grande spettacolo che il mondo abbia mai visto, una passione ardente, pericolosamente spenta... Il mondo intero arde, arde teatro del suo ultimo show.
>
> →

**`CRE.jerah.descrizione_extra`** · voce del bestiario, dopo averla studiata
> {'richiede_oggetto': 'biglietto_strano', 'testo': "Sembrerebbe che il suo egoismo vacillasse di fronte all'unica prova di affetto sincero che abbia mai ricevuto. Anche una sola persona può cambiare il destino di un intero mondo grazie a un gesto di affetto."}
>
> →

**`CRE.jerah.studio1.domanda`** · Studia › domanda (vuota = ne pesca una a caso dalle generiche)
> Rivelami chi sei... Perché fai tutto questo?
>
> →

**`CRE.jerah.studio1.risposta`** · Studia › cosa risponde
> Cosa ne puoi sapere tu, di me, un pobre hombre che ha sacrificato tutto per dimostrare cosa valeva!
>
> →

**`CRE.jerah.studio2.domanda`** · Studia › domanda (vuota = ne pesca una a caso dalle generiche)
> Abbiamo più cose in comune di quanto pensi, tu potresti aiutare a capirmi.
>
> →

**`CRE.jerah.studio2.risposta`** · Studia › cosa risponde
> ¡Pobre hombre! ¡Muere!
>
> →

**`CRE.jerah.studio3.domanda`** · Studia › domanda (vuota = ne pesca una a caso dalle generiche)
> Non ti do la colpa di tutto questo, voglio solo capire la tua storia...
>
> →

**`CRE.jerah.studio3.risposta`** · Studia › cosa risponde
> La mia storia è proprio quello che ha causato tutto questo, questo mondo non merita di essere salvato.
>
> →

**`CRE.jerah.studio4.domanda`** · Studia › domanda (vuota = ne pesca una a caso dalle generiche)
> Forse questo mondo no, ma tu sì.
>
> →

**`CRE.jerah.studio4.risposta`** · Studia › cosa risponde
> ...
>
> →

**`CRE.jerah.cedimento1.domanda`** · Studia › la domanda che la fa cedere
> Vedo che hai capito quale è stato il nostro errore... Vale la pena... di ricominciare...
>
> →

**`CRE.jerah.cedimento1.risposta`** · Studia › cosa risponde cedendo
> No. Per me è tardi... Ma cercherò di dare un bel finale a questa storia!
>
> →

**`CRE.jerah.cedimento2.domanda`** · Studia › la domanda che la fa cedere
> Vecchio Proprietario del teatro: È stato bello... lavorare con te, sai?...
>
> →

**`CRE.jerah.cedimento2.risposta`** · Studia › cosa risponde cedendo
> Grazie. Osservami, mentre cala il sipario per l'ultima volta, vecchio amico...
>
> →

**`CRE.jerah.testo_cedimento`** · quando cede
> Jerah barcolla. "Qué espectáculo... voi due," mormora. L'arena intera trema con lui. Ma non smette di attaccare: "Non posso perdere!"
>
> →

**`CRE.jerah.mossa1.testo`** · cosa si legge quando la usa
> ¡GRAN FINALE! Un muro di fiamme spazza tutta l'arena.
>
> →

**`CRE.jerah.mossa2.testo`** · cosa si legge quando la usa
> ¡Vamos! ... Una folata di vento ardente ti infligge lo status in fiamme.
>
> →

**`CRE.jerah.mossa3.testo`** · cosa si legge quando la usa
> Jerah schiva elegantemente tutti i tuoi colpi.
>
> →

**`CRE.jerah.mossa4.testo`** · cosa si legge quando la usa
> Jerah batte il tacco tre volte: dal fumo sale un Fomentado.
>
> →

**`CRE.jerah.leva1.testo`** · quando le mostri l'oggetto giusto
> La medaglia della vecchia plaza ti scivola di tasca e rotola nella sabbia dell'arena. Jerah smette di sorridere.
>
> →

**`CRE.jerah.leva2.testo`** · quando le mostri l'oggetto giusto
> Il biglietto ti scivola tra le dita e plana ai piedi di Jerah. Lui lo raccoglie come si raccoglie una cosa viva. Non dice perché.
>
> →

**`CRE.jerah.leva3.testo`** · quando le mostri l'oggetto giusto
> Il Vecchio Proprietario del teatro scavalca la barriera ed entra nel ruedo, zoppicando. "Sono ancora qui, muchacho. Non me ne sono mai andato."
>
> →

**`CRE.jerah.carta.nome`** · nome sulla carta collezionabile
> L'ultimo spettacolo di Jerah
>
> →

**`CRE.jerah.carta.testo`** · retro della carta collezionabile
> Era un giovane promettente, abbandonato da tutti, non mi sono mai pentito di avergli dato una possibilità. - Raphael Genio del Teatro
>
> →


### Goblin Tipico  <sub>`goblin_tipico`</sub>

**`CRE.goblin_tipico.nome`** · nome a schermo
> Goblin Tipico
>
> →

**`CRE.goblin_tipico.descrizione`** · voce del bestiario
> Verde, spelacchiato, armato di un bastone che ha trovato per terra. Non ha mai vinto una rissa in vita sua.
>
> →

**`CRE.goblin_tipico.studio1.risposta`** · Studia › cosa risponde
> Grugnisce, e nemmeno troppo convinto.
>
> →

**`CRE.goblin_tipico.carta.nome`** · nome sulla carta collezionabile
> Goblin Tipico
>
> →

**`CRE.goblin_tipico.carta.testo`** · retro della carta collezionabile
> Ce ne sono a centinaia su questo pianeta. Nessuno li conta più.
>
> →


### Slime Infimo  <sub>`slime_infimo`</sub>

**`CRE.slime_infimo.nome`** · nome a schermo
> Slime Infimo
>
> →

**`CRE.slime_infimo.descrizione`** · voce del bestiario
> Una pozza gelatinosa che si crede un mostro. Ci vuole più tempo a notarlo che a batterlo.
>
> →

**`CRE.slime_infimo.studio1.risposta`** · Studia › cosa risponde
> Non sembra avere nulla da dire. O da pensare.
>
> →

**`CRE.slime_infimo.carta.nome`** · nome sulla carta collezionabile
> Slime Infimo
>
> →

**`CRE.slime_infimo.carta.testo`** · retro della carta collezionabile
> Il gradino più basso della catena alimentare di questo pianeta. Forse anche più in basso.
>
> →


### Tartaruga Innocente  <sub>`tartaruga_innocente`</sub>

**`CRE.tartaruga_innocente.nome`** · nome a schermo
> Tartaruga Innocente
>
> →

**`CRE.tartaruga_innocente.descrizione`** · voce del bestiario
> Un guscio enorme e un aspetto che mette paura. Non ha mai fatto del male a nessuno.
>
> →

**`CRE.tartaruga_innocente.risparmio.testo`** · quando lo risparmi
> Decidi di lasciarla andare. Non c'era nessuna ragione di combatterla. Sul terreno, dove si trovava, resta una pietra liscia e fredda.
>
> →

**`CRE.tartaruga_innocente.mossa1.testo`** · cosa si legge quando la usa
> La tartaruga si ritira nel guscio.
>
> →

**`CRE.tartaruga_innocente.carta.nome`** · nome sulla carta collezionabile
> Tartaruga Innocente
>
> →

**`CRE.tartaruga_innocente.carta.testo`** · retro della carta collezionabile
> Vecchia, lenta, spaventosa da guardare. Nient'altro.
>
> →


### Manifestazione di un sogno  <sub>`manifestazione_di_un_sogno`</sub>

**`CRE.manifestazione_di_un_sogno.nome`** · nome a schermo
> Manifestazione di un sogno
>
> →

**`CRE.manifestazione_di_un_sogno.nome_breve`** · nome corto (schede in combattimento)
> La manifestazione
>
> →

**`CRE.manifestazione_di_un_sogno.descrizione`** · voce del bestiario
> Una forma che non dovrebbe esistere ancora, presa in prestito da un sogno che qualcuno, su questo pianeta, sta ancora sognando.
>
> →

**`CRE.manifestazione_di_un_sogno.studio1.domanda`** · Studia › domanda (vuota = ne pesca una a caso dalle generiche)
> Cosa sei... Non ho mai visto qualcosa di simile...
>
> →

**`CRE.manifestazione_di_un_sogno.studio1.risposta`** · Studia › cosa risponde
> Lasciati andare... Dormi...
>
> →

**`CRE.manifestazione_di_un_sogno.studio2.domanda`** · Studia › domanda (vuota = ne pesca una a caso dalle generiche)
> Non riesco più... a ... restare in piedi... devo... scappare...
>
> →

**`CRE.manifestazione_di_un_sogno.studio2.risposta`** · Studia › cosa risponde
> Sei stato molto bravo, ora riposa... per sempre... insieme a me...
>
> →

**`CRE.manifestazione_di_un_sogno.studio_esaurito`** · Studia › quando non ha più niente da dire
> La testa ti gira all'improvviso: non sei più in grado di studiare il nemico.
>
> →

**`CRE.manifestazione_di_un_sogno.carta.nome`** · nome sulla carta collezionabile
> Manifestazione di un sogno
>
> →

**`CRE.manifestazione_di_un_sogno.carta.testo`** · retro della carta collezionabile
> Non tutto quello che si incontra va combattuto. Alcune cose vanno solo evitate.
>
> →


### Un goblin terribilmente arrabbiato  <sub>`goblin_arrabbiato`</sub>

**`CRE.goblin_arrabbiato.nome`** · nome a schermo
> Un goblin terribilmente arrabbiato
>
> →

**`CRE.goblin_arrabbiato.nome_breve`** · nome corto (schede in combattimento)
> Goblin Arrabbiato
>
> →

**`CRE.goblin_arrabbiato.descrizione`** · voce del bestiario
> Non è mai stato bello, forte o rispettato, nemmeno tra i suoi. Il fattore di disallineamento gli ha dato l'unica cosa che gli mancava: qualcuno che lo temesse.
>
> →

**`CRE.goblin_arrabbiato.studio1.domanda`** · Studia › domanda (vuota = ne pesca una a caso dalle generiche)
> Perché tutta questa rabbia?
>
> →

**`CRE.goblin_arrabbiato.studio1.risposta`** · Studia › cosa risponde
> RABBIA! SOLO RABBIA!
>
> →

**`CRE.goblin_arrabbiato.studio2.domanda`** · Studia › domanda (vuota = ne pesca una a caso dalle generiche)
> Non hai altro da dire?
>
> →

**`CRE.goblin_arrabbiato.studio2.risposta`** · Studia › cosa risponde
> Nessuno mi ha mai ascoltato prima. Perché dovrei parlare adesso?
>
> →

**`CRE.goblin_arrabbiato.dialogo_soglia_hp.testo`** · quando scende sotto una soglia di vita
> Il goblin non accetta il suo destino: con le lacrime agli occhi, tenendo la sua mazza con le dita consunte, ti guarda con un odio indescrivibile. Il cuore di un perdente non vacilla mai. Preparati.
>
> →

**`CRE.goblin_arrabbiato.mossa_disperazione.testo`** · mossa della disperazione
> Ultima risorsa del perdente: un attacco suicida, colmo di rabbia.
>
> →

**`CRE.goblin_arrabbiato.rabbia_su_morte_alleato.testo`** · rabbia per un alleato caduto
> Il goblin arrabbiato ringhia: la morte del suo simile lo fa infuriare ancora di più. Il suo attacco cresce.
>
> →

**`CRE.goblin_arrabbiato.mossa1.testo`** · cosa si legge quando la usa
> Richiamo dei suoi simili: urla nella notte, e un goblin tipico risponde alla chiamata.
>
> →

**`CRE.goblin_arrabbiato.mossa2.testo`** · cosa si legge quando la usa
> Furia di un goblin: colpisce alla cieca, urlando.
>
> →

**`CRE.goblin_arrabbiato.mossa3.testo`** · cosa si legge quando la usa
> Pugno del vile: un colpo sferrato senza il minimo onore.
>
> →

**`CRE.goblin_arrabbiato.mossa4.testo`** · cosa si legge quando la usa
> Capriccio del goblin: si mette a battere i piedi e se la prende con tutto quello che ha intorno. Il suo attacco aumenta.
>
> →

**`CRE.goblin_arrabbiato.mossa5.testo`** · cosa si legge quando la usa
> Cattiveria innata: ti sferra tre attacchi deboli di fila.
>
> →

**`CRE.goblin_arrabbiato.carta.nome`** · nome sulla carta collezionabile
> Un goblin terribilmente arrabbiato
>
> →

**`CRE.goblin_arrabbiato.carta.testo`** · retro della carta collezionabile
> La prima fonte che l'Organizzazione ti manda a estinguere. Non tutte le fonti nascondono una tragedia.
>
> →


### Computer  <sub>`computer`</sub>

**`CRE.computer.nome`** · nome a schermo
> Computer
>
> →


### Veronica  <sub>`veronica`</sub>

**`CRE.veronica.nome`** · nome a schermo
> Veronica
>
> →

**`CRE.veronica.descrizione`** · voce del bestiario
> La tua allenatrice, e l'amica d'infanzia che non ha mai imparato a dosare la forza.
>
> →

**`CRE.veronica.studio1.domanda`** · Studia › domanda (vuota = ne pesca una a caso dalle generiche)
> Veronica è stata la mia prima e forse unica amica... non mi ha mai abbandonato fin da quando eravamo piccoli...
>
> →

**`CRE.veronica.studio1.risposta`** · Studia › cosa risponde
> Hey! Cosa succede? Guarda che io sono qui!
>
> →

**`CRE.veronica.studio_esaurito`** · Studia › quando non ha più niente da dire
> Non c'è altro che tu possa capire di lei adesso: è già tutta lì, davanti a te.
>
> →

**`CRE.veronica.allenamento1.prima1`** · allenamento, passo 1 (ATTACCA) — prima che tu agisca, battuta di Veronica
> Fammi vedere di cosa sei capace: colpiscimi al massimo della potenza.
>
> →

**`CRE.veronica.allenamento1.prima2`** · allenamento, passo 1 (ATTACCA) — prima che tu agisca, narrazione
> Scegli ATTACCA per colpire. È l'azione base: il danno dipende dal tuo attacco meno la difesa di chi hai davanti.
>
> →

**`CRE.veronica.allenamento1.dopo1`** · allenamento, passo 1 (ATTACCA) — dopo che hai agito, battuta di Veronica
> Spero che quello non fosse tutto quello di cui sei capace, {nome}...
>
> →

**`CRE.veronica.allenamento2.prima1`** · allenamento, passo 2 (DIFENDI) — prima che tu agisca, narrazione
> Veronica sembra caricare un pugno. È il momento di difendersi.
>
> →

**`CRE.veronica.allenamento2.prima2`** · allenamento, passo 2 (DIFENDI) — prima che tu agisca, narrazione
> Scegli DIFENDITI: alza la guardia per il turno. Usata di fila cresce, ma sempre di meno — e si perde appena fai altro.
>
> →

**`CRE.veronica.allenamento2.dopo1`** · allenamento, passo 2 (DIFENDI) — dopo che hai agito, narrazione
> Ti difendi, ma il colpo è comunque enorme: finisci a un passo dal collasso.
>
> →

**`CRE.veronica.allenamento3.prima1`** · allenamento, passo 3 (OGGETTO) — prima che tu agisca, battuta di Veronica
> In piedi. E adesso curati con tutta la tua anima!
>
> →

**`CRE.veronica.allenamento3.prima2`** · allenamento, passo 3 (OGGETTO) — prima che tu agisca, narrazione
> Apri OGGETTI e usa la Fiala HP: i consumabili si spendono, ma possono salvarti il combattimento.
>
> →

**`CRE.veronica.allenamento3.dopo1`** · allenamento, passo 3 (OGGETTO) — dopo che hai agito, battuta di Veronica
> Ottimo, che tu sia rimasto in piedi mi fa bruciare di emozione! Vuol dire che sono stata un'insegnante incredibilmente efficiente.
>
> →

**`CRE.veronica.allenamento4.prima1`** · allenamento, passo 4 (OGGETTO) — prima che tu agisca, battuta di Veronica
> Prova a colpirmi con un oggetto ora: scommetto che riuscirò a uscirne illesa alla massima potenza!
>
> →

**`CRE.veronica.allenamento4.prima2`** · allenamento, passo 4 (OGGETTO) — prima che tu agisca, battuta di Anonimo
> Ehm, sei la solita esagerata... una bomba al nitro?
>
> →

**`CRE.veronica.allenamento4.prima3`** · allenamento, passo 4 (OGGETTO) — prima che tu agisca, battuta di Veronica
> Colpiscimi! Sto bruciando come mille soli!
>
> →

**`CRE.veronica.allenamento4.dopo1`** · allenamento, passo 4 (OGGETTO) — dopo che hai agito, narrazione
> Le abilità passive si ottengono da oggetti equipaggiati, salendo di livello, o avendo in squadra un compagno con un forte legame.
>
> →

**`CRE.veronica.allenamento4.dopo2`** · allenamento, passo 4 (OGGETTO) — dopo che hai agito, battuta di Veronica
> Hai visto!? È così che si fa a superare ogni limite!!!
>
> →

**`CRE.veronica.allenamento4.dopo3`** · allenamento, passo 4 (OGGETTO) — dopo che hai agito, battuta di Anonimo
> Forse dovresti curarti...
>
> →

**`CRE.veronica.allenamento4.dopo4`** · allenamento, passo 4 (OGGETTO) — dopo che hai agito, battuta di Veronica
> Curarmi? E perché... piuttosto preparati...
>
> →

**`CRE.veronica.allenamento_finale1`** · allenamento, la scena che lo chiude — narrazione
> Veronica scatena il suo attacco speciale: Meteora di Atlante. Non c'è modo di schivarla.
>
> →

**`CRE.veronica.allenamento_finale2`** · allenamento, la scena che lo chiude — notifica
> Sei stato messo KO.
>
> →

**`CRE.veronica.allenamento_finale3`** · allenamento, la scena che lo chiude — battuta di Veronica
> ... Ho esagerato di nuovo... Ma al massimo della potenza!
>
> →


### Dott.ssa Curie Heartlife  <sub>`curie`</sub>

**`CRE.curie.nome`** · nome a schermo
> Dott.ssa Curie Heartlife
>
> →


### ??? (Organizzazione)  <sub>`figura_misteriosa`</sub>

**`CRE.figura_misteriosa.nome`** · nome a schermo
> ??? (Organizzazione)
>
> →


# 5. I personaggi giocabili

<sub>`data/classes.json`</sub>


### Anonimo  <sub>`anonimo`</sub>

**`CLA.anonimo.nome`** · nome a schermo
> Anonimo
>
> →


### Yhvina  <sub>`insonne`</sub>

**`CLA.insonne.nome`** · nome a schermo
> Yhvina
>
> →


### Sally  <sub>`sally`</sub>

**`CLA.sally.nome`** · nome a schermo
> Sally
>
> →


### Vega  <sub>`vega`</sub>

**`CLA.vega.nome`** · nome a schermo
> Vega
>
> →


### Niru  <sub>`niru`</sub>

**`CLA.niru.nome`** · nome a schermo
> Niru
>
> →


### Fio  <sub>`fio`</sub>

**`CLA.fio.nome`** · nome a schermo
> Fio
>
> →


### Rio  <sub>`rio`</sub>

**`CLA.rio.nome`** · nome a schermo
> Rio
>
> →


### Bero  <sub>`bero`</sub>

**`CLA.bero.nome`** · nome a schermo
> Bero
>
> →


### Mockingbear  <sub>`mockingbear`</sub>

**`CLA.mockingbear.nome`** · nome a schermo
> Mockingbear
>
> →


### Mr. Eto  <sub>`mr_eto`</sub>

**`CLA.mr_eto.nome`** · nome a schermo
> Mr. Eto
>
> →


### Yara  <sub>`sopravvissuta`</sub>

**`CLA.sopravvissuta.nome`** · nome a schermo
> Yara
>
> →


### Il Vecchio Proprietario del teatro  <sub>`vecchio_clown`</sub>

**`CLA.vecchio_clown.nome`** · nome a schermo
> Il Vecchio Proprietario del teatro
>
> →


# 6. Gli oggetti

<sub>`data/oggetti.json`</sub>


### Razione da viaggio  <sub>`razione_del_circo`</sub>

**`OGG.razione_del_circo.nome`** · nome nella sacca e nei negozi
> Razione da viaggio
>
> →

**`OGG.razione_del_circo.descrizione`** · descrizione (per gli oggetti chiave si legge raccogliendoli)
> Carne secca e datteri pressati, roba da traversata nel deserto. Rimette in piedi.
>
> →


### Tonico calmante  <sub>`tonico_calmante`</sub>

**`OGG.tonico_calmante.nome`** · nome nella sacca e nei negozi
> Tonico calmante
>
> →

**`OGG.tonico_calmante.descrizione`** · descrizione (per gli oggetti chiave si legge raccogliendoli)
> Distillato dall'Organizzazione. Allontana il confine per un po'.
>
> →


### Petardo  <sub>`petardo`</sub>

**`OGG.petardo.nome`** · nome nella sacca e nei negozi
> Petardo
>
> →

**`OGG.petardo.descrizione`** · descrizione (per gli oggetti chiave si legge raccogliendoli)
> Del vecchio spettacolo pirotecnico. Ignora le difese.
>
> →


### Premio di pezza  <sub>`premio_di_pezza`</sub>

**`OGG.premio_di_pezza.nome`** · nome nella sacca e nei negozi
> Premio di pezza
>
> →

**`OGG.premio_di_pezza.descrizione`** · descrizione (per gli oggetti chiave si legge raccogliendoli)
> Vinto al tiro a segno. Abbracciarlo guarisce più del previsto.
>
> →


### Lente di Nyu  <sub>`lente_di_nyu`</sub>

**`OGG.lente_di_nyu.nome`** · nome nella sacca e nei negozi
> Lente di Nyu
>
> →

**`OGG.lente_di_nyu.descrizione`** · descrizione (per gli oggetti chiave si legge raccogliendoli)
> Mostra alla fonte quello che non vuole vedere: una via d'uscita.
>
> →


### Caramella di Nyu  <sub>`caramella_di_nyu`</sub>

**`OGG.caramella_di_nyu.nome`** · nome nella sacca e nei negozi
> Caramella di Nyu
>
> →

**`OGG.caramella_di_nyu.descrizione`** · descrizione (per gli oggetti chiave si legge raccogliendoli)
> Sa di un ricordo bello. Di chi, non si sa.
>
> →


### Cuore di latta  <sub>`cuore_di_latta`</sub>

**`OGG.cuore_di_latta.nome`** · nome nella sacca e nei negozi
> Cuore di latta
>
> →

**`OGG.cuore_di_latta.descrizione`** · descrizione (per gli oggetti chiave si legge raccogliendoli)
> Battuto a mano dall'Artigiano. Batte davvero, se serve.
>
> →


### Specchio tascabile  <sub>`specchio_tascabile`</sub>

**`OGG.specchio_tascabile.nome`** · nome nella sacca e nei negozi
> Specchio tascabile
>
> →

**`OGG.specchio_tascabile.descrizione`** · descrizione (per gli oggetti chiave si legge raccogliendoli)
> Forgiato dalle schegge del padiglione. Riflette il male al mittente.
>
> →


### Fiala HP  <sub>`fiala_hp`</sub>

**`OGG.fiala_hp.nome`** · nome nella sacca e nei negozi
> Fiala HP
>
> →

**`OGG.fiala_hp.descrizione`** · descrizione (per gli oggetti chiave si legge raccogliendoli)
> Liquido rosso in vetro industriale. L'etichetta è sbiadita, l'effetto no.
>
> →


### Bomba artigianale  <sub>`bomba_artigianale`</sub>

**`OGG.bomba_artigianale.nome`** · nome nella sacca e nei negozi
> Bomba artigianale
>
> →

**`OGG.bomba_artigianale.descrizione`** · descrizione (per gli oggetti chiave si legge raccogliendoli)
> Messa insieme con quello che c'era nei cunicoli. Yara ne teneva sempre una addosso: non per combattere, per non farsi prendere viva.
>
> →


### Bomba al nitro  <sub>`bomba_al_nitro`</sub>

**`OGG.bomba_al_nitro.nome`** · nome nella sacca e nei negozi
> Bomba al nitro
>
> →

**`OGG.bomba_al_nitro.descrizione`** · descrizione (per gli oggetti chiave si legge raccogliendoli)
> Instabile, rumorosa, sproporzionata. Veronica ne tiene una scatola intera ai campi di addestramento.
>
> →


### Molotov  <sub>`molotov`</sub>

**`OGG.molotov.nome`** · nome nella sacca e nei negozi
> Molotov
>
> →

**`OGG.molotov.descrizione`** · descrizione (per gli oggetti chiave si legge raccogliendoli)
> Assemblata da qualcuno che non è sopravvissuto per lanciarla.
>
> →


### Benzina  <sub>`benzina`</sub>

**`OGG.benzina.nome`** · nome nella sacca e nei negozi
> Benzina
>
> →

**`OGG.benzina.descrizione`** · descrizione (per gli oggetti chiave si legge raccogliendoli)
> Una tanica mezza piena. L'odore copre perfino la ruggine.
>
> →


### Misterioso componente elettronico  <sub>`componente_elettronico`</sub>

**`OGG.componente_elettronico.nome`** · nome nella sacca e nei negozi
> Misterioso componente elettronico
>
> →

**`OGG.componente_elettronico.descrizione`** · descrizione (per gli oggetti chiave si legge raccogliendoli)
> Emette un segnale debole, a intervalli regolari, verso il cielo.
>
> →


### Viti e bulloni  <sub>`viti_e_bulloni`</sub>

**`OGG.viti_e_bulloni.nome`** · nome nella sacca e nei negozi
> Viti e bulloni
>
> →

**`OGG.viti_e_bulloni.descrizione`** · descrizione (per gli oggetti chiave si legge raccogliendoli)
> Un pugno di minuteria. All'Artigiano potrebbe interessare.
>
> →


### Copia di uno strano biglietto  <sub>`biglietto_strano`</sub>

**`OGG.biglietto_strano.nome`** · nome nella sacca e nei negozi
> Copia di uno strano biglietto
>
> →

**`OGG.biglietto_strano.descrizione`** · descrizione (per gli oggetti chiave si legge raccogliendoli)
> Un biglietto di ottima fattura per uno spettacolo di alta classe, non ci sono molte informazioni...
>
> →


### Prova di un forte amore  <sub>`prova_di_un_forte_amore`</sub>

**`OGG.prova_di_un_forte_amore.nome`** · nome nella sacca e nei negozi
> Prova di un forte amore
>
> →

**`OGG.prova_di_un_forte_amore.descrizione`** · descrizione (per gli oggetti chiave si legge raccogliendoli)
> Un pezzo di stoffa con una firma sopra "Lylloh" e alcuni cuoricini disegnati, sembrerebbe che un bambino abbia scritto questo.
>
> →


### Spilla a margherita  <sub>`spilla_margherita`</sub>

**`OGG.spilla_margherita.nome`** · nome nella sacca e nei negozi
> Spilla a margherita
>
> →

**`OGG.spilla_margherita.descrizione`** · descrizione (per gli oggetti chiave si legge raccogliendoli)
> Una piccola spilla a forma di margherita, nascosta sotto una piastrella della Casa Gigante. Qualcuno l'ha messa lì perché non venisse trovata.
>
> →


### Pacco di merendine scadute  <sub>`merendine_scadute`</sub>

**`OGG.merendine_scadute.nome`** · nome nella sacca e nei negozi
> Pacco di merendine scadute
>
> →

**`OGG.merendine_scadute.descrizione`** · descrizione (per gli oggetti chiave si legge raccogliendoli)
> La data è illeggibile da anni. Curano lo stesso, in un certo senso.
>
> →


### Vino di ottima qualità  <sub>`vino_di_ottima_qualita`</sub>

**`OGG.vino_di_ottima_qualita.nome`** · nome nella sacca e nei negozi
> Vino di ottima qualità
>
> →

**`OGG.vino_di_ottima_qualita.descrizione`** · descrizione (per gli oggetti chiave si legge raccogliendoli)
> Un'annata che qualcuno teneva per un'occasione speciale, mai arrivata.
>
> →


### Collana particolare  <sub>`collana_particolare`</sub>

**`OGG.collana_particolare.nome`** · nome nella sacca e nei negozi
> Collana particolare
>
> →

**`OGG.collana_particolare.descrizione`** · descrizione (per gli oggetti chiave si legge raccogliendoli)
> Pesante, di una foggia che non si vede più. Non sembra fatta per essere indossata da una bambina.
>
> →


### Un'anima inquieta  <sub>`anima_inquieta`</sub>

**`OGG.anima_inquieta.nome`** · nome nella sacca e nei negozi
> Un'anima inquieta
>
> →

**`OGG.anima_inquieta.descrizione`** · descrizione (per gli oggetti chiave si legge raccogliendoli)
> Non trova pace e non sa perché. Vibra piano, come se cercasse una direzione. Uno dei pezzi della Fontana.
>
> →


### Dei ricordi felici  <sub>`ricordi_felici`</sub>

**`OGG.ricordi_felici.nome`** · nome nella sacca e nei negozi
> Dei ricordi felici
>
> →

**`OGG.ricordi_felici.descrizione`** · descrizione (per gli oggetti chiave si legge raccogliendoli)
> Piccoli, caldi, quasi imbarazzanti da quanto sono semplici. Uno dei pezzi della Fontana.
>
> →


### La volontà di un fabbro  <sub>`volonta_di_un_fabbro`</sub>

**`OGG.volonta_di_un_fabbro.nome`** · nome nella sacca e nei negozi
> La volontà di un fabbro
>
> →

**`OGG.volonta_di_un_fabbro.descrizione`** · descrizione (per gli oggetti chiave si legge raccogliendoli)
> Chi la portava batteva il ferro finché non diceva la verità. Uno dei pezzi della Fontana.
>
> →


### Un cuore di disallineamento  <sub>`cuore_di_carnivalz`</sub>

**`OGG.cuore_di_carnivalz.nome`** · nome nella sacca e nei negozi
> Un cuore di disallineamento
>
> →

**`OGG.cuore_di_carnivalz.descrizione`** · descrizione (per gli oggetti chiave si legge raccogliendoli)
> Batte ancora, di quel battito sbagliato che deforma i mondi. Uno dei pezzi della Fontana.
>
> →


### Lanterna che pulsa  <sub>`lanterna_che_pulsa`</sub>

**`OGG.lanterna_che_pulsa.nome`** · nome nella sacca e nei negozi
> Lanterna che pulsa
>
> →

**`OGG.lanterna_che_pulsa.descrizione`** · descrizione (per gli oggetti chiave si legge raccogliendoli)
> Spenta, eppure pulsa come un cuore. Vuole tornare da qualcuno.
>
> →


### Medaglia della vecchia plaza  <sub>`medaglia_del_vecchio_circo`</sub>

**`OGG.medaglia_del_vecchio_circo.nome`** · nome nella sacca e nei negozi
> Medaglia della vecchia plaza
>
> →

**`OGG.medaglia_del_vecchio_circo.descrizione`** · descrizione (per gli oggetti chiave si legge raccogliendoli)
> Il premio della sua prima corrida, quando ancora ballava per fame. Incisa con un nome che non riesci a leggere. Jerah sì.
>
> →


### Scheggia di specchio  <sub>`scheggia_di_specchio`</sub>

**`OGG.scheggia_di_specchio.nome`** · nome nella sacca e nei negozi
> Scheggia di specchio
>
> →

**`OGG.scheggia_di_specchio.descrizione`** · descrizione (per gli oggetti chiave si legge raccogliendoli)
> Dentro c'è ancora il riflesso di un mondo che non esiste più.
>
> →


### Bottone dorato  <sub>`bottone_dorato`</sub>

**`OGG.bottone_dorato.nome`** · nome nella sacca e nei negozi
> Bottone dorato
>
> →

**`OGG.bottone_dorato.descrizione`** · descrizione (per gli oggetti chiave si legge raccogliendoli)
> Del primo costume di Jerah. Il Vecchio Proprietario del teatro lo custodiva da sempre.
>
> →


### Rottame di metallo  <sub>`rottame_di_metallo`</sub>

**`OGG.rottame_di_metallo.nome`** · nome nella sacca e nei negozi
> Rottame di metallo
>
> →

**`OGG.rottame_di_metallo.descrizione`** · descrizione (per gli oggetti chiave si legge raccogliendoli)
> Un pezzo contorto, strappato via da qualcosa di più grande. Ha i bordi ancora caldi, come se fosse stato masticato.
>
> →


### Convertitore  <sub>`convertitore`</sub>

**`OGG.convertitore.nome`** · nome nella sacca e nei negozi
> Convertitore
>
> →

**`OGG.convertitore.descrizione`** · descrizione (per gli oggetti chiave si legge raccogliendoli)
> Un nucleo metallico che il Divoratore teneva al posto di un cuore. Trasforma tutto ciò che tocca in qualcos'altro.
>
> →


### Il mondo è il mio Tesoro  <sub>`il_mondo_e_il_mio_tesoro`</sub>

**`OGG.il_mondo_e_il_mio_tesoro.nome`** · nome nella sacca e nei negozi
> Il mondo è il mio Tesoro
>
> →

**`OGG.il_mondo_e_il_mio_tesoro.descrizione`** · descrizione (per gli oggetti chiave si legge raccogliendoli)
> Un'arma forgiata dall'Artigiano su un nucleo che divora e restituisce doppio. Finché la porti con te, ogni nemico sconfitto rende di più: più bottino, più chance di drop rari.
>
> →


### Pergamene incomprensibili  <sub>`pergamene_incomprensibili`</sub>

**`OGG.pergamene_incomprensibili.nome`** · nome nella sacca e nei negozi
> Pergamene incomprensibili
>
> →

**`OGG.pergamene_incomprensibili.descrizione`** · descrizione (per gli oggetti chiave si legge raccogliendoli)
> Una scrittura che nessuno, su nessun pianeta che conosci, saprebbe leggere. Eppure qualcosa, guardandola, si muove nello stomaco.
>
> →


### Ciondolo del grande viaggio  <sub>`ciondolo_del_grande_viaggio`</sub>

**`OGG.ciondolo_del_grande_viaggio.nome`** · nome nella sacca e nei negozi
> Ciondolo del grande viaggio
>
> →

**`OGG.ciondolo_del_grande_viaggio.descrizione`** · descrizione (per gli oggetti chiave si legge raccogliendoli)
> Strappato al sacerdote folle della sala del lamento. È caldo al tatto, come se qualcosa, dentro, fosse ancora acceso.
>
> →


### Infuso antico  <sub>`infuso_antico`</sub>

**`OGG.infuso_antico.nome`** · nome nella sacca e nei negozi
> Infuso antico
>
> →

**`OGG.infuso_antico.descrizione`** · descrizione (per gli oggetti chiave si legge raccogliendoli)
> Un infuso di radici che non crescono più da nessuna parte, trovato ancora sigillato in un cargo abbandonato. Calma anche i pensieri più insistenti.
>
> →


### Gel Omega  <sub>`omega_gel`</sub>

**`OGG.omega_gel.nome`** · nome nella sacca e nei negozi
> Gel Omega
>
> →

**`OGG.omega_gel.descrizione`** · descrizione (per gli oggetti chiave si legge raccogliendoli)
> Un gel industriale, denso e freddo. Irrigidisce la pelle a contatto e neutralizza qualunque cosa ti stia già avvelenando il sangue.
>
> →


### Bastone  <sub>`bastone`</sub>

**`OGG.bastone.nome`** · nome nella sacca e nei negozi
> Bastone
>
> →

**`OGG.bastone.descrizione`** · descrizione (per gli oggetti chiave si legge raccogliendoli)
> Un pezzo di legno qualsiasi, tenuto per anni vicino alla porta per un motivo che ora sembra ovvio.
>
> →


### Spranga di ferro  <sub>`spranga_di_ferro`</sub>

**`OGG.spranga_di_ferro.nome`** · nome nella sacca e nei negozi
> Spranga di ferro
>
> →

**`OGG.spranga_di_ferro.descrizione`** · descrizione (per gli oggetti chiave si legge raccogliendoli)
> Pesante, fredda, coperta di una ruggine che non viene via. Ignora le difese.
>
> →


### Mazzafrusto  <sub>`mazzafrusto`</sub>

**`OGG.mazzafrusto.nome`** · nome nella sacca e nei negozi
> Mazzafrusto
>
> →

**`OGG.mazzafrusto.descrizione`** · descrizione (per gli oggetti chiave si legge raccogliendoli)
> Improvvisato con catena e un lucchetto. Chi l'ha costruito non aveva molto tempo, e si vede.
>
> →


### Sparachiodi arrugginito  <sub>`sparachiodi_arrugginito`</sub>

**`OGG.sparachiodi_arrugginito.nome`** · nome nella sacca e nei negozi
> Sparachiodi arrugginito
>
> →

**`OGG.sparachiodi_arrugginito.descrizione`** · descrizione (per gli oggetti chiave si legge raccogliendoli)
> Da cantiere, non da difesa personale. Funziona lo stesso, se lo tieni ben saldo.
>
> →


### Motosega  <sub>`motosega`</sub>

**`OGG.motosega.nome`** · nome nella sacca e nei negozi
> Motosega
>
> →

**`OGG.motosega.descrizione`** · descrizione (per gli oggetti chiave si legge raccogliendoli)
> Il serbatoio ha ancora qualche strappo di vita. Rumorosa, definitiva, difficile da trovare intatta.
>
> →


### Pagina di giornale (prima)  <sub>`pagina_di_giornale_1`</sub>

**`OGG.pagina_di_giornale_1.nome`** · nome nella sacca e nei negozi
> Pagina di giornale (prima)
>
> →

**`OGG.pagina_di_giornale_1.descrizione`** · descrizione (per gli oggetti chiave si legge raccogliendoli)
> Cronaca locale di Meridia, data illeggibile. In fondo alla pagina, un trafiletto: 'Comportamenti anomali in aumento, dicono le autorità: nulla di cui preoccuparsi.'
>
> →


### Pagina di giornale (seconda)  <sub>`pagina_di_giornale_2`</sub>

**`OGG.pagina_di_giornale_2.nome`** · nome nella sacca e nei negozi
> Pagina di giornale (seconda)
>
> →

**`OGG.pagina_di_giornale_2.descrizione`** · descrizione (per gli oggetti chiave si legge raccogliendoli)
> Titolo a caratteri cubitali: 'COPRIFUOCO OBBLIGATORIO. OSPEDALI AL COLLASSO.' Un articolo più piccolo parla di 'episodi di aggressività di massa, causa sconosciuta'.
>
> →


### Pagina di giornale (ultima)  <sub>`pagina_di_giornale_3`</sub>

**`OGG.pagina_di_giornale_3.nome`** · nome nella sacca e nei negozi
> Pagina di giornale (ultima)
>
> →

**`OGG.pagina_di_giornale_3.descrizione`** · descrizione (per gli oggetti chiave si legge raccogliendoli)
> L'ultima edizione mai stampata di Meridia. Metà pagina è vuota: chi la componeva non ha fatto in tempo a finirla. Le parole rimaste dicono solo: 'evacuare subito, non fer'.
>
> →


### Fiore di luna  <sub>`fiore_di_luna`</sub>

**`OGG.fiore_di_luna.nome`** · nome nella sacca e nei negozi
> Fiore di luna
>
> →

**`OGG.fiore_di_luna.descrizione`** · descrizione (per gli oggetti chiave si legge raccogliendoli)
> Un fiore comune, usato per trattare lievi infezioni o avvelenamenti. Oltre a essere bello, può anche essere molto utile.
>
> →


### Diserbante dei vivai  <sub>`diserbante`</sub>

**`OGG.diserbante.nome`** · nome nella sacca e nei negozi
> Diserbante dei vivai
>
> →

**`OGG.diserbante.descrizione`** · descrizione (per gli oggetti chiave si legge raccogliendoli)
> Una tanica dai laboratori della magione: «uso interno — contenimento vivai». Sviluppato dai capi ricerca per fermare quello che coltivavano, nel caso qualcuno avesse perso il controllo. Qualcuno l'ha perso.
>
> →


### Matrice di accesso  <sub>`matrice`</sub>

**`OGG.matrice.nome`** · nome nella sacca e nei negozi
> Matrice di accesso
>
> →

**`OGG.matrice.descrizione`** · descrizione (per gli oggetti chiave si legge raccogliendoli)
> Una piastrina mai assegnata a nessuno, presa dalla sala delle matrici. Da sola apre solo un messaggio di errore: le manca il chip di identificazione di chi dovrebbe portarla.
>
> →


### ID della capofamiglia  <sub>`id_card`</sub>

**`OGG.id_card.nome`** · nome nella sacca e nei negozi
> ID della capofamiglia
>
> →

**`OGG.id_card.descrizione`** · descrizione (per gli oggetti chiave si legge raccogliendoli)
> Il chip di identificazione della padrona di casa, trovato in fondo al vivaio, coperto di piccole piante. Con una matrice, apre tutto quello che lei poteva aprire.
>
> →


### Diari di ricerca  <sub>`diari_di_ricerca`</sub>

**`OGG.diari_di_ricerca.nome`** · nome nella sacca e nei negozi
> Diari di ricerca
>
> →

**`OGG.diari_di_ricerca.descrizione`** · descrizione (per gli oggetti chiave si legge raccogliendoli)
> I quaderni della capo ricerca dei giardini: anni di medicinali a basso costo per i pianeti più poveri, e poi, senza che nulla lo annunci, le prime pagine sui veleni.
>
> →


### Fiala misteriosa  <sub>`fiala_misteriosa`</sub>

**`OGG.fiala_misteriosa.nome`** · nome nella sacca e nei negozi
> Fiala misteriosa
>
> →

**`OGG.fiala_misteriosa.descrizione`** · descrizione (per gli oggetti chiave si legge raccogliendoli)
> Una fiala da laboratorio... ha ancora della sostanza incrostata sulle pareti interne. Da consegnare all'Organizzazione per l'analisi.
>
> →


### Meccanismo del varco  <sub>`meccanismo_del_varco`</sub>

**`OGG.meccanismo_del_varco.nome`** · nome nella sacca e nei negozi
> Meccanismo del varco
>
> →

**`OGG.meccanismo_del_varco.descrizione`** · descrizione (per gli oggetti chiave si legge raccogliendoli)
> Ingranaggi antichi, delle stesse dimensioni esatte della serratura sulla porta enorme nella Casa Gigante. Non l'hai ancora trovato: si dice che esista solo molto più avanti, nel tuo viaggio.
>
> →


### Bottiglia di liquore  <sub>`bottiglia_di_liquore`</sub>

**`OGG.bottiglia_di_liquore.nome`** · nome nella sacca e nei negozi
> Bottiglia di liquore
>
> →

**`OGG.bottiglia_di_liquore.descrizione`** · descrizione (per gli oggetti chiave si legge raccogliendoli)
> Il Vecchio Proprietario del teatro non viaggia mai senza scorta. Un sorso basta a schiarire i pensieri.
>
> →


### Pietra Quieta  <sub>`pietra_quieta`</sub>

**`OGG.pietra_quieta.nome`** · nome nella sacca e nei negozi
> Pietra Quieta
>
> →

**`OGG.pietra_quieta.descrizione`** · descrizione (per gli oggetti chiave si legge raccogliendoli)
> Una pietra liscia e fredda, lasciata cadere da una tartaruga che hai scelto di risparmiare. Sembra assorbire la prima cosa brutta che ti capita, in ogni scontro.
>
> →


### Ricordo del Passato  <sub>`ricordo_del_passato`</sub>

**`OGG.ricordo_del_passato.nome`** · nome nella sacca e nei negozi
> Ricordo del Passato
>
> →

**`OGG.ricordo_del_passato.descrizione`** · descrizione (per gli oggetti chiave si legge raccogliendoli)
> Un oggetto che porta con sé il peso di qualcosa che non c'è più. Si spezza per riportarti in vita, una volta sola.
>
> →


### Benda stretta  <sub>`benda_stretta`</sub>

**`OGG.benda_stretta.nome`** · nome nella sacca e nei negozi
> Benda stretta
>
> →

**`OGG.benda_stretta.descrizione`** · descrizione (per gli oggetti chiave si legge raccogliendoli)
> Sporca, ma tiene. Rimette in piedi chi ha ancora voglia di stare in piedi.
>
> →


### Fiala d'aura  <sub>`fiala_aura`</sub>

**`OGG.fiala_aura.nome`** · nome nella sacca e nei negozi
> Fiala d'aura
>
> →

**`OGG.fiala_aura.descrizione`** · descrizione (per gli oggetti chiave si legge raccogliendoli)
> Un liquido che non sta fermo dentro il vetro. Restituisce un po' di quello che spendi quando forzi il mondo.
>
> →


### Essenza d'aura  <sub>`essenza_di_aura`</sub>

**`OGG.essenza_di_aura.nome`** · nome nella sacca e nei negozi
> Essenza d'aura
>
> →

**`OGG.essenza_di_aura.descrizione`** · descrizione (per gli oggetti chiave si legge raccogliendoli)
> La stessa cosa della fiala, distillata più a lungo. Costa di più e vale di più.
>
> →


### Sale amaro  <sub>`sale_amaro`</sub>

**`OGG.sale_amaro.nome`** · nome nella sacca e nei negozi
> Sale amaro
>
> →

**`OGG.sale_amaro.descrizione`** · descrizione (per gli oggetti chiave si legge raccogliendoli)
> Brucia in gola e sveglia i morti. Toglie di dosso il sonno, e solo quello.
>
> →


### Carbone attivo  <sub>`carbone_attivo`</sub>

**`OGG.carbone_attivo.nome`** · nome nella sacca e nei negozi
> Carbone attivo
>
> →

**`OGG.carbone_attivo.descrizione`** · descrizione (per gli oggetti chiave si legge raccogliendoli)
> Nero, gessoso, disgustoso. Assorbe il veleno prima che finisca il suo lavoro.
>
> →


### Amuleto di pietra  <sub>`amuleto_di_pietra`</sub>

**`OGG.amuleto_di_pietra.nome`** · nome nella sacca e nei negozi
> Amuleto di pietra
>
> →

**`OGG.amuleto_di_pietra.descrizione`** · descrizione (per gli oggetti chiave si legge raccogliendoli)
> Grezzo, pesante al collo. Chi lo porta incassa un po' meglio.
>
> →


### Amuleto di ferro  <sub>`amuleto_di_ferro`</sub>

**`OGG.amuleto_di_ferro.nome`** · nome nella sacca e nei negozi
> Amuleto di ferro
>
> →

**`OGG.amuleto_di_ferro.descrizione`** · descrizione (per gli oggetti chiave si legge raccogliendoli)
> Una scheggia di lama montata su uno spago. Rende i colpi un po' più cattivi.
>
> →


### Amuleto di vento  <sub>`amuleto_di_vento`</sub>

**`OGG.amuleto_di_vento.nome`** · nome nella sacca e nei negozi
> Amuleto di vento
>
> →

**`OGG.amuleto_di_vento.descrizione`** · descrizione (per gli oggetti chiave si legge raccogliendoli)
> Leggerissimo, non sta mai fermo. Chi lo porta arriva prima.
>
> →


### Amuleto di cenere  <sub>`amuleto_di_cenere`</sub>

**`OGG.amuleto_di_cenere.nome`** · nome nella sacca e nei negozi
> Amuleto di cenere
>
> →

**`OGG.amuleto_di_cenere.descrizione`** · descrizione (per gli oggetti chiave si legge raccogliendoli)
> Cenere di qualcosa che è stato maledetto prima di te, e che ha resistito un momento in più.
>
> →


### Coltello di servizio  <sub>`coltello_di_servizio`</sub>

**`OGG.coltello_di_servizio.nome`** · nome nella sacca e nei negozi
> Coltello di servizio
>
> →

**`OGG.coltello_di_servizio.descrizione`** · descrizione (per gli oggetti chiave si legge raccogliendoli)
> In dotazione a ogni operativo. Nessuno l'ha mai chiamato un'arma.
>
> →


### Mannaia scheggiata  <sub>`mannaia_scheggiata`</sub>

**`OGG.mannaia_scheggiata.nome`** · nome nella sacca e nei negozi
> Mannaia scheggiata
>
> →

**`OGG.mannaia_scheggiata.descrizione`** · descrizione (per gli oggetti chiave si legge raccogliendoli)
> Pesante e mal bilanciata: colpisce più forte, ma ti rallenta.
>
> →


### Stigma del veglio  <sub>`stigma_del_veglio`</sub>

**`OGG.stigma_del_veglio.nome`** · nome nella sacca e nei negozi
> Stigma del veglio
>
> →

**`OGG.stigma_del_veglio.descrizione`** · descrizione (per gli oggetti chiave si legge raccogliendoli)
> Un marchio che non ti lascia dormire. L'aura si rigenera più in fretta, ma il corpo regge meno.
>
> →


### Stigma del muto  <sub>`stigma_del_muto`</sub>

**`OGG.stigma_del_muto.nome`** · nome nella sacca e nei negozi
> Stigma del muto
>
> →

**`OGG.stigma_del_muto.descrizione`** · descrizione (per gli oggetti chiave si legge raccogliendoli)
> Chi lo porta non urla mai. Incassa meglio, ma colpisce peggio.
>
> →


### Spazio nella realtà  <sub>`spazio_nella_realta`</sub>

**`OGG.spazio_nella_realta.nome`** · nome nella sacca e nei negozi
> Spazio nella realtà
>
> →

**`OGG.spazio_nella_realta.descrizione`** · descrizione (per gli oggetti chiave si legge raccogliendoli)
> Una piega vuota che si porta in tasca. Non pesa, e dentro ci sta altro.
>
> →


### Frammento — rastrelliera  <sub>`frammento_per_le_armi`</sub>

**`OGG.frammento_per_le_armi.nome`** · nome nella sacca e nei negozi
> Frammento — rastrelliera
>
> →

**`OGG.frammento_per_le_armi.descrizione`** · descrizione (per gli oggetti chiave si legge raccogliendoli)
> Ganci che non esistono, appesi a un muro che non c'è. Ci si appende del ferro vero.
>
> →


### Frammento — vassoio  <sub>`frammento_per_gli_accessori`</sub>

**`OGG.frammento_per_gli_accessori.nome`** · nome nella sacca e nei negozi
> Frammento — vassoio
>
> →

**`OGG.frammento_per_gli_accessori.descrizione`** · descrizione (per gli oggetti chiave si legge raccogliendoli)
> Un ripiano sottile piegato dentro una tasca. Le cose piccole non si perdono più.
>
> →


# 7. Gli stati

<sub>`data/stati.json`</sub> — avvelenato, terrore, e compagnia.

**`STA.veleno.nome`** · nome dello stato
> Veleno
>
> →

**`STA.veleno.testo_turno`** · a ogni turno che dura
> Il veleno si diffonde: peggiora ancora.
>
> →

**`STA.decomposizione.nome`** · nome dello stato
> Decomposizione
>
> →

**`STA.decomposizione.testo_turno`** · a ogni turno che dura
> La decomposizione avanza, punita da ogni colpo sferrato.
>
> →

**`STA.congelamento.nome`** · nome dello stato
> Congelamento
>
> →

**`STA.sonno.nome`** · nome dello stato
> Sonno
>
> →

**`STA.egocentrismo.nome`** · nome dello stato
> Egocentrismo
>
> →

**`STA.demotivazione.nome`** · nome dello stato
> Demotivazione
>
> →

**`STA.berserk.nome`** · nome dello stato
> Berserk
>
> →

**`STA.confusione.nome`** · nome dello stato
> Confusione
>
> →

**`STA.rapidita.nome`** · nome dello stato
> Rapidità
>
> →

**`STA.lentezza.nome`** · nome dello stato
> Lentezza
>
> →

**`STA.maledizione.nome`** · nome dello stato
> Maledizione
>
> →

**`STA.terrore.nome`** · nome dello stato
> Terrore
>
> →


# 8. Crescita: statistiche e abilità passive

<sub>`data/crescita.json`</sub> — i nomi che si leggono nel Diario.

**`CRES.stat.hp`** · nome di una statistica
> Punti vita
>
> →

**`CRES.stat.attacco`** · nome di una statistica
> Attacco
>
> →

**`CRES.stat.difesa`** · nome di una statistica
> Difesa
>
> →

**`CRES.stat.velocita`** · nome di una statistica
> Velocità
>
> →

**`CRES.stat.intelligenza`** · nome di una statistica
> Intelligenza
>
> →

**`CRES.stat.intelligenza.desc`** · descrizione della statistica
> Aumenta la probabilità di fuggire.
>
> →

**`CRES.stat.forza_mentale`** · nome di una statistica
> Forza mentale
>
> →

**`CRES.stat.forza_mentale.desc`** · descrizione della statistica
> Resistenza allo stress.
>
> →

**`CRES.stat.fattore`** · nome di una statistica
> Fattore Carnivalz
>
> →

**`CRES.stat.fattore.desc`** · descrizione della statistica
> Aumenta la probabilità di critici e di Slaughter.
>
> →

**`CRES.non_ce_tempo.nome`** · nome di un'abilità passiva
> Non c'è tempo!
>
> →

**`CRES.non_ce_tempo.desc`** · cosa fa l'abilità passiva
> Randomicamente raddoppi la tua velocità, solo nel primo turno.
>
> →

**`CRES.immondizia_tesoro.nome`** · nome di un'abilità passiva
> La tua immondizia è il mio tesoro
>
> →

**`CRES.immondizia_tesoro.desc`** · cosa fa l'abilità passiva
> 5% in più di drop dai nemici.
>
> →

**`CRES.battito_dell_eroe.nome`** · nome di un'abilità passiva
> Battito dell'eroe
>
> →

**`CRES.battito_dell_eroe.desc`** · cosa fa l'abilità passiva
> Sotto l'11% dei punti vita raddoppi l'attacco e azzeri lo stress, per un turno soltanto.
>
> →

**`CRES.trinita.nome`** · nome di un'abilità passiva
> Trinità
>
> →

**`CRES.trinita.desc`** · cosa fa l'abilità passiva
> Randomicamente un attacco normale diventa tre attacchi consecutivi.
>
> →

**`CRES.presenza_minacciosa.nome`** · nome di un'abilità passiva
> Presenza Minacciosa
>
> →

**`CRES.presenza_minacciosa.desc`** · cosa fa l'abilità passiva
> I nemici di livello inferiore al tuo subiscono 1 turno di terrore quando scendono sotto il 50% dei punti vita.
>
> →

**`CRES.crudelta.nome`** · nome di un'abilità passiva
> Crudeltà
>
> →

**`CRES.crudelta.desc`** · cosa fa l'abilità passiva
> Probabilità di KO istantaneo aumentata del 50% contro nemici con almeno 10 livelli in meno.
>
> →

**`CRES.illuminazione_1.nome`** · nome di un'abilità passiva
> Illuminazione parte 1
>
> →

**`CRES.illuminazione_1.desc`** · cosa fa l'abilità passiva
> Leggero aumento della probabilità di ottenere la carta del nemico.
>
> →

**`CRES.charm.nome`** · nome di un'abilità passiva
> Charm
>
> →

**`CRES.charm.desc`** · cosa fa l'abilità passiva
> Il legame con la squadra aumenta più facilmente.
>
> →

**`CRES.negazione.nome`** · nome di un'abilità passiva
> Negazione
>
> →

**`CRES.negazione.desc`** · cosa fa l'abilità passiva
> Bassa probabilità che un attacco subito venga annullato.
>
> →

**`CRES.infinito.nome`** · nome di un'abilità passiva
> Infinito
>
> →

**`CRES.infinito.desc`** · cosa fa l'abilità passiva
> Oltre il decimo turno, ogni turno che passa tutte le tue stat aumentano di 1 fino alla fine del combattimento.
>
> →

**`CRES.oltre_il_limite.nome`** · nome di un'abilità passiva
> Oltre il limite!
>
> →

**`CRES.oltre_il_limite.desc`** · cosa fa l'abilità passiva
> Tutti i nemici sotto il livello 100 iniziano con un turno di terrore.
>
> →

**`CRES.ancora_oltre_il_limite.nome`** · nome di un'abilità passiva
> Ancora una volta oltre il limite!
>
> →

**`CRES.ancora_oltre_il_limite.desc`** · cosa fa l'abilità passiva
> Sblocchi dialoghi speciali; i nemici sotto il livello 100 iniziano con due turni di terrore.
>
> →

**`CRES.tryharder.nome`** · nome di un'abilità passiva
> Tryharder
>
> →

**`CRES.tryharder.desc`** · cosa fa l'abilità passiva
> Probabilità di drop aumentata del 7%.
>
> →

**`CRES.illuminazione_2.nome`** · nome di un'abilità passiva
> Illuminazione parte 2
>
> →

**`CRES.illuminazione_2.desc`** · cosa fa l'abilità passiva
> L'aumento di probabilità di ottenere la carta del nemico diventa consistente.
>
> →

**`CRES.pressione_ultraterrena.nome`** · nome di un'abilità passiva
> Pressione ultraterrena
>
> →

**`CRES.pressione_ultraterrena.desc`** · cosa fa l'abilità passiva
> Compaiono nemici speciali benedetti da uno status divino: creature di livello 130 che hanno dominato il disallineamento e sono attratte dalla tua forza.
>
> →

**`CRES.una_nuova_alba.nome`** · nome di un'abilità passiva
> Una nuova alba
>
> →

**`CRES.una_nuova_alba.desc`** · cosa fa l'abilità passiva
> Probabilità di infliggere terrore a qualunque nemico a ogni attacco, aumentata al 33%.
>
> →

**`CRES.altruismo.nome`** · nome di un'abilità passiva
> Altruismo
>
> →

**`CRES.furia.nome`** · nome di un'abilità passiva
> Furia
>
> →

**`CRES.perspicacia_acuta.nome`** · nome di un'abilità passiva
> Perspicacia acuta
>
> →

**`CRES.leadership.nome`** · nome di un'abilità passiva
> Leadership
>
> →

**`CRES.karma_positivo.nome`** · nome di un'abilità passiva
> Karma positivo
>
> →

**`CRES.benedizione_dell_agnello.nome`** · nome di un'abilità passiva
> Benedizione dell'agnello
>
> →

**`CRES.disastro_vivente.nome`** · nome di un'abilità passiva
> Disastro vivente
>
> →

**`CRES.preferito_del_gatto.nome`** · nome di un'abilità passiva
> Preferito del gatto
>
> →


# 9. Appunti del Diario

<sub>`data/task.json`</sub> — i pensieri del protagonista su dove andare.

**`APP.vuoto_ardente.titolo`** · titolo dell'appunto
> Il Vuoto Ardente
>
> →

**`APP.vuoto_ardente.testo`** · il pensiero per esteso
> L'Organizzazione l'ha segnato sulle mie planimetrie come «punto anomalo, allineamento fuori controllo ma non in modo preoccupante». Quando parlano così vuol dire che non hanno idea di cosa ci sia dentro. Ho notato degli strani cambiamenti in quella regione... forse dovrei dare un'occhiata.
>
> →

**`APP.squarcio_industriale.titolo`** · titolo dell'appunto
> Lo Squarcio Industriale
>
> →

**`APP.squarcio_industriale.testo`** · il pensiero per esteso
> Una fabbrica che non lavora più da anni, e i rilevamenti dicono che dentro qualcosa continua a produrre. Non sono sicuro di voler sapere cosa. Ma è il primo punto sulla lista, e la lista non si accorcia da sola.
>
> →

**`APP.file_industriale.titolo`** · titolo dell'appunto
> I file dello Squarcio Industriale
>
> →

**`APP.file_industriale.testo`** · il pensiero per esteso
> In fondo ai corridoi c'è una stanza piena di schermi che riprendono chi ci entra, e un computer con dei file aperti. Ne ho lette tre pagine su sei prima che lo scontro lo mandasse in pezzi. Le altre tre sono ancora lì dentro: mi serve uno strumento capace di recuperare dei dati da una macchina bruciata.
>
> →

**`APP.mer_indagine.titolo`** · titolo dell'appunto
> Investiga il quartiere est
>
> →

**`APP.mer_indagine.testo`** · il pensiero per esteso
> Il compito è solo questo: raccogliere quanti più dati possibili nei dintorni. Ci sono varie strutture che sembrano interessanti — la strada principale, il parco, quella struttura abbandonata con le luci ancora accese. Nessuno mi ha chiesto di spingermi oltre.
>
> →

**`APP.mer_fiala.titolo`** · titolo dell'appunto
> La fiala del lago
>
> →

**`APP.mer_fiala.testo`** · il pensiero per esteso
> Una fiala da laboratorio, in mezzo a un lago prosciugato, in un parco di una città morta da anni. Ha ancora della sostanza incrostata dentro. Non so cosa sia, e non ho gli strumenti per scoprirlo qui: va consegnata all'Organizzazione perché la analizzino.
>
> →

**`APP.mer_macerie.titolo`** · titolo dell'appunto
> Sotto il quarto piano
>
> →

**`APP.mer_macerie.testo`** · il pensiero per esteso
> In fondo al garage sotterraneo, quattro piani sotto la città, il cumulo di macerie continua a scendere — e da sotto sale aria. Qualcosa, là in fondo, è aperto. A mani nude non si passa.
>
> →

**`APP.meridia.titolo`** · titolo dell'appunto
> Meridia
>
> →

**`APP.meridia.testo`** · il pensiero per esteso
> Sulla planimetria è ancora segnata come città. Dai numeri che ho davanti, città non lo è più da un pezzo — e quello che ci vive adesso non ha smesso di camminarci in mezzo.
>
> →

**`APP.jondoh.titolo`** · titolo dell'appunto
> I cunicoli di Jondoh
>
> →

**`APP.jondoh.testo`** · il pensiero per esteso
> Un pianeta minerario, e sotto il pianeta una rete di cunicoli che scende e non risale mai. Chi li ha scavati non aveva intenzione di tornare su. Comincio a farmi un'idea del perché.
>
> →

**`APP.qualcosa_preme.titolo`** · titolo dell'appunto
> Qualcosa preme
>
> →

**`APP.qualcosa_preme.testo`** · il pensiero per esteso
> C'è un punto sulla mappa che non ha un nome. Ci sono stato per un istante e mi ha rimandato indietro come si sputa un boccone. Non sono pronto, questo è chiaro. Ma prima o poi voglio sapere che cosa preme dall'altra parte.
>
> →

**`APP.yara_sorella.titolo`** · titolo dell'appunto
> La sorella di Yara
>
> →

**`APP.yara_sorella.testo`** · il pensiero per esteso
> Yara ha passato anni là sotto ad ammazzare quelle cose per una domanda sola: dov'è finita sua sorella. Non le ho promesso niente. Ma sto andando nella stessa direzione, e a differenza di lei io ho intenzione di arrivare in fondo.
>
> →

**`APP.pergamene.titolo`** · titolo dell'appunto
> Le pergamene incomprensibili
>
> →

**`APP.pergamene.testo`** · il pensiero per esteso
> Le ho raccolte nella sala del lamento e non sono scritte in niente che io riconosca. La dottoressa Heartlife passa la vita sui libri: se qualcuno può dirmi cosa c'è scritto è lei. Devo ricordarmi di portargliele quando rientro.
>
> →

**`APP.anomalia.titolo`** · titolo dell'appunto
> L'anomalia al centro del sistema
>
> →

**`APP.anomalia.testo`** · il pensiero per esteso
> Tre rilevamenti, tre posti che non avrebbero dovuto esistere. E adesso il centro del sistema si è aperto. È lì che l'allineamento sta cedendo davvero — tutto il resto era solo il rumore che fa una cosa grossa mentre si avvicina. Devo scendere.
>
> →

**`APP.teatro.titolo`** · titolo dell'appunto
> Il Teatro del Passato
>
> →

**`APP.teatro.testo`** · il pensiero per esteso
> Dopo i rilevamenti sulla planimetria sono comparsi due punti nuovi. Uno è un teatro. Un teatro che si affaccia sul Vuoto, con le luci ancora accese: vuol dire che là dentro qualcuno sta recitando per una platea che non c'è più.
>
> →

**`APP.casa_gigante.titolo`** · titolo dell'appunto
> La Casa Gigante
>
> →

**`APP.casa_gigante.testo`** · il pensiero per esteso
> E poi c'è quella casa. Le proporzioni sono sbagliate in un modo che mi dà fastidio anche solo a guardarla da fuori — come se fosse stata costruita per qualcuno che non ha mai smesso di essere bambino.
>
> →

**`APP.yhvina.titolo`** · titolo dell'appunto
> Yhvina
>
> →

**`APP.yhvina.testo`** · il pensiero per esteso
> Non voleva compagnia e non voleva parlarne, e adesso mi cammina dietro. Non le ho chiesto perché è entrata in quella casa da sola. Ma se ne esce viva, prima o poi glielo chiedo.
>
> →

**`APP.spilla.titolo`** · titolo dell'appunto
> La spilla a forma di margherita
>
> →

**`APP.spilla.testo`** · il pensiero per esteso
> Era sotto una piastrella dell'ala destra. Non è un oggetto: è una prova. Se quella cosa che vive in fondo alla casa è davvero chi comincio a sospettare, non serve colpirla — serve metterle davanti questo, e vedere se se ne ricorda.
>
> →

**`APP.casa_botola.titolo`** · titolo dell'appunto
> La botola sotto i cuscini
>
> →

**`APP.casa_botola.testo`** · il pensiero per esteso
> Sotto i cuscini della stanza dei giochi c'è una botola senza maniglia: solo una fessura e una spia che lampeggia da anni. Serve una chiave di accesso di quelle che i signori di questa casa si facevano fabbricare in proprio, e le facevano nel centro di ricerca in fondo ai giardini.
>
> →

**`APP.casa_custode.titolo`** · titolo dell'appunto
> La custode dei giardini
>
> →

**`APP.casa_custode.testo`** · il pensiero per esteso
> C'è un volto dentro la corteccia dell'albero grande, in fondo al giardino est. Innaffia le stesse piante da prima che questa casa diventasse quello che è: era capo ricerca, e l'hanno demansionata per essersi rifiutata di lavorare a quello che le chiedevano. Sa più cose di chiunque altro qui dentro, e non ha nessuna fretta di raccontarle.
>
> →

**`APP.casa_vivaio.titolo`** · titolo dell'appunto
> I rovi del vivaio
>
> →

**`APP.casa_vivaio.testo`** · il pensiero per esteso
> Il giardino nord finisce contro una muraglia viva che copre l'intero vivaio: colpirla non serve, si rigenera mentre la guardi. Nei laboratori dovrebbe esserci un diserbante sviluppato apposta, quando ancora qualcuno prevedeva che questo potesse succedere.
>
> →

**`APP.kizako.titolo`** · titolo dell'appunto
> Kizako Industries — Ala Dimenticata
>
> →

**`APP.kizako.testo`** · il pensiero per esteso
> Il nome era già sui documenti dello squarcio industriale, e adesso torna. Un'ala che qualcuno ha cancellato dalle planimetrie ufficiali: la gente cancella le cose per due motivi, o le ha dimenticate o non vuole che le si trovi.
>
> →

**`APP.fontana.titolo`** · titolo dell'appunto
> La Fontana
>
> →

**`APP.fontana.testo`** · il pensiero per esteso
> Un punto d'acqua in mezzo a un mondo che brucia. Non ha senso, e le cose che non hanno senso in questo posto di solito sono le uniche che valgono la pena di essere raggiunte.
>
> →


# 10. Nomi dei luoghi

<sub>`data/mappa.json`</sub> — quello che si legge sulla mappa stellare e nel Vuoto.

**`LUO.carnivalz_del_bosco.nome`** · nome sulla mappa stellare
> Il Vuoto Ardente
>
> →

**`LUO.carnivalz_del_bosco.tema`** · sottotitolo del mondo
> fama e spettacolo — passione, corrida, fiamme
>
> →

**`LUO.squarcio_industriale.nome`** · nome di uno squarcio
> Lo Squarcio Industriale
>
> →

**`LUO.teatro_del_passato.nome`** · nome di uno squarcio
> Il Teatro del Passato
>
> →

**`LUO.casa_gigante.nome`** · nome di uno squarcio
> La Casa Gigante
>
> →

**`LUO.rocca_ossidiana.nome`** · nome di uno squarcio
> Cunicoli sotterranei di Jondoh
>
> →

**`LUO.meridia.nome`** · nome di uno squarcio
> Meridia
>
> →

**`LUO.qualcosa_preme.nome`** · nome di uno squarcio
> Qualcosa preme
>
> →

**`LUO.kizako_ala.nome`** · nome di uno squarcio
> Kizako Industries — Ala Dimenticata
>
> →

**`LUO.fontana.nome`** · nome di uno squarcio
> La Fontana
>
> →

**`LUO.frattura_post_v5.nome`** · nome di uno squarcio
> Una crepa che pulsa
>
> →

**`LUO.carnivalz_del_porto.nome`** · nome sulla mappa stellare
> Il Carnivalz del Porto
>
> →

**`LUO.TUT.inizio`** · nome di una stanza sulla mappa della zona
> Punto d'atterraggio
>
> →

**`LUO.TUT.masso`** · nome di una stanza sulla mappa della zona
> Il masso e il ruscello
>
> →

**`LUO.TUT.bivio`** · nome di una stanza sulla mappa della zona
> Il bivio
>
> →

**`LUO.TUT.pozze`** · nome di una stanza sulla mappa della zona
> Le pozze d'acqua
>
> →

**`LUO.TUT.collina`** · nome di una stanza sulla mappa della zona
> La collina
>
> →

**`LUO.TUT.convergenza`** · nome di una stanza sulla mappa della zona
> Verso le urla
>
> →

**`LUO.OSS.varco`** · nome di una stanza sulla mappa della zona
> Il varco
>
> →

**`LUO.OSS.corridoio_ossidiana`** · nome di una stanza sulla mappa della zona
> Corridoio di ossidiana
>
> →

**`LUO.OSS.fossa_oscura`** · nome di una stanza sulla mappa della zona
> La fossa oscura
>
> →

**`LUO.OSS.sala_del_raccolto`** · nome di una stanza sulla mappa della zona
> Sala del raccolto
>
> →

**`LUO.OSS.sala_del_lamento`** · nome di una stanza sulla mappa della zona
> Sala del lamento
>
> →

**`LUO.OSS.cunicolo_1`** · nome di una stanza sulla mappa della zona
> Bivio dei cunicoli
>
> →

**`LUO.OSS.cunicolo_2`** · nome di una stanza sulla mappa della zona
> Cunicolo di sinistra
>
> →

**`LUO.OSS.piazza_sotterranea`** · nome di una stanza sulla mappa della zona
> Piazza sotterranea
>
> →

**`LUO.OSS.cunicolo_3`** · nome di una stanza sulla mappa della zona
> Cunicolo di destra
>
> →

**`LUO.OSS.cargo_abbandonato`** · nome di una stanza sulla mappa della zona
> Cargo abbandonato
>
> →

**`LUO.OSS.ponte_approccio`** · nome di una stanza sulla mappa della zona
> Il grande ponte marcio
>
> →

**`LUO.CASA.soglia`** · nome di una stanza sulla mappa della zona
> La soglia
>
> →

**`LUO.CASA.salone`** · nome di una stanza sulla mappa della zona
> Il salone
>
> →

**`LUO.CASA.sala_principale`** · nome di una stanza sulla mappa della zona
> Sala principale
>
> →

**`LUO.CASA.ala_destra`** · nome di una stanza sulla mappa della zona
> Ala destra
>
> →

**`LUO.CASA.ala_sinistra`** · nome di una stanza sulla mappa della zona
> Ala sinistra
>
> →

**`LUO.CASA.cucina`** · nome di una stanza sulla mappa della zona
> Cucina
>
> →

**`LUO.CASA.scala`** · nome di una stanza sulla mappa della zona
> La scala
>
> →

**`LUO.CASA.grande_bagno`** · nome di una stanza sulla mappa della zona
> Grande bagno
>
> →

**`LUO.CASA.stanza_giochi`** · nome di una stanza sulla mappa della zona
> Stanza dei giochi
>
> →

**`LUO.CASA.soffitta`** · nome di una stanza sulla mappa della zona
> Soffitta
>
> →

**`LUO.CASA.attico`** · nome di una stanza sulla mappa della zona
> Attico
>
> →

**`LUO.CASA.camera_da_letto`** · nome di una stanza sulla mappa della zona
> Camera da letto
>
> →

**`LUO.CASA.stanza_studi`** · nome di una stanza sulla mappa della zona
> Stanza degli studi
>
> →

**`LUO.CASA.tunnel`** · nome di una stanza sulla mappa della zona
> Il tunnel
>
> →

**`LUO.CASA.altare`** · nome di una stanza sulla mappa della zona
> L'altare
>
> →

**`LUO.CASA.giardino_ingresso`** · nome di una stanza sulla mappa della zona
> Verso i giardini
>
> →

**`LUO.CASA.giardino`** · nome di una stanza sulla mappa della zona
> Il giardino
>
> →

**`LUO.CASA.giardino_est`** · nome di una stanza sulla mappa della zona
> Giardino est
>
> →

**`LUO.CASA.albero_voce`** · nome di una stanza sulla mappa della zona
> L'albero grande
>
> →

**`LUO.CASA.giardino_ovest`** · nome di una stanza sulla mappa della zona
> Giardino ovest
>
> →

**`LUO.CASA.laboratorio`** · nome di una stanza sulla mappa della zona
> Il grande laboratorio
>
> →

**`LUO.CASA.sala_matrici`** · nome di una stanza sulla mappa della zona
> Sala delle matrici
>
> →

**`LUO.CASA.deposito_chimico`** · nome di una stanza sulla mappa della zona
> Deposito chimico
>
> →

**`LUO.CASA.giardino_nord`** · nome di una stanza sulla mappa della zona
> Giardino nord
>
> →

**`LUO.CASA.vivaio_1`** · nome di una stanza sulla mappa della zona
> Vivaio, primo piano
>
> →

**`LUO.CASA.vivaio_2`** · nome di una stanza sulla mappa della zona
> Vivaio, secondo piano
>
> →

**`LUO.CASA.vivaio_3`** · nome di una stanza sulla mappa della zona
> Fondo del vivaio
>
> →

**`LUO.IND.varco`** · nome di una stanza sulla mappa della zona
> Il varco
>
> →

**`LUO.IND.corridoi_stretti`** · nome di una stanza sulla mappa della zona
> Corridoi stretti
>
> →

**`LUO.IND.sala_vetrata`** · nome di una stanza sulla mappa della zona
> Sala vetrata
>
> →

**`LUO.IND.corridoio_tubi`** · nome di una stanza sulla mappa della zona
> Corridoio dei tubi
>
> →

**`LUO.IND.corridoi_infiniti`** · nome di una stanza sulla mappa della zona
> Corridoi infiniti
>
> →

**`LUO.IND.sala_sorveglianza`** · nome di una stanza sulla mappa della zona
> Stanza degli schermi
>
> →

**`LUO.IND.deposito`** · nome di una stanza sulla mappa della zona
> Deposito
>
> →

**`LUO.IND.sala_valvole`** · nome di una stanza sulla mappa della zona
> Sala delle valvole
>
> →

**`LUO.IND.sala_schede`** · nome di una stanza sulla mappa della zona
> Sala informatica
>
> →

**`LUO.IND.centro_controllo`** · nome di una stanza sulla mappa della zona
> Vecchio centro di controllo
>
> →

**`LUO.IND.nastro`** · nome di una stanza sulla mappa della zona
> Il nastro trasportatore
>
> →

**`LUO.IND.cuore`** · nome di una stanza sulla mappa della zona
> Cuore del complesso
>
> →

**`LUO.IND.discarica`** · nome di una stanza sulla mappa della zona
> La grande discarica
>
> →

**`LUO.IND.padiglione_e`** · nome di una stanza sulla mappa della zona
> Il Padiglione
>
> →

**`LUO.MER.varco`** · nome di una stanza sulla mappa della zona
> Il varco
>
> →

**`LUO.MER.periferia`** · nome di una stanza sulla mappa della zona
> Strade di periferia
>
> →

**`LUO.MER.ingresso_citta`** · nome di una stanza sulla mappa della zona
> Ingresso della città
>
> →

**`LUO.MER.complessi`** · nome di una stanza sulla mappa della zona
> Primi complessi
>
> →

**`LUO.MER.struttura`** · nome di una stanza sulla mappa della zona
> Struttura abbandonata
>
> →

**`LUO.MER.parco`** · nome di una stanza sulla mappa della zona
> Il parco
>
> →

**`LUO.MER.strada_principale`** · nome di una stanza sulla mappa della zona
> Strada principale
>
> →

**`LUO.MER.supermercato`** · nome di una stanza sulla mappa della zona
> Supermercato
>
> →

**`LUO.MER.officina`** · nome di una stanza sulla mappa della zona
> Officina
>
> →

**`LUO.MER.edicola`** · nome di una stanza sulla mappa della zona
> Edicola
>
> →

**`LUO.MER.vicolo`** · nome di una stanza sulla mappa della zona
> Vicolo sul retro
>
> →

**`LUO.MER.quartieri_profondi`** · nome di una stanza sulla mappa della zona
> Quartieri profondi
>
> →


# 11. Negozi

<sub>`data/negozi.json`</sub>

**`NEG.organizzazione.nome`** · nome del negozio
> Emporio dell'Organizzazione
>
> →

**`NEG.organizzazione.descrizione`** · descrizione
> Equipaggiamento standard per operativi. Prezzi calmierati, anima zero.
>
> →

**`NEG.nyu.nome`** · nome del negozio
> Il negozio di Nyu
>
> →

**`NEG.nyu.descrizione`** · descrizione
> La sorella di Sally vende cose che non dovrebbero esistere. Sorride sempre.
>
> →

**`NEG.artigiano.nome`** · nome del negozio
> La bottega dell'Artigiano
>
> →

**`NEG.artigiano.descrizione`** · descrizione
> "Roba industriale. Roba morta." Lui lavora solo ciò che ha una storia.
>
> →


# 12. Psichi

<sub>`data/psiche.json`</sub> — come reagisce un personaggio quando cade un compagno.

**`PSI.rabbia.nome`** · nome della psiche
> Rabbia
>
> →

**`PSI.rabbia.descrizione`** · descrizione
> Se un compagno va a terra si arrabbia: può attaccare di nuovo nello stesso turno.
>
> →

**`PSI.depressione.nome`** · nome della psiche
> Depressione
>
> →

**`PSI.depressione.descrizione`** · descrizione
> Se un compagno va a terra si deprime: la sua difesa cala e subisce più danno.
>
> →

**`PSI.concentrazione.nome`** · nome della psiche
> Concentrazione
>
> →

**`PSI.concentrazione.descrizione`** · descrizione
> Se un compagno va a terra si concentra: il fattore di disallineamento sale.
>
> →


# 13. Domande generiche di Studia

<sub>`data/studio.json`</sub> — usate quando una creatura non ha una domanda sua.

**`STU.generica1`** · domanda generica
> Ti ascolto.
>
> →

**`STU.generica2`** · domanda generica
> Rivelami i tuoi desideri.
>
> →

**`STU.generica3`** · domanda generica
> Fammi capire cosa ti è successo.
>
> →

**`STU.generica4`** · domanda generica
> Rispondi.
>
> →

**`STU.generica5`** · domanda generica
> È ora di scoprire la verità.
>
> →

**`STU.generica6`** · domanda generica
> Giustifica le tue azioni.
>
> →


# Appendice — dove manca del testo da scrivere

Non ci sono frasi da correggere qui: ci sono buchi da riempire. Il bottone «Parla con la
squadra» compare in ogni stanza in cui hai un compagno, ma una battuta esiste solo dove
qualcuno l'ha scritta: altrove il compagno risponde «*non ha altro da dirti, qui*».


## Yhvina nella Casa Gigante, stanza per stanza

Yhvina (`insonne`) si unisce a te in `camera_da_letto` e resta fino alla fine dello
squarcio: da lì in poi il bottone «Parla con la squadra» c'è ovunque, e dentro c'è solo lei.

| Stanza | Parla da sola nella scena | Premendo «Parla con la squadra» |
|---|---|---|
| `soglia` | — | **muta** |
| `salone` | — | **muta** |
| `sala_principale` | — | **muta** |
| `ala_destra` | — | **muta** |
| `ala_sinistra` | — | **muta** |
| `quadro_uomo` | — | **muta** |
| `quadro_donna` | — | **muta** |
| `quadro_famiglia` | — | **muta** |
| `mensola` | — | **muta** |
| `cucina` | — | **muta** |
| `scala` | — | **muta** |
| `grande_bagno` | — | **muta** |
| `stanza_giochi` | — | dice qualcosa |
| `foto_1` | — | **muta** |
| `foto_2` | — | **muta** |
| `foto_3` | — | **muta** |
| `soffitta` | — | **muta** |
| `attico` | — | **muta** |
| `camera_da_letto` | 3 battute | **muta** |
| `yhvina_si` | 2 battute | **muta** |
| `stanza_studi` | — | **muta** |
| `cartella_clinica` | — | **muta** |
| `tunnel` | 1 battuta | **muta** |
| `altare` | — | **muta** |
| `presentazione_ricordo` | — | **muta** |
| `porta_bloccata` | — | **muta** |
| `porta_enorme` | — | **muta** |
| `lettere_lettura` | — | **muta** |
| `lettere_bruciate` | — | **muta** |
| `ricordo_concluso` | — | **muta** |
| `ricordo_concluso_buono` | — | **muta** |
| `congedo_yhvina` | 2 battute | **muta** |
| `cacciata` | — | **muta** |
| `giardino_ingresso` | — | **muta** |
| `giardino` | — | **muta** |
| `giardino_est` | — | **muta** |
| `fiori_di_luna` | — | **muta** |
| `albero_voce` | — | **muta** |
| `voce_ignorata` | — | **muta** |
| `voce_avvicinati` | — | **muta** |
| `albero_voce_spilla` | — | **muta** |
| `spirito_rivelato` | — | **muta** |
| `spirito_hub` | — | dice qualcosa |
| `spirito_indizio_yhvina` | — | **muta** |
| `spirito_laboratori` | 6 battute | **muta** |
| `spirito_laboratori_ancora` | — | **muta** |
| `spirito_matrice` | 2 battute | **muta** |
| `spirito_vivaio_ancora` | — | **muta** |
| `spirito_esperimento` | — | **muta** |
| `spirito_foto` | — | **muta** |
| `spirito_ricordi` | — | **muta** |
| `spirito_diari` | 2 battute | **muta** |
| `spirito_storia` | 3 battute | **muta** |
| `spirito_storia_buona` | 1 battuta | **muta** |
| `spirito_storia_lasciata` | — | **muta** |
| `albero_addio` | — | dice qualcosa |
| `albero_addio_buono` | 5 battute | dice qualcosa |
| `giardino_ovest` | — | **muta** |
| `laboratorio` | — | **muta** |
| `sala_matrici` | — | **muta** |
| `deposito_chimico` | — | **muta** |
| `giardino_nord` | — | **muta** |
| `vivaio_ingresso` | — | **muta** |
| `vivaio_rovi` | — | **muta** |
| `vivaio_varco` | — | **muta** |
| `vivaio_apertura` | — | **muta** |
| `vivaio_1` | — | **muta** |
| `vivaio_1_perlustra` | — | **muta** |
| `vivaio_2` | — | **muta** |
| `vivaio_2_perlustra` | — | **muta** |
| `vivaio_3` | 1 battuta | **muta** |
| `vivaio_fondo` | — | **muta** |
| `volto_appare` | 1 battuta | **muta** |
| `dopo_volto` | 1 battuta | **muta** |
| `id_card_trovata` | — | **muta** |
| `vivaio_fondo_dopo` | — | **muta** |
| `botola_chiusa` | — | **muta** |
| `lettore_vuoto` | — | **muta** |
| `spirito_chiacchiere` | — | **muta** |


## Tutte le stanze dove i compagni non hanno niente da dire

Per riempirne una, in `data/dialoghi.json` dentro `luoghi` si aggiunge una voce con
**quell'id esatto**:

```json
"nome_della_stanza": {
  "una_tantum": "dialogo_yhvina_nome_della_stanza",
  "sequenza": [
    { "tipo": "narrazione", "testo": "%s si ferma un attimo a guardare il soffitto." },
    { "tipo": "dialogo", "chi": "insonne", "testo": "..." }
  ]
}
```

`%s` diventa il nome del compagno. Un `dialogo` senza `chi` è la battuta di chi hai davanti
in quel momento, così la stessa scena vale per qualunque compagno. `una_tantum` la fa
sentire una volta sola. L'introduzione e il tutorial non compaiono qui: là sei da solo,
quindi il bottone non esiste proprio.


### La Casa Gigante — 75 stanze mute

- `soglia` — La facciata della grande casa ti sovrasta, storta, con tutte le finestre buie tranne una.
- `salone` — Sembra tutto abbandonato da tantissimo tempo... la polvere è così fitta da sembrare una leggera…
- `sala_principale` — Sembra che le pareti siano addobbate con i quadri di gente che probabilmente viveva in questo…
- `ala_destra` — Il corridoio a scacchi dell'ala destra, e in fondo le stanze sfondate dalle macerie. Non porta da…
- `ala_sinistra` — L'ala sinistra: stanze grandi, vuote, e niente dentro a parte la polvere.
- `quadro_uomo` — Sembra un uomo molto severo... le rughe sul suo volto fanno trasparire un'estrema tristezza e una…
- `quadro_donna` — Una donna di una certa età... cos'ha in mano? Il suo sguardo non ti fa sentire al sicuro.
- `quadro_famiglia` — Ci sono un uomo, una donna, una bambina con una bambola in braccio e una donna anziana in posa...…
- `mensola` — La mensola dei detersivi, allineati come in una vetrina. L'odore di ammoniaca non se ne va.
- `cucina` — Pentole in fila, un tavolo apparecchiato per tre da molto tempo, senza che nessuno l'abbia mai…
- `scala` — La scala, e i suoi piani che non finiscono mai. Da qui si arriva ovunque, in questa casa.
- `grande_bagno` — Il grande bagno, le rubinetterie secche e la vasca piena di calcinacci.
- `foto_1` — Una fotografia ingiallita: una ragazzina, forse sei o sette anni, gioca seduta per terra con una…
- `foto_2` — La stessa ragazzina, cresciuta: un vestito più elegante, una posa più composta. Tiene ancora la…
- `foto_3` — Una festa di compleanno: candeline, un tavolo pieno di regali che sembrano tutti uguali e tutti…
- `soffitta` — La soffitta: scatoloni ovunque, tutti con la stessa scritta a mano. Nessuno è mai stato buttato.
- `attico` — L'attico, basso e lungo. In fondo, sotto uno spiovente, una porta chiusa da cui filtra una luce…
- `camera_da_letto` — La camera da letto sotto lo spiovente: un materasso per terra, una lampada che nessuno spegne mai.
- `yhvina_si` — Yhvina è in piedi accanto alla porta, e aspetta che sia tu a muoverti.
- `stanza_studi` — Sotto i cuscini, la botola dà su una stanza degli studi: scrivania, diplomi alle pareti, e un…
- `cartella_clinica` — "...sbalzi di umore frequenti, episodi depressivi persistenti. Livelli di disallineamento anomali…
- `tunnel` — Il tunnel scavato a mano scende oltre le fondamenta. Più avanti, il freddo.
- `altare` — Un altare tributario, costruito con le mani: candele consumate, una foto incorniciata, e un mucchio…
- `presentazione_ricordo` — Quando si vuole bene a qualcuno, un legame viene creato... come migliaia di fili intrecciati…
- `porta_bloccata` — Fai un passo oltre le candele, e la bambola si volta di scatto verso di te — non ti aveva mai…
- `porta_enorme` — Con la bambola non più a guardia, il passo oltre l'altare è libero: una porta enorme,…
- `lettere_lettura` — Sono lettere mai spedite, scritte dai genitori: parlano di rimorso, di quanto avrebbero voluto…
- `lettere_bruciate` — Le accendi una a una, sull'ultima candela ancora viva. Il rimorso di chi le ha scritte non serve…
- `ricordo_concluso` — Le cuciture non cedono: si strappano. La bambola si apre da sola lungo le giunture, un filo dopo…
- `ricordo_concluso_buono` — La bambola comincia a sfilacciarsi lo stesso, ma questa volta senza opporre resistenza: le ombre…
- `congedo_yhvina` — Dove c'era Yhvina non è rimasto niente. Il tuo compito, qui, è terminato.
- `cacciata` — Qualcosa ti solleva di peso e la casa ti scaraventa fuori, oltre lo squarcio. La ninna nanna…
- `giardino_ingresso` — Il vialetto che porta al giardino, sul fianco della casa.
- `giardino` — Il giardino sotto la luna. Tre sentieri: est, ovest, nord.
- `giardino_est` — Il giardino est. Il silenzio, qui, è più fitto che altrove.
- `fiori_di_luna` — Tra l'erba alta, due fiori pallidi si aprono solo di notte.
- `albero_voce` — La profondità del giardino est. L'albero grande in fondo, e niente altro.
- `voce_ignorata`
- `voce_avvicinati` — Cerchi ovunque... ma sembra che la voce non ci sia più. Qualunque cosa fosse, ormai è andata via.
- `albero_voce_spilla` — La profondità del giardino est. L'albero grande in fondo, e niente altro.
- `spirito_rivelato` — Le foglie cominciano a muoversi freneticamente e il vento si alza lievemente... Dall'albero…
- `spirito_indizio_yhvina`
- `spirito_laboratori`
- `spirito_laboratori_ancora`
- `spirito_matrice`
- `spirito_vivaio_ancora`
- `spirito_esperimento` — Il volto della vecchia custode, sulla corteccia dell'albero grande.
- `spirito_foto`
- `spirito_ricordi`
- `spirito_diari`
- `spirito_storia`
- `spirito_storia_buona`
- `spirito_storia_lasciata`
- `giardino_ovest` — La radura lastricata a ovest, e in fondo il grande laboratorio.
- `laboratorio` — Il grande laboratorio: banconi in fila, e le cartelle ancora appese.
- `sala_matrici` — La sala delle matrici: le macchine da incisione e le piastrine mai assegnate.
- `deposito_chimico` — Il deposito chimico. Le taniche contro la parete, allineate.
- `giardino_nord` — La muraglia di rovi a nord, e il vetro del vivaio appena visibile dietro.
- `vivaio_ingresso` — Le piante impediscono il passaggio: colpirle è inutile.
- `vivaio_rovi`
- `vivaio_varco` — Il diserbante affonda nel terreno ai piedi della muraglia. Per un momento non succede niente. Poi i…
- `vivaio_apertura` — Le piante si seccano e lasciano una piccola apertura, che ti permette di entrare nel vivaio.
- `vivaio_1` — Il primo piano del vivaio, le vasche lunghe e i cartellini illeggibili.
- `vivaio_1_perlustra`
- `vivaio_2` — Il secondo piano del vivaio, con le vetrate coperte dai rovi.
- `vivaio_2_perlustra` — C'è un buco, dove prima deve esserci stato un ascensore. Vuoi proseguire?
- `vivaio_3` — Il fondo del vivaio: l'ascensore a pezzi, e la stanza invasa dalle piante.
- `vivaio_fondo`
- `volto_appare` — Qualcosa prende forma sulla parete...
- `dopo_volto` — La stanza in fondo al vivaio. Sulla parete non è rimasto niente.
- `id_card_trovata` — Nel cassetto di una delle scrivanie trovi l'ID della capofamiglia, coperto di piccole piante.
- `vivaio_fondo_dopo` — La stanza in fondo al vivaio. Sulla parete non è rimasto niente.
- `botola_chiusa` — La botola non ha maniglia: solo una fessura sottile sul bordo, e sopra la fessura una spia che…
- `lettore_vuoto` — Infili la matrice nella fessura. La spia smette di lampeggiare e resta accesa, fissa, per qualche…
- `spirito_chiacchiere`


### Cunicoli sotterranei di Jondoh — 37 stanze mute

- `varco` — Il varco resta aperto alle tue spalle, un taglio di luce fredda sulla parete nera. Davanti, il…
- `corridoio_ossidiana` — Il corridoio scende, tagliato nella roccia nera. Ai lati, nicchie scavate a mano, segni di graffi e…
- `fossa_oscura` — Una fossa oscura dove piccole pietre illuminano quel poco che è visibile. Qualcosa si muove nel…
- `fondo_del_fosso` — Non sembra esserci altro. Senti qualcosa sballottato fra i tuoi piedi: uno zaino, di qualcuno più…
- `sala_del_raccolto` — Cos'è questo posto... c'è una puzza tremenda... quelli... sono cadaveri. Il modo in cui sono stati…
- `sala_del_lamento` — La sala del lamento: pareti coperte di graffi fino a dove arriva il braccio di un uomo, e un'eco…
- `lamento_imboscata` — Una figura oscura ti travolge dal buio!
- `dopo_lamento` — Qualcosa, dentro di te, si fissa in questo punto. Non tornerai indietro da qui.
- `cunicolo_1` — Questi cunicoli sembrano non avere fine. Da qui la roccia si biforca in due direzioni diverse.
- `cunicolo_2` — Il cunicolo di sinistra scende ancora, ma in fondo si intravede un bagliore instabile, come di…
- `cunicolo_3` — Il cunicolo di destra sale, e un filo di vento gelido comincia a farsi sentire: da qualche parte,…
- `piazza_sotterranea` — Nella piazza sotterranea trovi qualcuno di vivo, finalmente. Ti osserva a lungo, immobile, prima di…
- `piazza_ritorno` — Yara è dove l'hai lasciata: la schiena contro la roccia, gli occhi puntati sulla galleria da cui…
- `piazza_con_yara` — La piazza è vuota, adesso: le torce consumate fino alla base, e il silenzio che si richiude ogni…
- `yara_si_unisce` — Yara ti aspetta, già rivolta verso l'uscita della piazza.
- `cargo_abbandonato` — All'aperto trovi un cargo abbandonato, arrugginito, mezzo sepolto nella sabbia nera. All'interno,…
- `ponte_approccio` — Il cunicolo si apre su un grande ponte marcio, teso su un baratro che la luce non riesce a…
- `ponte_meta_compagna` — Le assi del ponte scricchiolano già sotto il primo passo. Sotto, solo buio.
- `ponte_meta_solo` — Le assi del ponte scricchiolano già sotto il primo passo. Sotto, solo buio.
- `ponte_centro` — Senti qualcosa muoversi sotto di te...
- `ponte_quasi_fine` — Sembra tutto ok: ormai sei a metà del ponte...
- `ponte_attacco` — Qualcosa sta salendo da sotto il ponte...
- `ponte_attacco_compagna`
- `oltre_ponte` — Attraversato il ponte, volgi lo sguardo all'indietro: altri vermi risalgono e divorano la carcassa…
- `oltre_ponte_gratitudine` — Dall'altra parte del ponte l'aria è ancora più densa. Yara non guarda più indietro.
- `cripta_senza_compagna` — La cripta è una galleria bassa di ossidiana lucida. Qualcosa continua a camminarci dentro, senza…
- `cripta_con_compagna` — La cripta è una galleria bassa di ossidiana lucida. Qualcosa continua a camminarci dentro, senza…
- `sconfitta_immortale` — Non riesci a scrollartelo di dosso in tempo. Il buio, alla fine, non ha nemmeno bisogno di…
- `altare_dei_sacrifici` — Un altare scavato nella pietra nera: candele consumate fino alla base, cera colata sopra cera, e…
- `altare_da_solo` — L'altare è come l'hai lasciato: le candele consumate, la scalinata che scende verso la luce…
- `altare_con_yara` — L'altare è come l'avete lasciato: le candele consumate, la scalinata che scende verso la luce…
- `trono_marcio_senza_compagna` — Qualcuno recita in una lingua a te sconosciuta dei canti mentre scendi gli ultimi gradini: le…
- `trono_marcio_con_compagna` — Qualcuno recita in una lingua a te sconosciuta dei canti mentre scendete gli ultimi gradini: le…
- `jongo_prima_caduta` — Jongo Dongo si rialza.
- `vittoria` — Jongo Dongo cade in ginocchio, poi si sfalda: la maledizione che lo teneva in piedi si scioglie…
- `sconfitta_boss`
- `espulso` — Il buio ti si richiude sopra come una fossa che si rinchiude. Quando riprendi fiato, sei di nuovo…


### Lo Squarcio Industriale — 27 stanze mute

- `varco` — La luce rossa, i corridoi stretti, l'olio consumato. Lo squarcio è alle tue spalle.
- `corridoi_stretti` — Corridoi stretti, luci a intermittenza. In fondo, una luce rossa.
- `corridoi_stretti_dopo` — Corridoi stretti, luci a intermittenza. In fondo, una luce rossa.
- `sala_vetrata` — Nella stanza tutto è illuminato da una fioca luce rossa. Lungo i lati, vari schermi con messaggi di…
- `sala_vetrata_dopo` — La luce rossa, gli schermi che muoiono e si riaccendono, la vetrata sulla catena di montaggio.
- `dopo_robo` — La luce rossa, gli schermi che muoiono e si riaccendono, la vetrata sulla catena di montaggio.
- `corridoio_tubi` — La piccola stanza dismessa in fondo al corridoio dei tubi.
- `corridoio_tubi_aperto` — La piccola stanza dismessa: tre entrate, e sopra ognuna una targa.
- `corridoi_infiniti` — Corridoi che si intrecciano senza fine. Davanti a te, una porta che non oppone molta resistenza.
- `corridoi_infiniti_dopo` — Corridoi che si intrecciano senza fine. In fondo, il vano vuoto della porta abbattuta.
- `sala_sorveglianza` — Gli schermi che ti riprendono da ogni angolazione. Sulla destra, il computer con i file aperti.
- `file_computer` — Pagina 1 di 6. «Rapporto interno, riservato alla direzione. Reparto montaggio: media di sedici ore…
- `dopo_operaio` — Gli schermi che ti riprendono da ogni angolazione. Il computer sulla destra, adesso spento e…
- `sala_sorveglianza_dopo` — Gli schermi che ti riprendono da ogni angolazione. Il computer sulla destra, adesso spento e…
- `deposito` — Il vecchio deposito. Scaffali piegati dal caldo, casse sventrate.
- `sala_valvole` — La sala delle valvole: ruote di metallo grandi come carri, e perdite dappertutto.
- `sala_schede` — La sala informatica: circuiti alle pareti, e in fondo la porta del centro di controllo.
- `centro_controllo` — Il vecchio centro di controllo: monitor spenti, un'unica poltrona, e i diari sulla scrivania.
- `diario_1` — «Giorno 1. Il complesso è operativo. Ho detto ai capisquadra che voglio efficienza, non lamentele.…
- `diario_2` — «Tre operai non si sono presentati oggi. Il caporeparto dice che ne ha abbastanza di come viene…
- `diario_3` — «Questo posto sembra essere destinato alla rovina, quei maledetti del sindacato sono riusciti a…
- `nastro` — Il nastro trasportatore che corre a vuoto. Il caldo, qui, toglie il respiro.
- `cuore` — Il cuore del complesso: la turbina ferma, i nomi incisi sulle pale, l'insegna sbiadita.
- `discarica` — Il piazzale a cielo aperto: montagne di rottami, e il sole rosso che ci batte sopra.
- `padiglione_e` — Il Padiglione: una struttura tonda enorme, e un unico portello sigillato sul fondo.
- `padiglione_e_chiuso`
- `espulso` — Le macerie ti schiacciano... il tuo destino è deciso, diventi un tutt'uno con i rottami...…


### Meridia — 28 stanze mute

- `varco` — La collina sopra Meridia. Sotto di te la città, e le ombre che si muovono piano.
- `periferia` — Le strade di periferia. La polvere sospesa, e niente che si muova.
- `ingresso_citta` — L'ingresso della città. I primi palazzi, e i cartelli che nessuno legge più.
- `complessi` — I primi complessi di edifici. La strada principale davanti, il parco da un lato, la struttura…
- `complessi_dopo` — I primi complessi di edifici. La strada principale davanti, il parco da un lato, la struttura…
- `struttura` — La struttura abbandonata. La rampa che scende, e le luci che nessuno ha mai spento.
- `garage_1` — Piano -1. Le file di posti auto vuoti, a perdita d'occhio.
- `garage_2` — Piano -2. I rottami sparsi, e gli angoli che restano bui.
- `garage_3` — Piano -3. Il rumore che hai sentito non si ripete.
- `garage_3_perlustra` — Non hai trovato nulla d'interessante... vari fori sono distribuiti nelle pareti... sembrano scavati…
- `garage_4` — Piano -4. Il cumulo di macerie che scende ancora, e l'aria che ne sale.
- `garage_4_perlustra` — Nonostante i tuoi sforzi il cumulo di macerie ti impedisce di proseguire oltre... Non sembra…
- `fuori_struttura` — La creatura ti osserva... sembra in qualche modo... invidiosa? In un battito d'occhio, ti ritrovi…
- `dopo_infetto`
- `seconda_ondata` — Non fai in tempo a riprendere fiato: dal fondo della strada ne arrivano altri, con lo stesso passo…
- `dopo_ondate` — Fuori dalla struttura. La strada, adesso, è di nuovo vuota.
- `fuori_struttura_dopo` — Fuori dalla struttura. La strada, adesso, è di nuovo vuota.
- `parco` — Il parco. Gli alberi secchi, e il lago quasi prosciugato.
- `parco_lago` — Al centro del lago qualcosa luccica. L'acqua è bassa, così ti fai strada verso l'oggetto...
- `dopo_nuvola` — Il parco. Gli alberi secchi, e il lago quasi prosciugato.
- `parco_dopo` — Il parco. Gli alberi secchi, e il lago quasi prosciugato.
- `strada_principale` — La strada principale. Le vetrine rotte, e i cartelli col nome della città.
- `supermercato` — Il supermercato saccheggiato. Scaffali rovesciati, carrelli fermi a metà corsia.
- `officina` — L'officina abbandonata. Il furgone ancora sollevato sul ponte.
- `edicola` — L'edicola con la saracinesca a metà, e le pile di giornali mai ritirati.
- `vicolo` — Il vicolo dietro l'edicola. I cassonetti rovesciati, la scala antincendio verso il nulla.
- `quartieri_profondi` — I quartieri profondi. I palazzi si stringono, e l'aria non si respira più.
- `espulso` — Il tuo destino è segnato. Tra le mille bocche affamate scompari in silenzio... un ultimo respiro si…


### Il Teatro del Passato — 6 stanze mute

- `foyer` — Questo squarcio dà sul passato: un teatro nel suo giorno migliore. Il foyer profuma di velluto e…
- `platea` — In platea non c'è nessuno. Sul palco, un ragazzo si esibisce in acrobazie folli: salti che nessun…
- `palcoscenico` — Da vicino il ragazzo è solo un ragazzo: fiato corto, mani fasciate, occhi che bruciano. Ti…
- `quinte` — Dietro le quinte: corde, sacchi di sabbia, uno specchio con le lampadine. Infilata nella cornice…
- `galleria` — Dalla galleria il palco sembra piccolo e il ragazzo un punto che vola. Il lampadario di cristallo…
- `botteghino` — Il botteghino è ordinato, pronto per una fila che deve ancora arrivare. Il registro segna un solo…


### Kizako Industries — Ala Dimenticata — 8 stanze mute

- `portone` — Lo squarcio si apre su un'altra ala dello stesso complesso: più grande, più antica, sigillata da un…
- `reparto` — Il reparto montaggio si perde nel buio. Nastri fermi, bracci meccanici piegati come schiene…
- `mensa` — Una mensa aziendale immensa, tavoli in fila fino a perdersi. Su un muro, un orologio marcatempo…
- `passerella` — Dalla passerella si domina tutto il reparto. Da qui i capisquadra guardavano gli operai come si…
- `archivi` — Gli archivi della Kizako Industries. Faldoni di brevetti d'arma, bilanci gonfi, e una parete intera…
- `fascicolo` — "Progetto di ottimizzazione del rendimento umano. Turni prolungati oltre soglia di crollo. Perdite…
- `studio_kizako` — Lo studio è vuoto, pulito, gelido: l'unica stanza intatta di tutto il complesso. Nessun ritratto…
- `espulso` — Le sirene esplodono tutte insieme e le luci di cantiere ti accecano. Quando torni a vedere, sei…


### La Fontana — 3 stanze mute

- `fontana` — Nessun deserto, nessuna fabbrica: qui c'è solo una luce chiara e sospesa, e al centro una fontana…
- `incavi` — Quattro incavi, quattro forme: un'anima inquieta, dei ricordi felici, la volontà di un fabbro, un…
- `fontana_completa` — I quattro pezzi trovano il loro posto. L'acqua sgorga dal nulla, limpida, e sale oltre il bordo…


### La campagna di Jerah — 26 stanze mute

- `inizio` — L'incarico dell'Organizzazione è chiaro: trovare la fonte ed estinguerla, prima che questo mondo…
- `bosco` — Tra le dune, una vecchia biglietteria da corrida rovesciata, mezza sepolta. Dentro, monete sparse e…
- `fiume` — L'arroyo è secco da secoli. Nella sabbia, mezza sepolta, una lanterna spenta che pulsa come un…
- `riva` — Più avanti, un carro da mercante ribaltato, il carico sparso nella sabbia. Qualcuno è fuggito in…
- `sentiero_lanterne` — Una fila di torce di ferro nero si accende al tuo passaggio, una alla volta, come se qualcuno…
- `radura` — Il piazzale davanti alla plaza. Cactus alti come uomini, sombreros bruciati appesi ai pali. Sulla…
- `campo_giostre` — Il patio delle cuadrillas, sotto le gradinate. Il toril con le sbarre divelte, una sala di specchi…
- `tunnel` — Nel toril qualcuno ha smontato le sbarre pezzo per pezzo, e ha lasciato la cassa degli attrezzi. In…
- `specchi` — Gli specchi non riflettono te: riflettono i mondi che non ci sono più. In uno di essi, una scheggia…
- `carovana` — In una terra molto, ma molto lontana, dove la luce del sole risplende ogni giorno... Dove maghi,…
- `carovana_si`
- `carovana_no`
- `carovana_racconto` — [Qui andranno le cinque tavole disegnate da Bru sulla storia di Jerah — arte non ancora pronta.]
- `giostra_cavalli` — Una giostra di cavalli da picador gira da sola, a luci spente. I cavalli di legno hanno tutti la…
- `baraccone_premi` — Un banco di gioco all'ombra delle gradinate: tre bersagli di latta, una pistola a spuntoni…
- `premio` — Tre colpi, tre bersagli. Nel silenzio, il banco ti porge un toro di pezza con un occhio solo.…
- `proscenio` — Sotto l'arco d'ingresso al ruedo c'è uno spiazzo riparato dal vento di sabbia. La fonte è vicina:…
- `falo` — Il fuoco prende in fretta, piccolo e amico in mezzo a tutto quel fuoco nemico. Qui il fragore…
- `falo_notte` — Le braci calano. Qualcuno dovrebbe dire qualcosa, ma il silenzio va bene lo stesso.
- `palco` — Una strana musica latina comincia a inondare la sala, dalle fiamme e dal cumulo di rose si innalza…
- `backstage` — Il callejón dietro la barriera è un intrico di corde e drappi bruciacchiati. In alto, tra le travi…
- `segreto` — Tra le travi trovi la medaglia della vecchia plaza, incisa con un nome che non riesci a leggere.…
- `boss` — Cosa spinge l'uomo a dare di più? Perché cerchiamo sempre l'approvazione di chi ci circonda? Forse…
- `sconfitta` — Ti risvegli fuori dalla plaza, la testa che rimbomba come un tamburo. Il disallineamento ti ha…
- `vittoria` — Jerah si spegne senza una parola, gli occhi ancora sulle gradinate vuote. Non c'era più niente da…
- `vittoria_eroe` — L'ultimo spettacolo di Jerah finisce così: un inchino vero, il primo da anni, la muleta abbassata…
