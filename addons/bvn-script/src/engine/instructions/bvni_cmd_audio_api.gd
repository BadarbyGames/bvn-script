extends Node

class_name BVNInternal_CmdAudioApi

func play(path:String) -> AudioStreamPlayer:
	var response := BVNInternal.find_audio_res(path)
	if BVNInternal.is_editor_mode and not(response.has(OK)):
		BVNInternal_Notif.toast("⚠ Could not find '%s'" % path)
	assert(response.has(OK), "Cannot find '%s' " % path)
	var audio := response[OK]
	
	#region SPECIAL CASES
	## @TODO check all the other audios, maybe do a matrix for every accepted audio type
	var wav = audio as AudioStreamWAV
	if wav: wav.loop_mode = AudioStreamWAV.LOOP_DISABLED
	#endregion
	
	var audio_player:AudioStreamPlayer = AudioStreamPlayer.new()
	audio_player.stream = audio
	audio_player.finished.connect(audio_player.queue_free)
	add_child(audio_player, true, Node.INTERNAL_MODE_FRONT)
	audio_player.play()
	
	if BVNInternal.is_editor_mode:
		# @TODO there is a chance for the user to play it multiple times
		# the way we sort this out right now is just to kill all audio
		BVN_EventBus.on_editor_audio_play.emit(audio_player)
	return audio_player
