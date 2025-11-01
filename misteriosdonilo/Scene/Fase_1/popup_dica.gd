extends CanvasLayer

func _ready():
	# Começa invisível
	visible = false
	
	# Conecta o clique do botão "voltar"
	if has_node("Area2D"):
		$Area2D.input_event.connect(_on_voltar_click)
		# Conecta qualquer input na Area2D para tratar com outra função
		$Area2D.connect("input_event", Callable(self, "_on_area2d_input"))
	
	# Conecta clique no fundo escuro para fechar
	if has_node("FundoEscuro"):
		$FundoEscuro.gui_input.connect(_on_fundo_escuro_click)

# Função chamada ao clicar na Area2D (botão voltar)
func _on_voltar_click(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed:
		visible = false

# Função adicional para inputs na Area2D
func _on_area2d_input(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed:
		print("Area2D clicada!")
		# Aqui você pode colocar qualquer ação ao clicar no pergaminho

# Função chamada ao clicar no fundo escuro
func _on_fundo_escuro_click(event: InputEvent):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		visible = false
