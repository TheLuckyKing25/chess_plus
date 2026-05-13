class_name TileState
extends GameData.ItemState


const THREATENED_COLOR: Color = Color(1, 0.2, 0.2, 1)
const VALID_COLOR: Color = Color(0.6, 1, 0.6, 1)
const SELECT_COLOR: Color = Color(0.1, 1, 1, 1)
const CHECKED_COLOR: Color = Color(1, 0.2, 0.2, 1)
const CASTLING_COLOR: Color = Color(1,1,1,1)
const MOVE_CHECKING_COLOR: Color = Color(1, 0.392, 0.153)


enum {
	CHECKED_MOVEMENT = 5,
	CHECKED = 4,
	THREATENED = 3,
	CASTLING = 2,
	MOVEMENT = 1,
	SELECTED = 0,
}


var state: Dictionary = {
	CHECKED_MOVEMENT: {"color": MOVE_CHECKING_COLOR, "enabled": false},
	CHECKED: {"color": CHECKED_COLOR, "enabled": false},
	THREATENED: {"color": THREATENED_COLOR, "enabled": false},
	CASTLING: {"color": CASTLING_COLOR, "enabled": false},
	MOVEMENT: {"color": VALID_COLOR, "enabled": false},
	SELECTED: {"color": SELECT_COLOR, "enabled": false},
}
