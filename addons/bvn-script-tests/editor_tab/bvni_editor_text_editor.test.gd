extends BVNInternal_GutTest

var engine:BVN_Engine
var visual_novel:BVN_VisualNovel
var test_scene:BVN_Page
var variables:BVN_Variables
func before_each():
	visual_novel = BVN_VisualNovel.new()
	
	var personA := BVN_CharacterSheet.new()
	personA.display_name = "personA"
	
	visual_novel.characters = [personA]
	
	#region Create Engine
	engine = add_child_autofree(BVN_Engine.new())
	engine.visual_novel = visual_novel
	
	variables = BVN_Variables.new()
	engine.add_child(variables)
	
	test_scene = BVN_Page.new()
	test_scene.page_data = BVN_PageData.new()
	engine.add_child(test_scene)
	#endregion

func test_cleanup_signal():
	assert_cleanup_signal(BVNInternal_EditorTextEditor.new())

func test_is_able_to_run_speaker_lines():
	var editor:BVNInternal_EditorTextEditor = add_child_autoqfree(BVNInternal_EditorTextEditor.new())
	editor.edited_scene = test_scene
	editor.text="""\
	personA: hello world
	"""
	
	editor.execute_line(0)
	assert_eq(engine.speaker_runner.speaker.display_name, "personA")
	assert_eq(engine.speaker_runner.text.target, "hello world")
