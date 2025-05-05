extends Node3D

@export_category("Turret")
@export var turret_head:Node3D = null
@export var damage:float = 1.0
@export var turret_range:float = 20.0
@export var fire_rate:float = 1.0
@export var turn_speed:float = 1.0
@export var pierce:int = 1
@export var critical_chance:float = 0.0
@export var critical_damage:float = 1.5
@export var projectile_speed:float = 100.0

@export_category("Projectile")
@export var projectile_scene:PackedScene

var base_stats:Dictionary = {
	"damage": 0,
	"turret_range": 0,
	"fire_rate": 0,
	"turn_speed": 0,
	"pierce": 0,
	"critical_chance": 0,
	"critical_damage": 0,
	"projectile_speed": 0
}

var final_stats:Dictionary = {}

@export_category("Modifiers")
@export var testing_modifier:Resource
var mods:Array = []

var turret_firing_timer:float = 0.0
var enemies_in_range:Array[Node3D]

var range_collision_shape:CollisionShape3D
var range_mesh_instance:MeshInstance3D

func _ready():
	add_to_group("turrets")

	range_collision_shape = $RangeArea/CollisionShape3D
	range_mesh_instance =$RangeArea/MeshInstance3D
	range_collision_shape.shape.radius = turret_range
	range_mesh_instance.mesh.radius = turret_range

	base_stats = {
		"damage": damage,
		"turret_range": turret_range,
		"fire_rate": fire_rate,
		"turn_speed": turn_speed,
		"pierce": pierce,
		"critical_chance": critical_chance,
		"critical_damage": critical_damage,
		"projectile_speed": projectile_speed
	}

	if testing_modifier != null:
		slot_card(testing_modifier)

func _process(_delta):
	projectile_fire(_delta)

func projectile_fire(delta, target: Node3D = null):
	if target == null:
		target = find_closest_enemy()
		if target == null:
			return

	# Turn
	var target_direction = atan2(target.global_position.x - global_position.x, target.global_position.z - global_position.z)
	turret_head.rotation.y = move_toward(turret_head.rotation.y, target_direction, final_stats["turn_speed"] * delta)

	if turret_firing_timer < final_stats["fire_rate"]:
		turret_firing_timer += delta
		return

	# Fire
	if abs(turret_head.rotation.y) <= abs(target_direction) + deg_to_rad(5) && abs(turret_head.rotation.y) >= abs(target_direction) - deg_to_rad(5):
		var proj = projectile_scene.instantiate()
		proj.speed = final_stats["projectile_speed"]
		proj.damage = final_stats["damage"]
		proj.max_pierce = final_stats["pierce"]
		proj.pierce = proj.max_pierce
		critical_chance = final_stats["critical_chance"]
		proj.hit_callbacks = []
		
		for effect in mods:
			if effect.has_method("on_projectile_spawned"):
				effect.on_projectile_spawned(self, proj)
		
		for effect in mods:
			if effect.has_method("on_projectile_hit"):
				proj.hit_callbacks.append(Callable(effect, "on_projectile_hit"))

		critical_damage = get_stat("critical_damage")
		if randf() < critical_chance:
			proj.damage *= critical_damage
		
		proj.transform.origin = Vector3(global_position.x, 1, global_position.z)
		proj.target_direction = (Vector3(target.global_position.x, 1, target.global_position .z) - Vector3(global_position.x, 1, global_position.z))
		proj.add_to_group("projectiles")
		get_tree().current_scene.add_child(proj)
		turret_firing_timer = 0.0

func get_stat(stat_name: String) -> float:
	var value = base_stats.get(stat_name, 0)
	for effect in mods:
		if effect.mode == Effect.MODE.ADDITIVE:
			value = effect.modify(stat_name, value)
	
	for effect in mods:
		if effect.mode == Effect.MODE.MULTIPLICATIVE:
			value = effect.modify(stat_name, value)

	return value

func slot_card(card_res: Resource):
	for effect in card_res.effects:
		mods.append(effect)
		print(effect)
		if effect.has_method("on_slot"):
			effect.on_slot(self)
		
	mods.sort_custom(func(a,b): return a.priortiy - b.priortiy)

	final_stats = base_stats.duplicate()
	for effect in mods:
		for stat_name in final_stats.keys():
			if effect.mode == Effect.MODE.ADDITIVE:
				final_stats[stat_name] = effect.modify(stat_name, final_stats[stat_name])
			if effect.mode == Effect.MODE.MULTIPLICATIVE:
				final_stats[stat_name] = effect.modify(stat_name, final_stats[stat_name])
	
	print(final_stats)

func unslot_card(card_res: Resource):
	for effect in card_res.effects:
		if effect.has_method("on_unslot"):
			effect.on_unslot(self)
		mods.erase(effect)

func find_closest_enemy() -> Node3D:
	if enemies_in_range.size() == 0:
		return null
	
	enemies_in_range.sort_custom(sort_enemies_by_distance)
	var closest_enemy = enemies_in_range[0]
	return closest_enemy

func sort_enemies_by_distance(a:Node3D, b:Node3D):
	return a.global_position.distance_squared_to(global_position) < b.global_position.distance_squared_to(global_position)

func _on_range_area_body_entered(body:Node3D):
	if body.is_in_group("enemies"):
		enemies_in_range.append(body)

func _on_range_area_body_exited(body:Node3D):
	if body.is_in_group("enemies"):
		enemies_in_range.erase(body)

func toggle_range_visibility(visibility:bool):
	$RangeArea/MeshInstance3D.visible = visibility
	
