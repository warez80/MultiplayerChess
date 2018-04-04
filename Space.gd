extends GridContainer

const row = 8
const col = 8
const width  = 123
const height = 123

var spaces = []
var init = false

func spaces_init():
	for i in range(0, row):
		for j in range(0, col):
			# Each child will be a textrect, and we want 64 of them
			var child = TextureRect.new()
			spaces.append(child)
			
	for i in range(0, row):
		for j in range(0, col):
			self.add_child(spaces[i + j*row])
			
	for b in self.get_children():
		print(b)
	
	init = true

func _ready():
	# We only want to initial spaces array once. We will also repeatedly use this method
	# for connecting to other nodes, so there is a risk of us adding more elements to 
	# the spaces array. To avoid that, we have the init boolean
	if(!init):
		spaces_init()
		


