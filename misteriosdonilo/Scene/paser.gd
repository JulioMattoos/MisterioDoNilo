extends CharacterBody2D

var player_in_range = false

var dialogue_is_active = false

var dialogue_instance = null

@export var dialogue_box_scene : PackedScene
@export var next_level_scene : PackedScene

func _process(delta):

	if Input.is_action_just_pressed("interact"):
		print("Tecla de interação pressionada!")


	if player_in_range and not dialogue_is_active and Input.is_action_just_pressed("interact"):
		show_dialogue()
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

	dialogue_is_active = true
	

	dialogue_instance = dialogue_box_scene.instantiate()
	get_tree().root.add_child(dialogue_instance)


func change_scene():
	dialogue_is_active = false
	
	if is_instance_valid(dialogue_instance):
		dialogue_instance.queue_free()
		
	
	get_tree().change_scene_to_file("res://Scene/Fase_1.tscn")
