extends VBoxContainer

## Internal helper for the notification system
class_name BVNInternal_Notif

var plugin:EditorPlugin
func _init(_plugin:EditorPlugin = null) -> void:
	plugin = _plugin

func _enter_tree() -> void:
	add_to_group(BVNInternal_Tags.EDITOR_NOTIF)
	
func start():
	
	var main := get_viewport_parent()
	main.add_child(self)
	
	alignment = BoxContainer.ALIGNMENT_END
	set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	position -= Vector2(20,20)
	

static func get_viewport_parent() -> Control:
	## @TODO add a check for differnt version, no gaurantee this wont change by the next version
	return EditorInterface.get_editor_viewport_2d().get_parent().get_parent()


static var container:Node: 
	get: return BVNInternal_Query.editor_notif
	
static func toast(text:String, config:Dictionary = {}) -> BVNInternal_NotifBadge:
	var icon:Texture2D = config.get("icon",null)
	var packed_scene := get_toast_packed_scene(BVNInternal_NotifBadge)
	var badge:BVNInternal_NotifBadge = packed_scene.instantiate()
	container.add_child(badge)
	
	badge.button.text = text
	if icon:
		badge.button.icon = icon
		
	container.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	container.position -= Vector2(20,20)
	
	var ttl:float = config.get("time_to_live",5.5)
	badge.start(ttl)
	return badge

static func toast_audio(text:String, config:Dictionary = {}) -> BVNInternal_NotifBadgeAudio:
	var icon:Texture2D = config.get("icon",null)
	var packed_scene := get_toast_packed_scene(BVNInternal_NotifBadgeAudio)
	var badge:BVNInternal_NotifBadgeAudio = packed_scene.instantiate()
	container.add_child(badge)
	
	badge.button.text = text
	if icon:
		badge.button.icon = icon
		
	container.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	container.position -= Vector2(20,20)
	
	badge.start(config.audio_player)
	return badge


static func get_toast_packed_scene(script:Script) -> PackedScene:
	var resource_path := script.resource_path
	var tscn_name := resource_path.get_file().get_basename()
	var tscn_dir := script.resource_path.get_base_dir()
	
	return load(str(tscn_dir,"/",tscn_name,".tscn"))

	
	
