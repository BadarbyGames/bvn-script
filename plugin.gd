@tool
extends EditorPlugin

var editor_tab:BVN_EditorTab

var editor_engine
var controllers:Array

func _enter_tree():

	# Construct the relative path to the scene file
	var plugin_dir = get_script().resource_path.get_base_dir()
	
	#region Add AUTOLOADED
	var bvn_path = plugin_dir + "/bvn.gd"
	add_autoload_singleton("BVN", bvn_path)
	
	var event_bus_path = plugin_dir + "/events/BVN_EventBus.gd"
	add_autoload_singleton("BVN_EventBus", event_bus_path)
	#endregion
	
	for path in [
		"/editor/bvn_editor_engine.gd",
		"/editor/bvn_project_vars.gd"
	]:
		var script_path = load(plugin_dir + path)
		var controller = script_path.new(self)
		controller.start()
		controllers.append(controller)
	
	#region Add Editor
	var editor_path = plugin_dir + "/editor_tab/bvn_editor_tab.tscn"
	var prefab:PackedScene = load(editor_path)
	editor_tab = prefab.instantiate()
	editor_tab.ready.connect(editor_tab.setup, CONNECT_ONE_SHOT)
	add_control_to_bottom_panel(editor_tab, "BVN Editor")
	#endregion

	

func _exit_tree():
	#region free Editor
	remove_control_from_bottom_panel(editor_tab)
	editor_tab.free()
	#endregion
	
	#region free AUTOLOADED
	remove_autoload_singleton("BVN")
	remove_autoload_singleton("BVN_EventBus")
	#endregion
	
	for controller in controllers:
		controller.end()
		controller.free()
