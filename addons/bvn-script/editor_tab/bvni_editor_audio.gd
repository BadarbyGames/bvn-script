@tool
extends Node

class_name BVNInternal_EditorAudio


func _enter_tree() -> void:
	add_to_group(BVNInternal_Tags.EDITOR_AUDIO)
	BVN_EventBus.on_editor_attached.connect(setup)
	
func _exit_tree() -> void:
	remove_from_group(BVNInternal_Tags.EDITOR_AUDIO)
	BVN_EventBus.on_editor_attached.disconnect(setup)
	if BVN_EventBus.on_editor_audio_play.is_connected(_on_audio_play):
		BVN_EventBus.on_editor_audio_play.disconnect(_on_audio_play)
	
func setup():
	BVN_EventBus.on_editor_audio_play.connect(_on_audio_play)

var playing_audios:Array[AudioStreamPlayer]= []
func _on_audio_play(player:AudioStreamPlayer):
	var audio_path := player.stream.resource_path
	var audio_name := audio_path.get_file()
	
	# Notify
	var icon_path:String = BVN_IconDirectory.get_icon_dir() + "/stop.svg"
	var icon:Texture2D = ResourceLoader.load(icon_path)
	var badge := BVNInternal_Notif.toast_audio("Playing %s " % audio_name , {"icon": icon, "audio_player": player})
	badge.button.pressed.connect(func ():
		player.stop()
		player.finished.emit(), CONNECT_ONE_SHOT)
