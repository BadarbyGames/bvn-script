extends RefCounted

class_name BVNInternal_BBCodeParser
#Basic [shake connected=1]Inner[/shake]
static func parse(text: String) -> Dictionary:
	var tokens = RegEx.create_from_string(
		#r"\[/?(?<tag>[a-zA-Z0-9]+)(?:=[^\]]+)?(?:\s*\w+=\w+)*\]"
		r"\[/?(?<tag>[a-zA-Z0-9]+)(?:=[^\]]+)?(?:\s*\w+=[^\[]+)*\]"
	)
	
	var attr_extract_rx = RegEx.create_from_string(
		r"""(?<tag>\w+)=((?<val>[^\s\"\']+\b)|('(?<val>[^']*)')|("(?<val>[^"]*)"))"""
	)

	var result = {"tag": "root", "attr": "", "children": []}
	var stack = [result]
	var last_pos = 0

	for m in tokens.search_all(text):
		var token_start :=  m.get_start()
		# 1. Add plain text before this tag
		if token_start > last_pos:
			var value :=  text.substr(last_pos, token_start - last_pos)
			stack[-1]["children"].append({
				"tag": "text",
				"value": text.substr(last_pos, token_start - last_pos)
			})

		var tag_text = m.get_string()

		if tag_text.begins_with("[/"):  
			# 2. Closing tag → pop stack if matching exists
			var close_name = tag_text.substr(2, tag_text.length() - 3) # strip [/ ... ]
			if stack.size() > 1 and stack[-1][&"tag"] == close_name:
				stack.pop_back()
			# If it doesn’t match, ignore gracefully (malformed BBCode)
		else:
			# 3. Opening or self-closing tag
			var inner = tag_text.substr(1, tag_text.length() - 2) # strip [ ... ]
			var parts = inner.split("=", false, 1)
			var tag_name =  m.get_string(&"tag")
			var attr := {}
			for attr_extract in attr_extract_rx.search_all(inner):
				var attr_tag := attr_extract.get_string("tag")
				var attr_val := attr_extract.get_string("val")
				attr[attr_tag] = attr_val
				pass
			#var attr = parts[1] if parts.size() > 1 else ""
			
			var node = {
				&"tag": tag_name,
				&"attr": attr,	# <-- Handle attributes here
				&"children": []
			}
			
			# 4. Self-closing tags (e.g. [br], [img=foo.png]) → don't push on stack
			if tag_name in ["br", "img", "hr"]:  
				stack[-1][&"children"].append(node)
			else:
				# Normal opening tag → add and push
				stack[-1][&"children"].append(node)
				stack.append(node)

		last_pos = m.get_end()

	# 5. Add trailing text after the last tag
	if last_pos < text.length():
		stack[-1][&"children"].append({
			&"tag": "text",
			&"value": text.substr(last_pos)
		})

	return result
	

static func print_tree(node: Dictionary, depth: int = 0) -> void:
	var indent = "\t".repeat(depth)
	
	if node.has("tag") and node["tag"] == "text":
		# Text nodes → just print the value
		print(indent + "TEXT: \"" + str(node.get("value", "")) + "\"")
	else:
		# Non-text nodes → print tag + attr
		var tag = node.get("tag", "??")
		#@TODO restore
		#var attr = node.get("attr",{})
		#if attr != {}:
			#print(indent + "[" + tag + "=" + str(attr) + "]")
		#else:
			#print(indent + "[" + tag + "]")

		# Recurse children
		for child in node.get("children", []):
			print_tree(child, depth + 1)
