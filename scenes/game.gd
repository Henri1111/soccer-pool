extends CanvasLayer

var player_scene: PackedScene = load("res://scenes/player.tscn")
@onready var game_contents: CanvasLayer = $GameContents
@onready var aufstellung_1: Node2D = $GameContents/TileMapLayer/Aufstellung1
@onready var ball: Ball = $GameContents/Ball
@onready var ball_inital_pos: Marker2D = $GameContents/TileMapLayer/BallInitalPos
var players: Array[Player] = []
var whose_turn: int
var waiting_for_player_action: bool = false

func _ready() -> void:
	ball.global_position = ball_inital_pos.global_position
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

	whose_turn = randi_range(0,1)
	turn()

func _process(_delta: float) -> void:
	if not waiting_for_player_action:
		var can_proceed: bool = true
		for player: Player in players:
			if (
				round(player.linear_velocity) != Vector2.ZERO
				or round(player.angular_velocity) != 0.0
				or round(ball.linear_velocity) != Vector2.ZERO
				or round(ball.angular_velocity) != 0.0
			):
				can_proceed = false
		if can_proceed == true:
			turn()

func turn() -> void:
	for player: Player in players: 
		if player.is_blue and whose_turn == 0:
			player.can_drag = false
		elif not player.is_blue and whose_turn == 1:
			player.can_drag = false
		elif player.is_blue and whose_turn == 1:
			player.can_drag = true
		elif not player.is_blue and whose_turn == 0:
			player.can_drag = true
	whose_turn = 1 if whose_turn == 0 else 0
	waiting_for_player_action = true

func player_has_actioned() -> void:
	await get_tree().create_timer(1.0).timeout
	waiting_for_player_action = false
