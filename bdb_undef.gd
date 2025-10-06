## This is a special class whose soul purpose is to replicate
## Undefined in BDB_UNDEF internal classes and functions
## This is useful for situations where null is a separate value
## From not being set.
##
## E.g. 
##  func some_func(arg = BDB_UNDEF):
##      if(arg == BDB_UNDEF) return # Might occur on first run
##      assert(arg != null, "Error, received a bad value")
class_name BDB_UNDEF

static func is_undefined(v, _v = null):
	return typeof(v) == typeof(BDB_UNDEF) and BDB_UNDEF == v

## Inverse of is_undefined. Can be used as a predicate
static func is_defined(v, _v = null):
	return typeof(v) != typeof(BDB_UNDEF) or BDB_UNDEF != v
pass
