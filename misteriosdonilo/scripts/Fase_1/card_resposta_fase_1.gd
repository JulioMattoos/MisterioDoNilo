extends Area2D

class_name CardResposta

# Sinal quando card é solto na área de resposta
signal resposta_arrastada(valor, eh_correta)

# Variáveis do card
var valor: int = 0
var eh_correta: bool = false
var arrastando: bool = false
var posicao_original: Vector2

# Referências aos nós filhos
@onready var sprite = $SpriteCard
@onready var collision_shape = $CollisionShape

func _ready():
	# Conectar o sinal de input do mouse
	connect("input_event", _on_input_event)
	# Guardar posição original para voltar se errar
	posicao_original = position

# Configurar o card com valor e se é correto
func configurar(valor_config: int, eh_correta_config: bool):
	valor = valor_config
	eh_correta = eh_correta_config
	
	# Carregar a imagem PNG do card baseado no valor
	var texture_path = "res://assets/images/cards/card_%d.png" % valor_config
	var texture = load(texture_path)
	
	if texture:
		sprite.texture = texture
	else:
		# Fallback: criar um quadrado colorido
		print("Texture não encontrada: ", texture_path)

# Quando o mouse interage com o card
func _on_input_event(_viewport, event, _shape_idx):
	# Verificar se foi clique esquerdo
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			# Mouse pressionado - iniciar arraste
			iniciar_arraste()
		else:
			# Mouse solto - finalizar arraste
			finalizar_arraste()

func iniciar_arraste():
	arrastando = true
	z_index = 10  # Faz o card ficar por cima dos outros
	scale = Vector2(1.1, 1.1)  # Aumenta um pouco ao ser arrastado

func finalizar_arraste():
	arrastando = false
	z_index = 0   # Volta ao z-index normal
	scale = Vector2(1.0, 1.0)  # Volta ao tamanho normal
	
	# Verificar se está em cima de alguma área de resposta
	var areas = get_overlapping_areas()
	for area in areas:
		if area.is_in_group("area_resposta"):
			# Emitir sinal de resposta
			resposta_arrastada.emit(valor, eh_correta)
			return
	
	# Se não está em área de resposta, volta para posição original
	voltar_para_original()

# Atualiza a posição do card enquanto está sendo arrastado
func _process(_delta):
	if arrastando:
		global_position = get_global_mouse_position()

# Animação para voltar à posição original
func voltar_para_original():
	var tween = create_tween()
	tween.tween_property(self, "position", posicao_original, 0.3)
	tween.set_ease(Tween.EASE_OUT)

# Função para obter o valor do card (usado na verificação)
func get_valor():
	return valor
