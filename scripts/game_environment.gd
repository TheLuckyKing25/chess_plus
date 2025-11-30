extends Node3D

@onready var board = $"/root/gameEnvironment/Board"
@onready var base = $"/root/gameEnvironment/Board/BoardBase"
var piece_to_promote = null


func _ready():
	board.promotion_requested.connect(_on_promotion_requested)
	
	
func _on_promotion_requested(piece):
	get_tree().paused = true
	piece_to_promote = piece
	var mouse_pos = get_viewport().get_mouse_position()
	$CanvasLayer/PromoteMenu.position = mouse_pos
	$CanvasLayer/PromoteMenu.show()
	

func _on_queen_pressed():
	get_tree().paused = false
	board.promote(piece_to_promote, Game.PawnPromotion.PAWN_PROMOTION_QUEEN)
	piece_to_promote = null
	$CanvasLayer/PromoteMenu.hide()

func _on_knight_pressed():
	get_tree().paused = false
	board.promote(piece_to_promote, Game.PawnPromotion.PAWN_PROMOTION_KNIGHT)
	piece_to_promote = null
	$CanvasLayer/PromoteMenu.hide()
	
func _on_rook_pressed():
	get_tree().paused = false
	board.promote(piece_to_promote, Game.PawnPromotion.PAWN_PROMOTION_ROOK)
	piece_to_promote = null
	$CanvasLayer/PromoteMenu.hide()

func _on_bishop_pressed():
	get_tree().paused = false
	board.promote(piece_to_promote, Game.PawnPromotion.PAWN_PROMOTION_BISHOP)
	piece_to_promote = null
	$CanvasLayer/PromoteMenu.hide()
