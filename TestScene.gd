extends Spatial


# Called when the node enters the scene tree for the first time.
# https://www.reddit.com/r/godot/comments/ao2bkh/need_help_creating_a_3d_array/
#
func _ready():
	# var brick = Brick.new()
	# brick.create_brick()

	var size = {'X': 4, 'Y': 4, 'Z': 4}
	var cnfgFile = "res://config/three_dim_test.json"

	var brick = Brick.new(cnfgFile,size)
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
