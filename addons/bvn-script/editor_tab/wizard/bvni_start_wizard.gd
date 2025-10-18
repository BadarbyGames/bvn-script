@tool
extends Control

class_name BVNInternal_StartWizard

@export var diag_select_dir:FileDialog
@export var diag_inform:AcceptDialog
@export var data_line_edit:LineEdit
@export var audio_line_edit:LineEdit
@export var image_line_edit:LineEdit
@export var novel_template_packed_scene:PackedScene
@export var descrpt_label:RichTextLabel

var current_line_edit:LineEdit
var current_proj_setter:Callable # This way because BVN_Settings is a static class and i cant be dynamic
var selected_folder:String
func _enter_tree() -> void:
	sync_settings()
	
func sync_settings():
	data_line_edit.text = BVN_Settings.setup_data_folder
	if !data_line_edit.focus_entered.is_connected(_on_click_input):
		data_line_edit.focus_entered.connect(_on_click_input.bind(data_line_edit))
		data_line_edit.focus_entered.connect(set.bind("current_proj_setter", func(dir): BVN_Settings.setup_data_folder = dir))
		
	audio_line_edit.text = BVN_Settings.setup_audio_folder
	if !audio_line_edit.focus_entered.is_connected(_on_click_input):
		audio_line_edit.focus_entered.connect(_on_click_input.bind(audio_line_edit))
		audio_line_edit.focus_entered.connect(set.bind("current_proj_setter", func(dir): BVN_Settings.setup_audio_folder = dir))
		
	image_line_edit.text = BVN_Settings.setup_audio_folder
	if !image_line_edit.focus_entered.is_connected(_on_click_input):
		image_line_edit.focus_entered.connect(_on_click_input.bind(image_line_edit))
		image_line_edit.focus_entered.connect(set.bind("current_proj_setter", func(dir): BVN_Settings.setup_data_folder = dir))

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

func ensure_dir(path: String) -> void:	
	var dir := DirAccess.open("res://")
	if dir:
		var parts := path.trim_prefix("res://").split("/")
		var current := "res://"
		for part in parts:
			if part == "":
				continue
			current += part + "/"
			if not DirAccess.dir_exists_absolute(current):
				DirAccess.make_dir_absolute(current)
				

func copy_folder(src_path: String, dst_path: String) -> void:
	var src_dir := DirAccess.open(src_path)
	if src_dir == null:
		push_error("Failed to open source folder: %s" % src_path)
		return

	# Ensure destination folder exists
	DirAccess.make_dir_recursive_absolute(dst_path)

	src_dir.list_dir_begin()
	var file_name := src_dir.get_next()
	while file_name != "":
		if file_name.begins_with(".") or file_name.ends_with(".import"):  # skip hidden system entries
			file_name = src_dir.get_next()
			continue

		var src_item_path := src_path.path_join(file_name)
		var dst_item_path := dst_path.path_join(file_name)

		if src_dir.current_is_dir():
			# Recursive copy for directories
			copy_folder(src_item_path, dst_item_path)
		else:
			# Copy file contents
			var src_file := FileAccess.open(src_item_path, FileAccess.READ)
			if src_file:
				var data := src_file.get_buffer(src_file.get_length())
				src_file.close()

				var dst_file := FileAccess.open(dst_item_path, FileAccess.WRITE)
				if dst_file:
					dst_file.store_buffer(data)
					dst_file.close()
				else:
					push_error("Failed to create file: %s" % dst_item_path)
			else:
				push_error("Failed to open file: %s" % src_item_path)

		file_name = src_dir.get_next()

	src_dir.list_dir_end()
