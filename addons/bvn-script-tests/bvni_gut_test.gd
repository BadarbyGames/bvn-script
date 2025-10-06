extends GutTest

class_name BVNInternal_GutTest

func assert_cleanup_signal(node:Node):
	var before = BVN_EventBus.debug_get_all_signals()
	add_child(node)
	
	node.free()
	assert_eq(BVN_EventBus.debug_get_all_signals(),before)
