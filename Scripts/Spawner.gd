extends Node2D

@export var fallenScene: PackedScene
@export var spawn_interval: float = 0.7
@export var x_min: float = 60.0
@export var x_max: float = 1020.0
@export var y_spawn: float = -50.0

func _ready() -> void:
	_spawn_loop()

func _spawn_loop() -> void:
	while true:
		await get_tree().create_timer(spawn_interval).timeout
		_spawn_one()

func _spawn_one() -> void:
	if fallenScene == null:
		return
	var obj := fallenScene.instantiate() as Node2D
	get_tree().current_scene.add_child(obj)
	obj.global_position = Vector2(randf_range(x_min, x_max), y_spawn)
