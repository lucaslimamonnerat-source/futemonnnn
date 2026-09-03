extends Area2D


@export var dialogue_resource: DialogueResource
@export var dialogue_start: String = "start"
@export var life = 1


func _process(delta: float) -> void:
	if life != 1:
		if get_parent():
			get_parent().queue_free()

func action() -> void:
	DialogueManager.show_example_dialogue_balloon(dialogue_resource, dialogue_start, [self])
