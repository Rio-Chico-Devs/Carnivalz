class_name StatiCombattimento
extends RefCounted

# COSA data/stati.json FA ADDOSSO A UN COMBATTENTE.
#
# Gli otto status - Terrore, Fiamme, Tossina, Sonno, Maledizione, Rabbia,
# Provocato, Frastornato - piu' Rapidita'/Lentezza e la combustione dei nemici
# che bruciano. Metterli, farli scadere, farli mordere a inizio turno.
#
# PERCHE' QUESTO PEZZO E NON UN ALTRO. Combattimento.gd e' un file da
# quattromilaseicento righe con quattordici mestieri dentro, e la tentazione e'
# di spostare il blocco che da' piu' fastidio a leggersi. Ho misurato invece
# quanto costa staccare ognuno: quante funzioni del motore continuerebbe a
# chiamare da fuori. Le abilita' - il pezzo che avevo in mente - ne chiamano
# venticinque e toccano sette variabili del nodo: spostarle voleva dire
# riscrivere quattrocento righe mettendo "scontro." davanti a ogni riga e
# perdere il controllo dei tipi su tutte, senza guadagnare un modulo. Questo
# blocco ne chiama SEI, e quattro di quelle sei servono solo a dire una frase.
#
# Ed e' un mestiere solo, con un confine naturale: qui dentro non si decide chi
# attacca chi, non si calcola un danno, non si tocca la plancia. Si legge
# stati.json e si applica. Il conto alla rovescia della Maledizione, il tiro di
# risveglio del Sonno, il danno a quota di vita massima di Fiamme e Tossina,
# la resistenza dichiarata nei dati ("immune", "ipersensibile", "invertito"):
# tutto quello che prima era sparso in mezzo al motore, adesso sta qui.
#
# bersagli_ammessi sta qui e non fra i bersagli: e' lo stato "provocato" che
# restringe l'elenco a uno solo, quindi e' una conseguenza di uno status, non
# una regola di mira.

var scontro                    # il nodo Combattimento: gli stati sono sue cose

func _init(nodo_scontro) -> void:
	scontro = nodo_scontro

# --- combustione: alcuni nemici bruciano a ogni loro turno (danno, a volte
# anche un bonus attacco che cresce turno dopo turno). Puo' essere attiva
# fin dall'inizio (nessun "attiva_da_studio" nei dati) o innescarsi dopo
# essere stato studiato un certo numero di volte.

func verifica_innesco_combustione(bersaglio: Dictionary) -> void:
	var comb: Dictionary = bersaglio.combustione
	if comb.is_empty() or bersaglio.in_fiamme or not comb.has("attiva_da_studio"):
		return
	if bersaglio.volte_studiato >= int(comb["attiva_da_studio"]):
		bersaglio.in_fiamme = true
		scontro.scrivi_forte(String(comb.get("testo_innesco", "Qualcosa in lui prende fuoco.")))

func applica_combustione(combattente: Dictionary) -> void:
	var comb: Dictionary = combattente.combustione
	var danno := int(comb.get("danno_per_turno", 1))
	combattente.hp = maxi(combattente.hp - danno, 0)
	if comb.has("bonus_attacco"):
		combattente.attacco += int(comb["bonus_attacco"])
	scontro.scrivi_con_colpo("[i]%s[/i]" % String(comb.get("testo_turno", "Brucia ancora un po'.")),
			combattente, danno, String(comb.get("elemento", "fuoco")))
	if combattente.hp <= 0:
		scontro._su_ko(combattente)

# --- stati generici (data/stati.json): veleno, sonno,
# GLI OTTO STATUS: Terrore, Fiamme, Tossina, Sonno, Maledizione, Rabbia,
# Provocato, Frastornato. Piu' Rapidita'/Lentezza, che non sono status subiti
# ma modificatori di velocita' e servono alle armi. Ogni personaggio puo' dichiarare nei dati una chiave
# "resistenze" (es. {"stress": "invertito", "oscuro": "ipersensibile"}):
# "immune" annulla lo stato, "ipersensibile" lo amplifica, "invertito" (solo
# per stress) ne capovolge l'effetto. Assente = "normale".

func frase_di_stato(chi: Dictionary, testo: String) -> String:
	# DOVE VA IL NOME LO DICE IL TESTO, con un %s. Senza %s la frase esce
	# esattamente come e' scritta.
	#
	# Prima non era cosi', e non era nemmeno sbagliato in un modo solo: la
	# stessa chiave "testo_fine" veniva stampata col nome davanti per il Sonno,
	# senza nome per le Fiamme, e "testo_turno" usciva "Nome: frase" per un dot
	# e "Nome frase" per il Sonno. Tre significati per la stessa chiave, e
	# leggendo stati.json non c'era modo di sapere quale ti sarebbe toccato:
	# scrivevi "Le fiamme si spengono" e ti ritrovavi "Marco Le fiamme si
	# spengono".
	#
	# E' la stessa convenzione che le abilita' usano da sempre in abilita.json,
	# quindi non e' una regola nuova da imparare: e' quella che c'era gia',
	# applicata anche qui.
	if testo.count("%s") == 0:
		return testo
	return testo % String(chi.get("nome", ""))

func applica_stato(bersaglio: Dictionary, id_stato: String, valore := 1) -> void:
	var resistenza := RegoleCombattimento.resistenza_di(bersaglio, id_stato)
	if resistenza == "immune":
		return
	if bersaglio.giocatore and String(bersaglio.get("scudo_stato", "")) != "":
		# l'accessorio addosso a QUESTO personaggio respinge il primo stato che
		# subisce, e lo immunizza da quello stesso stato per il resto dello
		# scontro; si consuma qui, una volta sola, e protegge solo lui
		var id_scudo := String(bersaglio.scudo_stato)
		bersaglio.scudo_stato = ""
		bersaglio.immunita_temporanea.append(id_stato)
		var nome_accessorio := String(GameState.dati_oggetto(id_scudo).get("nome", "Il tuo accessorio"))
		var nome_stato := String(GameState.stati.get(id_stato, {}).get("nome", id_stato))
		scontro.scrivi_forte("%s si spezza respingendo %s: per il resto dello scontro %s ne sarà immune."
				% [nome_accessorio, nome_stato, bersaglio.nome])
		GameState.consuma_equipaggiato(id_scudo)
		return
	if bersaglio.giocatore and bersaglio.id == GameState.id_protagonista:
		GameState.registra_stato_subito(id_stato)
	var amplificato := resistenza == "ipersensibile"
	var info_stato: Dictionary = GameState.stati.get(id_stato, {})
	var tipo := String(info_stato.get("tipo", ""))
	match tipo:
		"riserva":
			# LA MALEDIZIONE NON E' PIU' UN CONTO ALLA ROVESCIA. Bru: "conto alla
			# rovescia basato sulla resistenza. Parte da 10, un attacco che da' 3
			# punti ti porta a 7. A zero vai KO e non puoi essere rianimato con
			# oggetti fino alla fine del combattimento".
			#
			# Prima scendeva DA SOLA di un punto a turno: bastava aspettare e
			# morivi, e i colpi maledetti erano decorazione. Adesso la riserva sta
			# ferma finche' qualcuno non la morde: e' l'attacco che la consuma,
			# e senza attacchi non succede niente.
			var attivo: Dictionary = bersaglio.stati_attivi.get(id_stato, {})
			var punti := maxi(int(valore), 1)
			if amplificato:
				punti *= 2
			if attivo.is_empty():
				# la resistenza alza il tetto, non riduce i punti: chi resiste ne
				# incassa altrettanti ma parte da piu' in alto
				var iniziale := int(info_stato.get("riserva_iniziale", 10)) \
						+ int(bersaglio.get("resistenza_maledizione", 0))
				attivo = {"riserva": iniziale, "iniziale": iniziale}
				bersaglio.stati_attivi[id_stato] = attivo
				scontro.scrivi_forte(frase_di_stato(bersaglio,
						String(info_stato.get("testo_applicazione", "%s viene maledetto."))))
			attivo.riserva = maxi(int(attivo.riserva) - punti, 0)
			scontro.scrivi("[i]%s (%d/%d)[/i]" % [frase_di_stato(bersaglio,
					String(info_stato.get("testo_consumo", "La maledizione morde."))),
					int(attivo.riserva), int(attivo.iniziale)])
			if int(attivo.riserva) <= 0:
				scontro.scrivi_forte("La maledizione si compie: %s non resiste oltre." % bersaglio.nome)
				bersaglio.hp = 0
				if bool(info_stato.get("ko_non_rianimabile", false)):
					# e resta giu'. Nessun oggetto lo rimette in piedi fino alla
					# fine dello scontro: e' quello che rende la maledizione una
					# minaccia invece di un danno con un nome lungo
					bersaglio.non_rianimabile = true
				scontro.aggiorna_scheda(bersaglio)
				scontro._su_ko(bersaglio)
				return
		"sonno":
			# Bru: "immobile per massimo 3 turni... piu' subisci attacchi piu'
			# probabilita' hai di svegliarti". I colpi incassati mentre dorme si
			# contano qui sotto (vedi risolvi_stati_a_inizio_turno) e alzano il
			# tiro del risveglio: scuotere chi dorme funziona
			bersaglio.stati_attivi[id_stato] = {
				"turni_rimasti": int(info_stato.get("durata_massima", 3)) + (1 if amplificato else 0),
				"colpi_nel_sonno": 0}
			scontro.scrivi("[i]%s[/i]" % frase_di_stato(bersaglio,
					String(info_stato.get("testo_applicazione", "%s cade addormentato."))))
		"forza_attacco", "frastornato", "provocato":
			var durata := durata_dichiarata(info_stato)
			if amplificato:
				durata += 1
			var stato_nuovo := {"turni_rimasti": durata}
			if tipo == "provocato":
				# chi ti ha provocato: senza questo "solo lui" non vuol dire niente
				stato_nuovo["provocatore"] = String(bersaglio.get("id_provocatore", ""))
			bersaglio.stati_attivi[id_stato] = stato_nuovo
			scontro.scrivi("[i]%s[/i]" % frase_di_stato(bersaglio,
					String(info_stato.get("testo_applicazione", "%s subisce uno stato."))))
		"dot":
			# FIAMME E TOSSINA SONO LO STESSO MECCANISMO CON DUE TARATURE, non due
			# meccanismi. Il danno e' una quota della vita massima e non un numero
			# fisso: un 5 fisso e' letale al livello 1 e invisibile al 130.
			# Durata 0 = fino a fine scontro (la Tossina: "guarisci solo a fine
			# combattimento o se ti curi").
			var quota := float(info_stato.get("quota_vita_massima", 0.05))
			if amplificato:
				quota *= 2.0
			var danno_turno := maxi(int(round(int(bersaglio.get("hp_max", 1)) * quota)), 1)
			bersaglio.stati_attivi[id_stato] = {
				"danno": danno_turno,
				"turni_rimasti": durata_dichiarata(info_stato)}
			scontro.scrivi("[i]%s[/i]" % frase_di_stato(bersaglio,
					String(info_stato.get("testo_applicazione", "%s subisce uno stato."))))
		"velocita":
			bersaglio.stati_attivi[id_stato] = {"valore": int(info_stato.get("valore", 0))}
		"terrore":
			# Bru: "indebolimento temporaneo del personaggio e impossibilita' di
			# fare critico". Prima faceva solo stress e legame - due numeri fuori
			# dallo scontro - e in campo non cambiava niente
			var durata_terrore := durata_dichiarata(info_stato)
			if amplificato:
				durata_terrore += 1
			bersaglio.stati_attivi[id_stato] = {"turni_rimasti": durata_terrore}
			var incremento_stress := int(GameState.regole.get("terrore_stress_incremento", 40))
			var decremento_legame := int(GameState.regole.get("terrore_legame_decremento", -15))
			if amplificato:
				incremento_stress *= 2
				decremento_legame *= 2
			scontro.aggiungi_stress(bersaglio, incremento_stress)
			GameState.modifica_legame(decremento_legame)
			scontro.scrivi_forte(frase_di_stato(bersaglio,
					String(info_stato.get("testo_applicazione", "%s è paralizzato dal terrore."))))
	scontro.aggiorna_scheda(bersaglio)

func bersagli_ammessi(chi: Dictionary, candidati: Array[Dictionary]) -> Array[Dictionary]:
	# se qualcuno ti ha provocato, l'elenco si riduce a lui solo. Se e' caduto
	# nel frattempo torni libero: restare inchiodato a un morto bloccherebbe il
	# turno per tre battute
	var obbligato := RegoleCombattimento.bersaglio_obbligato(chi)
	if obbligato == "":
		return candidati
	var ristretto: Array[Dictionary] = []
	for c in candidati:
		if String(c.get("id", "")) == obbligato:
			ristretto.append(c)
	return ristretto if not ristretto.is_empty() else candidati

static func durata_dichiarata(info_stato: Dictionary) -> int:
	# uno stato dichiara "durata" fissa, oppure "durata_minima"/"durata_massima"
	# e la si tira. Zero vuol dire fino alla fine dello scontro
	if info_stato.has("durata"):
		return int(info_stato["durata"])
	var minimo := int(info_stato.get("durata_minima", 1))
	var massimo := int(info_stato.get("durata_massima", minimo))
	return GameState.rng.randi_range(minimo, maxi(massimo, minimo))

func risolvi_stati_a_inizio_turno(combattente: Dictionary) -> bool:
	# esegue countdown/salta-turno/dot a inizio turno; ritorna true se il
	# turno va saltato (Sonno) o se il personaggio muore prima di poter agire
	# (Fiamme e Tossina lo consumano, la Maledizione arriva a zero)
	var salta := false
	for id_stato in combattente.stati_attivi.keys().duplicate():
		var attivo: Dictionary = combattente.stati_attivi[id_stato]
		var info_stato: Dictionary = GameState.stati.get(id_stato, {})
		match String(info_stato.get("tipo", "")):
			"riserva":
				# non scende da sola: la consumano i colpi (vedi applica_stato).
				# Qui non c'e' niente da fare, ed e' voluto
				pass
			"sonno":
				# IL RISVEGLIO E' UN TIRO, e i colpi incassati lo alzano. Bru:
				# "piu' subisci attacchi piu' probabilita' hai di svegliarti".
				# Si tira PRIMA di saltare il turno: chi si sveglia adesso agisce
				# subito, invece di perdere anche la battuta del risveglio
				var soglia := float(info_stato.get("risveglio_base", 0.25)) \
						+ int(attivo.get("colpi_nel_sonno", 0)) * float(info_stato.get("risveglio_per_colpo", 0.30))
				if GameState.rng.randf() < soglia:
					combattente.stati_attivi.erase(id_stato)
					scontro.scrivi("[i]%s[/i]" % frase_di_stato(combattente,
							String(info_stato.get("testo_fine", "%s si sveglia."))))
					continue
				scontro.scrivi("[i]%s[/i]" % frase_di_stato(combattente,
						String(info_stato.get("testo_turno", "%s dorme."))))
				salta = true
				attivo.turni_rimasti = int(attivo.turni_rimasti) - 1
				if int(attivo.turni_rimasti) <= 0:
					combattente.stati_attivi.erase(id_stato)
					scontro.scrivi("[i]%s[/i]" % frase_di_stato(combattente,
							String(info_stato.get("testo_fine", "%s si sveglia."))))
			"forza_attacco", "frastornato", "provocato", "terrore":
				attivo.turni_rimasti = int(attivo.turni_rimasti) - 1
				if int(attivo.turni_rimasti) <= 0:
					combattente.stati_attivi.erase(id_stato)
					if info_stato.has("testo_fine"):
						scontro.scrivi("[i]%s[/i]" % frase_di_stato(combattente, String(info_stato["testo_fine"])))
			"dot":
				var danno := int(attivo.get("danno", 1))
				combattente.hp = maxi(combattente.hp - danno, 0)
				scontro.scrivi_con_colpo("[i]%s[/i]" % frase_di_stato(combattente,
						String(info_stato.get("testo_turno", "Il male si fa sentire ancora."))),
						combattente, danno, String(info_stato.get("elemento", "")))
				if combattente.hp <= 0:
					scontro._su_ko(combattente)
					return true
				# durata 0 = non scade: la Tossina resta finche' non ti curi o
				# finche' lo scontro non finisce
				if int(attivo.get("turni_rimasti", 0)) > 0:
					attivo.turni_rimasti = int(attivo.turni_rimasti) - 1
					if int(attivo.turni_rimasti) <= 0:
						combattente.stati_attivi.erase(id_stato)
						if info_stato.has("testo_fine"):
							scontro.scrivi("[i]%s[/i]" % frase_di_stato(combattente, String(info_stato["testo_fine"])))
	return salta
