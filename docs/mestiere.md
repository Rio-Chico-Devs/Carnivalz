# Il mestiere — sensazione, testo, racconto

> **Documento di studio.** Raccolto da fonti pubbliche l'**11 settembre 2026**, diviso in quattro
> parti, più una quinta che dice **cosa di tutto questo Carnivalz fa già** e cosa no — coi numeri
> presi dal nostro `stile.json`, non consigli generici.
>
> Come per `godot.md`: in questo ambiente WebFetch è bloccato, quindi la ricerca è passata da query
> mirate. Le fonti sono in fondo. Dove una cosa è una mia deduzione, è segnato.

---

| Parte | Di cosa parla |
| --- | --- |
| **1 · La sensazione** | Perché un gioco «si sente bene» anche quando la meccanica non cambia |
| **2 · Transizioni e colore** | Come si passa da una scena all'altra, e come si sceglie una tavolozza |
| **3 · Il testo a schermo** | Velocità, economia, e il numero che dovrebbe far paura a chiunque scriva un RPG |
| **4 · I maestri** | Quattro autori di RPG, e quattro tecniche rubate ai romanzieri |
| **5 · Carnivalz** | Cosa abbiamo già, cosa manca, cosa costa poco |

---

# Parte 1 · La sensazione

## Il *juice*: la stessa meccanica, vissuta diversamente

Nel 2013 Jan Willem Nijman (Vlambeer) tenne una conferenza — *The Art of Screenshake* — che è
ancora il riferimento. Prese uno sparatutto banale e, **senza cambiare una sola regola**, gli
attaccò una trentina di trucchi finché non sembrò un gioco diverso.

Il punto che conta: **nessuno di quei trucchi cambia cosa fa il gioco.** Cambiano cosa *sembra* che
faccia. Sono gratis dal punto di vista del design e cambiano tutto dal punto di vista di chi gioca.

I quattro che valgono per noi:

| Trucco | Cos'è | Perché funziona |
| --- | --- | --- |
| **Squash & stretch** | L'oggetto si schiaccia all'impatto e si allunga al rimbalzo | Viene dai dodici principi Disney. È il più vecchio trucco dell'animazione e regge ancora |
| **Hit-stop** *(sleep)* | Il gioco si **ferma ~0,2 secondi** quando un colpo va a segno | Il cervello legge la pausa come peso. È il più economico di tutti: due righe |
| **Screenshake** | Lo schermo trema quando succede qualcosa di importante | Rende **fisica** una reazione che altrimenti è solo un numero che cambia |
| **Contraccolpo** | Chi colpisce rincula, chi incassa reagisce | Il colpo diventa uno scambio fra due corpi, non un evento su uno solo |

⚠️ Con un avvertimento che le fonti ripetono: **se tutto si muove, niente risalta.** La scossa forte
va tenuta per gli eventi che la meritano.

## Il problema specifico del turno: il ritardo

Un gioco d'azione ha il feedback immediato — premi, succede. **Un gioco a turni no**, e per questo
chi lo fa deve inventarsi come trasmettere la soddisfazione *in differita*. È la difficoltà
centrale della nostra forma, e va detta chiaramente perché non si risolve da sola.

## I numeri del danno: la tecnica più usata al mondo

I numeri che volano trasformano **un calcolo invisibile in un fatto visibile**. Sono oggi fra le
tecniche di juice più universali: RPG, azione, sparatutto, mobile.

La grammatica su cui le fonti concordano:

| Cosa | Come dovrebbe muoversi |
| --- | --- |
| **Danno** | Rapido, verso l'alto, urgente |
| **Cura** | **Verde**, più lenta e più gentile, una traiettoria più pacifica |
| **Mancato / parato** | **Grigio o azzurrino, piccolo e sottotono** — deve dire «non è successo niente di importante» |

L'ultima riga è la più trascurata: dare a un colpo mancato lo stesso peso visivo di uno andato a
segno è una bugia, ed è una bugia che il giocatore paga in attenzione sprecata.

## I tempi dell'animazione, in millisecondi

Le fonti di motion design danno numeri precisi, e sono più corti di quanto si creda:

| Cosa si muove | Durata |
| --- | --: |
| Elemento piccolo, meno di 40 px | **100 ms** |
| Default per qualunque cosa | **200 ms** |
| Transizione importante (un pannello che entra) | **300-400 ms** |
| Elastico o rimbalzo | 800-1200 ms |

E le curve:

- **ease-out** per qualcosa che arriva e si ferma. È la scelta giusta quasi sempre.
- **ease-in** per qualcosa che parte da fermo. **Da evitare nella UI**: fa sembrare l'interfaccia lenta.
- **lineare**: da evitare in generale, sembra robotico.

E una regola di coerenza: se un pannello entra in scala, un altro scorre di lato e un terzo appare
e basta, **l'interfaccia sembra scucita**. Si sceglie un linguaggio e si tiene.

---

# Parte 2 · Transizioni e colore

## La transizione di combattimento è una firma

Lo *swirl* di Final Fantasy è diventato così riconoscibile da essere un genere: si fa una
**cattura dello schermo** e si applicano effetti *a quella immagine*. Final Fantasy X usò un effetto
di vetro che va in frantumi.

Tecnicamente è un trucco semplice — la scena non si sta trasformando, si sta trasformando una foto
della scena — e proprio per questo è alla portata di chiunque. Il valore non è tecnico: **è che
quel mezzo secondo dice al giocatore "adesso siamo in un'altra modalità"** prima che debba
capirlo dalle regole.

## Colore: poche regole, tutte verificabili

| Regola | Numero |
| --- | --- |
| Quanti colori | **6-8 più i neutri.** Più colori = più coppie da verificare. Una tavolozza ristretta e sicura batte una ampia e non testata |
| Contrasto del testo | **almeno 4,5:1** (WCAG 2.1) |
| Il colore più sicuro | **Il blu.** Quasi tutti i tipi di daltonismo lo lasciano intatto |

**La regola che vale più di tutte: mai affidare a un colore, da solo, un'informazione che serve.**
Il rosso-verde è la coppia da evitare, ed è esattamente quella che ogni gioco usa per
danno e cura.

La soluzione non è rinunciare al colore: è **raddoppiare il canale**. Un esempio citato spesso:
dare a ogni fazione una **silhouette diversa** — così funziona per chi non distingue i colori, *e*
funziona meglio per tutti gli altri, perché una forma si riconosce più in fretta di una tinta.

---

# Parte 3 · Il testo a schermo

## Il numero che dovrebbe far paura

| Mezzo | Parole al minuto |
| --- | --: |
| Una sceneggiatura televisiva | **~120** |
| Un gioco narrativo | **~16** |

**Sedici.** Un gioco ha circa un ottavo dello spazio verbale di una serie TV per dire la stessa
cosa. Non perché il giocatore legga più lentamente, ma perché **sta facendo altro**: guarda, sceglie,
si muove. Il testo è ospite.

La conseguenza pratica: il dialogo di gioco vive in **scambi da 2-4 righe**. Le fonti citano esempi
in cui *venti parole* bastano a dare tutto quello che serve per sapere cosa fare, e *trentasette*
a fare una richiesta d'aiuto che costruisce un personaggio.

Per scala: un RPG lungo sta sulle **50.000-100.000 parole**, cioè un romanzo intero.

## La velocità del testo: la risposta è "l'opzione"

Sulla macchina da scrivere — il testo che compare una lettera alla volta — le fonti sono divise, e
vale la pena riportare entrambi i lati perché sono tutti e due veri:

**A favore:** senza doppiaggio, il ritmo di scrittura **è** il tono di voce del personaggio. E per
chi ha dislessia il testo che arriva gradualmente **si legge più in fretta**, non più piano.

**Contro:** chi legge veloce aspetta, e aspettare la propria stessa lettura è la definizione di
frizione.

**La risposta su cui tutti convergono: non scegliere, dare l'opzione.** Velocità regolabile, e la
possibilità di far comparire tutta la riga subito.

## Rispettare il tempo di chi gioca

Sulla stessa linea, per il combattimento: **la velocità di battaglia regolabile è ormai uno
standard atteso**, non una gentilezza. Dragon Quest XI, i Kiseki e altri hanno turbo 2× e 3× e la
possibilità di saltare le animazioni.

E la critica onesta che accompagna sempre questa funzione: **ad alta velocità le animazioni perdono
il loro impatto.** Non è una funzione gratis — è un patto col giocatore, che sceglie lui.

> **La frase che riassume tutto**, da un saggio sul ritmo nei JRPG: *un sistema affascinante può
> essere ridotto in polvere costringendo il giocatore a ripetere le stesse azioni molte volte di
> fila.* Il problema non è quasi mai il sistema. È quante volte glielo fai rifare.

---

# Parte 4 · I maestri

## Quattro autori di RPG, una lezione per uno

### Toby Fox — *il rifiuto come meccanica*

Undertale nasce da un desiderio: **un RPG in cui si possano fare amici di tutti i boss**, e in cui
non uccidere sia davvero una strada, non un handicap. Il sistema di combattimento è venuto *dopo*
quel desiderio, non prima.

La sua frase che conta di più: **il punto non era fare un gioco dove nessuno si fa male. Era la
scelta di non fare male.** Un mondo che *non giudica, ma reagisce*.

> Riguarda la Mediazione direttamente. Non è un bottone di clemenza: è il momento in cui il gioco
> ti chiede perché stavi per picchiare. E l'altra sua regola — *«ogni mostro deve sembrare un
> individuo»* — è esattamente la ragione per cui ogni nemico deve avere le sue condizioni.

### Hironobu Sakaguchi — *i dettagli piccoli*

Quando reclutò lo sceneggiatore Kenji Terada gli chiese: **«voglio fare un gioco che faccia
piangere la gente. Mi aiuti?»**

Ma la parte tecnica è più istruttiva della citazione. Sakaguchi otteneva emozione dai **dettagli
minuscoli** — un personaggio che si inchina, che alza una mano — **con la grafica a pixel**. E
quando il codice diventò un limite, costruì un **sistema di script per gli eventi** per scrivere le
scene separatamente dal codice del gioco.

> È il nostro `events_tutorial.json`. Abbiamo già la cosa che Sakaguchi ha dovuto inventarsi.

### Yoko Taro — *si scrive dalla fine*

Scrive **il finale per primo** e torna indietro. Il motivo è meccanico: se sai dove vuoi che sia
emotivamente il giocatore alla fine, devi trovare **le cause che produrranno quell'emozione** — e
quelle cause vanno messe all'inizio.

È un metodo, non uno stile. Chiunque può usarlo.

### Robert Kurvitz — *la prosa come interfaccia*

In Disco Elysium quasi ogni riga **è detta da un'abilità** del protagonista. Le abilità non sono
numeri: sono voci con un carattere.

La lezione strutturale: **la prosa non è decorazione aggiunta dopo le meccaniche — è l'interfaccia
attraverso cui le meccaniche operano.** E il processo: Kurvitz scrisse prima **una novella breve**
che conteneva il tema, e solo dopo il team la fece esplodere in alberi di dialogo.

## Persona 5: l'interfaccia come personaggio

Il caso più studiato di UI che è *parte del gioco* invece che una finestra sopra.

Due cose sono rubabili anche senza il loro budget:

1. **Un colore solo, dominante.** Le Persona precedenti evidenziavano con colori secondari; la 5
   tiene **il rosso ovunque** e usa **linee** per guidare lo sguardo. Meno colori, non più.
2. **Il movimento indirizza l'attenzione**, non decora. Linee bianche al centro dello schermo che
   portano l'occhio dove deve andare.

## Quattro tecniche rubate ai romanzieri

### Vonnegut — le due che valgono per noi

Delle otto regole di Vonnegut, due sono direttamente applicabili a un RPG:

> **«Ogni frase deve fare una di due cose: rivelare un personaggio o far avanzare l'azione.»**

Con sedici parole al minuto, è un filtro brutale e giustissimo. Se una riga non fa né l'una né
l'altra, sta rubando il posto a una che lo farebbe.

> **«Ogni personaggio deve volere qualcosa, anche solo un bicchiere d'acqua.»**

Vale per i **nemici**. Una creatura che vuole qualcosa è una creatura con cui si può mediare.

### Le Guin — la prosa ha un suono

Le qualità che chiamiamo *vivace, scorrevole, forte* **sono qualità del suono**. E la sua nota più
concreta: *il ritmo della prosa dipende moltissimo — molto prosaicamente — dalla lunghezza delle
frasi.*

Una riga di dialogo che si legge male ad alta voce si legge male anche a schermo. E il testo di
gioco **si legge sempre a voce**, dentro la testa di chi gioca, al ritmo che gli dai tu.

### Swain — l'unità motivazione-reazione

La struttura più utile che ho trovato per scrivere un momento di combattimento:

| | Cos'è |
| --- | --- |
| **Motivazione** | Qualcosa di *esterno*, percepito dai sensi. La casa prende fuoco |
| **Reazione** | Tre cose **in quest'ordine**: sentimento → azione → parola |

L'ordine non è negoziabile: si sente prima, si agisce dopo, si parla per ultimo. Invertirlo è il
motivo per cui certe scene «suonano false» senza che si capisca perché.

> Applicata a noi: il nemico fa una cosa (motivazione), la creatura **reagisce** — non annuncia.
> È la differenza fra *«Il Ghoul usa Morso»* e una riga in cui prima si vede l'effetto.

### «Mostra, non raccontare» — con la correzione

La regola vera non è «mostra sempre». È **«mostra più di quanto racconti»**, perché scena ed
esposizione sono due strumenti diversi e ognuno fa cose che l'altro non può.

**Quando raccontare va bene:** per passare in fretta su qualcosa che non merita una scena, e per
dare un antefatto.

E il trucco meccanico per accorgersene: cerca **`era`, `erano`, `è`** e i **nomi che sono emozioni**
— *rabbia, tristezza, felicità*. Di solito segnalano che stai raccontando dove potresti mostrare.

---

# Parte 5 · Carnivalz

Qui i numeri vengono da `data/stile.json` e dal codice, non da stime.

## Quello che abbiamo già, e che molti giochi non hanno

**La velocità del testo è già un'opzione.** `Impostazioni.velocita_testo` moltiplica i caratteri al
secondo: 0,5 lento, 3 quasi istantaneo. È esattamente la risposta su cui le fonti convergono, ed è
già lì. Insieme a **testo grande** e **alto contrasto** — cioè un'attenzione all'accessibilità che
la maggior parte dei progetti indie aggiunge dopo, se mai.

**I tempi sono centralizzati e sono già nella finestra giusta.** In `stile.json`:

| | Nostro | La raccomandazione |
| --- | --: | --- |
| `comparsa_box` | **180 ms** | ✅ vicino al default di 200 |
| `dissolvenza_ritratto` | **220 ms** | ✅ |
| `lampeggio_colpo` | **280 ms** | ✅ |
| `transizione_scena` | **350 ms** | ✅ centro esatto della fascia per le transizioni importanti |
| `caratteri_al_secondo` | **46** | — |

Non li avevamo scelti leggendo linee guida di motion design, ma sono dentro la finestra. Vale la
pena dirlo perché è la conferma che l'orecchio funzionava.

**Il ritmo della punteggiatura.** Abbiamo `pausa_virgola` 0,10 · `pausa_punto` 0,26 ·
`pausa_sospensione` 0,45. È **Le Guin applicata al codice**: il testo respira dove respirerebbe una
voce. Non l'ho trovata in nessuna delle fonti sui giochi — è una cosa che abbiamo noi.

**La tavolozza è già ristretta.** Tredici colori di interfaccia, di cui la metà sono livelli di
sfondo e bordo. La raccomandazione è 6-8 più i neutri: siamo nella forma giusta.

## Tre cose che costano poco e si sentono molto

### 1. L'hit-stop — due righe, e cambia il peso di ogni colpo

Cerco `scossa`, `shake`, `hit_stop` nel progetto: **non c'è niente**. Il combattimento non ha
nessun trucco di juice.

L'hit-stop è **il più economico dei quattro**: ~0,2 secondi di pausa quando un colpo va a segno, e
il cervello legge la pausa come peso. Abbiamo già il posto dove metterlo — `Voce.accoda_effetto()`
mette in coda gli effetti — e abbiamo già `Stile.tempo()` per non scrivere il numero a mano.

È anche l'unico che **non ha controindicazioni per l'accessibilità**: lo screenshake può dare
fastidio e va reso disattivabile, la pausa no.

### 2. I colpi mancati fanno troppo rumore

`colori_danno` ha undici voci: normale, critico, cura, e otto elementi. **Non c'è la voce per
"mancato" o "parato".**

Oggi un colpo parato scrive una riga nel diario con lo stesso peso di uno andato a segno. Le fonti
sono chiare: mancato e parato vogliono **grigio o azzurrino, piccoli e sottotono**, perché il loro
messaggio è *«non è successo niente di importante»*.

Non è cosmetica: è **attenzione**. Ogni volta che il gioco dà rilievo a un non-evento, spende
attenzione che gli servirà tre righe dopo.

### 3. Rosso e verde — la coppia da controllare

`pericolo` è `#c04a4d`, `positivo` è `#6fbf7f`. Danno e cura sono rosso e verde: la coppia
esattamente sbagliata per chi non li distingue, ed è la coppia che ogni gioco usa.

La buona notizia è che **abbiamo già l'interruttore `alto_contrasto`** e non ho verificato cosa fa
con queste due tinte. E la soluzione consigliata non è cambiare colore: è **raddoppiare il canale** —
un `+` davanti alla cura e un `−` davanti al danno, o la traiettoria diversa (la cura sale piano,
il danno scatta). Entrambe funzionano per chi non vede la differenza *e* si leggono più in fretta
per tutti gli altri.

## Due cose più grosse, da decidere tu

### La transizione di combattimento

`Transizioni.gd` fa una **dissolvenza al nero** di 350 ms, ed è pulita. Ma è la stessa transizione
per *qualunque* cambio di scena.

Lo swirl di Final Fantasy esiste perché quel mezzo secondo **dice che stai entrando in un'altra
modalità** prima che tu debba dedurlo. Con la nostra estetica — il Carnevale, il dominio — c'è una
forma da trovare che non è lo swirl. Non la propongo io: è una decisione visiva, ed è tua.

### La velocità di combattimento

La velocità del testo è regolabile; **la velocità del combattimento no**. Le fonti la danno per
standard atteso in un gioco a turni moderno.

Da noi il combattimento è **a battute in tempo reale**, quindi «×2» vuol dire una cosa diversa che
in un gioco a turni: accelererebbe le ricariche, cioè **cambierebbe il gioco**, non solo la sua
presentazione. Va pensata, non copiata.

## Una cosa da Kurvitz, e una da Vonnegut, che ci riguardano oggi

**Kurvitz:** *la prosa è l'interfaccia attraverso cui le meccaniche operano.* Il nostro Studio è
già così — studiare una creatura **è** leggerla. Ma il Tecno log oggi è una scheda di dati con
etichette. Le abilità di Disco Elysium sono voci con un carattere. Il Tecno log potrebbe avere
**una voce**, non un formato.

**Vonnegut:** *ogni personaggio deve volere qualcosa, anche solo un bicchiere d'acqua.* È la
domanda che rende compilabile `mediazione.md`. Le 38 righe vuote non chiedono «a che condizioni
cede questo nemico»: chiedono **cosa vuole**. Una creatura che non vuole niente non media, e va
bene — quella si scrive `NO` e si va avanti.

---

## Fonti

**Game feel e animazione**
- [The Art of Screenshake — Jan Willem Nijman, Vlambeer](https://www.youtube.com/watch?v=SkgkIXZ_13Y)
- [Game feel on the web: squash, shake, and the art of juice](https://valdemird.com/blog/game-feel-on-the-web/)
- [How to Make Your Game Feel Good: Game Feel and Juice](https://egmatic.com/blog/how-to-make-your-game-feel-good)
- [Damage Numbers: Turning Abstract Stats into Satisfying Feedback — GameJuice](https://www.gamejuice.co.uk/articles/damage-numbers-satisfying-feedback)
- [Hit Detection: Elements That Convey Satisfying Damage in Turn-Based Combat — Goomba Stomp](https://goombastomp.com/hit-detection-elements-convey-satisfying-damage-turn-based-combat/)
- [Executing UX Animations: Duration and Motion Characteristics — Nielsen Norman Group](https://www.nngroup.com/articles/animation-duration/)
- [Easing Functions for Game Animations — Febucci](https://blog.febucci.com/2018/08/easing-functions/)
- [Game UI Animation: Smooth and Engaging Interface Transitions](https://gamineai.com/blog/game-ui-animation-creating-smooth-engaging-interface-transitions)

**Transizioni e colore**
- [Fight Woosh — TV Tropes](https://tvtropes.org/pmwiki/pmwiki.php/Main/FightWoosh)
- [Final Fantasy X Battle Transition — implementazione](https://github.com/EveraldoSembiring/Final-Fantasy-X-Battle-Transition)
- [The Power of Color: How Customizable Palettes Enhance Game Accessibility — Wayline](https://www.wayline.io/blog/color-palettes-game-accessibility)
- [Unlocking Colorblind Friendly Game Design — Chris Fairfield](https://chrisfairfield.com/unlocking-colorblind-friendly-game-design/)
- [How to make our game colors accessible to everyone](https://dev.to/indieklem/how-to-make-our-game-colors-accessible-to-everyone-8cb)
- [How to Build an Accessible Color Palette (2026)](https://ultimatedesigntools.com/blog/how-to-build-accessible-palette/)

**Il testo**
- [8 Key Principles of Writing Effective Game Dialogue — Game Developer](https://www.gamedeveloper.com/game-platforms/8-key-principles-of-writing-effective-game-dialogue)
- [Storytelling in Open World Games, Part 2 — Talin](https://dreamertalin.medium.com/storytelling-in-open-world-games-part-2-c1409fee2606)
- [Why isn't all text speed "instant"? — discussione](https://www.resetera.com/threads/why-isnt-all-text-speed-instant.6724/)
- [Nobody Cares About It But It's The Only Thing That Matters: Pacing And Level Design In JRPGs — Aevee Bee](https://medium.com/@MammonMachine/nobody-cares-about-it-but-it-s-the-only-thing-that-matters-pacing-and-level-design-3ed043dc3309)

**I maestri dell'RPG**
- [Game Design Deep Dive: Undertale's action-based RPG battles — Game Developer](https://www.gamedeveloper.com/design/game-design-deep-dive-i-undertale-i-s-action-based-rpg-battles)
- [How Undertale makes you think hard before killing monsters — Game Developer](https://www.gamedeveloper.com/design/how-i-undertale-i-makes-you-think-hard-before-killing-monsters)
- [Undertale Dev: «Every Monster Should Feel Like an Individual» — The Escapist](https://www.escapistmagazine.com/undertale-dev-every-monster-should-feel-like-an-individual/)
- [Sakaguchi Talks Emotional Storytelling, Evolving Turn-Based RPGs — Game Developer](https://www.gamedeveloper.com/game-platforms/e3-sakaguchi-talks-emotional-storytelling-evolving-turn-based-rpgs)
- [Final Fantasy's Dungeon Master — intervista a Sakaguchi](https://fullfrontal.moe/hironobu-sakaguchi-magic/)
- [Yoko Taro — Backward Script Writing](https://adamjones46.wordpress.com/2017/05/02/yoko-taro-reverse-story-telling/)
- [Nier's Yoko Taro On Success, Drinking, And Death — Game Informer](https://gameinformer.com/b/features/archive/2017/11/24/yoko-taro-nier-automata-interview-game-informer.aspx)
- [Robert Kurvitz talks about writing Disco Elysium](https://rpgcodex.net/article.php?id=11309)
- [Disco Elysium — analisi narrativa, Moonshake Books](https://moonshakebooks.com/2022/06/11/helen-hindpere-disco-elysium-narrative-analysis/)
- [Atlus Reveals The Design Secrets Behind Persona 5's Distinctive UI — Siliconera](https://www.siliconera.com/atlus-reveals-design-secrets-behind-persona-5s-distinctive-ui/)
- [What you can learn from Persona 5's UI design](https://ousiadroid.medium.com/what-you-can-learn-from-persona-5-s-ui-design-4a4a646245b1)

**I romanzieri**
- [Kurt Vonnegut: 8 Basics of Creative Writing — Gotham Writers](https://www.writingclasses.com/toolbox/tips-masters/kurt-vonnegut-8-basics-of-creative-writing)
- [Kurt Vonnegut's 8 Tenets of Storytelling — The Marginalian](https://www.themarginalian.org/2012/04/03/kurt-vonnegut-on-writing-stories/)
- [Ursula K. Le Guin — Steering the Craft](https://www.ursulakleguin.com/steering-the-craft)
- [3 Powerful Writing Exercises from Le Guin's "Steering the Craft"](https://nicolebianchi.com/ursula-k-le-guin-steering-the-craft/)
- [Motivation-Reaction Units: Cracking the Code of Good Writing — Helping Writers Become Authors](https://www.helpingwritersbecomeauthors.com/motivation-reaction-units/)
- [Writing The Perfect Scene — Advanced Fiction Writing (su Swain)](https://www.advancedfictionwriting.com/articles/writing-the-perfect-scene/)
- [Show AND Tell: Navigating the Nuances — Yellow Bird Editors](https://www.yellowbirdeditors.com/blog/2019/1/21/show-and-tell-navigating-the-nuances-of-showing-vs-telling)
- [The Truth Behind "Show, Don't Tell" — DIY MFA](https://diymfa.com/writing/the-truth-behind-show-dont-tell/)

---

*Il mestiere · raccolto l'11 settembre 2026 · ramo `claude/inizio-progetto-dya2lr`*
