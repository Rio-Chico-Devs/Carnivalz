# Audio di Carnivalz

Il gioco cerca questi file da solo: **finché non ci sono, resta silenzioso senza errori**.
Basta metterli qui col nome giusto e suonano automaticamente. Nessun codice da toccare.

- **Musica**: `.ogg` consigliato (loop pulito). Va in loop automatica.
- **Versi e voci**: `.wav` consigliato (suoni brevi).

## Musica — `audio/musica/`
| File | Quando suona |
|---|---|
| `menu.ogg` | Menu principale |
| `mappa.ogg` | Mappa stellare |
| `vuoto_jerah.ogg` | Il Vuoto (sistema) di Jerah |
| `campagna_jerah.ogg` | La campagna sul pianeta (Jerah) |
| `frattura_industriale.ogg` | Squarcio Industriale |
| `frattura_teatro.ogg` | Teatro del Passato |
| `frattura_casa.ogg` | Casa Gigante |
| `frattura_kizako.ogg` | Ala Kizako |
| `frattura_fontana.ogg` | La Fontana |
| `frattura_ossidiana.ogg` | La Rocca di Ossidiana |
| `frattura_meridia.ogg` | Meridia (città zombie) |
| `battle_comune.ogg` | Combattimento vs nemici comuni |
| `battle_particolare.ogg` | Combattimento vs nemici particolari (El Malabarista, Ferraglia Urlante, Divoratore, Abominio Marcio) |
| `battle_miniboss.ogg` | Combattimento vs miniboss (la bambola) |
| `battle_boss.ogg` | Combattimento vs boss/fonte (Jerah, Jongo Dongo) |

La musica di combattimento si sceglie dalla categoria più "alta" tra i nemici presenti
(boss > miniboss > particolare > comune). Nuove tracce per fratture/Vuoti futuri: basta
aggiungere il campo `musica` nel `data/mappa.json` e mettere il file qui.

## Versi dei nemici — `audio/versi/`
Un verso alla **comparsa** e uno alla **morte** di ogni nemico.
- `<id>.wav` → verso di comparsa (usato anche alla morte se manca quello dedicato)
- `<id>_morte.wav` → verso di morte (opzionale)

Id nemici attuali: `maschera_vuota`, `giocoliere`, `comparsa_di_ruggine`, `voce_registrata`,
`operaio_posseduto`, `ferraglia_urlante`, `divoratore`, `marionetta`, `ghoul`,
`teschio_errante`, `abominio_marcio`, `zombie_cittadino`, `infetto_rapido`,
`tenero_ricordo`, `jerah`, `jongo_dongo`.
(es. `jerah.wav`, `jerah_morte.wav`, `ghoul.wav`, ...)

## Voci registrate dei boss — `audio/voci/`
Frasi registrate per boss e miniboss, per evento:
- `<id>_inizio.wav` → all'inizio dello scontro
- `<id>_cedimento.wav` → quando la fonte cede alla speranza (solo boss convincibili)
- `<id>_sconfitta.wav` → alla sconfitta della fonte

Boss/miniboss attuali: `jerah` (inizio/cedimento/sconfitta), `tenero_ricordo` (inizio/sconfitta),
`jongo_dongo` (inizio/sconfitta — non è convincibile: nessun cedimento).

## Override nei dati (opzionale)
Ogni percorso di default può essere sovrascritto nei JSON:
- nel nemico: `"growl": "res://audio/versi/xxx.wav"`, `"morte": "..."`,
  `"voci": { "inizio": "...", "cedimento": "...", "sconfitta": "..." }`
- musica di menu/mappa/combattimento: `data/audio.json`
- musica di Vuoti/campagna/fratture: campi `musica` / `musica_campagna` in `data/mappa.json`
