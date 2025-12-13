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
