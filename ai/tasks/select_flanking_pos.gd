@tool
extends BTAction

enum AgentSide {
	CLOSEST,
	FARTHEST,
	BACK,
	FRONT,
}

@export var target_var: String = "target"
@export var flank_side: AgentSide = AgentSide.CLOSEST
@export var range_min: int = 300
@export var range_max: int = 400
@export var position_var: String = "pos"

func _generate_name() -> String:
	return "SelectFlankingPos  target: %s  range: [%s, %s]  side: %s  ➜%s" % [
		LimboUtility.decorate_var(target_var),
		range_min,
		range_max,
		AgentSide.keys()[flank_side],
		LimboUtility.decorate_var(position_var)]


func _tick(_delta: float) -> Status:
	var target := blackboard.get_var(target_var) as Node2D
	if not is_instance_valid(target):
		return FAILURE

	var dir: float
	match flank_side:
		AgentSide.FARTHEST:
			dir = signf(target.global_position.x - agent.global_position.x)
		AgentSide.CLOSEST :
			dir = -signf(target.global_position.x - agent.global_position.x)
		AgentSide.BACK:
			dir = -target.get_facing()
		AgentSide.FRONT:
			dir = target.get_facing()

	var flank_pos: Vector2
	var offset := Vector2(dir * randf_range(range_min, range_max), 0.0)
	flank_pos = target.global_position + offset
	if not agent.is_good_position(flank_pos):
		flank_pos = target.global_position - offset
	blackboard.set_var(position_var, flank_pos)
	return SUCCESS

