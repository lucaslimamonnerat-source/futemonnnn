extends CanvasLayer

@onready var inventory = $Control/NinePatchRect
var itemX = 10
var itemY = 10




#func _process(delta: float) -> void:
	#if State.axe_state == 1:
		#$Control/NinePatchRect/Axe.visible = true

func _novo_item(item: Texture2D):
	# 1. Cria o nó Sprite2D
	var novo_sprite = Sprite2D.new()
	
	# 2. Carrega a imagem/textura para o sprite
	novo_sprite.texture = item
	
	novo_sprite.z_index = 1000
	novo_sprite.scale = Vector2(2.418, 3.225)
	
	# 3. Define a posição relativa ao objeto pai
	novo_sprite.position = Vector2(120, 120)
	
	# 4. Adiciona o sprite como filho deste nó
	add_child(novo_sprite)
