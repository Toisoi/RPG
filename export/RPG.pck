GDPC                �
                                                                          P   res://.godot/exported/133200997/export-69e963a49695dd4030e5c61a12b8ddfe-game.scn�6      �N      ̰���D:JS��wD    T   res://.godot/exported/133200997/export-af43f1489f8ddd2e3337968c398c1c3c-player.scn  �,      �      q�C�1k������    ,   res://.godot/global_script_class_cache.cfg  P�             ��Р�8���8~$}P�    T   res://.godot/imported/bar_stamina_progress.png-acd542ef5838edfe83df447ed62fb2fa.ctex 4      ^       f��]�rqˢ�mo#%    L   res://.godot/imported/bar_under.png-23e6c61448c352241683037935588a62.ctex   `5      ^       �!�KBUd��B	�g    D   res://.godot/imported/icon.svg-218a8f2b3041327d8a5756f3a245f83b.ctex��             �u�-�Q��^����R�    H   res://.godot/imported/player.png-01de7ab6f3d9cf460faf3d087d125741.ctex  P+      ^       &ێ
]��9_������    H   res://.godot/imported/tilieset.png-c935442394d588b0c66d786b7f17b563.ctex �      �       '}�3����v��jh[       res://.godot/uid_cache.bin  0�      /      ���ɪ�L��u�ǡ�       res://ai/tasks/arrive_pos.gd              ̍$���z�h���       res://ai/tasks/back_away.gd             Ğx�I��,0mװ��        res://ai/tasks/face_target.gd          �      ��)�0ì ��BBm    $   res://ai/tasks/get_first_in_group.gd�	      �      �������$ �/\�z       res://ai/tasks/in_range.gd  �      2      �83s�{*�|ƣ��l�q    (   res://ai/tasks/is_aligned_with_target.gd�      �      6K�l��{.��'K        res://ai/tasks/move_forward.gd  �      '      �R�Y����5�y����       res://ai/tasks/pursue.gd       D      {�G�}ݰό��!s    (   res://ai/tasks/select_flanking_pos.gd   P            Pu3�S�J6��D     ,   res://ai/tasks/select_random_nearby_pos.gd  `      �      �l�&�*�x8���޶       res://icon.svg  p�      �      C��=U���^Qu��U3       res://icon.svg.import   ��      �       ��8����#�@d�[        res://objects/player/player.gd  p$      �      #ʎZ�����'۱��    (   res://objects/player/player.png.import  �+      �       K��<��;�Z���X     (   res://objects/player/player.tscn.remap  p�      c       �g��}	�N t���<a    $   res://objects/player/states/idle.gd  !      �       F�v��7n��\4��`    (   res://objects/player/states/sprint.gd   �!      �      0m�����LQ"��;��7    $   res://objects/player/states/walk.gd �#      �       �~�^�W�|��/��~       res://project.binary`�      X      �Y.yE�}��������    $   res://scenes/game/game.tscn.remap   ��      a       >�~L�F�eB7c�~���    8   res://scenes/game/hud/bar_stamina_progress.png.import   �4      �       �쵶"�Ҭ"�F�S#�    ,   res://scenes/game/hud/bar_under.png.import  �5      �       �˟�J�58,*�Q�ѹ    (   res://scenes/game/tilieset.png.import   ��      �       z&PxG;-C�g+�/�        @tool
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
           @tool
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
 @tool
extends BTAction

@export var target_var: String = "target"

func _generate_name() -> String:
	return "FaceTarget " + LimboUtility.decorate_var(target_var)


func _tick(_delta: float) -> Status:
	var target: Node2D = blackboard.get_var(target_var)
	if not is_instance_valid(target):
		return FAILURE
	var dir: float = target.global_position.x - agent.global_position.x
	agent.velocity = Vector2.ZERO
	agent.face_dir(dir)
	return SUCCESS
     @tool
extends BTAction

@export var group: StringName
@export var output_var: String = "target"


func _generate_name() -> String:
	return "GetFirstNodeInGroup \"%s\"  ➜%s" % [
		group,
		LimboUtility.decorate_var(output_var)
		]

func _tick(_delta: float) -> Status:
	var nodes: Array[Node] = agent.get_tree().get_nodes_in_group(group)
	if nodes.size() == 0:
		return FAILURE
	blackboard.set_var(output_var, nodes[0])
	return SUCCESS
           @tool
extends BTCondition

@export var distance_min: float
@export var distance_max: float
@export var target_var := "target"

var _min_distance_squared: float
var _max_distance_squared: float

func _generate_name() -> String:
	return "InRange (%d, %d) of %s" % [distance_min, distance_max,
		LimboUtility.decorate_var(target_var)]


func _setup() -> void:
	_min_distance_squared = distance_min * distance_min
	_max_distance_squared = distance_max * distance_max


func _tick(_delta: float) -> Status:
	var target: Node2D = blackboard.get_var(target_var, null)
	if not is_instance_valid(target):
		return FAILURE

	var dist_sq: float = agent.global_position.distance_squared_to(target.global_position)
	if dist_sq >= _min_distance_squared and dist_sq <= _max_distance_squared:
		return SUCCESS
	else:
		return FAILURE
              @tool
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
    @tool
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
         @tool
extends BTAction

const TOLERANCE := 30.0

@export var target_var: String = "target"
@export var speed_var: String = "speed"
@export var approach_distance: float = 100.0

var _waypoint: Vector2

func _generate_name() -> String:
	return "Pursue %s" % [LimboUtility.decorate_var(target_var)]


func _enter() -> void:
	var target: Node2D = blackboard.get_var(target_var, null)
	if is_instance_valid(target):
		_select_new_waypoint(_get_desired_position(target))


func _tick(_delta: float) -> Status:
	var target: Node2D = blackboard.get_var(target_var, null)
	if not is_instance_valid(target):
		return FAILURE

	var desired_pos: Vector2 = _get_desired_position(target)
	if agent.global_position.distance_to(desired_pos) < TOLERANCE:
		return SUCCESS

	if agent.global_position.distance_to(_waypoint) < TOLERANCE:
		_select_new_waypoint(desired_pos)

	var speed: float = blackboard.get_var(speed_var, 200.0)
	var desired_velocity: Vector2 = agent.global_position.direction_to(_waypoint) * speed
	agent.move(desired_velocity)
	agent.update_facing()
	return RUNNING


func _get_desired_position(target: Node2D) -> Vector2:
	var side: float = signf(agent.global_position.x - target.global_position.x)
	var desired_pos: Vector2 = target.global_position
	desired_pos.x += approach_distance * side
	return desired_pos


func _select_new_waypoint(desired_position: Vector2) -> void:
	var distance_vector: Vector2 = desired_position - agent.global_position
	var angle_variation: float = randf_range(-0.2, 0.2)
	_waypoint = agent.global_position + distance_vector.limit_length(150.0).rotated(angle_variation)
            @tool
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

           @tool
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
extends LimboState

func _update(_delta):
	var vector = agent.get_vector()
	if vector != Vector2.ZERO:
		get_root().dispatch(EVENT_FINISHED)
   extends LimboState

@export var speed: float
@export var stamina_use: float
@export var stamina_recovery: float
@export var stamina_recovery_time: float

func _update(delta):
	var vector = agent.get_vector()
	
	agent.move(vector * speed)
	
	agent.use_stamina(stamina_use)
	
	if Input.is_action_just_released("sprint") or vector == Vector2.ZERO or not agent.can_sprint:
		get_root().dispatch(EVENT_FINISHED)


func _exit():
	agent.recovery_stamina(stamina_recovery, stamina_recovery_time)
        extends LimboState

@export var speed: float

func _update(_delta):
	var vector = agent.get_vector()
	
	agent.move(vector * speed)
	
	if vector == Vector2.ZERO:
		get_root().dispatch(EVENT_FINISHED)
         extends CharacterBody2D

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


func move(vel: Vector2) -> void:
	velocity = vel
	move_and_slide()


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
        GST2            ����                        &   RIFF   WEBPVP8L   /  ���������    [remap]

importer="texture"
type="CompressedTexture2D"
uid="uid://w6js1n0w13j1"
path="res://.godot/imported/player.png-01de7ab6f3d9cf460faf3d087d125741.ctex"
metadata={
"vram_texture": false
}
               RSRC                    PackedScene            ��������                                            
   	   LimboHSM 
   IdleState 
   WalkState    SprintState    resource_local_to_scene    resource_name    custom_solver_bias    size    script 	   _bundled       Script    res://objects/player/player.gd ��������
   Texture2D     res://objects/player/player.png L����[S   Script $   res://objects/player/states/idle.gd ��������   Script $   res://objects/player/states/walk.gd ��������   Script &   res://objects/player/states/sprint.gd ��������      local://RectangleShape2D_hjrpw �         local://PackedScene_4s7fj �         RectangleShape2D       
     �@  @@         PackedScene    	      	         names "         Player    scale    collision_layer    collision_mask    script    hsm    idle_state    walk_state    sprint_state    player    CharacterBody2D 	   Sprite2D    texture    CollisionShape2D 	   position    shape 	   Camera2D 	   LimboHSM 
   IdleState    LimboState 
   WalkState    speed    SprintState    stamina_use    stamina_recovery    stamina_recovery_time    	   variants       
     �@  �@                                                                                
         �@                                 HC              �C     �A      @      node_count             nodes     _   ��������
       ����                              @     @     @     @      	                 ����                           ����      	      
                     ����                      ����                     ����                          ����                                ����                                           conn_count              conns               node_paths              editable_instances              version             RSRC             GST2   0         ����               0         &   RIFF   WEBPVP8L   //� ���W�����    [remap]

importer="texture"
type="CompressedTexture2D"
uid="uid://bofgwn14xb05s"
path="res://.godot/imported/bar_stamina_progress.png-acd542ef5838edfe83df447ed62fb2fa.ctex"
metadata={
"vram_texture": false
}
                GST2   0         ����               0         &   RIFF   WEBPVP8L   //� P��U�����    [remap]

importer="texture"
type="CompressedTexture2D"
uid="uid://dssdq8gn4tpc"
path="res://.godot/imported/bar_under.png-23e6c61448c352241683037935588a62.ctex"
metadata={
"vram_texture": false
}
            RSRC                    PackedScene            ��������                                            (      ..    CanvasLayer    StaminaProgressBar    resource_local_to_scene    resource_name    texture    margins    separation    texture_region_size    use_texture_padding    0:0/0 &   0:0/0/physics_layer_0/linear_velocity '   0:0/0/physics_layer_0/angular_velocity    0:0/0/script    1:0/0 &   1:0/0/physics_layer_0/linear_velocity '   1:0/0/physics_layer_0/angular_velocity    1:0/0/script    0:1/0 &   0:1/0/physics_layer_0/linear_velocity '   0:1/0/physics_layer_0/angular_velocity '   0:1/0/physics_layer_0/polygon_0/points    0:1/0/script    1:1/0 &   1:1/0/physics_layer_0/linear_velocity '   1:1/0/physics_layer_0/angular_velocity    1:1/0/script    script    tile_shape    tile_layout    tile_offset_axis 
   tile_size    uv_clipping     physics_layer_0/collision_layer    physics_layer_0/collision_mask 
   sources/0    tile_proxies/source_level    tile_proxies/coords_level    tile_proxies/alternative_level 	   _bundled    
   Texture2D    res://scenes/game/tilieset.png CR���U+   PackedScene !   res://objects/player/player.tscn Hq���
   Texture2D $   res://scenes/game/hud/bar_under.png ��� t
   Texture2D /   res://scenes/game/hud/bar_stamina_progress.png ���m�m�.   !   local://TileSetAtlasSource_7m11y �         local://TileSet_ag5nk �         local://PackedScene_0dmiq          TileSetAtlasSource                 
             
                                        
                                        
                        %         �   �   A   �   A   A   �   A                   
                                    TileSet    !         "         #                      PackedScene    '      	         names "         Game    Node2D    TileMap    scale 	   tile_set    format    layer_0/tile_data    Player 	   position    stamina_progress_bar    CanvasLayer    StaminaProgressBar    custom_minimum_size    offset_left    offset_top    offset_right    offset_bottom    step    value    nine_patch_stretch    texture_under    texture_progress    TextureProgressBar    	   variants       
     @@  @@                   �                                                                                                        	           
                                                                                                                                      	          
                                                                                                                                   	          
                                                                                                                                   	          
                                                                                                                                   	          
                                                                                                                                   	          
                                                                                                                                   	          
                                                                                                                                   	          
                                                                                                                                	          
                                       	           	          	          	          	          	         	         	         	          	 	         	 
         	          	          	          
           
          
          
          
          
         
         
         
          
 	         
 
         
          
          
                                                                                                      	          
                                                                                                                                   	          
                                                                                                                                   	          
                                                                                                                                   	          
                                                                                                                                   	          
                                                                                                                                   	          
                                                                                                                                   	          
                                                                                                                                   	          
                                                                                                                                   	          
                                                                                                                                   	          
                                                                                                                                	          
                                                                                                                             	          
                                                                                                                             	          
                                      ��        ��        ��        ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��      	 ��      	 ��      	 ��      	 ��      
 ��      
 ��      
 ��      
 ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��        ��        ��        ��        ��      ! ��      ! ��      ! ��      ! ��      " ��      " ��      " ��      " ��      # ��      # ��      # ��      # ��      $ ��      $ ��      $ ��      $ ��      !         !        !        !        !        !        !        !        !        ! 	       ! 
       !        !        !        !        !        !        !        "         "        "        "        "        "        "        "        "        " 	       " 
       "        "        "        "        "        "        "        #         #        #        #        #        #        #        #        #        # 	       # 
       #        #        #        #        #        #        #        $         $        $        $        $        $        $        $        $        $ 	       $ 
       $        $        $        $        $        $        $        ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��                                                                                                                                                                                                                                                                                                                                                                             	          	          	         	         
          
          
          
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              ����      ����      ����      ����      ��        ��       ��       ��       ��       ��       ��       ��       ��       ��	       ��
       ��       ��       ��       ����      ����      ����      ����      ��        ��       ��       ��       ��       ��       ��       ��       ��       ��	       ��
       ��       ��       ��       ����      ����      ����      ����      ��        ��       ��       ��       ��       ��       ��       ��       ��       ��	       ��
       ��       ��       ��       ����      ����      ����      ����      ��        ��       ��       ��       ��       ��       ��       ��       ��       ��	       ��
       ��       ��       ��                                                                                                                                                                                                                            	          
                                                                   
          	                                                                                                                                                                          	          
                                                                      
          	                                                                                          	          
                                                                      
          	                                                                                                                                                                                                	          
                                                                      
          	                                                                                                                                                                                                          	           
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 	         	         	         	         	          	          	          	          	          
          
          
          
          
          
          
          
          
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           !        !        !        !        !        !        !        !        !        !        !        !        !        "        "        "        "        "        "        "        "        "        "        "        "        "        #        #        #        #        #        #        #        #        #        #        #        #        #        $        $        $        $        $        $        $        $        $        $        $        $        $        ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��       ��                                                                                                                                                                                                                                                                                                           	        	        	        	        
        
        
        
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     
    ��C  #C                
      C   B     �@     %C     B)   {�G�z�?     �B                              node_count             nodes     C   ��������       ����                      ����                                        ���               	  @               
   
   ����                     ����
                        	      
                                           conn_count              conns               node_paths              editable_instances              version             RSRC              GST2              ����                          N   RIFFF   WEBPVP8L9   /�   J�;4�C ����4�� $ f������Gwf@�0�h�����?���
�[�m�           [remap]

importer="texture"
type="CompressedTexture2D"
uid="uid://bkquuntpvxlhb"
path="res://.godot/imported/tilieset.png-c935442394d588b0c66d786b7f17b563.ctex"
metadata={
"vram_texture": false
}
            GST2   �   �      ����               � �        �  RIFF�  WEBPVP8L�  /������!"2�H�m�m۬�}�p,�젮�N{2n�d��5���$I������ԇ$W�NT���H�ɊȌ�j���k��f�v칢�����n�d'��3���Gu��^�6R�Lw��@m��B���fZ��X�m���n�ضgֶm۶1�Iw=Ou*��۶����O�ii;@T�֏ٶڶ���vzw�WK��Cp#I��\ރخ}C\A6���$
2#�E.@$���A.��	G��( RD!F�JWl��$@G����� ����:ȁ�)��D]Rٴ"����P��ZK�*�F�Ww$+�wz=˻>�Ӗn�8�]�f���bw��C�AK�����貂���-ݺq��EO��U��1b8���KK���]�h�{Bb�k@#�Nu��m�h
�C��Cȩ��[�U�P.e�F�#��jqc���m�w��,ݺ�|���AfZ_���u2�Żm�ҭS�wj [ȅq=K�\�����q�G���� ����>�.W6�?�(ݺh���|��y��o��FRo�����w����N��I��e��Y��L�78�c%��ڔ[.�7l�NH�9�ʘ�\�Yʶ)vO\~�P��!�?�\��+P�o��Ⱥ�ŬZ���R�w�^5:!�Ta:Y�p��`��CJ���	)�z5�RF�u�5��$�,�M�0���n�m1�j�	�5��6h%sË�ص�R�:TB��W�q��6�o�=���V�_¡E0��y�ѬWT U�b�6Y�����?�xJJ1��z��ǃ�V���������Y�O�I����;����mM��d)sN��K�|)�z-Z�=��=�JI����J�k�OF��R��Te;m���m�$G��6�Ka����X�$�s�(�W�o��3!�l8s?+Ő�WS�t`��gojQ��F�Ӣ�VS���wuZRl�ס���^T�(_�^�*$��!�,����T�P���o�#��%�	����?�K������'Yʂ&9]����ˢ�Y��N�/YaZY�¦JƧ�#�?�R8��ʅ���,�R9�Q	�ZJ��`x�j݋�̝�!��X��,�o5�?���J�-��㳨փ�*L�R=4�;-��'���Pq�{1�YL�����	Q�:ET�:!�"ng%"�}�P	�L�ף����B.o��/�r���5,=���5���\�>�Ĺ��������/l�p�=d���{�_E�G��{���_��Y��θ���`X�3Pq���I+���@ 8;��>��	��+��o�6��
PEL�B�H�N�`������c�Q7Q2�+qQ�y�j�OC�C��?��DDb=�5~ħA ����Y���2���J]_�� A��zb�4/��ݏ:4o���$�+�B�  :���W�L |�����U+5�-�A�l�Ol}�ͭvD=��p"V��S��`�q|r�l	F� 4�1{�V'&�Y 鉡|pj� ߫'�?��Ȩ&�o�H#b��K����@D�˅ �x?Y-�pfV� ,!f�.�"86��j"�� '�J��CM�+ � Ĝ��"���,� ���Wo��	�0C����q'�5.��z@�S1,5ڴ�^��~L�t"�"�RS��Xw.�m[/����;�P�9��L��L�*]_����ur��s�3Ȗ+�^� �>�nnq�E�!R,<�D?����K�n�f�����m�QP�n�:b3�+��6�Yd)� e��-�� �z�`b=�;q�~�k��,�ܝj�?�W�X� @OwV�Џ�j��c��Ds�V�X ���\f�E���y��c��⋹�hx���ӗի�R�]�g�r�˶/����n�;�SSup`�S��6��u����f;Z�INs�|�oh�f�Pc�����^��gzt����x��)wq�Q�My53jƓa���8�6��,�F�ڸ����2��#�)���"�u���}'�"�>�����ǯ[����82һ�n�ٵ0�<v�ݑa}.+n��'����W:4Y�����P��(�k�Mȫۿ�Ϗ��?����Ӧ�K�|y�@suy��<�����{��x}~������~�IN=�s�ޝ�GG�����[�L}~�`�f%T�R!1�no���������v!�G���]��qw��m���E�Br�5���\1/.�j���c��g�\���p�,50l�>=}��
0���l�b�Y�+��dz����v+2ǚ�Ȋl	�Ȭ��"�H�Y&5�M���	ɗN�e؈�3�����n���|0X���
�W�C%�&5<��u�L��&9�6�#e��I��^e_ �G=�I�cΆ�J���>���N�/��׷�G��[���\��T��Ͷh���Qg?1��O��4{s{�����1�Y�����91Qry��=����y=/~٦h'�����[�tD�j��P����� *b��QN��������7��+K�e��T�@j��)��9;�J��JF�#������c��l���I{x�O��K��U��_]>>=_~}�����?��h�:� 5~}���/���߷˿˅8=+����ӝu��;镜�����\Ir�c��,���װ��ު�L�G���8�� �lG��Jr�){�|[�`��iO?޿�$�>�X��-<���r��r�x�������]_n�\
�^������o��u�w	������n�t{8���揫/�������7K�sp��~/{�$'mm�s�`z�wY������i�*��I�)���8t �?i�g�;].� ^ױ�[�o��[��R��w�*A��,�2h�f������}F��[�z!�p5���2hѥ�K���^	d��,������ps6��{���y;�2���=�<��s2�f��#=�bFsТ��i�CZ�A,��d���:T�;X�5�&hхͻ��1C�!hѮ^��7�������o�,��l@b��ze�� 1�w}���l�D.��Yz�r���T�#O�<��l��i#�S��!GĶ�EO}r�K����A�\�<N�zd!E��
R��z�S����x�ö�\.�2)"E �@3o9u�.y�@��e*H�m����]�h�HB.�#bD�j��V8ߥ��Eh���\�ejL�ku�;����l�>N{;����)�P���ʘ�R(E�����n�P.�5a��R7 �0bo��Y���k�%E��;����ÆB�2]m��ր^�Ȗ�4���1h�O������
(�WX[remap]

importer="texture"
type="CompressedTexture2D"
uid="uid://bljr4rckfn5al"
path="res://.godot/imported/icon.svg-218a8f2b3041327d8a5756f3a245f83b.ctex"
metadata={
"vram_texture": false
}
                [remap]

path="res://.godot/exported/133200997/export-af43f1489f8ddd2e3337968c398c1c3c-player.scn"
             [remap]

path="res://.godot/exported/133200997/export-69e963a49695dd4030e5c61a12b8ddfe-game.scn"
               list=Array[Dictionary]([])
     <svg height="128" width="128" xmlns="http://www.w3.org/2000/svg"><rect x="2" y="2" width="124" height="124" rx="14" fill="#363d52" stroke="#212532" stroke-width="4"/><g transform="scale(.101) translate(122 122)"><g fill="#fff"><path d="M105 673v33q407 354 814 0v-33z"/><path fill="#478cbf" d="m105 673 152 14q12 1 15 14l4 67 132 10 8-61q2-11 15-15h162q13 4 15 15l8 61 132-10 4-67q3-13 15-14l152-14V427q30-39 56-81-35-59-83-108-43 20-82 47-40-37-88-64 7-51 8-102-59-28-123-42-26 43-46 89-49-7-98 0-20-46-46-89-64 14-123 42 1 51 8 102-48 27-88 64-39-27-82-47-48 49-83 108 26 42 56 81zm0 33v39c0 276 813 276 813 0v-39l-134 12-5 69q-2 10-14 13l-162 11q-12 0-16-11l-10-65H447l-10 65q-4 11-16 11l-162-11q-12-3-14-13l-5-69z"/><path d="M483 600c3 34 55 34 58 0v-86c-3-34-55-34-58 0z"/><circle cx="725" cy="526" r="90"/><circle cx="299" cy="526" r="90"/></g><g fill="#414042"><circle cx="307" cy="532" r="60"/><circle cx="717" cy="532" r="60"/></g></g></svg>
             L����[S   res://objects/player/player.pngHq���    res://objects/player/player.tscn���m�m�..   res://scenes/game/hud/bar_stamina_progress.png��� t#   res://scenes/game/hud/bar_under.png���s��f"   res://scenes/game/game.tscnCR���U+   res://scenes/game/tilieset.png���=�,   res://icon.svg ECFG      application/config/name         RPG    application/run/main_scene$         res://scenes/game/game.tscn    application/config/features(   "         4.2    GL Compatibility       application/config/icon         res://icon.svg     display/window/stretch/mode         canvas_items   input/move_left�              deadzone      ?      events              InputEventKey         resource_local_to_scene           resource_name             device     ����	   window_id             alt_pressed           shift_pressed             ctrl_pressed          meta_pressed          pressed           keycode           physical_keycode   A   	   key_label             unicode    a      echo          script         input/move_right�              deadzone      ?      events              InputEventKey         resource_local_to_scene           resource_name             device     ����	   window_id             alt_pressed           shift_pressed             ctrl_pressed          meta_pressed          pressed           keycode           physical_keycode   D   	   key_label             unicode    d      echo          script         input/move_up�              deadzone      ?      events              InputEventKey         resource_local_to_scene           resource_name             device     ����	   window_id             alt_pressed           shift_pressed             ctrl_pressed          meta_pressed          pressed           keycode           physical_keycode   W   	   key_label             unicode    w      echo          script         input/move_down�              deadzone      ?      events              InputEventKey         resource_local_to_scene           resource_name             device     ����	   window_id             alt_pressed           shift_pressed             ctrl_pressed          meta_pressed          pressed           keycode           physical_keycode   S   	   key_label             unicode    s      echo          script         input/sprint�              deadzone      ?      events              InputEventKey         resource_local_to_scene           resource_name             device     ����	   window_id             alt_pressed           shift_pressed             ctrl_pressed          meta_pressed          pressed           keycode           physical_keycode    @ 	   key_label             unicode           echo          script         layer_names/2d_physics/layer_1         environment    layer_names/2d_physics/layer_2         player     layer_names/2d_physics/layer_3         enemies #   rendering/renderer/rendering_method         gl_compatibility*   rendering/renderer/rendering_method.mobile         gl_compatibility        