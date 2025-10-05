@icon("../../../../icons/gear.svg")
@tool
extends BVN_VM

## This ViewModel takes in a text input type control and 
class_name BVN_InputVM

@export var variable_name:String
@export var transaction_id:String
@export var target_node:Node

var debounce := BdbDebounce.new(0.1)
var value:String:
	get: return target_node.get("text")
	set(v): target_node.set("text",v)

func _init() -> void:
	tree_entered.connect(func ():
		if target_node == null:
			target_node = try_assign_parent([LineEdit,TextEdit], "LineEdit or TextEdit")
		
		const ADD_CHILD_MODE:InternalMode = InternalMode.INTERNAL_MODE_DISABLED
		add_child(debounce,false, ADD_CHILD_MODE)
		target_node.text_changed.connect(debounce.cb(notify_store).handle)
		if target_node is LineEdit:
			target_node.text_submitted.connect(debounce.cb_handle)
		)
	tree_exited.connect(func ():
		target_node.text_changed.disconnect(debounce.cb_handle)
		if target_node is LineEdit:
			target_node.text_submitted.disconnect(debounce.cb_handle)
		BdbIdioms.free_children(self)
		)

func notify_store(str:String = value):
	str = str.strip_edges()
	BVN_EventBus.on_request_update_var.emit({
		"var_name":variable_name,
		"value":str,
		"transaction_id": transaction_id
	})
