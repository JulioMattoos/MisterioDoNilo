extends Area2D

signal resposta_arrastada(valor, eh_correta)

var valor = 0
var eh_correta = false
var arrastando = false
var offset = Vector2.ZERO
var posicao_original = Vector2.ZERO

@onready var sprite = $Sprite
@onready var collision_shape = $CollisionShape2D

func configurar(valor_config, eh_correta_config):
	valor = valor_config
	eh_correta = eh_correta_config
	atualizar_aparencia()

func atualizar_aparencia():
	# Cria visual baseado no valor (usando sprites combinados)
	var textura = criar_textura_com_sprites(valor)
	if textura:
		sprite.texture = textura
	sprite.scale = Vector2(0.3, 0.3)
	
	# Configurar colisão
	var shape = RectangleShape2D.new()
	shape.extents = Vector2(40, 40)
	collision_shape.shape = shape

func criar_textura_com_sprites(valor):
	# Implementação simplificada - mostrando número como texto
	var label = Label.new()
	label.text = str(valor)
	label.add_font_override("font", load("res://fonts/FonteGrande.tres"))
	
	# Em uma versão final, você criaria uma textura com sprites reais
	return null

func _ready():
	posicao_original = position
	connect("input_event", Callable(self, "_on_input_event"))

func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			iniciar_arraste(event)
		else:
			finalizar_arraste()

func iniciar_arraste(_event):
	arrastando = true
	offset = global_position - get_global_mouse_position()
	z_index = 10
	scale = Vector2(0.35, 0.35)

func finalizar_arraste():
	arrastando = false
	z_index = 0
	scale = Vector2(0.3, 0.3)
	
	# Verificar se está na área de resposta
	var areas = get_overlapping_areas()
	for area in areas:
		if area.name == "AreaResposta":
			emit_signal("resposta_arrastada", valor, eh_correta)
			return
	
	# Se não está na área, volta para posição original
	voltar_para_original()

func _process(_delta):
	if arrastando:
		global_position = get_global_mouse_position() + offset
		# Limitar movimento na tela
		global_position.x = clamp(global_position.x, 50, 750)
		global_position.y = clamp(global_position.y, 50, 550)

func voltar_para_original():
	var tween = Tween.new()
	add_child(tween)
	tween.interpolate_property(self, "position", position, posicao_original, 0.3, Tween.TRANS_BACK, Tween.EASE_OUT)
	tween.start()
	await tween.finished
	tween.queue_free()

func get_valor():
	return valor
