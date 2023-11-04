extends CharacterBody2D

@export var movement_data : PlayerMovementData

var air_jump = false
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var coyote_jump_timer = $CoyoteJumpTimer
@onready var starting_pos = global_position


func _physics_process(delta):
	apply_gravity(delta)
	handle_jump()
	handle_wall_jump()
	var input_axis = Input.get_axis("move_left", "move_right")
	handle_acceleration(input_axis, delta)
	apply_friction(input_axis, delta)
	update_animations(input_axis)

	var was_on_floor = is_on_floor()
	move_and_slide()
	var just_left_ledge = was_on_floor and not is_on_floor() and velocity.y >= 0

	if just_left_ledge:
		coyote_jump_timer.start()


func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta * movement_data.gravity_scale

func handle_jump():
	if is_on_floor(): air_jump = true

	if is_on_floor() or coyote_jump_timer.time_left > 0.0:
		if Input.is_action_just_pressed("jump"):
			velocity.y = movement_data.jump_velocity
	elif not is_on_floor():
		if Input.is_action_just_released("jump") and velocity.y < movement_data.jump_velocity / 2:
			velocity.y = movement_data.jump_velocity / 2

		if Input.is_action_just_pressed("jump") and air_jump:
			velocity.y = movement_data.jump_velocity * movement_data.air_jump_scale
			air_jump = false

func handle_wall_jump():
	if not is_on_wall_only(): return

	var wall_normal = get_wall_normal()
	if (
		(Input.is_action_just_pressed("move_left") and wall_normal == Vector2.LEFT)
		or (Input.is_action_just_pressed("move_right") and wall_normal == Vector2.RIGHT)
	)	:
		velocity.x = wall_normal.x * movement_data.speed
		velocity.y = movement_data.jump_velocity


func apply_friction(input_axis, delta):
	
	if not input_axis:
		var target = movement_data.friction if is_on_floor() else movement_data.air_resistance
		velocity.x = move_toward(velocity.x, 0, target * delta)
			


func handle_acceleration(input_axis, delta):
	if input_axis:
		var target = movement_data.acceleration if is_on_floor() else movement_data.air_acceleration
		velocity.x = move_toward(
			velocity.x, movement_data.speed * input_axis, target * delta
		)


func update_animations(input_axis):
	if input_axis:
		animated_sprite_2d.flip_h = input_axis < 0
		animated_sprite_2d.play("run")
	else:
		animated_sprite_2d.play("idle")

	if not is_on_floor():
		animated_sprite_2d.play("jump")


func _on_hazard_detector_area_entered(area):
	global_position = starting_pos
