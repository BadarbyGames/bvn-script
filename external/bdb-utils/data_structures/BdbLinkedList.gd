extends RefCounted

class_name BdbLinkedList

var prev:BdbLinkedList:
	set(v):
		if prev:
			v.prev = prev
			prev.next = v
		prev = v
var next:BdbLinkedList:
	set(v):
		if next:
			v.next = next
			next.prev = v
		next = v

var payload:Variant
