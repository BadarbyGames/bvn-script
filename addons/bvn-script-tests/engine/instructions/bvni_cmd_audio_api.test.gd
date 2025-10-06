extends BVNInternal_GutTest

var packed_scene :PackedScene = load("res://addons/bvn-script/editor_tab/bvn_editor_tab.tscn")
var api :BVNInternal_CmdAudioApi 
func before_each():
	api = add_child_autofree(BVNInternal_CmdAudioApi.new())

func test_no_additional_garbage():
	assert_cleanup_signal(BVNInternal_CmdAudioApi.new())
	assert_no_new_orphans()

func test_plays_audio_in_game():
	var player := api.play("test_audio.ogg")
	
	# Assert that some audio player is playing the correct file
	assert_not_null(player)
	assert_true(player.playing)
	assert_eq(player.stream.resource_path.get_file(), "test_audio.ogg")
	
func test_audio_editor_starts_clean():
	var editor:BVN_EditorTab = add_child_autoqfree(packed_scene.instantiate())
	editor.setup()
	
	var manager := BVNInternal_Query.editor_audio
	assert_false(manager.btn_stop_audio.visible) # ensure it starts hidden
	
func test_plays_audio_in_game_editor_mode():
	var editor:BVN_EditorTab = add_child_autoqfree(packed_scene.instantiate())
	editor.setup()
	
	var manager := BVNInternal_Query.editor_audio
	var player := api.play("test_audio.ogg", true)
	
	assert_true(player in manager.playing_audios)
	assert_true(manager.btn_stop_audio.visible)
	assert_true(manager.btn_stop_audio.text.contains("test_audio.ogg"))
