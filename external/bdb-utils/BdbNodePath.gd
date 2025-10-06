class_name BdbNodePath

static func get_property(node:Node, prop_name:String) ->NodePath:
	return append_path(node.get_path(), ":"+prop_name)

## append_path("/foo/bar","/baz") -> /foo/bar/baz
## append_path("/foo/bar",":baz") -> /foo/bar:baz
## append_path("/foo:bar",":baz") -> /foo:bar:baz
static func append_path(path:NodePath, appendee:String) -> NodePath:
	var path_string := path.get_concatenated_names()
	if path.get_subname_count():
		path_string += ":"+path.get_concatenated_subnames()
	path_string += appendee
	return NodePath(path_string)

static func join(a, b, c = BDB_UNDEF, d = BDB_UNDEF) -> NodePath:
	var to_join: = [a,b]
	if BDB_UNDEF.is_defined(c): to_join.append(c)
	if BDB_UNDEF.is_defined(d): to_join.append(d)
	return NodePath("".join(to_join))

static func get_value(node:Node, node_path:NodePath):
	if node_path.get_name_count():
		var subnode = node.get_node_or_null(node_path)
		var tmp := NodePath(&":"+node_path.get_concatenated_subnames())
		return subnode.get_indexed(tmp)
	else:
		return node.get_indexed(node_path)
		
static func set_value(node:Node, node_path:NodePath, value:Variant):
	if node_path.get_name_count():
		var subnode = node.get_node_or_null(node_path)
		var tmp := NodePath(&":"+node_path.get_concatenated_subnames())
		subnode.set_indexed(tmp, value)
	else:
		node.set_indexed(node_path, value)
		
static func call_method(node_path:NodePath, args:Array):
	var node:Node = Engine.get_main_loop().root.get_node_or_null(node_path)
	if !node: return ERR_CANT_RESOLVE
	node.callv(node_path.get_concatenated_subnames(),args)
	return OK
