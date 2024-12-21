extends PlayerCharacterBaseState

@export var walk_state: PlayerCharacterBaseState
@export var run_state: PlayerCharacterBaseState
@export var crouch_state: PlayerCharacterBaseState

func update(delta: float):
	super(delta)
	character_controller.follow_camera_rotation()

func physics_update(delta: float):
	super(delta)

	# Check for walking/running input
	if character_controller.get_locomotion_input_direction().length() > 0.01:
		if Input.is_action_pressed("player_run"):
			transitioned.emit(self, run_state)
		else:
			transitioned.emit(self, walk_state)
		return
	
	if Input.is_action_pressed("player_crouch"):
		transitioned.emit(self, crouch_state)
