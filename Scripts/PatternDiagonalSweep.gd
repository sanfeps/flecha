extends Node
class_name PatternDiagonalSweep

static func run(spawner: Spawner) -> void:
	var steps: int = randi_range(8, 14)
	var left_to_right: bool = randf() < 0.5

	var x_start: float = spawner.x_min
	var x_end: float = spawner.x_max
	if not left_to_right:
		var tmp := x_start
		x_start = x_end
		x_end = tmp

	# “diagonal” = spawnear con X cambiando + pequeño desfase en Y
	for i in range(steps):
		var t: float = float(i) / float(steps - 1)
		var x: float = lerp(x_start, x_end, t)
		var y: float = spawner.y_spawn - i * 14.0  # cuanto más, más inclinada la diagonal

		spawner.spawn_one_at(x, y)
		await spawner.get_tree().create_timer(0.06).timeout
