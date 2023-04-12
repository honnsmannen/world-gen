extends Node2D


var negativt_spann = Vector2(0,0)

var positivt_spann = Vector2(1024,1024)

var posmod_x = 0

var posmod_y = 0

var width_function = 32
var height_function = 32
var spanis = 32*32

#fyll i array sakerna
var y_array1 = []
var	y_array2 = []
var	y_array3 = []
var	y_array4 = []
var	y_array5 = []

var array_x = [y_array1,y_array2,y_array3,y_array4,y_array5]



var cell_x = -1
var cell_y = -1
var compenserat_value = 0
var test = 0
var level_navigation_map
#var tree_offset = Vector2(32,32)
var tree_pos := Vector2(0,0)
var bush_pos := Vector2(0,0)
var not_tree_list = []
var tree_list = []

var generating = true
var current_tiles = []
var not_cleared = false

var previous_left_mouse_click_global_position : Vector2
var previous_right_mouse_click_global_position : Vector2

onready var character = $KinematicBody2D
onready var parent_level_scene = ("res://scener/värld_för_navigation.tscn")
onready var filuren = $Filuren

onready var game_over = preload("res://scener/Game_Over.tscn")
onready var marker = preload("res://scener/marker.tscn")

var characters = []

onready var Bush = preload("res://scener/Bush.tscn")
onready var tree = preload("res://scener/träd.tscn")
onready var noise = OpenSimplexNoise.new()
onready var tree_noise = OpenSimplexNoise.new()
onready var tile = get_node("TileMap")
func _ready() -> void:
	level_navigation_map = get_world_2d().get_navigation_map()
	init_pre_existing_level_characters()
	#world_gen(width_function, height_function)
	
	
	"""
	de här är till för generationen av världen.
	"""
	randomize()
	noise.seed = randi()
	noise.period = 15
	
	noise.octaves = 1
	
	tree_noise.seed = randi() * 2
	
	tree_noise.period = 1
	
	tree_noise.octaves = 100
	
func _process(delta: float) -> void:
	$negspann.global_position = negativt_spann
	$posspann.global_position = positivt_spann
	#"""
	if negativt_spann.x  < filuren.global_position.x and filuren.global_position.x < positivt_spann.x:
		# Player is within x range, do nothing
		pass
	else:
		_the_shitter_check()

	if negativt_spann.y < filuren.global_position.y and filuren.global_position.y < positivt_spann.y:
		pass
	else:
		_the_shitter_check()

	
	if Input.is_action_just_pressed("activate"):
		world_gen_destruction()
	
#"""
	
	update()
	
	#_world_destruction(45,25)
func init_pre_existing_level_characters() -> void:
	# init all the character scenes in the scene tree when starting the level
	# other characters created in create_character() will be initilized at that time
	for child_node in get_children():
		if child_node is KinematicBody2D:
			if child_node.has_method("init_character"):
				if characters.empty():
					# if no target i.e. left mouse click yet, set target to character position
					previous_left_mouse_click_global_position = child_node.global_position
				child_node.init_character(self, false)
				characters.push_back(child_node)

func world_gen(width: int, height: int, start_xy :Vector2) -> void:
	#to do : fixa så att det bara genar en värld mellan ett visst spann.
	
	var start_x = int(start_xy.x/32)
	var start_y = int(start_xy.y/32)
	

	for x in range(start_x, start_x + width):
		for y in range(start_y, start_y + height):
			
			if  -1 != $TileMap.get_cellv(Vector2(x,y)):
				return
			
			# Generate world data at (x, y)
			#if 1 != 1:
			#	pass
			else:
				var noise_x = x
				var noise_y = y
				var noise_value = noise.get_noise_2d(noise_x, noise_y)
				
				var tree_noise_value = int(round(tree_noise.get_noise_2d(noise_x, noise_y)))
				
				if noise_value < 0:
					compenserat_value = int(round(noise_value)) * -1

				else:
					compenserat_value = int(round(noise_value))
				
				
				if tree_noise_value == 1 and not Vector2(x,y) in tree_list:
					tree_pos = Vector2(x * 32, y * 32)
					tree_list.append(Vector2(x,y))
					#print(tree_list)
					var nytree = tree.instance()
					nytree.global_position = tree_pos
					add_child(nytree)
				

					
				
				$TileMap.set_cell(x, y, int(compenserat_value))



func _world_destruction(width , height , start_XY) -> void:
	
	var start_x = int(start_XY.x/32)
	var start_y = int(start_XY.y/32)
	for x in range(start_x, start_x + width):
		for y in range(start_y, start_y + height):
			$TileMap.set_cell(x, y, -1)

func _distance_from_2020(input_array : Array,x : int, y : int) -> void:
	var array_to_compare = input_array 
	if !generating and not_cleared:
		for i in range(x*y,0,-1):
			
			var compared_array = Vector2(x/2,y/2) - array_to_compare[i]
			if compared_array.x > 15 or compared_array.x < -15 or compared_array.y > 15 or compared_array.y < -15:
				current_tiles.erase(array_to_compare[i-1])
		not_cleared = false
func world_gen_destruction() -> void:

	var marker_position = Vector2(-32*32*2,-32*32*2)
	var mark_mod_x = posmod_x
	var mark_mod_y = posmod_y
	for x in range(5):
		mark_mod_y = posmod_y
		marker_position.y = -32*32*2
		marker_position.x = -32*32*2 + 32*32*mark_mod_x
		mark_mod_x += 1
		for y in range(5):
			var marker_instance = marker.instance()
			marker_position.y =-32*32*2 + 32*32*mark_mod_y
			mark_mod_y += 1
			if x > 0 and x < 4 and y > 0 and y < 4:
				world_gen(width_function,height_function,marker_position)
			else:
				_world_destruction(width_function,height_function,marker_position)
			array_x[x].append(marker_position)
			marker_instance.global_position = marker_position
			add_child(marker_instance)
		#print("array_x",array_x[x])
		
	


func _on_Filuren_died() -> void:
	add_child(game_over.instance())

func _worldgen_square() -> void:
	for x in range(5):
		print(x,"x")
		for y in range(5):
			print(y,"y")
			if x > 0 and x < 4 and y > 0 and y < 4:
				array_x[x].append("ett")
				
			else:
				array_x[x].append("noll")
		print(array_x[x])
		
		
		
func _the_shitter_check() -> void:
	if negativt_spann.x > filuren.global_position.x:
		# Player is to the left of the x range
		#print("negativt_spann.x: ",negativt_spann.x)
		#print("spanis: ", spanis)
		#print("filuren.global_position.x: ",filuren.global_position.x)
		posmod_x -= 1
		positivt_spann.x -= spanis
		negativt_spann.x -= spanis
		
		print("posmod_x: ", posmod_x)
		#  world_gen(width_function,height_function)
		world_gen_destruction()
	else:
		pass
	if positivt_spann.x < filuren.global_position.x:
		# Player is to the right of the x range
		print("pos_spann.x: ",positivt_spann.x)
		print("spanis: ", spanis)
		print("filuren.global_position.x: ",filuren.global_position.x)
		posmod_x += 1
		negativt_spann.x += spanis
		positivt_spann.x += spanis
		
		print("posmod_x: ", posmod_x)
		#world_gen(width_function,height_function)
		world_gen_destruction()
	else:
		pass
	if negativt_spann.y > filuren.global_position.y:
		# Player is below the y range
		#print("negativt_spann.y: ",negativt_spann.y)
		#print("spanis: ", spanis)
		#print("filuren.global_position.y: ",filuren.global_position.y)
		posmod_y -= 1
		negativt_spann.y -= spanis
		positivt_spann.y -= spanis
		
		print("posmod_y: ", posmod_y)
		#world_gen(width_function,height_function)
		world_gen_destruction()
	else:
		pass
	if positivt_spann.y < filuren.global_position.y:
		# Player is above the y range
		#print("pos_spann.y: ",positivt_spann.y)
		#print("spanis: ", spanis)
		#print("filuren.global_position.y: ", filuren.global_position.y)
		posmod_y += 1
		negativt_spann.y += spanis
		positivt_spann.y += spanis
		world_gen_destruction()
		print("posmod_y: ", posmod_y)
		#world_gen(width_function,height_function)
	else:
		pass
