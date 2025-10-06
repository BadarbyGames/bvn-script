@icon("../icons/folder.svg")
@tool
extends BVN_ManagedNodes

## Like a folder for scenes.
class_name BVN_SceneSet

var scene_parent:BVN_SceneSet:
	get:
		return BVN_EngineSelectors.find_bvn_scene_set_ancestor(self.get_parent())

func get_scene_path():
	var tmp := scene_parent
	if tmp and not(tmp is BVN_Engine):
		var prefix = tmp.get_scene_path()
		return str(prefix," / ",name)
	else:
		return name
