extends Node

class_name BVN_RootDir

static func get_dir() -> String:
	return (BVN_RootDir as Script).resource_path.get_base_dir()
