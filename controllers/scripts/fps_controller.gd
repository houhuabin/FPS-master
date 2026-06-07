extends CharacterBody3D

@export var SPEED: float = 4
@export var CROUCH_MOVE_SPEED: float = 1.2
@export var TOGGLE_CROUCH: bool = true
@export var JUMP_VELOCITY: float = 4.5

@export_range(0.5, 10.0, 0.1)
var CROUCH_ANIMATION_SPEED: float = 2.0

@export var MOUSE_SENSITIVITY: float = 0.5

@export var TILT_LOWER_LIMIT := deg_to_rad(-90.0)
@export var TILT_UPPER_LIMIT := deg_to_rad(90.0)

@export var CAMERA_CONTROLLER: Camera3D
@export var AMINATIONPLAYER: AnimationPlayer
@export var CROUCH_SHAPCAST: ShapeCast3D

var _mouse_input: bool = false
var _rotation_input: float = 0.0
var _tilt_input: float = 0.0

var _mouse_rotation: Vector3
var _player_rotation: Vector3
var _camera_rotation: Vector3

var _is_crouching: bool = false

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	if CROUCH_SHAPCAST:
		CROUCH_SHAPCAST.add_exception(self)


func _unhandled_input(event: InputEvent) -> void:

	_mouse_input = (
		event is InputEventMouseMotion
		and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	)

	if _mouse_input:
		_rotation_input = -event.relative.x * MOUSE_SENSITIVITY
		_tilt_input = -event.relative.y * MOUSE_SENSITIVITY


func _input(event):

	if event.is_action_pressed("exit"):
		get_tree().quit()

	if TOGGLE_CROUCH:

		if event.is_action_pressed("crouch") and is_on_floor():
			toggle_crouch()

	else:

		if event.is_action_pressed("crouch") and is_on_floor():
			crouch()

		elif event.is_action_released("crouch"):
			stand_up()


func toggle_crouch():

	if _is_crouching:
		stand_up()
	else:
		crouch()


func crouch():

	if _is_crouching:
		return

	AMINATIONPLAYER.play(
		"crouch",
		-1,
		CROUCH_ANIMATION_SPEED
	)

	_is_crouching = true


func stand_up():

	if !_is_crouching:
		return

	CROUCH_SHAPCAST.force_shapecast_update()

	if CROUCH_SHAPCAST.is_colliding():
		return

	AMINATIONPLAYER.play(
		"crouch",
		-1,
		-CROUCH_ANIMATION_SPEED,
		true
	)

	_is_crouching = false


func _update_camera(delta):

	_mouse_rotation.x += _tilt_input * delta

	_mouse_rotation.x = clamp(
		_mouse_rotation.x,
		TILT_LOWER_LIMIT,
		TILT_UPPER_LIMIT
	)

	_mouse_rotation.y += _rotation_input * delta

	_player_rotation = Vector3(
		0.0,
		_mouse_rotation.y,
		0.0
	)

	_camera_rotation = Vector3(
		_mouse_rotation.x,
		0.0,
		0.0
	)

	CAMERA_CONTROLLER.transform.basis = Basis.from_euler(
		_camera_rotation
	)

	global_transform.basis = Basis.from_euler(
		_player_rotation
	)

	CAMERA_CONTROLLER.rotation.z = 0.0

	_rotation_input = 0.0
	_tilt_input = 0.0


func _physics_process(delta):

	_update_camera(delta)

	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("jump") \
	and is_on_floor() \
	and !_is_crouching:

		velocity.y = JUMP_VELOCITY

	var input_dir = Input.get_vector(
		"move_left",
		"move_right",
		"move_forward",
		"move_backward"
	)

	var direction = (
		transform.basis
		* Vector3(input_dir.x, 0, input_dir.y)
	).normalized()

	var current_speed = SPEED

	if _is_crouching:
		current_speed = CROUCH_MOVE_SPEED

	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(
			velocity.x,
			0,
			current_speed
		)

		velocity.z = move_toward(
			velocity.z,
			0,
			current_speed
		)

	move_and_slide()
