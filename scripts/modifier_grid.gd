extends Control

const MODIFIER_TILE_CORNER_RADIUS = 20
const ModifierStyleBox: Dictionary = {
	"CONDITION_STYLEBOX": preload("res://assets/TileCondition.stylebox"),
	"PROPERTY_STYLEBOX": preload("res://assets/TileProperties.stylebox"),
}

var num_of_modifiers:int = 0
var current_visible_modifiers:int = 0

func _on_ready():
	change_grid_size()

func change_grid_size():
	match num_of_modifiers:
		1: grid_size_1()
		2,3,4: grid_size_2()
		5,6,7,8,9: grid_size_3()

func grid_size_1():
	self.columns = 1

func grid_size_2():
	self.columns = 2
	
func grid_size_3():
	self.columns = 3


func _on_tile_modifiers_modifier_count_changed(modifier_number: int, modifiers: Array) -> void:
	num_of_modifiers = modifier_number
	change_grid_size()
	while num_of_modifiers != current_visible_modifiers:
		if current_visible_modifiers < num_of_modifiers:
			get_child(current_visible_modifiers).visible = true
			current_visible_modifiers += 1
		elif current_visible_modifiers > num_of_modifiers:
			get_child(current_visible_modifiers-1).visible = false
			current_visible_modifiers -= 1
	for modifier in modifiers:
		var key = Game.TileModifierFlag.find_key(modifier)
		if key and key.begins_with("CONDITION"):
			get_child(modifiers.find(modifier)).add_theme_stylebox_override("panel",ModifierStyleBox.CONDITION_STYLEBOX)
		elif key and key.begins_with("PROPERTY"):
			get_child(modifiers.find(modifier)).add_theme_stylebox_override("panel",ModifierStyleBox.PROPERTY_STYLEBOX)
