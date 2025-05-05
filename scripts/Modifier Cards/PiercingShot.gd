class_name PiercingShot extends Effect

@export var extra_pierce:int = 4
@export var turn_speed_decrease:float = 0.25

func modify(stat_name: String, value: float) -> float:
    if stat_name == "pierce":
        value += extra_pierce
    if stat_name == "turn_speed":
        value *= (1 - turn_speed_decrease)
    return value