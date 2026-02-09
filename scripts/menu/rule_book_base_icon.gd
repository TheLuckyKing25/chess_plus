@tool
extends Control

@export var label_name:String:
	set(string):
		label_name = string
		$Panel/Label.text = string

@export_custom(PROPERTY_HINT_RESOURCE_TYPE, "AtlasTexture") var icon_image: AtlasTexture:
	set(icon):
		icon_image = icon
		$Panel/TextureRect.texture = icon
