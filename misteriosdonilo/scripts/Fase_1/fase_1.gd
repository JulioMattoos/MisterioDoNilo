extends Node2D

# Configuração das equações da sua imagem
var equacoes = [
	{"expressao": "1 + 2", "resultado": 3, "posicao_area": Vector2(850, 150)},
	{"expressao": "3 + 4", "resultado": 7, "posicao_area": Vector2(850, 250)},
	{"expressao": "9 - 6", "resultado": 3, "posicao_area": Vector2(850, 350)}
]

var equacao_atual = 0
var jogo_iniciado = false

# Referências aos nós da cena
@onready var ui = $UI_Fase1
@onready var container_cards = $ContainerCards_Fase_1
@onready var area_resposta1 = $AreaResposta1Fase1
@onready var area_resposta2 = $AreaResposta2Fase1
@onready var area_resposta3 = $AreaResposta3Fase1

func _ready():
	# Conectar sinais da UI
	ui.botao_iniciar_pressed.connect(iniciar_jogo)
	
	# Conectar sinais das áreas de resposta
	area_resposta1.resposta_recebida.connect(_on_resposta_recebida)
	area_resposta2.resposta_recebida.connect(_on_resposta_recebida)
	area_resposta3.resposta_recebida.connect(_on_resposta_recebida)
	
	# Posicionar áreas conforme a imagem
	area_resposta1.position = equacoes[0]["posicao_area"]
	area_resposta2.position = equacoes[1]["posicao_area"]
	area_resposta3.position = equacoes[2]["posicao_area"]
	
	# Mostrar tela inicial
	ui.mostrar_tela_inicial()

func iniciar_jogo():
	jogo_iniciado = true
	equacao_atual = 0
	ui.mostrar_jogo()
	criar_todos_cards()
	ui.atualizar_progresso(equacao_atual, equacoes.size())

func criar_todos_cards():
	# Limpar cards anteriores
	for card in container_cards.get_children():
		card.queue_free()
	
	# Valores dos cards baseados na sua imagem
	var valores_cards = [2, 3, 5, 6, 9]
	
	# Criar todos os cards
	for i in range(valores_cards.size()):
		var card = preload("res://Scene/Fase_1/CardResposta_Fase_1.tscn").instantiate()
		var valor = valores_cards[i]
		
		# Verificar se este card é correto para alguma equação
		var eh_correto = false
		for equacao in equacoes:
			if valor == equacao["resultado"]:
				eh_correto = true
				break
		
		# Configurar card
		card.configurar(valor, eh_correto)
		
		# Posicionar na linha inferior (500 pixels do topo)
		card.position = Vector2(200 + i * 120, 500)
		
		# Adicionar à cena
		container_cards.add_child(card)

func _on_resposta_recebida(valor, eh_correta):
	if eh_correta:
		# Encontrar qual equação foi resolvida
		for i in range(equacoes.size()):
			if valor == equacoes[i]["resultado"] and i >= equacao_atual:
				# Feedback positivo
				ui.mostrar_feedback("Correto! 🎉", true)
				
				# Aguardar um pouco
				await get_tree().create_timer(1.0).timeout
				
				# Avançar progresso
				equacao_atual = i + 1
				
				if equacao_atual < equacoes.size():
					ui.atualizar_progresso(equacao_atual, equacoes.size())
				else:
					completar_fase()
				break
	else:
		# Feedback negativo
		ui.mostrar_feedback("Tente novamente!", false)

func completar_fase():
	ui.mostrar_feedback("Parabéns! Fase concluída! 🎉", true)
	jogo_iniciado = false
	
	# Aguardar e voltar ao menu
	await get_tree().create_timer(3.0).timeout
	ui.mostrar_tela_inicial()


func _on_ui_fase_1_botao_iniciar_pressed() -> void:
	pass # Replace with function body.
