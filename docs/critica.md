# La critica — Carnivalz giudicato duro

> Scritto l'**11 settembre 2026**, dopo i tre studi (`godot.md`, `mestiere.md`, `lezioni.md`).
> Bru ha chiesto una rivalutazione critica con dei voti da 1 a 10, **in ottica di migliorarlo**.
>
> Ogni voto ha sotto **la prova che l'ha prodotto** — un numero preso dal progetto, non
> un'impressione. Dove non ho la prova, il voto non c'è e sta scritto perché.

---

## Prima di tutto: cosa non posso giudicare

Va detto subito, perché altrimenti tutti i voti sotto valgono meno di quello che sembrano.

**Non ho mai giocato a Carnivalz.** Ho letto ogni riga del codice, ho fatto girare 26.270 verifiche
e ho letto la tabella di 187.200 partite simulate. Ma **non l'ho visto muoversi**, e da quel che
risulta non l'ha ancora visto muoversi nessuno per davvero.

Quindi non posso dare un voto a:

- **come si sente** — il peso di un colpo, il ritmo di una battuta, se è divertente
- **se la storia funziona** — posso giudicare la scrittura riga per riga, non se ti prende
- **la direzione artistica** — per il motivo che leggi subito sotto

Questi tre sono, messi insieme, **la maggior parte di quello che decide se un gioco piace**. Un
voto dato da chi ha solo letto il codice va pesato per quello che è.

---

## Il fatto che domina tutto

```
immagini in tutto il progetto:                    0
asset citati nei dati:                           75
asset che non esistono su disco:                 75
ritratti che il gioco cerca:                     45
file audio:                                       0
```

**Non c'è niente da guardare e niente da sentire.** Non è un dettaglio da sistemare dopo: è
**l'intero canale visivo e sonoro di un medium audiovisivo**, e oggi è vuoto.

Il codice per mostrarli c'è tutto — ritratti, illustrazioni, mappe, musica per zona. È una
macchina completa che gira a vuoto.

Questo fatto pesa su metà dei voti sotto, e va tenuto in mente leggendoli.

---

# I voti

## Fondamenta tecniche — **9/10**

**La prova:**

| | |
| --- | --: |
| Verifiche automatiche | **26.270** |
| Prove | 72 |
| Dichiarazioni tipizzate / non tipizzate | **2.121 / 3** |
| Funzioni con tipo di ritorno | **727 / 727** |
| Partite simulate per il bilanciamento | **187.200** |

E il dettaglio che conta più dei numeri: **ogni prova nuova viene validata rompendo apposta la
meccanica che misura.** Una prova che non diventa rossa quando rompi la cosa non serve a niente, e
quelle le riscrivo. Non è una pratica comune nemmeno in software commerciale.

**Perché non 10:** le istanze perse all'uscita che nessuno ha mai indagato; `GameState` che tiene
anche lo stato del combattimento in corso, cioè roba locale a una scena dentro un globale; e il
renderer lasciato al default Forward+, che per un 2D è probabilmente la scelta sbagliata.

**Come si alza:** sono tre cose piccole e note. Questo voto è già quasi al soffitto.

---

## Documentazione e chiarezza del progetto — **8,5/10**

**La prova:** dodici documenti, di cui quattro compilabili a mano, tre di studio, quattro generati
da strumenti. Ogni decisione di design ha scritto accanto **il perché**, e nei dati i numeri miei
sono marcati come miei (`_bru`, `_perche`, `_dalla_descrizione`).

**Perché non 10:** tre documenti di lettura (GDD, carta, PDF personaggi) sono **stale** e dicono
cose non più vere. E `bilanciamento.md` misura un gioco che non esiste più, perché ho cambiato
status, tipi e progressione nello stesso giorno.

**Come si alza:** rilanciare il simulatore, rifare i tre documenti stale. Mezza giornata.

---

## Identità — cosa rende Carnivalz diverso — **7,5/10**

Questo è **l'asset di design più forte del progetto**, e va detto con la stessa durezza con cui
dirò il resto.

Tre cose che insieme non ce le ha nessun altro:

1. **Lo Studio.** Guardare una creatura riempie il tecno log *a strati* — un studio, uno strato — e
   la scheda in campo si riempie mentre impari. Kurvitz: *la prosa è l'interfaccia attraverso cui
   le meccaniche operano.* Qui è letteralmente così.
2. **La Mediazione.** Tre cancelli — natura, voglia, studio. E la voglia si tira **all'ingresso**,
   quindi la stessa specie è mediabile stasera e non domani. È Toby Fox senza copiarlo: non è un
   bottone di clemenza, è il gioco che ti chiede perché stavi per picchiare.
3. **La barra di dominio** per combattente, con la Mattanza che la svuota.

**Perché non di più:** l'identità è **dichiarata nei sistemi e non ancora dimostrata al giocatore**.
La Mediazione oggi funziona per **una creatura su trentanove** — la Tartaruga. Le altre 38 righe di
`mediazione.md` sono vuote. Un'identità che si manifesta nel 2,5% dei casi non è ancora un'identità:
è una promessa nel codice.

**Come si alza:** compilare anche solo i 18 nemici comuni. Diventa **8,5** il giorno in cui un
giocatore incontra la Mediazione tre volte in una partita invece di una.

---

## Meccaniche di combattimento — **6,5/10**

**Quello che regge, misurato:**

| Strategia | Vittoria media su 1.248 righe |
| --- | --: |
| attacca | 50% |
| studia | 50% |
| casuale | 39% |
| **difendi e basta** | **1%** |

Quest'ultima riga è **una risposta vera a una domanda di design**: le fonti dicono che *se la
strategia che non attacca mai vince, lo scontro è rotto*. Difendere e basta vince in **5 casi su
312**. Gli scontri non sono rotti in quel verso. E **zero scontri infiniti**, che era un problema
reale prima.

Che *attacca* e *studia* si equivalgano al 50% è la cosa migliore di questa tabella: **la strada
che il gioco vorrebbe insegnare costa quanto quella diretta.** Non è un caso, è stato costruito.

**Quello che non regge:**

- **Zero juice.** Cercato `scossa`, `shake`, `hit_stop` in tutto il progetto: **niente**. Un
  combattimento a turni non ha il feedback immediato, quindi deve *inventarsi* come trasmettere
  la soddisfazione in differita — e noi non ci abbiamo ancora provato.
- **`colori_danno` ha 11 voci e nessuna per «mancato».** Un colpo parato oggi pesa quanto uno
  andato a segno. Attenzione spesa su un non-evento.
- **I gradi III-VI hanno il colpo e non il fiocco.** «×3, e lascia Frastornato» fa il ×3; il
  Frastornato no. Diciotto mosse su trentasei sono a metà.
- **Tre problemi noti mai toccati:** il Divoratore si cura del 145%, Oppresso e Robo Pattuglia
  fanno scontri da 30 giri, Fomentado si uccide da solo.

**Come si alza:** l'hit-stop e il colore del mancato sono **due pomeriggi** e valgono mezzo punto
ciascuno. I tre problemi di bilancio valgono un altro mezzo punto. **7,5 è raggiungibile in una
settimana.**

---

## Progressione — **6/10**

**Quello che è buono davvero:** l'hype risolve **tre problemi reali** che avevi individuato tu, non
io. Chi non combatte non resta indietro (moneta unica). Il livello non sale da solo, quindi non
esiste il tesoreggiamento. Il mondo si regola sulla **media**, quindi chi porta avanti uno solo non
spacca la difficoltà.

E la rigiocabilità è una conseguenza pulita: a livello 130 torni sui bivi e prendi l'altro ramo.

**Quello che manca:** **la costellazione non esiste.** Il lettore PNG è pronto e provato su 12
punti sintetici, ma il disegno non è arrivato. Quindi oggi *il livello è quanti nodi hai comprato*,
ma **i nodi sono una lista, non una mappa**. Tutta la parte che dovrebbe essere seducente — vedere
la costellazione accendersi — non c'è.

Ed è il punto in cui il tuo stesso brief non è ancora soddisfatto: *«la gente vuole comprare,
spendere punti e ricevere ricompense»*. Comprare c'è. **Vedere cosa hai comprato, no.**

**Come si alza:** il disegno. È **l'unica cosa in tutto questo documento che non posso fare io.**

---

## Scrittura — **6/10**

Ho letto un campione vero, non a memoria. La verità è che **è disuguale**, e le due metà sono
molto distanti.

**Il meglio è buono per davvero.** L'apertura della Casa Gigante:

> *«Mi diceva mia madre: i bravi bambini restano lontani dalla grande casa in mezzo al bosco, non si
> avvicinano neanche per cogliere un fiore coperto di rugiada.»*

Quella è una voce. È una fiaba che minaccia, ha un ritmo suo, e fa quello che Vonnegut chiede a
ogni frase: rivela un personaggio *e* fa avanzare l'azione.

**Il peggio è irregolare.** Nello studio di Jongo Dongo: *«Non devo dare spiegazioni e chi vuole
farci del male!»* — c'è un errore di grammatica (*a chi*, non *e chi*). E le osservazioni del
Tenero Ricordo sono corrette ma generiche: *«Trasuda un'energia oscura indescrivibile»* è la frase
che si scrive quando non si è ancora deciso cosa sia.

**Il numero che spaventa:** `testi_da_correggere.md` ha **11.962 righe**, e per tua ammissione non
è mai stato riletto tutto.

**Come si alza:** non serve riscrivere. Serve **una passata sola con un filtro solo** — quello di
Vonnegut: *questa frase rivela un personaggio o fa avanzare l'azione?* Con 16 parole al minuto a
disposizione, quello che non fa né l'una né l'altra sta rubando il posto.

---

## Presentazione — effetti, UI, arte, suono — **2/10**

Questo è il voto brutale, e non c'è modo di ammorbidirlo onestamente.

**Zero immagini. Zero file audio. 75 asset citati, 75 mancanti.**

Il 2 e non l'1 è per queste cose, che esistono e sono fatte bene:

- Le **pause di punteggiatura** (virgola 0,10 · punto 0,26 · sospensione 0,45) — il testo respira
  dove respirerebbe una voce. Non l'ho trovata in nessuna fonte sui giochi: è una cosa nostra.
- I **tempi centralizzati** in `stile.json`, tutti dentro la finestra raccomandata dal motion design.
- La **velocità del testo regolabile**, più testo grande e alto contrasto: accessibilità che la
  maggior parte dei progetti aggiunge dopo, se mai.
- L'**audio sintetizzato a runtime** — che per l'interfaccia è una soluzione legittima e furba.

Ma sono **le fondamenta della presentazione, non la presentazione.** È un impianto elettrico
perfetto in una casa senza lampadine.

**Come si alza:** questo voto non si alza scrivendo codice. Si alza solo con disegni.

---

## Contenuto — **4/10**

| Zona | Nodi |
| --- | --: |
| Casa Gigante | **79** |
| Rocca Ossidiana | 37 |
| Meridia | 28 |
| Squarcio Industriale | 27 |
| Kizako Ala | 8 |
| Teatro del Passato | 6 |
| Fontana | 3 |
| Qualcosa Preme | 1 |

**189 nodi in otto zone, ma quattro zone su otto ne hanno meno di dieci.** La distribuzione dice
che due zone sono finite, due sono a metà e quattro sono appena abbozzate.

39 creature, che per una demo che arriva al livello 18 sono **tante, non poche** — e infatti
diciannove su trentanove sono Tetro, cioè la varietà è più nel numero che nella sostanza.

**Come si alza:** non aggiungendo zone. **Chiudendo quelle aperte.** E la regola d'oro di Romero
dice anche da dove ricominciare: *finisci il primo livello per ultimo*. Il tutorial è stato scritto
per primo, e da allora sono cambiati menu, status, tipi, hype e Mediazione.

---

# I due numeri finali

Dare un numero solo sarebbe disonesto, perché risponderebbe a due domande diverse con la stessa
cifra.

## Come prodotto che un giocatore può comprare oggi: **3/10**

Non perché sia fatto male. Perché **non si può vendere una cosa che non si vede**. Un gioco senza
un'immagine non supera il primo screenshot di una pagina Steam, e tutto il resto — i sistemi, le
26.270 verifiche, la Mediazione — non arriva mai a essere visto da nessuno.

## Come progetto, per quanto è messo bene: **7/10**

Ed è un sette alto. Le fondamenta sono da 9. L'identità di design è reale e non derivativa. Le
decisioni sono registrate col loro perché. Il bilanciamento è **misurato** invece che indovinato, e
questo quasi nessuno lo fa.

**La distanza fra 3 e 7 è tutta in una cosa sola: nessuno ha ancora disegnato niente.**

---

# L'osservazione scomoda

C'è una cosa che ho notato guardando il progetto nell'insieme, e la dico perché è più utile di un
altro voto.

**I sistemi sono molto più avanti di tutto il resto, e continuano ad allontanarsi.**

Oggi ho aggiunto otto status, cinque tipi con la tabella delle efficacie, due personaggi giocabili,
trentasei mosse, l'hype, la mediazione e sette tipi di abilità. Il gioco ha più meccaniche di
stamattina e **esattamente le stesse zero immagini**.

Non è un caso ed è in parte colpa mia: i sistemi sono la cosa che so fare, quindi quando chiedi
«cosa manca» io trovo sistemi che mancano. È un ciclo che si alimenta, e alla fine si arriva ad
avere un motore bellissimo per un gioco che nessuno ha mai visto.

**Le due cose che sbloccherebbero di più, e che non posso fare io:**

1. **Il disegno della costellazione.** Sblocca la progressione, che è il cuore del tuo brief
   sull'addictive.
2. **Anche solo cinque ritratti.** Non quarantacinque: cinque. Protagonista, Veronica, Yhvina, e
   due nemici. Basterebbe a far vedere se l'impianto visivo regge, e a smettere di costruire al
   buio.

Se dovessi scegliere fra un'altra settimana di sistemi e cinque disegni, **sceglierei i cinque
disegni senza esitare** — e sono quello che i sistemi li scrive.

---

## Riepilogo

| Voce | Voto | Cosa lo muove |
| --- | --: | --- |
| Fondamenta tecniche | **9** | Tre cose note e piccole |
| Documentazione | **8,5** | Rilanciare il simulatore, rifare i tre documenti stale |
| Identità | **7,5** | Compilare `mediazione.md` |
| Meccaniche | **6,5** | Hit-stop, colore del mancato, i tre problemi di bilancio |
| Progressione | **6** | Il disegno della costellazione |
| Scrittura | **6** | Una passata col filtro di Vonnegut |
| Contenuto | **4** | Chiudere le zone aperte, riaprire il tutorial |
| **Presentazione** | **2** | **Solo disegni. Niente codice aiuta qui** |
| | | |
| **Come prodotto, oggi** | **3** | |
| **Come progetto** | **7** | |

---

## Poscritto, lo stesso giorno — e una cosa che avevo scritto male

Dopo questa pagina Bru ha chiesto di migliorare codice, effetti e logica, e una parte di quello che
sta qui sopra è già cambiata. Aggiorno le voci mosse invece di rifare i voti: un giudizio datato
serve proprio perché resta datato.

| Voce | Cosa dicevo che serviva | Cosa è successo |
| --- | --- | --- |
| Meccaniche **6,5** | «Hit-stop, colore del mancato, i tre problemi di bilancio» | Il fermo immagine c'è, insieme a scossa e scatto. Il tipo adesso si vede nel numero (colore + ▲ / ▼ / ✕). Uno dei tre problemi è chiuso — il Divoratore — e non limandolo, ma con una regola di motore |
| Presentazione **2** | «**Solo disegni. Niente codice aiuta qui**» | **Qui avevo torto, ed è la riga peggiore del documento.** Il fondo dell'arena adesso prende il colore del tipo che hai davanti e i bordi si chiudono quando stai per cadere: è presentazione, è fatta di codice, e non ha richiesto nemmeno un disegno |

Quella frase non era una svista di misura, era un errore di ragionamento: avevo contato la
presentazione come se fosse **solo** figure, e da lì «niente codice aiuta» sembrava ovvio. Un gioco
senza un disegno ha comunque colore, ritmo, peso e silenzi — e quelli si scrivono.

**Non sposta i due numeri grossi.** Un fondo tinto e dei bordi che si chiudono non fanno un gioco
vendibile: le due cose che sbloccano davvero restano **il disegno della costellazione** e **anche
solo cinque ritratti**. Ma la Presentazione non è più a fondo scala per mancanza di strumenti: è
bassa perché mancano i disegni, che è una frase diversa.

---

*La critica · scritta l'11 settembre 2026 · poscritto lo stesso giorno · ramo `claude/inizio-progetto-dya2lr`*
