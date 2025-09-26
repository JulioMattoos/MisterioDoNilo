extends CharacterBody2D

# Variável para rastrear se o jogador está na área de interação.
var player_in_range = false

# Variável para controlar se o diálogo está ativo, para evitar múltiplas instâncias.
var dialogue_is_active = false

# Instância da cena de diálogo que será criada.
var dialogue_instance = null

# O Godot vai permitir que você arraste as cenas para esses campos no Inspector.
@export var dialogue_box_scene : PackedScene
@export var next_level_scene : PackedScene

func _ready():
	# Verifica se a cena do diálogo foi atribuída no Inspector.
	# Isso ajuda a evitar o erro "Cannot call method 'instantiate' on a null value".
	if dialogue_box_scene == null:
		print("Erro: A cena de diálogo não foi atribuída no Inspector!")
	
	# Verifica se a cena da próxima fase foi atribuída no Inspector.
	if next_level_scene == null:
		print("Erro: A cena da próxima fase não foi atribuída no Inspector!")

func _process(delta):
	# Condição para depuração.
	# Verifica se a tecla de interação ("interact") foi pressionada.
	if Input.is_action_just_pressed("interact"):
		print("Tecla de interação pressionada!")

	# Condição para iniciar a interação:
	# 1. O jogador precisa estar na área.
	# 2. O diálogo não pode já estar ativo.
	# 3. A tecla de interação ("interact") foi pressionada.
	if player_in_range and not dialogue_is_active and Input.is_action_just_pressed("interact"):
		show_dialogue()
	# Condição para avançar ou fechar o diálogo:
	# 1. O diálogo precisa estar ativo.
	# 2. A tecla de interação foi pressionada.
	elif dialogue_is_active and Input.is_action_just_pressed("interact"):
		change_scene()

func _on_interaction_area_body_entered(body):
	print("Jogador entrou na area de interação")
	# Verifica se o corpo que entrou é o jogador.
	if body.is_in_group("player"):
		player_in_range = true

func _on_interaction_area_body_exited(body):
	print("Jogador saiu da area de colisão")
	if body.is_in_group("player"):
		player_in_range = false

func show_dialogue():
	# Garante que a cena de diálogo existe antes de tentar instanciá-la.
	if dialogue_box_scene != null:
		# Define o estado do diálogo como ativo.
		dialogue_is_active = true
		
		# Instancia a cena do DialogueBox e a adiciona à árvore de nós.
		dialogue_instance = dialogue_box_scene.instantiate()
		get_tree().root.add_child(dialogue_instance)
	else:
		# Imprime um erro se a cena não foi atribuída.
		print("Erro: Não é possível instanciar. A cena de diálogo é nula!")

func change_scene():
	dialogue_is_active = false
	
	if is_instance_valid(dialogue_instance):
		dialogue_instance.queue_free()
	
	# Garante que a próxima cena existe antes de tentar carregá-la.
	if next_level_scene != null:
		get_tree().call_deferred("change_scene_to_file", next_level_scene.resource_path)
	else:
		print("Erro: A cena da próxima fase não foi atribuída!")
