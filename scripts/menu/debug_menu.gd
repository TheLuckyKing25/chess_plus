extends Control

signal new_placement_selected(placement:FEN)

var placement_tree: Dictionary = {
	"Standard Board": "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1",
	"Castling": {
			"All Valid": "r3k2r/pppppppp/8/8/8/8/PPPPPPPP/R3K2R w KQkq - 0 1",
			"Kingside Valid": "r3k2r/pppppppp/8/8/8/8/PPPPPPPP/R3K2R w Kk - 0 1",
			"Queenside Valid": "r3k2r/pppppppp/8/8/8/8/PPPPPPPP/R3K2R w Qq - 0 1",
			"None Valid": "r3k2r/pppppppp/8/8/8/8/PPPPPPPP/R3K2R w - - 0 1",
			"King Checked": "r3k2r/pppp1ppp/8/4Q3/4q3/8/PPPP1PPP/R3K2R w KQkq - 0 1",
			"Checked Close Movement": "r3k2r/ppp1p1pp/8/3Q1Q2/3q1q2/8/PPP1P1PP/R3K2R w KQkq - 0 1",
			"Checked Far Movement": "r3k2r/pp1ppp1p/8/2Q3Q1/2q3q1/8/PP1PPP1P/R3K2R w KQkq - 0 1",
			},
}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var root: TreeItem = %PiecePlacementList.create_item()
	for section in placement_tree.keys():
		var new_item: TreeItem = %PiecePlacementList.create_item(root)
		if typeof(placement_tree[section]) != TYPE_STRING:
			new_item.set_text(0,section)
			new_item.set_selectable(0,false)
			add_placements_to_section(new_item, section)
			new_item.collapsed = true
		else:
			new_item.set_text(0,section)
			new_item.set_metadata(0, placement_tree[section])
			new_item.set_selectable(0,true)


func add_placements_to_section(item: TreeItem, section:String):
	for placement in placement_tree[section].keys():
		var new_item: TreeItem = item.create_child()
		new_item.set_text(0,placement)
		new_item.set_metadata(0, placement_tree[section][placement])
		new_item.set_selectable(0,true)



func _on_piece_placement_list_item_selected() -> void:
	var selected_item: TreeItem = %PiecePlacementList.get_selected()
	var placement_key: FEN = FEN.new(selected_item.get_metadata(0))
	new_placement_selected.emit(placement_key)
