@tool
class_name BdbSelect

static func node(n:Node):
	assert(n, "Node is required but not founnd")
	return n
	
#region SIBLINGS
static func next_sibling(node:Node): return next_sibling_by_type(node, null)
static func prev_sibling(node:Node): return prev_sibling_by_type(node, null)

static func next_sibling_by_type(node:Node, type):
	var parent := node.get_parent()
	var count := parent.get_child_count()
	var sibling_index := node.get_index() + 1
	
	if 0 <= sibling_index and sibling_index < count:
		var sibling := parent.get_child(sibling_index)
		
		# If the wrong type, then move to next sibling
		if type and not(is_instance_of(sibling, type)):
			next_sibling_by_type(sibling, type)
		return sibling
	return null

static func prev_sibling_by_type(node:Node, type):
	var parent := node.get_parent()
	var count := parent.get_child_count()
	var sibling_index := node.get_index() - 1
	
	if 0 <= sibling_index and sibling_index < count:
		var sibling := parent.get_child(sibling_index)
		# If the wrong type, then move to next sibling
		if type and not(is_instance_of(sibling, type)):
			prev_sibling_by_type(sibling, type)
	return null
#endregion
	
#region by_type
static func child_by_type(parent:Node, type):
	return item_by_type(parent.get_children(),type)
	
static func child_by_type_recursive(parent:Node, type):
	var children = parent.get_children()
	
	var result = item_by_type(children,type)
	if result: return result
	
	for child in children:
		var tmp = child_by_type_recursive(child, type)
		if tmp: return tmp
		
	return null
	  
static func item_by_type(items:Array, type):
	for i in items: if is_instance_of(i, type): return i
	
static func children_by_type(parent:Node, type, result:Variant = []):
	return items_by_type(parent.get_children(),type, result)
	
static func children_by_type_recursive(parent:Node, type, result:Variant = []):
	var children = parent.get_children()
	items_by_type(children,type, result)
	for child in children:
		children_by_type_recursive(child,type,result)
	return result
 
"""
Override result
"""
static func items_by_type(items:Array, type, result:Variant = []) -> Variant:
	for item in items:
		if is_instance_of(item, type):
			result.append(item)
	return result
#endregion

#region by_name
static func child_by_name(parent:Node, nname:String):
	return item_by_name(parent.get_children(),nname)

static func children_by_name(parent:Node, nname:String):
	return items_by_name(parent.get_children(),nname)
	
static func item_by_name(items:Array, nname:String):
	for i in items: if i.name == nname: return i

static func items_by_name(items:Array, nname:String) -> Array:
	return items.filter(func (i): return i.name == nname)
#endregion
	
#region by_method
static func child_by_method(parent:Node, nname:String):
	return item_by_method(parent.get_children(),nname)

static func children_by_method(parent:Node, nname:String):
	return items_by_method(parent.get_children(),nname)
	
static func item_by_method(items:Array, nname:String):
	for i in items: if i.has_method(nname): return i

static func items_by_method(items:Array, nname:String) -> Array:
	return items.filter(func (i): return i.has_method(nname))
#endregion
