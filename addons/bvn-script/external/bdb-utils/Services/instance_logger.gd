extends Object

class_name InstanceLogger

const LEVEL_FATAL = 0
const LEVEL_ERROR = 1
const LEVEL_WARN = 2
const LEVEL_INF = 3
const LEVEL_DEBUG = 4

var source:String

## Log level as defined in kkSettings/log_level
var log_level:
	get: return ProjectSettings.get(&"kkSettings/log_level")

# Note: fatal is lowest level, no need for condition
#var is_atleast_fatal:bool:
#	get: return LEVEL_FATAL >= log_level
var is_atleast_error:bool:
	get: return LEVEL_ERROR <= log_level
var is_atleast_warn:bool:
	get: return LEVEL_WARN <= log_level
var is_atleast_info:bool:
	get: return LEVEL_INF <= log_level
var is_atleast_debug:bool:
	get: return LEVEL_DEBUG <= log_level

func _init(_source) -> void:
	source = _source

func _log(prefix, a = BDB_UNDEF, b = BDB_UNDEF, c = BDB_UNDEF, d = BDB_UNDEF):
	var to_print = [prefix + ": "]
	if BDB_UNDEF.is_defined(a): to_print.append_array([&" ",a])
	if BDB_UNDEF.is_defined(b): to_print.append_array([&" ",b])
	if BDB_UNDEF.is_defined(c): to_print.append_array([&" ",c])
	if BDB_UNDEF.is_defined(d): to_print.append_array([&" ",d])
	print.callv(to_print)
	
func fatal(correlation_id, a, b = BDB_UNDEF, c = BDB_UNDEF, d = BDB_UNDEF):
	if correlation_id == null:
		correlation_id = Time.get_ticks_msec()
	
	var prefix = str("[FATAL pid:", get_peer_id()," source: ",source, " cid: ",correlation_id,"]")
	_log(prefix,a,b,c,d)
	for ln in get_stack():
		_log(prefix,str(ln.source," ",ln.function,":",ln.line))
	
func error(correlation_id, a, b = BDB_UNDEF, c = BDB_UNDEF, d = BDB_UNDEF):
	if !is_atleast_error: return
	if correlation_id == null:
		correlation_id = Time.get_ticks_msec()
	
	var prefix = str("[ERROR pid:", get_peer_id()," source: ",source, " cid: ",correlation_id,"]")
	_log(prefix,a,b,c,d)
	for ln in get_stack():
		_log(prefix,str(ln.source," ",ln.function,":",ln.line))

func warn(correlation_id, a, b = BDB_UNDEF, c = BDB_UNDEF, d = BDB_UNDEF):
	if !is_atleast_warn: return
	if correlation_id == null:
		correlation_id = Time.get_ticks_msec()
	_log(str("[WARN pid:", get_peer_id()," source: ",source, " cid: ",correlation_id,"]"), a,b,c,d)
		
func info(correlation_id, a, b = BDB_UNDEF, c = BDB_UNDEF, d = BDB_UNDEF):
	if !is_atleast_info: return
	if correlation_id == null:
		correlation_id = Time.get_ticks_msec()
	_log(str("[INFO pid:", get_peer_id()," source: ",source, " cid: ",correlation_id,"]"), a,b,c,d)
		
func debug(correlation_id, a, b = BDB_UNDEF, c = BDB_UNDEF, d = BDB_UNDEF):
	if !is_atleast_debug: return
	
	if correlation_id == null:
		correlation_id = Time.get_ticks_msec()
	_log(str("[DEBUG pid:", get_peer_id()," source: ",source, " cid: ",correlation_id,"]"), a,b,c,d)

func get_peer_id():
	if Engine.is_editor_hint():
		return "@ editor"
	else:
		return Engine.get_main_loop().get_multiplayer().get_unique_id()
