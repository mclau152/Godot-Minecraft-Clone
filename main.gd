extends Node3D

const WORLD_SIZE_X = 64
const WORLD_SIZE_Z = 64
const MAX_HEIGHT = 8  # Increased max height for more variation
const NOISE_SCALE = 4.0  # Reduced noise scale for more reasonable heights

@onready var dirt_block = preload("res://dirtblock.tscn")
@onready var grass_block = preload("res://grassblock.tscn")

var noise = FastNoiseLite.new()

func _ready() -> void:
	setup_noise()
	generate_world()

func setup_noise() -> void:
	noise.seed = randi()
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.frequency = 0.07  # Lower frequency for smoother terrain
	noise.fractal_octaves = 4  # Add some detail to the terrain
	noise.fractal_lacunarity = 2.0
	noise.fractal_gain = 0.5

func generate_world() -> void:
	for x in range(WORLD_SIZE_X):
		for z in range(WORLD_SIZE_Z):
			# Adjust noise calculation
			var noise_value = noise.get_noise_2d(x * 1.0, z * 1.0)
			var height = int((noise_value + 1.0) * NOISE_SCALE)
			height = clamp(height, 1, MAX_HEIGHT)
			
			# Place dirt blocks
			for y in range(height - 1):
				var dirt = dirt_block.instantiate()
				add_child(dirt)
				dirt.position = Vector3(x, y, z)
			
			# Place grass block on top
			var grass = grass_block.instantiate()
			add_child(grass)
			grass.position = Vector3(x, height - 1, z)

func _process(delta: float) -> void:
	pass
