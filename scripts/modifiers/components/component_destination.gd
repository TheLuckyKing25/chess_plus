class_name DestinationComponent
extends ModifierComponent

const NAME: String = "Destination"

var vector: Vector2i = Vector2i(0,0)

func create_setting() -> Control:
	var setting: HBoxContainer = HBoxContainer.new()
	setting.alignment = BoxContainer.ALIGNMENT_CENTER
	setting.add_theme_constant_override("separation", 10)

	var coords: VBoxContainer = VBoxContainer.new()
	coords.alignment = BoxContainer.ALIGNMENT_CENTER
	coords.add_theme_constant_override("separation", 10)

	var label: Label = Label.new()
	label.text = NAME

	var amount:Range = SpinBox.new()
	amount.value = -1
	amount.min_value = 0
	amount.step = 1
	amount.allow_greater = false
	amount.editable = true
	amount.custom_minimum_size = Vector2(150,0)

	var file:Range = amount.duplicate()
	var rank:Range = amount.duplicate()

	file.max_value = Match.board.data.file_count
	file.prefix = "File"
	file.value_changed.connect(Callable(self,"on_file_value_changed"))

	rank.max_value = Match.board.data.rank_count
	rank.prefix = "Rank"
	rank.value_changed.connect(Callable(self,"on_rank_value_changed"))

	setting.add_child(label)
	setting.add_child(coords)
	coords.add_child(file)
	coords.add_child(rank)

	return setting

func on_file_value_changed(new_value:int):
	vector.y = new_value

func on_rank_value_changed(new_value:int):
	vector.x = new_value
