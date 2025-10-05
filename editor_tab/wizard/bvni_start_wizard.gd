@tool
extends Control

class_name BVNInternal_StartWizard

@export var diag_select_dir:FileDialog
@export var diag_inform:AcceptDialog
@export var data_line_edit:LineEdit
@export var audio_line_edit:LineEdit
@export var novel_template_packed_scene:PackedScene
@export var descrpt_label:RichTextLabel

var current_line_edit:LineEdit
var current_proj_setter:Callable # This way because BVN_Settings is a static class and i cant be dynamic
var selected_folder:String
func _enter_tree() -> void:
	if !data_line_edit.focus_entered.is_connected(_on_click_input):
		data_line_edit.focus_entered.connect(_on_click_input.bind(data_line_edit))
		data_line_edit.focus_entered.connect(set.bind("current_proj_setter", func(dir): BVN_Settings.setup_data_folder = dir))
	if !audio_line_edit.focus_entered.is_connected(_on_click_input):
		audio_line_edit.focus_entered.connect(_on_click_input.bind(audio_line_edit))
		audio_line_edit.focus_entered.connect(set.bind("current_proj_setter", func(dir): BVN_Settings.setup_audio_folder = dir))
	sync_settings()
	
func sync_settings():
	data_line_edit.text = BVN_Settings.setup_data_folder
	audio_line_edit.text = BVN_Settings.setup_audio_folder

func _on_click_input(line_edit:LineEdit) -> void:
	current_line_edit = line_edit
	
	
	diag_select_dir.current_dir = line_edit.text
	diag_select_dir.show()

func _on_select_dir_dialogue_dir_selected(dir: String) -> void:
	get_viewport().gui_release_focus()
	current_line_edit.text = dir
	current_proj_setter.call(dir)
	sync_settings()


func _on_select_dir_dialogue_canceled() -> void:
	get_viewport().gui_release_focus()


func _generate_template() -> void:
	var vn_resource:BVN_VisualNovel = generate_vn_resource()
	var vn_engine:PackedScene = generate_vn_main_scene(vn_resource)
	
	EditorInterface.open_scene_from_path(vn_engine.resource_path)
	
	diag_inform.title = "File Generated"
	diag_inform.dialog_text = \
	"""\
	Novel Resource File created at '%s'
	New Scene created at '%s'
	"""  %  [vn_resource.resource_path, vn_engine.resource_path]
	diag_inform.dialog_text = diag_inform.dialog_text.strip_edges()
	diag_inform.show()
	
func generate_vn_resource() -> BVN_VisualNovel:
	var data_path :String = BVN_Settings.setup_data_folder
	var novel := BVN_VisualNovel.new()
	var proj_name:String = ProjectSettings.get_setting("application/config/name")
	var strings = ["novel"]
	if proj_name: strings.push_back(proj_name)
	
	var file_name:String = "-".join(strings)
	var file_path:String = "%s/%s.tres" % [data_path,file_name]
	
	var err = ResourceSaver.save(novel,file_path)
	novel.take_over_path(file_path)
	assert(err == OK, error_string(err))
	return novel

func generate_vn_main_scene(vn_resource:BVN_VisualNovel) -> PackedScene:
	var data_path :String = BVN_Settings.setup_data_folder
	var file_name = "bvni_novel_template"
	var file_path:String = "%s/%s.tscn" % [data_path,file_name]
	
	var root_node:Node = novel_template_packed_scene.instantiate()
	var bvn_engine:BVN_Engine = BdbSelect.child_by_type_recursive(root_node, BVN_Engine)
	bvn_engine.visual_novel = vn_resource
	
	var new_packed := PackedScene.new()
	new_packed.pack(root_node)

	ResourceSaver.save(new_packed, file_path)
	new_packed.take_over_path(file_path)
	return new_packed
		
