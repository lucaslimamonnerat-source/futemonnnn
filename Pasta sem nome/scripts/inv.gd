extends Node

var items = []

func picked(item):
	if item == "Machado":
		items.append({"item": "machado", "type": "utilizavel"})
	if item == "Usar":
		items.append({"item": "usavel", "type": "usavel", "go": Callable(self, "_use")})

func _use(item):
	print("Item usado")
