extends Node

@onready var balao_fala = get_node_or_null("../CanvasLayer/BalaoFala")
var dialogue_box_ja_foi_mostrado = false

func _ready():
	print("Controlador do Mapa carregado!")
	
	# Aguardar alguns frames para garantir que o GameManager está pronto
	await get_tree().process_frame
	await get_tree().process_frame
	
	# Tentar encontrar o balão novamente se não encontrou na primeira vez
	if not balao_fala:
		balao_fala = get_node_or_null("../CanvasLayer/BalaoFala")
	
	# ⭐⭐ Verificar se o DialogueBox já foi mostrado nesta sessão (usar GameManager)
	var dialogue_box_ja_mostrado = false
	
	# Tentar acessar o GameManager de diferentes formas
	if Engine.has_singleton("GameManager"):
		dialogue_box_ja_mostrado = GameManager.dialogue_box_mostrado
		print("📊 GameManager encontrado! dialogue_box_mostrado = ", dialogue_box_ja_mostrado)
	else:
		# Tentar acessar diretamente como autoload
		var gm = get_node_or_null("/root/GameManager")
		if gm:
			dialogue_box_ja_mostrado = gm.dialogue_box_mostrado
			print("📊 GameManager encontrado via /root! dialogue_box_mostrado = ", dialogue_box_ja_mostrado)
		else:
			print("⚠️ GameManager não encontrado. Assumindo que DialogueBox não foi mostrado.")
	
	# Garantir que o balão seja escondido também através de busca direta na árvore
	_verificar_e_esconder_balao_se_necessario(dialogue_box_ja_mostrado)
	
	if balao_fala:
		if dialogue_box_ja_mostrado:
			# Se o DialogueBox já foi mostrado, esconder o balão permanentemente
			balao_fala.visible = false
			balao_fala.hide()
			print("✅ Balão escondido: DialogueBox já foi mostrado nesta sessão")
		else:
			# Se ainda não foi mostrado, mostrar o balão
			balao_fala.visible = true
			balao_fala.show()
			print("✅ Balão visível: DialogueBox ainda não foi mostrado")
	else:
		print("❌ ERRO: Balão de fala não encontrado!")
	
	# Salvar o estado localmente
	dialogue_box_ja_foi_mostrado = dialogue_box_ja_mostrado
	
	# Verificar novamente após mais um frame (caso o balão tenha sido recriado)
	await get_tree().process_frame
	_verificar_e_esconder_balao_se_necessario(dialogue_box_ja_mostrado)
	
	# Verificar periodicamente para garantir que o balão fique escondido
	_check_balao_periodicamente()

func _check_balao_periodicamente():
	# Verificar periodicamente enquanto a cena está ativa
	while is_inside_tree():
		await get_tree().create_timer(0.5).timeout
		if dialogue_box_ja_foi_mostrado and balao_fala:
			if balao_fala.visible:
				balao_fala.visible = false
				balao_fala.hide()
				print("🔒 Balão forçado a esconder (verificação periódica)")

func _verificar_e_esconder_balao_se_necessario(esconder: bool):
	if not esconder:
		return
	
	# Buscar o balão em qualquer lugar da cena
	var root = get_tree().current_scene
	if root:
		var balao = root.get_node_or_null("CanvasLayer/BalaoFala")
		if balao:
			balao.visible = false
			balao.hide()
			print("✅ Balão escondido via verificação adicional!")
		
		# Procurar em todos os CanvasLayers
		for canvas in root.find_children("*", "CanvasLayer", true, false):
			balao = canvas.get_node_or_null("BalaoFala")
			if balao:
				balao.visible = false
				balao.hide()
				print("✅ Balão encontrado e escondido em CanvasLayer (verificação adicional)!")

