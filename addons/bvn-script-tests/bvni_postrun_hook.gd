extends GutHookScript

func run():
	BVN_Settings.settings_override = {}
	BVNInternal_Notif.container.free()
	BVNInternal.is_editor_mode = false
