# Debug Printer Autoload
# contains all debug print functions and enable/disable switches
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
	"SALMON",
	"LIGHT_GREEN",
	"MEDIUM_PURPLE",
	"DARK_ORANGE",
	"DEEP_SKY_BLUE",
	"GOLDENROD",
	]

func print_pretty(value, _indent:int = 0):
	var string: String = ""
	if value is Array:
		string += _generate_array_string(value,_indent)
	elif value is Dictionary:
		string += _generate_dict_string(value,_indent)
	else:
		var temp_string = str(value).get_slice(":",0)
		string += "[color=" + _color_order[(_indent- 1) % _color_order.size()] + "]" + temp_string + "[/color]"
		if temp_string != str(value):
			var suffix = str(value).split(":",false,1)
			if suffix.get(1) != "":
				string += ":" + suffix.get(1)


	if _indent == 0:
		print_rich(string)
	else:
		return string


func _generate_array_string(value, _indent:int = 0) -> String:
	var string: String = "["
	for item in value:
		string += "\n"+ "".lpad(_indent + 1,INDENT) + print_pretty(item, _indent + 1) + ","
	string += "\n" + "".lpad(_indent,INDENT) + "]"

	return string


func _generate_dict_string(value, _indent:int = 0) -> String:
	var string: String = "{"
	for key in value.keys():
		string += "\n" + "".lpad(_indent + 1,INDENT) + print_pretty(key, _indent + 1)
		string += ": " + print_pretty(value.get(key), _indent + 1) + ","
	string += "\n" + "".lpad(_indent,INDENT) + "}"

	return string
#endregion
