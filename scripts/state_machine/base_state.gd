extends Node
class_name BaseState

signal transitioned(state: BaseState, new_state: BaseState)

var active := false:
	set = _set_active

func enter() -> void:
	active = true
	pass

func exit() -> void:
	active = false
	pass

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	pass

func input(_event: InputEvent) -> void:
	pass

func unhandled_input(_event: InputEvent) -> void:
	pass

func _set_active(value: bool) -> void:
	active = value