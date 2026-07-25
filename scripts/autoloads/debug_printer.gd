# Debug Printer Autoload
# contains all debug print functions and enable/disable switches
@tool
extends Node

const INDENT: String = "  "

const debug_print_switch: Dictionary = {
	"state_enter": false,
	"state_exit": false,
	"class_log": true,
}


func print_state_enter(state_name:String):
	if debug_print_switch.state_enter:
		print_rich("[b][color=web_green]Entered[/color]: [/b]",state_name)


func print_state_exit(state_name:String):
	if debug_print_switch.state_exit:
		print_rich("[b][color=brown]Exited[/color]: [/b]",state_name)


func print_class_log(classname:String, text:String, classname_color:String = "deep_sky_blue"):
	if debug_print_switch.class_log:
		var string: String = "[b][color="+classname_color+"]" + classname + "[/color]: [/b]" + text
		print_rich(string)


#region Print Pretty
var _color_order:Array = [
	"LIGHT_GREEN",
	"DEEP_SKY_BLUE",
	"MEDIUM_PURPLE",
	"SALMON",
	"DARK_ORANGE",
	"GOLDENROD",
	]


func print_pretty(value, detailed:bool = true, _indent:int = 0):
	var string: String = ""
	if value is Array:
		string += _generate_array_string(value, detailed, _indent)
	elif value is Dictionary:
		string += _generate_dict_string(value, detailed, _indent)
	else:
		var temp_string = str(value).get_slice(":",0)
		string += "[color=" + _color_order[clamp(_indent- 1,0,5) % _color_order.size()] + "]" + temp_string + "[/color]"
		if temp_string != str(value):
			var suffix = str(value).split(":",false,1)
			if suffix.get(1) != "" and detailed:
				string += ":" + suffix.get(1)

	if _indent == 0:
		print_rich(string)
	else:
		return string


func _generate_array_string(value:Array, detailed:bool = true, _indent:int = 0) -> String:
	# how many items an array can contain before it is no longer compacted
	const MAX_COMPACTING_SIZE: int = 10
	var array_dict_type_filter: Callable = func(item): return not typeof(item) in [TYPE_ARRAY,TYPE_DICTIONARY]
	var has_valid_types:bool = value.all(array_dict_type_filter)
	var string: String = "["
	if value.is_empty():
		return string + "]"
	if not detailed and has_valid_types and value.size() <= MAX_COMPACTING_SIZE:
		for item in value:
			string += print_pretty(item, detailed, _indent + 1) + (", " if item != value.back() else "")
		string += "]"
	elif detailed or not has_valid_types or value.size() > MAX_COMPACTING_SIZE:
		for item in value:
			string += "\n"+ "".lpad(_indent + 1,INDENT) + print_pretty(item, detailed, _indent + 1) + ","
		string += "\n" + "".lpad(_indent,INDENT) + "]"
	return string


func _generate_dict_string(value:Dictionary, detailed:bool = true, _indent:int = 0) -> String:
	const MAX_COMPACTING_SIZE: int = 10
	var string: String = "{"
	var array_dict_type_filter: Callable = func(item): return not typeof(item) in [TYPE_ARRAY,TYPE_DICTIONARY]
	var has_valid_types:bool = value.values().all(array_dict_type_filter)
	if value.is_empty():
		return string + "}"

	if not detailed and has_valid_types and value.size() <= MAX_COMPACTING_SIZE:
		for key in value.keys():
			string += print_pretty(key, detailed, _indent + 1)
			string += ": " + print_pretty(value.get(key), detailed, _indent + 1)
			string += ", " if key != value.keys().back() else ""
		string += "}"
	elif detailed or not has_valid_types or value.size() > MAX_COMPACTING_SIZE:
		for key in value.keys():
			string += "\n" + "".lpad(_indent + 1,INDENT) + print_pretty(key, detailed, _indent + 1)
			string += ": " + print_pretty(value.get(key), detailed, _indent + 1) + ","
		string += "\n" + "".lpad(_indent,INDENT) + "}"

	return string
#endregion
