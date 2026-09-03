extends CanvasLayer

@onready var inventory = $Control
var imagem = preload("res://sprites/Inventory/Axe.png")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	inventory.visible = false

func _process(delta: float) -> void:
	if State.axe_state == 1:
		$Control/NinePatchRect/Axe.visible = true

func _novo_item():
	var novo_sprite = Sprite2D.new()
	
	novo_sprite.texture = imagem
	
	novo_sprite.position = Vector2(100, 100)
	
	$CanvasLayer/Control/NinePatchRect.add_child(novo_sprite)
