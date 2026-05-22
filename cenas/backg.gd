extends Sprite2D
@onready var camera = $"../player2/Camera2D"

func _process(delta):
	global_position.x = camera.global_position.x
