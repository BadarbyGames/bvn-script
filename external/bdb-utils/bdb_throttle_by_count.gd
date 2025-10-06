extends RefCounted

class_name BdbThrottleByCount

var count := 0
var threshold:int

func _init(new_threshold:int, count_start:int = 0) -> void:
	threshold = new_threshold
	count = count_start
	

func apply() -> bool:
	if threshold < count:
		count = 0
		return true
	count+=1
	return false
