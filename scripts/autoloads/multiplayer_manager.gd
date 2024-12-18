class_name MultiplayerManagerGlobal
extends Node

## Emited when the lobby code is changed
signal lobby_code_changed(code: String)
## Emited when a holepunch is successful between two clients
signal hole_punched(my_port: int, host_port: int, host_address: String)

@export_group("Hole Puncher")
@export var rendevouz_address: String = "0.0.0.0"
@export var rendevouz_port: int = 5000
@export var port_cascade_range: int = 10
@export var response_window: int = 5

@export_group("Lobby")
@export var lobby_code_length := 6

var hole_puncher: HolePunch
var is_host: bool = false
var client_id: String
var client_port: int
var lobby_code: String:
	set(value):
		lobby_code = value
		self.lobby_code_changed.emit(value)


func _ready():
	_connect_signals()

func _exit_tree():
	_disconnect_signals()

##
## METHODS
##

func create_hole_puncher():
	hole_puncher = preload("res://addons/Holepunch/holepunch_node.gd").new()

	hole_puncher.rendevouz_address = rendevouz_address
	hole_puncher.rendevouz_port = rendevouz_port
	hole_puncher.port_cascade_range = port_cascade_range
	hole_puncher.response_window = response_window

	self.add_child(hole_puncher)
	hole_puncher.hole_punched.connect(_on_hole_punched)

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

## Close a multiplayer server
func close_connection():
	if hole_puncher != null:
		if hole_puncher.is_host:
			hole_puncher.finalize_peers(lobby_code)

		if hole_puncher.client_name != null:
			hole_puncher.checkout()

		hole_puncher.hole_punched.disconnect(_on_hole_punched)
		hole_puncher.queue_free()

##
## PRIVATE METHODS
##

func _connect_signals():
	pass

func _disconnect_signals():
	if hole_puncher != null && hole_puncher.hole_punched.is_connected(_on_hole_punched):
		hole_puncher.hole_punched.disconnect(_on_hole_punched)

##
## SIGNALS
## 

func _on_hole_punched(my_port: int, hosts_port: int, hosts_address: String):
	client_port = my_port
	self.hole_punched.emit(my_port, hosts_port, hosts_address)
