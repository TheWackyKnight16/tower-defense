class_name MissileTurret extends Effect

@export var markers_scene:PackedScene
@export var fire_rate:float = 2.0

var markers_scene_instance = null
var markers:Array = []
var prev_target:Node3D

func on_projectile_spawned(_turret, _proj):
	if _turret.shots_fired <= 0:
		print("No shots fired yet")
		markers.clear()

		markers_scene_instance = markers_scene.instantiate()
		_turret.add_child(markers_scene_instance)
		markers_scene_instance.global_position = _turret.target.global_position
		markers_scene_instance.look_at(_turret.global_position)

		for marker in markers_scene_instance.get_children():
			markers.append(marker.global_position)

		prev_target = _turret.target
	
	if markers.size() > 0:
		_proj.target_position = markers[_turret.shots_fired - 1]
	
	_turret.shots_fired += 1

	if _turret.shots_fired >= markers.size() || _turret.target == null || _turret.target != prev_target:
		if markers_scene_instance != null:
			markers_scene_instance.queue_free()
			_turret.turret_firing_timer -= fire_rate
			_turret.shots_fired = 0
	
	if markers_scene_instance == null:
		_proj.queue_free()
