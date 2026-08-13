extends CharacterBody2D

const SPEED = 100.0

@onready var anim: AnimatedSprite2D = $Animatedabobora
@onready var detection: Area2D = $DetectionArea
@onready var attack_timer: Timer = $AttackTimer
@onready var wall_detector: RayCast2D = $WallDetector
@onready var attack_hitbox: CollisionShape2D = $Hitbox/CollisionShape2D

enum AboboraState {
	IDLE,
	PATROL,
	ATTACK
}

var state = -1
var direction = -1
var player = null

func _ready():
	
	anim.flip_h = true
	
	detection.body_entered.connect(_on_body_entered)
	detection.body_exited.connect(_on_body_exited)
	attack_timer.timeout.connect(_on_attack_timer_timeout)
	anim.animation_finished.connect(_on_animation_finished)
	
	$Hitbox.add_to_group("abobora_attack")

	change_state(AboboraState.PATROL)
	
func _physics_process(delta):
	
	if !is_on_floor():
		velocity += get_gravity() * delta

	match state:

		AboboraState.PATROL:
			velocity.x = direction * SPEED

			if wall_detector.is_colliding():
				direction *= -1
				anim.flip_h = direction < 0
				wall_detector.target_position.x *= -1

		AboboraState.IDLE:
			velocity.x = 0

		AboboraState.ATTACK:
			velocity.x = 0

	update_sprite_direction()
	move_and_slide()


func change_state(new_state):
	if state == new_state:
		return

	state = new_state
	var attack_direction = 1

	match state:

		AboboraState.PATROL:
			anim.play("Run")

		AboboraState.IDLE:
			anim.play("Idle")
			attack_timer.start(0.8)

		AboboraState.ATTACK:
			if player:
				print("Posição Player: ", player.global_position.x, " | Posição Inimigo: ", global_position.x)
				
				# Checagem literal e super simples:
				if player.global_position.x < global_position.x:
					print("Decisão: Player está na ESQUERDA")
					anim.flip_h = true
					$Hitbox.position.x = -20.0 # Move a Area2D inteira para a esquerda
				else:
					print("Decisão: Player está na DIREITA")
					anim.flip_h = false
					$Hitbox.position.x = 20.0  # Move a Area2D inteira para a direita
				
			anim.play("attack")
			
			await get_tree().create_timer(1.0).timeout
			
			if state != AboboraState.ATTACK:
				return
				
			attack_hitbox.set_deferred("disabled", false)
			await get_tree().create_timer(0.55).timeout
			attack_hitbox.set_deferred("disabled", true)
			
func _on_body_entered(body):

	if body.is_in_group("player"):
		player = body
		change_state(AboboraState.ATTACK)


func _on_body_exited(body):

	if body == player:
		player = null
		change_state(AboboraState.PATROL)


func _on_animation_finished():
	print("Terminou:", anim.animation)
	
	if anim.animation == "attack":

		if player:
			change_state(AboboraState.IDLE)
		else:
			change_state(AboboraState.PATROL)

func _on_attack_timer_timeout():

	if player:
		change_state(AboboraState.ATTACK)
	else:
		change_state(AboboraState.PATROL)

func update_sprite_direction():

	if state == AboboraState.ATTACK:
		return

	if velocity.x > 0:
		anim.flip_h = false
	elif velocity.x < 0:
		anim.flip_h = true

func attack():
	print("ATAQUE")


	
