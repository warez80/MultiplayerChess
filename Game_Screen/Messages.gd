extends VBoxContainer

# sample message list

var messages = ["hello", "hey how are you?", "im not doing so well.", "why not?", "because u about to do die bc of this chess game"]
var children = []

func _ready():
	print("container reader")
	for i in range(0, 10*len(messages)):
		children.append(Label.new())
		children[i].text = messages[i % (len(messages))]
		
	#for i in range(0, len(children)):
	#	children[i].text = messages[i % (len(messages))]


func check_for_new_message():
	# add new child to children if there are any new messages
	pass

func _process(delta):
	
	# Check for new messages
	check_for_new_message()
	
	for i in range(0, len(children)):
		add_child(children[i])
	
	#var x = self.get_children();
	#print("number of children: " + str(self.get_child_count()))
	
		
	

	
#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
