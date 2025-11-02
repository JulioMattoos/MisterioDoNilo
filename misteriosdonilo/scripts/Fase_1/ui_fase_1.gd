extends Control
class_name UiFase1

signal botao_iniciar_pressed()

@onready var tela_inicial = $TelaInicial_Fase_1
@onready var botao_iniciar = $TelaInicial_Fase_1/BotaoIniciar_Fase_1

func _ready():
	if botao_iniciar:
		var cb = Callable(self, "_on_botao_iniciar_pressed")
		if not botao_iniciar.is_connected("pressed", cb):
			botao_iniciar.connect("pressed", cb)
	
	mostrar_tela_inicial()

func _on_botao_iniciar_pressed():
	emit_signal("botao_iniciar_pressed")

func mostrar_tela_inicial():
	if tela_inicial: 
		tela_inicial.visible = true


func mostrar_jogo():
	if tela_inicial: 
		tela_inicial.visible = false


func mostrar_feedback(mensagem: String, positivo: bool):
	# Implemente seu sistema de feedback aqui
	print("Feedback: ", mensagem)

func atualizar_progresso(atual: int, total: int):
	print("Progresso: ", atual, "/", total)
	
	
func _on_Botaoiniciar_Fase_1_pressed():
	get_tree().change_scene_to_file("res://Scene/Fase_1/Fase_1.tscn")


func _on_botao_iniciar_fase_1_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/Fase_1/Fase_1.tscn")
