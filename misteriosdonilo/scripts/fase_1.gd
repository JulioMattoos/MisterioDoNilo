extends Node2D

var sprites_numericos = {
	1: "res://EgyptianNumbers/1.png",
	2: "res://EgyptianNumbers/2.png",
	3: "res://EgyptianNumbers/3.png",
	4: "res://EgyptianNumbers/4.png",
	5: "res://EgyptianNumbers/5.png",
	6: "res://EgyptianNumbers/6.png",
	7: "res://EgyptianNumbers/7.png",
	8: "res://EgyptianNumbers/8.png",
	9: "res://EgyptianNumbers/9.png",
	10: "res://EgyptianNumbers/10.png",
	20: "res://EgyptianNumbers/20.png",
	30: "res://EgyptianNumbers/30.png",
	40: "res://EgyptianNumbers/40.png",
	50: "res://EgyptianNumbers/50.png",
	60: "res://EgyptianNumbers/60.png",
	70: "res://EgyptianNumbers/70.png",
	80: "res://EgyptianNumbers/80.png",
	90: "res://EgyptianNumbers/90.png",
	100: "res://EgyptianNumbers/100.png",
	200: "res://EgyptianNumbers/200.png",
	300: "res://EgyptianNumbers/300.png",
	400: "res://EgyptianNumbers/400.png",
	500: "res://EgyptianNumbers/500.png",
	600: "res://EgyptianNumbers/600.png",
	700: "res://EgyptianNumbers/700.png",
	800: "res://EgyptianNumbers/800.png",
	900: "res://EgyptianNumbers/900.png",
	1000: "res://EgyptianNumbers/1000.png",
	2000: "res://EgyptianNumbers/2000.png",
	3000: "res://EgyptianNumbers/3000.png",
	4000: "res://EgyptianNumbers/4000.png",
	5000: "res://EgyptianNumbers/5000.png",
	6000: "res://EgyptianNumbers/6000.png",
	7000: "res://EgyptianNumbers/7000.png",
	8000: "res://EgyptianNumbers/8000.png",
	9000: "res://EgyptianNumbers/9000.png",
}

var config_dificuldade = {
	"numero_min": 1,
	"numero_max": 30,
	"operacoes": ["+"],
	"opcoes_resposta": 3,
	"dificuldade_opcoes": 3,
	"sprites_ativos": ["sprite_1", "sprite_10"]
}

# Variáveis do jogo
var resultado_correto = 0
var opcoes_resposta = []
var opcao_correta_index = 0
var expressao_sprites = []

# Referências UI - DECLARADAS COMO VAR NORMAL
var label_instrucao
var container_expressao
var container_opcoes
var area_resposta
var sprite_resposta
var label_resultado

func _ready():
	# INICIALIZAR REFERÊNCIAS ONREADY AQUI
	label_instrucao = $UI_Fase_1/ContainerInfo_Fase_1/LabelInstrucao_Fase_1
	container_expressao = $UI_Fase_1/ContainerExpressao_Fase_1
	container_opcoes = $UI_Fase_1/ContainerOpcoes_Fase_1
	area_resposta = $AreaResposta_Fase_1/AreaResposta_Fase_1
	sprite_resposta = $AreaResposta_Fase_1/SpriteResposta_Fase_1
	label_resultado = $UI_Fase_1/LabelResultado_Fase_1
	
	setup_ui()
	iniciar_fase()

func setup_ui():
	# Conectar área de resposta
	area_resposta.connect("area_entered", self, "_on_resposta_recebida")
	
	# Conectar botão de nova pergunta se existir
	if has_node("UI_Fase_1/BotaoConfirmarResposta_Fase_1"):
		$UL_Fase_1/BotaoConfirmaResponse_to_Fase_1.pressed.connect(iniciar_fase)

func iniciar_fase():
	limpar_expressao()
	limpar_opcoes()
	resetar_ui()
	gerar_desafio()

func resetar_ui():
	label_resultado.text = ""
	label_resultado.modulate = Color(1, 1, 1)
	if sprite_resposta:
		sprite_resposta.texture = null

func gerar_desafio():
	gerar_expressao_aleatoria()
	gerar_opcoes_resposta()
	atualizar_ui()

func gerar_expressao_aleatoria():
	var num1 = gerar_numero_aleatorio_com_sprites()
	var num2 = gerar_numero_aleatorio_com_sprites()
	var operacao = config_dificuldade["operacoes"][randi() % config_dificuldade["operacoes"].size()]
	
	# Ajustar para subtração não negativa
	if operacao == "-" and num1 < num2:
		var temp = num1
		num1 = num2
		num2 = temp
	
	resultado_correto = calcular_resultado(num1, num2, operacao)
	criar_expressao_visual(num1, num2, operacao)

func gerar_numero_aleatorio_com_sprites():
	var numero = 0
	var max_tentativas = 5
	
	while numero < config_dificuldade["numero_min"] and max_tentativas > 0:
		numero = 0
		for sprite_nome in config_dificuldade["sprites_ativos"]:
			var valor_sprite = sprites_numericos[sprite_nome]
			var quantidade = randi() % 3 + 1  # 1-3 de cada tipo
			numero += valor_sprite * quantidade
			
			if numero > config_dificuldade["numero_max"]:
				numero = 0
				break
		
		max_tentativas -= 1
	
	return clamp(numero, config_dificuldade["numero_min"], config_dificuldade["numero_max"])

func calcular_resultado(num1, num2, operacao):
	match operacao:
		"+": return num1 + num2
		"-": return num1 - num2
		_: return num1 + num2

func criar_expressao_visual(num1, num2, operacao):
	limpar_expressao()
	adicionar_numero_visual(num1, 0)
	adicionar_operador_visual(operacao, 1)
	adicionar_numero_visual(num2, 2)
	adicionar_igual_visual(3)

func adicionar_numero_visual(numero, posicao):
	var temp_numero = numero
	var offset_x = 0
	
	for valor in [10, 1]:  # Apenas valores ativos na fase 1
		if temp_numero >= valor:
			var quantidade = temp_numero / valor
			var sprite_nome = encontrar_sprite_por_valor(valor)
			
			if sprite_nome in config_dificuldade["sprites_ativos"]:
				for i in range(quantidade):
					var sprite = criar_sprite_numero(sprite_nome)
					sprite.position = Vector2(posicao * 150 + offset_x, 0)
					offset_x += 35
					container_expressao.add_child(sprite)
					expressao_sprites.append(sprite)
			
			temp_numero %= valor

func encontrar_sprite_por_valor(valor):
	for sprite_nome in sprites_numericos:
		if sprites_numericos[sprite_nome] == valor:
			return sprite_nome
	return ""

func criar_sprite_numero(sprite_nome):
	var sprite = Sprite2D.new()
	var caminho_sprite = sprites_numericos.get(sprite_nome, "")
	if caminho_sprite != "":
		var texture = load(caminho_sprite)
		if texture:
			sprite.texture = texture
	sprite.scale = Vector2(0.25, 0.25)
	return sprite

func adicionar_operador_visual(operacao, posicao):
	var label = Label.new()
	label.text = operacao
	# label.add_font_override("font", load("res://fonts/FonteGrande.tres"))  # Comente se não tem fonte
	label.rect_position = Vector2(posicao * 150, -10)
	label.add_color_override("font_color", Color(1, 1, 1))
	container_expressao.add_child(label)
	expressao_sprites.append(label)

func adicionar_igual_visual(posicao):
	var label = Label.new()
	label.text = "= ?"
	# label.add_font_override("font", load("res://fonts/FonteGrande.tres"))  # Comente se não tem fonte
	label.rect_position = Vector2(posicao * 150, -10)
	label.add_color_override("font_color", Color(1, 1, 1))
	container_expressao.add_child(label)
	expressao_sprites.append(label)

func gerar_opcoes_resposta():
	opcoes_resposta.clear()
	opcoes_resposta.append(resultado_correto)
	
	# Gerar opções erradas
	for i in range(config_dificuldade["opcoes_resposta"] - 1):
		var opcao_errada = gerar_opcao_errada()
		opcoes_resposta.append(opcao_errada)
	
	opcoes_resposta.shuffle()
	opcao_correta_index = opcoes_resposta.find(resultado_correto)
	criar_opcoes_ui()

func gerar_opcao_errada():
	var opcao
	var tentativas = 0
	
	while tentativas < 10:
		opcao = resultado_correto + (randi() % 7 - 3)  # -3 a +3 de diferença
		if opcao > 0 and opcao != resultado_correto and not opcao in opcoes_resposta:
			return opcao
		tentativas += 1
	
	return resultado_correto + 1  # Fallback

func criar_opcoes_ui():
	for i in range(opcoes_resposta.size()):
		var opcao_valor = opcoes_resposta[i]
		# Usar Label temporário em vez de cena complexa
		var label = Label.new()
		label.text = str(opcao_valor)
		label.name = "Opcao_" + str(opcao_valor)
		label.rect_position = Vector2(i * 160 + 100, 0)
		label.add_color_override("font_color", Color(1, 1, 1))
		container_opcoes.add_child(label)

func atualizar_ui():
	if label_instrucao:
		label_instrucao.text = "Arraste a resposta correta para o círculo!"

func _on_resposta_recebida(area):
	if area and area.has_method("get_valor"):
		var valor_resposta = area.get_valor()
		var eh_correta = area.eh_correta
		verificar_resposta(valor_resposta, eh_correta)

func verificar_resposta(valor_resposta, eh_correta):
	if eh_correta:
		acertou_resposta(valor_resposta)
	else:
		errou_resposta(valor_resposta)

func acertou_resposta(valor_resposta):
	label_resultado.text = "Parabéns! Você acertou! 🎉"
	label_resultado.modulate = Color(0, 1, 0)
	
	# Mostrar resposta correta temporariamente
	var label_temp = Label.new()
	label_temp.text = str(valor_resposta)
	label_temp.add_color_override("font_color", Color(0, 1, 0))
	if sprite_resposta:
		# sprite_resposta.texture = criar_textura_opcao(valor_resposta)  # Simplificado
		pass
	
	await get_tree().create_timer(2.0).timeout
	iniciar_fase()

func errou_resposta(valor_resposta):
	label_resultado.text = "Tente novamente! Não é " + str(valor_resposta)
	label_resultado.modulate = Color(1, 0, 0)
	await get_tree().create_timer(1.5).timeout
	label_resultado.text = ""

func limpar_expressao():
	for sprite in expressao_sprites:
		if is_instance_valid(sprite):
			sprite.queue_free()
	expressao_sprites.clear()

func limpar_opcoes():
	for child in container_opcoes.get_children():
		if is_instance_valid(child):
			child.queue_free()

# Função para o botão de nova pergunta
func _on_BotaoNovaPergunta_pressed():
	iniciar_fase()
