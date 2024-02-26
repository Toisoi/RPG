@tool
extends BTCondition

@export var target_var: String = "target"
@export var tolerance: float = 30.0

func _generate_name() -> String:
	return "IsAlignedWithTarget " + LimboUtility.decorate_var(target_var)


func _tick(_delta: float) -> Status:
	var target := blackboard.get_var(target_var) as Node2D
	if not is_instance_valid(target):
		return FAILURE
	var y_diff: float = absf(target.global_position.y - agent.global_position.y)
	if y_diff < tolerance:
		return SUCCESS
	return FAILURE
