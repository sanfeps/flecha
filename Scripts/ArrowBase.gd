extends RigidBody2D
class_name ArrowBase

@export var lifetime_sec: float = 8.0   # ⏱️ tiempo de vida de la flecha

@export var sprite_offset_deg: float = 90.0
@export var min_speed_to_rotate: float = 40.0

var _special_used := false
var _last_angle: float = 0.0
var _initialized := false

func _ready() -> void:
	# Autodestrucción
	if lifetime_sec > 0.0:
		get_tree().create_timer(lifetime_sec).timeout.connect(queue_free)

func init_with_velocity(v: Vector2) -> void:
	linear_velocity = v
	if v.length() > 0.01:
		_last_angle = v.angle()
		rotation = _last_angle + deg_to_rad(sprite_offset_deg)
	_initialized = true

func _physics_process(_dt: float) -> void:
	if not _initialized:
		return

	var v := linear_velocity
	if v.length() > min_speed_to_rotate:
		_last_angle = v.angle()
	rotation = _last_angle + deg_to_rad(sprite_offset_deg)

func activate_special() -> void:
	if _special_used:
		return
	_special_used = true
	_do_special()

func _do_special() -> void:
	pass
