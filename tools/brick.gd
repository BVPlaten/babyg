# https://docs.godotengine.org/en/stable/getting_started/scripting/gdscript/gdscript_basics.html#classes

const globalCnfgFile = "res://cfgFile/terominoes.json"
# const globalCnfgFile = "res://cfgFile/AdvancedBricks.json"     # for 3D Tetris



# ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
# ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
# class Brick : it creates a brick
#
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# 2021-05.22   bvp   initial realease
# 
class_name Brick


var lyrCfg
var matrix        		# 2d array with boolean values to identify positions of boxes in the brick
var index 				# the ID of this brick
var positionArray = [] 	# array of boxes 

# constructor - if id is not given a random brick will be created
#
func _init(idx:int=-1):
	lyrCfg = ConfigLoader.new(globalCnfgFile,4,4,1)
	if idx < 0:
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		index = rng.randi()%lyrCfg.get_num_of_bricks()
	else:
		index = idx
	#create_brick(index) !!!!
	

# create a brick by a given index 
#
func create_brick(idx):
	matrix = lyrCfg.create_matrix(idx)	# read the     look of configuration as dictionary
	lyrCfg.print_matrix(matrix)
	positionArray = lyrCfg.get_pos_list(matrix)


# ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
# ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###                          # 3D Array as DataContainer for the MeshInstances### ### ### ### ### ### ### ### ### ###
#     class Box configuration as dictionary
#
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# 2021-05.22   bvp   initial realease
#
class Box:
	export var mtrl : SpatialMaterial		                         # 3D Array as DataContainer for the MeshInstances	# the look (every box has an own instnce)
	export var texture : ImageTexture
	export var colr : Color

	# constructor
	#
	func _init():
		mtrl = SpatialMaterial.new()
		texture = ImageTexture.new()

		
	# apply_color : change the color of the MeshInstance
	#
	# parameter : color   : the color of the box
	#                       null for random color
	func apply_color(color):
		if(color == null):
			colr = random_color()
		else:
			colr = color
		mtrl.albedo_color = colr

		
	# apply_texture : set a texture to the single box
	#
	# parameter : txtr_path path to the image-file
	#
	func apply_texture(txtr_path : String):
		if(txtr_path == ""):
			push_warning("no texture in Box.apply_texture(..)")
			return
		var image = Image.new()
		image.load(txtr_path)
		texture.create_from_image(image)
		mtrl.albedo_texture = texture
		

	# _random_color : returns a random color 
	#
	func random_color():
		var rng = RandomNumberGenerator.new()
		return Color(rng.randf_range(0.0, 1.0),rng.randf_range(0.0, 1.0),rng.randf_range(0.0, 1.0))

# ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
# ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
# class ConfigLoader : load JSON file with the brick configuration
#                      the object in the json-file is converted to and stored in a dictionary. the bricks must have numeric keys
#                      the path to the file must be given in the constructor
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# 2021-05.22   bvp   initial realease
    #  configuration as dictionary
class ConfigLoader:
	var cfg									# the configuration as dictionary
	var sizeX:int							# amount of boxes in configuration for this dimension
	var sizeY:int							#   "         "             "          "
	var sizeZ:int							#   "         "             "          "
	var matrix = []                         # 3D Array as DataContainer for the MeshInstances

	# load the configureration-file given as param
	#		
	# parameter configurationfile     : path configuration as dictionary
	# 
	func _init(configurationfile:String, sX:int, sY:int, sZ:int ):
		sizeX = sX
		sizeY = sY
		sizeZ = sZ
		cfg = load_confg(configurationfile)

	# loads json configuration file and returns it as dict
	#
	# parameter filePath     : path configuration as dictionary
	#
	func load_confg(filePath : String):
		var file = File.new()
		file.open(filePath, file.READ)
		var text = file.get_as_text()
		file.close()
		var conf = JSON.parse(text)
		if conf.error != OK:
			return
		return conf.result


	# get_num_of_bricks : get the amount of configured bricks in the conf-dict
	#
	func get_num_of_bricks():
		if(cfg==null):
			return     0
		else:
			return cfg.size()

	# create_array : creates a 3D matrix for the boxes of e
	#
	func create_array():
		matrix.resize(sizeX)
		for x in matrix:
			var yA = []
			yA.resize(sizeY)
			for z in yA:
				var zA = []
				zA.resize(sizeZ)
				z = zA
			x = yA



	# create the boolean matrix for a     brick as configuration as dictionary
	#
	# parameter :  idx = which brick should be created (idx in JSON cfg)
	#
	func create_matrix(idx : int):
		var mtrx = create_array()
		var data = cfg[String(idx)]
		for y in range(sizeY):
			var line = data[String(y)]
			for x in range(sizeX):
				var point = line[x]
				if (point == '#'):
					mtrx[x][y] = true
				else:
					mtrx[x][y] = false
		return mtrx
	

	# print a given matrx for debugging 
	#
	# parameter : mtrx is the matrix that should be printed
	#
	func print_matrix(mtrx):
		var line = ""
		for y in range(sizeY):
			for x in range(sizeX):
				if (mtrx[x][y] == true):
					line += "X"
				else:
					line += "."
			print(line)
			line = ""
	

	# get an Vector3-array with the coordinates of the given brick 
	#
	func get_pos_list(mtrx):
		var coordArry = []
		for y in range(sizeY):
			for x in range(sizeX):
				if (mtrx[x][y] == true):
					var boxCrd = Vector3(x,y,0)
					coordArry.append(boxCrd)
		return coordArry


	# string representation 
	#
	func _to_string():
		return "Size of the layer is " + str(sizeX) + " * " + str(sizeY)






