extends Area2D

@export var ir = ""

@onready var imagme = $root

func _input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		get_tree().change_scene_to_file("res://scenes/" + ir)

func _mouse_enter() -> void:
	scale = Vector2(0.22, 0.22)
	
func _mouse_exit() -> void:
	scale = Vector2(0.182, 0.182)
