extends Item
class_name ItemCor

@export var cor: Color = Color.RED

func usar(player):
	player.modulate = cor
	await player.get_tree().create_timer(5.0).timeout
	player.modulate = Color.WHITE
