extends Button

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
export(NodePath) var path

signal send
func _ready():
	print("button ready")
	pass
	
# when the button is pressed, it'll send
# a signal to all other nodes.
func _pressed():
	emit_signal("send")
	print("send")


func _process(delta):
	pass
