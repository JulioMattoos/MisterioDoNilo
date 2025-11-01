extends Area2D

@onready var popup_dica = $"../PopupDica"

func _ready():
	input_event.connect(_on_pergaminho_click)

func _on_pergaminho_click(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed:
		popup_dica.visible = true
