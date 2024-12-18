class_name MultiplayerConnectMenu
extends MenuState 

@onready var main_menu_button: Button = %MainMenuButton

@onready var host_button: Button = %HostButton
@onready var join_button: Button = %JoinButton
@onready var copy_code_button: Button = %CopyCodeButton
@onready var hide_code_button: Button = %HideCodeButton

@onready var lobby_code_label: Label = %LobbyCodeLabel
@onready var lobby_code_input: LineEdit = %LobbyCodeInput

@export var main_menu_state: MenuState 

var is_code_visible: bool:
	get:
		return is_code_visible
	set(value):
		is_code_visible = value
		
		lobby_code_input.secret = !is_code_visible

		if is_code_visible:
			lobby_code_label.text = MultiplayerManager.lobby_code
			hide_code_button.text = "Hide Lobby Code"
		else:
			lobby_code_label.text = "*".repeat(MultiplayerManager.lobby_code_length)
			hide_code_button.text = "Show Lobby Code"

func _ready():
	_connect_signals()

	is_code_visible = true
	join_button.disabled = len(lobby_code_input.text) < MultiplayerManager.lobby_code_length
	lobby_code_input.max_length = MultiplayerManager.lobby_code_length

func _exit_tree():
	_disconnect_signals()

func enter():
	super()
	MultiplayerManager.create_hole_puncher()

func exit():
	super()
	MultiplayerManager.close_connection()
	MultiplayerManager.lobby_code = ""

##
## PRIVATE METHODS
##

func _start_hosting_lobby():
	MultiplayerManager.is_host = true

	# Set lobby code
	var code_string := MultiplayerManager.generate_lobby_code()
	MultiplayerManager.lobby_code = code_string

	MultiplayerManager.start_traversal()

func _start_joining_lobby():
	if lobby_code_input.text.is_empty(): return

	MultiplayerManager.is_host = false
	MultiplayerManager.lobby_code = lobby_code_input.text.to_lower()
	
	MultiplayerManager.start_traversal()

func _connect_signals():
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	host_button.pressed.connect(_on_host_pressed)
	copy_code_button.pressed.connect(_on_copy_code_pressed)
	join_button.pressed.connect(_on_join_pressed)
	hide_code_button.pressed.connect(_on_hide_code_pressed)
	lobby_code_input.text_changed.connect(_on_lobby_code_text_changed)

	MultiplayerManager.lobby_code_changed.connect(_on_lobby_code_changed)
	MultiplayerManager.hole_punched.connect(_on_multiplayer_hole_punched)

func _disconnect_signals():
	main_menu_button.pressed.disconnect(_on_main_menu_pressed)
	host_button.pressed.disconnect(_on_host_pressed)
	copy_code_button.pressed.disconnect(_on_copy_code_pressed)
	join_button.pressed.disconnect(_on_join_pressed)
	hide_code_button.pressed.disconnect(_on_hide_code_pressed)
	lobby_code_input.text_changed.disconnect(_on_lobby_code_text_changed)

	MultiplayerManager.hole_punched.disconnect(_on_multiplayer_hole_punched)

##
## SIGNALS
##

func _on_main_menu_pressed():
	self.transitioned.emit(self, main_menu_state)

func _on_host_pressed():
	_start_hosting_lobby()

func _on_copy_code_pressed():
	if MultiplayerManager.lobby_code.is_empty(): return
	DisplayServer.clipboard_set(MultiplayerManager.lobby_code.to_upper())

func _on_join_pressed():
	_start_joining_lobby()

func _on_hide_code_pressed():
	is_code_visible = !is_code_visible

func _on_lobby_code_text_changed(new_text: String):
	var caret_col = lobby_code_input.caret_column
	lobby_code_input.text = new_text.to_upper()
	lobby_code_input.caret_column = caret_col

	join_button.disabled = len(lobby_code_input.text) < MultiplayerManager.lobby_code_length

func _on_lobby_code_changed(code: String):
	lobby_code_label.text = code

func _on_multiplayer_hole_punched(my_port: int, host_port: int, host_address: String):
	print("Hole punched | client port: %s, host_port: %s, host_address: %s" % [my_port, host_port, host_address])
