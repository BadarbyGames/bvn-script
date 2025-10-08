@tool
extends HBoxContainer

class_name BVNInternal_NotifBadge

@onready var button:Button = $Button
@onready var progress:ProgressBar = $Button/ProgressBar

var time_to_live:float:
	set(v):
		progress.max_value = v

func _enter_tree() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED

func start(ttl:float):
	progress.max_value = ttl
	progress_factor = 1
	process_mode = Node.PROCESS_MODE_INHERIT

var progress_factor:int = 0
func _process(delta: float) -> void:
	progress.value += delta * progress_factor
	if progress.value >= progress.max_value:
		queue_free()

func _on_button_mouse_entered() -> void:
	progress_factor = 0

func _on_button_mouse_exited() -> void:
	progress_factor = 1

func _on_button_pressed() -> void:
	progress.value = progress.max_value
