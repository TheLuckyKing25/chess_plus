class_name Player
extends Resource

## Used to group the pieces belonging to the player
@export var name:String

@export var color:Color

## The player whose turn it is
static var current: Player
static var previous: Player

static var en_passant: Player

## Unused. 
## Can be used with more than two players where turn order matters.
static var turn_order: Array
