@icon("../../../icons/unknown.svg")
@tool
extends BVN_Node

## Base node for variable types - extend this for custom data-types
class_name BVN_Var

var variable_name:String
func _init() -> void:
	if Engine.is_editor_hint():
		# inform the editor
		tree_entered.connect(func ():
			variable_name = name
			BVN_EventBus.on_editor_variable_add.emit(self))
		tree_exited.connect(func ():
			BVN_EventBus.on_editor_variable_rm.emit(self))
		renamed.connect(func ():
			BVN_EventBus.on_editor_variable_rename.emit(self, variable_name,name)
			variable_name = name
			)

## This function is called when a variable is set from the BVN Script.
## Since type is not gauranteed, the caller must be the one to handle that.
func try_set(value:Variant): 
	BdbError.not_implemented("BVN_Var try_set was not overwritten")

func _get_configuration_warnings() -> PackedStringArray:
	if get(&"value") == null:
		return ["This node should only be extended. Ensure there is an @export var value:YOUR_TYPE."]
	return []

func to_value_string() -> String:
	var val = get(&"value")
	return str(val) if val else &""

func get_editor_icon() -> String: return "unknown.svg"
