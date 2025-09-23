extends Button

func _ready():
	connect("pressed", Callable(self, "_on_pressed"))

func _on_pressed():
	# O sinal será conectado no script principal
	pass
