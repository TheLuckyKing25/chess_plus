extends MarginContainer

func _get_selected_tiles() -> Array: # gets selected tiles from game_board.gd
	var out: Array = []
	for tile in get_tree().get_nodes_in_group("Tile"):
		if tile.data.is_selected:
			out.append(tile)
	return out

# Gets selected modifier from Modifier List Panel
var selected_modifier_flag: int = ModifierEnums.TileModifierFlag.CONDITION_ICY

var MODIFIER_CLASSES := {
	ModifierEnums.TileModifierFlag.PROPERTY_COG: PropertyCog,
	ModifierEnums.TileModifierFlag.CONDITION_ICY: ConditionIcy,
	ModifierEnums.TileModifierFlag.CONDITION_STICKY: ConditionSticky,
	ModifierEnums.TileModifierFlag.PROPERTY_CONVEYER: PropertyConveyer,
	ModifierEnums.TileModifierFlag.PROPERTY_SPRINGY: PropertySpringy,
	ModifierEnums.TileModifierFlag.PROPERTY_WALL: PropertyWall,
	ModifierEnums.TileModifierFlag.PROPERTY_POISON: PropertyPoison,
	ModifierEnums.TileModifierFlag.PROPERTY_KINGSFAVOR: PropertyKingsFavor,
	ModifierEnums.TileModifierFlag.PROPERTY_GATE: PropertyGate,
	ModifierEnums.TileModifierFlag.PROPERTY_BUTTON: PropertyButton,
	ModifierEnums.TileModifierFlag.PROPERTY_LEVER: PropertyLever,
}

# This can probably be much more efficient
func _make_selected_modifier() -> TileModifier:
	match selected_modifier_flag:
		ModifierEnums.TileModifierFlag.PROPERTY_COG:
			return _make_cog_modifier()
		ModifierEnums.TileModifierFlag.CONDITION_ICY:
			return _make_icy_modifier()
		ModifierEnums.TileModifierFlag.CONDITION_STICKY:
			return _make_sticky_modifier()
		ModifierEnums.TileModifierFlag.PROPERTY_CONVEYER:
			return _make_conveyer_modifier()
		ModifierEnums.TileModifierFlag.PROPERTY_SPRINGY:
			return _make_springy_modifier()
		ModifierEnums.TileModifierFlag.PROPERTY_WALL:
			return _make_wall_modifier()
		ModifierEnums.TileModifierFlag.PROPERTY_POISON:
			return _make_poison_modifier()
		ModifierEnums.TileModifierFlag.PROPERTY_KINGSFAVOR:
			return _make_kingsfavor_modifier()
		ModifierEnums.TileModifierFlag.PROPERTY_GATE:
			return _make_gate_modifier()
		ModifierEnums.TileModifierFlag.PROPERTY_BUTTON:
			return _make_button_modifier()
		ModifierEnums.TileModifierFlag.PROPERTY_LEVER:
			return _make_lever_modifier()
		_:
			return _make_sticky_modifier()

@onready var cog_rotation = $BackgroundTopPanel/BoxContainer2/BoxContainer/BoxContainer2/AppliedTileModifierListPanel/MarginContainer/GridContainer/Cog/BoxContainer/DropdownOptions/BoxContainer3/BoxContainer/RotationAmount
func _make_cog_modifier() -> TileModifier:
	var m := PropertyCog.new()
	m.rotation = int(cog_rotation.value)
	return m

@onready var icy_lifetime = $BackgroundTopPanel/BoxContainer2/BoxContainer/BoxContainer2/AppliedTileModifierListPanel/MarginContainer/GridContainer/Icy/BoxContainer/DropdownOptions/BoxContainer3/BoxContainer/Lifetime
func _make_icy_modifier() -> TileModifier:
	var m := ConditionIcy.new()
	m.lifetime = int(icy_lifetime.value)
	return m

@onready var sticky_lifetime = $BackgroundTopPanel/BoxContainer2/BoxContainer/BoxContainer2/AppliedTileModifierListPanel/MarginContainer/GridContainer/Sticky/BoxContainer/DropdownOptions/BoxContainer3/BoxContainer/Lifetime
func _make_sticky_modifier() -> TileModifier:
	var m := ConditionSticky.new()
	m.lifetime = int(sticky_lifetime.value)
	return m

func _make_conveyer_modifier() -> TileModifier:
	var m := PropertyConveyer.new()
	m.direction = _get_conveyer_direction()
	return m

@onready var conveyer_direction = $BackgroundTopPanel/BoxContainer2/BoxContainer/BoxContainer2/AppliedTileModifierListPanel/MarginContainer/GridContainer/Conveyer/BoxContainer/DropdownOptions/BoxContainer3/BoxContainer/RotationAmount
func _get_conveyer_direction() -> int:
	match int(conveyer_direction.value):
		0: return PropertyConveyer.ConveyerDirection.NORTH
		45: return PropertyConveyer.ConveyerDirection.NORTHEAST
		90: return PropertyConveyer.ConveyerDirection.EAST
		135: return PropertyConveyer.ConveyerDirection.SOUTHEAST
		180: return PropertyConveyer.ConveyerDirection.SOUTH
		225: return PropertyConveyer.ConveyerDirection.SOUTHWEST
		270: return PropertyConveyer.ConveyerDirection.WEST
		315: return PropertyConveyer.ConveyerDirection.NORTHWEST
		_: return PropertyConveyer.ConveyerDirection.NORTH

@onready var springy_x = $BackgroundTopPanel/BoxContainer2/BoxContainer/BoxContainer2/AppliedTileModifierListPanel/MarginContainer/GridContainer/Springy/BoxContainer/DropdownOptions/BoxContainer3/BoxContainer/X
@onready var springy_y = $BackgroundTopPanel/BoxContainer2/BoxContainer/BoxContainer2/AppliedTileModifierListPanel/MarginContainer/GridContainer/Springy/BoxContainer/DropdownOptions/BoxContainer3/BoxContainer/Y
func _make_springy_modifier() -> TileModifier:
	var m := PropertySpringy.new()
	m.destination = Vector2i(
		int(springy_x.value),
		int(springy_y.value)
	)
	return m

func _make_wall_modifier() -> TileModifier:
	var m := PropertyWall.new()
	return m

func _make_kingsfavor_modifier() -> TileModifier:
	var m := PropertyKingsFavor.new()
	return m

func _make_gate_modifier() -> TileModifier:
	var m := PropertyGate.new()
	return m

@onready var button_radius = $BackgroundTopPanel/BoxContainer2/BoxContainer/BoxContainer2/AppliedTileModifierListPanel/MarginContainer/GridContainer/Button/BoxContainer/DropdownOptions/BoxContainer3/BoxContainer/Radius
func _make_button_modifier() -> TileModifier:
	var m := PropertyButton.new()
	m.radius = int(button_radius.value)
	return m

@onready var lever_radius = $BackgroundTopPanel/BoxContainer2/BoxContainer/BoxContainer2/AppliedTileModifierListPanel/MarginContainer/GridContainer/Lever/BoxContainer/DropdownOptions/BoxContainer3/BoxContainer/Radius
func _make_lever_modifier() -> TileModifier:
	var m := PropertyLever.new()
	m.radius = int(lever_radius.value)
	return m

@onready var poison_duration = $BackgroundTopPanel/BoxContainer2/BoxContainer/BoxContainer2/AppliedTileModifierListPanel/MarginContainer/GridContainer/Poison/BoxContainer/DropdownOptions/BoxContainer3/BoxContainer/Duration
func _make_poison_modifier() -> TileModifier:
	var m := PropertyPoison.new()
	m.duration = int(poison_duration.value)
	return m

func _debug_print(tile) -> void:
	print("Tile ", tile.data.board_position, " has ", tile.data.modifier_order.size(), " modifiers")
	for i in range(tile.data.modifier_order.size()):
		var mod = tile.data.modifier_order[i]
		print(" [", i, "] ", mod.get_class(), " flag=", mod.get("flag"), " lifetime=", mod.get("lifetime"))

# Button Handling
func _on_add_pressed() -> void:
	var tiles := _get_selected_tiles()
	print("ADD pressed. Selected tiles:", tiles.size())
	if tiles.is_empty():
		return
 
	for t in tiles:
		var arr: Array[TileModifier] = t.data.modifier_order.duplicate()
		arr.append(_make_selected_modifier())
		t.data.modifier_order = arr
		_debug_print(t)

func _on_replace_pressed() -> void:
	var tiles := _get_selected_tiles()
	print("REPLACE pressed. Selected tiles:", tiles.size())
	if tiles.is_empty():
		return

	for t in tiles:
		var arr: Array[TileModifier] = []
		arr.append(_make_selected_modifier())
		t.data.modifier_order = arr
		_debug_print(t)

func _on_erase_pressed() -> void:
	var tiles := _get_selected_tiles()
	print("ERASE pressed. Selected tiles:", tiles.size())
	if tiles.is_empty():
		return

	for t in tiles:
		var arr: Array[TileModifier] = []
		t.data.modifier_order = arr
		_debug_print(t)

func _on_cog_pressed() -> void:
	selected_modifier_flag = ModifierEnums.TileModifierFlag.PROPERTY_COG

func _on_icy_pressed() -> void:
	selected_modifier_flag = ModifierEnums.TileModifierFlag.CONDITION_ICY

func _on_sticky_pressed() -> void:
	selected_modifier_flag = ModifierEnums.TileModifierFlag.CONDITION_STICKY

func _on_conveyer_pressed() -> void:
	selected_modifier_flag = ModifierEnums.TileModifierFlag.PROPERTY_CONVEYER

func _on_springy_pressed() -> void:
	selected_modifier_flag = ModifierEnums.TileModifierFlag.PROPERTY_SPRINGY

func _on_wall_pressed() -> void:
	selected_modifier_flag = ModifierEnums.TileModifierFlag.PROPERTY_WALL

func _on_poison_pressed() -> void:
	selected_modifier_flag = ModifierEnums.TileModifierFlag.PROPERTY_POISON

func _on_kings_favor_pressed() -> void:
	selected_modifier_flag = ModifierEnums.TileModifierFlag.PROPERTY_KINGSFAVOR

func _on_gate_pressed() -> void:
	selected_modifier_flag = ModifierEnums.TileModifierFlag.PROPERTY_GATE

func _on_button_pressed() -> void:
	selected_modifier_flag = ModifierEnums.TileModifierFlag.PROPERTY_BUTTON

func _on_lever_pressed() -> void:
	selected_modifier_flag = ModifierEnums.TileModifierFlag.PROPERTY_LEVER
