extends Node

# SCRIVE I FILE DA MISURARE delle sagome della strada A (prove/SagomeA.gd):
#   art/interfaccia/statistiche/strada_a/<chiave>.svg   il disegno esatto, 480 x 480
#   art/interfaccia/statistiche/strada_a/<chiave>.png   lo stesso, nero su trasparente
#   docs/sagome_a.md                                    il canone e le misure di ognuna
#
#   ./prove/sagome_a.sh
#
# Una prova (prova_le_sagome_a_si_misurano) controlla che gli SVG sul disco
# siano quelli che il codice disegna adesso: se cambia una sagoma e non si
# rigenerano, la suite lo dice.

const A := preload("res://prove/SagomeA.gd")
const CARTELLA := "res://art/interfaccia/statistiche/strada_a"
const RAPPORTO := "res://docs/sagome_a.md"


func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(CARTELLA))
	for chiave: String in A.CHIAVI:
		var file := FileAccess.open(CARTELLA.path_join(chiave + ".svg"), FileAccess.WRITE)
		file.store_string(A.svg(chiave))
		file.close()
	var rapporto := FileAccess.open(RAPPORTO, FileAccess.WRITE)
	rapporto.store_string(scrivi_rapporto())
	rapporto.close()
	print("scritti %d SVG e %s" % [A.CHIAVI.size(), RAPPORTO])
	if DisplayServer.get_name() == "headless":
		print("senza finestra i PNG non si disegnano: lancia con xvfb-run (prove/sagome_a.sh)")
		get_tree().quit()
		return
	for chiave: String in A.CHIAVI:
		await fotografa(chiave)
	print("scritti %d PNG in %s" % [A.CHIAVI.size(), CARTELLA])
	get_tree().quit()


func fotografa(chiave: String) -> void:
	var lato := int(A.LATO) * A.PIXEL_PER_MODULO
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
		A.disegna(tela, chiave, Vector2(lato, lato) * 0.5, float(lato), Color.BLACK, Color.WHITE))
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


# --- il rapporto ---------------------------------------------------------------------------

func px(v: float) -> String:
	return A.numero(v * A.PIXEL_PER_MODULO)


func scrivi_rapporto() -> String:
	var r: Array[String] = []
	r.append("# Le sagome della strada A: il canone e le misure (generato, non scrivere qui a mano)")
	r.append("")
	r.append("Rigenera con `./prove/sagome_a.sh`. Il codice è `prove/SagomeA.gd`; i file da misurare")
	r.append("sono in `art/interfaccia/statistiche/strada_a/`: un SVG e un PNG per sagoma, 480 × 480,")
	r.append("nero su trasparente. Nell'SVG ogni sagoma è un percorso solo con `fill-rule=\"evenodd\"`.")
	r.append("")
	r.append("## Il canone")
	r.append("")
	r.append("| | moduli | pixel a 480 |")
	r.append("|---|---|---|")
	r.append("| la griglia | %s × %s | %s × %s |" % [A.numero(A.LATO), A.numero(A.LATO), px(A.LATO), px(A.LATO)])
	r.append("| il modulo | 1 | %d |" % A.PIXEL_PER_MODULO)
	r.append("| il margine (l'area viva va da 1 a 19) | %s | %s |" % [A.numero(A.MARGINE), px(A.MARGINE)])
	r.append("| **C**, il taglio: ogni vuoto, ogni distacco fra due parti | %s | %s |" % [A.numero(A.C), px(A.C)])
	r.append("| **T**, il tratto: ogni parte sottile, e quello che separa un taglio dal bordo | %s | %s |"
			% [A.numero(A.T), px(A.T)])
	r.append("")
	r.append("- **Gli angoli dei lati:** 0°, 45°, 90°, 135°; e solo per il fulmine e la brace la pendenza")
	r.append("  2 : 1 (63,43° e 116,57°).")
	r.append("- **Dritte:** niente piega del corsivo. La piega deformerebbe gli spessori: a 45° un tratto")
	r.append("  verrebbe più grosso del 10% e quello opposto più sottile del 10%.")
	r.append("- **Le coordinate** dei pieni stanno sul mezzo modulo (12 pixel). Non ci stanno quelle girate")
	r.append("  (la spada è costruita dritta e girata di 45°, i raggi corti dell'aura) e quelle fatte")
	r.append("  rientrando un bordo di T o di C: lì comanda la distanza.")
	r.append("- **Gli anelli:** livello 0 il pieno, 1 i tagli dentro il pieno, 2 i pieni dentro i tagli,")
	r.append("  3 i fori dentro quelli.")
	r.append("- **La pienezza** è l'inchiostro sul quadrato dell'area viva (18 × 18 moduli).")
	r.append("")
	var tutte: Array[float] = []
	for chiave: String in A.CHIAVI:
		tutte.append(A.pienezza(chiave))
	var media := 0.0
	for v in tutte:
		media += v
	media /= tutte.size()
	r.append("## Il peso, tutte insieme")
	r.append("")
	r.append("| sagoma | pienezza | dalla media | ingombro (moduli) |")
	r.append("|---|---|---|---|")
	for chiave: String in A.CHIAVI:
		var b := A.ingombro(chiave)
		r.append("| %s | %.3f | %+.1f%% | %s × %s |" % [A.NOMI[chiave], A.pienezza(chiave),
				(A.pienezza(chiave) / media - 1.0) * 100.0, A.numero(b.size.x), A.numero(b.size.y)])
	r.append("")
	r.append("Media %.3f." % media)
	r.append("")
	for chiave: String in A.CHIAVI:
		r.append_array(scheda(chiave))
	return "\n".join(r) + "\n"


func scheda(chiave: String) -> Array[String]:
	var r: Array[String] = []
	var b := A.ingombro(chiave)
	r.append("## %s (`%s`)" % [A.NOMI[chiave], chiave])
	r.append("")
	r.append("- **File:** `art/interfaccia/statistiche/strada_a/%s.svg` e `.png`" % chiave)
	r.append("- **Ingombro:** da %s,%s a %s,%s moduli (%s × %s pixel a 480)" % [A.numero(b.position.x),
			A.numero(b.position.y), A.numero(b.end.x), A.numero(b.end.y), px(b.size.x), px(b.size.y)])
	r.append("- **Pienezza:** %.3f (inchiostro %s moduli quadrati)" % [A.pienezza(chiave), A.numero(A.inchiostro(chiave))])
	var angoli: Array[String] = []
	for g in A.direzioni(chiave):
		angoli.append("%s°" % A.numero(g))
	r.append("- **Direzioni dei lati:** " + ", ".join(angoli))
	var parti: Array = A.anelli(chiave)["parti"]
	if not parti.is_empty():
		r.append("- **Le parti, come sono costruite:**")
		for p: Array in parti:
			r.append("  - %s: %s moduli (%s px)" % [p[0], A.numero(float(p[1])), px(float(p[1]))])
	var misure := A.spessori(chiave)
	if not misure.is_empty():
		r.append("- **Gli spessori, misurati sul disegno finito** (la distanza minima fra i bordi):")
		var viste: Dictionary = {}
		for m: Array in misure:
			var riga := "%s: %s moduli (%s px)" % [m[0], A.numero(float(m[1])), px(float(m[1]))]
			viste[riga] = int(viste.get(riga, 0)) + 1
		for riga: String in viste:
			r.append("  - %s%s" % [riga, (" — %d volte" % viste[riga]) if int(viste[riga]) > 1 else ""])
	r.append("")
	r.append("I lati, anello per anello, in pixel a 480:")
	r.append("")
	r.append("| anello | lato | da | a | lungo | direzione |")
	r.append("|---|---|---|---|---|---|")
	var a := A.anelli(chiave)
	var nomi := ["pieno", "taglio", "pieno dentro", "foro"]
	for livello in 4:
		var lista: Array = a[str(livello)]
		for n in lista.size():
			var p: PackedVector2Array = lista[n]
			for i in p.size():
				var q0 := p[i]
				var q1 := p[(i + 1) % p.size()]
				var d := q1 - q0
				var g := fposmod(rad_to_deg(atan2(d.y, d.x)), 180.0)
				if absf(g - 180.0) < 0.005:
					g = 0.0
				r.append("| %s %d | %d | %s, %s | %s, %s | %s | %s° |" % [nomi[livello], n + 1, i + 1, px(q0.x), px(q0.y),
						px(q1.x), px(q1.y), px(d.length()), A.numero(snappedf(g, 0.01))])
	r.append("")
	return r
