class_name RotationComponent
extends ModifierComponent

const NAME: String = "Rotation"
const UNIT: String = "degrees"

var value: int

func create_setting() -> Control:
	var setting: HBoxContainer = HBoxContainer.new()
	setting.alignment = BoxContainer.ALIGNMENT_CENTER
	setting.add_theme_constant_override("separation", 10)

	var label: Label = Label.new()
	label.text = NAME

	var amount:Range = SpinBox.new()
	amount.value = 0
	amount.min_value = 0
	amount.max_value = 315
	amount.step = 45
	amount.allow_greater = false
	amount.suffix = UNIT
	amount.editable = true
	amount.custom_minimum_size = Vector2(150,0)
	amount.value_changed.connect(Callable(self,"on_rotation_changed"))

	setting.add_child(label)
	setting.add_child(amount)

	return setting


func on_rotation_changed(new_value:int):
	value = new_value/45
