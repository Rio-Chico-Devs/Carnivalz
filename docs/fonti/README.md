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
