extends LimboState

@export var animation_player: AnimationPlayer

func _enter():
	animation_player.play("idle")


func _update(_delta):
	var vector = agent.get_vector()
	if vector != Vector2.ZERO:
		get_root().dispatch(EVENT_FINISHED)
