extends CanvasLayer

@onready var inventory = $Control/NinePatchRect
var itemX = 10
var itemY = 10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # inventory.visible = false

#func _process(delta: float) -> void:
	#if State.axe_state == 1:
		#$Control/NinePatchRect/Axe.visible = true

func _novo_item(item: Texture2D):
	var novo_sprite = Sprite2D.new()
	
	novo_sprite.texture = item
	novo_sprite.position = Vector2(itemX, itemY)
	
	itemX += 100
	
	inventory.add_child(novo_sprite)
