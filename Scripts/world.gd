extends Node2D

@export var platform: PackedScene
@export var item: PackedScene
@export var star: PackedScene

@export var player: CharacterBody2D

var time: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	generateLevel()
	stars()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
	time += delta

func generateLevel():
	for thing in $ThingHolder.get_children():
		thing.queue_free()
	for i in 200:
		var newPlatform = platform.instantiate()
		newPlatform.position = Vector2(randi_range(-1800, 1800), randi_range(-7000, -350))
		$ThingHolder.add_child(newPlatform)
	for i in 500:
		var newItem = item.instantiate()
		newItem.position = Vector2(randi_range(-1800, 1800), randi_range(-7000, -350))
		newItem.type = randi_range(0, 3)
		$ThingHolder.add_child(newItem)
	for i in 10:
		var newItem = item.instantiate()
		newItem.position = Vector2(randi_range(-1800, 1800), randi_range(-7000, -5000))
		newItem.type = 4
		$ThingHolder.add_child(newItem)

func _on_station_area_body_entered(body: Node2D) -> void:
	if player.newLevelAllowed:
		generateLevel()
		player.newLevelAllowed = false

func stars():
	for i in 1000:
		var newStar = star.instantiate()
		newStar.position = Vector2(randi_range(-4000, 4000), randi_range(0, -10000))
		$Background.add_child(newStar)
