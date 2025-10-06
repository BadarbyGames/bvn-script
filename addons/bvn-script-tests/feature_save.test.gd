extends GutTest

var save_svc:BVNInternal_SessionService
func before_all():
	save_svc = BVNInternal_SessionService.new()
	save_svc.session_data.file_name = "test"
	add_child(save_svc)
func after_all():
	save_svc.free()
	
func test_save_vars():
	#region
	var store:BVN_Variables = add_child_autoqfree(BVN_Variables.new())
	var var_string := BVN_VarString.new()
	var_string.name = "Player"
	var_string.value = "Ryan Harris"
	store.add_child(var_string)
	#endregion

	
	BVN.save()
	var result_data := save_svc.load_game()
	assert_eq(result_data.vars, { "Player":"Ryan Harris" })

func test_save_scenes():
	#region
	var sample_scene_set :BVN_SceneSet = add_child_autoqfree(BVN_SceneSet.new())
	sample_scene_set.name = "Chapter 20"
	var sample_scene:BVN_Scene = BVN_Scene.new()
	sample_scene.name = "Scene 5"
	sample_scene_set.add_child(sample_scene)
	
	var scene_svc:BVNInernal_SceneService = add_child_autoqfree(BVNInernal_SceneService.new())
	var context := scene_svc.mk_scene_context()
	context.scene = sample_scene
	#endregion
	
	BVN.save()
	var result_data := save_svc.load_game()
	var path = sample_scene.get_scene_path()
	assert_eq(result_data.scene.scene_path, sample_scene.get_scene_path())
