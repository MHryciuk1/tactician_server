class_name Server_Logic_Manager
extends Node
var player_ids = [0,0]
var connections : Array = [false, false]
var units_set_up : Array = [false, false]
var unit_containers: Array[Dictionary] = [{},{}]
var id_unit_mapping = [Unit, Knight, Scout, Archer]
var turn_player : int = 0
var curr_unique_id : int = 0
@onready var hex_grid :Hex_Grid = Hex_Grid.new(0)
func generate_turn_order() -> void:
	turn_player = (randi() % player_ids.size()) +1
func is_turn_player(id : int) -> int:
	if player_ids[turn_player-1] == id:
		return 0
	return 1
func get_unit_by_unique_id(id : int, player : int) -> Unit:
	return unit_containers[player - 1].get(id)
func gen_unit_unique_id() -> int:
	curr_unique_id +=1
	return curr_unique_id
	
func get_player_name(id) -> String:
	if player_ids[0] == id:
		return "Player 1"
	return "Player 2"
func player_connected(id: int) -> void:
	print(get_path())
	if connections[0]:
		connections[1] = true 
		player_ids[1]= id
	else:
		player_ids[0] = id
		connections[0] = true
func player_disconected(id: int) -> void:
	if player_ids[0] == id:
		connections[0] = false
	elif player_ids[1] == id:
		connections[1] = false
		
func get_hex_grid() -> Array:
	var out : Array[Dictionary] = []
	for i in hex_grid.cell_data.keys():
		out.append(hex_grid.cell_data[i].to_dict())
	return out
func is_unit_setup_valid(setup : Array, player : int) -> bool:
	return true
func generate_units(units_template, player) -> void:
	var out = []
	for i in units_template:
		if (i[0] == 0):
			break
		var new_unit : Unit = id_unit_mapping[i[0]].new()
		new_unit.init(self, hex_grid, i[1],player, i[0])
		unit_containers[player-1][new_unit.unique_id] = new_unit
		
func get_player_number(client_id : int) -> int:
	if client_id == player_ids[0]:
		return 1
	elif client_id == player_ids[1]:
		return 2
	print("ERROR: unknown client")
	return 0

@rpc("any_peer","call_remote","unreliable_ordered")
func move_request(source : int, target : Vector2i) -> void:
	
	var sending_client = multiplayer.get_remote_sender_id()
	var player =get_player_number(sending_client)
	if(!player):
		return
	if player != turn_player:
		print(str("player ", player," is not turn player"))
		return
	print(str( "player "), player)
	print(str("source ", source, " target ", target))
	var unit =  get_unit_by_unique_id(source,player)
	if(!unit):
		print("unit not found")
		print(str( "player "), player)
		print(str("source ", source, " target ", target))
		print(unit_containers)
		return
	var path = hex_grid.get_hexes_along_path_to(unit.current_cord, target)
	print(str("path, ", path))
	if(!path.size()):
		print("no path generated")
		return
	var actual_target  : Vector2i= path.pop_front()
	for i in path:
		var hex_data : Cell_Data = hex_grid.get_cell_data(i)
		if(unit.stats.move_range - hex_data.move_cost) >= 0:
			unit.stats.move_range -= hex_data.move_cost
			actual_target = i
		else:
			break
	if unit.current_cord == actual_target:
		print("No movement possible for ", unit.unit_type)
		return
	hex_grid.set_node_location(unit, actual_target)
	var unit_data : Array[Dictionary]= [unit.get_dict()]
	print("sending updates")
	unit_update.rpc_id(player_ids[player -1], unit_data)
	unit_update.rpc_id(player_ids[player -2], unit_data)
func change_teams_to(units : Array, team: int) -> Array:
	var out = []
	for i in units:
		i.team = team
		out.append(i)
	return out
func get_units_for_player(player : int, team : int) -> Array:
	var out : Array = []
	for i in unit_containers[player-1].values():
		i.team = team
		out.append(i.get_dict())
	return out
func send_confirmation(player : int, show_placement : bool) -> void:
	
	var response = {
		"status": 0,
		"data":  get_units_for_player(player, 1),
		"begin_placement" : show_placement
	}
	set_up_response.rpc_id(player_ids[player-1], response)
	pass
func send_enemy_units(player : int, show_placement : bool) -> void:
	var response = {
		"status": -1,
		"data":  get_units_for_player(player, 2),
		"begin_placement" : show_placement
	}
	set_up_response.rpc_id(player_ids[player-2],response)
	if ! units_set_up[player-2]:
			response.begin_placement = true
	
	pass
func send_end_placement(player : int) -> void:
	turn_start.rpc_id(player_ids[player-1])
func end_turn_updates(player) -> void:
	var units_to_update = unit_containers[player-1].values()
	for i in units_to_update:
		i.turn_end()
		
	pass
@rpc("any_peer","call_remote","unreliable_ordered")
func server_turn_end()-> void:
	var sending_client = multiplayer.get_remote_sender_id()
	var player =get_player_number(sending_client)
	if(!player):
		return
	if player != turn_player:
		print(str("player ", player," is not turn player"))
		return
	print(str(" turn end player", player))
	turn_player = 3 - turn_player
	end_turn_updates(player)
	turn_start.rpc_id(player_ids[turn_player-1])
@rpc("any_peer","call_remote","unreliable_ordered")
func server_send_starting_units(units):
	
	var sending_client = multiplayer.get_remote_sender_id()
	var player =get_player_number(sending_client)
	if(!player):
		return
	if(player_ids[player-1] != player_ids[turn_player-1]):
		print("ERROR: sending client is not turn player")
		return
	print(str( "player "), player)
	if is_unit_setup_valid(units, player ):
		units_set_up[player -1] = true
		var show_placement = false
		generate_units(units, player)
		turn_player = 3 - turn_player
		send_confirmation(player,show_placement)
		if ! units_set_up[player -2]:
			show_placement = true
		send_enemy_units(player, show_placement )
		if ! show_placement:
			send_end_placement(player-1)

	print(unit_containers)
@rpc()
func turn_start() -> void:
	pass
@rpc()
func set_up_response() -> void:
	pass
@rpc()
func unit_update(update : Array[Dictionary]) -> void:
	pass
