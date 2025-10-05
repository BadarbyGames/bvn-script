@icon("../../../../icons/gear.svg")
extends BVN_VM

## Add to a button to have it update a variable on click
class_name BVN_ChoiceButtonVM

## The node name of the variable in the GameStore
@export var variable_name:String
@export var view:BaseButton
@export var value:String

## Used for tying transaction operations together
var transaction_id:String

func _enter_tree():
	var errors = _get_configuration_warnings()
	assert(errors.size() == 0, ",".join(errors))
	view.pressed.connect(notify_store)
	
func _exit_tree():
	view.pressed.disconnect(notify_store)
	
func _get_configuration_warnings() -> PackedStringArray:
	if view == null:
		return [ "BVN_ChoiceButtonVM must have a BaseButton as view" ]
	return []
	
func notify_store():
	BVN_EventBus.on_request_update_var.emit({
		&"var_name":variable_name,
		&"value":value,
		&"transaction_id": transaction_id
	})
