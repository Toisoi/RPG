extends LimboState

func _update(_delta):
	var vector = agent.get_vector()
	if vector != Vector2.ZERO:
		get_root().dispatch(EVENT_FINISHED)
