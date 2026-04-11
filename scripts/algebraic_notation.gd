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
	if move.flags == Move.Type.IGNORE:
		return ""
	elif move.flags & Move.Type.CASTLING_QUEENSIDE:
		return ALGEBRAIC_NOTATION_CASTLING_QUEENSIDE

	elif move.flags & Move.Type.CASTLING_KINGSIDE:
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

	if move.flags & Move.Type.CAPTURING:
		notation.capturing = ALGEBRAIC_NOTATION_CAPTURE

	if move.flags & Move.Type.CHECK:
		notation.check_status += ALGEBRAIC_NOTATION_CHECK
	elif move.flags & Move.Type.CHECKMATE:
		notation.check_status += ALGEBRAIC_NOTATION_CHECKMATE

	if move.flags & Move.Type.EN_PASSANT:
		notation.en_passant += " " + ALGEBRAIC_NOTATION_EN_PASSANT
	elif move.flags & Move.Type.PROMOTION:
		notation.promoted_to += ALGEBRAIC_NOTATION_PROMOTION
