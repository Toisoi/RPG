extends CharacterBody2D

@export var sprite: AnimatedSprite2D

func move(vel: Vector2) -> void:
	velocity = vel
	move_and_slide()


func update_facing() -> void:
	if velocity.x > 0:
		sprite.flip_h = false
	elif velocity.x < 0:
		sprite.flip_h = true
