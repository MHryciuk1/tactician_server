class_name Unit

signal unit_selected(unit)
signal unit_moved(unit, to_coord)
signal unit_died(unit)
var unique_id :int = -1
var id : int = 0

@export var team: int = 1

@export var unit_type: String = "soldier"
var stats : Dictionary = {
	"cost": 1,
	"hp": 10,
	"move_range" : 2,
	"max_move_range": 2,
	"attack_range": 1,
	"damage": 5,
	"vision_range": 2,
}
var logic_manager: Server_Logic_Manager = null
var hex_grid: Hex_Grid = null
var ui  = null

func turn_end() -> void:
	stats.move_range = stats.max_move_range
	for i in moves.keys():
		var move = moves.get(i)
		move.uses_left = move.max_uses_per_turn
var moves = {
	"attack1" : Callable(attack_effect)
}

var current_cord: Vector2i
var alive: bool = true

func init(logic_ref: Server_Logic_Manager, grid_ref: Hex_Grid, start_cord: Vector2i, team_num : int, new_id : int) -> void:
	id = new_id
	logic_manager = logic_ref
	hex_grid = grid_ref
	current_cord = start_cord
	team = team_num
	hex_grid.set_node_location(self, start_cord)
	unique_id = logic_manager.gen_unit_unique_id()
	print(unique_id)

func get_stats() -> Dictionary:
	return stats
func get_dict() -> Dictionary:
	return {
		"team": team,
		"id": id,
		"unique_id" : unique_id,
		"pos" : current_cord,
		"stats" : stats,
		"moves": moves,
		"alive" : alive
	}
func check_attack(cord: Vector2i) -> bool:

	return current_cord.distance_to(cord) <= get_stats().attack_range #TODO distance_to will not return the number of hexes to the cord


func attack_effect(target: Unit) -> void:
	pass


func on_attacked(attacker: Unit, dmg: int) -> void:
	stats.hp -= dmg
	if stats.hp <= 0 and alive:
		print("im dead")
		alive = false
		#logic_manager.on_unit_death(self)
		#emit_signal("unit_died", self)

	
