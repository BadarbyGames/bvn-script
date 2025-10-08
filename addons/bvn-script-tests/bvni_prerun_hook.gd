extends GutHookScript

func run():
	BVN_Settings.settings_override = {
		"setup/data_folder": "res://addons/bvn-script-tests/assets",
		"setup/audio_folder": "res://addons/bvn-script-tests/assets"
	}
	
	gut.add_child(BVNInternal_Notif.new())
