extends Node2D

@export var normal_arrow_scene: PackedScene
var _next_arrow_scene: PackedScene = null

@onready var muzzle: Marker2D = $Muzzle

# --- Cuerda + preview ---
@onready var string_line: Line2D = $String
@onready var left_tip: Marker2D = $LeftTip
@onready var right_tip: Marker2D = $RightTip
@onready var nock: Marker2D = $Nock 
@onready var arrow_preview: Sprite2D = $ArrowPreview

var _nock_rest_pos: Vector2 = Vector2.ZERO

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

# Cuánto tienes que arrastrar para considerar que NO es tap
@export var drag_start_dist_px: float = 15.0

# Offset visual del preview (si tu sprite mira hacia arriba, suele ser -90)
@export var arrow_preview_offset_deg: float = 0

# Si cargas un poquito, ya cuenta como "drag" para que al soltar dispare
@export var charge_drag_threshold: float = 0.02

var _touching: bool = false
var _touch_id: int = -1
var _has_dragged: bool = false

var _start_pos: Vector2 = Vector2.ZERO
var _tap_start_pos: Vector2 = Vector2.ZERO
var _tap_start_ms: int = 0

var _aim_angle_rad: float = 0.0
var _aim_dir: Vector2 = Vector2.RIGHT
var _charge: float = 0.0

var _last_arrow: Node = null

func _ready() -> void:
	_nock_rest_pos = nock.position
	_update_string()
	_recompute_aim_from_bow_rotation()
	_reset_pull_visual()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and not _touching:
			_touching = true
			_touch_id = event.index
			_has_dragged = false

			_start_pos = event.position
			_tap_start_pos = event.position
			_tap_start_ms = Time.get_ticks_msec()

			_charge = min_charge
			_update_from_screen(event.position)

		elif (not event.pressed) and _touching and event.index == _touch_id:
			_touching = false
			_touch_id = -1

			var dt: int = Time.get_ticks_msec() - _tap_start_ms
			var dist: float = (event.position - _tap_start_pos).length()

			if (not _has_dragged) and dt <= tap_max_time_ms and dist <= tap_max_dist_px:
				_try_activate_last_arrow_special()
			else:
				_fire_arrow()

			_charge = min_charge
			_reset_pull_visual()

	elif event is InputEventScreenDrag:
		if _touching and event.index == _touch_id:
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

	# Rotación visual del arco (incluye offset del sprite del arco)
	rotation = _aim_angle_rad + deg_to_rad(sprite_offset_deg)

	# Y -> carga (solo hacia abajo desde el inicio)
	var dy: float = p.y - _start_pos.y
	var t_y: float = clamp(dy / max_pull_px, 0.0, 1.0)
	_charge = lerp(min_charge, max_charge, t_y)

	# Si hay carga, no lo consideramos tap
	if _charge > charge_drag_threshold:
		_has_dragged = true

	# Dirección física del disparo (sin offset visual)
	_aim_dir = Vector2.RIGHT.rotated(_aim_angle_rad).normalized()

	# Visual: cuerda + preview
	_set_pull_visual(_charge * max_pull_px)

func _fire_arrow() -> void:
	var scene_to_fire: PackedScene = _next_arrow_scene if _next_arrow_scene != null else normal_arrow_scene
	if scene_to_fire == null:
		return

	_next_arrow_scene = null

	# 🔒 CONGELAMOS valores en el momento del disparo
	var dir: Vector2 = _aim_dir
	var charge: float = _charge

	if charge <= 0.001:
		return  # seguridad extra

	var speed: float = lerp(min_shot_speed, max_shot_speed, charge)
	var v: Vector2 = dir * speed

	var arrow := scene_to_fire.instantiate()
	get_tree().current_scene.add_child(arrow)

	(arrow as Node2D).global_position = muzzle.global_position

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

# -------------------------
# VISUAL: CUERDA + PREVIEW
# -------------------------

func _recompute_aim_from_bow_rotation() -> void:
	var aim_angle: float = rotation - deg_to_rad(sprite_offset_deg)
	_aim_dir = Vector2.RIGHT.rotated(aim_angle).normalized()

func _set_pull_visual(pull_px: float) -> void:
	var clamped_pull: float = clamp(pull_px, 0.0, max_pull_px)
	nock.position = _nock_rest_pos + Vector2(0.0, _nock_rest_pos.y + clamped_pull)
	arrow_preview.position = nock.position
	var preview_vec: Vector2 = muzzle.global_position - arrow_preview.global_position
	if preview_vec.length() > 0.001:
		arrow_preview.global_rotation = preview_vec.angle() + deg_to_rad(arrow_preview_offset_deg)
	_update_string()

func _reset_pull_visual() -> void:
	nock.position = _nock_rest_pos
	arrow_preview.position = _nock_rest_pos
	_recompute_aim_from_bow_rotation()
	_update_string()

func _update_string() -> void:
	string_line.points = PackedVector2Array([
		left_tip.position,
		nock.position,
		right_tip.position
	])
