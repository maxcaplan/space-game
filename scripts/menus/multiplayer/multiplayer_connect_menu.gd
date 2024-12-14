extends Control

@export var host_button: Button
@export var join_button: Button
@export var copy_code_button: Button
@export var hide_code_button: Button

@export var lobby_code_label: Label
@export var lobby_code_input: LineEdit

var is_code_visible: bool:
    get:
        return is_code_visible
    set(value):
        is_code_visible = value
        
        lobby_code_input.secret = !is_code_visible

        if is_code_visible:
            lobby_code_label.text = MultiplayerManager.lobby_code
        else:
            lobby_code_label.text = "*".repeat(MultiplayerManager.lobby_code_length)

func _ready():
    connect_signals()
    is_code_visible = true

    lobby_code_input.max_length = MultiplayerManager.lobby_code_length

func _exit_tree():
    disconnect_signals()

##
## METHODS
##

func connect_signals():
    host_button.pressed.connect(_on_host_pressed)
    copy_code_button.pressed.connect(_on_copy_code_pressed)
    hide_code_button.pressed.connect(_on_hide_code_pressed)
    lobby_code_input.text_changed.connect(_on_lobby_code_text_changed)

func disconnect_signals():
    host_button.pressed.disconnect(_on_host_pressed)
    copy_code_button.pressed.disconnect(_on_copy_code_pressed)
    hide_code_button.pressed.disconnect(_on_hide_code_pressed)
    lobby_code_input.text_changed.disconnect(_on_lobby_code_text_changed)

##
## SIGNALS
##

func _on_host_pressed():
    var code_string := MultiplayerManager.set_lobby_code()
    lobby_code_label.text = code_string

func _on_copy_code_pressed():
    if MultiplayerManager.lobby_code.is_empty(): return
    DisplayServer.clipboard_set(MultiplayerManager.lobby_code.to_upper())

func _on_hide_code_pressed():
    is_code_visible = !is_code_visible

func _on_lobby_code_text_changed(new_text: String):
    var caret_col = lobby_code_input.caret_column
    lobby_code_input.text = new_text.to_upper()
    lobby_code_input.caret_column = caret_col