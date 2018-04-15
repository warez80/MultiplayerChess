extends AnimatedSprite
var elapsed_time = 0

func _ready():
	set_process(true)

func _process(delta):
	
	elapsed_time = elapsed_time + delta
	
	if( elapsed_time > 0.2 ):
		if( get_frame() == self.get_sprite_frames().get_frame_count() - 1):
			set_frame(0)
		else:
			self.set_frame(get_frame() + 1)
			
		elapsed_time = 0
