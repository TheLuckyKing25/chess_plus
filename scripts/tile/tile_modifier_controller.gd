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
	_change_grid_size()

func _change_grid_size():
	match modifiers.size():
		0: visible = false
		1: _grid_size(SUBVIEWPORT_1_RECT,SUBVIEWPORT_1_SCALE)
		2,3,4: _grid_size(SUBVIEWPORT_2_RECT,SUBVIEWPORT_2_SCALE)
		5,6,7,8,9: _grid_size(SUBVIEWPORT_3_RECT,SUBVIEWPORT_3_SCALE)
		_: _grid_size(SUBVIEWPORT_3_RECT,SUBVIEWPORT_3_SCALE)


func _grid_size(rect:Rect2, new_scale:Vector3):
	visible = true
	self.region_rect = rect
	scale = new_scale
