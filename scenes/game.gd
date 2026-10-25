extends CanvasLayer

var player_scene: PackedScene = load("res://scenes/player.tscn")
@onready var game_contents: CanvasLayer = $GameContents
@onready var aufstellung_1: Node2D = $GameContents/TileMapLayer/Aufstellung1

func _ready() -> void: 
	for marker: Marker2D in aufstellung_1.get_children():
		var new_player: Player = player_scene.instantiate()
		game_contents.add_child(new_player)
		new_player.global_position = marker.global_position
		var new_player_blue: Player = player_scene.instantiate()
		new_player_blue.set_blue()
		game_contents.add_child(new_player_blue)
		new_player_blue.global_position = marker.global_position
		new_player_blue.global_position.x = get_viewport().get_visible_rect().size.x - new_player_blue.global_position.x
