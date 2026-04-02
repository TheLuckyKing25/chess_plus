extends Node

signal game_hosted(ip: String, code: String)

const MAX_PLAYERS: int = 2

var is_online: bool = false
var my_player: int = -1

signal connected_to_game
signal opponent_disconnected

func get_local_ip() -> String:
	for address in IP.get_local_addresses():
		if address.begins_with("192.168.") or address.begins_with("10."):
			return address
		if address.begins_with("172."):
			var second_octet = address.split(".")[1].to_int()
			if second_octet >= 16 and second_octet <= 31:
				return address
	return "127.0.0.1"

func code_to_port(code: String) -> int:
	var port = 0
	if code.length() < 4:
		return -1 
		
	for i in range(4):
		var char_value = code.unicode_at(i) - 65
		port += char_value * int(pow(26, i))
		
	return port

func port_to_code(port: int) -> String:
	var code = ""
	var n = port
	for i in range(4):
		code += char(65 + (n % 26)) 
		n /= 26
	return code

func host_game() -> Dictionary:
	is_online = true
	my_player = 0 

	var port = randi_range(1024, 65535)
	var peer = ENetMultiplayerPeer.new()
	var err = peer.create_server(port, MAX_PLAYERS)
	if err != OK:
		push_error("NetworkManager: Failed to create server — error %s" % err)
		is_online = false
		return {}

	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	print("NetworkManager: Hosting on port %d, waiting for opponent..." % port)
	var result = { "ip": get_local_ip(), "code": port_to_code(port) }
	print("emitting game_hosted: ", result)
	game_hosted.emit(result["ip"], result["code"])
	return result


func join_game(ip: String, code: String) -> void:
	is_online = true
	my_player = 1

	var port = code_to_port(code)
	var peer = ENetMultiplayerPeer.new()
	var err = peer.create_client(ip, port)
	if err != OK:
		push_error("NetworkManager: Failed to connect to %s — error %s" % [ip, err])
		is_online = false
		return

	multiplayer.multiplayer_peer = peer
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	print("NetworkManager: Connecting to %s:%d..." % [ip, port])

func _on_peer_connected(_id: int) -> void:
	print("NetworkManager: Peer connected. starting game.")
	connected_to_game.emit()

func _on_connected_to_server() -> void:
	print("NetworkManager: Connected to server. starting game.")
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
