# Il controllo a basso livello — 24 settembre 2026

Bru: *«puoi fare un check a basso livello? un controllino alle radici del codice e
i livelli più bassi è d'obbligo ora, se non sai o hai dubbi documentati da fonti
attendibili»*.

La caccia del 23 settembre (`docs/caccia.md`) guardava il gioco: cosa arriva a
schermo, cosa si rompe giocando. Questa guarda sotto: **come si comporta il
motore sotto il nostro codice**, e se il codice lo sa. Sono le cose che non si
vedono finché non cambiano — un confronto che vale per contenuto invece che per
identità, un numero che torna float, una funzione che muore a metà senza dirlo.

---

## Le fonti

Due, e nessuna di seconda mano.

1. **Il riferimento ufficiale delle classi di Godot 4.7**, cioè lo stesso testo
   della documentazione del sito. Il sito e il repository su GitHub, da dove
   lavoro, non si raggiungono (la rete dell'ambiente li blocca). Ma l'editor di
   Godot se lo porta dentro, compresso, per la sua guida: l'ho estratto
   dall'eseguibile che fa girare il gioco. È una fonte migliore di una pagina
   web, perché è **la versione esatta** che usiamo, non quella che il sito
   mostra oggi. Lo strumento per rifarlo è `strumenti/riferimento_godot.py`:

   ```
   python3 strumenti/riferimento_godot.py /percorso/godot Dictionary Array.sort_custom
   ```

2. **Il motore stesso, dove il riferimento tace.** Il riferimento delle classi
   non dice cosa succede a una funzione ferma su `await` quando il suo oggetto
   sparisce: quello è il linguaggio, non una classe. Lì ho scritto esperimenti
   minimi e li ho fatti girare su Godot 4.7. Un esperimento sul motore che usi è
   una fonte attendibile quanto la documentazione — e le regole che ne sono
   uscite ora stanno nella suite (`prova_il_motore_si_comporta_come_il_codice_crede`),
   così se un aggiornamento di Godot ne cambia una lo si sa subito.

---

## In breve

| # | Cosa | La fonte | Il codice | Esito |
|--:|---|---|---|---|
| 1 | **Dopo un caricamento tutti i numeri della partita tornavano float** (livello 3 → 3.0) | JSON.stringify: «converts all numerical values to float types» | reggeva, perché ogni lettura passa da `int()`; ma dentro array e dizionari il tipo conta | **corretto**, prova, 4 sabotaggi |
| 2 | **Il dado ripartiva dal seme a ogni caricamento**: il primo tiro dopo ogni caricamento era il primo tiro della partita | RandomNumberGenerator.state: «Save and restore this property to restore the generator» | salvava solo il seme | **corretto**, prova, 2 sabotaggi |
| 3 | Confronto fra combattenti | `==` fra dizionari confronta **il contenuto**; `is_same` l'identità | i combattenti si distinguono per `indice` (unico) o con `is_same`: nessun `==` fra combattenti | a posto |
| 4 | Array modificati mentre si scorrono | Array.erase: «not supported and will result in unpredictable behavior» | nessun caso, nemmeno indiretto (un ciclo sui combattenti che evoca) | a posto |
| 5 | Ordinamenti | Array.sort_custom: «not stable» | il giro dei turni spareggia fino all'indice; gli altri due ordinano punti di un disegno | a posto |
| 6 | Dado globale | shuffle, pick_random, randi: «a common, global random seed» | tutto ciò che decide un esito usa `GameState.rng`; il globale serve solo al rumore dei suoni | a posto |
| 7 | Timer e pausa | create_timer: senza `process_always = false` il timer corre anche in pausa | tutti quelli che devono fermarsi lo dicono; l'unico che corre in pausa (il fermo immagine) lo fa apposta e lo scrive | a posto |
| 8 | Tween | quelli di `SceneTree` non muoiono col nodo; un giro infinito a durata zero si blocca | tutti creati su un nodo; le durate hanno un ripiego di 0,3 s, mai zero | a posto |
| 9 | Segnali collegati due volte | Object.connect: «A signal can only be connected once», se no errore | ogni `connect` fuori da `_ready` è su un bottone appena creato o in una funzione chiamata una volta | a posto |
| 10 | Divisioni per zero | un intero diviso zero è un errore; un float dà infinito | 173 divisioni, 83 per una variabile: tutte protette (`maxi(…, 1)`, un controllo prima) o su float | a posto |
| 11 | Funzioni ferme su `await` quando l'oggetto sparisce | esperimento | muoiono in silenzio, senza errori. **E un `RefCounted` che nessuno tiene muore a metà di un `await`** | i due moduli con `await` (Voce, Mazzata) hanno un padrone per tutto lo scontro: a posto |
| 12 | Il doppione che misura il box di testo | Node.duplicate: copia le proprietà salvate, niente script né segnali con i flag a 0; get_content_height: esatto se `threaded` è spento | il testo del box non ha script e non è threaded | a posto |
| 13 | Ordine di avvio degli autoload | — | nessun `_ready` (né quello che chiama) usa un autoload che parte dopo | a posto |
| 14 | Thread | — | nessuno | niente da guardare |
| 15 | Perdite di memoria | contatori di Performance, `--verbose` all'uscita | nodi fermi, nodi orfani a zero, risorse ferme; gli oggetti crescono per 8 scontri e poi si fermano (una cache che si riempie) | nessuna perdita |
| 16 | Determinismo | — | stesso seme, stesso scontro, colpo per colpo | a posto |
| 17 | Salvataggio che si rovina | FileAccess.WRITE azzera il file prima di scriverci | già risolto il 23 (`FileSicuro`: scrive accanto e scambia, rilegge, tiene la riserva) | a posto |

E un'osservazione che non è un difetto di basso livello ma è saltata fuori qui:
**un doppione di carta arriva in silenzio**. Nel bottino si scrive la carta solo
se è nuova; il doppione viene contato (`carte_copie`) ma non detto. Può essere
voluto — decide Bru.

---

## I due difetti

### 1. Un intero salvato tornava float

JSON non ha interi e float: ha «numeri». Godot lo dice nel riferimento di
`JSON.stringify`: *«converting a Variant to JSON text will convert all numerical
values to [float] types»*. Quindi una partita salvata col livello 3 si ricaricava
col livello 3.0. L'ho misurato: su una partita con livelli, esperienza, stress,
contatori, punti, carte e resistenze, **tutti e nove i numeri** tornavano float.

Oggi il gioco reggeva, perché ogni lettura di quei valori passa da `int()` — e
nessuna schermata mostrava un «.0» (guardate Sede, Selezione, Bestiario, Album,
Compendio: 381 testi). Ma il tipo, dentro i contenitori, conta. Misurato su
Godot 4.7:

| | risultato |
|---|---|
| `7 == 7.0` | vero |
| `[3, 2] == [3.0, 2.0]` | **falso** |
| `{"a": 5} == {"a": 5.0}` | **falso** |
| `[7.0].has(7)`, `7 in [7.0]` | **falso** |
| `match 5.0` contro il caso `5` | **non entra** |
| un dizionario con chiave `5`, cercando `5.0` | **non trova** |
| `str(5.0)`, `"%s" % 5.0` | **«5.0»** |

Il primo pezzo di codice che avesse usato uno di questi su un valore salvato
avrebbe sbagliato **solo dopo un caricamento** — cioè esattamente dove una prova
che gioca da una partita nuova non guarda mai.

**Corretto alla radice**: `FileSicuro.interi()` rimette interi i numeri senza
parte decimale (fino a 2⁵³, oltre il quale un float non è più esatto), e il
caricamento della partita ci passa. I decimali veri restano decimali. Le
impostazioni, che hanno float veri (il volume), non passano di lì.

### 2. Il dado ripartiva dall'inizio

Il salvataggio teneva il **seme** del dado, non il suo **stato**. A ogni
caricamento il dado ricominciava dal primo tiro della partita: quello che è
uscito all'inizio del gioco usciva di nuovo dopo ogni caricamento, ovunque tu
fossi arrivato. Il riferimento di `RandomNumberGenerator.state` è esplicito:
*«Save and restore this property to restore the generator to a previous state»*.

**Corretto**: si salva anche lo stato (`"dado"`, come testo: è un intero a 64 bit,
e JSON lo farebbe float — vedi sopra), e `riprendi_il_dado()` lo rimette. Un
salvataggio vecchio, che non ce l'ha, riparte dal seme come prima.

---

## La regola che il codice deve sapere

L'esperimento sulle funzioni ferme su `await` ha dato tre risultati, e il terzo
è una trappola:

1. un nodo liberato mentre una sua funzione aspetta `process_frame`: la funzione
   muore, **senza errori**;
2. un nodo liberato mentre aspetta il segnale di un altro: uguale;
3. **un `RefCounted` a cui nessuno tiene più un riferimento muore a metà del suo
   `await`**, in silenzio. Non c'è nessun «padrone implicito» della funzione in
   corso.

Vuol dire che le guardie `viva()` nel combattimento sono giuste (e a volte più
prudenti del necessario), e che **ogni modulo con un `await` deve avere un
padrone per tutta la durata dell'attesa**. Oggi ce l'hanno: Voce e Mazzata sono
tenute dallo scontro. Un modulo nuovo creato al volo e lasciato andare
smetterebbe di funzionare a metà senza dirlo.

---

## Le prove

- `prova_il_salvataggio_rende_i_numeri_e_il_dado_come_erano`: salva una partita
  con numeri e un dado già usato, la ricarica, e pretende gli stessi cinque tiri
  e numeri interi; e che `interi()` non tocchi i decimali, scenda negli array e
  nei dizionari, e si fermi a 2⁵³. **Sei sabotaggi, tutti presi**: niente
  conversione, conversione che arrotonda i decimali, niente tetto a 2⁵³,
  conversione che non scende negli array, dado non ripreso, dado non salvato.
- `prova_il_motore_si_comporta_come_il_codice_crede`: le regole del motore su
  cui il codice si appoggia, scritte come verifiche — i dizionari per contenuto
  e `is_same` per identità, JSON che restituisce float e il tipo che conta nei
  contenitori, il `RefCounted` senza padrone che muore nell'`await`, lo stato
  del dado. Se un aggiornamento di Godot ne cambia una, la suite lo dice.
