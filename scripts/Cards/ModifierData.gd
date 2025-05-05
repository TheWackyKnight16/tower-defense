extends Resource
class_name CardModifier

@export var modifier_name: String = "Unnamed Modifier"
@export_multiline var description: String = ""
# @export var icon: Texture # Optional icon for UI

# --- Common Stat Modifiers ---
@export var add_damage: int = 0
@export var multiply_damage: float = 1.0 # Use 1.0 for no change
@export var add_range: float = 0.0
@export var multiply_range: float = 1.0
@export var add_fire_rate: float = 0.0 # Note: Positive value increases shots/sec (reduces delay)
@export var multiply_fire_rate: float = 1.0
@export var add_crit_chance: float = 0.0 # 0.0 to 1.0
@export var add_crit_damage_multiplier: float = 0.0 # e.g., 0.5 for +50% crit damage
@export var add_pierce: int = 0
@export var multiply_projectile_speed: float = 1.0
@export var multiply_turret_rotation_speed: float = 1.0

# --- Flags/Data for Special Effects ---
@export var adds_burn: bool = false
@export var burn_chance: float = 0.0
@export var burn_damage: int = 0
@export var burn_duration: float = 0.0

@export var adds_explosion: bool = false
@export var explosion_radius: float = 0.0
@export var explosion_damage: int = 0

@export var enables_supercharge: bool = false
@export var supercharge_every_n_shots: int = 4
@export var supercharge_pierce: int = 2
@export var supercharge_damage_multiplier: float = 1.15
@export var supercharge_size_multiplier: float = 1.5
@export var supercharge_reload_penalty: float = 0.2 # Extra time added after supercharge shot

@export var enables_proximity_damage: bool = false
@export var proximity_max_bonus_damage: int = 10
@export var proximity_min_distance: float = 1.0 # Distance for max bonus
@export var proximity_max_distance: float = 10.0 # Distance for no bonus (lerps between)

@export var enables_thorns: bool = false
@export var thorns_damage: int = 1

@export var enables_force_field: bool = false
@export var force_field_health: int = 100

# Add more flags/data fields as needed for other effects

# Optional: Methods if a modifier needs complex setup/cleanup logic
# func apply_modifier(turret):
#     pass
# func remove_modifier(turret):
#     pass