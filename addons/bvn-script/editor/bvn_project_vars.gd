extends Object

var plugin:EditorPlugin
func _init(_plugin:EditorPlugin) -> void:
	plugin = _plugin

func start():
	ProjectSettings.settings_changed.connect(watch_properties)

func end():
	ProjectSettings.settings_changed.disconnect(watch_properties)

func watch_properties():
	var setting_name:String
	var has_changes := false
	
	const data_folder := "res://data"
	const assets_folder := "res://assets"

	has_changes = has_changes or try_add_property("dialogue/text_speed", 55, {
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_NONE,
		"hint_string": "Speed at they awhich each character appears in msec"
	})
	
	has_changes = has_changes or try_add_property("debug/add_child_mode", 1, {
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": "INTERNAL_MODE_FRONT:1,INTERNAL_MODE_BACK:2,INTERNAL_MODE_DISABLED:0",
	})
	
	has_changes = has_changes or try_add_property("debug/hotspots_visible", false, {
		"type": TYPE_BOOL,
		"hint": PROPERTY_HINT_NONE,
	})


	if has_changes:
		ProjectSettings.save() # persist to project.godot
		
func try_add_property(setting_name:String, value:Variant, info: Dictionary):
	setting_name = "BVN/" + setting_name
	if not ProjectSettings.has_setting(setting_name):
		info.name = setting_name
		ProjectSettings.set_setting(setting_name , value) # default value
		ProjectSettings.add_property_info(info)
		return true
	return false
