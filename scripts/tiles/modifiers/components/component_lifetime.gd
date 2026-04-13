class_name LifetimeComponent
extends ModifierComponent

## The number of turns that the modifier remains on a tile

const NAME: String = "Lifetime"
const UNIT: String = "turns"

var value: int

func create_setting() -> Control:
	var setting: HBoxContainer = HBoxContainer.new()
	setting.alignment = BoxContainer.ALIGNMENT_CENTER
	setting.add_theme_constant_override("separation", 10)

	var label: Label = Label.new()
	label.text = NAME

	var amount:Range = SpinBox.new()
	amount.value = -1
	amount.min_value = 0
	amount.max_value = 1000
	amount.step = 1
	amount.allow_greater = true
	amount.suffix = UNIT
	amount.editable = true
	amount.custom_minimum_size = Vector2(150,0)
	amount.value_changed.connect(Callable(self,"on_value_changed"))

	setting.add_child(label)
	setting.add_child(amount)

	return setting

func on_value_changed(new_value:int):
	if new_value == 0:
		value = 1000
	else:
		value = new_value
