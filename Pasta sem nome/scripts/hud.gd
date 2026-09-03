extends CanvasLayer


@onready var moedas_label: Label = $Control/MoedasLabel

func _process(delta: float) -> void:
	moedas_label.text = "Moedas: " + str(State.coins_state)
