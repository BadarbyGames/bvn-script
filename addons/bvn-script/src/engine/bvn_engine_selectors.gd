class_name BVN_EngineSelectors

			
static func find_bvn_scene_ancestor(node:Node) -> BVN_Scene:
	if node is BVN_Scene:
		return node
	elif node == null or node == node.owner:
		return null
	return find_bvn_scene_ancestor(node.get_parent())

static func find_bvn_scene_set_ancestor(node:Node) -> BVN_SceneSet:
	if node is BVN_SceneSet:
		return node
	elif node == node.owner:
		return node.owner as BVN_SceneSet
	var parent:Node = node.get_parent()
	if parent:
		return find_bvn_scene_set_ancestor(parent)
	return null


static func find_next_scene(scene):
	return _find_next_scene_downward(scene, 1000, scene)
	
static func _find_next_scene_downward(node:Node, safe_recursion, source_node):
	assert(safe_recursion, "BROKEN")
	var result:BVN_Scene = null
	
	if (node is BVN_Scene) and (node != source_node): 
		return node
	elif node == node.get_tree().root:
		return null
	
	# Check downwards
	var child = node.get_child(0) if node.get_child_count() else null
	if child:
		result = _find_next_scene_downward(child, safe_recursion, source_node)
		if result: return result
		
	# Check sideway
	var sibling = BdbSelect.next_sibling(node)
	if sibling:
		result = _find_next_scene_downward(sibling, safe_recursion, source_node)
		if result: return result
	
	# Check diagonal
	var parent = node.get_parent()
	var parent_sibling = BdbSelect.next_sibling(parent)
	if parent_sibling:
		result = _find_next_scene_downward(parent_sibling.get_child(0), safe_recursion, source_node)
	
	return result
