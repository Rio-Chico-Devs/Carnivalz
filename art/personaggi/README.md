# Ritratti dei personaggi

Ogni personaggio ha una cartella con le sue **espressioni** per i dialoghi:

```
art/personaggi/<id>/<espressione>.png
```

Esempio: `art/personaggi/anonimo/neutra.png`, `art/personaggi/anonimo/arrabbiata.png`, ...

Il gioco carica l'espressione richiesta dal dialogo. Se manca, ripiega su `neutra.png`;
se manca anche quella, sul vecchio file singolo `art/personaggi/<id>.png`; se manca tutto,
mostra un segnaposto con l'iniziale. Quindi puoi disegnarle a poco a poco senza rompere nulla.

Il nome del file **non e' sempre l'id**: lo decide il campo `ritratto` nei dati. Yhvina ha id
`insonne` ma il suo ritratto singolo si chiama `yhvina.png` (la cartella delle espressioni,
invece, si chiama sempre come l'id: `art/personaggi/insonne/`). L'elenco esatto per ognuno,
generato dai dati, sta in `docs/immagini.md`.

## Le 16 espressioni
`neutra` · `arrabbiata` · `felice` · `carina` · `infastidita` · `disgusto` · `speciale` ·
`dialogo` · `delusa` · `petrificata` · `annoiata` · `pensiero` · `sorpresa` · `sforzo` ·
`cool` · `decisa`

(La `neutra` è quella di default: conviene farla per prima per ogni personaggio.)

**Non sono una gabbia.** `espr` è semplicemente il nome del file: se una scena chiede
`"espr": "sotto_la_pioggia"`, basta che esista `sotto_la_pioggia.png`. Le 16 servono perché
avere sempre gli stessi nomi rende riusabili i disegni fra una scena e l'altra — ma quando una
scena ha bisogno di una faccia sua, se la prende.

`prove/Prove.gd` controlla i nomi dei file: non pretende che i disegni ci siano, ma un file che
**nessun dialogo chiede** fa fallire le prove. È l'unico modo di accorgersi di un nome scritto
storto, che altrimenti diventa in silenzio il segnaposto con l'iniziale.

## Chi compare nei dialoghi (dungeon 1)
- `anonimo` — il protagonista, sempre a sinistra
- `jerah` — la fonte
- `giocoliere` — El Muy Bonito (sub-boss)
- `vecchio_clown` — il Vecchio Proprietario del teatro (Raphael, Genio del Teatro)
- `insonne` — Yhvina
(gli altri sono soprattutto nemici da combattimento: basta la loro immagine di ritratto)

## Come sceglie l'espressione un dialogo
Nel nodo evento, i lati del palco possono indicare l'espressione:
```json
"destra": { "id": "jerah", "espr": "arrabbiata" }
```
oppure, forma breve equivalente:
```json
"destra": "jerah",
"espr_destra": "arrabbiata"
```
Valgono anche `espr_sinistra` e `espr_centro`. Senza indicazione: `neutra`.

## E battuta per battuta

Quella qui sopra è la faccia con cui il personaggio **entra in scena**. Dentro la `sequenza`,
ogni singolo messaggio può cambiarla:

```json
"sequenza": [
  { "tipo": "dialogo", "chi": "insonne", "testo": "Non dormo da tre giorni.", "espr": "delusa" },
  { "tipo": "dialogo", "chi": "insonne", "testo": "Ma sto benissimo.", "espr": "cool" }
]
```

Vale su qualunque lato del palco. Un'espressione dura finché qualcuno non la cambia: una
battuta senza `espr` tiene quella di prima.
