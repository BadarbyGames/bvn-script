@tool
extends Button

## Button that asks the VM to save the current session
class_name BVN_SaveButton

var vm:BVN_ButtonSaveSessionVM
func _init() -> void:
	tree_entered.connect(func ():
		text = "Save Session"
		vm = BVNInternal.ensure_child(self,BVN_ButtonSaveSessionVM)
		vm.retarget(self)
		)
		
	tree_exited.connect(func ():
		if is_instance_valid(vm):
			vm.queue_free()
		)
