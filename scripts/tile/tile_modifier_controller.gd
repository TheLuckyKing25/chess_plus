extends GameNode3D

signal modifierCountChanged(modifier_number:int, modifiers: Array)


var modifiers: Array[TileModifier] = []:
	set(new_modifiers):
		modifierCountChanged.emit(new_modifiers.size(),new_modifiers)
		modifiers = new_modifiers
		_change_grid_size()

const GRID_GAP = 31
const MODIFIER_SUBTILE_SIZE = 150

const MAX_COLUMN_NUM = 3

const SUBVIEWPORT_SIZE = 512

const SUBVIEWPORT_1_SIZE = MODIFIER_SUBTILE_SIZE
const SUBVIEWPORT_1_RECT = Rect2(0,0,SUBVIEWPORT_1_SIZE,SUBVIEWPORT_1_SIZE)

const SUBVIEWPORT_2_SIZE = (MODIFIER_SUBTILE_SIZE * 2) + GRID_GAP
const SUBVIEWPORT_2_RECT = Rect2(0,0,SUBVIEWPORT_2_SIZE,SUBVIEWPORT_2_SIZE)

const SUBVIEWPORT_3_SIZE = (MODIFIER_SUBTILE_SIZE * 3) + (GRID_GAP * 2)
const SUBVIEWPORT_3_RECT = Rect2(0,0,SUBVIEWPORT_3_SIZE,SUBVIEWPORT_3_SIZE)


func _on_grid_container_ready() -> void:
	modifierCountChanged.emit(modifiers.size(),modifiers)

func _on_ready():
	_change_grid_size()

func _change_grid_size():
	match modifiers.size():
		0: visible = false
		1: self.texture.region = SUBVIEWPORT_1_RECT
		2,3,4: self.texture.region = SUBVIEWPORT_2_RECT
		5,6,7,8,9: self.texture.region = SUBVIEWPORT_3_RECT
		_: self.texture.region = SUBVIEWPORT_3_RECT
