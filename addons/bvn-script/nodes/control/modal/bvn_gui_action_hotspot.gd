@tool
extends BVN_Button

## Clicking this area will tell the engine to proceed to the next instruction
## in the current BVN Scene.
class_name BVN_GuiActionHotspot

const EDITOR_VISIBLE_COLOR = Color(1.0, 0.003, 0.279, 1.0)
func _enter_tree() -> void:
	add_to_group(BVNInternal_Tags.TOOL_HOTSPOT)
	if Engine.is_editor_hint():
		update_hotspot_visibility(BVN_ProjectSettings.debug_hotspots_visible)
	else:
		update_hotspot_visibility(false)
	update_gizmo_text()
	
func _ready() -> void:
	pressed.connect(_on_pressed)
	
func _on_pressed():
	BVN_EventBus.on_request_next_engine_action.emit()

func update_gizmo_text():
	text = "On click - next instruction"

func update_hotspot_visibility(is_visible:bool):
	if is_visible:
		set("theme_override_colors/font_color", Color.WHITE)
		modulate = EDITOR_VISIBLE_COLOR
	else:
		modulate = Color.TRANSPARENT
