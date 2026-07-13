extends CharacterBody2D

const SPEED = 100.0

@onready var anim = $Animatedabobora
@onready var detection = $DetectionArea
@onready var attack_timer = $AttackTimer

enum AboboraState{
	IDLE,
	PATROL,
	ATTACK
}

var state = AboboraState.PATROL

var direction = -1
var player = null

func _ready():
	detection.body_entered.connect(_on_body_entered)
	detection.body_exited.connect(_on_body_exited)
	attack_timer.timeout.connect(_on_attack_timer_timeout)

func _physics_process(delta):

	if !is_on_floor():
		velocity += get_gravity() * delta

	match state:

		AboboraState.IDLE:
			idle()

		AboboraState.PATROL:
			patrol()

		AboboraState.ATTACK:
			attack()

	update_sprite_direction()
	move_and_slide()
	
func idle():
	anim.play("Idle")
	velocity.x = 0
	
func patrol():

	anim.play("Run")

	velocity.x = direction * SPEED

	if is_on_wall():
		direction *= -1
		
func attack():

	velocity.x = 0
	anim.play("Attack")

	if player:
		if player.global_position.x > global_position.x:
			anim.flip_h = false
		else:
			anim.flip_h = true

	if attack_timer.is_stopped():
		attack_timer.start()
		
func _on_body_entered(body):

	if body.is_in_group("Player"):
		player = body
		state = AboboraState.ATTACK
		
func _on_body_exited(body):

	if body == player:
		player = null
		state = AboboraState.PATROL
		
func _on_attack_timer_timeout():

	if player:
		print("Atacou!")

func update_sprite_direction():

	if state == AboboraState.ATTACK:
		return

	if velocity.x > 0:
		anim.flip_h = false
	elif velocity.x < 0:
		anim.flip_h = true
