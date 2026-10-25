extends CanvasLayer

var player_scene: PackedScene = load("res://scenes/player.tscn")
@onready var game_contents: CanvasLayer = $GameContents
@onready var aufstellung_1: Node2D = $GameContents/TileMapLayer/Aufstellung1
var players: Array[Player] = []

func _ready() -> void:
	for marker: Marker2D in aufstellung_1.get_children():
		var new_player: Player = player_scene.instantiate()
		game_contents.add_child(new_player)
		new_player.global_position = marker.global_position
		players.append(new_player)
		var new_player_blue: Player = player_scene.instantiate()
		new_player_blue.set_blue()
		game_contents.add_child(new_player_blue)
		new_player_blue.global_position = marker.global_position
		new_player_blue.global_position.x = get_viewport().get_visible_rect().size.x - new_player_blue.global_position.x
		players.append(new_player_blue)
