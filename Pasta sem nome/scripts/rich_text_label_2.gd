extends RichTextLabel

@export var offset_x: float = 447.0

func _ready() -> void:
	item_rect_changed.connect(_apply_offset)
	call_deferred("_apply_offset")

func _apply_offset() -> void:
	position.x = offset_x
