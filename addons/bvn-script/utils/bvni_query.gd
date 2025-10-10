class_name BVNInternal_Query

static var tree:SceneTree:
	get: return Engine.get_main_loop()

static var engine:BVN_Engine:
	get: 
		return tree.get_first_node_in_group(BVNInternal_Tags.ENGINE)
	
static var engine_session:BVNInternal_SessionService:
	get: return tree.get_first_node_in_group(BVNInternal_Tags.ENGINE_SESSION)

static var variables:BVN_Variables:
	get: return tree.get_first_node_in_group(BVNInternal_Tags.ENGINE_VARS)

static var editor_audio:BVNInternal_EditorAudio:
	get: return tree.get_first_node_in_group(BVNInternal_Tags.EDITOR_AUDIO)

static var hotspots:Array[BVN_GuiActionHotspot]:
	get:
		var tmp:= tree.get_nodes_in_group(BVNInternal_Tags.TOOL_HOTSPOT)
		var ary:Array[BVN_GuiActionHotspot] 
		ary.assign(tmp)
		return ary

static var editor_notif:
	get: return tree.get_first_node_in_group(BVNInternal_Tags.EDITOR_NOTIF)
