class_name BVN_EngineSelectors

			
static func find_bvn_page_ancestor(node:Node) -> BVN_Page:
	if node is BVN_Page:
		return node
	elif node == null or node == node.owner:
		return null
	return find_bvn_page_ancestor(node.get_parent())

static func find_bvn_chapter_ancestor(node:Node) -> BVN_Chapter:
	if node is BVN_Chapter:
		return node
	elif node == node.owner:
		return node.owner as BVN_Chapter
	var parent:Node = node.get_parent()
	if parent:
		return find_bvn_chapter_ancestor(parent)
	return null


static func find_next_page(scene):
	return _find_next_page_downward(scene, 1000, scene)
	
static func _find_next_page_downward(node:Node, safe_recursion, source_node):
	assert(safe_recursion, "BROKEN")
	var result:BVN_Page = null
	
	if (node is BVN_Page) and (node != source_node): 
		return node
	elif node == node.get_tree().root:
		return null
	
	# Check downwards
	var child = node.get_child(0) if node.get_child_count() else null
	if child:
		result = _find_next_page_downward(child, safe_recursion, source_node)
		if result: return result
		
	# Check sideway
	var sibling = BdbSelect.next_sibling(node)
	if sibling:
		result = _find_next_page_downward(sibling, safe_recursion, source_node)
		if result: return result
	
	# Check diagonal
	var parent = node.get_parent()
	var parent_sibling = BdbSelect.next_sibling(parent)
	if parent_sibling:
		result = _find_next_page_downward(parent_sibling.get_child(0), safe_recursion, source_node)
	
	return result
