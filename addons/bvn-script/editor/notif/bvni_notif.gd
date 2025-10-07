extends VBoxContainer

## Internal helper for the notification system
class_name BVNInternal_Notif

var plugin:EditorPlugin
func _init(_plugin:EditorPlugin) -> void:
	plugin = _plugin
	
func start():
	add_to_group(BVNInternal_Tags.EDITOR_NOTIF)
	
	var main := get_viewport_parent()
	main.add_child(self)
	
	alignment = BoxContainer.ALIGNMENT_END
	set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	position -= Vector2(20,20)
	

static func get_viewport_parent() -> Control:
	## @TODO add a check for differnt version, no gaurantee this wont change by the next version
	return EditorInterface.get_editor_viewport_2d().get_parent().get_parent()
	
static func toast(text:String):
	var resource_path := (BVNInternal_NotifBadge as Script).resource_path
	var tscn_name := resource_path.get_file().get_basename()
	var tscn_dir := (BVNInternal_NotifBadge as Script).resource_path.get_base_dir()
	var packed:PackedScene = load(str(tscn_dir,"/",tscn_name,".tscn"))

	var container:BVNInternal_Notif = BVNInternal_Query.editor_notif
	
	var badge:BVNInternal_NotifBadge = packed.instantiate()
	badge.time_to_live = 5.5
	
	container.add_child(badge)
	badge.button.text = text
	container.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	container.position -= Vector2(20,20)
	
	badge.run_as_timed_badge(7)

	
	
