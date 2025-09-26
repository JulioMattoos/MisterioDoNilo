extends Node2D

var equacoes = [
	{"expressao": "1 + 2", "resultado": 3, "posicao_area": Vector2(850, 150)},
	{"expressao": "3 + 4", "resultado": 7, "posicao_area": Vector2(850, 250)},
	{"expressao": "9 - 6", "resultado": 3, "posicao_area": Vector2(850, 350)}
]

var equacao_atual = 0
var jogo_iniciado = false

@onready var ui_fase_1 = $UI_Fase_1
@onready var container_cards = $ContainerCards_Fase_1

# Array para armazenar referências das áreas
var areas_resposta: Array = []

func _ready():
	print("Fase_1 carregada!")
	
	# Encontrar todas as áreas de resposta automaticamente
	for child in get_children():
		if child is AreaResposta:
			areas_resposta.append(child)
	
	if ui_fase_1:
		var cb = Callable(self, "iniciar_jogo")
		if not ui_fase_1.is_connected("botao_iniciar_pressed", cb):
			ui_fase_1.connect("botao_iniciar_pressed", cb)
	
	esconder_elementos_jogo()
	conectar_areas_resposta()

func esconder_elementos_jogo():
	if container_cards:
		container_cards.visible = false
	for area in areas_resposta:
		area.visible = false

func mostrar_elementos_jogo():
	if container_cards:
		container_cards.visible = true
	for area in areas_resposta:
		area.visible = true

func conectar_areas_resposta():
	var cb = Callable(self, "_on_resposta_recebida")
	for area in areas_resposta:
		if not area.is_connected("resposta_recebida", cb):
			area.connect("resposta_recebida", cb)

func iniciar_jogo():
	print("Iniciando jogo...")
	jogo_iniciado = true
	equacao_atual = 0

	if ui_fase_1:
		ui_fase_1.mostrar_jogo()

	mostrar_elementos_jogo()
	criar_cards_dinamicamente()

	if ui_fase_1:
		ui_fase_1.atualizar_progresso(equacao_atual, equacoes.size())

func criar_cards_dinamicamente():
	# Limpar cards anteriores
	for card in container_cards.get_children():
		card.queue_free()

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
			continue
			
		var card_instance = cenas_cards[valor].instantiate()
		if card_instance is CardResposta:
			var card: CardResposta = card_instance
			var eh_correto = false
			
			# Verificar se este card é resposta de alguma equação
			for equacao in equacoes:
				if valor == equacao["resultado"]:
					eh_correto = true
					break
			
			card.configurar(valor, eh_correto)
			card.position = Vector2(200 + i * 120, 500)
			card.posicao_original = card.position
			
			container_cards.add_child(card)
			
			# Conectar sinal do card
			var cb = Callable(self, "_on_card_dropped")
			if not card.is_connected("resposta_arrastada", cb):
				card.connect("resposta_arrastada", cb)
			
			print("Card criado: ", valor)

func _on_resposta_recebida(valor, eh_correta):
	_processar_resposta(valor, eh_correta)

func _on_card_dropped(valor, eh_correta):
	_processar_resposta(valor, eh_correta)

func _processar_resposta(valor, eh_correta):
	if eh_correta:
		# Encontrar card correto e fixar
		for card in container_cards.get_children():
			if card is CardResposta and card.valor == valor:
				card.fixar_na_posicao_atual()
				break
		
		if ui_fase_1: 
			ui_fase_1.mostrar_feedback("Correto! 🎉", true)
		
		await get_tree().create_timer(1.0).timeout
		equacao_atual += 1
		
		if equacao_atual < equacoes.size():
			if ui_fase_1: 
				ui_fase_1.atualizar_progresso(equacao_atual, equacoes.size())
		else:
			completar_fase()
	else:
		if ui_fase_1: 
			ui_fase_1.mostrar_feedback("Tente novamente!", false)
		
		# Voltar card para posição original
		for card in container_cards.get_children():
			if card is CardResposta and card.valor == valor:
				card.voltar_para_original()
				break

func completar_fase():
	if ui_fase_1: 
		ui_fase_1.mostrar_feedback("Parabéns! Fase concluída! 🎉", true)
	
	jogo_iniciado = false
	await get_tree().create_timer(3.0).timeout
	voltar_ao_menu()

func voltar_ao_menu():
	for card in container_cards.get_children():
		card.queue_free()
	
	esconder_elementos_jogo()
	if ui_fase_1: 
		ui_fase_1.mostrar_tela_inicial()
