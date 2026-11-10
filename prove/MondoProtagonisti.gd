extends RefCounted
# I DUE PROTAGONISTI sul pianeta (prove/MondoProva.gd), lui e lei, dai disegni
# di Bru: il foglio in pixel art, le due tavole di spalle e i due ritratti.
# Provvisori come la prova, ma fatti per restare: escono come PNG in
# art/pianeti/protagonista/ (lui.png, lei.png), e un PNG ridisegnato li' vince
# su questi.
#
# 24x32 a fotogramma, la testa piu' grande che nei disegni (a questa misura un
# viso realistico e' quattro pixel). Quello che deve restare riconoscibile:
#   lui - i capelli lavanda a punte, la pelle scura, la sciarpa bianca a frecce
#         nere, la giacca nera aperta, i pantaloni a righe, gli stivali, e lo
#         spadone sulla schiena col manico rosso;
#   lei - la coda alta, la fascia rossa con le stelle e l'anello d'oro, le
#         trecce, il top lavanda, i guanti lunghi neri, gli stivali alti.
# I colori sono presi dal foglio di Bru (raggruppati), una lettera ciascuno.
#
# Il foglio: righe giu', su, destra (la sinistra e' la destra allo specchio);
# colonne fermo, passo, altro passo. Di fronte e di spalle il passo e' un piede
# che si alza; di lato le gambe cambiano (PASSO_A, PASSO_B).

const LARGO := 24
const ALTO := 32

const TAVOLOZZA_LUI := {
	"o": "#0a0a0e",
	"n": "#1c1d21",
	"j": "#2c2d31",
	"J": "#45464f",
	"g": "#4d4e57",
	"P": "#5e5d62",
	"p": "#98979e",
	"q": "#c2c1c9",
	"s": "#b38f78",
	"S": "#6f5040",
	"l": "#cdab92",
	"H": "#e2e4fd",
	"h": "#c4c7f1",
	"v": "#9396d8",
	"V": "#5c5d96",
	"w": "#efece8",
	"W": "#b8b3ae",
	"e": "#253456",
	"r": "#8e2a2a",
	"R": "#5a1a1a",
	"y": "#f4f2ee",
	"Y": "#86868a",
	"i": "#86b4ee",
}

const TAVOLOZZA_LEI := {
	"o": "#04040c",
	"n": "#0b1422",
	"j": "#16233a",
	"J": "#2c3a52",
	"s": "#b4937c",
	"S": "#7d5858",
	"l": "#cbae98",
	"H": "#e2dafc",
	"h": "#c4baea",
	"v": "#9287b4",
	"V": "#544681",
	"t": "#d4caf6",
	"T": "#ada2d0",
	"X": "#73669f",
	"a": "#a8284a",
	"A": "#5e1a2c",
	"u": "#e0a838",
	"U": "#8a6020",
	"w": "#ece6f6",
	"W": "#a89cc8",
	"e": "#3a2450",
	"c": "#8b8a96",
	"k": "#3b3346",
	"K": "#514354",
	"i": "#c78cf0",
	"q": "#d8d6e4",
	"g": "#5a6078",
}

const LUI_GIU := [
	"...........o............",
	"......o...oHo..o........",
	".....oHo.oHHo.oho.......",
	".....ohHohHhhohHho..o...",
	"....ohHHHHhhhhhhhoohvo..",
	"...ohHHhHhhhhhhhhhhhvo..",
	"..ohhHhhhhhhhhhhhhhvvo..",
	".ovhhhhhhhhhhhhhhhvhvVo.",
	"..ovhhhhvhhhhvhhhvvvVo..",
	"..oVvhvhsvhhvsvhvsvVVo..",
	".o.oVvsslsssssslsssVo...",
	"oqooVsoossssssooSsSVo...",
	".oroVsiessssssseiSSVo...",
	"..oRoSssssssSsssSSo.....",
	"...oroSSssssssSSSo......",
	"....oYowwwwwwwwwWo......",
	"....oowwWwwwwwwWWWoo....",
	"...ojjowWoWoWWWWojjjo...",
	"..ojJjowwWslsslsoWjjjo..",
	"..oJjjoWwolslsSoojjjjo..",
	"..oJjoojjoslsslsojojjo..",
	"..ojjoojjosSsSsSojojjo..",
	"..osSo.onnnnqqnnno.oSo..",
	"..oggo.oPPpPPPPpPPo.ogo.",
	"..ogGo.oppppPpppppo.ogo.",
	"...oo..oPPPPoPPPPPo..o..",
	".......oggqgoggqggo.....",
	".......onnnnonnnnno.....",
	".......onqnnonnnqno.....",
	".......onnnnonnnnno.....",
	"......onnqqooonqqnno....",
	"........................",
]

const LUI_SU := [
	"...........o............",
	"......o...oHo..o........",
	".....oHo.oHHo.oho.......",
	".....ohHohHhhohHho..o...",
	"....ohHHHHhhhhhhhoohvo..",
	"...ohHHhHhhhhhhhhhhhvo..",
	"..ohhHhhhhhhhhhhhhhvvo..",
	".ovhhhhhhhhhhhhhhhvhvVo.",
	"..ovhhhhhhhhhhhhhvvvVo..",
	"..oVvhhhvhhhhvhhvvvVVoo.",
	"...oVvhvhhvhhvhvvvVVooqo",
	"...oVvvhvvhvvvhvvVVVoro.",
	"....oVvvVvvVvvVvVVVoRo..",
	".....oVVoVVoVVoVVVoro...",
	"......oSSssssssSoYYo....",
	"......owowwowwooqyYo....",
	"....oowwowwowwoqyYoo....",
	"...ojjjjjjjjjoqyYojjo...",
	"..ojJjjjjjjjoqyYojjjjo..",
	"..oJjjjjjjjoqyYojjjjjo..",
	"..oJjjnnnnoqyYonnnjnjo..",
	"..ojjoslsoqyYosSSojjjo..",
	"..osSo.ooqyYonnnno.oSo..",
	"..oggo.oqyYoPPPpPPo.ogo.",
	"..ogGooqyYopPpppppo.ogo.",
	"...oooqyYoPPoPPPPPo..o..",
	"......oYppppopppppo.....",
	".......onnnnonnnnno.....",
	".......onJnnonnJnno.....",
	".......onnnnonnnnno.....",
	"......onnnnoooonnnno....",
	"........................",
]

const LUI_DESTRA := [
	"..........o.............",
	"......o..oHo..o.........",
	".....oHooHHhooHo........",
	"....ohHHhHhhhhhHo.......",
	"...ohHHhhhhhhhhhho......",
	"..ohhhhhhhhhhhhhhvo.....",
	".ohhhhhhhhhhhhhhhvvo....",
	"..ovhhhhhhhhhhvhvvo.....",
	"..oovhhhhhhhvhsvhso.....",
	".oqoVvhhhhhvsssssso.....",
	"..ooVvvhhhvsslsssso.....",
	"...ooVvvhvssssoosso.....",
	"....oVVvvSsssssiesso....",
	".....oVVSsssssssSso.....",
	"......oSSssssSSSo.......",
	"......owwwwwwwwwo.......",
	"....owwWwwwwwwWWo.......",
	".oowwwWoojjjjsWo........",
	"owwoWwoojjJjjjslo.......",
	".owo.oo.ojJjjjsso.......",
	"..o....ojjJjjjsSo.......",
	".......ojjjJjjjno.......",
	".......onnqgGjnno.......",
	".......oPPpgGPPPo.......",
	".......oppppppppo.......",
	"........oPPPPPPo........",
	"........ogqggPPo........",
	"........onnnnnno........",
	"........onnnqnno........",
	"........onnnnnnno.......",
	"........onnnqqqqo.......",
	"........................",
]

const LUI_PASSO_A := {
	23: ".......oPPpgGPPPo.......",
	24: ".......opppppppppo......",
	25: "......oPPPoooPPPPo......",
	26: "......opPPo..ogqgPo.....",
	27: ".....onnnno...onnnno....",
	28: ".....onnno....onnqno....",
	29: "....onnno......onnnno...",
	30: "....onno.......onqqqqo..",
}

const LUI_PASSO_B := {
	23: ".......oPPpgGPPPo.......",
	24: ".......oppppppppo.......",
	25: ".......oPPPoPPPPo.......",
	26: ".......opgqoqgPPo.......",
	27: "......onnno.onnno.......",
	28: "......onnno.onqno.......",
	29: ".....onnno...onnno......",
	30: ".....onno....onqqqo.....",
}

const LEI_GIU := [
	"..........oo.o..........",
	".........ohHoho.........",
	"........ohHHhhvo........",
	"........ohHhhvvo........",
	"......oooooooooooo......",
	".....oauaawaawaawao.....",
	".....ouUuaaaaaaaaAo.....",
	"....ohhHuhhhhhhhhvvo....",
	"....ohHhvhhhvhhhvvvo....",
	"....oVhvsvhhsvhhsvVo....",
	"...ohVsslssssssssSVho...",
	"...ohVsooossssooosVho...",
	"...ohVsoiessssieosVho...",
	"...oHvsssssssssssSvHo...",
	"...ohoSssssSSssSSSohvo..",
	"...oHo..oSssssSo..oHo...",
	"..oshoo.osssssso.oohso..",
	".osslsottTtttttTTtosSso.",
	".osso.otttTttwtTTTo.oso.",
	".oqqo.ottTttwtTTXXo.oqo.",
	".ojJo.osslsssssSSSo.ojo.",
	".ojJo..osssssssSSo..ojo.",
	".onJo..owwwwWnnnnno.ojo.",
	".onjo..onnnnwwWnnno.ojo.",
	"..oo...onnnnoonnnno..o..",
	".......ossSo.osssSo.....",
	".......onJjo.onJjo......",
	".......onJjo.onJjo......",
	".......onJjo.onjjo......",
	".......onjno.onjno......",
	".......onno...onno......",
	"........................",
]

const LEI_SU := [
	"..........oo.o..........",
	".........ohHoho.........",
	"........ohHHhhvo........",
	"........oAaaaaAo........",
	"......oooaaaaaaooo......",
	".....oaaawaawaawaao.....",
	".....oAaaaaaaaaaaAo.....",
	"....ohhHhhhhhhhhhvvo....",
	"....ohHhhhhhhhhhvvvo....",
	"....oVhvhhhvhhhvvvVo....",
	"...ohVvhhvhhvhhvvvVho...",
	"...ohVvvhvvhvvvvvVVho...",
	"...ohVVvvVvvVvvVVVVho...",
	"...oHoVVoVVoVVoVVVoHo...",
	"...ohooSSssssssSSoohvo..",
	"...oHo..oSSSSSSo..oHo...",
	"..oshoo.osssssso.oohso..",
	".osslsottTttqttTTtosSso.",
	".osso.otttTtqttTTTo.oso.",
	".oqqo.ottTttqtTTXXo.oqo.",
	".ojJo.osslsssssSSSo.ojo.",
	".ojJo..osssssssSSo..ojo.",
	".onJo..owwwwWWWWWWo.ojo.",
	".onjo..onnnnnnnnnno.ojo.",
	"..oo...onnnnoonnnno..o..",
	".......ossSo.osssSo.....",
	".......onJjo.onJjo......",
	".......onJjo.onJjo......",
	".......onJjo.onjjo......",
	".......onjno.onjno......",
	".......onno...onno......",
	"........................",
]

const LEI_DESTRA := [
	"...oo...................",
	"..ohHoo.................",
	"..ohHHhoo...............",
	"...ohHhhvoo.............",
	"....oohvvooooooo........",
	".....oaawaawaauuo.......",
	".....oAaaaaaaauUuo......",
	"....ohhHhhhhhhuuvo......",
	"....ohHhhhhhhvhsvo......",
	"....oVhvhhhhvsssso......",
	"....oVvhhhhvssslsso.....",
	".....oVvhhvsssooosso....",
	".....oVvhvssssoiesso....",
	".....ohVVSsssssssSo.....",
	".....oHo.oSssSSSSo......",
	".....ohoo.oSsssSo.......",
	".....oHo.osssssso.......",
	"......oo.ottTssTto......",
	".........ottTslTXo......",
	".........ottTqqTXo......",
	".........ossSjJSSo......",
	".........ossSjJSSo......",
	".........owwWjJWWo......",
	".........onnnjjnno......",
	".........onnnnnno.......",
	"..........ossSso........",
	"..........onJjno........",
	"..........onJjno........",
	"..........onJjno........",
	"..........onjnnoo.......",
	"..........ono.nnno......",
	"........................",
]

const LEI_PASSO_A := {
	25: ".........osssosSo.......",
	26: ".........onJoonJjo......",
	27: "........onJjo.onJjo.....",
	28: "........onJo...onJjo....",
	29: ".......onjno...onjnoo...",
	30: ".......ono.....onnnno...",
}

const LEI_PASSO_B := {
	25: "..........osssSo........",
	26: "..........onJoJo........",
	27: ".........onJoonJo.......",
	28: ".........onJo.onJo......",
	29: "........onjno.onjnoo....",
	30: "........ono...onnnno....",
}


static func foglio(chi: String) -> Image:
	var lei := chi == "lei"
	var colori: Dictionary = TAVOLOZZA_LEI if lei else TAVOLOZZA_LUI
	var viste: Array = [LEI_GIU, LEI_SU, LEI_DESTRA] if lei else [LUI_GIU, LUI_SU, LUI_DESTRA]
	var passo_a: Dictionary = LEI_PASSO_A if lei else LUI_PASSO_A
	var passo_b: Dictionary = LEI_PASSO_B if lei else LUI_PASSO_B
	var img := Image.create_empty(LARGO * 3, ALTO * 3, false, Image.FORMAT_RGBA8)
	for riga in 3:
		var base: Array = viste[riga]
		var pose: Array = []
		if riga == 2:
			pose = [base, cambia(base, passo_a), cambia(base, passo_b)]
		else:
			# di spalle il piede che si alza per primo e' l'altro
			var primo := 5 if riga == 0 else 12
			var secondo := 12 if riga == 0 else 5
			pose = [base, alza(base, primo), alza(base, secondo)]
		for colonna in 3:
			disegna(img, pose[colonna], colori, Vector2i(colonna * LARGO, riga * ALTO))
	return img


static func alza(righe: Array, da_colonna: int) -> Array:
	# il piede si alza di un pixel: dalla riga 25 in giu', in quella meta'
	var nuove: Array = righe.duplicate()
	for y in range(25, 31):
		var riga := String(nuove[y])
		var sotto := String(righe[y + 1]) if y < 30 else ".".repeat(LARGO)
		for x in range(da_colonna, da_colonna + 7):
			riga = riga.substr(0, x) + sotto[x] + riga.substr(x + 1)
		nuove[y] = riga
	return nuove


static func cambia(righe: Array, gambe: Dictionary) -> Array:
	var nuove: Array = righe.duplicate()
	for y: int in gambe:
		nuove[y] = gambe[y]
	return nuove


static func disegna(img: Image, righe: Array, colori: Dictionary, dove: Vector2i) -> void:
	# l'ombra per terra sotto i piedi, poi il personaggio
	for y in ALTO:
		for x in LARGO:
			var q := Vector2((x + 0.5 - 12.0) / 7.5, (y + 0.5 - 30.5) / 1.8)
			if q.length_squared() < 1.0:
				img.set_pixel(dove.x + x, dove.y + y, Color(0.07, 0.05, 0.09, 0.31))
	for y in ALTO:
		var riga := String(righe[y])
		for x in LARGO:
			var lettera := riga[x]
			if colori.has(lettera):
				img.set_pixel(dove.x + x, dove.y + y, Color(String(colori[lettera])))
