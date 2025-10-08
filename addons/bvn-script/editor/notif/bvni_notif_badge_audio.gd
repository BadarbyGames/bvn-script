@tool
extends HBoxContainer

class_name BVNInternal_NotifBadgeAudio

@onready var button:Button = $Button
@onready var progress:ProgressBar = $Button/ProgressBar

func _enter_tree() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED

var player:AudioStreamPlayer 
func start(new_player:AudioStreamPlayer):
	player = new_player
	progress.max_value = new_player.stream.get_length()
	process_mode = Node.PROCESS_MODE_INHERIT
	
func _process(delta: float) -> void:
	if is_instance_valid(player):
		progress.value = player.get_playback_position()
	else:
		queue_free()

func _on_button_pressed() -> void:
	progress.value = progress.max_value
	queue_free()
