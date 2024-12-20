extends Node

@onready var bone_marker: Node3D = %BoneMarker

@export var skeleton: Skeleton3D
@export var bone_name: String
@export var target: Node3D

## Determins if the bone will activly look at the target each frame
@export var active: bool = false

@export_group("Invert")
@export var invert_x: bool = false
@export var invert_y: bool = false

@export_group("Clamping")
@export var clamp_x: bool = false
@export var clamp_y: bool = false

@export var x_clamp_min: float = -180
@export var x_clamp_max: float = 180

@export var y_clamp_min: float = -180
@export var y_clamp_max: float = 180

var bone_idx: int = -1

func _ready():
	_get_bone_parameter()

func _process(_delta):
	if !active: return

	bone_look_at_target()

##
## METHODS
##

func bone_look_at_target():
	if skeleton == null:
		printerr("skeleton is not set")
		return

	if bone_idx < 0:
		printerr("Can not find index for bone with name \"%s\"" % bone_name)
		return

	if target == null:
		printerr("target is not set")
		return

	var bone_local_trans = skeleton.get_bone_global_pose(bone_idx)
	var bone_global_trans = skeleton.to_global(bone_local_trans.origin)

	bone_marker.global_position = bone_global_trans
	bone_marker.look_at(target.global_position)

	bone_marker.global_rotation.y -= skeleton.global_rotation.y

	if invert_x:
		bone_marker.rotation.x *= -1
	if invert_y:
		bone_marker.rotation.y *= -1
	
	if clamp_x:
		bone_marker.rotation.x = clamp(bone_marker.rotation.x, deg_to_rad(x_clamp_min), deg_to_rad(x_clamp_max))
	if clamp_y:
		bone_marker.rotation.y = clamp(bone_marker.rotation.y, deg_to_rad(y_clamp_min), deg_to_rad(y_clamp_max))
	

	var new_bone_rot = Quaternion.from_euler(bone_marker.global_rotation)

	skeleton.set_bone_pose_rotation(bone_idx, new_bone_rot)
	

##
##
##

func _get_bone_parameter():
	var idx = skeleton.find_bone(bone_name)

	if idx < 0:
		printerr("Unable to find bone with name \"%s\"" % bone_name)
	
	bone_idx = idx
