extends Timer

class_name BdbDebounce

var debounce_secs:float

var params_array:Array


func _init(secs = 1) -> void:
	debounce_secs = secs
	autostart = false
	time_left
	one_shot = true
	
func cb(callable:Callable):
	timeout.connect(func (): callable.callv(params_array))
	return self

func handle(...args:Array):
	params_array = args
	stop()
	start(debounce_secs)
	

func cb_0(callable:Callable):
	printerr("@@ cb_0 deprecated, use cb")
	timeout.connect(callable)
	return cb_0_callback
	
func cb_0_callback():
	printerr("@@ cb_0 deprecated, use cb")
	stop()
	start(debounce_secs)

func cb_1_callback(param):
	printerr("@@ cb_0 deprecated, use cb")
	params_array = [param]
	stop()
	start(debounce_secs)
