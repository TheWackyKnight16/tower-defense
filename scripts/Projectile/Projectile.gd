extends Node3D

@onready var collision_area = $CollisionArea
@onready var detection_area = $DetectionArea

var projectile_data:ProjectileData

var damage:int = 0
var speed:float = 0.0

var max_pierce:int = 0
var pierce:int = 0

var is_explosive:bool = false
var explosion_radius:float = 0.0
var explosive_damage:float = 0.0

var is_homing:bool = false
var homing_speed:float = 0.0

var applies_effect:bool = false
var effect_duration:float = 0.0
# effect data

var target_direction:Vector3

var enemies_in_area:Array[Node3D]
var elapsed_time:float = 0.0

func _ready():
	damage = projectile_data.damage
	speed = projectile_data.speed

	max_pierce = projectile_data.max_pierce
	pierce = max_pierce

	is_explosive = projectile_data.is_explosive
	explosion_radius = projectile_data.explosion_radius
	explosive_damage = projectile_data.explosive_damage

	is_homing = projectile_data.is_homing
	homing_speed = projectile_data.homing_speed

	applies_effect = projectile_data.applies_effect
	effect_duration = projectile_data.effect_duration


	if target_direction == null:
		queue_free()
		return

	if is_explosive:
		detection_area.monitoring = true
		detection_area.get_child(0).shape.radius = explosion_radius

func _process(_delta):
	global_position += target_direction.normalized() * speed * _delta

	elapsed_time += _delta
	if elapsed_time >= 10:
		queue_free()

func _on_collision_area_body_entered(body:Node3D):
	if body.is_in_group("enemies"):
		pierce -= 1
		body.take_damage(damage)
		if pierce <= 0:
			if is_explosive:
				explode()
			elif applies_effect:
				body.apply_effect("effect data", effect_duration)
			else:
				queue_free()

func explode():
	for enemy in enemies_in_area:
		if enemy != null:
			enemy.take_damage(damage)
	queue_free()

func _on_detection_area_body_entered(body:Node3D):
	enemies_in_area.append(body)

func _on_detection_area_body_exited(body:Node3D):
	enemies_in_area.erase(body)
