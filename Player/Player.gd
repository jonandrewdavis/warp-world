extends CharacterBody2D

signal health_changed(health_value)

const Camera = preload("res://Network/CameraBase.tscn")
@onready var main = get_tree().get_root().get_node('Main')
@onready var sprite = $Sprite2D
@onready var weaponAnimate = $Sheathe/Weapon/AnimationPlayer
# weapon may want to send it's own stuff...
# @onready var weapon = $Weapon
@onready var sheathe = $Sheathe
@onready var healthBar = $ProgressBar

@export var ACCELERATION = 500
@export var MIN_SPEED = 15
@export var MAX_SPEED = 70
@export var FRICTION = 500

var health = 5 

# TODO: move this into the global imports, like the signal function
func call_delayed(callable, delay):
	get_tree().create_timer(delay, false).connect("timeout", callable)

func _enter_tree():
	set_multiplayer_authority(str(name).to_int())

func _ready():
	if not is_multiplayer_authority(): return
	var new_camera = Camera.instantiate()
	var remote = $PlayerCameraRemote
	new_camera.set_multiplayer_authority(str(name).to_int())
	remote.set_multiplayer_authority(str(name).to_int())
	main.add_child(new_camera)
	remote.set_remote_node(main.get_node('CameraBase').get_path())
	respawn()
	
func _physics_process(delta):
	if not is_multiplayer_authority(): return
	if health <= 0:
		$CollisionShape2D.set_disabled(true)
		$AnimationPlayer.play('death')
		return
	
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()

	if input_vector != Vector2.ZERO:
		if input_vector.x > 0:
			sheathe.scale.x = 1
			sprite.flip_h = false
		else:
			sheathe.scale.x = -1
			sprite.flip_h = true
		$AnimationPlayer.play("walk")
		if Input.is_action_pressed('shift'):
			velocity = velocity.move_toward(input_vector * (MAX_SPEED * 1.7), ACCELERATION * delta)
		else: 
			velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		$AnimationPlayer.play("idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)

	move_and_slide()


func _unhandled_input(event):
	if not is_multiplayer_authority(): return
	if health <= 0: return
	if Input.is_action_just_pressed("click"):
		weaponAnimate.play("swing1")
		

func _on_weapon_body_entered(body):
	if not is_multiplayer_authority(): return
	# TODO: check if its a payer.
	if body.has_method('on_damage'):
		body.on_damage.rpc_id(body.get_multiplayer_authority())

# needs a lot of work
func respawn():
	health = 3
	healthBar.value = health
	$CollisionShape2D.set_disabled(false)
	position = Vector2(0 + randf()*450,0 + randf()*450)
	
@rpc("any_peer")
func on_damage():
	health -= 1
	# health_changed.emit(health)
	healthBar.value = health
	if health <= 0:
		call_delayed(respawn, 2.8)

# func update_health_bar(health_value):
