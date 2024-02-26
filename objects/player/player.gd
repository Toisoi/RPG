extends "res://agents/scripts/agent_base.gd"

@export var hsm: LimboHSM
@export var idle_state: LimboState
@export var walk_state: LimboState
@export var sprint_state: LimboState

@export var stamina_progress_bar: TextureProgressBar

var can_sprint = true
var stamina_recovering = false

func _ready():
	hsm.add_transition(idle_state, walk_state, idle_state.EVENT_FINISHED)
	hsm.add_transition(walk_state, idle_state, walk_state.EVENT_FINISHED)
	hsm.add_transition(hsm.ANYSTATE, sprint_state, "sprint")
	hsm.add_transition(sprint_state, walk_state, sprint_state.EVENT_FINISHED)
	
	hsm.initialize(self)
	hsm.set_active(true)


func _unhandled_input(event):
	if event.is_action_pressed("sprint") and can_sprint:
		hsm.dispatch("sprint")


func use_stamina(usage: float) -> void:
	stamina_progress_bar.value -= usage * get_physics_process_delta_time()
	stamina_progress_bar.value = max(stamina_progress_bar.value, 0)
	
	if stamina_progress_bar.value == 0:
		can_sprint = false


func recovery_stamina(recovery: float, recovery_time: float) -> void:
	if not stamina_recovering:
		stamina_recovering = true
		await get_tree().create_timer(recovery_time).timeout
		while true:
			if stamina_progress_bar.value == stamina_progress_bar.max_value or hsm.get_active_state() == sprint_state:
				can_sprint = true
				stamina_recovering = false
				break
			
			stamina_progress_bar.value += recovery * get_physics_process_delta_time()
			stamina_progress_bar.value = min(stamina_progress_bar.value, stamina_progress_bar.max_value)
			await get_tree().create_timer(get_physics_process_delta_time()).timeout


func get_vector() -> Vector2:
	return Input.get_vector("move_left", "move_right", "move_up", "move_down")
