extends BVNInternal_GutTest

var api :BVNInternal_CmdAudioApi 
func before_each():
	add_engine_settings_autofree()
	api = add_child_autofree(BVNInternal_CmdAudioApi.new())
	clean_notifs()

func test_no_additional_garbage():
	assert_cleanup_signal(BVNInternal_CmdAudioApi.new())
	assert_no_new_orphans()

func test_plays_audio_in_game():
	var player := api.play("test_audio.ogg")
	
	# Assert that some audio player is playing the correct file
	assert_not_null(player)
	assert_true(player.playing)
	assert_eq(player.stream.resource_path.get_file(), "test_audio.ogg")
	
func test_send_notif_in_game_editor_mode():
	var editor:BVN_EditorTab = add_editor_tab_autofree().editor
	
	var manager:BVNInternal_Notif = BVNInternal_Query.editor_notif 
	var player := api.play("test_audio.ogg")
	
	var badge = manager.container.get_child(0) as BVNInternal_NotifBadgeAudio
	assert_not_null(badge)
	
	# Simulate pressing (deleting event)
	badge.button.pressed.emit()
	await wait_idle_frames(10) # Wait for all queue free()
	assert_eq(manager.container.get_children().size(), 0)
	assert_false(is_instance_valid(player))
	
	assert_true(true)
