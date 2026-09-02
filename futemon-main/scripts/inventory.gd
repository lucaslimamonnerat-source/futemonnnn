extends CanvasLayer

@onready var inventory = $Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	inventory.visible = false

func _process(delta: float) -> void:
	if State.axe_state == 1:
		$Control/NinePatchRect/Axe.visible = true
