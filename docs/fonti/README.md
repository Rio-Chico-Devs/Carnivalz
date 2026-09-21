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

## Perché non le committiamo e basta

Le committiamo eccome — stanno qui dentro apposta. Questa cartella non è
codice e non entra in nessun tetto strutturale: è la biblioteca del progetto.
