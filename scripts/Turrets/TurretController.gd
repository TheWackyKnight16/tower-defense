extends Node3D

@export_category("Turret Config")
@export var turret_head:Node3D
@export var config: Resource

var base_stats:Dictionary = {
	"damage": 0,
	"turret_range": 0,
	"fire_rate": 0,
	"turn_speed": 0,
	"pierce": 0,
	"critical_chance": 0,
	"critical_damage": 0,
	"projectile_speed": 0,
	"pellets": 0,
	"spread": 0,
	"prjectile_size": 0
}

var final_stats:Dictionary = {}

@export_category("Modifiers")
@export var testing_modifier:Resource
var mods:Array = []

var turret_firing_timer:float = 0.0
var enemies_in_range:Array[Node3D]
var distance_to_target:float = 0.0
var barrels:Array
var shot_count:int = 0

var range_collision_shape:CollisionShape3D
var range_mesh_instance:MeshInstance3D

func _ready():
	add_to_group("turrets")

	range_collision_shape = $RangeArea/CollisionShape3D
	range_mesh_instance =$RangeArea/MeshInstance3D

	for child in $TurretHead/Barrels.get_children():
		barrels.append(child)

	if config != null:
		base_stats = {
			"damage": config.damage,
			"turret_range": config.turret_range,
			"fire_rate": config.fire_rate,
			"turn_speed": config.turn_speed,
			"pierce": config.pierce,
			"critical_chance": config.critical_chance,
			"critical_damage": config.critical_damage,
			"projectile_speed": config.projectile_speed,
			"pellets": config.pellets,
			"spread": config.spread,
			"projectile_size": config.projectile_size
		}

	if testing_modifier != null:
		slot_card(testing_modifier)
	update_final_stats()

func _process(_delta):
	projectile_fire(_delta)

func projectile_fire(delta, target: Node3D = null):
	if target == null:
		target = find_closest_enemy()
		if target == null:
			return

	distance_to_target = global_position.distance_squared_to(target.global_position)

	# Turn
	var target_direction = atan2(target.global_position.x - global_position.x, target.global_position.z - global_position.z)
	turret_head.rotation.y = move_toward(turret_head.rotation.y, target_direction, final_stats["turn_speed"] * delta)

	if turret_firing_timer < final_stats["fire_rate"]:
		turret_firing_timer += delta
		return

	for i in range(final_stats["pellets"]):
		var random_spread = randf_range(-final_stats["spread"], final_stats["spread"])
		# Fire
		if abs(turret_head.rotation.y) <= abs(target_direction) + deg_to_rad(5) && abs(turret_head.rotation.y) >= abs(target_direction) - deg_to_rad(5):
			var proj = config.projectile_scene.instantiate()
			proj.speed = final_stats["projectile_speed"]
			proj.damage = final_stats["damage"]
			proj.max_pierce = final_stats["pierce"]
			proj.pierce = proj.max_pierce
			config.critical_chance = final_stats["critical_chance"]
			proj.hit_callbacks = []
			
			for effect in mods:
				if effect.has_method("on_projectile_spawned"):
					effect.on_projectile_spawned(self, proj)
			
			for effect in mods:
				if effect.has_method("on_projectile_hit"):
					proj.hit_callbacks.append(Callable(effect, "on_projectile_hit"))

			config.critical_damage = final_stats["critical_damage"]
			if randf() < config.critical_chance:
				proj.damage *= config.critical_damage
			
			proj.size = final_stats["projectile_size"]
			if barrels.size() > 0:
				var barrel = barrels[shot_count % barrels.size()]
				var barrel_position = barrel.global_position
				proj.transform.origin = Vector3(barrel_position.x, 1, barrel_position.z)
				proj.target_direction = (Vector3(target.global_position.x + random_spread, 1, target.global_position .z + random_spread) - Vector3(barrel_position.x, 1, barrel_position.z))
				shot_count += 1
				if shot_count >= barrels.size():
					shot_count = 0
			else:
				proj.transform.origin = Vector3(global_position.x, 1, global_position.z)
				proj.target_direction = (Vector3(target.global_position.x + random_spread, 1, target.global_position .z + random_spread) - Vector3(global_position.x, 1, global_position.z))
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
	if card_res.turret_config != null:
		config = card_res.turret_config
		update_base_stats()

	for effect in card_res.effects:
		mods.append(effect)
		if effect.has_method("on_slot"):
			effect.on_slot(self)
		
	mods.sort_custom(func(a,b): return a.priortiy - b.priortiy)

	update_final_stats()

func unslot_card(card_res: Resource):
	for effect in card_res.effects:
		if effect.has_method("on_unslot"):
			effect.on_unslot(self)
		mods.erase(effect)

func update_base_stats():
	if config == null:
		return
	
	base_stats = {
		"damage": config.damage,
		"turret_range": config.turret_range,
		"fire_rate": config.fire_rate,
		"turn_speed": config.turn_speed,
		"pierce": config.pierce,
		"critical_chance": config.critical_chance,
		"critical_damage": config.critical_damage,
		"projectile_speed": config.projectile_speed,
		"pellets": config.pellets,
		"spread": config.spread,
		"projectile_size": config.projectile_size
	}

func update_final_stats():
	final_stats = base_stats.duplicate()
	for effect in mods:
		for stat_name in final_stats.keys():
			if effect.mode == Effect.MODE.ADDITIVE:
				final_stats[stat_name] = effect.modify(stat_name, final_stats[stat_name])
			if effect.mode == Effect.MODE.MULTIPLICATIVE:
				final_stats[stat_name] = effect.modify(stat_name, final_stats[stat_name])
	
	range_collision_shape.shape.radius = config.turret_range
	range_mesh_instance.mesh.radius = config.turret_range
	print(final_stats)

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
	
