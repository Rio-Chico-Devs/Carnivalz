extends Control
# PROPOSTE PER IL BOND. Provvisorio come le altre vetrine: non e' il gioco.
#
# Bru, sulle prime tre (il filo, l'alba, l'anello, coi due personaggi): «no
# nessuno mi piace non ci devono essere i personaggi nel bond solo la scritta
# animata in modo angelico e pacifico tipo purificazione».
#
# Quindi solo la parola, e la luce. Il BOND e' la mediazione: la creatura non
# la abbatti, la liberi da quello che l'ha deformata. Il contrario della
# Mattanza: niente fasce, niente scatti, niente nero e rosso; la luce lava lo
# scontro, la parola si fa d'oro, e tutto comincia e finisce piano.
#
# COME E' FATTA, tre strati:
#   - il LAVAGGIO: uno shader legge lo scontro sotto e lo scolora, lo schiarisce
#     e lo sfoca, finche' ne resta un fantasma color crema; la luce ci arriva
#     in modo diverso in ogni proposta (un'onda, dei raggi, un cerchio)
#   - la PAROLA, disegnata bianca dentro un CanvasGroup: il suo shader la sfoca
#     (la parola che si condensa dalla luce), la dora (oro chiaro in alto, ambra
#     in basso), ci fa passare sopra un riflesso e le mette intorno il bagliore
#   - gli ornamenti, disegnati con la parola e dorati con lei: la riga col
#     rombo, l'aureola
#
#   purificazione   un'onda di luce sale dal basso e lava lo schermo; BOND (il
#                   maiuscoletto antico dei nomi) si condensa dal bianco
#                   all'oro, sotto si apre la riga col rombo, passa un riflesso
#   aureola         la luce scende dall'alto a raggi morbidi; le lettere (il
#                   tondo, leggero) scendono come piume, e sopra si posa
#                   l'aureola
#   calligrafia     la luce si apre dal centro con cerchi lenti, come
#                   sull'acqua; Bond si scrive in calligrafia, e l'inchiostro
#                   fresco e' bianco e si raffredda in oro
#
# Ognuna sullo scontro vero, a riposo; meno di tre secondi, e come la Mattanza
# un clic la salterebbe.
#
#   ./prove/film_bond.sh            le gira tutte in scatti/proposte_bond/
#   nell'editor: ProposteBond.tscn, F6 (fa la purificazione)

const PARTE := 0.6        # quando comincia, dentro il film
const ASSESTAMENTO := 90

# IL LAVAGGIO: lo scontro sotto, scolorito, schiarito e sfocato dove la luce e'
# arrivata ("dentro"); poi la luce stessa: il bianco dietro la parola, il fronte
# dell'onda, i raggi dall'alto, i cerchi
const LAVAGGIO := """
shader_type canvas_item;
uniform sampler2D schermo : hint_screen_texture, repeat_disable, filter_linear_mipmap;
uniform int modo = 0;            // 0 l'onda dal basso, 1 dall'alto, 2 dal centro
uniform float quanto = 0.0;      // quanto e' lavato dove la luce e' arrivata
uniform float sogno = 0.0;       // quanto e' sfocato (livelli di mipmap)
uniform float fronte = 2.0;      // dov'e' arrivata: l'altezza dell'onda, o il raggio
uniform float morbido = 0.3;     // quanto e' sfumato il fronte
uniform float cresta = 0.0;      // quanto brilla il fronte dell'onda
uniform float raggi = 0.0;       // i raggi dall'alto
uniform float alone = 0.0;       // il bianco dietro la parola
uniform float tempo = 0.0;
uniform float anelli[3];         // i raggi dei cerchi
uniform float anelli_forza[3];
uniform vec2 centro = vec2(0.5, 0.47);
uniform vec3 pesca : source_color = vec3(0.97, 0.90, 0.80);
uniform vec3 crema : source_color = vec3(1.0, 0.975, 0.94);
uniform vec3 oro : source_color = vec3(0.90, 0.68, 0.32);

void fragment() {
	vec2 uv = SCREEN_UV;
	float prop = SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x;
	vec2 q = (uv - centro) * vec2(prop, 1.0);
	float dist = length(q);
	float dentro = 1.0;
	if (modo == 0) {
		dentro = smoothstep(fronte - morbido, fronte, uv.y);
	} else if (modo == 1) {
		dentro = 1.0 - smoothstep(fronte, fronte + morbido, uv.y);
	} else if (modo == 2) {
		dentro = 1.0 - smoothstep(fronte - morbido, fronte, dist);
	}
	float lava = dentro * quanto;
	vec3 vero = textureLod(schermo, uv, 0.0).rgb;
	vec3 sfocato = textureLod(schermo, uv, sogno * dentro).rgb;
	float l = dot(sfocato, vec3(0.299, 0.587, 0.114));
	vec3 pallido = mix(pesca, crema, smoothstep(0.0, 0.7, l));
	vec3 col = mix(vero, sfocato, clamp(lava * 1.5, 0.0, 1.0));
	col = mix(col, pallido, lava);
	col = mix(col, vec3(1.0), alone * exp(-dist * dist / 0.12));
	if (modo == 0) {
		float d = (uv.y - (fronte - morbido * 0.45)) / 0.08;
		col = mix(col, vec3(1.0, 0.99, 0.96), cresta * exp(-d * d));
	}
	if (raggi > 0.0) {
		vec2 s = (uv - vec2(0.5, -0.45)) * vec2(prop, 1.0);
		float a = atan(s.x, s.y);
		float r = pow(0.5 + 0.5 * sin(a * 9.0 + 0.4 * sin(tempo * 0.7)), 5.0) * 0.65
				+ pow(0.5 + 0.5 * sin(a * 14.0 - tempo * 0.22 + 1.7), 7.0) * 0.35;
		float giu = exp(-max(length(s) - 0.45, 0.0) * 1.1);
		col = mix(col, vec3(1.0, 0.985, 0.95), clamp(raggi * r * giu, 0.0, 1.0));
		col = mix(col, oro, 0.18 * raggi * r * giu * (1.0 - giu));
	}
	for (int i = 0; i < 3; i++) {
		float d = (dist - anelli[i]) / 0.016;
		col = mix(col, oro, anelli_forza[i] * exp(-d * d));
	}
	COLOR = vec4(col, 1.0);
}
"""

# LA DORATURA: la parola arriva bianca (il CanvasGroup la disegna in un foglio
# suo, e qui se ne legge solo quanto e' coperto); qui si sfoca, si colora d'oro
# dall'alto in basso, ci passa il riflesso, e intorno le si accende il bagliore
const DORATURA := """
shader_type canvas_item;
render_mode unshaded;
uniform sampler2D foglio : hint_screen_texture, repeat_disable, filter_linear_mipmap;
uniform float sfoca = 0.0;        // raggio della sfocatura, in pixel
uniform float bagliore = 0.0;     // quanto splende intorno
uniform float bianco = 0.0;       // quanto e' ancora luce invece che oro
uniform float lucido = -1.0;      // dove passa il riflesso (x sullo schermo, da 0 a 1)
uniform float svela = 2.0;        // la calligrafia: si vede a sinistra di qui
uniform float sfuma_svela = 0.025;
uniform float inchiostro = 0.0;   // la calligrafia: il tratto fresco e' bianco
uniform vec2 alto_basso = vec2(0.3, 0.6);
uniform vec3 oro_chiaro : source_color = vec3(0.86, 0.63, 0.25);
uniform vec3 oro_scuro : source_color = vec3(0.52, 0.30, 0.06);
uniform vec3 tinta_alone : source_color = vec3(1.0, 0.84, 0.52);

float disco(vec2 uv, vec2 px, float r) {
	if (r < 0.75) {
		return textureLod(foglio, uv, 0.0).a;
	}
	float lod = max(0.0, log2(r) - 2.5);
	float s = 0.0;
	for (int i = 0; i < 24; i++) {
		float f = (float(i) + 0.5) / 24.0;
		float a = float(i) * 2.39996323;
		s += textureLod(foglio, uv + vec2(cos(a), sin(a)) * sqrt(f) * r * px, lod).a;
	}
	return s / 24.0;
}

void fragment() {
	vec2 uv = SCREEN_UV;
	vec2 px = SCREEN_PIXEL_SIZE;
	float m = disco(uv, px, sfoca);
	float g = 0.55 * disco(uv, px, 14.0 + sfoca) + 0.45 * disco(uv, px, 42.0 + sfoca);
	m *= 1.0 - smoothstep(svela - sfuma_svela, svela + sfuma_svela, uv.x);
	g *= 1.0 - smoothstep(svela - sfuma_svela, svela + sfuma_svela * 3.0, uv.x);
	float v = clamp((uv.y - alto_basso.x) / max(alto_basso.y - alto_basso.x, 0.001), 0.0, 1.0);
	vec3 tinta = mix(oro_chiaro, oro_scuro, smoothstep(0.0, 1.0, v));
	float d = (uv.x - lucido) - (uv.y - alto_basso.x) * 0.3;
	float riflesso = exp(-d * d / 0.0008);
	float caldo = inchiostro * (1.0 - smoothstep(0.0, 0.12, svela - uv.x));
	tinta = mix(tinta, vec3(1.0, 0.99, 0.95), clamp(max(max(bianco, caldo), riflesso * 0.9), 0.0, 1.0));
	float ga = clamp(g * bagliore * 1.6, 0.0, 1.0);
	float a = m + ga * (1.0 - m);
	vec3 col = (tinta * m + tinta_alone * ga * (1.0 - m)) / max(a, 0.0001);
	COLOR = vec4(col, a * COLOR.a);
}
"""

var scena: Node
var nome := "purificazione"
var tempo := -1.0
var luce: Luce


func _ready() -> void:
	var argomenti := OS.get_cmdline_user_args()
	if argomenti.size() > 1 and String(argomenti[0]) == "film":
		nome = String(argomenti[1])
	GameState.nuova_partita()
	GameState.party = ["anonimo", "veronica"]
	GameState.nemici_combattimento = ["marionetta"]
	scena = load("res://scenes/Combattimento.tscn").instantiate()
	add_child(scena)
	for i in ASSESTAMENTO:
		await get_tree().process_frame
	scena.set_process(false)
	scena.voce.coda.clear()
	scena.campo.evidenzia(scena.combattenti, scena.combattenti[0])
	scena.menu.principale()
	var sopra := CanvasLayer.new()
	sopra.layer = 20
	add_child(sopra)
	luce = Luce.new()
	luce.stile = nome
	luce.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	sopra.add_child(luce)
	tempo = 0.0
	print("INIZIO_FILM ", Engine.get_frames_drawn())


func _process(delta: float) -> void:
	if tempo < 0.0:
		return
	tempo += delta
	luce.avanza(tempo - PARTE)
	if tempo > PARTE + Luce.DURA + 0.8:
		get_tree().quit()


class Luce extends Control:
	const DURA := 2.8
	const VA_VIA := 0.65      # quanto ci mette tutto a ritirarsi, alla fine
	var stile := "purificazione"
	var orologio := -1.0
	var lavaggio: ColorRect
	var velo: ShaderMaterial
	var gruppo: CanvasGroup
	var oro: ShaderMaterial
	var parola: Parola

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		lavaggio = ColorRect.new()
		lavaggio.mouse_filter = Control.MOUSE_FILTER_IGNORE
		lavaggio.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		velo = materiale(LAVAGGIO)
		lavaggio.material = velo
		add_child(lavaggio)
		gruppo = CanvasGroup.new()
		gruppo.use_mipmaps = true
		gruppo.fit_margin = 220.0
		gruppo.clear_margin = 220.0
		oro = materiale(DORATURA)
		gruppo.material = oro
		add_child(gruppo)
		parola = Parola.new()
		gruppo.add_child(parola)
		prepara()
		avanza(-1.0)

	static func materiale(codice: String) -> ShaderMaterial:
		var shader := Shader.new()
		shader.code = codice
		var fatto := ShaderMaterial.new()
		fatto.shader = shader
		return fatto

	func prepara() -> void:
		var lato := get_viewport_rect().size
		parola.size = lato
		parola.centro = Vector2(lato.x * 0.5, lato.y * 0.47)
		match stile:
			"purificazione":
				parola.font = Caratteri.nomi()
				parola.corpo = int(lato.y * 0.17)
				parola.spazio = parola.corpo * 0.3
			"aureola":
				parola.font = Caratteri.tondo(500)
				parola.corpo = int(lato.y * 0.13)
				parola.spazio = parola.corpo * 0.5
			"calligrafia":
				parola.font = Caratteri.fiaba()
				parola.testo = "Bond"
				parola.intera = true
				parola.corpo = int(lato.y * 0.34)
		parola.prepara()
		oro.set_shader_parameter("alto_basso", parola.alto_basso() / lato.y)

	# --- le curve morbide: comincia piano e finisce piano ---
	static func morbido(u: float) -> float:
		return 0.5 - 0.5 * cos(PI * clampf(u, 0.0, 1.0))

	func fase(da: float, quanto: float) -> float:
		return morbido((orologio - da) / quanto)

	func avanza(adesso: float) -> void:
		orologio = adesso
		visible = orologio >= 0.0 and orologio <= DURA
		if not visible:
			return
		match stile:
			"purificazione":
				purificazione()
			"aureola":
				aureola()
			"calligrafia":
				calligrafia()
		parola.queue_redraw()

	func lava(modo: int, quanto: float, sogno: float, alone: float) -> void:
		velo.set_shader_parameter("modo", modo)
		velo.set_shader_parameter("quanto", quanto)
		velo.set_shader_parameter("sogno", sogno)
		velo.set_shader_parameter("alone", alone)
		velo.set_shader_parameter("tempo", orologio)

	# --- LA PURIFICAZIONE ---------------------------------------------------
	func purificazione() -> void:
		var parte := fase(DURA - VA_VIA, VA_VIA)   # alla fine tutto si ritira
		var via := 1.0 - parte
		# l'onda sale dal basso e lava: dietro di lei resta il fantasma crema
		lava(0, 0.93 * via, 2.6 * via, 0.7 * fase(0.4, 0.9) * via)
		velo.set_shader_parameter("fronte", lerpf(1.35, -0.4, fase(0.0, 1.2)))
		velo.set_shader_parameter("morbido", 0.32)
		velo.set_shader_parameter("cresta", 0.75 * (1.0 - fase(0.7, 0.6)))
		# la parola si condensa dalla luce: prima bianca e sfocata, poi oro e nitida
		oro.set_shader_parameter("sfoca", lerpf(24.0, 0.0, fase(0.45, 0.95)) + 14.0 * parte)
		oro.set_shader_parameter("bianco", maxf(0.6 * (1.0 - fase(0.6, 0.8)), 0.8 * parte))
		oro.set_shader_parameter("bagliore", lerpf(1.1, 0.55, fase(0.9, 0.8)) * via)
		oro.set_shader_parameter("lucido", lerpf(0.12, 1.0, fase(1.4, 0.8)))
		# prima le due lettere in mezzo, poi quelle ai lati; salgono un poco
		for i in parola.accese.size():
			var dai_lati := absf(float(i) - 1.5) - 0.5
			var u := fase(0.45 + 0.16 * dai_lati, 0.7)
			parola.accese[i] = u * via
			parola.scarti[i] = Vector2(0.0, 16.0 * (1.0 - u) - 22.0 * parte)
		parola.linea = fase(1.2, 0.75) * via

	# --- L'AUREOLA ----------------------------------------------------------
	func aureola() -> void:
		var parte := fase(DURA - VA_VIA, VA_VIA)
		var via := 1.0 - parte
		# la luce scende dall'alto, e coi raggi
		lava(1, 0.93 * via, 2.6 * via, 0.6 * fase(0.5, 0.9) * via)
		velo.set_shader_parameter("fronte", lerpf(-0.4, 1.4, fase(0.0, 1.1)))
		velo.set_shader_parameter("morbido", 0.4)
		velo.set_shader_parameter("raggi", 0.85 * fase(0.0, 0.9) * via)
		oro.set_shader_parameter("sfoca", lerpf(9.0, 0.0, fase(0.35, 1.3)) + 14.0 * parte)
		oro.set_shader_parameter("bianco", maxf(0.7 * (1.0 - fase(0.6, 1.0)), 0.8 * parte))
		oro.set_shader_parameter("bagliore", 0.75 * via)
		oro.set_shader_parameter("lucido", -1.0)
		# le lettere scendono come piume, dondolando, una dopo l'altra
		for i in parola.accese.size():
			var u := fase(0.25 + 0.15 * i, 1.05)
			var verso := 1.0 if i % 2 == 0 else -1.0
			var onda := u * PI * 1.5
			parola.accese[i] = minf(1.0, u * 1.5) * via
			parola.scarti[i] = Vector2(verso * 18.0 * sin(onda) * (1.0 - u), -60.0 * (1.0 - u) - 22.0 * parte)
			parola.giri[i] = verso * 0.2 * cos(onda) * (1.0 - u)
		parola.aureola = fase(1.25, 0.8) * via
		parola.dondola = 4.0 * sin(orologio * 2.2) - 22.0 * parte

	# --- LA CALLIGRAFIA -----------------------------------------------------
	func calligrafia() -> void:
		var parte := fase(DURA - VA_VIA, VA_VIA)
		var via := 1.0 - parte
		lava(2, 0.93 * via, 2.6 * via, 0.7 * fase(0.3, 0.8) * via)
		velo.set_shader_parameter("fronte", lerpf(0.0, 1.5, fase(0.0, 1.3)))
		velo.set_shader_parameter("morbido", 0.45)
		# i cerchi lenti: partono dal centro, rallentano, si spengono
		var raggi := PackedFloat32Array()
		var forze := PackedFloat32Array()
		for k in 3:
			var u := clampf((orologio - 0.2 - 0.4 * k) / 1.7, 0.0, 1.0)
			raggi.append(lerpf(0.05, 0.8, 1.0 - (1.0 - u) * (1.0 - u)))
			forze.append(0.25 * sin(u * PI) * via)
		velo.set_shader_parameter("anelli", raggi)
		velo.set_shader_parameter("anelli_forza", forze)
		# la parola si scrive da sinistra a destra: dove la penna e' appena
		# passata l'inchiostro e' ancora luce
		var bordi := parola.sinistra_destra() / get_viewport_rect().size.x
		oro.set_shader_parameter("svela", lerpf(bordi.x - 0.04, bordi.y + 0.16, fase(0.4, 1.05)))
		oro.set_shader_parameter("inchiostro", 1.0)
		oro.set_shader_parameter("sfoca", 14.0 * parte)
		oro.set_shader_parameter("bianco", 0.8 * parte)
		oro.set_shader_parameter("bagliore", 0.75 * via)
		oro.set_shader_parameter("lucido", -1.0)
		parola.accese[0] = via
		parola.scarti[0] = Vector2(0.0, -22.0 * parte)


class Parola extends Control:
	# la parola, bianca: il colore glielo da' la doratura. Lettera per lettera
	# (ognuna col suo spostamento, giro e luce), o tutta insieme se le lettere
	# si legano (la calligrafia)
	var font: Font
	var testo := "BOND"
	var intera := false
	var corpo := 100
	var spazio := 0.0
	var centro := Vector2.ZERO
	var accese: Array[float] = []
	var scarti: Array[Vector2] = []
	var giri: Array[float] = []
	var larghi: Array[float] = []
	var totale := 0.0
	var linea := 0.0          # la riga col rombo, sotto: quanto e' aperta
	var aureola := 0.0        # l'aureola, sopra: quanto c'e'
	var dondola := 0.0        # e quanto si e' spostata

	func prepara() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		var pezzi := 1 if intera else testo.length()
		accese.resize(pezzi)
		accese.fill(0.0)
		scarti.resize(pezzi)
		scarti.fill(Vector2.ZERO)
		giri.resize(pezzi)
		giri.fill(0.0)
		larghi.clear()
		totale = 0.0
		for i in pezzi:
			var l := font.get_string_size(pezzo(i), HORIZONTAL_ALIGNMENT_LEFT, -1, corpo).x
			larghi.append(l)
			totale += l + (spazio if i < pezzi - 1 else 0.0)

	func pezzo(i: int) -> String:
		return testo if intera else testo[i]

	func base() -> float:
		# la riga su cui poggiano le lettere, perche' la parola stia sul centro
		if intera:
			return centro.y + corpo * 0.2
		return centro.y + corpo * 0.36

	func alto_basso() -> Vector2:
		# da dove a dove va la doratura, dall'oro chiaro all'ambra
		if intera:
			return Vector2(base() - corpo * 0.55, base() + corpo * 0.08)
		return Vector2(base() - corpo * 0.72, base())

	func sinistra_destra() -> Vector2:
		return Vector2(centro.x - totale * 0.5, centro.x + totale * 0.5)

	func _draw() -> void:
		var x := centro.x - totale * 0.5
		for i in larghi.size():
			if accese[i] > 0.0:
				var mezzo := Vector2(x + larghi[i] * 0.5, centro.y)
				draw_set_transform(mezzo + scarti[i], giri[i], Vector2.ONE)
				draw_string(font, Vector2(-larghi[i] * 0.5, base() - centro.y), pezzo(i),
						HORIZONTAL_ALIGNMENT_LEFT, -1, corpo, Color(1, 1, 1, accese[i]))
			x += larghi[i] + spazio
		draw_set_transform(Vector2.ZERO)
		if linea > 0.0:
			riga()
		if aureola > 0.0:
			cerchio()

	func riga() -> void:
		# una riga sottile che si apre dal centro, piena in mezzo e a punta ai
		# lati, col rombo del gioco
		var y := base() + corpo * 0.3
		var mezza := (totale * 0.5 + corpo * 0.5) * linea
		if mezza < 4.0:
			return
		var bianco := Color(1, 1, 1, minf(1.0, linea * 2.0))
		draw_colored_polygon(PackedVector2Array([Vector2(centro.x - mezza, y), Vector2(centro.x, y - 1.8),
				Vector2(centro.x + mezza, y), Vector2(centro.x, y + 1.8)]), bianco)
		var r := corpo * 0.07 * minf(1.0, linea * 1.6)
		draw_colored_polygon(PackedVector2Array([Vector2(centro.x, y - r), Vector2(centro.x + r * 0.8, y),
				Vector2(centro.x, y + r), Vector2(centro.x - r * 0.8, y)]), bianco)

	func cerchio() -> void:
		# l'aureola: un anello visto di sbieco sopra la parola; si posa
		# scendendo e allargandosi
		var c := Vector2(centro.x, base() - corpo * 1.25 - 16.0 * (1.0 - aureola) + dondola)
		var rx := totale * lerpf(0.18, 0.26, aureola)
		var punti := PackedVector2Array()
		for k in 97:
			var ang := TAU * float(k) / 96.0
			punti.append(c + Vector2(cos(ang) * rx, sin(ang) * rx * 0.2))
		draw_polyline(punti, Color(1, 1, 1, aureola), maxf(2.0, corpo * 0.05), true)
