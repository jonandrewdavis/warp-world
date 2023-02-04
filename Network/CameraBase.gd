extends Camera2D

func _enter_tree():
	print('console base', name)

	
# Called when the node enters the scene tree for the first time.
func _ready():
	if not is_multiplayer_authority():
		# GET PLAYER's NAME I WAS CREATED WITH
		set_multiplayer_authority(str(name).to_int())
	# make_current()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
