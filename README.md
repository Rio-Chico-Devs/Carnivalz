# Carnivalz

RPG d'avventura narrativa dark fantasy: illustrazioni statiche, mappa stellare + eventi + scelte.
Motore in Godot (GDScript), **contenuti tutti nei JSON** sotto `data/` — mai hardcodati negli script.

## Come si avvia
Aprire `project.godot` con Godot 4.7+ (versione standard). La main scene è la mappa stellare:
un "!" pulsa dove un Carnivalz sta avendo luogo; click → si entra nella campagna narrata.

## Struttura
- `scenes/Mappa.tscn` + `scripts/Mappa.gd` — mappa stellare (main scene), marker data-driven
- `scenes/Main.tscn` + `scripts/Main.gd` — motore eventi: nodi, scelte filtrate per requisiti, effetti
- `scripts/GameState.gd` — autoload: party, inventario, RNG seedato, caricamento JSON
- `data/classes.json` — classi (id, nome, hp, abilita)
- `data/events.json` — campagna di prova (nodi ed effetti)
- `data/mappa.json` — sfondo e punti della mappa stellare
- `art/` — illustrazioni di Bru (`art/mappa.png` = sfondo mappa; finché manca, cielo placeholder)

## Formato dati

### mappa.json
```json
{
  "sfondo": "res://art/mappa.png",
  "punti": [
    { "id": "...", "nome": "...", "pos": [x, y], "attivo": true, "file_eventi": "res://data/....json" }
  ]
}
```
Le posizioni sono in coordinate 1280×720 (design resolution, stretch `canvas_items`).
Solo i punti con `attivo: true` mostrano il "!". Ogni punto indica il suo file eventi:
nuove campagne = nuovo JSON + nuovo punto, zero codice.

### events.json (una campagna)
```json
{
  "nodo_iniziale": "inizio",
  "nodi": {
    "id_nodo": {
      "testo": "narratore...",
      "scelte": [
        { "testo": "...", "vai": "altro_nodo", "richiede": "volo", "recluta": "meteora", "oggetto": "lanterna", "reset": true }
      ]
    }
  }
}
```
Chiavi effetto (tutte opzionali): `vai`, `richiede` (la scelta non appare se il party non ha
l'abilità), `recluta` (id classe nel party), `oggetto` (nell'inventario), `reset` (fine campagna,
torna alla mappa).

## Convenzioni
- Codice e chiavi JSON in italiano
- RNG solo seedato (`GameState.rng`), mai `randi()` sparsi: determinismo e multiplayer futuro
- `.godot/` fuori dal repo

## Roadmap
1. ✅ Vertical slice: motore eventi + gating per abilità
2. ✅ Mappa stellare con marker "!" data-driven
3. ⬜ Combattimento a turni base
4. ⬜ Salvataggio (serializzare GameState)
5. ⬜ Le 10 classi vere (varianti M/F)
