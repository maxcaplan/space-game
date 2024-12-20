class_name PlayerCharacterController
extends Node3D

@onready var camera_controller: CharacterCameraController = %CameraController
@onready var animation_tree: AnimationTree = %AnimationTree
@onready var state_machine: StateMachine = %StateMachine
@onready var character_body: CharacterBody3D = %CharacterBody
@onready var model: Node3D = %Model

@export var player_camera_current: bool = false:
	set(value):
		player_camera_current = value
		if camera_controller != null:
			camera_controller.current = value

@export_group("Model Camera Follow", "model_camera_follow_")
@export var model_camera_follow_min_angle: float = -90
@export var model_camera_follow_max_angle: float = 90
@export_range(0.0, 1.0) var model_camera_follow_lerp_weight: float = 0.5

var animation_locomotion_state_machine: AnimationNodeStateMachinePlayback

func _ready():
	animation_locomotion_state_machine = animation_tree["parameters/LocomotionStateMachine/playback"]
	camera_controller.current = player_camera_current
	_init_states()
	state_machine.start()

##
## METHODS
##

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
