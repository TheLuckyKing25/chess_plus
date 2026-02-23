class_name GameNode3D
extends Node3D

enum GameState {
	BoardCustomization,
	Gameplay
}

#region Piece Constants

enum PieceAbilityFlag{
	PIECE_ABILITY_PLACEHOLDER = 0
	}


enum PieceConditionFlag{
	PIECE_CONDITION_PLACEHOLDER = 0
	}


enum PiecePropertyFlag{
	PIECE_PROPERTY_PLACEHOLDER = 0
	}
#endregion


#region Tile Constants

enum TileModifierFlag{
	PROPERTY_COG = 1,
	CONDITION_ICY = 2,
	CONDITION_STICKY = 3,
	PROPERTY_CONVEYER = 4,
	PROPERTY_PRISM = 5,
	}

enum TileStateFlag{
	NONE = 0,
	SELECTED = 1,
	MOVEMENT = 2,
	CHECKING = 3,
	SPECIAL = 4,
	THREATENED = 5,
	CHECKED = 6,
	CHECKED_MOVEMENT = 7,
	}
#endregion

	
#region Game Colors Constants
## Color of a base tile which is lightened or darkened to make the board.

const COLOR_PALETTE: Dictionary = {		
	"TILE_CONDITIONS_BACKGROUND_COLOR": Color(0,0,0),
	"TILE_PROPERTIES_BACKGROUND_COLOR": Color(0,0,0)
}
#endregion


## Settings that may or may not be implimented as game options
#region Settings
static var game_setting: Dictionary = {
	## You must move the first piece you select
	"TOUCH_MOVE": false, #Not implimented
}
		
static var debug_setting: Dictionary = {
	"DEBUG_RESTRICT_MOVEMENT": false,
	"DEBUG_SKIP_TITLE": false,
	"DEBUG_SKIP_MATCHSELECTION": false,
}

const USER_SETTING: Dictionary[String,float] = {
	"PIECE_OUTLINE_THICKNESS": 0.1,
	"CAMERA_ROTATION_SPEED": 5
}
#endregion


#region Bit Flag Manipulation

var Flag:	Dictionary[String,Callable] = {
	"set_func": Callable(self,"set_flag"),
	"unset_func": Callable(self,"unset_flag"),
	"toggle_func": Callable(self,"toggle_flag"),
	"is_enabled_func": Callable(self,"flag_is_enabled"),
}

func unset_flag(bitfield: int, flag: int) -> int:
	bitfield &= ~(1 << flag)
	return bitfield
	

func set_flag(bitfield: int, flag: int) -> int:
	bitfield |= 1 << flag
	return bitfield


func toggle_flag(bitfield: int, flag: int) -> int:
	bitfield ^= 1 << flag
	return bitfield
	
func flag_is_enabled(bitfield: int, flag: int) -> bool:
	return bitfield & (1 << flag)

#endregion
