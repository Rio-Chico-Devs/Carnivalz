extends Node

# SCRIVE I FILE DELLE ICONE DELLE STATISTICHE (prove/IconeStatistiche.gd):
#   art/interfaccia/statistiche/proposta/<chiave>.svg   il disegno esatto, 480 x 480
#   art/interfaccia/statistiche/proposta/<chiave>.png   lo stesso, nero su trasparente
#   docs/icone_statistiche.md                           le idee, il peso, gli ingombri
#
#   ./prove/icone.sh
#
# Sono una proposta: il gioco legge art/interfaccia/statistiche/<chiave>.png
# (bianche su trasparente), non questa cartella. Una prova (prova_le_icone_si_reggono) controlla che gli
# SVG sul disco siano quelli che il codice disegna adesso.

const I := preload("res://prove/IconeStatistiche.gd")
const CARTELLA := "res://art/interfaccia/statistiche/proposta"
const RAPPORTO := "res://docs/icone_statistiche.md"


func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(CARTELLA))
	for chiave: String in I.CHIAVI:
		var file := FileAccess.open(CARTELLA.path_join(chiave + ".svg"), FileAccess.WRITE)
		file.store_string(I.svg(chiave))
		file.close()
	var rapporto := FileAccess.open(RAPPORTO, FileAccess.WRITE)
	rapporto.store_string(scrivi_rapporto())
	rapporto.close()
	print("scritti %d SVG e %s" % [I.CHIAVI.size(), RAPPORTO])
	if DisplayServer.get_name() == "headless":
		print("senza finestra i PNG non si disegnano: lancia con xvfb-run (prove/icone.sh)")
		get_tree().quit()
		return
	for chiave: String in I.CHIAVI:
		await fotografa(chiave)
	print("scritti %d PNG in %s" % [I.CHIAVI.size(), CARTELLA])
	get_tree().quit()


func fotografa(chiave: String) -> void:
	var lato := int(I.LATO * I.PIXEL)
	# nero su bianco, poi il bianco diventa trasparente: i tagli sono buchi veri, e
	# i bordi sfumati restano sfumati (la trasparenza e' quanto il pixel non e' bianco)
	var vista := SubViewport.new()
	vista.size = Vector2i(lato, lato)
	vista.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(vista)
	var tela := Control.new()
	tela.size = Vector2(lato, lato)
	tela.draw.connect(func() -> void:
		tela.draw_rect(Rect2(Vector2.ZERO, tela.size), Color.WHITE)
		I.disegna(tela, chiave, Vector2(lato, lato) * 0.5, float(lato), Color.BLACK, Color.WHITE))
	vista.add_child(tela)
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	var foto := vista.get_texture().get_image()
	foto.convert(Image.FORMAT_RGBA8)
	for y in foto.get_height():
		for x in foto.get_width():
			foto.set_pixel(x, y, Color(0, 0, 0, 1.0 - foto.get_pixel(x, y).r))
	foto.save_png(ProjectSettings.globalize_path(CARTELLA.path_join(chiave + ".png")))
	vista.queue_free()


func scrivi_rapporto() -> String:
	var r: Array[String] = []
	r.append("# Le icone delle statistiche (generato, non scrivere qui a mano)")
	r.append("")
	r.append("Rigenera con `./prove/icone.sh`. Il codice è `prove/IconeStatistiche.gd`; i file sono in")
	r.append("`art/interfaccia/statistiche/proposta/`: un SVG e un PNG per icona, 480 × 480, nero su")
	r.append("trasparente. Nell'SVG ogni icona è un percorso solo con `fill-rule=\"evenodd\"`. Sono una")
	r.append("proposta: il gioco legge `art/interfaccia/statistiche/<chiave>.png`, bianche su trasparente.")
	r.append("")
	r.append("Ogni icona è due figure che ne fanno una terza. Il disegno sta su una griglia di 100")
	r.append("(4,8 pixel per unità nei file), area viva da 4 a 96; i tagli e i distacchi sono C = 5,")
	r.append("i bordi T = 10. La pienezza è l'inchiostro sul quadrato di 100, contata su una griglia")
	r.append("di punti ogni mezza unità.")
	r.append("")
	r.append("I file sono il disegno a misura piena. Sotto i 32 pixel il gioco le disegna coi tagli più")
	r.append("larghi (mai sotto 1,4 pixel, a mezze unità), e timbrate l'ombra è la sagoma chiusa:")
	r.append("i vuoti fra un pezzo e l'altro restano del colore del fondo.")
	r.append("")
	var media := 0.0
	var raggi := 0.0
	for chiave: String in I.CHIAVI:
		media += I.pienezza(chiave)
		raggi += I.raggio_inerzia(chiave)
	media /= I.CHIAVI.size()
	raggi /= I.CHIAVI.size()
	r.append("Le correzioni ottiche si misurano (la foto «misure» delle proposte): la pienezza entro l'8%")
	r.append("dalla media, la grandezza (il raggio d'inerzia, quanto la massa è sparsa attorno al suo")
	r.append("centro) entro il 10%, il centro visivo (a metà fra il centro dell'ingombro e il baricentro)")
	r.append("entro 4 unità dal centro. E niente fili: due contorni o si toccano o stanno ad almeno un")
	r.append("taglio.")
	r.append("")
	r.append("| icona | le due figure | pienezza | dalla media | raggio | dalla media | centro visivo | ingombro (unità) |")
	r.append("|---|---|---|---|---|---|---|---|")
	for chiave: String in I.CHIAVI:
		var idea: Array = I.IDEE[chiave]
		var b := I.ingombro(chiave)
		var v := I.centro_visivo(chiave) - I.CENTRO
		r.append("| %s | %s + %s | %.3f | %+.1f%% | %.1f | %+.1f%% | %+.1f, %+.1f | da %s,%s a %s,%s |" % [I.NOMI[chiave],
				idea[0], idea[1], I.pienezza(chiave), (I.pienezza(chiave) / media - 1.0) * 100.0, I.raggio_inerzia(chiave),
				(I.raggio_inerzia(chiave) / raggi - 1.0) * 100.0, v.x, v.y, String.num(b.position.x, 1),
				String.num(b.position.y, 1), String.num(b.end.x, 1), String.num(b.end.y, 1)])
	r.append("")
	r.append("Medie: pienezza %.3f, raggio %.1f." % [media, raggi])
	r.append("")
	for chiave: String in I.CHIAVI:
		var idea: Array = I.IDEE[chiave]
		r.append("- **%s** (`%s`): %s e %s. %s" % [I.NOMI[chiave], chiave, idea[0], idea[1], idea[2]])
	r.append("")
	r.append("## Le distanze fra i contorni")
	r.append("")
	r.append("Per ogni icona, la distanza più corta fra due contorni che non si toccano (in unità; il")
	r.append("taglio C è %s). A misura piena è sempre almeno C; piccola (taglio %s a 16 pixel, %s chiara" % [String.num(I.C),
			String.num(I.taglio_per(16.0)), String.num(I.taglio_a_colori(16.0, Color.WHITE, Color.BLACK))])
	r.append("su scuro) almeno tre quarti del taglio.")
	r.append("")
	r.append("| icona | a misura piena | piccola | piccola, chiara su scuro |")
	r.append("|---|---|---|---|")
	for chiave: String in I.CHIAVI:
		var celle: Array[String] = []
		for taglio: float in [I.C, I.taglio_per(16.0), I.taglio_a_colori(16.0, Color.WHITE, Color.BLACK)]:
			var minima := INF
			for d: Array in I.distacchi(chiave, taglio):
				if float(d[1]) > 0.05:
					minima = minf(minima, float(d[1]))
			celle.append("—" if minima == INF else String.num(minima, 2))
		r.append("| %s | %s |" % [I.NOMI[chiave], " | ".join(celle)])
	return "\n".join(r) + "\n"
