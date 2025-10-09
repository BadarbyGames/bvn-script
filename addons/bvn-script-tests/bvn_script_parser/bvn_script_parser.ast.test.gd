extends GutTest

var parser:BVN_ScriptParser
func before_each(): parser = BVN_ScriptParser.new()

func test_basic_linear_input():
	var input:String = \
"""\
spongebob: hi patrick
patrick: hi spongebob
: this is the narrator\
"""
	
	var output := parser.parse_bvn_script(input)
	
	assert_eq(-1 , output.depth, "Root must start at -1 (special case)")
	assert_eq(-1 , output.line_index, "Root must start at -1 (special case)")
	assert_eq(3, output.children.size(), "3 statements, 3 children")
	
	assert_eq("spongebob: hi patrick", output.children[0].text)
	assert_eq(0, output.children[0].depth)
	assert_eq(0, output.children[0].line_index)
	assert_eq(output, output.children[0].parent)
	
	assert_eq("patrick: hi spongebob", output.children[1].text)
	assert_eq(0, output.children[1].depth)
	assert_eq(1, output.children[1].line_index)
	assert_eq(output, output.children[1].parent)
	
	assert_eq(": this is the narrator", output.children[2].text)
	assert_eq(0, output.children[2].depth)
	assert_eq(2, output.children[2].line_index)
	assert_eq(output, output.children[2].parent)
	
func test_nested():
	var input:String = \
"""\
speaker:
	nested a b c
	nested e f g
> command:
	newline a b c
	newline e f g
	newline h i j
if true:
	person a: hi opal
	person b: what do we always say?
elif true:
	person a: claire?
else:
	person z: hi\
"""
	var output := parser.parse_bvn_script(input)
	
	assert_eq(output.children.size(), 5)
	
	var speaker := output.children[0]
	assert_eq(speaker.type, Bvn_AstNode.TYPE_SPEAK)
	assert_eq(speaker.text, "speaker:")
	assert_eq(speaker.line_index, 0)
	assert_eq(speaker.children.size(), 2)
	assert_eq(speaker.children[0].text, "nested a b c")
	assert_eq(speaker.children[0].line_index, 1)
	assert_eq(speaker.children[1].text, "nested e f g")
	assert_eq(speaker.children[1].line_index, 2)
	
	var command := output.children[1]
	assert_eq(command.text, "> command:")
	assert_eq(command.type, Bvn_AstNode.TYPE_COMMAND)
	assert_eq(command.line_index, 3)
	assert_eq(command.children.size(), 3)
	assert_eq(command.children[0].text, "newline a b c")
	assert_eq(command.children[0].line_index, 4)
	assert_eq(command.children[1].text, "newline e f g")
	assert_eq(command.children[1].line_index, 5)
	assert_eq(command.children[2].text, "newline h i j")
	assert_eq(command.children[2].line_index, 6)
	
	var key_if := output.children[2]
	assert_eq(key_if.type, Bvn_AstNode.TYPE_IF)
	assert_eq(key_if.text, "if true:")
	assert_eq(key_if.line_index, 7)
	assert_eq(key_if.children.size(), 2)
	assert_eq(key_if.children[0].text, "person a: hi opal")
	assert_eq(key_if.children[0].line_index, 8)
	assert_eq(key_if.children[1].text, "person b: what do we always say?")
	assert_eq(key_if.children[1].line_index, 9)
	
	var key_elif := output.children[3]
	assert_eq(key_elif.type, Bvn_AstNode.TYPE_ELSE_IF)
	assert_eq(key_elif.text, "elif true:")
	assert_eq(key_elif.line_index, 10)
	assert_eq(key_elif.children.size(), 1)
	assert_eq(key_elif.children[0].text, "person a: claire?")
	assert_eq(key_elif.children[0].line_index, 11)
	
	var key_else := output.children[4]
	assert_eq(key_else.type, Bvn_AstNode.TYPE_ELSE)
	assert_eq(key_else.text, "else:")
	assert_eq(key_else.line_index, 12)
	assert_eq(key_else.children.size(), 1)
	assert_eq(key_else.children[0].text, "person z: hi")
	assert_eq(key_else.children[0].line_index, 13)
	
func test_nested_big_jumps():
	var input:String = \
"""\
if A:
	if AA:
		if AAA:
			if AAAA:
			elif AAAA:
else:
"""
	var output := parser.parse_bvn_script(input)
	
	assert_eq(output.children.size(), 2)
	assert_eq(output.children[0].text, "if A:")
	assert_eq(output.children[0].type, Bvn_AstNode.TYPE_IF)
	assert_eq(output.children[0].line_index, 0)
	assert_eq(output.children[1].text, "else:")
	assert_eq(output.children[1].type, Bvn_AstNode.TYPE_ELSE)
	assert_eq(output.children[1].line_index, 5, "Its at the end so last number")
	
	assert_eq(output.children[0].children[0].text, "if AA:")
	assert_eq(output.children[0].children[0].line_index,1)
	assert_eq(output.children[0].children[0].type, Bvn_AstNode.TYPE_IF)
	
	assert_eq(output.children[0].children[0].children[0].text, "if AAA:")
	assert_eq(output.children[0].children[0].children[0].type, Bvn_AstNode.TYPE_IF)
	assert_eq(output.children[0].children[0].children[0].line_index, 2)
	assert_eq(output.children[0].children[0].children[0].children[0].text, "if AAAA:")
	assert_eq(output.children[0].children[0].children[0].children[0].type, Bvn_AstNode.TYPE_IF)
	assert_eq(output.children[0].children[0].children[0].children[0].line_index, 3)
	assert_eq(output.children[0].children[0].children[0].children[1].text, "elif AAAA:")
	assert_eq(output.children[0].children[0].children[0].children[1].type, Bvn_AstNode.TYPE_ELSE_IF)
	assert_eq(output.children[0].children[0].children[0].children[1].line_index, 4)
		
