extends Game

signal modifierCountChanged(modifier_number:int, modifiers: Array)


var modifiers: Array = []:
	set(new_modifiers):
		modifierCountChanged.emit(new_modifiers.size(),new_modifiers)
		modifiers = new_modifiers
		change_grid_size()

const GRID_GAP = 31
const MODIFIER_SUBTILE_SIZE = 150

const MAX_COLUMN_NUM = 3

const SUBVIEWPORT_SIZE = 512

const SUBVIEWPORT_1_SCALE = Vector3(0.48,0.48,0.48)
const SUBVIEWPORT_1_SIZE = MODIFIER_SUBTILE_SIZE
const SUBVIEWPORT_1_RECT = Rect2(0,0,SUBVIEWPORT_1_SIZE,SUBVIEWPORT_1_SIZE)

const SUBVIEWPORT_2_SCALE = SUBVIEWPORT_1_SCALE/2
const SUBVIEWPORT_2_SIZE = (MODIFIER_SUBTILE_SIZE * 2) + GRID_GAP
const SUBVIEWPORT_2_RECT = Rect2(0,0,SUBVIEWPORT_2_SIZE,SUBVIEWPORT_2_SIZE)

const SUBVIEWPORT_3_SCALE: = SUBVIEWPORT_1_SCALE/3
const SUBVIEWPORT_3_SIZE = (MODIFIER_SUBTILE_SIZE * 3) + (GRID_GAP * 2)
const SUBVIEWPORT_3_RECT = Rect2(0,0,SUBVIEWPORT_3_SIZE,SUBVIEWPORT_3_SIZE)


func _on_grid_container_ready() -> void:
	modifierCountChanged.emit(modifiers.size(),modifiers)

func _on_ready():
	change_grid_size()

func change_grid_size():
	match modifiers.size():
		0: grid_size_0()
		1: grid_size_1()
		2,3,4: grid_size_2()
		5,6,7,8,9: grid_size_3()
		_: grid_size_3()

func grid_size_0():
	visible = false

func grid_size_1():
	visible = true
	self.region_rect = SUBVIEWPORT_1_RECT
	scale = SUBVIEWPORT_1_SCALE

func grid_size_2():
	visible = true
	self.region_rect = SUBVIEWPORT_2_RECT
	scale = SUBVIEWPORT_2_SCALE
	
func grid_size_3():
	visible = true
	visible = true
	self.region_rect = SUBVIEWPORT_3_RECT
	scale = SUBVIEWPORT_3_SCALE
