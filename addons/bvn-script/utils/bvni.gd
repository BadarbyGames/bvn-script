## Bunch of utility shit
class_name BVNInternal

## Returns res://adons/bvn-script or wherever the
## Plugin is saved at
static func get_plugin_path() -> String:
	# Script is in <plugin_path>/utility
	# First base dir removes the <script>.gd
	# Second base dir goes up a folder
	return (BVNInternal as Script).resource_path.get_base_dir().get_base_dir()

## Combination of checking and creating child
static func ensure_child(parent:Node, child_type, add_child_mode:Node.InternalMode = BVN_Settings.debug_add_child_mode ) -> Node:
	var child :Node = BdbSelect.child_by_type(parent, child_type)
	if child == null:
		child = child_type.new()
		add_child(parent, child, add_child_mode)
	return child


## Smart add child that works both in editor and runtime
static func add_child(parent:Node, child:Node, add_child_mode:Node.InternalMode = BVN_Settings.debug_add_child_mode ) -> Node:
	var new_owner = parent.get_tree().edited_scene_root \
		if Engine.is_editor_hint() \
		else parent.owner
	parent.add_child(child, true, add_child_mode)
	child.owner = new_owner
	return child

static func find_resource(path:String, hint = null) -> Array:
	var resource_paths:Array[String] = [BVN_Settings.setup_audio_folder]
	
	for base_path in resource_paths:
		var resource_path := str(base_path,"/", path)
		if ResourceLoader.exists(resource_path):
			# @TODO warning - overuse of this might result in increase me usage because of the caching
			# should we do something about this?
			return [OK,load(resource_path)]
	return [ERR_FILE_NOT_FOUND,null]
