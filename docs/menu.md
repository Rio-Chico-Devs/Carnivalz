# I menu — cosa dicono le fonti, e cosa fa il nostro codice

Tre fonti, lette per intero, estratte con `strumenti/sfoglia.py` e messe in
`docs/fonti/`. Una è empirica, una è la voce di chi ha fatto il menu di JRPG più
celebrato degli ultimi dieci anni, una è una demolizione schermata per schermata
di un Final Fantasy uscito ieri.

Alla fine di ogni pila c'è il controllo sul **nostro** codice: cosa regge già,
cosa no. Non è un elenco di buone intenzioni — dove ho potuto verificare, ho
aperto il file.

---

## Pila 1 — PLAY: le euristiche misurate

Fonte: `docs/fonti/euristiche-giocabilita-play.md` — Heather Desurvire
(Behavioristics; USC, Cinematic Arts) e Charlotte Wiberg (Umeå), *Game Usability
Heuristics (PLAY) For Evaluating and Designing Better Games: The Next
Iteration*.

**Perché vale più di una lista di consigli.** Non è un'opinione: è uno studio.
54 partecipanti (2 esclusi perché non hanno scelto un gioco di rango basso),
**116 principi candidati**, giochi divisi in rango alto e rango basso secondo i
punteggi di metacritic.com. Risultato: **48 dei 116 principi distinguono
davvero** i giochi buoni dai cattivi, con p < .0004 (cioè 0,05/116 — hanno
corretto per il numero di confronti, che è la cosa che di solito non si fa).
Altri 16 sono differenziatori a p < .004.

Prima di PLAY c'era **HEP**, presentata a CHI 2004 dagli stessi autori, divisa
in quattro aree: Game Play, Game Usability, Game Mechanics, Game Story. PLAY
nasce perché HEP «has been found useful but only in limited circumstances».

I principi sono stati costruiti anche con progettisti di **LucasArts, Sega,
Microsoft Game Studios, THQ e Disney**.

### Il risultato che ci riguarda più di tutti

> Players were more favorable toward games with **lower Usability difficulty**
> and **some amount of Strategy & Challenge difficulty**.

Cioè: la difficoltà è desiderata **nel gioco**, non **nel menu**. È la frase da
tenere appesa, perché è misurata e non ovvia — uno potrebbe pensare che un menu
denso e cifrato faccia «gioco tosto». I numeri dicono il contrario.

E accanto:

> Characteristic of Strategy & Challenge, players preferred games that rewarded
> skill and did not rely on rote memory.

### Le euristiche che valgono per una schermata di menu

Dalla Categoria III, *Usability & Game Mechanics* — le cito per esteso perché
sono il cancello:

| | |
|---|---|
| **B2** | «Status score Indicators are seamless, obvious, available and do not interfere with game play.» |
| **C1** | «Game provides feedback and reacts in a consistent, **immediate**, challenging and exciting way to the players actions.» |
| **E1** | «The game does not put an unnecessary burden on the player.» |
| **F1** | «Screen layout is efficient, integrated, and visually pleasing.» |
| **F2** | «The player experiences the user interface as consistent (in controller, **color, typographic**, dialogue and user interface design).» |
| **F3** | «The players experience the user interface/HUD as **a part of the game**.» |
| **F4** | «Art is recognizable to the player and **speaks to its function**.» |
| **G1** | «Navigation is consistent, logical and **minimalist**.» |
| **H2** | «Player interruption is supported, so that players can easily turn the game on and off and be able to save the games in different states.» |

E dalla Categoria I, che riguarda il nostro hype:

> **D3.** The game gives rewards that immerse the player more deeply in the game
> by **increasing their capabilities, capacity** or for example, expanding their
> ability to customize.

### Due avvertenze oneste su questa fonte

1. «Data for each genre was not gathered separately.» Non c'è un taglio per
   genere: un RPG a turni e uno sparatutto stanno nello stesso mucchio.
2. **Nella Tabella 1 c'è un errore di stampa.** La categoria III D
   («Terminology») ha tre voci D1, D2, D3 che sono **identiche parola per
   parola** a quelle della categoria I D («Goals»). Quindi l'euristica
   «Terminology» in quella tabella non ha contenuto proprio. L'ho verificato
   rileggendo le due sezioni: è così nel documento, non nella mia estrazione.

### Il controllo sul nostro codice

- **G1, «minimalist»**: la pausa è una lista di **sette voci**, tutte allo
  stesso peso. Non c'è raggruppamento fra quello che si consulta (Storico,
  Diario, Zaino), quello che si amministra (Personaggio, Opzioni) e quello che
  esce (Riprendi, Torna al menu). Sette scelte piatte.
- **F4, «art speaks to its function»**: le voci sono **solo testo**. Nessuna
  icona, nessuna forma che dica cosa c'è dietro.
- **B2, gli indicatori**: «Tazo 30» e «Lv 1» ci sono e stanno in alto a destra,
  fuori strada. Questo regge.
- **H2**: il salvataggio in stati diversi c'è già.

---

## Pila 2 — Persona 5, dalla voce di chi l'ha fatto

Fonte: `docs/fonti/persona5-intervista-interfaccia.md` — intervista a
**Masayoshi Sutou**, art director di Atlus, apparsa su *Famitsu* #1449 e
tradotta da Play-Asia; ripresa da Persona Central l'11 settembre 2016.

*(Correzione a quello che avevo scritto ieri sulla scorta di una sintesi: non è
una conferenza CEDEC+KYUSHU 2017 e non c'è Kazuhisa Wada. È un'intervista a
Famitsu del 2016, e parla Sutou da solo.)*

Sutou è in Atlus dal 1999, ha fatto l'interfaccia di *Shin Megami Tensei III:
Nocturne* «from scratch all by himself», poi Persona 3, 4, 5 e *Catherine*.

**Il colore è la cosa a cui ha dedicato più fatica**, e la nostra tavolozza è la
stessa:

> The biggest thing I put my all into was regarding the color of the interface
> compared to the game's main colour scheme. For example, the main color for
> Persona 3 was teal, Persona 4's a vivid yellow color […] Of course Persona 5's
> main color scheme is a **crimson red** and therefore after much deliberation I
> sat down and after trying out **black and white text** I was confident with it.

**Niente sfumature:**

> I always like using traditional methods, **I tend to not add gradations**, but
> prefer filling in each and every graphic.

**E la regola che è una regola di programmazione, non di gusto:**

> Each entry on the menu screen is animated and due to the fact that a lot of
> the GUI's data is found in the Resident Areas memory as soon as you press the
> button to bring up the menu it will **pop up without any lag whatsoever**,
> this was something that I was very particular about and something I needed to
> implement into the game.

Cioè: i dati dell'interfaccia stanno **già in memoria**, e per questo il menu si
apre senza attesa. L'animazione delle voci non costa l'apertura.

E su come si lavora:

> First we have to figure out the concept and lay out design for the UI and
> **what components would need to react in what ways** and so it's important to
> relay that to the programmers. We tend to create things **manually** rather
> than rely on using optimization tools.

### Il controllo sul nostro codice

- **Il colore**: siamo già lì. `pericolo` `#ed1c24`, `accento` `#e8123c`, sfondo
  nero, testo bianco. Non è una coincidenza da rivendicare, è una conferma che
  la strada è battuta.
- **Niente sfumature**: noi disegniamo con `StyleBoxFlat` e `draw_rect`, tinte
  piene. Regge.
- **L'apertura senza attesa**: `Pausa.apri()` chiama `mostra_menu()`, che fa
  `svuota()` e **ricostruisce i bottoni da zero ogni volta**. Su sette voci non
  si vede; sullo zaino e sul diario, che si ricostruiscono anche loro a ogni
  ingresso, **non lo so — e non voglio dirlo senza misurarlo**.
  Una cosa però è già giusta e vale scriverla: la sfocatura dello sfondo è
  asincrona e il menu **compare prima** che la fotografia sia pronta. Non è il
  menu ad aspettare l'effetto.

---

## Pila 3 — Final Fantasy XVI, demolito da un progettista

Fonte: `docs/fonti/ffxvi-interfaccia-durczok.md` — Paweł Durczok, *The Final
Fantasy XVI interface: a Cabinet of Curiosities*, 11 settembre 2023.

È la fonte più utile delle tre, perché non dice cosa fare: dice cosa è andato
storto in un gioco con budget enorme e squadra espertissima.

La tesi:

> the developers made the interface **deliberately slow**. […] Something I
> consider a **cardinal sin of game interfaces**.

**Problema 1 — le transizioni.** Un fuoco animato in fondo allo schermo, puramente
decorativo, e uno sfondo col protagonista in 3D con la camera che ruota a ogni
cambio di schermata. «It completely tanks performance»: le transizioni girano
**sotto i 30fps** con scatti visibili, poi il menu torna a 60. E la schermata
della mappa si **ricarica ogni volta**, anche senza uscire dai menu, bloccando
ogni azione finché non ha finito — «the previously loaded map doesn't seem to be
stored».

**Problema 2 — la densità.** L'HUD compete con gli effetti degli attacchi, e
**non si può spegnere niente**: dopo una dozzina di ore la memoria muscolare
rende inutile mostrare sempre i tasti, ma non c'è modo di toglierli. Nemmeno i
numeri di danno, i nomi delle abilità, le barre dei nemici.

**Problema 3 — e questo è quello che ci riguarda.** Le schermate a tutto schermo
— nome del capitolo, fine di uno scontro, salita di livello, incontro con un
bersaglio speciale — **non si possono chiudere subito**:

> an animation associated with the type of overlay needs to play out, before the
> "dismiss" prompt and the action become available. A particularly egregious
> example is the post-battle summary screen that shows the accumulated
> experience and battle points, money and renown being added to the previous
> values of those stats. **The animation works like a counter, is asynchronous
> for all 4 elements and seems to have easing added to it, which prolongs the
> tail end.** Only after that animation ends any items acquired from the fallen
> enemies are displayed and it becomes possible to close the overlay. One might
> think it's not a major issue, but **you'll be seeing hundreds of those screens**
> during the course of the game.

E peggio:

> some of the overlays aren't dismissable at all […] but are instead **on a
> timer that needs to elapse** before they fade out. That leads to very
> disruptive behaviour from the UI.

La conclusione è misurata, non astiosa:

> Is it a "bad" interface? No, it is not. It's functional, competent, provides
> feedback well (even if sometimes to an excessive level) […] Unfortunately,
> it's also a rather unresponsive, unnecessarily intrusive construct that simply
> **isn't very fun to use**.

### La regola che ne esce, e che è l'opposto di quello che stavo per fare

**Animare sì, sbarrare mai.** Il difetto di FFXVI non è che il contatore si
anima: è che **non si può chiuderlo finché l'animazione non finisce**. Sono due
cose separate, e io stavo per fonderle — avevo appena finito di mettere
l'ammorbidimento sulle barre della vita (`DISCESA := 0.30`, `CODA := 0.55`) e il
passo successivo sarebbe stato lo stesso trattamento su Tazo e hype dopo uno
scontro. Con la stessa coda lunga, e la stessa attesa.

### Il controllo sul nostro codice

**Quello che regge, e non per fortuna.** Le salite di livello non sono una
schermata a tutto schermo: `Main.notifiche_salite_di_livello()` mette le righe
nella **coda normale dei messaggi**, e il giocatore le fa scorrere al suo passo.
Nessun velo, nessuna animazione che sbarra. È già il comportamento giusto.

**Quello che non regge.** `Main.gd:500-503`, il caso `espulsione_automatica` —
un posto che ti rigetta fuori:

```gdscript
mostra_messaggio(...)
area_avanza.visible = false
await get_tree().create_timer(2.2, false).timeout
```

Si nasconde il comando per avanzare e si aspettano **2,2 secondi fissi**. Chi
legge in fretta guarda il muro. È esattamente il secondo caso di Durczok, le
schermate «on a timer that needs to elapse», e da noi ce n'è uno solo — ma c'è.

**E il difetto opposto.** La salita di livello mostra `forza 12 → 14 (+2)` come
**testo fermo**. FFXVI eccede e sbarra; noi non festeggiamo affatto. È l'unico
momento in cui il giocatore scopre a cosa è servito giocare come ha giocato —
lo dice il commento nel nostro stesso codice — e lo diciamo con una riga di
testo.

---

## Quello che va deciso prima di toccare il codice

Scritto e non fatto: Bru ha chiesto di studiare, e la struttura la decidiamo dopo.

1. **La pausa non è una lista piatta di sette voci.** Vanno raggruppate per
   mestiere: cosa si consulta, cosa si amministra, cosa esce. (PLAY G1)
2. **Ogni voce ha un segno oltre al testo.** (PLAY F4)
3. **Animare sì, sbarrare mai.** Qualunque contatore animato — Tazo, hype, le
   stat che salgono — deve avere una scorciatoia che lo porta al valore finale
   subito, e chiudere non deve mai aspettare la fine dell'animazione.
4. **Quei 2,2 secondi fissi diventano un'attesa saltabile.**
5. **La salita di livello merita più di una riga di testo**, ma dentro la coda
   dei messaggi, non in un velo che sbarra.
6. **Misurare quanto ci mette ad aprirsi lo zaino**, invece di supporlo. La
   regola di Sutou è un numero, e i numeri si misurano.
7. **Niente sfumature, tinte piene**: siamo già così, e adesso c'è scritto perché.
8. **Il menu non è il posto della difficoltà.** (PLAY, 4.1 — misurato)
