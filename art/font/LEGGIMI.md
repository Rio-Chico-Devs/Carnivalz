# I caratteri del gioco

Stanno qui dentro perche' un gioco si legge uguale su ogni macchina solo se
porta con se' i suoi caratteri. Quelli di sistema (Impact, Haettenschweiler)
non si possono incorporare in un'applicazione: questi si'.

| file | carattere | dove si usa | licenza |
|---|---|---|---|
| `titolo.ttf` | **Anton** (The Anton Project Authors) | titoli, voci del menu principale, cartigli della pausa | SIL Open Font License 1.1 — `OFL-Anton.txt` |
| `arrotondato.ttf` | **Nunito**, a peso variabile (The Nunito Project Authors) | le scritte piccole del menu principale: intestazione, descrizioni, comandi | SIL Open Font License 1.1 — `OFL-Nunito.txt` |
| `fiaba.ttf` | **Italianno**, calligrafico (Robert Leuschke, The Italianno Project Authors) | il racconto a schermo intero: l'inizio del gioco e dei livelli | SIL Open Font License 1.1 — `OFL-Italianno.txt` |
| `dialoghi.ttf` | **Bricolage Grotesque**, a tre assi variabili: corpo ottico, larghezza, peso (Mathieu Triay, The Bricolage Grotesque Project Authors) | il box dei dialoghi: dialoghi, narrazione, notifiche, il diario del combattimento | SIL Open Font License 1.1 — `OFL-BricolageGrotesque.txt` |
| `nomi.ttf` | **IM Fell English SC**, maiuscoletto (Igino Marini, dai caratteri Fell della stamperia di Oxford) | i nomi di chi parla: il nastro rosa, la riga del nome nel box, lo storico | SIL Open Font License 1.1 — `OFL-IMFell.txt` |
| `fregi.ttf` | **EB Garamond** (Georg Duffner, Octavio Pardo, The EB Garamond Project Authors) | i fregi dei tipografi: la fogliolina ❧ davanti al nome sul nastro | SIL Open Font License 1.1 — `OFL-EBGaramond.txt` |

Presi dal repository ufficiale di Google Fonts (`google/fonts`, cartelle
`ofl/anton`, `ofl/nunito`, `ofl/italianno`, `ofl/bricolagegrotesque`, `ofl/imfellenglishsc` e `ofl/ebgaramond`). La licenza OFL permette
di incorporarli e distribuirli col gioco, anche venduto, purche' il testo della
licenza li accompagni: e' il motivo dei file `OFL-*.txt` qui accanto, che non
vanno tolti.

Per cambiarli basta sostituire il `.ttf` tenendo lo stesso nome (o scrivere un
altro percorso in `data/stile.json`, sezione `font`).
