extends PlayerCharacterBaseState

func enter():
	super()
	character_controller.animation_locomotion_state_machine.travel("Walk")

func update(delta: float):
	super(delta)

	character_controller.follow_camera_rotation(true)