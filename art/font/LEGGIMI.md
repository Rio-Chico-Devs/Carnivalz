# I caratteri del gioco

Stanno qui dentro perche' un gioco si legge uguale su ogni macchina solo se
porta con se' i suoi caratteri. Quelli di sistema (Impact, Haettenschweiler)
non si possono incorporare in un'applicazione: questi si'.

| file | carattere | dove si usa | licenza |
|---|---|---|---|
| `titolo.ttf` | **Archivo corsivo**, a due assi variabili: peso e larghezza (Omnibus-Type, The Archivo Project Authors) | il grottesco nero del manifesto: titoli, etichette, voci, strisce, pillole; e dall'8 ottobre anche le scritte della mappa stellare, del Vuoto e dei plastici (Bru: «variante 3 sia») | SIL Open Font License 1.1 — `OFL-Archivo.txt` |
| `arrotondato.ttf` | **Nunito**, a peso variabile (The Nunito Project Authors) | le scritte piccole del menu principale: intestazione, descrizioni, comandi | SIL Open Font License 1.1 — `OFL-Nunito.txt` |
| `fiaba.ttf` | **Italianno**, calligrafico (Robert Leuschke, The Italianno Project Authors) | il racconto a schermo intero: l'inizio del gioco e dei livelli | SIL Open Font License 1.1 — `OFL-Italianno.txt` |
| `dialoghi.ttf` | **Bricolage Grotesque**, a tre assi variabili: corpo ottico, larghezza, peso (Mathieu Triay, The Bricolage Grotesque Project Authors) | il box dei dialoghi: dialoghi, narrazione, notifiche, il diario del combattimento | SIL Open Font License 1.1 — `OFL-BricolageGrotesque.txt` |
| `nomi.ttf` | **IM Fell English SC**, maiuscoletto (Igino Marini, dai caratteri Fell della stamperia di Oxford) | i nomi di chi parla: il nastro rosa, la riga del nome nel box, lo storico | SIL Open Font License 1.1 — `OFL-IMFell.txt` |

Presi dal repository ufficiale di Google Fonts (`google/fonts`, cartelle
`ofl/archivo`, `ofl/nunito`, `ofl/italianno`, `ofl/bricolagegrotesque` e `ofl/imfellenglishsc`). La licenza OFL permette
di incorporarli e distribuirli col gioco, anche venduto, purche' il testo della
licenza li accompagni: e' il motivo dei file `OFL-*.txt` qui accanto, che non
vanno tolti.

Per cambiarli basta sostituire il `.ttf` tenendo lo stesso nome (o scrivere un
altro percorso in `data/stile.json`, sezione `font`).

Archivo ha preso il posto di Anton il 29 settembre, coi bozzetti del manifesto
che Bru ha approvato («bene mi piace! approvato»). Quanto e' nero e quanto e'
stretto lo dicono gli assi in `data/stile.json` (sezioni `titoli`, `voci`,
`strisce`): e' lo stesso file per le etichette, per le voci strette del
combattimento e per le strisce larghe e spaziate.
