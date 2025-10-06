extends BVNInternal_GutTest

func test_cleans_signal_on_exit():
	assert_cleanup_signal(BVNInternal_SessionService.new())
