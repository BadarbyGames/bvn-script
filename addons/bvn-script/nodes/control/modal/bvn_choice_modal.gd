@tool
@icon("../../../icons/godot_button.svg")
extends PanelContainer

class_name BVN_ChoiceModal

@export_multiline var question_label:String:
	set(v): 
		question_label = v
		
## This is the name of the variable that the answer will be stored in
@export var variable_name:String
@export var choices:Array[String] = ["add a choice"]:
	set(v):
		choices = v
		if Engine.is_editor_hint():
			force_update_options.call_deferred()

## Used for tying transaction operations together
var transaction_id:String
var lock_source:String


func _init() -> void:
	tree_entered.connect(func ():
		force_update_options()
		)
	tree_exited.connect(func ():
		BdbIdioms.free_children(self)
		)

func force_update_options():
	var ADD_CHILD_MODE:InternalMode = BVN_ProjectSettings.debug_add_child_mode
	var new_owner = get_tree().edited_scene_root if Engine.is_editor_hint() else owner
	if !theme:
		theme = load(BVN_RootDir.get_dir() +  "/theme/bvn_default_theme.tres")

	BdbIdioms.free_children(self)
	var mbox := MarginContainer.new()
	mbox.set("theme_override_constants/margin_left",theme.get("MarginContainer/constants/margin_left") + 36)
	mbox.set("theme_override_constants/margin_right",theme.get("MarginContainer/constants/margin_right") + 36)
	mbox.set("theme_override_constants/margin_top",theme.get("MarginContainer/constants/margin_top") + 12)
	mbox.set("theme_override_constants/margin_bottom",theme.get("MarginContainer/constants/margin_bottom") + 12)
	add_child(mbox, true, ADD_CHILD_MODE)
	mbox.owner = new_owner
	
	var vbox := VBoxContainer.new()
	mbox.add_child(vbox, true, ADD_CHILD_MODE)
	vbox.owner = new_owner
	
	if question_label:
		var text_label := BVN_RichTextLabel.new()
		text_label.autowrap_mode = TextServer.AUTOWRAP_OFF
		text_label.fit_content = true
		text_label.text = question_label
		vbox.add_child(text_label)
		text_label.owner = new_owner
	
	if choices:
		for choice in choices:
			var btn := Button.new()
			btn.text = choice
			btn.name = "choice_" + choice
			btn.size_flags_vertical = Control.SIZE_EXPAND_FILL
			vbox.add_child(btn, true, ADD_CHILD_MODE)
			btn.owner = new_owner
			
			var vm := BVN_ChoiceButtonVM.new()
			vm.name = "BVN_ChoiceButtonVM"
			vm.view = btn
			vm.value = choice
			vm.variable_name = variable_name
			vm.transaction_id = transaction_id
			btn.add_child(vm, true, ADD_CHILD_MODE)
			btn.pressed.connect(close_modal)
			vm.owner = new_owner
			
func close_modal():
	queue_free()
	BVN_EventBus.on_request_unlock_engine.emit({ &"source": lock_source })
	BVN_EventBus.on_request_next_engine_action.emit()
