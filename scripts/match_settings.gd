class_name MatchSettings
extends Resource

var board_size: Dictionary[String,int] = {
	"rank": 8,
	"file": 8,
	"levels": 1,
}

var starting_player: Player


var rules: Dictionary[String,bool] = {
	"castling": true,
	"en_passant": true,
	"promotion": true,
	"time_control": false,
}


var time_control: Dictionary[String,int] = {
	"time_per_player_minutes": 120,
	"increment_seconds": 0,
}
