extends Node

class_name BVNInternal_EngineCommandRunner

var rx_assignment := {
	"rx" : RegEx.create_from_string(r"""^(?:[\s\t]*\>)?[\s\t]*(?<!")(?<ns>[a-zA-Z0-9_]+)\s\=\s*(?<v>.*)"""),
	"replacement": '> vars.update("$ns",$v)'
}

var rx_api_call := {
	"rx" : RegEx.create_from_string(r"""\b(?<!")([a-zA-Z0-9_]+)\.([\.a-zA-Z0-9_]+[(])"""),
	"replacement": 'api.$1.$2'
}

var rx_regular_node := {
	"rx" : RegEx.create_from_string(r"""(\$|(?<s>\%))(?:("|')(?<c>[^"'.]+)("|')|(?<d>[^.\s]+))"""),
	"replacement": "node.get_node_from_context('$s$c$d')"
}

## Removes GT sign (at the beginning)
var rx_rm_gt := {
	"rx" : RegEx.create_from_string(r"""^[\s\t]*\>[\s\t]*"""),
	"replacement": "",
}

var base_instance:CmdContext
var visual_novel:BVN_VisualNovel
var expression_var_names :
	get: return api_directory.keys()

var api_directory:Dictionary[String, Node] = {
		"engine":  BVNInternal_CmdEngineApi.new(),
		"audio":  BVNInternal_CmdAudioApi.new(),
		"vars": BVNInternal_CmdVarsApi.new(),
		"node": BVNInternal_CmdNodeApi.new(),
		"session": BVNInternal_CmdSessionApi.new(),
	}

func _enter_tree() -> void:
	base_instance = CmdContext.new()
	for key in api_directory:
		var api_node := api_directory[key]
		add_child(api_node)

	base_instance.api = api_directory

## Runs execute on the text of the node
func execute_node(ast_node:Bvn_AstNode, vars:Dictionary, node_context:Node) -> Array:
	return execute(ast_node.text.strip_edges(), vars, node_context)
		
	
## Takes an if/elif/else node and parses the logic in the parameters
## Note: This does not check if any of the prior siblings have returned true
## that is the job of the consumer
func execute_ifelse_node(ifelse_node:Bvn_AstNode, vars:Dictionary, node_context:Node) -> bool:
	# Else nodes have no conditions so they should always execute
	# Any if, else logic before the else node should be handled by te caller
	if ifelse_node.type == Bvn_AstNode.TYPE_ELSE: return true
	
	# Find the first true node
	var text = ifelse_node.text.strip_edges()
	var start_index = -1
	var end_index = text.find(&":")
	match ifelse_node.type:
		Bvn_AstNode.TYPE_IF: start_index = 2
		Bvn_AstNode.TYPE_ELSE_IF: start_index = 4
		
	assert(start_index >= 0, "This is not a valid if,if-else,else statement - unknown type")
	assert(end_index >= 0, "This is not a valid if,if-else,else statement - missing ':'")
	var command = text.substr(start_index,end_index-2)
	var result = execute(command, vars, node_context)
	return result[0] == OK and result[1]

var expansion_sets := [rx_assignment,rx_regular_node, rx_api_call, rx_rm_gt]
func expand_command(command:String,vars:Dictionary = {}) -> String:
	command.format(vars, &"{{_}}").strip_edges()
	
	#region NODE_EXPANSION
	for i in expansion_sets.size():
		var expansion_set = expansion_sets[i]
		var rx:RegEx = expansion_set.rx
		var replacement:String = expansion_set.replacement
		var new_command := rx.sub(command, replacement, true)
		command = new_command
	#endregion
	command = command.strip_edges()
	return command
	
const EMPTY_ARRAY := []
func execute(tmp:String, vars:Dictionary, node_context: Node) -> Array:
	var expression = Expression.new()
	var command := expand_command(tmp, vars)
	if !command:
		return []
		
	
	base_instance.api.vars.vars = vars
	base_instance.api.node.node_context = node_context
	
	var err = expression.parse(command, EMPTY_ARRAY)
	
	match err:
		ERR_INVALID_PARAMETER:
			printerr(&"Command is malformed - please recheck")
		OK:
			var result = expression.execute(EMPTY_ARRAY,base_instance)
			return [OK,result]
		_:
			printerr("Command error: " + error_string(err))
	return [err,null]
	
class CmdContext:
	extends RefCounted
	
	var api:Dictionary # populated elsewhere
	
	func ask(question_label:String = "", default_value:Variant = null):
		assert(question_label, "Please provide a question_label as param1")
		
		var instruction :Dictionary = {}
		instruction[BVNInternal_CmdVarsApi.SECRET_INSTRUCTION_HASH] = true
		instruction.question_label = question_label
		instruction.default_value = default_value
		return instruction

	
