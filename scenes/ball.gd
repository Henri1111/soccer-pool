extends RigidBody2D
class_name Ball

func _physics_process(_delta: float) -> void:
	var speed: float = sqrt(linear_velocity.x ** 2 + linear_velocity.y ** 2)
	if speed and speed < 50.0:
		linear_damp = 5.0
		angular_damp = 5.0
