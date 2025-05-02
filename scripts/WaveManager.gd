extends Node3D

var ENEMY_SCENE = preload("res://scenes/enemy.tscn")

var spawn_delay:float = 3.0
var spawn_timer:float = 0.0

var spawn_group_size:int = 10
var spawn_groups:Array[Node3D]
var spawn_points:Array[Marker3D]

func _ready():
    for child in get_children():
        spawn_groups.append(child)

func _process(delta):
    spawn_timer += delta
    if spawn_timer >= spawn_delay:
        spawn_timer = 0.0
        spawn_points.clear()
        # choose a spawn group then spawn in spawn points
        var spawn_group = spawn_groups[randi() % spawn_groups.size()]
        for child in spawn_group.get_children():
            spawn_points.append(child)
        for _i in range(spawn_group_size):
            spawn()

func spawn():
    var enemy = ENEMY_SCENE.instantiate()
    add_child(enemy)
    var spawn_point = spawn_points[randi() % spawn_points.size()]
    spawn_points.erase(spawn_point)

    enemy.global_position = spawn_point.global_position