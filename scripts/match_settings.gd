class_name MatchSettings
extends Resource

@export var board_size: Dictionary[String,int] = {
	"rank": 8,
	"file": 8,
	"levels": 1,
}


@export var starting_player: PlayerData


@export var rules: Dictionary[String,bool] = {
	"castling": true,
	"en_passant": true,
	"promotion": true,
	"time_control": false,
}


@export var time_control: Dictionary[String,int] = {
	"time_per_player_minutes": 120,
	"increment_seconds": 0,
}
