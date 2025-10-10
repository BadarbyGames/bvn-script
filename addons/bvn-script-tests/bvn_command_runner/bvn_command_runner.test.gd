extends GutTest

func test_no_orphans():
	var command_runner:BVNInternal_EngineCommandRunner = add_child_autofree(BVNInternal_EngineCommandRunner.new())
	assert_no_new_orphans()


func test_api_assignment_expansion():
	var command_runner :BVNInternal_EngineCommandRunner = add_child_autofree(BVNInternal_EngineCommandRunner.new())
	
	var rx = command_runner.rx_assignment
	
	# NOTE: omit vars, because this is called before the api expansion
	
	# basic call
	assert_eq(
		rx.rx.sub('> happiness = 123', rx.replacement, true),
		'> vars.update("happiness",123)')
		
	# tabbed after > basic call
	assert_eq(
		rx.rx.sub('>	 happiness = 123', rx.replacement, true),
		'> vars.update("happiness",123)')
	
	# tabbed before > basic call
	assert_eq(
		rx.rx.sub('			> happiness = 123', rx.replacement, true),
		'> vars.update("happiness",123)')
		
	# expressions
	assert_eq(
		rx.rx.sub('> happiness = 1 + 2 - 3 * 4 / 5', rx.replacement, true),
		'> vars.update("happiness",1 + 2 - 3 * 4 / 5)')
		
	# strings
	assert_eq(
		rx.rx.sub('> name = "john"', rx.replacement, true),
		'> vars.update("name","john")')
		
	# strings concat
	assert_eq(
		rx.rx.sub('> name = "john" + "doe"', rx.replacement, true),
		'> vars.update("name","john" + "doe")')
		
	# strings different stuff
	assert_eq(
		rx.rx.sub('> name = "john" + 200', rx.replacement, true),
		'> vars.update("name","john" + 200)')
		
	# func call
	assert_eq(
		rx.rx.sub('> music = ask()', rx.replacement, true),
		'> vars.update("music",ask())')
		
	# func call
	assert_eq(
		rx.rx.sub('> music = ask(123)', rx.replacement, true),
		'> vars.update("music",ask(123))')
		
	# func call
	assert_eq(
		rx.rx.sub('> name = ask("A","B","C")', rx.replacement, true),
		'> vars.update("name",ask("A","B","C"))')
	


func test_api_call_expansion():
	var command_runner :BVNInternal_EngineCommandRunner = add_child_autofree(BVNInternal_EngineCommandRunner.new())
	
	var rx := command_runner.rx_api_call
	
	# basic call
	assert_eq(
		rx.rx.sub('> audio.play()', rx.replacement),
		'> api.audio.play()')
		
	# call with args
	assert_eq(
		rx.rx.sub('> audio.play("guitar.wav")', rx.replacement),
		'> api.audio.play("guitar.wav")')
		
	# multiple
	assert_eq(
		rx.rx.sub('> audio.play(), other.func()', rx.replacement, true),
		'> api.audio.play(), api.other.func()')
		
	# nested
	assert_eq(
		rx.rx.sub('> audio.play(other.func())', rx.replacement, true),
		'> api.audio.play(api.other.func())')
		
	# exclude if not func call
	assert_eq(
		rx.rx.sub('> audio.play(other.not_func)', rx.replacement, true),
		'> api.audio.play(other.not_func)')
		
	# exclude if string
	assert_eq(
		rx.rx.sub('> audio.play("guitar.wav")', rx.replacement, true),
		'> api.audio.play("guitar.wav")')

func test_node_path_expansion():
	var command_runner :BVNInternal_EngineCommandRunner = add_child_autofree(BVNInternal_EngineCommandRunner.new())
	
	var rx_pattern = command_runner.rx_regular_node.rx
	var rx_replacement :String = command_runner.rx_regular_node.replacement
	
	# basic
	assert_eq(
		command_runner.expand_command("> $child0"),
		"api.node.get_node_from_context('child0')")
		
	# basic unique access
	assert_eq(
		command_runner.expand_command("> %child0"),																						
		"api.node.get_node_from_context('%child0')")
		
	# basic unique access with func call
	assert_eq(
		command_runner.expand_command("> %child0.show()"),		
		"api.node.get_node_from_context('%child0').show()")
	
	# spaced child double quote
	assert_eq(
		command_runner.expand_command("""> $"spaced child" """),
		"api.node.get_node_from_context('spaced child')")
		
	# spaced child single quote
	assert_eq(
		command_runner.expand_command("""> $'spaced child' """),
		"api.node.get_node_from_context('spaced child')")
		
	# spaced child double quote - unique
	assert_eq(
		command_runner.expand_command("""> %"spaced child" """),
		"api.node.get_node_from_context('%spaced child')")
		
	# spaced child single quote - unique
	assert_eq(
		command_runner.expand_command("""> %'spaced child' """),
		"api.node.get_node_from_context('%spaced child')")

	# multiple
	assert_eq(
		command_runner.expand_command("> $child0 and $child1"),
		"api.node.get_node_from_context('child0') and api.node.get_node_from_context('child1')")
		
	# drill down
	assert_eq(
		command_runner.expand_command("> $child0/ab/cd"),
		"api.node.get_node_from_context('child0/ab/cd')")
	
	# drill down with spaces
	assert_eq(
		command_runner.expand_command('> $"child0 / ab / cd "'),
		"api.node.get_node_from_context('child0 / ab / cd ')")
		
	## combine with call
	assert_eq(
		command_runner.expand_command("""> $House1/boy.show() """),
		"api.node.get_node_from_context('House1/boy').show()")
		
	# as parameter
	assert_eq(
		command_runner.expand_command("> node.solo( %'Win-Lose','show' )"),
		"api.node.solo( api.node.get_node_from_context('%Win-Lose'),'show' )")
	
		
	# does not affect assignments
	assert_eq(
		command_runner.expand_command("> audio = 25"),
		"api.vars.update(\"audio\",25)")
