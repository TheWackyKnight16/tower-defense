class_name BubbleShield extends Effect

@export var bubble_shield_scene:PackedScene
@export var max_health:int = 10
@export var radius:float = 2
@export var regeneration_time:float = 10.0

func on_slot(turret):
    var bubble_shield = bubble_shield_scene.instantiate()
    bubble_shield.max_health = max_health
    bubble_shield.cur_health = max_health
    bubble_shield.regeneration_time = regeneration_time
    bubble_shield.radius = radius
    turret.add_child(bubble_shield)

func on_unslot(turret):
    turret.get_node("BubbleShield").queue_free()
    