extends KinematicBody2D

# Raycasts
onready var lw_raycast = $Raycasts/LW_Raycast
onready var rw_raycast = $Raycasts/RW_Raycast
onready var g_raycast = $Raycasts/G_Raycast

# Movement
var direction = Vector2.ZERO
var speed = Vector2(20.0, 100.0)
var velocity = Vector2.ZERO


# Floor Normal
const FLOOR_NORMAL = Vector2.UP


# Additional Forces
var gravity = 200.0

func _physics_process(delta: float) -> void:
	direction = _get_direction(_get_character_movement_status())
	velocity = _calculate_velocity(direction, speed, velocity, _get_character_movement_status())
	velocity = move_and_slide(velocity, FLOOR_NORMAL)


func _get_direction(character_movement_status):
	if character_movement_status == "walking":
		direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
		direction.y = -1.0 if Input.get_action_strength("move_up") else 0.0
	elif character_movement_status == "wall_sliding":
		direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
		direction.y = -1.0 if Input.is_action_just_pressed("move_up") else 0.0
	
	return direction

func _calculate_velocity(
	direction: Vector2,
	speed: Vector2,
	velocity: Vector2,
	character_movement_status
):
	var out = velocity
	if character_movement_status == "on_air":
		out.y += gravity * get_physics_process_delta_time()
	
	if character_movement_status == "walking":
		out.x = direction.x * speed.x
		if direction.y == -1.0:
			out.y = speed.y * direction.y
	
	if character_movement_status == "wall_sliding":
		out.x = direction.x * speed.x
		out.y = 1
		if direction.y == -1.0:
			if lw_raycast.is_colliding():
				out.x =  100.0
				out.y = -100.0
			elif rw_raycast.is_colliding():
				out.x = -100.0
				out.y = -100.0
	
	return out


func _get_character_movement_status():
	var is_walking = false
	var is_wall_sliding = false
	
	if g_raycast.is_colliding():
		is_walking = true
		return "walking"
	elif lw_raycast.is_colliding() or rw_raycast.is_colliding():
		is_wall_sliding = true
		return "wall_sliding"
	else:
		return "on_air"
