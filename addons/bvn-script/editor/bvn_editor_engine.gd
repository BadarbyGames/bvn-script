extends Object

var plugin:EditorPlugin
func _init(_plugin:EditorPlugin) -> void:
	plugin = _plugin

func start():
	var editor := EditorInterface
	
	var inspector = editor.get_inspector()
	inspector.edited_object_changed.connect(on_select_new_bvn_page)
	
	plugin.scene_changed.connect(on_scene_change)

func end():
	var inspector := plugin.get_editor_interface().get_inspector()
	inspector.edited_object_changed.disconnect(on_select_new_bvn_page)

func on_select_new_bvn_page():
	var inspector := plugin.get_editor_interface().get_inspector()
	var edited := inspector.get_edited_object()
	
	# In cases where youre selecting random editor objects
	if not(edited is Node): return 
	
	var bvn_page := BVN_EngineSelectors.find_bvn_page_ancestor(edited)
	
	if bvn_page:
		BVN_EventBus.on_editor_scene_inspect.emit(bvn_page)
	else:
		BVN_EventBus.on_editor_scene_inspect.emit(null)

func on_scene_change(scene_root: Node):
	BVN_EventBus.on_editor_scene_change.emit(scene_root)
	
	# @TODO scan for BVN_Page's to hide
