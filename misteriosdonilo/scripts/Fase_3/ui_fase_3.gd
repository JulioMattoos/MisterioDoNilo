extends Control
class_name UiFase3

signal botao_iniciar_pressed()

@onready var tela_inicial = $TelaInicial_Fase_3
@onready var botao_iniciar: Button = $TelaInicial_Fase_3/BotaoIniciar_Fase_3
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
	print("🟢 Mostrando tela inicial da Fase 3...")
	if tela_inicial: 
		tela_inicial.visible = true
		print("✅ TelaInicial_Fase_3 visível")
	if sprite_ui:
		sprite_ui.visible = true
		print("✅ Sprite2D da UI visível")
	visible = true
	print("✅ UI_Fase_3 Control visível")

func mostrar_jogo():
	print("🔄 Escondendo UI da Fase 3...")
	if tela_inicial: 
		tela_inicial.visible = false
		print("✅ TelaInicial_Fase_3 escondida")
	if sprite_ui:
		sprite_ui.visible = false
		print("✅ Sprite2D da UI escondido")
	visible = false
	print("✅ UI_Fase_3 Control escondido")

func mostrar_feedback(mensagem: String, positivo: bool):
	# Implemente seu sistema de feedback aqui
	print("🎮 Feedback Fase 3: ", mensagem)

func atualizar_progresso(atual: int, total: int):
	print("📊 Progresso Fase 3: ", atual, "/", total)
