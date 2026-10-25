extends CanvasLayer

var player_scene: PackedScene = load("res://scenes/player.tscn")
var ball_scene: PackedScene = load("res://scenes/ball.tscn")
@onready var game_contents: CanvasLayer = $GameContents
@onready var aufstellung_1: Node2D = $GameContents/TileMapLayer/Aufstellung1
@onready var ball_inital_pos: Marker2D = $GameContents/TileMapLayer/BallInitalPos
@onready var score_blue: Label = $ColorRect/TextureRect/MarginContainer/HBoxContainer/ScoreBlue
@onready var score_red: Label = $ColorRect/TextureRect/MarginContainer/HBoxContainer/ScoreRed
var players: Array[Player] = []
var ball: Ball
var whose_turn: int
var waiting_for_player_action: bool = false
var points_blue: int = 0
var points_red: int = 0
var players_in_left_goal: Array[Player] = []
var players_in_right_goal: Array[Player] = []

func _ready() -> void:
	whose_turn = randi_range(0,1)
	setup_stage()
	
func clear() -> void:
	for player: Player in players.duplicate():
		player.queue_free()
		players.erase(player)
	waiting_for_player_action = false
	players_in_left_goal.clear()
	players_in_right_goal.clear()

func setup_stage() -> void:
	clear()
	await get_tree().process_frame
	ball = ball_scene.instantiate()
	game_contents.add_child(ball)
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
	for player: Player in players_in_left_goal:
		if (
			round(player.linear_velocity) == Vector2.ZERO
			and round(player.angular_velocity) == 0.0
		):
			player.process_mode = Node.PROCESS_MODE_DISABLED
			var tween: Tween = create_tween()
			tween.set_ease(Tween.EASE_IN_OUT)
			tween.set_trans(Tween.TRANS_EXPO)
			var new_position: Vector2
			while true:
				new_position = Vector2(randi_range(244, 440), randi_range(200, 440))
				var others: Array = [ball]
				others.append_array(players)
				var found_illegal_distance: bool = false
				for other: RigidBody2D in others:
					if new_position.distance_to(other.global_position) < 20.0:
						found_illegal_distance = true
				if not found_illegal_distance:
					break
			tween.tween_property(player, "global_position", new_position, 1.0)
			await tween.finished
			player.process_mode = Node.PROCESS_MODE_ALWAYS
	for player: Player in players_in_right_goal:
		if (
			round(player.linear_velocity) == Vector2.ZERO
			and round(player.angular_velocity) == 0.0
		):
			player.process_mode = Node.PROCESS_MODE_DISABLED
			var tween: Tween = create_tween()
			tween.set_ease(Tween.EASE_IN_OUT)
			tween.set_trans(Tween.TRANS_EXPO)
			var new_position: Vector2
			while true:
				new_position = Vector2(randi_range(712, 908), randi_range(200, 440))
				var others: Array = [ball]
				others.append_array(players)
				var found_illegal_distance: bool = false
				for other: RigidBody2D in others:
					if new_position.distance_to(other.global_position) < 20.0:
						found_illegal_distance = true
				if not found_illegal_distance:
					break
			tween.tween_property(player, "global_position", new_position, 1.0)
			await tween.finished
			player.process_mode = Node.PROCESS_MODE_ALWAYS

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
		player.linear_damp = 1.3
		player.angular_damp = 0.0
	ball.linear_damp = 1.0
	ball.angular_damp = 0.0
	whose_turn = 1 if whose_turn == 0 else 0
	waiting_for_player_action = true

func player_has_actioned() -> void:
	await get_tree().create_timer(1.0).timeout
	waiting_for_player_action = false

func _on_left_goal_body_entered(body: Node2D) -> void:
	if body is Player:
		players_in_left_goal.append(body)
	elif body is Ball:
		score_goal(1)

func _on_left_goal_body_exited(body: Node2D) -> void:
	if body is Player:
		players_in_left_goal.erase(body)
	
func _on_right_goal_body_entered(body: Node2D) -> void:
	if body is Player:
		players_in_right_goal.append(body)
	elif body is Ball:
		score_goal(0)

func _on_right_goal_body_exited(body: Node2D) -> void:
	if body is Player:
		players_in_right_goal.erase(body)

func score_goal(scorer_team: int) -> void:
	if scorer_team == 0:
		points_red += 1
		score_red.text = str(points_red)
		whose_turn = 1
	elif scorer_team == 1:
		points_blue += 1
		score_blue.text = str(points_blue)
		whose_turn = 0
	await get_tree().create_timer(2.0).timeout
	ball.queue_free()
	ball = null
	setup_stage()
