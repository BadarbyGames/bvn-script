@tool
extends Node

#region Events emitted from COMPONENTS -> Engine
## Requests the engine to not accept any input until an equivalent
## unlock has been called by some external component
signal on_request_activate_scene(config:Dictionary)

## Requests the engine to not accept any input until an equivalent
## unlock has been called by some external component
signal on_request_lock_engine(config:Dictionary)

## Requests the engine to remove an equivalent lock so it can
## begin to accept inputs again
signal on_request_unlock_engine(config:Dictionary)

## Requests the engine to update a variable
signal on_request_update_var(config:Dictionary)

## Requests the engine to show a modal with questions and save 
## the input to a configured variable.
signal on_request_ask_question(config:Dictionary)

## Requests the engine to move on to the next instruction on the street
signal on_request_next_engine_action()

## Requests the engine to save the current session. The engine
## then emits an `on_engine_demand_save` event to any relevant components
signal on_request_save_session(config: Dictionary)
signal on_request_load_session(config: Dictionary)



#endregion

#region Events emitted from ENGINE -> Components
signal on_engine_demand_speaker(speaker:BVN_CharacterSheet, message:String)
signal on_engine_demand_save(save_data: Dictionary)
signal on_engine_demand_load(save_data: Dictionary)
#endregion



#region INTERNAL EDITOR SIGNALS - DO NOT USE
signal on_editor_attached() # Run when setup is called. Sub components should listen to this instead
signal on_editor_scene_change(scene_root:Node)
signal on_editor_scene_inspect(scene:BVN_Scene)
signal on_editor_variable_add(variable:BVN_Var)
signal on_editor_variable_rm(variable:BVN_Var)
signal on_editor_variable_rename(variable:BVN_Var, from:String, to:String)
signal on_editor_audio_play(audio_stream_player:AudioStreamPlayer)
#endregion

func debug_get_all_signals():
	var array := []
		
	for prop in get_signal_list():
		var sig_name:String = prop.name
		if sig_name.begins_with("on_engine") \
			or sig_name.begins_with("on_editor") \
			or sig_name.begins_with("on_request"):
				array.append_array(get(sig_name).get_connections())
	
	return array
		
