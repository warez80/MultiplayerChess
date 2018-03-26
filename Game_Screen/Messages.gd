extends VBoxContainer
export(NodePath) var path


var messages = []
var message = ""

func _ready():
	# Check for new messages
	var textedit = get_node("../../../Text_Input/TextEdit")
	textedit.connect("sent", self, "add_new_message", [])

func add_new_message(message):
	
	#Todo: Get username and append to the front of the message
	
	# create a new label
	var to_add = Label.new()
	to_add.text = message
	
	# add new child to children if there are any new messages
	messages.append(to_add)
	add_child(messages[len(messages) - 1])

func _process(delta):
	pass
	