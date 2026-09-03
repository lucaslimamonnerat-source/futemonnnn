extends Item
class_name ItemVelocidade

var usando = false

func usar(player):
	if (usando == false):
		player.title_size *= 20
		usando = true
	else:
		player.title_size /= 20
		usando = false
