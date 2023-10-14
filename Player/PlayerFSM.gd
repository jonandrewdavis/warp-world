extends FiniteStateMachine

func _init():
	_add_state("idle")
	_add_state("move")
	_add_state("hurt")
	_add_state("dead")
	
func _ready() -> void:
	set_state(states.idle)
	
	
func _state_logic(_delta: float) -> void:
	if state == states.idle or state == states.move:
		parent.get_input()
		parent.move()
	if state == states.hurt:
		parent.move()
	
func _get_transition() -> int:
	match state:
		states.idle:
			if parent.velocity.length() > 10:
				return states.move
		states.move:
			if parent.velocity.length() < 10:
				return states.idle
		states.hurt:
			if not animation_player.is_playing():
				return states.idle
	return -1
	
	
func _enter_state(_previous_state: int, new_state: int) -> void:
	match new_state:
		states.idle:
			animation_player.play("PlayerAnimationSaved/idle")
		states.move:
			animation_player.play("PlayerAnimationSaved/move")
		states.hurt:
			parent.cancel_attack()
			animation_player.play("PlayerAnimationSaved/hurt")
		states.dead:
			animation_player.play("PlayerAnimationSaved/dead")
			parent.cancel_attack()
