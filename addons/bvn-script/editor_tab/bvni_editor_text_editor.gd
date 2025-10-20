@tool
extends CodeEdit

class_name BVNInternal_EditorTextEditor

var counter:int = 5
var edited_scene:BVN_Page
var debounce_break_point:BdbDebounce
var parser := BVN_ScriptParser.new()
var parsed_ast:Bvn_AstNode

func _enter_tree() -> void:
	if is_instance_valid(debounce_break_point): 
		debounce_break_point.queue_free()
	debounce_break_point = BdbDebounce.new(0.1)
	add_child(debounce_break_point)
	if !breakpoint_toggled.is_connected(debounce_break_point.handle):
		breakpoint_toggled.connect(debounce_break_point.cb(execute_breakpoints_as_line).handle)
		
func execute_breakpoints_as_line(line_index:int):
	# We are using the breakpoint as a way to "play" lines.
	# if there is a breakpoint, we need to convert it into a "executing" line
	var is_selecting_line := get_breakpointed_lines().size() > 0
	
	# When we clear the breakpoints, this function is called again
	# But this time with no breakpoints. So we shortcircuit
	if !is_selecting_line:
		return
		
	clear_breakpointed_lines()
	clear_executing_lines()
	
	
	execute_line(line_index)

func execute_line(line_index:int):
	assert(edited_scene, "No Scene set.")
	assert(edited_scene.page_data, "Scene has missing page_data")
	
	# Get all instructions
	parsed_ast = parser.parse_bvn_script(text)
	var ln_node := parsed_ast.find_node_by_line_index(line_index)
	var target_node := ln_node
	
	# If its a multiline-then we execute the parent
	if ln_node.type == Bvn_AstNode.TYPE_UNSPECIFIED:
		target_node = ln_node.parent
	
	if target_node:
		match target_node.type:
			Bvn_AstNode.TYPE_UNSPECIFIED:
				BdbError.bad_state()
			Bvn_AstNode.TYPE_IF:
				var dialog := AcceptDialog.new()
				dialog.dialog_text = "Warning: This is bad"
				dialog.confirmed.connect(func(): 
					dialog.queue_free())
				get_tree().root.add_child(dialog)  # or add to editor interface for plugins
				dialog.popup_centered()
			_:
				## Add the yellow arrow in the editor
				var lines := target_node.get_line_index_all()
				for line in lines:
					set_line_as_executing(line, true)
				var engine := BVNInternal_Query.engine
				var vars = BVNInternal_Query.variables.get_format_payload()
				vars[&".scene_path"] = edited_scene.get_scene_path()
				
				## Warn user that the engine is locked
				if engine.lock_service.is_locked:
					BVNInternal_Notif.toast("Engine is locked by [%s]" % engine.lock_service.action_locker)
				else:
					engine.execute_bvn_instruction(target_node, vars)
	
