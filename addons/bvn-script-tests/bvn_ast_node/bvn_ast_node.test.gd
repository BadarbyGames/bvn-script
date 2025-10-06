extends GutTest


func test_prev_and_next_sibling():
	var root := Bvn_AstNode.new()
	
	var child1 := root.add_child(Bvn_AstNode.new())
	var child2 := root.add_child(Bvn_AstNode.new())
	var child3 := root.add_child(Bvn_AstNode.new())
	
	assert_eq(child1.get_prev_sibling(), null)
	assert_eq(child2.get_prev_sibling(), child1)
	assert_eq(child3.get_prev_sibling(), child2)
	
	assert_eq(child1.get_next_sibling(), child2)
	assert_eq(child2.get_next_sibling(), child3)
	assert_eq(child3.get_next_sibling(), null)
	
func test_prev_node_wraps_to_parent():
	
	"""
	↳ a # (root) is prev of a1
		↳ a1 # prev node of a2
		↳ a2 # prev node of a2a
			↳a2a
	"""
	var a := Bvn_AstNode.new()
	var a1 := a.add_child(Bvn_AstNode.new())
	var a2 := a.add_child(Bvn_AstNode.new())
	var a2a := a2.add_child(Bvn_AstNode.new())
	
	assert_eq(a2a.get_prev_node(), a2)
	assert_eq(a2.get_prev_node(), a1)
	assert_eq(a1.get_prev_node(), a)
	assert_eq(a.get_prev_node(), null)
	
func test_next_node_wraps_to_neighbor():
	
	"""
	↳ a 
		↳ a1 # next node of a (root)
			↳a1a # next node of a1
		↳ a2
	"""
	var a := Bvn_AstNode.new()
	a.text = "a"
	var a1 := a.add_child(Bvn_AstNode.new())
	a1.text = "a1"
	var a1a := a1.add_child(Bvn_AstNode.new())
	a1a.text = "a1a"
	var a2 := a.add_child(Bvn_AstNode.new())
	a2.text = "a2"
	
	assert_eq(a.get_next_node(), a1)
	assert_eq(a1.get_next_node(), a1a)
	assert_eq(a1a.get_next_node(), a2)
	assert_eq(a2.get_next_node(), null)

func test_next_big_jump_forward():
	"""
	↳ a 
		↳ a1 
			↳a1a 
				↳ a1a1 
					↳ a1a1a
		↳ a2 # next node of a1a1
	"""
	var a := Bvn_AstNode.new()
	var a1 := a.add_child(Bvn_AstNode.new())
	var a1a := a1.add_child(Bvn_AstNode.new())
	var a1a1a := a1a.add_child(Bvn_AstNode.new())
	var a2 := a.add_child(Bvn_AstNode.new())
	a.text = "a"
	a1.text = "a1"
	a1a.text = "a1a"
	a1a1a.text = "a1a1a"
	a2.text = "a2"
	
	assert_eq(a1a1a.get_next_node(),a2)
