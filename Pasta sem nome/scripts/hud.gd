extends CanvasLayer

@onready var moedas_label: Label = $Control/MoedasLabel

func _process(delta: float) -> void:
	moedas_label.text = "Bateria: " + str(State.batteryLant)
	moedas_label.visible = not State.audiomenu_aberto
