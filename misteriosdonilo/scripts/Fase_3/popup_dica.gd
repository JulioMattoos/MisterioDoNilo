extends CanvasLayer

func _ready():
	# Começa invisível
	visible = false
	
	# Conecta o clique do botão "voltar"
	$Area2D.input_event.connect(_on_voltar_click)
	
	# Conecta qualquer input na Area2D para tratar com outra função
	$Area2D.connect("input_event", Callable(self, "_on_area2d_input"))

# Função chamada ao clicar na Area2D (botão voltar)
func _on_voltar_click(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		visible = false

# Função adicional para inputs na Area2D
func _on_area2d_input(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		print("Area2D clicada!")
		# Aqui você pode colocar qualquer ação ao clicar no pergaminho
