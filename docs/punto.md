# Il punto — dove siamo, cosa manca, cosa aspetta te

> **Questo è l'indice di tutto.** Da qui capisci quale documento aprire e cosa ci trovi dentro.
> Gli altri file sono di due specie e non vanno confuse:
> **📝 da compilare** — li scrivi tu, nessuno li rigenera, quello che scrivi resta.
> **⚙️ generati** — li riscrive uno strumento da capo: correggerli è fatica buttata.

---

## 1. La mappa dei documenti

| File | Specie | Cosa ci trovi | Stato |
| --- | --- | --- | --- |
| **`punto.md`** | 📝 | Questo. L'indice e lo stato di tutto | ✅ aggiornato |
| **`manuale.md`** | 📝 | Tipi · status · armi · crescita. **Il documento madre**: le decisioni di fondo stanno qui | ✅ tue risposte applicate |
| **`personaggi-giocabili.md`** | 📝 | Protagonista, Veronica, Yhvina: 54 mosse con livello e costo, più le versioni scriptate | ✅ ora sono anche nei dati |
| **`mediazione.md`** | 📝 | I 39 nemici, con la colonna «a che condizioni ascolta» da riempire | ⚠️ 38 righe vuote |
| **`storia.md`** | 📝 | La trama, i Vuoti, l'Organizzazione | 🕓 fermo a prima dell'hype |
| **`tipi.json`** *(dati)* | 📝 | La tabella di chi pesa su chi. **È mia: correggila** | ⚠️ da rivedere |
| **`stati.json`** *(dati)* | 📝 | Gli 8 status coi numeri. Ogni voce ha un campo `_bru` con la tua frase | ⚠️ numeri miei |
| **`testi_da_correggere.md`** | 📝 | Ogni riga di dialogo del gioco, in un posto solo | 🕓 grande, mai riletto tutto |
| **`godot.md`** | 👁 | Studio sul motore: fondamenta, avanzato, cosa si rompe in produzione, chi ha spedito. E cosa ci riguarda | ✅ nuovo |
| **`mestiere.md`** | 👁 | Studio sul mestiere: sensazione, transizioni, colore, testo, i maestri dell'RPG e le tecniche dei romanzieri. E cosa ci riguarda | ✅ nuovo |
| **`lezioni.md`** | 👁 | Studio sui maestri: EarthBound, Fear & Hunger, Zelda, Metroid, Doom, Final Fantasy, e cosa ne ha detto la critica | ✅ nuovo |
| **`critica.md`** | 👁 | Il gioco giudicato duro, voto per voto, con la prova sotto ogni voto | ✅ nuovo |
| **`dedalo.md`** | 👁 | Studio sulla **mappa**: la grammatica del livello, Jaquays, Lynch, i libri-gioco — e la nostra mappa misurata | ✅ nuovo |
| **`topologia.md`** | ⚙️ | La forma vera delle otto zone: anelli, scorciatoie, bivi, cancelli. `./strumenti/topologia.py` | ✅ nuovo |
| **`nemici.md`** | ⚙️ | Il bestiario coi numeri veri: mosse, quote, danni. `./strumenti/nemici.sh` | ✅ rigenerato oggi |
| `bilanciamento.md` | ⚙️ | **234.000** partite simulate, cinque modi di giocare: chi vince a che livello. `./prove/simula.sh` | ✅ rilanciato oggi |
| **`mappe.md`** | ⚙️ | Le mappe delle zone disegnate | ✅ |
| **`immagini.md`** | ⚙️ | Che disegni servono e quali ci sono | ✅ |
| **`gdd.html`** + PDF | 👁 | Il documento da far leggere a un game developer | 🕓 **stale**: sotto |
| **`carta.html`** | 👁 | La carta dei principi di design | 🕓 **stale**: sotto |
| **`personaggi.html`** + PDF | 👁 | Riferimento tipi/status/armi da leggere | 🕓 **stale**: sotto |

**👁 sono da leggere, non da compilare.** Li ho fatti prima delle ultime tre decisioni grosse
(hype, livello = nodi comprati, menu a cinque voci), quindi **oggi dicono cose che non sono più
vere**. Non li ho rifatti perché rigenerarli ha senso quando le decisioni si fermano, non a ogni
giro: dimmi quando e li riallineo in una passata sola.

> `mosse-dei-tre.md` **non esiste più**: era la prima stesura di `personaggi-giocabili.md` e vi
> chiedeva le stesse cose due volte. Quello che aveva di suo l'ho spostato nel file nuovo.

---

## 2. Cos'è il gioco, in dieci righe

Un RPG a squadra di 4 in cui **il combattimento non ha turni**: ognuno ha la sua ricarica, e
quando è pronto **prendi tu il controllo** — compagni compresi, nessuno va in automatico.

Il menu è **fisso a cinque voci**: Attacca · Difendi · Abilità · Oggetti · Fuggi. Più due che
compaiono solo quando ci sono: **Aiutante** e **Mediazione**.

Si cresce spendendo **hype** su una mappa a stelle disegnata a mano: **80 nodi, 60 comprabili**.
Il tuo livello **è** quanti nodi hai comprato. L'hype è unico per tutta la squadra e scegli tu su
chi spenderlo; il mondo si regola sulla **media** della squadra, così chi porta avanti un solo
personaggio non spacca la difficoltà.

Ogni frattura ricomincia da livello 1. Quello che resta fra una frattura e l'altra è estetico —
artwork, badge, titoli, dedizione.

---

## 3. Deciso **e nel motore** — non ci si torna sopra

| Cosa | Dove sta |
| --- | --- |
| **Battute** — ricarica indipendente, niente turni | `Combattimento.gd` |
| **L'hype** — due contatori, livello = nodi comprati, mondo sulla media | `GameState.aggiungi_hype` |
| **Gli 8 status** — Terrore, Fiamme, Tossina, Sonno, Maledizione, Rabbia, Provocato, Frastornato | `data/stati.json` |
| **I 5 tipi** — con tabella delle efficacie ed eccezioni per creatura | `data/tipi.json` |
| **Veronica e Yhvina** — due classi, 36 mosse dichiarate ed eseguibili | `data/classes.json` |
| **Menu a cinque voci** + Aiutante e Mediazione condizionali | `combattimento/Menu.gd` |
| **Difendi cumulativa** fino a fine scontro, tetto 6 scatti | `Regole.alza_guardia` |
| **Mediazione** — natura, voglia, studio | `Combattimento.media()` |
| **Barra di dominio** a 3 segmenti, per combattente; Mattanza la svuota | `Regole.riempi_dominio` |
| **Studio a strati** — il tecno log si riempie guardando | `rileva_tecnolog` |
| **Curva dei ruoli** — le statistiche escono dal ruolo, le eccezioni vanno dichiarate | `data/ruoli.json` |
| **Disallineamento** — i nemici non restano indietro più di 3 livelli | `GameState.livello_nemico` |
| **Sei caselle** — ogni creatura ha 6 slot mossa, i vuoti sono dichiarati | `data/personaggi.json` |
| **20 tipi di mossa** eseguibili dal motore | `esegui_mossa()` |
| **Il colpo si sente** — fermo immagine, scossa, scatto di chi colpisce | `combattimento/Impatto.gd` |
| **Il tipo si vede** — colore del numero, e ▲ / ▼ / ✕ per l'efficacia | `Stile.colore_colpo` |
| **L'arena reagisce** — fondo tinto dal tipo, bordi che si chiudono | `combattimento/Arena.gd` |
| **Allarme vita bassa** — la scheda batte prima che tu cada | `Campo.allarme_vita` |
| **Tetto alla cura di sé** — nessuna creatura si rimette addosso più della sua vita | `rimetti_in_piedi()` |
| **Punti di riferimento** — una stanza può dire cosa si vede da lì, e ci si deve poter arrivare | campo `vista` nelle zone |
| **Armi con attacchi propri**, sotto Abilità | `GameState.attacchi_arma` |
| **Salvataggio a 5 slot** + autosalvataggio | `GameState` |

**Come si controlla che sia vero:** `./prove/esegui.sh` — **79 prove, 26.368 verifiche**, gira in
circa quattro minuti. Ogni prova nuova la valido rompendo apposta la meccanica che misura: se non
diventa rossa, la prova non serve a niente e la riscrivo. **Nell'ultimo giro il metodo si è
ripagato due volte**: due prove che avevo appena scritto restavano verdi anche con la meccanica
rotta — una confrontava il colore sbagliato, l'altra non arrivava mai al caso che diceva di
misurare. Le ha trovate il sabotaggio, non io, e le ho riscritte.

---

## 4. Il divario fra carta e codice — **chiuso**

Qui c'erano sei cose decise che il gioco non faceva. Le ho fatte tutte, **coi numeri miei**, come
mi hai detto. Ogni numero che ho inventato è segnato nei dati: in `stati.json` ogni status porta
un campo `_bru` con la frase tua da cui esce, così quando cambi una cifra vedi subito se stai
correggendo una tua decisione o una mia invenzione.

| Cosa | Adesso |
| --- | --- |
| **Gli 8 status** | Fatti. Terrore blocca i critici e indebolisce, Fiamme è uno status vero, Tossina è costante e resta fino alla cura, Sonno ha il tetto a 3 turni e il risveglio che i colpi alzano, Maledizione è una riserva da 10 che consumano i colpi e chi cade non si rialza, Rabbia e Frastornato tolgono le mosse, Provocato esiste come stato subìto |
| **I 5 tipi** | Fatti — e ho scoperto una cosa: **l'efficacia dei tipi non esisteva affatto**. L'`elemento` serviva solo a colorare il numero del danno. Non andava spostata, andava costruita |
| **Veronica e Yhvina** | Nei dati. Veronica esiste come classe (prima c'era solo il miniboss del tutorial), Yhvina scende da ♥400 a ♥130, e tutte e 36 le mosse sono dichiarate ed eseguibili |
| **L'hype** | Fatto. Due contatori, il livello è quanti nodi hai comprato, il mondo si regola sulla media della squadra |
| **Maestria del dominio per personaggio** | Fatta. Prima leggeva sempre quella del protagonista, anche quando a chiedere era Veronica |
| **La costellazione** | Il lettore è pronto e provato. **Aspetta il tuo disegno** — è l'unica cosa qui che non posso fare io |

### Quello che resta indietro, e va detto

- **I gradi III-VI hanno il colpo, non il fiocco.** «×3, e lascia Frastornato» fa il ×3; il
  Frastornato no. Ho implementato la parte centrale di ogni mossa e ho lasciato la clausola in
  fondo. Sono livelli da 33 a 60 e la demo finisce al 18: costruire venti effetti speciali adesso,
  con numeri inventati, per cose che nessuno vedrà per mesi, è lavoro che si butta. Le descrizioni
  complete stanno in `personaggi-giocabili.md`.
- **La libreria di mosse** non c'è ancora: se due creature fanno la stessa cosa, è scritta due
  volte. È il lavoro che avevi chiesto per dare a ogni nemico un testo suo su una mossa condivisa.
- **`bilanciamento.md` è stato rilanciato**, ed era ora: misurava un gioco di mesi fa. Adesso
  copre 234.000 partite e cinque modi di giocare. Cosa dice, sotto.

---

## 5. Problemi noti, misurati — **uno chiuso, due no**

Li ha trovati il simulatore. Gli altri due non li ho sistemati perché sono di bilancio, e il
bilancio ha senso quando le armi e l'hype sono al loro posto — non prima. Il primo invece non era
di bilancio: era una regola che mancava, ed è un'altra cosa.

| Chi | Cosa succede |
| --- | --- |
| ~~**Il Divoratore**~~ | ~~Si rimette addosso il **145%** della sua vita massima~~ — **chiuso**, ma non limando lui: adesso è una regola di motore, nessuna creatura si cura di più della propria vita in tutto uno scontro. Continua a chiudersi su se stessa e a mangiarsi, solo che a un certo punto ha finito sé stessa, e lo dice |
| **Oppresso · Robo Pattuglia** | Guardia cumulativa senza contrappeso: diventano scontri da **30 giri** |
| **Fomentado** | La sua combustione lo uccide da sola. Vince chi aspetta |
| ~~**Volto sulla parete**~~ | Comparso e chiuso nello stesso giro: era passato dal 99% di vittorie al **2%**, e sembrava rotto. Non lo era — vedi sotto |

> **Perché una regola e non una correzione.** Limare il Divoratore avrebbe sistemato il Divoratore;
> domani ne arriva un'altra scritta con lo stesso entusiasmo. Il tetto invece copre tutte e sei le
> strade con cui una creatura può rimettersi in piedi — cura, furto di vita, modalità, e le due
> rigenerazioni — e c'è una prova che legge il sorgente e pretende che non se ne apra una settima.
> **Il tetto non vale per la tua squadra**: quelle cure le paghi tu, con oggetti comprati o aura
> spesa, e un limite invisibile sulle fiale che fanno effetto sarebbe la cosa più crudele del gioco.

### Il Volto sulla parete, e come il misuratore mi ha quasi fatto limare la creatura sbagliata

Rilanciando il simulatore il Volto è passato **dal 99% di vittorie al 2%**. Sembrava una regressione
del lavoro appena fatto. L'ho isolata invece di indovinare, ed è per questo che adesso esiste la
sonda:

| Esperimento | Risultato |
| --- | --- |
| Tolgo il tetto alla cura | **identico**: 2%, stesse battute, stesso danno. Non era quello |
| Tolgo il morso alla Tossina | **2% → 100%**. Era quello |

La Tossina toglieva il **3% della vita a ogni battuta e non scadeva mai**. La tua nota dice «leggeri
danni ogni turno, **meno di Fiamme**»: al turno lo era (3% contro 8%), ma le Fiamme durano 2-5 turni
e la Tossina no — in uno scontro da venti battute il totale arrivava al **60% della vita**, il
doppio di quanto fanno le Fiamme in tutta la loro durata. Il 3% era **mio**, e sbagliato.

**Ma la creatura non era rotta, e nemmeno del tutto la Tossina: era rotto il misuratore.** Nessuna
delle quattro strategie del simulatore ha mai aperto la sacca. Finché gli status non mordevano non
importava; dal giorno in cui la Tossina resta addosso *finché non ti curi*, un giocatore che non si
cura misura una cosa sola — quanto fa male non curarsi. E il Volto lascia cadere il **Fiore di
Luna**, che è esattamente l'antidoto: la contromossa c'era, e la tabella non sapeva vederla.

Quindi due cose, non una:

1. **Una quinta strategia, `si_cura`** — si porta dietro una sacca (`sacca_giocatore_tipo` in
   `crescita.json`) e la usa: prima si toglie lo status, poi beve se è sotto il 45%, poi picchia.
   Le altre quattro restano a mani vuote apposta, così le loro righe si confrontano ancora con le
   misure vecchie e **la differenza fra `attacca` e `si_cura` è il valore di sapersi curare.**
2. **Tossina dal 3% all'1,5%**, scelto misurando e non a occhio:

| Tossina | vince andandoci dritto | vince curandosi |
| --: | --: | --: |
| 3% (com'era) | 2% | 15% |
| 2% | 3% | 31% |
| **1,5% (adesso)** | **21%** | **57%** |
| 1% | 49% | 83% |

L'1,5% è il punto in cui **curarsi conta e non curarsi non è una condanna**. È un numero mio: la
misura sta dentro `stati.json` in un campo `_misura` accanto alla tua frase, e rifarla costa dieci
secondi.

### Cosa dice il giro completo, adesso

234.000 partite, 49 minuti. Le medie su tutte le 312 righe di ogni strategia:

| Modo di giocare | Vittorie medie |
| --- | --: |
| **Curandosi** | **54,2%** |
| Andandoci dritto | 50,3% |
| Studiando prima | 49,9% |
| A caso | 39,5% |
| Solo difendendosi | 2,2% |

**Il Divoratore: da 0% a 100% di vittorie** a livello 18 e 25. Il tetto alla cura ha fatto
esattamente quello che doveva, e senza toccare una sola riga della creatura.

**Il Volto sulla parete, a livello 18:** 21% andandoci dritto, 12% studiando, **57% curandosi.**
Sapere cosa portarsi dietro quasi triplica le tue probabilità: è la forma che volevi tu.

**Ma curarsi conta solo dove serve:** su 312 accoppiamenti, curarsi vince di più in **45**, uguale
in 266, meno in **1**. Non è un bottone che risolve tutto — è la risposta a certe creature e a
nessun'altra.

> **Attenzione a come si legge `si_cura`:** la sacca è la stessa a tutti i livelli. A livello 18
> quattro fiale su 1220 punti vita sono una scorta ragionevole; a livello 1 sono più vita di quanta
> ne abbia il protagonista. Quelle righe vanno lette **ai livelli in cui la creatura si incontra
> davvero**.

### Due cose nuove che ho trovato e non ho toccato

1. **Salire di livello può peggiorare uno scontro.** Il Volto sulla parete a livello 25 si vince il
   4% curandosi, contro il 57% a livello 18. È il disallineamento che fa il suo mestiere (i nemici
   non restano indietro più di 3 livelli), ma il risultato è che tornare più forti lo rende più
   duro. Va deciso da te se è quello che vuoi.
2. **«Solo difendendosi» adesso vince contro Diabolo** (a sette livelli) **e Rottami Erranti** (a
   uno). Prima vinceva solo contro Fomentado, che si brucia da solo. **Ho verificato che non è il
   tetto alla cura**: con e senza, la misura è identica al decimale. È nuovo rispetto a una tabella
   che però precede *tutto* il lavoro di questi giorni, quindi la causa sta lì in mezzo. Si trova in
   pochi minuti con `./prove/sonda.sh diabolo difendi 12` cambiando una cosa alla volta — non l'ho
   fatto perché è una domanda di bilancio, ed è tua.

---

## 6. Cosa aspetta te

In ordine di quanto blocca il lavoro. I primi tre sono quelli senza cui non posso andare avanti.

**Non ti aspetto più per andare avanti: ho messo numeri miei ovunque servisse.** Quello che segue
è roba da *correggere*, non da sbloccare — tranne le prime due, che non posso inventare io.

| | Cosa | Dove |
| --: | --- | --- |
| 1 | **Cosa evoca Yhvina** — non posso inventarla: è la sua identità e decide cosa va disegnato. Il Richiamo funziona ma chiama il vuoto | `personaggi-giocabili.md` |
| 2 | **Il disegno della costellazione** — 80 punti magenta `#FF00FF`. Il lettore è pronto e provato | mandamelo e basta |
| 3 | **La tabella dei tipi** — chi pesa su chi. L'ho scritta io con una ragione per riga | `data/tipi.json` |
| 4 | **I numeri degli status** — durate, quote, probabilità. Tutti miei | `data/stati.json` |
| 5 | **Le statistiche di Veronica** (♥160·5·4·2) **e Yhvina** (♥130·7·1·5) — proposte mie | `data/classes.json` |
| 6 | **Il ritmo dell'hype** — ×100 per scontro, 1000 per punto | `data/regole.json` |
| 7 | **Le condizioni di mediazione** dei 39 nemici | `mediazione.md` |
| 8 | **Un grado II** per ognuna delle tre linee del protagonista: gli altri quindici li propongo in scala | `personaggi-giocabili.md` |
| 9 | **Le mosse delle versioni scriptate** e dell'aiutante di Jondoh | `personaggi-giocabili.md` |
| 10 | **Il tetto alla cura di sé** (100% della vita massima) e la **soglia della vita bassa** (25%) | `data/regole.json` |
| 11 | **Quanto si sente un colpo** — durate del fermo immagine, ampiezza della scossa | `combattimento/Impatto.gd` |
| 12 | **Quanta tinta prende il fondo** (14%) e quanto sono spessi i bordi del velo (28%) | `combattimento/Arena.gd` |

---

## 7. Come si controlla il progetto da soli

Tre comandi, e non serve sapere niente di programmazione per leggerne l'esito.

| Comando | Quanto ci mette | Cosa dice |
| --- | --: | --- |
| `./prove/esegui.sh` | ~4 min | Se qualcosa si è rotto. Verde o rosso, senza sfumature |
| `./prove/simula.sh` | ~40 min | 234.000 partite giocate da sole: chi vince a che livello. Scrive `bilanciamento.md` |
| **`./prove/sonda.sh <creatura>`** | **~10 secondi** | **Una creatura sola, subito.** Cambi un numero in un file di dati e vedi immediatamente se era quello |
| `./strumenti/nemici.sh` | pochi secondi | Riscrive `nemici.md` coi numeri veri del bestiario |
| **`./strumenti/topologia.py`** | **un secondo** | Riscrive `topologia.md`: la **forma** delle mappe, non il contenuto |

> **La sonda è nuova, e serve più di quanto sembri.** Il giro completo dice *com'è messo* il
> bilanciamento; non può dire *per colpa di cosa*, perché a quella domanda si risponde cambiando una
> cosa sola e rimisurando — e se ogni misura costa quaranta minuti, non la si fa e si tira a
> indovinare. Non è un secondo simulatore: è quello, con un filtro. Stessa funzione, stesse
> strategie, stessi semi, e non riscrive `bilanciamento.md`.
>
> `./prove/sonda.sh volto_sulla_parete attacca 18`

---

## 8. I numeri del progetto, oggi

| | |
| --- | --: |
| Righe di codice (GDScript) | 19.905 |
| File di dati | 23 + 8 zone |
| Creature | 39 |
| Prove | 79, per 26.368 verifiche |
| Partite simulate | 234.000, cinque modi di giocare |
| Tipi di mossa che il motore esegue | 20 |
| Livello massimo | 130 |
| Nodi della costellazione | 80 disegnati, 60 comprabili |

---

*Il punto · aggiornato a mano quando cambia qualcosa · ramo `claude/inizio-progetto-dya2lr`*
