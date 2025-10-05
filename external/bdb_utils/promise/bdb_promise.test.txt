extends SimpleTest

func it_should_complete_await_only_after_resolve():
	var future = BdbPromise.new()
	var state = { "ctr": 100}

	future.then(func (_u): state.ctr = 200)
	expect(state.ctr).to.equal(100, "Should not execute change until resolved is called")
	
	future.resolve()
	await wait(1)
	expect(state.ctr).to.equal(200, "Should now be 200 now that resolved been called")

func it_should_complete_await_after_reject():
	var future = BdbPromise.new()
	var state = { "ctr": 100}

	future.catch(func (): 
		state.ctr = 200)
	expect(state.ctr).to.equal(100, "Should not execute change until reject is called")
	
	future.reject()
	await wait(1)
	expect(state.ctr).to.equal(200, "Should now be 200 now that reject been called")
	

func it_should_chain_then():
	var future = BdbPromise.new()
	var state = { 
			"a": 1,
			"b": 10,
			"c": 100,
		}

	future\
		.then(func (_u): state.a = 2)\
		.then(func (_u): state.b = 20)\
		.then(func (_u): state.c = 200)
		
	expect(state.a).to.equal(1, "Should(a) not execute change until resolved is called")
	expect(state.b).to.equal(10, "Should(b) not execute change until resolved is called")
	expect(state.c).to.equal(100, "Should(c) not execute change until resolved is called")
	
	future.resolve()
	await wait(1)
	expect(state.a).to.equal(2, "Should(a) have changed since resolved called")
	expect(state.b).to.equal(20, "Should(b) have changed since resolved called")
	expect(state.c).to.equal(200, "Should(c) have changed since resolved called")

func it_should_have_an_awaitable_then():
	var future = create_resolve_future(0.5)
	var state = { 
			"a": 1,
			"b": 10,
			"c": 100,
		}
		
	await future\
		.then(func (_u): state.a = 2)\
		.then(func (_u): state.b = 20)\
		.then(func (_u): state.c = 200)\
		.completed()
		
	expect(state.a).to.equal(2, "Should(a) have changed since resolved called")
	expect(state.b).to.equal(20, "Should(b) have changed since resolved called")
	expect(state.c).to.equal(200, "Should(c) have changed since resolved called")

func it_all_only_resolves_after_all_promises_done():
	var future1 := create_resolve_future(0.1)
	var future2 := create_resolve_future(0.2)
	var future3 := create_reject_future(0.3)
	var future_all = BdbPromise.all([
		future1,
		future2,
		future3
	])
	
	await future1.completed()
	expect(future1.fulfilled).to.equal([0.1,null], "BdbPromise")
	expect(future2.fulfilled).to.NOT.equal([0.2,null],"BdbPromise")
	expect(future3.fulfilled).to.NOT.equal([null,0.3],"BdbPromise")
	expect(future_all.fulfilled).to.equal(null, "This should not resolve the entire future until all 3 are done")
	
	await future2.completed()
	expect(future1.fulfilled).to.equal([0.1,null])
	expect(future2.fulfilled).to.equal([0.2,null])
	expect(future3.fulfilled).to.NOT.equal([null,0.3])
	expect(future_all.fulfilled).to.equal(null)
	
	await future3.completed()
	expect(future1.fulfilled).to.equal([0.1,null])
	expect(future2.fulfilled).to.equal([0.2,null])
	expect(future3.fulfilled).to.equal([null,0.3])
	expect(future_all.fulfilled).to.equal([[0.1,0.2,0.3],null])
	
func it_should_be_able_to_chain_returns():
	var future1 := create_resolve_future(0.1)
	var future2 := future1.then(func (time): return str("time ",time))
	var future3 := future2.then(func (new_str): return str(new_str," yall"))
		
	await future2.completed()
	expect(future2.fulfilled).to.equal(["time 0.1",null])
	await future3.completed()
	expect(future3.fulfilled).to.equal(["time 0.1 yall",null])
	
func it_should_be_able_to_unwrap_promises():
	var future1 := create_resolve_future(0.1)
	var future2 := BdbPromise.resolved(future1)
	
	await future2.completed()
	expect(future2.fulfilled).to.equal([0.1,null])
	
	
var time_elapsed := float(0)
func _process(delta: float) -> void:
	time_elapsed += delta
	
func it_can_poll():
	await BdbPromise.poll(func (): return time_elapsed >= 2).completed()
	expect(time_elapsed).to.be.gte(2, "Shouldve been called after ")
	
func create_resolve_future(time:float) -> BdbPromise:
	var future = BdbPromise.new()
	get_tree()\
		.create_timer(time)\
		.timeout\
		.connect(func ():future.resolve(time))
	return future
	
func create_reject_future(time:float) -> BdbPromise:
	var future = BdbPromise.new()
	get_tree()\
		.create_timer(time)\
		.timeout\
		.connect(func ():future.reject(time))
	return future
