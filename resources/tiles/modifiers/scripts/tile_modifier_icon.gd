class_name TileModifierIcon
extends Control

@onready var Icon = %Icon

@export var icon_image: Texture2D:
	get:
		return Icon.texture

@export var panel: StyleBoxFlat = preload("uid://b3b8tofmh4om0"):
	set(new_panel):
		add_theme_stylebox_override("panel",new_panel)
	get:
		return get_theme_stylebox("panel")

func _init(
		color:Color = Color(0.81,0.57,0.95),
		modifier_icon:Texture2D = PlaceholderTexture2D.new()
	):
	if modifier_icon is PlaceholderTexture2D:
		modifier_icon.size = Vector2(0,0)

	icon_image = modifier_icon
	panel.bg_color = color


func _on_icon_ready() -> void:
	set_icon(icon_image)

func set_icon(new_icon):
	icon_image = new_icon
	Icon.texture = new_icon
