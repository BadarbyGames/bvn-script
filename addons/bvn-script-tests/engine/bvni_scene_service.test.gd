extends BVNInternal_GutTest


func test_cleans_signal_on_exit():
	assert_cleanup_signal(BVNInernal_SceneService.new())

func test_only_should_only_show_incomin_node():
	add_child_autoqfree(BVNInernal_SceneService.new())
	var managed_nodes:BVN_ManagedNodes = add_child_autoqfree(BVN_ManagedNodes.new())
	var child1:Node2D = Node2D.new()
	var child2:Node2D = Node2D.new()
	var child3:Node2D = Node2D.new()
	
	managed_nodes.add_child(child1)
	assert_true(child1.visible, "Only 1 child, should be visible")
	assert_true(child2.visible, "Not yet, added - should still be visible")
	assert_true(child3.visible, "Not yet, added - should still be visible")
	
	
	managed_nodes.add_child(child2)
	assert_false(child1.visible, "Previous child should be hidden")
	assert_true(child2.visible, "Newly - Added should be visible")
	assert_true(child3.visible, "Not yet, added - should still be visible")
	
	managed_nodes.add_child(child3)
	assert_false(child1.visible, "Previous child should be hidden")
	assert_false(child2.visible, "Previous child should be hidden")
	assert_true(child3.visible, "Newly - Added should be visible")

func test_only_show_1_managed_node():
	add_child_autoqfree(BVNInernal_SceneService.new())
	var managed_nodes:BVN_ManagedNodes = add_child_autoqfree(BVN_ManagedNodes.new())
	var child1:Node2D = Node2D.new()
	var child2:Node2D = Node2D.new()
	var child3:Node2D = Node2D.new()
	child1.hide()
	child2.hide()
	child3.hide()
	managed_nodes.add_child(child1)
	managed_nodes.add_child(child2)
	managed_nodes.add_child(child3)
	
	child1.show()
	assert_true(child1.visible, "Only 1 child, should be visible")
	assert_false(child2.visible, "Not yet, added - should still be visible")
	assert_false(child3.visible, "Not yet, added - should still be visible")
	
	child2.show()
	assert_false(child1.visible, "Previous child should be hidden")
	assert_true(child2.visible, "Newly - Added should be visible")
	assert_false(child3.visible, "Not yet, added - should still be visible")
	
	child3.show()
	assert_false(child1.visible, "Previous child should be hidden")
	assert_false(child2.visible, "Previous child should be hidden")
	assert_true(child3.visible, "Newly - Added should be visible")
