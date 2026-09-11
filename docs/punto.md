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
| **`nemici.md`** | ⚙️ | Il bestiario coi numeri veri: mosse, quote, danni. `./strumenti/nemici.sh` | ✅ rigenerato oggi |
| **`bilanciamento.md`** | ⚙️ | 187.200 partite simulate: chi vince a che livello. `./prove/simula.sh` | 🕓 da rilanciare |
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
| **Armi con attacchi propri**, sotto Abilità | `GameState.attacchi_arma` |
| **Salvataggio a 5 slot** + autosalvataggio | `GameState` |

**Come si controlla che sia vero:** `./prove/esegui.sh` — **72 prove, 26.227 verifiche**, gira in
circa quattro minuti. Ogni prova nuova la valido rompendo apposta la meccanica che misura: se non
diventa rossa, la prova non serve a niente e la riscrivo.

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
- **`bilanciamento.md` è vecchio.** Ho cambiato status, tipi e progressione tutti nello stesso
  giorno: i numeri lì dentro misurano un gioco che non c'è più. Va rilanciato `./prove/simula.sh`
  (21 minuti) — ma ha senso farlo dopo che avrai corretto i miei numeri, non prima.

---

## 5. Problemi noti, misurati, **non toccati apposta**

Li ha trovati il simulatore. Non li ho sistemati perché sono di bilancio, e il bilancio ha senso
quando le armi e l'hype sono al loro posto — non prima.

| Chi | Cosa succede |
| --- | --- |
| **Il Divoratore** | Si cura del **145%** di quello che gli fai. Al primo incontro è imbattibile |
| **Oppresso · Robo Pattuglia** | Guardia cumulativa senza contrappeso: diventano scontri da **30 giri** |
| **Fomentado** | La sua combustione lo uccide da sola. Vince chi aspetta |

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

---

## 7. Come si controlla il progetto da soli

Tre comandi, e non serve sapere niente di programmazione per leggerne l'esito.

| Comando | Quanto ci mette | Cosa dice |
| --- | --: | --- |
| `./prove/esegui.sh` | ~4 min | Se qualcosa si è rotto. Verde o rosso, senza sfumature |
| `./prove/simula.sh` | ~21 min | 187.200 partite giocate da sole: chi vince a che livello. Scrive `bilanciamento.md` |
| `./strumenti/nemici.sh` | pochi secondi | Riscrive `nemici.md` coi numeri veri del bestiario |

---

## 8. I numeri del progetto, oggi

| | |
| --- | --: |
| Righe di codice (GDScript) | 18.731 |
| File di dati | 23 + 8 zone |
| Creature | 39 |
| Prove | 72, per 26.227 verifiche |
| Tipi di mossa che il motore esegue | 20 |
| Livello massimo | 130 |
| Nodi della costellazione | 80 disegnati, 60 comprabili |

---

*Il punto · aggiornato a mano quando cambia qualcosa · ramo `claude/inizio-progetto-dya2lr`*
