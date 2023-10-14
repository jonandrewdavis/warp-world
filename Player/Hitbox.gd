# NOTE: NOTE FOR FUTURE: Most multiplayer bugs are caused here.
# NOTE: Mostly because the values from Hitbox aren't in Multiplayer Syncronizers.
# NOTE: knockback is set and happens here.

# Sync values should really be dynamic. the server can spawn new things to make new values.

# NOTE: This is for AD to understand.
# The way this works is that you can create an Area2D and it'll be extended as Hitbox.
# A hitbox does the HITTING. and it Knocksbacks. Weapons and enemys have these to inflict hurt.
class_name Hitbox
extends Area2D

@export var damage = 1
@export var knockback_direction: Vector2 = Vector2.ZERO
@export var knockback_force: int = 200
@export var gather_force = 1

var body_inside: bool = false

@onready var collision_shape: CollisionShape2D = get_child(0)
# @onready var timer: Timer = Timer.new()

# NOTE: This is interesting boilerplate to avoid Connect
func _init():
	var __ = connect("body_entered",Callable(self,"_on_body_entered"))
	__ = connect("body_exited",Callable(self,"_on_body_exited"))
	
func _ready() -> void:
	assert(collision_shape != null)
#	timer.wait_time = 1
#	timer.autostart = true
#	add_child(timer)

# NOTE: DO NOT USE the _collide.
# TODO: Refactor ALL HITBOXes, possibly at the same time we do damage...

# NOTE: I need to better understand on body entered here, and collide
# func _on_body_entered(body: PhysicsBody2D) -> void:
	# print('body entered', body)
#	body_inside = true
	#timer.start()
	#while body_inside:
	#	_collide(body)
	#	await timer.timeout
	
func _on_body_exited(_body) -> void:
	body_inside = false
#	timer.stop()
	
# This func could really be ... I dunno. Hitbox.gd is a problem waiting to happen.
func _on_body_entered(body: PhysicsBody2D) -> void:
	if body != null and body.has_method("take_damage"):
		# print('_body_entered, calling take_damage, d: ', knockback_direction, 'f: ', knockback_force)
		body.take_damage(damage, knockback_direction, knockback_force)
