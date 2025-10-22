extends BVNInternal_GutTest

func test_next_only_moves_within_same_chapter():
	var engine:BVN_Engine = add_bvn_engine_autofree().engine
	var page_data := BVN_PageData.new()
	page_data.scene_script = "# comment"
	
	var chapter_1 :BVN_Chapter= BVNInternal.add_child(engine, BVN_Chapter.new())
	chapter_1.name = "chapter_1"
	var page_1_1 :BVN_Page = BVNInternal.add_child(chapter_1, BVN_Page.new())
	page_1_1.name = "page_1_1"
	page_1_1.page_data = page_data
	var page_1_2 :BVN_Page = BVNInternal.add_child(chapter_1, BVN_Page.new())
	page_1_2.name = "page_1_2"
	page_1_2.page_data = page_data
	var page_1_3 :BVN_Page = BVNInternal.add_child(chapter_1, BVN_Page.new())
	page_1_3.name = "page_1_3"
	page_1_3.page_data = page_data
	
	var chapter_2 :BVN_Chapter= BVNInternal.add_child(engine, BVN_Chapter.new())
	chapter_2.name = "chapter_2"
	var page_2_1 :BVN_Page = BVNInternal.add_child(chapter_2, BVN_Page.new())
	page_2_1.name = "page_2_1"
	page_2_1.page_data = page_data
	var page_2_2 :BVN_Page = BVNInternal.add_child(chapter_2, BVN_Page.new())
	page_2_2.name = "page_2_2"
	page_2_2.page_data = page_data
	var page_2_3 :BVN_Page = BVNInternal.add_child(chapter_2, BVN_Page.new())
	page_2_3.name = "page_2_3"
	page_2_3.page_data = page_data
	
	engine.print_tree_pretty()
	
	
	engine.run_page(page_1_3)
	assert_false(page_1_2.visible, "Negative test")
	assert_true(page_1_3.visible, "Should now be visible")
	assert_false(page_2_1.visible, "Negative test")
	
	await wait_frames(10)
	engine.next()
	assert_true(page_1_3.visible, "Should STILL be visible because it should not go beyond its own chapter")
	assert_false(page_2_1.visible, "Shouldn't have gone beyond its own chapter")
	
