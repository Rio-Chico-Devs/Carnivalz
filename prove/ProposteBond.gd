extends Control
# PROPOSTA PER IL BOND: LA PURIFICAZIONE. Provvisorio come le altre vetrine:
# non e' il gioco.
#
# Bru, sul primo giro coi personaggi: «no nessuno mi piace non ci devono essere
# i personaggi nel bond solo la scritta animata in modo angelico e pacifico tipo
# purificazione». Sulle tre di sola scritta (purificazione, aureola,
# calligrafia): «mi piace il primo, ma va migliorato manipolando ogni singola
# lettera e anche mettendoci più lavoro nelle animazioni».
#
# Il BOND e' la mediazione: la creatura non la abbatti, la liberi da quello che
# l'ha deformata. Quindi la luce lava, e ogni lettera nasce dalla luce:
#
#   1. l'ONDA sale dal basso, col bordo che ondeggia piano come la marea, e lava
#      lo scontro: ne resta un fantasma color crema, sfocato
#   2. ogni LETTERA ha i suoi tempi (prima la O, poi la N, la B, la D) e arriva
#      da una posa sua, un poco girata, piu' bassa e piu' in fuori:
#        - la luce sale lungo il suo contorno: due punte partono dal punto piu'
#          basso e si incontrano in cima. E' il contorno vero del carattere,
#          letto dal font, coi buchi della B, della O e della D
#        - la lettera si riempie dal basso come un vaso, col pelo della luce
#          bianco
#        - si raffredda in oro, e intanto si raddrizza e si posa
#   3. sotto si apre la RIGA, il ROMBO arriva girando di un quarto, e due luci
#      corrono dal centro alle punte
#   4. un RIFLESSO passa sulla parola: ogni lettera si accende quando la tocca;
#      poi le lettere respirano, piano, ognuna col suo passo
#   5. le lettere SALGONO una alla volta, da sinistra, e si sciolgono in luce;
#      la riga si ritira nel rombo, e una seconda onda porta via la luce verso
#      l'alto: lo scontro torna coi suoi colori, dal basso
#
# Tre strati: il lavaggio (uno shader che legge lo scontro sotto), le lettere
# (ognuna nel suo CanvasGroup, col suo shader: sfocatura, doratura,
# riempimento, bagliore), e sopra le tracce della luce sui contorni.
#
#   ./prove/film_bond.sh            la gira in scatti/proposte_bond/
#   nell'editor: ProposteBond.tscn, F6

const PARTE := 0.6        # quando comincia, dentro il film
const ASSESTAMENTO := 90

# IL LAVAGGIO: lo scontro sotto, scolorito, schiarito e sfocato fra le due
# onde: quella che sale e porta la luce, e quella che sale dopo e la porta via
const LAVAGGIO := """
shader_type canvas_item;
uniform sampler2D schermo : hint_screen_texture, repeat_disable, filter_linear_mipmap;
uniform float quanto = 0.0;      // quanto e' lavato dove la luce e' arrivata
uniform float sogno = 0.0;       // quanto e' sfocato (livelli di mipmap)
uniform float fronte = 2.0;      // l'onda che porta la luce: lava sotto di se'
uniform float coda = 2.0;        // l'onda che la porta via: sotto di lei lo scontro e' tornato
uniform float morbido = 0.3;     // quanto sono sfumati i bordi delle onde
uniform float cresta = 0.0;      // quanto brilla il bordo della prima
uniform float scia = 0.0;        // quanto brilla il bordo della seconda
uniform float alone = 0.0;       // il bianco dietro la parola
uniform float tempo = 0.0;
uniform vec2 centro = vec2(0.5, 0.47);
uniform vec3 pesca : source_color = vec3(0.97, 0.90, 0.80);
uniform vec3 crema : source_color = vec3(1.0, 0.975, 0.94);

void fragment() {
	vec2 uv = SCREEN_UV;
	float prop = SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x;
	float dist = length((uv - centro) * vec2(prop, 1.0));
	// il bordo delle onde ondeggia piano, come la marea
	float marea = 0.012 * sin(uv.x * 8.0 + tempo * 2.0) + 0.007 * sin(uv.x * 21.0 - tempo * 2.9);
	float f = fronte + marea;
	float c = coda - marea;
	float dentro = smoothstep(f - morbido, f, uv.y) * (1.0 - smoothstep(c - morbido, c, uv.y));
	float lava = dentro * quanto;
	vec3 vero = textureLod(schermo, uv, 0.0).rgb;
	vec3 sfocato = textureLod(schermo, uv, sogno * dentro).rgb;
	float l = dot(sfocato, vec3(0.299, 0.587, 0.114));
	vec3 pallido = mix(pesca, crema, smoothstep(0.0, 0.7, l));
	vec3 col = mix(vero, sfocato, clamp(lava * 1.5, 0.0, 1.0));
	col = mix(col, pallido, lava);
	col = mix(col, vec3(1.0), alone * dentro * exp(-dist * dist / 0.12));
	float d = (uv.y - (f - morbido * 0.45)) / 0.08;
	col = mix(col, vec3(1.0, 0.99, 0.96), cresta * exp(-d * d));
	float e = (uv.y - (c - morbido * 0.55)) / 0.08;
	col = mix(col, vec3(1.0, 0.99, 0.96), scia * exp(-e * e));
	COLOR = vec4(col, 1.0);
}
"""

# LA DORATURA: quello che c'e' nel CanvasGroup arriva bianco (se ne legge solo
# quanto e' coperto); qui si sfoca, si colora d'oro dall'alto in basso, si
# riempie dal basso col pelo bianco, ci passa il riflesso, e intorno gli si
# accende il bagliore
const DORATURA := """
shader_type canvas_item;
render_mode unshaded;
uniform sampler2D foglio : hint_screen_texture, repeat_disable, filter_linear_mipmap;
uniform float sfoca = 0.0;        // raggio della sfocatura, in pixel
uniform float bagliore = 0.0;     // quanto splende intorno
uniform float bianco = 0.0;       // quanto e' ancora luce invece che oro
uniform float lucido = -1.0;      // dove passa il riflesso (x sullo schermo, da 0 a 1)
uniform float riempi = -1.0;      // si riempie dal basso: c'e' sotto questa riga (y, da 0 a 1)
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
	m *= smoothstep(riempi - 0.005, riempi + 0.005, uv.y);
	g *= smoothstep(riempi - 0.04, riempi + 0.01, uv.y);
	float pelo = riempi > 0.0 ? exp(-pow((uv.y - riempi) / 0.012, 2.0)) : 0.0;
	float v = clamp((uv.y - alto_basso.x) / max(alto_basso.y - alto_basso.x, 0.001), 0.0, 1.0);
	vec3 tinta = mix(oro_chiaro, oro_scuro, smoothstep(0.0, 1.0, v));
	float d = (uv.x - lucido) - (uv.y - alto_basso.x) * 0.3;
	float riflesso = exp(-d * d / 0.0008);
	tinta = mix(tinta, vec3(1.0, 0.99, 0.95), clamp(max(max(bianco, pelo), riflesso * 0.9), 0.0, 1.0));
	float ga = clamp(g * bagliore * 1.6, 0.0, 1.0);
	float a = m + ga * (1.0 - m);
	vec3 col = (tinta * m + tinta_alone * ga * (1.0 - m)) / max(a, 0.0001);
	COLOR = vec4(col, a * COLOR.a);
}
"""

var tempo := -1.0
var luce: Luce


func _ready() -> void:
	GameState.nuova_partita()
	GameState.party = ["anonimo", "veronica"]
	GameState.nemici_combattimento = ["marionetta"]
	var scena: Node = load("res://scenes/Combattimento.tscn").instantiate()
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
	const DURA := 3.5
	const PAROLA := "BOND"
	# ogni lettera ha i suoi tempi e la sua posa d'arrivo
	const NASCE := [0.62, 0.4, 0.5, 0.72]       # quando la luce comincia a salirle addosso
	const GIRO := [-0.06, 0.045, -0.04, 0.06]   # quanto e' girata, prima di posarsi
	const FUORI := [-12.0, -4.0, 4.0, 12.0]     # quanto e' spostata in fuori
	const SALE := [2.3, 2.38, 2.46, 2.54]       # quando se ne va, da sinistra
	const RIFLESSO := 1.75                      # quando passa il riflesso
	const TORNA := 2.75                         # quando la seconda onda porta via la luce
	var orologio := -1.0
	var lato := Vector2.ZERO
	var corpo := 120
	var velo: ShaderMaterial
	var lettere: Array[Lettera] = []
	var dorature: Array[ShaderMaterial] = []
	var tracce: Tracce
	var scintille: Scintille
	var ornamento: Ornamento
	var oro_ornamento: ShaderMaterial
	var posto_ornamento := Vector2.ZERO
	var largo_riga := 0.0

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		lato = get_viewport_rect().size
		corpo = int(lato.y * 0.17)
		var centro := Vector2(lato.x * 0.5, lato.y * 0.47)
		var lavaggio := ColorRect.new()
		lavaggio.mouse_filter = Control.MOUSE_FILTER_IGNORE
		lavaggio.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		velo = materiale(LAVAGGIO)
		lavaggio.material = velo
		add_child(lavaggio)
		# le lettere al loro posto: larghe quanto dice il font, con l'aria fra l'una e l'altra
		var font := Caratteri.nomi()
		var spazio := corpo * 0.3
		var larghi: Array[float] = []
		var totale := spazio * float(PAROLA.length() - 1)
		for i in PAROLA.length():
			larghi.append(font.get_string_size(PAROLA[i], HORIZONTAL_ALIGNMENT_LEFT, -1, corpo).x)
			totale += larghi[i]
		var alto_basso := Vector2(centro.y - corpo * 0.35, centro.y + corpo * 0.35) / lato.y
		var x := centro.x - totale * 0.5
		for i in PAROLA.length():
			var oro := materiale(DORATURA)
			oro.set_shader_parameter("alto_basso", alto_basso)
			var lettera := Lettera.new(font, PAROLA[i], corpo, Vector2(x + larghi[i] * 0.5, centro.y), larghi[i])
			gruppo_dorato(oro).add_child(lettera)
			lettere.append(lettera)
			dorature.append(oro)
			x += larghi[i] + spazio
		oro_ornamento = materiale(DORATURA)
		oro_ornamento.set_shader_parameter("alto_basso", alto_basso)
		ornamento = Ornamento.new()
		ornamento.alto = corpo * 0.07
		posto_ornamento = Vector2(centro.x, centro.y + corpo * 0.65)
		largo_riga = totale * 0.5 + corpo * 0.5
		gruppo_dorato(oro_ornamento).add_child(ornamento)
		var oro_tracce := materiale(DORATURA)
		oro_tracce.set_shader_parameter("alto_basso", alto_basso)
		oro_tracce.set_shader_parameter("bianco", 0.3)
		oro_tracce.set_shader_parameter("bagliore", 1.0)
		tracce = Tracce.new()
		tracce.lettere = lettere
		gruppo_dorato(oro_tracce).add_child(tracce)
		# le punte di luce: quasi bianche, col bagliore largo
		var oro_scintille := materiale(DORATURA)
		oro_scintille.set_shader_parameter("alto_basso", alto_basso)
		oro_scintille.set_shader_parameter("bianco", 0.85)
		oro_scintille.set_shader_parameter("bagliore", 1.5)
		scintille = Scintille.new()
		scintille.lettere = lettere
		scintille.ornamento = ornamento
		gruppo_dorato(oro_scintille).add_child(scintille)
		avanza(-1.0)

	static func materiale(codice: String) -> ShaderMaterial:
		var shader := Shader.new()
		shader.code = codice
		var fatto := ShaderMaterial.new()
		fatto.shader = shader
		return fatto

	func gruppo_dorato(oro: ShaderMaterial) -> CanvasGroup:
		var gruppo := CanvasGroup.new()
		gruppo.use_mipmaps = true
		gruppo.fit_margin = 120.0
		gruppo.clear_margin = 120.0
		gruppo.material = oro
		add_child(gruppo)
		return gruppo

	# --- le curve: morbida comincia e finisce piano, frena arriva e si posa ---
	static func morbido(u: float) -> float:
		return 0.5 - 0.5 * cos(PI * clampf(u, 0.0, 1.0))

	static func frena(u: float) -> float:
		return 1.0 - pow(1.0 - clampf(u, 0.0, 1.0), 3.0)

	func fase(da: float, quanto: float) -> float:
		return morbido((orologio - da) / quanto)

	func riflesso_x() -> float:
		return lerpf(0.15, 1.0, fase(RIFLESSO, 0.7))

	func avanza(adesso: float) -> void:
		orologio = adesso
		visible = orologio >= 0.0 and orologio <= DURA
		if not visible:
			return
		onde()
		for i in lettere.size():
			muovi_lettera(i)
		muovi_ornamento()
		tracce.queue_redraw()
		scintille.queue_redraw()

	func onde() -> void:
		var torna := fase(TORNA, DURA - TORNA)
		velo.set_shader_parameter("fronte", lerpf(1.35, -0.4, fase(0.0, 1.15)))
		velo.set_shader_parameter("coda", lerpf(1.45, -0.45, torna))
		velo.set_shader_parameter("morbido", 0.32)
		velo.set_shader_parameter("cresta", 0.75 * (1.0 - fase(0.65, 0.6)))
		velo.set_shader_parameter("scia", 0.6 * sin(torna * PI))
		velo.set_shader_parameter("quanto", 0.93)
		velo.set_shader_parameter("sogno", 2.6)
		velo.set_shader_parameter("alone", 0.45 * fase(0.35, 0.9) * (1.0 - fase(2.3, 0.6)))
		velo.set_shader_parameter("tempo", orologio)

	func muovi_lettera(i: int) -> void:
		var lettera := lettere[i]
		var oro := dorature[i]
		var nasce := float(NASCE[i])
		# arriva dalla sua posa e si posa; se ne va salendo
		var arriva := frena((orologio - nasce) / 1.0)
		var parte := fase(float(SALE[i]), 0.55)
		lettera.position = lettera.posto + Vector2(float(FUORI[i]) * (1.0 - arriva), 22.0 * (1.0 - arriva) - 44.0 * parte)
		lettera.rotation = float(GIRO[i]) * (1.0 - arriva)
		lettera.scale = Vector2.ONE * (1.0 + 0.06 * (1.0 - arriva) + 0.04 * parte)
		# la luce sale lungo il contorno, poi la lettera si riempie dal basso
		lettera.traccia = fase(nasce, 0.55)
		lettera.traccia_luce = 1.0 - fase(nasce + 0.6, 0.35)
		var riempie := fase(nasce + 0.22, 0.55)
		var sotto := lettera.position.y + corpo * 0.38
		var sopra := lettera.position.y - corpo * 0.38
		oro.set_shader_parameter("riempi", lerpf(sotto, sopra, riempie) / lato.y if riempie < 1.0 else -1.0)
		lettera.luce = 1.0 - fase(float(SALE[i]) + 0.12, 0.4)
		lettera.queue_redraw()
		# piena e' ancora luce, poi si raffredda in oro; andando via torna luce
		oro.set_shader_parameter("bianco", maxf(0.5 * (1.0 - fase(nasce + 0.55, 0.55)), 0.9 * parte))
		oro.set_shader_parameter("sfoca", 16.0 * parte)
		oro.set_shader_parameter("lucido", riflesso_x())
		# il bagliore: forte appena piena, poi respira col suo passo; e quando
		# il riflesso la tocca si accende
		var piena := fase(nasce + 0.45, 0.35) * (1.0 - fase(nasce + 0.8, 0.6))
		var respiro := 0.08 * sin(orologio * 2.6 + float(i) * 1.3) * fase(nasce + 0.9, 0.5)
		var tocco := exp(-pow((riflesso_x() - lettera.position.x / lato.x) / 0.05, 2.0))
		oro.set_shader_parameter("bagliore", (0.45 + 0.7 * piena + respiro + 0.6 * tocco) * fase(nasce, 0.3) * (1.0 - parte))

	func muovi_ornamento() -> void:
		# la riga si apre, il rombo arriva girando, due luci corrono alle punte;
		# alla fine la riga si ritira nel rombo, e il rombo sale con le lettere
		var chiude := fase(2.3, 0.4)
		var parte := fase(2.55, 0.45)
		var arriva := frena((orologio - 1.4) / 0.6)
		ornamento.mezza = largo_riga * fase(1.4, 0.7) * (1.0 - chiude)
		ornamento.rombo = arriva
		ornamento.giro_rombo = PI * 0.5 * (1.0 - arriva)
		ornamento.corsa = (orologio - 1.75) / 0.55
		ornamento.luce = 1.0 - parte
		ornamento.position = posto_ornamento + Vector2(0.0, -44.0 * parte)
		ornamento.queue_redraw()
		oro_ornamento.set_shader_parameter("bianco", maxf(0.5 * (1.0 - fase(1.6, 0.6)), 0.9 * parte))
		oro_ornamento.set_shader_parameter("sfoca", 16.0 * parte)
		oro_ornamento.set_shader_parameter("bagliore", 0.6 * (1.0 - parte))
		oro_ornamento.set_shader_parameter("lucido", riflesso_x())


class Lettera extends Node2D:
	# una lettera, bianca (il colore glielo da' la doratura), col suo contorno
	# letto dal font: la luce ci sale sopra prima che si riempia
	var font: Font
	var segno := ""
	var corpo := 100
	var largo := 0.0
	var posto := Vector2.ZERO       # dove sta, posata
	var luce := 1.0                 # quanto c'e'
	var traccia := 0.0              # quanto e' salita la luce lungo il contorno (0..1)
	var traccia_luce := 1.0         # e quanto si vede
	var contorni: Array[PackedVector2Array] = []   # attorno al centro, dal punto piu' basso
	var lunghezze: Array[PackedFloat32Array] = []  # quanta strada fino a ogni punto

	func _init(carattere: Font, quale: String, grande: int, dove: Vector2, larghezza: float) -> void:
		font = carattere
		segno = quale
		corpo = grande
		posto = dove
		largo = larghezza
		position = dove
		leggi_contorni()

	func origine() -> Vector2:
		# dove comincia il glifo, rispetto al centro della lettera: le
		# maiuscole sono alte sette decimi del corpo
		return Vector2(-largo * 0.5, corpo * 0.35)

	func _draw() -> void:
		if luce > 0.0:
			draw_string(font, origine(), segno, HORIZONTAL_ALIGNMENT_LEFT, -1, corpo, Color(1, 1, 1, luce))

	func leggi_contorni() -> void:
		var ts := TextServerManager.get_primary_interface()
		var rid: RID = font.get_rids()[0]
		var glifo := ts.font_get_glyph_index(rid, corpo, segno.unicode_at(0), 0)
		var dati := ts.font_get_glyph_contours(rid, corpo, glifo)
		var punti: PackedVector3Array = dati.get("points", PackedVector3Array())
		var fini: PackedInt32Array = dati.get("contours", PackedInt32Array())
		var da := 0
		for fine in fini:
			var giro := dal_basso(appiattisci(punti, da, fine))
			for k in giro.size():
				giro[k] += origine()
			contorni.append(giro)
			lunghezze.append(misura(giro))
			da = fine + 1

	static func appiattisci(punti: PackedVector3Array, da: int, a: int) -> PackedVector2Array:
		# il contorno come lo scrive il font: punti sulla curva e punti di
		# controllo (curve di secondo grado; fra due di controllo di fila c'e' un
		# punto sulla curva sottinteso, a meta'). Qui diventa una spezzata
		var quanti := a - da + 1
		var fuori := PackedVector2Array()
		var primo := -1
		for k in quanti:
			if (int(punti[da + k].z) & 1) == 1:
				primo = k
				break
		if primo < 0:
			return fuori
		var corrente := Vector2(punti[da + primo].x, punti[da + primo].y)
		fuori.append(corrente)
		var controllo := Vector2.ZERO
		var in_sospeso := false
		for passo in range(1, quanti + 1):
			var p := punti[da + (primo + passo) % quanti]
			var q := Vector2(p.x, p.y)
			if (int(p.z) & 1) == 1:
				if in_sospeso:
					fuori.append_array(curva(corrente, controllo, q))
					in_sospeso = false
				else:
					fuori.append(q)
				corrente = q
			elif in_sospeso:
				var mezzo := (controllo + q) * 0.5
				fuori.append_array(curva(corrente, controllo, mezzo))
				corrente = mezzo
				controllo = q
			else:
				controllo = q
				in_sospeso = true
		if fuori.size() > 1 and fuori[0].is_equal_approx(fuori[fuori.size() - 1]):
			fuori.remove_at(fuori.size() - 1)
		return fuori

	static func curva(a: Vector2, c: Vector2, b: Vector2) -> PackedVector2Array:
		var fatto := PackedVector2Array()
		for k in range(1, 7):
			var t := float(k) / 6.0
			fatto.append(a.lerp(c, t).lerp(c.lerp(b, t), t))
		return fatto

	static func dal_basso(giro: PackedVector2Array) -> PackedVector2Array:
		# il giro comincia dal punto piu' basso, e si chiude tornandoci
		if giro.is_empty():
			return giro
		var basso := 0
		for k in giro.size():
			if giro[k].y > giro[basso].y:
				basso = k
		var fatto := giro.slice(basso)
		fatto.append_array(giro.slice(0, basso))
		fatto.append(giro[basso])
		return fatto

	static func misura(giro: PackedVector2Array) -> PackedFloat32Array:
		var fatto := PackedFloat32Array()
		var strada := 0.0
		for k in giro.size():
			if k > 0:
				strada += giro[k].distance_to(giro[k - 1])
			fatto.append(strada)
		return fatto


class Tracce extends Node2D:
	# la luce che sale lungo i contorni: per ogni giro due punte partono dal
	# punto piu' basso, una per verso, e si incontrano dall'altra parte
	var lettere: Array[Lettera] = []

	func _draw() -> void:
		for lettera in lettere:
			if lettera.traccia <= 0.0 or lettera.traccia_luce <= 0.0:
				continue
			draw_set_transform_matrix(lettera.transform)
			var bianco := Color(1, 1, 1, lettera.traccia_luce)
			for c in lettera.contorni.size():
				var giro := lettera.contorni[c]
				var strada := lettera.lunghezze[c]
				if giro.size() < 2:
					continue
				var tutta := strada[strada.size() - 1]
				var fin_qui := tutta * 0.5 * lettera.traccia
				draw_polyline(tratto(giro, strada, 0.0, fin_qui), bianco, 2.4, true)
				draw_polyline(tratto(giro, strada, tutta - fin_qui, tutta), bianco, 2.4, true)
		draw_set_transform_matrix(Transform2D.IDENTITY)

	static func punto_a(giro: PackedVector2Array, strada: PackedFloat32Array, s: float) -> Vector2:
		var k := clampi(strada.bsearch(s), 1, giro.size() - 1)
		var t := (s - strada[k - 1]) / maxf(strada[k] - strada[k - 1], 0.001)
		return giro[k - 1].lerp(giro[k], clampf(t, 0.0, 1.0))

	static func tratto(giro: PackedVector2Array, strada: PackedFloat32Array, da: float, a: float) -> PackedVector2Array:
		var fatto := PackedVector2Array([punto_a(giro, strada, da)])
		for k in giro.size():
			if strada[k] > da and strada[k] < a:
				fatto.append(giro[k])
		fatto.append(punto_a(giro, strada, a))
		return fatto


class Ornamento extends Node2D:
	# la riga sotto la parola, piena in mezzo e a punta ai lati, col rombo del
	# gioco; bianca come le lettere, la dora lo stesso shader
	var mezza := 0.0          # mezza lunghezza della riga
	var rombo := 0.0          # quanto e' arrivato il rombo
	var giro_rombo := 0.0
	var corsa := -1.0         # le due luci che corrono (le disegnano le scintille): 0 al centro, 1 alle punte
	var luce := 1.0
	var alto := 8.0           # mezza altezza del rombo

	func _draw() -> void:
		var bianco := Color(1, 1, 1, luce)
		if mezza > 4.0:
			draw_colored_polygon(PackedVector2Array([Vector2(-mezza, 0), Vector2(0, -1.8), Vector2(mezza, 0), Vector2(0, 1.8)]), bianco)
		if rombo > 0.05:
			draw_set_transform(Vector2.ZERO, giro_rombo, Vector2.ONE * rombo)
			draw_colored_polygon(PackedVector2Array([Vector2(0, -alto), Vector2(alto * 0.8, 0), Vector2(0, alto), Vector2(-alto * 0.8, 0)]), bianco)
			draw_set_transform(Vector2.ZERO)


class Scintille extends Node2D:
	# le punte di luce, quasi bianche: le due che salgono lungo ogni contorno
	# (si spengono quando si incontrano), il seme dove la luce tocca la lettera
	# per la prima volta, e le due comete che corrono lungo la riga
	var lettere: Array[Lettera] = []
	var ornamento: Ornamento

	func _draw() -> void:
		for lettera in lettere:
			if lettera.traccia <= 0.0 or lettera.traccia_luce <= 0.0:
				continue
			draw_set_transform_matrix(lettera.transform)
			var punta := Color(1, 1, 1, lettera.traccia_luce * (1.0 - pow(lettera.traccia, 4.0)))
			for c in lettera.contorni.size():
				var giro := lettera.contorni[c]
				var strada := lettera.lunghezze[c]
				if giro.size() < 2:
					continue
				var fin_qui := strada[strada.size() - 1] * 0.5 * lettera.traccia
				draw_circle(Tracce.punto_a(giro, strada, fin_qui), 3.0, punta, true, -1.0, true)
				draw_circle(Tracce.punto_a(giro, strada, strada[strada.size() - 1] - fin_qui), 3.0, punta, true, -1.0, true)
				if c == 0 and lettera.traccia < 0.35:
					var seme := lettera.traccia / 0.35
					draw_circle(giro[0], lerpf(7.0, 3.0, seme), Color(1, 1, 1, lettera.traccia_luce * (1.0 - seme)), true, -1.0, true)
		var corsa := ornamento.corsa
		if corsa >= 0.0 and corsa <= 1.0:
			draw_set_transform_matrix(ornamento.transform)
			var corre := Color(1, 1, 1, ornamento.luce * sin(corsa * PI))
			for verso: float in [-1.0, 1.0]:
				var testa := Vector2(verso * ornamento.mezza * corsa, 0.0)
				draw_colored_polygon(PackedVector2Array([testa - Vector2(verso * 30.0, 0.0), testa + Vector2(0.0, -2.2),
						testa + Vector2(0.0, 2.2)]), corre)
				draw_circle(testa, 2.6, corre, true, -1.0, true)
		draw_set_transform_matrix(Transform2D.IDENTITY)
