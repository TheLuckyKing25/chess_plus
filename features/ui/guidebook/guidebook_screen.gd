extends Control

@onready var back_button: Button = %BackButton

var root_node: TreeItem

var categories: Dictionary[String,TreeItem] = {}

var pages: Array[GuidebookPage] = []

func load_guidebook_pages():
	var dir := DirAccess.open("res://resources/guidebook")
	if dir == null: printerr("Could not open folder"); return
	dir.list_dir_begin()
	for file: String in dir.get_files():
		var resource := load(dir.get_current_dir() + "/" + file)
		pages.append(resource)

func _on_content_tree_ready() -> void:
	root_node = %ContentTree.create_item()
	load_guidebook_pages()
	for item:GuidebookPage in pages:
		if not categories.has(item.category):
			var category: TreeItem = %ContentTree.create_item()
			category.custom_minimum_height = 25
			category.set_text(0,item.category)
			categories[item.category] = category
		var tree_item: TreeItem = %ContentTree.create_item(categories[item.category])
		tree_item.custom_minimum_height = 25
		if item.icon:
			tree_item.set_icon(0,item.icon)
			tree_item.set_icon_max_width(0,25)
		if item.name:
			tree_item.set_text(0,item.name)
