extends Node2D



var cell_x = -1
var cell_y = -1
var compenserat_value = 0
var test = 0
var level_navigation_map
#var tree_offset = Vector2(32,32)
var tree_pos := Vector2(0,0)

var step_for_world_gen_x = 1
var step_for_world_gen_y = 1

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
	

func _process(delta: float) -> void:
	world_gen(20,20)







func world_gen(width,height) -> void:
	filurens_position = filuren.global_position - Vector2(320,320)
	"""
	if filuren.global_position.x < 0 and filuren.global_position.y < 0:
		step_for_world_gen_x = -1
		step_for_world_gen_y = -1
	elif filuren.global_position.x < 0 and !filuren.global_position.y < 0:
		step_for_world_gen_x = -1
		step_for_world_gen_y = 1
	elif !filuren.global_position.x < 0 and filuren.global_position.y < 0:
		step_for_world_gen_x = 1
		step_for_world_gen_y = -1
	else:
		step_for_world_gen_x = 1
		step_for_world_gen_y = 1
	"""
	for x in range(width + (int(round(filurens_position.x))/32), (int(round(filurens_position.x))/32) - width , step_for_world_gen_x):
		for y in range(height + (int(round(filurens_position.y))/32), (int(round(filurens_position.y))/32) - height , step_for_world_gen_y):
			if int(round(noise.get_noise_2d(x + (int(round(filurens_position.x))/32) , y + (int(round(filurens_position.y))/32)))) < 0:
				compenserat_value = int(round(noise.get_noise_2d(x + (int(round(filurens_position.x))/32), y + (int(round(filurens_position.y))/32)))) * -1
			else:
				compenserat_value = int(round(noise.get_noise_2d(x + (int(round(filurens_position.x))/32), y + (int(round(filurens_position.y))/32))))
			
			$TileMap.set_cell(x+(int(round(filurens_position.x))/32), y+(int(round(filurens_position.y))/32), compenserat_value)


