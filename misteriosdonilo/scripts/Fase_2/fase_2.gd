extends Node2D
# Configuração das equações - FASE 2 (Multiplicação e Divisão)
var equacoes = [
	{"expressao": "4 × 7", "resultado": 28, "area_index": 1},
	{"expressao": "6 ÷ 3", "resultado": 2, "area_index": 2},
	{"expressao": "8 × 6", "resultado": 40, "area_index": 3}
]

var equacao_atual = 0
var jogo_iniciado = false

@onready var ui_fase_2 = get_node_or_null("UI_Fase_2")
@onready var container_cards: Node = $ContainerCards_Fase_2

# Array para armazenar as áreas de resposta
@onready var area_resposta1: AreaResposta_2 = $AreaResposta1Fase2
@onready var area_resposta2: AreaResposta_2 = $AreaResposta2Fase2
@onready var area_resposta3: AreaResposta_2 = $AreaResposta3Fase2

# Tela de conclusão
@onready var tela_conclusao = $CanvasLayer/NivelConcluido
@onready var texture_rect_conclusao = $CanvasLayer/NivelConcluido/TextureRect

var areas_resposta: Array[AreaResposta_2] = []
var cartas_corretas_fixadas: Array[CardResposta_2] = []
var cards_instanciados: Array[CardResposta_2] = []
var espaco_pressionado = false  # Flag para detectar tecla espaço
var respostas_corretas = 0  # Contador de respostas corretas
var total_respostas = 3  # Total de respostas esperadas
var valores_ja_contados: Array = []  # Array para evitar contar a mesma resposta múltiplas vezes

func _ready():
	print("🎮 Fase_2 carregada!")
	
	# Configurar o array de áreas
	areas_resposta = [area_resposta1, area_resposta2, area_resposta3]
	
	# ⭐⭐ NOVO: Esconder todos os cards corretos no início
	_esconder_cards_corretos()
	
	# Verificar se todos os nodes existem
	if not ui_fase_2:
		print("⚠️ UI_Fase_2 não encontrada - jogo funcionará sem interface de menu")
	if not container_cards:
		push_error("ContainerCards_Fase_2 não encontrada!")
	
	# Configurar cada área com sua equação específica
	configurar_areas_resposta()
	# ⭐⭐ GARANTIR QUE CARDS ESTÃO INVISÍVEIS
	garantir_cards_area_invisiveis()
	
	if ui_fase_2 and ui_fase_2.has_signal("botao_iniciar_pressed"):
		var cb = Callable(self, "iniciar_jogo")
		if not ui_fase_2.botao_iniciar_pressed.is_connected(cb):
			ui_fase_2.botao_iniciar_pressed.connect(cb)
		print("✅ Conexão com UI_Fase_2 estabelecida")
		esconder_elementos_jogo()
	else:
		print("⚠️ UI_Fase_2 não encontrada! Iniciando jogo automaticamente...")
		# ⭐ Se não há UI, iniciar jogo automaticamente após um delay
		if get_tree():
			await get_tree().create_timer(0.5).timeout
		iniciar_jogo()
	
	conectar_areas_resposta()
	
	# Esconder tela de conclusão no início
	if tela_conclusao:
		tela_conclusao.visible = false
		tela_conclusao.hide()
	
	if texture_rect_conclusao:
		texture_rect_conclusao.visible = false
		texture_rect_conclusao.hide()

func configurar_areas_resposta():
	for i in range(equacoes.size()):
		if i < areas_resposta.size() and areas_resposta[i] != null:
			var equacao = equacoes[i]
			areas_resposta[i].configurar(equacao["resultado"], equacao["expressao"])
			print("🎯 Área ", i+1, " configurada para: ", equacao["expressao"], " = ", equacao["resultado"])

func esconder_elementos_jogo():
	if container_cards:
		container_cards.visible = false
	for area in areas_resposta:
		if area:
			area.visible = false

func mostrar_elementos_jogo():
	print("🟢 MOSTRANDO ELEMENTOS DO JOGO...")
	if container_cards:
		container_cards.visible = true
	for area in areas_resposta:
		if area:
			area.visible = true
			print("   ✅ Área visível: ", area.name)

func conectar_areas_resposta():
	for i in range(areas_resposta.size()):
		if areas_resposta[i] != null:
			var cb = Callable(self, "_on_resposta_recebida")
			if not areas_resposta[i].resposta_recebida.is_connected(cb):
				areas_resposta[i].resposta_recebida.connect(cb)
				print("✅ Área ", i+1, " conectada com sucesso")

func iniciar_jogo():
	print("🎮 Iniciando jogo Fase 2...")
	jogo_iniciado = true
	equacao_atual = 0
	respostas_corretas = 0  # ⭐ RESETAR contador de respostas corretas
	valores_ja_contados.clear()  # ⭐ LIMPAR array de valores já contados
	cartas_corretas_fixadas.clear()
	cards_instanciados.clear()
	
	# ⭐ GARANTIR INVISIBILIDADE NOVAMENTE
	garantir_cards_area_invisiveis()

	if ui_fase_2:
		ui_fase_2.mostrar_jogo()

	mostrar_elementos_jogo()
	
	# ⭐⭐ FASE 2: Usar cards que já existem na cena em vez de criar novos
	carregar_cards_existentes()
	
	# ⭐⭐ FASE 2: Aguardar criação dos cards antes de liberar
	if get_tree():
		await get_tree().process_frame
	
	liberar_todas_cartas()

	if ui_fase_2:
		ui_fase_2.atualizar_progresso(equacao_atual, equacoes.size())

func carregar_cards_existentes():
	print("📦 Carregando cards existentes da cena...")
	
	# Pegar os cards que já estão na cena (filhos diretos do Fase_2)
	var card_names = [
		"Card28Resposta_Fase_2",
		"Card40Resposta_Fase_2", 
		"Card2Resposta_Fase_2",
		"Card48Resposta_Fase_2",
		"Card6Resposta_Fase_2"
	]
	
	for card_name in card_names:
		var card = get_node_or_null(card_name)
		
		if card and card is CardResposta_2:
			# Garantir visibilidade
			card.visible = true
			card.modulate = Color.WHITE
			
			# Conectar sinal do card
			var cb = Callable(self, "_on_card_dropped")
			if not card.resposta_arrastada.is_connected(cb):
				card.resposta_arrastada.connect(cb)
			
			cards_instanciados.append(card)
			print("✅ Card carregado: ", card.name, " - Valor: ", card.valor)
		else:
			print("❌ Card não encontrado: ", card_name)
	
	print("📊 Total de cards carregados: ", cards_instanciados.size())

func criar_cards_dinamicamente():
	# ⭐ VERIFICAR se container_cards existe
	if not container_cards:
		print("⚠️ ContainerCards não encontrado, pulando criação de cards dinâmicos")
		return
	
	# Limpar cards anteriores
	for card in container_cards.get_children():
		card.queue_free()
	
	if get_tree():
		await get_tree().process_frame

	# ⭐ CARDS DA FASE 2 (Multiplicação e Divisão)
	var valores_cards = [2, 6, 28, 40, 48]
	var cenas_cards = {
		2: preload("res://Scene/Fase_2/Card2Resposta_Fase_2.tscn"),
		6: preload("res://Scene/Fase_2/Card6Resposta_Fase_2.tscn"),
		28: preload("res://Scene/Fase_2/Card28Resposta_Fase_2.tscn"),
		40: preload("res://Scene/Fase_2/Card40Resposta_Fase_2.tscn"),
		48: preload("res://Scene/Fase_2/Card48Resposta_Fase_2.tscn")
	}
	
	# ⭐⭐ FASE 2: Lista de valores corretos (os que devem aparecer quando acertados)
	var valores_corretos = [2, 28, 40]  # Respostas das 3 equações da Fase 2

	for i in range(valores_cards.size()):
		var valor = valores_cards[i]
		if not cenas_cards.has(valor):
			print("ERRO: Cena não encontrada para valor ", valor)
			continue
			
		var card_scene = cenas_cards[valor]
		if card_scene == null:
			print("ERRO: Cena é nula para valor ", valor)
			continue
			
		var card_instance = card_scene.instantiate()
		if card_instance is CardResposta_2:
			var card: CardResposta_2 = card_instance
			
			container_cards.add_child(card)
			card.configurar(valor)
			card.position = Vector2(200 + i * 120, 500)
			card.posicao_original = card.position
			
			# ⭐⭐ FASE 2: Tornar cards INVISÍVEIS no início
			card.visible = false
			card.modulate.a = 0  # Transparente para animação suave
			print("🔒 Card ", card.valor, " criado INVISÍVEL (Fase 2)")
			
			# Conectar sinal do card
			var cb = Callable(self, "_on_card_dropped")
			if not card.resposta_arrastada.is_connected(cb):
				card.resposta_arrastada.connect(cb)
			
			cards_instanciados.append(card)
			
			print("✅ Card criado: ", card.name, " - Valor: ", card.valor, " - Posição: ", card.position, " - Visível: ", card.visible)
		else:
			print("ERRO: Card instanciado não é do tipo CardResposta_2")

func _on_resposta_recebida(valor: int, correto_para_esta_area: bool):
	print("")
	print("=== 🎯 RESPOSTA RECEBIDA DA ÁREA ===")
	print("Valor do card: ", valor)
	print("Correto para esta área: ", correto_para_esta_area)
	print("=====================================")
	
	# ⭐⭐ CORREÇÃO CRÍTICA: Processar a resposta baseada no sinal da área
	_processar_resposta(valor, correto_para_esta_area)

func _on_card_dropped(valor: int):
	print("Card dropped (fallback): ", valor)

func _processar_resposta(valor: int, correto_para_esta_area: bool):
	print("=== 🔍 PROCESSANDO RESPOSTA ===")
	print("Valor recebido: ", valor)
	print("Correto para esta área? ", correto_para_esta_area)
	
	# ⭐ SIMPLIFICADO COMO FASE 1
	if correto_para_esta_area:
		# Verificar se esta resposta já foi contada
		if valores_ja_contados.has(valor):
			print("⚠️ Este valor já foi contado antes!")
			return
		
		print("🎉 RESPOSTA CORRETA!")
		
		# Incrementar contador
		respostas_corretas += 1
		valores_ja_contados.append(valor)
		print("✅ Respostas corretas: ", respostas_corretas, "/", total_respostas)
		
		if ui_fase_2:
			ui_fase_2.mostrar_feedback("Correto! 🎉", true)
		
		# Aguardar um pouco
		if get_tree():
			await get_tree().create_timer(1.0).timeout
		
		# Avançar equação
		equacao_atual += 1
		if equacao_atual < equacoes.size() and ui_fase_2:
			ui_fase_2.atualizar_progresso(equacao_atual, equacoes.size())
		
		# Verificar se todas as respostas foram acertadas
		if respostas_corretas >= total_respostas:
			print("🎊 FASE 2 COMPLETADA!")
			await mostrar_tela_final()
	else:
		print("❌ RESPOSTA INCORRETA!")
		if ui_fase_2:
			ui_fase_2.mostrar_feedback("Tente novamente! ❌", false)

func liberar_todas_cartas():
	for card in cards_instanciados:
		if card and is_instance_valid(card):
			card.liberar_card()

func voltar_ao_menu():
	print("Voltando ao menu...")
	for card in cards_instanciados:
		if card and is_instance_valid(card):
			card.queue_free()
	
	cards_instanciados.clear()
	cartas_corretas_fixadas.clear()
	
	esconder_elementos_jogo()
	if ui_fase_2: 
		ui_fase_2.mostrar_tela_inicial()

# ⭐ NOVO: Função para debug e detectar tecla espaço
func _input(event):
	if event is InputEventKey and event.pressed:
		# Detectar tecla Espaço apenas se a tela de conclusão estiver visível
		if event.keycode == KEY_SPACE and tela_conclusao and tela_conclusao.visible:
			espaco_pressionado = true
			print("⌨️ Tecla Espaço detectada! Flag setada para: ", espaco_pressionado)
		
		# Debug (tecla D)
		if event.keycode == KEY_D:
			print("=== DEBUG INFO ===")
			print("Equação atual: ", equacao_atual)
			print("Respostas corretas: ", respostas_corretas, "/", total_respostas)
			print("Valores já contados: ", valores_ja_contados)
			print("Tela conclusão visível: ", tela_conclusao.visible if tela_conclusao else "N/A")
			print("Cards instanciados: ", cards_instanciados.size())
			print("Cards fixados: ", cartas_corretas_fixadas.size())
			for card in cards_instanciados:
				if card and is_instance_valid(card):
					print(" - ", card.name, " | Valor: ", card.valor, " | Fixado: ", cartas_corretas_fixadas.has(card))

func garantir_cards_area_invisiveis():
	print("🔒 GARANTINDO CARDS DAS ÁREAS INVISÍVEIS...")
	
	var areas_verificadas = 0
	var areas_corrigidas = 0
	
	for i in range(areas_resposta.size()):
		var area = areas_resposta[i]
		
		if area == null:
			print("❌ Área ", i, " é nula - pulando")
			continue
		
		areas_verificadas += 1
		area.esconder_card_correto()
		print("✅ Área ", i+1, " - esconder_card_correto() chamado")
		areas_corrigidas += 1
	
	print("📊 RESUMO: ", areas_corrigidas, "/", areas_verificadas, " áreas corrigidas")
	verificar_visibilidade_areas()

func verificar_visibilidade_areas():
	print("🔍 VERIFICANDO VISIBILIDADE DAS ÁREAS:")
	
	for i in range(areas_resposta.size()):
		var area = areas_resposta[i]
		var visivel = "N/A"
		var resultado = "N/A"
		
		if area == null:
			print("   ", i+1, ": ❌ Área NULA")
			continue
		
		resultado = str(area.resultado_esperado)
		visivel = str(area.tem_card_correto_visivel())
		
		print("   ", i+1, ": Resultado=", resultado, " | Visível=", visivel)
	
	print("======================================")

# ⭐ NOVA FUNÇÃO: Mostrar tela final do nível
func mostrar_tela_final():
	print("🎊 FASE 2 COMPLETADA!")
	jogo_iniciado = false
	
	# Salvar progresso
	salvar_progresso()
	
	# Esconde UI do jogo
	if ui_fase_2:
		ui_fase_2.mostrar_feedback("Parabéns! Fase 2 concluída! 🎉", true)
	esconder_elementos_jogo()
	
	# Mostra a tela de conclusão com a imagem
	print("📸 Tentando mostrar tela de conclusão...")
	if tela_conclusao:
		print("✅ Tela de conclusão encontrada!")
		tela_conclusao.visible = true
		tela_conclusao.show()
		tela_conclusao.z_index = 100
		print("   Visível: ", tela_conclusao.visible)
		print("   Z-index: ", tela_conclusao.z_index)
		
		# Verificar TextureRect
		if texture_rect_conclusao:
			print("✅ TextureRect encontrado!")
			texture_rect_conclusao.visible = true
			texture_rect_conclusao.show()
			print("   Visível: ", texture_rect_conclusao.visible)
			print("   Textura: ", texture_rect_conclusao.texture)
			print("   Tamanho: ", texture_rect_conclusao.size)
			
			# Se não tiver textura, tentar carregar
			if not texture_rect_conclusao.texture:
				print("⚠️ Textura não carregada! Tentando carregar...")
				var texture = load("res://Scene/Fase_2/concluido2.png")
				if texture:
					texture_rect_conclusao.texture = texture
					print("✅ Textura carregada manualmente!")
				else:
					print("❌ ERRO: Não foi possível carregar a textura!")
		else:
			print("❌ ERRO: TextureRect não encontrado!")
	else:
		print("❌ ERRO: Tela de conclusão não encontrada!")
	
	# Aguarda alguns frames
	if get_tree():
		await get_tree().process_frame
		await get_tree().process_frame
		await get_tree().process_frame
	
	print("🖼️ Imagem de conclusão deveria estar visível agora!")
	print("   Pressione ESPAÇO para continuar...")
	
	# Aguarda o jogador apertar Espaço
	await _aguardar_tecla_espaco()
	
	# Troca de cena para o mapa principal
	print("🗺️ Retornando ao mapa principal...")
	if get_tree():
		get_tree().change_scene_to_file("res://Scene/icon.tscn")
	else:
		push_error("❌ Erro: get_tree() retornou null ao tentar mudar de cena!")

# ⭐ FUNÇÃO: Aguardar tecla espaço
func _aguardar_tecla_espaco() -> void:
	print("⌛ Aguardando tecla Espaço para retornar...")
	espaco_pressionado = false  # Resetar flag
	
	# Variável para detectar se foi apenas pressionada (não mantida)
	var espaco_pressionado_anterior = false
	
	# Verificar a cada frame se a tecla foi pressionada
	while true:
		if get_tree():
			await get_tree().process_frame
		else:
			push_error("❌ Erro: get_tree() retornou null no loop de espera!")
			break
		
		# Verificar através da flag (setada em _input)
		if espaco_pressionado:
			print("✅ Flag de tecla espaço detectada!")
			break
		
		# Verificar diretamente pelo Input
		var espaco_atual = Input.is_key_pressed(KEY_SPACE) or Input.is_action_pressed("ui_accept") or Input.is_action_pressed("interact")
		
		# Detectar quando a tecla é pressionada (não mantida)
		if espaco_atual and not espaco_pressionado_anterior:
			print("✅ Tecla Espaço pressionada (detectada no loop)!")
			espaco_pressionado = true
			break
		
		espaco_pressionado_anterior = espaco_atual
	
	print("✅ Tecla Espaço confirmada! Retornando ao mapa...")

# ⭐ FUNÇÃO: Salvar progresso
func salvar_progresso():
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		gm.concluir_fase(2)
		print("✅ Fase 2 marcada como concluída (sessão atual)")
		print("📊 GameManager.fase_2_completa = ", gm.fase_2_completa)
	else:
		print("❌ ERRO: GameManager não encontrado ao salvar progresso da Fase 2!")
	
func _esconder_cards_corretos():
	print("🔧 Escondendo todos os cards corretos...")
	
	var card1 = get_node_or_null("Card_Correto_Fase_21")
	var card2 = get_node_or_null("Card_Correto_Fase_22") 
	var card3 = get_node_or_null("Card_Correto_Fase_23")
	
	if card1:
		card1.visible = false
		print("✅ Card_Correto_Fase_21 escondido")
	if card2:
		card2.visible = false
		print("✅ Card_Correto_Fase_22 escondido")
	if card3:
		card3.visible = false
		print("✅ Card_Correto_Fase_23 escondido")
