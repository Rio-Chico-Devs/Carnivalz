extends Control

# LA BASE DELLA CRESCITA: quello che la schermata sa e i conti che le servono.
# Sopra di lei, un livello per cosa: RuotaCrescita disegna la ruota e la
# lastra, MotoCrescita i pezzi che si muovono, MomentiCrescita il bivio, il
# salto e la carta; SchedaCrescita in cima tiene il filo (i momenti, i tasti).
# Le regole della ruota stanno in Crescita, i numeri in data/ruote.json.

const P := preload("res://scripts/crescita/PezziCrescita.gd")
const S := preload("res://scripts/crescita/SimboliCrescita.gd")
const IS := preload("res://scripts/crescita/IconeStatistiche.gd")

const CENTRO := Vector2(938, 392)
const R_MOZZO := 170.0
const R_DENTRO := 180.0
const R_FUORI := 276.0
const R_CELLE := 282.0      # l'anello dei numeri
const R_ORLO := 336.0
const LASTRA := [Vector2(-20, -20), Vector2(606, -20), Vector2(440, 740), Vector2(-20, 740)]
const ROMANI := ["I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X"]
const TENDINA := 0.5        # la lastra fra due momenti: copre a meta'
const CADE := 0.3           # il timbro, dall'alto alla tasca
const VOLA := 0.5           # il punto, dal contatore alla tasca
const TAGLIO := Vector2(0.158, -0.987)   # il taglio storto del bivio, verso l'alto
const GETTONI := Vector2(46, 104)        # il primo gettone del contatore
const PASSO_GETTONE := 39.0
const PRENDI_A := Vector2(30, 624)       # l'etichetta PRENDI sulla lastra
const FINE_SALTO := 3.8                  # quando il salto ha finito di entrare
const FINE_CARTA := 1.4
const PAROLE := {"hp": "VITA", "attacco": "ATTACCO", "difesa": "DIFESA", "velocita": "VELOCITÀ",
		"intelligenza": "INTELLIGENZA", "fattore": "FATTORE", "forza_mentale": "FORZA MENTALE",
		"maestria_dominio": "MAESTRIA"}
# cosa vuol dire una statistica, in una riga, se crescita.json non lo dice
const DETTO := {"hp": "Reggi più colpi prima di cadere.", "attacco": "Ogni tuo colpo pesa di più.",
		"difesa": "Ogni colpo che incassi ti scalfisce meno.", "velocita": "Nel giro agisci prima.",
		"intelligenza": "Scappi più facilmente.", "forza_mentale": "Lo stress ti morde meno.",
		"fattore": "Più colpi nel punto giusto."}


class Strato extends Control:
	# un foglio da disegno, grande come la tavola: disegna chi glielo dice
	var come: Callable

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		size = Vector2(Tavola.LARGO, Tavola.ALTO)

	func _draw() -> void:
		come.call(self)


var su_indietro := Callable()
var si_sale := true          # in combattimento la ruota si guarda e basta
var tavola: Tavola
var sotto: Strato
var spacco: Strato
var sopra: Strato
var tasti_qui: Control
var vecchia: SubViewport     # la ruota del giro chiuso, per spaccarla
var vecchia_tela: Strato
var tempo := 0.0

# chi, e dove sta la sua ruota
var squadra: Array[String] = []
var chi := ""
var adesso := 1              # il livello che il mozzo mostra (cambia quando il timbro batte)
var guardato := 2            # la tasca sotto la lancetta
var vista := 2.0             # dove sta davvero la ruota: ci arriva con una molla
var spinta_vista := 0.0
var linguette: Array[Rect2] = []
var indietro_qui := Rect2()

# il momento, e la lastra che porta al prossimo
var momento := "ruota"
var momento_a := 0.0
var prossimo := ""
var tendina_a := -10.0
var in_coda: Array = []      # [quando, cosa]: quello che succede da solo

# la salita in corso
var livello_nuovo := 0
var a_destra := true
var peso := 1.0
var spinta_peso := 0.0
var preso_a := -1.0
var salita := {}             # il racconto: stat (prima, dopo), motivi, strada
var valori_bivio := {}       # quanto valevano le due statistiche entrando nel bivio
var carte: Array = []        # [[tipo, id], ...] quello che arriva, da mostrare
var carta := 0
var punti_prima := 0
var prendi_a := -10.0
var timbro_a := -10.0
var livello_timbrato := 0
var timbrato := false
var rullo_a := -10.0
var rullo_da := 0
var accendi_a := -10.0
var vittoria_a := -10.0
var crepa_a := -10.0
var spacca_a := -10.0


# --- la ruota di chi ---------------------------------------------------------------------------

func tetto() -> int:
	return Crescita.tetto()


func beta() -> bool:
	# la ruota si ferma prima della fine del gioco
	return tetto() < int(GameState.regole.get("livello_massimo", 130))


func giri() -> int:
	return ceili(float(GameState.regole.get("livello_massimo", 130)) / 20.0)


func giro_di(livello: int) -> int:
	return clampi(floori((livello - 1) / 20.0), 0, giri() - 1)


static func primo_del_giro(g: int) -> int:
	return 20 * g + 1


func spicchi_del_giro(g: int) -> int:
	return mini(20, int(GameState.regole.get("livello_massimo", 130)) - 20 * g)


func ultimo_del_giro(g: int) -> int:
	return primo_del_giro(g) + spicchi_del_giro(g) - 1


func chiuso() -> bool:
	# il giro di adesso e' finito: tutte le sue tasche sono prese
	return guardato == adesso and (adesso == ultimo_del_giro(giro_di(adesso)) or adesso >= tetto())


func chiuso_e_si_va_oltre() -> bool:
	return chiuso() and adesso < tetto() and vittoria_a < 0.0


func coppia(livello: int) -> Array[String]:
	return Crescita.coppia(chi, livello)


func scelta_di(livello: int) -> String:
	# la strada presa a quel livello. I primi livelli possono essere venuti
	# d'altra parte (porta_al_livello, i nodi): li' una strada non c'e'
	var prese := Crescita.tasche_di(chi)
	var indice := livello - (GameState.livello_di(chi) - prese.size()) - 1
	return String(prese[indice]) if indice >= 0 and indice < prese.size() else ""


func arrivi_di(livello: int) -> Array:
	return Crescita.arriva(chi, livello)


func valore(stat: String) -> int:
	return Corredo.statistica_base(chi, stat)


func nome_di(id_classe: String) -> String:
	if id_classe == GameState.id_protagonista and GameState.nome_protagonista != "":
		return GameState.nome_protagonista
	return Corredo.nome_di(id_classe)


func stato_della_tasca(livello: int) -> String:
	# quello che e' la tasca sotto la lancetta, per la lastra
	if chiuso():
		return "chiuso"
	if livello == adesso + 1:
		return "prossimo"
	return "preso" if livello <= adesso else "dopo"


func testo_prendi() -> String:
	if chiuso():
		return "AL %s" % tema(giro_di(adesso) + 1)["nome"] if adesso < tetto() else "GIRO COMPLETO"
	if guardato != adesso + 1:
		return "IN FILA: PRIMA IL LIVELLO %d" % (adesso + 1)
	if not si_sale:
		return "DOPO LO SCONTRO"
	if GameState.punti_abilita_liberi() < 1 and not (prendi_a >= 0.0 and livello_nuovo == 0):
		return "MANCANO %s HYPE" % migliaia(per_punto() - GameState.hype_disponibile % per_punto())
	return "PRENDI · 1 PUNTO"


func vista_della_vecchia() -> float:
	# nel giro di vittoria la ruota fa un giro intero, e si ferma dov'era
	if vittoria_a < 0.0:
		return vista
	var g := giro_di(adesso)
	var n := float(spicchi_del_giro(g))
	var k := clampf((tempo - vittoria_a) / 1.0, 0.0, 1.0)
	var v := float(adesso) + n * k * k * (3.0 - 2.0 * k)
	return fposmod(v - primo_del_giro(g), n) + primo_del_giro(g)


func taglio_del_bivio() -> float:
	return lerpf(760.0, 640.0, peso)


func righe_della_salita() -> Array[Dictionary]:
	# ogni statistica cresciuta: quanto aveva, quanto ha dato la strada, quanto
	# le azioni, e il perche' delle azioni (come lo dice il resoconto)
	var righe: Array[Dictionary] = []
	var strada_presa: Dictionary = salita.get("strada", {})
	for voce: Dictionary in salita.get("stat", []):
		var chiave := String(voce.get("stat", ""))
		var scelta := int(strada_presa.get("quanto", 0)) if String(strada_presa.get("stat", "")) == chiave else 0
		var riga := {"stat": chiave, "prima": int(voce.get("prima", 0)), "scelta": scelta,
				"fatte": maxi(int(voce.get("dopo", 0)) - int(voce.get("prima", 0)) - scelta, 0),
				"perche": Resoconto.perche_di(chiave, salita.get("motivi", []))}
		# la strada presa per prima: e' la scelta appena fatta
		if scelta > 0:
			righe.push_front(riga)
		else:
			righe.append(riga)
	while righe.size() > 5:
		righe.pop_back()
	return righe


# --- i dati e i tempi ----------------------------------------------------------------------------

static func nome_stat(chiave: String) -> String:
	return String(GameState.crescita.get("stat", {}).get(chiave, {}).get("nome", chiave))


static func detto(chiave: String) -> String:
	var scritto := String(GameState.crescita.get("stat", {}).get(chiave, {}).get("descrizione", ""))
	return scritto.get_slice(".", 0) + "." if scritto != "" else String(DETTO.get(chiave, ""))


static func dati_di(tipo: String, id: String) -> Dictionary:
	if tipo == "passiva":
		for voce: Dictionary in GameState.crescita.get("passive_livello", []):
			if String(voce.get("id", "")) == id:
				return voce
		return {}
	return GameState.abilita_combattimento(id)


static func simbolo_di(tipo: String, id: String) -> String:
	# il simbolo di una passiva e' il suo id; di un'abilita', la sua linea
	if tipo == "passiva":
		return id
	var linea := String(GameState.abilita_combattimento(id).get("linea", ""))
	return linea if linea != "" else id


static func per_punto() -> int:
	return maxi(int(GameState.regole.get("hype_per_punto", 1000)), 1)


static func migliaia(n: int) -> String:
	var s := str(n)
	var fuori := ""
	while s.length() > 3:
		fuori = "." + s.substr(s.length() - 3) + fuori
		s = s.substr(0, s.length() - 3)
	return s + fuori


static func molla(dove: float, spinta: float, verso: float, delta: float) -> Vector2:
	# ci arriva e rimbalza appena, come la ruota che si ferma sulla tasca
	var nuova := spinta + (170.0 * (verso - dove) - 17.0 * spinta) * delta
	return Vector2(dove + nuova * delta, nuova)


func entrata(da: float, durata: float) -> float:
	return clampf((tempo - momento_a - da) / durata, 0.0, 1.0)


func dopo(quando: float, da: float, durata: float) -> float:
	return clampf((tempo - quando - da) / durata, 0.0, 1.0) if quando >= 0.0 else 0.0


static func rimbalza(x: float) -> float:
	var c1 := 1.70158
	return 1.0 + (c1 + 1.0) * pow(x - 1.0, 3.0) + c1 * pow(x - 1.0, 2.0)


static func frena(x: float) -> float:
	return 1.0 - pow(1.0 - x, 3.0)


static func velo(tinta: Color, quanto: float) -> Color:
	return Color(tinta, tinta.a * quanto)


static func tema(g: int) -> Dictionary:
	# per ogni giro: il campo, l'anello, le tasche prese e da prendere, quella
	# che esce, il mozzo. Tre colori e due loro toni, ogni volta in un ordine diverso
	var tm: Dictionary
	match g:
		0:
			tm = {"campo": "arancio", "anello": P.NERO, "numero": P.CREMA, "numero_preso": P.ARANCIO,
					"speciale": P.CREMA, "speciale_segno": P.NERO,
					"presa": P.NERO, "presa_segno": P.CREMA, "presa_ombra": P.ARANCIO,
					"futura": P.CREMA, "futura_segno": P.NERO, "futura_ombra": P.ARANCIO,
					"esce": P.CREMA, "esce_segno": P.NERO, "esce_ombra": P.ARANCIO,
					"mozzo": P.NERO, "mozzo_numero": P.CREMA, "mozzo_ombra": P.ARANCIO, "retino": Color(P.ARANCIO, 0.55),
					"accento": P.ARANCIO}
		1:
			tm = {"campo": "carta", "anello": P.NERO, "numero": P.CREMA, "numero_preso": P.ARANCIO,
					"speciale": P.ARANCIO, "speciale_segno": P.NERO,
					"presa": P.ARANCIO, "presa_segno": P.NERO, "presa_ombra": P.CREMA,
					"futura": P.CARTA, "futura_segno": P.NERO, "futura_ombra": P.ARANCIO,
					"esce": P.NERO, "esce_segno": P.ARANCIO, "esce_ombra": P.CREMA,
					"mozzo": P.NERO, "mozzo_numero": P.ARANCIO, "mozzo_ombra": P.CREMA, "retino": Color(P.CREMA, 0.3),
					"accento": P.ARANCIO}
		2:
			tm = {"campo": "nero", "anello": P.ARANCIO, "numero": P.NERO, "numero_preso": Color(P.NERO, 0.45),
					"speciale": P.CREMA, "speciale_segno": P.NERO,
					"presa": P.CREMA, "presa_segno": P.NERO, "presa_ombra": P.ARANCIO,
					"futura": P.BRUNO, "futura_segno": P.CREMA, "futura_ombra": P.NERO,
					"esce": P.ARANCIO, "esce_segno": P.NERO, "esce_ombra": P.CREMA,
					"mozzo": P.ARANCIO, "mozzo_numero": P.NERO, "mozzo_ombra": P.CREMA, "retino": Color(P.NERO, 0.3),
					"accento": P.NERO}
		3:
			tm = {"campo": "arancio", "anello": P.CREMA, "numero": P.NERO, "numero_preso": P.ARANCIO_SCURO,
					"speciale": P.NERO, "speciale_segno": P.CREMA,
					"presa": P.NERO, "presa_segno": P.CREMA, "presa_ombra": P.ARANCIO,
					"futura": P.ARANCIO_SCURO, "futura_segno": P.NERO, "futura_ombra": P.CREMA,
					"esce": P.CREMA, "esce_segno": P.NERO, "esce_ombra": P.ARANCIO,
					"mozzo": P.CREMA, "mozzo_numero": P.NERO, "mozzo_ombra": P.ARANCIO, "retino": Color(P.ARANCIO, 0.5),
					"accento": P.ARANCIO_SCURO}
		4:
			tm = {"campo": "nero", "anello": P.CREMA, "numero": P.NERO, "numero_preso": P.TRATTO,
					"speciale": P.ARANCIO, "speciale_segno": P.NERO,
					"presa": P.ARANCIO, "presa_segno": P.NERO, "presa_ombra": P.CREMA,
					"futura": P.BRUNO, "futura_segno": P.CREMA, "futura_ombra": P.NERO,
					"esce": P.CREMA, "esce_segno": P.NERO, "esce_ombra": P.ARANCIO,
					"mozzo": P.NERO, "mozzo_numero": P.CREMA, "mozzo_ombra": P.ARANCIO, "retino": Color(P.ARANCIO, 0.4),
					"accento": P.ARANCIO}
		5:
			tm = {"campo": "carta", "anello": P.ARANCIO, "numero": P.NERO, "numero_preso": Color(P.NERO, 0.45),
					"speciale": P.NERO, "speciale_segno": P.CREMA,
					"presa": P.NERO, "presa_segno": P.ARANCIO, "presa_ombra": P.CREMA,
					"futura": P.CARTA, "futura_segno": P.NERO, "futura_ombra": P.ARANCIO,
					"esce": P.ARANCIO, "esce_segno": P.NERO, "esce_ombra": P.CREMA,
					"mozzo": P.ARANCIO, "mozzo_numero": P.NERO, "mozzo_ombra": P.CREMA, "retino": Color(P.NERO, 0.25),
					"accento": P.NERO}
		_:
			tm = {"campo": "nero", "anello": P.ARANCIO, "numero": P.NERO, "numero_preso": Color(P.NERO, 0.45),
					"speciale": P.CREMA, "speciale_segno": P.NERO,
					"presa": P.ARANCIO, "presa_segno": P.NERO, "presa_ombra": P.CREMA,
					"futura": P.BRUNO, "futura_segno": P.ARANCIO, "futura_ombra": P.NERO,
					"esce": P.CREMA, "esce_segno": P.NERO, "esce_ombra": P.ARANCIO,
					"mozzo": P.NERO, "mozzo_numero": P.ARANCIO, "mozzo_ombra": P.CREMA, "retino": Color(P.ARANCIO, 0.45),
					"accento": P.ARANCIO}
	tm["nome"] = ["PRIMO", "SECONDO", "TERZO", "QUARTO", "QUINTO", "SESTO", "ULTIMO"][mini(g, 6)] + " GIRO"
	return tm
