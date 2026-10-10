# Debug Printer Autoload
# contains all debug print functions and enable/disable switches
class_name Debug

class Printer:
	const INDENT: String = "[indent]"

	const debug_print_switch: Dictionary = {
		"state_enter": false,
		"state_exit": false,
	}

	static func print_state_enter(state_name:String):
		if debug_print_switch.state_enter:
			print_rich("[b][color=web_green]Entered[/color]: [/b]",state_name)


	static func print_state_exit(state_name:String):
		if debug_print_switch.state_exit:
			print_rich("[b][color=brown]Exited[/color]: [/b]",state_name)


	# Names used to group together print statements
	enum ChannelNames {
		BOARD_CHANGE = 1,

		CLICKED_SIGNAL = 1,

		PIECE_INITIALLIZATION = 1,
		TILE_INITIALLIZATION = 2
	}

	# switches to choose which print statements are printed
	#region Switchboards
	const SIGNAL_CONNECTION_LOG_SWITCHBOARD: Dictionary = {
		ChannelNames.CLICKED_SIGNAL: 1
	}

	const PRINT_INITIALIZATION_STATUS_SWITCHBOARD: Dictionary = {
		ChannelNames.PIECE_INITIALLIZATION: 0,
		ChannelNames.TILE_INITIALLIZATION: 0
	}

	const PRINT_PRETTY_JSON_SWITCHBOARD: Dictionary = {
		ChannelNames.BOARD_CHANGE: 1
	}
	#endregion


	#region Signal Status
	enum ConnectionStatus {CONNECTED, DISCONNECTED}


	static func print_signal_connection_log(type: int, signal_name:StringName, signal_owner:Object, signal_connectee:Object, _channel:int = -1):
		const BG_COLOR: String = "#002F00"
		if not SIGNAL_CONNECTION_LOG_SWITCHBOARD.get(_channel): return
		var signal_name_colored: String = _color_string(signal_name,"LIGHT_BLUE")
		var format_order: Array[String] = [signal_owner.name,signal_connectee.name,signal_name_colored]
		var string:String = ""
		match type:
			0: string = "[color=LIGHT_GREEN]Connected[/color] {2} [color=LIGHT_GREEN]signal[/color]: {0} to {1}"
			1: string = "[color=SALMON]Disconnected[/color] {2} [color=SALMON]signal[/color]: {0} from {1}"
		print_rich(add_bg_color(string.format(format_order),BG_COLOR))
	#endregion


	#region Object Successfully Initiallized
	static func print_initiallization_status_log(object_name:StringName, _channel:int = -1):
		const BG_COLOR: String = "NAVY_BLUE"
		if not PRINT_INITIALIZATION_STATUS_SWITCHBOARD.get(_channel): return

		var signal_name_colored: String = _color_string(object_name,"LIGHT_BLUE")
		var format_order: Array[String] = [signal_name_colored]
		var string: String = "[color=LIGHT_GREEN]Successfully Initiallized:[/color] {0}".format(format_order)
		string = add_bg_color(string, BG_COLOR)
		print_rich(string)

	#endregion


	static func add_bg_color(string:String, color_name:StringName) -> String:
		return "[bgcolor={0}]{1}[/bgcolor]".format([color_name,string])


	#region Print Pretty JSON
	static var _color_order:Array = [
		"LIGHT_GREEN",
		"DEEP_SKY_BLUE",
		"MEDIUM_PURPLE",
		"SALMON",
		"DARK_ORANGE",
		"GOLDENROD",
		]


	static func print_pretty_json(line_name: String, value: Variant, _channel: int = -1, whitespace:bool = true):
		const BG_COLOR: String = "#300030"
		if not PRINT_PRETTY_JSON_SWITCHBOARD.get(_channel): return

		var string: String = JSON.stringify(value,"\t",false)
		string = color_keys(remove_node_id(string))
		string = "[color={2}]{0}[/color]:{1}".format([line_name,string,_color_order.get(0)])
		string = add_bg_color(string,BG_COLOR)
		if not whitespace:
			string = string.replace("\n","").replace("\t","")
		print_rich(string)


	static func remove_node_id(string:String) -> String:
		var regular_expression: RegEx = RegEx.new()
		regular_expression.compile("(:<[a-zA-Z0-9]*#(-?[0-9]*)>)")
		string = regular_expression.sub(string,"",true)
		return string


	static func color_keys(string:String) -> String:
		var lines: PackedStringArray = string.split("\n",false)
		var finished: PackedStringArray = []
		for line:String in lines:
			var color_index:int = line.count("\t") % _color_order.size()
			var key_string: String = line.get_slice("\"",1)
			if key_string != line:
				line = line.replace(key_string,_color_string(key_string,_color_order[color_index]))
			finished.append(line)
		return "\n".join(finished) + "\n"


	static func _bold_string(string:String) -> String:
		return "[b]{0}[/b]".format([string])


	static func _color_string(string:String, color_name:String) -> String:
		return "[color={0}]{1}[/color]".format([color_name,string])
	#endregion
