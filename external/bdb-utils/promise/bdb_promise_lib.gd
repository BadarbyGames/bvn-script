class_name BdbPromiseLib

static func is_ready(node:Node) -> BdbPromise:
	if node.is_node_ready():
		return BdbPromise.resolved(node)
	return BdbPromise\
		.poll(func ():return node.is_node_ready())\
		.then(func (): return node)
