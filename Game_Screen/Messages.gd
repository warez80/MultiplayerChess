extends VBoxContainer

# sample message list

var messages = ["h", "e", "l", "l", "o", " ", "n", "a", "s", "s", "i", "f", "a", "n", "d", "j", "u", "n"]
var children = []

func _ready():
	
	for i in range(0, len(messages)):
		children.append(Control.new())

func check_for_new_message():
	# add new child to children if there are any new messages
	pass

func _process(delta):
	
	# Check for new messages
	check_for_new_message()
	
	for i in range(0, len(messages)):
		add_child(children[i])
	
	print("number of children: " + str(self.get_child_count()))

	
#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
