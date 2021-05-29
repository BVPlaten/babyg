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
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# 2021-05-21   bvp   initial realease
func _init(cfgFile:String=globalCnfgFile, sizeDict:Dictionary=sizeOfSpace):
	#prepare the brick creation with the cfg-file and the available dimension-sizes
	brickFactory = BrickFactory.new(cfgFile,sizeDict['X'],sizeDict['Y'],sizeDict['Z'])


# create a brick by a given index 
#
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# 2021-05-21   bvp   initial realease
func create_brick(idx:int=-1):
	var index:int
	if idx < 0:
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		index = rng.randi()%numberOfBricks
	else:
		index = idx
	brickFactory.create_brick(index)
	print(brickFactory)


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
# class BrickFactory : creates a matrix of box-mesh-instances from the form given in the configuration-file
#                      
#                      
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# 2021-05-22   bvp   initial realease
class BrickFactory:
	var sizeX:int							# amount of boxes in configuration for this dimension
	var sizeY:int							#   "         "             "          "
	var sizeZ:int							#   "         "             "          "
	var config 								# configuration-dict
	var matrix 								# 3D Array as DataContainer for the MeshInstances (boxes :-) )
	var brickIdx                            # brick of the index in the configuration

	# load the configureration-file given as param
	#		
	# parameter configurationfile  : path configuration as dictionary
	#            sX                : possible horizontal size of a brick
	#            sY                : possible vertical size of a brick
	#            sZ                : possible depth of a brick
	#
	# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	# 2021-05-29   bvp   initial realease
	func _init(configurationfile:String, sX:int, sY:int, sZ:int ):
		sizeX = sX
		sizeY = sY
		sizeZ = sZ
		brickIdx = null
		config = ConfigLoader.new(configurationfile).cfg


	# create_matrix : this is the main-function. it generates a matrix with boxes
	#
	# parameter :  idx = which brick should be created (idx in JSON cfg)
	#
	# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	# 2021-05-29   bvp   initial realease
	func create_brick(idx : int):
		matrix = create_array()
		brickIdx = idx
		for x in sizeX:
			for y in sizeY:
				for z in sizeZ:				
					if (get_point(idx,x,y,z)):
						matrix[x][y][z] = '#'  # add_box_here
					else:
						matrix[x][y][z] = ' '  # add null here


	# create_array : "memory-allocation" for the empty 3D matrix
	#
	# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	# 2021-05-29   bvp   initial realease
	func create_array(xS:int=sizeX, yS:int=sizeY, zS:int=sizeZ):
		var array = []
		array.resize(xS)    					# X-dimension
		for x in xS:    						# this method should be faster than range since it uses a real iterator iirc
			array[x] = []
			array[x].resize(yS)    				# Y-dimension
			for y in yS:
				array[x][y] = []
				array[x][y].resize(zS)    		# Z-dimension
				for z in zS:
					array[x][y][z] = null
		return array
		
				
	# get_point : returns true if the given point for the given brick-idx is set
	#             the first line in the configuration is the last line in the coord-system
	#             so there must be a coord-convesion to avoid becoming crazy
	#
	# parameter : idx : the index of the brick in the configuration
	#             x   : the x-coordinate
	#             y   : the y-coordinate
	#             z   : the z-coordinate
	#
	# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	# 2021-05-29   bvp   initial realease
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
	# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	# 2021-05-29   bvp   initial realease
	func text_of_matrix(mtrx=matrix):
		var txt = ""
		for x in sizeX:
			for y in sizeY:
				for z in sizeZ:
					txt += str(mtrx[x][y][z])
			txt += '\n'
		txt += '\n'
		return txt


	# string representation 
	#
	func _to_string():
		var outP = "Size of the layer is " + str(sizeX) + " * " + str(sizeY) + " * " + str(sizeZ) + "\n"
		outP += "configuration index of the brick : " + str(brickIdx) + " \n"
		outP += text_of_matrix()
		outP += '\n'
		return outP

