@tool
@icon("../../../icons/godot_button.svg")
extends PanelContainer

class_name BVN_TextInputModal

		
## This is the name of the variable that the answer will be stored in
@export var variable_name:String
@export var lock_source:String
## The text to display to the player
@export_multiline var question_label:String = "Placeholder Question"

## Used for tying transaction operations together
var transaction_id:String
var text_input:LineEdit 

func _init() -> void:
	tree_entered.connect(func ():
		force_update_options.call_deferred()
		)
	tree_exited.connect(func ():
		BdbIdioms.free_children(self)
		)

func force_update_options():
	if !theme:
		theme = load(BVN_RootDir.get_dir() +  "/theme/bvn_default_theme.tres")

	BdbIdioms.free_children(self)

	var mbox := MarginContainer.new()
	mbox.set("theme_override_constants/margin_left",theme.get("MarginContainer/constants/margin_left") + 36)
	mbox.set("theme_override_constants/margin_right",theme.get("MarginContainer/constants/margin_right") + 36)
	mbox.set("theme_override_constants/margin_top",theme.get("MarginContainer/constants/margin_top") + 12)
	mbox.set("theme_override_constants/margin_bottom",theme.get("MarginContainer/constants/margin_bottom") + 12)
	BVNInternal.add_child(self, mbox)
	
	#mbox.set_anchors_preset(Control.PRESET_FULL_RECT, true)
	
	var vbox := VBoxContainer.new()
	BVNInternal.add_child(mbox, vbox)
	#vbox.set_anchors_preset(Control.PRESET_FULL_RECT, true)
	
	if question_label:
		var text_label := BVN_RichTextLabel.new()
		text_label.autowrap_mode = TextServer.AUTOWRAP_OFF
		text_label.fit_content = true
		text_label.text = question_label
		BVNInternal.add_child(vbox, text_label)
		
	
	var input := LineEdit.new()
	input.placeholder_text = "input text"
	input.custom_minimum_size = Vector2(300,32)
	input.size_flags_vertical = Control.SIZE_EXPAND_FILL
	BVNInternal.add_child(vbox, input)
	input.text_submitted.connect(close_modal)
	text_input = input
	
	var btn := Button.new()
	btn.text = "Submit"
	btn.name = "submit"
	btn.pressed.connect(close_modal)
	BVNInternal.add_child(vbox, btn)
	
	var vm := BVN_InputVM.new()
	vm.variable_name = variable_name
	vm.target_node = input
	vm.retarget(input)
	
	
			
func close_modal(..._dummy_args:Array):
	queue_free()
	if lock_source:
		BVN_EventBus.on_request_unlock_engine.emit({ &"source": lock_source })
	BVN_EventBus.on_request_next_engine_action.emit()
