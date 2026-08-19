extends Area2D

@export var chance_encontro := 10 # 10%

var player_dentro = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.entrou_no_mato(self)


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.saiu_do_mato(self)
