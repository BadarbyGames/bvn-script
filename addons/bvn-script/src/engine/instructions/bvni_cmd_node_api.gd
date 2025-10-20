extends Node

## > nodes.XXXX
class_name BVNInternal_CmdNodeApi

var node_context:Node
func get_node_from_context(str:String):
	return node_context.get_node(str)
	
func hide_scenes():
	var engine:BVN_Engine = get_tree().get_first_node_in_group(BVNInternal_Tags.ENGINE)
	engine.managed_node_service.push_page(null)
	

func solo(node: Node, cb_func:String = &""):
	var engine:BVN_Engine = get_tree().get_first_node_in_group(BVNInternal_Tags.ENGINE)
	
	var lock_success := engine.lock_service.lock_engine({"source":node})
	
	if !lock_success:
		printerr("Unable to get lock. Already locked")
		return
	
	engine.managed_node_service.push_page(node)
	if cb_func:
		assert(node.has_method(cb_func), "'%s' does not have a function named '%s'" % [node.name, cb_func])
		Callable(node,cb_func).call()
		
	var fn := watch_none_scene_node.bind(node)
	node.visibility_changed.connect(fn,CONNECT_ONE_SHOT)
	node.tree_exited.connect(fn,CONNECT_ONE_SHOT)
		
func watch_none_scene_node(node:Node):
	if node.visibility_changed.is_connected(watch_none_scene_node):
		node.visibility_changed.disconnect(watch_none_scene_node)
	if node.tree_exited.is_connected(watch_none_scene_node):
		node.tree_exited.disconnect(watch_none_scene_node)
		
	var engine:BVN_Engine = get_tree().get_first_node_in_group(BVNInternal_Tags.ENGINE)
	engine.managed_node_service.pop_page()
	engine.lock_service.unlock_engine({"source":node})
	engine.next()
	
