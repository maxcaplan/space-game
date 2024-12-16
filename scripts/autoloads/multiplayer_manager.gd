class_name MultiplayerManagerGlobal
extends Node

## Emited when a holepunch is successful between two clients
signal hole_punched(my_port: int, host_port: int, host_address: String)

@onready var hole_puncher: HolePunch = %HolePunch

@export var lobby_code_length := 6

var is_host: bool = false
var client_id: String
var client_port: int
var lobby_code: String

func _ready():
    connect_signals()

func _exit_tree():
    disconnect_signals()

##
## METHODS
##

## Generates a unique lobby code string
## TODO: replace local generation of random lobby code with server side lobby code generation to ensure unique codes
func generate_lobby_code() -> String:
    var alpha := ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z",]
    var code_string: String = ""

    for i in range(lobby_code_length):
        if randf() >= 0.5:
            code_string += str(randi_range(0, 9))
        else:
            code_string += alpha[randi_range(0, len(alpha) - 1)]
    
    return code_string

## Start traversing a network to attempt to punch a network hole between two clients 
func start_traversal():
    if lobby_code.is_empty(): 
        printerr("Unable to network start traversal, no lobby code is set")
        return

    print("Starting traversal as %s", "host" if is_host else "client")

    client_id = OS.get_unique_id()
    hole_puncher.start_traversal(lobby_code.to_lower(), is_host, client_id)

## Start a multiplayer server
func start_server(server_port: int, max_clients = 5):
    if server_port == null: return
    var peer = ENetMultiplayerPeer.new()
    peer.create_server(server_port, max_clients)
    multiplayer.multiplayer_peer = peer

## Connect to a multiplayer server
func connect_to_server(server_ip: String, server_port: int, my_port: int):
    var peer = ENetMultiplayerPeer.new()
    peer.create_client(server_ip, server_port, 0, 0, 0, my_port)
    multiplayer.multiplayer_peer = peer

func connect_signals():
    hole_puncher.hole_punched.connect(_on_hole_punched)

func disconnect_signals():
    hole_puncher.hole_punched.disconnect(_on_hole_punched)

##
## SIGNALS
## 

func _on_hole_punched(my_port: int, hosts_port: int, hosts_address: String):
    client_port = my_port
    hole_punched.emit(my_port, hosts_port, hosts_address)