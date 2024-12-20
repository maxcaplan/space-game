class_name StateMachine
extends Node

@export var initial_state : BaseState 
@export var auto_start: bool = true
@export var debug : bool = false

var current_state : BaseState
var states : Dictionary = {}

signal transitioned(state: BaseState, new_state: BaseState)

func _ready():
	states = init_child_states()
	if auto_start:
		start()

func _process(delta):
	if not current_state:
		return
	
	current_state.update(delta)

func _physics_process(delta):
	if not current_state:
		return
	
	current_state.physics_update(delta)

func _input(event):
	if not current_state:
		return
	
	current_state.input(event)

func _unhandled_input(event):
	if not current_state:
		return
	
	current_state.unhandled_input(event)

##
## METHODS
##

## Starts the state machine entering an initial state
func start(state: BaseState = initial_state) -> void:
	change_state(state)

## Changes the current state to a new state
func change_state(new_state: BaseState) -> void:
	if current_state == new_state:
		return

	if current_state:
		current_state.exit()

	var old_state = current_state
	
	current_state = new_state
	current_state.enter()
	
	transitioned.emit(old_state, current_state)
	
	if debug: print(current_state.name)

## Get all child state nodes and connect transition signal
func init_child_states() -> Dictionary:
	var child_states: Dictionary = {}
	
	for child in get_children():
		if child is BaseState:
			child_states[child.name] = child
			child.transitioned.connect(_on_child_transition)
	
	return child_states

##
## SIGNAL FUNCTIONS
##

func _on_child_transition(state: BaseState, new_state: BaseState):
	if state != current_state:
		return
	
	if !states.has(new_state.name):
		return
	
	change_state(new_state)
