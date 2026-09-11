# Godot — quello che serve sapere

> **Documento di studio**, non di progetto. Raccoglie quello che ho trovato su Godot da fonti
> pubbliche il **11 settembre 2026**, diviso in quattro livelli, più una quinta parte che dice
> **cosa di tutto questo riguarda Carnivalz davvero** — con i numeri misurati sul nostro codice,
> non consigli generici.
>
> Le fonti sono in fondo. Dove una cosa è una mia deduzione e non una fonte, è segnato.

---

## Come leggerlo

| Stack | Per chi | Cosa ci trovi |
| --- | --- | --- |
| **1 · Fondamenta** | Chi apre l'editor la prima volta | Nodi, scene, GDScript, segnali, Resource |
| **2 · Intermedio** | Chi ha un gioco che gira e vuole che non si rompa | Rendering, UI, salvataggi, esportazione |
| **3 · Avanzato** | Chi ha un collo di bottiglia vero | Server, thread, GDExtension, memoria |
| **4 · Il mondo reale** | Chiunque voglia *spedire* | Cosa si rompe in produzione, e chi ce l'ha fatta |
| **5 · Carnivalz** | Noi | Cosa ci riguarda, cosa abbiamo già giusto, cosa no |

---

# Stack 1 · Fondamenta

## L'idea centrale: tutto è un nodo, e i nodi fanno alberi

Godot non ha entità con componenti attaccati sopra. Ha **nodi** che ereditano l'uno dall'altro e
si annidano in un albero. Una scena è un pezzo di albero salvato su disco, e una scena può essere
istanziata dentro un'altra come se fosse un nodo solo.

La conseguenza pratica: **una scena deve funzionare senza sapere dove la metti.** Il momento in cui
una scena figlia cerca `get_node("../../GameManager")` è il momento in cui hai smesso di poterla
riusare, e il giorno che la sposti non ti dà un errore di compilazione — ti dà un `null` a runtime.

## La regola che regge tutto: *call down, signal up*

È l'unica regola di architettura che vale la pena imparare a memoria.

| Direzione | Come si comunica |
| --- | --- |
| **Verso il basso** (un padre chiama un figlio) | Chiamata diretta. `get_node()` va benissimo: il padre sa cosa ha dentro |
| **Verso l'alto** (un figlio avvisa il padre) | **Segnale.** Il figlio non deve sapere chi lo ascolta |
| **Fra fratelli** | Il segnale del primo lo collega **il padre comune**, che per definizione li conosce entrambi ed è pronto dopo tutti e due |
| **Fra sistemi lontani** | Un *event bus*: un autoload che contiene solo segnali |

Il motivo per cui non è pedanteria: un riferimento diretto verso l'alto **incolla** i due oggetti.
Un segnale no. Chi emette non sa chi ascolta, e questo è esattamente ciò che ti permette di
cambiare il resto senza rompere questo.

## GDScript: la cosa che fa la differenza più grande

**Tipizzare.** Non è stile, è velocità misurata:

| Cosa | Guadagno col tipo dichiarato |
| --- | --: |
| Aritmetica sugli interi | 28-36% |
| Operazioni sui Vector2 | 55-59% |
| Chiamate a funzioni native | fino a 150% |

Il motivo è che senza tipo il runtime deve, **a ogni singola operazione**, capire cosa ha per le
mani e scegliere l'operazione giusta. Col tipo dichiarato quel lavoro sparisce: il compilatore
emette l'istruzione specifica una volta sola.

Si scrive in due modi, e valgono uguale:

```gdscript
var vita: int = 100        # esplicito
var vita := 100            # inferito - Godot deduce int, ed è comunque tipizzato
var vita = 100             # NON tipizzato: questo è quello che costa
```

## La trappola di GDScript che nessuno ti dice

**Un errore a runtime non fa crashare il gioco: interrompe la funzione dov'è successo e lascia
proseguire tutto il resto.** Godot è progettato apposta per essere difficile da far crashare, e per
questo le eccezioni sono state rifiutate.

Il prezzo è che un errore *non si vede*. Una funzione che esplode a metà ha già fatto la prima
metà del suo lavoro, non fa la seconda, e non lo dice a nessuno. Dall'esterno sembra una funzione
che fa poco, non una funzione rotta.

> È esattamente il buco che abbiamo tappato due volte in questo progetto: una `%s` di troppo in una
> frase interrompeva l'abilità a metà, e sembrava solo un'abilità debole.

## Resource: i dati separati dalla logica

Un `Resource` è un contenitore di dati che si salva su disco e si condivide fra scene. È il modo
canonico di fare un gioco *data-driven* in Godot.

**Node o Resource?** La regola pratica: serve una rappresentazione visiva, o serve stare
nell'albero per ricevere il `delta` a ogni frame? → Node. Altrimenti → Resource.

Un avvertimento: le Resource personalizzate **non emettono `changed()` da sole**. Se ti serve
sapere quando cambiano, devi chiamare `emit_changed()` a mano nei setter.

## Autoload (singleton): utilissimi, e la cosa più abusata del motore

Un autoload è uno script caricato all'avvio e sempre raggiungibile per nome.

**Quando ha senso:** una cosa che deve sopravvivere al cambio di scena o essere condivisa da tutto
il gioco — il salvataggio, le impostazioni, un bus di eventi. *L'autoload più utile in assoluto è
un bus di eventi: uno script che non contiene altro che segnali.*

**Quando è un errore:** quando lo usi per non dover passare un riferimento. Le fonti sono
concordi e dure su questo — è «la funzionalità più abusata del motore». Il sintomo: un autoload
con dentro vita del giocatore, numero di nemici, inventario, dialogo corrente, etichette della UI,
musica del livello e flag di debug. A quel punto non è un sistema, è **un cassetto della
spazzatura**, e al terzo mese la lista degli autoload *è* il progetto.

---

# Stack 2 · Intermedio

## I tre renderer, e perché la scelta conta anche in 2D

| Renderer | Per chi | Nota |
| --- | --- | --- |
| **Forward+** | Desktop, 3D ambizioso | **Default su desktop.** Scala benissimo con tanti oggetti e tante luci, ma ha un **costo di base più alto**: una scena semplice può andare *peggio* |
| **Mobile** | Dispositivi deboli | Semplificato, meno funzionalità |
| **Compatibility** | GPU vecchie, web, mobile basso | Nato per chi non ha Vulkan, ma **va molto bene anche su hardware nuovo** |

La riga che conta per un gioco 2D: *Forward+ ha una base più cara, e in una scena semplice può
rendere meno.* Un RPG 2D non ha niente da guadagnare dal renderer più avanzato.

## Draw call: il vero collo di bottiglia

Il collo di bottiglia tipico di Godot **non è il linguaggio di scripting**: sono le *draw call* e
la complessità dell'albero delle scene.

Per il 2D la leva principale è il **TextureAtlas**: sprite che condividono una texture vengono
raggruppati in una draw call sola. Con un dettaglio che fa perdere ore a chi non lo sa: **tutti
gli sprite dentro un atlas devono avere le stesse impostazioni di compressione** — compressioni
miste costringono Godot a spezzare il raggruppamento.

## UI: ancore e container, e l'errore che fanno tutti

Due modi di posizionare, e vanno capiti come due cose diverse:

- **Ancore** — dove si "attacca" un elemento rispetto al genitore. Somigliano a `position: absolute`.
- **Container** — il genitore dispone i figli secondo una regola. Somigliano a `display: flex`.

**L'errore classico:** mettere le ancore e *poi* aggiustare a mano posizione e margini. Il default
è l'angolo in alto a sinistra: se il genitore si ridimensiona, il figlio resta inchiodato lì.

Regola pratica: più elementi con spaziatura coerente (una fila di bottoni, una lista) → **container**.
E le `size_flags` decidono il resto: *Fill* riempie lo spazio assegnato, *Expand* reclama una quota
dello spazio avanzato.

## Profilare: tre regole che valgono più di cento micro-ottimizzazioni

1. **Non profilare nell'editor.** L'editor aggiunge overhead a ogni frame. I numeri veri si
   prendono su una build esportata.
2. **Il frame time non è un numero, sono tre**: lavoro CPU nei tuoi script, lavoro CPU nel motore,
   lavoro GPU nel renderer. Il profiler li separa; gli FPS no.
3. **Profila, cambia una cosa sola, riprofila.** Metà delle ottimizzazioni che sembrano ovvie non
   spostano il frame time, e qualcuna lo peggiora.

## Salvataggi: il formato è anche una scelta di sicurezza

| Formato | Pro | Contro |
| --- | --- | --- |
| **JSON** | Nessuna esecuzione di codice. Leggibile | Niente tipi: ogni `Vector2` lo smonti e rimonti a mano |
| **Resource** (`.tres` / `.res`) | Tipi statici, meno codice, tutti i tipi Godot gratis | ⚠️ **Può eseguire codice** |
| **ConfigFile** | Comodo per le impostazioni | ⚠️ Stessa vulnerabilità |

⚠️ **Il punto di sicurezza, che è serio:** le Resource, `ConfigFile` e `str2var` **possono
eseguire codice**. Caricare un file di salvataggio arrivato da fuori — uno scambiato fra giocatori,
uno scaricato — è un'esecuzione di codice arbitrario sulla macchina di chi gioca. Se usi le
Resource per i salvataggi esistono caricatori sicuri che controllano il contenuto prima.

Convenzione: si sviluppa con `.tres` (testo, leggibile, va d'accordo con git) e si spedisce con
`.res` (binario, veloce, e manometterlo costa più fatica).

## Esportare: il fastidio ricorrente

I **template di esportazione devono corrispondere esattamente** alla versione di Godot
(`4.7.0.stable` con `4.7.0.stable`). Template 4.6 su un progetto 4.7 dà «templates not found» o
un export che fallisce.

E la regola che si impara sempre troppo tardi: **provare la build esportata su una macchina
pulita** prima della prima consegna. È lì che si scoprono i «funziona sul mio computer».

---

# Stack 3 · Avanzato

## I Server: sotto l'albero delle scene

Il nucleo di Godot è fatto di **Server** — API di basso livello per rendering, fisica e audio.
L'albero delle scene è costruito *sopra* di loro. Si può parlare direttamente ai server e saltare
del tutto i nodi.

**Quando serve:** quando l'albero diventa il collo di bottiglia, tipicamente **da qualche centinaio
di oggetti simili in su**. Generazione procedurale, particelle, migliaia di oggetti dinamici.

**Il prezzo:** si lavora con i **RID**, maniglie opache che si allocano e liberano **a mano**.
Dimenticare un `canvas_item_free(rid)` è una perdita di memoria che nessun garbage collector
verrà a rimediare. E i server sono asincroni: **qualunque funzione che ritorna un valore li blocca**,
costringendoli a smaltire la coda.

## Thread: una regola sola, e non si negozia

**L'albero delle scene NON è thread-safe.** Punto.

| Da un thread secondario | Si fa così |
| --- | --- |
| Toccare nodi, scene, UI | **Mai direttamente.** `call_deferred()`, che rimanda al thread principale |
| Passare dati fra thread | Mutex |
| Lavoro pesante davvero parallelo | **I server sono thread-safe**: quella è la strada |

Caricare scene da più thread «può funzionare», ma le risorse in Godot si caricano una volta sola e
due thread che toccano la stessa risorsa danno comportamenti imprevisti o crash.

> E si sposa malissimo con la trappola dello Stack 1: **un errore GDScript dentro un thread viene
> ignorato in silenzio**. Il thread esce prima, il programma continua, e non te lo dice nessuno.

## Memoria: due sistemi diversi nello stesso motore

| Tipo | Come muore |
| --- | --- |
| **RefCounted** (Resource comprese) | Da solo, quando nessuno lo riferisce più |
| **Object e Node** | **A mano.** `free()` o `queue_free()` |

Un `queue_free()` dimenticato dentro un ciclo che genera oggetti perde migliaia di nodi per
sessione. Il nodo **orfano** è quello tolto dall'albero ma mai liberato.

**Come si trovano:** la scheda *Monitors* mostra il conteggio degli orfani e degli oggetti totali;
`print_orphan_nodes()` dice di che tipo sono; e da riga di comando `--verbose` stampa `Leaked
instance: <Tipo>:<id>` per ciascuno.

## GDExtension: quando GDScript non basta

Se una parte è davvero troppo lenta, si riscrive in C++ — e la strada moderna è **GDExtension**,
non i moduli.

| | GDExtension | Modulo C++ |
| --- | --- | --- |
| Compilazione | Solo la tua libreria | **Tutto il motore** |
| Ricarica a caldo | Sì | No |
| Posizione ufficiale | Consigliata | *«usa a tuo rischio»* |

Ma prima di arrivarci vale la pena rileggere Stack 2: **il collo di bottiglia tipico non è il
linguaggio**. Per macchine a stati, logica di UI, dialoghi, inventari e input, la differenza fra
linguaggi non la vedono né i giocatori né il profiler.

---

# Stack 4 · Il mondo reale

## Chi ha spedito davvero

| Gioco | Genere | Risultato |
| --- | --- | --- |
| **Slay the Spire 2** | Roguelike a carte | Picco Steam **574.638 giocatori**. Mega Crit ha **lasciato Unity per Godot dopo oltre due anni** di sviluppo già fatto |
| **Brotato** | Arena shooter | Oltre **10 milioni di copie** entro il 2025 |
| **Dome Keeper** | Roguelike | ~**6,1 milioni** di ricavi |
| **Cassette Beasts** | RPG con mostri | ~**4,1 milioni**. Gli autori: senza Godot «difficilmente ce l'avremmo fatta da soli» |

Il secondo dato è quello che conta di più per noi: **il gioco Godot di maggior successo è un RPG a
turni 2D**, cioè la nostra stessa forma. Non è un motore che regge l'RPG a fatica — è il terreno
dove ha già vinto.

## Quello che si rompe, secondo chi ha spedito

**La comunità è per lo più hobbistica.** L'effetto pratico: i requisiti commerciali — conformità
degli store, certificazioni, integrazioni — spesso te li scrivi da solo, perché nessuno li ha
scritti prima di te.

**Il team rendering è tirato.** I programmatori di rendering sono difficili da trovare, il codice
è difficile da revisionare, e devono servire dall'Android economico al web alle console.

**Il churn delle API.** La critica più diretta che ho trovato, da una sviluppatrice che ha spedito
VR e portato su PSVR2: troppe persone rinominano funzioni e variabili nel motore per «pulizia», a
pezzi e senza una ragione forte. La sua richiesta testuale: *«per favore smettete di rinominare le
funzioni nel motore — qualcuno di noi sta cercando di spedire dei giochi».*

**Altre cose riportate:** file di progetto a volte corrotti o tornati indietro (scene, override,
connessioni di segnali); selezione 3D inaffidabile nell'editor; e almeno un caso di **crash solo in
build Release** mentre in debug andava — cioè il tipo di bug che trovi dopo aver dichiarato finito.

## Web: il punto più debole, e va saputo prima

L'export HTML5 **resta la piattaforma più debole**: i post sui problemi del web superano quelli di
qualunque altra piattaforma.

- Il multithread nel browser richiede due header HTTP (`Cross-Origin-Opener-Policy` e
  `Cross-Origin-Embedder-Policy`). Itch.io li mette lui se spunti l'opzione.
- **Senza SharedArrayBuffer l'audio gracchia**, perché non può essere mixato su un thread dedicato.
- Ci sono stati periodi in cui gli export web non giravano affatto su **macOS e iOS** per bug a monte.

## Multiplayer: sappi cosa NON c'è

Godot dà il trasporto e la replica. **Non dà**: lobby, matchmaking, autenticazione, lista amici,
NAT traversal. E il `MultiplayerSynchronizer` gestisce solo tipi primitivi — un inventario te lo
codifichi e decodifichi a mano in `PackedByteArray`. La stabilità delle connessioni comincia a
soffrire **oltre la quarantina di utenti per server**.

> Riguarda direttamente la decisione che avevi già preso: *prima la campagna, il multiplayer dopo e
> solo se il gioco va*. Le fonti la sostengono — il multiplayer in Godot non è una spunta da
> mettere, è un progetto suo.

## Console: si può, ma passa da un'azienda

Godot è MIT e senza NDA; le console richiedono contratti e accesso chiuso. Le due cose non stanno
insieme, quindi **la Fondazione Godot non mantiene port per console**. Li fa **W4 Games**, fondata
nel 2021 da quattro persone fra cui Juan Linietsky e Rémi Verschelde, cioè chi guidava Godot.

Ci sono port middleware approvati per **Switch, Xbox Series X/S e PS5**, ad abbonamento annuale,
convertibile in licenza perpetua con accordo Enterprise.

## Testare in automatico: si fa, ed è normale

Due framework: **GUT** e **GdUnit4**. Girano headless, si integrano in CI, esportano report JUnit.

Due accorgimenti che le fonti ripetono:
- **Mai committare `.godot/`**: l'import si rifà sul runner.
- Serve un **passaggio di import headless prima** del passaggio di test: due comandi, non uno.

---

# Stack 5 · Cosa riguarda Carnivalz

Qui i numeri sono misurati sul nostro codice oggi, non stimati.

## Quello che abbiamo già giusto, e non per caso

**Il codice è tipizzato praticamente al 100%.** Ho contato:

| | |
| --- | --: |
| Dichiarazioni `var` tipizzate (`:=` o `: Tipo`) | **2.121** |
| Dichiarazioni non tipizzate | **3** |
| Funzioni | **727** |
| Funzioni con tipo di ritorno dichiarato | **727** |

Le tre non tipizzate sono deliberate: tengono un `Control` che può essere `null`, dove il tipo
inferito non aiuterebbe. **La leva di prestazioni più grossa di GDScript — quella che vale fino al
150% sulle chiamate native — è già tirata a fondo.** Non c'è niente da guadagnare lì.

**Il salvataggio è in JSON**, che è il formato **senza esecuzione di codice**. Se un giorno si
scambiano salvataggi fra giocatori, o se ne scarica uno, non c'è la vulnerabilità che hanno le
Resource e `ConfigFile`. Non era una scelta di sicurezza quando è stata fatta, ma è quella giusta.

**Abbiamo già una suite headless** da 26.270 verifiche che gira in CI — la cosa che le fonti
raccomandano e che quasi nessun progetto Godot ha.

## Tre cose che vanno guardate

### 1. Il renderer è il default, e per un gioco 2D probabilmente è quello sbagliato

`project.godot` **non ha una sezione `[rendering]`**: usiamo il default, che su desktop è
**Forward+**. È il renderer «più avanzato», ed è pensato per scene 3D con molti oggetti e molte
luci — a prezzo di un **costo di base più alto**, che in una scena semplice rende *peggio*.

Carnivalz è 2D a 1280×720 con qualche sprite e dei Control. **Compatibility** è nato per le GPU
senza Vulkan ma «funziona molto efficientemente anche su hardware nuovo», gira su molto più
hardware, e ha l'export web meno problematico.

È **una riga** in `project.godot`, e si misura in un pomeriggio. Non l'ho cambiata da solo perché
è una decisione che tocca ogni macchina su cui girerà il gioco.

### 2. Le istanze perse all'uscita: le vediamo e non le abbiamo mai guardate

Ogni volta che gira la suite, Godot stampa:

```
WARNING: ObjectDB instances leaked at exit (run with --verbose for details).
```

Ho verificato oggi che **c'era anche prima delle mie prove** — non l'ho introdotto io — ma non l'ha
mai indagato nessuno. Significa che qualcosa viene tolto dall'albero e mai liberato.

Adesso so come si trova: `--verbose` stampa `Leaked instance: <Tipo>:<id>` per ognuna, e
`print_orphan_nodes()` dice di che tipo sono. **In `scripts/` e `prove/` la parola `orphan` non
compare da nessuna parte**: non lo controlla nessuno.

Oggi non fa male — la suite finisce e il processo muore. Farebbe male **in partita**, in uno scontro
che monta e smonta schede a ripetizione. È il candidato numero uno se un giorno il gioco comincia a
rallentare più a lungo ci giochi.

### 3. Sei autoload, e uno è grosso

```
GameState · AudioManager · Stile · Impostazioni · Transizioni · Pausa
```

Cinque su sei sono esattamente ciò per cui gli autoload esistono: audio, stile, impostazioni,
transizioni, pausa. Sono servizi, non stato.

**`GameState` è l'eccezione da tenere d'occhio.** Ha dentro il salvataggio, il livello, l'hype, la
squadra, la sacca, i flag, il bestiario, i nemici del combattimento corrente, la progressione, il
seme dell'RNG. È il profilo che le fonti descrivono come «non più un sistema, un cassetto della
spazzatura».

Detto onestamente: **non propongo di smontarlo adesso.** In un gioco a scene che si chiudono e
riaprono, lo stato di partita *deve* sopravvivere al cambio di scena, e per quello l'autoload è la
risposta corretta. Il pezzo che non c'entra è lo stato del **combattimento in corso**
(`nemici_combattimento`, `nodo_se_vinci`, `nodo_se_perdi`): quello è locale a una scena e vive in
un globale. Se un giorno vorremo due scontri simulati in parallelo — e il simulatore ci va vicino —
è lì che si romperà.

## Una cosa che devo dirti su come sto provando il codice

Il progetto dichiara **`config/features = "4.7"`**. Le prove che ho girato oggi le ho girate con
**Godot 4.4.1**, perché è quello che sono riuscito a scaricare in questo ambiente.

Vuol dire che **il verde che ti ho riportato è verde su 4.4.1**, non su 4.7. Per le cose che
abbiamo toccato — logica, dati, matematica del combattimento — la differenza è quasi certamente
nulla. Ma 4.7 è uscito il **18 giugno 2026** e porta cambiamenti veri sui Control (le *Transform
Offset*, che agiscono sopra il layout normale), e la nostra UI è tutta Control.

**Non è un problema oggi, ma è una cosa che sai tu e non sapeva il documento.** Quando giri
`./prove/esegui.sh` sulla tua macchina con la 4.7 vera, quello è il verde che conta.

---

## Fonti

**Ufficiali e documentazione**
- [Best practices — Godot Engine docs](https://docs.godotengine.org/en/stable/tutorials/best_practices/index.html)
- [Scene organization](https://docs.godotengine.org/en/stable/tutorials/best_practices/scene_organization.html)
- [Autoloads versus internal nodes](https://github.com/godotengine/godot-docs/blob/master/tutorials/best_practices/autoloads_versus_internal_nodes.rst)
- [Overview of renderers](https://docs.godotengine.org/en/stable/tutorials/rendering/renderers.html)
- [Optimization using Servers](https://github.com/godotengine/godot-docs/blob/master/tutorials/performance/using_servers.rst)
- [Thread-safe APIs](https://docs.godotengine.org/en/stable/tutorials/performance/thread_safe_apis.html)
- [WorkerThreadPool](https://docs.godotengine.org/en/stable/classes/class_workerthreadpool.html)
- [Resources](https://docs.godotengine.org/en/stable/tutorials/scripting/resources.html)
- [Godot 4.7 release notes](https://godotengine.org/releases/4.7/)
- [Console Support](https://godotengine.org/consoles/) · [W4 Consoles](https://www.w4games.com/w4consoles)
- [Web Export in 4.3 — progress report](https://godotengine.org/article/progress-report-web-export-in-4-3/)

**Prestazioni e tipizzazione**
- [Yes, your Godot game runs faster with static types — beep.blog](https://www.beep.blog/2024-02-14-gdscript-typing/)
- [Static Typing in Godot: increase performance up to ~47%](https://www.bodenmchale.com/2025/02/24/improve-godot-performance-using-static-types/)
- [How to Profile GDScript Performance in Godot 4](https://dev.to/ziva/how-to-profile-gdscript-performance-in-godot-4-a-2026-guide-16jn)
- [Godot Performance Profiling Guide — Bugnet](https://bugnet.io/blog/godot-performance-profiling-guide-for-beginners)

**Architettura**
- [Node communication (the right way) — Godot 4 Recipes](https://kidscancode.org/godot_recipes/4.x/basics/node_communication/index.html)
- [Best practices with Godot signals — GDQuest](https://www.gdquest.com/tutorial/godot/best-practices/signals/)
- [Godot 4 Autoload Singletons: When To Use, When To Avoid](https://zivadotsh.hashnode.dev/godot-4-autoload-singletons-when-to-use-when-to-avoid)
- [Resource-based architecture for Godot 4](https://medium.com/@sfmayke/resource-based-architecture-for-godot-4-25bd4b2d9018)

**UI, salvataggi, memoria**
- [Responsive UI Design in Godot: Anchors, Size Flags — Wayline](https://www.wayline.io/blog/responsive-ui-design-godot-anchors-size-flags)
- [Saving and Loading Games in Godot 4 — GDQuest](https://www.gdquest.com/library/save_game_godot4/)
- [Implementing a Save/Load System: JSON, ConfigFile, Resources — UhiyamaLab](https://uhiyama-lab.com/en/notes/godot/save-load-system/)
- [godot-safe-resource-loader](https://github.com/derkork/godot-safe-resource-loader)
- [How to Find Memory Leaks in Godot Games — Bugnet](https://bugnet.io/blog/how-to-find-memory-leaks-in-godot-games)
- [ObjectDB instances leaked at exit — issue](https://github.com/godotengine/godot/issues/44226)

**Il mondo reale**
- [The Godot Rough Patch — Claire Blackshaw](https://claire-blackshaw.com/blog/2025/05/godot_rough_patch/)
- [Shipping Godot VR and Porting to PSVR2 — Claire Blackshaw](https://www.claire-blackshaw.com/blog/2026/07/shipping-godot-vr-and-porting-to-psvr2-a-partial-post-mortem/)
- [I Shipped a Godot Game to Steam — Full Postmortem](https://gamineai.com/blog/i-shipped-a-godot-game-to-steam-full-postmortem)
- [Slay the Spire 2 ditched Unity for Godot — PC Gamer](https://www.pcgamer.com/games/card-games/slay-the-spire-2-ditched-unity-for-open-source-engine-godot-after-2-years-of-development/)
- [Steam stats for Godot show exponential growth — GamesRadar](https://www.gamesradar.com/games/roguelike/steam-stats-for-slay-the-spire-2s-engine-godot-show-strong-signs-of-exponential-growth/)
- [Most Successful Games Made With Godot — revenue analysis](https://godotawesome.com/godot-games-table/)
- [Godot 4 Multiplayer: Best Practices & Benchmarks (2026)](https://ziva.sh/blogs/godot-multiplayer)
- [GDScript errors in another thread are silently ignored — issue](https://github.com/godotengine/godot/issues/76030)

**Test automatici**
- [GdUnit4](https://github.com/godot-gdunit-labs/gdUnit4) · [Run automated tests on CI — David Saltares](https://saltares.com/run-automated-tests-for-your-godot-game-on-ci/)

---

*Studio su Godot · raccolto l'11 settembre 2026 · ramo `claude/inizio-progetto-dya2lr`*
