# Debug Printer Autoload
# contains all debug print functions and enable/disable switches
extends Node

const debug_print_switch: Dictionary = {
	"state_enter": true,
	"state_exit": true,
}


func print_state_enter(state_name:String):
	if debug_print_switch.state_enter:
		print_rich("[b][color=web_green]Entered[/color]: [/b]",state_name)


func print_state_exit(state_name:String):
	if debug_print_switch.state_exit:
		print_rich("[b][color=brown]Exited[/color]: [/b]",state_name)
