extends Node

class_name BVNInternal_CmdVarsApi

const SECRET_INSTRUCTION_HASH = &"_12xl33t_1l1k3_80085" # Key to determine that the dict was not added by the player

var vars:Dictionary
var _transaction_id:String
var _transaction_promise:BdbPromise

func _enter_tree() -> void:
	BVN_EventBus.on_request_update_var.connect(_on_listen_to_transactions)
	
func _exit_tree() -> void:
	BVN_EventBus.on_request_update_var.disconnect(_on_listen_to_transactions)

## M
func _on_listen_to_transactions(config:Dictionary):
	if !_transaction_id or _transaction_id != config.transaction_id: return
	
	_transaction_promise.resolve()

func update(vname:StringName, value:Variant):
	assert(vars.has(vname), "Unknown variable '%s' " % vname)
	
	if value is Dictionary and value.get(SECRET_INSTRUCTION_HASH, false): # Then wait for completion
		return update_via_modal(vname, value)
	else:
		BVN_EventBus.on_request_update_var.emit({
			"var_name": vname, 
			"value": value
		})
	return true # Handled
	
func update_via_modal(var_name:String, instruction: Dictionary):
	var lock_id =  str(Time.get_ticks_usec())
	
	var payload := {
		"label": instruction.question_label,
		"var_name": var_name,
		"transaction_id": _transaction_id,
		"lock_source": lock_id
	}
	
	if instruction.default_value is Array:
		var options:Array[String]
		options.assign(instruction.default_value) 
		payload.options = options
		payload.type = BVN_ChoiceModal
	elif instruction.default_value == null:
		payload.type = BVN_TextInputModal
		
	BVN_EventBus.on_request_lock_engine.emit({ "source": lock_id })
	BVN_EventBus.on_request_ask_question.emit(payload)		
	return true # Handled
