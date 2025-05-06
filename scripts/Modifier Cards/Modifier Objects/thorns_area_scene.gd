extends Node3D

var return_damage:float = 0.0

func take_damage(damage, source):
    if source.is_in_group("enemies") && source.has_method("take_damage"):
        source.take_damage(damage * return_damage)
        #print("Thorns damage: ", damage * return_damage, " on ", source)