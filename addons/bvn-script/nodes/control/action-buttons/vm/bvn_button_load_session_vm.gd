@icon("../../../../icons/gear.svg")
@tool
extends BVN_VM

class_name BVN_ButtonLoadSessionVM

@export var target_node:BaseButton
@export var save_game_name:String:
	set(v):
		save_game_name = v
		check_save_file()

func _init() -> void:
	tree_entered.connect(func ():
		if target_node == null: 
			target_node = try_assign_parent(BaseButton,"BaseButton") 
			check_save_file()
			
			BdbSig.sig_conn(
				BVN_EventBus.on_request_save_session,
				check_save_file
			)
		target_node.pressed.connect(request_save)
		)
		
	tree_exited.connect(func ():
		target_node.pressed.disconnect(request_save)
		BdbSig.sig_disconn(
			BVN_EventBus.on_request_save_session, 
			check_save_file
			)
		)
		
func check_save_file():
	var tmp := BVNInternal_Query.engine_session
	target_node.disabled = not(tmp and tmp.has_save_game(save_game_name))
		
func request_save():
	BVN_EventBus.on_request_load_session.emit({})
