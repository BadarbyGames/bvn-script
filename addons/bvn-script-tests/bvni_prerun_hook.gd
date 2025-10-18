extends GutHookScript

func run():
	BVNInternal.is_editor_mode = true
	BVN_Settings.settings_global_override = {
		"setup/data_folder": "res://addons/bvn-script-tests/assets",
		"setup/audio_folder": "res://addons/bvn-script-tests/assets"
	}
	
	gut.add_child(BVNInternal_Notif.new())
