extends Projectile

var target_position:Vector3

var frequency:float = 16.0
var amplitude:float = 0.07

var time: float = 0.0

func _process(delta):
    time += delta

    var to_target = ((target_position + Vector3(0, 1, 0)) - global_position).normalized()
    global_position += to_target * speed * delta

    var sine_offset = sin(time * frequency) * amplitude
    var perp = to_target.cross(Vector3.UP).normalized()
    global_position += perp * sine_offset

    if global_position.distance_squared_to((target_position + Vector3(0, 1, 0))) < 0.05:
        print("Target reached")
        for callbacks in hit_callbacks:
            callbacks.call(self, null)
        queue_free()