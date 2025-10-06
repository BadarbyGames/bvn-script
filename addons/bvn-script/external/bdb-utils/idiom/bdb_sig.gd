class_name BdbSig

static func sig_clear(sig:Signal):
	for connection in sig.get_connections():
		sig.disconnect(connection.callable)

static func sig_conn(sig:Signal, cb:Callable, flags: Object.ConnectFlags = 0):
	if !sig.is_connected(cb):
		sig.connect(cb, flags)

static func sig_disconn(sig:Signal, cb:Callable):
	if sig.is_connected(cb):
		sig.disconnect(cb)
