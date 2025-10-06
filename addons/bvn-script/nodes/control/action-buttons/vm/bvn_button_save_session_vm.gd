@icon("../../../../icons/gear.svg")
@tool
extends BVN_VM

class_name BVN_ButtonSaveSessionVM

@export var target_node:BaseButton

func _init() -> void:
	tree_entered.connect(func ():
		if target_node == null: 
			target_node = try_assign_parent(BaseButton,"BaseButton") 
		target_node.pressed.connect(request_save)
		)
		
	tree_exited.connect(func ():
		target_node.pressed.disconnect(request_save)
		)
		
func request_save():
	BVN_EventBus.on_request_save_session.emit({})
