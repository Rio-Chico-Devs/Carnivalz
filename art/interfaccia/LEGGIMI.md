# I disegni dell'interfaccia

Qui stanno i pezzi disegnati dell'interfaccia che non sono né personaggi né
oggetti. Per ora uno solo:

```
art/interfaccia/statistiche/<chiave>.png
```

Sono le icone delle statistiche nella scheda della squadra. Le chiavi sono
`hp`, `attacco`, `difesa`, `velocita`, `aura`.

Sul foglio da 1280×720 stanno in 24×24 pixel, dentro un quadratino nero.
Conviene disegnarle a 52×52, bianche su trasparente. Il file entra intero e
centrato. Finché non c'è, al suo posto c'è un disegno a forme: cuore, lama,
scudo, fulmine, stella.

In `statistiche/strada_a/` ci sono le sagome della strada A pulite, da misurare:
un SVG e un PNG per statistica, 480 × 480, nero su trasparente. Le scrive
`./prove/sagome_a.sh` dal codice (`prove/SagomeA.gd`), e il gioco non le carica:
servono a controllarle. Il canone e le misure stanno in `docs/sagome_a.md`.

In `statistiche/proposta/` ci sono le icone nuove delle proposte, nello stesso
formato: le scrive `./prove/icone.sh` da `prove/IconeStatistiche.gd`, idee e pesi
in `docs/icone_statistiche.md`. Neanche queste le carica il gioco: per metterle
nella scheda vanno esportate bianche e copiate in `statistiche/<chiave>.png`.

Le misure di tutto il resto (gli oggetti, la figura intera, la carta,
l'emblema) stanno in `docs/interfaccia.md`. L'elenco di cosa manca, coi nomi
esatti dei file, sta in `docs/immagini.md`.
