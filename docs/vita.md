# Più vita e movimento: cinque esempi

Bru:

> «cominciamo a lavorare sui minigiochi e gli effetti del gioco ora [...] mi
> fai degli esempi di animazioni che diano più vita e movimento al gioco?»

I menu hanno già il loro vocabolario di movimento (`docs/animazione.md`:
entrata, uscita, cascata, sfioro, gelatina), e il menu principale si muove già
(la ruota gira, le lampadine tremano, la parallasse). La parte ferma è **lo
scontro**: a riposo non si muove niente tranne l'ECG, il turno passa
accendendo una cornice, la Mattanza parte come un comando qualunque, e il
minigioco sono cerchi rossi su nero.

Gli esempi sono girati **sulla schermata vera dello scontro**, ma il codice del
gioco non l'ho toccato: stanno tutti in `prove/ProposteVita.gd`, strati e tween
messi sopra. Quelli che piacciono si spostano nel gioco nel posto scritto qui
sotto.

```
./prove/film_vita.sh              # tutti, in scatti/proposte_vita/ (un .mp4 ciascuno)
./prove/film_vita.sh mattanza     # uno solo
```

Nell'editor: `prove/ProposteVita.tscn`, F6 (fa il respiro).

Le lettere al posto dei ritratti sono quelle di oggi: coi disegni veri il
respiro e i tagli rendono molto di più.

Per ogni esempio c'è scritto cosa farebbe col **movimento ridotto** (l'opzione
c'è già, `Movimento.ridotto()`): negli esempi non c'è ancora, è come lo farei
portandoli nel gioco.

## 1. Il respiro (lo scontro a riposo)

- **Chi combatte respira**: il disegno dentro lo schermo si gonfia e si sgonfia
  del 1-2% (in altezza, e un poco al contrario in larghezza), ognuno col suo
  passo (2,8-3,4 s), mai insieme. Il nemico di più, e ondeggia di mezzo grado:
  è una creatura. Si muove il disegno, non la cornice.
- **Il riflesso sul vetro**: ogni 4-5 secondi passa sul vetro di un cabinato
  una lama di luce di traverso, in tre quarti di secondo. Ogni schermo ha il
  suo tempo.
- **Le braci**: i Carnivalz «sono mondi in fiamme». Dietro i cabinati, sopra
  la trama del fondo, salgono piano dei rombi piccoli (il rombo è il segno del
  gioco), chiari come scintille o scuri come cenere, che ondeggiano e girano.

Nel gioco: il respiro in `Slot.gd` e nel riquadro del nemico, le braci accanto
alla trama dell'arena (`Arena.gd`), il riflesso nel `Vetro` di `Manifesto.gd`.

**Movimento ridotto**: niente respiro e niente braci; il riflesso resta, ma
fermo e più tenue.

## 2. Lo squarcio (l'entrata nello scontro)

La scena da cui arrivi si **crepa** lungo una linea storta (lo squarcio dei
Carnivalz, che è anche il modo in cui si aprono le zone), la crepa si accende,
le due metà volano via girando un poco, e sotto lo scontro entra a pezzi:
prima il nemico e la sua scheda da sinistra, poi la squadra dall'alto, per
ultimo il quadrante dei comandi, che è dove devi guardare (la cascata di
`docs/animazione.md`: la cosa principale chiude la sequenza).

Dalla crepa all'ultimo pezzo fermo passa **poco più di mezzo secondo**. Nel
film la scena di prima è il luna park; nel gioco sarebbe la foto della
schermata da cui arrivi.

Nel gioco: all'apertura di `Combattimento.tscn`, prima di dare la mano al
giocatore.

**Movimento ridotto**: una dissolvenza.

## 3. Il turno che passa

Oggi lo dice la cornice che si accende. In più:

- lo slot di chi tocca **si alza** (+3,5%) e si inclina di un grado, con un
  rimbalzo corto; gli altri tornano giù e si smorzano appena;
- sotto lo schermo entra una **fascia** col nome: «TOCCA A VERONICA», «TOCCA A
  TE» (nera, scritta arancio, come le etichette del manifesto);
- quando tocca al **nemico** il suo schermo si accende di rosso due volte, il
  riquadro sobbalza, e la fascia è rossa: «TOCCA A MARIONETTA».

Nel gioco: in `Campo.evidenzia`, che è già il punto in cui si accende la
cornice.

**Movimento ridotto**: niente inclinazione e niente rimbalzo; la fascia
compare sul posto.

## 4. La Mattanza

Il **taglio a tutto schermo**, quando parte:

1. un lampo bianco e un velo scuro;
2. tre fasce di traverso entrano da parti opposte: una nera larga, una rossa e
   una arancio sottili;
3. sulla nera scivola l'iniziale (domani il ritratto) di chi la fa, e continua
   piano a scivolare mentre tutto è fermo; dietro, delle linee di corsa
   fanno sembrare la fascia ancora in volo;
4. **MATTANZA** cade come un timbro, con le schegge;
5. tutto esce dall'altra parte e lo scontro sbanda.

In tutto **un secondo**. È lungo per un'animazione d'interfaccia, ma si vede
una volta per scontro, in un momento che deve pesare. **Un clic lo salta**
(la regola di `docs/animazione.md`: niente deve far aspettare).

Nel gioco: in `Mattanza.gd`, prima che parta la barra. Lo stesso taglio, con
un'altra parola e un altro colore, va bene per il **BOND**.

**Movimento ridotto**: solo la fascia nera con la parola, ferma, per mezzo
secondo.

## 5. Il minigioco col corpo (Collisioni infinite)

Il gioco sotto è quello vero (`Minigioco.gd`, la raffica): qui cambia cosa
succede intorno.

- **L'anticipo**: nell'ultimo mezzo secondo prima che un pugno arrivi, intorno
  al suo anello compaiono otto tacche che corrono verso il centro. Dicono
  «adesso» anche con la coda dell'occhio, mentre guardi un altro pugno.
- **La parata**: un anello bianco che si allarga e sparisce, **PARATA!** come
  un timbro di traverso, le schegge, il quadrante che sobbalza di 4 pixel, il
  contatore che fa la gelatina.
- **Il colpo preso**: lo schermo del minigioco si **crepa** (rosso e bianco),
  si accende di rosso, lo scontro sbanda forte (12 pixel), chi l'ha preso si
  accende di rosso, e **PRESO** in rosso.

Il timbro prende il posto della scritta che il minigioco mette oggi sul
pugno (nel film quella è nascosta).

Nel gioco: in `RiquadroRaffica.gd`, che disegna già i riscontri.

**Movimento ridotto**: niente tacche che corrono e niente scossa; l'anello e
la crepa restano (sono l'informazione), il timbro compare fermo.

## Cosa chiedo a Bru

1. Quali di questi cinque vanno nel gioco, e quali vanno cambiati?
2. Lo squarcio: va bene per ogni scontro, o solo per gli scontri importanti
   (boss, imboscate)? Per gli scontri comuni potrebbe bastare la seconda metà,
   cioè i pezzi che entrano.
3. Il taglio della Mattanza va bene anche per il BOND, con un altro colore?
4. I **minigiochi**: oggi c'è la raffica (Collisioni infinite) e il colpo di
   grazia della Mattanza. Quali altri hai in mente? Li disegno e li prototipo
   nello stesso modo.
