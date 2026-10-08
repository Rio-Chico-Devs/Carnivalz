# Cose da fare

Le decisioni lasciate per dopo, perché non si perdano. Quando una si chiude,
si toglie da qui e si scrive dove è finita (README, `mappa.json`, …).

## Le riserve delle sonde
*Rimandata da Bru l'8 ottobre: «ci pensiamo dopo a quello, mettili in una lista
di cose da fare».*

Le sonde dei pianeti (`scripts/Sonde.gd`) trovano minerali e risorse per
l'Organizzazione, e quando li estrai finiscono nelle **riserve**
(`GameState.sonde["riserve"]`, si salvano con la partita). Si accumulano, ma per
ora **non si vedono da nessuna parte** (solo nel testo della scheda quando
estrai) **e non si spendono**. Da decidere:

- **dove si vedono**: nel data pad, alla Sede, nella scheda del Vuoto…;
- **a cosa servono**: cosa si compra o si costruisce con i minerali, e cosa fa
  l'Organizzazione con le sue risorse;
- se le riserve hanno un **tetto** o crescono senza fine.

## I segnaposto del Vuoto
Esempi miei, da sostituire quando ci sono i contenuti veri:

- **i quattro pianeti d'esempio** del Vuoto Ardente (`mappa.json`, `pianeti`):
  nomi, storie, e il gioco con cui si esplorano (`file_eventi`, per ora vuoto:
  la scheda dice «esplorazione in arrivo»);
- **i numeri delle sonde** (`mappa.json`, `sonda` di ogni pianeta): ogni quanti
  minuti trovano, quanti giacimenti tengono, cosa e quanto. Vanno provati
  giocando;
- **i tre segreti** del Vuoto (`mappa.json`, `segreti`): posti, testi e premi.

## La griglia dello spazio
*Bru, l'8 ottobre, fra quattro proposte: «per ora quella attuale è la migliore».*

La griglia resta com'è. Le quattro proposte (retino, curve di livello, tavola
tecnica, rilievo) sono tolte dal gioco ma restano nella storia del repository,
nel commit «Griglia dello spazio: quattro proposte da far scegliere a Bru»
(`773ea2b`): se un giorno si vuole riprenderne una, si parte da lì.
