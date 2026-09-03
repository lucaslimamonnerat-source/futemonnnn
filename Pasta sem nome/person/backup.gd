extends CharacterBody2D

var VELOCIDADE = 200

var situationAtual = "idle"

var matos = []

func _ready():
	randomize()

func entrou_no_mato(mato):
	matos.append(mato)

func saiu_do_mato(mato):
	matos.erase(mato)

func tentar_encontro():

	if matos.is_empty():
		return

	for mato in matos:

		var roll = randi() % 400

		if roll < mato.chance_encontro:
			VELOCIDADE = 0

			SceneTransition.change_scene(
				"res://scenes/battle.tscn"
			)

			return

func _process(delta: float) -> void:
	var direction = Input.get_vector("esquerda", "direita", "cima", "baixo")
	
	velocity = direction * VELOCIDADE
	
	if Input.is_action_pressed("sair"):
		get_tree().change_scene_to_file("res://scenes/menu_start.tscn")
	
	if Input.is_action_pressed("direita"):
		situationAtual = "idleL"
		$animaco.play("run")
		$animaco.flip_h = false
	elif Input.is_action_pressed("esquerda"):
		situationAtual = "idleL"
		$animaco.play("run")
		$animaco.flip_h = true
	elif Input.is_action_pressed("cima"):
		situationAtual = "idleC"
		$animaco.flip_h = false
		$animaco.play("runC")
	elif Input.is_action_pressed("baixo"):
		situationAtual = "idle"
		$animaco.flip_h = false
		$animaco.play("runB")
	else:
		$animaco.play(situationAtual)
	
	move_and_slide()
	if direction != Vector2.ZERO:
		tentar_encontro()
