extends GutHookScript

func run():
	BVN_ProjectSettings.settings_global_override = {}
	BVNInternal_Notif.container.free()
	BVNInternal.is_editor_mode = false
