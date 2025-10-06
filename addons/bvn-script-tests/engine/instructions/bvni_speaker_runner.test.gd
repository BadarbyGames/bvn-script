extends BVNInternal_GutTest

var parser := BVN_ScriptParser.new()
var vn := BVN_VisualNovel.new()
var runner := BVNInternal_SpeakerRunner.new()
	
func before_all():
	add_child(runner)
	var char1 = BVN_CharacterSheet.new()
	char1.display_name = "Al"
	var char2 = BVN_CharacterSheet.new()
	char2.display_name = "Marie"
	var char3 = BVN_CharacterSheet.new()
	char3.display_name = "Mei"
	vn.characters = [char1,char2,char3]
	
	runner.is_animated = true
	runner.visual_novel = vn

func after_all():
	runner.free()
	
func test_cleans_signal_on_exit():
	assert_cleanup_signal(BVNInternal_SpeakerRunner.new())

#region BBCODE
func test_regular_text():
	var ast_node:= parser.parse_bvn_script(
"""\
al: hello\
"""	)
	runner.load_ast_node(ast_node.children[0], {})
	
	runner.move_to_next()
	assert_eq(runner.text.current, "h")
	
	runner.move_to_next()
	assert_eq(runner.text.current, "he")
	
	runner.move_to_next()
	runner.move_to_next()
	runner.move_to_next()
	assert_eq(runner.text.current, "hello")
	
func test_bbcode_wrapped_simple():
	var ast_node:= parser.parse_bvn_script(
"""\
al: [b]foo[/b]\
"""	)
	runner.load_ast_node(ast_node.children[0], {})
	
	assert_text_yields(1, "[b]f[/b]")
	assert_text_yields(1, "[b]fo[/b]")
	assert_text_yields(1, "[b]foo[/b]")
	
func test_bbcode_wrapped_with_regular_text():
	var ast_node:= parser.parse_bvn_script(
"""\
marie: hello [b]world[/b]\
"""	)
	runner.load_ast_node(ast_node.children[0], {})
	
	assert_text_yields(1, "h")
	assert_text_yields(1, "he")
	assert_text_yields(1, "hel")
	assert_text_yields(1, "hell")
	assert_text_yields(1, "hello")
	assert_text_yields(1, "hello") # final output is stripped()
	
	assert_text_yields(1, "hello [b]w[/b]")
	assert_text_yields(4, "hello [b]world[/b]")
	
func test_multi_layer_bbcode():
	var ast_node:= parser.parse_bvn_script(
"""\
marie: I'm [b]a little [i]teapot[/i] short and[/b] stout.\
"""	)
	runner.load_ast_node(ast_node.children[0], {})
	
	assert_text_yields(3, "I'm") 
	assert_text_yields(1, "I'm") # final output is stripped()
	assert_text_yields(1, "I'm [b]a[/b]")
	assert_text_yields(8, "I'm [b]a little [/b]")
	assert_text_yields(1, "I'm [b]a little [i]t[/i][/b]")
	assert_text_yields(1, "I'm [b]a little [i]te[/i][/b]")
	assert_text_yields(4, "I'm [b]a little [i]teapot[/i][/b]")
	assert_text_yields(1, "I'm [b]a little [i]teapot[/i] [/b]")
	assert_text_yields(9, "I'm [b]a little [i]teapot[/i] short and[/b]")
	assert_text_yields(6, "I'm [b]a little [i]teapot[/i] short and[/b] stout")

func assert_text_yields(n:int, expected_text:String):
	move_x_times(n)
	assert_eq(runner.text.current, expected_text)

func move_x_times(n:int):
	runner.move_to_next()
	for i in (n-1):
		runner.move_to_next()
#endregion
