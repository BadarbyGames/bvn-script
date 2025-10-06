extends Node

## This should be added as an autoload

@export_group("Node Group Names")
@export var by_all:String = "di.*"
@export var by_name:String = "di.name"
@export var by_type:String = "di.type"
@export var by_factory:String = "di.factory"
@export var by_startup:String = "di.startup"

var registry:Dictionary = {}

var main:BdbDiContainer

enum VALUE_TYPE {
	VALUE = 0,
	FACTORY = 1
}

func _enter_tree() -> void:
	main = BdbDiContainer.new()
	add_child(main)

func _ready() -> void:
	add_to_group('di.root')
	
	var tree := get_tree()
	for node in tree.get_nodes_in_group(by_all):
		main.register_by_type(node)
		main.register_by_name(node)
	for node in tree.get_nodes_in_group(by_name):
		main.register_by_name(node)
	for node in tree.get_nodes_in_group(by_type):
		main.register_by_type(node)
	for node in tree.get_nodes_in_group(by_factory):
		main.register_by_factory(node)
	for node in tree.get_nodes_in_group(by_startup):
		main.register_by_startup(node)

func fetch(request):
	return main.fetch(request)
		
func require(request):
	return main.require(request)
