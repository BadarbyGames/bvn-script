extends RefCounted

class_name Bvn_AstNode

enum AST_NODE_TYPE {
	UNSPECIFIED = 0,
	NOOP = 1, # Either comment or new line
	SPEAK = 2,
	COMMAND = 3,
	IF = 4,
	ELSE_IF = 5,
	ELSE = 6,
}

const TYPE_UNSPECIFIED = AST_NODE_TYPE.UNSPECIFIED
const TYPE_NOOP = AST_NODE_TYPE.NOOP
const TYPE_SPEAK = AST_NODE_TYPE.SPEAK
const TYPE_COMMAND = AST_NODE_TYPE.COMMAND
const TYPE_IF = AST_NODE_TYPE.IF
const TYPE_ELSE_IF = AST_NODE_TYPE.ELSE_IF
const TYPE_ELSE = AST_NODE_TYPE.ELSE

var parent:Bvn_AstNode
var children:Array[Bvn_AstNode]
var depth:int = -1
var line_index:int = -1
var text:String
var type:AST_NODE_TYPE = AST_NODE_TYPE.UNSPECIFIED

var is_root:bool:
	get: return parent == self

func _init(p:Bvn_AstNode = null) -> void:
	if p:
		parent = p
		parent.add_child(self)
	else:
		parent = self
	
func add_child(child:Bvn_AstNode) -> Bvn_AstNode:
	children.append(child)
	child.parent = self
	return child
	
func get_prev_sibling() -> Bvn_AstNode:
	var index := parent.children.find(self) - 1
	if index >= 0:
		return parent.children[index]
	return null
	
func get_next_sibling() -> Bvn_AstNode:
	var index := parent.children.find(self) + 1
	if index < parent.children.size():
		return parent.children[index]
	return null
	
func get_prev_node() -> Bvn_AstNode:
	var sibling := get_prev_sibling()
	if sibling: return sibling
	
	if not(is_root): return parent
	
	return null
	
func get_next_node(include_children:bool = true) -> Bvn_AstNode:
	if include_children and children: return children[0]
	
	if is_root: return null
	var sibling := get_next_sibling()
	if sibling: return sibling
	return parent.get_next_node(false)
	
func get_text_all(separator :String = &"", starting_text:String = text) -> String:
	var txt_accum := starting_text
	for child in children:
		txt_accum += separator + child.text
	return txt_accum
	
func get_line_index_all() -> Array[int]:
	var accum :Array[int]= [line_index]
	for child in children:
		accum.append_array(child.get_line_index_all())
	return accum
	
func find_node_by_line_index(target_ln_index:int) -> Bvn_AstNode:
	if line_index == target_ln_index:
		return self
	for child in children:
		var tmp := child.find_node_by_line_index(target_ln_index)
		if tmp: return tmp
	return null
		
func print_tree():
	if parent != self: # If root, don't print
		var tabs := "\t".repeat(depth)
		if tabs:
			tabs += ' ↳ '
		print("@[%s,%s]: " % [parent.depth,depth] + tabs + text)
	for child in children:
		child.print_tree()
