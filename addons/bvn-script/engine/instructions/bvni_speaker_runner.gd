extends Node

class_name BVNInternal_SpeakerRunner

var visual_novel:BVN_VisualNovel
var speaker:BVN_CharacterSheet
var text:Dictionary[String,String] = {
	"current": "",
	"target": "",
}
var is_animated:bool = true

var speed_msec:int = 0: # No delay
	set(v):
		throttler.threshold = v
		speed_msec = v
		
var is_completed :bool:
	get: return bbcode_root and (bbcode_root.get(&"is_completed",false)) 

var bbcode_root:Dictionary	
func load_ast_node(ast_node:Bvn_AstNode, vars:Dictionary):
	var params := ast_node.text.split(":")
	var param_char := params[0].strip_edges()
	var param_text := params[1].strip_edges()
	var character := visual_novel.find_character_by_name(param_char)
	assert(character, "Unknown character %s" % param_char)
	
	text.current = ""
	text.current = param_text
	text.target = param_text
	# process multiline text
	for child in ast_node.children:
		text.target += &"\n" + child.text
	text.target = text.target.format(vars, &"{{_}}")
	
	bbcode_root = BVNInternal_BBCodeParser.parse(text.target)
	if not is_animated:
		bbcode_root.set(&"is_completed",true)
		bbcode_root.set(&"value",param_text)
	
	speaker = character
	throttler.threshold = speed_msec
	
## Begins the animation. 
func run():
	# In unit tests, this function is not called because we want to test it frame by frame
	BVN_EventBus.on_request_lock_engine.emit({ "source": self })
	BdbSig.sig_conn(
		BVN_EventBus.on_request_next_engine_action, 
		flush_all_text, 
		CONNECT_ONE_SHOT)
	
	set_process(true)

func _on_load_callback(..._unused:Array):
	flush_all_text()
	# attempt to unlock - incase, there was any
	BVN_EventBus.on_request_unlock_engine.emit({ "source": self })
	

func flush_all_text():
	BdbSig.sig_disconn(BVN_EventBus.on_request_next_engine_action, flush_all_text)
		
	if !is_completed:
		text.current = text.target
		BVN_EventBus.on_engine_demand_speaker.emit(speaker, text.current.strip_edges())
	set_process(false)
	BVN_EventBus.on_request_unlock_engine.emit({ "source": self })
	

func watch_speedmsec() -> void:
	speed_msec = ProjectSettings.get_setting("BVN/dialogue/text_speed", 0)
	
func _enter_tree() -> void:
	watch_speedmsec()
	ProjectSettings.settings_changed.connect(watch_speedmsec)
	BVN_EventBus.on_engine_demand_load.connect(_on_load_callback)
	
func _exit_tree() -> void:
	ProjectSettings.settings_changed.disconnect(watch_speedmsec)
	BVN_EventBus.on_engine_demand_load.disconnect(_on_load_callback)

var throttler := BdbThrottleByMsec.new(0)
func _process(delta: float) -> void:
	if speaker and throttler.apply():
		move_to_next()
		
## Moves the cursor to the next letter in the text series. Returns true completed
func move_to_next() -> bool:
	if not is_completed:
		var result := get_text(bbcode_root)
		text.current = result.strip_edges()
		
		BVN_EventBus.on_engine_demand_speaker.emit(speaker, text.current.strip_edges())
		if is_completed:
			flush_all_text()
			return true
		return false
	return true

var IS_WIP = 0
var IS_COMPLETED_PENDING = 1	
var IS_COMPLETED_CONFIRMED = 2
func get_text(bbnode:Dictionary) -> String:
	var value:String = bbnode.get(&"value","")
	if bbnode.get(&"is_completed", IS_WIP): 
		return value
	elif bbnode.tag == &"text":
		var index:int = bbnode.get(&"progress_index", 0) + 1
		
		bbnode.set(&"progress_index", index)
		if index == value.length():
			bbnode.set(&"is_completed", IS_COMPLETED_PENDING)
			
	
		return value.substr(0, index)
	else:
		var final_text = ""
		if bbnode.children:
			for child:Dictionary in bbnode.children:
				final_text += get_text(child)
				
				# if child is NOT complete, we dont continue, because
				# we should stop at the current place its being displayed
				var completed_state:int = child.get(&"is_completed", 0)
				match completed_state:
					IS_WIP: break
					IS_COMPLETED_PENDING: 
						child.set(&"is_completed", IS_COMPLETED_CONFIRMED)
						break
					IS_COMPLETED_CONFIRMED:
						if bbnode.children[-1] == child: # is last child
							bbnode.set(&"is_completed", IS_COMPLETED_CONFIRMED)
						continue
		if bbnode.tag == &"root":
			final_text = final_text
		else:
			var starting_tag :String = bbnode.tag
			for attr in bbnode.attr:
				var attr_val:String = bbnode.attr[attr]
				if attr == starting_tag: 
					starting_tag += '=%s' % attr_val
				else:
					starting_tag += ' %s="%s"' % [attr,attr_val]
				
			var ending_tag :String = bbnode.tag
			
			final_text = ("[%s]%s[/%s]" % [starting_tag,final_text,ending_tag])
		bbnode.set(&"value", final_text) # propagate changes above
		return final_text
		
	
