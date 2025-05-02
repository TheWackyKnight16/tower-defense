class_name Enemy
extends CharacterBody3D

@export var max_health:int = 5
@export var speed:float = 10
@export var damage:int = 1

var cur_health:int = max_health
var target = null

var anim: AnimationPlayer

func _ready():
    add_to_group("enemies")

    anim = get_node("TempEnemy/AnimationPlayer")
    anim.play("ArmatureAction")

func _process(_delta):
    move_to_target()

func move_to_target():
    if target == null:
        target = find_closest_turret()
        if target == null:
            #queue_free()
            return
    
    var direction = (target.global_position - global_position).normalized()
    velocity = direction * speed
    move_and_slide()

    look_at(target.global_position)
    rotation.y += deg_to_rad(90)

func find_closest_turret():
    var turrets = get_tree().get_nodes_in_group("turrets")
    var closest_turret = null
    var closest_dist = 1000000

    for turret in turrets:
        var dist = global_position.distance_squared_to(turret.global_position)
        if dist < closest_dist:
            closest_dist = dist
            closest_turret = turret

    return closest_turret

func take_damage(taken_damage):
    cur_health -= taken_damage
    if cur_health <= 0:
        queue_free()
