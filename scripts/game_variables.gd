class_name Game

class Colour:
	## Game colors
	enum {
		TILE_LIGHT,
		TILE_DARK,
		
		VALID_TILE,
		
		THREATENED_PIECE,
		THREATENED_TILE,
		
		CHECKING_PIECE,
		CHECKING_TILE,
		
		SELECT_PIECE,
		SELECT_TILE,
		
		CHECKED_PIECE,
		CHECKED_TILE,
		
		MOVE_CHECKING_TILE,
		
		SPECIAL_PIECE,
		SPECIAL_TILE,
		
		PLAYER,
	}

	## Color of a base tile which is lightened or darkened to make the board.
	const COLOR_TILE: Color = Color(0.75, 0.5775, 0.435) 

	const PALETTE: Dictionary = {
		TILE_LIGHT: COLOR_TILE * 4/3,
		TILE_DARK: COLOR_TILE * 2/3,
		
		VALID_TILE: Color(0.6, 1, 0.6), 
		
		THREATENED_PIECE: Color(0.9, 0, 0),
		THREATENED_TILE: Color(1, 0.2, 0.2),
		
		CHECKING_PIECE: Color(0.9, 0.9, 0),
		CHECKING_TILE: Color(1, 1, 0.25),
		
		SELECT_PIECE: Color(0, 0.9, 0.9),
		SELECT_TILE: Color(0.1, 1, 1),
		
		CHECKED_PIECE: Color(0.9, 0, 0),
		CHECKED_TILE: Color(1, 0.2, 0.2),
		
		MOVE_CHECKING_TILE: Color(1, 0.65, 0.25),
		
		SPECIAL_PIECE: Color(1,1,1),
		SPECIAL_TILE: Color(1,1,1),
		
		PLAYER: [
			Color(0.9, 0.9, 0.9), 
			Color(0.1, 0.1, 0.1),
		],
	}
	
class Settings:
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
