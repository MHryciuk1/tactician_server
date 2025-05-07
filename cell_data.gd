class_name Cell_Data
var location : Vector2i
var hex_type : int = 0
var  move_cost : int = 1
var occupant : Unit
var cell_id : int 

func _init(pos : Vector2i, type : int, cost : int, id : int) -> void:
	location=pos
	hex_type=type
	move_cost = cost
	cell_id = id
func to_dict() -> Dictionary:
	var unique_id : int = -1
	if(occupant):
		unique_id = occupant.unique_id
	return {
		"location":location,
		"cell_id":cell_id,
		"hex_type":hex_type,
		"occupant_unique_id": unique_id,
		"move_cost":move_cost
	}
