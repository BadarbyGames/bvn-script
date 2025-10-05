extends AudioStreamPlayer2D

## Audio2D that synchronizes bleep sounds with the message display
class_name BVN_GuiSpeakerBleeps

func _init() -> void:
	tree_entered.connect(func ():
		BVN_EventBus.on_engine_demand_speaker.connect(play_bleep)
		)
	tree_exited.connect(func ():
		BVN_EventBus.on_engine_demand_speaker.disconnect(play_bleep)
		)
		
func play_bleep(speaker:BVN_CharacterSheet, message:String):
	if speaker.voice_bleeps:
		stream = speaker.voice_bleeps.pick_random()
		play()
