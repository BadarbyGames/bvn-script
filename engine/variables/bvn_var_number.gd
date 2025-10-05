@icon("../../icons/number.svg")
@tool
extends BVN_Var

## Float-based variable
class_name BVN_VarNum

@export var value:float

@export_group(&"Configuration")
@export var format:NumFormat = NumFormat.FLOAT

enum NumFormat {
	FLOAT,
	INT,
}

func try_set(v):
	match typeof(v):
		TYPE_FLOAT,TYPE_INT,TYPE_STRING, TYPE_BOOL:
			value = float(v)

func to_value_string() -> String:
	match format: 
		NumFormat.INT: return str(int(value))
		_: return str(snapped(value,0.01))

func get_editor_icon() -> String: return "number.svg"
