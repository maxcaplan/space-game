class_name PlayerCharacterController
extends Node3D

@onready var camera_controller: CharacterCameraController = %CameraController
@onready var camera_stand_pos_marker: Marker3D = %CameraStandPosition
@onready var camera_crouch_pos_marker: Marker3D = %CameraCrouchPosition

@onready var animation_tree: AnimationTree = %AnimationTree
@onready var state_machine: StateMachine = %StateMachine

@onready var character_body: CharacterBody3D = %CharacterBody
@onready var model: Node3D = %Model

@export var player_camera_current: bool = false:
	set(value):
		player_camera_current = value
		if camera_controller != null:
			camera_controller.current = value

@export var camera_position_tween_duration: float = 0.5

@export_group("Model Camera Follow", "model_camera_follow_")
@export var model_camera_follow_min_angle: float = -90
@export var model_camera_follow_max_angle: float = 90
@export_range(0.0, 1.0) var model_camera_follow_lerp_weight: float = 0.5

var animation_locomotion_state_machine: AnimationNodeStateMachinePlayback

var camera_position_tween: Tween

var camera_stand_pos: Vector3:
	get:
		if camera_stand_pos_marker != null:
			return camera_stand_pos_marker.position
		return Vector3.ZERO

var camera_crouch_pos: Vector3:
	get:
		if camera_crouch_pos_marker != null:
			return camera_crouch_pos_marker.position
		return Vector3.ZERO

func _ready():
	animation_locomotion_state_machine = animation_tree["parameters/LocomotionStateMachine/playback"]
	camera_controller.current = player_camera_current
	_init_states()
	state_machine.start()

##
## METHODS
##

## Returns the normalized vector for player locomotion input direction
func get_locomotion_input_direction() -> Vector2:
	var left_right_axis = Input.get_axis("player_left", "player_right")
	var forward_backward_axis = Input.get_axis("player_backward", "player_forward")

	return Vector2(left_right_axis, forward_backward_axis).normalized()

func set_camera_position(new_position: Vector3, tweened: bool = true, duration: float = camera_position_tween_duration):
	if camera_position_tween != null:
		camera_position_tween.kill()
		camera_position_tween = null
	
	if !tweened:
		_set_camera_position_with_offset(new_position)
		return

	var current_camera_position = Vector3(camera_controller.camera_offset.x, camera_controller.position.y, camera_controller.camera_offset.z)

	camera_position_tween = get_tree().create_tween()
	camera_position_tween.tween_method(_set_camera_position_with_offset, current_camera_position, new_position, duration)

## Updates model rotation to follow the cameras rotation within bounds
func follow_camera_rotation(face_camera: bool = false, lerp_rotation: bool = face_camera, bounded: bool = true):
	if face_camera:
		if lerp_rotation:
			model.rotation.y = lerp_angle(model.rotation.y, camera_controller.rotation.y, model_camera_follow_lerp_weight)
		else:
			model.rotation.y = camera_controller.rotation.y
	
	if bounded:
		var model_cam_rot_diff = angle_difference(camera_controller.rotation.y, model.rotation.y)

		if model_cam_rot_diff > deg_to_rad(model_camera_follow_max_angle):
			var bound_diff = model_cam_rot_diff - deg_to_rad(model_camera_follow_max_angle)
			model.rotate_y(-bound_diff)
		
		if model_cam_rot_diff < deg_to_rad(model_camera_follow_min_angle):
			var bound_diff = model_cam_rot_diff - deg_to_rad(model_camera_follow_min_angle)
			model.rotate_y(-bound_diff)
##
## PRIVATE METHODS
##

## Initializes state machine states
func _init_states():
	for key in state_machine.states:
		if state_machine.states[key] is PlayerCharacterBaseState:
			state_machine.states[key].character_controller = self

func _set_camera_position_with_offset(new_position: Vector3):
	camera_controller.position.y = new_position.y
	camera_controller.camera_offset = Vector3(new_position.x, 0, new_position.z)
