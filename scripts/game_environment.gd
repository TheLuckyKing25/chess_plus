extends Node3D

@export_group("Settings")

# Player settings
@export var PIECE_OUTLINE_THICKNESS: float = 0.1
# Debug settings
@export var DEBUG_RESTRICT_MOVEMENT: bool = true
# Game settings
## Show the path that a piece uses to check a king
@export var GAME_SHOW_CHECKING_PIECE_PATH: bool = true
## Show the piece that is checking a king
@export var GAME_SHOW_CHECKING_PIECE: bool = true
## You must move the first piece you select
@export var GAME_TOUCH_MOVE_RULE: bool = false # Not implimented


## Settings that may or may not be implimented as game options
var options: Dictionary = {
	# Debug settings
	"DEBUG_RESTRICT_MOVEMENT": true,
	
	# Game settings
	## Show the path that a piece uses to check a king
	"SHOW_CHECKING_PIECE_PATH": true,
	## Show the piece that is checking a king
	"SHOW_CHECKING_PIECE": true,
	## You must move the first piece you select
	"TOUCH_MOVE": false, # Not implimented
	
	# Player settings
	"PIECE_OUTLINE_THICKNESS": 0.1,
}


@onready var board = $"/root/gameEnvironment/Board"
@onready var base = $"/root/gameEnvironment/Board/BoardBase"
