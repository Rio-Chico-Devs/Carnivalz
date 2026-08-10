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

echo "→ importo le risorse"
"$GODOT" --headless --path . --import >/dev/null
echo "→ il gioco si avvia"
esegui_pulito "l'avvio del gioco" "$GODOT" --headless --path . --quit-after 240
echo "→ prove"
esegui_pulito "le prove" "$GODOT" --headless --path . prove/Prove.tscn
