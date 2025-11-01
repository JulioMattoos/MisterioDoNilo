extends Node

@onready var balao_fala = get_node_or_null("../CanvasLayer/BalaoFala")
@onready var balao_fala2 = get_node_or_null("../CanvasLayer/BalaoFala2")
var dialogue_box_ja_foi_mostrado = false

func _ready():
	print("Controlador do Mapa carregado!")
	
	# Aguardar alguns frames para garantir que o GameManager está pronto
	await get_tree().process_frame
	await get_tree().process_frame
	
	# Tentar encontrar os balões novamente se não encontrou na primeira vez
	if not balao_fala:
		balao_fala = get_node_or_null("../CanvasLayer/BalaoFala")
	if not balao_fala2:
		balao_fala2 = get_node_or_null("../CanvasLayer/BalaoFala2")
	
	# ⭐⭐ Verificar se o DialogueBox já foi mostrado nesta sessão (usar GameManager)
	var dialogue_box_ja_mostrado = false
	var fase_1_completa = false
	var gm = get_node_or_null("/root/GameManager")
	
	if gm:
		dialogue_box_ja_mostrado = gm.dialogue_box_mostrado
		fase_1_completa = gm.fase_concluida(1)
		print("📊 GameManager encontrado!")
		print("   dialogue_box_mostrado = ", dialogue_box_ja_mostrado)
		print("   fase_1_completa = ", fase_1_completa)
		print("   Condição para mostrar balão 2: fase_1_completa=", fase_1_completa, " AND not dialogue_box_ja_mostrado=", not dialogue_box_ja_mostrado)
	else:
		print("⚠️ GameManager não encontrado. Assumindo que DialogueBox não foi mostrado.")
	
	# Garantir que o balão seja escondido também através de busca direta na árvore
	_verificar_e_esconder_balao_se_necessario(dialogue_box_ja_mostrado)
	
	# ⭐⭐ Gerenciar visibilidade do primeiro balão
	if balao_fala:
		if dialogue_box_ja_mostrado:
			# Se o DialogueBox já foi mostrado, esconder o balão permanentemente
			balao_fala.visible = false
			balao_fala.hide()
			print("✅ Balão 1 escondido: DialogueBox já foi mostrado nesta sessão")
		else:
			# Se ainda não foi mostrado, mostrar o balão
			balao_fala.visible = true
			balao_fala.show()
			print("✅ Balão 1 visível: DialogueBox ainda não foi mostrado")
	else:
		print("❌ ERRO: Balão de fala 1 não encontrado!")
	
	# ⭐⭐ Gerenciar visibilidade do segundo balão (só aparece após fase 1 concluída)
	if balao_fala2:
		print("🔍 Verificando condições para balão 2:")
		print("   fase_1_completa = ", fase_1_completa)
		print("   dialogue_box_ja_mostrado = ", dialogue_box_ja_mostrado)
		print("   Condição (fase_1_completa AND not dialogue_box_ja_mostrado) = ", fase_1_completa and not dialogue_box_ja_mostrado)
		
		# ⭐⭐ IMPORTANTE: Se fase 1 foi concluída, mostrar balão 2 sempre
		# Mas esconder se dialogue_box foi mostrado após concluir fase 1
		if fase_1_completa:
			# Se fase 1 foi concluída, mostrar balão 2
			# O balão só será escondido quando o DialogueBox aparecer novamente (ao interagir com Paser no novo local)
			balao_fala2.visible = true
			balao_fala2.show()
			balao_fala2.set_visible(true)
			print("✅ Balão 2 VISÍVEL: Fase 1 concluída!")
			print("   visible = ", balao_fala2.visible)
			print("   dialogue_box_ja_mostrado = ", dialogue_box_ja_mostrado, " (será escondido se DialogueBox aparecer)")
		else:
			# Esconder balão 2 se fase 1 ainda não foi concluída
			balao_fala2.visible = false
			balao_fala2.hide()
			print("✅ Balão 2 escondido: Fase 1 ainda não concluída")
	else:
		print("❌ ERRO: Balão de fala 2 não encontrado!")
		# Tentar buscar novamente
		balao_fala2 = get_node_or_null("../CanvasLayer/BalaoFala2")
		if balao_fala2:
			print("✅ Balão 2 encontrado via busca direta!")
			# Repetir lógica de visibilidade
			if fase_1_completa and not dialogue_box_ja_mostrado:
				balao_fala2.visible = true
				balao_fala2.show()
				print("✅ Balão 2 VISÍVEL (após busca): Fase 1 concluída!")
	
	# Salvar o estado localmente
	dialogue_box_ja_foi_mostrado = dialogue_box_ja_mostrado
	
	# Verificar novamente após mais um frame (caso o balão tenha sido recriado)
	await get_tree().process_frame
	_verificar_e_esconder_balao_se_necessario(dialogue_box_ja_mostrado)
	
	# ⭐⭐ Verificar novamente o balão 2 após mais um frame para garantir visibilidade
	await get_tree().process_frame
	if balao_fala2 and fase_1_completa:
		balao_fala2.visible = true
		balao_fala2.show()
		print("✅ Balão 2 verificado novamente e mantido visível!")
	
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

func _posicionar_balao2_proximo_khepre():
	# Buscar o Khepre no mapa
	var khepre = get_node_or_null("../Khepre")
	
	if khepre and balao_fala2:
		# Obter viewport para calcular a posição
		var viewport = get_viewport()
		if viewport:
			# Obter tamanho da tela
			var screen_size = viewport.get_visible_rect().size
			
			# Posicionar balão acima do Khepre na tela (centralizado)
			balao_fala2.position = Vector2(
				screen_size.x / 2 - 400,  # Centralizado horizontalmente
				150  # Acima do Khepre (ajuste conforme necessário)
			)
			print("✅ Balão 2 posicionado próximo ao Khepre: ", balao_fala2.position)
		else:
			# Fallback: posição fixa
			balao_fala2.position = Vector2(112, 150)
			print("✅ Balão 2 posicionado em posição padrão (fallback): ", balao_fala2.position)
	else:
		if not khepre:
			print("⚠️ Khepre não encontrado!")
		if not balao_fala2:
			print("⚠️ Balão 2 não encontrado!")

