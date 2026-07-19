class_name DirectionComponent
extends ModifierComponent

const _DIRECTION_BUTTON_ORDER: Array = [
	Constants.Direction.NORTHWEST,
	Constants.Direction.NORTH,
	Constants.Direction.NORTHEAST,
	Constants.Direction.WEST,
	null,
	Constants.Direction.EAST,
	Constants.Direction.SOUTHWEST,
	Constants.Direction.SOUTH,
	Constants.Direction.SOUTHEAST,
]

const NAME: String = "Direction"

var direction: Constants.Direction = Constants.Direction.NORTH

func create_setting() -> Control:
	var setting: HBoxContainer = HBoxContainer.new()
	setting.alignment = BoxContainer.ALIGNMENT_CENTER
	setting.add_theme_constant_override("separation", 10)

	var label: Label = Label.new()
	label.text = NAME

	var grid: GridContainer = GridContainer.new()
	grid.add_theme_constant_override("h_separation", 5)
	grid.add_theme_constant_override("v_separation", 5)
	grid.columns = 3

	var basic_button: Button = Button.new()
	basic_button.custom_minimum_size = Vector2(30,30)
	basic_button.toggle_mode = true

	var button_group = ButtonGroup.new()

	setting.add_child(label)
	setting.add_child(grid)
	var array: Array[Button] = []
	array.resize(9)
	for index in range(array.size()):
		array[index] = basic_button.duplicate()
		array[index].set_meta("direction", _DIRECTION_BUTTON_ORDER[index])
		grid.add_child(array[index])
		array[index].button_group = button_group

	array[1].button_pressed = true
	array[4].disabled = true
	array[4].flat = true

	button_group.pressed.connect(Callable(self,"on_direction_pressed"))

	return setting


func on_direction_pressed(button: BaseButton):
	direction = button.get_meta("direction") as Constants.Direction
