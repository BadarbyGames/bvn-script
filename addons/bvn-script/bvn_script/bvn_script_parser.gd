extends RefCounted

class_name BVN_ScriptParser

const PERSON_DELIMETER = &":"

const NEWLINE = &"\n"
const END_OF_EXPRESSION = ""
const TAB = &"\t"
const SPACE = &" "

enum PARSE_MODE {
	EXPRESSION,
	INDENT_FIND
}

func parse_bvn_script(script:String) -> Bvn_AstNode:
	script = script.strip_edges()
	
	var root_node:Bvn_AstNode = Bvn_AstNode.new()
	var curr_node:Bvn_AstNode = root_node
	var prev_node:Bvn_AstNode = root_node
	
	var max_len = script.length()
	
	
	var parse_mode := PARSE_MODE.INDENT_FIND
	var curr_expression = ""
	var curr_depth:int = 0
	var SAFE_LOOP_MAX := int(pow(2,14))
	var line_index := -1
	var i := 0
	
	while i < SAFE_LOOP_MAX:
		var char := script[i] if (i < max_len) else NEWLINE
		
		if parse_mode == PARSE_MODE.INDENT_FIND:
			if char == TAB:
				curr_depth += 1
			else:
				parse_mode = PARSE_MODE.EXPRESSION
				
				# Check if it went below
				if curr_depth > curr_node.depth:
					var new_node := Bvn_AstNode.new(curr_node)
					new_node.depth = curr_depth
					
					prev_node = curr_node
					curr_node = new_node
				# Check if they indented backward
				elif curr_depth <= curr_node.depth:
					# Locate the parent that is at this depth, so we can make a sibling for it
					var tmp = curr_node
					while tmp.depth > curr_depth:
						tmp = tmp.parent
						
					# Create a sibling of 
					var new_node := Bvn_AstNode.new(tmp.parent)
					new_node.depth = curr_depth
					
					prev_node = curr_node
					curr_node = new_node
				# else do nothing (same level)

				
		if parse_mode == PARSE_MODE.EXPRESSION:
			match char:
				NEWLINE:
					line_index += 1
					curr_node.text = curr_expression
					curr_node.type = get_type(curr_expression)
					curr_node.line_index = line_index
					
					# RESET - its a new line
					parse_mode = PARSE_MODE.INDENT_FIND
					curr_depth = 0
					curr_expression = ""
				_:
					curr_expression += char
		
		i += 1
		if i > max_len:
			break
			
	if i >= SAFE_LOOP_MAX:
		BdbError.max_iterations()
		
	return root_node
	
const IF_KEYWORD = &"if"
const ELSE_KEYWORD = &"else"
const ELSE_IF_KEYWORD = &"elif"
func get_type(line:String) -> Bvn_AstNode.AST_NODE_TYPE:
	var tmp := line.strip_edges()
	if tmp and tmp[0] == &"#": return Bvn_AstNode.TYPE_NOOP
	if tmp and tmp[0] == &">": return Bvn_AstNode.TYPE_COMMAND
	if tmp.find(PERSON_DELIMETER) >= 0:
		if tmp.begins_with(IF_KEYWORD): return Bvn_AstNode.TYPE_IF
		if tmp.begins_with(ELSE_IF_KEYWORD): return Bvn_AstNode.TYPE_ELSE_IF
		if tmp.begins_with(ELSE_KEYWORD): return Bvn_AstNode.TYPE_ELSE
			
		return Bvn_AstNode.TYPE_SPEAK

	return Bvn_AstNode.TYPE_UNSPECIFIED 
