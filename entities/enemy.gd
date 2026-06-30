extends CharacterBody2D

var speed = 100
var amplitude = 20
var frequency = 2.0
var time = 0.0

@onready var anim: AnimatedSprite2D = $Animacaobat

enum BatState {
	PATROL,
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
	update_sprite_direction()
	move_and_slide()

func update_sprite_direction():
	if velocity.x > 0:
		$Animacaobat.flip_h = false
	elif velocity.x < 0:
		$Animacaobat.flip_h = true
		
func patrol(delta):
	time += delta

	velocity.x = -speed
	velocity.y = sin(time * frequency) * amplitude
	anim.play("patrol")
	
func _on_detection_area_body_entered(body):
	print("Entrou:", body.name)
	print(body.get_groups())
	
	if body.is_in_group("player"):
		print("Jogador detectado")
		player = body
		state = BatState.ATTACK
		anim.play("attack")


func _on_detection_area_body_exited(body):
	if body == player:
		player = null
		state = BatState.PATROL
		
var attack_speed = 200
@export var attack_cooldown := 1.5

func attack():
	print("Atacando")
	
	if player == null:
		return
		
	
	$AttackCooldown.start()
	
	var direction = (player.global_position - global_position).normalized()
	velocity = direction * attack_speed
	
	state = BatState.COOLDOWN
	
func cooldown(delta):
	pass
	
func _ready():
	$HitBox.add_to_group("enemy_attack")


func _on_attack_cooldown_timeout() -> void:
	if player != null:
		state = BatState.ATTACK
	else:
		state = BatState.PATROL
