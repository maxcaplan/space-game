extends Node3D

@onready var camera: Camera3D = %Camera3D
@onready var camera_pitch: Node3D = %CameraPitch
@onready var camera_yaw: Node3D = self

## Determins if the camera controller is activly capturing camera movement
@export var active: bool = false:
	set(value):
		active = value

		if capture_mouse_while_active && value && current:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		
		if visbible_mouse_while_inactive && !value && current:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

## Determins if the camera controllers camera is the current camera of the viewport
@export var current: bool = false:
	set(value):
		current = value

		if camera != null:
			camera.current = value

## Determins if the mouse should be captured when the controller is active. Will only capture if the camera is current
@export var capture_mouse_while_active: bool = true
## Determins if the mouse should be made visible when the controller is inactive. Will only change mouse visibility if the camera is current
@export var visbible_mouse_while_inactive: bool = false

@export_group("Control Settings")
@export var look_sensitivity: Vector2 = Vector2(0.01, 0.01)
@export var invert_camera_x: bool = false
@export var invert_camera_y: bool = false
@export var camera_max_pitch: float = 85
@export var camera_min_pitch: float = -80

func _ready():
	if camera != null:
		camera.current = current
	
	if capture_mouse_while_active && active && current:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	if visbible_mouse_while_inactive && !active && current:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _unhandled_input(event: InputEvent):
	if !active: return

	if event is InputEventMouseMotion:
		_handle_mouse_motion(event)
		

##
## PRIVATE METHODS
##

func _handle_mouse_motion(event: InputEventMouseMotion):
	var yaw_rotation = -event.relative.x * look_sensitivity.x
	var pitch_rotation = -event.relative.y * look_sensitivity.y

	if invert_camera_x: yaw_rotation *= -1
	if invert_camera_y: pitch_rotation *= -1

	camera_yaw.rotate_y(yaw_rotation)
	camera_pitch.rotate_x(pitch_rotation)

	camera_pitch.rotation.x = clampf(camera_pitch.rotation.x, deg_to_rad(camera_min_pitch), deg_to_rad(camera_max_pitch))