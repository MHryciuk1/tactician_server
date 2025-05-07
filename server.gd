extends Node
const  SERVER_PORT = 2000
const DEFAULT_SERVER_IP = "127.0.0.1"
const MAX_CLIENTS = 2
var players : Dictionary = {}
@onready var lm  = $Level/Logic_Manager
func _ready() -> void:
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	create_game()
	pass
func create_game():
	var server_peer = ENetMultiplayerPeer.new()
	var error = server_peer.create_server(SERVER_PORT, MAX_CLIENTS)
	if error:
		return error
	multiplayer.multiplayer_peer = server_peer
func  _on_player_connected(id):
	print(str("player connected ", id))
	players.set(id,true)
	lm.player_connected(id)
	var keys =  players.keys()
	if keys.size() == MAX_CLIENTS:
		var res : Dictionary = {
			"hex_layout": lm.get_hex_grid(),
			"player_name":  "Player 0",
			"turn_start": 0
			
		}
		lm.generate_turn_order()
		for i in keys:
			res.player_name = lm.get_player_name(i)
			res.turn_start = lm.is_turn_player(i)
			setup.rpc_id(i, res)
			
func _on_player_disconnected(id):
	print(str("player disconnected ", id))
	players.erase(id)
	lm.player_disconected(id)
	pass
@rpc()
func setup(i):
	print("setup")
