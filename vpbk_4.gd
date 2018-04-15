extends Sprite

var screen_height = ProjectSettings.get_setting("display/window/size/height") - 350
var screen_width  = ProjectSettings.get_setting("display/window/size/width") - 350
var direction     = Vector2(randi() % 5, randi() % 4)

func _process(delta):
	
	# basic
	position += direction
	
	if position.x >= screen_width or position.x <= 125:
		direction.x = -(direction.x)
	if position.y >= screen_height or position.y <= 125:
		direction.y = -(direction.y)
	