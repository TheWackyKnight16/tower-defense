extends Node3D

@onready var collision_area = $CollisionArea
@onready var detection_area = $DetectionArea

var damage:float = 0
var speed:float = 0.0

var max_pierce:int = 0
var pierce:int = 0

var target_direction:Vector3

var hit_callbacks:Array = []
var enemies_in_area:Array[Node3D] = []
var elapsed_time:float = 0.0

func _ready():
	if target_direction == null:
		queue_free()
		return

func _process(_delta):
	global_position += target_direction.normalized() * speed * _delta

	elapsed_time += _delta
	if elapsed_time >= 10:
		queue_free()

func _on_collision_area_body_entered(body:Node3D):
	if body.is_in_group("enemies"):
		for callbacks in hit_callbacks:
			callbacks.call(self, body)

		pierce -= 1
		body.take_damage(damage)

		if pierce <= 0:
				queue_free()

func _on_detection_area_body_entered(body:Node3D):
	enemies_in_area.append(body)

func _on_detection_area_body_exited(body:Node3D):
	enemies_in_area.erase(body)
