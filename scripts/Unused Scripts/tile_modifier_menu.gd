extends MarginContainer

func _get_selected_tiles() -> Array: # gets selected tiles from game_board.gd
	var out: Array = []
	for tile in get_tree().get_nodes_in_group("Selected"):
		out.append(tile)
	return out

# Gets selected modifier from Modifier List Panel
var selected_modifier_flag: int = TileModifier.ModifierType.CONDITION_ICY

var MODIFIER_CLASSES := {
	TileModifier.ModifierType.PROPERTY_COG: PropertyCog,
	TileModifier.ModifierType.CONDITION_ICY: ConditionIcy,
	TileModifier.ModifierType.CONDITION_STICKY: ConditionSticky,
	TileModifier.ModifierType.PROPERTY_CONVEYER: PropertyConveyer,
	TileModifier.ModifierType.PROPERTY_SPRINGY: PropertySpringy,
	TileModifier.ModifierType.PROPERTY_WALL: PropertyWall,
	TileModifier.ModifierType.PROPERTY_POISON: PropertyPoison,
	TileModifier.ModifierType.PROPERTY_KINGSFAVOR: PropertyKingsFavor,
	TileModifier.ModifierType.PROPERTY_GATE: PropertyGate,
	TileModifier.ModifierType.PROPERTY_BUTTON: PropertyButton,
	TileModifier.ModifierType.PROPERTY_LEVER: PropertyLever,
}

# This can probably be much more efficient
func _make_selected_modifier() -> TileModifier:
	match selected_modifier_flag:
		TileModifier.ModifierType.PROPERTY_COG:
			return _make_cog_modifier()
		TileModifier.ModifierType.CONDITION_ICY:
			return _make_icy_modifier()
		TileModifier.ModifierType.CONDITION_STICKY:
			return _make_sticky_modifier()
		TileModifier.ModifierType.PROPERTY_CONVEYER:
			return _make_conveyer_modifier()
		TileModifier.ModifierType.PROPERTY_SPRINGY:
			return _make_springy_modifier()
		TileModifier.ModifierType.PROPERTY_WALL:
			return _make_wall_modifier()
		TileModifier.ModifierType.PROPERTY_POISON:
			return _make_poison_modifier()
		TileModifier.ModifierType.PROPERTY_KINGSFAVOR:
			return _make_kingsfavor_modifier()
		TileModifier.ModifierType.PROPERTY_GATE:
			return _make_gate_modifier()
		TileModifier.ModifierType.PROPERTY_BUTTON:
			return _make_button_modifier()
		TileModifier.ModifierType.PROPERTY_LEVER:
			return _make_lever_modifier()
		_:
			return _make_sticky_modifier()

@onready var cog_rotation = $BackgroundTopPanel#/BoxContainer2/BoxContainer/BoxContainer2/AppliedTileModifierListPanel/MarginContainer/GridContainer/Cog/BoxContainer/DropdownOptions/BoxContainer3/BoxContainer/RotationAmount
func _make_cog_modifier() -> TileModifier:
	var m := PropertyCog.new()
	m.rotation = int(cog_rotation.value)
	return m

@onready var icy_lifetime = $BackgroundTopPanel#/BoxContainer2/BoxContainer/BoxContainer2/AppliedTileModifierListPanel/MarginContainer/GridContainer/Icy/BoxContainer/DropdownOptions/BoxContainer3/BoxContainer/Lifetime
func _make_icy_modifier() -> TileModifier:
	var m := ConditionIcy.new()
	m.lifetime = int(icy_lifetime.value)
	return m

@onready var sticky_lifetime = $BackgroundTopPanel#/BoxContainer2/BoxContainer/BoxContainer2/AppliedTileModifierListPanel/MarginContainer/GridContainer/Sticky/BoxContainer/DropdownOptions/BoxContainer3/BoxContainer/Lifetime
func _make_sticky_modifier() -> TileModifier:
	var m := ConditionSticky.new()
	m.lifetime = int(sticky_lifetime.value)
	return m

func _make_conveyer_modifier() -> TileModifier:
	var m := PropertyConveyer.new()
	m.direction = _get_conveyer_direction()
	return m

@onready var conveyer_direction = $BackgroundTopPanel#/BoxContainer2/BoxContainer/BoxContainer2/AppliedTileModifierListPanel/MarginContainer/GridContainer/Conveyer/BoxContainer/DropdownOptions/BoxContainer3/BoxContainer/RotationAmount
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

@onready var springy_x = $BackgroundTopPanel#/BoxContainer2/BoxContainer/BoxContainer2/AppliedTileModifierListPanel/MarginContainer/GridContainer/Springy/BoxContainer/DropdownOptions/BoxContainer3/BoxContainer/X
@onready var springy_y = $BackgroundTopPanel#/BoxContainer2/BoxContainer/BoxContainer2/AppliedTileModifierListPanel/MarginContainer/GridContainer/Springy/BoxContainer/DropdownOptions/BoxContainer3/BoxContainer/Y
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

@onready var button_radius = $BackgroundTopPanel#/BoxContainer2/BoxContainer/BoxContainer2/AppliedTileModifierListPanel/MarginContainer/GridContainer/Button/BoxContainer/DropdownOptions/BoxContainer3/BoxContainer/Radius
func _make_button_modifier() -> TileModifier:
	var m := PropertyButton.new()
	m.radius = int(button_radius.value)
	return m

@onready var lever_radius = $BackgroundTopPanel#/BoxContainer2/BoxContainer/BoxContainer2/AppliedTileModifierListPanel/MarginContainer/GridContainer/Lever/BoxContainer/DropdownOptions/BoxContainer3/BoxContainer/Radius
func _make_lever_modifier() -> TileModifier:
	var m := PropertyLever.new()
	m.radius = int(lever_radius.value)
	return m

@onready var poison_duration = $BackgroundTopPanel#/BoxContainer2/BoxContainer/BoxContainer2/AppliedTileModifierListPanel/MarginContainer/GridContainer/Poison/BoxContainer/DropdownOptions/BoxContainer3/BoxContainer/Duration
func _make_poison_modifier() -> TileModifier:
	var m := PropertyPoison.new()
	m.duration = int(poison_duration.value)
	return m

func _debug_print(tile) -> void:
	print("Tile ", tile.data.board_position, " has ", tile.data.modifier_order.size(), " modifiers")
	for i in range(tile.data.modifier_order.size()):
		var mod = tile.data.modifier_order[i]
		print(" [", i, "] ", mod.get_class(), " flag=", mod.get("flag"), " lifetime=", mod.get("lifetime"))

func _on_cog_pressed() -> void:
	selected_modifier_flag = TileModifier.ModifierType.PROPERTY_COG

func _on_icy_pressed() -> void:
	selected_modifier_flag = TileModifier.ModifierType.CONDITION_ICY

func _on_sticky_pressed() -> void:
	selected_modifier_flag = TileModifier.ModifierType.CONDITION_STICKY

func _on_conveyer_pressed() -> void:
	selected_modifier_flag = TileModifier.ModifierType.PROPERTY_CONVEYER

func _on_springy_pressed() -> void:
	selected_modifier_flag = TileModifier.ModifierType.PROPERTY_SPRINGY

func _on_wall_pressed() -> void:
	selected_modifier_flag = TileModifier.ModifierType.PROPERTY_WALL

func _on_poison_pressed() -> void:
	selected_modifier_flag = TileModifier.ModifierType.PROPERTY_POISON

func _on_kings_favor_pressed() -> void:
	selected_modifier_flag = TileModifier.ModifierType.PROPERTY_KINGSFAVOR

func _on_gate_pressed() -> void:
	selected_modifier_flag = TileModifier.ModifierType.PROPERTY_GATE

func _on_button_pressed() -> void:
	selected_modifier_flag = TileModifier.ModifierType.PROPERTY_BUTTON

func _on_lever_pressed() -> void:
	selected_modifier_flag = TileModifier.ModifierType.PROPERTY_LEVER
