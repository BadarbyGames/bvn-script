@icon("../../icons/alphabet.svg")
@tool
extends BVN_Var

## String-based variable
class_name BVN_VarString

@export var value:String

func try_set(v):
	value = str(v)

func to_value_string() -> String:
	return value

func get_editor_icon() -> String: return "alphabet.svg"
