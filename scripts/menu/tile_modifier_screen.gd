extends Control

const TILE_MODIFIER_BUTTON:PackedScene = preload("uid://ca80534plviow")

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
	"Promote(WIP)": PropertyPromote,
	"Gate(WIP)": PropertyGate,
	"Button(WIP)": PropertyButton,
	"Lever(WIP)": PropertyLever
}

var tile_modifier_list: Array[TileModifier] = []

func _ready() -> void:
	for modifier in MODIFIER_LOOKUP.keys():
		%ModiferList.add_item(modifier)

func connect_to_scene_buttons(
		back_pressed: Callable,
		continue_pressed: Callable,
		host_pressed: Callable
		):
	%BackButton.pressed.connect(back_pressed)
	%ContinueButton.pressed.connect(continue_pressed)
	%HostButton.pressed.connect(host_pressed)

func disconnect_from_scene_buttons(
		back_pressed: Callable,
		continue_pressed: Callable,
		host_pressed: Callable
		):
	%BackButton.pressed.disconnect(back_pressed)
	%ContinueButton.pressed.disconnect(continue_pressed)
	%HostButton.pressed.disconnect(host_pressed)


func _connect_to_back_button(function:Callable):
	%BackButton.pressed.connect(function)

func _connect_to_continue_button(function:Callable):
	%ContinueButton.pressed.connect(function)

func _connect_to_host_button(function: Callable):
	%HostButton.pressed.connect(function)

func _disconnect_from_back_button(function:Callable):
	%BackButton.pressed.disconnect(function)

func _disconnect_from_continue_button(function:Callable):
	%ContinueButton.pressed.disconnect(function)

func _disconnect_from_host_button(function: Callable):
	%HostButton.pressed.disconnect(function)


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
		tile.change("is_selected",false)
		tile.remove_from_group("Selected")
	for child in %AppliedTileModifiers.get_children():
		%AppliedTileModifiers.remove_child(child)
		child.queue_free()

func _on_replace_pressed() -> void:
	var tiles := get_tree().get_nodes_in_group("Selected")
	#print("REPLACE pressed. Selected tiles:", tiles.size())

	for tile in tiles:
		tile.data.modifier_order = tile_modifier_list.duplicate(true)
		tile.change("is_selected",false)
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
