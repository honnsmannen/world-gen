extends KinematicBody2D

signal hp_updated(hp)
signal died()
signal damaged(hp)
signal hunger(hunger)



onready var vapen_scene = preload("res://scener/Vapen.tscn")
onready var enemy = preload("res://scener/fiender.tscn")
onready var light = get_node("NightLight")
export (int) var speed = 200
onready var hp = max_hp

var max_hp = 100
var velocity = Vector2()
var dmg_amount = 10
var can_attack := true
var direction := Vector2.RIGHT
var hunger := 100

var temp_item = ""
var active_item = "tom"
var carrying_an_item = false
var item_amount = 0
var carrying_item = "tom"


func get_input():
	velocity = Vector2()
	if Input.is_action_pressed("right"):
		velocity.x += 1
		direction = Vector2.RIGHT
	if Input.is_action_pressed("left"):
		velocity.x -= 1
		direction = Vector2.LEFT
	if Input.is_action_pressed("down"):
		velocity.y += 1
		direction = Vector2.DOWN
	if Input.is_action_pressed("up"):
		velocity.y -= 1
		direction = Vector2.UP
	velocity = velocity.normalized() * speed
	if Input.is_action_pressed("Attack") and can_attack:
		_shoot()
		$AudioStreamPlayer.playing = true
	
		
	if Input.is_action_just_pressed("activate"):
		pass

			
	if Input.is_action_just_pressed("switch_active_item"):
		active_item_switch()

		print("active_item: ", active_item)
		print("carrying_item: ", carrying_item)
		print("temp_item: ", temp_item)
	if Input.is_action_just_pressed("ui_down"):
		$Camera2D.zoom = $Camera2D.zoom - Vector2(0.1,0.1)
	if Input.is_action_just_pressed("ui_up"):
		$Camera2D.zoom = $Camera2D.zoom + Vector2(0.1,0.1)
	if Input.is_action_pressed("ui_right"):
		$Camera2D.zoom = $Camera2D.zoom - Vector2(0.1,0.1)
	if Input.is_action_pressed("ui_left"):
		$Camera2D.zoom = $Camera2D.zoom + Vector2(0.1,0.1)
func _physics_process(delta):
	get_input()
	velocity = move_and_slide(velocity)

func damage(dmg_amount):
	hp -= dmg_amount
	emit_signal("damaged", hp)
	if hp <= 0:
		died()
		
func died():
	visible = false
	emit_signal("died")
	

func _on_Zone_body_entered(body: Node) -> void:
	if body.is_in_group("enemy"):
		damage(dmg_amount)
		print(hp)


func _shoot() -> void:
	can_attack = false
	$AttackTimer.start()

	var vapen_instance = vapen_scene.instance()
	vapen_instance.global_position = $Vapenspawn.global_position
	vapen_instance.set_direction($Vapenspawn.global_position, get_global_mouse_position())
	
	get_tree().get_root().add_child(vapen_instance)

func _on_AttackTimer_timeout() -> void:
	can_attack = true
	$AttackTimer.stop()
	
	
func item_picked_up(item_id : String, amount) -> void:
	if !carrying_an_item or carrying_item == item_id:
		carrying_item = item_id
		item_amount += amount
		carrying_an_item = true
		print(item_id)
	emit_signal("item_picked_up", item_id)
		
#kod för att lämna items
func item_dropped_off() -> void:
	if carrying_an_item:
		item_amount = 0
		carrying_item = "tom"
		carrying_an_item = false

func active_item_switch() -> void:
	if active_item == "tom":
		active_item = carrying_item
		carrying_item = "tom"
	else:
		temp_item = active_item
		active_item = carrying_item
		carrying_item = temp_item
		temp_item = ""
	
func _on_Day_Night_night_tick(night) -> void:
	light.show()

func _on_Day_Night_day_tick(day) -> void:
	light.hide()

func _on_HungerTimer_timeout() -> void:
	hunger = clamp(hunger, 2, 100)
	hunger -= 1
	print("hunger: ", hunger)
	emit_signal("hunger", hunger)
	if hunger == 0:
		$DamageTimer.start()
	
func _on_DamageTimer_timeout() -> void:
	damage(dmg_amount)
	print("damage")



