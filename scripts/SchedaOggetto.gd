class_name SchedaOggetto
extends RefCounted

# IL NOME DI CHI PORTA UN OGGETTO, detto come lo dice la storia: il nome
# della classe se e' un compagno, del personaggio se no. Serve alle carte della
# squadra, alla figura intera e al negozio («addosso a Veronica»).
#
# Qui c'era anche la riga dello zaino (nome, quanti, in uso, cosa fa): adesso
# lo zaino e' una schermata sua (Zaino.gd, RigaZaino.gd), e le parole di cosa
# fa un oggetto restano quelle di Merce.riassunto_effetto, dappertutto.

static func nome_di_classe(id_classe: String) -> String:
	var definizione: Dictionary = GameState.classi.get(id_classe, {})
	if not definizione.is_empty():
		return String(definizione.get("nome", id_classe))
	return String(GameState.personaggi.get(id_classe, {}).get("nome", id_classe))
