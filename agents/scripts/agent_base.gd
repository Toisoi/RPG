extends CharacterBody2D

@export var sprite: Sprite2D

func move(vel: Vector2) -> void:
	velocity = vel
	move_and_slide()


func update_facing() -> void:
	if velocity.x > 0 and not sprite.flip_h:
		sprite.flip_h = true
	elif velocity.x < 0 and sprite.flip_h:
		sprite.flip_h = false
