extends Node

class_name BVNInternal_CmdSessionApi

func save(file_name:String = &""):
	var payload := {}
	if file_name: payload[&"file_name"] = file_name
	BVN_EventBus.on_request_save_session.emit(payload)
