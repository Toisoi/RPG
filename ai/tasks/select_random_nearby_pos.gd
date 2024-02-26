@tool
extends BTAction

@export var range_min: float = 300.0
@export var range_max: float = 500.0
@export var position_var: String = "pos"

func _generate_name() -> String:
	return "SelectRandomNearbyPos  range: [%s, %s]  ➜%s" % [
		range_min, range_max,
		LimboUtility.decorate_var(position_var)]


func _tick(_delta: float) -> Status:
	var pos: Vector2
	var is_good_position: bool = false
	while not is_good_position:
		var angle: float = randf() * TAU
		var rand_distance: float = randf_range(range_min, range_max)
		pos = agent.global_position + Vector2(sin(angle), cos(angle)) * rand_distance
		is_good_position = agent.is_good_position(pos)
	blackboard.set_var(position_var, pos)
	return SUCCESS
