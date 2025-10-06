extends GutTest

func test_load_feature():
	var save_svc:BVNInternal_SessionService = add_child_autoqfree(BVNInternal_SessionService.new())
	save_svc.save_game("test",{
		"vars": {
			"Player":"Ryan Harris"
		}
	})
	
	var store:BVN_Variables = add_child_autoqfree(BVN_Variables.new())
	store.add_variable(BVN_VarString, "Player")
	
	save_svc.load_game("test")
	
	assert_eq(store.get_var_by_name("Player"), "Ryan Harris")
	
