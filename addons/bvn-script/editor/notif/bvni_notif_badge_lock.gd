@tool
extends HBoxContainer

class_name BVNInternal_NotifBadgeLock

@onready var button:Button = $Button

func _enter_tree() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED

var unlock_key:Variant
func start(unlock_key):
	process_mode = Node.PROCESS_MODE_INHERIT
	self.unlock_key = unlock_key

func _on_button_pressed() -> void:
	BVN_EventBus.on_request_unlock_engine.emit({
		&"source": unlock_key
	})
	queue_free()
