@icon("../../../icons/database.svg")
@tool
extends Node

## Container for Settings related to this engine's settings.
class_name BVN_SettingsNode

func _init() -> void:
	tree_entered.connect(func ():
		add_to_group(BVNInternal_Tags.ENGINE_SETTINGS)
		)
	tree_exited.connect(func ():
		remove_from_group(BVNInternal_Tags.ENGINE_SETTINGS)
		)

@export_dir var data_folder: String = ""
@export_dir var audio_folder: String = ""
@export_dir var images_folder: String = ""
