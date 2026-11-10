# Le tessere dei pianeti da esplorare

Qui stanno i disegni dei mondi generati (`prove/MondoProva.tscn`): **una
cartella per bioma** (`pianure/`, `ardente/`), e dentro gli stessi nomi.
Ogni PNG si può ridisegnare o sostituire, per esempio con Aseprite o con uno
strumento come PixelLab: **il file messo qui vince** su quello che il codice sa
disegnare da solo (`prove/MondoTessere.gd`).

Quelli che ci sono adesso li ha disegnati il codice: sono provvisori, ma
seguono già le regole qui sotto, così un disegno nuovo si mette al posto di
uno vecchio senza toccare niente.

    ./prove/mondi.sh tessere     riscrive i PNG che MANCANO (gli altri non li tocca)

Per rifare un pezzo dal codice, cancella il suo file e rilancia.

## Le regole, per ogni disegno

- **16 pixel per casella.** Il gioco ingrandisce tre volte, senza sfumare.
- **Vista dall'alto e un po' di fronte**, come negli Zelda a 16 bit: i
  muri e i tronchi si vedono di faccia, i tetti e le chiome da sopra.
- **La luce viene sempre dall'alto a sinistra.** Ombra in basso a destra, e
  un'ombra ovale per terra sotto ogni cosa che sta in piedi.
- **Pochi colori, quelli della tavolozza del bioma** (`MondoTessere.TAVOLOZZE`).
  Le ombre virano al freddo, le luci al caldo.
- **Le cose hanno un contorno scuro** (il colore più scuro della loro rampa,
  mai nero puro). **Il terreno no.**
- **Niente filtri e niente effetti dentro i disegni.** La corruzione la mette
  il gioco: un disegno è sempre «come è quando è sano».
- **L'Organizzazione ha la sua livrea**: carta `#efd8b2`, segnale `#f29a2e`,
  fondo `#0b0e14`, inchiostro `#4a7aa8`. Sono i quattro colori della mappa
  stellare (`data/stile.json`, «proiezione»). Tutto quello che costruisce lei
  (faro, case, lampioni, capsula, forziere) è fatto con quelli, su ogni
  pianeta.

## I terreni: 16 pezzi ciascuno

`sabbia.png`, `terra.png`, `erba.png`, `prato.png`: **64×64, una griglia di 4×4
tessere**. È la «doppia griglia»: il mondo sa il terreno di ogni casella, e
ogni tessera si disegna a cavallo di quattro caselle. Il numero della tessera
dice in quali dei suoi **angoli** c'è quel terreno:

| angolo | vale |
|---|---|
| alto a sinistra | 1 |
| alto a destra | 2 |
| basso a sinistra | 4 |
| basso a destra | 8 |

La tessera numero *n* (la somma) sta alla colonna `n % 4` e alla riga
`n / 4`: la 0 è vuota, la 15 è piena, la 3 ha il terreno in alto, la 5 a
sinistra. Il bordo passa sempre **a metà del lato** della tessera, così due
tessere vicine combaciano.

Gli strumenti che generano terreni «Wang» o «a 16 pezzi» danno lo stesso
insieme di pezzi, magari in un altro ordine: basta rimetterli in questo.

I terreni stanno uno sopra l'altro, in quest'ordine: **acqua, sabbia, terra,
erba, erba alta** (`prato`). Ogni strato è trasparente dove non c'è.
L'acqua sta sotto tutto.

`*_varianti.png`: **64×16**, la tessera piena in quattro versioni (la prima
uguale alla numero 15). Il mondo le alterna perché il prato non sembri carta
da parati.

`acqua.png`: **64×16**, quattro fotogrammi dell'acqua (o della lava),
ripetibili su ogni lato.

## Le rupi

`rupe.png`, **64×96**:

| righe | cosa |
|---|---|
| 0 | la parete, metà di sopra (con l'orlo chiaro): sola, inizio a sinistra, in mezzo, fine a destra |
| 1 | la parete, metà di sotto (con l'ombra al piede): stessi quattro pezzi |
| 2–5 | l'orlo dell'alto: 16 pezzi, indice = 1 se si scende a nord, 2 a est, 4 a sud, 8 a ovest |

La parete è alta **due caselle** e sta sotto l'orlo sud dell'alto.

## Le cose

Ogni cosa ha un **piede**: il punto che sta per terra, al centro della sua
casella. Il gioco ordina le cose per profondità da lì.

| file | misura | piede | cos'è |
|---|---|---|---|
| `albero_1`, `albero_2` | 32×40 | 16, 36 | gli alberi (nel bioma ardente: l'agave grande e l'albero secco) |
| `cespuglio` | 16×16 | 8, 14 | |
| `sasso` | 16×16 | 8, 14 | |
| `masso` | 32×28 | 16, 26 | |
| `rovi`, `rovi_2` | 16×16 | 8, 14 | la corruzione del Carnivalz: col colore della fonte |
| `vena_quarzo`, `vena_ferro`, `vena_cristallo`, `vena_vuota` | 16×16 | 8, 14 | le risorse, e la vena scavata |
| `faro_rotto`, `faro` | 32×48 | 16, 44 | il cuore della regione: spento e riparato |
| `modulo` | 32×32 | 16, 28 | la casa che compare quando la regione è tua |
| `lampione` | 16×32 | 8, 29 | |
| `capsula` | 32×32 | 16, 29 | dove si atterra |
| `forziere` | 16×16 | 8, 14 | |

Per terra, senza piede (riempiono la casella):

| file | misura | cos'è |
|---|---|---|
| `fiori` | 16×16 | non fermano il cammino |
| `campo` | 16×16 | il campo coltivato della colonia |
| `ponte_rotto_o`, `ponte_o` | 16×16 | una casella di ponte, attraversato da ovest a est |
| `ponte_rotto_v`, `ponte_v` | 16×16 | attraversato da nord a sud |
| `scala_rotta`, `scala` | 16×32 | la scala nella parete della rupe (le due caselle di parete) |

## I protagonisti

`protagonista/lui.png` e `protagonista/lei.png`, **72×96**: i due protagonisti
dai disegni di Bru, uguali su ogni pianeta (per questo non stanno nelle
cartelle dei biomi). Tre righe (giù, su, destra; la sinistra è la destra allo
specchio) e tre colonne (fermo, passo, altro passo), **24×32** l'una, con
l'ombra per terra già dentro. I piedi stanno a **12, 30** di ogni fotogramma.

Li disegna `prove/MondoProtagonisti.gd`, pixel per pixel, coi colori presi
dal foglio in pixel art di Bru. Nel gioco **P** passa da lui a lei.
