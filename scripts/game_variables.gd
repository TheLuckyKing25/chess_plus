class_name Game
extends Node3D


#region Piece Constants
enum PieceType{
	PIECE_TYPE_PAWN,
	PIECE_TYPE_ROOK,
	PIECE_TYPE_BISHOP,
	PIECE_TYPE_KNIGHT,
	PIECE_TYPE_KING,
	PIECE_TYPE_QUEEN,
	}


enum PawnPromotion{
	PAWN_PROMOTION_ROOK,
	PAWN_PROMOTION_BISHOP,
	PAWN_PROMOTION_KNIGHT,
	PAWN_PROMOTION_QUEEN,
	}


enum PieceStateFlag{
	PIECE_STATE_NONE, 
	PIECE_STATE_SELECTED, 
	PIECE_STATE_THREATENED, 
	PIECE_STATE_CAPTURED, 
	PIECE_STATE_CHECKED, 
	PIECE_STATE_CHECKING, 
	PIECE_STATE_SPECIAL,
	}


enum PieceAbilityFlag{
	PIECE_ABILITY_PLACEHOLDER
	}


enum PieceConditionFlag{
	PIECE_CONDITION_PLACEHOLDER
	}


enum PiecePropertyFlag{
	PIECE_PROPERTY_PLACEHOLDER
	}


const piece_script: Dictionary[int, Resource] = {
	PieceType.PIECE_TYPE_PAWN: preload("res://scripts/pawn.gd"),
	PieceType.PIECE_TYPE_ROOK: preload("res://scripts/rook.gd"),
	PieceType.PIECE_TYPE_BISHOP: preload("res://scripts/bishop.gd"),
	PieceType.PIECE_TYPE_KNIGHT: preload("res://scripts/knight.gd"),
	PieceType.PIECE_TYPE_KING: preload("res://scripts/king.gd"),
	PieceType.PIECE_TYPE_QUEEN: preload("res://scripts/queen.gd"),
}


const piece_mesh: Dictionary = {
	PieceType.PIECE_TYPE_PAWN: preload("res://assets/pawn_mesh.obj"),
	PieceType.PIECE_TYPE_ROOK: preload("res://assets/rook_mesh.obj"),
	PieceType.PIECE_TYPE_BISHOP: preload("res://assets/bishop_mesh.obj"),
	PieceType.PIECE_TYPE_KNIGHT: preload("res://assets/knight_mesh.obj"),
	PieceType.PIECE_TYPE_KING: preload("res://assets/king_mesh.obj"),
	PieceType.PIECE_TYPE_QUEEN: preload("res://assets/queen_mesh.obj"),
}
#endregion


#region Tile Constants
enum TilePropertyFlag{
	TILE_PROPERTY_PLACEHOLDER,
	}


enum TileConditionFlag{
	TILE_CONDITION_ICEY,
	TILE_CONDITION_STICKY,
	}


enum TileStateFlag{
	TILE_STATE_NONE,
	TILE_STATE_SELECTED,
	TILE_STATE_MOVEMENT,
	TILE_STATE_CHECKING,
	TILE_STATE_SPECIAL,
	TILE_STATE_THREATENED,
	TILE_STATE_CHECKED,
	}
#endregion


enum Direction{ 
	NORTH, 
	NORTHEAST, 
	EAST, 
	SOUTHEAST, 
	SOUTH, 
	SOUTHWEST, 
	WEST, 
	NORTHWEST,
	}
	
#region Game Colors Constants
## Color of a base tile which is lightened or darkened to make the board.
const TILE_COLOR: Color = Color(0.75, 0.5775, 0.435) 


const COLOR_PALETTE: Dictionary = {
	"TILE_COLOR_LIGHT": TILE_COLOR * 4/3,
	"TILE_COLOR_DARK": TILE_COLOR * 2/3,
	
	"VALID_TILE_COLOR": Color(0.6, 1, 0.6), 
	
	"THREATENED_PIECE_COLOR": Color(0.9, 0, 0),
	"THREATENED_TILE_COLOR": Color(1, 0.2, 0.2),
	
	"CHECKING_PIECE_COLOR": Color(0.9, 0.9, 0),
	"CHECKING_TILE_COLOR": Color(1, 1, 0.25),
	
	"SELECT_PIECE_COLOR": Color(0, 0.9, 0.9),
	"SELECT_TILE_COLOR": Color(0.1, 1, 1),
	
	"CHECKED_PIECE_COLOR": Color(0.9, 0, 0),
	"CHECKED_TILE_COLOR": Color(1, 0.2, 0.2),
	
	"MOVE_CHECKING_TILE_COLOR": Color(1, 0.65, 0.25),
	
	"SPECIAL_PIECE_COLOR": Color(1,1,1),
	"SPECIAL_TILE_COLOR": Color(1,1,1),
	
	"PLAYER_COLOR": [
		Color(0.9, 0.9, 0.9), 
		Color(0.1, 0.1, 0.1),
	],
}
#endregion

enum Player{
	PLAYER_ONE, 
	PLAYER_TWO
	}

const player_groups:Dictionary = {
	Player.PLAYER_ONE: "Player_One",
	Player.PLAYER_TWO: "Player_Two",
}

static var turn_num: int = 0
static var prev_player = Player.PLAYER_ONE
static var current_player: int = Player.PLAYER_ONE


## Settings that may or may not be implimented as game options
#region Settings
static var game_setting: Dictionary = {
	## You must move the first piece you select
	"TOUCH_MOVE": false, #Not implimented
}
		
static var debug_setting: Dictionary = {
	"DEBUG_RESTRICT_MOVEMENT": false,
}

static var user_setting: Dictionary = {
	"PIECE_OUTLINE_THICKNESS": 0.1,
	"CAMERA_ROTATION_SPEED": 5
}
#endregion

#region MoveRule Enums
# If Jump and Threaten are set at the same time, 
# then the moverule will check threaten validity then continue through tile 
## Actions performed by the piece on a tile
enum ActionType{ 
		NONE = 0,			# Unsets all flags
		JUMP = 1 << 0, 		# Continue through tile
		MOVE = 1 << 1, 		# Tile unoccupied
		THREATEN = 1 << 2,  # Tile occupied by opponent
		BRANCH = 1 << 3,	# Branch from tile, flag set on last moverule of a branch
		SPECIAL = 1 << 4,	# Used for special movements, flag set on last moverule of a branch
	}

## Purpose of the movement
## The same throughout entire moveset
enum PurposeType{ 
		UNSET = 0,
		STANDARD_MOVEMENT = 1,
		CASTLING = 2,			# used to find rook and to check if space between king and rook is clear
		ROOK_FINDING = 3,		# used to find rook and to check if space between king and rook is clear
		CHECK_DETECTING = 4,	# used for check detection
	}
#endregion


func piece_is_pawn(piece: Piece) -> bool:
	return piece and piece.is_in_group("Pawn")


func piece_is_bishop(piece: Piece) -> bool:
	return piece and piece.is_in_group("Bishop")


func piece_is_queen(piece: Piece) -> bool:
	return piece and piece.is_in_group("Queen")


func piece_is_king(piece: Piece) -> bool:
	return piece and piece.is_in_group("King")


func piece_is_rook(piece: Piece) -> bool:
	return piece and piece.is_in_group("Rook")


func piece_is_knight(piece: Piece) -> bool:
	return piece and piece.is_in_group("Knight")


func piece_is_opponent_of(piece1: Piece, piece2: Piece ) -> bool:
	return piece1 and piece2 and piece1.player != piece2.player


func piece_has_moved(piece: Piece) -> bool:
	return piece and piece.is_in_group("has_moved")


func pieces_are_different(piece1: Piece, piece2: Piece) -> bool:
	return piece1 and piece2 and piece1 != piece2

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
