extends CanvasLayer

# Sinal quando botão iniciar é pressionado
signal botao_iniciar_pressed

# Referências aos nós
@onready var tela_inicial = $TelaInicial
@onready var tela_jogo = $TelaJogo
@onready var label_progresso = $TelaJogo/LabelProgresso
@onready var label_feedback = $TelaJogo/LabelFeedback

func _ready():
	# Mostrar tela inicial ao carregar
	mostrar_tela_inicial()

func mostrar_tela_inicial():
	tela_inicial.visible = true
	tela_jogo.visible = false

func mostrar_jogo():
	tela_inicial.visible = false
	tela_jogo.visible = true
	# Esconder feedback
	label_feedback.visible = false

func atualizar_progresso(expressao_atual, total_expressoes):
	label_progresso.text = "Expressão %d/%d" % [expressao_atual + 1, total_expressoes]

func mostrar_feedback(mensagem, eh_correta = false):
	label_feedback.text = mensagem
	label_feedback.modulate = Color.GREEN if eh_correta else Color.RED
	label_feedback.visible = true

func _on_botao_iniciar_pressed():
	# Emitir sinal quando botão é pressionado
	botao_iniciar_pressed.emit()
