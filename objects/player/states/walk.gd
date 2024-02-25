extends LimboState

@export var speed: float

func _update(_delta):
	var vector = agent.get_vector()
	
	agent.move(vector * speed)
	
	if vector == Vector2.ZERO:
		get_root().dispatch(EVENT_FINISHED)
