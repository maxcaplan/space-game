class_name PlayerCharacterBaseState
extends BaseState

@export var animation_state_name: String

var character_controller: PlayerCharacterController

func enter():
	super()
	if !animation_state_name.is_empty():
		character_controller.animation_locomotion_state_machine.travel(animation_state_name)