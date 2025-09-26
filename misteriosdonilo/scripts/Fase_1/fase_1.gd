extends Node2D

# Configuração das equações - CORRIGIDOS OS RESULTADOS
var equacoes = [
	{"expressao": "1 + 1", "resultado": 2, "area_index": 0},
	{"expressao": "3 + 2", "resultado": 5, "area_index": 1},
	{"expressao": "9 - 6", "resultado": 3, "area_index": 2}
]

var equacao_atual = 0
var jogo_iniciado = false

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
	
	# Verificar se todos os nodes existem
	if not ui_fase_1:
		push_error("UI_Fase_1 não encontrada!")
	if not container_cards:
		push_error("ContainerCards_Fase_1 não encontrada!")
	
	# Configurar cada área com sua equação específica
	configurar_areas_resposta()
	
	if ui_fase_1:
		var cb = Callable(self, "iniciar_jogo")
		if not ui_fase_1.is_connected("botao_iniciar_pressed", cb):
			ui_fase_1.connect("botao_iniciar_pressed", cb)
	else:
		print("ERRO: UI_Fase_1 não encontrada!")
	
	esconder_elementos_jogo()
	conectar_areas_resposta()

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
	cartas_corretas_fixadas.clear()
	cards_instanciados.clear()  # ⭐ LIMPAR array de cards

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
			card.configurar(valor, false)
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
	_processar_resposta(valor, correto_para_esta_area)

func _on_card_dropped(valor):
	# Este sinal é apenas para fallback, a verificação principal é pelas áreas
	print("Card dropped (fallback): ", valor)

func _processar_resposta(valor, correto_para_esta_area):
	print("=== PROCESSANDO RESPOSTA ===")
	print("Valor recebido: ", valor)
	print("Correto para esta área? ", correto_para_esta_area)
	print("Equação atual: ", equacao_atual)
	
	# ⭐ MELHORIA: Buscar card de forma mais robusta
	var card_solto = null
	for card in cards_instanciados:  # ⭐ Usar array de controle
		if card and is_instance_valid(card) and card.has_method("get_valor"):
			var card_valor = card.get_valor() if card.has_method("get_valor") else card.valor
			print("Verificando card: ", card.name, " - Valor: ", card_valor)
			if card_valor == valor:
				card_solto = card
				print("✅ Card correto encontrado: ", card.name)
				break
	
	if card_solto == null:
		print("❌ ERRO: Nenhum card com valor ", valor, " encontrado!")
		print("Cards disponíveis:")
		for card in cards_instanciados:
			if card and is_instance_valid(card):
				var card_valor = card.get_valor() if card.has_method("get_valor") else card.valor
				print(" - ", card.name, " | Valor: ", card_valor)
		return
	
	# ⭐ VERIFICAR se o card já está fixado
	if cartas_corretas_fixadas.has(card_solto):
		print("ℹ️ Card já estava fixado - ignorando")
		return
	
	if correto_para_esta_area:
		print("🎉 RESPOSTA CORRETA PARA A EQUAÇÃO: ", equacoes[equacao_atual]["expressao"])
		
		# Verificar se é a resposta esperada para a equação atual
		var resultado_esperado = equacoes[equacao_atual]["resultado"]
		if valor == resultado_esperado:
			ui_fase_1.mostrar_feedback("Correto! 🎉", true)
			card_solto.fixar_na_posicao_atual()
			cartas_corretas_fixadas.append(card_solto)
			print("✅ Card fixado com sucesso!")
			
			# Avançar no jogo
			await get_tree().create_timer(1.0).timeout
			equacao_atual += 1
			
			if equacao_atual < equacoes.size():
				ui_fase_1.atualizar_progresso(equacao_atual, equacoes.size())
				print("➡️ Próxima equação: ", equacoes[equacao_atual]["expressao"])
			else:
				completar_fase()
		else:
			print("❌ Card correto, mas não para esta equação!")
			ui_fase_1.mostrar_feedback("Card correto, mas equação errada!", false)
			card_solto.voltar_para_original()
	else:
		print("❌ RESPOSTA INCORRETA!")
		ui_fase_1.mostrar_feedback("Tente novamente!", false)
		card_solto.voltar_para_original()

func liberar_todas_cartas():
	for card in cards_instanciados:
		if card and is_instance_valid(card) and card.has_method("liberar_card"):
			card.liberar_card()

func completar_fase():
	print("🎊 FASE COMPLETADA!")
	ui_fase_1.mostrar_feedback("Parabéns! Fase concluída! 🎉", true)
	jogo_iniciado = false
	
	await get_tree().create_timer(3.0).timeout
	voltar_ao_menu()

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

# ⭐ NOVO: Função para debug
func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_D:
			print("=== DEBUG INFO ===")
			print("Equação atual: ", equacao_atual)
			print("Cards instanciados: ", cards_instanciados.size())
			print("Cards fixados: ", cartas_corretas_fixadas.size())
			for card in cards_instanciados:
				if card and is_instance_valid(card):
					var valor = card.get_valor() if card.has_method("get_valor") else card.valor
					print(" - ", card.name, " | Valor: ", valor, " | Fixado: ", cartas_corretas_fixadas.has(card))
