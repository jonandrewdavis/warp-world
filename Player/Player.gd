extends CharacterBody2D

var current_weapon: Node2D

@export var max_hp: int = 3
@export var hp: int = 3 
@export var FRICTION: int = 500
@export var acceleration = 500
@export var max_speed = 100

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var state_machine: Node = get_node("FiniteStateMachine")
@onready var animated_sprite: AnimatedSprite2D = get_node("AnimatedSprite2D")
@onready var mov_direction: Vector2 = Vector2.ZERO

@onready var userlabel = $Label
@onready var world = get_parent()

# var UI = preload("res://UI/UI.tscn")
var UIref = null

var mouse_direction: Vector2

const PLAYER_MAX_CONST = 80
const RESPAWN_RADIUS = 75
var PLAYER_START: Vector2 = Vector2(-0, 10)

func _enter_tree():
	set_multiplayer_authority(str(name).to_int())

func _ready() -> void:
	# NOTE: This `not is_multiplayer_authority()` check 
	# assures that code runs only on the client.
	# All nodes within these are LOCAL only. Camera, Inventory, UI, etc.
	# TODO: Move `userlabel.text` above this line and remove from sync
	if not is_multiplayer_authority(): return
	var newCamera = Camera2D.new()
	# var newUI = UI.instantiate()
	userlabel.text = SavedData.username
	# All local. Weapons are in /Weapons, so those exist on server, and need to.
	# emit_signal("weapon_picked_up", weapons.get_child(0).get_texture())
	newCamera.ignore_rotation = true
	newCamera.limit_smoothed = true
	add_child(newCamera)
	# add_child(newUI)
	# UIref = get_node("UI")
	_restore_previous_state()
	
func is_player():
	return true

func _physics_process(delta: float) -> void:
	if mov_direction != Vector2.ZERO:
		velocity = velocity.move_toward(mov_direction * max_speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)

func move() -> void:
	move_and_slide()
	
# take_damage drives a lot of logic
# source is from HitBox on enemies or on weapon
func take_damage(dam: int, dir: Vector2, force: int) -> void:
	if state_machine.state != state_machine.states.dead:
		hp -= dam
		velocity += dir * force
		if hp > 0:
			state_machine.set_state(state_machine.states.hurt)
		else:
			state_machine.set_state(state_machine.states.dead)
		_spawn_hit_effect()

func take_knockback(_dam: int, dir: Vector2, force: int) -> void:
		velocity += dir * force

func _spawn_hit_effect() -> void:
	pass

func _restore_previous_state() -> void:
	max_hp = 5
	hp = 5
	max_speed = PLAYER_MAX_CONST
	if self.name == str(1):
		PLAYER_START = Vector2.ZERO
	if randi() % 2 == 0:
		position = Vector2(PLAYER_START.x + randf() * RESPAWN_RADIUS, PLAYER_START.y + randf() * RESPAWN_RADIUS)
	else: 
		position = Vector2(PLAYER_START.x - randf() * RESPAWN_RADIUS, PLAYER_START.y - randf() * RESPAWN_RADIUS)
	state_machine.set_state(state_machine.states.idle)

func _process(_delta: float) -> void:
	if not is_multiplayer_authority(): return
	
	mouse_direction = (get_global_mouse_position() - global_position).normalized()
	
	if mouse_direction.x > 0 and animated_sprite.flip_h:
		animated_sprite.flip_h = false
	elif mouse_direction.x < 0 and not animated_sprite.flip_h:
		animated_sprite.flip_h = true
		
	# current_weapon.move(mouse_direction)

func _unhandled_input(_event):
	if not is_multiplayer_authority(): return
	if Input.is_action_just_pressed("escape"):
		pass

func get_input() -> void:
	if not is_multiplayer_authority(): return
		
	mov_direction = Vector2.ZERO
	mov_direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	mov_direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	mov_direction = mov_direction.normalized()
	
func cancel_attack() -> void:
	pass
#	current_weapon.cancel_attack()
	
func respawn() -> void:
	delay_loot(global_position)
	_restore_previous_state()

func delay_loot(new_pos):
	pass

func interact(): 
	# Look for interactable bodies,
	# pick closest
	pass

# TODO: This should be emit, (signal up)
func player_pvp(value):
	if value == true:
		userlabel.add_theme_color_override("font_color", Color(1,0,0))
	else:
		userlabel.remove_theme_color_override("font_color")
	self.set_collision_layer_value(6, value)

