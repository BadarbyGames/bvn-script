@icon("../../../../icons/gear.svg")
@tool
extends BVN_VM

## This ViewModel takes in a text type control and in synchronizes the text content
## With the current speaker set by the engine
class_name BVN_SynchronizedTextVM

@export var character:BVN_CharacterSheet
@export var is_animated:bool = true
@export var is_bleep_voiced:bool = true
@export var target_node:Node
@export var sync_mode:SyncMode

enum SyncMode {
	UNSPECIFIED = 0,
	SPEAKER_NAME,
	SPEAKER_MESSAGE
}

const MODE_SPEAKER_NAME  = SyncMode.SPEAKER_NAME
const MODE_SPEAKER_MESSAGE  = SyncMode.SPEAKER_MESSAGE


var text:String:
	get: return target_node.get("text")
	set(v): target_node.set("text",v)

func _init() -> void:
	tree_entered.connect(func ():
		BVN_EventBus.on_engine_demand_speaker.connect(update_text)
		)
	tree_exited.connect(func ():
		BVN_EventBus.on_engine_demand_speaker.disconnect(update_text)
		)
		
func update_text(speaker:BVN_CharacterSheet, message:String):
	match sync_mode:
		SyncMode.SPEAKER_NAME:
			text = speaker.display_name
		SyncMode.SPEAKER_MESSAGE:
			text = message
		_:
			BdbError.bad_state("Please specify a sync_mode")
		
func _get_configuration_warnings() -> PackedStringArray:
	if text:
		return ["Do not hard-code text. This field is overwritten."]
	return []
