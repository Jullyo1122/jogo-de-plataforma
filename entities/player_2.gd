extends CharacterBody2D


enum PlayerState{
	idle,
	run,
	jump,
	demage,
	attack
}
@onready var anim: AnimatedSprite2D = $AnimacaoGirl

const SPEED = 200.0
const JUMP_VELOCITY = -400.0

var status = PlayerState
		
func _ready() -> void:	
	add_to_group("player")
	go_to_idle_state()

func _physics_process(delta: float) -> void:
	
	if not is_on_floor():
		velocity += get_gravity() * delta
		
		
	match status:
		
		PlayerState.idle:
			idle_state()
		PlayerState.run:
			run_state()
		PlayerState.jump:
			jump_state()
		PlayerState.demage:
			demage_state()
		PlayerState.attack:
			attack_state()
			
	move_and_slide()

func go_to_idle_state():
	status = PlayerState.idle
	anim.play("Idle")

func go_to_run_state():
	status = PlayerState.run
	anim.play("Run")
	
func go_to_jump_state():
	status = PlayerState.jump
	anim.play("Jump")
	velocity.y = JUMP_VELOCITY

func go_to_demage_state():
	status = PlayerState.demage
	anim.play("Demage")
	
func go_to_attack_state():
	status = PlayerState.attack
	anim.play("Attack")
	velocity.x = 0
	
func idle_state():
	move()
	if velocity.x != 0:
		go_to_run_state()
		return
	
	if Input.is_action_just_pressed("jump"):
		go_to_jump_state()
		return
	
	if Input.is_action_just_pressed("attack"):
		go_to_attack_state()
		return
	

func run_state():
	move()
	if velocity.x == 0:
		go_to_idle_state()
		return
	if Input.is_action_just_pressed("jump"):
		go_to_jump_state()
		return
	
	if Input.is_action_just_pressed("attack"):
		go_to_attack_state()
		return

	

func jump_state():
	move()
	if is_on_floor():
		if velocity.x == 0:
			go_to_idle_state()
		else:
			go_to_run_state()
		return
		
	if Input.is_action_just_pressed("attack"):
		go_to_attack_state()
		return

func demage_state():
	pass
	
func attack_state():
	if !anim.is_playing():
		go_to_idle_state()

func move():
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	if direction < 0:
		anim.flip_h = true 
	elif direction > 0:
		anim.flip_h = false

func _on_hit_box_area_entered(area):
	print(area.name)
	print(area.get_groups())

	if area.is_in_group("enemy_attack"):
		print("Tomou dano")
		go_to_demage_state()
