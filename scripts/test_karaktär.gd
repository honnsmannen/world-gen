extends KinematicBody2D


var level_scene : Node2D

onready var nav_agent = $NavigationAgent2D

var carrying_item = "tom"

var follow_player = false

var carrying_an_item = false
onready var player = get_node("/root/värld_för_navigation/Filuren")

var item_amount = 0

export var nav_agent_radius : float = 45.0
export var nav_optimize_path : bool = true
export var nav_avoidance_enabled : bool = true
export var character_speed_multiplier : float = 100.0
var is_dead := false

var velocity : Vector2

onready var parent_level_scene = ("res://scener/värld_för_navigation.tscn")

# final navigation destination position/point
var nav_destination : Vector2 
# next navigation destination position/point
var next_nav_position : Vector2 

# The normal path to the destination
var character_nav_path : Array = []

# The actual path being calcuated during travel, used in the draw function
var character_real_nav_path : Array = []

func _ready() -> void:
	# init velocity
	# Vector2.ZERO is enumeration for Vector2(0,0)
	
	velocity = Vector2.ZERO 
	
	nav_agent = $NavigationAgent2D
	# connect nav agent signal callback functions
	#nav_agent.connect("path_changed", self, "character_path_changed")
	#nav_agent.connect("target_reached", self, "character_target_reached_reached")
	#nav_agent.connect("navigation_finished", self, "character_navigation_finished")
	nav_agent.connect("velocity_computed", self, "character_velocity_computed")
	# config nav agent attributes
	nav_agent.max_speed = character_speed_multiplier
#	nav_agent.radius = nav_agent_radius
	nav_agent.avoidance_enabled = nav_avoidance_enabled

# init called by parent, inits flow down from parent nodes to create easy parent child references

func init_character(parent_level_scene : Node2D, instanced_in_code : bool) -> void:
	# set the level_scene easy reference as the init calling level scene
	level_scene = parent_level_scene
	print("hallå")
	# init positions

	if instanced_in_code:
		#init position(s) for character existing in the level scene during start
		global_position = level_scene.previous_right_mouse_click_global_position
		nav_destination = level_scene.previous_left_mouse_click_global_position
		next_nav_position = level_scene.previous_right_mouse_click_global_position
	else:
		#init position(s) for character scenes created during play
		nav_destination = global_position
		next_nav_position = global_position
		


	# set the initial target location to nav_destination
	nav_agent.set_target_location(nav_destination)

func _physics_process(_delta : float) -> void:

	if follow_player:
		nav_agent.set_target_location(player.global_position)


	# get the next nav position from the character's navigation agent
	next_nav_position = nav_agent.get_next_location()
	# add the next nav position to the 'real' path for draw function
	character_real_nav_path.push_back(next_nav_position)
	# calculate the desired velocity, i.e velocity pre nav server calculated
	var desired_velocity = global_position.direction_to(next_nav_position) * character_speed_multiplier
	
	# feed the desired into the navigation agent 
	# set_velocity will trigger a callback from velocity_computed signal
	nav_agent.set_velocity(desired_velocity)
	
func set_navigation_position(nav_position_to_set : Vector2) -> void:
	nav_destination = nav_position_to_set
	#print("nav_destination: ", nav_destination)
	
	# set the new character target location
	nav_agent.set_target_location(nav_destination)
	
	# calculate a new map path with the server using character nav agent map and new nav destination
	character_nav_path = Navigation2DServer.map_get_path(nav_agent.get_navigation_map(), global_position, nav_destination, nav_optimize_path)
	
	#print("character_nav_path: ", character_nav_path)
	
	#print("Navigation2DServer.map_get_path(nav_agent.get_navigation_map(), global_position, nav_destination, nav_optimize_path): " , Navigation2DServer.map_get_path(nav_agent.get_navigation_map(), global_position, nav_destination, nav_optimize_path))
	
	# clear the old real nav path, used for draw function
	character_real_nav_path.clear()




	
func character_velocity_computed(calculated_velocity : Vector2) -> void:
	velocity = calculated_velocity
	
	# check if nav agent target is reached
	if !nav_agent.is_target_reached():
		#print("bleh")
		# move and slide with the new calculated velocity
		velocity = move_and_slide(velocity)
		
		#print("Navigation2DServer.map_get_closest_point(nav_agent.get_navigation_map(), global_position): ",Navigation2DServer.map_get_closest_point(nav_agent.get_navigation_map(), global_position))
	else:
		# if reached target, stand at the closest point in the navigation map
		global_position = Navigation2DServer.map_get_closest_point(nav_agent.get_navigation_map(), global_position)
		#print(":P")




func die() -> void:
	if not is_dead:
		is_dead = true
	queue_free()

func _on_Area2D_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		follow_player = true
		$AudioStreamPlayer.playing = true
		

func _on_Area2D_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		nav_destination = global_position
		follow_player = false
		$AudioStreamPlayer.playing = false
