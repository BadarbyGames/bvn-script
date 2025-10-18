extends Node

class_name BdbFs

pass

#func ensure_dir(path: String) -> void:	
	#var dir := DirAccess.open("res://")
	#if dir:
		#var parts := path.trim_prefix("res://").split("/")
		#var current := "res://"
		#for part in parts:
			#if part == "":
				#continue
			#current += part + "/"
			#if not DirAccess.dir_exists_absolute(current):
				#DirAccess.make_dir_absolute(current)
				
#func copy_folder(src_path: String, dst_path: String) -> void:
	#var src_dir := DirAccess.open(src_path)
	#if src_dir == null:
		#push_error("Failed to open source folder: %s" % src_path)
		#return
#
	## Ensure destination folder exists
	#DirAccess.make_dir_recursive_absolute(dst_path)
#
	#src_dir.list_dir_begin()
	#var file_name := src_dir.get_next()
	#while file_name != "":
		#if file_name.begins_with(".") or file_name.ends_with(".import"):  # skip hidden system entries
			#file_name = src_dir.get_next()
			#continue
#
		#var src_item_path := src_path.path_join(file_name)
		#var dst_item_path := dst_path.path_join(file_name)
#
		#if src_dir.current_is_dir():
			## Recursive copy for directories
			#copy_folder(src_item_path, dst_item_path)
		#else:
			## Copy file contents
			#var src_file := FileAccess.open(src_item_path, FileAccess.READ)
			#if src_file:
				#var data := src_file.get_buffer(src_file.get_length())
				#src_file.close()
#
				#var dst_file := FileAccess.open(dst_item_path, FileAccess.WRITE)
				#if dst_file:
					#dst_file.store_buffer(data)
					#dst_file.close()
				#else:
					#push_error("Failed to create file: %s" % dst_item_path)
			#else:
				#push_error("Failed to open file: %s" % src_item_path)
#
		#file_name = src_dir.get_next()
#
	#src_dir.list_dir_end()
