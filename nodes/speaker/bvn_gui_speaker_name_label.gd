@tool
extends BVN_Label

## This label is synced with the current dialogue being displayed.
## If a character is set, it is only synchronized with that character
class_name BVN_GuiSpeakerNameLabel

@export var character:BVN_CharacterSheet
@export var is_animated:bool = false

var speed_msec:int = 0: # No delay
	set(v):
		speed_msec = v
		if text_synchronizer:
			text_synchronizer.speed_msec = speed_msec

var text_synchronizer:BVN_SynchronizedTextVM
func _init() -> void:
	tree_entered.connect(func ():
		text_synchronizer = BVN_SynchronizedTextVM.new()
		text_synchronizer.target_node = self
		text_synchronizer.sync_mode = BVN_SynchronizedTextVM.MODE_SPEAKER_NAME
		add_child(text_synchronizer, false, Node.INTERNAL_MODE_FRONT)
		, CONNECT_ONE_SHOT)
	tree_exited.connect(func ():
		if is_instance_valid(text_synchronizer):
			text_synchronizer.queue_free()
		, CONNECT_ONE_SHOT)
		
func _get_configuration_warnings() -> PackedStringArray:
	if text:
		return ["This field will be overwritten."]
	return []
