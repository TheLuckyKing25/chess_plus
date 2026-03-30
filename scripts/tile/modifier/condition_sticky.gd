class_name ConditionSticky
extends TileModifier

# The sticky condition blocks all movement indefinitely until the tile expires.

## The number of turns that the Sticky condition remains on a tile,
## from  [code]0[/code]  to  [code]1000[/code] .[br]
## Setting it to  [code]-1[/code]  means infinite lifetime.
@export_range(-1,1000,1.0,"suffix: turns") var lifetime: int

func _init():
	flag = ModifierType.CONDITION_STICKY
	color = Color(0.1, 0.1, 0.1)
	is_stopping = true


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
	lifetime = new_value

#endregion


func blocks_movement(board, piece, tile) -> bool:
	return true
