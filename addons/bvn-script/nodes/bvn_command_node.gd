@tool
extends Node

## A node that takes BVN Commands as parameters and are able to execute
## in context of the current state of the engine
class_name BVN_CommandNode

@export_tool_button("Execute") var exec_cmd = execute_command
@export_multiline var commands:String

func execute_command():
	var script_parser:BVN_ScriptParser = BVN_ScriptParser.new()
	var ast_node:= script_parser.parse_bvn_script(commands)

	var engine := BVNInternal_Query.engine
	var vars = BVNInternal_Query.variables.get_format_payload()
	engine.execute_bvn_instruction(ast_node.get_next_node(), vars)
