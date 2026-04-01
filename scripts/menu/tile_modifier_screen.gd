extends Control

const TILE_MODIFIER_BUTTON:PackedScene = preload("res://scenes/menu/selected_tile_modifier_button.tscn")

var MODIFIER_LOOKUP: Dictionary = {
	"Cog": PropertyCog,
	"Icy": ConditionIcy,
	"Sticky": ConditionSticky,
	"Smokey": PropertySmokey,
	"Prism": PropertyPrism,
	"Wall": PropertyWall,
	"Conveyer(WIP)": PropertyConveyer,
	"Springy(WIP)": PropertySpringy,
	"Poison(WIP)": PropertyPoison,
	"Promote(WIP)": PropertyKingsFavor,
	"Gate(WIP)": PropertyGate,
	"Button(WIP)": PropertyButton,
	"Lever(WIP)": PropertyLever,
}

var tile_modifier_list: Array[TileModifier] = []

func _ready() -> void:
	NetworkManager.game_hosted.connect(_on_game_hosted)
	for modifier in MODIFIER_LOOKUP.keys():
		%ModiferList.add_item(modifier)

func _on_game_hosted(ip: String,code: String) -> void:
	print("signal received: ", code)
	$ReferenceRect/BoxContainer/ScreenNavigationMenu/BoxContainer/HostCodeBackgroundPanel/Panel/MarginContainer/HostCodeLabel.text = "Code: %s\nIP: %s" % [code, ip]

func _connect_to_back_button(function:Callable):
	%BackButton.pressed.connect(function)


func _connect_to_continue_button(function:Callable):
	%ContinueButton.pressed.connect(function)


func _on_modifer_list_item_selected(index: int) -> void:
	var new_tile_modifier_button = TILE_MODIFIER_BUTTON.instantiate()
	new_tile_modifier_button.text = %ModiferList.get_item_text(index)
	new_tile_modifier_button.associated_modifier = MODIFIER_LOOKUP[new_tile_modifier_button.text].new()

	%AppliedTileModifiers.add_child(new_tile_modifier_button)
	new_tile_modifier_button.index = new_tile_modifier_button.get_index()
	new_tile_modifier_button.down_pressed.connect(Callable(self,"_on_selected_tile_modifier_button_down_button_pressed"))
	new_tile_modifier_button.up_pressed.connect(Callable(self,"_on_selected_tile_modifier_button_up_button_pressed"))


func _on_selected_tile_modifier_button_down_button_pressed(index: int):
	%AppliedTileModifiers.move_child(%AppliedTileModifiers.get_child(index), index + 1)
	for modifier in %AppliedTileModifiers.get_children():
		modifier.index = modifier.get_index()


func _on_selected_tile_modifier_button_up_button_pressed(index: int):
	%AppliedTileModifiers.move_child(%AppliedTileModifiers.get_child(index), index - 1)
	for modifier in %AppliedTileModifiers.get_children():
		modifier.index = modifier.get_index()

func _on_selected_tile_modifier_button_remove_button_pressed():
	for modifier in %AppliedTileModifiers.get_children():
		modifier.index = modifier.get_index()

# Button Handling
func _on_add_pressed() -> void:
	var tiles = get_tree().get_nodes_in_group("Selected")
	#print("ADD pressed. Selected tiles:", tiles.size())

	for tile in tiles:
		var tile_modifier_order = tile.data.modifier_order
		tile_modifier_order.append_array(tile_modifier_list.duplicate(true))
		tile.data.modifier_order = tile_modifier_order
		tile._unselect()
		tile.remove_from_group("Selected")
	for child in %AppliedTileModifiers.get_children():
		%AppliedTileModifiers.remove_child(child)
		child.queue_free()

func _on_replace_pressed() -> void:
	var tiles := get_tree().get_nodes_in_group("Selected")
	#print("REPLACE pressed. Selected tiles:", tiles.size())

	for tile in tiles:
		tile.data.modifier_order = tile_modifier_list.duplicate(true)
		tile._unselect()
		tile.remove_from_group("Selected")
	for child in %AppliedTileModifiers.get_children():
		%AppliedTileModifiers.remove_child(child)
		child.queue_free()

func _on_erase_pressed() -> void:
	var tiles:= get_tree().get_nodes_in_group("Selected")
	#print("ERASE pressed. Selected tiles:", tiles.size())

	for tile in tiles:
		tile.data.clear_modifiers()



func _on_applied_tile_modifiers_child_order_changed() -> void:
	if not %AppliedTileModifiers:
		return

	tile_modifier_list.clear()
	for modifier_button in %AppliedTileModifiers.get_children():
		tile_modifier_list.append(modifier_button.associated_modifier)
