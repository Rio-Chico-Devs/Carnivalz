class_name TeleVetro
extends Control
# UN VETRO ROTTO A SCHERMO (VetroRotto.gd), sopra i pugni della raffica.
#
# Quattro tele una sopra l'altra, perche' un vetro rotto e' quattro cose che si
# vedono in quattro modi diversi:
#   lastre   i pezzi fermi, che mostrano quello che c'e' dietro spostato: hanno
#            lo shader che legge lo schermo (vetro_lastre.gdshader), con l'onda
#            dell'impatto che spinge in fuori
#   vetro    le crepe incise, i buchi, il vetro schiacciato, il rosso ai bordi
#   schegge  i pezzi che saltano: anche loro guardano dietro, quindi lo shader
#   luce     quello che si accende e si somma a quello che c'e' sotto: le crepe
#            che bruciano, il bagliore, l'onda, il lampo, le scintille
#
# Una per vetro e non una per tutti: l'onda e' dello shader, e due vetri
# vicini nel tempo hanno due onde diverse. Lo shader che legge lo schermo costa
# una copia dello schermo: c'e' solo mentre c'e' il vetro.

const LASTRE := preload("res://shaders/vetro_lastre.gdshader")
const FORZA_ONDA := 7.0   # di quanti pixel l'onda spinge in fuori quello che c'e' dietro

var vetro: VetroRotto
var eta := 0.0
var ridotto := false
var lastre: Control
var crepe: Control
var schegge: Control
var luce: Control


func _init(di: VetroRotto) -> void:
	vetro = di
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	lastre = tela(guarda_dietro(), func() -> void: vetro.disegna_lastre(lastre, eta, ridotto))
	crepe = tela(null, func() -> void: vetro.disegna(crepe, eta, ridotto))
	schegge = tela(guarda_dietro(), func() -> void: vetro.disegna_schegge(schegge, eta, ridotto))
	var somma := CanvasItemMaterial.new()
	somma.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	luce = tela(somma, func() -> void: vetro.disegna_luce(luce, eta, ridotto))


func guarda_dietro() -> ShaderMaterial:
	var materiale := ShaderMaterial.new()
	materiale.shader = LASTRE
	materiale.set_shader_parameter("impatto", vetro.impatto)
	return materiale


func tela(materiale: Material, disegno: Callable) -> Control:
	var fatta := Control.new()
	fatta.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fatta.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fatta.material = materiale
	fatta.draw.connect(disegno)
	add_child(fatta)
	return fatta


func misura(quanto: Vector2) -> void:
	# lo shader legge solo dentro il piano: gli si dice quanto e' grande
	for materiale in [lastre.material, schegge.material]:
		(materiale as ShaderMaterial).set_shader_parameter("misura", quanto)


func mostra(adesso: float, meno_movimento: bool) -> void:
	eta = adesso
	ridotto = meno_movimento
	var onda := vetro.raggio_onda(eta, ridotto)
	var materiale := lastre.material as ShaderMaterial
	materiale.set_shader_parameter("onda_raggio", onda)
	materiale.set_shader_parameter("onda_forza", FORZA_ONDA * (1.0 - maxf(VetroRotto.onda(eta, ridotto), 0.0)))
	materiale.set_shader_parameter("scomposta", 0.12 + 0.25 * VetroRotto.calore(eta, ridotto))
	for fatta in [lastre, crepe, schegge, luce]:
		(fatta as CanvasItem).queue_redraw()
