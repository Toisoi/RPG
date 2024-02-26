extends LimboState

@export var speed: float
@export var stamina_use: float
@export var stamina_recovery: float
@export var stamina_recovery_time: float

func _update(_delta):
	var vector = agent.get_vector()
	
	agent.move(vector * speed)
	
	agent.use_stamina(stamina_use)
	
	if Input.is_action_just_released("sprint") or vector == Vector2.ZERO or not agent.can_sprint:
		get_root().dispatch(EVENT_FINISHED)


func _exit():
	agent.recovery_stamina(stamina_recovery, stamina_recovery_time)
