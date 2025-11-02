extends Control
class_name UiFase3_1

signal botao_iniciar_pressed()

@onready var tela_inicial = $TelaInicial_Fase_3_1
@onready var botao_iniciar: Button = $TelaInicial_Fase_3_1/BotaoIniciar_Fase_3_1
@onready var sprite_ui = $Sprite2D

func _ready():
	if botao_iniciar:
		var cb = Callable(self, "_on_botao_iniciar_pressed")
		if not botao_iniciar.is_connected("pressed", cb):
			botao_iniciar.connect("pressed", cb)
	
	mostrar_tela_inicial()

func _on_botao_iniciar_pressed():
	emit_signal("botao_iniciar_pressed")

func mostrar_tela_inicial():
	print("🟢 Mostrando tela inicial da Fase 3.1...")
	visible = true
	if sprite_ui:
		sprite_ui.visible = true
		print("✅ Sprite2D da UI visível")
	if tela_inicial: 
		tela_inicial.visible = true
		tela_inicial.show()
		print("✅ TelaInicial_Fase_3_1 visível")
	if botao_iniciar:
		botao_iniciar.visible = true
		botao_iniciar.show()
		print("✅ Botão Iniciar visível")
	print("✅ UI_Fase_3_1 Control visível")

func mostrar_jogo():
	print("🔄 Escondendo UI da Fase 3.1...")
	if tela_inicial: 
		tela_inicial.visible = false
		print("✅ TelaInicial_Fase_3_1 escondida")
	if sprite_ui:
		sprite_ui.visible = false
		print("✅ Sprite2D da UI escondido")
	visible = false
	print("✅ UI_Fase_3_1 Control escondido")

func mostrar_feedback(mensagem: String, positivo: bool):
	# Implemente seu sistema de feedback aqui
	print("🎮 Feedback Fase 3_1: ", mensagem)

func atualizar_progresso(atual: int, total: int):
	print("📊 Progresso Fase 3_1: ", atual, "/", total)
