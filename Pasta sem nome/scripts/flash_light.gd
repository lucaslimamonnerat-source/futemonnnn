extends PointLight2D

# Variável para acumular o tempo que passa
var tempo_decorrido: float = 0.0

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("mRight"):
		State.batteryOn = not State.batteryOn
		enabled = State.batteryOn

func _process(delta: float) -> void:
	if State.carregado == false or State.batteryOn == false:
		enabled = false
	
	if State.batteryLant != 0:
		State.carregado = true
	
	if State.batteryOn == true and State.carregado:
		# Acumula o tempo a cada frame
		tempo_decorrido += delta
		
		if State.batteryLant < 1:
			State.carregado = false
		
		# Se passou de 3 segundos
		if tempo_decorrido >= 0.4:
			State.batteryLant -= 1
			tempo_decorrido = 0.0 # Reinicia o cronômetro
	else:
		# Opcional: reseta o tempo se a lanterna desligar
		tempo_decorrido = 0.0
