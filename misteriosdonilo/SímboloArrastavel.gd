extends Sprite

var valor = 1
var arrastando = false
var offset = Vector2.ZERO

func _ready():
	# Tornar clicável
	self.texture = load(get_parent().sprites_simbolos[valor])

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.pressed:
				# Começar a arrastar
				arrastando = true
				offset = position - get_global_mouse_position()
				z_index = 10  # Traz para frente
			else:
				# Parar de arrastar
				arrastando = false
				z_index = 0

func _process(delta):
	if arrastando:
		position = get_global_mouse_position() + offset
		
		# Limitar à área de jogo
		position.x = clamp(position.x, 50, 600)
		position.y = clamp(position.y, 100, 400)

# Função para quando o símbolo é clicado (para remover)
func _on_Símbolo_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == BUTTON_RIGHT:
			queue_free()
			get_parent().simbolos_na_tela.erase(self)
