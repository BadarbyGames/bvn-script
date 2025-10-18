@icon("../../../icons/boolean.svg")
@tool
extends BVN_Var

## Boolean-based variable
class_name BVN_VarBool

@export var value:bool
@export_group(&"Configuration")
@export var true_text:String = &"true"
@export var false_text:String = &"false"

func try_set(v):
	value = true if v else false # Collapse to a boolean

func to_value_string() -> String:
	return true_text if value else false_text

func get_editor_icon() -> String: return "boolean.svg"
