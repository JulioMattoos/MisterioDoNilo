extends Node2D

# Dicionário com os paths para os sprites PNG
var sprites_simbolos = {
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

# Variáveis do jogo
var numero_alvo = 0
var expressao_atual = ""
var resultado_jogador = 0
var simbolos_na_tela = []
var simbolo_arrastando = null

# Referências UI
onready var label_numero_alvo = $UI/LabelNumeroAlvo
onready var label_expressao = $UI/LabelExpressao
onready var label_resultado = $UI/LabelResultado
onready var area_simbolos = $AreaSímbolos


func _ready():
	# Configurar a área de drop
	area_simbolos.connect("input_event", self, "_on_area_simbolos_input")
	iniciar_fase()

func iniciar_fase():
	limpar_simbolos()
	label_resultado.text = ""
	label_resultado.modulate = Color(1, 1, 1)
	
	# Número alvo entre 1-30 para facilitar
	numero_alvo = randi() % 30 + 1
	label_numero_alvo.text = "Monte: " + converter_para_egipicio(numero_alvo)
	
	gerar_expressao()

func gerar_expressao():
	var num1 = randi() % 15 + 1
	var num2 = randi() % 15 + 1
	var operacao = ["+", "-"][randi() % 2]
	
	if operacao == "-" and num1 < num2:
		var temp = num1
		num1 = num2
		num2 = temp
	
	expressao_atual = str(num1) + " " + operacao + " " + str(num2)
	label_expressao.text = "Calcule: " + expressao_atual
	
	if operacao == "+":
		resultado_jogador = num1 + num2
	else:
		resultado_jogador = num1 - num2
