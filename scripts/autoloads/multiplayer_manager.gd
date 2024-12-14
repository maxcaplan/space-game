class_name MultiplayerManagerGlobal
extends Node

@onready var hole_puncher: HolePunch = %HolePunch

@export var lobby_code_length := 6

var lobby_code: String

# Generates a unique lobby code string
func set_lobby_code() -> String:
    var alpha := ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z",]
    var code_string: String = ""

    for i in range(lobby_code_length):
        if randf() >= 0.5:
            code_string += str(randi_range(0, 9))
        else:
            code_string += alpha[randi_range(0, len(alpha) - 1)]
    
    lobby_code = code_string
    return code_string

