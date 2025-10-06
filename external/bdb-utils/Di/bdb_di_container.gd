extends Node

class_name BdbDiContainer

@export_group("Node Group Names")
var registry:Dictionary = {}

enum VALUE_TYPE {
	VALUE = 0,
	FACTORY = 1
}

func register(item:Variant, key:Variant, value_type:VALUE_TYPE):
	if registry.has(key):
		if is_same(registry[key], item): return
		printerr("[WARN] Overriding entry for name '%s'"%key)
		
	registry[key] = {
		"type": value_type,
		"value": item
	}
	
func register_factory(item:Variant, key:Variant):
	register(item, key, VALUE_TYPE.FACTORY)
		
func register_by_name(node:Node, key = node.name):
	register(node, key, VALUE_TYPE.VALUE)
	
func register_by_type(node:Node, type:Variant = node.get_script()):
	register(node, type, VALUE_TYPE.VALUE)
	
func register_by_startup(node:Node):
	node._startup(self)

func fetch(request):
	var tmp  = registry.get(request)
	if not tmp:
		return
	if tmp.type == VALUE_TYPE.FACTORY:
		return tmp.value.call(self)
	return tmp.value
		
func require(request):
	var item = fetch(request)
	if not item:
		if request is Script:
			printerr("Di.require called but item was not found %s " % request.get_global_name())
		else:
			printerr("Di.require called but item was not found %s " % request)
		# Helpers.error("Di.require called but item was not found %s " % request)
	return item
