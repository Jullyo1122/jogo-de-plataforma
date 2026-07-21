extends CharacterBody2D

const SPEED = 100.0

@onready var anim: AnimatedSprite2D = $Animatedabobora
@onready var detection: Area2D = $DetectionArea
@onready var attack_timer: Timer = $AttackTimer
@onready var wall_detector: RayCast2D = $WallDetector
enum AboboraState {
	IDLE,
	PATROL,
	ATTACK
}

var state = -1
var direction = -1
var player = null

func _ready():
	detection.body_entered.connect(_on_body_entered)
	detection.body_exited.connect(_on_body_exited)
	attack_timer.timeout.connect(_on_attack_timer_timeout)
	anim.animation_finished.connect(_on_animation_finished)

	change_state(AboboraState.PATROL)

func _physics_process(delta):
	
	print("Body: ", global_position)
	print("Sprite: ", anim.global_position)
	print("Collision: ", $Collisionabobora.global_position)
	print("Detection: ", detection.global_position)
	print("----------------")

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

			if player:
				anim.flip_h = player.global_position.x < global_position.x

	update_sprite_direction()
	move_and_slide()


func change_state(new_state):

	if state == new_state:
		return
		
	print("Mudando de", state, "para", new_state)
	
	state = new_state

	match state:

		AboboraState.PATROL:
			anim.play("Run")

		AboboraState.IDLE:
			anim.play("Idle")
			attack_timer.start(0.8)

		AboboraState.ATTACK:
			anim.play("attack")


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
