extends Node2D

# Configuração das equações - CORRIGIDOS OS RESULTADOS
var equacoes = [
	{"expressao": "1 + 1", "resultado": 2, "area_index": 2},
	{"expressao": "3 + 2", "resultado": 5, "area_index": 5},
	{"expressao": "9 - 6", "resultado": 3, "area_index": 3}
]

var equacao_atual = 0
var jogo_iniciado = false

@onready var tela_conclusao = $CanvasLayer/NivelConcluido
@onready var texture_rect_conclusao = $CanvasLayer/NivelConcluido/TextureRect
@onready var botao_voltar = $CanvasLayer/NivelConcluido/BotaoVoltar
@onready var container = $ContainerCards_Fase_1

var respostas_corretas = 0
var total_respostas = 3  # ajuste se necessário
var espaco_pressionado = false  # ⭐ Flag para detectar tecla espaço
var valores_ja_contados: Array = []  # ⭐ Array para evitar contar a mesma resposta múltiplas vezes


@onready var ui_fase_1 = $UI_Fase_1
@onready var container_cards = $ContainerCards_Fase_1

# Array para armazenar as áreas de resposta
@onready var area_resposta1 = $AreaResposta1Fase1
@onready var area_resposta2 = $AreaResposta2Fase1
@onready var area_resposta3 = $AreaResposta3Fase1

var areas_resposta: Array = []
var cartas_corretas_fixadas: Array = []
var cards_instanciados: Array = []  # ⭐ NOVO: Array para controlar cards criados

func _ready():
	print("Fase_1 carregada!")
	
	# Configurar o array de áreas
	areas_resposta = [area_resposta1, area_resposta2, area_resposta3]
	
	# ⭐⭐ NOVO: Esconder todos os cards corretos no início
	_esconder_cards_corretos()
	
	# Verificar se todos os nodes existem
	if not ui_fase_1:
		push_error("UI_Fase_1 não encontrada!")
	if not container_cards:
		push_error("ContainerCards_Fase_1 não encontrada!")
	
	# Configurar cada área com sua equação específica
	configurar_areas_resposta()
	
	# ⭐⭐ GARANTIR QUE CARDS ESTÃO INVISÍVEIS
	garantir_cards_area_invisiveis()
	
	if ui_fase_1:
		var cb = Callable(self, "iniciar_jogo")
		if not ui_fase_1.is_connected("botao_iniciar_pressed", cb):
			ui_fase_1.connect("botao_iniciar_pressed", cb)
	else:
		print("ERRO: UI_Fase_1 não encontrada!")
	
	esconder_elementos_jogo()
	conectar_areas_resposta()
	
	if tela_conclusao:
		tela_conclusao.visible = false   # <-- corrigido
		tela_conclusao.hide()  # Garantir que está escondido
	
	if texture_rect_conclusao:
		texture_rect_conclusao.visible = false
		texture_rect_conclusao.hide()  # Garantir que está escondido

	if botao_voltar:
		# Conecta apenas se ainda não estiver conectado
		if botao_voltar and not botao_voltar.is_connected("pressed", Callable(self, "_on_voltar_ao_mapa_pressed")):
			botao_voltar.connect("pressed", Callable(self, "_on_voltar_ao_mapa_pressed"))

	# conecta áreas de resposta dentro do container
	if container:
		for area in container.get_children():
			if area.has_signal("resposta_correta"):
				var cb = Callable(self, "_on_resposta_correta")
				if not area.is_connected("resposta_correta", cb):
					area.connect("resposta_correta", cb)




func configurar_areas_resposta():
	for i in range(equacoes.size()):
		if i < areas_resposta.size() and areas_resposta[i] != null:
			var equacao = equacoes[i]
			# ⭐ CORREÇÃO: Chamar método de configuração corretamente
			if areas_resposta[i].has_method("configurar"):
				areas_resposta[i].configurar(equacao["resultado"], equacao["expressao"])
				print("Área ", i, " configurada para: ", equacao["expressao"], " = ", equacao["resultado"])
			else:
				print("ERRO: Área ", i, " não tem método configurar()")

func esconder_elementos_jogo():
	if container_cards:
		container_cards.visible = false
	for area in areas_resposta:
		if area:
			area.visible = false

func mostrar_elementos_jogo():
	if container_cards:
		container_cards.visible = true
	for area in areas_resposta:
		if area:
			area.visible = true

func conectar_areas_resposta():
	for i in range(areas_resposta.size()):
		if areas_resposta[i] != null:
			# ⭐ CORREÇÃO: Conectar sinal corretamente
			if areas_resposta[i].has_signal("resposta_recebida"):
				var cb = Callable(self, "_on_resposta_recebida")
				if not areas_resposta[i].is_connected("resposta_recebida", cb):
					areas_resposta[i].connect("resposta_recebida", cb)
					print("Área ", i, " conectada com sucesso")
			else:
				print("ERRO: Área ", i, " não tem sinal resposta_recebida")

func iniciar_jogo():
	print("Iniciando jogo...")
	jogo_iniciado = true
	equacao_atual = 0
	respostas_corretas = 0  # ⭐ RESETAR contador de respostas corretas
	valores_ja_contados.clear()  # ⭐ LIMPAR array de valores já contados
	espaco_pressionado = false  # ⭐ RESETAR flag da tecla espaço
	cartas_corretas_fixadas.clear()
	cards_instanciados.clear()  # ⭐ LIMPAR array de cards
	
	# ⭐ GARANTIR INVISIBILIDADE NOVAMENTE
	garantir_cards_area_invisiveis()

	if ui_fase_1:
		ui_fase_1.mostrar_jogo()

	mostrar_elementos_jogo()
	criar_cards_dinamicamente()
	liberar_todas_cartas()

	if ui_fase_1:
		ui_fase_1.atualizar_progresso(equacao_atual, equacoes.size())

func criar_cards_dinamicamente():
	# Limpar cards anteriores
	for card in container_cards.get_children():
		card.queue_free()
	
	# ⭐ CORREÇÃO: Aguardar um frame para garantir que os cards foram removidos
	await get_tree().process_frame

	var valores_cards = [2, 3, 5, 6, 9]
	var cenas_cards = {
		2: preload("res://Scene/Fase_1/Card2Resposta_Fase_1.tscn"),
		3: preload("res://Scene/Fase_1/Card3Resposta_Fase_1.tscn"),
		5: preload("res://Scene/Fase_1/Card5Resposta_Fase_1.tscn"),
		6: preload("res://Scene/Fase_1/Card6Resposta_Fase_1.tscn"),
		9: preload("res://Scene/Fase_1/Card9Resposta_Fase_1.tscn")
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
		if card_instance is CardResposta:
			var card: CardResposta = card_instance
			
			# ⭐ CORREÇÃO: Adicionar à cena PRIMEIRO
			container_cards.add_child(card)
			
			# Configurar DEPOIS de adicionar
			card.configurar(valor)
			card.position = Vector2(200 + i * 120, 500)
			card.posicao_original = card.position
			
			# Conectar sinal do card
			var cb = Callable(self, "_on_card_dropped")
			if not card.is_connected("resposta_arrastada", cb):
				card.connect("resposta_arrastada", cb)
			
			# ⭐ ADICIONAR ao array de controle
			cards_instanciados.append(card)
			
			print("✅ Card criado: ", card.name, " - Valor: ", card.valor, " - Posição: ", card.position)
		else:
			print("ERRO: Card instanciado não é do tipo CardResposta")

func _on_resposta_recebida(valor, correto_para_esta_area):
	print("=== RESPOSTA RECEBIDA DA ÁREA ===")
	print("Valor: ", valor, " | Correto: ", correto_para_esta_area)
	print("📊 Estado ANTES de processar: respostas_corretas = ", respostas_corretas, "/", total_respostas)
	_processar_resposta(valor, correto_para_esta_area)
	print("📊 Estado DEPOIS de processar: respostas_corretas = ", respostas_corretas, "/", total_respostas)

func _on_card_dropped(valor):
	# Este sinal é apenas para fallback, a verificação principal é pelas áreas
	print("Card dropped (fallback): ", valor)

func _processar_resposta(valor, correto_para_esta_area):
	print("=== PROCESSANDO RESPOSTA ===")
	print("Valor recebido: ", valor)
	print("Correto para esta área? ", correto_para_esta_area)
	
	# ⭐ CORREÇÃO: Se a resposta está correta, processar diretamente sem precisar do card
	# O card já foi processado e removido pela área
	if correto_para_esta_area:
		print("🎉 Resposta CORRETA detectada!")
		
		# ⭐ VERIFICAR SE ESTA RESPOSTA JÁ FOI CONTADA
		if valores_ja_contados.has(valor):
			print("⚠️ Este valor já foi contado antes! Pulando incremento...")
			return
		
		# Buscar a área que recebeu este card corretamente
		var area_correta = null
		for area in areas_resposta:
			if area and area.ultimo_card_recebido == valor and area.resultado_esperado == valor:
				area_correta = area
				print("🎯 Área CORRETA identificada: ", area.name)
				break
		
		if area_correta == null:
			print("⚠️ Área correta não encontrada, mas resposta está correta. Continuando...")
		
		# ⭐ INCREMENTAR CONTADOR DE RESPOSTAS CORRETAS
		respostas_corretas += 1
		valores_ja_contados.append(valor)  # ⭐ Marcar este valor como já contado
		print("✅ Respostas corretas INCREMENTADAS: ", respostas_corretas, "/", total_respostas)
		print("📝 Valores já contados: ", valores_ja_contados)
		print("🔍 Verificando condição: respostas_corretas (", respostas_corretas, ") >= total_respostas (", total_respostas, ") = ", respostas_corretas >= total_respostas)
		
		# Mostrar feedback (com verificação de null)
		if ui_fase_1:
			ui_fase_1.mostrar_feedback("Correto! 🎉", true)
		else:
			print("⚠️ ui_fase_1 é null! Não foi possível mostrar feedback.")
		
		# Avançar equação
		await get_tree().create_timer(1.0).timeout
		equacao_atual += 1
		
		# Verificar se todas as 3 respostas foram acertadas
		print("🔍 VERIFICAÇÃO FINAL: respostas_corretas = ", respostas_corretas, ", total_respostas = ", total_respostas)
		if respostas_corretas >= total_respostas:
			print("🎊🎊🎊 TODOS OS 3 CARDS FORAM ACERTADOS! 🎊🎊🎊")
			print("🎊 Chamando mostrar_tela_final() agora...")
			mostrar_tela_final()
		else:
			print("⏳ Ainda faltam acertos. Cards acertados: ", respostas_corretas, "/", total_respostas)
			if equacao_atual < equacoes.size():
				if ui_fase_1:
					ui_fase_1.atualizar_progresso(equacao_atual, equacoes.size())
				else:
					print("⚠️ ui_fase_1 é null! Não foi possível atualizar progresso.")
	else:
		print("❌ Resposta INCORRETA!")
		if ui_fase_1:
			ui_fase_1.mostrar_feedback("Tente novamente!", false)
		else:
			print("⚠️ ui_fase_1 é null! Não foi possível mostrar feedback.")

func liberar_todas_cartas():
	for card in cards_instanciados:
		if card and is_instance_valid(card) and card.has_method("liberar_card"):
			card.liberar_card()

func completar_fase():
	print("🎊 FASE COMPLETADA!")
	jogo_iniciado = false
	
	# Esconde UI do jogo
	if ui_fase_1:
		ui_fase_1.mostrar_feedback("Parabéns! Fase concluída! 🎉", true)
	else:
		print("⚠️ ui_fase_1 é null! Não foi possível mostrar feedback.")
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

func voltar_ao_menu():
	print("Voltando ao menu...")
	# ⭐ CORREÇÃO: Limpar arrays
	for card in cards_instanciados:
		if card and is_instance_valid(card):
			card.queue_free()
	
	cards_instanciados.clear()
	cartas_corretas_fixadas.clear()
	
	esconder_elementos_jogo()
	if ui_fase_1: 
		ui_fase_1.mostrar_tela_inicial()


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
			print("Tela conclusão visível: ", tela_conclusao.visible if tela_conclusao else "N/A")
			print("TextureRect visível: ", texture_rect_conclusao.visible if texture_rect_conclusao else "N/A")
			print("Cards instanciados: ", cards_instanciados.size())
			print("Cards fixados: ", cartas_corretas_fixadas.size())
			for card in cards_instanciados:
				if card and is_instance_valid(card):
					var valor = card.get_valor() if card.has_method("get_valor") else card.valor
					print(" - ", card.name, " | Valor: ", valor, " | Fixado: ", cartas_corretas_fixadas.has(card))
					

# ⭐ FUNÇÃO DE TROCA MELHORADA
func _executar_troca_card(card_arrastado: CardResposta, area_resposta: AreaResposta):
	print("🔄 INICIANDO TROCA DE CARD")
	print("   Card: ", card_arrastado.name, " (", card_arrastado.valor, ")")
	print("   Área: ", area_resposta.name)
	
	# 1. VERIFICAR SE A ÁREA TEM O MÉTODO
	if not area_resposta.has_method("mostrar_card_correto"):
		print("❌ ERRO: Área não tem método mostrar_card_correto()")
		card_arrastado.voltar_para_original()
		return
	
	# 2. DEBUG: Verificar estado antes da troca
	print("📊 ESTADO ANTES DA TROCA:")
	print("   - Card arrastado visível: ", card_arrastado.visible)
	print("   - Card fixo visível: ", area_resposta.tem_card_correto_visivel() if area_resposta.has_method("tem_card_correto_visivel") else "N/A")
	
	# 3. MOSTRAR CARD FIXO NA ÁREA (PRIMEIRO)
	print("🎯 Ativando card fixo na área...")
	area_resposta.mostrar_card_correto()
	
	# 4. VERIFICAR SE O CARD FIXO FICOU VISÍVEL
	if area_resposta.has_method("tem_card_correto_visivel"):
		var ficou_visivel = area_resposta.tem_card_correto_visivel()
		print("   ✅ Card fixo ficou visível? ", ficou_visivel)
		
		if not ficou_visivel:
			print("❌ ALERTA: Card fixo NÃO ficou visível!")
	
	# 5. REMOVER CARD ARRASTADO
	print("✨ Removendo card arrastado...")
	if card_arrastado.has_method("desaparecer"):
		card_arrastado.desaparecer()
	else:
		# Fallback seguro
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
		
		# MÉTODO 1: Usar função da área se existir
		if area.has_method("esconder_card_correto"):
			area.esconder_card_correto()
			print("✅ Área ", i, " - esconder_card_correto() chamado")
			areas_corrigidas += 1
		
		# MÉTODO 2: Acesso direto ao sprite (fallback)
		elif area.has_node("CardCorretoSprite"):
			var sprite = area.get_node("CardCorretoSprite")
			if sprite:
				sprite.visible = false
				sprite.scale = Vector2(1, 1)
				sprite.modulate = Color.WHITE
				print("✅ Área ", i, " - CardCorretoSprite desativado diretamente")
				areas_corrigidas += 1
		
		# MÉTODO 3: Tentar acesso por propriedade
		elif "card_correto_sprite" in area:
			var sprite = area.card_correto_sprite
			if sprite and is_instance_valid(sprite):
				sprite.visible = false
				print("✅ Área ", i, " - card_correto_sprite desativado via propriedade")
				areas_corrigidas += 1
		
		else:
			print("⚠️ Área ", i, " - Não encontrou método para esconder card")
	
	print("📊 RESUMO: ", areas_corrigidas, "/", areas_verificadas, " áreas corrigidas")
	
	# ⭐ VERIFICAÇÃO FINAL
	verificar_visibilidade_areas()


func verificar_visibilidade_areas():
	print("🔍 VERIFICANDO VISIBILIDADE DAS ÁREAS:")
	
	for i in range(areas_resposta.size()):
		var area = areas_resposta[i]
		var visivel = "N/A"
		var resultado = "N/A"
		
		if area == null:
			print("   ", i, ": ❌ Área NULA")
			continue
		
		# Tentar diferentes formas de verificar
		if area.has_method("esconder_card_correto") and "resultado_esperado" in area:
			resultado = str(area.resultado_esperado)
		
		if area.has_node("CardCorretoSprite"):
			var sprite = area.get_node("CardCorretoSprite")
			visivel = str(sprite.visible) if sprite else "Sprite Nulo"
		elif "card_correto_sprite" in area:
			var sprite = area.card_correto_sprite
			visivel = str(sprite.visible) if sprite and is_instance_valid(sprite) else "Sprite Inválido"
		
		print("   ", i, ": Resultado=", resultado, " | Visível=", visivel)
	
	print("======================================")
	
	
func _esconder_cards_corretos():
	print("🔧 Escondendo todos os cards corretos...")
	
	var card1 = get_node_or_null("Card_Correto_Fase_1")
	var card2 = get_node_or_null("Card_Correto_Fase_2") 
	var card3 = get_node_or_null("Card_Correto_Fase_3")
	
	if card1:
		card1.visible = false
		print("✅ Card_Correto_Fase_1 escondido")
	if card2:
		card2.visible = false
		print("✅ Card_Correto_Fase_2 escondido")
	if card3:
		card3.visible = false
		print("✅ Card_Correto_Fase_3 escondido")
		
		
# ⭐ NOVA FUNÇÃO: Mostrar tela final do nível
func mostrar_tela_final():
	print("🎉 Nível 1 Concluído! Mostrando tela de conclusão...")
	jogo_iniciado = false
	
	# Esconde elementos do jogo
	esconder_elementos_jogo()
	if ui_fase_1:
		ui_fase_1.mostrar_feedback("Parabéns! Fase concluída! 🎉", true)
	else:
		print("⚠️ ui_fase_1 é null! Não foi possível mostrar feedback de conclusão.")
	
	# Mostra a tela de conclusão (Control)
	if tela_conclusao:
		print("✅ Tela de conclusão encontrada! Tornando visível...")
		tela_conclusao.visible = true
		tela_conclusao.show()  # ⭐ FORÇAR mostrar
		print("✅ Tela de conclusão visível: ", tela_conclusao.visible)
		
		# Forçar processamento
		tela_conclusao.process_mode = Node.PROCESS_MODE_ALWAYS
	else:
		print("❌ ERRO: Tela de conclusão (Control) não encontrada!")
		return
	
	# Garante que o TextureRect também está visível
	if texture_rect_conclusao:
		print("✅ TextureRect encontrado! Tornando visível...")
		texture_rect_conclusao.visible = true
		texture_rect_conclusao.show()  # ⭐ FORÇAR mostrar
		print("✅ TextureRect visível: ", texture_rect_conclusao.visible)
		
		# Verifica se a textura está carregada
		if texture_rect_conclusao.texture:
			print("✅ Textura 'nivel concluido.png' carregada!")
		else:
			print("❌ ERRO: Textura não encontrada no TextureRect!")
			# Tentar carregar manualmente
			var texture_path = "res://imagens/assets_Fase_1/nivel concluido.png"
			var texture = load(texture_path)
			if texture:
				texture_rect_conclusao.texture = texture
				print("✅ Textura carregada manualmente!")
			else:
				print("❌ ERRO: Não foi possível carregar a textura!")
	else:
		print("❌ ERRO: TextureRect não encontrado!")
		# Tentar buscar novamente
		texture_rect_conclusao = get_node_or_null("CanvasLayer/NivelConcluido/TextureRect")
		if texture_rect_conclusao:
			print("✅ TextureRect encontrado via get_node_or_null!")
			texture_rect_conclusao.visible = true
			texture_rect_conclusao.show()
	
	# Aguarda alguns frames para garantir que tudo apareceu
	await get_tree().process_frame
	await get_tree().process_frame
	
	# Resetar flag antes de aguardar
	espaco_pressionado = false
	
	# Aguarda o jogador apertar Espaço
	print("⌨️ Aguardando tecla Espaço...")
	await _aguardar_tecla_espaco()
	
	# Troca de cena para o mapa principal
	print("🗺️ Retornando ao mapa principal...")
	get_tree().change_scene_to_file("res://Scene/icon.tscn")


func _on_voltar_ao_mapa_pressed() -> void:
	print("🗺️ Botão 'Voltar ao Mapa' pressionado!")
	get_tree().change_scene_to_file("res://Scene/icon.tscn")
