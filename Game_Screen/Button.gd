extends Button

export(NodePath) var path

signal send

func _ready():
	pass
	
# when the button is pressed, it'll send
# a signal to all other nodes.
func _pressed():
	emit_signal("send")
	

func _process(delta):
	pass
