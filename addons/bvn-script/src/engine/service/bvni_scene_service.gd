@tool
extends Node

class_name BVNInernal_ManagedNodeService

var pages:Array[Node]:
	get:
		var pages:Array[Node]= []
		for page in get_tree().get_nodes_in_group(BVNInternal_Tags.NODE_MANAGED):
			if page.has_signal("visibility_changed"):
				pages.append(page)
		return pages
var page_context:BVNInternal_SceneExecutionContext

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
	save_data.page = {
		"page_path": page_context.page.get_page_path()
	}
func _on_engine_demand_load(save_data:Dictionary):
	if not pages:
		printerr("No pages found")
		return
				
	var page_path:String = save_data.get("page", {}).get("page_path")	
	if page_path:
		page_context.page = find_by_page_path(page_path)
		if not page_context.page:
			printerr("Unable to load saved page(%s)" % page_path)
	if not page_context.page:
		page_context.page = pages[0]
	
func mk_page_context() -> BVNInternal_SceneExecutionContext:
	page_context = BVNInternal_SceneExecutionContext.new()
	return page_context

func find_by_page_path(page_path:String):
	for page:BVN_Page in pages:
		if page.get_page_path() == page_path: return page
		
var page_history:Array[Node] = []
func toggle_scene(page_or_node:Node):
	var visited := {}
	var hidden_node_names :Array[String] = []
	
	_toggle_page(page_or_node, true)
	visited[page_or_node] = true
	
	for scene_source in [pages,page_history]:
		for other_page in scene_source:
			if visited.has(other_page): continue
			visited[other_page] = true
			
			if other_page.visible != false:
				_toggle_page(other_page, false)
				
				 # hidden_node_names is only used in the editor
				if Engine.is_editor_hint():
					hidden_node_names.append(other_page.name)

	if Engine.is_editor_hint(): 
		BVNInternal_Notif.toast("'%s' activated" % page_or_node.name)
		if hidden_node_names:
			BVNInternal_Notif.toast("'%s' is hidden" % ",".join(hidden_node_names))
			
func _toggle_page(node:Node, is_visible:bool):
	node.set_process(is_visible)
	node.set_physics_process(is_visible)
	node.visible = is_visible
	
	# Canvas_Layer has a seperate control, so we also toggle that
	for canvas_layer:CanvasLayer in BdbSelect.children_by_type_recursive(node, CanvasLayer):
		canvas_layer.visible = is_visible

func push_page(page_or_node:Node):
	page_history.append(page_or_node)
	toggle_scene(page_or_node)

func pop_page():
	var page_or_node:Node = page_history.pop_front()
	toggle_scene(page_or_node)

		
