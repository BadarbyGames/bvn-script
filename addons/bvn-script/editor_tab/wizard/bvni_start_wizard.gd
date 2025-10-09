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

func _generate_template() -> void:
	var plugin_folder := BVNInternal.get_plugin_path()
	var assets_template_folder := str(plugin_folder, "/editor_tab/wizard/template_assets/")
	var assets_folder = BVN_Settings.setup_audio_folder
	
	ensure_dir(BVN_Settings.setup_data_folder)
	copy_folder(assets_template_folder, BVN_Settings.setup_audio_folder)
		
	#region CUSTOM POLL LOGIC
	var editor_fs := EditorInterface.get_resource_filesystem()
	editor_fs.scan()
	
	var looking = true
	var safe_number = 100
	while looking and safe_number > 0: 
		safe_number -= 1
		await get_tree().create_timer(0.25).timeout
		if ResourceLoader.exists(str(assets_folder,"/chat-gpt-boy-16.png")):
			looking = false
	assert(!looking, "Asset folder could not be created.")
	#endregion
	
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
	diag_inform.confirmed.connect(func ():
		if editor_fs:
			editor_fs.scan_sources()
			#editor_fs.scan()
		, CONNECT_ONE_SHOT)
	diag_inform.show()
	
	
func generate_vn_resource() -> BVN_VisualNovel:
	var data_path :String = BVN_Settings.setup_data_folder
	var novel := BVN_VisualNovel.new()
	
	var girl := BVN_CharacterSheet.new()
	girl.display_name = "girl"
	novel.characters.append(girl)
	
	var boy := BVN_CharacterSheet.new()
	boy.display_name = "boy"
	novel.characters.append(boy)
	

	var file_name:String = "bvn_main_novel"
	var file_path:String = "%s/%s.tres" % [data_path,file_name]
	
	var err = ResourceSaver.save(novel,file_path)
	novel.take_over_path(file_path)
	assert(err == OK, error_string(err))
	return novel

var test = preload("res://assets/chat-gpt-boy-16.png")
func generate_vn_main_scene(vn_resource:BVN_VisualNovel) -> PackedScene:
	var data_path :String = BVN_Settings.setup_data_folder
	var file_name:String = "bvn_main_scene"
	var file_path:String = "%s/%s.tscn" % [data_path,file_name]
	
	var root_node:Node = novel_template_packed_scene.instantiate()
	root_node.name = "BVNI Root Node"
	
	var new_assets_dir = BVN_Settings.setup_images_folder
	for sprite2d:Sprite2D in BdbSelect.children_by_type_recursive(root_node, Sprite2D):
		var texture_file_name := sprite2d.texture.resource_path.get_file()
		var texture_file_path := str(new_assets_dir,"/",texture_file_name)
		
		var response := BVNInternal.find_resource(texture_file_path)
		if response[0] == OK:
			sprite2d.texture = response[1]
	
	var bvn_engine:BVN_Engine = BdbSelect.child_by_type_recursive(root_node, BVN_Engine)
	bvn_engine.visual_novel = vn_resource
	
	var new_packed := PackedScene.new()
	new_packed.pack(root_node)

	ResourceSaver.save(new_packed, file_path)
	new_packed.take_over_path(file_path)
	return new_packed
	
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
