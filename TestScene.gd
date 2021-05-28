extends Spatial

var xW = 5
var yW = 5
var zW = 5


# Called when the node enters the scene tree for the first time.
# https://www.reddit.com/r/godot/comments/ao2bkh/need_help_creating_a_3d_array/
#
func _ready():
	var brick = Brick.new()
	brick.create_brick()


# func make_multidim_array(width,height,depth):
# 	var array = []
# 	array.resize(width)    # X-dimension
# 	for x in width:    # this method should be faster than range since it uses a real iterator iirc
# 		array[x] = []
# 		array[x].resize(height)    # Y-dimension
# 		for y in height:
# 			array[x][y] = []
# 			array[x][y].resize(depth)    # Z-dimension
# 			for z in depth:
# 				array[x][y][z] = "valueTest"
# 	return array
