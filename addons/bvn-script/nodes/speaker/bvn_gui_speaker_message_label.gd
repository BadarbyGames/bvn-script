@tool
extends BVN_RichTextLabel

## This label is synced with the current speaker's dialogue.
class_name BVN_GuiSpeakerMessageBox

@export var character:BVN_CharacterSheet
@export var is_animated:bool = true
@export var is_bleep_voiced:bool = true

var speed_msec:int = 0: # No delay
	set(v):
		speed_msec = v
		if text_synchronizer:
			text_synchronizer.speed_msec = speed_msec
			
var text_synchronizer:BVN_SynchronizedTextVM
func _init() -> void:
	tree_entered.connect(func ():
		bbcode_enabled = true
		text_synchronizer = BVN_SynchronizedTextVM.new()
		text_synchronizer.target_node = self
		text_synchronizer.sync_mode = BVN_SynchronizedTextVM.MODE_SPEAKER_MESSAGE
		add_child(text_synchronizer, false, Node.INTERNAL_MODE_FRONT))
	tree_exited.connect(func ():
		if is_instance_valid(text_synchronizer):
			text_synchronizer.queue_free())
		
func _get_configuration_warnings() -> PackedStringArray:
	if text:
		return ["This field's text will be overwritten by the engine."]
	return []
