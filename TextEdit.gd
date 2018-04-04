extends TextEdit
export(NodePath) var path

signal sent(message)

func _ready():
	var send_button = get_node("../Button")
	send_button.connect("send", self, "send_message")

func _process(delta):
	pass
	
func send_message():
	if(self.text != ""):
		# select all the text
		self.select_all()
		
		# selected text is going to be the text we send
		var message = self.get_selection_text()
		
		# send a signal to "Messages" node to get message we send
		emit_signal("sent", message)
		
		# send 
		self.cut()
	
	
#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
