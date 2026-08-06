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
esegui_pulito() {
	local titolo="$1"; shift
	local registro
	registro="$(mktemp)"
	set +e
	"$@" 2>&1 | tee "$registro"
	local esito=${PIPESTATUS[0]}
	set -e
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
