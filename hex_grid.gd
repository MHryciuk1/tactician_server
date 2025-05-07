class_name Hex_Grid
enum {
	BASE_LAYOUT = 0
}

var cell_data : Dictionary[Vector2i, Cell_Data] = {}
var pathfinding_graph = AStar2D.new()
func populate_base_layout_cell_data() -> void:
	var to_connect : Array[Cell_Data] = []
	for i in range(10):
		for j in range(10):
			var id : int= pathfinding_graph.get_available_point_id()
			var pos : Vector2i= Vector2i(i,j)
			var cost : int = 1
			pathfinding_graph.add_point(id,pos,cost)
			insert_to_cell_data(Cell_Data.new(pos,0,cost, id), pos)
			to_connect.append(get_cell_data(pos))
	for i in range(to_connect.size()):
		var adj := get_valid_spaces(to_connect[i].location,1)
		for j in adj:
			pathfinding_graph.connect_points(to_connect[i].cell_id,cell_data[j].cell_id)	
func _init(layout : int) -> void:
	match layout:
		BASE_LAYOUT:
			populate_base_layout_cell_data()
func set_node_location(node : Unit, pos : Vector2i) -> void:
	var data : Cell_Data = get_cell_data(node.current_cord)
	data.occupant = null
	node.current_cord = pos
	data = get_cell_data(node.current_cord)
	data.occupant = node
	pass
func get_hexes_along_path_to(cord_a : Vector2i, cord_b : Vector2i, data : bool = false, partial_path : bool = false) -> Array:
	var data_a = get_cell_data(cord_a)
	var data_b = get_cell_data(cord_b)
	if (not data_a) or (not data_b):
		print("error in hex_grid.gd/get_hexes_along_path_to: one of the cells don't exist")
		print(str("cord_a: ", cord_a))
		print(str("cord_b: ", cord_b))
		return []
	var raw_path : PackedVector2Array = pathfinding_graph.get_point_path(data_a.cell_id, data_b.cell_id, partial_path)
	print(raw_path)
	if not data:
		return raw_path
	var out : Array = []
	for i in raw_path:
		out.append(get_cell_data(i))
	return out
func get_cell_data(cord : Vector2i):
	return cell_data.get(cord)

func get_valid_spaces(cord : Vector2i, radius : int, with_data : bool = false) -> Array:
	var axal_cord :Vector2i= oddr_to_axial(cord)
	var N = abs(radius)
	var out : Array = []
	for q in range((-1*N), N+1):
		#print(q)
		for r in range(max(-1*N,(-1*q)-N), min(N,(-1*q)+N)+1):
			var new_cor = axial_to_oddr(axal_cord+Vector2i(q,r))
			var data = get_cell_data(new_cor)
			if data:
				if with_data:
					out.append(data)
				else:
					out.append(data.location)
	return out
func insert_to_cell_data(data, cord) ->void:
	cell_data[cord] = data
func axial_to_oddr(axial_cord : Vector2i) -> Vector2i:
	var col = axial_cord.x + (axial_cord.y - (axial_cord.y&1)) / 2
	var row = axial_cord.y
	return Vector2i(col, row)
func oddr_to_axial(oddr_cord : Vector2i) -> Vector2i:
	var q = oddr_cord.x - (oddr_cord.y - (oddr_cord.y&1)) / 2
	var r = oddr_cord.y
	return Vector2i(q, r)
