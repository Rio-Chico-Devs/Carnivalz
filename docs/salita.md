# La salita di livello: la schermata vera

Bru: «cominciamo a fare la schermata di crescita vera proponimi dei design e ci
lavoriamo insieme, le animazioni che ho visto per la ruota per cosa erano
destinate? quando le avrei viste nel gioco?»

## 1. A cosa servivano i film della ruota

Erano prove di come si sarebbero mosse le schermate della crescita. Le ha girate
`prove/ProposteCrescita.gd` (`-- film ...`), servivano per scegliere l'aspetto, e
nel gioco non ci sono mai state.

- **`in_movimento.mp4`**: le tre schermate approvate, in movimento:
  - la **ruota**: la lancetta scorre sulle tasche e la ruota ci arriva con una
    molla; la lastra a sinistra cambia (ARRIVI AL, PIÙ AVANTI, GIÀ PRESO);
  - il **bivio**: si sceglie una strada, il taglio si sposta, si prende, l'altra
    strada viene spazzata via e compare il timbro LIVELLO 8;
  - le **passive**: si porta una passiva nel terzo alloggio.
- **`i_sette_giri.mp4`**: il giro chiuso che passa al prossimo, col sipario
  («TERZO GIRO · LIVELLI 41–60») e un aspetto nuovo, fino al 130.

Nel gioco si sarebbero viste **ogni volta che si spende un punto** (1000 hype),
cioè ogni volta che si sale di livello. Il passaggio fra un giro e l'altro si
sarebbe visto al 20, al 40 e così via; nella beta, che si ferma al 20, c'è al suo
posto il giro chiuso col tetto.

Non si vedono perché **manca proprio questa schermata**. Comprare un livello il
gioco lo sa già fare (`GameState.sblocca_nodo`, che converte anche le azioni in
statistiche), ma lo chiamano solo le prove. Il trucco dell'hype riempie il
mucchio, e poi non c'è un tasto per spenderlo.

## 2. Cosa deve dire la schermata, a ogni punto speso

1. **Si sale di un livello.** Un punto è una tasca, cioè un livello.
2. **Si sceglie una strada del bivio**, per esempio più vita o più attacco.
3. **Le azioni diventano statistiche, col loro perché.**
   - Viene da `GameState.applica_crescita_livello`: «+6 attacco per i colpi che
     hai tirato (30)».
   - È l'unico momento in cui si scopre a cosa è servito giocare come si è
     giocato.
   - Oggi lo dice solo una riga di testo nel resoconto (`Resoconto.gd`).
4. **A certi livelli arriva un'abilità o una passiva.**

## 3. Tre direzioni

Le tavole sono in `scatti/proposte_salita/`, si rifanno con
`./prove/proposte_salita.sh` e vengono da `prove/ProposteSalita.gd`. I numeri
sono veri:

- il protagonista d'esempio passa dal 7 all'8: il bivio è fra vita e attacco, e
  arriva Vendetta;
- le azioni sono quelle del giocatore tipo di `crescita.json`, convertite con gli
  stessi conti del gioco.

| | come | pro | contro |
|---|---|---|---|
| **A · Il banco** | Uno schermo solo: la ruota resta e cambia la lastra a sinistra (cosa dà, poi le due strade, poi cosa è cresciuto). | È la più veloce: cinque punti di fila senza cambiare schermo. | Il bivio approvato diventa due schede piccole. |
| **B · Tre tempi** | Ogni momento a tutto schermo: la ruota, il bivio approvato, il salto (il livello enorme e il perché), la carta di quello che arriva. | Usa i pezzi approvati così come sono, e il perché ha un momento suo. | Sono più schermate per punto. ESC salta tutto, sempre. |
| **C · La ruota gira** | Solo la ruota, al centro: il mozzo si spacca in due lungo il taglio del bivio, e la carta esce dalla tasca. | È la più da luna park: la ruota è il palco. | Il bivio sta in un cerchio, e il perché in una colonna stretta. |

Nelle barrette di crescita i colori sono sempre gli stessi:

- **grigio**: quello che avevi;
- **pieno**: quello che ti hanno dato le azioni;
- **arancio**: quello che ti ha dato la strada.

Il perché è scritto sotto, negli stessi colori.

**Il consiglio: la B.**

- Mette in fila proprio le tre schermate approvate e aggiunge il salto, cioè il
  momento che oggi manca (albero.md 4.8: «si deve vedere, e sentire»).
- Nella beta si sale diciannove volte in tutto, e ogni salita può prendersi il
  suo spazio.
- Chi ha fretta preme ESC.
- Dalla C si può prendere la carta che esce dalla tasca.

## 4. Da dove ci si entra

- **Dalla pausa**: una voce «Crescita» fra Zaino e Personaggio e squadra, col
  numero dei punti da spendere quando ce ne sono.
- **Dal resoconto di fine scontro**: dove oggi dice «Hai N punti da spendere», un
  tasto per andarci subito.
- **Le schede in alto** (Anonimo, Veronica, Yhvina): l'hype è di tutta la
  squadra, e si sceglie su chi spenderlo.

## 5. Le domande per Bru

1. A, B o C? Oppure un pezzo di una dentro l'altra.
2. Si entra dalla pausa e dal resoconto: va bene così?
3. Il punto più grosso, che è anche quello di albero.md §5 (domande 1 e 3).
   - La ruota è **tutta** la crescita: un punto, una tasca, un livello.
   - Allora l'albero a costellazione con i nodi ai livelli 25, 29… non serve più.
   - Senza questa risposta la schermata si può disegnare, ma non attaccare al
     gioco.
4. Veronica e Yhvina hanno la loro ruota, con le loro tasche, nella stessa
   schermata?
