@tool
extends Enemy

@onready var path_3d: Path3D = $Path3D
@onready var path_follow_3d: PathFollow3D = $Path3D/PathFollow3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var shoot_timer: Timer = $ShootTimer
@onready var mesh: Node3D = $Mesh
@onready var small_explosion: Node3D = $SmallExplosion
@onready var scrap_particles: GPUParticles3D = $ScrapParticles

@export var path_curve: Curve3D:
	get: 
		return path_curve
	set(value):
		path_curve = value
		if is_node_ready():
			path_3d.curve = value

@export var speed: float = 10
@export var shoot_time: float = 1
@export var burst_delay: float = 0.2
@export var max_shoot_times: int = 1
@export var shoot_amount: int = 3

@export var bullet_scene: PackedScene

var shoot_times: int = 0

func _ready() -> void:
	path_curve = path_curve
	if Engine.is_editor_hint(): return
	visible = false
	shoot_timer.wait_time = shoot_time
	mesh.top_level = true
	#mesh.scale = scale
	#mesh.rotation

func die() -> void:
	super.die()
	path_3d.queue_free()
	small_explosion.reparent(get_parent().get_parent())
	small_explosion.explode()
	scrap_particles.reparent(path_3d.get_parent())
	scrap_particles.emitting = true

func _on_awake_state_entered() -> void:
	path_3d.reparent(player_controller.path_follow)
	reparent(path_follow_3d)
	#path_3d.scale = scale
	#path_3d.rotation = rotation
	scale = Vector3.ONE
	rotation = Vector3.ZERO
	position = Vector3.ZERO
	visible = true
	animation_player.play("RESET")
	shoot_timer.start()

func _on_awake_state_processing(delta: float) -> void:
	mesh.global_position = global_position
	mesh.look_at(player.global_position)
	path_follow_3d.progress += speed * delta
	if path_follow_3d.progress_ratio == 1:
		path_3d.queue_free()


func _on_shoot_timer_timeout() -> void:
	if shoot_times >= max_shoot_times:
		return
	
	shoot_times += 1
	for i in shoot_amount:
		create_bullet()
		await get_tree().create_timer(burst_delay).timeout

func create_bullet() -> void:
	var bullet = bullet_scene.instantiate() as Projectile
	add_sibling(bullet)
	bullet.global_position = global_position
	bullet.set_direction_towards_position(bullet.predict_position(player, player.path_velocity))
	bullet.global_rotation = Vector3.ZERO
	bullet.top_level = true

