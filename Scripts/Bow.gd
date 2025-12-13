extends Node2D

@export var normal_arrow_scene: PackedScene   # pon aquí la flecha normal (antes era arrow_scene)
var _next_arrow_scene: PackedScene = null     # la que da el power-up (solo 1 tiro)
@onready var muzzle: Marker2D = $Marker2D

@export var angle_left_deg: float = -170.0
@export var angle_right_deg: float = -10.0

@export var min_shot_speed: float = 800.0
@export var max_shot_speed: float = 2200.0

@export var max_pull_px: float = 400.0
@export var sprite_offset_deg: float = 90.0

@export var min_charge: float = 0.0
@export var max_charge: float = 1.0

# TAP
@export var tap_max_dist_px: float = 20.0
@export var tap_max_time_ms: int = 220

# NUEVO: cuánto tienes que arrastrar para considerar que NO es tap
@export var drag_start_dist_px: float = 15.0

var _touching: bool = false
var _touch_id: int = -1
var _has_dragged: bool = false   # <-- NUEVO

var _start_pos: Vector2 = Vector2.ZERO
var _tap_start_pos: Vector2 = Vector2.ZERO
var _tap_start_ms: int = 0

var _aim_angle_rad: float = 0.0
var _aim_dir: Vector2 = Vector2.RIGHT
var _charge: float = 0.0

var _last_arrow: Node = null

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and not _touching:
			# Inicio de gesto (puede acabar siendo tap o drag)
			_touching = true
			_touch_id = event.index
			_has_dragged = false

			_start_pos = event.position
			_tap_start_pos = event.position
			_tap_start_ms = Time.get_ticks_msec()

			_charge = min_charge
			_update_from_screen(event.position)

		elif (not event.pressed) and _touching and event.index == _touch_id:
			# Fin de gesto: decidimos si fue TAP o DISPARO
			_touching = false
			_touch_id = -1

			var dt: int = Time.get_ticks_msec() - _tap_start_ms
			var dist: float = (event.position - _tap_start_pos).length()

			if (not _has_dragged) and dt <= tap_max_time_ms and dist <= tap_max_dist_px:
				_try_activate_last_arrow_special()
			else:
				_fire_arrow()

			_charge = min_charge

	elif event is InputEventScreenDrag:
		if _touching and event.index == _touch_id:
			# Si te has movido lo suficiente, ya NO es tap
			var moved: float = (event.position - _start_pos).length()
			if moved > drag_start_dist_px:
				_has_dragged = true

			_update_from_screen(event.position)

func _update_from_screen(p: Vector2) -> void:
	var size: Vector2 = get_viewport_rect().size
	if size.x <= 0.0 or size.y <= 0.0:
		return

	# X -> ángulo (invertido)
	var t_x: float = clamp(p.x / size.x, 0.0, 1.0)
	t_x = 1.0 - t_x
	var ang_deg: float = lerp(angle_left_deg, angle_right_deg, t_x)
	_aim_angle_rad = deg_to_rad(ang_deg)

	rotation = _aim_angle_rad + deg_to_rad(sprite_offset_deg)

	# Y -> carga (solo hacia abajo desde el inicio)
	var dy: float = p.y - _start_pos.y
	var t_y: float = clamp(dy / max_pull_px, 0.0, 1.0)
	_charge = lerp(min_charge, max_charge, t_y)

	_aim_dir = Vector2.RIGHT.rotated(_aim_angle_rad).normalized()

func _fire_arrow() -> void:
	var scene_to_fire: PackedScene = _next_arrow_scene if _next_arrow_scene != null else normal_arrow_scene
	if scene_to_fire == null:
		return

	# consume el power-up (solo 1 disparo)
	_next_arrow_scene = null

	var dir: Vector2 = _aim_dir
	var speed: float = lerp(min_shot_speed, max_shot_speed, _charge)
	var v: Vector2 = dir * speed

	var arrow := scene_to_fire.instantiate()
	get_tree().current_scene.add_child(arrow)

	(arrow as Node2D).global_position = muzzle.global_position

	# si todas tus flechas heredan de ArrowBase (recomendado)
	if arrow is ArrowBase:
		arrow.init_with_velocity(v)
	elif arrow is RigidBody2D:
		arrow.linear_velocity = v

	_last_arrow = arrow


func _try_activate_last_arrow_special() -> void:
	if _last_arrow == null:
		return
	if not is_instance_valid(_last_arrow):
		_last_arrow = null
		return
	if _last_arrow.has_method("activate_special"):
		_last_arrow.activate_special()

func set_next_arrow_scene(scene: PackedScene) -> void:
	_next_arrow_scene = scene
