extends CanvasLayer

@onready var inventory = $Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	inventory.visible = false
