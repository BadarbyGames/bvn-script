@icon("../../icons/gear.svg")
extends BVN_Node

class_name BVN_VM


func try_assign_parent(type_or_types:Variant, type_name:String):
	var types:Array
	if type_or_types is Array: types.assign(type_or_types)
	else: types = [type_or_types]
	
	var parent := get_parent()
	var print_arrgs := [get_script().get_global_name(),type_name]
	for type in types:
		if is_instance_of(parent, type):
			return parent
	printerr("'%s' needs a target_node of type '%s'."% print_arrgs)
	printerr("	↳ This defaults to parent but can be manually overriden.")
	return null

func retarget(new_parent:Node):
	name = "INTERNAL " + get_script().get_global_name()
	if get_parent() != new_parent:
		BVNInternal.add_child(new_parent, self)
	return self
