@icon("../icons/folder.svg")
@tool
extends Node

## In BVN, only 1 scene is allowed to be visible at a time. Children under this node is registered
## Are considered scenes and if any one of these nodes are hidden/shown, all the other managed nodes
## are hidden.
class_name BVN_ManagedNodes

func _init() -> void:
	child_entered_tree.connect(connect_child)
	child_exiting_tree.connect(disconnect_child)
	
func connect_child(node:Node):
	if node is BVN_ManagedNodes: return
	
	var fn := BVN_EventBus.on_request_activate_scene.emit
	node.add_to_group(BVNInternal_Tags.NODE_MANAGED)
	
	# Handler for when visiblity is toggled
	if !node.visibility_changed.is_connected(fn):
		var payload := {"node":node}
		var cb := fn.bind(payload)
		
		# Sometimes the node is already visible, so no change is emitted
		# so we "forcefully" call the callback, to hide the other nodes.
		# We also need to call this before the signals are added so we dont
		# double emit.
		node.visible = node.visible
		cb.call() 		
		node.visibility_changed.connect(cb)
			
func disconnect_child(node:Node):
	if node is BVN_ManagedNodes: return
	
	var fn := BVN_EventBus.on_request_activate_scene.emit
	node.remove_from_group(BVNInternal_Tags.NODE_MANAGED)
	
	# Handler for when visiblity is toggled
	if node.visibility_changed.is_connected(fn):
		node.visibility_changed.disconnect(fn)
