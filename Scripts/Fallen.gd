extends RigidBody2D
class_name Fallen


@export var lifetime_sec: float = 10.0 


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if lifetime_sec > 0.0:
		get_tree().create_timer(lifetime_sec).timeout.connect(queue_free)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("arrows"):
		queue_free()
