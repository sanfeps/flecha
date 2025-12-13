extends Node
class_name PatternRow

static func run(spawner: Spawner) -> void:
	var count: int = randi_range(4, 8)
	var margin: float = 80.0
	var x0: float = spawner.x_min + margin
	var x1: float = spawner.x_max - margin

	for i in range(count):
		var t: float = float(i) / max(1.0, float(count - 1))
		var x: float = lerp(x0, x1, t)
		spawner.spawn_one_at(x, spawner.y_spawn)

		# si quieres que caigan "en fila temporal", añade delay
		await spawner.get_tree().create_timer(0.08).timeout
