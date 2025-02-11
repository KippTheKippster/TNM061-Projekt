@icon("res://assets/editor icons/Projectile3DIcon.svg")
extends Node3D
class_name Projectile

@export var speed: float = 30
var direction: Vector3 = Vector3.FORWARD:
	get: return direction
	set(value):
		direction = value.normalized()

@export var free_on_impact: bool = true
@export var move_with_rotation: bool = true

func _process(delta: float) -> void:
	if move_with_rotation:
		position += basis * direction * speed * delta
	else:
		position += direction * speed * delta

func set_direction_towards(node: Node3D) -> void:
	set_direction_towards_position(node.global_position)

func set_direction_towards_position(pos: Vector3) -> void:
	direction = pos - global_position

func shoot_at_player(player: Player) -> void:
	set_direction_towards_position(predict_position(player, player.true_velocity))

func predict_position(target: Node3D, velocity: Vector3) -> Vector3:
	var a = velocity.dot(velocity) - pow(speed, 2)
	var b = 2 * (target.global_position - global_position).dot(velocity)
	var c = target.global_position - global_position
	c = c.dot(c)
	var root_1 = (-b + sqrt(pow(b, 2) - 4 * a * c)) / (2 * a) 
	var root_2 = (-b - sqrt(pow(b, 2) - 4 * a * c)) / (2 * a) 
	var time = root_1
	if root_1 < 0 and root_2 > 0:
		time = root_2
	else:
		return target.global_position
		
	var final_position = target.global_position + velocity * time
	return final_position

func _on_remove_timer_timeout() -> void:
	queue_free()

func _on_hurt_area_damaged_health_area(_health_area: HealthArea) -> void:
	queue_free()

func _on_hurt_area_body_entered(_body: Node3D) -> void:
	if free_on_impact:
		queue_free()
