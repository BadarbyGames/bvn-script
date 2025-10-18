@icon("../../icons/database.svg")
@tool
extends BVN_Node2D

class_name BVN_Variables

func _init() -> void:
	var on_save_cb := func (save_file:Dictionary):
			save_file.vars = _on_engine_demand_save()
	var on_load_cb := func (save_file:Dictionary):
			for var_name in save_file.vars:
				set_var_by_name({
					"var_name": var_name, 
					"value": save_file.vars[var_name]
				})
			
	tree_entered.connect(func ():
		add_to_group(BVNInternal_Tags.ENGINE_VARS)
		BVN_EventBus.on_request_update_var.connect(set_var_by_name)
		BVN_EventBus.on_engine_demand_save.connect(on_save_cb)
		BVN_EventBus.on_engine_demand_load.connect(on_load_cb)
		)
	tree_exited.connect(func ():
		remove_from_group(BVNInternal_Tags.ENGINE_VARS)
		BVN_EventBus.on_request_update_var.disconnect(set_var_by_name)
		BVN_EventBus.on_engine_demand_save.disconnect(on_save_cb)
		BVN_EventBus.on_engine_demand_load.disconnect(on_load_cb)
		)
		
## Called in response to a "save" event. Return the dictionary to save into
## the save file. You can overwrite this to modify how the variables are saved.
func _on_engine_demand_save() -> Dictionary:
	var payload := {}
	for var_node:BVN_Var in BdbSelect.children_by_type(self, BVN_Var):
		payload[var_node.name] = var_node.to_value_string()
	return payload
	
func _get_configuration_warnings() -> PackedStringArray:
	var results = BdbSelect.child_by_type(self, BVN_Var)
	if !results:
		return ["Must have atleast 1 BVN_Var node"]
	return []

func get_format_payload():
	var payload := {}
	for var_node:BVN_Var in BdbSelect.children_by_type(self, BVN_Var):
		payload[var_node.name] = var_node.to_value_string()
	return payload
	
	
#region API
func set_var_by_name(config:Dictionary):
	var bvn_var := get_node(NodePath(config.var_name)) as BVN_Var
	if bvn_var:
		bvn_var.try_set(config.value)

func get_var_by_name(var_name:String) -> Variant:
	var bvn_var := get_node(NodePath(var_name)) as BVN_Var
	return bvn_var.value
		
func add_variable(script:Script, var_name:String, value:Variant = null) -> BVN_Var:
	var var_node:BVN_Var = script.new()
	var_node.name = var_name
	var_node.try_set(value)
	add_child(var_node)
	var_node.owner = owner
	return var_node
#endregion
