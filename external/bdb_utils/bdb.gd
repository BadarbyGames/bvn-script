extends Node

class_name Bdb

const default_message = "This is required"
static func require(n:Variant, msg:String = default_message):
	assert(n, default_message)
	return n

## Checks against null, freed and to-be freed nodes
static func is_instance_will_be_valid(n:Node):
	return n and is_instance_valid(n) and !n.is_queued_for_deletion()

static func exec(cb:Callable):
	return cb.call()

static func noop(a = null,b = null,c = null,d = null,e = null): return
