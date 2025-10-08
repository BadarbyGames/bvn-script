@tool
extends Node

@onready var hotspot_button:Button = %"Hide HotSpots"

func _enter_tree() -> void:
	add_to_group(BVNInternal_Tags.EDITOR_AUDIO)
	BVN_EventBus.on_editor_attached.connect(setup)
	
func _exit_tree() -> void:
	remove_from_group(BVNInternal_Tags.EDITOR_AUDIO)
	BVN_EventBus.on_editor_attached.disconnect(setup)
	
func setup():
	toggle_button_text(BVN_Settings.debug_hotspots_visible)
	hotspot_button.pressed.connect(func ():
		var new_value := !BVN_Settings.debug_hotspots_visible
		BVN_Settings.debug_hotspots_visible = new_value
		toggle_hotspot_visibility(new_value)
		toggle_button_text(new_value)
		)
		
func toggle_button_text(is_visible:bool):
	if is_visible:
		hotspot_button.text = "💤 Hide Hotspots"
	else:
		hotspot_button.text = "👁 Show Hotspots"
		
func toggle_hotspot_visibility(is_visible:bool):
	for hotspot in BVNInternal_Query.hotspots:
		hotspot.update_hotspot_visibility(is_visible)
