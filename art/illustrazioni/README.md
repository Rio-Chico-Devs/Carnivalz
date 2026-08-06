# Illustrazioni delle scene

Qui vanno i disegni **singoli a schermo intero**: non ritratti di personaggi, ma quadri
che una scena si ferma a mostrare. La scena si oscura, compare l'immagine con la sua
didascalia sotto, e al click la scena riprende da dove era.

Li chiama un messaggio della `sequenza` di un nodo evento:

```json
{
  "tipo": "immagine",
  "file": "res://art/illustrazioni/file_reparto_montaggio.png",
  "testo": "In fila davanti alla catena ci sono più uomini di quanti quel reparto potesse contenerne."
}
```

Formato: PNG, orizzontale, qualunque misura — il gioco scala mantenendo le proporzioni
dentro un riquadro di circa 760×460.

**Se il file non c'è ancora non si rompe niente:** resta la didascalia, a schermo intero, e
la scena si legge lo stesso. Le illustrazioni si possono quindi fare con calma, dopo aver
scritto le scene.

Proprio per questo `prove/Prove.gd` fa due controlli (`prova_illustrazioni`), altrimenti un
percorso scritto storto sarebbe indistinguibile da un disegno non ancora fatto:

- ogni messaggio `immagine` deve avere una **didascalia** (è quello che resta) e un `file`
  dentro questa cartella, con estensione `.png`;
- ogni file **messo qui** deve essere chiamato da qualche scena — un disegno che nessuno
  chiama è un nome sbagliato dall'altro lato.

L'elenco di quelle che servono, con la didascalia di ognuna e la spunta di quelle già fatte,
si rigenera in `docs/immagini.md` con `python3 strumenti/genera_immagini.py`.
