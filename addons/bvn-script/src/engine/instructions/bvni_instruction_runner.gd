extends Node

class_name BVNInternal_Instruction_Runner

func execute_ast_node(ast_node:Bvn_AstNode, context:BVNInternal_SceneExecutionContext, vars:Dictionary = {}) -> void:
	var is_run_in_game = context # context gets created on PLAY only
	
	

"""
AST_TYPE_COMMAND:
			var nodes_to_run:Array[Bvn_AstNode] = [ast_node]
			nodes_to_run.append_array(ast_node.children)
			
			for node_to_run in nodes_to_run:
				var result: = cmd_runner.execute_node(node_to_run, vars, context.scene if context else null)
				assert(result[0] == OK, "There was an error running the command '%s'" % node_to_run.text)

			if is_run_in_game:
				next(ast_node.get_next_node(false))
"""
