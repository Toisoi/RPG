extends "res://agents/scripts/agent_base.gd"

@export var navigation_agent: NavigationAgent2D

func get_next_point(target_position: Vector2) -> Vector2:
	navigation_agent.target_position = target_position
	return navigation_agent.get_next_path_position()
