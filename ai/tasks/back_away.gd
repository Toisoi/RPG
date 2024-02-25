@tool
extends BTAction

@export var speed_var: String = "speed"
@export var max_angle_deviation: float = 0.7

var _dir: Vector2
var _desired_velocity: Vector2


func _enter() -> void:
	_dir = Vector2.LEFT * agent.get_facing()
	var speed: float = blackboard.get_var(speed_var, 200.0)
	var rand_angle = randf_range(-max_angle_deviation, max_angle_deviation)
	_desired_velocity = _dir.rotated(rand_angle) * speed


func _tick(_delta: float) -> Status:
	agent.move(_desired_velocity)
	agent.face_dir(-signf(_dir.x))
	return RUNNING
