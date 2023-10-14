extends Node

var weapons: Array = []
var equipped_weapon_index: int = 0
var username = 'unnamed noob'
var host_name: String = ''

func reset_data() -> void:
	weapons = []
	equipped_weapon_index = 0
