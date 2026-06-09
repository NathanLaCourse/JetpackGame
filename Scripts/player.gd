extends CharacterBody2D

var world: Node2D

@export var UI: Control
var energyPie: Control
@export var goToBase: bool
@export var springRaycast: RayCast2D
@export var spanish: bool = true

var firstTouch: Vector2

var acceleration = 5 #meters per second
var jetpackFuel: float = 5
var maxjetpackFuel: int = 5
var coins: int = 0
var rainbow: int = 0
var maxThermal: int = 100
var springPower: int = 200

var newLevelAllowed: bool = false

var upgradeCosts = [3, 5, 10, 15, 20, 30]
var upgradesPurchased = [0, 0, 0, 0]

var chemicalEnergy: float = 0
var thermalEnergy: float = 0
var kineticEnergy: float = 0
var gravitatinalEnergy: float = 0
var elasticEnergy: float = 0

const mass = 1 #kg
const PxToM = 100 #Pixels per Meter
const gravity = 3 #meters per second

func _ready() -> void:
	world = get_parent()
	energyPie = UI.get_child(0)

func _physics_process(delta: float) -> void:
	
	var onGround: bool = springRaycast.is_colliding() or $floorArea.has_overlapping_bodies()
	
	if jetpackFuel > maxjetpackFuel:
		jetpackFuel = maxjetpackFuel
	
	if Input.is_action_just_pressed("click"):
		firstTouch = get_local_mouse_position()
	
	var direction: Vector2
	if Input.is_action_pressed("click"):
		var mousePos: Vector2 = get_local_mouse_position()
		var mouseOffset: Vector2 = mousePos - firstTouch
		if mouseOffset.length() > 100:
			mouseOffset = mouseOffset.normalized() * 100
		direction = mouseOffset / 100
		$Camera2D/UI/Sprite2D.visible = true
		$Camera2D/UI/Sprite2D.position = firstTouch
		$Camera2D/UI/Sprite2D/Sprite2D2.position = mouseOffset
	else:
		$Camera2D/UI/Sprite2D.visible = false
		direction = Vector2(Input.get_axis("left", "right"), Input.get_axis("up", "down")).normalized()
	
	$AudioStreamPlayer.volume_db = lerpf($AudioStreamPlayer.volume_db, -80.0, 0.2)
	if direction:
		if onGround:
			velocity += direction * acceleration * PxToM * delta
		else:
			if jetpackFuel > 0:
				jetpackFuel -= delta * direction.length()
				velocity += direction * acceleration * PxToM * delta
				$AudioStreamPlayer.volume_db = lerpf($AudioStreamPlayer.volume_db, 40.0, 0.2)
	
	if position.y < -21:
		velocity.y += gravity * PxToM * delta
	velocity.y -= elasticEnergy * PxToM * delta
	
	var previousKinetic: float = 0.5 * mass * pow(velocity.length() / PxToM, 2)
	velocity *= 0.99
	move_and_slide()
	kineticEnergy = 0.5 * mass * pow(velocity.length() / PxToM, 2)
	var kineticChange = kineticEnergy - previousKinetic
	thermalEnergy -= kineticChange
	
	gravitatinalEnergy = mass * gravity * -position.y / PxToM
	if springRaycast.is_colliding():
		elasticEnergy = 0.5 * springPower * pow((global_position.y + springRaycast.target_position.y - springRaycast.get_collision_point().y) / PxToM, 2)
	else:
		elasticEnergy = 0
	
	setEnergyPie()
	
	if position.y > -100:
		jetpackFuel = maxjetpackFuel
		thermalEnergy = 0
		UI.get_child(2).position.x = lerp(UI.get_child(2).position.x, 300.0, 0.1)
		shop()
	else:
		if position.y < -500 or jetpackFuel == 0: 
			newLevelAllowed = true
		UI.get_child(2).position.x = lerp(UI.get_child(2).position.x, 1000.0, 0.1)
	
	if thermalEnergy > maxThermal:
		newLevelAllowed = true
		$Camera2D/UI/EnergyPie/ThermalLimit/AnimationPlayer.play("blowup")
	if goToBase:
		goToBase = false
		global_position = Vector2(0, -50)
		velocity = Vector2.ZERO
	
	if rainbow > 0:
		$Sprite2D.self_modulate = Color.from_hsv(fmod(world.time*rainbow/2, 1), 1.0, 1.0, 1.0)
		if $Sprite2D/CPUParticles2D.emitting == false:
			$Sprite2D/CPUParticles2D.emitting = true

func setEnergyPie():
	var totalEnergy = chemicalEnergy+thermalEnergy+kineticEnergy+gravitatinalEnergy+elasticEnergy
	
	energyPie.get_child(0).value = (chemicalEnergy+thermalEnergy+kineticEnergy+gravitatinalEnergy+elasticEnergy) / totalEnergy
	energyPie.get_child(1).value = (thermalEnergy+kineticEnergy+gravitatinalEnergy+elasticEnergy) / totalEnergy
	energyPie.get_child(2).value = (kineticEnergy+gravitatinalEnergy+elasticEnergy) / totalEnergy
	energyPie.get_child(3).value = (gravitatinalEnergy+elasticEnergy) / totalEnergy
	energyPie.get_child(4).value = (elasticEnergy) / totalEnergy
	
	energyPie.get_child(5).value = jetpackFuel / maxjetpackFuel
	
	energyPie.get_child(6).value = thermalEnergy / maxThermal
	
	UI.get_child(1).text = "$" + str(coins)
	

func shop():
	
	if spanish:
		$Camera2D/UI/Shop/Panel/Label.text = "+2 Maxima Combustible"
		$Camera2D/UI/Shop/Panel2/Label.text = "+2 Aceleración"
		$Camera2D/UI/Shop/Panel3/Label.text = "+1,000 Fuerza del Resorte"
		$Camera2D/UI/Shop/Panel4/Label.text = "+50 Límite Térmico"
	else:
		$Camera2D/UI/Shop/Panel/Label.text = "+2 Max Fuel"
		$Camera2D/UI/Shop/Panel2/Label.text = "+2 Acceleration"
		$Camera2D/UI/Shop/Panel3/Label.text = "+1,000 Spring Strength"
		$Camera2D/UI/Shop/Panel4/Label.text = "+50 Thermal Limit"
	
	for i in 4:#UI.get_child(2).get_children().size():
		var upgrade = UI.get_child(2).get_child(i)
		if upgradesPurchased[i] < 6:
			if spanish:
				upgrade.get_child(1).text = "Compra - $" + str(upgradeCosts[upgradesPurchased[i]])
			else:
				upgrade.get_child(1).text = "Purchase - $" + str(upgradeCosts[upgradesPurchased[i]])
			if upgrade.get_child(1).button_pressed && Input.is_action_just_pressed("click"):
				if coins >= upgradeCosts[upgradesPurchased[i]]:
					coins -= upgradeCosts[upgradesPurchased[i]]
					upgradesPurchased[i] += 1
					if i == 0:
						maxjetpackFuel += 2
					if i == 1:
						acceleration += 2
					if i == 2:
						springPower += 1000
					if i == 3:
						maxThermal += 50
					$Camera2D/UI/Shop/AudioStreamPlayer.stream = load("res://Sounds/Upgrade" + str(upgradesPurchased[i]) + ".mp3")
					$Camera2D/UI/Shop/AudioStreamPlayer.playing = true
		else:
			upgrade.get_child(1).text = "Upgraded to Max"
			upgrade.get_child(1).disabled = true
