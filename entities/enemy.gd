extends CharacterBody2D

var speed = 100
var amplitude = 20
var frequency = 2.0
var time = 0.0

enum BatState {
	PATROL,
	ATTACK
}

var state = BatState.PATROL
var player: Node2D = null


func _physics_process(delta):
	match state:
		BatState.PATROL:
			patrol(delta)

		BatState.ATTACK:
			attack()
	update_sprite_direction()
	move_and_slide()

func update_sprite_direction():
	if velocity.x > 0:
		$AnimatedSprite2D.flip_h = false
	elif velocity.x < 0:
		$AnimatedSprite2D.flip_h = true
		
func patrol(delta):
	time += delta

	velocity.x = -speed
	velocity.y = sin(time * frequency) * amplitude
	
func _on_detection_area_body_entered(body):
	print("Entrou:", body.name)
	print(body.get_groups())
	
	if body.is_in_group("player"):
		print("Jogador detectado")
		player = body
		state = BatState.ATTACK


func _on_detection_area_body_exited(body):
	if body == player:
		player = null
		state = BatState.PATROL
		
var attack_speed = 200

func attack():
	print("Atacando")
	
	if player == null:
		return

	var direction = (player.global_position - global_position).normalized()

	velocity = direction * attack_speed

func _ready():
	$HitBox.add_to_group("enemy_attack")
