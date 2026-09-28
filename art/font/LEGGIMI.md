# I caratteri del gioco

Stanno qui dentro perche' un gioco si legge uguale su ogni macchina solo se
porta con se' i suoi caratteri. Quelli di sistema (Impact, Haettenschweiler)
non si possono incorporare in un'applicazione: questi si'.

| file | carattere | dove si usa | licenza |
|---|---|---|---|
| `titolo.ttf` | **Anton** (The Anton Project Authors) | titoli, voci del menu principale, cartigli della pausa | SIL Open Font License 1.1 — `OFL-Anton.txt` |
| `arrotondato.ttf` | **Nunito**, a peso variabile (The Nunito Project Authors) | le scritte piccole del menu principale: intestazione, descrizioni, comandi | SIL Open Font License 1.1 — `OFL-Nunito.txt` |
| `fiaba.ttf` | **Cormorant Garamond corsivo**, a peso variabile (Christian Thalmann, The Cormorant Project Authors) | il racconto a schermo intero: l'inizio del gioco e dei livelli | SIL Open Font License 1.1 — `OFL-CormorantGaramond.txt` |

Presi dal repository ufficiale di Google Fonts (`google/fonts`, cartelle
`ofl/anton`, `ofl/nunito` e `ofl/cormorantgaramond`). La licenza OFL permette
di incorporarli e distribuirli col gioco, anche venduto, purche' il testo della
licenza li accompagni: e' il motivo dei file `OFL-*.txt` qui accanto, che non
vanno tolti.

Per cambiarli basta sostituire il `.ttf` tenendo lo stesso nome (o scrivere un
altro percorso in `data/stile.json`, sezione `font`).
