#!/usr/bin/env bash
# Lancia le prove del progetto. Serve Godot 4 nel PATH (o in $GODOT).
#   ./prove/esegui.sh
set -euo pipefail
cd "$(dirname "$0")/.."
GODOT="${GODOT:-$(command -v godot || command -v godot4 || true)}"
if [ -z "$GODOT" ]; then
	echo "Godot non trovato. Installalo, oppure: GODOT=/percorso/godot ./prove/esegui.sh" >&2
	exit 127
fi

# UN ERRORE A RUNTIME DENTRO UNA PROVA NON LA FA FALLIRE.
#
# In GDScript un errore a runtime interrompe la funzione in cui succede e
# ridà il controllo a chi l'ha chiamata, che tira dritto. Una prova che esplode
# a metà quindi non conta le sue verifiche e non lascia nessun fallimento: il
# totale cala di qualche numero e in fondo compare lo stesso "PASSATE, nessun
# problema". È successo davvero, con una prova che leggeva un file di eventi
# nel modo sbagliato: due SCRIPT ERROR nell'output, e verde.
#
# Nessun contatore dentro Prove.gd può accorgersene, perché il codice che
# dovrebbe accorgersene è proprio quello che non viene eseguito. Se ne accorge
# chi guarda da fuori: questo script.
#
# E UN ERRORE DI PARSE NON FA NEMMENO QUELLO: APPENDE TUTTO.
#
# Se lo script della scena non compila, Godot non lo carica, _ready() non parte
# mai, e la scena resta lì aperta a non fare niente. Nessun errore in coda,
# nessun esito, nessun verde e nessun rosso: il comando semplicemente non
# torna più. È successo con una riga sola - una variabile dedotta da un
# Variant, che qui è un warning trattato come errore - e ha bloccato le prove
# per venti minuti prima che si capisse che non erano lente, erano ferme.
# Quindi ogni esecuzione ha un tempo massimo, e scadere è un fallimento.
LIMITE_SECONDI="${LIMITE_SECONDI:-600}"

esegui_pulito() {
	local titolo="$1"; shift
	local registro
	registro="$(mktemp)"
	set +e
	timeout --foreground "$LIMITE_SECONDI" "$@" 2>&1 | tee "$registro"
	local esito=${PIPESTATUS[0]}
	set -e
	if [ "$esito" -eq 124 ]; then
		echo ""
		echo "✗ $titolo: non è finito entro ${LIMITE_SECONDI}s." >&2
		echo "  Di solito vuol dire che uno script non compila: Godot non carica la" >&2
		echo "  scena, _ready() non parte e non arriva né un verde né un rosso." >&2
		rm -f "$registro"
		exit 1
	fi
	if [ -n "${CONTROLLA_PERDITE:-}" ] && grep -q "ObjectDB instances leaked at exit" "$registro"; then
		echo ""
		echo "✗ $titolo: il gioco ha lasciato indietro degli oggetti." >&2
		echo "  Rilancia con --verbose per vedere quali: di solito e' un nodo tolto" >&2
		echo "  dall'albero e mai liberato, oppure una coroutine ferma su un await" >&2
		echo "  dentro qualcosa che nel frattempo e' stato liberato." >&2
		rm -f "$registro"
		exit 1
	fi
	if grep -qE '^(USER )?(SCRIPT ERROR|ERROR):' "$registro"; then
		echo ""
		echo "✗ $titolo: Godot ha segnalato degli errori (sopra). Non è verde." >&2
		rm -f "$registro"
		exit 1
	fi
	rm -f "$registro"
	if [ "$esito" -ne 0 ]; then
		exit "$esito"
	fi
}

# LA VERSIONE GIUSTA, O IL VERDE NON VALE.
#
# Per settimane le prove sono girate su Godot 4.4.1 mentre il progetto dichiara
# 4.7, e 4.4.1 senza finestra MISURA I CARATTERI FINTI: una riga alta tre volte
# il corpo (a 16 punti, 48 pixel invece di 23). Ogni prova che guardava se un
# testo ci sta in altezza misurava un testo che non esiste. La 4.7 senza
# finestra misura giusto. Quindi: se il Godot qui e' piu' vecchio di quello
# del progetto, lo si dice prima di cominciare.
dichiarata="$(sed -nE 's/^config\/features=PackedStringArray\("([0-9]+\.[0-9]+)".*/\1/p' project.godot)"
usata="$("$GODOT" --version 2>/dev/null | grep -oE '^[0-9]+\.[0-9]+' | head -1)"
if [ -n "$dichiarata" ] && [ -n "$usata" ] \
		&& [ "$(printf '%s\n%s\n' "$usata" "$dichiarata" | sort -V | head -1)" != "$dichiarata" ]; then
	echo "⚠ Godot $usata, ma il progetto e' fatto per $dichiarata: il verde di qui non" >&2
	echo "  e' quello che conta. Sotto la 4.5 senza finestra le altezze del testo sono finte." >&2
fi

echo "→ importo le risorse"
"$GODOT" --headless --path . --import >/dev/null

# PRIMA DI TUTTO: L'ERRORE CHE APPENDE TUTTO.
#
# In questo progetto i warning sono errori, e "tipo dedotto da un Variant" è
# uno di quelli. Il guaio è come si manifesta: non fallisce, APPENDE. Godot non
# carica la scena, _ready() non parte, e si aspetta il tempo massimo per
# scoprire che c'era una riga sbagliata.
#
# Il modo di prenderlo in un secondo non è chiedere a Godot di compilare
# (--check-only non carica gli autoload, quindi non conosce GameState e si
# lamenta di tutt'altro): è cercare la riga. `var x := qualcosa.call(...)` dà
# sempre Variant, perché una Callable non dichiara cosa restituisce. È l'errore
# che è già costato due esecuzioni intere.
echo "→ niente tipi dedotti da un Variant"
# Due forme, e mi hanno fermato tre esecuzioni intere:
#   var x := qualcosa.call(...)     -> una Callable non dichiara cosa ritorna
#   var x := nodo.metodo(...)       -> su una variabile tipata Node il metodo
#                                      non è noto staticamente
# In entrambi i casi esce Variant, i warning qui sono errori, e la scena non si
# carica più: il gioco non fallisce, si pianta.
# Il controllo guarda solo la TESTA dell'espressione, subito dopo il ':='. Se
# guardasse tutta la riga prenderebbe anche `var x := int(nodo.campo.get(...))`,
# che ha un tipo dichiarato e va benissimo: un controllo che grida al lupo si
# impara a ignorarlo, e allora tanto vale non averlo.
if grep -rnE '^[[:space:]]*var [a-z_0-9]+ :=[[:space:]]*([a-z_0-9]+\.call\(|(schermata|scontro|mappa|negozio|pausa|istanza)\.[a-z_0-9.]+\()' scripts prove --include='*.gd' ; then
	echo "" >&2
	echo "✗ le righe qui sopra deducono il tipo da una Callable: in GDScript è" >&2
	echo "  Variant, i warning qui sono errori, e la scena non si carica più." >&2
	echo "  Scrivi il tipo a mano: var x: int = qualcosa.call(...)" >&2
	exit 1
fi
# IL GIOCO NON DEVE PERDERE NIENTE, LE PROVE POSSONO.
#
# "ObjectDB instances leaked at exit" ci stava in fondo a ogni esecuzione da
# settimane e lo guardavamo senza capirlo. Misurato: chi perde e' LA SUITE, non
# il gioco - e sono coroutine sospese (svuota_coda, attendi_lettura) dentro
# combattimenti che una prova libera a meta' volo. In Godot 4 una coroutine
# sospesa non si puo' annullare: l'unico modo di non lasciarla li' sarebbe far
# finire ogni scontro di prova per davvero, che vuol dire aspettarlo.
#
# Avviato da solo, il gioco non ne perde NEMMENO UNA. Quindi l'avviso smette di
# essere rumore e diventa una sentinella: qui dentro zero, e se un giorno il
# numero si muove vuol dire che a perdere ha cominciato il gioco.
# NIENTE AVVISI DI GDSCRIPT, come nell'editor. Senza --debug Godot non li
# stampa, e quindi nessuna prova li vedeva: li vedeva Bru, in giallo, aprendo il
# progetto. Qui si caricano tutti gli script con --debug e un solo avviso ferma
# tutto (vedi prove/Avvisi.gd)
echo "→ nessun avviso di GDScript"
registro_avvisi="$(mktemp)"
timeout --foreground "$LIMITE_SECONDI" "$GODOT" --headless --path . --debug prove/Avvisi.tscn > "$registro_avvisi" 2>&1 || true
grep -E '^Avvisi: ' "$registro_avvisi" || true
if ! grep -qE '^Avvisi: [0-9]+ script caricati' "$registro_avvisi" \
		|| grep -qE '^(WARNING|USER WARNING|SCRIPT ERROR|ERROR):' "$registro_avvisi"; then
	grep -A1 -E '^(WARNING|USER WARNING|SCRIPT ERROR|ERROR):' "$registro_avvisi" >&2 || true
	echo "" >&2
	echo "✗ GDScript ha degli avvisi (sopra): l'editor li mostra in giallo a chi apre" >&2
	echo "  il progetto. Si correggono, non si spengono." >&2
	rm -f "$registro_avvisi"
	exit 1
fi
rm -f "$registro_avvisi"

CONTROLLA_PERDITE=1
echo "→ il gioco si avvia"
esegui_pulito "l'avvio del gioco" "$GODOT" --headless --path . --quit-after 240
unset CONTROLLA_PERDITE
echo "→ prove"
esegui_pulito "le prove" "$GODOT" --headless --path . prove/Prove.tscn
