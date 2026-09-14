# I nastri col nome

Il pezzo di nastro storto che compare in basso a sinistra quando qualcuno parla,
col suo nome sopra. Uno per personaggio, **col nome già scritto dentro il
disegno**: il lettering è di Bru, e il gioco non ci scrive niente sopra.

```
art/nastri/<id>.png
```

L'`<id>` è quello del personaggio in `data/personaggi.json` — lo stesso che usano
i ritratti. Attenzione: **non è sempre il nome**. Veronica ha id `brawler`,
Yhvina ha id `insonne`. L'elenco completo, generato dai dati, sta in
`docs/immagini.md`.

## La misura

**Non c'è una misura giusta, e più grande è meglio è.** Il gioco porta il nastro
all'altezza che vuole lui (`forme.altezza_nastro` in `data/stile.json`) e
calcola la larghezza da solo mantenendo le proporzioni del disegno.

Serve a una cosa sola: due nastri disegnati in due giorni diversi, uno più
grande e uno più piccolo, restano alti uguali a schermo invece di ballare uno
rispetto all'altro. Quindi disegnali alla misura che ti è comoda — l'unica cosa
che conta sono **le proporzioni**, cioè quanto è lungo rispetto a quanto è alto.

PNG con trasparenza. I bordi strappati, le ombre, la carta che sborda: tutto
quello che sta fuori dal rettangolo lo fa la trasparenza, quindi disegna pure
un nastro sbilenco senza preoccuparti di riempire l'immagine.

## Finché non c'è

Resta il rettangolo rosa col nome scritto dal gioco in minuscolo. Non è un
errore e non è temporaneo per modo di dire: sono quarantotto personaggi, i
disegni arriveranno alla spicciolata, e il ripiego deve reggere per mesi. Si
può giocare tutto il gioco senza un solo nastro disegnato.

Quindi non serve farli tutti insieme, e non serve avvisare nessuno quando ne
arriva uno: si copia il file qui dentro e alla partita dopo c'è.

## Come entra in scena

Il nastro non compare: **arriva da fuori dallo schermo**, da sinistra, quasi in
verticale, e si posa raddrizzandosi con un piccolo rimbalzo (mezzo secondo).
Vale anche per il tuo disegno, che quindi va inteso come un oggetto che vola,
non come un'etichetta appoggiata.

Rientra **solo quando cambia chi parla**: dieci battute di fila della stessa
persona non lo fanno rientrare dieci volte.

Per guardare l'animazione fotogramma per fotogramma:

```
./prove/scatto.sh nastro 5
./prove/scatto.sh nastro 12
./prove/scatto.sh nastro 20
```
