extends Node2D

var type: int = 0
var random = randf()

func _ready() -> void:
	
	if type == 0:
		$Sprite2D.modulate = Color(1.0, 1.0, 0.0, 1.0)
	if type == 1:
		$Sprite2D.modulate = Color("ff9000")
	if type == 2:
		$Sprite2D.modulate = Color("00ffffff")
	if type == 3:
		$Sprite2D.modulate = Color("ff0000ff")

func _process(delta: float) -> void:
	if type == 4:
		$Sprite2D.modulate = Color.from_hsv(fmod(get_parent().get_parent().time + random, 1), 1.0, 1.0, 1.0)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if type == 0:
		body.coins += 1
	if type == 1:
		body.jetpackFuel += 2
	if type == 2:
		body.velocity += 300 * body.velocity.normalized()
	if type == 3:
		body.thermalEnergy += 100
	if type == 4:
		body.rainbow += 1
	$AnimationPlayer.play("collect")
