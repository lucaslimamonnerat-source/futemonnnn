extends CanvasLayer

@onready var moedas_label: Label = $Control/MoedasLabel

func _process(delta: float) -> void:
	moedas_label.text = "Moedas: " + str(State.coins_state)
	moedas_label.visible = not State.audiomenu_aberto
