extends Node

class_name BVN_IconDirectory

static func get_icon_dir() -> String:
	return (BVN_IconDirectory as Script).resource_path.get_base_dir()

static func get_wizard_path() -> String:
	return (BVNInternal_StartWizard as Script).resource_path.get_base_dir()
