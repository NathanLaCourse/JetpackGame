extends Sprite2D

var originalPosition: Vector2
var z: float

func _ready() -> void:
	originalPosition = position
	z = randf_range(0.25, 2)
	var randScale = randf()
	scale = Vector2(randScale, randScale)
	self_modulate.a = randf()

func _process(delta: float) -> void:
	position = originalPosition * z
