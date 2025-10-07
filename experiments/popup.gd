@tool
extends EditorScript

func _run():
	BVNInternal_Notif.toast("hello")
	
func test1():
	var button := Button.new()
	button.text = "asdasd" 
	#button.z_index = 9999
	#button.custom_minimum_size = Vector2(120,75)
	
	#EditorInterface.get_
	
	button.pressed.connect(func ():
		if is_instance_valid(button):
			button.queue_free()
		,CONNECT_ONE_SHOT)
		
	#var main := EditorInterface.get_base_control()
	var main := EditorInterface.get_editor_viewport_2d().get_parent().get_parent()
	#var main := EditorInterface.get_editor_toaster()
	#origin.add_child(button)
	main.add_child(button)
	main.get_tree().create_timer(5).timeout.connect(func ():
		if is_instance_valid(button):
			button.queue_free()
		)
	button.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	button.position -= Vector2(20,20)
	
	
