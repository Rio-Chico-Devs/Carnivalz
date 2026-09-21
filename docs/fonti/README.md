# Le fonti che non riesco a scaricare

Da dentro questa sessione ogni dominio risponde **403** dal proxy di policy:
la documentazione di Godot, i PDF dei paper, i blog. La ricerca web funziona,
ma restituisce **sintesi** — e una sintesi mi ha già fatto leggere al contrario
uno studio da 45.000 giocatori (vedi `docs/tutorial.md`, sezione 0).

Quindi: Bru le scarica, io le leggo qui.

## Come metterle

Un file per fonte, con un nome che dica cos'è:

```
docs/fonti/godot-inputevent.md
docs/fonti/command-pattern.md
docs/fonti/chi2012-tutorials.pdf
```

**Il formato non conta**: `.md`, `.txt` e `.pdf` li leggo tutti. Non serve
pulire, riformattare o tagliare — il testo incollato così com'è va benissimo, e
anzi è meglio: quello che a te sembra un pezzo inutile a volte è la riga che
cambia la conclusione.

**Metti il link in cima al file**, una riga sola. Serve a sapere cosa stiamo
citando quando lo citiamo, e a ritrovarlo fra sei mesi.

## Cosa c'è qui dentro

I PDF non hanno una prima riga dove mettere il link, quindi stanno qui.

| file | cos'è | link |
|---|---|---|
| `chi2012-tutorial-complessita.pdf` | Andersen, O'Rourke, Liu, Snider, Lowdermilk, Truong, Cooper, Popović — *The Impact of Tutorials on Games of Varying Complexity*, CHI 2012 | https://grail.cs.washington.edu/projects/gameplay-analytics/chi2012-tutorial.pdf |
| `command-pattern-nystrom.pdf` | Robert Nystrom — *Command*, in *Game Programming Patterns* | https://gameprogrammingpatterns.com/command.html |
| `input-buffering-wayline.md` | Gemma Ellison — *Input Buffering: The Key to Responsive Game Feel* | https://www.wayline.io/blog/input-buffering-responsive-game-feel |
| `faulkner-cinque-utenti.pdf` | Laura Faulkner — *Beyond the five-user assumption*, Behavior Research Methods 35(3), 2003 | https://link.springer.com/article/10.3758/BF03195514 |
| `show-or-tell-fdg2024.pdf` | Anderson, Carpenter, Hussein, DeLiema — *Show or Tell?*, FDG 2024 | https://doi.org/10.1145/3649921.3650021 |
| `gdscript-guida-di-stile.pdf` | *GDScript style guide*, documentazione ufficiale di Godot | https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html |
| `complessita-cognitiva-sonar.pdf` | G. Ann Campbell — *Cognitive Complexity: a new way of measuring understandability*, SonarSource | https://www.sonarsource.com/resources/cognitive-complexity/ |

## Perché non le committiamo e basta

Le committiamo eccome — stanno qui dentro apposta. Questa cartella non è
codice e non entra in nessun tetto strutturale: è la biblioteca del progetto.

## Quello che mi manca ancora (in ordine di quanto cambia il gioco)

Bru: «fammi un elenco del resto delle fonti che non hai potuto vedere per
intero». Questa è la lista, ricavata rileggendo cosa i documenti citano
davvero, non a memoria.

### 1. Le cose su cui poggiano decisioni GIÀ PRESE

**Il carico cognitivo — Sweller.** Dopo che Andersen, «Show or Tell?» e
Faulkner hanno smontato quello che ci avevo costruito sopra, **questo è
l'unico puntello rimasto** di tutto il verdetto sul tutorial
(`docs/tutorial.md` §1, §2). Non ho mai letto una fonte primaria: lo cito da
sintesi. Se dice una cosa diversa, §2 resta senza fondamenta.
- Sweller, *Cognitive Load During Problem Solving: Effects on Learning*,
  Cognitive Science 12(2), 1988 — l'originale
- **Più utile ancora:** Kalyuga, Ayres, Chandler, Sweller, *The Expertise
  Reversal Effect*, Educational Psychologist 38(1), 2003. Dice che
  l'istruzione esplicita aiuta i principianti e **danneggia** gli esperti: è
  esattamente la domanda «il tutorial va saltabile?», e nessuno degli studi
  che ho letto la tocca.

**Kelleher e Pausch — gli Stencils.** *Stencils-based tutorials: design and
evaluation*, CHI 2005. È **l'unico studio che sostiene il blocco del menu**,
e lo conosco solo dalla frase con cui lo descrive Andersen. Il blocco è codice
già spedito (`Menu.principale`, il parametro `spento`). Se Stencils non dice
quello che Andersen riporta, il menu va sbloccato.

**Godot: `InputEvent`, `mouse_filter`, propagazione dell'input.** Ho spedito
una correzione costruita sull'affermazione «un `Button` con `disabled = true`
non emette `pressed` ma si prende lo stesso il click». Ci credo per averlo
visto, ma **non ho mai letto la pagina**. Se le regole di propagazione sono
diverse c'è forse un rimedio migliore (`mouse_filter = PASS`), e quasi
sicuramente altri punti morti che non ho trovato.
- `docs.godotengine.org` → *Using InputEvent*, *InputEvent* (class reference),
  *Control.mouse_filter*

### 2. I numeri che il giocatore SENTE, e che oggi non hanno nessuna fonte

**Le finestre di input: la parata e la raffica.** `QUOTA_PARABILE = 0.80`, e
la raffica di Veronica con `intervallo` da 0.55 a 0.30 e `durata` 0.75. Avevo
citato «6-8 fotogrammi per gli attacchi, 3-4 per le schivate» da una sintesi;
quando hai mandato l'articolo di Ellison ho controllato e **quei numeri lì
dentro non ci sono**. Quindi oggi sono numeri scelti a occhio da me.
- La cosa più utile in assoluto: **il sorgente di Celeste** (Maddy Thorson ha
  pubblicato `Player.cs`), che ha le costanti vere di jump grace e input
  buffer di un gioco spedito. Numeri veri, non consigli.
- In alternativa: un riferimento di frame data di un picchiaduro, o il post
  di Maddy Thorson sul perdono nei controlli.

**Godot: prestazioni e profiling.** Ho citato «l'editor aggiunge overhead a
ogni fotogramma, profila una build esportata». Tutta la tornata
sull'«ingiocabile» è misurata con `prove/misura.sh`, che gira in headless. Se
quella frase ha eccezioni, i numeri di `Misura.gd` possono essere fuorvianti.
- `docs.godotengine.org` → sezione *Optimization*, e *Overview of debugging
  tools* / il profiler

**Un teardown serio di un tutorial JRPG.** L'avevi offerto e non è mai
arrivato. Sto disegnando la lezione di Veronica contro **quello che immagino
faccia Yu-Gi-Oh GX**, non contro qualcosa di misurato. Va bene qualsiasi cosa
battuta per battuta: GX, Persona, un Final Fantasy.

### 3. Le regole di struttura che applico a ogni commit

**Ousterhout, *A Philosophy of Software Design*.** «Moduli profondi contro
moduli sottili», «un passacarte è una bandiera rossa», «la lunghezza da sola
è raramente una ragione per spezzare». Le uso come **regole** in ogni
decisione strutturale — hanno prodotto `Stati.gd`, `Intenzione.gd`, e la
rimozione di tre passacarte. Non ho mai letto il libro. (Se non si trova:
vanno benissimo le slide del suo talk o del corso di Stanford.)

**Parnas, *On the Criteria To Be Used in Decomposing Systems into Modules*,
1972.** «Nascondi la decisione di progetto che cambierà». È il criterio con
cui scelgo cosa estrarre. PDF libero, si trova facilmente.

**Sonar, *Clean as You Code*.** Il cancello strutturale È questa idea
(cricchetto sul codice nuovo). Ho il paper sulla complessità cognitiva, non
questo.

**Connascenza — Page-Jones, o il talk di Jim Weirich.** Citata una volta
sola: la più bassa della lista.

### Quello che NON serve procurare

- **Lo studio del MIT sull'istruzione esplicita e i bambini col giocattolo.**
  È un'analogia fra psicologia dello sviluppo e un'interfaccia di
  combattimento. Anche se è accurato, il transfer non c'è: **lo tolgo invece
  di verificarlo.**
- **Nielsen 1993 e Virzi 1992**, gli originali della regola dei cinque
  utenti: superati per il nostro scopo da Faulkner, che adesso ho per intero.
