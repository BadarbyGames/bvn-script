extends Node

class_name BVNInternal_EditorAudio

@onready var btn_stop_audio:Button = %Stop_Audio_Btn

func _enter_tree() -> void:
	add_to_group(BVNInternal_Tags.EDITOR_AUDIO)
	BVN_EventBus.on_editor_attached.connect(setup)
	
func _exit_tree() -> void:
	remove_from_group(BVNInternal_Tags.EDITOR_AUDIO)
	BVN_EventBus.on_editor_attached.disconnect(setup)
	if BVN_EventBus.on_editor_audio_play.is_connected(_on_audio_play):
		BVN_EventBus.on_editor_audio_play.disconnect(_on_audio_play)
	
func setup():
	btn_stop_audio.hide() # Always start hidden
	BVN_EventBus.on_editor_audio_play.connect(_on_audio_play)

var playing_audios:Array[AudioStreamPlayer]= []
func _on_audio_play(player:AudioStreamPlayer):
	# IF already in list, then we re just replay it.
	for playing_audio in playing_audios:
		if playing_audio.stream.get_rid() == player.stream.get_rid():
			playing_audio.stop()
			playing_audios.erase(playing_audio)
	
	btn_stop_audio.text = "🛑 Stop Playing %s" % (
			"all audio" if playing_audios else player.stream.resource_path
		)
	btn_stop_audio.show()
	
	player.finished.connect(func ():
		playing_audios.erase(player)
		if not(playing_audios):
			btn_stop_audio.hide())
	btn_stop_audio.pressed.connect(func ():
		for audio in playing_audios:
			audio.stop()
		playing_audios.clear()
		btn_stop_audio.hide()
		, CONNECT_ONE_SHOT)
		
	# Keep attend at the end, so the "all_audio" text bit works
	playing_audios.append(player)
