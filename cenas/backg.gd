extends Sprite2D

@onready var camera = $"../../../player2/Camera2D"

var offset_x = 250

func _process(delta):
	if camera:
		position.x = camera.position.x + offset_x
