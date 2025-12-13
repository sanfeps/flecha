extends Node2D
class_name Spawner

@export var falling_scene: PackedScene
@export var powerup_scenes: Array[PackedScene]
@export var powerup_chance: float = 0.10

@export var x_min: float = 60.0
@export var x_max: float = 1020.0
@export var y_spawn: float = -80.0

@export var base_interval: float = 0.8  # tiempo entre spawns "normales"

var _running := false

func _ready() -> void:
	start()

func start() -> void:
	if _running: return
	_running = true
	_run_loop()

func stop() -> void:
	_running = false

func spawn_one_at(x: float, y: float) -> Node2D:
	var scene: PackedScene = falling_scene
	if powerup_scenes.size() > 0 and randf() < powerup_chance:
		scene = powerup_scenes[randi() % powerup_scenes.size()]

	var obj := scene.instantiate() as Node2D
	get_tree().current_scene.add_child(obj)
	obj.global_position = Vector2(x, y)
	return obj

func _run_loop() -> void:
	# Bucle infinito de patrones
	while _running:
		# Elige un patrón al azar (puedes hacer pesos luego)
		var r := randi() % 3
		if r == 0:
			await PatternRow.run(self)
		elif r == 1:
			await PatternDiagonalSweep.run(self)
		else:
			await PatternRandom.run(self)

		# descanso pequeño entre patrones
		await get_tree().create_timer(0.6).timeout
