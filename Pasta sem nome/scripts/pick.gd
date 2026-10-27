extends Area2D

@export var dialogue_resource: DialogueResource
@export var dialogue_start: String = "start"
var life = 0
@export var item_name: String = ""

func action() -> void:
	
	if item_name == "Machado":
		State.axe_state = 1
	elif item_name == "Bateria":
		if State.batteryLant >= 99:
			print("ababa")
			return
		else:
			State.batteryLant += 2
	
	if get_parent():
		get_parent().queue_free()
