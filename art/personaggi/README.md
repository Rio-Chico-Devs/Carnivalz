# Ritratti dei personaggi

Ogni personaggio ha una cartella con le sue **espressioni** per i dialoghi:

```
art/personaggi/<id>/<espressione>.png
```

Esempio: `art/personaggi/anonimo/neutra.png`, `art/personaggi/anonimo/arrabbiata.png`, ...

Il gioco carica l'espressione richiesta dal dialogo. Se manca, ripiega su `neutra.png`;
se manca anche quella, sul vecchio file singolo `art/personaggi/<id>.png`; se manca tutto,
mostra un segnaposto con l'iniziale. Quindi puoi disegnarle a poco a poco senza rompere nulla.

## Le 16 espressioni
`neutra` · `arrabbiata` · `felice` · `carina` · `infastidita` · `disgusto` · `speciale` ·
`dialogo` · `delusa` · `petrificata` · `annoiata` · `pensiero` · `sorpresa` · `sforzo` ·
`cool` · `decisa`

(La `neutra` è quella di default: conviene farla per prima per ogni personaggio.)

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
