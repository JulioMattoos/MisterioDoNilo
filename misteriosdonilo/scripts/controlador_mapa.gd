extends Node

@onready var balao_fala = get_node_or_null("../CanvasLayer/BalaoFala")
@onready var balao_fala2 = get_node_or_null("../CanvasLayer/BalaoFala2")
@onready var balao_fala3 = get_node_or_null("../CanvasLayer/BalaoFala3")
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
	if not balao_fala3:
		balao_fala3 = get_node_or_null("../CanvasLayer/BalaoFala3")
	
	# ⭐⭐ Verificar se o DialogueBox já foi mostrado nesta sessão (usar GameManager)
	var dialogue_box_ja_mostrado = false
	var fase_1_completa = false
	var fase_2_completa = false
	var gm = get_node_or_null("/root/GameManager")
	
	if gm:
		dialogue_box_ja_mostrado = gm.dialogue_box_mostrado
		fase_1_completa = gm.fase_concluida(1)
		fase_2_completa = gm.fase_concluida(2)
		print("📊 GameManager encontrado!")
		print("   dialogue_box_mostrado = ", dialogue_box_ja_mostrado)
		print("   fase_1_completa = ", fase_1_completa)
		print("   fase_2_completa = ", fase_2_completa)
	else:
		print("⚠️ GameManager não encontrado. Assumindo que DialogueBox não foi mostrado.")
	
	# ⭐⭐⭐ GERENCIAR VISIBILIDADE DOS BALÕES BASEADO NO PROGRESSO
	# Prioridade: Fase 2 > Fase 1 > Inicial
	
	if fase_2_completa:
		# ⭐⭐⭐ FASE 2 CONCLUÍDA: Mostrar apenas balão 3
		print("🎯 Fase 2 concluída - Mostrando balão 3")
		
		# Esconder balões 1 e 2
		if balao_fala:
			balao_fala.visible = false
			balao_fala.hide()
			print("✅ Balão 1 escondido (Fase 2 concluída)")
		
		if balao_fala2:
			balao_fala2.visible = false
			balao_fala2.hide()
			print("✅ Balão 2 escondido (Fase 2 concluída)")
		
		# Mostrar balão 3
		if balao_fala3:
			balao_fala3.visible = true
			balao_fala3.show()
			print("✅ Balão 3 VISÍVEL (Fase 2 concluída)")
		else:
			print("❌ ERRO: Balão 3 não encontrado!")
	
	elif fase_1_completa:
		# ⭐⭐ FASE 1 CONCLUÍDA: Mostrar apenas balão 2
		print("🎯 Fase 1 concluída - Mostrando balão 2")
		
		# Esconder balões 1 e 3
		if balao_fala:
			balao_fala.visible = false
			balao_fala.hide()
			print("✅ Balão 1 escondido (Fase 1 concluída)")
		
		if balao_fala3:
			balao_fala3.visible = false
			balao_fala3.hide()
			print("✅ Balão 3 escondido (apenas Fase 1 concluída)")
		
		# Mostrar balão 2
		if balao_fala2:
			balao_fala2.visible = true
			balao_fala2.show()
			print("✅ Balão 2 VISÍVEL (Fase 1 concluída)")
		else:
			print("❌ ERRO: Balão 2 não encontrado!")
	
	else:
		# ⭐ NENHUMA FASE CONCLUÍDA: Mostrar apenas balão 1
		print("🎯 Nenhuma fase concluída - Mostrando balão 1")
		
		# Esconder balões 2 e 3
		if balao_fala2:
			balao_fala2.visible = false
			balao_fala2.hide()
			print("✅ Balão 2 escondido (nenhuma fase concluída)")
		
		if balao_fala3:
			balao_fala3.visible = false
			balao_fala3.hide()
			print("✅ Balão 3 escondido (nenhuma fase concluída)")
		
		# Mostrar balão 1 se DialogueBox não foi mostrado
		if balao_fala:
			if dialogue_box_ja_mostrado:
				balao_fala.visible = false
				balao_fala.hide()
				print("✅ Balão 1 escondido: DialogueBox já foi mostrado")
			else:
				balao_fala.visible = true
				balao_fala.show()
				print("✅ Balão 1 visível: DialogueBox ainda não foi mostrado")
		else:
			print("❌ ERRO: Balão 1 não encontrado!")
	
	# Salvar o estado localmente
	dialogue_box_ja_foi_mostrado = dialogue_box_ja_mostrado
	
	# Verificar novamente após alguns frames
	await get_tree().process_frame
	await get_tree().process_frame
	
	# Re-aplicar visibilidade para garantir
	if fase_2_completa and balao_fala3:
		balao_fala3.visible = true
		balao_fala3.show()
		print("✅ Balão 3 verificado novamente e mantido visível!")
	elif fase_1_completa and balao_fala2:
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

