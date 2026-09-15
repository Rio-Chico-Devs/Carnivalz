# La schermata di combattimento

Questo documento esiste per un errore. Quando Bru ha mandato i disegni, quello
della schermata di **dialogo** è finito subito nel codice e nei dati — colori,
misure, il nastro, il box bianco — e infatti quella schermata è esattamente
com'era disegnata. Del **combattimento** invece è rimasto solo *come deve
funzionare*, sparso fra i commenti. Il *com'è fatto* non l'ha scritto nessuno,
e quando l'immagine non è più stata davanti agli occhi non c'era niente a cui
tornare.

Quindi: qui dentro ci va tutto quello che Bru ha detto della schermata di
combattimento, con le sue parole, **prima** di scrivere una riga di codice.

---

## Stato: la disposizione manca ancora

Quello che segue è il **comportamento**, ed è completo: viene dalle parole di
Bru e si può costruire e provare così com'è.

Quello che **non** è scritto qui è dove stanno le cose nel rettangolo: quanto è
grande il box del nemico, se i compagni stanno in fila sotto o di lato, dove
cadono le barre rispetto al ritratto. Quello sta nel disegno, e il disegno va
riguardato.

> Da fare: rimettere il disegno del combattimento davanti, e riempire la
> sezione **Disposizione** qui sotto prima di toccare `scenes/Combattimento.tscn`.

---

## I combattenti

- **Fino a 3 slot per i compagni.**
- **Un nemico solo.** «non ci saranno più di un nemico». Nel box grande c'è il
  disegno del nemico.
- Ogni nemico ha **le sue dinamiche di combattimento e i suoi minigiochi**.
- Un'orda è **un nemico solo** che si indebolisce perdendo vita: «se per esempio
  abbiamo un orda di zombie, quel combattimento funzionerà che più perde vita il
  nemico orda di zombie più diventa debole».

## Le quattro misure, decise una volta per tutte

Bru: «hp è hp, la seconda sarà aura non hype, la terza sarà la barra dominio, e
l'hype è l'xp come prima, è l'aura che va consumata per le mosse, si riempie
dopo il combattimento o con oggetti o skill particolari di alcuni personaggi, la
barra dominio misura quando scatta la mattanza, e così è deciso definitivamente».

| | cos'è | come si riempie |
|---|---|---|
| **HP** | la vita | cure, oggetti |
| **Aura** | il mana: si spende per le mosse, più la mossa è forte più ne vuole | **non** dentro lo scontro: dopo, o con oggetti, o con skill particolari |
| **Dominio** | misura quando scatta la Mattanza | combattendo |
| **Hype** | è l'XP, la progressione | come prima |

## L'ECG

> ✅ **fatto** — `scripts/combattimento/Ecg.gd` (le regole) e `Tracciato.gd` (il disegno)

Bru: «vogliamo una sorta di ecg che si muova simulando le condizioni dei
personaggi, se ha tanto stress ci vuole che sia nervoso con ecg irregolare e
movimentato, la linea è rossa quando ferito gravemente meno del 25% di hp,
gialla sopra il 25% ma meno del 75% verde sopra il 75%».

Due informazioni in una riga sola: il **colore** dice la vita, il **movimento**
dice lo stress. Gli estremi cadono dove li ha messi lui — al 25% esatto è già
gialla («rossa *sotto* il 25%»), al 75% esatto è ancora gialla («verde *sopra*
il 75%»). Chi è a terra fa una riga dritta.

I tre colori stanno in `data/stile.json` (`ecg_verde`, `ecg_giallo`, `ecg_rosso`).

## Gli status

«quei riquadri vicino alla vita sono gli status».

## Il menu dei comandi

«se premi su attacco vedi una lista degli attacchi disponibili, stessa cosa le
skill, invece per difesa non ce lista, per fuga neanche, per oggetti invece la
lista di oggetti utilizzabili».

| comando | apre una lista? |
|---|---|
| Attacco | sì — gli attacchi disponibili |
| Skill | sì |
| Difesa | **no** |
| Fuga | **no** |
| Oggetti | sì — quelli utilizzabili |

## BOND e MATTANZA

«quando uno dei personaggi è pronto per legare col nemico il tasto bond si
illumina, quando la mattanza è pronta si illumina quella».

Due tasti che **non** si accendono a comando: si accendono quando la cosa è
pronta, e finché non lo sono stanno spenti. È l'unico avviso che il giocatore
riceve, quindi deve vedersi senza cercarlo.

## Il quadrante

> ✅ **fatto per la parte minigiochi** — `scripts/combattimento/Minigioco.gd`

«quel quadrante sotto avrà varie funzioni durante il turno del nemico dovrai
completare dei minigiochi per salvarti dai suoi colpi o diminuire i danni
complessivi a seconda dell'attacco lanciato».

E ci passa anche tutto il parlato: «il suo dialogo appare dove mettiamo i
minigiochi e così anche quelli dei nemici e protagonisti più la narrazione del
combattimento».

Una superficie sola che a turno **racconta** e **gioca**. Oggi è il box del
combattimento, e il minigioco ci si stende sopra.

## Il box del nemico

«nel box del boss ci vanno le info che si scoprono con lo studio».

Quindi quel riquadro non è decorazione: è il tecno log che si riempie strato per
strato mentre studi, e all'inizio è quasi vuoto.

---

## Disposizione

*(da riempire guardando il disegno)*
