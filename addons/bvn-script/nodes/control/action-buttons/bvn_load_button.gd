@tool
extends Button

## Button that asks the VM to save the current session
class_name BVN_LoadButton

@export var save_game_name:String:
	set(v): 
		save_game_name = v
		if vm: vm.save_game_name = v

var vm:BVN_ButtonLoadSessionVM
func _init() -> void:
	tree_entered.connect(func ():
		text = "Load Session"
		vm = BVNInternal.ensure_child(self,BVN_ButtonLoadSessionVM)
		vm.save_game_name = save_game_name
		vm.retarget(self)
		)
		
	tree_exited.connect(func ():
		if is_instance_valid(vm):
			vm.queue_free()
		)
