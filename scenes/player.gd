extends RigidBody2D
class_name Player

@onready var collision_shape: CollisionShape2D = $CollisionShape2D

const MAX_INITIAL_SPEED: float = 1800  # pixel/second
const MAX_DRAG_DISTANCE: float = 200  # pixel
var currently_dragging = false
var is_blue = false

func calc_velocity(speed: float, angle: float) -> Vector2:
	var x: int = round(speed * cos(deg_to_rad(angle)))
	var y: int = round(speed * sin(deg_to_rad(angle)))
	return Vector2(x, y)

func calc_angle(a: Vector2, b: Vector2) -> float:
	return rad_to_deg(atan2(b.y - a.y, b.x - a.x))

func apply_impulse_towards_point(point: Vector2, speed) -> void:
	var angle_to_point = calc_angle(global_position, point)
	var velocity: Vector2 = calc_velocity(speed, angle_to_point)
	apply_impulse(velocity)

func _physics_process(_delta: float) -> void:
	var speed: float = sqrt(linear_velocity.x ** 2 + linear_velocity.y ** 2)
	if speed and speed < 50.0:
		linear_damp = 5.0
		angular_damp = 5.0

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
		var mouse_event = event as InputEventMouseButton
		if mouse_event.is_released() and currently_dragging:
			currently_dragging = false
			var distance: float = min(position.distance_to(mouse_event.position), MAX_DRAG_DISTANCE)
			var speed = MAX_INITIAL_SPEED * (distance / MAX_DRAG_DISTANCE)
			var opposite_point = position + -(mouse_event.position - position)
			apply_impulse_towards_point(opposite_point, speed)

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			currently_dragging = true

func set_blue() -> void:
	is_blue = true
	$Sprite2D.texture = preload("uid://ml4ol1vuhvbv")
