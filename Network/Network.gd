extends Node

@onready var main_menu = $MainMenuCanvas/MainMenu
@onready var user = $MainMenuCanvas/MainMenu/MarginContainer/VBoxContainer/user
@onready var address_entry = $MainMenuCanvas/MainMenu/MarginContainer/VBoxContainer/address

const Player = preload("res://Player/Player.tscn")

const PORT = 9999
var enet_peer = ENetMultiplayerPeer.new()

# if you capture mouse, you've gotta have this
func _unhandled_input(event):
	if Input.is_action_just_pressed("escape"):
		get_tree().quit()

func _on_join_pressed():
	main_menu.hide()
	# hud.show()
	print('addy',address_entry.text)
	enet_peer.create_client(address_entry.text, PORT)
	print('peer',enet_peer)
	print('host', enet_peer.get_host())
	multiplayer.multiplayer_peer = enet_peer


func _on_host_pressed():
	main_menu.hide()
	# hud.show()

	enet_peer.create_server(PORT)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(remove_player)
	
	add_player(multiplayer.get_unique_id())
	
	upnp_setup()


func add_player(peer_id):
	print('im peer id', peer_id)
	var player = Player.instantiate()
	player.name = str(peer_id)
	get_parent().add_child(player)

	
func remove_player(peer_id):
	var player = get_node_or_null(str(peer_id))
	if player:
		player.queue_free()

func update_health_bar(health_value):
	pass
	# health_bar.value = health_value

func _on_multiplayer_spawner_spawned(node):
	print('spawned', node)

func upnp_setup():
	var upnp = UPNP.new()
	
	var discover_result = upnp.discover()
	assert(discover_result == UPNP.UPNP_RESULT_SUCCESS, \
		"UPNP Discover Failed! Error %s" % discover_result)

	assert(upnp.get_gateway() and upnp.get_gateway().is_valid_gateway(), \
		"UPNP Invalid Gateway!")

	var map_result = upnp.add_port_mapping(PORT)
	assert(map_result == UPNP.UPNP_RESULT_SUCCESS, \
		"UPNP Port Mapping Failed! Error %s" % map_result)
	
	print("Success! Join Address: %s" % upnp.query_external_address())

