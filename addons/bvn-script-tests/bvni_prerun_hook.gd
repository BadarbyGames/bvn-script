extends GutHookScript

func run():
	BVNInternal.is_editor_mode = true
	BVN_ProjectSettings.settings_global_override = {}
	
	gut.add_child(BVNInternal_Notif.new())
