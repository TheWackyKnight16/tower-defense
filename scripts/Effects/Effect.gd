class_name Effect extends Resource

enum MODE {
    ADDITIVE,
    MULTIPLICATIVE
}

@export_enum("Additive", "Multiplicative") var mode: int = MODE.ADDITIVE
@export var priortiy: int = 0

func modify(_stat_name: String, cur_value: float) -> float:
    return cur_value