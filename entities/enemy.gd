extends CharacterBody2D

var speed = 100
var amplitude = 20
var frequency = 2.0
var time = 0.0

@onready var anim: AnimatedSprite2D = $Animacaobat

enum BatState {
	PATROL,
	CHASE,
	ATTACK,
	COOLDOWN
}

var state = BatState.PATROL
var player: Node2D = null


func _physics_process(delta):
	match state:
		BatState.PATROL:
			patrol(delta)

		BatState.ATTACK:
			attack()
		
		BatState.COOLDOWN:
			cooldown(delta)
			
		BatState.CHASE:
			chase()

	update_sprite_direction()
	move_and_slide()

func update_sprite_direction():
	if velocity.x > 0:
		$Animacaobat.flip_h = false
	elif velocity.x < 0:
		$Animacaobat.flip_h = true
		
func patrol(delta):
	print("Patrulhando")
	time += delta

	velocity.x = -speed
	velocity.y = sin(time * frequency) * amplitude
	anim.play("patrol")
	
func _on_detection_area_body_entered(body):
	if body.is_in_group("player"):
		player = body
		state = BatState.CHASE
		
var attack_speed = 200
@export var chase_speed := 120
@export var attack_cooldown := 1.5
@export var attack_distance := 40.0

func attack():
	print("Atacando")
	
	if player == null:
		state = BatState.PATROL
		return
		
	anim.play("attack")
	
	var direction = (player.global_position - global_position).normalized()
	velocity = direction * attack_speed
	
	$AttackCooldown.start()
	
	state = BatState.COOLDOWN
	
@export var detection_distance := 200.0

func chase():
	if player == null:
		state = BatState.PATROL
		return
		
	if global_position.distance_to(player.global_position) > detection_distance:
		player = null
		state = BatState.PATROL
		return
		
	var direction = (player.global_position - global_position).normalized()
	velocity = direction * chase_speed

	# Se chegou perto, inicia o ataque
	if global_position.distance_to(player.global_position) <= attack_distance:
		state = BatState.ATTACK

func cooldown(delta):
	velocity = Vector2.ZERO
	
func _ready():
	$HitBox.add_to_group("enemy_attack")


func _on_attack_cooldown_timeout() -> void:
	if player != null:
		state = BatState.CHASE
	else:
		state = BatState.PATROL
