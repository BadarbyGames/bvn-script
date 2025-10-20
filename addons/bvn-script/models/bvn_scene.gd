@icon("../icons/page.svg")
@tool
extends BVN_Node2D

## Container for game elements to show the player at a particular time.
## Only one BVN Scene can be in display at a time.
class_name BVN_Page

@export var page_data:BVN_PageData

var chapter:BVN_Chapter:
	get: return BVN_EngineSelectors.find_bvn_chapter_ancestor(self)

func _init() -> void:
	BdbSig.sig_conn(tree_entered, setup)

func _setup(): pass
func setup():
	if !page_data: 
		page_data = BVN_PageData.new()
		assert(chapter, "Needs to be a child of either the engine or a scene set")
	add_to_group(BVNInternal_Tags.NODE_MANAGED)
	add_to_group(BVNInternal_Tags.NODE_PAGE)
	_setup()
	
		
func _get_configuration_warnings() -> PackedStringArray:
	var errs := []
	if !chapter:
		errs.append(["Needs to be a child of either the engine or a scene set"])
	if page_data == null:
		errs.append(["No scene data set. Please set one"])
	return errs

func get_scene_path():
	return str(chapter.get_scene_path(), " / ", name)
