extends GutTest

class_name BVNInternal_GutTest

func assert_cleanup_signal(node:Node):
	var before = BVN_EventBus.debug_get_all_signals()
	add_child(node)
	
	node.free()
	assert_eq(BVN_EventBus.debug_get_all_signals(),before)

func add_bvn_engine_autofree() -> Dictionary:
	var components := {}
	components.visual_novel = BVN_VisualNovel.new()
	
	components.personA = BVN_CharacterSheet.new()
	components.personA.display_name = "personA"
	
	
	components.visual_novel.characters.assign([components.personA])
	
	#region Create Engine
	components.engine = add_child_autofree(BVN_Engine.new())
	components.engine.visual_novel = components.visual_novel
	
	components.variables = BVN_Variables.new()
	components.engine.add_child(components.variables)
	
	components.scene = BVN_Scene.new()
	components.scene.scene_data = BVN_SceneData.new()
	components.engine.add_child(components.scene)
	return components
var packed_scene :PackedScene = load("res://addons/bvn-script/editor_tab/bvn_editor_tab.tscn")
func add_editor_tab_autofree() -> Dictionary:
	var components = {}
	components.editor = add_child_autofree(packed_scene.instantiate())
	components.editor.setup()
	return components
