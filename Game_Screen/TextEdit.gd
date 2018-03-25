extends TextEdit

func _ready():
	print("textbox ready")

func _process(delta):
	var send_button = get_node("../Button")
	send_button.connect("send", self, "send_message")
	
func send_message():
	if(self.text != ""):
		# need to send message and then clear the textEdit box
		pass
		
	
	
#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
