@tool
extends BVN_Node2D

var engine:Variant:
	set(v):
		assert(engine == null or engine == v, "ERR: multiple editor engines found in the tree.")
		engine = v
		
## Executes the next instruction in the script
func next():
	BVN_EventBus.on_request_next_engine_action.emit()
	
## Sets a variable's value
func set_variable(var_name:String, value:Variant):
	BVN_EventBus.on_request_update_var.emit({
			"var_name": var_name, 
			"value": value
		})
		
## Gets a variabl's value
func get_variable(var_name:String):
	return engine.store.get_var_by_name(var_name)
	
## Disable the "next" script instruction from occuring.
## You must pass it a requester. This acts as the "key" for unlocking. 
## Any subsequent unlock calls will fail if the requesters do not match
##
## @example:
##		bvn.lock( "can_be_anything" )
##		bvn.unlock( self ) 	# this fails because the keys dont match
##		bvn.unlock( "key" ) # this fails because the keys dont match
##		bvn.unlock( "can_be_anything" ) # now unlocks
func lock(requester:Variant): 
	BVN_EventBus.on_request_lock_engine.emit({ "source": requester})

## This works in tandem with lock. See lock for more details.
func unlock(requester:Variant): 
	BVN_EventBus.on_request_lock_engine.emit({ "source": requester})
	
## Saves the current session
func save():
	BVN_EventBus.on_request_save_session.emit({})
