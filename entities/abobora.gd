extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
@onready var anim: AnimatedSprite2D = $Animatedabobora
enum AboboraState{
	IDLE
}
	
var state = AboboraState.IDLE

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	match state:
		AboboraState.IDLE:
			idle()
		
	move_and_slide()

func idle():
	anim.play("Idle")
	
