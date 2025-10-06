extends GutTest

func test_no_orphans():
	var command_runner:BVNInternal_EngineCommandRunner = add_child_autofree(BVNInternal_EngineCommandRunner.new())
	assert_no_new_orphans()


func test_api_assignment_expansion():
	var command_runner:BVNInternal_EngineCommandRunner = add_child_autofree(BVNInternal_EngineCommandRunner.new())
	command_runner
	pass
