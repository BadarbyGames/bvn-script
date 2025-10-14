extends GutTest

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
	
func test_attributes():
	var tree := BVNInternal_BBCodeParser.parse("""my [size=24 word=big website=http://www.google.com name="Mr Nose" address='Single Quote St.']big[/size] boy""")
	assert_eq_deep(tree,
	{
		"tag": "root",
		"attr": "",
		"children": [
			{
				"tag": "text",
				"value": "my "
			},
			{
				"tag": "size",
				"attr": {
					"size":"24",
					"word":"big",
					"name": "Mr Nose",
					"address": "Single Quote St.",
					"website": "http://www.google.com"
				},
				"children": [
					{
						"tag": "text",
						"value": "big"
					}
				]
			},
			{
				"tag": "text",
				"value": " boy"
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
