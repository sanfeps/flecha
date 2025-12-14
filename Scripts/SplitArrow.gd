extends ArrowBase
class_name SplitArrow

@export var child_arrow_scene: PackedScene   # la flecha “normal” que se va a spawnear
@export var count: int = 10                  # cuántas flechas salen
@export var spawn_speed: float = 1400.0      # velocidad de las hijas
@export var keep_parent_speed: bool = true   # si true, usa la velocidad actual de la flecha
@export var spawn_radius: float = 18.0       # para que no nazcan todas en el mismo punto exacto

# Dispersión:
@export var full_circle: bool = true         # true = 360º, false = cono
@export var cone_deg: float = 90.0           # si full_circle=false, ancho del cono
@export var cone_center_uses_velocity: bool = true  # cono centrado en dirección actual

func _do_special() -> void:
	if child_arrow_scene == null:
		return

	var base_speed: float = spawn_speed
	if keep_parent_speed:
		base_speed = max(linear_velocity.length(), 50.0)

	var center_angle: float = 0.0
	if cone_center_uses_velocity and linear_velocity.length() > 1.0:
		center_angle = linear_velocity.angle()
	else:
		center_angle = rotation  # si prefieres

	if full_circle:
		for i in range(count):
			var ang: float = TAU * float(i) / float(count)
			_spawn_child(ang, base_speed)
	else:
		var half: float = deg_to_rad(cone_deg) * 0.5
		for i in range(count):
			var t: float = 0.0
			if count > 1:
				t = float(i) / float(count - 1)  # 0..1
			var ang: float = center_angle + lerp(-half, half, t)
			_spawn_child(ang, base_speed)

	queue_free()

func _spawn_child(angle_rad: float, speed: float) -> void:
	var a := child_arrow_scene.instantiate()
	get_tree().current_scene.add_child(a)

	var dir := Vector2.RIGHT.rotated(angle_rad).normalized()

	# Pequeño offset para evitar colisión instantánea entre ellas
	(a as Node2D).global_position = global_position + dir * spawn_radius

	if a is RigidBody2D:
		a.linear_velocity = dir * speed
		# Si tus flechas se auto-orientan en ArrowBase, no hace falta,
		# pero esto evita el “primer frame raro”:
		a.rotation = dir.angle() + deg_to_rad(90.0)
