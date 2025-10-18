@icon("../icons/database.svg")
@tool
extends Node

## Used to override the project settings in cases where you have multiple
## Visual Novels in a single project.
class_name BVN_SettingsOverridesNode

func _enter_tree() -> void:
	notify_settings()

@export_dir var setup_data_folder: String:
	set(v):
		setup_data_folder = v
		notify_settings()
	
@export_dir var setup_audio_folder: String:
	set(v):
		setup_audio_folder = v
		notify_settings()
	
@export_dir var setup_images_folder: String:
	set(v):
		setup_images_folder = v
		notify_settings()
		
func notify_settings():
	BVN_Settings.settings_global_override.set("setup/data_folder",setup_data_folder)
	BVN_Settings.settings_global_override.set("setup/audio_folder", setup_audio_folder)
	BVN_Settings.settings_global_override.set("setup/images_folder", setup_images_folder)
