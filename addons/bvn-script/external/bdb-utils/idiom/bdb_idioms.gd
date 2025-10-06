extends RefCounted

class_name BdbIdioms

static func free_children(parent:Node):
	for c in parent.get_children():
		c.free()
