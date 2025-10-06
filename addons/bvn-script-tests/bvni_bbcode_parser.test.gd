extends GutTest

var rx := RegEx.create_from_string(r"(?<spacer>\s*|^)(?<bbinner>\[\w+\]\w+\[/\w+])+")

var test_cases := [
	["hello [b]world[/b]", ["[b]world[/b]"], [6]],
	["[b]foo[/b] bar", ["[b]foo[/b]"], [0]],
	["[b][i][x]Deep nested[/x][/i][/b]", ["A [b][i][x]Deep nested[/x][/i][/b]"],[2]],
]
#func test_can_split_nodes_into_wtv(params=use_parameters(test_cases)):
func test_linear_children():
	var tree := BVNInternal_BBCodeParser.parse("foo [b]bar[/b] baz")
	assert_eq_deep(tree,
	{
		"tag": "root",
		"attr": "",
		"children": [
			{
				"tag": "text",
				"value": "foo "
			},
			{
				"tag": "b",
				"attr": {},
				"children": [
					{
						"tag": "text",
						"value": "bar"
					}
				]
			},
			{
				"tag": "text",
				"value": " baz"
			}
		]
	})
	
func test_nested():
	var tree := BVNInternal_BBCodeParser.parse("foo [b][i]bar[/i]baz[/b] ban")
	assert_eq_deep(tree,
	{
		"tag": "root",
		"attr": "",
		"children": [
			{
				"tag": "text",
				"value": "foo "
			},
			{
				"tag": "b",
				"attr": {},
				"children": [
					{
						"tag": "i",
						"attr": {},
						"children": [
							{
								"tag": "text",
								"value": "bar"
							}
						]
					},
					{
						"tag": "text",
						"value": "baz"
					}
				]
			},
			{
				"tag": "text",
				"value": " ban"
			}
		]
	})
