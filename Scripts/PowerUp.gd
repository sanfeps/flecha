extends Fallen
class_name PowerUp

@export var arrow_scene_reward: PackedScene   # flecha que se activa para el siguiente disparo

func _on_area_2d_body_entered(body: Node2D) -> void:
	if not body.is_in_group("arrows"):
		return

	# Buscar el Bow (ajusta el nombre si tu nodo no se llama exactamente "Bow")
	var bow := get_tree().current_scene.get_node_or_null("Bow")
	if bow != null and bow.has_method("set_next_arrow_scene"):
		bow.set_next_arrow_scene(arrow_scene_reward)

	# El power-up se destruye (no llamamos al super porque queremos ESTE efecto)
	queue_free()
	
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
