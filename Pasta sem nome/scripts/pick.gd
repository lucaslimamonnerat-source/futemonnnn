extends Area2D

@export var dialogue_resource: DialogueResource
@export var dialogue_start: String = "start"
var life = 0
@export var item_name: String = ""

func action() -> void:
	DialogueManager.show_example_dialogue_balloon(dialogue_resource, dialogue_start, [self])
	
	State.axe_state = 1
	
	if get_parent():
		get_parent().queue_free()
