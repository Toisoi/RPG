@tool
extends BTAction

@export var target_position_var := "pos"
@export var speed_var := "speed"
@export var tolerance := 50.0
@export var avoid_var: String


func _generate_name() -> String:
	return "Arrive  pos: %s%s" % [
		LimboUtility.decorate_var(target_position_var),
		"" if avoid_var.is_empty() else "  avoid: " + LimboUtility.decorate_var(avoid_var)
	]


func _tick(_delta: float) -> Status:
	var target_pos: Vector2 = blackboard.get_var(target_position_var, Vector2.ZERO)
	if target_pos.distance_to(agent.global_position) < tolerance:
		return SUCCESS

	var speed: float = blackboard.get_var(speed_var, 10.0)
	var dist: float = absf(agent.global_position.x - target_pos.x)
	var dir: Vector2 = agent.global_position.direction_to(target_pos)

	var vertical_factor: float = remap(dist, 200.0, 500.0, 1.0, 0.0)
	vertical_factor = clampf(vertical_factor, 0.0, 1.0)
	dir.y *= vertical_factor

	if not avoid_var.is_empty():
		var avoid_node: Node2D = blackboard.get_var(avoid_var)
		if is_instance_valid(avoid_node):
			var distance_vector: Vector2 = avoid_node.global_position - agent.global_position
			if dir.dot(distance_vector) > 0.0:
				var side := dir.rotated(PI * 0.5).normalized()
				var strength: float = remap(distance_vector.length(), 200.0, 400.0, 1.0, 0.0)
				strength = clampf(strength, 0.0, 1.0)
				var avoidance := side * signf(-side.dot(distance_vector)) * strength
				dir += avoidance

	var desired_velocity: Vector2 = dir.normalized() * speed
	agent.move(desired_velocity)
	agent.update_facing()
	return RUNNING
