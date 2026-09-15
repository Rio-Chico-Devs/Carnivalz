# I ritratti

Un personaggio ha **una cartella**, e dentro tutte le facce che gli servono. Il
gioco pesca da solo quella giusta.

```
art/personaggi/<id>/<faccia>.png
```

Gli `id` sono quelli di `data/classes.json`: `anonimo`, `veronica`, `insonne`
(Yhvina), `sally`…

## Le facce del combattimento

| file | quando esce |
|---|---|
| `sano.png` | vita piena, non l'ha ancora toccato nessuno |
| `ferito_lieve.png` | sopra il **75%** |
| `ferito_medio.png` | fra il **25%** e il **75%** |
| `ferito_grave.png` | sotto il **25%** |
| `ko.png` | a terra |

**Le soglie sono quelle dell'ECG**, le stesse che hai dettato per la linea del
cuore. Non è pigrizia: tenendole uguali, quando il tracciato diventa giallo la
faccia cambia *nello stesso istante*. Chi gioca impara una soglia, non due.

La faccia **non sfarfalla**: peggiorare è immediato — un colpo che ti porta
sotto il quarto si deve vedere subito — ma per tornare indietro la vita deve
risalire *oltre* la soglia, non appena sopra. Altrimenti in tempo reale un
personaggio che balla intorno al 25% cambierebbe faccia dieci volte al secondo.

## Le facce degli status

Stesso posto, col nome dello status:

```
art/personaggi/veronica/fiamme.png
art/personaggi/veronica/maledizione.png
```

Quelli che esistono: `fiamme` · `maledizione` · `terrore` · `tossina` · `sonno` ·
`rabbia` · `provocato` · `frastornato` · `rapidita` · `lentezza`.

**Lo status vince sulla ferita** (ma non sul KO). È una scelta, e si ribalta in
una riga: la vita è già scritta in due posti — la barra e il colore dell'ECG —
mentre di essere in fiamme lo dice solo un riquadro piccolo. Il ritratto è lo
spazio più grande della schermata, e conviene darlo alla cosa che altrimenti si
vede meno. Se la pensi al contrario, dillo.

## Le due immagini che valgono per tutti

```
art/personaggi/ko.png          il KO generico
art/personaggi/slot_vuoto.png  il riquadro di uno slot senza nessuno dentro
```

Il **KO generico** è quello che hai detto di voler disegnare una volta sola: se
un personaggio non ha ancora il suo `ko.png`, esce questo. Così nessuno resta a
sorridere con la barra a zero.

Lo **slot vuoto** è il riquadro in più finché non hai compagni. I tre slot
restano sempre e tre: uno che sparisce nasconde quanto grande può diventare la
squadra.

## Non devi disegnare tutto prima di provare

Ogni file che manca **scivola su quello dopo**, in quest'ordine:

```
ko        →  <id>/ko.png  →  ko.png (generico)  ┐
status    →  <id>/<status>.png                  ├→  <id>/sano.png  →  <id>/neutra.png
ferita    →  <id>/ferito_*.png                  ┘         →  il ritratto vecchio
                                                          →  l'iniziale disegnata dal codice
```

Vuol dire che puoi partire con **due file per personaggio** — `sano.png` e
`ko.png` — e il combattimento funziona già. Gli altri si aggiungono quando ci
sono, senza toccare una riga di codice.

E vuol dire anche una cosa sui numeri, che è meglio sapere prima: con undici
personaggi giocabili, cinque facce di ferita e dieci status, il conto pieno fa
**165 ritratti**. Non è una ragione per non farlo — è una ragione per farli in
quest'ordine: prima `sano` di tutti, poi `ko` di tutti, poi le ferite dei tre
che si giocano di più, e gli status per ultimi.

## Le pose dei dialoghi

Nella stessa cartella, e continuano a funzionare come prima:

```
art/personaggi/veronica/neutra.png
art/personaggi/veronica/decisa.png
art/personaggi/veronica/felice.png
```

`neutra.png` è anche l'ultimo ripiego del combattimento: meglio la faccia
sbagliata che nessuna faccia.

## Formato

**Quadrati** per il combattimento: lo slot è un quadrato, e un'immagine larga e
bassa viene tagliata sopra e sotto (non stiracchiata — il gioco ritaglia, non
deforma). Almeno **512×512**.

Fondo **trasparente** se vuoi che si veda il grigio dietro; fondo pieno se
preferisci che il riquadro sia tutto tuo. Funzionano tutti e due.
