extends Node

const PORT: int = 9999
const MAX_PLAYERS: int = 2

var is_online: bool = false
var my_player: int = -1

signal connected_to_game
signal opponent_disconnected

func host_game() -> void:
	is_online = true
	my_player = 0 

	var peer = ENetMultiplayerPeer.new()
	var err = peer.create_server(PORT, MAX_PLAYERS)
	if err != OK:
		push_error("NetworkManager: Failed to create server — error %s" % err)
		return

	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	print("NetworkManager: Hosting on port %d, waiting for opponent..." % PORT)


func join_game(ip: String) -> void:
	is_online = true
	my_player = 1

	var peer = ENetMultiplayerPeer.new()
	var err = peer.create_client(ip, PORT)
	if err != OK:
		push_error("NetworkManager: Failed to connect to %s — error %s" % [ip, err])
		return

	multiplayer.multiplayer_peer = peer
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	print("NetworkManager: Connecting to %s:%d..." % [ip, PORT])

func _on_peer_connected(_id: int) -> void:
	print("NetworkManager: Peer connected — starting game.")
	connected_to_game.emit()

func _on_connected_to_server() -> void:
	print("NetworkManager: Connected to server — starting game.")
	connected_to_game.emit()

func _on_connection_failed() -> void:
	push_error("NetworkManager: Connection failed.")
	is_online = false

func _on_peer_disconnected(_id: int) -> void:
	print("NetworkManager: Opponent disconnected.")
	opponent_disconnected.emit()

## Always true in local/offline mode.
func is_my_turn(current_player_turn: int) -> bool:
	if not is_online:
		return true
	return current_player_turn == my_player
