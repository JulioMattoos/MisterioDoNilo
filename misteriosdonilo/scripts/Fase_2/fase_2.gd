extends Node2D
# Configuração das equações - FASE 2 (Multiplicação e Divisão)
var equacoes = [
	{"expressao": "4 × 7", "resultado": 28, "area_index": 1},
	{"expressao": "6 ÷ 3", "resultado": 2, "area_index": 2},
	{"expressao": "8 × 6", "resultado": 48, "area_index": 3}
]

var equacao_atual = 0
var jogo_iniciado = false

@export var ui_fase_2_path: NodePath
@export var container_cards_path: NodePath

@onready var ui_fase_2: UiFase2 = get_node_or_null(ui_fase_2_path)
@onready var container_cards: Node = get_node_or_null(container_cards_path)

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
		push_error("UI_Fase_2 não encontrada!")
	if not container_cards:
		push_error("ContainerCards_Fase_2 não encontrada!")
	
	# Configurar cada área com sua equação específica
	configurar_areas_resposta()
	# ⭐⭐ GARANTIR QUE CARDS ESTÃO INVISÍVEIS
	garantir_cards_area_invisiveis()
	
	if ui_fase_2:
		var cb = Callable(self, "iniciar_jogo")
		if not ui_fase_2.botao_iniciar_pressed.is_connected(cb):
			ui_fase_2.botao_iniciar_pressed.connect(cb)
		print("✅ Conexão com UI_Fase_2 estabelecida")
	else:
		print("⚠️ ERRO: UI_Fase_2 não encontrada! Iniciando jogo automaticamente...")
		# ⭐ CORREÇÃO: Se não há UI, iniciar jogo automaticamente
		iniciar_jogo()
	
	# ⭐ MOVER esconder_elementos_jogo() para dentro da condição de UI
	# Se não há UI, não devemos esconder os elementos
	if ui_fase_2:
		esconder_elementos_jogo()
	
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
	criar_cards_dinamicamente()
	liberar_todas_cartas()

	if ui_fase_2:
		ui_fase_2.atualizar_progresso(equacao_atual, equacoes.size())

func criar_cards_dinamicamente():
	# ⭐ VERIFICAR se container_cards existe
	if not container_cards:
		print("⚠️ ContainerCards não encontrado, pulando criação de cards dinâmicos")
		return
	
	# Limpar cards anteriores
	for card in container_cards.get_children():
		card.queue_free()
	
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
			
			# Conectar sinal do card
			var cb = Callable(self, "_on_card_dropped")
			if not card.resposta_arrastada.is_connected(cb):
				card.resposta_arrastada.connect(cb)
			
			cards_instanciados.append(card)
			
			print("✅ Card criado: ", card.name, " - Valor: ", card.valor, " - Posição: ", card.position)
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
	
	# Buscar card solto
	var card_solto: CardResposta_2 = null
	var area_correta: AreaResposta_2 = null
	
	# BUSCAR CARD SOLTO
	for card in cards_instanciados:
		if card and is_instance_valid(card) and card.valor == valor:
			card_solto = card
			print("🎯 Card solto encontrado: ", card.name, " - Valor: ", card.valor)
			break
	
	if card_solto == null:
		print("❌ Card solto não encontrado!")
		return
	
	# ⭐⭐ CORREÇÃO: Buscar área correta baseada no resultado esperado
	print("📍 Procurando área correta...")
	for area in areas_resposta:
		if area and area.resultado_esperado == valor:
			area_correta = area
			print("🎯 Área CORRETA identificada: ", area.name, " - Espera: ", area.resultado_esperado)
			break
	
	if area_correta == null:
		print("❌ Nenhuma área correta encontrada para o valor ", valor)
		card_solto.voltar_para_original()
		return
	
	# ⭐⭐ VALIDAÇÃO FINAL: Usar a informação da área
	if correto_para_esta_area:
		# Verificar se o card já foi usado
		if cartas_corretas_fixadas.has(card_solto):
			print("⚠️ Card já foi usado corretamente antes")
			card_solto.voltar_para_original()
			return
			
		# ⭐ VERIFICAR SE ESTA RESPOSTA JÁ FOI CONTADA
		if valores_ja_contados.has(valor):
			print("⚠️ Este valor já foi contado antes! Pulando incremento...")
			card_solto.voltar_para_original()
			return
		
		print("🎉 RESPOSTA CORRETA CONFIRMADA!")
		print("   Card: ", card_solto.name, " | Valor: ", card_solto.valor)
		print("   Área: ", area_correta.name, " | Expressão: ", area_correta.expressao)
		
		# ⭐ INCREMENTAR CONTADOR DE RESPOSTAS CORRETAS
		respostas_corretas += 1
		valores_ja_contados.append(valor)  # ⭐ Marcar este valor como já contado
		print("✅ Respostas corretas INCREMENTADAS: ", respostas_corretas, "/", total_respostas)
		print("📝 Valores já contados: ", valores_ja_contados)
		
		if ui_fase_2:
			ui_fase_2.mostrar_feedback("Correto! 🎉", true)
		
		# ⭐⭐ EXECUTAR TROCA
		_executar_troca_card(card_solto, area_correta)
		
		# Aguardar um pouco
		await get_tree().create_timer(1.0).timeout
		
		# Verificar se todas as 3 respostas foram acertadas
		print("🔍 VERIFICAÇÃO FINAL: respostas_corretas = ", respostas_corretas, ", total_respostas = ", total_respostas)
		if respostas_corretas >= total_respostas:
			print("🎊🎊🎊 TODOS OS 3 CARDS FORAM ACERTADOS! 🎊🎊🎊")
			print("🎊 Chamando mostrar_tela_final() agora...")
			await mostrar_tela_final()  # ⭐ Adicionar await para aguardar completa conclusão
		else:
			print("⏳ Ainda faltam acertos. Cards acertados: ", respostas_corretas, "/", total_respostas)
			# Avançar equação para feedback visual
			equacao_atual += 1
			if equacao_atual < equacoes.size() and ui_fase_2:
				ui_fase_2.atualizar_progresso(equacao_atual, equacoes.size())
	else:
		print("❌ RESPOSTA INCORRETA CONFIRMADA!")
		print("   Card: ", card_solto.valor)
		print("   Área esperava: ", area_correta.resultado_esperado, " (", area_correta.expressao, ")")
		if ui_fase_2:
			ui_fase_2.mostrar_feedback("Tente novamente! ❌", false)
		card_solto.voltar_para_original()

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

# ⭐ FUNÇÃO DE TROCA MELHORADA
func _executar_troca_card(card_arrastado: CardResposta_2, area_resposta: AreaResposta_2):
	print("")
	print("🔄 INICIANDO TROCA DE CARD")
	print("   Card: ", card_arrastado.name, " (", card_arrastado.valor, ")")
	print("   Área: ", area_resposta.name, " (", area_resposta.expressao, ")")
	
	# 1. VERIFICAR SE A ÁREA TEM O MÉTODO
	if not area_resposta.has_method("mostrar_card_correto"):
		print("❌ ERRO: Área não tem método mostrar_card_correto()")
		card_arrastado.voltar_para_original()
		return
	
	# 2. DEBUG: Verificar estado antes da troca
	print("📊 ESTADO ANTES DA TROCA:")
	print("   - Card arrastado visível: ", card_arrastado.visible)
	print("   - Card fixo visível: ", area_resposta.tem_card_correto_visivel())
	
	# 3. MOSTRAR CARD FIXO NA ÁREA (PRIMEIRO)
	print("🎯 Ativando card fixo na área...")
	area_resposta.mostrar_card_correto()
	
	# 4. VERIFICAR SE O CARD FIXO FICOU VISÍVEL
	var ficou_visivel = area_resposta.tem_card_correto_visivel()
	print("   ✅ Card fixo ficou visível? ", ficou_visivel)
		
	if not ficou_visivel:
		print("❌ ALERTA: Card fixo NÃO ficou visível!")
	
	# 5. REMOVER CARD ARRASTADO
	print("✨ Removendo card arrastado...")
	if card_arrastado.has_method("desaparecer"):
		card_arrastado.desaparecer()
	else:
		# Fallback
		card_arrastado.visible = false
		card_arrastado.set_process_input(false)
		await get_tree().process_frame
		if is_instance_valid(card_arrastado):
			card_arrastado.queue_free()
	
	# 6. ATUALIZAR CONTROLE DE ESTADO
	cartas_corretas_fixadas.append(card_arrastado)
	if cards_instanciados.has(card_arrastado):
		cards_instanciados.erase(card_arrastado)
	
	print("✅ TROCA CONCLUÍDA!")
	print("   - Card arrastado: REMOVIDO")
	print("   - Card fixo: ATIVADO na área")
	print("")
	
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
	else:
		print("⚠️ ui_fase_2 é null! Não foi possível mostrar feedback.")
	esconder_elementos_jogo()
	
	# Mostra a tela de conclusão com a imagem
	print("📸 Tentando mostrar tela de conclusão...")
	if tela_conclusao:
		print("✅ Tela de conclusão encontrada! Tornando visível...")
		tela_conclusao.visible = true
		print("✅ Tela de conclusão agora está visível: ", tela_conclusao.visible)
	else:
		print("❌ ERRO: Tela de conclusão não encontrada!")
	
	# Aguarda um frame para garantir que a tela apareceu
	await get_tree().process_frame
	
	# Aguarda o jogador apertar Espaço
	print("⌨️ Aguardando tecla Espaço...")
	await _aguardar_tecla_espaco()
	
	# Troca de cena para o mapa principal
	print("🗺️ Retornando ao mapa principal...")
	get_tree().change_scene_to_file("res://Scene/icon.tscn")

# ⭐ FUNÇÃO: Aguardar tecla espaço
func _aguardar_tecla_espaco() -> void:
	print("⌛ Aguardando tecla Espaço para retornar...")
	espaco_pressionado = false  # Resetar flag
	
	# Variável para detectar se foi apenas pressionada (não mantida)
	var espaco_pressionado_anterior = false
	
	# Verificar a cada frame se a tecla foi pressionada
	while true:
		await get_tree().process_frame
		
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
	if Engine.has_singleton("GameManager"):
		GameManager.concluir_fase(2)
		print("✅ Fase 2 marcada como concluída (sessão atual)")
	
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
