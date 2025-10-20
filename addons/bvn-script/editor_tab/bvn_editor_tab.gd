@tool
extends Control

class_name BVN_EditorTab

# Note: DO NOT Export these. Weird interaction with the editor.
@onready var start_wizard:Control = %"Configuration Wizard"
@onready var text_editor:BVNInternal_EditorTextEditor = %CodeEditor
@onready var scene_name:Label = %SceneName

var timer:Timer

## List of all variables to autocomplete to
var variables_list :Array[BVN_Var]= []

var edited_scene:BVN_Page:
	set(v):
		edited_scene = v
		text_editor.edited_scene = v
			
var is_editing_scene:
	get: return edited_scene and edited_scene.page_data
	
#region TEMP SCAFFOLD - @TODO delete
var parser := BVN_ScriptParser.new()
var parsed_ast:Bvn_AstNode: 
	get: return text_editor.parsed_ast
	set(v): text_editor.parsed_ast = v
#endregion


# Don't put in ready or enter_tree - because its a @tool script, it will run
# _ready even while viewing it as prefab instead of an actual tool
var is_attached_to_editor = false
func setup() -> void:
	is_attached_to_editor = true # assumption made that SETUP is only called when its in the editor
	
	timer = Timer.new()
	timer.autostart = false
	timer.time_left
	timer.one_shot = true
	add_child(timer,false, INTERNAL_MODE_FRONT)
	
	text_editor.syntax_highlighter = BVNInternal_SyntaxHighlighter.new()
	text_editor.code_completion_prefixes = ["{{"," ","if","elif",">", "\t"]

	
	# This is debounce
	text_editor.text_changed.connect(_reset_debounce)
	timer.timeout.connect(_save_bvn_script)
	
	text_editor.code_completion_enabled = true
	text_editor.code_completion_requested.connect(_try_autocomplete)
	text_editor.get_tab_size()
	text_editor.focus_exited.connect(_save_bvn_script)

		
	BVN_EventBus.on_editor_scene_inspect.connect(_on_inspect_scene)
	BVN_EventBus.on_editor_variable_add.connect(_on_var_add)
	BVN_EventBus.on_editor_variable_rm.connect(_on_var_rm)
	BVN_EventBus.on_editor_variable_rename.connect(_on_var_rename)
	
	
	var is_old_project := BVN_ProjectSettings.last_edited_engine and \
		FileAccess.file_exists(BVN_ProjectSettings.last_edited_engine)
	start_wizard.visible = !is_old_project

	BVN_EventBus.on_editor_attached.emit()
	
func _on_var_rename(variable:BVN_Var, from:String, to:String):
	pass
	# TODO feature to auto replace variables after showing
	# a dialogue
func _on_var_add(variable:BVN_Var):
	variables_list.append(variable)
func _on_var_rm(variable:BVN_Var):
	variables_list.erase(variable)
	
func _reset_debounce():
	text_editor.update_code_completion_options(true)
	timer.stop()
	timer.start(1)
	
func _try_autocomplete():
	if !is_editing_scene: return
	if !parsed_ast: return
	
	var suggestions:=[]
	
	var line_index := text_editor.get_caret_line()
	var line_text := text_editor.get_line(line_index)
		
	var ast_node := parsed_ast.find_node_by_line_index(line_index)
	
	
	var word := text_editor.get_word_under_caret()
	var icon_dir := BVN_IconDirectory.get_icon_dir()
	
	match ast_node.type:
		Bvn_AstNode.TYPE_COMMAND:
			var commander := BVNInternal_EngineCommandRunner.new()
			for var_name in commander.expression_var_names:
				var icon_name := "command.svg"
				if var_name.begins_with(word) if word else true:
					text_editor.add_code_completion_option(
							CodeEdit.KIND_PLAIN_TEXT, 
							var_name, 
							var_name,
							Color.WHITE, load(icon_dir + "/" + icon_name)
						)
		
	for variable in variables_list:
		var var_name := str(variable.name)
		var icon_name := variable.get_editor_icon()
		if var_name.begins_with(word) if word else true:
			text_editor.add_code_completion_option(
					CodeEdit.KIND_PLAIN_TEXT, 
					var_name, 
					var_name,
					Color.WHITE, load(icon_dir + "/" + icon_name)
				)
	
	text_editor.update_code_completion_options(true)
	
func _on_inspect_scene(scene:BVN_Page):
	_save_bvn_script() # save current script before moving on
	
	if scene:
		scene_name.text = scene.get_scene_path()
		edited_scene = scene
		var page_data := edited_scene.page_data
		if !page_data:
			edited_scene.page_data = BVN_PageData.new()
			get_tree().edited_scene_root.property_list_changed_notify()
			
		text_editor.text = edited_scene.page_data.scene_script
	else:
		scene_name.text = "No BVN Scene Tree Selected"
		edited_scene = null
		text_editor.text = &""
	
func _save_bvn_script():
	if !is_editing_scene: return
	parsed_ast = parser.parse_bvn_script(text_editor.text)
	edited_scene.page_data.scene_script = text_editor.text.strip_edges()
	
func _input(event: InputEvent) -> void:
	if text_editor.has_focus() and event is InputEventMouseMotion:
		pass
		#var pos := get_local_mouse_position()
		#var row = text_editor.get_word_at_pos(pos)
		##var col = text_editor.get_column_from_position(row, pos)
		##var word = text_editor.get_word_at_position(pos)
		#var word = "asd"
		# Now you know what’s under the cursor
