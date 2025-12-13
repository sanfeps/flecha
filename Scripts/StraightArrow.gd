extends ArrowBase
class_name ArrowRedirectUp

@export var keep_speed := true
@export var up_speed := 1800.0

func _do_special() -> void:
	var s: float = linear_velocity.length()
	if not keep_speed:
		s = up_speed
	linear_velocity = Vector2.UP * s
