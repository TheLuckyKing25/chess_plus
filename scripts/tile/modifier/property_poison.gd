class_name PropertyPoison
extends TileModifier

@export_range(-1, 1000, 1.0, "suffix: turns") var lifetime: int = 3
@export_range(-1, 1000, 1.0, "suffix: turns") var duration: int = 3

func _init():
	flag = ModifierType.PROPERTY_POISON
	color = Color(0.5,0.25,0.7)


func _create_dropdown_ui():
	dropdown_ui = VBoxContainer.new()
	dropdown_ui.alignment = BoxContainer.ALIGNMENT_CENTER
	dropdown_ui.add_theme_constant_override("separation", 10)

	dropdown_ui.add_child(_create_range_setting("Lifetime", "", "turns", Callable(self,"_on_dropdown_lifetime_changed")))
	dropdown_ui.add_child(_create_range_setting("Effect Duration", "", "turns",Callable(self,"_on_dropdown_duration_changed")))


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


func _on_dropdown_lifetime_changed(new_value:int):
	if new_value == 0:
		lifetime = 1000
	else:
		lifetime = new_value


func _on_dropdown_duration_changed(new_value:int):
	duration = new_value


func on_piece_enter(board, piece, from_tile, to_tile) -> void:
	piece.data.is_poisoned = true
	piece.data.poison_turn_applied = board._turn_num
	piece.data.poison_duration = duration
