extends CharacterBody2D

const SPEED = 100.0

func _physics_process(delta: float) -> void:
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()

	velocity = input_vector * SPEED

	# Animações
	if input_vector != Vector2.ZERO:
		if abs(input_vector.x) > abs(input_vector.y):
			if input_vector.x > 0:
				$SkinKhepre.play("walk_right")
			else:
				$SkinKhepre.play("walk_left")
		else:
			if input_vector.y > 0:
				$SkinKhepre.play("walk_down")
			else:
				$SkinKhepre.play("walk_up")
	else:
		$SkinKhepre.stop()

	move_and_slide()
