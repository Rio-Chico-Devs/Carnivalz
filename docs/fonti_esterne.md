# I problemi che non vengono dal codice — 12 ottobre 2026

Bru: *«vedi se trovi altri problemi dovuti più che altro a fonti esterne e non
al codice, informati online».*

Il cursore che spariva sul menu era di questo tipo: il codice del gioco era
giusto, ma Godot, l'editor e il sistema insieme lo spegnevano. Qui ho cercato
gli altri problemi dello stesso tipo, quelli che dipendono da:
- il computer di chi gioca: sistema, driver, schermo, tastiera, mouse;
- quello che gli gira intorno: antivirus, OneDrive, l'editor;
- la versione di Godot.

Per ognuno ho cercato online, poi ho controllato sul codice del gioco e sul
sorgente di Godot 4.7 se tocca davvero Carnivalz.

---

## In breve

### Corretti nel gioco (con prove; 15 sabotaggi, tutti presi)

| # | Da dove viene | Cosa succedeva | Cosa fa adesso |
|--:|---|---|---|
| 1 | **Backup, computer nuovo, OneDrive** | «Salvata il…» e CONTINUA usavano la data del *file*. Chi ricopia la cartella dei salvataggi aggiorna quella data: una partita vecchia ricopiata diventava «la più recente», e CONTINUA caricava quella | L'ora la scrive il gioco dentro il salvataggio. Per i salvataggi fatti prima resta la data del file |
| 2 | **Ora legale** | Il fuso era quello di *adesso*: una partita salvata d'estate e guardata d'inverno risultava salvata un'ora prima | Col salvataggio si salva anche il fuso di quel momento |
| 3 | **Tastiere francesi, tedesche…** | I comandi della mappa sono legati alla *posizione* dei tasti (giusto: WASD resta un quadrato ovunque). Ma la guida scriveva sempre «Q», «W», «Z e X», e su una tastiera francese quel tasto ha stampato «A» | La guida chiede al sistema cosa c'è stampato su quel tasto, anche nelle frasi |
| 4 | **Sospensione del portatile, sistema inchiodato** | Godot passa a ogni fotogramma tutto il tempo trascorso, senza tetto. Chiudi il coperchio durante una scelta a tempo: alla riapertura è già scaduta. Lo stesso per il colpo di grazia e la Mattanza | `Tempo.gd`: l'orologio, lo scontro e le sonde contano al massimo un decimo di secondo per fotogramma |
| 5 | **Alt-tab, notifiche, un clic sull'editor** | Il gioco continuava a correre senza nessuno davanti | Il gioco si ferma com'è, solo dove ESC aprirebbe la pausa, e il menu di pausa compare al ritorno: così lo Strumento di cattura fotografa il gioco e non la pausa (Bru, 12 e 21 ottobre). Si spegne in Opzioni › Grafica; c'è anche F12 |
| 6 | **Schermi piccoli (1366×768)** | 1280×720 più la barra del titolo non entra sopra la barra delle applicazioni. Godot la centra lo stesso e la barra del titolo finisce fuori dallo schermo, dove non si può afferrare | Se non entra, la finestra si rimpicciolisce (sempre 16:9) e si centra con la cornice dentro |
| 7 | **La vista «Game» dell'editor** | Lì Godot non fa lo schermo intero: scrive solo «Embedded window only supports Windowed mode.». L'interruttore sembrava rotto | Nell'editor l'interruttore è spento, e passandoci sopra dice perché |

### Da fare fuori dal codice

1. **Aggiorna Godot alla 4.7.2.** Ci sono già la 4.7.1 (14 luglio) e la 4.7.2
   (17 agosto). Ho lanciato tutta la suite sulla 4.7.2: 83.282 verifiche,
   nessun problema. Il progetto non cambia. Le correzioni che ci riguardano:
   - **un crash all'avvio** se Godot non riesce a scrivere il file di log, cioè
     se la cartella dei dati utente è bloccata (antivirus, cartella protetta,
     disco pieno) (GH-121926);
   - **mouse da gioco ad alta frequenza su Windows** (2 kHz e oltre; alcuni
     mouse partono già così di fabbrica). L'articolo ufficiale (che Bru mi ha
     mandato in PDF) dice tre cose che ci riguardano:
     - colpisce soprattutto i giochi col cursore visibile, cioè tutto
       Carnivalz;
     - su Windows 11, con la maggior parte dei processori, il problema comincia
       già fra 1 e 2 kHz, e i portatili soffrono di più;
     - nella misura ufficiale, col cursore visibile a 8 kHz i fotogrammi
       arrivavano a scatti oltre i 16 ms («giocabile ma non fluido»), e su
       processori più lenti si scende a pochi fotogrammi al secondo. Con la
       4.7.2 sparisce (GH-109639).

     Il consiglio che resta a noi, tenere leggero il codice che risponde al
     movimento del mouse, lo rispettiamo già: l'accumulo dei movimenti di Godot
     è acceso (un evento per fotogramma), e `Cursore.gd` lavora al più due
     volte al secondo;
   - **impaginazione dei contenitori** (`BoxContainer`, la dimensione massima),
     cioè quello su cui sono costruite le nostre schermate (GH-120351,
     GH-120500, GH-120984, GH-120002);
   - **un blocco dell'editor** avviando il progetto con l'editor degli script
     staccato in una finestra (GH-119614).
2. **Il progetto fuori da OneDrive.** Se la cartella sta in «Documenti» e
   Windows la sincronizza con OneDrive, Godot importa file che OneDrive sta
   scaricando o bloccando. Il risultato sono errori di salvataggio, editor
   bloccato all'avvio, file importati di continuo. La soluzione che riportano
   tutti è spostarla su una cartella locale.
3. **Escludi la cartella del progetto da Windows Defender.** Lo dice la guida
   ufficiale di Godot: al primo avvio dopo l'accensione la scansione rallenta
   molto il controllo dei file del progetto. Il percorso è Sicurezza di Windows
   → Protezione da virus e minacce → Esclusioni.
4. **Direct3D 12.** Dalla 4.6 su Windows Godot usa Direct3D 12 invece di
   Vulkan, e quindi anche tu. Online ci sono segnalazioni di scatti e blocchi
   di un paio di secondi, soprattutto su portatili con grafica Intel. Se li
   vedi, prova Vulkan: Impostazioni progetto → Rendering → Rendering Device →
   Driver (Windows). Il primo avvio dopo un aggiornamento dei driver può
   scattare un attimo mentre la scheda compila gli shader: è normale e succede
   una volta sola.
5. **Se il cursore sparisce ancora**, disattiva «Embed Game on Next Play» nella
   vista Game e prova col gioco in una finestra sua. Se lì non succede, la causa
   è l'incorporamento nell'editor.
6. **Quando esporterai per altri.** Le due pagine ufficiali che mi hai
   mandato («Exporting for Windows» ed «EditorExportPlatformWindows»), lette
   insieme al codice dell'esportatore:
   - **la firma.** Un `.exe` non firmato fa comparire l'avviso blu di Windows.
     Godot firma da solo all'export, ma servono due cose: lo strumento
     `SignTool.exe`, che viene col Windows SDK, e un certificato di firma, che
     si compra. Poi va impostato in due posti: Impostazioni dell'editor →
     Export → Windows → Sign Tool, e nel preset Windows la sezione Codesign
     (Enable, Identity col file del certificato, Password). La password si
     può anche passare con la variabile d'ambiente
     `GODOT_WINDOWS_CODESIGN_PASSWORD`, così non finisce nel repository;
   - **il `.pck` dentro l'eseguibile.** La documentazione ufficiale non parla
     di antivirus: la segnalazione resta solo degli sviluppatori su itch.io.
     Però nel codice di Godot `embed_pck` di serie è **spento**, e il nostro
     export l'ha acceso. Se un antivirus si lamenta, la prima cosa da provare
     è spegnerlo: il gioco diventa un `.exe` più un `.pck` accanto;
   - **gli shader pronti nell'eseguibile** (`shader_baker/enabled`, di serie
     spento). Compila gli shader durante l'export invece che sul computer di
     chi gioca, quindi niente scatto la prima volta che compare un effetto.
     Funziona col motore grafico Forward+ (il nostro) e va fatto dall'editor
     su Windows: da qui non posso provarlo, quindi non l'ho acceso;
   - **la descrizione del file** (`application/file_description`) la pagina
     la dà come obbligatoria, e mancava: senza, Gestione attività mostra solo
     il nome dell'eseguibile. L'ho aggiunta («Carnivalz»). La versione,
     senza `application/config/version`, Godot la scrive come 1.0.0.0.

   La firma, il `.pck` e gli shader pronti non li ho cambiati: sono scelte tue.

---

## Guardati e a posto

- **Le lettere nei nomi.** Tutti e cinque i caratteri del gioco hanno le
  lettere che servono:
  - tutte le accentate italiane;
  - quelle di francese, spagnolo e tedesco;
  - quelle dell'est Europa e del turco (ł, ő, ş, ž…);
  - € e i simboli comuni.

  E hanno acceso il ripiego sui caratteri del sistema. Un «Niccolò» o una
  «Zoë» si scrivono, niente quadratini.
- **Lo shader delle fratture** fra OpenGL e Direct3D/Vulkan. Le mie foto e i
  miei film sono fatti col ripiego OpenGL; tu giochi in Direct3D 12. Le cose
  che cambiano fra i due sono la copia dello schermo e l'asse Y delle
  coordinate. Lo shader delle lenti misura le posizioni in coordinate sue, non
  dello schermo, quindi le fratture stanno al posto giusto su tutti e due.
  Limite: qui non ho potuto *disegnare* in Vulkan (gli archivi dei driver non
  sono raggiungibili), solo leggere.
- **L'ora legale su Windows.** Godot la legge bene (`os_windows.cpp`); lo
  sbaglio era nostro, che usavamo il fuso di adesso per un salvataggio vecchio
  (voce 2).
- **Un salvataggio che non si scrive** (disco pieno, cartella bloccata): la
  Sede lo dice al giocatore.
- **Il ripiego quando la scheda non regge Direct3D 12 né Vulkan**: Godot
  passa da solo a OpenGL, ed è proprio la strada che il gioco fa nelle mie
  prove (`xvfb`). Funziona.

## Guardati, non corretti, e perché

- **Fotogrammi senza tetto con la sincronia verticale spenta dal driver**
  (pannello NVIDIA, «Vertical sync: Off»). Il menu può girare a migliaia di
  fotogrammi al secondo: ventole al massimo, a volte un fischio della scheda.
  Si risolve con `Engine.max_fps`. Non l'ho messo: potrebbe rallentare
  l'automa, e la sincronia spenta forzata è una scelta del giocatore. Se lo
  vuoi è una riga.
- **Cambio di cuffie o casse a gioco aperto** (Bluetooth): non ho trovato
  segnalazioni confermate per Godot 4 su Windows. Non provato.
- **Monitor con scale diverse** (uno al 100%, uno al 150%): le segnalazioni
  riguardano l'editor, che si vede sfocato, non il gioco.

## Fonti

Ufficiali (gli ultimi tre mandati da Bru in PDF, 12 ottobre):
- [Godot — Fixing high polling rate mice on Windows](https://godotengine.org/article/fixing-high-polling-rate-mice-on-windows/) (Hugo Locurcio, 24 agosto 2026)
- [Godot docs 4.7 — Exporting for Windows](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_windows.html)
- [Godot docs 4.7 — EditorExportPlatformWindows](https://docs.godotengine.org/en/stable/classes/class_editorexportplatformwindows.html)
- codice dell'esportatore di Godot 4.7: `editor/export/editor_export_platform_pc.cpp` (i valori di serie di `embed_pck` e `shader_baker/enabled`), `platform/windows/export/template_modifier.cpp` (la descrizione e la versione del file)
- [Godot — Maintenance release 4.7.1](https://godotengine.org/article/maintenance-release-godot-4-7-1/); changelog 4.7.1 e 4.7.2 letto dal repository di Godot (`CHANGELOG.md` ai tag `4.7.1-stable` e `4.7.2-stable`)
- [Godot docs 4.7 — Troubleshooting (Windows Defender)](https://docs.godotengine.org/en/4.7/tutorials/troubleshooting.html)
- [Godot docs 4.7 — Reducing stutter from shader compilations](https://docs.godotengine.org/en/4.7/tutorials/performance/pipeline_compilations.html)
- [Godot docs — Renderers (il ripiego su OpenGL)](https://docs.godotengine.org/zh-cn/4.5/tutorials/rendering/renderers.html)
- [Godot docs — InputEventKey (tasti fisici ed etichette)](https://docs.godotengine.org/en/4.2/classes/class_inputeventkey.html)
- [Godot 4.6: Direct3D 12 predefinito su Windows](https://digitalproduction.com/2025/12/04/godot-4-6-dev5-lands-d3d12-default-delta-patching-android-gradle-2d-boosts)

Forum e segnalazioni:
- [D3D12 contro Vulkan in 4.6 (forum)](https://forum.godotengine.org/t/godot-4-6-3-pure-2d-windows-d3d12-vs-vulkan-stability-hardware-compatibility/140257) · [blocchi di 1–2 secondi in 4.6](https://forum.godotengine.org/t/godot-4-6-randomly-freezes-for-1-or-2-seconds-then-continues-like-nothing-happend/137663)
- [OneDrive e Godot: errori di salvataggio](https://forum.godotengine.org/t/errors-saving-various-godot-files/36270) · [editor bloccato da OneDrive](https://ask.godotengine.org/100623/godot-keeps-not-responding-and-downloading-from-onedrive)
- [Antivirus e `.pck` incorporato (itch.io)](https://itch.io/post/12331284)
- [Pausa quando la finestra perde il fuoco (forum)](https://forum.godotengine.org/t/pausing-the-rendering-engine-when-application-loses-focus/98821)
- [Scatti dopo il risveglio dalla sospensione (forum)](https://godotforums.org/d/42481-unable-to-figure-out-the-source-of-lag-spikes)
- [Fotogrammi senza tetto con la sincronia spenta](https://community.gamedev.tv/t/max-fps-may-not-be-set-by-default/235625)
- [Editor sfocato con monitor a scale diverse](https://forum.godotengine.org/t/godot-4-6-editor-blurry-on-mixed-dpi-dual-monitor-setup-windows-11/132508)
