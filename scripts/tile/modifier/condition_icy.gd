class_name ConditionIcy
extends TileModifier

# The icy condition slides a piece an additional one tile in the direction they moved.

## The number of turns that the Icy condition remains on a tile,
## from  [code]0[/code]  to  [code]1000[/code] .[br]
## Setting it to  [code]-1[/code]  means infinite lifetime.
@export_range(-1,1000,1.0,"suffix: turns") var lifetime: int


func _init():
	flag = ModifierType.CONDITION_ICY
	color = Color(0.75, 1, 1)
	is_slippery = true

#region Dropdown UI Creation
func _create_dropdown_ui():
	dropdown_ui = VBoxContainer.new()
	dropdown_ui.alignment = BoxContainer.ALIGNMENT_CENTER
	dropdown_ui.add_theme_constant_override("separation", 10)
	dropdown_ui.add_child(_create_range_setting("Lifetime", "", "turns", Callable(self,"_on_dropdown_range_changed")))


func _create_range_setting(text: String, _prefix:String, _suffix:String, _call_on_value_changed:Callable) -> Control:
	var setting: HBoxContainer = HBoxContainer.new()
	setting.alignment = BoxContainer.ALIGNMENT_CENTER
	setting.add_theme_constant_override("separation", 10)

	var label: Label = Label.new()
	label.text = text

	var amount:Range = SpinBox.new()
	amount.value = -1
	amount.min_value = 0
	amount.max_value = 1000
	amount.step = 1
	amount.allow_greater = true
	amount.suffix = _suffix
	amount.editable = true
	amount.custom_minimum_size = Vector2(150,0)
	amount.value_changed.connect(_call_on_value_changed)

	setting.add_child(label)
	setting.add_child(amount)

	return setting


func _on_dropdown_range_changed(new_value:int):
	if new_value == 0:
		lifetime = 1000
	else:
		lifetime = new_value
#endregion


func on_piece_enter(board, piece, from_tile, to_tile) -> void:
	if from_tile == null or to_tile == null:
		return

	var delta: Vector2i = to_tile.data.board_position - from_tile.data.board_position
	if delta == Vector2i.ZERO:
		return

	# Normalize delta or else the piece will double movement rather than 1 tile
	delta.x = sign(delta.x)
	delta.y = sign(delta.y)

	var next_pos: Vector2i = to_tile.data.board_position + delta

	if next_pos.x < 0 or next_pos.x >= board.data.rank_count:
		return
	if next_pos.y < 0 or next_pos.y >= board.data.file_count:
		return

	var next_tile = board.data.tile_array[board.data.get_index(next_pos.x, next_pos.y)]
	if next_tile == null:
		return
	if next_tile.occupant != null:
		return

	board.perform_move(Move.new(to_tile, next_tile))
