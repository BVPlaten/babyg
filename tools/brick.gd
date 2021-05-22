const globalCnfgFile = "res://config/terominoes.json"


# ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
# ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
# class Box : helper to config a single box as part of a brick
#
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# 2021-05.22   bvp   initial realease
#
class Box:
	export var mtrl : SpatialMaterial			# the look (every box has an own instnce)
	export var texture : ImageTexture
	export var clr : Color

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
			clr = _random_color()
		else:
			clr = color
		mtrl.albedo_color = clr
	
		
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
	func _random_color():
		var rng = RandomNumberGenerator.new()
		return Color(rng.randf_range(0.0, 1.0),rng.randf_range(0.0, 1.0),rng.randf_range(0.0, 1.0))



# ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
# ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
# class ConfigLoader : load JSON file with the brick configuration
#                      the object in the json-file is converted to and stored in a dictionary. the bricks must have numeric keys
#                      the path to the file must be given in the constructor
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# 2021-05.22   bvp   initial realease
# 
class ConfigLoader:
	var config = null	# geometric info of a layer (2d matrix of booleans)
	const sizeX = 4
	const sizeY = 4

	# load the configureration-file given as param
	#		
	# parameter cfgFile : path to the JSON config-file
	# 
	func _init(cfgFile:String=""):
		if cfgFile == "":
			cfgFile = globalCnfgFile
		config = load_confg(cfgFile)

	# loads json configuration file and returns it as dict
	#
	# parameter filePath : path to the JSON config.-file
	# 
	func load_confg(filePath : String):
		var file = File.new()
		file.open(filePath, file.READ)
		var text = file.get_as_text()
		file.close()
		var cfg = JSON.parse(text)
		if cfg.error != OK:
			return
		return cfg.result


	# get_num_of_bricks : get the amount of configured bricks in the conf-dict
	#
	func get_num_of_bricks():
		if(config==null):
			return 0
		else:
			return config.size()


	# create_array : create a shematic 2d-matrix which represents the  positions
	#                of the boxes in the brick
	#
	func create_array(width : int,height : int):
		var map = []
		for i in range(width):
			var col = []
			col.resize(height)
			map.append(col)
		return map


	# create the boolean matrix for a brick as defined in the config-file
	#
	# parameter :  idx = which brick should be created (idx in JSON cfg)
	#
	func create_matrix(idx : int):
		var mtrx = create_array(sizeX,sizeX)
		var data = config[String(idx)]
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




# ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
# ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
# class Brick : it creates a brick 
#               a brick is a couple of boxes combined in a MultimeshInstance
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# 2021-05.22   bvp   initial realease
# 
class Brick:
	var lyrCfg
	var matrix        		# 2d array with boolean values to identify positions of boxes in the brick
	var index 				# the ID of this brick
	var positionArray = [] 	# array of boxes 

	# constructor - if id is not given a random brick will be created
	#
	func _init(idx:int=-1):
		lyrCfg = ConfigLoader.new()
		if idx < 0:
			var rng = RandomNumberGenerator.new()
			rng.randomize()
			index = rng.randi()%lyrCfg.get_num_of_bricks()
		else:
			index = idx
		create_brick(index)
		

	# create a brick by a given index 
	#
	func create_brick(idx):
		matrix = lyrCfg.create_matrix(idx)	# read the look of the block from config
		lyrCfg.print_matrix(matrix)
		positionArray = lyrCfg.get_pos_list(matrix)


