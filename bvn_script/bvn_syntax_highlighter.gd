extends SyntaxHighlighter
class_name BVNInternal_SyntaxHighlighter

const NO_COLOR := {}
var color_orange := Color(0.8, 0.6, 0.2) # orange

var parser := BVN_ScriptParser.new()

const ORANGE := { &"color":  Color(0.8, 0.6, 0.2) }
const GRAY := { &"color":  Color(0.284, 0.285, 0.322, 1.0) }

var rx_if := RegEx.create_from_string(r"^\s*(else|elif|if).*(:)")

var rx_cmd := RegEx.create_from_string(r"^\s*(>)")

var rx_comment := RegEx.create_from_string(r"^\s*#.*")
var rx_character := RegEx.create_from_string(r"^\s*(\w+)\s*(:)")

func _get_line_syntax_highlighting(line: int) -> Dictionary:
	var text := get_text_edit().get_line(line)
	var highlights := {}
	
	if rx_comment.search(text):
		highlights[0] = GRAY
		return highlights
	
	var rxs:Array[RegEx]= [
		rx_if,
		rx_cmd,
		rx_character
	]

	for rx in rxs:
		var result := rx.search(text)
		if !result: continue
		
		for group_index in range(1,result.get_group_count()+1):
			var i1 := result.get_start(group_index)
			var key_len := result.get_string(group_index).length()
			highlights[i1] = ORANGE
			highlights[i1+key_len] = NO_COLOR

	return highlights
