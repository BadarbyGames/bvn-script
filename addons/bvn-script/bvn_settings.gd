class_name BVN_Settings

static var settings_override:Dictionary[String,Variant] = {}

static func _load(prop_name:String, defaultValue):
	return  settings_override.get(
		prop_name,
		ProjectSettings.get_setting(str("BVN/",prop_name), defaultValue)
	)
static func _save(prop_name:String, new_value):
	ProjectSettings.set_setting(str("BVN/",prop_name), new_value)
	ProjectSettings.save() 
	
static var setup_data_folder: String:
	get: return _load("setup/data_folder", "")
	set(v): _save("setup/data_folder", v)
	
static var setup_audio_folder: String:
	get: return _load("setup/audio_folder", "")
	set(v): _save("setup/audio_folder", v)
	
static var setup_images_folder: String:
	get: return _load("setup/images_folder", "")
	set(v): _save("setup/images_folder", v)

static var last_edited_engine: String:
	get: return _load("debug/last_edited_engine", "")
	set(v): _save("debug/last_edited_engine", v)
	
static var debug_add_child_mode: Node.InternalMode:
	get: return _load("debug/add_child_mode", Node.INTERNAL_MODE_FRONT)

static var debug_hotspots_visible: bool:
	get: return _load("debug/hotspots_visible", false)
	set(v): _save("debug/hotspots_visible", v)
