extends Control

@onready var texture_rect_fundo = $TextureRect

func _ready():
	print("Tela de Título carregada!")
	
	# Habilitar detecção de mouse na tela inteira
	mouse_filter = Control.MOUSE_FILTER_STOP
	
	# Configurar o fundo (TextureRect)
	if texture_rect_fundo:
		texture_rect_fundo.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		texture_rect_fundo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		texture_rect_fundo.mouse_filter = Control.MOUSE_FILTER_STOP
		print("✅ TextureRect configurado!")
	
	print("💡 Clique em qualquer lugar da tela para iniciar o jogo!")

func _input(event):
	# Detectar cliques do mouse
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			print("🗺️ Tela clicada! Carregando mapa principal...")
			iniciar_jogo()
			get_viewport().set_input_as_handled()

func _gui_input(event):
	# Alternativa: detectar cliques na interface
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			print("🗺️ Tela clicada! Carregando mapa principal...")
			iniciar_jogo()
			accept_event()

func iniciar_jogo():
	var tree = get_tree()
	if tree != null and is_inside_tree():
		tree.call_deferred("change_scene_to_file", "res://Scene/TelaIntroducao.tscn")
	else:
		print("❌ ERRO: Árvore da cena não está disponível!")
