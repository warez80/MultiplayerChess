extends ScrollContainer

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var background = Color(0, 255, 0)

func _ready():
	self.self_modulate = background
