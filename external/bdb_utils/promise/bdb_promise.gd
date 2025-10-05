extends RefCounted

class_name BdbPromise

var fulfilled = null
var is_fulfilled = false

signal on_resolved()

var noop = func(): return
var success_cb:Callable = noop
var fail_cb:Callable = noop

func _init(initial_awaitable:Callable = noop):
	if not is_same(initial_awaitable,noop):
		reference()  # if we dont increase counter, this will be freed
		# before the promise is even resolved
		get_coroutine().connect(func ():
			match initial_awaitable.get_argument_count():
				1: initial_awaitable.call(resolve)
				2: initial_awaitable.call(resolve,reject)
				_: assert(false,"Constructor callables must be created with either 1 or 2 args")
			, CONNECT_ONE_SHOT)
	
static func get_coroutine():
	return Engine.get_main_loop().process_frame
	
static func timer(time=0.1):
	return Engine.get_main_loop().create_timer(time)
	
## This returns a promise that can be awaited until the predicate
## returns true. This polls every 0.1 seconds. The 3rd argument
## accepts a promise to resolve when the poll is done, otherwise it returns
## a new promise.
static func poll(predicate:Callable, sec:float = 0.1, promise:BdbPromise = null):
	if promise == null:
		promise = BdbPromise.new()
	if predicate.call():
		promise.resolve()
		return promise
	timer(sec).timeout.connect(func (): poll(predicate,sec,promise))
	return promise
	
## Creates a new promise
static func resolved(v) -> BdbPromise:
	if v is BdbPromise:
		return v
	var pr = BdbPromise.new()
	pr.fulfilled = v
	pr.is_fulfilled = true
	return pr
	
static func all(args:Array)->BdbPromise:
	if not args:
		return resolved(true)
	
	var promise := BdbPromise.new()
	var args_size = args.size()
	var state = {"resolved":0}
	
	var results = range(args_size)
	
	for index in args_size:
		var arg = args[index]
		var promise_cb = func(result = null):
			state.resolved += 1
			if result:
				results[index] = result
			
			if state.resolved == args_size:
				promise.resolve(results)
		arg.then(promise_cb,promise_cb)
		
	return promise
	

func then(_success_cb:Callable = success_cb, _fail_cb:Callable = fail_cb)->BdbPromise:
	var new_pr = BdbPromise.new()
	reference()
	
	# Rewrapping is to ensure the callback always fits
	success_cb = func (arg = null):
		var return_value = arg
		match _success_cb.get_argument_count():
			0: return_value = _success_cb.call()
			1: return_value = _success_cb.call(arg)
			_: assert(false,"Then callbacks must be created with between 0-1 args got %s" % _success_cb.get_argument_count())
		new_pr.resolve(return_value)
		unreference()
		
	fail_cb = func (arg = null):
		match _fail_cb.get_argument_count():
			0: _fail_cb.call()
			1: _fail_cb.call(arg)
			_: assert(false,"Then callbacks must be created with between 0-1 args got %s" % _fail_cb.get_argument_count())
		new_pr.reject(arg)
		unreference()
			
	if is_fulfilled:
		success_cb.call(fulfilled)
	return new_pr
	
func catch(_fail_cb:Callable = fail_cb)->BdbPromise:
	return then(success_cb,_fail_cb)

## Returns the signal or a value
## e.g.  await do_something().completed()
func completed():
	reference()
	while not(is_fulfilled):
		await get_coroutine() # This converts it into an awaitable coroutine
	unreference()
	return fulfilled

## Resolves the promise
func resolve(v = null):
	if is_fulfilled: return
	fulfilled = [v,null]
	is_fulfilled = true
	
	match success_cb.get_argument_count():
		0: success_cb.call()
		1: success_cb.call(v)
		_: assert(false,"Then callbacks must be created with between 0-1 args got %s" % success_cb.get_argument_count())
	
	on_resolved.emit()
	
	if unreference():
		free()
	
var _debug_info:Dictionary = {}
func bind_debug_info(dict:Dictionary):
	_debug_info.merge(dict, true)
	
## Rejects the promise
func reject(err = null):
	if is_fulfilled: return
	fulfilled = [null,err]
	is_fulfilled = true
	
	match fail_cb.get_argument_count():
		0: fail_cb.call()
		1: fail_cb.call(err)
		_: assert(false,"Then callbacks must be created with between 0-1 args")
	
	on_resolved.emit()
	if unreference():
		free()
