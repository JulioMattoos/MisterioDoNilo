extends Area2D
class_name CardResposta

signal resposta_arrastada(valor, eh_correta)

var valor: int = 0
var eh_correta: bool = false
var posicao_original: Vector2

@onready var sprite: Sprite2D = $SpriteCard_Fase_1

var _arrastando := false
var _offset: Vector2

func _ready():
	if posicao_original == Vector2.ZERO:
		posicao_original = global_position
	
	# Conectar input_event seguro
	var cb = Callable(self, "_on_input_event")
	if not is_connected("input_event", cb):
		connect("input_event", cb)

func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			# Iniciar arrasto
			_arrastando = true
			_offset = global_position - get_global_mouse_position()
			get_viewport().set_input_as_handled()
		else:
			# Soltar
			if _arrastando:
				_arrastando = false
				_on_soltar()
	
	elif event is InputEventMouseMotion and _arrastando:
		# Mover suavemente
		global_position = get_global_mouse_position() + _offset

func _on_soltar():
	var areas_sobrepostas = get_overlapping_areas()
	for area in areas_sobrepostas:
		if area is AreaResposta:
			emit_signal("resposta_arrastada", valor, eh_correta)
			return
	
	# Se não encontrou área válida, voltar
	voltar_para_original()

func configurar(_valor: int, _eh_correta: bool) -> void:
	valor = _valor
	eh_correta = _eh_correta

func get_valor() -> int:
	return valor

func voltar_para_original():
	global_position = posicao_original

func fixar_na_posicao_atual():
	_arrastando = false
	collision_layer = 0
	collision_mask = 0
