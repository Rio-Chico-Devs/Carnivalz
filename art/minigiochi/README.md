# I disegni dei minigiochi

Un minigioco disegna le sue cose da solo finché il disegno non c'è. Quando lo
metti qui, vince il tuo.

```
art/minigiochi/<nome>.png
```

## Quello che serve adesso

| file | cos'è | come viene usato |
|---|---|---|
| `pugno.png` | un pugno di Veronica, quelli delle **Collisioni infinite** | compare nel quadrante, ci clicchi sopra per fermarlo |

**Quadrato**, o quasi: il gioco lo mette dentro una casella quadrata e lo
allarga fino a riempirla. Un pugno disegnato largo e basso viene stiracchiato.

**Con lo sfondo trasparente.** Il quadrante è bianco: un PNG con il fondo bianco
dentro si vede come un francobollo.

**Grande basta.** A schermo viene circa 70 pixel di lato, ma la finestra può
essere più grande della mia: disegnalo almeno 256×256 e non ci pensiamo più.

Finché non c'è, al suo posto c'è un cerchio rosso col bordo chiaro. Non è un
segnaposto per modo di dire — ha la misura e il tempo che avrà il tuo disegno,
quindi il minigioco si può già giocare e soprattutto si può già **bilanciare**.

Per guardarlo:

```
./prove/scatto.sh collisioni        # la raffica a metà
./prove/scatto.sh collisioni 80     # più avanti nel tempo
```

## Se un pugno arriva troppo in fretta (o troppo piano)

I numeri non stanno nel codice, stanno nel copione dell'allenamento, in
`data/personaggi.json` sotto `veronica` → `tutorial_combattimento`:

```json
"minigioco": { "quanti": 14, "intervallo": 0.34, "durata": 0.52, "danno": 9 }
```

- **quanti** — quanti pugni in tutto
- **intervallo** — ogni quanti secondi ne parte uno (non è un metronomo: ognuno
  sbanda un po', se no si impara a memoria in tre battute)
- **durata** — per quanto resta a schermo. Si para solo per i primi due terzi:
  la coda è il pugno che ti ha già preso e sta rientrando
- **danno** — quanto pesa ognuno che non fermi

Pararli **tutti** azzera il danno. È voluto, ed è il motivo per cui la finestra
è così stretta: «deve essere molto difficile pararli tutti senno sei
invincibile».
