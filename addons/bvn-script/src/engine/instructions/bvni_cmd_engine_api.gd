extends Node

class_name BVNInternal_CmdEngineApi

func lock(key:Variant) -> bool:
	var engine:BVN_Engine = get_tree().get_first_node_in_group(BVNInternal_Tags.ENGINE)
	var lock_success := engine.lock_service.lock_engine({"source":key})
	
	if lock_success:
		if BVNInternal.is_editor_mode:
			var source_str:String = str(key)
			BVNInternal_Notif.toast_lock(source_str, {"source":key})
	else:
		printerr("Unable to get lock. Already locked")
	
	return lock_success
