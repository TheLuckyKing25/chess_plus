class_name AlgebraicNotaion
extends RefCounted

const ALGEBRAIC_NOTATION_EN_PASSANT = "e.p."
const ALGEBRAIC_NOTATION_CASTLING_KINGSIDE = "O-O"
const ALGEBRAIC_NOTATION_CASTLING_QUEENSIDE = "O-O-O"
const ALGEBRAIC_NOTATION_CHECK = "+"
const ALGEBRAIC_NOTATION_CHECKMATE = "#"
const ALGEBRAIC_NOTATION_PROMOTION = "="
const ALGEBRAIC_NOTATION_CAPTURE = "x"

static func get_notation(move:Move):
	if move.ignore_move:
		return ""
	elif move.outcome_flag.castling_queenside.enabled:
		return ALGEBRAIC_NOTATION_CASTLING_QUEENSIDE

	elif move.outcome_flag.castling_kingside.enabled:
		return ALGEBRAIC_NOTATION_CASTLING_KINGSIDE

	var notation: Dictionary = {
		"piece": "",
		"starting_tile": "",
		"capturing": "",
		"destination_tile": "",
		"promoted_to": "",
		"en_passant": "",
		"check_status": "",
	}

	notation.piece = move.starting_tile.occupant.data.algebraic_notation
	notation.starting_tile = move.starting_tile
	notation.destination_tile = move.destination_tile

	if move.outcome_flag.capturing.enabled:
		notation.capturing = ALGEBRAIC_NOTATION_CAPTURE

	if move.outcome_flag.check.enabled:
		notation.check_status += ALGEBRAIC_NOTATION_CHECK
	elif move.outcome_flag.checkmate.enabled:
		notation.check_status += ALGEBRAIC_NOTATION_CHECKMATE

	if move.outcome_flag.en_passant.enabled:
		notation.en_passant += " " + ALGEBRAIC_NOTATION_EN_PASSANT
	elif move.outcome_flag.promotion.enabled:
		notation.promoted_to += ALGEBRAIC_NOTATION_PROMOTION
