extends MenuState 

@onready var singleplayer_button = %SingleplayerButton
@onready var multiplayer_button = %MultiplayerButton
@onready var quit_button = %QuitButton

@export var multiplayer_menu: MenuState 

func _ready():
    _connect_signals()

func _exit_tree():
    _disconnect_signals()

##
## PRIVATE METHODS
##

func _quit_game():
    get_tree().quit()

func _connect_signals():
    singleplayer_button.pressed.connect(_on_singleplayer_pressed)
    multiplayer_button.pressed.connect(_on_multiplayer_pressed)
    quit_button.pressed.connect(_on_quit_pressed)

func _disconnect_signals():
    singleplayer_button.pressed.disconnect(_on_singleplayer_pressed)
    multiplayer_button.pressed.disconnect(_on_multiplayer_pressed)
    quit_button.pressed.disconnect(_on_quit_pressed)

##
## SIGNAL METHODS
##

func _on_singleplayer_pressed():
    pass

func _on_multiplayer_pressed():
    self.transitioned.emit(self, multiplayer_menu)

func _on_quit_pressed():
    _quit_game()