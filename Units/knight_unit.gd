class_name Knight
extends Unit
func _init() -> void:
	stats = {
			"cost": 1,
			"hp": 10,
			"move_range": 1,
			"max_move_range": 1,
			"attack_range": 1,
			"damage": 6,
			"team": team,
			"vision_range": 3
		}
	moves = {
		"attack1" : {
			"function" : Callable(attack_effect),
			"description" : str("range: ", stats.attack_range, "dmg: ", stats.damage),
			"max_targets" : 1,
			"min_targets" : 1,
			"targets_who" : "enemy",
			"max_uses_per_turn": 1,
			"uses_left" : 1
			}
	}
		
func attack_effect(target: Unit) -> void:
	target.on_attacked(target, stats.damage)
	pass
