extends Node

class_name BVNInternal_SessionService

var session_data:Dictionary = {
	&"file_name": "slot_1"
}

func _enter_tree() -> void:
	BVN_EventBus.on_request_save_session.connect(cb_save_game)
	BVN_EventBus.on_request_load_session.connect(cb_load_game)
	
func _exit_tree() -> void:
	BVN_EventBus.on_request_save_session.disconnect(cb_save_game)
	BVN_EventBus.on_request_load_session.disconnect(cb_load_game)
	
func cb_save_game(dict:Dictionary): 
	if dict.has("file_name"):
		session_data.file_name = dict.file_name
	assert(session_data.file_name, "Session has no file name")
	return save_game(session_data.file_name)
func cb_load_game(dict:Dictionary): 
	if dict.has("file_name"):
		session_data.file_name = dict.file_name
	return load_game(session_data.file_name)

## Returns the data saved into the file
func save_game(file_name:String, save_data = {}) -> Dictionary:
	var file_path := "user://save/%s.save" % file_name

	# Ensure directory always exists
	DirAccess.open("user://").make_dir_recursive("user://save")

	var save_file = FileAccess.open(file_path, FileAccess.WRITE)
	assert(FileAccess.get_open_error() == OK)
	BVN_EventBus.on_engine_demand_save.emit(save_data)
	var json_string = JSON.stringify(save_data)

	# Store the save dictionary as a new line in the save file.
	save_file.store_line(json_string)
	print("Saved game at %s " % file_path)
	return save_data

# Note: This can be called from anywhere inside the tree. This function
# is path independent.
func load_game(file_name:String = session_data.get(&"file_name","")) -> Dictionary:
	var file_path := "user://save/%s.save" % file_name
	var save_data:Dictionary
	if FileAccess.file_exists(file_path):
		var file = FileAccess.open(file_path, FileAccess.READ)
		var content = file.get_as_text()
		save_data = JSON.parse_string(content)
		BVN_EventBus.on_engine_demand_load.emit(save_data)
		print("Loaded save file from: %s " % file_name)
	else:
		save_data = {}
	return save_data
