extends Node2D



var cell_x = -1
var cell_y = -1
var compenserat_value = 0
var test = 0
var level_navigation_map
#var tree_offset = Vector2(32,32)
var tree_pos := Vector2(0,0)



var filurens_position : Vector2

onready var filuren: KinematicBody2D = $Filuren


var previous_left_mouse_click_global_position : Vector2
var previous_right_mouse_click_global_position : Vector2

onready var character = $KinematicBody2D
onready var parent_level_scene = ("res://scener/värld_för_navigation.tscn")

var characters = []


#onready var tree = preload("res://scener/träd.tscn")
onready var noise = OpenSimplexNoise.new()
onready var tile = get_node("TileMap")
func _ready() -> void:
	#level_navigation_map = get_world_2d().get_navigation_map()
	#init_pre_existing_level_characters()
	
	
	"""
	de här är till för generationen av världen.
	"""
	randomize()
	noise.seed = randi()
	noise.period = 15
	
	noise.octaves = 1
	world_gen(20,20)

func _process(delta: float) -> void:
	world_gen(20,20)
	print(int(round(filurens_position.x)))
	print(int(round(filurens_position.y)))






func world_gen(width,height) -> void:
	filurens_position = filuren.global_position
	for x in range(width):
		for y in range(height):
			if int(round(noise.get_noise_2d(x + int(round(filurens_position.x)) , y + int(round(filurens_position.y))))) < 0:
				compenserat_value = int(round(noise.get_noise_2d(x + int(round(filurens_position.x)) , y + int(round(filurens_position.y)))))
			
			$TileMap.set_cell(x+int(round(filurens_position.x)), y+int(round(filurens_position.y)), compenserat_value)


