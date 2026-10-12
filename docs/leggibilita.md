# Le scritte che non si leggono — 12 ottobre 2026

Bru: *«nell'inserimento nome giocatore non si legge la scritta, cerca per altri
punti dove le scritte non sono visibili, specialmente nel menu principale in
tutte le sue parti, o perché i colori non sono giusti o per qualsiasi altro
motivo».*

Il colore di una scritta non è giusto o sbagliato da solo: dipende da cosa ha
dietro, e cosa ha dietro lo sa solo lo schermo. Per questo ho guardato le foto
vere, non il codice: `prove/Leggibilita.gd` fotografa ogni schermata, trova le
lettere e misura il loro contrasto col fondo (come funziona: README, «Le
scritte si leggono?»).

Guardate: le 30 schermate del menu principale (titolo, menu, nuova partita,
nome, carica e cancella, collezioni, come si gioca, opzioni, extra e codice,
album, bestiario, compendio) e le 10 della pausa, ognuna normale, con l'alto
contrasto e col testo grande: 120 foto.

## Cosa non si leggeva, e perché

| # | Dove | Perché | Prima | Dopo |
|--:|---|---|---|---|
| 1 | **Il nome del giocatore** (quello che hai visto tu) | lettere crema su una riga crema: il colore era quello pensato per il nero, rimasto quando le righe del menu sono diventate carta | invisibile | 16:1 |
| 2 | **Il codice degli Extra** | stesso campo, stesso difetto | invisibile | 16:1 |
| 3 | **Le opzioni, la riga col fuoco** (Audio, Grafica, Accessibilità) | la scritta chiara sulla banda nera; il foglio, un attimo dopo, la «correggeva» in nera perché era chiara. Nero su nero | invisibile | 16:1 |
| 4 | **Una casella spuntata col fuoco** (es. «Testo più grande» acceso) | Godot usa il colore «col fuoco» solo per la casella a riposo; spuntata usa quello «premuto», che era nero | invisibile | 16:1 |
| 5 | **«premi un tasto» sul titolo** | grigio sul tendone scuro, e pulsando scendeva al 35%: nel momento più spento quasi spariva | 1,9:1 | 7:1 |
| 6 | **La descrizione in basso** | le righe vanno a capo di nuovo quando cambia la larghezza, ma nessuno lo diceva alla descrizione, che restava della misura vecchia. Entrando dal titolo era alta 2433 pixel e la scritta finiva sopra lo schermo; stretta la finestra, l'ultima riga usciva sotto (la tua foto del cursore) | fuori dallo schermo | al suo posto |
| 7 | **La «o» fra due tasti** in COME SI GIOCA | grigio a 15 pixel: di calcolo 4,75:1, ma i bordi sfumati di una lettera così sottile se ne mangiano un po' | 4,2:1 | 7,5:1 |

«Prima» è misurato sulle foto; «dopo» è il conto dei colori (sulle foto viene un
po' meno, per i bordi sfumati delle lettere). Il giro finale di foto, sulle 30
schermate del menu principale, non trova più niente da sistemare né normale né
con l'alto contrasto; col testo grande solo il rombo qui sotto.

Ogni correzione ha la sua verifica in `prova_le_scritte_del_menu_si_leggono`, e
l'ho rotta apposta tredici volte (una correzione alla volta): la prova se ne
accorge tutte e tredici.

## Cosa resta, e lo decidi tu

- **Le etichette piccole della pausa**, 12–13 pixel: «SCOMPARTO» nello zaino;
  «CLASSE», «LIVELLO», «PSICHE · CONCENTRAZIONE», «LEGAME DELLA SQUADRA» e
  «ARMA · 1 DI 5» nella scheda. Il contrasto va bene: sono piccole. Stanno nei
  disegni dello zaino e della scheda che hai approvato tu, quindi non le ho
  toccate: se vuoi le porto a 14.
- **Il rombo «◆» di «premi un tasto» col testo grande**: la riga si allarga e il
  rombo di sinistra esce dal tendone, sul cielo arancio (2,5:1 nel momento più
  spento). È una decorazione, non una scritta: le WCAG non la contano.

## Cosa non guarda

Le schermate di gioco (scontri, mappe, dialoghi) e le scritte disegnate a mano
più alte di 60 pixel, che lo strumento non sa ancora separare dal disegno:
quelle le ho controllate coi colori, a calcolo.
