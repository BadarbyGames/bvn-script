@tool
extends Control

class_name BVNInternal_StartWizard

@export var diag_select_dir:FileDialog
@export var diag_inform:AcceptDialog
@export var novel_template_packed_scene:PackedScene
@export var descrpt_label:RichTextLabel

var current_line_edit:LineEdit
var current_proj_setter:Callable # This way because BVN_ProjectSettings is a static class and i cant be dynamic
var selected_folder:String
