@tool
extends Node

class_name BvnInternal_GuiOrchestrator

var gui_canvas:CanvasLayer

func _enter_tree() -> void:
	BVN_EventBus.on_request_ask_question.connect(show_ask_question_dialogue)

func _exit_tree() -> void:
	BVN_EventBus.on_request_ask_question.disconnect(show_ask_question_dialogue)

func show_ask_question_dialogue(config:Dictionary):
	match config.type:
		BVN_ChoiceModal:
			show_choice_modal(config)
		_:
			show_text_modal(config)
	
func show_text_modal(config:Dictionary):
	var var_name:String = Bdb.require(config.var_name)
	var label:String = Bdb.require(config.label)
	
	var input := BVN_TextInputModal.new()
	input.question_label = label
	input.variable_name = var_name
	input.transaction_id = config.transaction_id
	input.lock_source = config.lock_source
	
	gui_canvas.add_child(input)
	input.set_anchors_and_offsets_preset.call_deferred(Control.PRESET_CENTER)
	input.owner = owner

func show_choice_modal(config:Dictionary):
	var options:Array[String] = Bdb.require(config.options)
	var var_name:String = Bdb.require(config.var_name)
	var label:String = Bdb.require(config.label)
	
	var questions := BVN_ChoiceModal.new()
	questions.question_label = label
	questions.variable_name = var_name
	questions.choices = options
	questions.transaction_id = config.transaction_id
	questions.lock_source = config.lock_source
	
	gui_canvas.add_child(questions)
	questions.set_anchors_and_offsets_preset.call_deferred(Control.PRESET_CENTER)
	questions.owner = owner
