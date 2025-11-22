class_name Game

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
	PIECE_STATE_FLAG_NONE, 
	PIECE_STATE_FLAG_SELECTED, 
	PIECE_STATE_FLAG_THREATENED, 
	PIECE_STATE_FLAG_CAPTURED, 
	PIECE_STATE_FLAG_CHECKED, 
	PIECE_STATE_FLAG_CHECKING, 
	PIECE_STATE_FLAG_SPECIAL,
	}


enum TileStateFlag{
	TILE_STATE_FLAG_NONE,
	TILE_STATE_FLAG_SELECTED,
	TILE_STATE_FLAG_MOVEMENT,
	TILE_STATE_FLAG_CHECKING,
	TILE_STATE_FLAG_SPECIAL_MOVEMENT,
	TILE_STATE_FLAG_THREATENED,
	TILE_STATE_FLAG_CHECKED,
	}

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

## Settings that may or may not be implimented as game options
enum {
	# Debug settings
	DEBUG_RESTRICT_MOVEMENT,
	
	# Game settings
	## Show the path that a piece uses to check a king
	SHOW_CHECKING_PIECE_PATH,
	## Show the piece that is checking a king
	SHOW_CHECKING_PIECE,
	## You must move the first piece you select
	TOUCH_MOVE,  #Not implimented
	
	# Player settings
	PIECE_OUTLINE_THICKNESS,	
}

static var options: Dictionary = {
	DEBUG_RESTRICT_MOVEMENT: false,
	
	SHOW_CHECKING_PIECE_PATH: true,
	SHOW_CHECKING_PIECE: true,
	TOUCH_MOVE: false,
	
	PIECE_OUTLINE_THICKNESS: 0.1,
}
		
