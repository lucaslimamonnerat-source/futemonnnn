# Porta.gd
extends Area2D

var player_perto = false

func _ready():
	$CasaWip.visible = false
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func abrir_porta():
	$CasaWip.visible = true

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_perto = true
		body.porta_proxima = self
		body.cena_destino = get_parent().cena_destino    # avisa o player

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_perto = false
		body.porta_proxima = null
