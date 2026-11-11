# I livelli disegnati

Qui stanno i livelli fatti da **un disegno intero**, non da tessere: la mappa
è un PNG solo, e accanto c'è la sua **pianta**, un JSON con lo stesso nome
che dice dove si cammina.

    F6 su prove/LivelloProva.tscn                  ci si cammina (P passa da lei a lui)
    python3 strumenti/livelli/ricalca_livello.py   rifà le mappe dai disegni di Bru

| livello | cos'è |
|---|---|
| `panottico` | **Il Panottico silenzioso**: dietro la porta enorme oltre l'altare della bambola, nella Casa Gigante. È il disegno di Bru («THE SILENT PANOPTICON»), preso uguale |

## La mappa: `<nome>.png`

- **Un pixel del disegno è un pixel del mondo**, come le tessere dei pianeti:
  il gioco ingrandisce tre volte. Lei è alta 56: nel Panottico è alta come le
  sagome nelle capsule del laboratorio.
- Vista **dall'alto e un po' di fronte**: i muri si vedono di faccia, i
  pavimenti da sopra.
- **Fuori dalle stanze è trasparente**: il gioco ci mette il buio.
- Niente scritte e niente legenda dentro il disegno: i nomi delle stanze li
  scrive il gioco quando ci entri.

Il Panottico lo scrive `strumenti/livelli/ricalca_livello.py` dal disegno di
Bru (`strumenti/livelli/fogli/panottico.png`). Tiene tutti i pixel com'erano e
toglie solo quello che non è mappa:

- la scacchiera, il titolo, i nomi scritti fuori, la bussola e la legenda;
- la scritta sul pavimento del corridoio in alto, rifatta con le piastrelle
  di sopra.

## La pianta: `<nome>.json`

Tutti i numeri sono pixel della mappa. Un rettangolo è `[x0, y0, x1, y1]`,
con `x1` e `y1` fuori.

| chiave | cos'è |
|---|---|
| `nome` | il nome del livello, scritto sopra il nome di ogni stanza |
| `mappa` | il PNG |
| `limiti` | fin dove arriva la telecamera |
| `partenza`, `verso` | dove si entra, e da che parte si guarda (`[0, 1]` giù) |
| `stanze` | i nomi delle stanze e i loro rettangoli: entrandoci compare il nome |
| `pavimento` | i rettangoli dove si cammina |
| `ostacoli` | i rettangoli dove no, anche se sono sul pavimento (le capsule, le colonne, i cavi) |
| `porte` | una zona e dove porta (`a`, `verso`). Le porte chiuse del disegno si passano come negli Zelda: ci entri e sei dall'altra parte |
| `giro` | i punti del giro del pilota automatico |

Dove si cammina conta il **piede**, il punto per terra al centro dei piedi
(un rettangolo di 10×6, come nei mondi): il corpo sta sopra e copre il muro
dietro.

Le prove (`prove/Prove.gd`, «i livelli disegnati si attraversano») guardano
ogni pianta:

- si parte da un posto dove si sta;
- ogni porta porta in un posto dove si sta, e non dentro un'altra porta;
- il pilota fa tutto il giro passando da ogni stanza.

Il film del giro: `prove/LivelloProva.tscn -- film`.
