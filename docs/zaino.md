# Lo zaino

*Bru, 8 ottobre: «bisogna anche migliorare la visual dello zaino, siccome avremo
un'immagine per ogni oggetto ci deve essere una lista, studiamo online come fare
uno zaino ben ordinato e esteticamente perfetto, documentati dai migliori giochi
per ottenere il miglior risultato».*

Qui c'è cosa ho trovato, cosa ne ho preso e cosa ho lasciato. Lo zaino nuovo sta
in `scripts/Zaino.gd` (la schermata), `scripts/RigaZaino.gd` (una riga della
lista), `scripts/PezziZaino.gd` (il fondo, l'oggetto grande, i riquadri) ed
`scripts/ElencoZaino.gd` (cosa c'è dentro, in che ordine, cos'è nuovo: senza
disegnare niente, così si prova da solo).

## Prima: com'era

Un indice a sinistra con i cinque scomparti e, a destra, un foglio con i nomi
scritti uno sotto l'altro. Niente immagini, niente da scorrere con le frecce, e
**tre difetti veri**:

- gli stessi oggetti in **due scomparti**: un ricordo o una chiave stavano sia
  in «Oggetti speciali» sia in «Ricordi e chiavi», perché nel salvataggio
  stanno in tutte e due le liste;
- la **pila** (il bottino dei nemici, `GameState.pila`) non si vedeva da
  nessuna parte. Bru l'aveva chiesta come «un'altra sezione dell'inventario»;
- l'arma in mano diceva «in uso — Anonimo» in piccolo e in grigio chiaro, dopo
  il nome: si perdeva.

## Cosa fanno i migliori

### Lista o griglia
La griglia è un **gioco** a sé: la valigetta di Resident Evil 4 funziona perché
fare spazio è una scelta («uno shotgun occupa più posto di un uovo, com'è
giusto») e mette tensione invece di spezzarla. Quando lo spazio non è un
rompicapo, i dibattiti fra sviluppatori e le guide dicono la stessa cosa: **la
lista si legge più in fretta e si ordina**, la griglia è più bella da guardare
ma più lenta. Un giocatore la riassume così: la griglia sa di zaino, la lista
«con o senza immagine» sa di ordine e di scopo. Baldur's Gate 3 mescola le due
cose: griglia per l'equipaggiamento, lista per il resto.

Da noi lo spazio si conta a pezzi, non a forme (`regole.json`, `zaino`): niente
rompicapo. Quindi **lista**, con l'immagine in ogni riga, come vuole Bru.

### Scomparti in linguette, a un tasto di distanza
Breath of the Wild divide lo zaino in sette scomparti (armi, archi, scudi,
abiti, materiali, cibo, oggetti importanti), ed è anche il suo difetto più
citato: dentro uno scomparto di più pagine la levetta gira le pagine invece di
passare allo scomparto vicino, e per mangiare in battaglia si apre il menu, si
va al cibo, si sfogliano le pagine. Metaphor: ReFantazio, dopo l'uscita, ha
aggiunto con un aggiornamento il **salto di categoria** nella schermata degli
oggetti.

Da noi: gli scomparti sono **linguette in alto**, sempre visibili, col loro
conto («CONSUMABILI 3/20»), e **destra/sinistra** passa allo scomparto vicino da
qualunque riga. Su e giù restano alla lista.

### Una riga per tipo, col conto
Impilare gli oggetti uguali in una riga sola è il primo modo di non far
scorrere il giocatore. Era già così (tre fiale: una riga «×3»), resta così.

### «In uso» si deve vedere
In Metaphor l'arma addosso è segnata «E:1» nella lista, e la critica dei
giocatori è stata proprio questa: un codice che non si capisce, e niente
colore. Da noi: un'etichetta **IN USO** arancio, piena, nella riga; e nella
scheda a destra chi lo porta.

### L'oggetto scelto, grande, con la sua descrizione
In Persona 5 la voce su cui sei si ingrandisce e prende colore, e una riga di
aiuto spiega cosa fa; nei commenti dei giocatori il **testo della descrizione**
è spesso l'unica cosa che distingue due oggetti simili. Diablo IV, nel suo
aggiornamento di febbraio 2020 dedicato all'interfaccia, ha rifatto le icone
perché si **leggessero** meglio e ha abbassato luce e colore dei fondi dietro le
icone: l'oggetto deve staccarsi dal fondo, non il fondo dall'oggetto. Le linee
guida di Valve per Dota 2 dicono lo stesso dei disegni piccoli: conta la
**sagoma**, e il chiaro/scuro conta più del colore.

Da noi: a destra, sulla fascia nera, **l'immagine grande** dell'oggetto scelto;
accanto, nello schermo del cabinato, nome, scomparto, i riquadri con quello che
fa in numeri (gli stessi della vetrina del negozio) e la descrizione intera.
Nella riga l'immagine sta su una piastrella scura uguale per tutti: quando
arriveranno i disegni di Bru, saranno tutti sullo stesso fondo.

### Ordinare, e dire come
L'ordine fisso stanca: le guide citano categoria, nome, quantità e
**arrivo** (il più recente) come chiavi utili. La proposta più concreta l'ha
fatta Amped-UX per Breath of the Wild: il tasto «ordina» c'era già, bastava che
**girasse fra più ordini e dicesse con una parola** quale sta usando.

Da noi: un tasto **ORDINA** sopra la lista, che gira fra **TIPO** (gli
oggetti che fanno la stessa cosa stanno insieme: prima la vita, poi l'aura, lo
stress…), **NOME**, **QUANTITÀ** e **ARRIVO**, e lo scrive. Lo zaino si ricorda
l'ordine scelto finché giochi.

### Il segno «NUOVO», e quando sparisce
Diablo 3 mette una stella sull'oggetto **e sullo scomparto** che lo contiene.
Chi ne parla nei forum degli sviluppatori è d'accordo su un punto: il segno va
tolto quando l'oggetto **lo guardi**, non quando apri il menu; e un segno deve
guadagnarsi il posto, se no l'occhio impara a saltarlo.

Da noi: **NUOVO** sulla riga di un oggetto mai visto, e un rombo arancio sulla
linguetta dello scomparto che ne ha. Sparisce quando la riga viene scelta. Si
salva con la partita (`oggetti_visti`); un salvataggio di prima considera già
visto tutto quello che hai, così nessuno si ritrova lo zaino coperto di NUOVO.

### Bello, ma che si legga
Katsura Hashino, regista di Persona e di Metaphor, ha raccontato che i loro
menu sono belli perché **ogni menu ha il suo disegno**, e che all'inizio le
forme spigolose di Persona 5 «non si leggevano»: hanno dovuto rifarle più
volte. È la regola che teniamo: lo zaino prende la lingua della scheda della
squadra (arancio del manifesto, schermi dei cabinati, la fascia nera storta),
ma ogni scritta sta su un fondo pieno.

## Quattro proposte, da scegliere

*Bru, 9 ottobre: «ok molto meglio lo zaino, vedi se puoi ancora fare meglio
mandami altri esempi altrimenti approviamo questo».*

Gli stessi dati, gli stessi tasti, quattro modi di disegnarli
(`scripts/ProposteZaino.gd`, provvisorio). Nello zaino il tasto **PROPOSTA 1/4**,
in alto accanto al titolo, gira fra le quattro.

| | proposta | com'è | a cosa punta |
|---|---|---|---|
| 1 | **Cabinato** | com'è oggi: la lista nello schermo di un cabinato | la stessa famiglia della scheda squadra |
| 2 | **Fasce** | la lista sull'arancio, una fascia nera storta per riga, quella scelta esce chiara dalla fila | la lingua delle voci della pausa: la più «manifesto» |
| 3 | **Taccuino** | un foglio chiaro scritto in nero, diviso in sezioni (VITA, AURA, STRESS, DANNI, CURE…), la scelta con l'evidenziatore | la più ordinata: i gruppi si vedono senza leggere |
| 4 | **Vetrina grande** | la lista stretta, solo i nomi; l'oggetto scelto enorme al centro, col nome sotto | i disegni di Bru diventano la cosa più grande a schermo |

Quando Bru sceglie, la proposta scelta entra in `Zaino.gd` e `RigaZaino.gd` e il
file delle proposte se ne va.

## Cosa ho lasciato fuori, e perché

- **La griglia e le forme diverse degli oggetti.** Bello in RE4 perché è il
  gioco; da noi sarebbe una regola nuova da imparare.
- **La ricerca per nome** (The Witcher 3): con cinquanta oggetti in tutto e uno
  scomparto alla volta, non serve ancora.
- **Usare, buttare, vendere dallo zaino.** Lo zaino resta **da guardare**: si
  equipaggia dalla scheda della squadra, si compra e si vende al negozio. Una
  cosa per schermata.
- **I preferiti.** Senza un uso rapido in combattimento non hanno dove servire.

## Le fonti

- Dibattito «grid vs list» fra sviluppatori — [gamedev.net](https://gamedev.net/forums/topic/669150-inventory-management-grid-vs-list/)
- Liste, griglie, ordinamento — [StraySpark](https://www.strayspark.studio/blog/inventory-crafting-system-players-enjoy), [Games by Hyper](https://gamesbyhyper.com/docs/item-management/list-inventory/), [Ark Times](https://2fwww.arktimes.com/?p=28250)
- Breath of the Wild — [Game Developer](https://www.gamedeveloper.com/art/a-ui-ux-analysis-of-zelda-breath-of-the-wilds), [Prototypr](https://blog.prototypr.io/thoughts-on-ux-of-zelda-breath-of-the-wild-fd4d2248dbc1), [Kotaku / Amped-UX](https://kotaku.com/five-ways-nintendo-could-fix-breath-of-the-wilds-clunky-1793957796), [UX Collective su Tears of the Kingdom](https://uxdesign.cc/tears-of-the-kingdom-how-nintendo-improved-and-ignored-ui-issues-843f094b14b2)
- Persona 5 e Metaphor — [Mechanics of Magic](https://mechanicsofmagic.com/2022/04/23/visual-design-of-games-persona-5/), [Kotaku](https://kotaku.com/-metaphor-refantazio-persona-5-menu-ui-hashino-1851667088), [Push Square](https://www.pushsquare.com/news/2024/10/making-metaphor-refantazio-personas-immaculate-menus-is-really-annoying-says-director), [80.lv](https://80.lv/articles/persona-director-says-making-stylish-ui-is-really-annoying/), [Steam, critiche dei giocatori](https://steamcommunity.com/app/2679460/discussions/0/4695657408664188393), [TechRadar, l'aggiornamento](https://www.techradar.com/gaming/consoles-pc/metaphor-refantazios-latest-patch-makes-improvements-to-its-main-menu-by-adding-a-new-party-formation-option)
- Diablo IV — [Blizzard, aggiornamento di febbraio 2020](https://news.blizzard.com/en-us/article/23308274/diablo-iv-quarterly-updatefebruary-2020)
- Resident Evil 4 — [Bloody Disgusting](https://bloody-disgusting.com/video-games/3658221/resident-evil-4-perfected-inventory-system-resident-evil-25/), [Resident Evil Wiki](https://residentevil.fandom.com/wiki/Attache_Case), [Gfinity](https://www.gfinityesports.com/guides/resident-evil-4-remake-inventory-system)
- Il segno «nuovo» — [PlayFab community](https://community.playfab.com/questions/14806/best-way-to-track-whether-an-item-is-new-for-a-pla.html), [ORK Framework](https://forum.orkframework.com/discussion/2954/inventory-menu-issues), [Baymard sui badge](https://baymard.com/blog/badge-ui)
- Icone leggibili — [Game Developer, regole delle icone](https://www.gamedeveloper.com/design/icon-design-rules-you-should-know), [Polycount sulle linee guida di Dota 2](https://polycount.com/discussion/comment/1919653)
