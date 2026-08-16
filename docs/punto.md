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
| **`personaggi-giocabili.md`** | 📝 | Protagonista, Veronica, Yhvina: 54 mosse con livello e costo, più le versioni scriptate | ⚠️ 4 buchi, sotto |
| **`mediazione.md`** | 📝 | I 39 nemici, con la colonna «a che condizioni ascolta» da riempire | ⚠️ 38 righe vuote |
| **`storia.md`** | 📝 | La trama, i Vuoti, l'Organizzazione | 🕓 fermo a prima dell'hype |
| **`testi_da_correggere.md`** | 📝 | Ogni riga di dialogo del gioco, in un posto solo | 🕓 grande, mai riletto tutto |
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

**Come si controlla che sia vero:** `./prove/esegui.sh` — **68 prove, 25.575 verifiche**, gira in
circa quattro minuti. Ogni prova nuova la valido rompendo apposta la meccanica che misura: se non
diventa rossa, la prova non serve a niente e la riscrivo.

---

## 4. Deciso **ma non ancora nel motore** — il divario fra carta e codice

Questa è la parte che conta di più in un punto della situazione, ed è la più facile da nascondere.
Sono cose su cui abbiamo già deciso e che **oggi il gioco non fa**.

| Cosa avevamo deciso | Cosa fa il gioco oggi | Quanto pesa |
| --- | --- | --- |
| **L'hype**: moneta unica, livello = nodi comprati, mondo sulla media della squadra | **Non esiste.** C'è ancora l'xp classica con la curva `10 × lv^1.5` | 🔴 grosso |
| **Gli 8 status** (Terrore, Fiamme, Tossina, Sonno, Maledizione, Rabbia, Provocato, Frastornato) | Ce ne sono 10 e sono i vecchi: `veleno`, `berserk`, `confusione`, più egocentrismo/demotivazione/rapidità/lentezza che non sono nella tua lista. **Fiamme e Provocato non esistono come status** | 🔴 grosso |
| **I 5 tipi** (Natura·Artificio·Spirituale·Speciale·Tetro) al posto di `elemento` | I tipi sono scritti su tutte e 39 le creature, **ma il motore calcola ancora su `elemento`** (fuoco, veleno, oscuro…). Metà lavoro | 🟡 medio |
| **La costellazione** — 80 nodi disegnati a mano | Il lettore PNG è pronto e provato, **ma il disegno non è ancora arrivato** | 🟡 aspetta te |
| **Libreria di mosse** — una mossa generica riusabile, con testo diverso per ogni creatura che la usa | Ogni mossa è scritta dentro la creatura che la usa. Se due creature fanno la stessa cosa, è scritta due volte | 🟡 medio |
| **Maestria del dominio per personaggio** | È una sola, del protagonista: Veronica e Yhvina usano la sua | 🟢 piccolo |
| **Veronica e Yhvina giocabili** | Nei dati c'è solo la Veronica del tutorial (invincibile, zero mosse). Le 36 mosse sono scritte nel documento, **non nei dati** | 🔴 grosso |

**Perché non le ho già fatte.** Le prime due si mordono la coda con quello che devi ancora
decidere: gli status vogliono i numeri (quanti turni, quanto indebolisce), l'hype vuole sapere
quanto rende ogni nemico prima di poterlo tarare. Farli adesso vorrebbe dire inventare i numeri e
poi rifare tutto quando arrivano i tuoi. **Dimmi da quale partire e parto**: se preferisci che li
faccia con numeri miei da correggere dopo, lo faccio — basta saperlo.

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

| | Cosa | Dove scriverlo |
| --: | --- | --- |
| 1 | **Statistiche di partenza di Veronica e Yhvina** — senza non le posso montare né misurare | `personaggi-giocabili.md` |
| 2 | **Cosa evoca Yhvina** — è la sua identità, e decide cosa va disegnato | `personaggi-giocabili.md` |
| 3 | **Il disegno della costellazione** — 80 punti magenta `#FF00FF`. Il lettore è pronto | mandamelo e basta |
| 4 | **Le condizioni di mediazione** dei 39 nemici, o anche solo dei comuni | `mediazione.md` |
| 5 | **Un grado II** per ognuna delle tre linee del protagonista: gli altri quindici li propongo in scala | `personaggi-giocabili.md` |
| 6 | **I numeri degli status** — quanti turni, quanto indebolisce, quanto fa male nel tempo | `manuale.md` |
| 7 | **Le mosse delle versioni scriptate** (Yhvina della Casa Gigante, Veronica del tutorial) e dell'aiutante di Jondoh | `personaggi-giocabili.md` |

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
| Righe di codice (GDScript) | 17.745 |
| File di dati | 22 + 8 zone |
| Creature | 39 |
| Prove | 68, per 25.575 verifiche |
| Tipi di mossa che il motore esegue | 20 |
| Livello massimo | 130 |
| Nodi della costellazione | 80 disegnati, 60 comprabili |

---

*Il punto · aggiornato a mano quando cambia qualcosa · ramo `claude/inizio-progetto-dya2lr`*
