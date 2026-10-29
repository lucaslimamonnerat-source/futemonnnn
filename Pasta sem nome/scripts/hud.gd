extends CanvasLayer

@onready var moedas_label: Label = $Control/MoedasLabel
@onready var sprite_anim = $Control/AnimatedSprite2D

func _process(delta: float) -> void:
	moedas_label.text = "Bateria: " + str(State.batteryLant)
	moedas_label.visible = not State.audiomenu_aberto
	
	if State.batteryLant >= 70:
		sprite_anim.play("carregado")
	elif State.batteryLant < 70 and State.batteryLant >= 30:
		sprite_anim.play("cabando")
	elif State.batteryLant < 30 and State.batteryLant >= 11:
		sprite_anim.play("menos")
	elif State.batteryLant < 11 and State.batteryLant >= 1:
		sprite_anim.play("zerado")
	elif State.batteryLant == 0 :
		sprite_anim.play("cabo")
