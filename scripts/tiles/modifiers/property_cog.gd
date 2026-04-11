class_name PropertyCog
extends TileModifier

# The cog property changes the direction a piece is able to move in. Currently, this is temporary
# and the piece gains its normal movement back after moving off the piece.

@export var rotation: int


func _init():
	name = "Cog"
	flag = ModifierType.PROPERTY_COG
	color = Color(0.77,0.42,0)
	icon = load("uid://rpbtfnubhk8n")
	can_modify_movement = true


#region Dropdown UI Creation
func _create_dropdown_ui():
	dropdown_ui = VBoxContainer.new()
	dropdown_ui.alignment = BoxContainer.ALIGNMENT_CENTER
	dropdown_ui.add_theme_constant_override("separation", 10)

	dropdown_ui.add_child(_create_range_setting("Rotation Amount", "", "degrees", Callable(self,"_on_dropdown_rotation_changed")))


func _create_range_setting(text: String, _prefix:String, _suffix:String, _call_on_value_changed:Callable) -> Control:
	var setting: HBoxContainer = HBoxContainer.new()
	setting.alignment = BoxContainer.ALIGNMENT_CENTER
	setting.add_theme_constant_override("separation", 10)

	var label: Label = Label.new()
	label.text = text

	var amount:Range = SpinBox.new()
	amount.value = 0
	amount.min_value = 0
	amount.max_value = 315
	amount.step = 45
	amount.allow_greater = false
	amount.suffix = _suffix
	amount.editable = true
	amount.custom_minimum_size = Vector2(150,0)
	amount.value_changed.connect(_call_on_value_changed)

	setting.add_child(label)
	setting.add_child(amount)

	return setting


func _on_dropdown_rotation_changed(new_value:int):
	rotation = new_value/45
#endregion


func modify_movement(movement: Movement):
	if movement == null:
		return
	else:
		movement.rotate_movement(rotation)
