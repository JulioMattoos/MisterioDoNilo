extends Control
class_name UiFase3

signal botao_iniciar_pressed()

@onready var tela_inicial = $TelaInicial_Fase_3
@onready var botao_iniciar: Button = $TelaInicial_Fase_3/BotaoIniciar_Fase_3

func _ready():
	if botao_iniciar:
		var cb = Callable(self, "_on_botao_iniciar_pressed")
		if not botao_iniciar.pressed.is_connected(cb):
			botao_iniciar.pressed.connect(cb)
	
	mostrar_tela_inicial()

func _on_botao_iniciar_pressed():
	botao_iniciar_pressed.emit()

func mostrar_tela_inicial():
	if tela_inicial: 
		tela_inicial.visible = true

func mostrar_jogo():
	if tela_inicial: 
		tela_inicial.visible = false

func mostrar_feedback(mensagem: String, positivo: bool):
	# Implemente seu sistema de feedback aqui
	print("🎮 Feedback Fase 3: ", mensagem)

func atualizar_progresso(atual: int, total: int):
	print("📊 Progresso Fase 3: ", atual, "/", total)
