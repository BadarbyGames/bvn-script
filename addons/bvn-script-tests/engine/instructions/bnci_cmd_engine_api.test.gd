extends BVNInternal_GutTest

var api :BVNInternal_CmdEngineApi 
var engine:BVN_Engine
func before_each():
	clean_notifs()
	api = add_child_autofree(BVNInternal_CmdEngineApi.new())
	engine = add_bvn_engine_autofree().engine

func test_no_additional_garbage():
	assert_cleanup_signal(BVNInternal_CmdEngineApi.new())
	assert_no_new_orphans()

func test_lock_in_game():
	assert_false(engine.lock_service.is_locked)
	
	var is_locked := api.lock(self)
	assert_true(engine.lock_service.is_locked)
	
func test_lock_in_editor_mode():
	var editor:BVN_EditorTab = add_editor_tab_autofree().editor
	var manager:BVNInternal_Notif = BVNInternal_Query.editor_notif 
	
	var is_locked := api.lock(self)
	#
	var tmp := manager.container.get_child(0)
	var badge = manager.container.get_child(0) as BVNInternal_NotifBadgeLock
	assert_not_null(badge)
	
	## Simulate pressing (deleting event)
	badge.button.pressed.emit()
	await wait_idle_frames(10) # Wait for all queue free()
	assert_eq(manager.container.get_children().size(), 0)
	assert_false(engine.lock_service.is_locked)
	
	#assert_true(true)
