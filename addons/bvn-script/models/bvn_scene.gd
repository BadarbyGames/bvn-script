@icon("../icons/page.svg")
@tool
extends BVN_Node2D

## Container for game elements to show the player at a particular time.
## Only one BVN Scene can be in display at a time.
class_name BVN_Scene

@export var scene_data:BVN_SceneData

var scene_set:BVN_SceneSet:
	get: return BVN_EngineSelectors.find_bvn_scene_set_ancestor(self)

func _init() -> void:
	tree_entered.connect(setup, CONNECT_ONE_SHOT)

func _setup(): pass
func setup():
	if !scene_data: 
		scene_data = BVN_SceneData.new()
		assert(scene_set, "Needs to be a child of either the engine or a scene set")
	add_to_group(BVNInternal_Tags.NODE_MANAGED)
	add_to_group(BVNInternal_Tags.NODE_SCENE)
	_setup()
	
		
func _get_configuration_warnings() -> PackedStringArray:
	var errs := []
	if !scene_set:
		errs.append(["Needs to be a child of either the engine or a scene set"])
	if scene_data == null:
		errs.append(["No scene data set. Please set one"])
	return errs

func get_scene_path():
	return str(scene_set.get_scene_path(), " / ", name)
