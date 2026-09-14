# Le mappe disegnate

Una zona può avere la sua mappa come **disegno** invece che come griglia di
quadratini. Il disegno è tuo; il gioco ci mette sopra i riquadri cliccabili e
i segni (dove sei, dove devi andare, dove sei già stato).

```
art/mappe/<nome>.png
```

## Due mappe possibili, e sceglie il file dei dati

| | quando | com'è |
|---|---|---|
| **griglia** | squarci, dungeon, labirinti | quadratini che si accendono camminando. Si costruisce da sé: non serve disegnarla |
| **disegno** | il complesso, i posti che hanno una pianta | il tuo disegno, con le aree sopra |

La griglia resta giusta dov'è: un labirinto che si scopre un pezzo alla volta
si racconta bene a quadretti, ed è anche il motivo per cui quel modo esiste.
Un edificio no — di un edificio esiste la pianta, e la pianta la disegna chi
lo ha immaginato.

## Cosa serve da te, per ogni mappa disegnata

**Il disegno.** PNG, orizzontale, alla misura che ti è comoda. Più grande è
meglio è: il gioco lo rimpicciolisce per farlo stare nella cornice, e lo
rimpicciolisce intero — non lo deforma mai, una pianta stiracchiata non è più
una pianta.

**Le coordinate delle aree.** Per ogni area, un rettangolo in **pixel del tuo
file**, letto in qualunque programma di disegno:

```json
{ "id": "sala_allenamento", "nome": "Sala di allenamento",
  "riquadro": [980, 400, 460, 280], "icona": "obiettivo" }
```

cioè `[x, y, larghezza, altezza]` con l'origine in alto a sinistra.

**E la misura del foglio**, una volta sola per mappa:

```json
"disegno": "res://art/mappe/complesso.png",
"misura_disegno": [1920, 1080]
```

Va dichiarata anche se il disegno c'è: così le prove controllano che i
rettangoli stiano dentro il foglio e non si accavallino **senza dover aprire
l'immagine** — e tu puoi scrivere le coordinate mentre il disegno è ancora in
lavorazione, invece che dopo.

## Cosa NON devi disegnarci sopra

- **i corridoi come linee di collegamento.** Su una griglia il gioco disegna le
  linee fra le stanze perché non c'è altro modo di dire che comunicano. Sul tuo
  disegno i corridoi ci sono già: il gioco smette di disegnare linee da solo.
  I collegamenti nei dati restano — decidono **dove si può andare**, che è
  logica e non grafica — semplicemente non si vedono più.
- **il "sei qui", il punto esclamativo, i punti interrogativi.** Li mette il
  gioco, e cambiano mentre giochi: quello che hai visitato, quello che sai
  esistere, quello dove devi andare. Se li disegnassi resterebbero fermi.

## Finché il disegno non c'è

Si vede il foglio vuoto, col suo bordo, e le aree al loro posto sopra. Non è un
errore ed è utile: si può sistemare la disposizione prima che il disegno sia
finito, e si vede se un'area è finita dove non doveva.

Per guardarlo:

```
./prove/scatto.sh complesso
```

## Le icone

Un'area può chiedere un'icona con `"icona": "<nome>"`. Quelle che esistono:
`boss` · `miniboss` · `forte` · `uscita` · `negozio` · `personaggio` · `chiave` ·
`obiettivo`.

`obiettivo` è il punto esclamativo che salta, ed è l'unica che si vede **prima**
di essere stati in quel posto: le altre raccontano cosa hai trovato, questa dove
devi andare.

Anche le icone si possono disegnare: `art/icone_mappa/<nome>.png` e quello vince
su quella disegnata dal codice.
