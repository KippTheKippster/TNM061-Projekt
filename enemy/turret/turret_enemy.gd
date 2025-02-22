extends Enemy

const ENEMY_BULLET = preload("res://enemy/enemy_bullet.tscn")

@export var shoot_amount: int = 3

@onready var shoot_marker: Marker3D = %ShootMarker
@onready var small_explosion: Node3D = $SmallExplosion
@onready var scrap_particles: GPUParticles3D = $ScrapParticles
@onready var shoot_timer: Timer = $ShootTimer
@onready var awake: AtomicState = $StateChart/Active/Awake
@onready var sattelite: Node3D = $Sattelite

@export var debug: bool = false

@onready var head: Node3D = $Sattelite/Head

#func _ready() -> void:
#	head.top_level = true
#	head.global_rotation = global_rotation
#	head.global_position = global_position

func _process(delta: float) -> void:
	var dif := player.global_position - global_position
	dif = global_basis.inverse() * dif
	
	var horizontal := Vector2(dif.z, dif.x)
	var vertical := Vector2(dif.y, horizontal.length())
	
	var angle_x := clamp(vertical.angle(), -PI / 2, PI / 2) as float
	#angle_x = vertical.angle()
	
	head.rotation = Vector3(angle_x, horizontal.angle(), 0)
	
	if debug:
		print("local:")
		print_angle(head.rotation)
		print("global:")
		print_angle(head.global_rotation)
	#head.rotation.x = clamp(head.rotation.x, -PI / 4, PI / 4)
	#if debug:
	#	print("cur:", rad_to_deg(head.rotation.x))

func print_angle(v: Vector3) -> void:
	print(rad_to_deg(v.x), ", ", rad_to_deg(v.y), ", ", rad_to_deg(v.z))

func shoot() -> void:
	for i in shoot_amount:
		create_bullet()
		await get_tree().create_timer(0.2).timeout

func create_bullet() -> void:
	var bullet = ENEMY_BULLET.instantiate() as Projectile
	add_sibling(bullet)
	bullet.global_position = shoot_marker.global_position
	bullet.set_direction_towards_position(bullet.predict_position(player, player.path_velocity))

func die() -> void:
	queue_free()
	small_explosion.explode()
	scrap_particles.reparent(get_parent())
	scrap_particles.emitting = true
	

func _on_shoot_timer_timeout() -> void:
	shoot()

func _on_asleep_state_entered() -> void:
	shoot_timer.stop()

func _on_awake_state_entered() -> void:
	shoot_timer.start()
	shoot()

func _on_visible_on_screen_notifier_3d_screen_exited() -> void:
	if awake.active: 
		queue_free()
