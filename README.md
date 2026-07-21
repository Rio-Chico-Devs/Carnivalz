# Carnivalz

RPG d'avventura narrativa dark fantasy: illustrazioni statiche, mappa stellare + eventi + scelte.
Motore in Godot (GDScript), **contenuti tutti nei JSON** sotto `data/` — mai hardcodati negli script.
Il protagonista è l'**Anonimo**: il gioco si vive in prima persona attraverso le sue avventure.

## Come si avvia
Aprire `project.godot` con Godot 4.7+ (versione standard). Flusso:
**mappa stellare** ("!" dove un Carnivalz sta avendo luogo) → click → **selezione del party**
(solo le classi sbloccate; l'Anonimo c'è sempre) → **campagna narrata** → fine → mappa.

## Struttura
- `scenes/Mappa.tscn` + `scripts/Mappa.gd` — mappa stellare (main scene), marker data-driven
- `scenes/Selezione.tscn` + `scripts/Selezione.gd` — menu del party: mostra solo le classi
  sbloccate e si riadatta man mano che i personaggi entrano o escono dai disponibili
- `scenes/Main.tscn` + `scripts/Main.gd` — motore eventi + palco dialoghi
- `scenes/Combattimento.tscn` + `scripts/Combattimento.gd` — combattimento a turni
- `scenes/Ritratto.tscn` + `scripts/Ritratto.gd` — ritratto riusabile (immagine o placeholder)
- `scripts/GameState.gd` — autoload: roster, party, inventario, livelli, RNG seedato, JSON
- `data/classes.json` — classi giocabili (`protagonista` + lista con id, nome, hp, velocita, abilita, ritratto)
- `data/personaggi.json` — personaggi non giocabili (ritratti nei dialoghi + stat se combattono)
- `data/regole.json` — numeri di bilanciamento (hp base, danno, riduzioni, rabbia)
- `data/events.json` — campagna di prova
- `data/mappa.json` — sfondo e punti della mappa stellare
- `art/` — illustrazioni di Bru: `art/mappa.png` (sfondo mappa), `art/personaggi/<id>.png`
  (ritratti). Finché mancano: placeholder generati (cielo stellato / iniziale del nome)

## Palco dialoghi
Sopra il box del narratore ci sono due spazi per i disegni: a **sinistra sempre il
protagonista** (o un alternativo, chiave `sinistra` nel nodo), a **destra l'interlocutore**
(chiave `destra`). I dialoghi sono discussioni tra almeno due persone, quindi gli spazi sono
solo due. Se il nodo ha la chiave `centro`, quel personaggio parla da solo al centro e gli
spazi laterali spariscono.

## Combattimento
Il più semplice possibile, per divertire senza mille numeri da tenere d'occhio:
- **5 HP** a testa (`hp_base`, sovrascrivibile per classe/nemico nei dati), **1 danno** ad attacco
- Party e nemici in un'unica fila d'iniziativa ordinata per **velocità**: il più veloce di
  tutti agisce per primo, 1 attacco a testa per giro
- Il danno **subìto dal party cala in proporzione al livello**: probabilità di assorbire il
  colpo = (livello − 1) × 10%, tetto 50% (a danno 1, la riduzione percentuale diventa
  naturalmente "ogni tanto il colpo non passa")
- Status **rabbia**: in rari casi (35%) concede un attacco extra nello stesso turno; scatta
  nei sopravvissuti quando un alleato va a terra
- Vittoria: +1 livello a tutto il party. Sconfitta: nodo `se_perdi` o ritorno alla mappa
- Tutti i numeri stanno in `data/regole.json`; l'RNG è quello seedato di GameState

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
Posizioni in coordinate 1280×720 (design resolution, stretch `canvas_items`). Solo i punti
con `attivo: true` mostrano il "!". Nuove campagne = nuovo JSON + nuovo punto, zero codice.

### events.json (una campagna)
```json
{
  "nodo_iniziale": "inizio",
  "nodi": {
    "id_nodo": {
      "testo": "narratore...",
      "sinistra": "anonimo",
      "destra": "meteora",
      "centro": "imbonitore",
      "scelte": [
        { "testo": "...", "vai": "altro_nodo", "richiede": "volo", "recluta": "meteora", "oggetto": "lanterna", "lascia": "meteora", "reset": true },
        { "testo": "Affrontalo", "combatti": ["imbonitore"], "se_vinci": "vittoria", "se_perdi": "sconfitta" }
      ]
    }
  }
}
```
Chiavi nodo (opzionali): `sinistra` (default: protagonista), `destra`, `centro` (esclude i lati).
Chiavi effetto sulle scelte (tutte opzionali): `vai`, `richiede` (la scelta non appare se il
party non ha l'abilità), `recluta` (sblocca la classe e la mette nel party), `oggetto`
(nell'inventario), `lascia` (la classe esce dai disponibili), `combatti` (lista di id nemici;
`se_vinci`/`se_perdi` sono i nodi di destinazione), `reset` (fine campagna, torna alla mappa;
roster, zaino e livelli restano).

## Convenzioni
- Codice e chiavi JSON in italiano
- RNG solo seedato (`GameState.rng`), mai `randi()` sparsi: determinismo e multiplayer futuro
- Il numero totale di classi non va mai mostrato: il menu elenca solo le sbloccate
- `.godot/` fuori dal repo

## Roadmap
1. ✅ Vertical slice: motore eventi + gating per abilità
2. ✅ Mappa stellare con marker "!" data-driven
3. ✅ Selezione party adattiva + palco dialoghi con ritratti
4. ✅ Combattimento a turni base (velocità, rabbia, livelli)
5. ⬜ Salvataggio (serializzare GameState)
6. ⬜ Le 10 classi vere (varianti M/F)
