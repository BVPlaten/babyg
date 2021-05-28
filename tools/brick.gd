# https://docs.godotengine.org/en/stable/getting_started/scripting/gdscript/gdscript_basics.html#classes


# const globalCnfgFile = "res://config/AdvancedBricks.json"     # for 3D Tetris



# ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
# ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
# class Brick : it creates a brick
#
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# 2021-05.22   bvp   initial realease
# 
class_name Brick

var brickFactory
const numberOfBricks = 7
const sizeOfSpace = {'X': 4, 'Y': 4, 'Z': 1}
const globalCnfgFile = "res://config/terominoes.json"

# constructor - if id is not given a random brick will be created
#
func _init(cfgFile:String=globalCnfgFile):
	brickFactory = BrickFactory.new(cfgFile,sizeOfSpace['X'],sizeOfSpace['Y'],sizeOfSpace['Z'])


# create a brick by a given index 
#
func create_brick(idx:int=-1):
	var index:int
	if idx < 0:
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		index = rng.randi()%numberOfBricks
	else:
		index = idx
	brickFactory.create_brick(index)


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
class ConfigLoader:
	var cfg									# the configuration as dictionary


	# load the configureration-file given as param
	#		
	# parameter configurationfile     : path configuration as dictionary
	# 
	func _init(configurationfile:String):
		load_confg(configurationfile)


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
			push_error("error loading config-file in ConfigLoader.load_confg()")
		cfg =  conf.result


	# get_config_amount : get the amount of configured bricks in the conf-dict
	#
	func get_config_amount():
		if(cfg==null):
			return     0
		else:
			return cfg.size()



# ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
# ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
# class BrickFactory : 
#                      
#                      
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# 2021-05-22   bvp   initial realease
class BrickFactory:
	var sizeX:int							# amount of boxes in configuration for this dimension
	var sizeY:int							#   "         "             "          "
	var sizeZ:int							#   "         "             "          "
	var config 								# configuration
	var matrix = [[[]]]                         # 3D Array as DataContainer for the MeshInstances

	# load the configureration-file given as param
	#		
	# parameter configurationfile     : path configuration as dictionary
	# 
	func _init(configurationfile:String, sX:int, sY:int, sZ:int ):
		sizeX = sX
		sizeY = sY
		sizeZ = sZ
		config = ConfigLoader.new(configurationfile).cfg


	# create_matrix : this is the main-function. it generates a matrix with boxes
	#
	# parameter :  idx = which brick should be created (idx in JSON cfg)
	#
	func create_brick(idx : int):
		create_array()
		for z in sizeZ:
			for y in sizeY:
				for x in sizeX:
					if (get_point(idx,x,y,z)):
						matrix[x][y][z] = '#'  # add_box_here
					else:
						matrix[x][y][z] = ' '


	# create_array : "memory-allocation" for the empty 3D matrix
	#
	func create_array():
		for z in sizeZ:
			matrix.resize(sizeZ)
			for y in sizeY:
				matrix[y].resize(sizeY)
				for x in sizeX:
					matrix[z][y].resize(sizeX)

				
	# get_point : returns true if the given point for the given brick-idx is set
	#             the first line in the configuration is the last line in the coord-system
	#             so there must be a coord-convesion to avoid becoming crazy
	#
	# parameter : idx : the index of the brick in the configuration
	#             x   : the x-coordinate
	#             y   : the y-coordinate
	#             z   : the z-coordinate
	#
	func get_point(idx:int, x:int, y:int, z:int):
		var data = config[String(idx)]
		if (data[str(x)][z][y] == '#'):
			return true
		else:
			return false


	# print a given matrx for debugging 
	#
	# parameter : mtrx is the matrix that should be printed
	#
	func text_of_matrix(mtrx=matrix):
		var txt = ""
		for x in sizeX:
			for y in sizeY:
				for z in sizeZ:
					txt += mtrx[x][y][z]
				txt += '\n'
			txt += '\n'
		txt += '\n'
		return txt


	# string representation 
	#
	func _to_string():
		var outP = "Size of the layer is " + str(sizeX) + " * " + str(sizeY) + " * " + str(sizeZ) + "\n"
		outP += text_of_matrix()
		outP += '\n'
		return outP


	# # get an Vector3-array with the coordinates of the given brick 
	# #
	# func get_pos_list(mtrx):
	# 	var coordArry = []
	# 	for y in range(sizeY):
	# 		for x in range(sizeX):
	# 			if (mtrx[x][y] == true):
	# 				var boxCrd = Vector3(x,y,0)
	# 				coordArry.append(boxCrd)
	# 	return coordArry
