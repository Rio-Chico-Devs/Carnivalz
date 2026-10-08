class_name CieloProiezione
extends RefCounted

# IL CIELO DELLA PROIEZIONE (Proiezione.gd): le stelle, la nebulosa del
# settore, e il rumore che fa gli schizzi sulla griglia. Tutto quello che non e' un corpo e non e' una scritta.
#
# Il rumore si fa una volta sola per partita: e' la stessa trama ogni volta
# che si apre la mappa, e rifarlo costerebbe un attimo a ogni apertura.

const STELLA := preload("res://shaders/proiezione_stella.gdshader")
const NEBULOSA := preload("res://shaders/proiezione_nebulosa.gdshader")

static var rumore_fatto: ImageTexture = null


static func dati() -> Dictionary:
	var d: Variant = Stile.dati.get("proiezione", {})
	return d if d is Dictionary else {}


static func tinte() -> Dictionary:
	# i quattro inchiostri, da stile.json: chi disegna li chiede tutti insieme
	var d := dati()
	return {"fondo": Color(String(d.get("fondo", "#0b0e14"))),
			"inchiostro": Color(String(d.get("inchiostro", "#4a7aa8"))),
			"carta": Color(String(d.get("carta", "#efd8b2"))),
			"segnale": Color(String(d.get("segnale", "#f29a2e")))}


static func misura(chiave: String, predefinita: float) -> float:
	return float(dati().get(chiave, predefinita))


static func inquadratura(livello: String) -> Dictionary:
	var d: Variant = dati().get(livello, {})
	return d if d is Dictionary else {}


static func rumore() -> ImageTexture:
	if rumore_fatto == null:
		var n := FastNoiseLite.new()
		n.seed = 11
		n.noise_type = FastNoiseLite.TYPE_SIMPLEX
		n.frequency = 0.03
		n.fractal_octaves = 4
		rumore_fatto = ImageTexture.create_from_image(n.get_seamless_image(256, 256))
	return rumore_fatto


static func materiale(shader: Shader, parametri: Dictionary) -> ShaderMaterial:
	var m := ShaderMaterial.new()
	m.shader = shader
	for chiave in parametri:
		m.set_shader_parameter(chiave, parametri[chiave])
	return m


static func stelle(tinta: Color, quante: int, seme: int) -> MultiMeshInstance3D:
	# lontane, su una cupola: le poche sotto l'orizzonte le copre la griglia
	var d := RandomNumberGenerator.new()
	d.seed = seme
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_colors = true
	var quadro := QuadMesh.new()
	quadro.size = Vector2.ONE
	mm.mesh = quadro
	mm.instance_count = quante
	for i in quante:
		var giro := d.randf() * TAU
		var alto := asin(d.randf_range(-0.05, 0.95))
		var dove := Vector3(cos(alto) * sin(giro), sin(alto), cos(alto) * cos(giro)) * d.randf_range(60.0, 120.0)
		var lato := d.randf_range(0.1, 0.42) * (2.2 if d.randf() < 0.04 else 1.0)
		mm.set_instance_transform(i, Transform3D(Basis.IDENTITY.scaled(Vector3.ONE * lato), dove))
		mm.set_instance_color(i, Color(1, 1, 1, d.randf_range(0.25, 1.0)))
	var nodo := MultiMeshInstance3D.new()
	nodo.multimesh = mm
	nodo.material_override = materiale(STELLA, {"carta": tinta, "brilla": 0.0 if Movimento.ridotto() else 1.0})
	return nodo


static func nebulosa(tinta: Color) -> ColorRect:
	var r := ColorRect.new()
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	r.size = Vector2(1600, 620)
	r.position = Vector2(-160, -40)
	r.material = materiale(NEBULOSA, {"rumore": rumore(), "tinta": tinta})
	return r


# LA FORMA DELLE FRATTURE (shaders/proiezione_lenti, "stile"). Bru: «dobbiamo
# lavorare sulle fratture ancora non mi piace come si vedono». Finche' non
# sceglie, le proposte stanno qui (proiezione.fratture in data/stile.json; per
# gli scatti FORMA_FRATTURE): "lente" quella di prima, "strappo", "crepa",
# "varco", "gorgo". Quelle nuove sono piu' grandi: piccole non si leggevano
const FORME_FRATTURA := {"lente": [0, 1.0], "strappo": [1, 1.35], "crepa": [2, 1.45], "varco": [3, 1.3],
		"gorgo": [4, 1.35]}
static var forma_fratture := ""


static func forma_delle_fratture() -> Array:
	if forma_fratture == "":
		forma_fratture = String(dati().get("fratture", "lente"))
	return FORME_FRATTURA.get(forma_fratture, FORME_FRATTURA["lente"])
