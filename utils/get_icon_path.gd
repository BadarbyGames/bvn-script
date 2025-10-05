@tool
extends EditorScript

func _run() -> void:
	# @icon("../../../icons/godot_button.svg")
	var icon_dir := "res://addons/bvn-script/icons/"
	var target_path := "res://addons/bvn-script/nodes/bvn_managed_nodes.gd"
	
	# Remove the filenames, we only care about the directories
	var rel = get_relative_dir(icon_dir, target_path)
	print("@ICON PATH ","%s/"%rel)

func get_relative_dir(path_a: String, path_b: String) -> String:
	var dir_a := path_a.get_base_dir().split("/")
	var dir_b := path_b.get_base_dir().split("/")
	
	# Find where they diverge
	var i := 0
	while i < min(dir_a.size(), dir_b.size()) and dir_a[i] == dir_b[i]:
		i += 1
	
	# How many ".." we need to climb from B
	var rel := "../".repeat(dir_b.size() - i)
	
	# Go down into A
	if i < dir_a.size():
		rel += "/".join(dir_a.slice(i, dir_a.size()))
	
	return rel.substr(0)
