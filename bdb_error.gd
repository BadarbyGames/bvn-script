class_name BdbError

const NOT_IMPLEMENTED_STR = &"This method has not been implemented"
static func not_implemented(str:String = NOT_IMPLEMENTED_STR):
	assert(false, str)

const DEPRECATED_STR = &"This method has been deprecated"
static func deprecated(str:String = DEPRECATED_STR):
	assert(false, str)

const MAX_ITERATIONS_STR = &"Potentially large or infinite loop. Please update the parameters"
static func max_iterations(str:String = MAX_ITERATIONS_STR):
	assert(false, str)

const BAD_STATE = &"Reached invalid state"
static func bad_state(str:String = BAD_STATE):
	assert(false, str)
