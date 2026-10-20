extends PointLight2D

# Variável para acumular o tempo que passa
var tempo_decorrido: float = 0.0

func _process(delta: float) -> void:
	if State.batteryOn == true:
		# Acumula o tempo a cada frame
		tempo_decorrido += delta
		
		# Se passou de 3 segundos
		if tempo_decorrido >= 3.0:
			State.batteryLant -= 1
			tempo_decorrido = 0.0 # Reinicia o cronômetro
	else:
		# Opcional: reseta o tempo se a lanterna desligar
		tempo_decorrido = 0.0
