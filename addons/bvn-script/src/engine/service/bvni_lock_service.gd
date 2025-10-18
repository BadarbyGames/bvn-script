extends Node

class_name BVNInternal_LockService

var action_locker:Variant
var is_locked:bool:
	get: return action_locker != null

func _enter_tree() -> void:
	BVN_EventBus.on_request_lock_engine.connect(lock_engine)
	BVN_EventBus.on_request_unlock_engine.connect(unlock_engine)
	BVN_EventBus.on_request_load_session.connect(reset_engine_lock)
	
func _exit_tree() -> void:
	BVN_EventBus.on_request_lock_engine.disconnect(lock_engine)
	BVN_EventBus.on_request_unlock_engine.disconnect(unlock_engine)
	BVN_EventBus.on_request_load_session.disconnect(reset_engine_lock)
	
#region ENGINE LOCK LOGIC
func reset_engine_lock(_config:Dictionary): # Callback for when session is reloaded
	action_locker = null

func lock_engine(config:Dictionary) -> bool:
	if action_locker != null: return false
	var lock_source = config.source
	action_locker = lock_source
	return true

func unlock_engine(config:Dictionary):
	if config.source == action_locker:
		action_locker = null
		return true
	return false
#endregion
