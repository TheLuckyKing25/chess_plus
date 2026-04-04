class_name Constants
extends RefCounted

# Credit to Queble on Youtube: https://youtu.be/acNQIBBIpQk?si=uzFgnBTi2P2lOh9g

const SCENE_PATHS: Dictionary = {
	"game_environment": "uid://h7v0gyqyq0h7",
	"match_creation_screen": "uid://bmtcaraovyhdt",
	"tile_modifier_screen": "uid://b1twmfuyqv1lx",
	"wait_screen": "uid://crgfep2xyg10g",
	"game_overlay": "uid://b2b5f3ejhqp35",
	"join_screen": "uid://cvr8wyhalupas",
	"loading_screen": "uid://v4i5knax4g12",
	"pause_screen": "uid://dh0xqsvmtokbh",
	"settings_menu": "uid://0fccgu7f77gg",
	"start_screen": "uid://2aw5r4ibxl8k",
	"selected_tile_modifier_button": "uid://ca80534plviow",
	"rulebook_menu": "uid://c0md30urlwow5",
	"tile_modifier_icon": "uid://dmyh3g5g0c8ou",
	"camera_with_controls": "uid://base8ln7a12p2",
	"board": "uid://vqvs470xc1lw",
	"piece": "uid://dnismskxjehm6",
	"tile": "uid://cega76qfg50kj",
	"smoke": "uid://6mhxpvgl814g",
}

const RESOURCE_PATHS: Dictionary = {
	"player_one": "uid://dxvl1tq0afyxx",
	"player_two": "uid://dc7e5u71wtrpp",
}

const ICON_PATHS: Dictionary = {
	"modifier": {
		"cog": "uid://rpbtfnubhk8n",
		"icy": "uid://cw82lp67yuedh",
		"smokey": "uid://c2qxlt526rfpo",
		"sticky": "uid://8jo5aw846ekg",
		"wall": "uid://ctd4y6jjqr4ta",
	}
}

const CAMERA_ROTATION_SPEED: int = 5
const TURN_TRANSITION_DELAY_MSEC: int = 500 # time to wait before starting transition
const MAX_TURN_TRANSITION_LENGTH_MSEC: float = 2000 # 2 Seconds
const TURN_TRANSITION_SPEED: float = CAMERA_ROTATION_SPEED/MAX_TURN_TRANSITION_LENGTH_MSEC
