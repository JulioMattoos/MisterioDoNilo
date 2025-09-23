extends Area2D

@onready var sprite_resposta = $SpriteResposta

func _ready():
	# Configurar forma de colisão
	var collision = $CollisionShape2D
	var shape = CircleShape2D.new()
	shape.radius = 60
	collision.shape = shape
	
	# Configurar visual de fundo
	configurar_visual()

func configurar_visual():
	# Adicionar um círculo visual se não existir
	if not has_node("FundoVisual"):
		var fundo = Sprite2D.new()
		fundo.name = "FundoVisual"
		# Carregue uma textura de círculo ou use draw()
		add_child(fundo)
		move_child(fundo, 0)  # Coloca atrás do sprite de resposta

func _on_area_entered(area):
	if area.has_method("get_valor"):
		# A lógica principal é tratada no Fase1.gd
		pass
