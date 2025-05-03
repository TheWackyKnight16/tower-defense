extends Node3D

@export var screen_sprite: Sprite3D
@export var sub_viewport: SubViewport

@onready var screen_camera = sub_viewport.get_node("Camera3D")
@onready var cursor = sub_viewport.get_node("CRTShader/Cursor")

var turret = preload("res://scenes/turrets/turret_test.tscn")

var screen_collider_body: StaticBody3D
var main_camera: Camera3D
var turret_highlight: Node3D
var selected_object

var max_turrets: int = 3
var turret_count: int = 0

var result_screen
var shape_result_screen
var cursor_offset

var mouse_on_screen: bool = false
var is_hovering_button:bool = false
var turret_placement_mode:bool = false
var max_turrets_reached:bool = false
var object_selected:bool = false

func _ready():
	turret_highlight = turret.instantiate()

func _process(_delta):
	if turret_count >= max_turrets:
		max_turrets_reached = true

	if turret_highlight != null && mouse_on_screen:
		if result_screen && result_screen.has("position"):
			turret_highlight.transform.origin = result_screen.position
			if max_turrets_reached:
				turret_highlight.queue_free()
				turret_highlight = null

	if Input.is_action_just_pressed("left_click"):
		if mouse_on_screen && turret_placement_mode:
			if max_turrets_reached:
				print("Max turrets reached.")
				turret_placement_mode = false
				return
			
			if turret_placement_mode && !max_turrets_reached && result_screen:
				var instance = turret.instantiate()
				instance.transform.origin = result_screen.position
				instance.toggle_range_visibility(false)

				get_tree().current_scene.add_child(instance)
				turret_count += 1

		toggle_turret_placement_mode()

	object_selection()

func object_selection():
	if mouse_on_screen:
		if !object_selected:
			Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

		if Input.is_action_just_pressed("left_click") && !turret_placement_mode && shape_result_screen.size() > 0:
			var turret_colliders: Array
			for object in shape_result_screen:
				if !object.has("collider"):
					return
				if object.collider.is_in_group("turrets"):
					turret_colliders.append(object.collider)

			if turret_colliders.size() > 0:
				var selected_turret = turret_colliders[0]
				if selected_turret.is_in_group("turrets"):
					object_selected = true
					selected_object = selected_turret.get_parent()
					cursor.position = screen_camera.unproject_position(selected_object.position) - cursor_offset
					Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			else:
				object_selected = false
				selected_object = null
			
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func toggle_turret_placement_mode():
	if is_hovering_button && turret_placement_mode == true:
		if turret_highlight != null:
			turret_highlight.queue_free()
			turret_highlight = null
		turret_placement_mode = false
		print("Turret placement mode off: " + str(turret_placement_mode))
	elif is_hovering_button && turret_placement_mode == false:
		if !max_turrets_reached:
			turret_highlight = turret.instantiate()
			get_tree().current_scene.add_child(turret_highlight)
		turret_placement_mode = true
		print("Turret placement mode on: " + str(turret_placement_mode))

func _on_turret_placement_button_mouse_entered():
	is_hovering_button = true

func _on_turret_placement_button_mouse_exited():
	is_hovering_button = false

func _input(event):
	if event is InputEventMouseMotion:
		main_camera = get_viewport().get_camera_3d()

		var mouse_pos = event.position
		var ray_origin_main = main_camera.project_ray_origin(mouse_pos)
		var ray_end_main = ray_origin_main + main_camera.project_ray_normal(mouse_pos) * 2000

		var query_main = PhysicsRayQueryParameters3D.create(ray_origin_main, ray_end_main)

		var space_state_main = get_world_3d().direct_space_state
		var result_main = space_state_main.intersect_ray(query_main)

		if result_main and result_main.has("collider") and result_main.collider.is_in_group("screen"):
			mouse_on_screen = true

			screen_collider_body = result_main.collider

			var global_hit_pos = result_main.position
			var local_hit_pos = screen_sprite.to_local(global_hit_pos)

			var texture = sub_viewport.get_texture()

			var pixel_size = screen_sprite.pixel_size
			var sprite_width = texture.get_width() * pixel_size
			var sprite_height = texture.get_height() * pixel_size

			var norm_x = 0.0
			var norm_y = 0.0
			if screen_sprite.centered:
				norm_x = (local_hit_pos.x / sprite_width) + 0.5
				norm_y = (-local_hit_pos.y / sprite_height) + 0.5
			else:
				norm_x = local_hit_pos.x / sprite_width
				norm_y = -local_hit_pos.y / sprite_height

			var viewport_size = sub_viewport.size
			var viewport_pos = Vector2(norm_x, norm_y) * Vector2(viewport_size)

			# Set the cursor position
			cursor_offset = Vector2(cursor.size.x / 2, cursor.size.y / 2)
			if !object_selected:
				cursor.position = viewport_pos - cursor_offset

			viewport_pos.x = clampf(viewport_pos.x, 0.0, viewport_size.x - 1)
			viewport_pos.y = clampf(viewport_pos.y, 0.0, viewport_size.y - 1)

			var space_state_screen = screen_camera.get_world_3d().direct_space_state

			var ray_origin_screen = screen_camera.project_ray_origin(viewport_pos)
			var ray_end_screen = ray_origin_screen + screen_camera.project_ray_normal(viewport_pos) * 1000

			var query_screen = PhysicsRayQueryParameters3D.create(ray_origin_screen, ray_end_screen)
			query_screen.collision_mask = 8
			result_screen = space_state_screen.intersect_ray(query_screen)

			if result_screen.has("position"):
				var shape_query_screen = PhysicsShapeQueryParameters3D.new()
				shape_query_screen.shape = BoxShape3D.new()
				shape_query_screen.shape.size = Vector3(6, 6, 6)
				shape_query_screen.transform.origin = result_screen.position

				shape_result_screen = space_state_screen.intersect_shape(shape_query_screen, 8)
		else:
			mouse_on_screen = false
		
			
