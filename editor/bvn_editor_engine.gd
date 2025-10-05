extends Object

var plugin:EditorPlugin
func _init(_plugin:EditorPlugin) -> void:
	plugin = _plugin

func start():
	var editor := EditorInterface
	
	var inspector = editor.get_inspector()
	inspector.edited_object_changed.connect(on_select_new_bvn_scene)
	
	plugin.scene_changed.connect(on_scene_change)

func end():
	var inspector := plugin.get_editor_interface().get_inspector()
	inspector.edited_object_changed.disconnect(on_select_new_bvn_scene)

func on_select_new_bvn_scene():
	var inspector := plugin.get_editor_interface().get_inspector()
	var edited := inspector.get_edited_object()
	
	# In cases where youre selecting random editor objects
	if not(edited is Node): return 
	
	var bvn_scene := BVN_EngineSelectors.find_bvn_scene_ancestor(edited)
	
	if bvn_scene:
		BVN_EventBus.on_editor_scene_inspect.emit(bvn_scene)
	else:
		BVN_EventBus.on_editor_scene_inspect.emit(null)

func on_scene_change(scene_root: Node):
	BVN_EventBus.on_editor_scene_change.emit(scene_root)
	
	# @TODO scan for BVN_Scene's to hide
