extends RefCounted

class_name BdbThrottleByMsec

var last_apply  := 0
var threshold:int

func _init(new_threshold:int) -> void:
	threshold = new_threshold
	Time.get_ticks_msec()
	
func apply() -> bool:
	var curr_time := Time.get_ticks_msec()
	if curr_time >= (last_apply + threshold):
		last_apply = curr_time
		return true
	return false
