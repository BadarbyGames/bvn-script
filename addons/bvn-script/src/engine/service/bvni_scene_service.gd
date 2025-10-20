@tool
extends Node

class_name BVNInernal_ManagedNodeService

var scenes:Array[Node]:
	get:
		var scenes:Array[Node]= []
		for scene in get_tree().get_nodes_in_group(BVNInternal_Tags.NODE_MANAGED):
			if scene.has_signal("visibility_changed"):
				scenes.append(scene)
		return scenes
var scene_context:BVNInternal_SceneExecutionContext

func _enter_tree() -> void:
	BVN_EventBus.on_engine_demand_save.connect(_on_engine_demand_save)
	BVN_EventBus.on_engine_demand_load.connect(_on_engine_demand_load)
	BVN_EventBus.on_request_activate_scene.connect(_on_request_activate_scene)
		
func _exit_tree() -> void:
	BVN_EventBus.on_engine_demand_save.disconnect(_on_engine_demand_save)
	BVN_EventBus.on_engine_demand_load.disconnect(_on_engine_demand_load)
	BVN_EventBus.on_request_activate_scene.disconnect(_on_request_activate_scene)
	
func _on_request_activate_scene(dict:Dictionary):
	if dict.node.visible:
		toggle_scene(dict.node)
	
func _on_engine_demand_save(save_data:Dictionary):
	save_data.scene = {
		"scene_path": scene_context.scene.get_scene_path()
	}
func _on_engine_demand_load(save_data:Dictionary):
	if not scenes:
		printerr("No scenes found")
		return
				
	var scene_path:String = save_data.get("scene", {}).get("scene_path")	
	if scene_path:
		scene_context.scene = find_by_scene_path(scene_path)
		if not scene_context.scene:
			printerr("Unable to load saved scene(%s)" % scene_path)
	if not scene_context.scene:
		scene_context.scene = scenes[0]
	
func mk_scene_context() -> BVNInternal_SceneExecutionContext:
	scene_context = BVNInternal_SceneExecutionContext.new()
	return scene_context

func find_by_scene_path(scene_path:String):
	for scene:BVN_Page in scenes:
		if scene.get_scene_path() == scene_path: return scene
		
var scene_history:Array[Node] = []
func toggle_scene(scene_or_node:Node):
	var visited := {}
	var hidden_node_names :Array[String] = []
	
	_toggle_scene(scene_or_node, true)
	visited[scene_or_node] = true
	
	for scene_source in [scenes,scene_history]:
		for other_scene in scene_source:
			if visited.has(other_scene): continue
			visited[other_scene] = true
			
			if other_scene.visible != false:
				_toggle_scene(other_scene, false)
				
				 # hidden_node_names is only used in the editor
				if Engine.is_editor_hint():
					hidden_node_names.append(other_scene.name)

	if Engine.is_editor_hint(): 
		BVNInternal_Notif.toast("'%s' activated" % scene_or_node.name)
		if hidden_node_names:
			BVNInternal_Notif.toast("'%s' is hidden" % ",".join(hidden_node_names))
			
func _toggle_scene(node:Node, is_visible:bool):
	node.set_process(is_visible)
	node.set_physics_process(is_visible)
	node.visible = is_visible
	
	# Canvas_Layer has a seperate control, so we also toggle that
	for canvas_layer:CanvasLayer in BdbSelect.children_by_type_recursive(node, CanvasLayer):
		canvas_layer.visible = is_visible

func push_scene(scene_or_node:Node):
	scene_history.append(scene_or_node)
	toggle_scene(scene_or_node)

func pop_scene():
	var scene_or_node:Node = scene_history.pop_front()
	toggle_scene(scene_or_node)

		
