extends Node
class_name PatternRandom

static func run(spawner: Spawner) -> void:
	var n: int = randi_range(3, 6)
	for _i in range(n):
		var x: float = randf_range(spawner.x_min, spawner.x_max)
		spawner.spawn_one_at(x, spawner.y_spawn)
		await spawner.get_tree().create_timer(spawner.base_interval).timeout
