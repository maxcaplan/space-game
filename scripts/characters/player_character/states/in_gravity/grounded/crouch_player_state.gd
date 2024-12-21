extends PlayerCharacterBaseState

@export var idle_state: PlayerCharacterBaseState
@export var crouch_walk_state: PlayerCharacterBaseState

func enter():
	super()
	character_controller.set_camera_position(character_controller.camera_crouch_pos, true)

func exit():
	character_controller.set_camera_position(character_controller.camera_stand_pos, true)

func update(delta: float):
	super(delta)
	character_controller.follow_camera_rotation()

func physics_update(delta: float):
	super(delta)

	if !Input.is_action_pressed("player_crouch"):
		transitioned.emit(self, idle_state)