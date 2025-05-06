class_name Thorns extends Effect

@export var thorns_area_scene:PackedScene
@export var return_damage:float = 0.5

func on_slot(turret):
    var thorns_area = thorns_area_scene.instantiate()
    thorns_area.return_damage = return_damage
    thorns_area.add_to_group("turrets")
    thorns_area.name = "ThornsArea"
    turret.add_child(thorns_area)