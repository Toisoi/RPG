@tool
extends BTAction

@export var speed_var: String = "speed"
@export var duration: float = 0.1

func _generate_name() -> String:
	return "MoveForward  speed: %s  duration: %ss" % [
		LimboUtility.decorate_var(speed_var),
		duration]


func _tick(_delta: float) -> Status:
	var facing: float = agent.get_facing()
	var speed: float = blackboard.get_var(speed_var, 100.0)
	var desired_velocity: Vector2 = Vector2.RIGHT * facing * speed
	agent.move(desired_velocity)
	agent.update_facing()
	if elapsed_time > duration:
		return SUCCESS
	return RUNNING
